
class ccpcall {

    [string]$SafeName;
    [Parameter(ParameterSetName = 'All',HelpMessage = "Your CCP AppID")]
		[string]$AppID;
    [string]$CCPHost;
    [Parameter(ParameterSetName = 'All',HelpMessage = "CCP Port")]
    [ValidateSet('443', '8443')]
        [string]$CCPPort = '8443';
    [string]$Username;
    [string]$Address;
    [string]$PolicyID;
    [string]$Reason;
    [string]$StringToDisplay;
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
    
}


class certauth : ccpcall {

    ##static [string]$AuthType = "userauth"
    [string]$certAuthVar;
    [string]$Thumbprint;
    
    

    certauth(){
        $this.authtype = "CertAuth"
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
        
        $this.UserAuthVar = 'User Auth'

    }


}

#######################
### NOTES
#######################
<#

$a = [certauth]::new()
$a = [certauth]::new("MyAppID")

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

$a.test
$a.test("my string")


#>

