Import-Module "$PSScriptRoot/UniversalDashboard.Outrest.psm1" -Force
$Endpoints = Out-UDRestApi -Command "Get-Service"
Start-UDRestApi -Endpoint $Endpoints -Port 10000 
Invoke-RestMethod -Method Get -Uri "http://localhost:10000/api/Service"