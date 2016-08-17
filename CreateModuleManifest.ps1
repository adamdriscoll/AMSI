$FunctionsToExport = @(
'Initialize-Amsi',
'Uninitialize-Amsi',
'New-AmsiSession',
'Remove-AmsiSession',
'Test-AmsiString')

$NewModuleManifestParams = @{
	ModuleVersion = $ENV:APPVEYOR_BUILD_VERSION
	Path = (Join-Path $PSScriptRoot '.\AMSI.psd1')
	Author = 'Adam Driscoll'
	Company = 'Adam Driscoll'
	Description = 'PowerShell wrapper for the Antimalware Scan Interface'
	RootModule = 'AMSI.psm1'
	FunctionsToExport = $FunctionsToExport
	ProjectUri = 'https://github.com/adamdriscoll/amsi'
	Tags = @('AMSI', 'Antimalware Scan Interface')
}

New-ModuleManifest @NewModuleManifestParams