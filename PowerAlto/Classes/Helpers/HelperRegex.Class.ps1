class HelperRegex {
    static [string]$Ipv4 = '\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'
    static [string]$Ipv4Range = '\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)-((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'

    #static [string]$Fqdn = '(?=^.{1,254}$)(^(?:(?!\d|-)[a-zA-Z0-9\-]{1,63}(?<!-)\.?)+(?:[a-zA-Z]{2,})$)'
    # removed the restriction of not-starting with a digit
    static [string]$Fqdn = '(?=^.{1,254}$)(^(?:(?!-)[a-zA-Z0-9\-]{1,63}(?<!-)\.?)+(?:[a-zA-Z]{2,})$)'

    # function for checking regular expressions
    static [string] checkRegex([string]$matchString, [string]$regexString, [string]$errorMessage) {
        $regex = [regex]$regexString
        if ($regex.Match($matchString).Success) {
            return $matchString
        } else {
            Throw $errorMessage
        }
    }

    static [bool] checkRegex([string]$matchString, [string]$regexString, [bool]$returnBool) {
        $regex = [regex]$regexString
        if ($regex.Match($matchString).Success) {
            return $true
        } else {
            return $false
        }
    }

    # Ipv4 Address
    static [string] isIpv4([string]$matchString, [string]$errorMessage) {
        $regexString = [HelperRegex]::Ipv4
        return [HelperRegex]::checkRegex($matchString, $regexString, $errorMessage)
    }

    static [bool] isIpv4([string]$matchString, [bool]$returnBool) {
        $regexString = [HelperRegex]::Ipv4
        return [HelperRegex]::checkRegex($matchString, $regexString, $true)
    }

    # Ipv4 Range
    static [string] isIpv4Range([string]$matchString, [string]$errorMessage) {
        $regexString = [HelperRegex]::Ipv4Range
        return [HelperRegex]::checkRegex($matchString, $regexString, $errorMessage)
    }

    static [bool] isIpv4Range([string]$matchString, [bool]$returnBool) {
        $regexString = [HelperRegex]::Ipv4Range
        return [HelperRegex]::checkRegex($matchString, $regexString, $true)
    }

    # Fqdn
    static [string] isFqdn([string]$matchString, [string]$errorMessage) {
        $regexString = [HelperRegex]::Fqdn
        return [HelperRegex]::checkRegex($matchString, $regexString, $errorMessage)
    }

    static [bool] isFqdn([string]$matchString, [bool]$returnBool) {
        $regexString = [HelperRegex]::Fqdn
        return [HelperRegex]::checkRegex($matchString, $regexString, $true)
    }

    # Fqdn or Ipv4 Address
    static [string] isFqdnOrIpv4([string]$matchString, [string]$errorMessage) {
        $regexString = [HelperRegex]::Ipv4 + "|" + [HelperRegex]::Fqdn
        return [HelperRegex]::checkRegex($matchString, $regexString, $errorMessage)
    }

    static [bool] isFqdnOrIpv4([string]$matchString, [bool]$returnBool) {
        $regexString = [HelperRegex]::Ipv4 + "|" + [HelperRegex]::Fqdn
        return [HelperRegex]::checkRegex($matchString, $regexString, $true)
    }

    # Constructor
    HelperRegex () {
    }
}