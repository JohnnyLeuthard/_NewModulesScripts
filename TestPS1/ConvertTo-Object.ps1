
function ConvertTo-Object 
{
    [CmdletBinding(SupportsShouldProcess=$True)]
	Param
    (
        [parameter(valuefrompipeline=$true)]
        $hashtable
    )
    
    $object = New-Object PSObject
    $hashtable.GetEnumerator() | ForEach-Object {
        Add-Member -inputObject $object `
            -memberType NoteProperty -name $_.Name -value $_.Value
    }

    return $object
}
########################
##### NOTES
########################
<#




#Example
------------

$ComputerName = $Env:ComputerName
$Date = Get-Date


$Props = @{
    "First" = "Johnny"
    "Last" = "Leuthard"
    "Middle" = "E."
    "TodatsDate" = $Date
    "ComputerName" = $ComputerName
    "Culture" = (Get-Culture).Name
    "FirstMD5" = (get-md5 $Props.First).md5
    "LastMD5" = (get-md5 $Props.Last).md5
}

$temp = $props | ConvertTo-Object 
$temp




#>

