# Regras de firewall
apt install iptables

iptables -I INPUT -p ICMP -j DROP

iptables -F

iptables -L

iptables -I INPUT -p ICMP -j REJECT

iptables -L
