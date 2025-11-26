<#
.SYNOPSIS
    Automação de Envio de Documentos/e-mails PPGEC
#>

param (
    [string]$AlunosFile,
    [string]$DocsPath,
    [switch]$DryRun,
    [switch]$ResetCreds,
    [switch]$Help,
    [switch]$Update
)
# ==============================================================================
# 0. VERSIONAMENTO E AUTO-UPDATE
# ==============================================================================
$Version = "1.0.0"
$RepoUrl = "https://raw.githubusercontent.com/gui-carrazzoni/SO/main/enviar.ps1"

function Check-Update {
    Write-Host "Verificando atualizações..." -ForegroundColor Gray
    try {
        # 1. Baixa o código do GitHub (apenas texto)
        $WebClient = New-Object System.Net.WebClient
        $RemoteContent = $WebClient.DownloadString($RepoUrl)

        # 2. Usa Regex para achar a versão no código remoto
        if ($RemoteContent -match '\$Version\s*=\s*"([\d\.]+)"') {
            $RemoteVersion = [System.Version]$matches[1]
            $LocalVersion  = [System.Version]$Version

            if ($RemoteVersion -gt $LocalVersion) {
                Write-Host "Nova versão encontrada: $RemoteVersion (Atual: $LocalVersion)" -ForegroundColor Green
                Write-Host "Atualizando..." -NoNewline

                # 3. Sobrescreve o próprio arquivo
                Set-Content -Path $PSCommandPath -Value $RemoteContent -Encoding UTF8

                Write-Host " [CONCLUÍDO]" -ForegroundColor Green
                Write-Host "Por favor, execute o comando novamente para usar a nova versão."
                exit
            } else {
                Write-Host "Você já está na versão mais recente ($LocalVersion)." -ForegroundColor Green
            }
        } else {
            Write-Warning "Não foi possível ler a versão remota."
        }
    }
    catch {
        Write-Error "Falha ao verificar atualização: $($_.Exception.Message)"
        Write-Host "Verifique sua conexão com a internet ou se o repositório existe." -ForegroundColor Red
    }
}

# Se o usuário pediu update, roda a função e encerra
if ($Update) {
    Check-Update
    exit
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ==============================================================================
#  FUNÇÃO DE HELP
# ==============================================================================
function Show-Help {
    Write-Host "
USO:
  enviar -AlunosFile <caminho_txt> -DocsPath <caminho_zip_ou_pasta> [Opções]

DESCRIÇÃO:
  Ferramenta de automação para envio de documentos acadêmicos via SMTP.
  Realiza o pareamento inteligente entre nomes de arquivos e lista de alunos.

PARÂMETROS OBRIGATÓRIOS:
  -AlunosFile   Caminho para o arquivo .txt com a lista de nomes.
  -DocsPath     Caminho para o arquivo .zip ou pasta com os documentos.

OPÇÕES:
  -DryRun       Modo Simulação. Mostra os matches na tela sem enviar e-mail.
  -ResetCreds   Apaga as credenciais salvas e solicita novo login/senha.
  -Help         Exibe esta mensagem de ajuda.
  -Update       Verifica e atualiza o comando com a versão mais recente disponível.

EXEMPLOS:
  1. Simulação (Recomendado):
    enviar -AlunosFile alunos.txt -DocsPath docs.zip -DryRun

  2. Envio Real:
    enviar -AlunosFile alunos.txt -DocsPath docs.zip

  3. Redefinir Senha de App:
    enviar -ResetCreds
" -ForegroundColor Cyan
}


if ($Help) {
    Show-Help
    exit
}

# ==============================================================================
# CONFIGURAÇÕES GERAIS
# ==============================================================================
$CredsFile = Join-Path $PSScriptRoot ".ppgec_creds.xml"
$LogFile   = Join-Path $PSScriptRoot "envios.log"
$Dominio   = "@poli.br"
$SmtpServer = "smtp.gmail.com"
$SmtpPort   = 587

# ==============================================================================
# FUNÇÕES DE UTILIDADE
# ==============================================================================

function Write-Log {
    param($Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Line = "$Timestamp | $Message"
    Write-Host $Line
    Add-Content -Path $LogFile -Value $Line -Encoding UTF8
}

function Remove-Diacritics {
    param([string]$Text)
    $Text = $Text.Normalize([Text.NormalizationForm]::FormD)
    $Builder = New-Object Text.StringBuilder
    foreach ($Char in $Text.ToCharArray()) {
        if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($Char) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$Builder.Append($Char)
        }
    }
    return $Builder.ToString().Normalize([Text.NormalizationForm]::FormC)
}

function Get-Initials {
    param([string]$Name)
    $IgnoreList = @("de", "da", "do", "dos", "das", "e", "o")
    $Parts = $Name.Split(" ", [StringSplitOptions]::RemoveEmptyEntries)
    $Initials = ""

    foreach ($Part in $Parts) {
        if ($Part.ToLower() -in $IgnoreList) { continue }
        $Initials += $Part.Substring(0,1)
    }
    return $Initials
}

function Manage-Credentials {
    if ($ResetCreds) {
        if (Test-Path $CredsFile) {
            Remove-Item $CredsFile -Force
            Write-Host "Credenciais antigas removidas." -ForegroundColor Yellow
        }
    }

    if (-not (Test-Path $CredsFile)) {
        Write-Host "`n=== CONFIGURAÇÃO DE PRIMEIRO ACESSO ===" -ForegroundColor Cyan
        Write-Host "Insira o E-mail e Senha de App."
        $Credential = Get-Credential -Message "Credenciais SMTP"
        $Credential | Export-Clixml -Path $CredsFile
        Write-Host "Credenciais salvas." -ForegroundColor Green
    }
    return Import-Clixml -Path $CredsFile
}

function Send-Email {
    param($Destinatario, $FilePath, $Creds)

    $Msg = New-Object System.Net.Mail.MailMessage
    $Msg.From = $Creds.UserName
    $Msg.To.Add($Destinatario)
    $Msg.Subject = "Seu documento"
    $Msg.Body = "Olá,`n`nSegue o documento em anexo.`n`nAtenciosamente."
    $Msg.BodyEncoding = [System.Text.Encoding]::UTF8
    $Msg.SubjectEncoding = [System.Text.Encoding]::UTF8

    $Attachment = New-Object System.Net.Mail.Attachment($FilePath)
    $Msg.Attachments.Add($Attachment)

    $Smtp = New-Object System.Net.Mail.SmtpClient($SmtpServer, $SmtpPort)
    $Smtp.EnableSsl = $true
    $Smtp.Credentials = $Creds

    try {
        $Smtp.Send($Msg)
        return $true
    }
    catch {
        Write-Error "Erro SMTP: $($_.Exception.Message)"
        return $false
    }
    finally {
        $Msg.Dispose()
        $Attachment.Dispose()
    }
}

# ==============================================================================
# INÍCIO DO FLUXO PRINCIPAL
# ==============================================================================

$StoredCreds = Manage-Credentials

if ($ResetCreds -and (-not $AlunosFile)) { exit }

if (-not $AlunosFile -or -not $DocsPath) {
    Write-Error "Parâmetros obrigatórios ausentes. Use -Help para ajuda."
    exit
}

if (-not (Test-Path $AlunosFile)) { Write-Error "Arquivo de alunos não encontrado."; exit }

$WorkDir = $DocsPath
$IsZip = $false

if ($DocsPath.EndsWith(".zip")) {
    $IsZip = $true
    $WorkDir = Join-Path $PWD "docs_tmp_$(Get-Random)"
    Write-Host "Extraindo ZIP..." -ForegroundColor Gray
    Expand-Archive -Path $DocsPath -DestinationPath $WorkDir -Force
}

# CARREGAR ALUNOS COM UTF-8
Write-Host "Carregando lista de alunos..." -ForegroundColor Gray
$AlunosRaw = Get-Content $AlunosFile -Encoding UTF8
$AlunosData = @()

foreach ($Line in $AlunosRaw) {
    if ([string]::IsNullOrWhiteSpace($Line)) { continue }
    $CleanName = (Remove-Diacritics $Line).ToLower().Replace(" ", "")
    $AlunosData += [PSCustomObject]@{ Original = $Line; Clean = $CleanName }
}


Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "               SIMULAÇÃO DE CORRESPONDÊNCIA               "
Write-Host "==========================================================" -ForegroundColor Cyan

$Files = Get-ChildItem -Path $WorkDir -File
$MatchesFound = @()

foreach ($File in $Files) {
    $FileClean = (Remove-Diacritics $File.Name).ToLower().Replace(" ", "")
    foreach ($Aluno in $AlunosData) {
        if ($FileClean -match $Aluno.Clean) {
            $Iniciais = Get-Initials $Aluno.Original
            $Email = "$($Iniciais.ToLower())$Dominio"

            Write-Host " [MATCH] $($File.Name)  ---->  $Email"
            $MatchesFound += [PSCustomObject]@{ File=$File; Email=$Email }
        }
    }
}

Write-Host "`nMatches confirmados: $($MatchesFound.Count)"

if ($DryRun) {
    Write-Host "Modo Dry-Run. Encerrando." -ForegroundColor Yellow
    if ($IsZip) { Remove-Item -Path $WorkDir -Recurse -Force }
    exit
}

$Confirmation = Read-Host "Enviar e-mails reais? (s/n)"
if ($Confirmation -ne 's') {
    if ($IsZip) { Remove-Item -Path $WorkDir -Recurse -Force }
    exit
}

# ENVIO REAL
foreach ($Item in $MatchesFound) {
    Write-Host "Enviando para $($Item.Email)..." -NoNewline
    $Sucesso = Send-Email -Destinatario $Item.Email -FilePath $Item.File.FullName -Creds $StoredCreds
    if ($Sucesso) { Write-Host " [OK]" -ForegroundColor Green; Write-Log "SUCESSO: $($Item.Email)" }
    else { Write-Host " [ERRO]" -ForegroundColor Red; Write-Log "FALHA: $($Item.Email)" }
}

if ($IsZip) { Remove-Item -Path $WorkDir -Recurse -Force }
Write-Host "`nConcluído." -ForegroundColor Cyan