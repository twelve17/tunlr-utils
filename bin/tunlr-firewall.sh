#!/bin/bash 

# Refresh firewall rules to accomodate the given home and server ip.

SERVER_IFACE="eth0"

# your home cable/dsl/fiber/etc ISP
HOME_IP=$1

# your local host internal or public IP here
SERVER_IP=$2

# Whether to save the firewall rules to survive reboots
SAVE_RULES="y"

# log iptable rules
DEBUG="n"

if [ -z "$HOME_IP" ]; then
  echo "missing value for HOME_IP"
  exit 1
fi

if [ -z "$SERVER_IP" ]; then
  echo "missing value for SERVER_IP"
  exit 1
fi

#-----------------------------------------------------------------------------
add_rules () {
  # Reset 
  iptables -F
  
  # Allow localhost 
  iptables -A INPUT -i lo -j ACCEPT
  
  # Allow existing 
  iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
  
  # Allow ssh'ing from anywhere. Disabled here due to usage of knockd.
  #iptables -A INPUT -p tcp --dport ssh -j ACCEPT
  
  # Only allow TCP connections into/out of HTTP(s) from the home ISP address
  for dport in 80 443; do 
    # For the filter table (which is the default):
    iptables -A INPUT -i $SERVER_IFACE -s $HOME_IP -d $SERVER_IP -p tcp --dport $dport -j ACCEPT
    # For the nat table
    iptables -t nat -A PREROUTING -i $SERVER_IFACE -p tcp --dport $dport -j DNAT --to $SERVER_IP
  done
  
  # Only allow TCP/UDP connections into DNS from the home ISP address
  for protocol in tcp udp; do
    iptables -A INPUT -i $SERVER_IFACE -s $HOME_IP -d $SERVER_IP -p $protocol --dport 53 -j ACCEPT
    if [ "$DEBUG" == "y" ]; then
      iptables -A INPUT -p $protocol --dport 53 -j LOG --log-level debug
    fi
  done
  
  # Block everything else
  iptables -A INPUT -j DROP
}

#-----------------------------------------------------------------------------
save_rules () {
  iptables-save > /etc/iptables.rules
}

add_rules
[ "$SAVE_RULES" == "y" ] && save_rules
