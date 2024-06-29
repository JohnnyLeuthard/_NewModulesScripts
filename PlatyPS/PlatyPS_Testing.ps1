

$ModuleName     = 'MyModules'
$ModBaseFolder  = '/Users/johnnyleuthard/Clouds/OneDrive/Coding/POSHModules'
$ModuleFolder   = "$ModBaseFolder\$ModuleName"

Set-Location $ModuleFolder
########################################################
# Install PlatyPS
########################################################
<#
Only needs to be run once and can be instlled by scope as well
#>
Install-Module platyPS -Force


########################################################
# List of modules to import
########################################################
$ModuleList = @()
$ModuleList += $ModuleFolder
$ModuleList += 'PlatyPS'

Import-Module $ModuleList
#- OR
Clear-Host;Remove-Module $ModuleName; Import-Module $ModuleFolder

Get-Module 
############################
Get-Module
Get-Command -Module platyPS

Clear-Host; Remove-Module $ModuleName; Import-Module $ModuleFolder  
Get-Module 
Get-Command -Module $ModuleName 



########################################################
### Create/Modify MD files from comment based help
########################################################
<#
    Module may need to be loaded 1st if it is not in one the default module folders
#>
# $ModuleDetails  = (Get-Module -ListAvailable $ModuleName)
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
New-MarkdownHelp -Command Get-SPN -OutputFolder $MDFilePath -Force



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
### Update MD help files  *******
########################################################
Remove-Module $ModuleName
Import-Module $ModuleFolder
Get-Module

Update-MarkdownHelp -Path $MDFilePath -Force  ##??
# OR a single file
Update-MarkdownHelp -Path "$MDFilePath\Get-SPN.md"
Update-MarkdownHelp -Path "$MDFilePath\Convert-EPOCHDateTime.md"



########################################################
### create an master external help file  (XML) from MD
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

# PlatyPS: PowerShell Help meets Markdown by Sergei Vorobev ****
https://www.youtube.com/watch?v=zGOl5g_AJ5U

# Build Beautiful Documentation with platyPS and Material for MkDocs by Josh Hendricks
https://www.youtube.com/watch?v=27KksfgzhuE

# Build Beautiful Docs using PlatyPS and MKDocs with Josh Hendricks
https://www.youtube.com/watch?v=svqPt3jEPyY

# MD Schema
https://github.com/PowerShell/platyPS/blob/master/platyPS.schema.md


#>

