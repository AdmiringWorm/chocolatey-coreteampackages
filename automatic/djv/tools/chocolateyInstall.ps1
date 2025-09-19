﻿$ErrorActionPreference = 'Stop';

$toolsPath = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

if ((Get-OSArchitectureWidth 32) -or $env:chocolateyForceX86 -eq $true)
  { Write-Error "32-bit is no longer supported. Please install version 1.0.5.20170203" }

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'exe'
  file           = "$toolsPath\DJV-3.1.1-Windows-AMD64.exe"
  softwareName   = 'djv-*'
  silentArgs     = '/S'
  validExitCodes = @(0)
}

Install-ChocolateyInstallPackage @packageArgs

Get-ChildItem $toolsPath\*.exe | ForEach-Object { Remove-Item $_ -ea 0; if (Test-Path $_) { Set-Content "$_.ignore" '' } }
