function Test-PaConnection {
    if (!($Global:PaConnectionArray)) {
        Write-Host -ForegroundColor Red "No connections, use Get-PaConnectionString to create them"
        return
    }
}

