---
external help file: PowerAlto4-help.xml
Module Name: PowerAlto4
online version:
schema: 2.0.0
---

# Get-PaReportJob

## SYNOPSIS
Gets Report Job status from Palo Alto Device.

## SYNTAX

### singlejob (Default)
```
Get-PaReportJob [-JobId] <Int32> [-Wait] [-ShowProgress] [<CommonParameters>]
```

### alljobs
```
Get-PaReportJob [[-JobId] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Gets Report Job status from Palo Alto Device.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -JobId
{{Fill JobId Description}}

```yaml
Type: Int32
Parameter Sets: singlejob
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: Int32
Parameter Sets: alljobs
Aliases:

Required: False
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Wait
{{Fill Wait Description}}

```yaml
Type: SwitchParameter
Parameter Sets: singlejob
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowProgress
{{Fill ShowProgress Description}}

```yaml
Type: SwitchParameter
Parameter Sets: singlejob
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
