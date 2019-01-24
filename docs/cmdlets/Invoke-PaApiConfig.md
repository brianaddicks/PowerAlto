---
external help file: PowerAlto-help.xml
Module Name: PowerAlto
online version:
schema: 2.0.0
---

# Invoke-PaApiConfig

## SYNOPSIS
Invokes a Palo Alto Config Api.

## SYNTAX

### get (Default)
```
Invoke-PaApiConfig [-Get] [-XPath] <String> [<CommonParameters>]
```

### edit
```
Invoke-PaApiConfig [-Edit] [-Element] <String> [-XPath] <String> [<CommonParameters>]
```

### set
```
Invoke-PaApiConfig [-Set] [-Element] <String> [-XPath] <String> [<CommonParameters>]
```

### move
```
Invoke-PaApiConfig [-Move] [-Location] <String> [-XPath] <String> [<CommonParameters>]
```

### delete
```
Invoke-PaApiConfig [-Delete] [-XPath] <String> [<CommonParameters>]
```

## DESCRIPTION
Invokes a Palo Alto Config Api.

## EXAMPLES

### EXAMPLE 1
```
Invoke-PaApiConfig -Action "get" -XPath "/config/devices/entry[@name='localhost.localdomain']/network/interface"
```

Returns interface configuration for the currently connected Palo Alto Device.

## PARAMETERS

### -Delete
move parameters

```yaml
Type: SwitchParameter
Parameter Sets: delete
Aliases:

Required: True
Position: 0
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Edit
edit parameters

```yaml
Type: SwitchParameter
Parameter Sets: edit
Aliases:

Required: True
Position: 0
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Element
{{Fill Element Description}}

```yaml
Type: String
Parameter Sets: edit, set
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Get
get parameters

```yaml
Type: SwitchParameter
Parameter Sets: get
Aliases:

Required: True
Position: 0
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Location
{{Fill Location Description}}

```yaml
Type: String
Parameter Sets: move
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Move
move parameters

```yaml
Type: SwitchParameter
Parameter Sets: move
Aliases:

Required: True
Position: 0
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Set
set parameters

```yaml
Type: SwitchParameter
Parameter Sets: set
Aliases:

Required: True
Position: 0
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -XPath
XPath of desired configuration.

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
