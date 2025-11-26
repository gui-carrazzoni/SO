<#
.SYNOPSIS
    Instalador Automático da Ferramenta 'enviar'

.DESCRIPTION
    1. Cria a pasta C:\Bin
    2. Copia o script enviar.ps1
    3. Cria o wrapper enviar.cmd (para rodar como comando global)
    4. Adiciona ao PATH do usuário
#>

# ==============================================================================
# 1. VERIFICAÇÃO DE ADMINISTRADOR
# ==============================================================================
$Principal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERRO: Este script precisa ser executado como ADMINISTRADOR." -ForegroundColor Red
    Write-Host "Por favor, clique com o botão direito e selecione 'Executar como Administrador'."
    Pause
    exit
}

# ==============================================================================
# 2. CONFIGURAÇÕES
# ==============================================================================
$InstallDir = "C:\Bin"
$SourceScript = Join-Path $PSScriptRoot "enviar.ps1"
$DestScript   = Join-Path $InstallDir "enviar.ps1"
$WrapperFile  = Join-Path $InstallDir "enviar.cmd"

Write-Host "=== INICIANDO INSTALAÇÃO ===" -ForegroundColor Cyan

# ==============================================================================
# 3. CRIAR DIRETÓRIO
# ==============================================================================
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Write-Host "[OK] Pasta $InstallDir criada." -ForegroundColor Green
} else {
    Write-Host "[OK] Pasta $InstallDir já existe." -ForegroundColor Yellow
}

# ==============================================================================
# 4. COPIAR O SCRIPT PRINCIPAL
# ==============================================================================
if (Test-Path $SourceScript) {
    Copy-Item -Path $SourceScript -Destination $DestScript -Force
    Write-Host "[OK] Script copiado para $DestScript" -ForegroundColor Green
} else {
    Write-Error "Arquivo 'enviar.ps1' não encontrado na pasta atual. Você clonou o repositório?"
    Pause
    exit
}

# ==============================================================================
# 5. CRIAR O COMANDO 'WRAPPER' (.cmd)
# ==============================================================================
# Isso cria o arquivo que permite chamar apenas 'enviar' e burla a ExecutionPolicy
$CmdContent = @"
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$DestScript" %*
"@

Set-Content -Path $WrapperFile -Value $CmdContent -Encoding ASCII
Write-Host "[OK] Comando global 'enviar' criado." -ForegroundColor Green

# ==============================================================================
# 6. ATUALIZAR O PATH DO WINDOWS
# ==============================================================================
$CurrentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)

if ($CurrentPath -notlike "*$InstallDir*") {
    $NewPath = "$CurrentPath;$InstallDir"
    [Environment]::SetEnvironmentVariable("Path", $NewPath, [EnvironmentVariableTarget]::User)
    Write-Host "[OK] $InstallDir adicionado ao PATH do usuário." -ForegroundColor Green
} else {
    Write-Host "[INFO] O PATH já está configurado." -ForegroundColor Yellow
}

# ==============================================================================
# 7. FINALIZAÇÃO
# ==============================================================================
Write-Host ""
Write-Host "INSTALAÇÃO CONCLUÍDA COM SUCESSO!" -ForegroundColor Cyan
Write-Host "---------------------------------------------------"
Write-Host "IMPORTANTE: Feche este terminal e abra um novo para usar o comando."
Write-Host "Teste digitando: enviar -Help"
Write-Host "---------------------------------------------------"
Pause