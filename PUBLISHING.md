# Publishing to GitHub / Publicar en GitHub

## First push / Primer push

```bash
cd HyperArch
git init -b main
git add .
git commit -m "feat: initial public release of HyperArch"
gh repo create HyperArch --public --source=. --push
# o sin gh CLI: crea el repo vacío en github.com y
# git remote add origin git@github.com:ProgramerJr/HyperArch.git && git push -u origin main
```

## Repo settings / Ajustes del repo

- **About**: description "Linux workstation with a built-in system AI · Arch + Hyprland + ROCm",
  topics: `archlinux` `hyprland` `linux-distribution` `rocm` `amd` `local-ai` `btrfs`
- **Branches → main**: require PR + require status checks (CI / validate)
- **Security → Private vulnerability reporting**: enable (SECURITY.md points there)
- **Releases**: tag `v0.3.0-alpha`. The ISO exceeds the 2 GB release-asset limit —
  publish `SHA256SUMS` in the release and host the ISO externally (Cloudflare R2)
  or let users build it themselves (that is the documented path).

## Español

Los mismos pasos: crea el repo, activa la protección de rama con el check del CI,
activa el reporte privado de vulnerabilidades, y recuerda que la ISO no cabe en
un Release de GitHub (límite 2 GB por fichero): publica los checksums y aloja la
ISO fuera, o deja que cada uno la compile (es la vía documentada).
