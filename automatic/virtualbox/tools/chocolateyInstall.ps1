﻿#https://www.virtualbox.org/manual/ch02.html#idm819

$toolsPath = Split-Path $MyInvocation.MyCommand.Definition
. $toolsPath\helpers.ps1

$cert = Get-ChildItem Cert:\CurrentUser\TrustedPublisher -Recurse | Where-Object { $_.Thumbprint -eq 'a88fd9bdaa06bc0f3c491ba51e231be35f8d1ad5' }
if (!$cert) {
    $toolsPath = Split-Path $MyInvocation.MyCommand.Definition
    Start-ChocolateyProcessAsAdmin "certutil -addstore 'TrustedPublisher' '$toolsPath\oracle.cer'"
}

$pp = Get-PackageParameters
$silentArgs = @('-s -l -msiparams REBOOT=ReallySuppress')
$silentArgs += if (!$pp.CurrentUser)      { 'ALLUSERS=1' } else { 'ALLUSERS=2';  Write-Host 'Param: Installing for current user' }
$silentArgs += if ($pp.NoDesktopShortcut) { 'VBOX_INSTALLDESKTOPSHORTCUT=0';     Write-Host 'Param: No desktop shortcut' }
$silentArgs += if ($pp.NoQuickLaunch)     { 'VBOX_INSTALLQUICKLAUNCHSHORTCUT=0'; Write-Host 'Param: No quick launch shortcut' }
$silentArgs += if ($pp.NoRegister)        { 'VBOX_REGISTERFILEEXTENSIONS=0';     Write-Host 'Param: No registration for virtualbox file extensions' }

$packageArgs = @{
  packageName            = 'virtualbox'
  fileType               = 'EXE'
  url                    = 'https://download.virtualbox.org/virtualbox/7.1.12/VirtualBox-7.1.12-169651-Win.exe'
  url64bit               = 'https://download.virtualbox.org/virtualbox/7.1.12/VirtualBox-7.1.12-169651-Win.exe'
  checksum               = 'a7691470e3dbbee6ba9fc0cc0073c9c64aa66da69c99981214a35c5fa2621f5a'
  checksum64             = 'a7691470e3dbbee6ba9fc0cc0073c9c64aa66da69c99981214a35c5fa2621f5a'
  checksumType           = 'sha256'
  checksumType64         = 'sha256'
  silentArgs             = $silentArgs
  validExitCodes         = @(0, 3010)
  softwareName           = 'Oracle VM VirtualBox *'
}
Install-ChocolateyPackage @packageArgs

$packageName = $packageArgs.packageName
$installLocation = Get-VirtualBoxIntallLocation
if (!$installLocation)  { Write-Warning "Can't find $packageName install location, can't install extension pack"; return }

if ($pp.ExtensionPack) {
    Write-Host "Installing extension pack"
    Write-Warning "*** THIS IS A COMMERCIAL EXTENSION AND CAN INCURE SIGNIFICANT FINANCIAL COSTS ***"

    $url_ep       = 'https://download.virtualbox.org/virtualbox/7.1.12/Oracle_VirtualBox_Extension_Pack-7.1.12.vbox-extpack'
    $checksum_ep  = 'c7ed97f4755988ecc05ec633475e299bbc1e0418cc3d143747a45c99df53abd3'
    $file_path_ep = (Get-PackageCacheLocation) + '\' + ($url_ep -split '/' | Select-Object -Last 1)
    Get-ChocolateyWebFile `
        -PackageName    'virtualbox-extensionpack' `
        -FileFullPath   $file_path_ep `
        -Url            $url_ep `
        -Url64bit       $url_ep `
        -Checksum       $checksum_ep `
        -Checksum64     $checksum_ep `
        -ChecksumType   'sha256' `
        -ChecksumType64 'sha256'
    if (!(Test-Path $file_path_ep)) { Write-Warning "Can't download latest extension pack" }
    else {
        Set-Alias vboxmanage $installLocation\VBoxManage.exe
        "y" | vboxmanage extpack install --replace $file_path_ep 2>&1
        if ($LastExitCode -ne 0) { Write-Warning "Extension pack installation failed with exit code $LastExitCode" }
    }
}

if (!$pp.NoPath) { Write-Host "Adding to PATH if needed"; Install-ChocolateyPath $installLocation }

Write-Host "$packageName installed to '$installLocation'"
Register-Application "$installLocation\$packageName.exe" vbox
Write-Host "$packageName registered as vbox"
