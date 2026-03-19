# 02 — Configuração de Rede / IP

> **Público:** Técnico | **Tempo estimado:** 30 minutos

---

## 🌐 Planejamento de Rede


| Item | Valor  |
|------|----------------|
| Rede | 192.168.20.10/24 |
| Gateway (Roteador) | 192.168.20.1 |
| IP do Servidor | 192.168.20.10 |
| Máscara de sub-rede | 255.255.255.0 |
| DNS Primário | 192.168.20.10 (o próprio servidor) |
| DNS Secundário | 8.8.8.8 (Google) |

> ⚠️ **Servidores devem sempre ter IP fixo (estático).** Nunca use DHCP em servidores de produção.

---

## ⚙️ 1. Configurar IP Estático

### Via Interface Gráfica
```
1. Painel de Controle > Centro de Rede e Compartilhamento
2. Alterar configurações do adaptador
3. Clique direito no adaptador > Propriedades
4. Selecione "Protocolo TCP/IPv4" > Propriedades
5. Preencha:
   - Endereço IP: 192.168.20.10
   - Máscara: 255.255.255.0
   - Gateway padrão: 192.168.20.1
   - DNS Preferencial: 192.168.20.10
   - DNS Alternativo: 8.8.8.8
```

### Via PowerShell (recomendado)
```powershell
# Identificar o índice do adaptador
Get-NetAdapter

# Configurar IP estático
New-NetIPAddress `
  -InterfaceAlias "Ethernet" `
  -IPAddress 192.168.20.10 `
  -PrefixLength 24 `
  -DefaultGateway 192.168.20.1

# Configurar DNS
Set-DnsClientServerAddress `
  -InterfaceAlias "Ethernet" `
  -ServerAddresses ("192.168.20.10", "8.8.8.8")
```

---

## 🔍 2. Verificar Conectividade

```powershell
# Testar gateway
ping 192.168.20.1

# Testar DNS externo
ping 8.8.8.8

# Testar resolução de nomes
Resolve-DnsName google.com

# Ver configurações atuais
ipconfig /all
Get-NetIPConfiguration
```

## 🖥️ 3. Configurar Nome do Servidor e Grupo de Trabalho/Domínio

```powershell
# Renomear servidor (se ainda não feito)
Rename-Computer -NewName "SRViFixTech" -Restart
```

> ⚠️ O servidor entrará no domínio após a configuração do Active Directory (próxima etapa).
