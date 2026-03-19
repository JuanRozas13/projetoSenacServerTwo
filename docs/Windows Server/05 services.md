# 05 — Serviços e Aplicações

> **Público:** Técnico | **Tempo estimado:** 2–4 horas (conforme serviços escolhidos)

---

## 📦 Serviços Abordados

| Serviço | Função |
|---------|--------|
| File Server | Compartilhamento de arquivos na rede |
| Print Server | Gerenciamento centralizado de impressoras |
| IIS | Hospedagem de sites e aplicações web |
| Remote Desktop Services | Acesso remoto para usuários |
| Windows Admin Center | Administração web do servidor |

---

## 📁 1. File Server (Servidor de Arquivos)

### 1.1 — Instalar a função
```powershell
Install-WindowsFeature -Name FS-FileServer -IncludeManagementTools
```

### 1.2 — Criar compartilhamentos
```powershell
# Criar pasta
New-Item -Path "D:\Compartilhados\Financeiro" -ItemType Directory

# Compartilhar pasta
New-SmbShare `
  -Name "Financeiro" `
  -Path "D:\Compartilhados\Financeiro" `
  -Description "Arquivos do setor Financeiro" `
  -FullAccess "EMPRESA\GRP-TI" `
  -ChangeAccess "EMPRESA\GRP-Financeiro" `
  -ReadAccess "EMPRESA\Domain Users"

# Verificar compartilhamentos
Get-SmbShare
```

### 1.3 — Configurar permissões NTFS
```powershell
$acl = Get-Acl "D:\Compartilhados\Financeiro"

# Adicionar permissão para grupo Financeiro
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
  "EMPRESA\GRP-Financeiro", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow"
)
$acl.SetAccessRule($rule)
Set-Acl -Path "D:\Compartilhados\Financeiro" -AclObject $acl
```

### 1.4 — Quotas de disco
```powershell
# Habilitar quota no volume D:\
$quota = New-FsrmQuotaTemplate `
  -Name "Quota-5GB" `
  -Size 5GB `
  -SoftLimit

New-FsrmQuota -Path "D:\Compartilhados\Financeiro" -Template "Quota-5GB"
```

---

## 🖨️ 2. Print Server (Servidor de Impressão)

### 2.1 — Instalar a função
```powershell
Install-WindowsFeature -Name Print-Server -IncludeManagementTools
```

### 2.2 — Adicionar impressora
```powershell
# Adicionar porta de impressora TCP/IP
Add-PrinterPort -Name "IP_192.168.1.50" -PrinterHostAddress "192.168.1.50"

# Instalar driver (exemplo: HP Universal)
Add-PrinterDriver -Name "HP Universal Printing PCL 6"

# Adicionar impressora compartilhada
Add-Printer `
  -Name "Impressora-RH" `
  -DriverName "HP Universal Printing PCL 6" `
  -PortName "IP_192.168.1.50" `
  -Shared `
  -ShareName "IMP-RH" `
  -Published $true
```

---

## 🌐 3. IIS — Internet Information Services

### 3.1 — Instalar IIS
```powershell
Install-WindowsFeature `
  -Name Web-Server, Web-Mgmt-Console, Web-Asp-Net45 `
  -IncludeManagementTools
```

### 3.2 — Criar site
```powershell
# Criar diretório do site
New-Item -Path "C:\inetpub\intranet" -ItemType Directory

# Criar site no IIS
New-WebSite `
  -Name "Intranet" `
  -Port 80 `
  -PhysicalPath "C:\inetpub\intranet" `
  -HostHeader "intranet.empresa.local"
```

### 3.3 — Testar IIS
```
1. Abra o navegador no servidor
2. Acesse: http://localhost
3. Deve exibir a página padrão do IIS
```

---

## 🖥️ 4. Remote Desktop Services (RDS)

> Permite que usuários acessem o servidor remotamente via área de trabalho.

### 4.1 — Habilitar RDP
```powershell
# Habilitar RDP
Set-ItemProperty `
  -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" `
  -Name "fDenyTSConnections" `
  -Value 0

# Habilitar no firewall
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Adicionar usuários com permissão de RDP
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "EMPRESA\GRP-TI"
```

### 4.2 — Configurar NLA (autenticação de nível de rede)
```powershell
# Habilitar NLA (mais seguro)
Set-ItemProperty `
  -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" `
  -Name "UserAuthentication" `
  -Value 1
```

---

## 🔧 5. Windows Admin Center

> Interface web moderna para administração do servidor (alternativa ao Server Manager).

### 5.1 — Instalar
```powershell
# Baixar e instalar o Windows Admin Center
# Download: https://aka.ms/WindowsAdminCenter
# Execute o instalador e siga o assistente
# Porta padrão: 443 (HTTPS)
```

### 5.2 — Acessar
```
https://SRV-AD-01 (no navegador de qualquer máquina na rede)
```

---

## 📊 6. Monitoramento de Recursos

```powershell
# CPU, Memória e Disco em tempo real
Get-Counter '\Processor(_Total)\% Processor Time'
Get-Counter '\Memory\Available MBytes'
Get-Counter '\PhysicalDisk(_Total)\% Disk Time'

# Processos que mais consomem CPU
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

# Espaço em disco
Get-PSDrive -PSProvider FileSystem | Select-Object Name, Used, Free
```

---

## ✅ Checklist de Conclusão

- [ ] File Server configurado com compartilhamentos e permissões
- [ ] Quotas de disco definidas
- [ ] Print Server com impressoras publicadas
- [ ] IIS instalado e site de teste funcionando
- [ ] RDP habilitado e restrito a grupos autorizados
- [ ] Windows Admin Center instalado (opcional)

---

⬅️ Anterior: [04 — GPO](04-gpo.md) | ➡️ Próxima: [06 — Segurança e Firewall](06-seguranca.md)