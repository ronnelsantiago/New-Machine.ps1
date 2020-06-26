Fire up an elevated powershell and run this:

```pwsh
iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/ronnelsantiago/New-Machine.ps1/master/New-Machine.ps1'))
```

This script will:

- Installs apps using chocolatey
- Installs powershell modules
- Setup git alias
- Creates `c:\repos` and `c:\temp` folders
- Disable sleep on AC power
- Removes pre loaded windows 10 apps that I don't need
- Setting my prefered windows explorer options, eg. shows hidden files, show file extensions, etc
- Enabling windows features
- Installs WSL distros(ubuntu and kali)
- Installs Azure CLI

> On a descent machine and internet connection this usually takes around 25-30 minutes.
