---
external help file: PowerAlto4-help.xml
Module Name: PowerAlto4
online version:
schema: 2.0.0
---

# Set-PaSecurityPolicy

## SYNOPSIS
Creates/Configures a Security Policy on a Palo Alto device.

## SYNTAX

### name
```
Set-PaSecurityPolicy [-Name] <String> [-SourceZone <String[]>] [-SourceUser <String[]>]
 [-DestinationZone <String[]>] [-DestinationAddress <String[]>] [-Action <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### paobject
```
Set-PaSecurityPolicy [-PaSecurityPolicy] <PaSecurityPolicy> [-SourceZone <String[]>] [-SourceUser <String[]>]
 [-DestinationZone <String[]>] [-DestinationAddress <String[]>] [-Action <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Creates/Configures a Security Policy on a Palo Alto device.

## EXAMPLES

### EXAMPLE 1
```

```

## PARAMETERS

### -Name
{{Fill Name Description}}

```yaml
Type: String
Parameter Sets: name
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PaSecurityPolicy
{{Fill PaSecurityPolicy Description}}

```yaml
Type: PaSecurityPolicy
Parameter Sets: paobject
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -SourceZone
{{Fill SourceZone Description}}

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

### -SourceUser
{{Fill SourceUser Description}}

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

### -DestinationZone
{{Fill DestinationZone Description}}

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

### -DestinationAddress
{{Fill DestinationAddress Description}}

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

### -Action
{{Fill Action Description}}

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
