---
external help file: PowerAlto4-help.xml
Module Name: PowerAlto4
online version:
schema: 2.0.0
---

# Move-PaSecurityPolicy

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

### name-bottom
```
Move-PaSecurityPolicy [-Name] <String> [-Bottom] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### name-top
```
Move-PaSecurityPolicy [-Name] <String> [-Top] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### name-after
```
Move-PaSecurityPolicy [-Name] <String> -After <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### name-before
```
Move-PaSecurityPolicy [-Name] <String> -Before <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### paobject-bottom
```
Move-PaSecurityPolicy [-PaSecurityPolicy] <PaSecurityPolicy> [-Bottom] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### paobject-top
```
Move-PaSecurityPolicy [-PaSecurityPolicy] <PaSecurityPolicy> [-Top] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### paobject-after
```
Move-PaSecurityPolicy [-PaSecurityPolicy] <PaSecurityPolicy> -After <String> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### paobject-before
```
Move-PaSecurityPolicy [-PaSecurityPolicy] <PaSecurityPolicy> -Before <String> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -After
{{Fill After Description}}

```yaml
Type: String
Parameter Sets: name-after, paobject-after
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Before
{{Fill Before Description}}

```yaml
Type: String
Parameter Sets: name-before, paobject-before
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Bottom
{{Fill Bottom Description}}

```yaml
Type: SwitchParameter
Parameter Sets: name-bottom, paobject-bottom
Aliases:

Required: True
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

### -Name
{{Fill Name Description}}

```yaml
Type: String
Parameter Sets: name-bottom, name-top, name-after, name-before
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PaSecurityPolicy
{{Fill PaSecurityPolicy Description}}

```yaml
Type: PaSecurityPolicy
Parameter Sets: paobject-bottom, paobject-top, paobject-after, paobject-before
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Top
{{Fill Top Description}}

```yaml
Type: SwitchParameter
Parameter Sets: name-top, paobject-top
Aliases:

Required: True
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

### PaSecurityPolicy
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
