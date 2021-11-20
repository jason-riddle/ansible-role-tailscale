# Ansible Role: Tailscale

[![CI](https://github.com/jason-riddle/ansible-role-tailscale/workflows/CI/badge.svg?event=push)](https://github.com/jason-riddle/ansible-role-tailscale/actions?query=workflow%3ACI)

Installs [Tailscale](https://tailscale.com/) on Debian/Ubuntu.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

    tailscale_apt_release_stage: stable

The release stage to use for downloading. There are two release stages, `stable` or `unstable`.

    tailscale_apt_key: "https://pkgs.tailscale.com/{{ tailscale_apt_release_stage }}/{{ ansible_distribution|lower }}/{{ ansible_distribution_release|lower }}.gpg"
    tailscale_apt_repository: "deb https://pkgs.tailscale.com/{{ tailscale_apt_release_stage }}/{{ ansible_distribution|lower }} {{ ansible_distribution_release|lower }} main"
    tailscale_apt_ignore_key_error: false

Apt repository options for tailscale installation.

    tailscaled_daemon_state: started
    tailscaled_daemon_enabled: true

Configure the state of the tailscaled deamon.

    tailscale_authorize_daemon: true

Run the authorize command.

    tailscale_authorize_key: "tskey-abcdef1234567890"

Use the following key when authorizing.

    tailscale_authorize_timeout: 10

Timeout to wait for the authorize command to complete.

## Dependencies

None.

## Example Playbook

    - hosts: all

      vars:
        tailscale_apt_release_stage: "stable"
        tailscale_authorize_key: "tskey-abcdef1234567890"

      roles:
        - jason_riddle.tailscale

## License

MIT