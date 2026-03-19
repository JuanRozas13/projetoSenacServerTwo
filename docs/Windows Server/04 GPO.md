# 04 — GPO (Group Policy Objects)

> **Público:** Técnico | **Tempo estimado:** 1–3 horas (conforme complexidade)

---

## 📖 O que são GPOs?

**Group Policy Objects (GPOs)** são conjuntos de configurações aplicadas automaticamente a usuários e computadores dentro do domínio. Com GPOs, você controla:

- Configurações de segurança
- Mapeamento de drives e impressoras
- Papel de parede e personalização
- Restrições de acesso a software e sistema
- Scripts de logon/logoff

---

## 🛠️ 1. Ferramentas de Gerenciamento

```powershell
# Instalar Console de Gerenciamento de Política de Grupo (GPMC)
Install-WindowsFeature -Name GPMC -IncludeManagementTools
```

Acesse via: **Ferramentas > Gerenciamento de Política de Grupo** (Server Manager) ou `gpmc.msc`.

---

## 📋 2. Criar e Vincular uma GPO

### Via PowerShell
```powershell
# Criar GPO
New-GPO -Name "GPO-Seguranca-Usuarios" -Comment "Políticas de segurança para usuários"

# Vincular GPO a uma OU
New-GPLink `
  -Name "GPO-Seguranca-Usuarios" `
  -Target "OU=Usuarios,OU=Empresa,DC=empresa,DC=local" `
  -Enforced No
```

### Via Interface Gráfica
```
1. Abra gpmc.msc
2. Expanda: Floresta > Domínios > empresa.local
3. Clique com botão direito na OU desejada
4. Selecione "Criar um GPO neste domínio e vinculá-lo aqui"
5. Dê um nome descritivo e clique OK
6. Clique com botão direito no GPO > Editar
```

---

## 🔒 3. GPOs de Segurança Recomendadas

### 3.1 — Política de Senha
```
Configuração: Configuração do Computador > Políticas > Configurações do Windows
             > Configurações de Segurança > Políticas de Conta > Política de Senha

Recomendações:
✅ Comprimento mínimo da senha: 10 caracteres
✅ A senha deve atender aos requisitos de complexidade: Habilitado
✅ Idade máxima da senha: 90 dias
✅ Idade mínima da senha: 1 dia
✅ Impor histórico de senhas: 10 senhas lembradas
```

```powershell
# Via PowerShell
Set-ADDefaultDomainPasswordPolicy `
  -Identity "empresa.local" `
  -MinPasswordLength 10 `
  -ComplexityEnabled $true `
  -MaxPasswordAge "90.00:00:00" `
  -MinPasswordAge "1.00:00:00" `
  -PasswordHistoryCount 10
```

### 3.2 — Bloqueio de Conta
```
Política de Bloqueio de Conta:
✅ Limite de bloqueio de conta: 5 tentativas
✅ Duração do bloqueio: 30 minutos
✅ Zerar contador após: 30 minutos
```

### 3.3 — Bloqueio de USB (Dispositivos Removíveis)
```
Configuração do Usuário > Políticas > Modelos Administrativos
> Sistema > Acesso ao Armazenamento Removível

✅ Todas as classes de armazenamento removível: Negar todos os acessos = Habilitado
```

### 3.4 — Desabilitar Painel de Controle para usuários
```
Configuração do Usuário > Políticas > Modelos Administrativos
> Painel de Controle

✅ Proibir acesso ao Painel de Controle e às configurações do PC = Habilitado
```

### 3.5 — Tempo de tela bloqueada
```
Configuração do Computador > Políticas > Configurações do Windows
> Configurações de Segurança > Políticas Locais > Opções de Segurança

✅ Logon Interativo: Limite de inatividade do computador = 600 segundos (10 min)
```

---

## 🗺️ 4. Mapear Drives de Rede via GPO

```
Configuração do Usuário > Preferências > Configurações do Windows > Mapeamentos de Unidade

1. Botão direito > Novo > Unidade Mapeada
2. Ação: Criar
3. Local: \\SRV-FILE-01\Compartilhado
4. Letra da unidade: Z:
5. Reconectar: Sim

Targeting (filtros por grupo):
- Item-level Targeting > Grupo de Segurança > GRP-Financeiro
```

---

## 🖨️ 5. Mapear Impressoras via GPO

```
Configuração do Usuário > Políticas > Configurações do Windows
> Implantação de Impressora

1. Adicione a impressora compartilhada
2. Defina como padrão se necessário
3. Use Item-Level Targeting para segmentar por OU ou grupo
```

---

## 🖼️ 6. Papel de Parede Corporativo

```
Configuração do Usuário > Políticas > Modelos Administrativos
> Área de Trabalho > Área de Trabalho

✅ Papel de parede da área de trabalho:
   Caminho: \\SRV-AD-01\NETLOGON\wallpaper.jpg
   Estilo: Preenchimento
```

---

## 📜 7. Scripts de Logon

```powershell
# Criar script de logon em NETLOGON
# Caminho: \\empresa.local\NETLOGON\logon.bat ou logon.ps1

# Exemplo: logon.ps1
# Mapear drive
New-PSDrive -Name Z -PSProvider FileSystem -Root "\\SRV-FILE-01\Dados" -Persist

# Sincronizar hora
w32tm /resync
```

```
GPO: Configuração do Usuário > Políticas > Configurações do Windows > Scripts > Fazer Logon
Adicione o script logon.ps1
```

---

## 🔄 8. Forçar Atualização de GPO

```powershell
# No servidor — atualizar todos os clientes remotamente
Invoke-GPUpdate -Computer "PC-USUARIO-01" -Force -RandomDelayInMinutes 0

# No próprio cliente
gpupdate /force

# Verificar GPOs aplicadas no cliente
gpresult /r
gpresult /h C:\relatorio-gpo.html
```

---

## 📊 9. Ordem de Aplicação e Herança

```
Ordem de processamento (última tem precedência):
1. Local (GPO local do computador)
2. Site
3. Domínio
4. OUs (da mais externa para a mais interna)

Dicas:
- "Enforced" (Forçado): GPO não pode ser bloqueada por OUs filhas
- "Block Inheritance" (Bloquear Herança): OU ignora GPOs de OUs acima
```

---

## ✅ Checklist de Conclusão

- [ ] GPMC instalado
- [ ] GPO de política de senha configurada
- [ ] GPO de bloqueio de conta configurada
- [ ] GPO de segurança (USB, Painel de Controle) configurada
- [ ] Drives de rede mapeados via GPO
- [ ] Scripts de logon configurados (se necessário)
- [ ] GPOs testadas com `gpresult /r` em cliente

---

⬅️ Anterior: [03 — Active Directory](03-active-directory.md) | ➡️ Próxima: [05 — Serviços e Aplicações](05-servicos.md)