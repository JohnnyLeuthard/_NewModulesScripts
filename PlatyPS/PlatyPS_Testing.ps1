Clear-Host;Remove-Module MyModule*; Import-Module '/Users/johnnyleuthard/Clouds/OneDrive/Coding/POSHModules/MyModules'

############################

$ModuleList = @()
$ModuleList += '/Users/johnnyleuthard/Clouds/OneDrive/Coding/POSHModules/MyModules'
$ModuleList += 'PlatyPS'

Import-Module $ModuleList

############################
$ModuleName = 'MyModule'
Get-Module
Get-Command -Module platyPS

Clear-Host;Remove-Module $ModuleName; Import-Module '/Users/johnnyleuthard/Clouds/OneDrive/Coding/POSHModules/MyModules'

Get-Module 
Get-Command -Module $ModuleName 

########################################################

########################################################
### Create/Modify MD files from comment based help
########################################################
$ModuleName = 'MyModules'
$ModuleDetails = (Get-Module $ModuleName)
$ModulePath = $ModuleDetails.ModuleBase

#--- Create MD files (must be loaded)
$OutputPath = "$ModulePath\en-us"
$MDFilePath = "$OutputPath\MD"
$XMLFilePath = "$OutputPath\XML"


#--- Create MD files for every function
New-MarkdownHelp -Module $ModuleName -OutputFolder $MDFilePath -Force
#**** OR ***
#- Create MD file for an individule command
New-MarkdownHelp -Command Convert-EPOCHDateTime -OutputFolder $MDFilePath -Force


#--- Update MD's
Remove-Module $ModuleList
Import-Module $ModuleList
Update-MarkdownHelp -Path $MDFilePath -Force  ##??

########################################################

########################################################
### XML help from MD files
########################################################
New-ExternalHelp -Path $MDFilePath -OutputPath $XMLFilePath -Force


########################################################
### create an about help MD file
########################################################
$AboutFileName = @()
$AboutFileName += 'DummyAboutFile'
$AboutFileName += $ModuleName 
$AboutFileName | % {New-MarkdownAboutHelp -OutputFolder $MDFilePath -AboutName $_ }


########################################################
### create an external help file (XML) from MD
########################################################
<#
    When using get-help this will override the comment based help 
    About files not included ##??

#>
#--- Only include an individual MD
New-ExternalHelp -Path "$MDFilePath\Convert-EPOCHDateTime.md" -OutputPath $OutputPath
#-- Include all MD's
New-ExternalHelp -Path "$MDFilePath" -OutputPath $OutputPath


########################################################
### 
########################################################



########################################################
### NOTES
########################################################
<#

#>

