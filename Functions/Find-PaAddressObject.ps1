function Find-PaAddressObject {
	<#
	.SYNOPSIS
		Search Address Objects and Address Groups for a given IP, FQDN, or string.
	.DESCRIPTION
		Returns objects from Palo Alto firewall.  If no objectname is specfied, all objects of the specified type are returned.
	.PARAMETER SearchString
		Specificies the Palo Alto connection string with address and apikey.
  .PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
    .PARAMETER ObjectName
        Declares a specific object to return.
    .PARAMETER Update
        Specifies that only an exact name match should be returned.  No inclusive search is performed.
    .EXAMPLE
        PS C:\Users\user> Find-PaAddressObject server-triton | ft -AutoSize

        Groups Addresses                                                     
        ------ ---------                                                     
        {}     {@{Name=server-triton; Value=10.10.64.10/32; Type=ip-netmask}}

        if the global variables global:address and global:addressgroups exist, the search is performed locally.  If they do not exist and update will be performed.
    .EXAMPLE
        PS C:\Users\user> Find-PaAddressObject server-triton -update | ft -AutoSize
        updating addresses

        Groups Addresses                                                     
        ------ ---------                                                     
        {}     {@{Name=server-triton; Value=10.10.64.10/32; Type=ip-netmask}}

        The update parameter updates the global variables global:address and global:addressgroups searching.
	#>
    
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [String]$SearchString,

        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection,

        [Parameter(Mandatory=$False)]
        [alias('u')]
        [Switch]$Update
    )

    BEGIN {
        $AddressObject = @{}
        $AddressProperties = @("Name","Type","Value")
        foreach ($Value in $AddressProperties) {
            $AddressObject.Add($Value,$null)
        }
        
        $ReturnCreate = @{}
        $ReturnProperties = @("Groups","Addresses")
        foreach ($Value in $ReturnProperties) {
            $ReturnCreate.Add($Value,$null)
        }
        $ReturnObject = New-Object psobject -Property $ReturnCreate

        $IpRx = [regex] "^(\d+\.){3}\d+$"
        
        Function Process-Query ( [String]$PaConnectionString ) {
            $AddressObjects = @()
            $GroupObjects = @()
            if ((!($Global:Addresses)) -or ($Update)) {
                "updating addresses"
                $Global:Addresses = (Send-PaApiQuery -Config get -xpath "/config/devices/entry/vsys/entry/address" -pc $PaConnectionString).response.result.address.entry
                $Global:AddressGroups = (Send-PaApiQuery -Config get -xpath "/config/devices/entry/vsys/entry/address-group"-pc $PaConnectionString).response.result."address-group".entry
            }
            $Addresses = $Global:Addresses
            $AddressGroups = $Global:AddressGroups
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
                if (($SearchString -eq $Group.name) -or ($Group.Member -contains $SearchString) -or ($Group.Member."#text" -contains $SearchString)) { $GroupObjects += $Group }
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