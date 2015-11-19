function Set-SCCMClientCacheSize
{
	PARAM($ComputerName)
	$Cache = Get-WmiObject -Namespace ‘ROOT\CCM\SoftMgmtAgent’ -Class CacheConfig -ComputerName $ComputerName
	$Cache.Size = ‘10240’
	$Cache.Put()
	Get-Service -ComputerName $ComputerName -Name 'ccmexec'| Restart-Service -Name CcmExec
}