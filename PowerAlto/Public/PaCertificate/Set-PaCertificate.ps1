function Set-PaCertificate {
    [CmdletBinding()]
    Param (
        [parameter(Mandatory=$True,Position=0)]
        [String]$CertificateName,

		[parameter(Mandatory=$True,Position=1)]
        [String]$CertificateFile,

		[parameter(Mandatory=$True,Position=2)]
        [String]$CertificatePassphrase
    )

    BEGIN {
        $VerbosePrefix = "Set-PaCertificate:"
        function New-MultipartFileContent {
            [OutputType('System.Net.Http.MultipartFormDataContent')]
            [CmdletBinding()]
            param(
                [Parameter(Mandatory)]
                [System.IO.FileInfo]$File,
                [string]$HeaderName='file'
            )

            # build the header and make sure to include quotes around Name
            # and FileName like https://github.com/PowerShell/PowerShell/pull/6782)
            $fileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new('form-data')
            $fileHeader.Name = "`"$HeaderName`""
            $fileHeader.FileName = "`"$($File.Name)`""

            # build the content
            $fs = [System.IO.FileStream]::new($File.FullName, [System.IO.FileMode]::Open)
            $fileContent = [System.Net.Http.StreamContent]::new($fs)
            $fileContent.Headers.ContentDisposition = $fileHeader
            $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('application/octet-stream')

            # add it to a new MultipartFormDataContent object
            $mp = [System.Net.Http.MultipartFormDataContent]::new()
            $mp.Add($fileContent)

            # get rid of the quotes around the boundary value
            # https://github.com/PowerShell/PowerShell/issues/9241
            $b = $mp.Headers.ContentType.Parameters | Where-Object { $_.Name -eq 'boundary' }
            $b.Value = $b.Value.Trim('"')

            # return an array wrapped copy of the object to avoid PowerShell unrolling 
            return @(,$mp)
        }
        
    }

    PROCESS {
        $BodyLines = New-MultipartFileContent -File $CertificateFile
        $QueryString = @{}
        $QueryString.type = 'import'
        $QueryString.category = 'keypair'
        $QueryString.'certificate-name' = $CertificateName
        $QueryString.'format' = 'pkcs12'
        $QueryString.'passphrase' = $CertificatePassphrase       

		$ReturnObject = $Global:PaDeviceObject.invokeApiQuery($QueryString, 'POST', $BodyLines)
    }

    END {
        $ReturnObject
    }
}