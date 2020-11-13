# Network automation using GitHub Actions


## Project Overview
Mass configuration push tool for networking devices using GitHub Actions self-hosted runners installed on the Opengear OOB access server and the Netmiko Python library.


## Components
- GitHub Actions using a self-hosted runner
- Ubuntu 20 Docker container
- Docker engine
- Opengear OOB access server
- Netmiko Python library


## Usage
**Workflow diagram**
![](/diagram-network-automation-github-actions.png)

**Workflow steps using GitHub Desktop**  
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
- networking devices' configuration is updated


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
- *Create a Personal Access Token: github.com > profile pic > Settings > Developer settings > Personal access tokens > Generate new token*  
```
gh auth login (GitHub.com > Paste an authentication token > <TOKEN> > HTTPS)
```

**Create a new user and download a GitHub Actions self-hosted agent**
```
adduser siteadmin
su siteadmin
cd home/siteadmin/
mkdir actions-runner && cd actions-runner
```
- *Get the runner version from: github.com > repo > Settings > Actions > Add runner*  
```
curl -O -L https://github.com/actions/runner/releases/download/v<RUNNER_VERSION>/actions-runner-linux-x64-<RUNNER_VERSION>.tar.gz
tar xzf ./actions-runner-linux-x64-<RUNNER_VERSION>.tar.gz
```

**Clone the repo and store GitHub credentials in Git**
```
git clone https://github.com/Davitiani/network-automation-github-actions.git
git config --global credential.helper store
```

**Configure and run the GitHub Actions self-hosted agent**  
- *Get the token from: github.com > repo > Settings > Actions > Add runner*  
```
./config.sh --url https://github.com/Davitiani/network-automation-github-actions --token <TOKEN>
./run.sh
```

**Uninstall the agent**  
- *Get the token from: github.com > repo > Settings > Actions > ... > Remove*
```
./config.sh remove --token <TOKEN>
```


## Issues
- [x] standardize on deleting the repo folder vs keeping it and doing a git pull  
- [x] git credentials cache timeout max value
  - decided to store credentials instead of caching
- [x] jobs are failing with this error: `/actions-runner/_work/_temp/78761644-b80a-41b9-9c0c-dd480bd61c8f.sh: line 1: cd: network-automation-github-actions: No such file or directory`
  - changed to absolute path in the yml files
