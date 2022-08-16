# Ansible Role for Tailscale

[![CI](https://github.com/jason-riddle/ansible-role-tailscale/workflows/CI/badge.svg?event=push)](https://github.com/jason-riddle/ansible-role-tailscale/actions?query=workflow%3ACI)

Installs [Tailscale](https://tailscale.com/) on Debian/Ubuntu and RedHat/CentOS.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

    tailscale_apt_gpg_key: "https://pkgs.tailscale.com/stable/{{ ansible_distribution|lower }}/{{ ansible_distribution_release|lower }}.gpg"
    tailscale_apt_repository: "deb https://pkgs.tailscale.com/stable/{{ ansible_distribution|lower }} {{ ansible_distribution_release|lower }} main"

Apt repository options for Tailscale installation.

    tailscale_yum_repository_url: "https://pkgs.tailscale.com/stable/{{ ansible_distribution|lower }}/{{ ansible_distribution_major_version }}/tailscale.repo"

Yum repository options for Tailscale installation.

    tailscale_service_name: "tailscaled"
    tailscale_service_state: started
    tailscale_service_enabled: true

Control the state of the Tailscaled service, and whether it should start on boot.

    tailscale_register_node: false
    tailscale_register_authkey: ""
    tailscale_register_timeout: "30s"
    tailscale_register_args: "--accept-routes"

Register the node. Runs `tailscale up` and passes arguments to that command. `tailscale_register_authkey` must be set.

See https://tailscale.com/kb/1080/cli/#up.

    tailscale_generate_cert: false
    tailscale_cert_domain: ""
    tailscale_cert_dir: "/usr/local/etc/ssl/certs"
    tailscale_cert_filename: "{{ tailscale_cert_domain }}.crt"
    tailscale_cert_private_key_dir: "/usr/local/etc/ssl/private"
    tailscale_cert_private_key_filename: "{{ tailscale_cert_domain }}.key"

**This feature is in beta. It may be removed or changed in a future release.**

Generate a TLS cert for HTTPS. Runs `tailscale cert` and passes arguments to that command. `tailscale_cert_domain` must be set.

See https://tailscale.com/kb/1153/enabling-https/.

    tailscale_default_tailscaled_options:
      # Allow caddy user to fetch cert.
      # See https://tailscale.com/kb/1190/caddy-certificates/#provide-non-root-users-with-access-to-fetch-certificate.
      - regexp: "^#?TS_PERMIT_CERT_UID"
        line: "TS_PERMIT_CERT_UID=\"caddy\""

Use Ansible's `lineinfile` module to ensure certain settings are configured inside `/etc/default/tailscaled`.

## Dependencies

None.

## Example Playbook

### Register the node using a custom hostname

```yaml
- hosts: all

  vars:
    tailscale_register_node: true
    tailscale_register_authkey: "{{ lookup('env', 'TAILSCALE_AUTHKEY') }}"
    tailscale_register_args: "--hostname={{ lookup('env', 'HOSTNAME') }}-{{ ansible_distribution|lower }}"

  roles:
    - jason_riddle.tailscale
```

### (In beta) Generate a TLS cert for HTTPS and allow caddy user to fetch cert.

```yaml
- hosts: all

  vars:
    tailscale_generate_cert: true
    tailscale_cert_domain: "machine-name.domain-alias.ts.net"
    tailscale_cert_dir: "/usr/local/etc/ssl/certs"
    tailscale_cert_filename: "{{ tailscale_cert_domain }}.crt"
    tailscale_cert_private_key_dir: "/usr/local/etc/ssl/private"
    tailscale_cert_private_key_filename: "{{ tailscale_cert_domain }}.key"
    tailscale_default_tailscaled_options:
      # Allow caddy user to fetch cert.
      # See https://tailscale.com/kb/1190/caddy-certificates/#provide-non-root-users-with-access-to-fetch-certificate.
      - regexp: "^#?TS_PERMIT_CERT_UID"
        line: "TS_PERMIT_CERT_UID=\"caddy\""

  roles:
    - jason_riddle.tailscale
```

## License

MIT
