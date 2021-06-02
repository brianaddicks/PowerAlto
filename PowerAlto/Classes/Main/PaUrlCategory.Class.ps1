class PaUrlCategory {
    [string]$Name
    [string]$Description
    [string[]]$Members

    ###################################### Methods #######################################
    # invokeReportGetQuery
    [Xml] ToXml() {
        [xml]$Doc = New-Object System.Xml.XmlDocument
        $root = $Doc.CreateNode("element","custom-url-category",$null)
        
        # Start Entry Node
        $EntryNode = $Doc.CreateNode("element","entry",$null)
        $EntryNode.SetAttribute("name",$this.Name)

        # Description
        if ($this.Description) {
            # Description
            $DescriptionNode = $Doc.CreateNode("element","description",$null)
            $DescriptionNode.InnerText = $this.Description
            $EntryNode.AppendChild($DescriptionNode)
        }

        # Members
        $EntryNode = [HelperXml]::AddNodeWithMembers($EntryNode,'list',$this.Members)

        $root.AppendChild($EntryNode)
        $Doc.AppendChild($root)

        return $Doc
    }

    ##################################### Initiators #####################################
    # Initiator
    PaUrlCategory([string]$Name) {
        $this.Name = $Name
    }
}