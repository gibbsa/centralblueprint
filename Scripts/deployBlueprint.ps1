<#
    .Description
        This script deploys a blueprint by checking current deployment version of blueprint and updating version 
        if needed and adding importing from location. Version should be a number in n.nn format.

    .Parameter environment
    A indicator for which cloud either AzureCloud or AzureUSGovernment.

    .Parameter blueprintName
    Name of the Blueprint to deploy.

    .Parameter version
    If first time deployed the blueprint will need a version number in 'n.nn' format. Default is 0 and will be incramented by .01.

    .Parameter path
    Location of blueprint. Main deploy file, this scripts includes artifacts in artifacts folder. 
    
    .Notes
    Author: shawngib@microsoft.com
    Updated: July/2/2020

#>

param
(
    [Parameter(Mandatory = $False)]
    [ValidateSet("AzureCloud","AzureUSGovernment")]
    [string]$environment = "AzureCloud",

    [Parameter(Mandatory = $False)]
    [string]$blueprintName = "CentralLogging",

    [Parameter(Mandatory = $False)]
    [int]$version = 0,

    [Parameter(Mandatory = $False)]
    [string]$path = "F:\GitHub\Monitoring_Setup\policies\Central_Workspace"
)
# Function to add numbers to arrays to help create selectors
function Add-IndexNumberToArray (
    [Parameter(Mandatory=$True)]
    [array]$array
    )
{
    for($i=0; $i -lt $array.Count; $i++) 
    { 
        Add-Member -InputObject $array[$i] -Name "#" -Value ($i+1) -MemberType NoteProperty 
    }
    $array
}

# Log in if required and select active subscription
try
{
    $AzLogin = Get-AzSubscription
}
catch
{
    $null = Login-AzAccount -Environment $environment
    $AzLogin = Get-AzSubscription
}

# Set variables
$SelectedSubscriptionItem = 0
[string]$Subscription = ""
[array]$ordered = ""

# Main #
if($AzLogin.Count -gt 1)
{
    $null = Add-IndexNumberToArray($AzLogin)
    while($SelectedSubscriptionItem -gt $AzLogin.Count -or $SelectedSubscriptionItem -lt 1)
    {
        write-host("Select a subscription")
        $AzLogin | Select-Object "#", Name, ID | Format-Table
        try
        {
            $SelectedSubscriptionItem = Read-Host "Choose:"
            $Subscription = $AzLogin[$SelectedSubscriptionItem -1]
            $null = Select-AzSubscription -SubscriptionId $Subscription
        }
        catch
        {
            Write-Warning -Message "Invalid selection, please try again."
        }
    }
}

# Gets/Sets version of imported templated using numbers. Not required if wanting to manually control versions.
try {
    $print = get-azblueprint -Name $blueprintName -ErrorAction SilentlyContinue
    [array]$c = foreach($number in $print.Versions) 
        {
            $num = $number -replace "`t|`n|`r",""
            ([convert]::ToDecimal($num))
        } 
    $ordered = $c | Sort-Object -Descending
    $wholeversion =  [convert]::ToInt16($ordered[0])
    if($wholeversion -gt 0 -and $ordered[0] - $wholeversion -eq 0 ) { $version = $ordered[0] + 1 }
    else { $version = $ordered[0] +.01 } 
    }
    catch
    {
        Write-Output("Blueprint has not been found so version equals 1")
        $version = .01
    }

Import-AzBlueprintWithArtifact -InputPath $path -Name $blueprintName -IncludeSubFolders -Force
$blueprint = Get-AzBlueprint -Name $blueprintName 
Publish-AzBlueprint -Blueprint $blueprint -Version $version

Get-AzUserAssignedIdentity -ResourceGroupName Central-Logging-RG

## ARM Templates with deploy scripts require user managed identity.
#Install-Module -Name PowerShellGet -AllowPrerelease
#Install-Module -Name Az.ManagedServiceIdentity -AllowPrerelease
#New-AzUserAssignedIdentity -ResourceGroupName <RESOURCEGROUP> -Name <USER ASSIGNED IDENTITY NAME>