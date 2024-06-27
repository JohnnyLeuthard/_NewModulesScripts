﻿

$ModuleName     = 'MyModules'
$ModBaseFolder  = '/Users/johnnyleuthard/Clouds/OneDrive/Coding/POSHModules'
$ModuleFolder   = "$ModBaseFolder\$ModuleName"

############################
#--- Install PlatyPS
Install-Module platyPS -Force

# List of modules tO import
$ModuleList = @()
$ModuleList += $ModuleFolder
$ModuleList += 'PlatyPS'
Import-Module $ModuleList
#- OR
Clear-Host;Remove-Module $ModuleName; Import-Module $ModuleFolder

############################
Get-Module
Get-Command -Module platyPS

Clear-Host; Remove-Module $ModuleName; Import-Module $ModuleFolder  

Get-Module 
Get-Command -Module $ModuleName 

########################################################

########################################################
### Create/Modify MD files from comment based help
########################################################
$ModuleDetails  = (Get-Module $ModuleName)
$ModulePath     = $ModuleDetails.ModuleBase

#--- Help files / PlatyPS output folders
$OutputPath     = "$ModulePath\en-us"
$MDFilePath     = "$OutputPath\MD"
$XMLFilePath    = "$OutputPath\XML"


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
$AboutFileName | ForEach-Object {New-MarkdownAboutHelp -OutputFolder $MDFilePath -AboutName $_ }


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

https://www.youtube.com/watch?v=zGOl5g_AJ5U

https://www.youtube.com/watch?v=27KksfgzhuE

https://www.youtube.com/watch?v=svqPt3jEPyY



#>

