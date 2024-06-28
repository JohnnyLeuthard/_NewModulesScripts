
$DateInfo = Get-Date 
#---
$ModuleName             = 'MyModules'
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

# Use this to manualy test. Should use $PSSCriptRoot but this can override for testing
$TestingFolder = $PSScriptRoot
#$TestingFolder = '/Users/johnnyleuthard/Clouds/OneDrive/Coding/POSHModules/MyModules'

# Dynamicly determine Module Name
$directorySeparator     = [System.IO.Path]::DirectorySeparatorChar
$moduleName             = $TestingFolder.Split($directorySeparator)[-1]
#-- Manifest file name
$moduleManifest         = $TestingFolder + $directorySeparator + $moduleName + '.psd1'
#-- Public functions folder path
$publicFunctionsPath    = $TestingFolder + $directorySeparator + 'Public' + $directorySeparator + 'Functions'
#-- Private functions folder path
$privateFunctionsPath   = $TestingFolder + $directorySeparator + 'Private' + $directorySeparator + 'Functions'
$currentManifest        = Test-ModuleManifest $moduleManifest

# Get list of PS1 files in the functions folders (files atrating with __ get ignored)
$aliases = @()  ##??
$publicFunctions  = Get-ChildItem -Path $publicFunctionsPath -Recurse  | Where-Object { ($_Name -notlike "__*") -and ($_.Extension -eq '.ps1')}
$privateFunctions = Get-ChildItem -Path $privateFunctionsPath -Recurse | Where-Object { ($_Name -notlike "__*") -and ($_.Extension -eq '.ps1')}
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

# If there are aliases or public functions added/removed update the manifest
if ($functionsAdded -or $functionsRemoved -or $aliasesAdded -or $aliasesRemoved) {

    try {

        $updateModuleManifestParams = @{}
        $updateModuleManifestParams.Add('Path', $moduleManifest)
        $updateModuleManifestParams.Add('ErrorAction', 'Stop')
        if ($aliases.Count -gt 0) { $updateModuleManifestParams.Add('AliasesToExport', $aliases) }
        if ($publicFunctions.Count -gt 0) { $updateModuleManifestParams.Add('FunctionsToExport', $publicFunctions.BaseName) }

        Update-ModuleManifest @updateModuleManifestParams
    }
    catch {
        $_ | Write-Error
    }
}

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


#------------------------------
#  Misc stuff
#------------------------------

#--- Copy a dummy script into modules public functions folder
$BaseTempFilesPath  = "$ModBaseFolder\_NewModulesScripts"
$SourceTestFileList = @()
$SourceTestFileList += "$BaseTempFilesPath\TestPS1\Convert-EPOCHDateTime.ps1"
$SourceTestFileList += "$BaseTempFilesPath\TestPS1\ConvertTo-Object.ps1"
$SourceTestFileList += "$BaseTempFilesPath\TestPS1\Get-SPN.ps1"

$DestTestFile       = "$ModuleFolder\public\Functions"
$SourceTestFileList  | ForEach-Object {Copy-Item $_ $DestTestFile }

#---


#------------------------------
#  GIT Stuff
#------------------------------
<#

New-Item -Path "$ModuleFolder\readme.MD" -ItemType File -Force | Out-Null
New-Item -Path "$ModuleFolder\TODO.MD"   -ItemType File -Force | Out-Null

Set-Location $ModuleFolder 
Git init 
New-Item -Path "$ModuleFolder\.gitignore"   -ItemType File -Force | Out-Null
git add .
git commit -m "1st commit after greating Repo"

#>



##########################
### NOTES
##########################
<#

https://benheater.com/creating-a-powershell-module


#>

