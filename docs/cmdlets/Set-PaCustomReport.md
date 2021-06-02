---
external help file: PowerAlto-help.xml
Module Name: PowerAlto
online version:
schema: 2.0.0
---

# Set-PaCustomReport

## SYNOPSIS
Creates/Configures a custom report on a Palo Alto device.

## SYNTAX

### summary
```
Set-PaCustomReport [-Name] <String> [-Description <String>] [-Vsys <String>] -SummaryDatabase <String>
 -TimeFrame <String> [-EntriesShown <Int32>] [-Groups <Int32>] -Columns <String[]> [-Query <String>]
 [-SortBy <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### detailed
```
Set-PaCustomReport [-Name] <String> [-Description <String>] [-Vsys <String>] -DetailedLog <String>
 -TimeFrame <String> [-EntriesShown <Int32>] [-Groups <Int32>] -Columns <String[]> [-Query <String>]
 [-SortBy <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates/Configures a custom report on a Palo Alto device.

## EXAMPLES

### EXAMPLE 1
```

```

## PARAMETERS

### -Columns
{{Fill Columns Description}}

```yaml
Type: String[]
Parameter Sets: (All)
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

### -DetailedLog
{{Fill DetailedLog Description}}

```yaml
Type: String
Parameter Sets: detailed
Aliases:
Accepted values: Traffic, Threat, URL, WildFire Submissions, Data Filtering, HIP Match, User-ID, Tunnel, Authentication

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EntriesShown
{{Fill EntriesShown Description}}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:
Accepted values: 5, 10, 25, 50, 100, 250, 500, 1000, 5000, 10000

Required: False
Position: Named
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### -Groups
{{Fill Groups Description}}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:
Accepted values: 5, 10, 25, 50

Required: False
Position: Named
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
{{Fill Name Description}}

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

### -Query
{{Fill Query Description}}

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

### -SortBy
{{Fill SortBy Description}}

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

### -SummaryDatabase
{{Fill SummaryDatabase Description}}

```yaml
Type: String
Parameter Sets: summary
Aliases:
Accepted values: Application Statistics, Traffic, Threat, URL, Tunnel

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeFrame
{{Fill TimeFrame Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
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
