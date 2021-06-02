class PaServiceGroup {
    [string]$Name
    [string[]]$Member
    [string[]]$Tags

    ###################################### Methods #######################################
    # invokeReportGetQuery
    <# [Xml] ToXml() {
        [xml]$Doc = New-Object System.Xml.XmlDocument
        $root = $Doc.CreateNode("element", "address-group", $null)

        # Start Entry Node
        $EntryNode = $Doc.CreateNode("element", "entry", $null)
        $EntryNode.SetAttribute("name", $this.Name)

        # Start Type Node with Value
        $TypeNode = $Doc.CreateNode("element", $this.Type, $null)
        $TypeNode.InnerText = $this.Value

        # Static Members
        if ($this.Type -eq 'static') {
            # Tag Members
            foreach ($member in $this.Member) {
                $MemberNode = $Doc.CreateNode("element", 'member', $null)
                $MemberNode.InnerText = $member
                $TypeNode.AppendChild($MemberNode)
            }
        }

        # Dynamic Filter
        if ($this.Type -eq 'dynamic') {
            $FilterNode = $Doc.CreateNode("element", "filter", $null)
            $FilterNode.InnerText = $this.Filter
            $TypeNode.AppendChild($FilterNode)
        }

        $EntryNode.AppendChild($TypeNode)

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

        # Append Entry to Root and Root to Doc
        $root.AppendChild($EntryNode)
        $Doc.AppendChild($root)

        return $Doc
    } #>

    ##################################### Initiators #####################################
    # Initiator
    PaServiceGroup([string]$Name) {
        $this.Name = $Name
    }
}