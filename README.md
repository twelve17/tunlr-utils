# /etc/sudoers.d/tunlr-utils 
Defaults!/opt/tunlr-utils/bin/tunlr-config.rb env_keep += "SSH_CLIENT SSH_ORIGINAL_COMMAND"
<user> ALL=NOPASSWD: /opt/tunlr-utils/bin/tunlr-config.rb

# ~/.ssh/authorized_keys 
command="sudo /opt/tunlr-utils/bin/tunlr-config.rb",no-port-forwarding,no-x11-forwarding,no-agent-forwarding ssh-rsa AAAAB.... someone@somehost 

cd ~/
git clone http://.... tunlr-utils
sudo mv ~/tunlr-utils /opt/tunlr-utils
sudo chmod 700 /opt/tunlr-utils



# Client 
ssh -y -i /jffs/configs/ssh/your_key_for_tunlr_utils -l <user> <tunlr_host> sudo /opt/tunlr-utils/bin/tunlr-config.rb providers ip2location.com,pandora.com,...
ssh -y -i /jffs/configs/ssh/your_key_for_tunlr_utils -l <user> <tunlr_host> sudo /opt/tunlr-utils/bin/tunlr-config.rb client
