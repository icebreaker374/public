Connect-MgGraph -ClientId "<ClientIdHere>" -CertificateThumbprint "<CertThumbprintHere>" -TenantId "<TenantIdHere>" | Out-Null

$ServiceHealthIssues = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/admin/serviceAnnouncement/issues?filter=status eq 'serviceDegradation' or status eq 'investigationSuspended' or status eq 'investigating' or status eq 'restoringService' or status eq 'serviceInterruption'"
$ServiceHealthIssuesReadable = @()

foreach($issue in $ServiceHealthIssues.value){

    $Description = $issue.impactDescription
    
    $OriginalStatus = (((($issue.posts | Sort createdDateTime | Select-object -First 1).description.content)))
    
    if($OriginalStatus -CMatch "Current Status:"){
    
        $OriginalStatus = $OriginalStatus.Substring($OriginalStatus.IndexOf("Current Status:"))
    }

    elseif($OriginalStatus -CMatch "Final Status:"){
    
        $OriginalStatus = $OriginalStatus.Substring($OriginalStatus.IndexOf("Final Status:"))
    }

    elseif($OriginalStatus -CMatch "Current status:"){
    
        $OriginalStatus = $OriginalStatus.Substring($OriginalStatus.IndexOf("Current status:"))
    }

    elseif($OriginalStatus -CMatch "Final status:"){
    
        $OriginalStatus = $OriginalStatus.Substring($OriginalStatus.IndexOf("Final status:"))
    }

    else{
    
        $OriginalStatus = $OriginalStatus.Substring($OriginalStatus.LastIndexOf("`n"))
    }
    
    $RecentStatus = (((($issue.posts | Sort createdDateTime | Select-object -Last 1).description.content)))
    
    if($RecentStatus -CMatch "Current Status:"){
    
        $RecentStatus = $RecentStatus.Substring($RecentStatus.IndexOf("Current Status:"))
    }

    elseif($RecentStatus -CMatch "Final Status:"){
    
        $RecentStatus = $RecentStatus.Substring($RecentStatus.IndexOf("Final Status:"))
    }

    elseif($RecentStatus -CMatch "Current status:"){
    
        $RecentStatus = $RecentStatus.Substring($RecentStatus.IndexOf("Current status:"))
    }

    elseif($RecentStatus -CMatch "Final status:"){
    
        $RecentStatus = $RecentStatus.Substring($RecentStatus.IndexOf("Final status:"))
    }

    else{
    
        $RecentStatus = $RecentStatus.Substring($RecentStatus.LastIndexOf("`n"))
    }
    
    $ServiceHealthIssuesReadable += [PSCustomObject]@{
    
        Started = ($issue.startDateTime).ToString("yyyy-MM-dd-HH:mm:ss-tt")
        EventId = $issue.id
        Status = $issue.status
        AffectedServices = $issue.service
        Description = $issue.impactDescription
        OriginalStatus = $OriginalStatus
        RecentStatus = $RecentStatus

    }
}

$ServiceHealthIssuesReadable | Sort Started -Descending | ConvertTo-Json
