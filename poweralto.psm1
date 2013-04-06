Import-module ipv4math -global
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
function Find-PaObjectUsage {
    <#
	.SYNOPSIS
		Find unused Address Objects and Address Groups.
	.DESCRIPTION
		
	.EXAMPLE
        EXAMPLES!
	.EXAMPLE
		EXAMPLES!
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
	#>

    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection,

        [Parameter(Mandatory=$False)]
        [alias('u')]
        [Switch]$Update
    )

    BEGIN {
        $ResultObject = @{}
        $ResultProperties = @("Name","Groups","Security","Nat")
        foreach ($Value in $ResultProperties) {
            $ResultObject.Add($Value,$null)
        }

        Function Process-Query ( [String]$PaConnectionString ) {
            $ResultTable = @()
            if ((!($Global:Addresses)) -or ($Update)) {
                "updating addresses and rulebase"
                $Global:Addresses = (Send-PaApiQuery -Config get -xpath "/config/devices/entry/vsys/entry/address" -pc $PaConnectionString).response.result.address.entry
                $Global:AddressGroups = (Send-PaApiQuery -Config get -xpath "/config/devices/entry/vsys/entry/address-group"-pc $PaConnectionString).response.result."address-group".entry
                $Global:SecurityRuleBase = Get-PaSecurityRule
                $Global:NatRuleBase = Get-PaNatRule
            }
            $Addresses = $Global:Addresses
            $AddressGroups = $Global:AddressGroups
            $All = $Addresses + $AddressGroups
            $i = 0
            foreach ($item in $All) {
                $Usage = Get-PaObjectUsage $item.name
                $CurrentResult = New-Object PsObject -Property $ResultObject
                $CurrentResult.Name     = $item.name
                $CurrentResult.Groups   = ($Usage.Groups | measure).count
                $CurrentResult.Security = ($Usage.SecurityRules | measure).count
                $CurrentResult.Nat      = ($Usage.NatRules | measure).count
                $ResultTable += $CurrentResult
                $i++
                $Progress = [math]::truncate(($i / $all.count) * 100)
                Write-Progress -Activity "Scanning Address Usage" -Status "$Progress% complete"-PercentComplete $Progress
            }
        return $ResultTable
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

function Get-PaNatRule {
    <#
	.SYNOPSIS
		Returns NAT Ruleset from Palo Alto firewall.
	.DESCRIPTION
		
	.EXAMPLE
        EXAMPLES!
	.EXAMPLE
		EXAMPLES!
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
	#>

    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection
    )

    BEGIN {
        $xpath = "/config/devices/entry/vsys/entry/rulebase/nat/rules"
        function Text-Query ( [String]$PaProp ) {
            if ($entry."$PaProp"."#text") { return $entry."$PaProp"."#text" } `
                else { return  $entry."$PaProp" }
        }
        function Member-Query ( [String]$PaProp ) {
            if ($entry."$PaProp".member."#text") { return $entry."$PaProp".member."#text" } `
                else { return  $entry."$PaProp".member }
        }
        Function Process-Query ( [String]$PaConnectionString ) {
            $NatRule = @{}
            $ExportString = @("Name","Description","Tag","SourceZone","DestinationZone","DestinationInterface","Service","SourceAddress","DestinationAddress","SourceTransType","SourceTransAddressType","SourceTransInterface","SourceTransAddress","BiDirectional","DestTransEnabled","DestTransAddress","DestTransPort")
            foreach ($Value in $ExportString) {
                $NatRule.Add($Value,$null)
            }
            $NatRules = @()
            $NatRulebase = (Send-PaApiQuery -Config get -XPath $xpath -pc $PaConnectionString).response.result.rules.entry
            
            #Covert results into PSobject
            foreach ($entry in $NatRulebase) {
                $CurrentRule = New-Object PSObject -Property $NatRule

                $CurrentRule.Name                   = $entry.Name
                $CurrentRule.Description            = $entry.Description
                $CurrentRule.Tag                    = Member-Query "tag"
                $CurrentRule.SourceZone             = Member-Query "from"
                $CurrentRule.DestinationZone        = Member-Query "to"
                $CurrentRule.DestinationInterface   = Text-Query "to-interface"
                $CurrentRule.Service                = Text-Query "service"
                $CurrentRule.SourceAddress          = Member-Query "source"
                $CurrentRule.DestinationAddress     = Member-Query "destination"
                if ($entry."source-translation"."dynamic-ip-and-port") {
                    $CurrentRule.SourceTransType    = "DynamicIpAndPort"
                    if ($entry."source-translation"."dynamic-ip-and-port"."interface-address".interface."#text") {
                        $CurrentRule.SourceTransAddressType = "InterfaceAddress"
                        $CurrentRule.SourceTransInterface   = $entry."source-translation"."dynamic-ip-and-port"."interface-address".interface."#text"
                        $CurrentRule.SourceTransAddress      = $entry."source-translation"."dynamic-ip-and-port"."interface-address".ip."#text"
                    } elseif ($entry."source-translation"."dynamic-ip-and-port"."interface-address".interface) {
                        $CurrentRule.SourceTransAddressType = "InterfaceAddress"
                        $CurrentRule.SourceTransInterface   = $entry."source-translation"."dynamic-ip-and-port"."interface-address".interface
                    } elseif ($entry."source-translation"."dynamic-ip-and-port"."translated-address") {
                        $CurrentRule.SourceTransAddressType = "TranslatedAddress"
                        $CurrentRule.SourceTransInterface   = $entry."source-translation"."dynamic-ip-and-port"."translated-address".member."#text"
                    }
                } elseif ($entry."source-translation"."static-ip") {
                    $CurrentRule.SourceTransType    = "StaticIp"
                    $CurrentRule.SourceTransAddress = $entry."source-translation"."static-ip"."translated-address"."#text"
                    $CurrentRule.BiDirectional      = $entry."source-translation"."static-ip"."bi-directional"."#text"
                } elseif ($entry."source-translation"."dynamic-ip") {
                    $CurrentRule.SourceTransType    = "DynamicIp"
                    $CurrentRule.SourceTransAddress = $entry."source-translation"."dynamic-ip"."translated-address".member."#text"
                }
                if ($entry."destination-translation") {
                    $CurrentRule.DestTransEnabled = "yes"
                    $CurrentRule.DestTransAddress = $entry."destination-translation"."translated-address"."#text"
                    $CurrentRule.DestTransPort    = $entry."destination-translation"."translated-port"."#text"
                }
                $NatRules += $CurrentRule
            }
            return $NatRules | select $ExportString
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

function Get-PaObjectUsage {
    <#
	.SYNOPSIS
		Returns Security, Nat, Address and Address Group usge of specific search string.
	.DESCRIPTION
		
	.EXAMPLE
        EXAMPLES!
	.EXAMPLE
		EXAMPLES!
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
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
        Function Process-Query ( [String]$PaConnectionString ) {
            if ((!($Global:SecurityRuleBase)) -or ($Update)) {
                "updating rules"
                $Global:SecurityRuleBase = Get-PaSecurityRule
                $Global:NatRuleBase = Get-PaNatRule
            }
            $SecurityRuleBase = $Global:SecurityRuleBase
            $NatRuleBase = $Global:NatRuleBase


            #if (!($SecurityRuleBase)) { $SecurityRuleBase = Get-PaSecurityRule }
            #if (!($NatRuleBase)) { $NatRuleBase = Get-PaNatRule }
            $Objects = Find-PaAddressObject $SearchString

            $SecurityRuleUse = @()
            $NatRuleUse      = @()

            foreach ($Address in $Objects.Addresses) {
                $SecurityRuleUse += $SecurityRulebase | where { ($_.SourceAddress -contains $Address.Name) -or $_.DestinationAddress -contains $Address.Name }
                $NatRuleUse += $NatRuleBase | where { ($_.SourceAddress -contains $Address.name) -or ($_.DestinationAddress -contains $Address.name) -or ($_.SourceTransAddress -contains $Address.name) -or ($_.DestTransAddress -contains $Address.name) }
            }
            foreach ($Group in $Objects.Groups) {
                $SecurityRuleUse += $SecurityRulebase | where { ($_.SourceAddress -contains $Group.name) -or ($_.DestinationAddress -contains $Group.name) }
                $NatRuleUse += $NatRuleBase | where { ($_.SourceAddress -contains $Group.name) -or ($_.DestinationAddress -contains $Group.name) -or ($_.SourceTransAddress -contains $Group.name) -or ($_.DestTransAddress -contains $Group.name) }
            }

        $ReturnObject = @{}
        $ReturnObject.Addresses = $Objects.Addresses
        $ReturnObject.Groups = $Objects.Groups
        $ReturnObject.SecurityRules = $SecurityRuleUse
        $ReturnObject.NatRules = $NatRuleUse
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
function Get-PaSecurityRule {
    <#
	.SYNOPSIS
		Returns Security Ruleset from Palo Alto firewall.
	.DESCRIPTION
		Returns Security Ruleset from Palo Alto firewall.
	.EXAMPLE
        EXAMPLES!
	.EXAMPLE
		EXAMPLES!
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
	#>

    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection,

        [Parameter(Mandatory=$False)]
        [alias('c')]
        [Switch]$Candidate,

        [Parameter(Mandatory=$False)]
        [alias('u')]
        [Switch]$Update
    )

    BEGIN {
        $xpath = "/config/devices/entry/vsys/entry/rulebase/security/rules"
        if ($Candidate) { $type = "get" } `
                   else { $type = "show" }

        Function Process-Query ( [String]$PaConnectionString ) {
            $SecurityRule = @{}
            $ExportString = @("Name","Description","Tag","SourceZone","SourceAddress","SourceNegate","SourceUser","HipProfile","DestinationZone","DestinationAddress","DestinationNegate","Application","Service","UrlCategory","Action","ProfileType","ProfileGroup","ProfileVirus","ProfileVuln","ProfileSpy","ProfileUrl","ProfileFile","ProfileData","LogStart","LogEnd","LogForward","DisableSRI","Schedule","QosType","QosMarking","Disabled")
            foreach ($Value in $ExportString) {
                $SecurityRule.Add($Value,$null)
            }
            $SecurityRules = @()
            if ((!($Global:SecurityRuleBase)) -or ($Update)) {
                $Global:SecurityRuleBase = (Send-PaApiQuery -Config $type -XPath $xpath -pc $PaConnectionString).response.result.rules.entry
            }
            $SecurityRulebase = $Global:SecurityRuleBase
            
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
                    $CurrentRule.Disabled           = $entry.disabled
                $SecurityRules += $CurrentRule
            }
            #$SecurityRulebase
            return $SecurityRules | select $ExportString
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

function Get-PaSystemInfo {
	<#
	.SYNOPSIS
		Returns general information about the desired PA.
	.DESCRIPTION
		Returns the version number of various components of a Palo Alto firewall.
	.EXAMPLE
        C:\PS> Get-PaVersion -PaConnectionString https://192.168.1.1/api/?key=apikey
        hostname                              : pegasus
        ip-address                            : 192.168.1.1
        netmask                               : 255.255.255.0
        default-gateway                       : 192.168.1.10
        ipv6-address                          : 
        ipv6-link-local-address               : fe80::b60c:23ff:fe0c:5500/64
        ipv6-default-gateway                  : 
        mac-address                           : b4:0c:25:03:55:00
        time                                  : Mon Nov 19 17:02:19 2012
                                        
        uptime                                : 2 days, 15:26:48
        devicename                            : pegasus
        family                                : 200
        model                                 : PA-200
        serial                                : 012345678901
        sw-version                            : 5.0.0
        global-protect-client-package-version : 1.2.0
        app-version                           : 338-1582
        app-release-date                      : 2012/11/13  12:46:13
        av-version                            : 882-1216
        av-release-date                       : 2012/11/15  18:13:58
        threat-version                        : 338-1582
        threat-release-date                   : 2012/11/13  12:46:13
        wildfire-version                      : 0
        wildfire-release-date                 : unknown
        url-filtering-version                 : 3984
        global-protect-datafile-version       : 0
        global-protect-datafile-release-date  : unknown
        logdb-version                         : 5.0.2
        platform-family                       : 200
        logger_mode                           : False
        vpn-disable-mode                      : off
        operational-mode                      : normal
        multi-vsys                            : off
	.EXAMPLE
		C:\PS> Get-PaVersion https://192.168.1.1/api/?key=apikey
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
	#>

    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection
    )

    BEGIN {
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        Function Process-Query ( [String]$PaConnectionString ) {
            $SystemInfo = (Send-PaApiQuery -op "<show><system><info></info></system></show>").response.result.system
            return $SystemInfo
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

function Invoke-PaCommit {
	<#
	.SYNOPSIS
		Commits candidate config to Palo Alto firewall
	.DESCRIPTION
		Commits candidate config to Palo Alto firewall and returns resulting job stats.
	.EXAMPLE
        Needs to write some examples
	.EXAMPLE
		Needs to write some examples
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
    .PARAMETER Force
		Forces the commit command in the event of a conflict.
	#>
    
    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection,

        [Parameter(Mandatory=$False)]
        [switch]$Force
    )

    BEGIN {
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

        Function Process-Query ( [String]$PaConnectionString ) {
            if ($Force) {
                $CustomData = Send-PaApiQuery -commit -force
            } else {
                $CustomData = Send-PaApiQuery -commit
            }
            if ($CustomData.response.status -eq "success") {
                if ($CustomData.response.msg -match "no changes") {
                    Return "There are no changes to commit."
                }
                $job = $CustomData.response.result.job
                $cmd = "<show><jobs><id>$job</id></jobs></show>"
                $JobStatus = Send-PaApiQuery -op "$cmd"
                while ($JobStatus.response.result.job.status -ne "FIN") {
                    Write-Progress -Activity "Commiting to PA" -Status "$($JobStatus.response.result.job.progress)% complete"-PercentComplete ($JobStatus.response.result.job.progress)
                    $JobStatus = Send-PaApiQuery -op "$cmd"
                }
                return $JobStatus.response.result.job
            }
            Throw "$($CustomData.response.result.msg)"
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

function Restart-PaSystem {
    <#
	.SYNOPSIS
		Restarts PA and watches initial autocommit job for completion.
	.DESCRIPTION
		
	.EXAMPLE
        EXAMPLES!
	.EXAMPLE
		EXAMPLES!
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
	#>

    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection,

        [Parameter(Mandatory=$False)]
        [alias('dw')]
        [String]$DontWait,
        
        [Parameter(Mandatory=$False)]
        [alias('i')]
        [Decimal]$Id,
        
        [Parameter(Mandatory=$False)]
        [alias('p')]
        [Decimal]$Parentid
    )

    BEGIN {
        Function Process-Query ( [String]$PaConnectionString ) {
            #Configure progress bar for waiting for a response
            $WaitJobParams = @{Activity = "Sending Reboot Commnad"}
            if ($Id)          { $WaitJobParams.Add("Id",$id) }
            if ($ParentId)    { $WaitJobParams.Add("ParentId",$Parentid) }

            #Reboot the system
            $xpath = "<request><restart><system></system></restart></request>"
            $Reboot = Send-PaApiQuery -Op $xpath
            
            #If desired, down't wait for the system to come back up
            if ($DontWait) { return $Reboot }
            
            #Wait for system to go down (so we don't get a false positive and think it's already back up)
            for ($w = 0;$w -le 14;$w++) {
                $Caption = "Sleeping $(15 - $w)"
                $WaitJobParams.Set_Item("Activity",$Caption)
                Write-Progress @WaitJobParams
                sleep 1
            }

            #Update Progress Bar
            $WaitJobParams.Set_Item("Activity","Trying to connect")

            #Set our test condition to false
            $RebootTest = $false

            #Configure progress bar for waiting for job 1 to complete after reboot
            $WatchJobParams = @{ job = 1
                                 caption = "Waiting for reboot" }
            if ($Id)           { $WatchJobParams.Add("Id",$id) }
            if ($ParentId)     { $WatchJobParams.Add("ParentId",$Parentid) }

            #Attempt counter
            $a = 1

            #Loop until $RebootTest is true
            while (!($RebootTest)) {
                try {
                    #attempt to connect
                    $WaitJobParams.Set_Item("Activity","Attempting to connect")
                    Write-Progress @WaitJobParams
                    $RebootJob = Watch-PaJob @WatchJobParams
                    if ($RebootJob.response) { $RebootTest = $true }
                } catch {
                    #if exception from try block (thrown by $RebootJob), wait 15 seconds, updates progress
                    for ($w = 0;$w -le 14;$w++) {
                        $Caption = "Attempt $a`: Unable to connect, Trying again in $(15 - $w)"
                        $WaitJobParams.Set_Item("Activity",$Caption)
                        Write-Progress @WaitJobParams
                        sleep 1
                        #increment attempt counter
                    }
                    $a++
                    $RebootTest = $false
                }
                
            }
            return $RebootJob
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
function Restore-PaPreviousVersion {
    <#
	.SYNOPSIS
		Reverts to previous configuration version
	.DESCRIPTION
		
	.EXAMPLE
        EXAMPLES!
	.EXAMPLE
		EXAMPLES!
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
	#>

    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection
    )

    BEGIN {
        Function Process-Query ( [String]$PaConnectionString ) {
            $LastVers = (Send-PaApiQuery -op "<show><config><audit><info></info></audit></config></show>").response.result.entry[1].name
            $LoadLast = Send-PaApiQuery -op "<load><config><version>$LastVers</version></config></load>"
            if ($LoadLast.response.status -eq "succes") { Invoke-Pacommit } `
                else { throw $LoadLast.response.msg }
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
function Send-PaApiQuery {
	<#
	.SYNOPSIS
		Formulate and send an api query to a PA firewall.
	.DESCRIPTION
		Formulate and send an api query to a PA firewall.
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
	#>
    Param (
        #############################CONFIG#############################

        [Parameter(ParameterSetName="config",Mandatory=$True,Position=0)]
        [ValidateSet("show","get","set","edit","delete","rename","clone","move")] 
        [String]$Config,

        [Parameter(ParameterSetName="config",Mandatory=$True)]
        [ValidatePattern("\/config\/.*")]
        [String]$XPath,

        [Parameter(ParameterSetName="config")]
        [alias('e')]
        [String]$Element,

        [Parameter(ParameterSetName="config")]
        [alias('m')]
        [String]$Member,

        [Parameter(ParameterSetName="config")]
        [alias('nn')]
        [String]$NewName,

            #========================CLONE=========================#

        [Parameter(ParameterSetName="config")]
        [alias('cf')]
        [String]$CloneFrom,

            #=========================MOVE=========================#

        [Parameter(ParameterSetName="config")]
        [alias('mw')]
        [ValidateSet("after","before","top","bottom")] 
        [String]$MoveWhere,

        [Parameter(ParameterSetName="config")]
        [alias('dst')]
        [String]$MoveDestination,

        ###########################OPERATIONAL##########################

        [Parameter(ParameterSetName="op",Mandatory=$True,Position=0)]
        [ValidatePattern("<\w+>.*<\/\w+>")]
        [String]$Op,

        #############################REPORT#############################

        [Parameter(ParameterSetName="report",Mandatory=$True,Position=0)]
        [ValidateSet("dynamic","predefined")]
        #No Custom Reports supported yet, should probably make a seperate cmdlet for it.
        [String]$Report,

        [Parameter(ParameterSetName="report")]
        [alias('rn')]
        [String]$ReportName,

        [Parameter(ParameterSetName="report")]
        [alias('r')]
        [Decimal]$Rows,

        [Parameter(ParameterSetName="report")]
        [alias('p')]
        [ValidateSet("last-60-seconds","last-15-minutes","last-hour","last-12-hrs","last-24-hrs","last-calendar-day","last-7-days","last-7-calendar-days","last-calendar-week","last-30-days")] 
        [String]$Period,

        [Parameter(ParameterSetName="report")]
        [alias('start')]
        [ValidatePattern("\d{4}\/\d{2}\/\d{2}\+\d{2}:\d{2}:\d{2}")]
        [String]$StartTime,

        [Parameter(ParameterSetName="report")]
        [alias('end')]
        [ValidatePattern("\d{4}\/\d{2}\/\d{2}\+\d{2}:\d{2}:\d{2}")]
        [String]$EndTime,

        #############################EXPORT#############################

        [Parameter(ParameterSetName="export",Mandatory=$True,Position=0)]
        [ValidateSet("application-pcap","threat-pcap","filter-pcap","filters-pcap","configuration","certificate","high-availability-key","key-pair","application-block-page","captive-portal-text","file-block-continue-page","file-block-page","global-protect-portal-custom-help-page","global-protect-portal-custom-login-page","global-protect-portal-custom-welcome-page","ssl-cert-status-page","ssl-optout-text","url-block-page","url-coach-text","virus-block-page","tech-support","device-state")]
        [String]$Export,

        [Parameter(ParameterSetName="export")]
        [alias('f')]
        [String]$From,

        [Parameter(ParameterSetName="export")]
        [alias('t')]
        [String]$To,

            #=========================DLP=========================#

        [Parameter(ParameterSetName="export")]
        [alias('dp')]
        [String]$DlpPassword,

            #=====================CERTIFICATE=====================#

        [Parameter(ParameterSetName="export")]
        [alias('ecn')]
        [String]$CertificateName,

        [Parameter(ParameterSetName="export")]
        [alias('ecf')]
        [ValidateSet("pkcs12","pem")]
        [String]$CertificateFormat,

        [Parameter(ParameterSetName="export")]
        [alias('epp')]
        [String]$ExportPassPhrase,

            #=====================TECH SUPPORT====================#

        [Parameter(ParameterSetName="export")]
        [alias('ta')]
        [ValidateSet("status","get","finish")]
        [String]$TsAction,

        [Parameter(ParameterSetName="export")]
        [alias('j')]
        [Decimal]$Job,

        [Parameter(ParameterSetName="export",Mandatory=$True)]
        [alias('ef')]
        [String]$ExportFile,


        #############################IMPORT#############################

        [Parameter(ParameterSetName="import",Mandatory=$True,Position=0)]
        [ValidateSet("software","anti-virus","content","url-database","signed-url-database","license","configuration","certificate","high-availability-key","key-pair","application-block-page","captive-portal-text","file-block-continue-page","file-block-page","global-protect-portal-custom-help-page","global-protect-portal-custom-login-page","global-protect-portal-custom-welcome-page","ssl-cert-status-page","ssl-optout-text","url-block-page","url-coach-text","virus-block-page","global-protect-client","custom-logo")]
        [String]$Import,

        [Parameter(ParameterSetName="import",Mandatory=$True,Position=1)]
        [String]$ImportFile,

            #=====================CERTIFICATE=====================#

        [Parameter(ParameterSetName="import")]
        [alias('icn')]
        [String]$ImportCertificateName,

        [Parameter(ParameterSetName="import")]
        [alias('icf')]
        [ValidateSet("pkcs12","pem")]
        [String]$ImportCertificateFormat,

        [Parameter(ParameterSetName="import")]
        [alias('ipp')]
        [String]$ImportPassPhrase,

            #====================RESPONSE PAGES====================#

        [Parameter(ParameterSetName="import")]
        [alias('ip')]
        [String]$ImportProfile,

            #=====================CUSTOM LOGO======================#

        [Parameter(ParameterSetName="import")]
        [alias('wh')]
        [ValidateSet("login-screen","main-ui","pdf-report-footer","pdf-report-header")]
        [String]$ImportWhere,

        ##############################LOGS##############################

        [Parameter(ParameterSetName="log",Mandatory=$True,Position=0)]
        [ValidateSet("traffic","threat","config","system","hip-match","get","finish")]
        [String]$Log,

        [Parameter(ParameterSetName="log")]
        [alias('q')]
        [String]$LogQuery,

        [Parameter(ParameterSetName="log")]
        [alias('nl')]
        [ValidateRange(1,5000)]
        [Decimal]$NumberLogs,

        [Parameter(ParameterSetName="log")]
        [alias('sl')]
        [String]$SkipLogs,

        [Parameter(ParameterSetName="log")]
        [alias('la')]
        [ValidateSet("get","finish")]
        [String]$LogAction,

        [Parameter(ParameterSetName="log")]
        [alias('lj')]
        [Decimal]$LogJob,

        #############################USER-ID############################

        [Parameter(ParameterSetName="userid",Mandatory=$True,Position=0)]
        [ValidateSet("get","set")] 
        [String]$UserId,

        #############################COMMIT#############################

        [Parameter(ParameterSetName="commit",Mandatory=$True,Position=0)]
        [Switch]$Commit,

        [Parameter(ParameterSetName="commit")]
        [Switch]$Force,

        [Parameter(ParameterSetName="commit")]
        [alias('part')]
        [String]$Partial,

        ############################CONNECTION##########################

        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection
    )

    BEGIN {
        function Send-WebFile ($url) {
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($data)

            [System.Net.HttpWebRequest] $webRequest = [System.Net.WebRequest]::Create($url)

            $webRequest.Method = "POST"
            $webRequest.ContentType = "text/html"
            $webRequest.ContentLength = $buffer.Length;

            $requestStream = $webRequest.GetRequestStream()
            $requestStream.Write($buffer, 0, $buffer.Length)
            $requestStream.Flush()
            $requestStream.Close()


            [System.Net.HttpWebResponse] $webResponse = $webRequest.GetResponse()
            $streamReader = New-Object System.IO.StreamReader($webResponse.GetResponseStream())
            $result = $streamReader.ReadToEnd()
            return $result
        }

        Add-Type -AssemblyName System.Web
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        Function Process-Query ( [String]$PaConnectionString ) {
            $url = $PaConnectionString
            #############################CONFIG#############################
            if ($Config) {
                $ReturnType = "String"
                $url += "&type=config"
                $url += "&action=$Config"
                $url += "&xpath=$xpath"
                if (($Config -eq "set") -or ($Config -eq "edit")-or ($Config -eq "delete")) {
                    #if ($Element) { $url += "/$Element" }
                    $Member = $Member.replace(" ",'%20')
                    if ($Member -match ",") {
                        foreach ($Value in $Member.split(',')) {
                            if ($Value) { $Members += "<member>$Value</member>" }
                        }
                        $Member = $Members
                    }
                    if ($Element) {
                        if ($element -match "<") {
                            "test"
                            $url+= "&element=$element"
                        } else {
                            $url+= "&element=<$element>$Member</$element>"
                        }
                    }
                } elseif ($Config -eq "rename") {
                    $url += "&newname=$NewName"
                } elseif ($Config -eq "clone") {
                    $url += "/"
                    $url += "&from=$xpath/$CloneFrom"
                    $url += "&newname=$NewName"
                    return "Times out ungracefully as of 11/20/12 on 5.0.0"
                } elseif ($Config -eq "move") {
                    $url += "&where=$MoveWhere"
                    if ($MoveDestination) {
                        $url += "&dst=$MoveDestination"
                    }
                }

                $global:lasturl = $url
                $global:response = [xml]$WebClient.DownloadString($url)
                return $global:response

            ###########################OPERATIONAL##########################
            } elseif ($Op) {
                $ReturnType = "String"
                $url += "&type=op"
                $url += "&cmd=$Op"

                $global:lasturl = $url
                $global:response = [xml]$WebClient.DownloadString($url)
                return $global:response

            #############################REPORT#############################
            } elseif ($Report) {
                $ReturnType = "String"
                $url += "&type=report"
                $url += "&reporttype=$Report"
                if ($ReportName) { $url += "&reportname=$ReportName" }
                if ($Rows) { $url += "&topn=$Rows" }
                if ($Period) {
                    $url+= "&period=$Period"
                } elseif ($StartTime) {
                    $url += "&starttime=$StartTime"
                    if ($EndTime) { $url += "&starttime=$EndTime" }
                }
                return [xml]$WebClient.DownloadString($url)
        
            #############################EXPORT#############################
            } elseif ($Export) {
                if (($export -eq "filters-pcap") -or ($export -eq "filter-pcap")) {
                    return "Times out ungracefully as of 11/20/12 on 5.0.0"
                }
                $url += "&type=export"
                $url += "&category=$Export"
                if ($From) { $url += "&from=$From" }
                if ($To) { $url += "&to=$To" }
                if ($DlpPassword) { $url += "dlp-password=$DlpPassword" }
                if ($CertificateName) {
                    $url += "&certificate-name=$CertificateName"
                    $url += "&include-key=no"
                }
                if ($CertificateFormat) { $url += "&format=$CertificateFormat" }
                if ($ExportPassPhrase) {
                    $url += "&include-key=yes"
                    $url += "&passphrase=$ExportPassPhrase"
                }
                if ($TsAction) { $url += "&action=$TsAction" }
                if ($Job) { $url += "&job-id=$Job" }
                $WebClient.DownloadFile($url,$ExportFile)
                return "File downloaded to $ExportFile"

            #############################IMPORT#############################
            } elseif ($Import) {
                $url += "&type=import"
                $url += "&category=$Import"
                if ($ImportCertificateName) {
                    $url += "&certificate-name=$ImportCertificateName"
                    $url += "&format=$ImportCertificateFormat"
                    $url += "&passphrase=$ImportPassPhrase"
                }
                if ($ImportProfile) { $url += "&profile=$ImportProfile" }
                if ($ImportWhere) { $url += "&where=$ImportWhere" }
                $global:lasturl = $url

                #return Send-WebFile $url $ImportFile
                return "Currently non-functional, not sure how to do this with webclient"


            ##############################LOGS##############################
            } elseif ($Log) {
                $url += "&type=log"
                if ($Log -eq "get") {
                    $url += "&action=$log"
                    $url += "&job-id=$LogJob"
                } else {
                    $url += "&log-type=$Log"
                }
                if ($LogQuery) { $url += "&query=$($LogQuery.Replace(" ",'%20'))" }
                if ($NumberLogs) { $url += "&nlogs=$NumberLogs" }
                if ($SkipLogs) { $url += "&skip=$SkipLogs" }

                $global:lasturl  = $url
                #$global:response = [xml]$WebClient.DownloadString($url)

                #return $global:response
                return $url

            #############################USER-ID############################
            } elseif ($UserId) {
                $url += "&type=user-id"
                $url += "&action=$UserId"
                $global:lasturl = $url
                $global:response = [xml]$WebClient.DownloadString($url)
                return $global:response

            #############################COMMIT#############################
            } elseif ($Commit) {
                $url += "&type=commit"
                $url += "&cmd=<commit></commit>"
                $global:lasturl = $url
                $global:response = [xml]$WebClient.DownloadString($url)
                return $global:response
            }
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
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
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
        [string]$DisableSri,

        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection
    )

    BEGIN {
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

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
        Function Process-Query ( [String]$PaConnectionString ) {
            $xpath = "/config/devices/entry/vsys/entry/rulebase/security/rules/entry[@name='$Name']"
            
            if ($Rename) {
                $Response = Send-PaApiQuery -Config rename -XPath $xpath -NewName $Rename -PaConnection $PaConnectionString
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

function Set-PaUpdateSchedule {
    <#
	.SYNOPSIS
		Defines schedule for content updates.
	.DESCRIPTION
		
	.EXAMPLE
        EXAMPLES!
	.EXAMPLE
		EXAMPLES!
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
	#>

    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection,

        [Parameter(Mandatory=$True)]
        [alias('c')]
        [ValidateSet("threats","av","url","all")] 
        [String]$Content,

        [Parameter(Mandatory=$False)]
        [alias('a')]
        [ValidateSet("download","install")] 
        [String]$Action,
        
        [Parameter(Mandatory=$True)]
        [alias('r')]
        [ValidateSet("daily","weekly","hourly","none")] 
        [String]$Recurrence,
        
        [Parameter(Mandatory=$False)]
        [alias('t')]
        [ValidatePattern("\d+\:\d+|\d{1,2}")]
        [String]$Time,

        [Parameter(Mandatory=$False)]
        [alias('d')]
        [ValidateSet("sunday","monday","tuesday","wednesday","thursday","friday","saturday")] 
        [String]$Day,

        [Parameter(Mandatory=$False)]
        [alias('th')]
        [ValidatePattern("\d+|none")]
        [String]$Threshold,

        [Parameter(Mandatory=$False)]
        [alias('p')]
        [Switch]$PeerSync
    )

    BEGIN {
        Function Set-Schedule ( [String]$Content) {
            $basexpath = "/config/devices/entry/deviceconfig/system/update-schedule/$Content/recurring"
            if ($Recurrence -eq "none") {
                $RecurrenceResponse = Send-PaApiQuery -Config delete -XPath $basexpath
                if ($RecurrenceResponse.response.status -eq "error") { throw $RecurrenceResponse.response.msg.line }
                return
            }
            switch ($Action) {
                download { $Action = "download-only" }
                install  { $Action = "download-and-install" }
            }
            if ($PeerSync) {
                $PeerSyncResponse = Send-PaApiQuery -Config set -xpath "$basexpath&element=<sync-to-peer>yes</sync-to-peer>"
                if ($PeerSyncResponse.response.status -eq "error") { throw $PeerSyncResponse.response.msg.line }
            }
            if ($Threshold -and ($Content -ne "url-database")) {
                if ($Threshold -eq "none") {
                    $ThresholdResponse = Send-PaApiQuery -Config delete -xpath "$basexpath/threshold"
                } else {
                    $ThresholdResponse = Send-PaApiQuery -Config set -XPath "$basexpath&element=<threshold>$Threshold</threshold>"
                }
                if ($ThresholdResponse.response.status -eq "error") { throw $ThresholdResponse.response.msg.line }
            }
            $ActionReponse = Send-PaApiQuery -Config set -XPath "$basexpath&element=<$Recurrence><action>$Action</action></$Recurrence>"
            if ($ActionResponse.response.status -eq "error") { throw $ActionResponse.response.msg.line }
            $TimeResponse = Send-PaApiQuery -Config set -XPath "$basexpath/$Recurrence&element=<at>$Time</at>"
            if ($TimeResponse.response.status -eq "error") { throw "$Recurrence";$TimeResponse.response.msg.line.line."#cdata-section" }
            if ($Recurrence -eq "weekly") {
                $DayResponse = Send-PaApiQuery -Config set -XPath "$basexpath/$Recurrence&element=<day-of-week>$Day</day-of-week>"
                if ($DayResponse.response.status -eq "error") { throw $DayResponse.response.msg.line }
            }
        }

        Function Process-Query ( [String]$PaConnectionString ) {
            switch ($Content) {
                threats { $Content = "threats"; Set-Schedule $Content      }
                av      { $Content = "anti-virus"; Set-Schedule $Content   }
                url     { $Content = "url-database"; Set-Schedule $Content }
                all     {
                            $Contents = @("threats","anti-virus","url-database")
                            foreach ($C in $Contents) {
                                Set-Schedule $C
                            }
                        }
            }
        }
    }

    PROCESS {
        if (($Recurrence -eq "Hourly") -and ($Content -ne "av")) { Throw "Only Threats can be scheduled hourly" }
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
function Test-PaConnection {
    if (!($Global:PaConnectionArray)) {
        return $false
    } else {
        return $true
    }
}

function Update-PaContent {
    <#
	.SYNOPSIS
		Updates Pa Content files.
	.DESCRIPTION
		
	.EXAMPLE
        EXAMPLES!
	.EXAMPLE
		EXAMPLES!
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
	#>

    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection
    )

    BEGIN {
        Function Process-Query ( [String]$PaConnectionString ) {
            $UpToDate = $false

            $xpath = "<request><content><upgrade><check></check></upgrade></content></request>"
            "checking for new content"
            $ContentUpdate = Send-PaApiQuery -Op $xpath
            if ($ContentUpdate.response.status -ne "success") { throw $ContentUpdate.response.msg }
            if ($ContentUpdate.response.result."content-updates".entry.current -eq "no") {            
                if ($ContentUpdate.response.result."content-updates".entry.downloaded -eq "no") {
                    $xpath = "<request><content><upgrade><download><latest></latest></download></upgrade></content></request>"
                    $ContentDownload = Send-PaApiQuery -Op $xpath
                    if ($ContentDownload.response.status -ne "success") { throw $ContentDownload.response.msg }
                    
                    $job = $ContentDownload.response.result.job
                    $size = [Decimal]($ContentUpdate.response.result."content-updates".entry.size)
                    $Version = $ContentUpdate.response.result."content-updates".entry.version
                    $Status = Watch-PaJob -Job $job -c "Downloading $Version" -s $Size
                    if ($Status.response.status -ne "success") { throw $Status.response.msg }
                } else {
                    "content already downloaded"
                }
                $xpath = "<request><content><upgrade><install><version>latest</version></install></upgrade></content></request>"
                $ContentInstall = Send-PaApiQuery -Op $xpath
                $Job = $ContentInstall.response.result.job
                $Status = Watch-PaJob -Job $job -c "Installing content $Version"
                
                if ($Status.response.result.job.details.Line.newjob.nextjob) {
                    $Job = $Status.response.result.job.details.Line.newjob.nextjob
                    $Status = Watch-PaJob -Job $job -c "New content push"
                }
            } else {
                $UpToDate = $true
                "content already installed"
            }

            $xpath = "<request><anti-virus><upgrade><check></check></upgrade></anti-virus></request>"
            "checking for new antivirus"
            $AvUpdate = Send-PaApiQuery -Op $xpath
            if ($AvUpdate.response.status -ne "success") { throw $AvUpdate.response.msg }

            if ($AvUpdate.response.result."content-updates".entry.current -eq "no") {
                if ($AvUpdate.response.result."content-updates".entry.downloaded -eq "no") {
                    $xpath = "<request><anti-virus><upgrade><download><latest></latest></download></upgrade></anti-virus></request>"
                    $AvDownload = Send-PaApiQuery -Op $xpath
                    if ($AvDownload.response.status -ne "success") { throw $AvDownload.response.msg }
                    
                    $job = $AvDownload.response.result.job
                    $size = [Decimal]($AvUpdate.response.result."content-updates".entry.size)
                    $Version = $AvUpdate.response.result."content-updates".entry.version
                    $Status = Watch-PaJob -Job $job -c "Downloading antivirus $Version" -s $Size
                    if ($Status.response.status -ne "success") { throw $Status.response.msg }
                } else {
                    "antivirus already downloaded"
                }
                $xpath = "<request><anti-virus><upgrade><install><version>latest</version></install></upgrade></anti-virus></request>"
                $AvInstall = Send-PaApiQuery -Op $xpath
                if ($AvInstall.response.status -ne "success") { throw $AvInstall.response.msg }
                
                $job = $AvInstall.response.result.job
                $Status = Watch-PaJob -Job $Job -c "Installing antivirus $Version"
                if ($Status.response.status -ne "success") { throw $Status.response.msg }
                
                if ($status.response.result.job.details.line.newjob.nextjob) {
                    $Job = $status.response.result.job.details.line.newjob.nextjob
                    $Status = Watch-PaJob -Job $job -c "pushing antivirus"
                }
            } else {
                $UpToDate = $true
                "antivirus already install"
            }

            return $UpToDate
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
function Update-PaSoftware {
    <#
	.SYNOPSIS
		Updates PanOS System Software to desired level.
	.DESCRIPTION
		Updates PanOS System Software to desired level.  Can do multiple stepped updated, download only and restart or not.
	.EXAMPLE
        EXAMPLES!
	.EXAMPLE
		EXAMPLES!
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
	#>

    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection,

        [Parameter(Mandatory=$True)]
        [alias('v')]
        [ValidatePattern("\d\.\d\.\d(-\w\d+)?|latest")]
        [String]$Version,

        [Parameter(Mandatory=$False)]
        [alias('d')]
        [Switch]$DownloadOnly,

        [Parameter(Mandatory=$False)]
        [alias('nr')]
        [Switch]$NoRestart
    )

    BEGIN {
        Function Get-Stepping ( [String]$Version ) {
            $Stepping = @()
            $UpdateCheck = Send-PaApiQuery -Op "<request><system><software><check></check></software></system></request>"
            if ($UpdateCheck.response.status -eq "success") {
                $VersionInfo = Send-PaApiQuery -Op "<request><system><software><info></info></software></system></request>"
                $AllVersions = $VersionInfo.response.result."sw-updates".versions.entry
                $DesiredVersion = $AllVersions | where { $_.version -eq "$Version" }
                if (!($DesiredVersion)) { return "version $Version not listed" }
                $DesiredBase = $DesiredVersion.version.Substring(0,3)
                $CurrentVersion = (Get-PaSystemInfo)."sw-version"
                $CurrentBase = $CurrentVersion.Substring(0,3)
                if ($CurrentBase -eq $DesiredBase) {
                    $Stepping += $Version
                } else {
                    foreach ($v in $AllVersions) {
                        $Step = $v.version.Substring(0,3)
                        if (($Stepping -notcontains "$Step.0") -and ("$Step.0" -ne "$CurrentBase.0") -and ($Step -le $DesiredBase)) {
                            $Stepping += "$Step.0"
                        }
                    }
                    $Stepping += $Version
                }
                set-variable -name pacom -value $true -scope 1
                return $Stepping | sort
            } else {
                return $UpdateCheck.response.msg.line
            }
        }

        Function Download-Update ( [Parameter(Mandatory=$True)][String]$Version ) {
            $VersionInfo = Send-PaApiQuery -Op "<request><system><software><info></info></software></system></request>"
            if ($VersionInfo.response.status -eq "success") {
                $DesiredVersion = $VersionInfo.response.result."sw-updates".versions.entry | where { $_.version -eq "$Version" }
                if ($DesiredVersion.downloaded -eq "no") {
                    $Download = Send-PaApiQuery -Op "<request><system><software><download><version>$($DesiredVersion.version)</version></download></software></system></request>"
                    $job = [decimal]($Download.response.result.job)
                    $Status = Watch-PaJob -j $job -c "Downloading $($DesiredVersion.version)" -s $DesiredVersion.size -i 2 -p 1
                    if ($Status.response.result.job.result -eq "FAIL") {
                        return $Status.response.result.job.details.line
                    }
                    set-variable -name pacom -value $true -scope 1
                    return $Status
                } else {
                    set-variable -name pacom -value $true -scope 1
                    return "PanOS $Version already downloaded"
                }
            } else {
                throw $VersionInfo.response.msg.line
            }
        }

        Function Install-Update ( [Parameter(Mandatory=$True)][String]$Version ) {
            $VersionInfo = Send-PaApiQuery -Op "<request><system><software><info></info></software></system></request>"
            if ($VersionInfo.response.status -eq "success") {
                $DesiredVersion = $VersionInfo.response.result."sw-updates".versions.entry | where { $_.version -eq "$Version" }
                if ($DesiredVersion.downloaded -eq "no") { "PanOS $Version not downloaded" }
                if ($DesiredVersion.current -eq "no") {
                    $xpath = "<request><system><software><install><version>$Version</version></install></software></system></request>"
                    $Install = Send-PaApiQuery -Op $xpath
                    $Job = [decimal]($Install.response.result.job)
                    $Status = Watch-PaJob -j $job -c "Installing $Version" -i 2 -p 1
                    if ($Status.response.result.job.result -eq "FAIL") {
                        return $Status.response.result.job.details.line
                    }
                    set-variable -name pacom -value $true -scope 1
                    return $Status
                } else {
                    set-variable -name pacom -value $true -scope 1
                    return "PanOS $Version already installed"
                }
            } else {
                return $VersionInfo.response.msg.line
            }
        }

        Function Process-Query ( [String]$PaConnectionString ) {
            $pacom = $false
            while (!($pacom)) {
                if ($Version -eq "latest") {
                    $UpdateCheck = Send-PaApiQuery -Op "<request><system><software><check></check></software></system></request>"
                    if ($UpdateCheck.response.status -eq "success") {
                        $VersionInfo = Send-PaApiQuery -Op "<request><system><software><info></info></software></system></request>"
                        $Version = ($VersionInfo.response.result."sw-updates".versions.entry | where { $_.latest -eq "yes" }).version
                        if (!($Version)) { throw "no version marked as latest" }
                        $pacom = $true
                    } else {
                        return $UpdateCheck.response.msg.line
                    }
                }
            }

            $pacom = $false
            while (!($pacom)) {
                $Steps = Get-Stepping "$Version"
                $Steps
            }

            Write-host "it will take $($steps.count) upgrades to get to the current firmware"

            if (($Steps.count -gt 1) -and ($NoRestart)) {
                Throw "Must use -Restart for multiple steps"
            }
            
            $status = 0
            if ($DownloadOnly)      { $Total = ($Steps.count) } 
                elseif ($NoRestart) { $Total = ($Steps.count)*2 }
                else                { $Total = ($Steps.count)*3 }

            Write-Progress -Activity "Updating Software $Status/$Total" -Status "$($Status + 1)/$Total`: downloading $s" -id 1 -PercentComplete 0

            foreach ($s in $Steps) {
                $pacom = $false
                
                while (!($pacom)) {
                    $Download += Download-Update $s
                }
                $Status++
                $Progress = ($Status / $total) * 100
                Write-Progress -Activity "Updating Software $Status/$Total" -Status "$($Status + 1)/$Total`: downloading $s" -id 1 -PercentComplete $Progress
            }
            sleep 5

            if ($DownloadOnly) { return $Download }
            
            
            
            foreach ($s in $Steps) {
                $pacom = $false
                Write-Progress -Activity "Updating Software $Status/$Total" -Status "$($Status + 1)/$Total`: installing $s" -id 1 -PercentComplete $Progress
                while (!($pacom)) {
                    $pacom = $true
                    $Install = Install-Update $s
                }
                $Status++
                $Progress = ($Status / $total) * 100
                Write-Progress -Activity "Updating Software $Status/$Total" -Status "$($Status + 1)/$Total`: restarting $s" -id 1 -PercentComplete $Progress
                if (!($NoRestart)) {
                    Restart-PaSystem -i 2 -p 1
                    $Status++
                    $Progress = ($Status / $total) * 100
                    
                }
                Write-Progress -Activity "Updating Software $Status/$Total" -Status "Restarting" -id 1 -PercentComplete $Progress
            }
            Write-Progress -Activity "Updating Software $Status/$Total" -Status "Restarting" -id 1 -PercentComplete 100
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
function Watch-PaJob {
    <#
	.SYNOPSIS
		Watch a given Jobs progress.
	.DESCRIPTION
		
	.EXAMPLE
        EXAMPLES!
	.EXAMPLE
		EXAMPLES!
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
	#>

    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection,

        [Parameter(Mandatory=$True)]
        [alias('j')]
        [Decimal]$Job,

        [Parameter(Mandatory=$False)]
        [alias('s')]
        [Decimal]$Size,
        
        [Parameter(Mandatory=$False)]
        [alias('i')]
        [Decimal]$Id,
        
        [Parameter(Mandatory=$False)]
        [alias('p')]
        [Decimal]$Parentid,

        [Parameter(Mandatory=$True)]
        [alias('c')]
        [String]$Caption
    )

    BEGIN {
        Function Process-Query ( [String]$PaConnectionString ) {
            $cmd = "<show><jobs><id>$Job</id></jobs></show>"
            $JobStatus = Send-PaApiQuery -op "$cmd"
            $TimerStart = Get-Date
            
            $ProgressParams = @{}
            $ProgressParams.add("Activity",$Caption)
            if ($Id)       { $ProgressParams.add("Id",$Id) }
            if ($ParentId) { $ProgressParams.add("ParentId",$ParentId) }
            $ProgressParams.add("Status",$null)
            $ProgressParams.add("PercentComplete",$null)

            while ($JobStatus.response.result.job.status -ne "FIN") {
                $JobProgress = $JobStatus.response.result.job.progress
                $SizeComplete = ([decimal]$JobProgress * $Size)/100
                $Elapsed = ((Get-Date) - $TimerStart).TotalSeconds
                if ($Elapsed -gt 0) { $Speed = [math]::Truncate($SizeComplete/$Elapsed*1024) }
                $Status = $null
                if ($size)          { $Status = "$Speed`KB/s " } 
                $Status += "$($JobProgress)% complete"
                $ProgressParams.Set_Item("Status",$Status)
                $ProgressParams.Set_Item("PercentComplete",$JobProgress)
                Write-Progress @ProgressParams
                $JobStatus = Send-PaApiQuery -op "$cmd"
            }
            $ProgressParams.Set_Item("PercentComplete",100)
            Write-Progress @ProgressParams
            return $JobStatus
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
