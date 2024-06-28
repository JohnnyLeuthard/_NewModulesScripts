
Function Convert-EPOCHDateTime
{
<#
  .Synopsis
    Converts Unix EPOCH time to a human readable date
  .description
    Converts Unix EPOCH time to a human readable date displaying in format of severl different time zones

  .Parameter InputTime
    The EPOCH time to convert
    
  .Example
    Convert-EPOCHDateTime -InputTime 999999094

    InputTime LocalTimezone         LocalTime           UTCTime
    --------- -------------         ---------           -------
    999999094 Eastern Standard Time 9/8/2001 9:31:34 PM 9/9/2001 1:31:34 AM


  .Example
    -9147600,1539613448,1529604105 | Convert-EPOCHDateTime

    InputTime LocalTimezone         LocalTime              UTCTime
    --------- -------------         ---------              -------
      -9147600 Eastern Standard Time 9/16/1969 11:00:00 PM  9/17/1969 3:00:00 AM
      1539613448 Eastern Standard Time 10/15/2018 10:24:08 AM 10/15/2018 2:24:08 PM
      1529604105 Eastern Standard Time 6/21/2018 2:01:45 PM   6/21/2018 6:01:45 PM


  .Link
    https://github.com/JohnnyLeuthard/MyModules/blob/main/en-us/MD/Convert-EPOCHDateTime.md
  .Notes
    Author: Johnny Leuthard

#>
[CmdletBinding(SupportsShouldProcess,DefaultParameterSetName = 'All')]
Param
  (
    [Parameter(Position = 0, ValueFromPipeline, Mandatory,ParameterSetName='All')]
    [Parameter(ValueFromPipeline,ParameterSetName='TEMP')]
    [ValidateNotNullOrEmpty()]
      $InputTime
      
  )
  Begin
  {
  }
  Process
  {

    $FriendlyDate = (get-date '1/1/1970').addseconds($inputTime)

    # Get Local timezone
    ##$strCurrentTimeZone = (gwm-wmiobject win32_timezone).StandardName
    ##$TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById(($strCurrentTimeZone)
    ##$LocalTime = [System.TimeZoneInfo]::convertTimeZone.tolocalTime($FriendlyDate) )
    $LocalTime = ( [System.TimeZone]::CurrentTimeZone.ToLocalTime($FriendlyDate) )

    $HashData = [ordered]@{
      'InputTime'     = $InputTime
      'LocalTimezone' = ( [System.TimeZone]::CurrentTimeZone).StandardName
      'LocalTime'     = $LocalTime
      'UTCTime'       = $FriendlyDate
    }
    New-Object -TypeName psobject -Property $HashData
  }
  end
  {
  }
}#(Function Convert-EPOCHDateTime)
##################
<#

Convert-EPOCHDateTime -InputTime '1636112341'

#>


