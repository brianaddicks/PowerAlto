---
external help file: PowerAlto-help.xml
Module Name: PowerAlto
online version:
schema: 2.0.0
---

# Set-PaAddress

## SYNOPSIS
Creates/Configures an address object on a Palo Alto device.

## SYNTAX

### name
```
Set-PaAddress [-Name] <String> -Type <String> -Value <String> [-Description <String>] [-Tag <String[]>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### paaddress
```
Set-PaAddress [-PaAddress] <PaAddress> [-Type <String>] [-Value <String>] [-Description <String>]
 [-Tag <String[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates/Configures an address object on a Palo Alto device.

## EXAMPLES

### EXAMPLE 1
```

```

## PARAMETERS

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
{{Fill Description Description}}

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

### -Name
{{Fill Name Description}}

```yaml
Type: String
Parameter Sets: name
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PaAddress
{{Fill PaAddress Description}}

```yaml
Type: PaAddress
Parameter Sets: paaddress
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Tag
{{Fill Tag Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
{{Fill Type Description}}

```yaml
Type: String
Parameter Sets: name
Aliases:
Accepted values: ip-netmask, ip-range, fqdn, ip-netmask, ip-range, fqdn, ip-netmask, ip-range, fqdn, ip-netmask, ip-range, fqdn

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: paaddress
Aliases:
Accepted values: ip-netmask, ip-range, fqdn, ip-netmask, ip-range, fqdn, ip-netmask, ip-range, fqdn, ip-netmask, ip-range, fqdn

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
{{Fill Value Description}}

```yaml
Type: String
Parameter Sets: name
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: paaddress
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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
