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

    $MkDocsYamlPath = Join-Path -Path $env:BHProjectPath -ChildPath 'mkdocs.yml'

    If ($ENV:BHBuildSystem -ne 'AppVeyor') {
        # Create mkdocs.yml file for readthedocs, would love to use powershell-yaml for this, but it was unreliable at best
        $mkdocs = "site_name: $($env:BHProjectName) Docs`r`n"
        $mkdocs += "theme: readthedocs`r`n"
        $mkdocs += "pages:`r`n"
        $mkdocs += "  - Home: index.md`r`n"
        $mkdocs += "  - Cmdlets:`r`n"

        Import-Module $env:BHPSModulePath
        $Cmdlets = Get-Command -Module $env:BHProjectName
        foreach ($cmdlet in $Cmdlets) {
            $mkdocs += "    - $($cmdlet.Name): cmdlets/$($cmdlet.Name).md`r`n"
        }

        $mkdocs | Out-File -FilePath $MkDocsYamlPath -Force
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