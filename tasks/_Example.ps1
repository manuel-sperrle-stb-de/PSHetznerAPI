$PSDefaultParameterValues['*Hetzner*:AuthAPIToken'] = Get-Content (Join-Path $PSScriptRoot 'AuthAPIToken.env')
$PSDefaultParameterValues['*Hetzner*:BaseUri'] = 'https://dns.hetzner.com/api/v1'

Get-ChildItem $PSScriptRoot/.. -Recurse -Filter *.Function.ps1 | ForEach-Object {
    . $_.FullName
}

$Zones = ("zones" | Invoke-RestMethod-Hetzner -Paged).zones
$Zones.Count