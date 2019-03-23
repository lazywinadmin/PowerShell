function New-ScriptMessage
{
<#
	.SYNOPSIS
		Helper Function to show default message used in VERBOSE/DEBUG/WARNING

	.DESCRIPTION
		Helper Function to show default message used in VERBOSE/DEBUG/WARNING
		and... HOST in some case.
		This is helpful to standardize the output messages

	.PARAMETER Message
		Specifies the message to show

	.PARAMETER Block
		Specifies the Block where the message is coming from.

	.PARAMETER DateFormat
		Specifies the format of the date.
		Default is 'yyyy\/MM\/dd HH:mm:ss:ff' For example: 2016/04/20 23:33:46:78

	.PARAMETER FunctionScope
		Valid values are "Global", "Local", or "Script", or a number relative to the current scope (0 through the number of scopes, where 0 is the current scope and 1 is its parent). "Local" is the default

		See also: About_scopes https://technet.microsoft.com/en-us/library/hh847849.aspx

		Example:
		0 is New-ScriptMessage
		1 is the function calling New-ScriptMessage
		2 is for example the script/function calling the function which call New-ScriptMessage
		etc...

	.EXAMPLE
		New-ScriptMessage -Message "Francois-Xavier" -Block PROCESS -Verbose -FunctionScope 0

		[2016/04/20 23:33:46:78][New-ScriptMessage][PROCESS] Francois-Xavier

	.EXAMPLE
		New-ScriptMessage -message "Connected"

		if the function is just called from the prompt you will get the following output
		[2015/03/14 17:32:53:62] Connected

	.EXAMPLE
		New-ScriptMessage -message "Connected to $Computer" -FunctionScope 1

		If the function is called from inside another function,
		It will show the name of the function.
		[2015/03/14 17:32:53:62][Get-Something] Connected

	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
#>

	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[String]$Message,
		[String]$Block,
		[String]$DateFormat = 'yyyy\/MM\/dd HH:mm:ss:ff',
		$FunctionScope = "1"
	)

	PROCESS
	{
		$DateFormat = Get-Date -Format $DateFormat
		$MyCommand = (Get-Variable -Scope $FunctionScope -Name MyInvocation -ValueOnly).MyCommand.Name
		IF ($MyCommand)
		{
			$String = "[$DateFormat][$MyCommand]"
		} #IF
		ELSE
		{
			$String = "[$DateFormat]"
		} #Else

		IF ($PSBoundParameters['Block'])
		{
			$String += "[$Block]"
		}
		Write-Output "$String $Message"
	} #Process
}
