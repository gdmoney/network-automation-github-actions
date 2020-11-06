# Network automation using GitHub Actions self-hosted runners and Netmiko


## Install on an Ubuntu 20 Docker container
```
docker pull ubuntu
docker run -it ubuntu
```
```
apt update
apt upgrade

apt install apt-utils
apt install curl apt install iputils-ping
apt install net-tools
apt install python3-pip
apt install software-properties-common
apt install vim

pip3 install --upgrade pip
pip3 install netmiko
```
- comment out user sudo check in the `run.sh` and `config.sh` files
```
mkdir actions-runner && cd actions-runner

curl -O -L https://github.com/actions/runner/releases/download/v2.273.6/actions-runner-linux-x64-2.273.6.tar.gz

tar xzf ./actions-runner-linux-x64-2.273.6.tar.gz

./config.sh --url https://github.com/Davitiani/network-automation-github-actions --token ALDNW5PAE54W7CXIDWRP7PS7URIDY

./run.sh
```
## Install on an Ubuntu 20 laptop
```
apt update
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


## Install on a Windows 10 laptop
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
