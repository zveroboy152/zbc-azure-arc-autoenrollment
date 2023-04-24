# Define the script block to run on each active server
$ScriptBlock = {
try {
    $servicePrincipalClientId="EXAMPLE TEXT";
    $servicePrincipalSecret="EXAMPLE TEXT";

    $env:SUBSCRIPTION_ID = "EXAMPLE TEXTc";
    $env:RESOURCE_GROUP = "EXAMPLE TEXT";
    $env:TENANT_ID = "EXAMPLE TEXT";
    $env:LOCATION = "westus2";
    $env:AUTH_TYPE = "principal";
    $env:CORRELATION_ID = "EXAMPLE TEXT";
    $env:CLOUD = "AzureCloud";
    

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-WebRequest -UseBasicParsing -Uri "https://aka.ms/azcmagent-windows" -TimeoutSec 30 -OutFile "$env:TEMP\install_windows_azcmagent.ps1";
    & "$env:TEMP\install_windows_azcmagent.ps1";
    if ($LASTEXITCODE -ne 0) { exit 1; }
    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect --service-principal-id "$servicePrincipalClientId" --service-principal-secret "$servicePrincipalSecret" --resource-group "$env:RESOURCE_GROUP" --tenant-id "$env:TENANT_ID" --location "$env:LOCATION" --subscription-id "$env:SUBSCRIPTION_ID" --cloud "$env:CLOUD" --tags "Datacenter=240,CountryOrRegion=USA,Environment=Homelab" --correlation-id "$env:CORRELATION_ID";
}
catch {
    $logBody = @{subscriptionId="$env:SUBSCRIPTION_ID";resourceGroup="$env:RESOURCE_GROUP";tenantId="$env:TENANT_ID";location="$env:LOCATION";correlationId="$env:CORRELATION_ID";authType="$env:AUTH_TYPE";operation="onboarding";messageType=$_.FullyQualifiedErrorId;message="$_";};
    Invoke-WebRequest -UseBasicParsing -Uri "https://gbl.his.arc.azure.com/log" -Method "PUT" -Body ($logBody | ConvertTo-Json) | out-null;
    Write-Host  -ForegroundColor red $_.Exception;
}

}

# Get a list of all active Windows servers in the domain
$Servers = Get-ADComputer -Filter {(OperatingSystem -like "*Windows Server*") -and (Enabled -eq $true)} | Select-Object -ExpandProperty Name

# Loop through each server and do a reachability check by pinging
foreach ($Server in $Servers) {
    Write-Host "Checking reachability of $Server"
    if (Test-Connection -ComputerName $Server -Count 1 -Quiet) {
        Write-Host "Running script block on $Server"
        Invoke-Command -ComputerName $Server -ScriptBlock $ScriptBlock

        sleep 3
    }
    else {
        Write-Host "$Server is not reachable"
    }
}
