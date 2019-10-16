function Out-UDRestApi {
    param(
        [Parameter(Mandatory, ParameterSetName = "Module")]
        [string]$Module,
        [Parameter(Mandatory, ParameterSetName = "Command")]
        [string]$Command
    )

    if ($PSCmdlet.ParameterSetName -eq 'Module')
    {
        Out-UDModuleRestApi -Module $Module
    }

    if ($PSCmdlet.ParameterSetName -eq 'Command')
    {
        $CommandDefinition = Get-Command $Command 
        Out-UDRestEndpoint -CommandDefinition $CommandDefinition
    }
}

function Out-UDModuleRestApi {
    param(
        [Parameter(Mandatory, ParameterSetName = "Module")]
        [string]$Module
    )

    Get-Command -Module $Module | ForEach-Object {
        Out-UDRestEndpoint -CommandDefinition $_ 
    }
}

function Out-UDRestEndpoint {
    param(
        [Parameter(Mandatory)]
        $CommandDefinition
    )

    

    $RestMethod = ConvertTo-RestMethod -Verb $CommandDefinition.Verb
    $CommandDefinition.ParameterSets | ForEach-Object {
        $RestUrl = New-RestUrl -ParameterSet $_
        $MandatoryParameters = $_.Parameters.Where({$_.IsMandatory})

        $Endpoint = ""
        if ($MandatoryParameters.Length -gt 0)
        {
            $paramBlock = "param("
            $_.Parameters.Where({$_.IsMandatory}) | ForEach-Object {
                $paramBlock += "`$$($_.Name),"
            }
            $paramBlock = $paramBlock.TrimEnd(',')
            $paramBlock += ")`r`n"
            $Endpoint += $paramBlock
        }

        $Endpoint += '
        $Parameters = @{}

        $PSBoundParameters.Keys | ForEach-Object {
            $Parameters[$_] = $PSBoundParameters[$_]
        }

        $Request.Query.GetEnumerator() | ForEach-Object {
            $Parameters[$_.Key] = $_.Value[0]
        }
        '

        $Endpoint += $CommandDefinition.Name + " @Parameters | ConvertTo-Json"

        $ScriptBlock = [scriptblock]::Create($Endpoint)
        New-UDEndpoint -Url $RestUrl -Method $RestMethod -Endpoint $ScriptBlock
    }

}

function New-RestUrl {
    param(
        [Parameter(Mandatory)]
        [System.Management.Automation.CommandParameterSetInfo]$ParameterSet
    )

    $Url = "/$($CommandDefinition.Noun)"

    $ParameterSet.Parameters.Where({$_.IsMandatory}) | ForEach-Object {
        $Url += "/:$($_.Name)"
    }

    $Url
}

function ConvertTo-RestMethod {
    param(
        [Parameter(Mandatory)]
        [string]$Verb
    )

    $GetVerbs = @('Get')
    $PostVerbs = @('Invoke', 'New')
    $PutVerbs = @('Set')
    $DeleteVerbs = @('Remove')

    if ($GetVerbs -contains $Verb) {
        return 'GET'
    }

    if ($PostVerbs -contains $Verb) {
        return 'POST'
    }

    if ($PutVerbs -contains $Verb) {
        return 'PUT'
    }

    if ($DeleteVerbs -contains $Verb) {
        return 'DELETE'
    }
}