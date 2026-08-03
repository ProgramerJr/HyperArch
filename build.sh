#!/usr/bin/env bash
#
#  HyperArch — constructor de ISO
#
#  Se ejecuta desde Windows (Docker Desktop + WSL2) o desde cualquier host
#  con Docker. No necesitas tener Linux instalado: el contenedor construye
#  la imagen completa.
#
#      ./build.sh              construir
#      ./build.sh --clean      limpiar caché de trabajo antes
#      ./build.sh --check      solo verificar requisitos
#
set -euo pipefail

# Git Bash (MSYS) reescribe las rutas que empiezan por "/" al pasarlas a
# procesos nativos de Windows, lo que rompe los montajes de Docker.
export MSYS_NO_PATHCONV=1

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$HERE/out"
WORK="$HERE/.work"

A=$'\e[1;34m'; G=$'\e[1;32m'; Y=$'\e[1;33m'; D=$'\e[0;90m'; R=$'\e[0m'
say()  { echo "${G}::${R} $*"; }
warn() { echo "${Y}!!${R} $*"; }
die()  { echo "${A}xx${R} $*" >&2; exit 1; }

banner() {
    printf "${A}"
    echo '  ██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗'
    echo '  ███████║ ╚████╔╝ ██████╔╝█████╗  ██████╔╝'
    echo '  ██║  ██║   ██║   ██║     ███████╗██║  ██║'
    printf "${R}${D}  constructor de ISO${R}\n\n"
}

check() {
    say "Verificando requisitos"
    command -v docker >/dev/null || die "Docker no encontrado. Instala Docker Desktop."
    docker info >/dev/null 2>&1 || die "El demonio de Docker no responde. Arranca Docker Desktop."

    local free_gb
    free_gb=$(df -BG "$HERE" | awk 'NR==2 {gsub("G","",$4); print $4}')
    [[ "${free_gb:-0}" -ge 20 ]] || warn "Solo ${free_gb}GB libres. Se recomiendan 20GB o más."

    say "Docker $(docker version --format '{{.Server.Version}}') · ${free_gb}GB libres"
}

[[ "${1:-}" == "--check" ]] && { banner; check; exit 0; }
[[ "${1:-}" == "--clean" ]] && { say "Limpiando caché"; rm -rf "$WORK"; }

banner
TTY_FLAGS=()
[ -t 0 ] && TTY_FLAGS=(-it)

check
mkdir -p "$OUT" "$WORK"

say "Lanzando contenedor de compilación"
docker run --rm "${TTY_FLAGS[@]}" \
    --privileged \
    -v "$HERE:/src:ro" \
    -v "$OUT:/out" \
    -v "$WORK:/work" \
    archlinux:latest \
    bash -euo pipefail -c '
        echo ":: Preparando entorno de compilación"
        pacman -Sy --noconfirm --needed archiso git jq >/dev/null

        # multilib: necesario para Steam y librerías de 32 bits
        sed -i "/^#\[multilib\]/,+1 s/^#//" /etc/pacman.conf
        pacman -Sy >/dev/null

        PROFILE=/work/profile
        rm -rf "$PROFILE"
        cp -r /usr/share/archiso/configs/releng "$PROFILE"
        cd "$PROFILE"

        echo ":: Aplicando identidad de HyperArch"
        sed -i "s/^iso_name=.*/iso_name=\"hyperarch\"/"                     profiledef.sh
        sed -i "s/^iso_label=.*/iso_label=\"HYPERARCH_$(date +%Y%m)\"/"     profiledef.sh
        sed -i "s|^iso_publisher=.*|iso_publisher=\"HyperArch\"|"           profiledef.sh
        sed -i "s|^iso_application=.*|iso_application=\"HyperArch Live\"|"  profiledef.sh

        echo ":: Componiendo lista de paquetes"
        for f in base gpu desktop terminal development multimedia gaming ai; do
            grep -vE "^\s*(#|$)" "/src/packages/$f.txt" >> packages.x86_64
        done
        # multilib dentro de la ISO
        sed -i "/^#\[multilib\]/,+1 s/^#//" pacman.conf
        sort -u packages.x86_64 -o packages.x86_64
        echo "   $(wc -l < packages.x86_64) paquetes"

        echo ":: Aplicando overlay de configuración"
        cp -r /src/airootfs/. airootfs/

        # Instalador accesible desde el live
        mkdir -p airootfs/usr/local/bin
        cp /src/installer/install.sh airootfs/usr/local/bin/hyperarch-install
        chmod +x airootfs/usr/local/bin/hyperarch-install
        mkdir -p airootfs/root
        cp -r /src/packages airootfs/root/packages

        chmod +x airootfs/usr/local/bin/hyper-* 2>/dev/null || true
        find airootfs/etc/skel -name "*.sh" -exec chmod +x {} + 2>/dev/null || true

        echo ":: Habilitando servicios"
        mkdir -p airootfs/etc/systemd/system/multi-user.target.wants
        for svc in NetworkManager docker; do
            ln -sf "/usr/lib/systemd/system/$svc.service" \
                   "airootfs/etc/systemd/system/multi-user.target.wants/$svc.service"
        done

        # Mensaje de bienvenida del entorno live
        cat > airootfs/etc/motd <<MOTD

  HyperArch Live

  Para instalar en disco (BORRA TODO el disco indicado):

      sudo hyperarch-install /dev/nvme0n1

  Lista tus discos con:  lsblk

MOTD

        echo ":: Compilando ISO (20-40 min)"
        mkarchiso -v -w /work/build -o /out .

        echo ":: Generando checksums"
        cd /out && sha256sum *.iso > SHA256SUMS
    '

echo
say "Compilación terminada"
ls -lh "$OUT"/*.iso 2>/dev/null || warn "No se encontró ISO en $OUT"
echo
echo "  Siguiente paso: graba la ISO con ${Y}Rufus${R}"
echo "    · Esquema de partición: ${Y}GPT${R}"
echo "    · Sistema destino: ${Y}UEFI (no CSM)${R}"
echo "    · Modo de escritura: ${Y}DD Image${R}"
echo
