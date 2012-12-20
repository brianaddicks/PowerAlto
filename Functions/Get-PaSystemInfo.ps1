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

