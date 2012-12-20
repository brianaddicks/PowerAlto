function Get-PaConnectionString {
	<#
	.SYNOPSIS
		Connects to a Palo Alto firewall and returns an connection string with API key.
	.DESCRIPTION
		Connects to a Palo Alto firewall and returns an connection string with API key. Return values are added to $global:PaConnectionArray
	.EXAMPLE
		C:\PS> Connect-Pa 192.168.1.1
        https://192.168.1.1/api/?key=LUFRPT1SanJaQVpiNEg4TnBkNGVpTmRpZTRIamR4OUE9Q2lMTUJGREJXOCs3SjBTbzEyVSt6UT01

        c:\PS> $global:PaConnectionArray

        ConnectionString                 ApiKey                           Address
        ----------------                 ------                           -------
        https://10.10.42.72/api/?key=... LUFRPT1SanJaQVpiNEg4TnBkNGVpT... 10.10.42.72
	.EXAMPLE
		C:\PS> Connect-Pa -Address 192.168.1.1 -Cred $PSCredential
        https://192.168.1.1/api/?key=LUFRPT1SanJaQVpiNEg4TnBkNGVpTmRpZTRIamR4OUE9Q2lMTUJGREJXOCs3SjBTbzEyVSt6UT01
	.PARAMETER Address
		Specifies the IP or FQDN of the system to connect to.
    .PARAMETER Cred
        Specifiy a PSCredential object, If no credential object is specified, the user will be prompted.
    .OUTPUTS
        System.String
	#>

    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [ValidatePattern("\d+\.\d+\.\d+\.\d+|(\w\.)+\w")]
        [string]$Address,

        [Parameter(Mandatory=$True,Position=1)]
        [System.Management.Automation.PSCredential]$Cred
    )

    BEGIN {
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        Add-Type -AssemblyName System.Management.Automation

        $global:PaConnectionArray = @()
        $Connection = @{}
        $ConnectionProps = @("Address","ApiKey","ConnectionString")
        foreach ($Value in $ConnectionProps) {
            $Connection.Add($Value,$null)
        }
    }

    PROCESS {
        $user = $cred.UserName.Replace("\","")
        $ApiKey = ([xml]$WebClient.DownloadString("https://$Address/api/?type=keygen&user=$user&password=$($cred.getnetworkcredential().password)"))
        if ($ApiKey.response.status -eq "success") {
            $CurrentConnection = New-Object PsObject -Property $Connection
            $CurrentConnection.Address = $Address
            $CurrentConnection.ApiKey = $ApiKey.response.result.key
            $CurrentConnection.ConnectionString = "https://$Address/api/?key=$($ApiKey.response.result.key)"
            #$CurrentConnection
            $global:PaConnectionArray += $CurrentConnection
            return "https://$Address/api/?key=$($ApiKey.response.result.key)"
        } else {
            Throw "$($ApiKey.response.result.msg)"
        }
    }
}

