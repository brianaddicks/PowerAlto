<# if (-not $ENV:BHProjectPath) {
    Set-BuildEnvironment -Path $PSScriptRoot\..
}
Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue
Import-Module (Join-Path $ENV:BHProjectPath $ENV:BHProjectName) -Force

InModuleScope $ENV:BHProjectName {
    $PSVersion = $PSVersionTable.PSVersion.Major
    $ProjectRoot = $ENV:BHProjectPath

    $Verbose = @{ }
    if ($ENV:BHBranchName -notlike "master" -or $env:BHCommitMessage -match "!verbose") {
        $Verbose.add("Verbose", $True)
    }

    Describe "Remove-PaIpsecTunnel" {
        #region dummydata
        ########################################################################

        ########################################################################
        #endregion dummydata

        #region firstTest
        ########################################################################
        Context FirstTest {
            It "should pass the first test" {
            }
        }
        ########################################################################
        #endregion firstTest
    }
}
 #>