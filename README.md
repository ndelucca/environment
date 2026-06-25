# My Environment

For a long time I've been playing around with several linux distributions.

Current environment: Fedora Sway Spin

## Setup

Clone with submodules (the nvim config lives in a submodule):

```bash
git clone --recurse-submodules https://github.com/ndelucca/environment.git "${HOME}/environment"

cd "${HOME}/environment"

./fedora-sway-spin/bootstraping.sh
```

The bootstrap also runs `git submodule update --init --recursive`, so an existing
clone without `--recurse-submodules` is fixed automatically.

### SSH (manual, per machine)

SSH keys are not stored in this repo. On each new machine generate a key and add
the public part to GitHub:

```bash
ssh-keygen -t ed25519 -C "ndelucca@protonmail.com"
cat ~/.ssh/id_ed25519.pub   # add this to GitHub → Settings → SSH keys
```

`GIT_SSH_COMMAND` (in `.bashrc.d/01-ps1.sh`) already points to `~/.ssh/id_ed25519`.

### Notes

- `common-scripts/` are helper scripts for setting up Raspberry Pi boards; they
  are **not** part of the PC setup and are not run by the bootstrap.

## Home Server

Ansible configuration for my Fedora home server with Cockpit web management and AdGuard Home DNS filtering.

```bash
cd "${HOME}/environment/home-server"

ansible-playbook playbooks/site.yml -l server-host
```
