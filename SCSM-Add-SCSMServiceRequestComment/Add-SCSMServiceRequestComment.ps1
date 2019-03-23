Function Add-SCSMServiceRequestComment
{
    param (
        [parameter(Mandatory = $True, Position = 0)]
        $SRObject,

        [parameter(Mandatory = $True, Position = 1)]
        $Comment,

        [parameter(Mandatory = $True, Position = 2)]
        $EnteredBy,

        [parameter(Mandatory = $False, Position = 3)]
        [switch]$AnalystComment,

        [parameter(Mandatory = $False, Position = 4)]
        [switch]$IsPrivate
    )

    # Make sure that the SR Object it passed to the function
    If ($SRObject.Id -ne $NULL)
    {


        If ($AnalystComment)
        {
            $CommentClass = "System.WorkItem.TroubleTicket.AnalystCommentLog"
            $CommentClassName = "AnalystCommentLog"
        }
        else
        {
            $CommentClass = "System.WorkItem.TroubleTicket.UserCommentLog"
            $CommentClassName = "EndUserCommentLog"
        }

        # Generate a new GUID for the comment
        $NewGUID = ([guid]::NewGuid()).ToString()

        # Create the object projection with properties
        $Projection = @{
            __CLASS = "System.WorkItem.ServiceRequest";
            __SEED = $SRObject;
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