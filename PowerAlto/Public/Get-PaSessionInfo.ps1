function Get-PaSessionInfo {
    [CmdletBinding()]
    Param (
    )

    BEGIN {
        $VerbosePrefix = "Get-PaSessionInfo:"
        $Cmd = '<show><session><info></info></session></show>'
    }

    PROCESS {
        $Query = Invoke-PaApiOperation -Cmd $Cmd
        $Results = $Query.response.result
        #Write-Verbose $Results

        $ReturnObject = "" | Select-Object SupportedSessions, AllocatedSessions, TcpSessions, UdpSessions, SessionsSinceBoot

        $ReturnObject.SupportedSessions = $Results.'num-max'
        $ReturnObject.AllocatedSessions = $Results.'num-active'
        $ReturnObject.TcpSessions = $Results.'num-tcp'
        $ReturnObject.UdpSessions = $Results.'num-udp'
        $ReturnObject.SessionsSinceBoot = $Results.'num-installed'

        $ReturnObject
    }
}