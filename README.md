# 📧 Automação de Envios de Documentos/emails - PPGEC

> Projeto de Extensão desenvolvido na disciplina de Sistemas Operacionais da Escola Politécnica de Pernambuco (UPE).

Este projeto consiste em uma ferramenta de linha de comando (CLI) híbrida (Bash + Python) para automatizar o envio de documentos acadêmicos personalizados para alunos do Programa de Pós-Graduação em Engenharia da Computação (PPGEC).

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
