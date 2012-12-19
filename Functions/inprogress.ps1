$LicUpdate = Send-PaApiQuery -Op "<request><license><fetch></fetch></license></request>"

$zone = @("trust","untrust")

foreach ($z in $zone) {
    $SecRules = Get-PaSecurityRule -c -u
    $Rules = $SecRules | where { ($_.SourceZone -contains $z) -or ($_.DestinationZone -contains $z) }
    if ($Rules) {
        foreach ($r in $Rules) {
            $xpath = "/config/devices/entry/vsys/entry/rulebase/security/rules/entry[@name='$($r.name)']"
            $DelRule = Send-PaApiQuery -Config delete -XPath $xpath
            if ($DelRule.response.status -eq "success") { "deleted rule: $($r.name)" } `
                else { throw $DelRule.response.msg }
        }
    }
    $DelZone = Send-PaApiQuery -Config delete -XPath "/config/devices/entry/vsys/entry/zone/entry[@name='$z']"
    if ($DelZone.response.status -eq "success") { "deleted zone: $z" } `
        else { throw $DelZone.response.msg }
}

$Interfaces = (Send-PaApiQuery -Config get -XPath "/config/devices/entry/network/interface/ethernet").response.result.ethernet.entry

$xpath = "/config/devices/entry/network/virtual-wire/entry[@name='default-vwire']"
$DelVWire = Send-PaApiQuery -Config delete -xpath $xpath

if ($DelVWire.response.status -eq "success") { "deleted default-vwire" } `
    else { throw $DelVWire.response.msg }

foreach ($i in $Interfaces) {
    $xpath = "/config/devices/entry/network/interface/ethernet/entry[@name='$($i.name)']"
    $DelInterface = Send-PaApiQuery -Config delete -XPath $xpath
    if ($DelInterface.response.status -eq "success") { "deleted interface: $($i.name)" } `
        else { throw $DelInterface.response.msg.line }
}

Invoke-PaCommit