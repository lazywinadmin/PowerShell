Function Add-SRComment
{
<#
	.SYNOPSIS
		Function to add a comment inside a Service Request

	.DESCRIPTION
		Function to add a comment inside a Service Request
		You need to have SMlets installed and permission to write inside
		the service request.

	.PARAMETER ServiceRequestObject
		Specifies the ServiceRequest where the comment will be added

	.PARAMETER Comment
		Specifies the comment to add.

	.PARAMETER CommentType
		Specifies the comment type.
		You need to specify 'User' or 'Analyst'.

	.PARAMETER EnteredBy
		Specifies your name.

	.PARAMETER IsPrivate
		Specifies if the switch is private

	.EXAMPLE
		PS C:\> Add-SRComment -ServiceRequestObject $SR -Comment "Task Completed" -CommentType Analyst -EnteredBy 'Francois-Xavier Cat'

	.EXAMPLE
		PS C:\> Add-SRComment -ServiceRequestObject $SR -Comment "Task Completed" -CommentType Analyst -EnteredBy 'Francois-Xavier Cat' -IsPrivate

	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm

		Script inspired from http://www.scsm.se/?p=1423 by Anders Asp
#>
	[CmdletBinding()]
	PARAM (

		[Alias("SRObject")]
		[parameter(Mandatory = $true)]
		[System.WorkItem.ServiceRequest]$ServiceRequestObject,

		[parameter(Mandatory = $True)]
		[String]$Comment,

		[ValidateSet("User", "Analyst")]
		[parameter(Mandatory = $True)]
		[System.WorkItem.TroubleTicket]
		[String]$CommentType,

		[parameter(Mandatory = $True)]
		[String]$EnteredBy,

		[Switch]$IsPrivate
	)
	BEGIN
	{
		TRY
		{
			if (-not (Get-Module -Name Smlets))
			{
				Import-Module -Name Smlets -ErrorAction 'Stop'
			}
		}
		CATCH
		{
			$Error[0]	
		}
	}
	PROCESS
	{
		TRY
		{
			# Make sure that the SR Object it passed to the function
			If ($ServiceRequestObject.Id -ne $NULL)
			{
				Switch ($CommentType)
				{
					"Analyst" {
						$CommentClass = "System.WorkItem.TroubleTicket.AnalystCommentLog"
						$CommentClassName = "AnalystCommentLog"
					}
					"User" {
						$CommentClass = "System.WorkItem.TroubleTicket.UserCommentLog"
						$CommentClassName = "EndUserCommentLog"
					}
				}
				# Generate a new GUID for the comment
				$NewGUID = ([guid]::NewGuid()).ToString()

				# Create the object projection with properties
				$Projection = @{
					__CLASS = "System.WorkItem.ServiceRequest";
					__SEED = $ServiceRequestObject;
					EndUserCommentLog = @{
						__CLASS = $CommentClass;
						__OBJECT = @{
							Id = $NewGUID;
							DisplayName = $NewGUID;
							Comment = $Comment;
							EnteredBy = $EnteredBy;
							EnteredDate = (Get-Date).ToUniversalTime();
							IsPrivate = $IsPrivate.ToBool();
						}
					}
				}

				# Create the actual comment
				New-SCSMObjectProjection -Type "System.WorkItem.ServiceRequestProjection" -Projection $Projection
			}
			else
			{
				Throw "Invalid Service Request Object!"
			}
		}
		CATCH
		{
			$Error[0]	
		} #CATCH
	} #PROCESS
} # Function