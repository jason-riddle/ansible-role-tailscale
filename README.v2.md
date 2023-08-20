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

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

## Dependencies

None.

## Examples

## License

MIT
