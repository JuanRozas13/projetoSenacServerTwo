# 03 — Active Directory / DNS / DHCP

> **Público:** Técnico | **Tempo estimado:** 1–2 horas

---

## 🏗️ Visão Geral

O **Active Directory Domain Services (AD DS)** é o coração da infraestrutura Windows. Ele centraliza autenticação, autorização e gerenciamento de usuários, computadores e políticas da empresa.

```
┌─────────────────────────────────────────┐
│           empresa.local (Domínio)        │
│                                         │
│  ┌──────────┐   ┌──────────┐           │
│  │ Usuários │   │   GPOs   │           │
│  └──────────┘   └──────────┘           │
│  ┌──────────┐   ┌──────────┐           │
│  │Computad. │   │  Grupos  │           │
│  └──────────┘   └──────────┘           │
└─────────────────────────────────────────┘
```

---

## 📦 1. Instalar as Funções (Roles)

```powershell
# Instalar AD DS, DNS e DHCP de uma vez
Install-WindowsFeature `
  -Name AD-Domain-Services, DNS, DHCP `
  -IncludeManagementTools `
  -Verbose
```

---

## 🌐 2. Promover o Servidor a Domain Controller

### Via PowerShell
```powershell
# Criar uma nova floresta/domínio
Install-ADDSForest `
  -DomainName "empresa.local" `
  -DomainNetbiosName "EMPRESA" `
  -ForestMode "WinThreshold" `
  -DomainMode "WinThreshold" `
  -InstallDns:$true `
  -DatabasePath "C:\Windows\NTDS" `
  -LogPath "C:\Windows\NTDS" `
  -SysvolPath "C:\Windows\SYSVOL" `
  -Force:$true
```

> ⚠️ O servidor irá **reiniciar automaticamente** ao final. Isso é esperado.

### Via Interface Gráfica (Server Manager)
```
1. Server Manager > Notificações (ícone de bandeira)
2. Clique em "Promover este servidor a controlador de domínio"
3. Selecione "Adicionar uma nova floresta"
4. Nome do domínio raiz: empresa.local
5. Nível funcional: Windows Server 2016 ou superior
6. Marque "Servidor DNS"
7. Defina a senha do DSRM (guarde em local seguro!)
8. Avance e clique em Instalar
```

---

## 👥 3. Estrutura Organizacional (OUs)

> OUs (Unidades Organizacionais) organizam usuários e computadores para facilitar aplicação de GPOs.

```powershell
# Criar estrutura de OUs
$domain = "DC=empresa,DC=local"

New-ADOrganizationalUnit -Name "Empresa"          -Path $domain
New-ADOrganizationalUnit -Name "Usuarios"         -Path "OU=Empresa,$domain"
New-ADOrganizationalUnit -Name "Computadores"     -Path "OU=Empresa,$domain"
New-ADOrganizationalUnit -Name "Servidores"       -Path "OU=Empresa,$domain"
New-ADOrganizationalUnit -Name "Grupos"           -Path "OU=Empresa,$domain"
New-ADOrganizationalUnit -Name "TI"               -Path "OU=Usuarios,OU=Empresa,$domain"
New-ADOrganizationalUnit -Name "Financeiro"       -Path "OU=Usuarios,OU=Empresa,$domain"
New-ADOrganizationalUnit -Name "RH"               -Path "OU=Usuarios,OU=Empresa,$domain"
```

---

## 👤 4. Criar Usuários e Grupos

```powershell
# Criar usuário
New-ADUser `
  -Name "João Silva" `
  -GivenName "João" `
  -Surname "Silva" `
  -SamAccountName "joao.silva" `
  -UserPrincipalName "joao.silva@empresa.local" `
  -Path "OU=TI,OU=Usuarios,OU=Empresa,DC=empresa,DC=local" `
  -AccountPassword (ConvertTo-SecureString "Senha@123" -AsPlainText -Force) `
  -Enabled $true `
  -ChangePasswordAtLogon $true

# Criar grupo de segurança
New-ADGroup `
  -Name "GRP-TI" `
  -GroupScope Global `
  -GroupCategory Security `
  -Path "OU=Grupos,OU=Empresa,DC=empresa,DC=local"

# Adicionar usuário ao grupo
Add-ADGroupMember -Identity "GRP-TI" -Members "joao.silva"
```

---

## 🌍 5. Configurar DNS

O DNS é instalado e configurado automaticamente com o AD DS. Verifique as zonas:

```powershell
# Listar zonas DNS
Get-DnsServerZone

# Criar registro A manualmente (se necessário)
Add-DnsServerResourceRecordA `
  -Name "fileserver" `
  -ZoneName "empresa.local" `
  -IPv4Address "192.168.1.20"

# Criar registro PTR (reverso)
Add-DnsServerResourceRecordPtr `
  -Name "20" `
  -ZoneName "1.168.192.in-addr.arpa" `
  -PtrDomainName "fileserver.empresa.local."
```

### Verificar resolução DNS
```powershell
Resolve-DnsName "empresa.local"
Resolve-DnsName "SRV-AD-01.empresa.local"
nslookup empresa.local
```

---

## 📡 6. Configurar DHCP

### 6.1 — Autorizar o servidor DHCP no AD
```powershell
Add-DhcpServerInDC -DnsName "SRV-AD-01.empresa.local" -IPAddress 192.168.1.10
```

### 6.2 — Criar escopo (Scope)
```powershell
# Criar escopo de endereços
Add-DhcpServerv4Scope `
  -Name "Rede Corporativa" `
  -StartRange 192.168.1.100 `
  -EndRange 192.168.1.200 `
  -SubnetMask 255.255.255.0 `
  -Description "Escopo principal da empresa" `
  -State Active

# Configurar opções do escopo (gateway e DNS)
Set-DhcpServerv4OptionValue `
  -ScopeId 192.168.1.0 `
  -Router 192.168.1.1 `
  -DnsServer 192.168.1.10 `
  -DnsDomain "empresa.local"
```

### 6.3 — Criar exclusões e reservas
```powershell
# Excluir IPs já usados por servidores/equipamentos fixos
Add-DhcpServerv4ExclusionRange `
  -ScopeId 192.168.1.0 `
  -StartRange 192.168.1.1 `
  -EndRange 192.168.1.50

# Criar reserva por MAC address (para impressoras, etc.)
Add-DhcpServerv4Reservation `
  -ScopeId 192.168.1.0 `
  -IPAddress 192.168.1.60 `
  -ClientId "AA-BB-CC-DD-EE-FF" `
  -Description "Impressora RH"
```

---

## 🖥️ 7. Ingressar Computadores no Domínio

```powershell
# No computador cliente (via PowerShell como Administrador)
Add-Computer `
  -DomainName "empresa.local" `
  -Credential (Get-Credential) `
  -Restart
```

Ou via **Sistema > Alterar configurações > Membro de Domínio**.

---

## ✅ Checklist de Conclusão

- [ ] AD DS instalado e configurado
- [ ] Domínio `empresa.local` criado
- [ ] Estrutura de OUs criada
- [ ] Usuários e grupos criados
- [ ] DNS funcional (resolução interna e externa)
- [ ] DHCP ativo e distribuindo endereços
- [ ] Pelo menos um computador ingressado no domínio

---

⬅️ Anterior: [02 — Rede / IP](02-rede.md) | ➡️ Próxima: [04 — GPO](04-gpo.md)