class PaCustomReport {
    [string]$Name
    [string]$Description
    [string]$Database
    [string]$SortBy
    [string[]]$Columns
    [string]$TimeFrame
    [int]$EntriesShown
    [int]$Groups
    [string]$Query

    ###################################### Methods #######################################
    # GetColumnType
    [string] GetColumnType([string]$Column) {
        $AggregateColumns  = @()
        $AggregateColumns += 'src'
        $AggregateColumns += 'srcuser'
        $AggregateColumns += 'dst'
        $AggregateColumns += 'dstuser'
        $AggregateColumns += 'action'
        $AggregateColumns += 'threatid'
        $AggregateColumns += 'quarter-hour-of-receive_time'


        $ValueColumns  = @()
        $ValueColumns += 'count'
        $ValueColumns += 'bytes'
        $ValueColumns += 'sessions'

        if ($ValueColumns -contains $Column) {
            $ColumnType = 'value'
        } elseif ($AggregateColumns -contains $Column) {
            $ColumnType = 'aggregate'
        } else {
            Throw "PaCustomReport: Unrecognized column: $Column"
        }

        return $ColumnType
    }

    # invokeReportGetQuery
    [Xml] ToXml() {
        [xml]$Doc = New-Object System.Xml.XmlDocument
        $root = $Doc.CreateNode("element","reports",$null)
        
        # Start Entry Node
        $EntryNode = $Doc.CreateNode("element","entry",$null)
        $EntryNode.SetAttribute("name",$this.Name)

        # Start Type Node
        $TypeNode = $Doc.CreateNode("element","type",$null)

        # Start DatabaseNode
        $DatabaseShortName = $this.TranslateDatabaseName($this.Database,"short")
        $DatabaseNode      = $Doc.CreateNode("element",$DatabaseShortName,$null)
        
        # Create Aggregate/Member Nodes
        $AggregateNode = $Doc.CreateNode("element",'aggregate-by',$null)
        $ValueNode     = $Doc.CreateNode("element",'values',$null)

        # Columns
        foreach ($c in $this.Columns) {
            $MemberNode = $Doc.CreateNode("element",'member',$null)
            $MemberNode.InnerText = $c
            switch ($this.GetColumnType($c)) {
                'aggregate' {
                    $AggregateNode.AppendChild($MemberNode)
                    continue
                }
                'value' {
                    $ValueNode.AppendChild($MemberNode)
                    continue
                }
            }
        }

        if ($this.SortBy) {
            # Create SortBy Node
            $SortByNode = $Doc.CreateNode("element",'sortby',$null)
            $SortByNode.InnerText = $this.SortBy
            $DatabaseNode.AppendChild($SortByNode)
        }

        # Add aggregate/value nodes to database node
        $DatabaseNode.AppendChild($AggregateNode)
        $DatabaseNode.AppendChild($ValueNode)
        
        # add Database to type
        $TypeNode.AppendChild($DatabaseNode)

        # Add Type to Entry Node
        $EntryNode.AppendChild($TypeNode)

        # Create/Add TimeFrame to Entry
        $TimeFrameNode = $Doc.CreateNode("element",'period',$null)
        $TimeFrameNode.InnerText = $this.TimeFrame
        $EntryNode.AppendChild($TimeFrameNode)

        # Create/Add EntriesShown to Entry
        $EntriesShownNode = $Doc.CreateNode("element",'topn',$null)
        $EntriesShownNode.InnerText = $this.EntriesShown
        $EntryNode.AppendChild($EntriesShownNode)

        # Create/Add Groups to Entry
        $GroupsNode = $Doc.CreateNode("element",'topm',$null)
        $GroupsNode.InnerText = $this.Groups
        $EntryNode.AppendChild($GroupsNode)

        # Create/Add Description to Entry
        $GroupsNode = $Doc.CreateNode("element",'description',$null)
        $GroupsNode.InnerText = $this.Description
        $EntryNode.AppendChild($GroupsNode)

        # Create/Add Description to Entry
        $GroupsNode = $Doc.CreateNode("element",'caption',$null)
        $GroupsNode.InnerText = $this.Name
        $EntryNode.AppendChild($GroupsNode)

        if ($this.Query) {
            # Create/Add Query to Entry
            $QueryNode = $Doc.CreateNode("element",'query',$null)
            $QueryNode.InnerText = $this.Query
            $EntryNode.AppendChild($QueryNode)
        }

        # Append Entry to Root and Root to Doc
        $root.AppendChild($EntryNode)
        $Doc.AppendChild($root)

        return $Doc
    }

    # Translate Database strings
    [string] TranslateDatabaseName([string]$Name,[string]$DesiredType) {
        $DatabaseTranslations = @{}
        $DatabaseTranslations.trsum = "Traffic Summary"
        $DatabaseTranslations.thsum = "Threat Summary"

        $TranslatedName = $null
        if (($DatabaseTranslations.Keys -contains $Name) -and ($DesiredType -eq "Friendly")) {
            $TranslatedName = $DatabaseTranslations.$Name
        } elseif (($DatabaseTranslations.Values -contains $Name) -and ($DesiredType -eq "Short")) {
            $TranslatedName = $DatabaseTranslations.Keys | Where-Object { $DatabaseTranslations["$_"] -eq $Name }
        } else {
            Throw "Invalid Database Name: $Name"
        }

        return $TranslatedName
    }

    ##################################### Initiators #####################################
    # Initiator
    PaCustomReport([string]$Name) {
        $this.Name = $Name
    }
}