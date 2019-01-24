---
external help file: PowerAlto4-help.xml
Module Name: PowerAlto4
online version:
schema: 2.0.0
---

# Set-PaTargetDeviceGroup

## SYNOPSIS
Changes target Device Group for current session.

## SYNTAX

```
Set-PaTargetDeviceGroup [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION
Changes target Device Group for current session.

## EXAMPLES

### EXAMPLE 1
```
Set-PaTargetDeviceGroup -Name "remote-sites"
```

Changes context in panorama to the "remote-sites" Device Group

## PARAMETERS

### -Name
Name of the desired Device Group.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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
