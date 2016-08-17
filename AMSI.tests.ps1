if ($ENV:AppVEYOR -eq 'true')
{
	Write-Warning "Unable to run these tests on AppVeyor since these tests require Windows 10 or Windows Server 2016."
	return
}

$ENV:APPVEYOR_BUILD_VERSION = '99.99'
. (Join-Path $PSScriptRoot 'CreateModuleManifest.ps1')
$ModulePath = Join-Path $PSScriptRoot 'AMSI.psd1' 
Import-Module $ModulePath -Force 

Describe "Test-AmsiString" {
	Context "Script contains no malware" {
		It "Should return false" {
			Test-AmsiString 'Get-Process' | Should be $false
		}
	}

	Context "Script contains malware" {
		It "Should return true" {
			Test-AmsiString 'Invoke-Expression [System.TExt.Encoding]::Unicode.GetString([Convert]::FromBase64String("SDFSEUHRSHFKEH"))"' | Should be $true
		}
	}
}