function Get-PaConnectionString {
	<#
	.SYNOPSIS
		Connects to a Palo Alto firewall and returns an connection string with API key.
	.DESCRIPTION
		Connects to a Palo Alto firewall and returns an connection string with API key.
	.EXAMPLE
		Connect-Pa -Address 192.168.1.1 -Cred PSCredential
	.EXAMPLE
		Connect-Pa 192.168.1.1
	.PARAMETER Address
		Specifies the IP or DNS name of the system to connect to.
    .PARAMETER User
        Specifies the username to make the connection with.
    .PARAMETER Password
        Specifies the password to make the connection with.
	#>

    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Address,

        [Parameter(Mandatory=$True,Position=1)]
        [PSCredential]$Cred
    )

    BEGIN {
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    }

    PROCESS {
        $ApiKey = ([xml]$WebClient.DownloadString("https://$Address/api/?type=keygen&user=$($cred.username)&password=$($cred.getnetworkcredential().password)")).response.result.key
        return "https://$Address/api/?key=$Apikey"
        
    }
}

function Get-PaSystemInfo {
	<#
	.SYNOPSIS
		Returns the version number of various components of a Palo Alto firewall.
	.DESCRIPTION
		Returns the version number of various components of a Palo Alto firewall.
	.EXAMPLE
        Get-PaVersion -PaConnectionString https://192.168.1.1/api/?key=apikey
	.EXAMPLE
		Get-PaVersion https://192.168.1.1/api/?key=apikey
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey.
	#>

    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$PaConnectionString
    )

    BEGIN {
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    }

    PROCESS {
        $Url = "$PaConnectionString&type=op&cmd=<show><system><info></info></system></show>"
        $SoftwareVersion = ([xml]$WebClient.DownloadString($Url)).response.result.system
        return $SoftwareVersion
        
    }
}

function Get-PaRunningConfig {
	<#
	.SYNOPSIS
		Returns the running configuratino of a Palo Alto firewall.
	.DESCRIPTION
		Returns the running configuratino of a Palo Alto firewall.
	.EXAMPLE
        Get-PaRunningConfig -PaConnectionString https://192.168.1.1/api/?key=apikey
	.EXAMPLE
		Get-PaRunningConfig https://192.168.1.1/api/?key=apikey
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey.
	#>

    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$PaConnectionString

#        [Parameter(Mandatory=$True,Position=1)]
#        [string]$Path
    )

    BEGIN {
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    }

    PROCESS {
        $Url = "$PaConnectionString&type=export&category=configuration"
        [xml]$doc = $WebClient.DownloadString($Url)
        "Downloaded to $Path"
        return [xml]$doc
    }
}
