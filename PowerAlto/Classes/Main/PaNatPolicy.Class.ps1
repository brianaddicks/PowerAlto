class PaNatPolicy {
    # General
    [string]$Name
    [string]$Description
    [string]$NatType = 'ipv4'
    [string[]]$Tags
    [bool]$Disabled

    # Original Packet
    [string[]]$SourceZone
    [string]$DestinationZone
    [string]$DestinationInterface = 'any'
    [string]$Service = 'any'
    [string[]]$SourceAddress
    [string[]]$DestinationAddress

    # Translated Packet
    # Source Translation
    ## Static IP
    [string]$SourceTranslationType
    [string]$SourceTranslatedAddress
    [bool]$BiDirectional

    # Destination Translation
    # Static IP
    [string]$DestinationTranslationType
    [string]$DestinationTranslatedAddress
    [int]$DestinationTranslatedPort
    [bool]$DnsRewrite
    [string]$DnsRewriteDirection

    # Active/Active HA Binding
    [string]$ActiveActiveDeviceBinding

    static [string]$ConfigNode = 'rulebase/nat/rules'

    ###################################### Methods #######################################
    # Clone
    [Object] Clone () {
        $NewObject = [PaNatPolicy]::New()
        foreach ($Property in ($this | Get-Member -MemberType Property)) {
            $NewObject.$($Property.Name) = $this.$($Property.Name)
        } # foreach
        return $NewObject
    }

    # ToXml
    [Xml] ToXml() {
        [xml]$Doc = New-Object System.Xml.XmlDocument
        $root = $Doc.CreateNode("element", "rules", $null)

        # Start Entry Node
        $EntryNode = $Doc.CreateNode("element", "entry", $null)
        $EntryNode.SetAttribute("name", $this.Name)

        #region mandatoryparameters
        #######################################################################

        # NatType
        $TypeNode = $Doc.CreateNode("element", 'nat-type', $null)
        $TypeNode.InnerText = $this.NatType
        $EntryNode.AppendChild($TypeNode)

        # Disabled
        if ($this.Disabled) {
            $TypeNode = $Doc.CreateNode("element", 'disabled', $null)
            $TypeNode.InnerText = 'yes'
            $EntryNode.AppendChild($TypeNode)
        }

        # Service
        $TypeNode = $Doc.CreateNode("element", 'service', $null)
        $TypeNode.InnerText = $this.Service
        $EntryNode.AppendChild($TypeNode)

        # SourceZone
        $MembersNode = $Doc.CreateNode("element", 'from', $null)
        foreach ($member in $this.SourceZone) {
            $MemberNode = $Doc.CreateNode("element", 'member', $null)
            $MemberNode.InnerText = $member
            $MembersNode.AppendChild($MemberNode)
        }
        $EntryNode.AppendChild($MembersNode)

        # DestinationZone
        $MembersNode = $Doc.CreateNode("element", 'to', $null)
        $MemberNode = $Doc.CreateNode("element", 'member', $null)
        $MemberNode.InnerText = $this.DestinationZone
        $MembersNode.AppendChild($MemberNode)
        $EntryNode.AppendChild($MembersNode)

        # SourceAddress
        $MembersNode = $Doc.CreateNode("element", 'source', $null)
        foreach ($member in $this.SourceAddress) {
            $MemberNode = $Doc.CreateNode("element", 'member', $null)
            $MemberNode.InnerText = $member
            $MembersNode.AppendChild($MemberNode)
        }
        $EntryNode.AppendChild($MembersNode)

        # DestinationAddress
        $MembersNode = $Doc.CreateNode("element", 'destination', $null)
        foreach ($member in $this.DestinationAddress) {
            $MemberNode = $Doc.CreateNode("element", 'member', $null)
            $MemberNode.InnerText = $member
            $MembersNode.AppendChild($MemberNode)
        }
        $EntryNode.AppendChild($MembersNode)

        #######################################################################
        #endregion mandatoryparameters

        if ($this.Tags) {
            # Tag Members
            $MembersNode = $Doc.CreateNode("element", 'tag', $null)
            foreach ($member in $this.Tags) {
                $MemberNode = $Doc.CreateNode("element", 'member', $null)
                $MemberNode.InnerText = $member
                $MembersNode.AppendChild($MemberNode)
            }
            $EntryNode.AppendChild($MembersNode)
        }

        if ($this.Description) {
            # Description
            $DescriptionNode = $Doc.CreateNode("element", "description", $null)
            $DescriptionNode.InnerText = $this.Description
            $EntryNode.AppendChild($DescriptionNode)
        }

        #region translation
        #######################################################################

        if ($this.SourceTranslationType) {
            $SourceTranslationNode = $Doc.CreateNode("element", 'source-translation', $null)

            switch ($this.SourceTranslationType) {
                'static-ip' {
                    $SourceTranslationTypeNode = $Doc.CreateNode("element", 'static-ip', $null)

                    if ($this.BiDirectional) {
                        $ChildNode = $Doc.CreateNode("element", 'bi-directional', $null)
                        $ChildNode.InnerText = 'yes'
                        $SourceTranslationTypeNode.AppendChild($ChildNode)
                    }

                    if ($this.SourceTranslatedAddress) {
                        $ChildNode = $Doc.CreateNode("element", 'translated-address', $null)
                        $ChildNode.InnerText = $this.SourceTranslatedAddress
                        $SourceTranslationTypeNode.AppendChild($ChildNode)
                    }
                    $SourceTranslationNode.AppendChild($SourceTranslationTypeNode)
                }
            }
            $EntryNode.AppendChild($SourceTranslationNode)
        }

        if ($this.DestinationTranslationType) {

            switch ($this.DestinationTranslationType) {
                'static-ip' {
                    $DestinationTranslationNode = $Doc.CreateNode("element", 'destination-translation', $null)
                    if ($this.DestinationTranslatedAddress) {
                        $ChildNode = $Doc.CreateNode("element", 'translated-address', $null)
                        $ChildNode.InnerText = $this.DestinationTranslatedAddress
                        $DestinationTranslationNode.AppendChild($ChildNode)
                    }
                    if ($this.DestinationTranslatedPort) {
                        $ChildNode = $Doc.CreateNode("element", 'translated-port', $null)
                        $ChildNode.InnerText = $this.DestinationTranslatedPort
                        $DestinationTranslationNode.AppendChild($ChildNode)
                    }   
                    if ($this.DnsRewrite) {
                        $DnsRewriteTranslationNode = $Doc.CreateNode("element", 'dns-rewrite', $null)
                        if ($this.DnsRewriteDirection) {
                            $ChildNode = $Doc.CreateNode("element", 'direction', $null)
                            $ChildNode.InnerText = $this.DnsRewriteDirection
                            $DnsRewriteTranslationNode.AppendChild($ChildNode)
                        }
                        $DestinationTranslationNode.AppendChild($DnsRewriteTranslationNode)
                    }
                    $EntryNode.AppendChild($DestinationTranslationNode)
                }
            }
        }

        #######################################################################
        #endregion translation

        #region Active/Active HA Binding
        #######################################################################

        if ($this.ActiveActiveDeviceBinding) {
            $ActiveActiveDeviceBindingNode = $Doc.CreateNode("element", "active-active-device-binding", $null)
            $ActiveActiveDeviceBindingNode.InnerText = $this.ActiveActiveDeviceBinding
            $EntryNode.AppendChild($ActiveActiveDeviceBindingNode)
        }

        #######################################################################
        #endregion Active/Active HA Binding

        # Append Entry to Root and Root to Doc
        $root.AppendChild($EntryNode)
        $Doc.AppendChild($root)

        return $Doc
    }

    ##################################### Initiators #####################################
    # Initiator
    PaNatPolicy([string]$Name) {
        $this.Name = $Name
    }

    # Empty Initiator
    PaNatPolicy() {
    }
}