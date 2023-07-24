function Get-HetznerZones {

    [CmdletBinding()]
    param (

        # The Base Uri/URL used - example: 'https://dns.hetzner.com/api/v1'
        [Parameter(Mandatory)]
        [string]
        $BaseUri,

        # The AuthAPIToken used - example: '12345678901234567890123456789012'
        [Parameter(Mandatory)]
        [string]
        $AuthAPIToken

    )
    
    ("zones" | Invoke-RestMethod-Hetzner -Paged).zones

}