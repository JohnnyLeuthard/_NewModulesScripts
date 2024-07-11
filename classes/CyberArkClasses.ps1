

class ccpcall {

    [Parameter(ParameterSetName = 'All',HelpMessage = "Your CCP AppID")]
		[string]$AppID;
    [Parameter(ParameterSetName = 'All',HelpMessage = "Your CCP AppID")]
        [string]$CCPHost;
    [Parameter(ParameterSetName = 'All',HelpMessage = "CCP Port")]
    [ValidateSet('443', '8443')]
        [string]$CCPPort = '8443';
    #[Parameter(ParameterSetName = 'All')]
	#    [string]$BaseURL;   

    [Parameter(ParameterSetName = 'All')]
	    [string]$SafeName;
    [Parameter(ParameterSetName = 'All')]
	    [string]$ObjectName;
    

    [Parameter(ParameterSetName = 'All')]
        [string]$Username;
    [Parameter(ParameterSetName = 'All')]
        [string]$Address;
    [Parameter(ParameterSetName = 'All')]
        [string]$Reason;
    
    [Parameter(ParameterSetName = 'All')]
        [string]$PolicyID;
    [Parameter(ParameterSetName = 'All')]
        [string]$StringToDisplay;
    
    [Parameter(ParameterSetName = 'All')]
        [string]$AuthType;

        

    ccpcall () {}

    ccpcall ($SafeName)
    {
        $this.safename = $SafeName
    }

#    <#
    # method - test
    test([string]$StringToDisplay) {
        $this:StringToDisplay = $StringToDisplay
        #write-host $stringToDisplay -ForegroundColor Green
        write-host $this.StringToDisplay -ForegroundColor Green
    }

    #>
    
    $BaseURL = ($CCPHost + ':' + $CCPPort)

}


class certauth : ccpcall {

    ##static [string]$AuthType = "userauth"
    [string]$certAuthVar;
    [string]$Thumbprint;
    [string]$AuthType = 'CertAuth';
      
    
    certauth(){
    
        $this.authtype = "CertAuth"
    }


    certauth($appID,$CCPHost,$CCPPort,$UserName,$Address,$Reason,$Thumbprint) {
        $this.AppID         = $appID
        $this.CCPHost       = $CCPHost
        $this.CCPPort       = $CCPPort
        $this.Username      = $UserName
        $this.Address       = $Address
        $this.Reason        = $Reason
        $this.Thumbprint    = $Thumbprint

        $this.AuthType      = 'Cert Auth Type'
    }

}


class userauth : ccpcall {

    [string]$UserAuthVar;
    #[string]$AuthType = "userauth"
    
    userauth(){}

    userauth($AppID){
        $this.AppID = $appID
    }

    userauth($AppID,$CCPHost,$CCPPort){
        $this.AppID = $appID
        $this.CCPHost = $CCPHost
        $this.CCPPort = $CCPPort
    }

    userauth($AppID,$CCPHost,$CCPPort,$UserName,$Address,$Reason){
        $this.AppID = $appID
        $this.CCPHost = $CCPHost
        $this.CCPPort = $CCPPort
        $this.UserName = $UserName
        $this.Address = $Address
        $this.Reason = $Reason
        
        $this.UserAuthVar = 'User Auth Type'

    }


}

#######################
### NOTES
#######################
<#

$a = [certauth]::new()
$a = [certauth]::new("MyAppID")
$a = [certauth]::new("MyAppID","CCPServer1",'443','MyUserID','MyAddress','TESTING custom class')
$a = [certauth]::new("MyAppID","CCPServer1",'443','MyUserID','MyAddress','TESTING custom class','1D6F4B2C4D4B1D6F4B2C4D4B1D6F4B2C4D4B')
$a = [certauth]::new("MyAppID","CCPServer1",'8443','MyUserID','MyAddress','TESTING custom class','1D6F4B2C4D4B1D6F4B2C4D4B1D6F4B2C4D4B')


$a = [userauth]::new()
$a = [userauth]::new("MyAppID")
$a = [userauth]::new("MyAppID","CCPServer1",'443')
$a = [userauth]::new("MyAppID","CCPServer1",'443','MyID','MyAddress','TESTING custom class')

$a = [ccpcall]::new()
$a = [ccpcall]::new("MySafe")

$a

$a.AppID = 'MyCCPAppID'
$a.Username = 'userID1'
$a.CCPHost = 'Server1.contoso.com'
$a.Reason = 'testing a call using a class'
$a.Address = 'contoso.com'
$a.SafeName = 'MySafe'
$a.CCPPort = '443'  

$a.StringToDisplay = 'My String"  

$a.gettype()
$a.gettype() | fl * 

$a.test
$a.test("my string")


#>

