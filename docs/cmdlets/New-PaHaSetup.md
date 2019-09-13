---
external help file: PowerAlto-help.xml
Module Name: PowerAlto
online version:
schema: 2.0.0
---

# New-PaHaSetup

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

### activepassive
```
New-PaHaSetup [-Enabled] [-GroupId <Int32>] [-Description <String>] [-EnableConfigSync]
 [-PeerHa1IpAddress <String>] [-BackupPeerHa1IpAddress <String>] [<CommonParameters>]
```

### activeactive
```
New-PaHaSetup [-Enabled] -GroupId <Int32> [-Description <String>] [-EnableConfigSync]
 -PeerHa1IpAddress <String> [-BackupPeerHa1IpAddress <String>] [-ActiveActive] -DeviceId <Int32>
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

### -ActiveActive
{{Fill ActiveActive Description}}

```yaml
Type: SwitchParameter
Parameter Sets: activeactive
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupPeerHa1IpAddress
{{Fill BackupPeerHa1IpAddress Description}}

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

### -DeviceId
{{Fill DeviceId Description}}

```yaml
Type: Int32
Parameter Sets: activeactive
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableConfigSync
{{Fill EnableConfigSync Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Enabled
{{Fill Enabled Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupId
{{Fill GroupId Description}}

```yaml
Type: Int32
Parameter Sets: activepassive
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: Int32
Parameter Sets: activeactive
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PeerHa1IpAddress
{{Fill PeerHa1IpAddress Description}}

```yaml
Type: String
Parameter Sets: activepassive
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: activeactive
Aliases:

Required: True
Position: Named
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
