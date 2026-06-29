# windows-11

Entorno paralelo a `fedora-sway-spin`, para una maquina Windows 11. Mantiene la
misma filosofia: un bootstrap idempotente que orquesta pasos numerados, una lista
declarativa de paquetes y configs versionadas.

## Equivalencias con Fedora

| Fedora (`fedora-sway-spin`)      | Windows (`windows-11`)                                |
| -------------------------------- | ----------------------------------------------------- |
| `bootstraping.sh`                | `bootstrap.ps1`                                        |
| `dnf` + `packages.txt`           | `winget` (`packages.json`) + `scoop` (`scoop-packages.txt`) |
| GNU Stow                         | stub de `$PROFILE` + symlinks (Developer Mode)        |
| bash + `.bashrc.d/`              | PowerShell 7 + `dotfiles/powershell/profile.d/`       |
| PS1 + `__git_ps1`                | Starship (`starship.toml`)                            |
| foot (`foot.ini`)                | Windows Terminal (`settings.json`)                    |
| tmux                             | paneles de Windows Terminal (sin sesiones persistentes) |
| nvim (submodulo)                 | el mismo submodulo, linkeado a `%LOCALAPPDATA%\nvim`  |
| Zed (`settings.json.in` + jq merge) | igual: `dotfiles\zed` mergeado a `%APPDATA%\Zed`    |

## Setup

Requiere **PowerShell 7** (`pwsh`). Si solo tenes Windows PowerShell 5.1, instala
PowerShell 7 con `winget install Microsoft.PowerShell` y reabri la terminal.

```powershell
git clone --recurse-submodules https://github.com/ndelucca/nd.environment.git "$HOME\nd.environment"
cd "$HOME\nd.environment"
pwsh -File .\windows-11\bootstrap.ps1
```

Para que los symlinks funcionen sin admin, habilita **Developer Mode**
(Settings -> Privacy & security -> For developers). Si no, el bootstrap copia los
configs en lugar de linkearlos (funciona igual, pero hay que reejecutar tras
editar un config).

Despues del bootstrap, **abri una terminal nueva** para tomar el profile.

## SSH (manual, por maquina)

Las claves SSH no estan en el repo. En cada maquina nueva:

```powershell
ssh-keygen -t ed25519 -C "ndelucca@protonmail.com"
Get-Content "$HOME\.ssh\id_ed25519.pub"   # agregarla en GitHub -> Settings -> SSH keys
```

## Nota sobre WSL

WSL es una terminal aparte y no se provisiona desde este bootstrap. Lo relevante:

- El clipboard funciona dentro de WSL/Windows Terminal via OSC-52 (ya configurado
  en el `tmux.conf` de Fedora), sin pasos extra.
- Performance: mantener los repos en el filesystem de Linux (`~`), no en `/mnt/c`.
- Reutilizacion: dentro de WSL se puede clonar el repo y aplicar el mismo
  `fedora-sway-spin/dotfiles/.bashrc.d` con stow, sin trabajo nuevo.
- Starship es multiplataforma: el mismo `starship.toml` podria unificar el prompt
  de Fedora a futuro.
