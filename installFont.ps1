function Install-Fonts
{
  [CmdletBinding()]
    Param
      (
       [string[]]$Files
      )

      $objShell = New-Object -ComObject Shell.Application
      $Fonts = $objShell.NameSpace(20)
      If (!($Files -eq $null)) {
        Get-ChildItem "$Files\*.ttf" | ForEach-Object {
          $Fonts.CopyHere($_.FullName, 0x10)
        }
      }
}

