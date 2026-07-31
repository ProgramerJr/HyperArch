# Contributing / Contribuir

**English** below · **Español** más abajo

---

## English

Thanks for considering a contribution. HyperArch is alpha software built and
tested against one reference machine, so real-world reports are the most
valuable contribution there is.

### The most useful things you can do

1. **Build the ISO and report what breaks.** Package names drift in Arch;
   `packages/*.txt` will rot first. Open an issue with the `build.sh` log.
2. **Test in QEMU** (`./test-vm.sh --with-disk`) and report installer failures
   with the exact error message.
3. **Test on non-reference AMD hardware** and tell us what needed changing.

### Ground rules

- One change per pull request.
- Shell scripts must pass `bash -n` and ideally `shellcheck`.
- Python must compile (`python3 -m py_compile`).
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org):
  `feat(installer): ...`, `fix(widgets): ...`, `docs(readme): ...`
- User-facing strings in the desktop are Spanish-first (reference user);
  documentation is bilingual. Write in whichever language is comfortable and
  translation gets sorted in review.
- **The AI safety policy is non-negotiable**: no PR may add a category of
  destructive action that executes automatically. Auto-applied actions must be
  reversible and bounded; everything else is a logged suggestion.

### What will not be merged

- NVIDIA support (out of scope, no hardware to test on)
- Anti-cheat workarounds of any kind
- Features that bake credentials into the ISO

---

## Español

Gracias por plantearte contribuir. HyperArch es software en alfa construido y
probado contra una única máquina de referencia, así que los reportes del mundo
real son la contribución más valiosa que existe.

### Lo más útil que puedes hacer

1. **Compila la ISO y reporta lo que rompa.** Los nombres de paquetes cambian
   en Arch; `packages/*.txt` será lo primero en desactualizarse. Abre un issue
   con el log de `build.sh`.
2. **Prueba en QEMU** (`./test-vm.sh --with-disk`) y reporta los fallos del
   instalador con el mensaje de error exacto.
3. **Prueba en hardware AMD distinto al de referencia** y cuéntanos qué hubo
   que cambiar.

### Reglas

- Un cambio por pull request.
- Los scripts de shell deben pasar `bash -n` e idealmente `shellcheck`.
- El Python debe compilar (`python3 -m py_compile`).
- Mensajes de commit en [Conventional Commits](https://www.conventionalcommits.org):
  `feat(installer): ...`, `fix(widgets): ...`, `docs(readme): ...`
- Los textos de cara al usuario en el escritorio van primero en español
  (usuario de referencia); la documentación es bilingüe. Escribe en el idioma
  que te sea cómodo y la traducción se resuelve en la revisión.
- **La política de seguridad de la IA no es negociable**: ningún PR puede
  añadir una categoría de acción destructiva que se ejecute automáticamente.
  Las acciones auto-aplicadas deben ser reversibles y acotadas; todo lo demás
  es una sugerencia registrada en el log.

### Lo que no se va a fusionar

- Soporte NVIDIA (fuera de alcance, sin hardware donde probarlo)
- Elusiones de anti-cheat de ningún tipo
- Funcionalidades que horneen credenciales en la ISO
