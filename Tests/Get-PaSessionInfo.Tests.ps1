<# if (-not $ENV:BHProjectPath) {
    Set-BuildEnvironment -Path $PSScriptRoot\..
}
Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue
Import-Module (Join-Path $ENV:BHProjectPath $ENV:BHProjectName) -Force


InModuleScope $ENV:BHProjectName {
    BeforeAll {
        $PSVersion = $PSVersionTable.PSVersion.Major
        $ProjectRoot = $ENV:BHProjectPath

        $Verbose = @{}
        if ($ENV:BHBranchName -notlike "master" -or $env:BHCommitMessage -match "!verbose") {
            $Verbose.add("Verbose", $True)
        }

        Mock -CommandName Invoke-PaApiOperation {
            return @{
                response = @{
                    result = @{
                        'num-max'       = 1000;
                        'num-active'    = 900;
                        'num-tcp'       = 800;
                        'num-udp'       = 700;
                        'num-installed' = 600
                    }
                }
            }
        } -Verifiable
    }

    Describe "Get-PaSessionInfo" {
        $SessionInfo = Get-PaSessionInfo
        It "Should return correct SupportedSessions" {
            $SessionInfo.SupportedSessions | Should -BeExactly 1000
        }
        It "Should return correct AllocatedSessions" {
            $SessionInfo.AllocatedSessions | Should -BeExactly 900
        }
        It "Should return correct TcpSessions" {
            $SessionInfo.TcpSessions | Should -BeExactly 800
        }
        It "Should return correct UdpSessions" {
            $SessionInfo.UdpSessions | Should -BeExactly 700
        }
        It "Should return correct SessionsSinceBoot" {
            $SessionInfo.SessionsSinceBoot | Should -BeExactly 600
        }
    }
} #>