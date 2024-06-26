

Function Convert-EPOCHDateTime
{
  <#
  .SYNOPSIS
    Convert EPOCH time - this should not display
  .DESCRIPTION
    Convert EPOCH time to local time
  .Parameter InputTime
    The EPOCH time to converte

  .EXAMPLE
    Convert-EPOCHDateTime -InputTime -9147600

    Converts Unix EPOCH time -9147600 to a human readable date

  .EXAMPLE
    -9147600,1539613448,1529604105 | Convert-EPOCHDateTime


  .LINK

  .NOTES
    Author: Johnny Leuthard

#>
  [CmdletBinding(SupportsShouldProcess,DefaultParameterSetName = 'None')]
  Param
  (
    [Parameter(Position = 0, ValueFromPipeline, Mandatory)]
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


