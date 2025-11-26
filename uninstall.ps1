<#
.SYNOPSIS
    Desinstalador da Ferramenta 'enviar'

.DESCRIPTION
    1. Remove os arquivos enviar.ps1 e enviar.cmd de C:\Bin
    2. Remove C:\Bin do PATH do usuário
    3. Remove a pasta C:\Bin se ela estiver vazia
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
$FilesToRemove = @("enviar.ps1", "enviar.cmd", ".ppgec_creds.xml")

Write-Host "=== INICIANDO DESINSTALAÇÃO ===" -ForegroundColor Cyan

# ==============================================================================
# 3. REMOVER ARQUIVOS
# ==============================================================================
foreach ($File in $FilesToRemove) {
    $FilePath = Join-Path $InstallDir $File
    if (Test-Path $FilePath) {
        Remove-Item -Path $FilePath -Force
        Write-Host "[REMOVIDO] $File apagado com sucesso." -ForegroundColor Green
    } else {
        Write-Host "[INFO] $File não encontrado (já removido?)." -ForegroundColor DarkGray
    }
}

# ==============================================================================
# 4. LIMPAR O PATH DO WINDOWS
# ==============================================================================
$CurrentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)

# Verifica se o caminho está no PATH (case insensitive)
if ($CurrentPath -like "*$InstallDir*") {
    # Remove C:\Bin e possíveis ponto-e-vírgulas extras
    $NewPath = $CurrentPath.Replace("$InstallDir;", "").Replace(";$InstallDir", "").Replace("$InstallDir", "")

    [Environment]::SetEnvironmentVariable("Path", $NewPath, [EnvironmentVariableTarget]::User)
    Write-Host "[LIMPO] $InstallDir removido do PATH do usuário." -ForegroundColor Green
} else {
    Write-Host "[INFO] O PATH já está limpo." -ForegroundColor Yellow
}

# ==============================================================================
# 5. REMOVER A PASTA (SE ESTIVER VAZIA)
# ==============================================================================
if (Test-Path $InstallDir) {
    $RemainingFiles = Get-ChildItem -Path $InstallDir
    if ($RemainingFiles.Count -eq 0) {
        Remove-Item -Path $InstallDir -Force
        Write-Host "[REMOVIDO] Pasta $InstallDir apagada (estava vazia)." -ForegroundColor Green
    } else {
        Write-Host "[AVISO] A pasta $InstallDir contém outros arquivos e NÃO foi removida." -ForegroundColor Yellow
        Write-Host "Arquivos restantes: $($RemainingFiles.Name -join ', ')"
    }
}

# ==============================================================================
# 6. FINALIZAÇÃO
# ==============================================================================
Write-Host ""
Write-Host "DESINSTALAÇÃO CONCLUÍDA!" -ForegroundColor Cyan
Write-Host "---------------------------------------------------"
Write-Host "O comando 'enviar' não estará mais disponível após reiniciar o terminal."
Write-Host "---------------------------------------------------"
Pause