# Configurar o nftables
cd /etc
nano /etc/sysctl.d/99-ipforward.conf
net.ipv4.ip_forward=1
sysctl --system

# Ativando o serviço nftable para iniciar ao ligar o server
systemctl status nftables
systemctl start nftables
systemctl status nftables
systemctl enable nftables
systemctl status nftables


# 
cp nftables.conf  nftables.conf.bkp

ls nftables*

nftables.conf  nftables.conf.bkp

nano nftables.conf


# ANTES
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
        chain input {
                type filter hook input priority filter;
        }
        chain forward {
                type filter hook forward priority filter;
        }
        chain output {
                type filter hook output priority filter;
        }
}

table ip nat {
        chain postrouting {
                type nat hook postrouting priority 100;
                policy accept;
                oif "eno1" masquerade
        }
}


# DEPOIS

