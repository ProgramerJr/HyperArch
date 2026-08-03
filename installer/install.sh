#!/usr/bin/env bash
#
# HyperArch — instalador
#
# Instala HyperArch como SISTEMA ÚNICO en el disco indicado. BORRA TODO.
# Se ejecuta desde el entorno live de la ISO:
#
#     sudo hyperarch-install /dev/nvme0n1
#
set -euo pipefail

DISK="${1:-}"
HOSTNAME_DEFAULT="hyperarch"
USERNAME_DEFAULT="hyper"

BLUE=$'\e[1;34m'; GRN=$'\e[1;32m'; YEL=$'\e[1;33m'; RST=$'\e[0m'
say()  { echo "${GRN}::${RST} $*"; }
warn() { echo "${YEL}!!${RST} $*"; }
die()  { echo "${BLUE}xx${RST} $*" >&2; exit 1; }

# ── Comprobaciones ────────────────────────────────────────────────────────
[[ $EUID -eq 0 ]] || die "Ejecuta como root."
[[ -n "$DISK" ]]  || die "Uso: hyperarch-install /dev/nvmeXn1"
[[ -b "$DISK" ]]  || die "$DISK no es un dispositivo de bloque."
[[ -d /sys/firmware/efi ]] || die "Se requiere arranque UEFI."

SIZE=$(lsblk -bdno SIZE "$DISK")
MODEL=$(lsblk -dno MODEL "$DISK" || echo "desconocido")

echo
echo "  ${BLUE}HyperArch${RST} — instalación"
echo "  ─────────────────────────────────────────"
echo "  Disco   : $DISK ($MODEL)"
echo "  Tamaño  : $((SIZE / 1000000000)) GB"
echo
warn "TODO el contenido de $DISK se destruirá de forma irreversible."
read -rp "  Escribe DESTRUIR para continuar: " confirm
[[ "$confirm" == "DESTRUIR" ]] || die "Cancelado."

read -rp "  Nombre de host [$HOSTNAME_DEFAULT]: " HOST; HOST="${HOST:-$HOSTNAME_DEFAULT}"
read -rp "  Usuario [$USERNAME_DEFAULT]: " USER_NAME; USER_NAME="${USER_NAME:-$USERNAME_DEFAULT}"

while :; do
    read -rsp "  Contraseña para $USER_NAME: " PASS; echo
    read -rsp "  Repite la contraseña: " PASS2; echo
    [[ "$PASS" == "$PASS2" && -n "$PASS" ]] && break
    warn "No coinciden o están vacías."
done

# ── Particionado ──────────────────────────────────────────────────────────
say "Particionando $DISK"
sgdisk --zap-all "$DISK"
sgdisk -n1:0:+1G   -t1:ef00 -c1:"EFI"       "$DISK"
sgdisk -n2:0:0     -t2:8300 -c2:"HYPERARCH" "$DISK"
partprobe "$DISK"; sleep 2

if [[ "$DISK" == *nvme* || "$DISK" == *mmcblk* ]]; then
    ESP="${DISK}p1"; ROOT="${DISK}p2"
else
    ESP="${DISK}1";  ROOT="${DISK}2"
fi

say "Formateando"
mkfs.fat -F32 -n EFI "$ESP"
mkfs.btrfs -f -L HYPERARCH "$ROOT"

# ── Subvolúmenes (RR-04) ──────────────────────────────────────────────────
say "Creando subvolúmenes Btrfs"
mount "$ROOT" /mnt
for sv in @ @home @snapshots @var_log @var_cache @docker @models; do
    btrfs subvolume create "/mnt/$sv"
done
umount /mnt

OPTS="noatime,compress=zstd:3,space_cache=v2,ssd,discard=async"

mount -o "$OPTS,subvol=@" "$ROOT" /mnt
mkdir -p /mnt/{home,.snapshots,var/log,var/cache,var/lib/docker,var/lib/hyperarch/models,boot}
mount -o "$OPTS,subvol=@home"      "$ROOT" /mnt/home
mount -o "$OPTS,subvol=@snapshots" "$ROOT" /mnt/.snapshots
mount -o "$OPTS,subvol=@var_log"   "$ROOT" /mnt/var/log
mount -o "$OPTS,subvol=@var_cache" "$ROOT" /mnt/var/cache

# @docker y @models: CoW desactivado. Capas de contenedor y pesos de modelos
# son ficheros grandes, ya comprimidos y de escritura intensiva: bajo
# copy-on-write se fragmentan de forma severa.
mount -o "noatime,space_cache=v2,ssd,discard=async,nodatacow,subvol=@docker" \
      "$ROOT" /mnt/var/lib/docker
mount -o "noatime,space_cache=v2,ssd,discard=async,nodatacow,subvol=@models" \
      "$ROOT" /mnt/var/lib/hyperarch/models
chattr +C /mnt/var/lib/docker /mnt/var/lib/hyperarch/models 2>/dev/null || true

mount "$ESP" /mnt/boot

# ── Sistema base ──────────────────────────────────────────────────────────
say "Instalando sistema base (esto tarda)"
PKG_DIR="$(dirname "$(readlink -f "$0")")/../packages"
mapfile -t PKGS < <(cat "$PKG_DIR"/{base,gpu,desktop,terminal,development,multimedia,gaming,ai}.txt \
                    | grep -vE '^\s*(#|$)')

pacstrap -K /mnt "${PKGS[@]}"

say "Generando fstab"
genfstab -U /mnt >> /mnt/etc/fstab

# ── Overlay de configuración ──────────────────────────────────────────────
say "Aplicando configuración de HyperArch"
cp -r "$(dirname "$(readlink -f "$0")")/../airootfs/." /mnt/

# ── Configuración dentro del chroot ───────────────────────────────────────
say "Configurando el sistema"
arch-chroot /mnt /bin/bash -euo pipefail << CHROOT
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc

sed -i 's/^#es_ES.UTF-8/es_ES.UTF-8/' /etc/locale.gen
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=es_ES.UTF-8" > /etc/locale.conf
echo "KEYMAP=es" > /etc/vconsole.conf

echo "$HOST" > /etc/hostname
cat > /etc/hosts << HOSTS
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOST.localdomain $HOST
HOSTS

# Usuario
useradd -m -G wheel,video,audio,storage,docker,libvirt -s /bin/zsh "$USER_NAME"
echo "$USER_NAME:$PASS" | chpasswd
passwd -l root
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel

# Snapper necesita que /.snapshots exista sin conflicto
umount /.snapshots 2>/dev/null || true
rm -rf /.snapshots
snapper --no-dbus -c root create-config /
btrfs subvolume delete /.snapshots 2>/dev/null || true
mkdir /.snapshots
mount -a
chmod 750 /.snapshots

# initramfs con soporte Btrfs y Plymouth
sed -i 's/^HOOKS=.*/HOOKS=(base udev plymouth autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck)/' /etc/mkinitcpio.conf
sed -i 's/^MODULES=.*/MODULES=(amdgpu)/' /etc/mkinitcpio.conf

# GRUB con menú de snapshots (D-01, RR-01)
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=HyperArch
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=3/' /etc/default/grub
sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amdgpu.ppfeaturemask=0xffffffff amd_pstate=active nowatchdog split_lock_detect=off"|' /etc/default/grub
sed -i 's/^#GRUB_DISABLE_SUBMENU=.*/GRUB_DISABLE_SUBMENU=n/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Tema de arranque
plymouth-set-default-theme hyperarch || true
mkinitcpio -P

# Servicios
systemctl enable NetworkManager greetd docker libvirtd earlyoom ufw fstrim.timer bluetooth
systemctl enable btrfs-scrub@-.timer paccache-clean.timer smartd
systemctl enable snapper-timeline.timer snapper-cleanup.timer grub-btrfsd
systemctl enable ollama hyper-ai

# Firewall (SE-01)
ufw default deny incoming
ufw default allow outgoing
ufw --force enable

# ccache
sed -i 's|^#MAKEFLAGS=.*|MAKEFLAGS="-j\$(nproc)"|' /etc/makepkg.conf
sed -i 's|^BUILDENV=.*|BUILDENV=(!distcc color ccache check !sign)|' /etc/makepkg.conf

# Permisos de la config de usuario
chown -R "$USER_NAME:$USER_NAME" "/home/$USER_NAME"
chmod +x /usr/local/bin/hyper-* 2>/dev/null || true
chmod +x "/home/$USER_NAME/.config/waybar/widgets/"*.sh 2>/dev/null || true
CHROOT

say "Desmontando"
umount -R /mnt

echo
echo "  ${GRN}Instalación completada.${RST}"
echo
echo "  Tras reiniciar, ejecuta:  ${YEL}hyper-setup${RST}"
echo "  (instala VS Code, Brave, lazydocker, LACT y descarga el modelo de IA)"
echo
