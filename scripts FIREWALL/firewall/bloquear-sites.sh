# Filtro de URLs
cd /etc/dnsmasq.d
nano blacklist.conf

# Redes sociais
address=/facebook.com/0.0.0.0
address=/instagram.com/0.0.0.0
address=/tiktok.com/0.0.0.0
address=/twitter.com/0.0.0.0
address=/x.com/0.0.0.0

# Streaming
address=/youtube.com/0.0.0.0
address=/netflix.com/0.0.0.0
address=/primevideo.com/0.0.0.0
address=/disneyplus.com/0.0.0.0

# Mensageiros
address=/whatsapp.com/0.0.0.0
address=/web.whatsapp.com/0.0.0.0
address=/discord.com/0.0.0.0
address=/telegram.org/0.0.0.0

# Jogos
address=/twitch.tv/0.0.0.0
address=/steamcommunity.com/0.0.0.0
address=/epicgames.com/0.0.0.0
address=/roblox.com/0.0.0.0

# Conteúdo adulto (exemplos)
address=/pornhub.com/0.0.0.0
address=/xvideos.com/0.0.0.0
address=/xnxx.com/0.0.0.0

# Downloads
address=/thepiratebay.org/0.0.0.0
address=/1337x.to/0.0.0.0
address=/yts.mx/0.0.0.0

# salvar e sair do nano


cd ..

ls dnsmasq*

nano dnsmasq.conf

#LAN
interface=enp4s0
bind-interfaces


#DNS
listen-address=192.168.20.1
server=8.8.8.8
server=8.8.4.4
cache-size=1000 

#Novas regras de firewall adicionada 
#Blacklist
domain-needed
conf-file=/etc/dnsmasq.d/blacklist.conf

# salvar e sair do nano

# Reiniciar o serviço dnsmasq para aplicar as mudanças
systemctl restart dnsmasq
systemctl status dnsmasq