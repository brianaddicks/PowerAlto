# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
    $ProjectRoot = $ENV:BHProjectPath
    if (-not $ProjectRoot) {
        $ProjectRoot = $PSScriptRoot
    }

    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $CoverageFile = "CoverageResults_PS$PSVersion`_$TimeStamp.xml"
    $CoverageFile = "cov.xml"
    $lines = '----------------------------------------------------------------------'

    $Verbose = @{}
    if ($ENV:BHCommitMessage -match "!verbose") {
        $Verbose = @{Verbose = $True}
    }
}

Task Default -Depends Deploy

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
}

Task Test -Depends Init {
    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    # Gather test results. Store them in a variable and file
    $CodeCoverageFiles = (Get-ChildItem "$ProjectRoot/$($ENV:BHProjectName)" -Recurse -File -Filter *.ps1).FullName
    $TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile" -CodeCoverage $CodeCoverageFiles -CodeCoverageOutputFile "$ProjectRoot\$CoverageFile"

    # In Appveyor?  Upload our tests! #Abstract this into a function?
    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
            "$ProjectRoot\$TestFile" )
    }

    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue

    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if ($TestResults.FailedCount -gt 0) {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
    "`n"
}

Task Build -Depends Test {
    $lines

    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        # Load the module, read the exported functions, update the psd1 FunctionsToExport
        Set-ModuleFunctions
    }

    If ($ENV:BHBuildSystem -ne 'AppVeyor') {
        # Bump the module version
        Update-Metadata -Path $env:BHPSModuleManifest
    }
}

Task Documentation -Depends Build {
    $lines

    $DocRoot = Join-Path -Path $env:BHProjectPath -ChildPath 'docs'
    $MkDocsYamlPath = Join-Path -Path $env:BHProjectPath -ChildPath 'mkdocs.yml'
    $DocCmdletPath = Join-Path -Path $DocRoot -ChildPath 'cmdlets'
    $DocExternalHelpPath = Join-Path $env:BHPSModulePath -ChildPath 'en-US'

    If ($ENV:BHBuildSystem -ne 'AppVeyor') {
        # Create mkdocs.yml file for readthedocs
        $mkdocs = [ordered]@{
            site_name = "$($env:BHProjectName) Docs"
            theme     = 'readthedocs'
            pages     = @()
        }
        $mkdocs.pages += @{ Home = 'index.md' }
        Import-Module $env:BHPSModulePath
        $Cmdlets = Get-Command -Module $env:BHProjectName
        $OrderedCmdlets = @()
        foreach ($cmdlet in $Cmdlets) {
            $CmdletName = $cmdlet.Name
            $OrderedCmdlets += @{"$CmdletName" = "cmdlets/$CmdletName`.md"}
        }
        $mkdocs.pages += @{cmdlets = $OrderedCmdlets}

        $mkdocs | ConvertTo-Yaml | Out-File -FilePath $MkDocsYamlPath -Force

        ## Update help with PlatyPS

        # Mark Down Help
        $ExistingMarkDownFiles = Get-ChildItem -Path $DocCmdletPath
        $MissingMarkDownFiles = $Cmdlets | Where-Object { $ExistingMarkDownFiles.BaseName -notcontains $_.Name }
        foreach ($file in $MissingMarkDownFiles) {
            $MissingName = $file.Name
            Write-Host "Added MarkDowm help for $MissingName"
            $NewMarkdownFile = New-MarkdownHelp -Command $MissingName -OutputFolder $DocCmdletPath

        }

        Write-host "Updating MarkDown help in $DocCmdletPath"
        $UpdateMarkdownHelp = Update-MarkdownHelp -Path $DocCmdletPath

        # External Help File
        Write-Host "Updating External help file in $DocExternalHelpPath"
        $UpdateExternalHelp = New-ExternalHelp -Path $DocCmdletPath -OutputPath $DocExternalHelpPath -Force
    }
}

Task Deploy -Depends Documentation {
    $lines

    $Params = @{
        Path    = $ProjectRoot
        Force   = $true
        Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
    }
    Invoke-PSDeploy @Verbose @Params
}