#REQUIRES -RunAsAdministrator

Function POSH_Template
{
<#
.SYNOPSIS
	Short description
.DESCRIPTION
	Long description

.PARAMETER Name
.PARAMETER ID

	
.EXAMPLE
	<example usage>
	Explanation of what the example does

.INPUTS
	Inputs (if any)
.OUTPUTS
	Output (if any)
.LINK

.FUNCTIONALITY

.NOTES
	Author: Johnny Leuthard

	
#>
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='None',ConfirmImpact = 'High')]
	param 
	(
		[Parameter(Mandatory,ParameterSetName = 'ByName')]
		[Parameter(Mandatory,ParameterSetName = 'None',HelpMessage = "Enter the Name you want to use")]
		[ValidateCount(1, 5)]
		[Alias("Name")]
			[string[]]$UserName,
		

		[Parameter(Mandatory,ParameterSetName = 'ById')]
		[ValidateNotNullOrEmpty()]
			[string]$Id,


		[Parameter(Mandatory,ParameterSetName = 'ComputerName')]
		[Parameter(Mandatory,ParameterSetName = 'None')]
		[Alias("computer","Host")]
			[string[]]$ComputerName,


		[Parameter(ParameterSetName = 'ByName',HelpMessage = "Enter a count number")]
		[Parameter(ParameterSetName = 'ById')]
		[ValidateNotNullOrEmpty()]
		[ValidateRange(1, 5)]
			[int]$Count = 1,
	
		[Parameter()]
		[ValidateNotNull()]
		[ValidateRange(512MB, 1024MB)]
			[int]$MemoryStartupBytes,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[ValidateSet('1', '2')]
			[int]$Generation = 2,
		
		[Parameter(ParameterSetName = 'ByName',HelpMessage = "Enter the folder path")]
		[Parameter(ParameterSetName = 'ById')]
		[ValidatePattern('^D:\\')]
		[ValidateScript({if (-not (test-path -path $_)){throw "The folder [$_] does not exist. pleae try another."}else{$true}})]
			[string]$Path = 'C:\somebogusfolder',
		
		[Parameter()]
		[AllowNull()]
			[string]$OperatingSystem,
		
		[Parameter(Mandatory)]
		[ValidateNotNull()]
		[string]$NullParamTest,

        [Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$NullEmptyParamTest,
		
		[Parameter()]
		[AllowNull()]
		[string]$AllowNullParam
	)
	Begin {

		# Create a file?
		# Do something just once
		Write-Debug "Begin section reached"
	}
	Process {

		write-Debug "Process section reached"
		if ($PSCmdlet.ParameterSetName -eq 'ById')
		{
			Write-Host "You're using the $($PSCmdlet.ParameterSetName)  parameter set by using the Id parameter [$($Id)]"
		}
		elseif ($PSCmdlet.ParameterSetName -eq 'ByName')
		{
			Write-Host "You're using the ByName parameter set by using the Name parameter [$($Name)]"	
		}

		Write-Verbose "This is a verbose message"
		Write-Debug "This is a debug message used with the -debug switch"



	}#(Pocess)
	End {
		write-debug "END section reached"

		Write-Output $someData

	}#(End)

}
#####################################
### NOTES
#####################################
<#

POSH_Template -debug


#>

