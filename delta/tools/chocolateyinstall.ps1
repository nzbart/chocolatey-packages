$ErrorActionPreference = 'Stop'; # stop on all errors

$toolsDir = Split-Path -parent $MyInvocation.MyCommand.Definition
$workingDir = Join-Path $toolsDir "extract"
$packageArgs = @{
  PackageName = $env:ChocolateyPackageName
  FileFullPath64 = Get-Item $toolsDir\*.zip
  Destination = $workingDir
}

Get-ChocolateyUnzip @packageArgs
$extractedBinaryPath = Get-ChildItem -r $workingDir -fi delta.exe | Select-Object -expand FullName
Move-Item $extractedBinaryPath $toolsDir
Remove-Item -r -fo $workingDir
