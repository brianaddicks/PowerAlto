[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true,ParameterSetName = 'StartJob')]
    [string]$ApiKey,

    [Parameter(Mandatory = $true,ParameterSetName = 'StartJob')]
    [string]$DomainName,

    [Parameter(Mandatory = $true,ParameterSetName = 'StartJob')]
    [string[]]$PaloAltoAddress,

    [Parameter(Mandatory = $false,ParameterSetName = 'StartJob')]
    [string]$LogFolder,

    [Parameter(Mandatory = $true,ParameterSetName = 'StopJob')]
    [switch]$StopJob
)

$JobName = 'NPS-TO-PA-USERID'

switch ($PsCmdlet.ParameterSetName) {
    'StopJob' {
        Unregister-Event $JobName
        Remove-Job -Name $JobName -Force
        return
    }
}

# If job is already running, unregister it and start over
if ([bool](Get-Job -Name $JobName -ErrorAction SilentlyContinue)) {
    Unregister-Event $JobName
    Remove-Job -Name $JobName -Force
}

$Log = [System.Diagnostics.EventLog]"Security"
$Action = {
    # get the original event entry that triggered the event
    $entry = $event.SourceEventArgs.Entry

    # do something based on the event
    if ($entry.EventId -eq 6272) {
        $IpRx = [regex]'Client\sIP\sAddress:\s+(?<ip>\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b)'
        $ThisIP = $IpRx.Match($Entry.Message).Groups['ip'].Value

        $AccountNameRx = [regex] 'Fully\sQualified\sAccount\sName:\s+(?<name>.+)'
        $AccountName = $AccountNameRx.Match($Entry.Message).Groups['name'].Value
        if ($AccountName -match '@') {
            $AccountName = $AccountName.Split('@')[0]
        }

        if ($AccountName -match '\\') {
            $AccountName = $AccountName.Split('\')[1]
        }

        # don't send events for hostname logins
        if ($AccountName -match '(host\/|\$)') {
            Write-Warning "bad name: $AccountName"
            return
        }

        $AccountName = $DomainName + "\" + $AccountName.ToLower()

        Write-Warning "Event was received...............$AccountName $ThisIp"

        # ignore invalid certs
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

        $NewXml = @"
<uid-message>
<version>1.0</version>
<type>update</type>
<payload>
<login>
<entry name="$AccountName" ip="$ThisIP" />
</login>
</payload>
</uid-message>
"@

        $NewXml = $NewXml -replace "`r","" -replace "`n",""

        $EncodedXml = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($NewXml))

        foreach ($paAddress in $PaloAltoAddress) {
            $Uri = "https://$paAddress/api/?type=user-id&key=$ApiKey"
            $Uri += "&cmd=$NewXml"
            if ($LogFolder) {
                if (Test-Path $LogFolder) {
                    $LogPath = Join-Path -Path $LogFolder -ChildPath 'nps-to-pa.log'
                    Write-Warning "$AccountName -> $ThisIP to PA: $paAddress"
                    "$AccountName -> $ThisIP to PA: $paAddress" | Out-File -FilePath $LogPath -Append
                }
            }
            $global:testevent = $entry
            $SendRequest = Invoke-RestMethod -Uri $Uri
        }
    }
}

$job = Register-ObjectEvent -InputObject $log -EventName EntryWritten -SourceIdentifier $JobName -Action $Action