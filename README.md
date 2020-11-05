# Network automation using GitHub Actions self-hosted runners and Netmiko


## GHA self-hosted runner install on Linux
### Ubuntu 20
**Install**
```
apt install python3-pip
sudo pip3 install --upgrade pip
sudo pip3 install netmiko
```
```
mkdir actions-runner && cd actions-runner

curl -O -L https://github.com/actions/runner/releases/download/v2.273.6/actions-runner-linux-x64-2.273.6.tar.gz

tar xzf ./actions-runner-linux-x64-2.273.6.tar.gz

./config.sh --url https://github.com/Davitiani/network-automation-github-actions --token ALDNW5PAE54W7CXIDWRP7PS7URIDY

./run.sh
```


## GHA self-hosted runner install on Windows
### PowerShell 7 (run as Admin)
**Install**
```
mkdir actions-runner
cd C:\actions-runner

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.273.6/actions-runner-win-x64-2.273.6.zip -OutFile actions-runner-win-x64-2.273.6.zip

Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-2.273.6.zip", "$PWD")

./config.cmd --url https://github.com/gdmoney/network-automation-github-actions --token ALDNW5LV6CWOJBDDY5B7VB27UL3ZA

./run.cmd
```

**Monitor**  
`Get-EventLog -LogName Application -Source ActionsRunnerService`
`Get-Service "actions.runner.*"`
`Start-Service "actions.runner.*"`
`Stop-Service "actions.runner.*"`

**Remove**  
`Remove-Service "actions.runner.gdmoney-network-automation-github-actions.SDGLWA9BB1E7B7"`

`Remove-Service "actions.runner.*"`

`config.cmd remove`
