﻿$ErrorActionPreference = 'Stop'

$packageArgs = @{
  packageName    = $env:chocolateyPackageName
  fileType       = 'EXE'
  url            = 'https://lockhunter.com/assets/exe/lockhuntersetup_3-4-3.exe'
  checksum       = '02F738111A7EF929B8017277109FF3CB188ED0896FA385B79205DA888AFA266D'
  checksumType   = 'sha256'
  silentArgs     = "/VERYSILENT /NORESTART /SUPPRESSMSGBOXES /SP- /LOG=`"$($env:TEMP)\$($env:chocolateyPackageName).$($env:chocolateyPackageVersion).InnoInstall.log`""
  validExitCodes = @(0)
  softwareName   = 'LockHunter*'
}
Install-ChocolateyPackage @packageArgs

$packageName = $packageArgs.packageName
$installLocation = Get-AppInstallLocation $packageArgs.softwareName
if (!$installLocation) { Write-Warning "Can't find $packageName install location"; return }
Write-Host "$packageName installed to '$installLocation'"

Register-Application "$installLocation\$packageName.exe"
Write-Host "$packageName registered as $packageName"

Install-BinFile $packageName "$installLocation\$packageName.exe"
