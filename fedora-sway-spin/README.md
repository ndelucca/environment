# Fedora Sway Spin — entorno de Naza

Configuración personal sobre **Fedora Sway Spin**. Este README documenta la
**intención, la situación y las reglas** del setup, para no tener que re-investigar
decisiones ya tomadas. Para los pasos de instalación generales, ver el
[`README.md` de la raíz](../README.md).

## Intención

Un escritorio **Wayland-first**, cohesivo (familia GTK/Adwaita), moderno y
**reproducible**, que se **apoya en el Spin** en vez de pelearse con él. La idea es
tocar el sistema lo mínimo: heredar lo que el Spin ya resuelve bien y solo override /
agregar lo propio, de forma declarativa y versionada.

## Cómo está armado (situación)

- **Instalación:** `bootstraping.sh` corre los pasos `setup/NN-*.sh` en orden
  (idempotentes). Valores por máquina en `vars.sh` (única fuente de verdad);
  hardware (monitores, sensor de temperatura) autodetectado en runtime. La lista
  autoritativa de paquetes dnf vive en `setup/packages.txt` (lo de abajo es un resumen
  conceptual del stack, no el manifiesto).
- **Dotfiles:** GNU **stow** `--no-folding` symlinkea `dotfiles/{.bashrc.d,.config,.local}`
  a `~`. Configs con valores variables se generan desde templates `.in`: `04-stow.sh`
  los renderiza (sed/jq) con los valores de `vars.sh` ANTES de stowear, y el resultado
  queda git-ignorado; solo se versiona el `.in`.
- **Config de Sway en capas:** usamos el `include` con `layered-include` del Spin. Los
  defaults del Spin viven en `/usr/share/sway/config.d/*`; nosotros override por
  **mismo nombre de archivo** en `~/.config/sway/config.d/`. **No** forkeamos archivos
  del sistema.
- **nvim:** submódulo aparte (`git@github.com:ndelucca/nvim.git`), gestionado con
  `vim.pack` nativo (sin gestor de plugins externo). `bootstraping.sh` corre
  `git submodule update --init --recursive`; si clonaste sin `--recurse-submodules`,
  ese paso lo trae igual.

## Reglas / decisiones (lo que conviene recordar)

### Wayland / compositor
- Stack 100% Wayland-nativo: sway, foot, waybar, swaync, swaylock, swayidle (del Spin),
  kanshi, wlsunset, swayosd, grim+slurp+swappy, wl-clipboard+cliphist, swaybg.
- **rofi = `rofi` 2.0** = el fork *rofi-wayland* ya mainline. Corre **nativo en
  Wayland**, NO es el viejo rofi X11. No migrar "por ser X11".
- **No** seteamos `MOZ_ENABLE_WAYLAND` / `GDK_BACKEND` etc.: en Fedora 44 son
  innecesarios (Firefox/GTK ya van a Wayland). Evitar ese cruft.
- `$lock_timeout` / `$screen_timeout` (en `sway/config`) **los consume el
  `90-swayidle.conf` del Spin** (están definidos antes del `include`). No son variables
  muertas.
- **waybar lo arranca el Spin** vía `swaybar_command waybar` en su `90-bar.conf`. Por
  eso no hay `exec waybar` en nuestra config, y está bien.
- **Deriva del Spin:** como varios daemons (waybar, swayidle, agente polkit) y el
  `include` en capas dependen de archivos del Spin que NO controlamos, si una versión
  futura los renombra/elimina las cosas fallan en silencio. Correr **`nd-doctor`** (en
  `~/.local/bin`, también al final del bootstrap) chequea que esas suposiciones sigan
  válidas tras una actualización del sistema.
- kanshi arranca por `exec_always` en `sway/config` (el `kanshi.service` está disabled).
- **Multi-monitor:** los nombres de output viven en `vars.sh`
  (`OUTPUT_INTERNAL`/`OUTPUT_EXTERNAL`, única fuente de verdad); tanto `sway/config` como
  `kanshi/config` se generan desde ahí. Si cambiás de monitor o de puerto, corré
  `swaymsg -t get_outputs` para ver los nombres reales y actualizá esos dos valores en
  `vars.sh` (más `DOCK_LEFT_WIDTH`), luego re-corré `04-stow.sh`.

### Toolkit y theming
- Familia **GTK / Adwaita-dark** en todo (GTK3 + GTK4 coordinados, cursor Adwaita 24
  replicado a XWayland por `environment.d/cursor.conf`).
- **Qt:** no se puede sacar 100% del Spin (entra por `lxqt-policykit` que arranca el
  Spin, `sddm`, `gstreamer-qt6`, `kf6-*`, `qtwebengine`). En vez de eso lo dejamos
  **cubierto como baseline**: `qt6ct` + `environment.d/qt.conf`
  (`QT_QPA_PLATFORM=wayland;xcb`, `QT_QPA_PLATFORMTHEME=qt6ct`) + `qt6ct/qt6ct.conf`
  (Fusion + paleta oscura + diálogos GTK). Así cualquier app Qt (incluido el diálogo de
  polkit) sale dark + Wayland. No reemplazamos el agente polkit del Spin.
- **Paletas (2 dominios):** el toolkit (GTK/Adwaita-dark) es el baseline, y el color de
  acento se divide en dos dominios deliberados, no por descuido:
  1. **Desktop + Terminal** (waybar, rofi, swaync, swayosd, swaylock, foot, tmux, prompt
     bash) → verde unificado `#387838` (el de tmux).
  2. **Editores** (nvim + Zed) → **Dracula** (púrpura), igual en ambos para que el editor
     sea su propia superficie de foco, consistente entre sí aunque distinta del escritorio.
  Cada herramienta replica el hex a mano en su config (no hay SSOT de color); es deuda
  conocida y aceptada (cada herramienta usa una sintaxis distinta). waybar además usa
  unos pocos colores *semánticos de estado* (cargando, screenshare, muteado, etc.),
  aparte del acento a propósito; sus valores viven en el `@define-color` de
  `waybar/style.css` (no se enumeran acá para que esta nota no quede desactualizada).

### Login / sesión
- **SDDM lo trae el Spin** (`reason: Group`); nosotros **solo lo configuramos**
  (`02-...sh` escribe `/etc/sddm.conf.d/ndelucca.conf` + wallpaper, no lo instala).
  Su greeter corre en **Wayland** (`sddm-wayland-sway`, `DisplayServer=wayland`). Es
  Qt pero pre-sesión: se deja como está.
- **Agente polkit:** lo arranca el Spin (`/usr/share/sway/config.d/95-autostart-policykit-agent.conf`
  → `lxqt-policykit-agent`). Se deja (queda pintado por qt6ct).

### Audio / red
- **Audio = PipeWire** (+ `pipewire-pulse` + wireplumber). NO PulseAudio. El módulo
  `pulseaudio` de waybar usa la capa de compat — es lo correcto.
- Red = NetworkManager (`nmcli`, script `nd-fixed-ip`).

### Tareas croneadas (systemd user)
- Las tareas personales recurrentes corren como **systemd *user* units**, no atadas al
  arranque de la shell. Las units viven versionadas en `dotfiles/.config/systemd/user/` y
  las symlinkea **stow** junto con el resto de `.config`.
- Habilitarlas (crear los symlinks en `timers.target.wants/`) es trabajo de `systemctl`,
  no de stow: lo hace `setup/08-systemd-user.sh` después del stow, con
  `daemon-reload` + `enable --now`. **Convención:** habilita cualquier `nd-*.timer` del
  directorio. Agregar una tarea = soltar su `.service` + `.timer` con prefijo `nd-` y
  re-correr el bootstrap.
- No usa `loginctl enable-linger`: alcanza con la sesión gráfica activa. El paso de setup
  saltea sin romper si corre sin user manager (bootstrap headless).
- **`nd-public-ip`**: chequea la IP pública al iniciar sesión y cada hora
  (`nd-public-ip.timer` → `.service` → `nd-public-ip check`). Si cambió, avisa por
  **notificación de escritorio** (`notify-send`/dunst); ya no muestra alerta en la
  terminal. Aceptar la IP nueva con `nd-public-ip update`. El alias `myip` sigue usando
  `nd-public-ip show`.

### Fuentes
- **Regla: solo JetBrainsMono Nerd Font** en toda la UI (terminal, GTK, barras,
  launcher, lock). La trae el COPR `jhuang6451/nerd-fonts` (`jetbrains-mono-nf`).

### Editores
- **nvim** (terminal) + **Neovide** (GUI del *mismo* nvim) + **Zed**.
- Neovide se instala desde el **binario oficial de release** a `~/.local/bin/neovide-bin`
  (en `03-apps.sh`), NO por flatpak (el flatpak corre nvim en sandbox y no usaría el
  nvim / LSPs / toolchains del host). Comparte la config del submódulo nvim. Como no hay
  paquete que lo actualice, re-correr el bootstrap re-baja el binario cuando el release
  más nuevo (API de GitHub) difiere del instalado.
- El comando `neovide` en PATH es un **wrapper** (`dotfiles/.local/bin/neovide`): Neovide
  necesita **OpenGL >= 3.2** y en GPUs viejas (este Aspire 5742 tiene Intel Ironlake, tope
  GL 2.1) el contexto GL falla (`EGL_BAD_MATCH`). El wrapper detecta la versión de GL con
  `glxinfo` y cae a **render por software** (llvmpipe) solo si hace falta; en hardware
  capaz no toca nada. Trade-off en esta laptop: anda pero por CPU (no acelerado).

### Apps por defecto
- Terminal foot · launcher rofi · imágenes **Loupe** · PDF **Papers** · video **mpv** ·
  archivos **Thunar** · navegadores firefox/chromium. Los handlers se setean con
  `xdg-mime` al final de `03-apps.sh` (escriben en `~/.config/mimeapps.list`, que **no**
  se stowea porque es un archivo real que el sistema reescribe; lo que no seteamos —p. ej.
  http→chromium— se respeta como esté). Los archivos de texto/código (text/plain incluido,
  ver `NEOVIDE_MIMES`) abren en **Neovide**, no en nvim-en-terminal.
- **PWAs** vía `chromium --app=` (Spotify, ChatGPT, WhatsApp, Gmail) en `05-webapps.sh`
  — sin Electron. La lista vive en el array `WEBAPPS`; sacar un servicio de ahí borra su
  lanzador en la próxima corrida (prune declarativo).

### Apps que NO queremos
- Se borran de forma declarativa: la lista vive en `setup/remove-packages.txt`, borrado
  idempotente por `setup/07-remove-unwanted.sh` (cableado en `bootstraping.sh`).
