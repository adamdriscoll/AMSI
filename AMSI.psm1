$Script:AmsiContext = [IntPtr]::Zero

$NativeMethodCode = Join-Path $PSScriptRoot 'NativeMethods.cs'
Add-Type (Get-Content $NativeMethodCode -Raw)

function Initialize-Amsi {
	<#
		.SYNOPSIS 
			Initializes the Antimalware Scan Interface API for this process. 
		.PARAMETER appName
			The name, version, or GUID string of the app calling the AMSI API.
	#>
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
	<#
		.SYNOPSIS
			Remove the instance of the AMSI API that was originally opened by Initialize-Amsi.
	#>
	[Amsi.NativeMethods]::AmsiUninitialize($Script:AmsiContext)
	$Script:AmsiContext = [IntPtr]::Zero
}

function New-AmsiSession {
	<#
		.SYNOPSIS
			Opens a session within which multiple scan requests can be correlated.
	#>
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
	<#
		.SYNOPSIS
			Close a session that was opened by New-AmsiSession.
	#>
	param(
		[Parameter(Mandatory)]$Session
	)

	[Amsi.NativeMethods]::AmsiCloseSession($Script:AmsiContext, [ref]$Session)
}

function Test-AmsiString {
	<#
		.SYNOPSIS
			Scans a string for malware.
		.PARAMETER string
			The string to scan for malware.
		.PARAMETER contentName
			The filename, URL, unique script ID, or similar of the content being scanned.
		.PARAMETER session
			If multiple scan requests are to be correlated within a session, set session to the value returned by New-AmsiSession.
	#>
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

