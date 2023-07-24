param (
    $MgSiteDisplayName = 'IT',
    $MgSiteListDisplayName = 'Domains'
)

Function Get-Data {
   
    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [object]
        $MgSite,

        [Parameter(Mandatory)]
        [object]
        $MgSiteList

    )

    $GetMgSiteListItemNestedParams = @{
        MgSite = $MgSite
        MgSiteList = $MgSiteList
    }

    $SelectObjectParams = @{
        Property = @(
            'SiteId'
            'ListId'
            'ListItemId'
            @{
                n = 'Title'
                e = { $_.Fields.AdditionalProperties.Title }
            }
            @{
                n = 'Owner'
                e = { $_.Fields.AdditionalProperties.Owner }
            }
            @{
                n = 'Bemerkung'
                e = { $_.Fields.AdditionalProperties.Bemerkung }
            }
            @{
                n = 'ZoneId'
                e = { $_.Fields.AdditionalProperties.ZoneId }
            }
            @{
                n = 'ZoneFile'
                e = { $_.Fields.AdditionalProperties.ZoneFile }
            }    
        )    
    }
    
    $Data = @{}

    'Fetching Mg ...' | Write-Host
    $Data.Mg = Get-MgSiteListItemNested @GetMgSiteListItemNestedParams | Select-Object @SelectObjectParams

    'Fetching Hetzner ...' | Write-Host
    $Data.Hetzner = Get-HetznerZones

    $Data

}



'Loading Functions ...' | Write-Host
Get-ChildItem $PSScriptRoot/.. -Recurse -Filter *.Function.ps1 | ForEach-Object {
    $_.BaseName.TrimEnd('.Function') | Write-Host
    . $_.FullName
}

'Loading Prerequisites ...' | Write-Host
$HetznerAuthApiToken = Get-Content (Join-Path $PSScriptRoot 'AuthAPIToken.env')

'PSDefaultParameterValues ...' | Write-Host
$PSDefaultParameterValues['Connect-MgGraph:Scopes'] = @(
    "Sites.Read.All"
    "Sites.ReadWrite.All"
)
$PSDefaultParameterValues['Get-MgSiteByDisplayName:DisplayName'] = $MgSiteDisplayName
$PSDefaultParameterValues['Get-MgSiteListByDisplayName:DisplayName'] = $MgSiteListDisplayName
$PSDefaultParameterValues['*Hetzner*:BaseUri'] = 'https://dns.hetzner.com/api/v1'
$PSDefaultParameterValues['*Hetzner*:AuthAPIToken'] = $HetznerAuthApiToken

'Connect-MgGraph ...' | Write-Host
Connect-MgGraph

'Get-MgSiteByDisplayName "{0}" ...' -f $MgSiteDisplayName | Write-Host
$MgSite = Get-MgSiteByDisplayName
$PSDefaultParameterValues['Get-MgSiteListByDisplayName:MgSite'] = $MgSite
$PSDefaultParameterValues['Get-Data:MgSite'] = $MgSite
$MgSite.Id | Write-Host

'Get-MgSiteListByDisplayName "{0}" ...' -f $MgSiteListDisplayName | Write-Host
$MgSiteList = Get-MgSiteListByDisplayName
$PSDefaultParameterValues['Get-Data:MgSiteList'] = $MgSiteList
$MgSiteList.Id | Write-Host

'Get-Data ...' | Write-Host
$Data = Get-Data

'Generating Missing ...' | Write-Host
$Missing = $Data.Hetzner | Where-Object { $Data.Mg.ZoneId -notcontains $_.id }

'Processing Missing -> MgGraph' | Write-Host
$Missing | ForEach-Object {
    
    $HetznerObject = $_

    # soft: check if it exists by name
    if ( $ExistingMgByName = $Data.Mg | Where-Object { $_.Title -eq $HetznerObject.name } ) {

        $MgSiteListItemParams = @{
            SiteId = $MgSite.Id
            ListId = $MgSiteList.Id
            ListItemId = $ExistingMgByName.ListItemId
            BodyParameter = @{
                fields = @{
                    ZoneId = $HetznerObject.id
                }
            }
        }
        Update-MgSiteListItem @MgSiteListItemParams

    }
    else {

        $MgSiteListItemParams = @{
            SiteId = $MgSite.Id
            ListId = $MgSiteList.Id
            BodyParameter = @{
                fields = @{
                    Title = $HetznerObject.name
                    ZoneId = $HetznerObject.id
                }
            }
        }
        New-MgSiteListItem @MgSiteListItemParams
    
    }

}

$Data.Mg | Where-Object ZoneId -ne $null | ForEach-Object {
 
    $MgSiteListItemParams = @{
        SiteId = $_.SiteId
        ListId = $_.ListId
        ListItemId = $_.ListItemId
        BodyParameter = @{
            fields = @{
                ZoneFile = "zones/{0}/export" -f $_.ZoneId | Invoke-RestMethod-Hetzner -ContentType 'application/x-www-form-urlencoded; charset=utf-8'
            }
        }
    }
    Update-MgSiteListItem @MgSiteListItemParams

}