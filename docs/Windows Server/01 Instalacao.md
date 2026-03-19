# 01 — Instalação do Windows Server
Público: Técnico | Tempo estimado: 1–2 horas



> **Público:** Técnico | **Tempo estimado:** 1–2 horas

---

## 📋 Pré-requisitos de Hardware

| Componente | Mínimo | Recomendado |
|------------|--------|-------------|
| CPU |  GHz 64-bit | 2.0 GHz+ / 4+ núcleos |
| RAM | 16 GB  |
| Disco | ** GB | 120 GB+ (SSD) |
| Rede | 1 adaptador Ethernet | 

---

## 🔽 1. Download da ISO

1. Acesse o [Microsoft Evaluation Center](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022)
2. Faça login com sua conta Microsoft
3. Escolha **ISO** como formato de download
4. Selecione o idioma desejado (**Português (Brasil)**)

> 💡 Para ambiente de produção, utilize a mídia fornecida com sua licença volumétrica (VLSC).

---

## 💿 2. Criação da Mídia de Boot

### Via Rufus (recomendado para USB)
```
1. Baixe o Rufus em https://rufus.ie
2. Insira um pendrive de 8 GB+
3. Selecione a ISO baixada
4. Esquema de partição: GPT (para UEFI) ou MBR (para BIOS legado)
5. Clique em INICIAR
```
---

## ⚙️ 3. Configuração da BIOS/UEFI

1. Acesse a BIOS/UEFI na inicialização (geralmente `F2`, `DEL` ou `F10`)
2. Configure a ordem de boot: **USB/DVD primeiro**
3. Habilite **UEFI Boot** (desabilite CSM/Legacy se possível)
4. Habilite **Virtualization Technology (VT-x / AMD-V)** se for usar Hyper-V
5. Salve e reinicie

---

## 🖥️ 4. Processo de Instalação

### Passo a passo

**4.1 — Tela inicial**
- Idioma: Português (Brasil)
- Formato de hora: Português (Brasil)
- Teclado: ABNT2

**4.2 — Tipo de instalação**
- Selecione **Instalação personalizada** (nova instalação limpa)

**4.3 — Edição do Windows Server**

| Edição | Quando usar |
|--------|-------------|
| Standard (Experiência Desktop) | Ambiente com interface gráfica 

> ✅ Para esta documentação, usaremos **Standard com Experiência Desktop**.

**4.4 — Particionamento do disco**

```
Disco 0 — Exemplo de particionamento recomendado:
┌─────────────────┬──────────┬──────────────────────┐
│ Partição        │ Tamanho  │ Uso                  │
├─────────────────┼──────────┼──────────────────────┤
│ Sistema (EFI)   │ 100 MB   │ Boot UEFI            │
│ MSR             │ 16 MB    │ Reservada Microsoft  │
│ Windows (C:\)   │ 80 GB+   │ Sistema Operacional  │
└─────────────────┴──────────┴──────────────────────┘
```

**4.5 — Aguardar instalação**
- O servidor irá reiniciar automaticamente 2–3 vezes
- Tempo médio: 20–40 minutos

---

## 🔐 5. Configuração Inicial Pós-instalação

### 5.1 — Definir senha do Administrador
```
A senha deve conter:
✅ Mínimo 8 caracteres
✅ Letras maiúsculas e minúsculas
✅ Números
✅ Caracteres especiais (!@#$%)
```

### 5.2 — Alterar nome do servidor
```powershell
# Via PowerShell
Rename-Computer -NewName "SRViFixTech" -Restart
```
Ou via **Painel de Controle > Sistema > Alterar configurações**.

### 5.3 — Ativar o Windows
```powershell
# Verificar status de ativação
slmgr /xpr

# Ativar com chave de produto (KMS ou MAK)
slmgr /ipk XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
slmgr /ato
```

### 5.4 — Instalar atualizações
```powershell
# Via PowerShell (instalar módulo se necessário)
Install-Module PSWindowsUpdate -Force
Get-WindowsUpdate -Install -AcceptAll -AutoReboot
```
Ou via **Configurações > Windows Update**.

### 5.5 — Instalar drivers e VMware/Hyper-V Tools (se VM)
- **VMware:** Instalar VMware Tools pelo menu da VM
- **Hyper-V:** Integration Services já incluído no Windows Server 2022
