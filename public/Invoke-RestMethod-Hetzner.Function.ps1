# https://dns.hetzner.com/api-docs/
Function Invoke-RestMethod-Hetzner {

    [CmdletBinding()]
    param (     

        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]
        $Query,
        
        [Parameter(Mandatory)]
        [string]
        $BaseUri,

        [Parameter(Mandatory)]
        [string]
        $AuthAPIToken,

        [string]
        $ContentType = 'application/json',

        [string]
        $Method = 'GET'

    )

    begin {

        $RestMethodParams = @{
            Method      = $Method            
            Headers     = @{
                'Auth-API-Token' = $AuthAPIToken
                'Content-Type'   = $ContentType
            }
        }

    }

    process {

        $Query | ForEach-Object {

            #[Collections.Generic.List[object]]$Return = @()

            $RestMethodParams.Uri = '{0}/{1}' -f $BaseUri.TrimEnd('/'), $Query.TrimStart('/')
            # API will Error if pages is too high        
            
            $Page = 1
            do {
                
                $ThisRestMethodParams = $RestMethodParams.Clone()
                $ThisRestMethodParams.Uri = $ThisRestMethodParams.Uri + "?page=$Page"

                try {
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