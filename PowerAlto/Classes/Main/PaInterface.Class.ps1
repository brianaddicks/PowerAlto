class PaInterface {
    # Main Config Panel
    [string]$Name
    [string]$Comment
    [string]$Type
    [string]$AggregateGroup
    [int]$Tag
    
    # Config
    [string]$VirtualRouter
    [string]$Zone

    # Ipv4
    [string[]]$IpAddress

    # Advanced
    [string]$ManagementProfile

    # Static Properties
    static [String] $XPathNode    = "network/interface"
    static [String] $ResponseNode = "interface"
    
    

    ###################################### Methods #######################################
    # invokeReportGetQuery
    <#
    [Xml] ToXml() {
        [xml]$Doc = New-Object System.Xml.XmlDocument
        $root = $Doc.CreateNode("element","address",$null)
        
        # Start Entry Node
        $EntryNode = $Doc.CreateNode("element","entry",$null)
        $EntryNode.SetAttribute("name",$this.Name)

        # Start Type Node with Value
        $TypeNode = $Doc.CreateNode("element",$this.Type,$null)
        $TypeNode.InnerText = $this.Value
        $EntryNode.AppendChild($TypeNode)

        if ($this.Tags) {
            # Tag Members
            $MembersNode = $Doc.CreateNode("element",'tag',$null)
            foreach ($member in $this.Tags) {
                $MemberNode = $Doc.CreateNode("element",'member',$null)
                $MemberNode.InnerText = $member
                $MembersNode.AppendChild($MemberNode)
            }
            $EntryNode.AppendChild($MembersNode)
        }

        if ($this.Description) {
            # Description
            $DescriptionNode = $Doc.CreateNode("element","description",$null)
            $DescriptionNode.InnerText = $this.Description
            $EntryNode.AppendChild($DescriptionNode)
        }

        # Append Entry to Root and Root to Doc
        $root.AppendChild($EntryNode)
        $Doc.AppendChild($root)

        return $Doc
    }
    #>

    ##################################### Initiators #####################################
    # Initiator
    PaInterface([string]$Name) {
        $this.Name = $Name
    }
}