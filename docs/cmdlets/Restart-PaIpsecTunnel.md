---
external help file: PowerAlto-help.xml
Module Name: PowerAlto
online version:
schema: 2.0.0
---

# Restart-PaIpsecTunnel

## SYNOPSIS
Restarts active IPSEC Tunnel.

## SYNTAX

```
Restart-PaIpsecTunnel [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION
Clears exising IPSEC and IKE connections for a given tunnel then restarts them with the 'test' command.

## EXAMPLES

### Example 1
```powershell
PS C:\> Restart-PaIpsecTunnel -Name 'MyIpsecTunnel'
```

Clears existing IPSEC Tunnel connection.

## PARAMETERS

### -Name
Name of IPSEC Tunnel.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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
