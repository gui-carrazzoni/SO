# 📧 Automação de Envios - PPGEC (Windows Edition)

> Projeto de Extensão desenvolvido na disciplina de Sistemas Operacionais da Escola Politécnica de Pernambuco (UPE).

Este projeto consiste em uma ferramenta de linha de comando (CLI) desenvolvida em **PowerShell** para automatizar o envio de documentos acadêmicos personalizados. A ferramenta realiza o pareamento inteligente entre arquivos (PDFs) e uma lista de alunos, disparando e-mails automaticamente.

## 🚀 Funcionalidades

- **Instalação Global:** Funciona como um comando nativo do Windows (`enviar`).
- **Smart Matching:** Associa arquivos (ex: `documento-joao-silva.pdf`) aos nomes na lista (ex: `João da Silva`) ignorando acentos, espaços e traços.
- **Gestão de Credenciais:** Armazena sua senha de e-mail de forma criptografada e segura no seu computador.
- **Modo Simulação:** Teste tudo antes de enviar (`-DryRun`).
- **Auto-Update:** O comando se atualiza sozinho consultando o repositório remoto.

---

## ⚡ Instalação Automática

Para utilizar o comando `enviar` em qualquer pasta do seu computador, siga os passos abaixo:

1. **Clone ou Baixe** este repositório.
2. Localize o arquivo `install.ps1` na pasta do projeto.
3. Clique com o botão direito no arquivo e selecione **"Executar com o PowerShell"**.
   > **Nota:** Se solicitado, conceda permissão de Administrador (necessário para criar a pasta `C:\Bin` e configurar o PATH).
4. Aguarde a mensagem de "INSTALAÇÃO CONCLUÍDA".
5. **Importante:** Feche todas as janelas do terminal/PowerShell e abra uma nova para que o comando seja reconhecido.

---

## 💻 Guia de Uso

A sintaxe básica do comando é:
```powershell
enviar -AlunosFile <arquivo.txt> -DocsPath <arquivo.zip> [Opções]
````
## Preparação dos Arquivos

 **Lista de Alunos `(.txt)`**: Um arquivo de texto com o nome completo de um aluno por linha.

  **Documentos:** Pode ser uma pasta ou um arquivo .zip. O nome do arquivo deve conter o nome do aluno.

  **Primeira Execução** (Configuração)
Na primeira vez que você rodar o comando, ele pedirá suas credenciais do Gmail.

 **⚠️ Atenção:** Utilize uma Senha de App (App Password) do Google, e não sua senha de login pessoal.

```PowerShell
enviar -AlunosFile turma.txt -DocsPath documentos.zip -DryRun
```
*Uma janela segura do Windows abrirá solicitando E-mail e Senha.*

##  Modo Simulação (Recomendado)
Sempre execute com a flag -DryRun antes. Isso mostra na tela quem vai receber o quê, sem enviar nada.

```PowerShell

enviar -AlunosFile turma.txt -DocsPath documentos.zip -DryRun
```
## Envio Real
Se a simulação estiver correta, rode sem a flag de DryRun. O script ainda pedirá uma confirmação final (s/n).*

```PowerShell
enviar -AlunosFile turma.txt -DocsPath documentos.zip
```

## Outras Opções Úteis
**Verificar Atualizações:** Baixa a versão mais recente do script automaticamente.

```PowerShell
enviar -Update
```
**Trocar de Senha:** Caso precise alterar o e-mail ou a senha salva.

```PowerShell
enviar -ResetCreds
```

**Menu de Ajuda:**

```PowerShell
enviar -Help
```
---

## 🗑️ Desinstalação
Caso queira remover a ferramenta do seu sistema:

Localize o arquivo `uninstall.ps1` na pasta do repositório clonado.

Clique com o botão direito e selecione "Executar com o PowerShell".

O script irá:

Remover os arquivos de `C:\Bin.`

Limpar o comando do seu `PATH`.

Apagar as credenciais salvas.


# 📧 Automação de Envios - PPGEC (Linux Edition)

## 🚀 Funcionalidades

- **Orquestração via Bash:** Manipulação de arquivos, descompactação de ZIPs e lógica de interação.
- **Envio SMTP via Python:** Script auxiliar robusto para disparo de e-mails via Gmail (ou outros provedores).
- **Smart Matching:** Algoritmo que associa nomes de arquivos (ex: `ata_joao_silva.pdf`) aos nomes na lista de alunos, gerando automaticamente o e-mail institucional baseado nas iniciais.
- **Modo de Segurança (Dry-Run):** Simula todo o processo sem enviar nada, para validação prévia.
- **Auditoria:** Geração automática de logs (`envios.log`) com timestamp de cada operação.

## 🛠️ Pré-requisitos

Para executar a ferramenta, você precisa de um ambiente Unix-like (Linux, macOS ou WSL no Windows) com:

- **Bash** (Shell padrão)
- **Python 3**
- **Unzip** (para descompactar os lotes)
- **Iconv** (para tratamento de caracteres especiais)

No Ubuntu/Debian/WSL, você pode instalar as dependências com:
```bash
sudo apt update
sudo apt install python3 unzip 

```
⚙️ Instalação e Configuração
1. Clonar o Repositório
Baixe o código para sua máquina local:
```bash
git clone [https://github.com/gui-carrazzoni/SO.git](https://github.com/gui-carrazzoni/SO.git)
cd SO

```

2. Permissões de Execução
Scripts baixados da internet não possuem permissão de execução por padrão. Utilize o comando chmod para liberar:
```bash
chmod +x enviar.sh send_mail.py

```
3. Configuração de Credenciais
Abra o arquivo send_mail.py e edite as variáveis de configuração para inserir o e-mail remetente.

⚠️ IMPORTANTE: Se estiver usando Gmail, você NÃO deve usar sua senha de login normal. Crie uma Senha de App (App Password) nas configurações de segurança da sua conta Google.
```python
# No arquivo send_mail.py:

SMTP_USER = "seu.email@gmail.com"
SMTP_PASS = "sua-senha-de-app-aqui"

```
💻 Como Usar
A sintaxe básica do comando é:
```bash
./enviar.sh [opções] <arquivo_lista_alunos.txt> <arquivo_docs.zip>

```
Passo 1: Preparar os Arquivos
Lista de Alunos: Crie um arquivo .txt contendo um nome completo de aluno por linha.

Documentos: Organize os PDFs em uma pasta ou arquivo .zip. O nome do arquivo deve conter partes do nome do aluno para o sistema fazer a correspondência.

Passo 2: Modo Simulação (Recomendado)
Antes de enviar, rode com a flag --dry-run. Isso mostrará na tela quem receberá qual arquivo, sem disparar o e-mail.
```bash
./enviar.sh --dry-run alunos.txt documentos.zip

```
## 📂 Estrutura do Projeto

```text
.
├── enviar.sh        # Script principal (Lógica, Interface, Logs)
├── send_mail.py     # Script auxiliar (Conexão SMTP)
├── alunos.txt       # Lista de alunos (base de dados)
├── docs.zip         # Arquivo compactado com os documentos
├── envios.log       # (Gerado automaticamente) Registro de atividades
└── README.md        # Documentação do projeto
```

👥 Autores
Projeto desenvolvido pela equipe de Sistemas Operacionais (2025):

Alysson Fernandes Silva Tavares

Guilherme Santos Carrazoni

Pedro Henrique Bullé de Souza

Escola Politécnica de Pernambuco - UPE
