# 07 — Backup e Recuperação

> **Público:** Técnico e Gestores | **Tempo estimado:** 1–2 horas (configuração)

---

## 🎯 Estratégia de Backup — Regra 3-2-1

> Uma boa estratégia de backup segue a regra **3-2-1**:

```
3 cópias dos dados
  ↓
2 mídias diferentes (ex: disco local + NAS)
  ↓
1 cópia off-site (fora da empresa ou nuvem)
```

---

## 📅 Tipos de Backup

| Tipo | Descrição | Frequência sugerida |
|------|-----------|---------------------|
| **Completo** | Cópia integral de todos os dados | Semanal (fim de semana) |
| **Incremental** | Apenas o que mudou desde o último backup | Diário |
| **Diferencial** | O que mudou desde o último backup completo | Diário |
| **Estado do Sistema** | AD, Registro, arquivos do sistema | Diário |

---

## 💾 1. Windows Server Backup (nativo)

### 1.1 — Instalar
```powershell
Install-WindowsFeature -Name Windows-Server-Backup -IncludeManagementTools
```

### 1.2 — Backup completo do servidor
```powershell
# Backup de todo o servidor para disco externo (ex: E:\)
$policy = New-WBPolicy
$backupLocation = New-WBBackupTarget -VolumePath "E:"
Add-WBBackupTarget -Policy $policy -Target $backupLocation

# Adicionar estado do sistema
Add-WBSystemState -Policy $policy

# Adicionar todos os volumes
$volumes = Get-WBVolume -AllVolumes
Add-WBVolume -Policy $policy -Volume $volumes

# Agendar backup diário às 23h
Set-WBSchedule -Policy $policy -Schedule 23:00

# Aplicar política
Set-WBPolicy -Policy $policy
```

### 1.3 — Backup manual via PowerShell
```powershell
# Backup do estado do sistema (AD)
$policy = New-WBPolicy
Add-WBSystemState -Policy $policy
$target = New-WBBackupTarget -VolumePath "E:"
Add-WBBackupTarget -Policy $policy -Target $target

Start-WBBackup -Policy $policy
```

### 1.4 — Verificar status do backup
```powershell
# Ver histórico de backups
Get-WBSummary

# Ver jobs agendados
Get-WBJob -Previous 10
```

---

## 🔄 2. Backup do Active Directory

### 2.1 — Estado do Sistema (System State)
```powershell
# O backup do estado do sistema inclui automaticamente:
# ✅ Base de dados do AD (NTDS.dit)
# ✅ SYSVOL
# ✅ Registro do sistema
# ✅ Arquivos de boot

# Agendar backup diário do System State
$policy = New-WBPolicy
Add-WBSystemState -Policy $policy
$target = New-WBBackupTarget -NetworkPath "\\SRV-BACKUP\Backups\AD" `
  -Credential (Get-Credential)
Add-WBBackupTarget -Policy $policy -Target $target
Set-WBSchedule -Policy $policy -Schedule 02:00
Set-WBPolicy -Policy $policy
```

---

## ☁️ 3. Backup para Nuvem (Azure Backup)

### 3.1 — Pré-requisitos
```
1. Conta Azure com assinatura ativa
2. Recovery Services Vault criado no portal Azure
3. Agente MARS instalado no servidor
```

### 3.2 — Instalar agente MARS
```powershell
# Baixar de: https://aka.ms/azurebackup_agent
# Execute o instalador e registre no vault

# Após registro, agende via interface do agente ou PowerShell:
Start-OBRegistration
```

### 3.3 — Política de retenção sugerida para Azure
```
Backup diário:    retenção de 30 dias
Backup semanal:   retenção de 12 semanas
Backup mensal:    retenção de 12 meses
Backup anual:     retenção de 3 anos
```

---

## 🗂️ 4. Backup de Compartilhamentos (File Server)

```powershell
# Script de backup simples com Robocopy
$origem = "D:\Compartilhados"
$destino = "\\SRV-BACKUP\Backups\FileServer"
$log     = "C:\Logs\backup-$(Get-Date -Format 'yyyy-MM-dd').log"

robocopy $origem $destino /MIR /COPYALL /R:3 /W:10 /LOG:$log /TEE

# Agendar via Task Scheduler
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
  -Argument "-File C:\Scripts\backup-files.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At "01:00"
Register-ScheduledTask -TaskName "Backup-FileServer" `
  -Action $action -Trigger $trigger -RunLevel Highest
```

---

## 🔁 5. Restauração

### 5.1 — Restaurar arquivos específicos
```powershell
# Listar versões disponíveis de backup
Get-WBBackupSet

# Iniciar restauração de pasta específica
$backupSet = Get-WBBackupSet | Select-Object -Last 1
Start-WBFileRecovery `
  -BackupSet $backupSet `
  -SourcePath "D:\Compartilhados\Financeiro" `
  -TargetPath "D:\Restaurado\Financeiro" `
  -Overwrite
```

### 5.2 — Restaurar Estado do Sistema (AD)
```
⚠️ Este processo requer reinicialização em Modo de Restauração do AD (DSRM)

1. Reinicie o servidor e pressione F8
2. Selecione "Directory Services Restore Mode"
3. Faça login com a senha DSRM definida na instalação
4. Abra o cmd como administrador:

wbadmin start systemstaterecovery -backupTarget:E: -authsysvol

5. Reinicie normalmente após a restauração
```

### 5.3 — Restaurar VM completa (se ambiente virtualizado)
```
VMware: Snapshots ou integração com Veeam
Hyper-V: Checkpoints ou Windows Server Backup com Hyper-V role
Azure: Recovery Services > Restore VM
```

---

## 📊 6. Testando o Backup (Fundamental!)

> ⚠️ **Um backup não testado não é um backup.** Agende testes periódicos de restauração.

```
Checklist de teste mensal:
✅ Restaurar arquivo aleatório e verificar integridade
✅ Verificar logs de backup (sem erros)
✅ Confirmar espaço disponível no destino de backup
✅ Testar acesso ao backup off-site/nuvem
✅ Documentar tempo de restauração (RTO)
```

---

## 📋 7. Documentação de Recuperação de Desastres (DR)

| Métrica | Definição | Meta |
|---------|-----------|------|
| **RPO** (Recovery Point Objective) | Quanto de dados posso perder? | Máx. 24h |
| **RTO** (Recovery Time Objective) | Em quanto tempo preciso restaurar? | Máx. 4h |

---

## ✅ Checklist de Conclusão

- [ ] Windows Server Backup instalado
- [ ] Backup do Estado do Sistema agendado
- [ ] Backup dos compartilhamentos agendado
- [ ] Destino off-site ou nuvem configurado
- [ ] Primeiro backup completo executado com sucesso
- [ ] Teste de restauração realizado
- [ ] RPO e RTO documentados

---

⬅️ Anterior: [06 — Segurança e Firewall](06-seguranca.md)

---

## 🎉 Parabéns!

Você concluiu a implantação completa do Windows Server. O ambiente está pronto para produção.

> 📌 Lembre-se de manter esta documentação atualizada conforme o ambiente evoluir.