Connect-MgGraph -TenantId "<TenantIdHere>" -ClientId "<ClientIdHere>" -CertificateThumbprint "<CertThumbprintHere>" -ContextScope Process | Out-Null

# Initializes the log collection variable.
$RequestLog = @()

# Forms the date/time filter strings in a format the Graph API URLs will accept.
$DateTimeFilterStart = (((Get-Date).Date).AddDays(-7)).ToString('yyyy-MM-dd') + "T04:00:00Z"
$DateTimeFilterEnd = (Get-Date).ToString('yyyy-MM-dd') + "T" + "04:00:00Z"

# Stores the GUID's for the groups to be audited.
$PIMGroups = @(

    "Group1GUIDHere" # Group 1 Name
    "Group2GUIDHere" # Group 2 Name
    "Group3GUIDHere" # Group 3 Name
)

$RequireApprovalGroups = @(

    "Group3GUIDHere" # Group 3 Name
)
# Forms the Graph API URL to pull all the PIM activation requests for the last 7 days. Also sets a skip count variable to be used in tandem with a
# do/while function to perform API request output paging.

foreach($group in $PIMGroups){

    $graphRequestURI = "https://graph.microsoft.com/v1.0/identityGovernance/privilegedAccess/group/assignmentScheduleRequests?filter=groupId eq " + "'" + "$group" + "' " + "and createdDateTime ge $DateTimeFilterStart " + "and createdDateTime lt $DateTimeFilterEnd"
    $PIMRequests = Invoke-MgGraphRequest -Method GET -Uri $graphRequestURI
    $skipCount = ($PIMRequests.'@odata.nextLink' -Split "skip=")[1]
    
    if($PIMRequests.'@odata.nextLink'){

        do{
    
            $graphRequestPageURI = "https://graph.microsoft.com/v1.0/identityGovernance/privilegedAccess/group/assignmentScheduleRequests?filter=groupId eq " + "'" + "$group" + "'" + "and createdDateTime ge $DateTimeFilterStart " + "and createdDateTime le $DateTimeFilterEnd" + "&skip=$skipCount"
            $PIMRequestsPage = Invoke-MgGraphRequest -Method GET -Uri $graphRequestPageURI
            $PIMRequests.value += $PIMRequestsPage.value
            $skipCount += $skipCount
        } until (!$PIMRequestsPage.'@odata.nextLink')
    }


    foreach($request in $PIMRequests.value){

        $requestId = $request.id

        $createdTimeInEST = [TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($request.createdDateTime, 'Eastern Standard Time')
        $createdTime = Get-Date -Date $createdTimeInEST -Format "MM-dd-yyyy-HH:mm:ss"
        #Converts the request time to EST.
    
        $requestorURI = "https://graph.microsoft.com/v1.0/users/" + $request.createdBy.user.id + '?$select=userPrincipalName,displayName'
        $requestor = Invoke-MgGraphRequest -Method GET -Uri $requestorURI
        $requestorEmail = $requestor.userPrincipalName
        $requestorDisplayName = $requestor.displayName
        # Forms the Graph API URL to get the UPN and display name of the user submitting the request, invokes it, and extrapolates both to invidivudal variables.
    
        $groupURI = "https://graph.microsoft.com/v1.0/groups/" + $request.groupId + '?$select=displayName'
        $groupInfo = Invoke-MgGraphRequest -Method GET -Uri $groupURI
        $groupDisplayName = $groupInfo.displayName
        # Forms the Graph API URL to get the display name of the group the user submitted the request for, invokes it, and extrapolates it to a variable.
    
        $action = $request.action
        $reason = $request.justification
        # Extrapolates the event action type and reason to individual variables.

        $ticketNumber = $request.ticketInfo.ticketNumber
        # Extrapolates the ticket number to a variable.    
            
        if($groupDisplayName -In $RequireApprovalGroups){

            $approvalURI = "https://graph.microsoft.com/v1.0/identityGovernance/privilegedAccess/group/assignmentApprovals/$requestId"
            $approvalInfo = Invoke-MgGraphRequest -Method GET -Uri $approvalURI
        }
        # Forms the Graph API URL to get the approval related data for a specific PIM request, invokes it, and extrapolates the data to individual variables.

        if($approvalInfo.Length -EQ 0){

            $requestObject = [PSCustomObject]@{
    
                Requestor = "$requestorDisplayName ($requestorEmail)"
                PimGroup = $groupDisplayName
                StartTime = $createdTime
                Action = $action
                TicketNumber = $ticketNumber
                Reason = $reason
                ApprovalDenialAction = ""
                ApprovalDenialActorName = ""
                ApprovalDenialActorEmail = ""
                ApprovalDenialTime = ""
                ApprovalDenialReason = ""
            }
        }

        else{

            $approvalDenialAction = $approvalInfo.stages.reviewResult
            $approvalDenialActorDisplayName = $approvalInfo.stages.reviewedBy.displayName
            $approvalDenialActorEmail = $approvalInfo.stages.reviewedBy.userPrincipalName

            if(!$approvalInfo.stages.reviewedDateTime){

                $approvalDenialTime = "N/A"
            }

            else{
            
                $approvalDenialTimeInEST = [TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($approvalInfo.stages.reviewedDateTime, 'Eastern Standard Time')
                $approvalDenialTime = Get-Date -Date $approvalDenialTimeInEST -Format "MM-dd-yyyy-HH:mm:ss"
            }

            $approvalDenialReason = $approvalInfo.stages.justification
            
            $requestObject = [PSCustomObject]@{
    
                Requestor = "$requestorDisplayName ($requestorEmail)"
                PimGroup = $groupDisplayName
                StartTime = $createdTime
                Action = $action
                TicketNumber = $ticketNumber
                Reason = $reason
                ApprovalDenialAction = $approvalDenialAction
                ApprovalDenialActorName = $approvalDenialActorDisplayName
                ApprovalDenialActorEmail = $approvalDenialActorEmail
                ApprovalDenialTime = $approvalDenialTime
                ApprovalDenialReason =$approvalDenialReason
            }
        }
        # Forms a custom object type that appends the entries to a human-readable log format that can be exported to CSV.

        $RequestLog += $requestObject
        # Appends each request entry to the log.
    }
}

$RequestLog | Sort StartTime | ConvertTo-Json
# Sorts the log by StartTime and converts it to JSON.
