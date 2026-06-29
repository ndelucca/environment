# Zed — referencia rápida

Notas extraídas de los comentarios de `keymap.json` / `settings.json.in`, para
tener a mano los flujos sin abrir los configs. Filosofía: apoyarse en los
bindings **nativos** de Zed (que ya cubren los flujos de la config de nvim), y
remapear solo lo mínimo.

## Multicursor (≈ multicursor.nvim)

| Acción | Binding nativo Zed | Equivalente nvim |
|---|---|---|
| Cursor en **siguiente** ocurrencia | `g l` | `<C-n>` |
| Cursor en **anterior** ocurrencia | `g L` | — |
| **Saltear** la coincidencia actual | `g >` / `g <` | `<C-q>` (skip) |
| Seleccionar **todas** las ocurrencias | `g a` | — |
| Inserción en **columna** | `ctrl-v` + movimiento + `I` / `A` | visual-block |
| Agregar cursor **abajo / arriba** | `cmd-alt-j` / `cmd-alt-k` | `<C-j>` / `<C-k>` |

> Para **paridad exacta** con nvim (`<C-n>` / `<C-j>` / `<C-k>`), descomentar el
> segundo bloque de `keymap.json` (context `Editor && vim_mode == normal`):
> `ctrl-n` → `editor::SelectNext`, `ctrl-j` → `editor::AddSelectionBelow`,
> `ctrl-k` → `editor::AddSelectionAbove`.

## Otros flujos nativos (no hace falta remapear)

| Acción | Binding | Equivalente nvim |
|---|---|---|
| File finder | `space space` / `cmd-p` | `<leader>ff` |
| Project search / grep | `cmd-shift-f` | `<leader>fg` |
| File explorer | `-` | `-` (mini.files) |
| Ir a definición | `g d` | LSP |
| Referencias | `g r` | LSP |
| Rename | `f12` / `c d` | LSP |
| Code actions | `g .` | LSP |

## Remaps propios (`keymap.json`)

- `j k` / `j j` (en modo insert) → volver a normal (`vim::NormalBefore`).

## Nota sobre el versionado

`settings.json` se genera de `settings.json.in` por `setup/04-stow.sh` (deep-merge
con jq) y está git-ignored: Zed reescribe `settings.json` en runtime (p. ej.
`ssh_connections`), y solo el `.in` se trackea. Editá el `.in`, no el generado.
