# Zed — referencia rapida (Windows)

Port de la config de Zed de `fedora-sway-spin`. Misma filosofia: apoyarse en los
bindings **nativos** de Zed (que ya cubren los flujos de la config de nvim) y
remapear solo lo minimo.

## Donde vive

Zed lee su config de `%APPDATA%\Zed\` (`settings.json`, `keymap.json`). El paso
`setup/04-link-configs.ps1` los despliega ahi:

- `settings.json` se **genera** con `jq` haciendo deep-merge de `settings.json.in`
  por encima del `settings.json` existente. Zed reescribe ese archivo en runtime
  (p. ej. `wsl_connections`), por eso no se symlinkea: el merge preserva ese estado
  de runtime y deja que la config versionada gane sobre los defaults. Edita el
  `.in`, no el generado.
- `keymap.json` va por **symlink** (Zed no lo reescribe).

## Multicursor (≈ multicursor.nvim)

| Accion | Binding nativo Zed | Equivalente nvim |
|---|---|---|
| Cursor en **siguiente** ocurrencia | `g l` | `<C-n>` |
| Cursor en **anterior** ocurrencia | `g L` | — |
| **Saltear** la coincidencia actual | `g >` / `g <` | `<C-q>` (skip) |
| Seleccionar **todas** las ocurrencias | `g a` | — |
| Insercion en **columna** | `ctrl-v` + movimiento + `I` / `A` | visual-block |

> Para **paridad exacta** con nvim (`<C-n>` / `<C-j>` / `<C-k>`), descomentar el
> segundo bloque de `keymap.json` (context `Editor && vim_mode == normal`).

## Otros flujos nativos (no hace falta remapear)

| Accion | Binding | Equivalente nvim |
|---|---|---|
| File finder | `space space` / `ctrl-p` | `<leader>ff` |
| Project search / grep | `ctrl-shift-f` | `<leader>fg` |
| File explorer | `-` | `-` (mini.files) |
| Ir a definicion | `g d` | LSP |
| Referencias | `g r` | LSP |
| Rename | `f12` / `c d` | LSP |
| Code actions | `g .` | LSP |

## Remaps propios (`keymap.json`)

- `j k` / `j j` (en modo insert) → volver a normal (`vim::NormalBefore`).
