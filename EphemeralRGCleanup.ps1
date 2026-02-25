Disable-AzContextAutosave -Scope Process | Out-Null
Connect-AzAccount -Identity | Out-Null

$subscriptionId = (Get-AzContext).Subscription.Id
$now = [DateTime]::UtcNow

Write-Output "Starting ephemeral RG cleanup at $now UTC"

$resourceGroups = Get-AzResourceGroup

foreach ($rg in $resourceGroups) {
    $tags = $rg.Tags
    if ($null -eq $tags) { continue }

    $isEphemeral = $tags["ephemeral"]
    $createdTag   = $tags["Created"]

    if ($isEphemeral -ne "true" -or [string]::IsNullOrWhiteSpace($createdTag)) { continue }

    $createdTime = $null
    $formats = @("yyyy-MM-dd HH:mm:ss", "yyyy-MM-ddTHH:mm:ss", "yyyy-MM-dd HH:mm:ssZ")
    foreach ($fmt in $formats) {
        try {
            $createdTime = [DateTime]::ParseExact($createdTag.Trim(), $fmt,
                [System.Globalization.CultureInfo]::InvariantCulture,
                [System.Globalization.DateTimeStyles]::AssumeUniversal -bor
                [System.Globalization.DateTimeStyles]::AdjustToUniversal)
            break
        } catch { }
    }

    if ($null -eq $createdTime) {
        Write-Warning "RG '$($rg.ResourceGroupName)': could not parse 'created' tag value '$createdTag'. Skipping."
        continue
    }

    $ageHours = ($now - $createdTime).TotalHours
    Write-Output "RG '$($rg.ResourceGroupName)': age = $([math]::Round($ageHours,2)) hours"

    if ($ageHours -gt 24) {
        Write-Output "DELETING RG '$($rg.ResourceGroupName)' (age > 24h)"
        Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force -AsJob | Out-Null
        Write-Output "Delete job submitted for '$($rg.ResourceGroupName)'"
    }
}

Write-Output "Cleanup run complete."
