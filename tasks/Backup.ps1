$PSDefaultParameterValues['*Hetzner*:AuthAPIToken'] = Get-Content (Join-Path $PSScriptRoot 'AuthAPIToken.env')
$PSDefaultParameterValues['*Hetzner*:BaseUri'] = 'https://dns.hetzner.com/api/v1'

Get-ChildItem $PSScriptRoot/.. -Recurse -Filter *.Function.ps1 | ForEach-Object {
    . $_.FullName
}

$VolumesPath = Join-Path $PSScriptRoot/.. 'volumes'
$ZonesPath = Join-Path $VolumesPath 'zones'

$TimeStamp = Get-Date -Format yyyyMMddhhmmss
$Destination = Join-Path $ZonesPath $TimeStamp

New-Item $Destination -ItemType Directory | Out-Null

'Processing Zones' | Write-Host
$Zones = Get-HetznerZones
$Zones | ConvertTo-Json | Out-File (Join-Path $Destination 'zones.json' )
'Zone Count: {0}' -f $Zones.Count | Write-Host

$Zones | ForEach-Object {
    'Processing Zone: name:"{0}" id:"{1}"' -f $_.name, $_.id  | Write-Host
    $FilePath = Join-Path $Destination ('{0}.{1}.zone' -f $_.name, $_.id )
    $_ | Get-HetznerZoneFile | Out-File $FilePath
}