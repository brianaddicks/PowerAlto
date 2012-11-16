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
        [System.Management.Automation.PSCredential]$Cred
    )

    BEGIN {
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        Add-Type -AssemblyName System.Management.Automation
    }

    PROCESS {
        $user = $cred.UserName.Replace("\","")
        $ApiKey = ([xml]$WebClient.DownloadString("https://$Address/api/?type=keygen&user=$user&password=$($cred.getnetworkcredential().password)"))
        if ($ApiKey.response.status -eq "success") {
            return "https://$Address/api/?key=$($ApiKey.response.result.key)"
        } else {
            Throw "$($ApiKey.response.result.msg)"
        }
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
        $SystemInfo = ([xml]$WebClient.DownloadString($Url)).response.result.system
        return $SystemInfo
        
    }
}

function Get-PaCustom {
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$PaConnectionString,

        [Parameter(Mandatory=$True,Position=1)]
        [string]$Type,

        [Parameter(Mandatory=$True,Position=2)]
        [string]$Action,

        [Parameter(Mandatory=$True,Position=3)]
        [string]$XPath
    )

    BEGIN {
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    }

    PROCESS {
        $url = "$PaConnectionString&type=$type&action=$action&xpath=$xpath"
        $CustomData = [xml]$WebClient.DownloadString($Url)
        if ($CustomData.response.status -eq "success") {
            return $CustomData
        } else {
            Throw "$($CustomData.response.result.msg)"
        }
    }
}



function Get-PaRules {
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$PaConnectionString
    )

    BEGIN {

    }

    PROCESS {
        $type = "config"
        $action = "show"
        $xpath = "/config/devices/entry/vsys/entry/rulebase/security/rules"
        $SecurityRulebase = (Get-PaCustom $PaConnectionString $type $action $xpath).response.result.rules.entry

        #Create hashtable for SecurityRule PSObject.  For new properties just append string to $ExportString
        $SecurityRule = @{}
        $ExportString = @("Name","Description","Tag","SourceZone","SourceAddress","SourceNegate","SourceUser","HipProfile","DestinationZone","DestinationAddress","DestinationNegate","Application","Service","UrlCategory","Action","ProfileType","ProfileGroup","ProfileVirus","ProfileVuln","ProfileSpy","ProfileUrl","ProfileFile","ProfileData","LogStart","LogEnd","LogForward","DisableSRI","Schedule","QosType","QosMarking")

        foreach ($Value in $ExportString) {
            $SecurityRule.Add($Value,$null)
        }

        $SecurityRules = @()

        #Covert results into PSobject
        foreach ($entry in $SecurityRulebase) {
            $CurrentRule = New-Object PSObject -Property $SecurityRule
                $CurrentRule.Name               = $entry.name
                $CurrentRule.Description        = $entry.description
                $CurrentRule.Tag                = $entry.tag.member
                $CurrentRule.SourceZone         = $entry.from.member
                $CurrentRule.SourceAddress      = $entry.source.member
                $CurrentRule.SourceNegate       = $entry."negate-source"
                $CurrentRule.SourceUser         = $entry."source-user".member
                $CurrentRule.HipProfile         = $entry."hip-profiles".member
                $CurrentRule.DestinationZone    = $entry.to.member
                $CurrentRule.DestinationAddress = $entry.destination.member
                $CurrentRule.DestinationNegate  = $entry."negate-destination"
                $CurrentRule.Application        = $entry.application.member
                $CurrentRule.Service            = $entry.service.member
                $CurrentRule.UrlCategory        = $entry.category.member
                $CurrentRule.Action             = $entry.action
                if ($entry."profile-setting".group) {
                    $CurrentRule.ProfileGroup   = $entry."profile-setting".group.member
                    $CurrentRule.ProfileType    = "group"
                } elseif ($entry."profile-setting".profiles) {
                    $CurrentRule.ProfileType    = "profiles"
                    $CurrentRule.ProfileVirus   = $entry."profile-setting".profiles.virus.member
                    $CurrentRule.ProfileVuln    = $entry."profile-setting".profiles.vulnerability.member
                    $CurrentRule.ProfileSpy     = $entry."profile-setting".profiles.spyware.member
                    $CurrentRule.ProfileUrl     = $entry."profile-setting".profiles."url-filtering".member
                    $CurrentRule.ProfileFile    = $entry."profile-setting".profiles."file-blocking".member
                    $CurrentRule.ProfileData    = $entry."profile-setting".profiles."data-filtering".member
                }
                $CurrentRule.LogStart           = $entry."log-start"
                $CurrentRule.LogEnd             = $entry."log-end"
                $CurrentRule.LogForward         = $entry."log-setting"
                $CurrentRule.Schedule           = $entry.schedule
                if ($entry.qos.marking."ip-dscp") {
                    $CurrentRule.QosType        = "ip-dscp"
                    $CurrentRule.QosMarking     = $entry.qos.marking."ip-dscp"
                } elseif ($entry.qos.marking."ip-precedence") {
                    $CurrentRule.QosType        = "ip-precedence"
                    $CurrentRule.QosMarking     = $entry.qos.marking."ip-precedence"
                }
                $CurrentRule.DisableSRI         = $entry.option."disable-server-response-inspection"
        

            $SecurityRules += $CurrentRule
        }
        return $SecurityRules | select $ExportString
    }
}

