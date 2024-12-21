Import-Module Chocolatey-AU
Import-Module "$PSScriptRoot\..\..\scripts\au_extensions.psm1"

$domain = 'https://inkscape.org'

function global:au_BeforeUpdate {
  Get-RemoteFiles -Purge -NoSuffix
}

function global:au_SearchReplace {
  @{
    ".\legal\VERIFICATION.txt"      = @{
      "(?i)(^\s*location on\:?\s*)\<.*\>" = "`${1}<$($Latest.UpdateUrl)>"
      "(?i)(\s*64\-Bit Software.*)\<.*\>" = "`${1}<$($Latest.URL64)>"
      "(?i)(^\s*checksum\s*type\:).*"     = "`${1} $($Latest.ChecksumType64)"
      "(?i)(^\s*checksum64\:).*"          = "`${1} $($Latest.Checksum64)"
    }
    ".\tools\chocolateyInstall.ps1" = @{
      "(?i)(^\s*file64\s*=\s*`"[$]toolsPath\\).*" = "`${1}$($Latest.FileName64)`""
      "(?i)(DisplayVersion\s*-eq\s*)'.*'"         = "`${1}'$($Latest.RemoteVersion)'"
    }
    "$($Latest.PackageName).nuspec" = @{
      "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$($Latest.ReleaseNotes)`$2"
    }
  }
}

function global:au_GetLatest {
  $redirUrl = Get-RedirectedUrl "$domain/release/"

  $version = $redirUrl -split '\/(inkscape-)?' | Select-Object -last 1 -skip 1

  try {
    $64bit_page = Invoke-WebRequest "$redirUrl/windows/64-bit/msi/dl/" -UseBasicParsing
  }
  catch {
    throw "Failed to download 32bit or 64bit executeble. Throwing minimized error to allow gist to be updated."
  }

  $re = '\.msi$'
  $url64 = $64bit_page.links | Where-Object href -match $re | Select-Object -first 1 -expand href | ForEach-Object { $domain + $_ }

  @{
    Version       = $version
    RemoteVersion = $version
    URL64         = $url64
    ReleaseNotes  = $redirUrl + "#left-column"
    UpdateUrl     = $redirUrl + "windows"
    PackageName   = 'InkScape'
  }
}

update -ChecksumFor none
