# Network Automation Using GitHub Actions


## Project Overview
Network automation framework loosely based on **[GitOps](https://opengitops.dev/)** principles:
- **GitHub** is assumed to be the [Single Source of Truth](https://en.wikipedia.org/wiki/Single_source_of_truth) - all data related to the definition of the solution is documented here
- all device configurations are defined as `code` and stored in a [distributed version control system](https://en.wikipedia.org/wiki/Distributed_version_control) repository
- configuration files are in **raw format** and use a [declarative](https://en.wikipedia.org/wiki/Declarative_programming) language syntax to describe the **desired** system state
- all configuration changes are initiated via **Git** and are implemented programmatically via **GitHub Actions**
- manual changes by directly modifying device configurations are **not permitted**
- configurations are [immutable](https://en.wikipedia.org/wiki/Immutable_object) - incremental changes are **not permitted**
- configuration is either fully replaced (`config replace`) via **TFTP** or a device is wiped clean when powered off and new config is loaded via **DHCP** upon reboot
- rollbacks are simplified with a single command (`git revert HEAD`)
- devices' **actual** state is continuously monitored and compared to the **desired** state
- **alerts** are generated if any configuration changes resulting in **deviation** from the desired state are detected
- GitHub documents the entire history of past changes (who did what, when, and why) and all team communication (pull requests, issue tracking, comments)


## Solution Components
- GitHub repository - the source of truth for device configurations
- [GitHub Actions self-hosted runner](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners) - runs the workflow job
- [Ubuntu 20.04 Docker container](https://hub.docker.com/_/ubuntu) - hosts the GitHub Actions runner and the TFTP server
- [Opengear OOB access server](https://opengear.com/products/om2200-operations-manager/) - bare metal server running the Docker Engine
- [Unimus network automation tool](https://unimus.net/) - backs up and audits device configs
- [Slack](https://slack.com) - sends config change notifications
- [Netmiko Python library](https://github.com/ktbyers/netmiko) - SSHs into devices and replaces configs


## Reference Architecture
![](/diagram-network-automation-github-actions.png)


## Usage
**Workflow steps**
- *Standard* change - a low-risk change that's pre-approved and follows documented, repeatable tasks
  - clone this repo
  - modify the device configuration files(s)
  - commit and push directly to the main branch
- *Normal* change - a moderate or high-risk change that requires code review and approval prior to deployment
  - clone this repo, create a new branch and publish it
  - modify the device configuration files(s)
  - commit changes to the new branch and push to origin
  - create a pull request to submit proposed change(s)
  - pull request peer review
  - pre-deployment testing (functional/integration/performance) for complex and high-risk changes
  - pull request approval and merge based on validation test results
- GitHub Actions workflow is triggered
  - workflows can also be triggered manually via GH CLI (`gh workflow run <WORKFLOW_NAME>`) or GUI from the repo's Actions page on GH
- self-hosted runner starts running the job(s)
- Python script is executed
- static testing (syntax check/config validation) by the device NOS
- devices' configuration is replaced
- Unimus continuously audits devices' operational state and generates alerts if config drift is detected
- operator gets a Slack notification describing the config change(s)


## Build
**Download and run Ubuntu on Opengear**
```
sudo -i
docker pull ubuntu
docker run -it ubuntu
```

**Install required packages**
```
apt update && apt upgrade -y

apt install apt-utils curl git iputils-ping python3-pip tftpd-hpa vim wget -y
apt install software-properties-common -y

pip3 install --upgrade pip keyring keyrings.alt netmiko
```

**Install [GitHub CLI](https://github.com/cli/cli/blob/trunk/docs/install_linux.md), login to GitHub and store GH credentials in git**
- *Create a Personal Access Token: github.com > profile pic > Settings > Developer settings > Personal access tokens > Generate new token: repo, read:org*
```
type -p curl >/dev/null || (apt update && apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& apt update \
&& apt install gh -y

gh auth login (GitHub.com > HTTPS > n > Paste an authentication token)

git config --global credential.helper store
```

**Create a new user and directories**
```
useradd -ms /bin/bash siteadmin && su siteadmin
mkdir /home/siteadmin/actions-runner && mkdir /home/siteadmin/actions-runner/network-automation-github-actions
```

**Store and encrypt device login credentials**
```
python3
import keyring
keyring.set_password('<SYSTEM_NAME>', '<USERNAME>', '<PASSWORD>')

# verify the password
keyring.get_password('cisco', 'siteadmin')

quit()
exit
```

**Configure and start the TFTP service as root**
```
cat /etc/default/tftpd-hpa
vi /etc/default/tftpd-hpa

TFTP_USERNAME="siteadmin"
TFTP_DIRECTORY="/home/siteadmin/actions-runner/network-automation-github-actions"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="--secure"

/etc/init.d/tftpd-hpa start

# verify TFTP service is running
service --status-all
```

**Clone this repo**
```
su siteadmin
cd /home/siteadmin/actions-runner/
git clone https://github.com/gdmoney/network-automation-github-actions.git
```

**Download, extract, configure, and run the GitHub Actions self-hosted agent**
- *Get the token from: github.com > repo > Settings > Actions > Runners > New self-hosted runner*
```
curl -o actions-runner-linux-x64-2.305.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.305.0/actions-runner-linux-x64-2.305.0.tar.gz

tar xzf ./actions-runner-linux-x64-2.305.0.tar.gz

./config.sh --url https://github.com/gdmoney/network-automation-github-actions --token <TOKEN>

./run.sh

Connected to GitHub
Listening for Jobs
```

**Uninstall the agent (optional)**
- *Get the token from: github.com > repo > Settings > Actions > ... > Remove*
```
./config.sh remove --token <TOKEN>
```


## Troubleshooting
**After container or Opengear restart**
- *Start Ubuntu and Unimus containers*
  - *start the Ubuntu container first so that it gets the .2 IP address*
```
sudo -i
docker container ls -a

docker container start <CONTAINER ID>
docker container inspect <CONTAINER ID> | grep IP
```

- *Start the TFTP service and the GitHub Actions runner*
```
docker container attach <CONTAINER ID>

/etc/init.d/tftpd-hpa start
service --status-all

su siteadmin
cd /home/siteadmin/actions-runner/
./run.sh
```
