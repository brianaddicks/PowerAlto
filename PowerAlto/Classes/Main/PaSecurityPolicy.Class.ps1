class PaSecurityPolicy:ICloneable {
    # General
    [int]$Number
    [string]$Name
    [string]$RuleType = 'universal'
    [string]$Description
    [string[]]$Tags

    # Source
    [string[]]$SourceZone
    [string[]]$SourceAddress = 'any'

    # User
    [string[]]$SourceUser = 'any'
    [string[]]$HipProfile = 'any'

    # Destination
    [string[]]$DestinationZone
    [string[]]$DestinationAddress = 'any'

    # Application
    [string[]]$Application = 'any'

    # Service/Url Category
    [string[]]$Service = 'application-default'
    [string[]]$UrlCategory = 'any'

    # Actions
    ## Action Setting
    [string]$Action = 'allow'
    [bool]$SendIcmpUnreachable

    ## Profile Setting
    [string]$ProfileType
    [string]$GroupProfile
    [string]$Antivirus
    [string]$VulnerabilityProtection
    [string]$AntiSpyware
    [string]$UrlFiltering
    [string]$FileBlocking
    [string]$DataFiltering
    [string]$WildFireAnalysis

    ## Log Setting
    [bool]$LogAtSessionStart
    [bool]$LogAtSessionEnd = $true
    [string]$LogForwarding

    ## Other Settings
    [string]$Schedule
    [string]$QosType
    [string]$QosMarking
    [bool]$Dsri

    ###################################### Methods #######################################
    # Clone
    [Object] Clone () {
        $NewObject = [PaSecurityPolicy]::New()
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

        ##########################################
        # General

        # RuleType
        if ($this.RuleType -ne 'universal') {
            $PropertyNode = $Doc.CreateNode("element", 'rule-type', $null)
            $PropertyNode.InnerText = $this.RuleType
            $EntryNode.AppendChild($PropertyNode)
        }

        # Description
        if ($this.Description) {
            $PropertyNode = $Doc.CreateNode("element", 'description', $null)
            $PropertyNode.InnerText = $this.Description
            $EntryNode.AppendChild($PropertyNode)
        }

        # Tags
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

        ##########################################
        # Source

        # SourceZone
        $MembersNode = $Doc.CreateNode("element", 'from', $null)
        foreach ($member in $this.SourceZone) {
            $MemberNode = $Doc.CreateNode("element", 'member', $null)
            $MemberNode.InnerText = $member
            $MembersNode.AppendChild($MemberNode)
        }
        $EntryNode.AppendChild($MembersNode)

        # SourceAddress
        $MembersNode = $Doc.CreateNode("element", 'source', $null)
        foreach ($member in $this.SourceAddress) {
            $MemberNode = $Doc.CreateNode("element", 'member', $null)
            $MemberNode.InnerText = $member
            $MembersNode.AppendChild($MemberNode)
        }
        $EntryNode.AppendChild($MembersNode)

        ##########################################
        # User

        # SourceUser
        $MembersNode = $Doc.CreateNode("element", 'source-user', $null)
        foreach ($member in $this.SourceUser) {
            $MemberNode = $Doc.CreateNode("element", 'member', $null)
            $MemberNode.InnerText = $member
            $MembersNode.AppendChild($MemberNode)
        }
        $EntryNode.AppendChild($MembersNode)

        # HipProfile
        $MembersNode = $Doc.CreateNode("element", 'hip-profiles', $null)
        foreach ($member in $this.HipProfile) {
            $MemberNode = $Doc.CreateNode("element", 'member', $null)
            $MemberNode.InnerText = $member
            $MembersNode.AppendChild($MemberNode)
        }
        $EntryNode.AppendChild($MembersNode)

        ##########################################
        # Destination

        # DestinationZone
        $MembersNode = $Doc.CreateNode("element", 'to', $null)
        foreach ($member in $this.DestinationZone) {
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

        ##########################################
        # Application

        # Application
        $MembersNode = $Doc.CreateNode("element", 'application', $null)
        foreach ($member in $this.Application) {
            $MemberNode = $Doc.CreateNode("element", 'member', $null)
            $MemberNode.InnerText = $member
            $MembersNode.AppendChild($MemberNode)
        }
        $EntryNode.AppendChild($MembersNode)

        ##########################################
        # Service/Url

        # Service
        $MembersNode = $Doc.CreateNode("element", 'service', $null)
        foreach ($member in $this.Service) {
            $MemberNode = $Doc.CreateNode("element", 'member', $null)
            $MemberNode.InnerText = $member
            $MembersNode.AppendChild($MemberNode)
        }
        $EntryNode.AppendChild($MembersNode)

        # UrlCategory
        $MembersNode = $Doc.CreateNode("element", 'category', $null)
        foreach ($member in $this.UrlCategory) {
            $MemberNode = $Doc.CreateNode("element", 'member', $null)
            $MemberNode.InnerText = $member
            $MembersNode.AppendChild($MemberNode)
        }
        $EntryNode.AppendChild($MembersNode)

        ##########################################
        # Actions

        ################
        # Action Setting

        # Action
        $PropertyNode = $Doc.CreateNode("element", 'action', $null)
        $PropertyNode.InnerText = $this.Action
        $EntryNode.AppendChild($PropertyNode)

        # SendIcmpUnreachable
        if ($this.SendIcmpUnreachable) {
            $PropertyNode = $Doc.CreateNode("element", 'icmp-unreachable', $null)
            $PropertyNode.InnerText = [HelperApi]::TranslateBoolToPa($this.SendIcmpUnreachable)
            $EntryNode.AppendChild($PropertyNode)
        }

        ################
        # Profile Setting

        # add profile-setting node
        $PropertyNode = $Doc.CreateNode("element", 'profile-setting', $null)

        switch ($this.ProfileType) {
            'group' {
                # group node
                $MembersNode = $Doc.CreateNode("element", 'group', $null)
                foreach ($member in $this.GroupProfile) {
                    $MemberNode = $Doc.CreateNode("element", 'member', $null)
                    $MemberNode.InnerText = $member
                    $MembersNode.AppendChild($MemberNode)
                }
                $PropertyNode.AppendChild($MembersNode)

                # add profile-settings node
                $EntryNode.AppendChild($PropertyNode)
            }
            'profiles' {
                # profiles node
                $ProfilesNode = $Doc.CreateNode("element", 'profiles', $null)

                # Antivirus
                $MembersNode = $Doc.CreateNode("element", 'virus', $null)
                foreach ($member in $this.Antivirus) {
                    $MemberNode = $Doc.CreateNode("element", 'member', $null)
                    $MemberNode.InnerText = $member
                    $MembersNode.AppendChild($MemberNode)
                }
                $ProfilesNode.AppendChild($MembersNode)

                # VulnerabilityProtection
                $MembersNode = $Doc.CreateNode("element", 'vulnerability', $null)
                foreach ($member in $this.VulnerabilityProtection) {
                    $MemberNode = $Doc.CreateNode("element", 'member', $null)
                    $MemberNode.InnerText = $member
                    $MembersNode.AppendChild($MemberNode)
                }
                $ProfilesNode.AppendChild($MembersNode)

                # AntiSpyware
                $MembersNode = $Doc.CreateNode("element", 'spyware', $null)
                foreach ($member in $this.AntiSpyware) {
                    $MemberNode = $Doc.CreateNode("element", 'member', $null)
                    $MemberNode.InnerText = $member
                    $MembersNode.AppendChild($MemberNode)
                }
                $ProfilesNode.AppendChild($MembersNode)

                # UrlFiltering
                $MembersNode = $Doc.CreateNode("element", 'url-filtering', $null)
                foreach ($member in $this.UrlFiltering) {
                    $MemberNode = $Doc.CreateNode("element", 'member', $null)
                    $MemberNode.InnerText = $member
                    $MembersNode.AppendChild($MemberNode)
                }
                $ProfilesNode.AppendChild($MembersNode)

                # FileBlocking
                $MembersNode = $Doc.CreateNode("element", 'file-blocking', $null)
                foreach ($member in $this.FileBlocking) {
                    $MemberNode = $Doc.CreateNode("element", 'member', $null)
                    $MemberNode.InnerText = $member
                    $MembersNode.AppendChild($MemberNode)
                }
                $ProfilesNode.AppendChild($MembersNode)

                # DataFiltering
                $MembersNode = $Doc.CreateNode("element", 'data-filtering', $null)
                foreach ($member in $this.DataFiltering) {
                    $MemberNode = $Doc.CreateNode("element", 'member', $null)
                    $MemberNode.InnerText = $member
                    $MembersNode.AppendChild($MemberNode)
                }
                $ProfilesNode.AppendChild($MembersNode)

                # WildFireAnalysis
                $MembersNode = $Doc.CreateNode("element", 'wildfire-analysis', $null)
                foreach ($member in $this.WildFireAnalysis) {
                    $MemberNode = $Doc.CreateNode("element", 'member', $null)
                    $MemberNode.InnerText = $member
                    $MembersNode.AppendChild($MemberNode)
                }
                $ProfilesNode.AppendChild($MembersNode)

                # add to profile-setting node
                $PropertyNode.AppendChild($ProfilesNode)

                # add profile-settings node
                $EntryNode.AppendChild($PropertyNode)
            }
        }



        ################
        # Log Setting

        if ($this.LogAtSessionStart) {
            # LogAtSessionStart
            $PropertyNode = $Doc.CreateNode("element", 'log-start', $null)
            $PropertyNode.InnerText = [HelperApi]::TranslateBoolToPa($this.LogAtSessionStart)
            $EntryNode.AppendChild($PropertyNode)
        }

        if (!($this.LogAtSessionEnd)) {
            # LogAtSessionEnd
            $PropertyNode = $Doc.CreateNode("element", 'log-end', $null)
            $PropertyNode.InnerText = [HelperApi]::TranslateBoolToPa($this.LogAtSessionEnd)
            $EntryNode.AppendChild($PropertyNode)
        }

        if ($this.LogForwarding) {
            # LogForwarding
            $PropertyNode = $Doc.CreateNode("element", 'log-setting', $null)
            $PropertyNode.InnerText = $this.LogForwarding
            $EntryNode.AppendChild($PropertyNode)
        }

        ################
        # Other Settings

        # Schedule

        if ($this.Schedule) {
            $PropertyNode = $Doc.CreateNode("element", 'schedule', $null)
            $PropertyNode.InnerText = $this.Schedule
            $EntryNode.AppendChild($PropertyNode)
        }

        if ($this.QosType) {
            # qos node
            $PropertyNode = $Doc.CreateNode("element", 'qos', $null)

            # qos node
            $MarkingNode = $Doc.CreateNode("element", 'qos', $null)

            switch ($this.QosType) {
                'FollowC2S' {
                    $QosTypeNode = $Doc.CreateNode("element", 'follow-c2s-flow', $null)
                    $MarkingNode.AppendChild($QosTypeNode)
                    continue
                }
                'IpDscp' {
                    $QosTypeNode = $Doc.CreateNode("element", 'ip-dscp', $null)
                    $QosTypeNode.InnerText = $this.QosMarking
                    $MarkingNode.AppendChild($QosTypeNode)
                    continue
                }
                'IpPrecedence' {
                    $QosTypeNode = $Doc.CreateNode("element", 'ip-precedence', $null)
                    $QosTypeNode.InnerText = $this.QosMarking
                    $MarkingNode.AppendChild($QosTypeNode)
                    continue
                }
            }

            # add qos node
            $PropertyNode.AppendChild($MarkingNode)

            # add qos node
            $EntryNode.AppendChild($PropertyNode)
        }

        # Dsri

        if ($this.Dsri) {
            # option node
            $PropertyNode = $Doc.CreateNode("element", 'option', $null)


            # DsriNode
            $DsriNode = $Doc.CreateNode("element", 'disable-server-response-inspection', $null)
            $DsriNode.InnerText = [HelperApi]::TranslateBoolToPa($this.Dsri)
            $PropertyNode.AppendChild($DsriNode)


            # add option node
            $EntryNode.AppendChild($PropertyNode)
        }

        # Append Entry to Root and Root to Doc
        $root.AppendChild($EntryNode)
        $Doc.AppendChild($root)

        return $Doc
    }

    ##################################### Initiators #####################################
    # Initiator with Name
    PaSecurityPolicy([string]$Name) {
        $this.Name = $Name
    }

    # Empty Initiator
    PaSecurityPolicy() {
    }
}