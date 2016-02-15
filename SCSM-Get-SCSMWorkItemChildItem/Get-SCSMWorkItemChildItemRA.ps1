# Get the review activity
$childWI_ReviewerActivityHasReviewers_Class_id = '6e05d202-38a4-812e-34b8-b11642001a80'
$childWI_ReviewerActivityHasReviewers_Class_obj = Get-SCSMRelationshipClass -id $childWI_ReviewerActivityHasReviewers_Class_id


# Get the reviewer
$childWI_ReviewerisUser_Class_id = '90da7d7c-948b-e16e-f39a-f6e3d1ffc921'
$childWI_ReviewerisUser_Class_obj = Get-SCSMRelationshipClass -id $childWI_ReviewerisUser_Class_id

$childWI_reviewers = Get-SCSMRelatedObject -SMObject $childWI_obj -Relationship $childWI_ReviewerActivityHasReviewers_Class_obj