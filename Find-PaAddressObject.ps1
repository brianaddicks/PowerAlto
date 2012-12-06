function Find-PaAddressObject {
	<#
	.SYNOPSIS
		Search Object values for a given IP or FQDN
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
        [String]$SearchString,

        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection
    )

    BEGIN {
        $AddressObject = @{}
        $AddressProperties = @("Name","Type","Value")
        foreach ($Value in $AddressProperties) {
            $AddressObject.Add($Value,$null)
        }
        
        $ReturnObject = @{}
        $ReturnProperties = @("Groups","Addresses")
        foreach ($Value in $ReturnProperties) {
            $ReturnObject.Add($Value,$null)
        }

        $IpRx = [regex] "^(\d+\.){3}\d+$"
        
        Function Process-Query ( [String]$PaConnectionString ) {
            $AddressObjects = @()
            $GroupObjects = @()
            $Addresses = (Send-PaApiQuery -Config get -xpath "/config/devices/entry/vsys/entry/address" -pc $PaConnectionString).response.result.address.entry
            $AddressGroups = (Send-PaApiQuery -Config get -xpath "/config/devices/entry/vsys/entry/address-group"-pc $PaConnectionString).response.result."address-group".entry
            $Found = @()
            foreach ($Address in $Addresses) {
                $IsFound = $false
                $SearchArray = @()
                $CurrentAddress = New-Object PsObject -Property $AddressObject
                $CurrentAddress.Name = $Address.Name
                    if ($Address."ip-netmask") {
                        $CurrentAddress.Type = "ip-netmask"
                        if ($Address."ip-netmask"."#text") {
                            $CurrentAddress.Value = $Address."ip-netmask"."#text"
                        } else {
                            $CurrentAddress.Value = $Address."ip-netmask"
                        }
                        if ($CurrentAddress.Value -match "/") {
                            $AddressSplit = $CurrentAddress.Value.Split("/")
                            $AddressOnly = $AddressSplit[0]
                            $Mask = $AddressSplit[1]
                            if ($Mask -eq 32) {
                                $IsFound = ($AddressOnly -eq $SearchString)
                            } else {
                                $Start = Get-NetworkAddress $AddressOnly (ConvertTo-Mask $Mask)
                                $Stop = Get-BroadcastAddress $AddressOnly (ConvertTo-Mask $Mask)
                                if ($IpRx.Match($SearchString).Success) {
                                    $IsFound = Test-IpRange "$start-$stop" $SearchString
                                }
                            }
                        } else {
                            $IsFound = ($CurrentAddress.Value -eq $SearchString)
                        }
                    } elseif ($Address."ip-range") {
                        $CurrentAddress.Type = "ip-range"
                        $CurrentAddress.Value = $Address."ip-range"
                        if ($IpRx.Match($SearchString).Success) {
                            $IsFound = Test-IpRange $CurrentAddress.value $SearchString
                        }
                    }

                if ($Address.fqdn) {
                    $CurrentAddress.Type = "fqdn"
                    $CurrentAddress.Value = $Address.fqdn
                    $IsFound = ($CurrentAddress.Value -eq $SearchString)
                }
                if ($SearchString -eq $address.Name) { $IsFound = $true }
                if ($IsFound) { $AddressObjects += $CurrentAddress }
            }
            $ReturnObject.Addresses = $AddressObjects

            foreach ($Group in $AddressGroups) {
                foreach ($Address in $AddressObjects) {
                    if (($Group.Member -contains $Address.Name) -or ($Group.Member."#text" -contains $Address.Name)) {
                        $GroupObjects += $Group
                    }
                }
            }
            $ReturnObject.Groups = $GroupObjects

            return $ReturnObject
        }
    }

    PROCESS {
        if ($PaConnection) {
            Process-Query $PaConnection
        } else {
            if (Test-PaConnection) {
                foreach ($Connection in $Global:PaConnectionArray) {
                    Process-Query $Connection.ConnectionString
                }
            } else {
                Throw "No Connections"
            }
        }
    }
}