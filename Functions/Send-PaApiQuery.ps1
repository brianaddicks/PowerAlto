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
        [ValidateSet("traffic","threat","config","system","hip-match")]
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
                    if ($Element) { $url += "/$Element" }
                    $Member = $Member.replace(" ",'%20')
                    if ($Member -match ",") {
                        foreach ($Value in $Member.split(',')) {
                            if ($Value) { $Members += "<member>$Value</member>" }
                        }
                        $Member = $Members
                    }
                    if ($Element) { $url+= "&element=<$element>$Member</$element>" }
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
                return "Currently non-functional, not sure how to do this with webclient"


            ##############################LOGS##############################
            } elseif ($Log) {
                "type=log"
                "log-type=$Log"
                if ($LogQuery) { "query=$($LogQuery.Replace(" ",'%20'))" }
                if ($NumberLogs) { "nlogs=$NumberLogs" }
                if ($SkipLogs) { "skip=$SkipLogs" }
                if ($LogAction) {
                    "action=$LogAction"
                    "job-id=$LogJob"
                }
                return "Haven't gotten to this yet"

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

