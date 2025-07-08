﻿$toolsPath = Split-Path $MyInvocation.MyCommand.Definition
. $toolsPath\helpers.ps1

$version = '138.0.7204.101'
if ($version -eq (Get-ChromeVersion)) {
  Write-Host "Google Chrome $version is already installed."
  return
}

$packageArgs = @{
  packageName            = 'googlechrome'
  fileType               = 'MSI'
  url                    = 'https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise.msi'
  url64bit               = 'https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi'
  checksum               = '39a290a7eff6c099ce7257cbf84519800f3a27c54141f8e1e9ada44c0e2d3553'
  checksum64             = 'a278de734b2e1573d2220f9b7a01610532fb89c364fa78294a0b3bdb1d8f0320'
  checksumType           = 'sha256'
  checksumType64         = 'sha256'
  silentArgs             = "/quiet /norestart /l*v `"$($env:TEMP)\$($env:chocolateyPackageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
  validExitCodes         = @(0)
}

if (Get-Chrome32bitInstalled) { 'url64bit', 'checksum64', 'checksumType64' | ForEach-Object { $packageArgs.Remove($_) } }
Install-ChocolateyPackage @packageArgs
