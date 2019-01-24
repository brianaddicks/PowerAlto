# PowerAlto

PowerAlto is a PowerShell module used to interact with Palo Alto Firewalls as well as Panorama.

## Installation

As Classes (introduced in PowerShell 5) are heavily used in PowerAlto, PowerShell 5 or PowerShell Core is required to run this module.

```powershell
Install-Module PowerAlto
```

## Usage

Basic usage of this module consists of connecting to a device and then running API calls. The initial connection can be performed with a PSCredential object or with an API key.

### Connecting

```powershell
# Connecting with a PSCredential
Get-PaDevice -DeviceAddress pa.example.com -Credential (Get-Credential)

# Connecting with an API key
Get-PaDevice -DeviceAddress pa.example.com -ApiKey 'mysupersecretapikey'
```

### Generic API Calls

The following generic cmdlets are available to make config, operational, report, and commit api calls.

* Invoke-PaApiConfig
* Invoke-PaApiOperation
* Invoke-PaApiReport
* Invoke-PaCommit

### Specific API Calls

More specific cmdlets are available for commonly performed tasks.

* Get-PaAddress
* Get-PaAddressGroup
* Get-PaConfigDiff
* Get-PaCustomReport
* Get-PaDevice
* Get-PaInterface
* Get-PaJob
* Get-PaNatPolicy
* Get-PaReportJob
* Get-PaSecurityPolicy
* Get-PaTag
* Get-PaUrlCategory
* Invoke-PaCustomReport
* Move-PaSecurityPolicy
* New-PaTag
* Remove-PaAddress
* Remove-PaAddressGroup
* Remove-PaSecurityPolicy
* Remove-PaTag
* Set-PaAddress
* Set-PaAddressGroup
* Set-PaCustomReport
* Set-PaSecurityPolicy
* Set-PaTag
* Set-PaTargetDeviceGroup
* Set-PaTargetVsys
* Set-PaUrlCategory
