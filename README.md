# Ansible Role for Tailscale

[![CI](https://github.com/jason-riddle/ansible-role-tailscale/workflows/CI/badge.svg?event=push)](https://github.com/jason-riddle/ansible-role-tailscale/actions?query=workflow%3ACI)

Installs [Tailscale](https://tailscale.com/) on Debian/Ubuntu.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

    tailscale_apt_gpg_key: "https://pkgs.tailscale.com/stable/{{ ansible_distribution|lower }}/{{ ansible_distribution_release|lower }}.gpg"
    tailscale_apt_repository: "deb https://pkgs.tailscale.com/stable/{{ ansible_distribution|lower }} {{ ansible_distribution_release|lower }} main"

Apt repository options for Tailscale installation.

    tailscale_service_name: "tailscaled"
    tailscale_service_state: started
    tailscale_service_enabled: true
    tailscale_restart_handler_state: restarted

Configure the state of the Tailscale service.

    tailscale_register_node: false

Register the node to a Tailnet.

    tailscale_register_authkey: ""

Register the node with this authkey.

    tailscale_register_timeout: "30s"

Max amount of time to wait for the Tailscale service to initialize.

    tailscale_register_args: "--accept-routes"

Additional args to use when registering. See https://tailscale.com/kb/1080/cli/#up.

    tailscale_default_tailscaled_options:
      # Allow www-data user to fetch certs
      - regexp: "^#?TS_PERMIT_CERT_UID"
        line: "TS_PERMIT_CERT_UID=\"www-data\""

Use Ansible's `lineinfile` module to ensure certain settings are configured inside `/etc/default/tailscaled`.

## Dependencies

None.

## Example Playbook

### Install and register the agent using a hostname

```yaml
- hosts: all

  vars:
    tailscale_register_node: true
    tailscale_register_authkey: "{{ lookup('env', 'TAILSCALE_AUTHKEY') }}"
    tailscale_register_args: "--hostname={{ lookup('env', 'HOSTNAME') }}-{{ ansible_distribution|lower }}"

  roles:
    - jason_riddle.tailscale
```

## License

MIT
