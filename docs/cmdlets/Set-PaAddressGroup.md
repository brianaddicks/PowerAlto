---
external help file: PowerAlto4-help.xml
Module Name: PowerAlto4
online version:
schema: 2.0.0
---

# Set-PaAddressGroup

## SYNOPSIS
Creates/Configures an address object on a Palo Alto device.

## SYNTAX

### name-filter
```
Set-PaAddressGroup [-Name] <String> -Filter <String> [-Description <String>] [-Tag <String[]>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### name-member
```
Set-PaAddressGroup [-Name] <String> -Member <String> [-Description <String>] [-Tag <String[]>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### object-filter
```
Set-PaAddressGroup [-PaAddressGroup] <PaAddressGroup> [-Filter <String>] [-Description <String>]
 [-Tag <String[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### object-member
```
Set-PaAddressGroup [-PaAddressGroup] <PaAddressGroup> [-Member <String>] [-Description <String>]
 [-Tag <String[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates/Configures an address object on a Palo Alto device.

## EXAMPLES

### EXAMPLE 1
```

```

## PARAMETERS

### -Name
{{Fill Name Description}}

```yaml
Type: String
Parameter Sets: name-filter, name-member
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PaAddressGroup
{{Fill PaAddressGroup Description}}

```yaml
Type: PaAddressGroup
Parameter Sets: object-filter, object-member
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Filter
{{Fill Filter Description}}

```yaml
Type: String
Parameter Sets: name-filter
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: object-filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Member
{{Fill Member Description}}

```yaml
Type: String
Parameter Sets: name-member
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: object-member
Aliases:

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
