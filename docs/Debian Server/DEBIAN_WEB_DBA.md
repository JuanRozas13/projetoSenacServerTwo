<!-- Configuração Debian Web/DBA -->
<!-- Cenario do servidor Banco de dados -->

<!-- Identificar os dispositivos conectados ao servidor -->
lspci
<!-- Procurar o: 
Ethernet controller:
-->

<!-- identificar interfaces/gitplacas de rede -->
ip a

<!-- Resetar as configurações de ip do servidor -->
ifdown enp0s3

<!-- Para receber um novo ip -->
ifup enps03

ip a