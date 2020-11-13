# Network automation using GitHub Actions


## Project Overview
Mass configuration push tool for networking devices using GitHub Actions self-hosted runners and the Netmiko Python library.


## Components
- GitHub Actions
- GitHub Actions self-hosted runners
- Ubuntu 20
- Docker engine
- Opengear access server
- Netmiko Python library


## Usage
**Diagram**
![](/diagram-network-automation-github-actions.png)

**Workflow using GitHub Desktop**  
- clone this repo
- create a new branch and publish it
- modify the device config file(s)
- commit changes to the new branch and push to origin
- create a pull request
- pull request review/approval
- merge pull request to update the Main branch
- delete the new branch
- GitHub Actions workflow starts
- self-hosted runner runs the jobs
- Python scripts are executed
- networking devices are updated


## Build
### Ubuntu 20.04.1 LTS Docker container
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
apt install curl 
apt install git  
apt install iputils-ping  
apt install net-tools
apt install python3-pip
apt install software-properties-common
apt install sudo
apt install vim

pip3 install --upgrade pip
pip3 install netmiko
```

**[Install GitHub CLI](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)**
```
apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
apt-add-repository https://cli.github.com/packages
apt update
apt install gh
```
*Create a Personal Access Token: github.com > profile pic > Settings > Developer settings > Personal access tokens > Generate new token*  
```
gh auth login (GitHub.com > Paste an authentication token > PASTE > HTTPS)
```

**Install the GitHub Actions self-hosted agent**
```
adduser siteadmin
usermod -aG sudo siteadmin
su siteadmin

sudo mkdir actions-runner
sudo chown siteadmin:siteadmin actions-runner
cd actions-runner
```
```
curl -O -L https://github.com/actions/runner/releases/download/v<RUNNER_VERSION>/actions-runner-linux-x64-<RUNNER_VERSION>.tar.gz
tar xzf ./actions-runner-linux-x64-<RUNNER_VERSION>.tar.gz
```

**Clone and update the repo**
```
git clone https://github.com/Davitiani/network-automation-github-actions.git
cd network-automation-github-actions
git pull
cd ..
```
*Cache GitHub credentials in Git*  
```
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=28800'
```

**Run the GitHub Actions self-hosted agent**
*Get the token from: GitHub > repo > Settings > Actions > Add runner*
```
./config.sh --url https://github.com/Davitiani/network-automation-github-actions --token <TOKEN>
./run.sh
```

**Uninstall the agent**  
```
./config.sh remove --token <TOKEN>
```


## Issues
- [x] standardize on deleting the repo folder vs keeping it and doing a git pull  
- [x] git credentials cache timeout max value (8 hours)
