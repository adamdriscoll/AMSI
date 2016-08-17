$Script:AmsiContext = [IntPtr]::Zero

$NativeMethodCode = Join-Path $PSScriptRoot 'NativeMethods.cs'
Add-Type (Get-Content $NativeMethodCode -Raw)

function Initialize-Amsi {
	param(
		[Parameter(Mandatory)]
		[string]
		$appName
	)

	$ret = [Amsi.NativeMethods]::AmsiInitialize($appName, [ref]$Script:AmsiContext)
	if ($ret -ne 0)
	{
		throw (New-Object System.ComponentModel.Win32Exception -ArgumentList $ret)
	}
}

function Unitialize-Amsi {
	[Amsi.NativeMethods]::AmsiUninitialize($Script:AmsiContext)
	$Script:AmsiContext = [IntPtr]::Zero
}

function New-AmsiSession {
	$Session = [IntPtr]::Zero
	$ret = [Amsi.NativeMethods]::AmsiOpenSession($Script:AmsiContext, [ref]$Session)
	if ($ret -ne 0)
	{
		throw (New-Object System.ComponentModel.Win32Exception -ArgumentList $ret)
	}
	else
	{
		$Session
	}
}

function Remove-AmsiSession {
	param(
		[Parameter(Mandatory)]$Session
	)

	[Amsi.NativeMethods]::AmsiCloseSession($Script:AmsiContext, [ref]$Session)
}

function Test-AmsiString {
	param(
		[Parameter(Mandatory)]
		[string]$string,
		[Parameter()]
		[string]$contentName = 'PowerShellScript',
		[Parameter()]
		[IntPtr]$session = [IntPtr]::Zero
	)

	$internallyInitialized = $false
	if ($Script:AmsiContext -eq [IntPtr]::Zero)
	{
		Initialize-Amsi -appName "PowerShell:$PID"
		$internallyInitialized = $true
	}

	[AMSI.AMSI_RESULT]$Result = 0
	$ret = [Amsi.NativeMethods]::AmsiScanString($Script:AmsiContext, $string, $contentName, $session, [ref]$Result)
	if($ret -ne 0)
	{
		throw (New-Object System.ComponentModel.Win32Exception -ArgumentList $ret)
	}

	#Any return result equal to or larger than 32768 is considered malware, and the content should be blocked. 
	if ($Result -ge 32768)
	{
		$true
	}
	else
	{
		$false 
	}

	if ($internallyInitialized)
	{
		Unitialize-Amsi
	}
}

