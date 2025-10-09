﻿$ErrorActionPreference = 'Stop';

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe'
  url           = 'https://julialang-s3.julialang.org/bin/winnt/x86/1.12/julia-1.12.0-win32.exe'
  checksum      = '4C0371F054A67022A2235B2160B124B4EE620CA419617130E5AE3646501299E9'
  checksumType  = 'sha256'
  file64        = "$toolsDir\julia-1.12.0-win64.exe"

  softwareName  = 'Julia*'

  silentArgs    = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
  validExitCodes= @(0)
}
$packageVersion = "1.12.0"

if ((Get-OSArchitectureWidth -compare 32) -or ($env:chocolateyForceX86 -eq $true)) {
    Install-ChocolateyPackage @packageArgs
}
else {
    Install-ChocolateyInstallPackage @packageArgs
}

# Lets remove the installer as there is no more need for it
Get-ChildItem $toolsDir\*.exe | ForEach-Object { Remove-Item $_ -ea 0; if (Test-Path $_) { Set-Content "$_.ignore" '' } }

# Find the executable of current installed version
[array]$keysCurrentVersion = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName'] | Where-Object {
  ($_.DisplayName -split "\s+" | Select-Object -last 1) -eq $packageVersion
}

if ($keysCurrentVersion.Count -eq 0)  { Write-Warning "Can't find Julia install location"; return }
$executableLocation = $($keysCurrentVersion | Select-Object -First 1).DisplayIcon
Write-Host "Julia installed to '$executableLocation'"

Install-BinFile 'julia' $executableLocation
