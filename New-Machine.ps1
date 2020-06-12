[CmdletBinding()]
param ()

$timer = [System.Diagnostics.Stopwatch]::StartNew()
$ErrorActionPreference = "Stop"

$IsAdmin = (New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    throw "You need to run this from an elevated pwsh prompt"
}

Write-Host "Setting execution policy" -ForegroundColor Magenta
Set-ExecutionPolicy RemoteSigned

Write-Host "Ensuring PS profile exists" -ForegroundColor Magenta
if (-not (Test-Path $profile)) {
    New-Item $profile -Force
}

Write-Progress -Activity "Installing chocolatey"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))
Write-Host "Reloading powershell profile" -ForegroundColor Magenta
. $profile
Write-Progress -Activity "Installing chocolatey packages"
$chocoPackages = @(
    "brave"
    "firefox"
    "googlechrome"
    "microsoft-edge-insider-dev"
    "7zip"
    "bleachbit"
    "notepadplusplus"
    "paint.net"
    "screentogif"
    "sublimetext3"
    "baretail"
    "docker-desktop"
    "fiddler"
    "git"
    "github-desktop"
    "linqpad"
    "microsoft-windows-terminal"
    "microsoftazurestorageexplorer"
    "nvm.portable"
    "postman"
    "powershell-core"
    "smtp4dev"
    "sysinternals"
    "visualstudiocode"
    "signal"
    "yarn"
    "rescuetime"
)
foreach ($package in $chocoPackages) {
    Write-Host "Installing choco package: $package" -ForegroundColor Magenta
    choco install -y $package
    refreshenv
}

Write-Host "Installing nuget package provider" -ForegroundColor Magenta
Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.208 -Force

Write-Host "Ensuring PowerShell Gallery is trusted" -ForegroundColor Magenta
if (-not ((Get-PackageSource -Name "PSGallery").IsTrusted)) {
    $null = Set-PackageSource -Name "PSGallery" -Trusted
}
Write-Host "Installing Powershell modules" -ForegroundColor Magenta
$ModulesToInstall = @(
    "Posh-Docker"
    "Posh-Git"
)
foreach ($Module in $ModulesToInstall) {
    if ($null -eq (Get-Module -Name $Module -ListAvailable)) {
        Write-Host ("Installing PowerShell Module - {0}" -f $Module) -ForegroundColor Magenta
        $null = Install-Module -Name $Module -Force
    }
    else {
        $InstalledVersion = (Get-Module -Name $Module -ListAvailable)[0].version
        $LatestVersion = (Find-Module -Name $Module)[0].version

        if ($InstalledVersion -lt $LatestVersion) {
            if ($null -eq (Get-Package -Name $Module -ErrorAction SilentlyContinue)) {
                Write-Host ("Force Installing PowerShell Module - {0}" -f $Module) -ForegroundColor Magenta
                $null = Install-Module -Name $Module -Force
                
            }
            else {
                Write-Host ("Updating PowerShell Module - {0}" -f $Module) -ForegroundColor Magenta
                $null = Update-Module -Name $Module -Force
            }
        }
    }
}

Write-Host "Setting git aliases" -ForegroundColor Magenta
git config --global alias.co "checkout"
git config --global alias.cob "checkout -b"
git config --global alias.df "diff"
git config --global alias.ec "config --global -e"
git config --global alias.f "fetch origin --prune"
git config --global alias.l "log -n 30 --oneline"
git config --global alias.lga "log --graph --oneline --all --decorate"
git config --global alias.st "status"

Write-Host "Setting git credential manager" -ForegroundColor Magenta
git config --global credential.useHttpPath true

Write-Host "Setting VS Code as the Git editor" -ForegroundColor Magenta
git config --global core.editor "code --wait"

$repos = "c:\repos"
Write-Host "Creating $repos folder" -ForegroundColor Magenta
if (-not (Test-Path $repos)) {
    New-Item $repos -ItemType Directory
}

$temp = "c:\temp"
Write-Host "Creating $temp folder" -ForegroundColor Magenta
if (-not (Test-Path $temp)) {
    New-Item $temp -ItemType Directory
}

Write-Host "Disable Sleep on AC Power..."  -ForegroundColor Magenta
Powercfg /Change monitor-timeout-ac 20
Powercfg /Change standby-timeout-ac 0

Write-Host "Removing pre loaded windows 10 apps" -ForegroundColor Magenta
$unWantedApps = @(
    "4DF9E0F8.Netflix",
    "Fitbit.FitbitCoach",
    "king.com.CandyCrushFriends",
    "king.com.CandyCrushSaga",
    "king.com.FarmHeroesSaga",
    "Microsoft.BingNews",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.Office.OneNote",
    "Microsoft.SkypeApp",
    "Microsoft.ZuneMusic"
)
foreach ($app in $unWantedApps) {
    Write-Host "Removing $app" -ForegroundColor Magenta
    Get-AppxPackage -Name $app | Remove-AppxPackage
}

Write-Host "Setting windows explorer options" -ForegroundColor Magenta
$key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
$advancedKey = "$key\Advanced"
$cabinetStateKey = "$key\CabinetState"
if (Test-Path -Path $key) {
    Write-Host "EnableShowRecentFilesInQuickAccess" -ForegroundColor Magenta
    Set-ItemProperty $key ShowRecent 1

    Write-Host "EnableShowFrequentFoldersInQuickAccess" -ForegroundColor Magenta
    Set-ItemProperty $key ShowFrequent 1
}
if (Test-Path -Path $advancedKey) {
    Write-Host "EnableShowHiddenFilesFoldersDrives" -ForegroundColor Magenta
    Set-ItemProperty $advancedKey Hidden 1

    Write-Host "EnableShowFileExtensions" -ForegroundColor Magenta
    Set-ItemProperty $advancedKey HideFileExt 0

    Write-Host "EnableShowProtectedOSFiles" -ForegroundColor Magenta
    Set-ItemProperty $advancedKey ShowSuperHidden 1

    Write-Host "EnableExpandToOpenFolder" -ForegroundColor Magenta
    Set-ItemProperty $advancedKey NavPaneExpandToCurrentFolder 1

    Write-Host "EnableOpenFileExplorerToQuickAccess" -ForegroundColor Magenta
    Set-ItemProperty $advancedKey LaunchTo 2
}
if (Test-Path -Path $cabinetStateKey) {
    Write-Host "EnableShowFullPathInTitleBar" -ForegroundColor Magenta
    Set-ItemProperty $cabinetStateKey FullPath 1
}

Write-Host "Enabling windows features" -ForegroundColor Magenta
$features = @(
    "Microsoft-Hyper-V-All"
    "Containers"
    "VirtualMachinePlatform"
    "HypervisorPlatform"
    "Microsoft-Windows-Subsystem-Linux"
)
foreach ($feature in $features) {
    Write-Host "Enabling windows feature: $feature" -ForegroundColor Magenta
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName $feature
}

Write-Host "Reloading powershell profile" -ForegroundColor Magenta
. $profile

# disable progress report as Invoke-WebRequest is playing up
$ProgressPreference = 'SilentlyContinue'

# https://docs.microsoft.com/en-us/windows/wsl/install-manual
Write-Host "Downloading ubuntu distro."
$ubuntu = ".\Ubuntu.appx"
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile $ubuntu -UseBasicParsing; Write-Host "Installing ubuntu distro."; Add-AppxPackage $ubuntu; Remove-Item $ubuntu; Write-Host "Finished installing ubuntu distro."

Write-Host "Downloading kali distro."
$kali = ".\Kali.appx"
Invoke-WebRequest -Uri https://aka.ms/wsl-kali-linux-new -OutFile $kali -UseBasicParsing; Write-Host "Installing kali distro."; Add-AppxPackage $kali; Remove-Item $kali; Write-Host "Finished installing kali distro."

Write-Host "Downloading azure cli."
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Write-Host "Installing azure cli."; Start-Process msiexec.exe -Wait -ArgumentList "/I AzureCLI.msi /quiet"; Remove-Item .\AzureCLI.msi; Write-Host "Finished installing azure cli."

$timer.Stop()
Write-Host ""
Write-Host "Script run for $($timer.Elapsed.ToString("hh\:mm\:ss")), it could have taken you at least 3x amount of time if you have to do it manually." -ForegroundColor Green
Write-Host "Now do the following:"  -ForegroundColor Yellow
Write-Host "1. Reboot."  -ForegroundColor Yellow
Write-Host "2. Do a windows update."  -ForegroundColor Yellow
Write-Host "3. Finalized the installation of WSL distros by running them."  -ForegroundColor Yellow
Write-Host "4. Enjoy your new machine. :)"  -ForegroundColor Yellow
Write-Host ""
Read-Host -Prompt "All done, press [ENTER] to restart your computer '$env:COMPUTERNAME'"
Restart-Computer
