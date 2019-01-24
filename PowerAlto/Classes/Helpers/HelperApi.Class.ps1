class HelperApi {
    # TranslateBool
    static [bool] TranslatePaToBool([string]$ApiBool,[bool]$DefaultValue) {
        if ($ApiBool -eq 'yes') {
            return $true
        } elseif ($ApiBool -eq 'no') {
            return $false
        } elseif ($ApiBool -eq '') {
            return $DefaultValue
        } else {
            Throw "Invalid bool value: $ApiBool"
        }
    }

    # TranslateBoolToPa
    static [bool] TranslateBoolToPa([bool]$ThisBool) {
        if ($ThisBool) {
            return 'yes'
        } else {
            return 'no'
        }
    }

    # Constructor
    HelperApi () {
    }
}