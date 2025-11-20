#!/usr/bin/env bash

# CONFIGURAÇÕES

PY_MAILER="./send_mail.py"
LOGFILE="./envios.log"
DRY_RUN=false
DOMINIO="@poli.br"

# FUNÇÕES

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" | tee -a "$LOGFILE"
}

erro() {
    echo "ERRO: $1"
    exit 1
}

mostrar_uso() {
cat <<EOF
Uso:
  $0 [opções] alunos.txt <docs_dir ou zip>

Opções:
  --dry-run     não envia nada
  --help        mostra ajuda

Formato do alunos.txt:
  nome completo do aluno

Exemplo:
  alysson pereira gomes
  pedro henrique silva
EOF
exit 0
}

# PARSE DAS FLAGS

while [[ "$1" == --* ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true ;;
        --help) mostrar_uso ;;
        *) erro "Opção desconhecida: $1" ;;
    esac
    shift
done

# ARQUIVOS OBRIGATÓRIOS

ALUNOS_FILE="$1"
DOCS="$2"

[[ -z "$ALUNOS_FILE" ]] && erro "Faltou o arquivo de alunos"
[[ -z "$DOCS" ]] && erro "Faltou a pasta ou ZIP"
[[ ! -f "$ALUNOS_FILE" ]] && erro "Arquivo $ALUNOS_FILE não encontrado"

# DESCOMPACTANDO ZIP

TMP_DIR=""
if [[ "$DOCS" == *.zip ]]; then
    TMP_DIR="./docs_tmp_$$"
    mkdir -p "$TMP_DIR"
    unzip "$DOCS" -d "$TMP_DIR" >/dev/null || erro "Falha ao extrair ZIP"
    DOCS="$TMP_DIR"
fi

[[ ! -d "$DOCS" ]] && erro "$DOCS não é pasta válida"

# CARREGA NOMES EM ARRAYS
# - nomes_originais: para gerar iniciais
# - nomes: para matching (minúsculas + sem espaços + transliteração)

declare -a nomes
declare -a nomes_originais

while read -r nome; do
    [[ -z "$nome" ]] && continue
    nomes_originais+=("$nome")
    clean_nome=$(echo "$nome" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]' | iconv -f UTF-8 -t ASCII//TRANSLIT)
    nomes+=("$clean_nome")
done < "$ALUNOS_FILE"

# FUNÇÃO PARA GERAR INICIAIS, IGNORA PREPOSIÇÕES E ARTIGOS


gerar_iniciais() {
    local nome="$1"
    local inic=""
    local ignore_list=("de" "da" "do" "dos" "das" "e")
    for palavra in $nome; do
        palavra_lc=$(echo "$palavra" | tr '[:upper:]' '[:lower:]')
        skip=false
        for ign in "${ignore_list[@]}"; do
            [[ "$palavra_lc" == "$ign" ]] && skip=true
        done
        $skip && continue
        letra="${palavra:0:1}"
        inic+="$letra"
    done
    echo "$inic"
}

# CONFIRMAÇÃO ANTES DE ENVIAR

echo "PRÉVIA DO ENVIO:"
echo "Alunos carregados: ${#nomes[@]}"
echo "Arquivos na pasta: $(ls "$DOCS" | wc -l)"
echo "Domínio configurado: $DOMINIO"
echo ""
echo "AVISO: Se você continuar, os emails serão enviados via SMTP."
echo "Deseja realmente enviar? (s/n)"
read resposta

if [[ "$resposta" != "s" && "$resposta" != "S" ]]; then
    echo "Envio cancelado pelo usuário."
    [[ -n "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
    exit 0
fi

echo "Iniciando envio..."

# LOOP DE ENVIO

PYTHON_CMD="python3"
command -v python >/dev/null && PYTHON_CMD="python"

for doc in "$DOCS"/*; do
    filename=$(basename "$doc")
    lower=$(echo "$filename" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]' | iconv -f UTF-8 -t ASCII//TRANSLIT)

    encontrado=false

    for i in "${!nomes[@]}"; do
        nome_clean="${nomes[$i]}"
        nome_original="${nomes_originais[$i]}"

        if [[ "$lower" == *"$nome_clean"* ]]; then
            encontrado=true
            iniciais=$(gerar_iniciais "$nome_original")  # usa nome original
            email="${iniciais,,}$DOMINIO"

            log "MATCH: \"$filename\" -> $nome_original -> $email"

            if $DRY_RUN; then
                continue
            fi

            $PYTHON_CMD "$PY_MAILER" "$email" "$doc"
            [[ $? == 0 ]] && log "Enviado SMTP -> $email" || log "FALHA SMTP -> $email"
        fi
    done

    if ! $encontrado; then
        log "NÃO ENCONTRADO: \"$filename\""
    fi
done

log "Processo concluído."
[[ -n "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
