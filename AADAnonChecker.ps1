#FarFromPerfect, feel free to contribute to improve it

while ($true) {
    $domainName = Read-Host "Enter a domain name (type 'exit' to quit)"
    if ($domainName -eq "exit") {
        break
    }
    $tenantId = $null
    $response = Invoke-WebRequest -Uri "https://login.windows.net/$domainName/.well-known/openid-configuration" -UseBasicParsing -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        $json = $response.Content | ConvertFrom-Json
        $issuer = $json.issuer
        $parts = $issuer.Split('/')
        $tenantId = $parts[$parts.Count - 2]
        Write-Host "The domain '$domainName' is hosted in Azure AD. Tenant ID: $tenantId"
        Write-Host "Checking if AllowAnonymous is enabled"
        Connect-AzureAD -TenantId $tenantId -AllowAnonymous
        $anonymousFlag = (Get-AzureADDirectorySetting | Where-Object {$_.DisplayName -eq "Group.Unified" -and $_.TargetType -eq "Groups"}).Values
            if ($anonymousFlag -eq $true) {
                Write-Host "AllowAnonymous flag is enabled"
                Write-Host "Connecting anonymously"
                Connect-AzureAD -TenantDomain $domainname -AllowPromptForCredentials:$false -SkipUserPromptForAdminConsent
            }
            else {
                Write-Host "AllowAnonymous flag is not enabled"
            }
    }
    else {
        Write-Host "The domain '$domainName' is not hosted in Azure AD."
    }
}
