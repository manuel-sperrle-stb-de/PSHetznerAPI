Function Invoke-RestMethod-Hetzner {
# https://dns.hetzner.com/api-docs/

    [CmdletBinding()]
    param (     

        # The query itself - example: 'zones'
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]
        $Query,
        
        # The Base Uri/URL used - example: 'https://dns.hetzner.com/api/v1'
        [Parameter(Mandatory)]
        [string]
        $BaseUri,

        # The AuthAPIToken used - example: '12345678901234567890123456789012'
        [Parameter(Mandatory)]
        [string]
        $AuthAPIToken,

        # -eq Invoke-RestMethod
        [string]
        $ContentType = 'application/json',

        # -eq Invoke-RestMethod
        [string]
        $Method = 'GET',

        # -eq Invoke-RestMethod
        [object]
        $Body

    )

    begin {

        $RestMethodParams = @{
            Method  = $Method            
            Headers = @{
                'Auth-API-Token' = $AuthAPIToken
                'Content-Type'   = $ContentType
            }
            Body    = $Body
        }

    }

    process {

        $Query | ForEach-Object {

            $RestMethodParams.Uri = '{0}/{1}' -f $BaseUri.TrimEnd('/'), $Query.TrimStart('/')
            
            $Page = 1
            do {
                
                $ThisRestMethodParams = $RestMethodParams.Clone()
                $ThisRestMethodParams.Uri = $ThisRestMethodParams.Uri + "?page=$Page"

                try {
                    # API will Error if pages is too high
                    $Answer = Invoke-RestMethod @ThisRestMethodParams -ErrorAction Stop
                }
                catch {
                    # tbd: catch/handle errors
                    $Finished = $true
                    $Answer = $false
                }
                finally {
                    if (-not $Answer) { $Finished = $true }
                    $Answer
                }
                
                $Page++

            } until ($Finished)

        }

    }

}