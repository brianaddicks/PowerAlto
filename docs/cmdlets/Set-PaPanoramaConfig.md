---
external help file: PowerAlto-help.xml
Module Name: PowerAlto
online version:
schema: 2.0.0
---

# Set-PaPanoramaConfig

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

### noclass
```
Set-PaPanoramaConfig [-PrimaryServer <String>] [-SecondaryServer <String>] [-ReceiveTimeout <Int32>]
 [-SendTimeout <Int32>] [-RetryCount <Int32>] [-DisableDeviceMonitoring] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### class
```
Set-PaPanoramaConfig -PaPanoramaConfig <PaPanoramaConfig> [-WhatIf] [-Confirm] [<CommonParameters>]
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

### -DisableDeviceMonitoring
{{Fill DisableDeviceMonitoring Description}}

```yaml
Type: SwitchParameter
Parameter Sets: noclass
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PaPanoramaConfig
{{Fill PaPanoramaConfig Description}}

```yaml
Type: PaPanoramaConfig
Parameter Sets: class
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -PrimaryServer
{{Fill PrimaryServer Description}}

```yaml
Type: String
Parameter Sets: noclass
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReceiveTimeout
{{Fill ReceiveTimeout Description}}

```yaml
Type: Int32
Parameter Sets: noclass
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RetryCount
{{Fill RetryCount Description}}

```yaml
Type: Int32
Parameter Sets: noclass
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecondaryServer
{{Fill SecondaryServer Description}}

```yaml
Type: String
Parameter Sets: noclass
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SendTimeout
{{Fill SendTimeout Description}}

```yaml
Type: Int32
Parameter Sets: noclass
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### PaPanoramaConfig
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
