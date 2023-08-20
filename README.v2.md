# Ansible Role for Tailscale

[![CI](https://github.com/jason-riddle/ansible-role-tailscale/workflows/CI/badge.svg?event=push)](https://github.com/jason-riddle/ansible-role-tailscale/actions?query=workflow%3ACI)

Install, configure, and manage [Tailscale](https://tailscale.com/) on Linux.

Tailscale is a modern, easy-to-use VPN. It enables you to share access to machines and devices in a secure way.

## Features

The following features are available:
  - Install the Tailscale agent on a Debian or Redhat-based machine.
  - Register the Tailscale agent to a tailnet.

The following features are in beta. **They may be changed or removed in a future release**:
  - Generate HTTPS certs, for serving HTTPS traffic with Tailscale or with [Caddy](https://caddyserver.com/).

Examples are available to show how to use each feature. See the [Examples](#Examples) section.

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

    tailscale_default_options_enabled: false
    tailscale_default_options_settings:
      # Allow caddy user to fetch cert.
      # See https://tailscale.com/kb/1190/caddy-certificates/#provide-non-root-users-with-access-to-fetch-certificate.
      - regexp: "^#?TS_PERMIT_CERT_UID"
        line: "TS_PERMIT_CERT_UID=\"caddy\""

Configures /etc/default/tailscaled.

## Dependencies

None.

## Examples

# Install the Tailscale agent, but don’t register the agent to a tailnet.

```yaml
- hosts: all

  roles:
    - jason_riddle.tailscale
```

# Install the Tailscale agent and register the agent to a tailnet.

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

# Generate an HTTPS cert for serving HTTPS traffic.

See https://tailscale.com/kb/1153/enabling-https/ for more information on this feature.

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

Note: By default, Tailscale traffic is secure and encrypted, but is served over HTTP. Here is an explanation about this from their website: https://tailscale.com/kb/1153/enabling-https/

> Connections between Tailscale nodes are secured with end-to-end encryption. Browsers, web APIs, and products like Visual Studio Code are not aware of that, however, and can warn users or disable features based on the fact that HTTP URLs to your tailnet services look unencrypted since they’re not using TLS certificates, which is what those tools are expecting.

So, while this is secure, sometimes you absolutely require the HTTPS protocol to be used. An example is an application that only serves traffic over HTTPS and refuses to run on HTTP. Another example is a tool that only allows communication via an HTTPS endpoint.

## License

MIT
