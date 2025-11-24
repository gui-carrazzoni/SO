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
