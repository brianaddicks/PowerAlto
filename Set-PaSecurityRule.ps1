function Set-PaSecurityRule {
	<#
	.SYNOPSIS
		Edits settings on a Palo Alto Security Rule
	.DESCRIPTION
		Edits settings on a Palo Alto Security Rule
	.EXAMPLE
        Needs to write some examples
	.EXAMPLE
		Needs to write some examples
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey.
	#>
    
    Param (
        #[Parameter(Mandatory=$True,Position=0)]
        #[string]$PaConnectionString,

        [Parameter(Mandatory=$True,Position=0)]
        [string]$Name,

        [alias('r')]
        [string]$Rename,

        [alias('d')]
        [string]$Description,

        [alias('t')]
        [string]$Tag,

        [alias('sz')]
        [string]$SourceZone,

        [alias('sa')]
        [string]$SourceAddress,

        [alias('su')]
        [string]$SourceUser,

        [alias('h')]
        [string]$HipProfile,

        [alias('dz')]
        [string]$DestinationZone,

        [alias('da')]
        [string]$DestinationAddress,

        [alias('app')]
        [string]$Application,

        [alias('s')]
        [string]$Service,

        [alias('u')]
        [string]$UrlCategory,

        [alias('sn')]
        [ValidateSet("yes","no")]
        [string]$SourceNegate,

        [alias('dn')]
        [ValidateSet("yes","no")] 
        [string]$DestinationNegate,

        [alias('a')]
        [ValidateSet("allow","deny")] 
        [string]$Action,

        [alias('ls')]
        [ValidateSet("yes","no")] 
        [string]$LogStart,

        [alias('le')]
        [ValidateSet("yes","no")] 
        [string]$LogEnd,

        [alias('lf')]
        [string]$LogForward,

        [alias('sc')]
        [string]$Schedule,

        [alias('dis')]
        [ValidateSet("yes","no")]
        [string]$Disabled,

        [alias('pg')]
        [string]$ProfileGroup,

        [alias('pvi')]
        [string]$ProfileVirus,

        [alias('pvu')]
        [string]$ProfileVuln,

        [alias('ps')]
        [string]$ProfileSpy,

        [alias('pu')]
        [string]$ProfileUrl,

        [alias('pf')]
        [string]$ProfileFile,

        [alias('pd')]
        [string]$ProfileData,

        [alias('qd')]
        [ValidateSet("none","af11","af12","af13","af21","af22","af23","af31","af32","af33","af41","af42","af43","cs0","cs1","cs2","cs3","cs4","cs5","cs6","cs7","ef")] 
        [string]$QosDscp,

        [alias('qp')]
        [ValidateSet("none","cs0","cs1","cs2","cs3","cs4","cs5","cs6","cs7")] 
        [string]$QosPrecedence,

        [alias('ds')]
        [ValidateSet("yes","no")] 
        [string]$DisableSri
    )

    BEGIN {
        Test-PaConnection
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        $type = "config"

        function EditProperty ($parameter,$element,$xpath) {
            if ($parameter) {
                if ($parameter -eq "none") { $action = "delete" } `
                    else                   { $action = "edit" }
                $Response = Send-PaApiQuery -Config $action -XPath $xpath -Element $element -Member $parameter
                if ($Response.response.status -eq "success") {
                    return "$element`: success"
                } else {
                    throw $Response.response.msg.line
                }
            }
        }
    }

    PROCESS {
        foreach ($Connection in $Global:PaConnectionArray) {
            $PaConnectionString = $Connection.ConnectionString
            $xpath = "/config/devices/entry/vsys/entry/rulebase/security/rules/entry[@name='$Name']"
            
            if ($Rename) {
                $Response = Send-PaApiQuery -Config rename -XPath $xpath -NewName $Rename
                if ($Response.response.status -eq "success") {
                    return "Rename success"
                } else {
                    throw $Response.response.msg.line
                }
            }

            EditProperty $Description "description" $xpath
            EditProperty $SourceNegate "negate-source" $xpath
            EditProperty $DestinationNegate "negate-destination" $xpath
            EditProperty $Action "action" $xpath
            EditProperty $LogStart "log-start" $xpath
            EditProperty $LogEnd "log-end" $xpath
            EditProperty $LogForward "log-setting" $xpath
            EditProperty $Schedule "schedule" $xpath
            EditProperty $Disabled "disabled" $xpath
            EditProperty $QosDscp "ip-dscp" "$xpath/qos/marking"
            EditProperty $QosPrecedence "ip-precedence" "$xpath/qos/marking"
            EditProperty $DisableSri "disable-server-response-inspection" "$xpath/option"
            EditProperty $SourceAddress "source" $xpath
            EditProperty $SourceZone "from" $xpath
            EditProperty $Tag "tag" $xpath
            EditProperty $SourceUser "source-user" $xpath
            EditProperty $HipProfile "hip-profiles" $xpath
            EditProperty $DestinationZone "to" $xpath
            EditProperty $DestinationAddress "destination" $xpath
            EditProperty $Application "application" $xpath
            EditProperty $Service "service" $xpath
            EditProperty $UrlCategory "category" $xpath
            EditProperty $HipProfile "hip-profiles" $xpath
            EditProperty $ProfileGroup "group" "$xpath/profile-setting"
            EditProperty $ProfileVirus "virus" "$xpath/profile-setting/profiles"
            EditProperty $ProfileVuln "vulnerability" "$xpath/profile-setting/profiles"
            EditProperty $ProfileSpy "spyware" "$xpath/profile-setting/profiles"
            EditProperty $ProfileUrl "url-filtering" "$xpath/profile-setting/profiles"
            EditProperty $ProfileFile "file-blocking" "$xpath/profile-setting/profiles"
            EditProperty $ProfileData "data-filtering" "$xpath/profile-setting/profiles"
        }
    }
}

