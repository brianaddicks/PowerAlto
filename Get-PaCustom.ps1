function Get-PaCustom {
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$PaConnectionString,

        [Parameter(Mandatory=$True,Position=1)]
        [string]$Type,

        [Parameter(Mandatory=$True,Position=2)]
        [string]$Action,

        [Parameter(Mandatory=$True,Position=3)]
        [string]$XPath
    )

    BEGIN {
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    }

    PROCESS {
        $url = "$PaConnectionString&type=$type&action=$action&xpath=$xpath"
        $CustomData = [xml]$WebClient.DownloadString($Url)
        if ($CustomData.response.status -eq "success") {
            if (($action -eq "show") -or ($action -eq "get")) {
                return $CustomData
            } else {
                return $customdata.response.status
            }
        } else {
            Throw "$($CustomData.response.result.msg)"
        }
    }
}

