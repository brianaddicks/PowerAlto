---
external help file: PowerAlto4-help.xml
Module Name: PowerAlto4
online version:
schema: 2.0.0
---

# Get-PaDevice

## SYNOPSIS
Establishes initial connection to Palo Alto API.

## SYNTAX

### ApiKey (Default)
```
Get-PaDevice [-DeviceAddress] <String> [-ApiKey] <String> [[-Port] <Int32>] [-HttpOnly] [-SkipCertificateCheck]
 [-Quiet] [-Vsys <String>] [<CommonParameters>]
```

### Credential
```
Get-PaDevice [-DeviceAddress] <String> [-Credential] <PSCredential> [[-Port] <Int32>] [-HttpOnly]
 [-SkipCertificateCheck] [-Quiet] [-Vsys <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-PaDevice cmdlet establishes and validates connection parameters to allow further communications to the Palo Alto API.
The cmdlet needs at least two parameters:
 - The device IP address or FQDN
 - A valid API key or PSCredential object

The cmdlet returns an object containing details of the connection, but this can be discarded or saved as desired; the returned object is not necessary to provide to further calls to the API.

## EXAMPLES

### EXAMPLE 1
```
Get-PaDevice -DeviceAddress "pa.example.com" -ApiKey "LUFRPT1asdfPR2JtSDl5M2tjfdsaTktBeTkyaGZMTURasdfTTU9BZm89OGtKN0F"
```

Connects to Palo Alto Device using the default port (443) over SSL (HTTPS) using an API Key

### EXAMPLE 2
```
Get-PaDevice -DeviceAddress "pa.example.com" -Credential (Get-Credential)
```

Prompts the user for username and password and connects to the Palo Alto Device with those creds. 
This will generate a keygen call and the user's API Key will be used for all subsequent calls.

## PARAMETERS

### -DeviceAddress
Fully-qualified domain name for the Palo Alto Device.
Don't include the protocol ("https://" or "http://").

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiKey
ApiKey used to access Palo Alto Device.

```yaml
Type: String
Parameter Sets: ApiKey
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
PSCredental object to provide as an alternative to an API Key.

```yaml
Type: PSCredential
Parameter Sets: Credential
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Port
The port the Palo Alto Device is using for management communicatins.
This defaults to port 443 over HTTPS, and port 80 over HTTP.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 443
Accept pipeline input: False
Accept wildcard characters: False
```

### -HttpOnly
When specified, configures the API connection to run over HTTP rather than the default HTTPS.
Not recommended!

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: http

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipCertificateCheck
When used, all certificate warnings are ignored.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Quiet
When used, the cmdlet returns nothing on success.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: q

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Vsys
{{Fill Vsys Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
