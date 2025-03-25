﻿$ErrorActionPreference = 'Stop'

$fallbackUrl32 = 'https://download.gimp.org/gimp/v3.0/windows/gimp-3.0.2-setup.exe'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'exe'
  url            = 'https://download.gimp.org/gimp/v3.0/windows/gimp-3.0.2-setup.exe'
  softwareName   = 'GIMP'
  checksum       = '7a5eca6cc9cf6cf68b7e674eecf879afc13e657ef59fb7742093a05e9998ffa5'
  checksumType   = 'sha256'
  silentArgs     = "/VERYSILENT /NORESTART /RESTARTEXITCODE=3010 /SUPPRESSMSGBOXES /SP- /LOG=`"$($env:TEMP)\$($env:chocolateyPackageName).$($env:chocolateyPackageVersion).InnoInstall.log`""
  validExitCodes = @(0)
}

Try {
    Get-WebHeaders -Url $packageArgs.url
} Catch {
    Write-Warning "The mirror URL is not available, falling back to the main site"
    $packageArgs.url = $fallbackUrl32
}

Install-ChocolateyPackage @packageArgs
