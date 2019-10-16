# UDOutRest

## Universal Dashboard REST API Generator for PowerShell

You can use Universal Dashboard OutREST to generate REST API based on Universal Dashboard from Modules and Functions you already have. 

## Note! This is merely an experiment at this point and will not work in many scenarios. 

# Installation 

```
Install-Module UniversalDashboard.OutRest
```

# Example 

```
$Endpoints = Out-UDRestApi -Command "Get-Service"
Start-UDRestApi -Endpoint $Endpoints -Port 10000 
Invoke-RestMethod -Method Get -Uri "http://localhost:10000/api/Service"
```




