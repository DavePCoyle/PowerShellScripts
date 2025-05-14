# Ensure Az module is imported
Import-Module Az.Network
Import-Module Az.Accounts

# Connect to Azure (if not already connected)
Connect-AzAccount

# Get all subscriptions
$subscriptions = Get-AzSubscription

# Initialize an array to store results
$results = @()

foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)" -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    # Get all Application Gateways in this subscription
    $gateways = Get-AzApplicationGateway

    foreach ($gw in $gateways) {
        foreach ($httpSetting in $gw.BackendHttpSettingsCollection) {
            $results += [pscustomobject]@{
                Subscription         = $sub.Name
                ResourceGroup        = $gw.ResourceGroupName
                AppGatewayName       = $gw.Name
                BackendHttpSetting   = $httpSetting.Name
                Port                 = $httpSetting.Port
                Protocol             = $httpSetting.Protocol
                RequestTimeout       = $httpSetting.RequestTimeout
                ConnectionDraining   = $httpSetting.ConnectionDraining.Enabled
                DrainTimeoutInSec    = $httpSetting.ConnectionDraining.DrainTimeoutInSec
                CookieBasedAffinity  = $httpSetting.CookieBasedAffinity
            }
        }
    }
}

# Export to CSV
$results | Export-Csv -Path "$HOME\appGatewayTimeouts.csv" -NoTypeInformation
Write-Host "Exported results to $HOME\appGatewayTimeouts.csv" -ForegroundColor Green
