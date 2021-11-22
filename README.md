# Ansible Role: Tailscale

[![CI](https://github.com/jason-riddle/ansible-role-tailscale/workflows/CI/badge.svg?event=push)](https://github.com/jason-riddle/ansible-role-tailscale/actions?query=workflow%3ACI)

Installs [Tailscale](https://tailscale.com/) on Debian/Ubuntu.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

    tailscale_apt_release_stability: stable

The release stability to use. There are two options, `stable` or `unstable`.

    tailscale_apt_key: "https://pkgs.tailscale.com/{{ tailscale_apt_release_stage }}/{{ ansible_distribution|lower }}/{{ ansible_distribution_release|lower }}.gpg"
    tailscale_apt_repository: "deb https://pkgs.tailscale.com/{{ tailscale_apt_release_stage }}/{{ ansible_distribution|lower }} {{ ansible_distribution_release|lower }} main"
    tailscale_apt_ignore_key_error: false

Apt repository options for tailscale installation.

    tailscale_daemon_state: started
    tailscale_daemon_enabled: true

Configure the state of the tailscale deamon.

    tailscale_skip_up: false

Skip running tailscale up.

    tailscale_up_auth_key: ""

Use the following key when authorizing.

    tailscale_up_command_timeout: 10

Timeout to wait for the up command to complete.

    tailscale_up_args: []

A list of additional args to pass to the up command. See https://tailscale.com/kb/1080/cli/#up.

## Dependencies

None.

## Example Playbook

    - hosts: all

      vars:
        tailscale_up_auth_key: "tskey-abcdef1234567890"
        tailscale_up_args:
          - --advertise-tags=tag:server,tag:staging

      roles:
        - jason_riddle.tailscale

## License

MIT
