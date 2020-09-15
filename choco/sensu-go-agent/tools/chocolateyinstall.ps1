$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation   = Join-Path $toolsDir "sensu-go-agent_${env:chocolateyPackageVersion}_en-US.x86.msi"
$file64Location = Join-Path $toolsDir "sensu-go-agent_${env:chocolateyPackageVersion}_en-US.x64.msi"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'msi'
  file          = $fileLocation
  file64        = $file64Location

  softwareName  = 'Sensu Agent'

  silentArgs    = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyInstallPackage @packageArgs
