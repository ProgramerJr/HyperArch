#!/usr/bin/env bash
# Cargado por todos los widgets de Waybar.
# Los tokens NUNCA viajan en la ISO (FR-09): solo la plantilla .example.

TOKENS="$HOME/.config/hyperarch/tokens.env"
ENC="$HOME/.config/hyperarch/tokens.env.gpg"

# Preferir la versión cifrada (SE-02). Nunca se escribe en disco en claro.
if [ -f "$ENC" ] && command -v gpg >/dev/null 2>&1; then
    eval "$(gpg --quiet --decrypt "$ENC" 2>/dev/null | grep -E '^[A-Z_]+=')"
elif [ -f "$TOKENS" ]; then
    . "$TOKENS"
fi

# out <texto> <tooltip> [clase css: ok|warn|err]
out() {
    jq -nc --arg t "$1" --arg tt "${2:-}" --arg c "${3:-}" \
        '{text: $t, tooltip: $tt, class: $c}'
}

# need <NOMBRE_VARIABLE> <etiqueta corta>
# Sale limpiamente con aviso si falta la credencial.
need() {
    if [ -z "${!1:-}" ]; then
        out "󰒲 $2" "Falta $1 en ~/.config/hyperarch/tokens.env" "warn"
        exit 0
    fi
}
