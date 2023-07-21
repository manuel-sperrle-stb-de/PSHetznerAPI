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
        $Body,

        [switch]
        $Paged

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

        if (-not $Paged) {
            $Query | ForEach-Object {
                $RestMethodParams.Uri = '{0}/{1}' -f $BaseUri.TrimEnd('/'), $_.TrimStart('/')
                Invoke-RestMethod @RestMethodParams
            }
        }
        else {

            $Page = 1
            do {

                $RestMethodParams.Uri = '{0}/{1}?page={2}' -f $BaseUri.TrimEnd('/'), $_.TrimStart('/'), $Page
                
                try { 
                    $Answer = Invoke-RestMethod @RestMethodParams -ErrorAction Stop
                }
                catch {
                    $Answer = $null
                    $Finished = $true
                }
                finally {
                    if ($Answer) {
                        $Answer
                        $Page++
                    }
                    else {
                        $Finished = $true
                    }
                }
            }
            until ($Finished)
        }       
    }
}