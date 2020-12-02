# Network Automation Using GitHub Actions


## Project Overview
Network automation framework based on the following **GitOps** principles:
- all device configurations are defined as `code` and stored in GitHub - [a distributed version control system](https://en.wikipedia.org/wiki/Distributed_version_control)
- these text files are in a [declarative](https://en.wikipedia.org/wiki/Declarative_programming) language format and describe the **desired** system state
- systems' **current** state is continuously monitored and compared to the **desired** state
- alerts are generated if any configuration changes resulting in deviations from the desired state are detected
- GitHub is assumed to be the [Single Source of Truth](https://en.wikipedia.org/wiki/Single_source_of_truth)
- all configuration changes are initiated via **Git** (`git push`) and are implemented programmatically via **GitHub Actions**
- no manual changes by directly altering device configurations are permitted
- devices configurations are [immutable](https://en.wikipedia.org/wiki/Immutable_object) - no incremental changes are permitted
- the entire configuration is either replaced (`configuration replace`) or is wiped clean and the new configuration is loaded upon reboot
- GitHub preserves the entire history of past changes (who did what, when, and why) and all team communication (pull requests, issue tracking, comments)


## Components
- GitHub Actions self-hosted runners
- Ubuntu Docker container
- Docker engine
- Opengear OOB access server
- [Unimus](https://github.intuit.com/t4i-event-tech/Unimus)
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
- Python script is executed
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
apt install python3-pip
apt install software-properties-common

pip3 install --upgrade pip
pip3 install netmiko

-optional-
apt install iputils-ping  
apt install net-tools
apt install sudo
apt install vim
```

**Install TFTP server**
```
apt install tftpd-hpa

cat /etc/default/tftpd-hpa
vi /etc/default/tftpd-hpa

TFTP_USERNAME="siteadmin"
TFTP_DIRECTORY="/home/siteadmin/actions-runner/network-automation-github-actions"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="--secure"

/etc/init.d/tftpd-hpa start
/etc/init.d/tftpd-hpa restart

service --status-all
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

Connected to GitHub
Listening for Jobs
```

**Uninstall the agent**  
- *Get the token from: github.com > repo > Settings > Actions > ... > Remove*
```
./config.sh remove --token <TOKEN>
```
