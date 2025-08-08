# Ansible Configuration - Beastie (FreeBSD Development Workstation)

## Target System

- **Platform**: FreeBSD development workstation
- **Purpose**: Personal development environment configuration
- **Management**: Ansible automation

## Configuration Constraints

- Use FreeBSD package manager (`pkg`) not Linux package managers
- Prefer ports collection when packages unavailable
- Respect FreeBSD file system hierarchy (`/usr/local/` for third-party software)
- Use FreeBSD service management (`service`, `sysrc`)
- Follow FreeBSD security practices (user/group management, file permissions)

## Execution Model

**NEVER run ansible commands directly.** Only tell the user what commands to run, then wait for their output.

## Ansible Best Practices

- Use descriptive task names
- Group related tasks with tags
- Make playbooks idempotent
- Use handlers for service restarts
- Validate configurations before applying

## Development Tools Focus

- Text editors, IDEs, development languages
- Version control systems
- Build tools and compilers
- Development databases and services
- Networking and debugging tools
