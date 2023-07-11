# Ansible Role for Tailscale

[![CI](https://github.com/jason-riddle/ansible-role-tailscale/workflows/CI/badge.svg?event=push)](https://github.com/jason-riddle/ansible-role-tailscale/actions?query=workflow%3ACI)

[Tailscale](https://tailscale.com/) on Linux.

Features:
- Install Tailscale.
- Register Node to Tailnet.
- (Beta Feature) Provision HTTPS certificates.
- (Beta Feature) Run Funnel.

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

Control the state of the tailscaled service.

    tailscale_up_node: false
    tailscale_up_authkey: ""
    tailscale_up_timeout: "30s"
    tailscale_up_extra_args: ""
    tailscale_up_no_log: true

Run `tailscale up` with arguments. `tailscale_up_authkey` must be set.

See https://tailscale.com/kb/1080/cli/#up.

    tailscale_cert_enabled: false
    tailscale_cert_domain: ""
    tailscale_cert_dir: "/usr/local/etc/ssl/certs"
    tailscale_cert_filename: "{{ tailscale_cert_domain }}.crt"
    tailscale_cert_private_key_dir: "/usr/local/etc/ssl/private"
    tailscale_cert_private_key_filename: "{{ tailscale_cert_domain }}.key"

**This feature is in beta. It may be removed or changed in a future release.**

Run `tailscale cert` with arguments. `tailscale_cert_domain` must be set.

See https://tailscale.com/kb/1153/enabling-https/.

    tailscale_cert_enabled: false

**This feature is in beta. It may be removed or changed in a future release.**

Run `tailscale funnel` with arguments.

See https://tailscale.com/kb/1223/tailscale-funnel/.

    tailscale_default_options_enabled: false
    tailscale_default_options_settings:
      # Allow caddy user to fetch cert.
      # See https://tailscale.com/kb/1190/caddy-certificates/#provide-non-root-users-with-access-to-fetch-certificate.
      - regexp: "^#?TS_PERMIT_CERT_UID"
        line: "TS_PERMIT_CERT_UID=\"caddy\""

Configures /etc/default/tailscaled.

## Dependencies

None.

## Example Playbook

### Install Tailscale.

```yaml
- hosts: all

  roles:
    - jason_riddle.tailscale
```

### Register Node to Tailnet.

```yaml
- hosts: all

  vars:
    tailscale_up_node: true
    tailscale_up_authkey: "{{ lookup('env', 'TAILSCALE_AUTHKEY') }}"
    # Optional: Specify args to `tailscale up` command.
    tailscale_up_extra_args: "--hostname={{ lookup('env', 'HOSTNAME') }}-{{ ansible_distribution|lower }}"

  roles:
    - jason_riddle.tailscale
```

### (Beta Feature) Provision HTTPS certificates.

See https://tailscale.com/kb/1153/enabling-https/.

```yaml
- hosts: all

  vars:
    tailscale_cert_enabled: true
    tailscale_cert_domain: "machine-name.domain-alias.ts.net"
    tailscale_cert_dir: "/usr/local/etc/ssl/certs"
    tailscale_cert_filename: "{{ tailscale_cert_domain }}.crt"
    tailscale_cert_private_key_dir: "/usr/local/etc/ssl/private"
    tailscale_cert_private_key_filename: "{{ tailscale_cert_domain }}.key"
    tailscale_default_options_enabled: true
    tailscale_default_options_settings:
      # Allow caddy user to fetch cert.
      # See https://tailscale.com/kb/1190/caddy-certificates/#provide-non-root-users-with-access-to-fetch-certificate.
      - regexp: "^#?TS_PERMIT_CERT_UID"
        line: "TS_PERMIT_CERT_UID=\"caddy\""

  roles:
    - jason_riddle.tailscale
```

### (Beta Feature) Run Funnel.

See https://tailscale.com/kb/1223/tailscale-funnel/.

```yaml
- hosts: all

  vars:
    tailscale_funnel_enabled: true

  roles:
    - jason_riddle.tailscale
```

## License

MIT
