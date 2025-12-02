# My Environment

For a long time I've been playing around with several linux distributions.

Current environment: Fedora Sway Spin

## Setup

```bash
git clone https://github.com/ndelucca/environment.git "${HOME}/environment"

cd "${HOME}/environment"

./fedora-sway-spin/bootstraping.sh
```

## Home Server

Ansible configuration for my Fedora home server with Cockpit web management and AdGuard Home DNS filtering.

```bash
cd "${HOME}/environment/home-server"

ansible-playbook playbooks/site.yml -l server-host
```
