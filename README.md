<div align="center">

```
██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗
██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗
███████║ ╚████╔╝ ██████╔╝█████╗  ██████╔╝
██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══╝  ██╔══██╗
██║  ██║   ██║   ██║     ███████╗██║  ██║
╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝
```

**A Linux workstation with a built-in system AI**

Arch · Hyprland · Btrfs · ROCm · Docker

**English** · [Español](README.es.md)

</div>

---

> **Status: alpha.** The installer **wipes the entire target disk**. Never run it
> against data you cannot afford to lose. Test in a VM first (`./test-vm.sh`).

## What is this

An Arch-based distribution built for a specific workstation — Ryzen 9 7900X3D,
Radeon RX 7900 XTX, 64 GB RAM — around three ideas:

**Glass outside, production inside.** The desktop is deliberately spectacular —
absolute black, translucent glass, crimson accents, 144 Hz animations — until you
open a work tool. Then blur, transparency and long animations disappear and the
system enters Production Mode automatically. Close the last work app and the glass
comes back on its own. There is a `benchmark` subcommand that measures the actual
GPU savings instead of just claiming them.

**An AI that optimizes without being a liability.** A local model analyses system
telemetry every two minutes and tunes the machine. It only auto-applies reversible,
bounded actions; everything else is logged as a suggestion. If the model is
unavailable, a deterministic rule layer keeps working — the AI is never a single
point of failure, and there is no "destructive automatic action" category by design.

**Hardware-aware.** The 7900X3D has two asymmetric CCDs — one with 3D V-Cache, one
with higher clocks. Windows handles this with a proprietary driver; here it is
controlled explicitly with `hyper-ccd`. Docker and AI-model subvolumes are created
with copy-on-write disabled, because container layers and model weights are large,
already-compressed files that fragment badly under CoW.

## Requirements

| | |
|---|---|
| To build | Windows/Linux/macOS with Docker, 20 GB free |
| To install | x86-64 CPU, UEFI, AMD GPU, 16 GB RAM min, 256 GB SSD min |
| Reference hardware | Ryzen 9 7900X3D · RX 7900 XTX · 64 GB · 4 TB NVMe |

## 1 · Build the ISO

From Windows with Docker Desktop running (or any host with Docker):

```bash
git clone https://github.com/ProgramerJr/HyperArch.git
cd HyperArch
./build.sh --check     # verify requirements
./build.sh             # build (20–40 min)
```

The ISO lands in `out/` with its `SHA256SUMS`.

## 2 · Test in a VM (do this first)

```bash
./test-vm.sh --with-disk    # boots the ISO with a disposable 40 GB virtual disk
# inside the live environment:
sudo hyperarch-install /dev/vda
./test-vm.sh --boot-disk    # boot the installed system
```

## 3 · Write the USB

With [Rufus](https://rufus.ie): partition scheme **GPT**, target **UEFI (non-CSM)**,
write mode **DD Image**.

## 4 · Install on real hardware

Disable **Secure Boot** in the BIOS and boot from the USB.

```bash
lsblk                                # identify your disk
sudo hyperarch-install /dev/nvme0n1  # WIPES that entire disk
```

The installer creates the Btrfs layout, installs the base system, and configures
GRUB with a snapshot menu. Reboot when done.

## 5 · First boot

```bash
hyper-setup
```

Installs VS Code (three isolated profiles), Brave, lazydocker, LACT, the wallpaper
engine renderer, and downloads the AI model. Then add your credentials:

```bash
nano ~/.config/hyperarch/tokens.env
```

## Shortcuts

`SUPER` is the Windows key. Modifier tiers have meaning: `SUPER` launches,
`SUPER+SHIFT` is the secondary variant, `SUPER+ALT` is window geometry.

| | | | |
|---|---|---|---|
| `SUPER+RETURN` | Terminal | `SUPER+H` | Hyper Hub |
| `SUPER+R` | VS Code · React | `SUPER+M` | Monitor (btop) |
| `SUPER+J` | VS Code · Java | `SUPER+SHIFT+M` | GPU (nvtop) |
| `SUPER+O` | VS Code · DevOps | `SUPER+I` | AI panel |
| `SUPER+G` | lazygit | `SUPER+P` | **Production Mode** |
| `SUPER+D` | lazydocker | `SUPER+Z` | **Focus Mode** |
| `SUPER+SHIFT+D` | MongoDB Compass | `SUPER+SPACE` | Launcher |
| `SUPER+B` | Browser | `SUPER+E` | Files |
| `SUPER+S` | Steam | `SUPER+L` | Lock |
| `SUPER+SHIFT+W` | Toggle animated wallpaper | `SUPER+SHIFT+S` | Region screenshot |

Workspaces: 1 terminal · 2 editor · 3 browser · 4 data · 5 monitoring · 9 games.

## Commands

```bash
hyper-hub                         # control centre (--watch for live view)
hyper-production-mode benchmark   # measure the real GPU savings
hyper-profile dev|ai|gaming|silent
hyper-ccd info                    # 7900X3D CCD topology
hyper-ccd cache <program>         # pin to the V-Cache CCD
hyper-update                      # snapshot → system → AUR → cleanup
hyper-backup init|run             # real backups (restic, external disk)
hyper-wallpaper engine <id>       # animated Workshop wallpaper
mongo-up / mongo-down             # MongoDB in a container
snap-list                         # system snapshots
```

## How the AI works

```
        ┌─────────────────────────────────────┐
        │  Telemetry: CPU · RAM · GPU · disk  │
        └────────────────┬────────────────────┘
                         │
        ┌────────────────▼────────────────┐
        │  Layer 1 · Deterministic rules  │  ← always on,
        │  renice · swappiness · cache    │     needs no model
        └────────────────┬────────────────┘
                         │
        ┌────────────────▼────────────────┐
        │  Layer 2 · Local LLM (optional) │  ← enriches,
        │  diagnosis · pattern detection  │     never required
        └────────────────┬────────────────┘
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
        AUTO (reversible)     SUGGESTION (log only)
```

## Animated wallpapers

Wallpaper Engine itself is Windows software; HyperArch uses the community
[linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine) renderer.
You need Wallpaper Engine on Steam (Workshop items are tied to the license).
Recommended match for the Crimson theme: Workshop item `1180974281`
("Black and red Abstract"). Production Mode automatically falls back to the static
wallpaper — an animated background is exactly the GPU cost that mode exists to remove.

## Recovery

If an update breaks the system: GRUB → *HyperArch snapshots* → boot an earlier one.
`@var_log` and `@var_cache` are deliberately excluded from rollback so you keep the
logs that explain what broke. Snapshots are **not** backups — they live on the same
disk. Use `hyper-backup` against an external drive.

## Known limitations

- **League of Legends does not work** — not via Proton, not in a VM. Vanguard
  attests the physical boot chain and rejects all virtualisation. Dual-boot Windows
  on a separate disk if you need it.
- No disk encryption (deliberate: recovery simplicity on a stationary desktop;
  secrets are protected at application level).
- No hibernation (would need 64 GB of swap and conflicts with the no-CoW layout).
- Tested only on AMD hardware. NVIDIA is out of scope.
- Alpha software: the first build will likely surface package-name drift in
  `packages/*.txt`. Please open an issue with the build log.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Issues and PRs welcome in English or Spanish.

## License

MIT
