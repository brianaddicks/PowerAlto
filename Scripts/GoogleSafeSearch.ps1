remove-module poweralto
Import-Module c:\dev\poweralto\poweralto.psm1
Add-Type -AssemblyName System.Web

###############################################################################
# New App Basics
###############################################################################

$Name      = "google-websearch"
$Signature = "google-websearch"
$BaseXpath = "/config/devices/entry[@name='localhost.localdomain']/vsys/entry[@name='vsys1']/application/entry[@name='$Name']"

###############################################################################
# Basic Elements of the application

$Element = "<subcategory>internet-utility</subcategory>
            <category>general-internet</category>
            <technology>client-server</technology>
            <description>detect google web search, different from google image search</description>
            <risk>2</risk>
            <evasive-behavior>no</evasive-behavior>
            <consume-big-bandwidth>no</consume-big-bandwidth>
            <used-by-malware>no</used-by-malware>
            <able-to-transfer-file>no</able-to-transfer-file>
            <has-known-vulnerability>no</has-known-vulnerability>
            <tunnel-other-application>no</tunnel-other-application>
            <tunnel-applications>no</tunnel-applications>
            <prone-to-misuse>no</prone-to-misuse>
            <pervasive-use>no</pervasive-use>
            <file-type-ident>no</file-type-ident>
            <virus-ident>no</virus-ident>
            <spyware-ident>no</spyware-ident>
            <data-ident>no</data-ident>
            <parent-app>web-browsing</parent-app>"

$Create  = Send-PaApiQuery -Config set -XPath $BaseXpath -Element $Element
if ($Create.response.status -ne "success") { Throw $Create.response.msg }

###############################################################################
# Define Ports

$PortPath = $BaseXpath + "/default"
$Element  = 'port'
$Member   = 'tcp/80,tcp/443'

$SetPort = Send-PaApiQuery -Config set -XPath $PortPath -Element $Element -Member $Member
if ($SetPort.response.status -ne "success") { Throw $SetPort.response.msg }

###############################################################################
# Create Signature

$Sigpath  = $BaseXpath + "/signature/entry[@name='$Signature']"
$Element  = '<scope>protocol-data-unit</scope>'
$Element += '<order-free>yes</order-free>'

$SetSig = Send-PaApiQuery -Config set -XPath $Sigpath -Element $Element
if ($SetSig.response.status -ne "success") { Throw $SetSig.response.msg }

###############################################################################
# Create 1st condition

$AndCondition = 'And Condition 2'
$OrCondition  = 'Or Condition 1'
$Pattern = [System.Web.HttpUtility]::UrlEncode('\.google\.')
$Context = [System.Web.HttpUtility]::UrlEncode('http-req-headers')

$Xpath    = $Sigpath + "/and-condition/entry[@name='$AndCondition']/or-condition/entry[@name='$OrCondition']/operator/pattern-match"
$Element  = "<pattern>$Pattern</pattern>"
$Element += "<context>$Context</context>"

$SetCon = Send-PaApiQuery -Config set -XPath $Xpath -Element $Element
if ($SetCon.response.status -ne "success") { Throw $SetCon.response.msg }

###############################################################################
# Create 2nd condition

$AndCondition = 'And Condition 4'
$OrCondition  = 'Or Condition 1'
$Pattern = [System.Web.HttpUtility]::UrlEncode('hl=en&amp;gs_nf=')
$Context = [System.Web.HttpUtility]::UrlEncode('http-req-params')

$Xpath    = $Sigpath + "/and-condition/entry[@name='$AndCondition']/or-condition/entry[@name='$OrCondition']/operator/pattern-match"
$Element  = "<pattern>$Pattern</pattern>"
$Element += "<context>$Context</context>"

$SetCon = Send-PaApiQuery -Config set -XPath $Xpath -Element $Element
if ($SetCon.response.status -ne "success") { Throw $SetCon.response.msg }




###############################################################################
# New App Basics
###############################################################################

$Name      = "google-image-search-moderate"
$Signature = "google-image-search-moderate"
$BaseXpath = "/config/devices/entry[@name='localhost.localdomain']/vsys/entry[@name='vsys1']/application/entry[@name='$Name']"

###############################################################################
# Basic Elements of the application

$Element  = '<subcategory>photo-video</subcategory>'
$Element += '<category>media</category>'
$Element += '<technology>client-server</technology>'
$Element += '<description>detect google image search, different from google web search</description>'
$Element += '<risk>2</risk>'
$Element += '<evasive-behavior>no</evasive-behavior>'
$Element += '<consume-big-bandwidth>no</consume-big-bandwidth>'
$Element += '<used-by-malware>no</used-by-malware>'
$Element += '<able-to-transfer-file>no</able-to-transfer-file>'
$Element += '<has-known-vulnerability>no</has-known-vulnerability>'
$Element += '<tunnel-other-application>no</tunnel-other-application>'
$Element += '<tunnel-applications>no</tunnel-applications>'
$Element += '<prone-to-misuse>no</prone-to-misuse>'
$Element += '<pervasive-use>no</pervasive-use>'
$Element += '<file-type-ident>no</file-type-ident>'
$Element += '<virus-ident>no</virus-ident>'
$Element += '<spyware-ident>no</spyware-ident>'
$Element += '<data-ident>no</data-ident>'
$Element += '<parent-app>web-browsing</parent-app>'
#$Element  = [System.Web.HttpUtility]::UrlEncode($Element)

$Create  = Send-PaApiQuery -Config set -XPath $BaseXpath -Element $Element
if ($Create.response.status -ne "success") { Throw $Create.response.msg }

###############################################################################
# Define Ports

$PortPath = $BaseXpath + "/default"
$Element  = 'port'
$Member   = 'tcp/80,tcp/443'

$SetPort = Send-PaApiQuery -Config set -XPath $PortPath -Element $Element -Member $Member
if ($SetPort.response.status -ne "success") { Throw $SetPort.response.msg }

###############################################################################
# Create Signature

$Sigpath  = $BaseXpath + "/signature/entry[@name='$Signature']"
$Element  = '<scope>protocol-data-unit</scope>'
$Element += '<order-free>yes</order-free>'

$SetSig = Send-PaApiQuery -Config set -XPath $Sigpath -Element $Element
if ($SetSig.response.status -ne "success") { Throw $SetSig.response.msg }

###############################################################################
# Set Condition

$AndCondition = 'And Condition 2'
$OrCondition  = 'Or Condition 1'
$Pattern = [System.Web.HttpUtility]::UrlEncode('www\.google\.com')
$Context = [System.Web.HttpUtility]::UrlEncode('http-req-host-header')

$Xpath    = $Sigpath + "/and-condition/entry[@name='$AndCondition']/or-condition/entry[@name='$OrCondition']/operator/pattern-match"
$Element  = "<pattern>$Pattern</pattern>"
$Element += "<context>$Context</context>"

$SetCon = Send-PaApiQuery -Config set -XPath $Xpath -Element $Element
if ($SetCon.response.status -ne "success") { Throw $SetCon.response.msg }

###############################################################################
# Set Condition

$AndCondition = 'And Condition 4'
$OrCondition  = 'Or Condition 1'
$Pattern = [System.Web.HttpUtility]::UrlEncode('source=')
$Context = [System.Web.HttpUtility]::UrlEncode('http-req-params')

$Xpath    = $Sigpath + "/and-condition/entry[@name='$AndCondition']/or-condition/entry[@name='$OrCondition']/operator/pattern-match"
$Element  = "<pattern>$Pattern</pattern>"
$Element += "<context>$Context</context>"

$SetCon = Send-PaApiQuery -Config set -XPath $Xpath -Element $Element
if ($SetCon.response.status -ne "success") { Throw $SetCon.response.msg }

###############################################################################
# Set Condition

$AndCondition = 'And Condition 5'
$OrCondition  = 'Or Condition 1'
$Pattern = [System.Web.HttpUtility]::UrlEncode(':FF=0:TM')
$Context = [System.Web.HttpUtility]::UrlEncode('http-req-headers')

$Xpath    = $Sigpath + "/and-condition/entry[@name='$AndCondition']/or-condition/entry[@name='$OrCondition']/operator/pattern-match"
$Element  = "<pattern>$Pattern</pattern>"
$Element += "<context>$Context</context>"

$SetCon = Send-PaApiQuery -Config set -XPath $Xpath -Element $Element
if ($SetCon.response.status -ne "success") { Throw $SetCon.response.msg }





###############################################################################
# New App Basics
###############################################################################

$Name      = "google-image-search-ss-off"
$Signature = "google-image-search-ss-off"
$BaseXpath = "/config/devices/entry[@name='localhost.localdomain']/vsys/entry[@name='vsys1']/application/entry[@name='$Name']"

###############################################################################
# Basic Elements of the application

$Element  = '<subcategory>photo-video</subcategory>'
$Element += '<category>media</category>'
$Element += '<technology>client-server</technology>'
$Element += '<description>detect google image search, different from google web search</description>'
$Element += '<risk>2</risk>'
$Element += '<evasive-behavior>no</evasive-behavior>'
$Element += '<consume-big-bandwidth>no</consume-big-bandwidth>'
$Element += '<used-by-malware>no</used-by-malware>'
$Element += '<able-to-transfer-file>no</able-to-transfer-file>'
$Element += '<has-known-vulnerability>no</has-known-vulnerability>'
$Element += '<tunnel-other-application>no</tunnel-other-application>'
$Element += '<tunnel-applications>no</tunnel-applications>'
$Element += '<prone-to-misuse>no</prone-to-misuse>'
$Element += '<pervasive-use>no</pervasive-use>'
$Element += '<file-type-ident>no</file-type-ident>'
$Element += '<virus-ident>no</virus-ident>'
$Element += '<spyware-ident>no</spyware-ident>'
$Element += '<data-ident>no</data-ident>'
$Element += '<parent-app>web-browsing</parent-app>'

$Create  = Send-PaApiQuery -Config set -XPath $BaseXpath -Element $Element
if ($Create.response.status -ne "success") { Throw $Create.response.msg }

###############################################################################
# Define Ports

$PortPath = $BaseXpath + "/default"
$Element  = 'port'
$Member   = 'tcp/80,tcp/443'

$SetPort = Send-PaApiQuery -Config set -XPath $PortPath -Element $Element -Member $Member
if ($SetPort.response.status -ne "success") { Throw $SetPort.response.msg }

###############################################################################
# Create Signature

$Sigpath  = $BaseXpath + "/signature/entry[@name='$Signature']"
$Element  = '<scope>protocol-data-unit</scope>'
$Element += '<order-free>yes</order-free>'

$SetSig = Send-PaApiQuery -Config set -XPath $Sigpath -Element $Element
if ($SetSig.response.status -ne "success") { Throw $SetSig.response.msg }

###############################################################################
# Set Condition

$AndCondition = 'And Condition 2'
$OrCondition  = 'Or Condition 1'
$Pattern = [System.Web.HttpUtility]::UrlEncode('www\.google\.com')
$Context = [System.Web.HttpUtility]::UrlEncode('http-req-host-header')

$Xpath    = $Sigpath + "/and-condition/entry[@name='$AndCondition']/or-condition/entry[@name='$OrCondition']/operator/pattern-match"
$Element  = "<pattern>$Pattern</pattern>"
$Element += "<context>$Context</context>"

$SetCon = Send-PaApiQuery -Config set -XPath $Xpath -Element $Element
if ($SetCon.response.status -ne "success") { Throw $SetCon.response.msg }

###############################################################################
# Set Condition

$AndCondition = 'And Condition 4'
$OrCondition  = 'Or Condition 1'
$Pattern = [System.Web.HttpUtility]::UrlEncode('source=')
$Context = [System.Web.HttpUtility]::UrlEncode('http-req-params')

$Xpath    = $Sigpath + "/and-condition/entry[@name='$AndCondition']/or-condition/entry[@name='$OrCondition']/operator/pattern-match"
$Element  = "<pattern>$Pattern</pattern>"
$Element += "<context>$Context</context>"

$SetCon = Send-PaApiQuery -Config set -XPath $Xpath -Element $Element
if ($SetCon.response.status -ne "success") { Throw $SetCon.response.msg }

###############################################################################
# Set Condition

$AndCondition = 'And Condition 5'
$OrCondition  = 'Or Condition 1'
$Pattern = [System.Web.HttpUtility]::UrlEncode(':FF=4:LD')
$Context = [System.Web.HttpUtility]::UrlEncode('http-req-headers')

$Xpath    = $Sigpath + "/and-condition/entry[@name='$AndCondition']/or-condition/entry[@name='$OrCondition']/operator/pattern-match"
$Element  = "<pattern>$Pattern</pattern>"
$Element += "<context>$Context</context>"

$SetCon = Send-PaApiQuery -Config set -XPath $Xpath -Element $Element
if ($SetCon.response.status -ne "success") { Throw $SetCon.response.msg }




###############################################################################
# New App Basics
###############################################################################

$Name      = "google-safesearch-set-moderate"
$Signature = "google-safesearch-set-moderate"
$BaseXpath = "/config/devices/entry[@name='localhost.localdomain']/vsys/entry[@name='vsys1']/application/entry[@name='$Name']"

###############################################################################
# Basic Elements of the application

$Element  = '<subcategory>photo-video</subcategory>'
$Element += '<category>media</category>'
$Element += '<technology>client-server</technology>'
$Element += '<description>Detect attempt to set safesearch moderate, which is google default setting.</description>'
$Element += '<risk>3</risk>'
$Element += '<evasive-behavior>no</evasive-behavior>'
$Element += '<consume-big-bandwidth>no</consume-big-bandwidth>'
$Element += '<used-by-malware>no</used-by-malware>'
$Element += '<able-to-transfer-file>no</able-to-transfer-file>'
$Element += '<has-known-vulnerability>no</has-known-vulnerability>'
$Element += '<tunnel-other-application>no</tunnel-other-application>'
$Element += '<tunnel-applications>no</tunnel-applications>'
$Element += '<prone-to-misuse>no</prone-to-misuse>'
$Element += '<pervasive-use>no</pervasive-use>'
$Element += '<file-type-ident>no</file-type-ident>'
$Element += '<virus-ident>no</virus-ident>'
$Element += '<spyware-ident>no</spyware-ident>'
$Element += '<data-ident>no</data-ident>'
$Element += '<parent-app>web-browsing</parent-app>'

$Create  = Send-PaApiQuery -Config set -XPath $BaseXpath -Element $Element
if ($Create.response.status -ne "success") { Throw $Create.response.msg }

###############################################################################
# Define Ports

$PortPath = $BaseXpath + "/default"
$Element  = 'port'
$Member   = 'tcp/80,tcp/443'

$SetPort = Send-PaApiQuery -Config set -XPath $PortPath -Element $Element -Member $Member
if ($SetPort.response.status -ne "success") { Throw $SetPort.response.msg }

###############################################################################
# Create Signature

$Sigpath  = $BaseXpath + "/signature/entry[@name='$Signature']"
$Element  = '<scope>protocol-data-unit</scope>'
$Element += '<order-free>yes</order-free>'

$SetSig = Send-PaApiQuery -Config set -XPath $Sigpath -Element $Element
if ($SetSig.response.status -ne "success") { Throw $SetSig.response.msg }

###############################################################################
# Set Condition

$AndCondition = 'And Condition 2'
$OrCondition  = 'Or Condition 1'
$Pattern = [System.Web.HttpUtility]::UrlEncode('\.google\.')
$Context = [System.Web.HttpUtility]::UrlEncode('http-req-headers')

$Xpath    = $Sigpath + "/and-condition/entry[@name='$AndCondition']/or-condition/entry[@name='$OrCondition']/operator/pattern-match"
$Element  = "<pattern>$Pattern</pattern>"
$Element += "<context>$Context</context>"

$SetCon = Send-PaApiQuery -Config set -XPath $Xpath -Element $Element
if ($SetCon.response.status -ne "success") { Throw $SetCon.response.msg }

###############################################################################
# Set Condition

$AndCondition = 'And Condition 3'
$OrCondition  = 'Or Condition 1'
$Pattern = [System.Web.HttpUtility]::UrlEncode('setprefs')
$Context = [System.Web.HttpUtility]::UrlEncode('http-req-uri-path')

$Xpath    = $Sigpath + "/and-condition/entry[@name='$AndCondition']/or-condition/entry[@name='$OrCondition']/operator/pattern-match"
$Element  = "<pattern>$Pattern</pattern>"
$Element += "<context>$Context</context>"

$SetCon = Send-PaApiQuery -Config set -XPath $Xpath -Element $Element
if ($SetCon.response.status -ne "success") { Throw $SetCon.response.msg }

###############################################################################
# Set Condition

$AndCondition = 'And Condition 4'
$OrCondition  = 'Or Condition 1'
$Pattern = [System.Web.HttpUtility]::UrlEncode('safeui=images')
$Context = [System.Web.HttpUtility]::UrlEncode('http-req-params')

$Xpath    = $Sigpath + "/and-condition/entry[@name='$AndCondition']/or-condition/entry[@name='$OrCondition']/operator/pattern-match"
$Element  = "<pattern>$Pattern</pattern>"
$Element += "<context>$Context</context>"

$SetCon = Send-PaApiQuery -Config set -XPath $Xpath -Element $Element
if ($SetCon.response.status -ne "success") { Throw $SetCon.response.msg }





###############################################################################
# New App Basics
###############################################################################

$Name      = "google-safesearch-set-off"
$Signature = "google-safesearch-set-off"
$BaseXpath = "/config/devices/entry[@name='localhost.localdomain']/vsys/entry[@name='vsys1']/application/entry[@name='$Name']"

###############################################################################
# Basic Elements of the application

$Element  = '<subcategory>photo-video</subcategory>'
$Element += '<category>media</category>'
$Element += '<technology>client-server</technology>'
$Element += '<description>Detect attempt to set safesearch OFF, which is no filtering.</description>'
$Element += '<risk>4</risk>'
$Element += '<evasive-behavior>no</evasive-behavior>'
$Element += '<consume-big-bandwidth>no</consume-big-bandwidth>'
$Element += '<used-by-malware>no</used-by-malware>'
$Element += '<able-to-transfer-file>no</able-to-transfer-file>'
$Element += '<has-known-vulnerability>no</has-known-vulnerability>'
$Element += '<tunnel-other-application>no</tunnel-other-application>'
$Element += '<tunnel-applications>no</tunnel-applications>'
$Element += '<prone-to-misuse>no</prone-to-misuse>'
$Element += '<pervasive-use>no</pervasive-use>'
$Element += '<file-type-ident>no</file-type-ident>'
$Element += '<virus-ident>no</virus-ident>'
$Element += '<spyware-ident>no</spyware-ident>'
$Element += '<data-ident>no</data-ident>'
$Element += '<parent-app>web-browsing</parent-app>'

$Create  = Send-PaApiQuery -Config set -XPath $BaseXpath -Element $Element
if ($Create.response.status -ne "success") { Throw $Create.response.msg }

###############################################################################
# Define Ports

$PortPath = $BaseXpath + "/default"
$Element  = 'port'
$Member   = 'tcp/80,tcp/443'

$SetPort = Send-PaApiQuery -Config set -XPath $PortPath -Element $Element -Member $Member
if ($SetPort.response.status -ne "success") { Throw $SetPort.response.msg }

###############################################################################
# Create Signature

$Sigpath  = $BaseXpath + "/signature/entry[@name='$Signature']"
$Element  = '<scope>protocol-data-unit</scope>'
$Element += '<order-free>yes</order-free>'

$SetSig = Send-PaApiQuery -Config set -XPath $Sigpath -Element $Element
if ($SetSig.response.status -ne "success") { Throw $SetSig.response.msg }

###############################################################################
# Set Condition

$AndCondition = 'And Condition 2'
$OrCondition  = 'Or Condition 1'
$Pattern = [System.Web.HttpUtility]::UrlEncode('\.google\.')
$Context = [System.Web.HttpUtility]::UrlEncode('http-req-headers')

$Xpath    = $Sigpath + "/and-condition/entry[@name='$AndCondition']/or-condition/entry[@name='$OrCondition']/operator/pattern-match"
$Element  = "<pattern>$Pattern</pattern>"
$Element += "<context>$Context</context>"

$SetCon = Send-PaApiQuery -Config set -XPath $Xpath -Element $Element
if ($SetCon.response.status -ne "success") { Throw $SetCon.response.msg }

###############################################################################
# Set Condition

$AndCondition = 'And Condition 3'
$OrCondition  = 'Or Condition 1'
$Pattern = [System.Web.HttpUtility]::UrlEncode('setprefs')
$Context = [System.Web.HttpUtility]::UrlEncode('http-req-uri-path')

$Xpath    = $Sigpath + "/and-condition/entry[@name='$AndCondition']/or-condition/entry[@name='$OrCondition']/operator/pattern-match"
$Element  = "<pattern>$Pattern</pattern>"
$Element += "<context>$Context</context>"

$SetCon = Send-PaApiQuery -Config set -XPath $Xpath -Element $Element
if ($SetCon.response.status -ne "success") { Throw $SetCon.response.msg }

###############################################################################
# Set Condition

$AndCondition = 'And Condition 4'
$OrCondition  = 'Or Condition 1'
$Pattern = [System.Web.HttpUtility]::UrlEncode('safeui=off')
$Context = [System.Web.HttpUtility]::UrlEncode('http-req-params')

$Xpath    = $Sigpath + "/and-condition/entry[@name='$AndCondition']/or-condition/entry[@name='$OrCondition']/operator/pattern-match"
$Element  = "<pattern>$Pattern</pattern>"
$Element += "<context>$Context</context>"

$SetCon = Send-PaApiQuery -Config set -XPath $Xpath -Element $Element
if ($SetCon.response.status -ne "success") { Throw $SetCon.response.msg }







###############################################################################
# Import Application Block Response Page
###############################################################################

$data = @'
<html>
    <head>
        <title>Application Blocked</title>
        <style>
            #content{border:3px solid#aaa;background-color:#fff;margin:40;padding:40;font-family:Tahoma,Helvetica,Arial,sans-serif;font-size:12px;}
            h1{font-size:20px;font-weight:bold;color:#196390;}
            b{font-weight:bold;color:#196390;}
        </style>
    </head>
    <body bgcolor="#e7e8e9">
        <div id="content">
            <h1>Application Blocked</h1>
                <p>Access to the application you were trying to use has been blocked in accordance with company policy. Please contact your system administrator if you believe this is in error.</p>
                <p><b>User:</b> <user/> </p>
                <p><b>Application:</b> <appname/> </p>
                <p>test</p>
                <p id="warningText">asdf</p>
        </div>
        <script type="text/javascript">
            var cat = "<appname/>";
            switch(cat)
            {
                 case 'google-image-search-moderate':
                 case 'google-image-search-ss-off':
                 case 'google-safesearch-set-moderate':
                 case 'google-safesearch-set-off':
                      document.getElementById("warningText").innerHTML = "Google Safe Search is not enabled.  To enable it, go to your <a href='https://www.google.com/preferences'> Google Preferences</a> and check <strong>Filter explicit results</strong>, the click <strong>Save</strong>.";
                      break;
            }
        </script>
    </body>
</html>
'@

$data = @'
<html>
    <head>
        <title>Application Blocked</title>
        <style>
            #content{border:3px solid#aaa;background-color:#fff;margin:40;padding:40;font-family:Tahoma,Helvetica,Arial,sans-serif;font-size:12px;}
            h1{font-size:20px;font-weight:bold;color:#196390;}
            b{font-weight:bold;color:#196390;}
        </style>
    </head>
    <body bgcolor="#e7e8e9">
        <div id="content">
            <h1>Application Blocked</h1>
                <p>Access to the application you were trying to use has been blocked in accordance with company policy. Please contact your system administrator if you believe this is in error.</p>
                <p><b>User:</b> <user/> </p>
                <p><b>Application:</b> <appname/> </p>
                <p id="warningText"></p>
        </div>
        <script type="text/javascript">
            var cat = "<appname/>";
            switch(cat)
            {
                 case 'google-image-search-moderate':
                 case 'google-image-search-ss-off':
                 case 'google-safesearch-set-moderate':
                 case 'google-safesearch-set-off':
                      document.getElementById("warningText").innerHTML = "Google Safe Search is not enabled.  To enable it, go to your <a href='https://www.google.com/preferences'> Google Preferences</a> and check <strong>Filter explicit results</strong>, the click <strong>Save</strong>.";
                      break;
            }
        </script>
    </body>
</html>
'@

$buffer = [System.Text.Encoding]::UTF8.GetBytes($data)

$url  = 'https://10.10.72.2/api/?key=LUFRPT1SanJaQVpiNEg4TnBkNGVpTmRpZTRIamR4OUE9Q2lMTUJGREJXOCs3SjBTbzEyVSt6UT09&type=import&category=application-block-page'
$url += '&client=wget&file-name=test'
[System.Net.HttpWebRequest] $webRequest = [System.Net.WebRequest]::Create($url)

$webRequest.Method = "POST"
#$webRequest.headers.Set("token",$ApiKey)
$webRequest.ContentType = "application/xml"
$webRequest.ContentLength = $buffer.Length;

$requestStream = $webRequest.GetRequestStream()
$requestStream.Write($buffer, 0, $buffer.Length)
$requestStream.Flush()
$requestStream.Close()


[System.Net.HttpWebResponse] $webResponse = $webRequest.GetResponse()
$streamReader = New-Object System.IO.StreamReader($webResponse.GetResponseStream())
$result = [xml]$streamReader.ReadToEnd()

if ($result.response.status -ne "success") { throw $result.response.result }





###############################################################################
# create Rule
###############################################################################

$Name = "google-safesearch2"
$SourceZone = @("lan","server","wifi")
$DestinationZone = @("net")

$Source = "any"
$Destination = "any"
$Service = "any"
$Application = @("google-image-search-moderate",
                 "google-image-search-ss-off",
                 "google-safesearch-set-moderate",
                 "google-safesearch-set-off")
$Action = "deny"

$RuleXml  = "<source><member>$Source</member></source>"
$RuleXml += "<destination><member>$Destination</member></destination>"
$RuleXml += "<service><member>$Service</member></service>"

$MemberXml = ""
foreach ($a in $Application) {
    $MemberXml += "<member>$a</member>"
}
$RuleXml += "<application>$MemberXml</application>"

$RuleXml += "<action>$Action</action>"
$RuleXml += "<source-user><member>any</member></source-user>"
$RuleXml += "<option><disable-server-response-inspection>no</disable-server-response-inspection></option>"
$RuleXml += "<negate-source>no</negate-source>"
$RuleXml += "<negate-destination>no</negate-destination>"
$RuleXml += "<disabled>no</disabled>"
$RuleXml += "<log-start>no</log-start>"
$RuleXml += "<log-end>yes</log-end>"
$RuleXml += "<description>Block Google without SafeSearch</description>"

$MemberXml = ""
foreach ($s in $SourceZone) {
    $MemberXml += "<member>$s</member>"
}
$RuleXml += "<from>$MemberXml</from>"

$MemberXml = ""
foreach ($d in $DestinationZone) {
    $MemberXml += "<member>$d</member>"
}
$RuleXml += "<to>$MemberXml</to>"

$CreateRule = Send-PaApiQuery -Config set -XPath "/config/devices/entry/vsys/entry/rulebase/security/rules/entry[@name='$Name']" -Element $RuleXml
if ($CreateRule.response.status -ne "success") { Throw $CreateRule.response.msg }

$MoveRule = Send-PaApiQuery -Config move -XPath "/config/devices/entry/vsys/entry/rulebase/security/rules/entry[@name='$Name']" -MoveWhere top
if ($MoveRule.response.status -ne "success") { Throw $MoveRule.response.msg }

$Commit = Invoke-PaCommit
if ($Commit.status -ne "FIN") { Throw $Commit.details }