function Test-PaConnection {
    if (!($Global:PaConnectionArray)) {
        return $false
    } else {
        return $true
    }
}

