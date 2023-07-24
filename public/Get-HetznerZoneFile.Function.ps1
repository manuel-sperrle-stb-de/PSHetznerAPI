function Get-HetznerZoneFile {

    [CmdletBinding()]
    param (

        # The Hetzner Zone Id
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $Id,

        # The Base Uri/URL used - example: 'https://dns.hetzner.com/api/v1'
        [Parameter(Mandatory)]
        [string]
        $BaseUri,

        # The AuthAPIToken used - example: '12345678901234567890123456789012'
        [Parameter(Mandatory)]
        [string]
        $AuthAPIToken

    )
 
    process {

        $Id | ForEach-Object {
            "zones/{0}/export" -f $_ | Invoke-RestMethod-Hetzner -ContentType 'application/x-www-form-urlencoded; charset=utf-8'
        }
    
    }   

}