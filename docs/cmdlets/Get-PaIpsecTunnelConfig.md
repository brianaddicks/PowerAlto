---
external help file: PowerAlto-help.xml
Module Name: PowerAlto
online version:
schema: 2.0.0
---

# Get-PaIpsecTunnelConfig

## SYNOPSIS
Retrieves configurations of IpsecTunnel.

## SYNTAX

```
Get-PaIpsecTunnelConfig [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves configurations of IpsecTunnel.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-PaIpsecTunnelConfig -Name 'MyIpsecTunnel'
```

Retrieves configuration of IPSEC Tunnel named 'MyIpsecTunnel'.

## PARAMETERS

### -Name
Name of IPSEC Tunnel.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
