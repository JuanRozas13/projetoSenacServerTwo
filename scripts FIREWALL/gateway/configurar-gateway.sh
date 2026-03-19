# interfaces de rede
cd /etc

ls dns*

nano dnsmasq.conf

#LAN
interface= enp4s0
bind-interfaces


#DNS
listen-address=192.168.20.1
server=8.8.8.8
server=8.8.4.4
cache-size=1000

