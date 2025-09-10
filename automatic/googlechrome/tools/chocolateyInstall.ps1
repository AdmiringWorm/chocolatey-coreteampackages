﻿$toolsPath = Split-Path $MyInvocation.MyCommand.Definition
. $toolsPath\helpers.ps1

$version = '140.0.7339.128'
if ($version -eq (Get-ChromeVersion)) {
  Write-Host "Google Chrome $version is already installed."
  return
}

$packageArgs = @{
  packageName            = 'googlechrome'
  fileType               = 'MSI'
  url                    = 'https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise.msi'
  url64bit               = 'https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi'
  checksum               = 'ff5127ffbe17399441adf8cf01d0bf8a5537386e0d2362bc8816281503d99476'
  checksum64             = 'c5aadc8ba54a2df4c9668ac7d0b1732d9f7a7bc1186fbd8f37f46fb35264d479'
  checksumType           = 'sha256'
  checksumType64         = 'sha256'
  silentArgs             = "/quiet /norestart /l*v `"$($env:TEMP)\$($env:chocolateyPackageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
  validExitCodes         = @(0)
}

if (Get-Chrome32bitInstalled) { 'url64bit', 'checksum64', 'checksumType64' | ForEach-Object { $packageArgs.Remove($_) } }
Install-ChocolateyPackage @packageArgs
