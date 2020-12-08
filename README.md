# Network Automation Using GitHub Actions


## Project Overview
Network automation framework based on the following **[GitOps](https://www.gitops.tech/)** principles:
- all device configurations are defined as `code` and stored in a [distributed version control system](https://en.wikipedia.org/wiki/Distributed_version_control) repository
- configuration files are in **raw format** and use a [declarative](https://en.wikipedia.org/wiki/Declarative_programming) language syntax to describe the **desired** system state
- GitHub is assumed to be the [Single Source of Truth](https://en.wikipedia.org/wiki/Single_source_of_truth) - everything related to the application and the environment is documented here
- all configuration changes are initiated via **Git** (`git push`) and are implemented programmatically via **GitHub Actions**
- manual changes by directly modifying device configurations are **not permitted**
- configurations are [immutable](https://en.wikipedia.org/wiki/Immutable_object) - incremental changes are **not permitted**
- configuration is either fully replaced (`configuration replace`) or the device is wiped clean and the new config is loaded upon reboot
- devices' **current** state is continuously monitored and compared to the **desired** state
- alerts are generated if any configuration changes resulting in deviation from the desired state are detected
- GitHub documents the entire history of past changes (who did what, when, and why) and all team communication (pull requests, issue tracking, comments)


## Solution Components
- [GitHub Actions self-hosted runners](https://docs.github.com/en/free-pro-team@latest/actions/hosting-your-own-runners/about-self-hosted-runners)
- [Ubuntu 20.04 Docker container](https://hub.docker.com/_/ubuntu)
- Docker engine
- [Opengear OOB access server](https://opengear.com/products/om2200-operations-manager/)
- [Unimus](https://unimus.net/)
- [Netmiko Python library](https://github.com/ktbyers/netmiko)


## Usage
**Workflow diagram**
![](/diagram-network-automation-github-actions.png)

**Workflow steps**  
- clone this repo
- create a new branch and publish it
- modify the device configuration files(s)
- commit changes to the new branch and push to origin
- create a pull request to submit proposed change(s)
- pull request peer review
- runtime testing (functional/integration/performance) in non-prod (if applicable)
- pull request approval
- merge pull request to update the main branch
- GitHub Actions workflow is triggered
- self-hosted runner starts running the job(s)
- Python script is executed
- static testing (syntax check/config validation) by the device OS
- devices' configuration is replaced
- Unimus continuously audits device configs and generates change-based alerts


## Build
**Download and install Ubuntu**
```
docker pull ubuntu
docker run -it ubuntu
docker ps
docker container attach <CONTAINER_ID>
```

**Install required packages**
```
apt update
apt upgrade

apt install apt-utils
apt install curl 
apt install git  
apt install python3-pip
apt install software-properties-common
apt install vim

pip3 install --upgrade pip  
pip3 install keyring.alt  
pip3 install netmiko  
```

**Create a new user**
```
adduser siteadmin
su siteadmin
```

**Store and encrypt device login credentials**
```
python3
import keyring
keyring.set_password('<SYSTEM_NAME>', '<USERNAME>', '<PASSWORD>')
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

**Install [GitHub CLI](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)**
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

**Download the GitHub Actions self-hosted agent**
```
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
