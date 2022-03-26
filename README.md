# Ansible Role for Tailscale

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

    tailscale_service_state: started
    tailscale_service_enabled: true

Configure the state of the tailscale service.

    tailscale_run_up_command: false

Run the up command.

    tailscale_up_auth_key: null

The auth key to use for the up command. Set to a string (not recommended),
ansible fact, dynamic lookup, or reference an environment variable ex.
`"{{ lookup('env', 'TAILSCALE_AUTH_KEY') }}"`.

    tailscale_up_command_timeout: 10

Timeout to wait for the up command to complete.

    tailscale_up_args: []

A list of additional args to pass to the up command. See https://tailscale.com/kb/1080/cli/#up.

    tailscale_config_contents: |
      # Set the port to listen on for incoming VPN packets.
      # Remote nodes will automatically be informed about the new port number,
      # but you might want to configure this in order to set external firewall
      # settings.
      PORT="41641"

      # Extra flags you might want to pass to tailscaled.
      FLAGS=""

The configuration for /etc/default/tailscale.

## Dependencies

None.

## Example Playbook

    - hosts: all

      vars:
        tailscale_run_up_command: true
        tailscale_up_auth_key: "{{ lookup('env', 'TAILSCALE_AUTH_KEY') }}"
        tailscale_up_args:
          - --advertise-tags=tag:server,tag:staging

      roles:
        - jason_riddle.tailscale

## License

MIT
