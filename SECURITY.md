# Security Policy / Política de seguridad

**EN** — Report vulnerabilities privately via GitHub Security Advisories
(Security tab → Report a vulnerability). Do not open public issues for
exploitable problems. Areas of special interest: the AI action layer
(`hyper-ai`, which runs privileged sysctl and renice operations), the installer
(runs as root against block devices), and anything touching `tokens.env`.
You should hear back within 7 days.

**ES** — Reporta vulnerabilidades en privado vía GitHub Security Advisories
(pestaña Security → Report a vulnerability). No abras issues públicos para
problemas explotables. Áreas de interés especial: la capa de acciones de la IA
(`hyper-ai`, que ejecuta operaciones privilegiadas de sysctl y renice), el
instalador (corre como root contra dispositivos de bloque) y todo lo que toque
`tokens.env`. Tendrás respuesta en un máximo de 7 días.

## Supported versions / Versiones con soporte

Alpha: only the latest release is supported. / Solo la última versión publicada.
