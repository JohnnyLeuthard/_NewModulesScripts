
Function Get-SPN
{
<# 

	.Synopsis
        Get SPN of a server or list of servers
	.Description
		Get Service Principal Names (SPN) of a server or list of servers.
   
   
	.Example
        get-spn
		
		Gets the SPN of the current computer
        
	
	.Example
		Get-SPN Server1
		or
        Get-SPN -ComputerName Server1
        
		Gets the SPN's of a server names Server1

	.Example
		$ServerList | Get-SPN
		

		Gets the SPN's of a list of servers contained in the variable names $ServerList
        
	.Example
		Get-Content "C:\Temp\Servers.txt" | Get-SPN
		
 
		Gets the SPN's of a list of servers contained in the text file C:\Temp\Servers.txt
        

	.Example
		Get-Content "C:\Temp\Servers.txt" | Get-SPN | Export-Csv -NoTypeInformation "C:\Temp\SPNData.csv"

		Gets the SPN's of a list of servers contained in the text file C:\Temp\Servers.txt 
        Then exports it to the CSV file C:\Temp\SPNData.csv

	.Example
		Get-Content "C:\Temp\Servers.txt" | Get-SPN | Export-Clixml  "C:\Temp\SPNData.xml"
		
		Gets the SPN's of a list of servers contained in the text file C:\Temp\Servers.txt 
        Then exports it to the XML file C:\Temp\SPNData.xml
    
    .LINK
        https://github.com/JohnnyLeuthard/MyModules/blob/main/en-us/MD/Get-SPN.md
        
    .Notes
		Author: Johnny Leuthard

#>    
    [CmdletBinding()]
	Param 
   	(
        [Parameter(ValueFromPipeline,Position=0)]
		$ComputerName = $env:ComputerName
        
	)
    begin
    {
        
        #Get a list of domains in the forest
        $GetDomains = ([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest() ).Domains | select -ExpandProperty Name 
        #Loop through domains and build LDAP query
        $DomainList = @()
        foreach ($i in  $GetDomains)
        {  $DomainList += ("LDAP://DC=" + ($i).replace(".",",DC=")) }

        
    }#begin
    Process
    {
            
            #Loop through each domaion
            Foreach ($Domain in $DomainList)
            {
                
                #Create objects used to search
                $Searcher = New-Object DirectoryServices.DirectorySearcher
                $Rootsearch = New-Object DirectoryServices.DirectoryEntry $Domain

                $PageSize = 10 #How many computers to retuen at a time
                $SizeLimit = 10000 #max number computers to return

                #Search criteria
                #$Filter = "(&(objectCategory=computer)(objectClass=computer)(cn=$ComputerName))"
                $Temp = $computerName.split(".")[0] #pull host from FQDN if FQDN supplied
                $Filter = "(&(objectCategory=computer)(objectClass=computer)(cn=$Temp))"
                
                $Searcher.filter = $filter
                $Searcher.SearchScope = "SubTree"
                $Searcher.PageSize = $PageSize
                $Searcher.SizeLimit = $SizeLimit
                $Searcher.SearchRoot = $Rootsearch

                #Collect all matching computer names
                $ComputerList = $Searcher.findall() | ForEach-Object {Write-Progress "Server matching search string $Temp found at " $Domain ;$_   }

                #At least 1 computer matching name was found
                If ($ComputerList -ne $null)
                {
                    
                    #Loop through each matching compurtername
                    Foreach ($Computer in $ComputerList)
                    {
                        
                        #Collect all the properties of current object into a variable
                        $objData = $computer.properties 
                        
                        #Loop through all SPN's
                        Foreach ($SPN in $objData.serviceprincipalname)
                        {
                            
                            #Add properties to custom object
                            $MyCustomeObject = New-Object system.object 
                            $MyCustomeObject | Add-Member -type noteproperty -Name Name -Value $($objData.name)
                            #$MyCustomeObject | Add-Member -type noteproperty -Name CN -Value $($objData.cn)
                            $MyCustomeObject | Add-Member -type noteproperty -Name DNSHostName -Value $($objData.dnshostname)
                            $MyCustomeObject | Add-Member -type noteproperty -Name ServicePrincipalName -Value $SPN
                            #$MyCustomeObject | Add-Member -type noteproperty -Name MissingSPN -Value "True/False - not in use yet"
                            #$MyCustomeObject | Add-Member -type noteproperty -Name OperatingSystem -Value $($objData.operatingsystem)
                            #$MyCustomeObject | Add-Member -type noteproperty -Name Servicepack -Value $($objData.operatingsystemservicepack)
                            #$MyCustomeObject | Add-Member -type noteproperty -Name WhenCreated -Value $($objData.whencreated)
                            #$MyCustomeObject | Add-Member -type noteproperty -Name WhenChanged -Value $($objData.whenchanged)
                            #$MyCustomeObject | Add-Member -type noteproperty -Name Description -Value $($objData.description)
                            #$MyCustomeObject | Add-Member -type noteproperty -Name DistinguishedName -Value $($objData.distinguishedname)
                            #$MyCustomeObject | Add-Member -type noteproperty -Name LDAPQuery -Value $($Domain)
                            
                            
                            #Dump data onto pipeline
                            $MyCustomeObject                            
                        
                        }#foreach serviceprincipalname
                    }#foreach Computer
                }#if
            }#Foreach Domain
            
    }#Process
   
    end
    {
    }
}#function


#######################
#### Notes ############
#######################
<#




Code to get service data - TESTING
--------------------------



$Service = "TermService"
$ServiceInfo = (Get-WmiObject -class Win32_Service -ComputerName $ComputerName -Credential $creds -filter "Name='$Service'" )
If ($ServiceInfo -ne $null) 
{ 
    #Service found 
    #check for SPN?
}





ToDo
--------
- Error Handling
  - not find in AD
  - ping server and give info on that
  - collect services
- Faster search? Right now it gathers all then loops through. Try to loop through as found?
- Rather than hard code domains get list of domains from AD  
- Reorder the found domains to search Corp first?  



Testing data
--------------------


Get-Content C:\Temp\Serverlist.txt | Get-SPN


Get-SPN wp*


#>

