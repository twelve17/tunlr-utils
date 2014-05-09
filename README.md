# tunlr-utils

Update the configuration of a Tunlr-Clone server configured somewhat like outlined in the [Tunlr-Clone](https://github.com/corporate-gadfly/Tunlr-Clone) project.

## Installation

### Download Project

As root:

```
cd ~/
git git@github.com:twelve17/tunlr-utils.git
sudo mv tunlr-utils /opt/tunlr-utils
sudo chmod 700 /opt/tunlr-utils
```

### Configure Sudoers

```
sudo vi /etc/sudoers.d/tunlr-utils
```

```
Defaults!/opt/tunlr-utils/bin/tunlr-config.rb env_keep += "SSH_CLIENT SSH_ORIGINAL_COMMAND"
<user> ALL=NOPASSWD: /opt/tunlr-utils/bin/tunlr-config.rb
```

### Configure Command-Only SSH Key

As a normal user:

```
vi ~/.ssh/authorized_keys 
```

```
command="sudo /opt/tunlr-utils/bin/tunlr-config.rb",no-port-forwarding,no-x11-forwarding,no-agent-forwarding ssh-rsa AAAAB.... someone@somehost 
```

## Run From Client

Update the provider domains:
```
ssh -y -i /jffs/configs/ssh/your_key_for_tunlr_utils -l <user> <tunlr_host> sudo /opt/tunlr-utils/bin/tunlr-config.rb providers ip2location.com,pandora.com,...
```

Update the client IP:
```
ssh -y -i /jffs/configs/ssh/your_key_for_tunlr_utils -l <user> <tunlr_host> sudo /opt/tunlr-utils/bin/tunlr-config.rb client
```
