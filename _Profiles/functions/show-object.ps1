#############################################################################
##
## Show-Object
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
##############################################################################
function show-object {
    <#

.SYNOPSIS

Provides a graphical interface to let you explore and navigate an object.


.EXAMPLE

PS > $ps = { Get-Process -ID $pid }.Ast
PS > Show-Object $ps

#>

    param(
        ## The object to examine
        [Parameter(ValueFromPipeline = $true)]
        $InputObject
    )

    Set-StrictMode -Version 3

    Add-Type -Assembly System.Windows.Forms

    ## Figure out the variable name to use when displaying the
    ## object navigation syntax. To do this, we look through all
    ## of the variables for the one with the same object identifier.
    $rootVariableName = Get-ChildItem variable:\* -Exclude InputObject, Args |
        Where-Object -FilterScript {
            $_.Value -and
            ($_.Value.GetType() -eq $InputObject.GetType()) -and
            ($_.Value.GetHashCode() -eq $InputObject.GetHashCode())
        }

    ## If we got multiple, pick the first
    $rootVariableName = $rootVariableName | ForEach-Object Name | Select-Object -First 1

    ## If we didn't find one, use a default name
    if (-not $rootVariableName) {
        $rootVariableName = "InputObject"
    }

    ## A function to add an object to the display tree
    function PopulateNode($node, $object) {
        ## If we've been asked to add a NULL object, just return
        if (-not $object) { return }

        ## If the object is a collection, then we need to add multiple
        ## children to the node
        if ([System.Management.Automation.LanguagePrimitives]::GetEnumerator($object)) {
            ## Some very rare collections don't support indexing (i.e.: $foo[0]).
            ## In this situation, PowerShell returns the parent object back when you
            ## try to access the [0] property.
            $isOnlyEnumerable = $object.GetHashCode() -eq $object[0].GetHashCode()

            ## Go through all the items
            $count = 0
            foreach ($childObjectValue in $object) {
                ## Create the new node to add, with the node text of the item and
                ## value, along with its type
                $newChildNode = New-Object -TypeName Windows.Forms.TreeNode
                $newChildNode.Text = "$($node.Name)[$count] = $childObjectValue : " +
                $childObjectValue.GetType()

                ## Use the node name to keep track of the actual property name
                ## and syntax to access that property.
                ## If we can't use the index operator to access children, add
                ## a special tag that we'll handle specially when displaying
                ## the node names.
                if ($isOnlyEnumerable) {
                    $newChildNode.Name = "@"
                }

                $newChildNode.Name += "[$count]"
                $null = $node.Nodes.Add($newChildNode)

                ## If this node has children or properties, add a placeholder
                ## node underneath so that the node shows a '+' sign to be
                ## expanded.
                AddPlaceholderIfRequired $newChildNode $childObjectValue

                $count++
            }
        }
        else {
            ## If the item was not a collection, then go through its
            ## properties
            foreach ($child in $object.PSObject.Properties) {
                ## Figure out the value of the property, along with
                ## its type.
                $childObject = $child.Value
                $childObjectType = $null
                if ($childObject) {
                    $childObjectType = $childObject.GetType()
                }

                ## Create the new node to add, with the node text of the item and
                ## value, along with its type
                $childNode = New-Object -TypeName Windows.Forms.TreeNode
                $childNode.Text = $child.Name + " = $childObject : $childObjectType"
                $childNode.Name = $child.Name
                $null = $node.Nodes.Add($childNode)

                ## If this node has children or properties, add a placeholder
                ## node underneath so that the node shows a '+' sign to be
                ## expanded.
                AddPlaceholderIfRequired $childNode $childObject
            }
        }
    }

    ## A function to add a placeholder if required to a node.
    ## If there are any properties or children for this object, make a temporary
    ## node with the text "..." so that the node shows a '+' sign to be
    ## expanded.
    function AddPlaceholderIfRequired($node, $object) {
        if (-not $object) { return }

        if ([System.Management.Automation.LanguagePrimitives]::GetEnumerator($object) -or
            @($object.PSObject.Properties)) {
            $null = $node.Nodes.Add( (New-Object -TypeName Windows.Forms.TreeNode "...") )
        }
    }

    ## A function invoked when a node is selected.
    function OnAfterSelect {
        param($Sender, $TreeViewEventArgs)

        ## Determine the selected node
        $nodeSelected = $Sender.SelectedNode

        ## Walk through its parents, creating the virtual
        ## PowerShell syntax to access this property.
        $nodePath = GetPathForNode $nodeSelected

        ## Now, invoke that PowerShell syntax to retrieve
        ## the value of the property.
        $resultObject = Invoke-Expression $nodePath
        $outputPane.Text = $nodePath

        ## If we got some output, put the object's member
        ## information in the text box.
        if ($resultObject) {
            $members = Get-Member -InputObject $resultObject | Out-String
            $outputPane.Text += "`n" + $members
        }
    }

    ## A function invoked when the user is about to expand a node
    function OnBeforeExpand {
        param($Sender, $TreeViewCancelEventArgs)

        ## Determine the selected node
        $selectedNode = $TreeViewCancelEventArgs.Node

        ## If it has a child node that is the placeholder, clear
        ## the placeholder node.
        if ($selectedNode.FirstNode -and
            ($selectedNode.FirstNode.Text -eq "...")) {
            $selectedNode.Nodes.Clear()
        }
        else {
            return
        }

        ## Walk through its parents, creating the virtual
        ## PowerShell syntax to access this property.
        $nodePath = GetPathForNode $selectedNode

        ## Now, invoke that PowerShell syntax to retrieve
        ## the value of the property.
        Invoke-Expression "`$resultObject = $nodePath"

        ## And populate the node with the result object.
        PopulateNode $selectedNode $resultObject
    }

    ## A function to handle keypresses on the form.
    ## In this case, we capture ^C to copy the path of
    ## the object property that we're currently viewing.
    function OnKeyPress {
        param($Sender, $KeyPressEventArgs)

        ## [Char] 3 = Control-C
        if ($KeyPressEventArgs.KeyChar -eq 3) {
            $KeyPressEventArgs.Handled = $true

            ## Get the object path, and set it on the clipboard
            $node = $Sender.SelectedNode
            $nodePath = GetPathForNode $node
            [System.Windows.Forms.Clipboard]::SetText($nodePath)

            $form.Close()
        }
    }

    ## A function to walk through the parents of a node,
    ## creating virtual PowerShell syntax to access this property.
    function GetPathForNode {
        param($Node)

        $nodeElements = @()

        ## Go through all the parents, adding them so that
        ## $nodeElements is in order.
        while ($Node) {
            $nodeElements = , $Node + $nodeElements
            $Node = $Node.Parent
        }

        ## Now go through the node elements
        $nodePath = ""
        foreach ($Node in $nodeElements) {
            $nodeName = $Node.Name

            ## If it was a node that PowerShell is able to enumerate
            ## (but not index), wrap it in the array cast operator.
            if ($nodeName.StartsWith('@')) {
                $nodeName = $nodeName.Substring(1)
                $nodePath = "@(" + $nodePath + ")"
            }
            elseif ($nodeName.StartsWith('[')) {
                ## If it's a child index, we don't need to
                ## add the dot for property access
            }
            elseif ($nodePath) {
                ## Otherwise, we're accessing a property. Add a dot.
                $nodePath += "."
            }

            ## Append the node name to the path
            $nodePath += $nodeName
        }

        ## And return the result
        $nodePath
    }

    ## Create the TreeView, which will hold our object navigation
    ## area.
    $treeView = New-Object -TypeName Windows.Forms.TreeView
    $treeView.Dock = "Top"
    $treeView.Height = 500
    $treeView.PathSeparator = "."
    $treeView.Add_AfterSelect( { OnAfterSelect @args } )
    $treeView.Add_BeforeExpand( { OnBeforeExpand @args } )
    $treeView.Add_KeyPress( { OnKeyPress @args } )

    ## Create the output pane, which will hold our object
    ## member information.
    $outputPane = New-Object -TypeName System.Windows.Forms.TextBox
    $outputPane.Multiline = $true
    $outputPane.ScrollBars = "Vertical"
    $outputPane.Font = "Consolas"
    $outputPane.Dock = "Top"
    $outputPane.Height = 300

    ## Create the root node, which represents the object
    ## we are trying to show.
    $root = New-Object -TypeName Windows.Forms.TreeNode
    $root.Text = "$InputObject : " + $InputObject.GetType()
    $root.Name = '$' + $rootVariableName
    $root.Expand()
    $null = $treeView.Nodes.Add($root)

    ## And populate the initial information into the tree
    ## view.
    PopulateNode $root $InputObject

    ## Finally, create the main form and show it.
    $form = New-Object -TypeName Windows.Forms.Form
    $form.Text = "Browsing " + $root.Text
    $form.Width = 1000
    $form.Height = 800
    $form.Controls.Add($outputPane)
    $form.Controls.Add($treeView)
    $null = $form.ShowDialog()
    $form.Dispose()
}