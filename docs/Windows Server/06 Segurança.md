# 06 — Segurança e Firewall

> **Público:** Técnico | **Tempo estimado:** 2–3 horas

---

## 🔐 Visão Geral de Segurança

A segurança do servidor deve ser pensada em camadas:

```
┌─────────────────────────────────────┐
│         Monitoramento e Logs        │  ← Camada 5
├─────────────────────────────────────┤
│      Controle de Acesso (AD/GPO)    │  ← Camada 4
├─────────────────────────────────────┤
│         Firewall do Windows         │  ← Camada 3
├─────────────────────────────────────┤
│         Hardening do Sistema        │  ← Camada 2
├─────────────────────────────────────┤
│      Segurança Física / Rede        │  ← Camada 1
└─────────────────────────────────────┘
```

---

## 🔥 1. Firewall do Windows

### 1.1 — Verificar status
```powershell
Get-NetFirewallProfile | Select-Object Name, Enabled
```

### 1.2 — Ativar firewall em todos os perfis
```powershell
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True
```

### 1.3 — Regras essenciais — o que LIBERAR
```powershell
# RDP (apenas da rede interna)
New-NetFirewallRule `
  -DisplayName "RDP - Rede Interna" `
  -Direction Inbound `
  -Protocol TCP `
  -LocalPort 3389 `
  -RemoteAddress 192.168.1.0/24 `
  -Action Allow

# ICMP (Ping) - rede interna
New-NetFirewallRule `
  -DisplayName "Ping - Rede Interna" `
  -Direction Inbound `
  -Protocol ICMPv4 `
  -RemoteAddress 192.168.1.0/24 `
  -Action Allow

# SMB (Compartilhamento de arquivos)
New-NetFirewallRule `
  -DisplayName "SMB - Rede Interna" `
  -Direction Inbound `
  -Protocol TCP `
  -LocalPort 445 `
  -RemoteAddress 192.168.1.0/24 `
  -Action Allow

# DNS
New-NetFirewallRule `
  -DisplayName "DNS - Entrada" `
  -Direction Inbound `
  -Protocol UDP `
  -LocalPort 53 `
  -Action Allow

# DHCP
New-NetFirewallRule `
  -DisplayName "DHCP - Servidor" `
  -Direction Inbound `
  -Protocol UDP `
  -LocalPort 67 `
  -Action Allow
```

### 1.4 — O que BLOQUEAR
```powershell
# Bloquear acesso RDP de fora da rede
New-NetFirewallRule `
  -DisplayName "BLOQUEAR RDP Externo" `
  -Direction Inbound `
  -Protocol TCP `
  -LocalPort 3389 `
  -RemoteAddress Internet `
  -Action Block

# Bloquear Telnet
New-NetFirewallRule `
  -DisplayName "BLOQUEAR Telnet" `
  -Direction Inbound `
  -Protocol TCP `
  -LocalPort 23 `
  -Action Block
```

### 1.5 — Listar regras ativas
```powershell
Get-NetFirewallRule | Where-Object Enabled -eq True | 
  Select-Object DisplayName, Direction, Action | 
  Format-Table -AutoSize
```

---

## 🛡️ 2. Hardening do Sistema

### 2.1 — Desabilitar serviços desnecessários
```powershell
# Serviços que geralmente podem ser desabilitados em servidores
$servicesToDisable = @(
  "XblGameSave",      # Xbox
  "XboxNetApiSvc",    # Xbox
  "WMPNetworkSvc",    # Windows Media Player
  "Fax",              # Fax
  "lfsvc"             # Geolocalização
)

foreach ($svc in $servicesToDisable) {
  Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
  Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
}
```

### 2.2 — Renomear conta Administrador
```powershell
# Via GPO: Configuração do Computador > Políticas > Configurações do Windows
#          > Configurações de Segurança > Políticas Locais > Opções de Segurança
#          > Contas: Renomear conta de administrador = adm_local

Rename-LocalUser -Name "Administrator" -NewName "adm_local"
```

### 2.3 — Desabilitar conta Guest
```powershell
Disable-LocalUser -Name "Guest"
```

### 2.4 — Habilitar auditoria de eventos
```powershell
# Via GPO ou secpol.msc
# Habilitar auditoria de logon, acesso a objetos, mudanças de política

auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Account Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Account Management" /success:enable /failure:enable
auditpol /set /subcategory:"Policy Change" /success:enable /failure:enable
```

### 2.5 — Configurar NTP (Sincronização de Hora)
```powershell
# Configurar servidor de hora externo
w32tm /config /manualpeerlist:"a.st1.ntp.br b.st1.ntp.br" /syncfromflags:manual /reliable:YES /update
net stop w32tm && net start w32tm
w32tm /resync /force
```

---

## 🔑 3. Controle de Acesso Privilegiado

### 3.1 — Princípio do menor privilégio
```
✅ Usuários comuns: apenas Domain Users
✅ Suporte de TI: grupo local "Remote Desktop Users"
✅ Administradores de TI: grupo "Domain Admins" (com parcimônia)
✅ Operações rotineiras: nunca usar conta de Administrador de domínio
```

### 3.2 — Criar conta de serviço separada
```powershell
# Criar conta de serviço dedicada para aplicações
New-ADUser `
  -Name "svc-backup" `
  -SamAccountName "svc-backup" `
  -UserPrincipalName "svc-backup@empresa.local" `
  -Path "OU=Servicos,OU=Empresa,DC=empresa,DC=local" `
  -AccountPassword (ConvertTo-SecureString "SenhaForte@Srv123" -AsPlainText -Force) `
  -PasswordNeverExpires $true `
  -CannotChangePassword $true `
  -Enabled $true
```

---

## 📋 4. Monitoramento de Logs

### 4.1 — Eventos críticos para monitorar

| ID do Evento | Descrição |
|-------------|-----------|
| 4625 | Falha de logon |
| 4624 | Logon bem-sucedido |
| 4720 | Conta de usuário criada |
| 4726 | Conta de usuário excluída |
| 4732 | Membro adicionado a grupo privilegiado |
| 4740 | Conta bloqueada |
| 1102 | Log de auditoria apagado |

### 4.2 — Verificar logs via PowerShell
```powershell
# Ver tentativas de logon com falha (últimas 24h)
Get-EventLog -LogName Security -InstanceId 4625 -Newest 50 |
  Select-Object TimeGenerated, Message |
  Format-List

# Ver contas bloqueadas
Search-ADAccount -LockedOut | Select-Object Name, LockedOut, LastLogonDate

# Desbloquear conta
Unlock-ADAccount -Identity "joao.silva"
```

### 4.3 — Aumentar tamanho dos logs de eventos
```powershell
# Aumentar limite do log de Segurança para 512 MB
wevtutil sl Security /ms:524288000
wevtutil sl System /ms:104857600
wevtutil sl Application /ms:104857600
```

---

## 🛡️ 5. Windows Defender (Antivírus)

```powershell
# Verificar status do Windows Defender
Get-MpComputerStatus

# Atualizar definições de vírus
Update-MpSignature

# Executar varredura rápida
Start-MpScan -ScanType QuickScan

# Executar varredura completa
Start-MpScan -ScanType FullScan
```

---

## ✅ Checklist de Conclusão

- [ ] Firewall habilitado nos três perfis
- [ ] Regras de firewall revisadas e documentadas
- [ ] Serviços desnecessários desabilitados
- [ ] Conta Administrador renomeada
- [ ] Conta Guest desabilitada
- [ ] Auditoria de eventos habilitada
- [ ] Sincronização de hora configurada (NTP)
- [ ] Windows Defender ativo e atualizado
- [ ] Logs monitorados

---

⬅️ Anterior: [05 — Serviços](05-servicos.md) | ➡️ Próxima: [07 — Backup e Recuperação](07-backup.md)