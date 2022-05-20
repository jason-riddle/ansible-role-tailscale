# Ansible Role for Tailscale

[![CI](https://github.com/jason-riddle/ansible-role-tailscale/workflows/CI/badge.svg?event=push)](https://github.com/jason-riddle/ansible-role-tailscale/actions?query=workflow%3ACI)

Installs [Tailscale](https://tailscale.com/) on Debian/Ubuntu.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

    tailscale_apt_gpg_key: "https://pkgs.tailscale.com/stable/{{ ansible_distribution|lower }}/{{ ansible_distribution_release|lower }}.gpg"
    tailscale_apt_repository: "deb https://pkgs.tailscale.com/stable/{{ ansible_distribution|lower }} {{ ansible_distribution_release|lower }} main"

Apt repository options for tailscale installation.

## Dependencies

None.

## Example Playbook

    - hosts: all

      roles:
        - jason_riddle.tailscale

## License

MIT
