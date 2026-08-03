# HyperArch — Brand assets

## Logo

| File | Use |
|---|---|
| `logo/hyperarch-logo-blue.png` | Original. Repository / GitHub identity. |
| `logo/hyperarch-logo-crimson.png` | Recoloured to the OS palette. Used in-system. |
| `logo/*-emblem.png` | Emblem only, no wordmark. Plymouth boot splash. |
| `logo/*-512.png`, `*-256.png` | Working sizes (README, icons). |

## Palette decision

**Blue and violet everywhere** — brand and system share one palette, taken
straight from the logo.

An earlier revision themed the desktop in crimson. It was dropped for a concrete
reason: HyperArch's status widgets (Netlify deploys, Render services, Docker
containers, GitHub Actions) use red to mean *failure*. With crimson also acting
as the brand accent, a glance at the top bar could not distinguish identity from
alarm. On a monitoring surface that is a real defect, not a matter of taste.

So the palette is now split by **meaning**, not by context:

- **Brand** — blue `#2f9bff` and violet `#6d3cff`. Borders, prompts, headings,
  active workspace, wallpaper.
- **State** — green `#4ade80` healthy, amber `#fbbf24` in progress,
  red `#ff3b5c` failed. Used nowhere else.

Red now appears on screen only when something is actually wrong.

## Colours

| Token | Value | Role |
|---|---|---|
| Background | `#090909` | Absolute black |
| Surface | `#0d0f14` | Panels, terminal body |
| Accent | `#2f9bff` | Brand primary |
| Accent violet | `#6d3cff` | Brand secondary, gradients |
| Text | `#d6e4f3` | Foreground |
| Muted | `#55606e` | Secondary text |
| State OK | `#4ade80` | Healthy |
| State warn | `#fbbf24` | In progress |
| State error | `#ff3b5c` | Failure — reserved |
