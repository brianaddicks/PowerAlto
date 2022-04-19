class PaloAltoDevice {
    [string]$Name
    [string]$Model
    [string]$Serial
    [string]$Hostname
    [string]$ApiKey

    # Verion info
    [string]$OsVersion
    [string]$GpAgent
    [string]$AppVersion
    [string]$ThreatVersion
    [string]$WildFireVersion
    [string]$UrlVersion

    # Settings
    [bool]$VsysEnabled
    [xml]$Config

    [ValidateRange(1, 65535)]
    [int]$Port = 443

    [ValidateSet('http', 'https')]
    [string]$Protocol = "https"

    # Context Data
    [string]$TargetVsys = 'shared'
    [string]$TargetDeviceGroup

    # Track usage
    hidden [bool]$Connected
    hidden [string]$ConfigNode
    [array]$UrlHistory
    [array]$RawQueryResultHistory
    [array]$QueryHistory
    [array]$QueryParamHistory
    $LastError
    $LastResult

    # Create XPath
    [string] createXPath ([string]$ConfigNode, [string]$Name) {
        $XPath = '/config'
        $this.ConfigNode = $ConfigNode
        $ObjectsInSharedOnNonVsysSystems = @()
        $ObjectsInSharedOnNonVsysSystems += 'reports'

        # choose correct vsys/device-group

        $PanoramaNodesinDevices = @(
            'device-group'
            'deviceconfig'
            'log-collector'
            'log-colletor-group'
            'platform'
            'plugins'
            'template'
            'template-stack'
            'wildfire-appliance'
            'wildfire-appliance-cluster'
        )

        if ($this.Model -eq "Panorama") {
            if ($this.TargetDeviceGroup) {
                $XPath += "/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='$($this.TargetDeviceGroup)']"
            } else {
                $ConfigNodeFound = $false
                :PanoramaNodesinDevices foreach ($node in $PanoramaNodesinDevices) {
                    if ($ConfigNode -match $node) {
                        $XPath += "/devices/entry[@name='localhost.localdomain']"
                        $ConfigNodeFound = $true
                        break PanoramaNodesinDevices
                    }
                }

                if (-not $ConfigNodeFound) {
                    $XPath += '/shared'
                }
            }
        } elseif ($ConfigNode -match 'deviceconfig') {
            $XPath += "/devices/entry[@name='localhost.localdomain']"
        } elseif ($ConfigNode -match 'network/') {
            $XPath += "/devices/entry[@name='localhost.localdomain']"
        } else {
            if ($this.VsysEnabled) {
                if ($this.TargetVsys -eq 'shared') {
                    $XPath += '/shared'
                } else {
                    $XPath += "/devices/entry/vsys/entry[@name='$($this.TargetVsys)']"
                }
            } else {
                if ($ObjectsInSharedOnNonVsysSystems -contains $ConfigNode) {
                    $XPath += '/shared'
                } else {
                    $XPath += "/devices/entry/vsys/entry[@name='vsys1']"
                }
            }
        }

        # Add ConfigNode
        $XPath += "/$ConfigNode"

        if ($Name) {
            $XPath += "/entry[@name='$Name']"
        }

        return $XPath
    }

    # Create query string
    static [string] createQueryString ([hashtable]$hashTable) {
        $i = 0
        $queryString = "?"
        foreach ($hash in $hashTable.GetEnumerator()) {
            $i++
            $queryString += $hash.Name + "=" + $hash.Value
            if ($i -lt $HashTable.Count) {
                $queryString += "&"
            }
        }
        return $queryString
    }

    # Generate Api URL
    [String] getApiUrl([string]$formattedQueryString) {
        if ($this.Hostname) {
            $url = "https://" + $this.Hostname + "/api/" + $formattedQueryString
            return $url
        } else {
            return $null
        }
    }

    ##################################### Main Api Query Function #####################################
    # invokeApiQuery
    [xml] invokeApiQuery([hashtable]$queryString,[string]$method, $body) {
        # If the query is not a keygen query we need to append the apikey to the query string
        if ($queryString.type -ne "keygen") {
            $queryString.key = $this.ApiKey
        }

        # format the query string and general the full url
        $formattedQueryString = [HelperWeb]::createQueryString($queryString)
        $url = $this.getApiUrl($formattedQueryString)

        # Populate Query/Url History
        # Redact password if it's a keygen query
        if ($queryString.type -ne "keygen") {
            $this.UrlHistory += $url
        } else {
            $this.UrlHistory += $url.Replace($queryString.password, "PASSWORDREDACTED")
            $queryString.password = $queryString.password, "PASSWORDREDACTED"
        }

        # add query object to QueryHistory
        $this.QueryHistory += $queryString

        # try query
        try {
            $QueryParams = @{}
            $QueryParams.Uri = $url
            $QueryParams.UseBasicParsing = $true
            $QueryParams.Method = $method
            switch ($method) {
<#                 'PUT' {
                    $QueryParams.Uri += $this.createQueryString($queryString)
                    if ('' -ne $body) {
                        $QueryParams.Body = $body
                    }
                } #>
                'POST' {
                    if ('' -ne $body) {
                        $QueryParams.Body = $body
                        if ($queryString.type -eq 'import' -and $queryString.category -eq 'keypair') {
                            $Boundary = [System.Guid]::NewGuid().ToString()
                            $QueryParams.ContentType = "multipart/form-data; boundary=`"$Boundary`""
                            $QueryParams.TimeoutSec = 60
                        }
                    }
                    #$QueryParams.ContentType = 'application/json'
                }
                <# 'PATCH' {
                    $QueryParams.Body = $body
                    $QueryParams.ContentType = 'application/json'
                } #>
                <# 'GET' {
                    $QueryParams.Uri += $this.createQueryString($queryString)
                } #>
                <# 'DELETE' {
                    $QueryParams.Uri += $this.createQueryString($queryString)
                } #>
            }

<#             if ($queryString.type -eq "keygen") {
                $QueryParams.Method = 'POST'
            } else {
                $QueryParams.Method = $method
            } #>

            switch ($global:PSVersionTable.PSEdition) {
                'Core' {
                    $QueryParams.SkipCertificateCheck = $true
                    continue
                }
                default {
                    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                    try {
                        add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
                    } catch {

                    }
                    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
                    continue
                }
            }

            $this.QueryParamHistory += $QueryParams

            $rawResult = Invoke-WebRequest @QueryParams
        } catch {
            Throw $_
        }

        $result = [xml]($rawResult.Content)
        $this.RawQueryResultHistory += $rawResult
        $this.LastResult = $result

        $proccessedResult = $this.processQueryResult($result)

        return $proccessedResult
    }

    # processQueryResult
    [xml] processQueryResult ([xml]$unprocessedResult) {
        $result = $null

        switch ($unprocessedResult.response.status) {
            'success' {
                $result = $unprocessedResult
            }
            'error' {
                if ($unprocessedResult.response.msg.line) {
                    if ($unprocessedResult.response.msg.line.'#cdata-section') {
                        $Message = $unprocessedResult.response.msg.line.'#cdata-section' -join "`r`n"
                        Write-Verbose "line and #cdata-section detected: $Message"
                    } else {
                        $Message = $unprocessedResult.response.msg.line -join "`r`n"
                        Write-Verbose "line detected: $Message"
                    }
                } else {
                    $Message = $unprocessedResult.response.msg
                    Write-Verbose "line not detected: $Message"
                }
                Throw $Message
            }
            'unauth' {
                $Message = $unprocessedResult.response.msg.line
                Throw $Message
            }
        }

        return $result
    }

    # Keygen API Query
    [xml] invokeKeygenQuery([PSCredential]$credential) {
        $queryString = @{}
        $queryString.type = "keygen"
        $queryString.user = $credential.UserName
        $queryString.password = $Credential.getnetworkcredential().password
        $result = $this.invokeApiQuery($queryString,'POST','')
        $this.ApiKey = $result.response.result.key
        return $result
    }

    # Commit API Query
    [xml] invokeCommitQuery([string]$cmd) {
        $queryString = @{}
        $queryString.type = "commit"
        $queryString.cmd = $cmd
        $result = $this.invokeApiQuery($queryString)
        return $result
    }

    # Operational API Query
    [xml] invokeOperationalQuery([string]$cmd) {
        $queryString = @{}
        $queryString.type = "op"
        $queryString.cmd = $cmd
        $result = $this.invokeApiQuery($queryString)
        return $result
    }

    # invokeConfigQuery without element
    [Xml] invokeConfigQuery([string]$Action, [string]$XPath) {
        $queryString = @{}
        $queryString.type = "config"
        $queryString.action = $Action
        $queryString.xpath = $xPath

        $result = $this.invokeApiQuery($queryString)
        return $result
    }

    # invokeConfigQuery with element/location
    [Xml] invokeConfigQuery([string]$Action, [string]$XPath, [string]$Element) {
        $queryString = @{}
        $queryString.type = "config"
        $queryString.action = $Action
        $queryString.xpath = $XPath
        switch ($Action) {
            'move' {
                $queryString.where = $Element
                continue
            }
            'set' {
                $queryString.element = $Element
                continue
            }
        }

        $result = $this.invokeApiQuery($queryString)
        return $result
    }

    # invokeReportQuery
    [Xml] invokeReportQuery([string]$ReportType, [string]$ReportName, [string]$Cmd) {
        $queryString = @{}
        $queryString.type = "report"
        $queryString.reporttype = $ReportType
        $queryString.reportname = $ReportName
        $queryString.cmd = $Cmd

        $result = $this.invokeApiQuery($queryString)
        return $result
    }

    # invokeReportGetQuery
    [Xml] invokeReportGetQuery([int]$JobId) {
        $queryString = @{}
        $queryString.type = "report"
        $queryString.action = "get"
        $queryString.'job-id' = $JobId

        $result = $this.invokeApiQuery($queryString)
        return $result
    }

    # with just a querystring
    [psobject] invokeApiQuery([hashtable]$queryString) {
        return $this.invokeApiQuery($queryString, 'GET', '')
    }

    # with just a method
    [psobject] invokeApiQuery([string]$method) {
        return $this.invokeApiQuery(@{}, $method, '')
    }

    # with no method or querystring specified
    [psobject] invokeApiQuery() {
        return $this.invokeApiQuery(@{}, 'GET', '')
    }

    #  https://<firewall>/api/?type=report&action=get&job-id=jobid

    # Test Connection
    [bool] testConnection() {
        $result = $this.invokeOperationalQuery('<show><system><info></info></system></show>')
        $this.Connected = $true
        $this.Name = $result.response.result.system.devicename
        $this.Hostname = $result.response.result.system.'ip-address'
        $this.Model = $result.response.result.system.model
        $this.Serial = $result.response.result.system.serial
        $this.OsVersion = $result.response.result.system.'sw-version'
        $this.GpAgent = $result.response.result.system.'global-protect-client-package-version'
        $this.AppVersion = $result.response.result.system.'app-version'
        $this.ThreatVersion = $result.response.result.system.'threat-version'
        $this.WildFireVersion = $result.response.result.system.'wildfire-version'
        $this.UrlVersion = $result.response.result.system.'url-filtering-version'
        if ($result.response.result.system.'multi-vsys' -eq 'on') {
            $this.VsysEnabled = $true
        } else {
            $this.VsysEnabled = $false
        }
        return $true
    }

    ##################################### Initiators #####################################
    # Initiator with apikey
    PaloAltoDevice([string]$Hostname, [string]$ApiKey) {
        $this.Hostname = $Hostname
        $this.ApiKey = $ApiKey
    }

    # Initiator with Credential
    PaloAltoDevice([string]$Hostname, [PSCredential]$Credential) {
        $this.Hostname = $Hostname
        $this.invokeKeygenQuery($Credential)
    }

    # Initiator with configfile
    PaloAltoDevice([string]$ConfigFilePath) {
        $this.Config = [xml](Get-Content -Path $ConfigFilePath -Raw)
        $this.OsVersion = $this.Config.config.version
        $this.Name = $this.Config.config.devices.entry.deviceconfig.system.hostname
        $this.HostName = $this.Config.config.devices.entry.deviceconfig.system.'ip-address'
    }
}