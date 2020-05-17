$ErrorActionPreference = 'Stop'; # stop on all errors

$toolsDir = Split-Path -parent $MyInvocation.MyCommand.Definition
$workingDir = Join-Path $toolsDir "extract"
$packageArgs = @{
  PackageName = $env:ChocolateyPackageName
  FileFullPath64 = Get-Item $toolsDir\*.zip
  Destination = $workingDir
}

Get-ChocolateyUnzip @packageArgs
Get-ChildItem -r $workingDir -fi delta.exe | Move-Item .
Remove-Item -r -fo $workingDir