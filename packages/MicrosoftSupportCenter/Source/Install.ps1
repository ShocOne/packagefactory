<#
    .SYNOPSIS
    Installs the application
#>
[CmdletBinding()]
param ()

#region Restart if running in a 32-bit session
if (!([System.Environment]::Is64BitProcess)) {
    if ([System.Environment]::Is64BitOperatingSystem) {
        $Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$($MyInvocation.MyCommand.Definition)`""
        $ProcessPath = $(Join-Path -Path $Env:SystemRoot -ChildPath "\Sysnative\WindowsPowerShell\v1.0\powershell.exe")
        Write-Verbose -Message "Restarting in 64-bit PowerShell."
        Write-Verbose -Message "FilePath: $ProcessPath."
        Write-Verbose -Message "Arguments: $Arguments."
        $params = @{
            FilePath     = $ProcessPath
            ArgumentList = $Arguments
            Wait         = $True
            WindowStyle  = "Hidden"
        }
        Start-Process @params
        exit 0
    }
}
#endregion

try {
    New-Item -Path "$env:ProgramData\PackageFactory\Logs" -ItemType "Directory" -ErrorAction "SilentlyContinue" | Out-Null
    $Installer = Get-ChildItem -Path $PWD -Filter "SupportCenterInstaller.msi" -Recurse -ErrorAction "SilentlyContinue"
    $params = @{
        FilePath     = "$env:SystemRoot\System32\msiexec.exe"
        ArgumentList = "/package `"$($Installer.FullName)`" /quiet /log `"C:\ProgramData\PackageFactory\logs\SupportCenterInstaller.log`""
        NoNewWindow  = $True
        PassThru     = $True
        Wait         = $True
    }
    $result = Start-Process @params
}
catch {
    throw "Failed to update Microsoft Configuration Manager Support Center."
}
finally {
    exit $result.ExitCode
}