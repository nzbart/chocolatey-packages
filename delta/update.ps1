Import-Module Chocolatey-AU

$releasesApi = 'https://api.github.com/repos/dandavison/delta/releases/latest'

function global:au_SearchReplace {
   @{
        "$($Latest.PackageName).nuspec" = @{
            "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$($Latest.ReleaseNotes)`$2"
        }

        ".\legal\VERIFICATION.txt" = @{
          "(?i)(\s+x64:).*"            = "`${1} $($Latest.URL64)"
          "(?i)(checksum64:).*"        = "`${1} $($Latest.Checksum64)"
          "(?i)(Get-RemoteChecksum).*" = "`${1} $($Latest.URL64)"
        }
    }
}

function global:au_BeforeUpdate { Get-RemoteFiles -Purge }

function global:au_GetLatest {
    # The releases HTML page lazy-loads its assets, so query the API instead.
    $headers = @{}
    if ($Env:github_api_key) { $headers.Authorization = "token $Env:github_api_key" }
    $release = Invoke-RestMethod -Uri $releasesApi -Headers $headers -UseBasicParsing

    $url = $release.assets |
        Where-Object name -match '^delta-.*-x86_64-pc-windows-msvc\.zip$' |
        Select-Object -First 1 -ExpandProperty browser_download_url
    if (!$url) { throw "No delta-*-x86_64-pc-windows-msvc.zip asset in release $($release.tag_name)" }

    @{
        Version      = $release.tag_name -replace '^v', ''
        URL64        = $url
        ReleaseNotes = $release.html_url
    }
}

update -ChecksumFor none