function Set-PaNatPolicy {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ValueFromPipeline, ParameterSetName = "rulebase", Mandatory = $True, Position = 0)]
        [Parameter(ValueFromPipeline, ParameterSetName = "prerulebase", Mandatory = $True, Position = 0)]
        [Parameter(ValueFromPipeline, ParameterSetName = "postrulebase", Mandatory = $True, Position = 0)]
        [PaNatPolicy]$PaNatPolicy,

        [Parameter(ParameterSetName = "prerulebase", Mandatory = $True)]
        [switch]$PreRulebase,

        [Parameter(ParameterSetName = "postrulebase", Mandatory = $True)]
        [switch]$PostRulebase,

        [Parameter(ParameterSetName = "rulebase", Mandatory = $false)]
        [switch]$PushedSharedPolicy
    )

    BEGIN {
    }

    PROCESS {

        $VerbosePrefix = "Set-PaNatPolicy:"

        switch ($PsCmdlet.ParameterSetName) {
            'postrulebase' {
                $XPathNode = 'post-rulebase/nat/rules'
            }
            'prerulebase' {
                $XPathNode = 'pre-rulebase/nat/rules'
            }
            'rulebase' {
                $XPathNode = 'rulebase/nat/rules'
            }
        }

        $ElementXml = $PaNatPolicy.ToXml().rules.entry.InnerXml
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $PaNatPolicy.Name)

        if ($PSCmdlet.ShouldProcess("Creating new $($PsCmdlet.ParameterSetName) Nat Policy: $($PaNatPolicy.Name)")) {
            $Set = Invoke-PaApiConfig -Set -Xpath $XPath -Element $ElementXml

            $Set
        }
    }
}