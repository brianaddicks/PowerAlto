function Get-PaObject {
	<#
	.SYNOPSIS
		Returns objects from Palo Alto firewall.
	.DESCRIPTION
		Returns objects from Palo Alto firewall.  If no objectname is specfied, all objects of the specified type are returned.  if -Exact is not used, an inclusive search of the specified ObjectName will be performed.
	.EXAMPLE
        Needs to write some examples
	.EXAMPLE
		Needs to write some examples
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey.
    .PARAMETER ObjectType
		Specifies the type of objects to return.  Supports address, addressgroup, service, servicegroup
    .PARAMETER ObjectName
        Declares a specific object to return.
    .PARAMETER Exact
        Specifies that only an exact name match should be returned.  No inclusive search is performed.
	#>
    
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$PaConnectionString,

        [Parameter(Mandatory=$True,Position=1)]
        [ValidateSet("address","addressgroup","service","servicegroup")] 
        [string]$ObjectType,

        [Parameter(Position=2)]
        [string]$ObjectName,

        [alias('x')]
        [switch]$Exact
    )

    BEGIN {
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        $type = "config"
        $action = "get"
        $ObjectTypes = @{"address" = "address"
                         "addressgroup" = "address-group"
                         "service" = "service"
                         "servicegroup" = "service-group"
        }
        $xpath = "/config/devices/entry/vsys/entry/$($ObjectTypes.get_item($ObjectType))"
    }

    PROCESS {
        #"$PaConnectionString $type $action $xpath"
        $Result = Get-PaCustom $PaConnectionString $type $action $xpath
        #$result
        $Objects = $Result.response.result.$($ObjectTypes.get_item($ObjectType)).entry
        $Matches = @()
        if ($ObjectName) {
            if ($Exact) {
                $NameMatch = $Objects | where { $_.name -eq $ObjectName }
            } else {
                $NameMatch = $Objects | where { $_.name -match $ObjectName }
            }
            return $Matches
        } else {
            return $Result.response.result."$($ObjectTypes.get_item($ObjectType))".entry
            
        }
    }
}

