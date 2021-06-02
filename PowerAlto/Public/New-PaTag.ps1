function New-PaTag {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Name,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateSet('Red', 'Green', 'Blue', 'Yellow', 'Copper', 'Orange', 'Purple', 'Gray', 'Light Green', 'Cyan', 'Light Gray', 'Blue Gray', 'Lime', 'Black', 'Gold', 'Brown', 'Green')]
        [string]$Color,

        [Parameter(Mandatory = $False, Position = 2)]
        [string]$Comments
    )

    BEGIN {
    }

    PROCESS {

        if ($Color) {
            Write-Verbose "Color specified: $Color"
            $ConfigObject = [PaTag]::new($Name, $Color)
        } else {
            $ConfigObject = [PaTag]::new($Name)
        }

        $ConfigObject.Comments = $Comments

        return $ConfigObject
    }
}