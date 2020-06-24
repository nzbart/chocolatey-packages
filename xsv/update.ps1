import-module au

$releases = 'https://github.com/BurntSushi/xsv/releases'

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
    $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing

    $url = $download_page.links | 
        Where-Object href -match 'xsv-.*-x86_64-pc-windows-msvc.zip$' | 
        Select-Object -First 1 -expand href | 
        ForEach-Object { 'https://github.com' + $_ }

    $version  = $url -split '/' | Select-Object -Last 1 -Skip 1

    @{
        Version      = $version
        URL64        = $url
        ReleaseNotes = "$releases/tag/${version}"
    }
}

update -ChecksumFor none
