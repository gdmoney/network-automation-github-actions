# Network automation using GitHub Actions self-hosted runners and Netmiko


## Install on an Ubuntu 20 Docker container
**Download and install Ubuntu**
```
docker pull ubuntu
docker run -it ubuntu
```
**Update and install packages**
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
- comment out user sudo check in the `run.sh` and `config.sh` files at the top  

**Install and run the self-hosted agent**
```
mkdir actions-runner && cd actions-runner

curl -O -L https://github.com/actions/runner/releases/download/v2.273.6/actions-runner-linux-x64-2.273.6.tar.gz

tar xzf ./actions-runner-linux-x64-2.273.6.tar.gz

./config.sh --url https://github.com/Davitiani/network-automation-github-actions --token ALDNW5PAE54W7CXIDWRP7PS7URIDY

./run.sh
```
**[Install GitHub CLI](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)**
```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
sudo apt-add-repository https://cli.github.com/packages
sudo apt update
sudo apt install gh
```
- create a Personal Access Token: GitHub > profile pic > Settings > Developer settings > Personal access tokens > Generate new token

## Install on an Ubuntu 20 laptop
**Update and install packages**
```
sudo apt update
sudo apt upgrade
sudo apt install python3-pip
sudo pip3 install --upgrade pip
sudo pip3 install netmiko
```
**Install and run the self-hosted agent**
```
mkdir actions-runner && cd actions-runner

curl -O -L https://github.com/actions/runner/releases/download/v2.273.6/actions-runner-linux-x64-2.273.6.tar.gz

tar xzf ./actions-runner-linux-x64-2.273.6.tar.gz

./config.sh --url https://github.com/Davitiani/network-automation-github-actions --token ALDNW5PAE54W7CXIDWRP7PS7URIDY

./run.sh
```
**[Install GitHub CLI](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)**
```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
sudo apt-add-repository https://cli.github.com/packages
sudo apt update
sudo apt install gh
```

## Install on a Windows 10 laptop
**Using PowerShell 7**
```
mkdir actions-runner
cd C:\actions-runner

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.273.6/actions-runner-win-x64-2.273.6.zip -OutFile actions-runner-win-x64-2.273.6.zip

Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-2.273.6.zip", "$PWD")

./config.cmd --url https://github.com/gdmoney/network-automation-github-actions --token ALDNW5LV6CWOJBDDY5B7VB27UL3ZA

./run.cmd
```
