#!/usr/bin/env bash
#
# test-vm.sh — prueba la ISO en QEMU ANTES de tocar hardware real.
#
# El instalador borra discos enteros. Este script existe para que el primer
# arranque y la primera instalación ocurran contra un disco virtual
# desechable, nunca contra tu NVMe.
#
# Desde WSL2 (Windows) o Linux:
#     ./test-vm.sh                  arranca la ISO en live
#     ./test-vm.sh --with-disk      añade un disco virtual de 40G para
#                                   probar la instalación completa
#     ./test-vm.sh --boot-disk      arranca desde el disco ya instalado
#
# En WSL2 sin aceleración KVM irá lento pero funciona para validar que la
# ISO arranca y el instalador termina. Alternativa en Windows nativo:
# Hyper-V o VirtualBox con la misma ISO (UEFI activado).
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO=$(ls -t "$HERE"/out/hyperarch-*.iso 2>/dev/null | head -1 || true)
DISK="$HERE/out/test-disk.qcow2"

command -v qemu-system-x86_64 >/dev/null || {
    echo "QEMU no instalado."
    echo "  Debian/Ubuntu/WSL:  sudo apt install qemu-system-x86 ovmf"
    echo "  Arch:               sudo pacman -S qemu-full edk2-ovmf"
    exit 1
}

# Firmware UEFI (la ISO exige UEFI, igual que el hardware real)
OVMF=""
for c in /usr/share/OVMF/OVMF_CODE_4M.fd /usr/share/OVMF/OVMF_CODE.fd \
         /usr/share/ovmf/OVMF.fd /usr/share/edk2/x64/OVMF_CODE.4m.fd \
         /usr/share/edk2-ovmf/x64/OVMF_CODE.fd; do
    [[ -f "$c" ]] && { OVMF="$c"; break; }
done
[[ -n "$OVMF" ]] || { echo "Firmware OVMF no encontrado. Instala el paquete ovmf/edk2-ovmf."; exit 1; }

ACCEL=()
if [[ -w /dev/kvm ]]; then
    ACCEL=(-enable-kvm -cpu host)
    echo ":: KVM disponible (rápido)"
else
    ACCEL=(-cpu qemu64)
    echo ":: Sin KVM: emulación pura, lenta pero válida para probar"
fi

ARGS=(
    "${ACCEL[@]}"
    -m 8G -smp 6
    -drive "if=pflash,format=raw,readonly=on,file=$OVMF"
    -device virtio-vga-gl -display gtk,gl=on
    -device virtio-net,netdev=n0 -netdev user,id=n0
    -device qemu-xhci -device usb-tablet
    -audiodev pa,id=a0 -device intel-hda -device hda-duplex,audiodev=a0
)

case "${1:-}" in
    --with-disk)
        [[ -n "$ISO" ]] || { echo "No hay ISO en out/. Ejecuta ./build.sh primero."; exit 1; }
        [[ -f "$DISK" ]] || qemu-img create -f qcow2 "$DISK" 40G
        echo ":: ISO: $(basename "$ISO")  +  disco virtual 40G"
        echo ":: Dentro del live: sudo hyperarch-install /dev/vda"
        exec qemu-system-x86_64 "${ARGS[@]}" \
            -cdrom "$ISO" \
            -drive "file=$DISK,if=virtio,format=qcow2" \
            -boot d
        ;;
    --boot-disk)
        [[ -f "$DISK" ]] || { echo "No hay disco de prueba. Instala primero con --with-disk."; exit 1; }
        echo ":: Arrancando el sistema instalado"
        exec qemu-system-x86_64 "${ARGS[@]}" \
            -drive "file=$DISK,if=virtio,format=qcow2"
        ;;
    --clean)
        rm -f "$DISK"; echo "Disco de prueba eliminado."
        ;;
    *)
        [[ -n "$ISO" ]] || { echo "No hay ISO en out/. Ejecuta ./build.sh primero."; exit 1; }
        echo ":: Arrancando live: $(basename "$ISO")"
        exec qemu-system-x86_64 "${ARGS[@]}" -cdrom "$ISO" -boot d
        ;;
esac
