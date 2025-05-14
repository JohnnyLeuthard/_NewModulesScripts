
$DateInfo = Get-Date 
#---
$ModuleName             = 'MyModules'
#$ModuleName             = 'MyModules2'
$ModBaseFolder          = '\Users\johnnyleuthard\Clouds\OneDrive\Coding\POSHModules'
$ModuleFolder           = "$ModBaseFolder\$ModuleName"
$ModuleDescription      = 'Custom PowerShell tools'
$Author                 = 'Johnny Leuthard'

#---
$NestedModules = @()
$NestedModules += 'paPAS'
#---
$RequiredModules = @()
#$RequiredModules += 'MyModules2'
$RequiredModules += 'psPAS'
$RequiredModules += 'PlatyPS'
#$RequiredModules += 'PSScriptAnalyzer'
#$RequiredModules += 'DSC'
#$RequiredModules += 'P22EXE'
#$RequiredModules += 'PowershellGet'
#$RequiredModules += 'PoshInternals'
#---
$RequiredFilesList = @()
$RequiredFilesList += 'dummy.json'
$RequiredFilesList += '.\files\dummy2.json'
#$RequiredFilesList += '.\files\EnvironmentVariables.xml'

#------------------------------
#  Create Misc Folders
#------------------------------
If(!(Test-Path $ModuleFolder ))
{ 
    #write-Host "MOD Folder Missing" -ForegroundColor DarkYellow 
    New-Item -Path "$ModuleFolder"                      -ItemType Directory -Force | Out-Null
    New-Item -Path "$ModuleFolder\en-us"                -ItemType Directory -Force | Out-Null
    New-Item -Path "$ModuleFolder\public\Functions"     -ItemType Directory -Force | Out-Null
    New-Item -Path "$ModuleFolder\private\Functions"    -ItemType Directory -Force | Out-Null
    New-Item -Path "$ModuleFolder\classes"              -ItemType Directory -Force | Out-Null
    New-Item -Path "$ModuleFolder\files"                -ItemType Directory -Force | Out-Null 
}

#------------------------------
#  Manifest details PSD1
#------------------------------
$ManafestDetails = @{
    'RootModule'            = $ModuleName
    'Author'                = $Author
#    'NestedModules'       = $NestedModules
#    'RequiredModules'      = $RequiredModules
    'Description'           = $ModuleDescription
    'Path'                  = "$ModuleFolder\$ModuleName.psd1"
    'ModuleVersion'         = '1.0'
    'GUID'                  = (New-Guid)
    'CompanyName'           = 'Contoso'
#    'FileList'             = $RequiredFilesList
#    'ScriptsToProcess'     = '__startup.ps1'
#    'DefaultCommandPrefix'  = 'JEL'
#    'AliasesToExport'       = '*'
#    'CLRVersion'            = '4.0'
    'PowerShellVersion'    = '5.1'
    'Copyright'             = (($DateInfo.year).tostring() + ' '  + $ModuleDescription + ' by ' +  $Author)
}
New-ModuleManifest @ManafestDetails

#------------------------------
#  Create PSM1 file
#------------------------------
$PSM1FileContents = @'

# Set a Global variable (used for testing, validation, etc.)
Set-Variable -Name TestGlobalVar -Value "This is a test 1...2...3" -Scope Global

#write-Host "PSScriptRoot path is: $PSScriptRoot" -ForegroundColor Green
# Dynamicly determine Module Name
$directorySeparator = [System.IO.Path]::DirectorySeparatorChar
$moduleName = $PSScriptRoot.Split($directorySeparator)[-1]
#-- Manifest file name
$moduleManifest = $PSScriptRoot + $directorySeparator + $moduleName + '.psd1'
#-- Public functions folder path
$publicFunctionsPath    = $PSScriptRoot + $directorySeparator + 'Public' + $directorySeparator + 'Functions'
#-- Private functions folder path
$privateFunctionsPath   = $PSScriptRoot + $directorySeparator + 'Private' + $directorySeparator + 'Functions'
$currentManifest        = Test-ModuleManifest $moduleManifest

# Import Settings file  ##?? (set this to script scope not global? )
$dataPath = Join-Path -Path $PSScriptRoot -ChildPath Settings.psd1
#$global:SettingsHashtable = Import-PowerShellDataFile -Path $dataPath ##??
$script:SettingsHashtable = Import-PowerShellDataFile -Path $dataPath ##??

# Another load settings
$SettingsFile = "$PSScriptRoot\files\environmant.psd1"
$Script:ScriptSettings = Import-PowerShellDataFile -Path $SettingsFile

# Get list of PS1 files in the functions folders (files atrating with __ will be ignored)
$aliases = @()  ##??
$publicFunctions  = Get-ChildItem -Path $publicFunctionsPath -Recurse  | Where-Object { ($_.Name -notlike "__*") -and ($_.Extension -eq '.ps1')}
$privateFunctions = Get-ChildItem -Path $privateFunctionsPath -Recurse | Where-Object { ($_.Name -notlike "__*") -and ($_.Extension -eq '.ps1')}
#$publicFunctions  = Get-ChildItem -Path $publicFunctionsPath  | Where-Object {$_.Extension -eq '.ps1'}
#$privateFunctions = Get-ChildItem -Path $privateFunctionsPath | Where-Object {$_.Extension -eq '.ps1'}
#-- DOT source scripts
$PublicFunctions | ForEach-Object { . $_.FullName }
$privateFunctions | ForEach-Object { . $_.FullName }


# Export all of the public functions from this module
$publicFunctions | ForEach-Object { 

    # The command has already been sourced in above. Query any defined aliases.
    $alias = Get-Alias -Definition $_.BaseName -ErrorAction SilentlyContinue
    if ($alias) {
        $aliases += $alias
        Export-ModuleMember -Function $_.BaseName -Alias $alias
    }
    else {
        Export-ModuleMember -Function $_.BaseName
    }
}

# Get list of ublic functions/alises losted in manifest and add/remove changes
$functionsAdded     = $publicFunctions | Where-Object {$_.BaseName -notin $currentManifest.ExportedFunctions.Keys}
$functionsRemoved   = $currentManifest.ExportedFunctions.Keys | Where-Object {$_ -notin $publicFunctions.BaseName}
$aliasesAdded       = $aliases | Where-Object {$_ -notin $currentManifest.ExportedAliases.Keys}
$aliasesRemoved     = $currentManifest.ExportedAliases.Keys | Where-Object {$_ -notin $aliases}

# If there are aliases or public functions added/removed update the manifest with those changes
if ($functionsAdded -or $functionsRemoved -or $aliasesAdded -or $aliasesRemoved) {
    try {
        $updateModuleManifestParams = @{}
        $updateModuleManifestParams.Add('Path', $moduleManifest)
        $updateModuleManifestParams.Add('ErrorAction', 'Stop')
        if ($aliases.Count -gt 0) { $updateModuleManifestParams.Add('AliasesToExport', $aliases) }
        if ($publicFunctions.Count -gt 0) { $updateModuleManifestParams.Add('FunctionsToExport', $publicFunctions.BaseName) }
        # Update manifest (PSD1) file
        Update-ModuleManifest @updateModuleManifestParams
    }
    catch {
        $_ | Write-Error
    }
}

# Load classes
#". $PSScriptRoot/Clases/ClassCar.ps1"

'@
$PSM1FileContents | Out-File "$ModuleFolder/$ModuleName.psm1" -Encoding utf8 


#------------------------------
#  Create __startup.ps1
#------------------------------
<#
This file gets added to the startup scriups in the PSD1 file and get's run at module load
It looks at the required files list in the PDS1 and gives an error any of the required files do not exist.

Having prioblems with this that I believe are due to the Module folder needs to be in one of the local folders
that PowerShell looks at for modules.
#>
$StartupFileContents = @'

    #$RequiredFiles = ((Get-Module $ModuleFolder -ListAvailable).Filelist)
    $RequiredFiles  = ((Get-Module $moduleName  -ListAvailable).Filelist)  ##??
        
    $RequiredFiles | % {
        If (-not (Test-Path $_ -Pathtype Leaf)) {
            Write-Warning "****** The file [$($_)] does not exsist and is listed in the required files for this module. please correct the problem and reliad the module ****** "  
        }
    }
'@
$StartupFileContents | Out-File "$ModuleFolder\__startup.ps1" -Encoding utf8 -Force

#------------------------------
#  Create Misc Files
#------------------------------

#- Basic GIT files

#- Test public script
@'
    Function Test-ScriptPublic 
    {
        Write-Host "This is a public finction" -ForegroundColor Green
        Test-ScriptPrivate
    }
'@ | Out-File "$ModuleFolder\Public\Functions\Test-ScriptPublic.ps1" -Force

#- Test private script
@'
    Function Test-ScriptPrivate 
    {
        Write-Host "This is a PRIVATE function being called from a public function" -ForegroundColor Green
    }
'@ | Out-File "$ModuleFolder\private\Functions\Test-ScriptPrivate.ps1" -Force

#- Example class
@'

class car
{
    [string]$vin
    static [int]$numberofWheeles = 4
    [int]$NumberOfDoors
    [datetime]$year
    [string]$model
    [string]$color

    car(){}

    car($model,$year){
        $this.model = $model
        $this.year  = $year
    }

    
    paint ([string]$paint)
    {
        $this.color = $paint
        Write-Host "New car color is $paint" -ForegroundColor $paint
    }
    
}

'@ | Out-File "$ModuleFolder\classes\ClassCar.ps1" -Force

#- Example Setings
@'

    @{
        'ENVProd' = @{
            This = $true
            That = $false
        }@
        'ENVUAT' = @{
            This = $false
            That = $true
        }@

        AnotherSetting = '1234'

'@ | Out-File "$ModuleFolder\Files\settings.psd1" -Force

#--- Copy a dummy script into modules public functions folder
$BaseTempFilesPath  = "$ModBaseFolder\_NewModulesScripts"
$SourceTestFileList = @()
$SourceTestFileList += "$BaseTempFilesPath\TestPS1\Convert-EPOCHDateTime.ps1"
$SourceTestFileList += "$BaseTempFilesPath\TestPS1\ConvertTo-Object.ps1"
$SourceTestFileList += "$BaseTempFilesPath\TestPS1\Get-SPN.ps1"

$DestTestFile       = "$ModuleFolder\public\Functions"
$SourceTestFileList  | ForEach-Object {Copy-Item $_ $DestTestFile }



#------------------------------
#  Create a settings PSD1 setup
#------------------------------

@{
    # paths to important folders
    dataInPath = 'c:\data1', '\\server2\public\data'
    dataOutPath = '\\server99\public\results'
    dataLogPath = 'f:\local\log'

    # AD groups 
    dataGroups = 'Technicians', 'Testers', 'Auditors'

    # miscellaneaous settings
    dataTimeoutSeconds = 5400
    dataLogLevel = 4

    dataJohnnyTest = '1234'
} | Out-File '/Users/johnnyleuthard/Clouds/OneDrive/Coding/POSH-TEMPLATE/MyModules/settings.psd1'

#---

#------------------------------
#  Create Settings.psd1
#------------------------------
@'
@{
    # paths to important folders
    dataInPath = 'c:\data1', '\\server2\public\data'
    dataOutPath = '\\server99\public\results'
    dataLogPath = 'f:\local\log'

    # AD groups 
    dataGroups = 'Technicians', 'Testers', 'Auditors'

    # miscellaneaous settings
    dataTimeoutSeconds = 5400
    dataLogLevel = 4

    dataJohnnyTest = '1234'
} 
'@ | Out-File $ModuleFolder\Settings.psd1

#------------------------------
#  GIT Stuff
#------------------------------
<#
#-- change to the module folder
Set-Location $ModuleFolder 

#-- various MD files
New-Item -Path "$ModuleFolder\readme.MD" -ItemType File -Force | Out-Null
New-Item -Path "$ModuleFolder\TODO.MD"   -ItemType File -Force | Out-Null

#-- GitIgnore file
@'

'@ | Out-File "$ModuleFolder\.gitignore" | Out-Null

#-- setup GIT
Git init 
git add .
git commit -m "1st commit after greating Repo"

##?? Publish?

#>





##########################
### NOTES
##########################
<#

https://benheater.com/creating-a-powershell-module


#>

