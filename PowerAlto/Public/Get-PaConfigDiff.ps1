function Get-PaConfigDiff {
    [CmdletBinding()]
    Param (
    )

    BEGIN {
        $RunningConfig = Invoke-PaApiOperation '<show><config><running/></config></show>'
        $CandidateConfig = Invoke-PaApiOperation '<show><config><candidate/></config></show>'
    }

    PROCESS {
        # Format Xml for comparison
        $RunningConfig = [HelperXml]::SplitXml($RunningConfig)
        $CandidateConfig = [HelperXml]::SplitXml($CandidateConfig)

        Compare-Object $RunningConfig $CandidateConfig
        # Would like to clean this up a bit and return output that's useful
    }
}