# interfaces de rede
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5)

cd /etc/network

nano interface

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eno1
iface eno1 inet static
address 192.168.20.1/24
gateway 10.26.44.1
