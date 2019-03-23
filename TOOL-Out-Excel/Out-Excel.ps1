function Out-Excel
{
<#
	.SYNOPSIS
	.DESCRIPTION
	.PARAMETER Property
	.PARAMETER Raw
	.NOTES
    	Original Script: http://pathologicalscripter.wordpress.com/out-excel/

		TODO:
			Parameter to change color of header
			Parameter to activate background color on Odd unit
			Add TRY/CATCH
			Validate Excel first is present
#>
	[CmdletBinding()]
	PARAM ([string[]]$property, [switch]$raw)

	BEGIN
	{
		# start Excel and open a new workbook
		$Excel = New-Object -Com Excel.Application
		$Excel.visible = $True
		$Excel = $Excel.Workbooks.Add()
		$Sheet = $Excel.Worksheets.Item(1)
		# initialize our row counter and create an empty hashtable
		# which will hold our column headers
		$Row = 1
		$HeaderHash = @{ }
	}

	PROCESS
	{
		if ($_ -eq $null) { return }
		if ($Row -eq 1)
		{
			# when we see the first object, we need to build our header table
			if (-not $property)
			{
				# if we haven’t been provided a list of properties,
				# we’ll build one from the object’s properties
				$property = @()
				if ($raw)
				{
					$_.properties.PropertyNames | %{ $property += @($_) }
				}
				else
				{
					$_.PsObject.get_properties() | % { $property += @($_.Name.ToString()) }
				}
			}
			$Column = 1
			foreach ($header in $property)
			{
				# iterate through the property list and load the headers into the first row
				# also build a hash table so we can retrieve the correct column number
				# when we process each object
				$HeaderHash[$header] = $Column
				$Sheet.Cells.Item($Row, $Column) = $header.toupper()
				$Column++
			}
			# set some formatting values for the first row
			$WorkBook = $Sheet.UsedRange
			$WorkBook.Interior.ColorIndex = 19
			$WorkBook.Font.ColorIndex = 11
			$WorkBook.Font.Bold = $True
			$WorkBook.HorizontalAlignment = -4108
		}
		$Row++
		foreach ($header in $property)
		{
			# now for each object we can just enumerate the headers, find the matching property
			# and load the data into the correct cell in the current row.
			# this way we don’t have to worry about missing properties
			# or the “ordering” of the properties
			if ($thisColumn = $HeaderHash[$header])
			{
				if ($raw)
				{
					$Sheet.Cells.Item($Row, $thisColumn) = [string]$_.properties.$header
				}
				else
				{
					$Sheet.Cells.Item($Row, $thisColumn) = [string]$_.$header
				}
			}
		}
	}

	end
	{
		# now just resize the columns and we’re finished
		if ($Row -gt 1) { [void]$WorkBook.EntireColumn.AutoFit() }
	}
}