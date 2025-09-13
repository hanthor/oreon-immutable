# Oreon Immutable OS

Oreon Immutable OS is a custom bootc-based (container-to-disk) operating system derived from AlmaLinux 10. It builds a custom immutable OS image using container technology that can be deployed as bootable disk images (QCOW2, ISO, raw) or run as containers.

This distribution combines the stability of AlmaLinux 10 with the power of immutable infrastructure, providing atomic updates, rollbacks, and enhanced security through containerized OS management.

## What is bootc?

[bootc](https://github.com/bootc-dev/bootc) is a new way to build and manage Linux systems using container technology. Unlike traditional package-based distributions, bootc systems are built as container images and deployed atomically, providing:

- **Immutable Infrastructure**: System files are read-only, preventing accidental modifications
- **Atomic Updates**: Complete system updates applied atomically with automatic rollback capability  
- **Containerized Builds**: OS images built using familiar container tooling (Podman/Docker)
- **Enhanced Security**: Reduced attack surface through immutable base system

## Features

- **Base**: AlmaLinux 10 bootc foundation
- **Desktop Environment**: GNOME Workstation with Oreon-specific customizations
- **Custom Branding**: Oreon logos, themes, and visual identity
- **Enhanced Extensions**: Pre-configured GNOME Shell extensions including:
  - Dash to Panel (Oreon edition)
  - Arc Menu (Oreon edition) 
  - Blur My Shell (Oreon edition)
  - Desktop Icons
- **Development Ready**: Includes kernel-devel, podman, and development tools
- **Hardware Support**: Comprehensive hardware support including Atheros firmware

# Community & Support

For questions and support:
- [Universal Blue Forums](https://universal-blue.discourse.group/) - General bootc and immutable OS discussions
- [Universal Blue Discord](https://discord.gg/WEu6BdFEtp) - Community chat and support
- [bootc discussion forums](https://github.com/bootc-dev/bootc/discussions) - Official bootc project discussions


## System Management

Oreon Immutable OS uses bootc for system management:

```bash
# Check current system status
sudo bootc status

# Update to latest version
sudo bootc upgrade

# Switch to a different version/variant
sudo bootc switch ghcr.io/hanthor/oreon-immutable:latest

# Rollback to previous version
sudo bootc rollback
```

# Building and Development

This section is for developers and advanced users who want to build custom variants of Oreon Immutable OS.

## Prerequisites

- Linux system with Podman installed
- [just](https://just.systems/man/en/introduction.html) command runner
- [bootc-image-builder](https://osbuild.org/docs/bootc/) for creating disk images

## Building the Container Image

```bash
# Build the container image
just build

# Build with custom parameters
just build ghcr.io/hanthor/oreon-immutable:latest latest
```

## Building Disk Images

After building the container image, you can create bootable disk images:

```bash
# Build QCOW2 virtual machine image
just build-qcow2

# Build ISO installer
just build-iso

# Build raw disk image  
just build-raw
```

## Development and Testing

```bash
# Lint shell scripts
just lint

# Format shell scripts
just format

# Check Justfile syntax
just check

# Clean build artifacts
just clean

# Run VM for testing
just run-vm-qcow2
```

# Technical Details

## Repository Structure

- **[Containerfile](./Containerfile)**: Defines the container image build process
- **[build.sh](./build_files/build.sh)**: Main system configuration script that:
  - Configures AlmaLinux repositories with package excludes
  - Adds Oreon-specific package repositories
  - Swaps AlmaLinux branding for Oreon branding
  - Installs GNOME workstation environment with Oreon customizations
- **[build.yml](./.github/workflows/build.yml)**: GitHub Actions workflow for container builds
- **[build-disk.yml](./.github/workflows/build-disk.yml)**: GitHub Actions workflow for disk image creation
- **[disk_config/](./disk_config/)**: Configuration files for different disk image formats

## Available Commands

The `Justfile` provides convenient commands for development:

```bash
# List all available commands
just --list

# Building
just build                # Build container image
just build-qcow2         # Build QCOW2 VM image
just build-iso           # Build ISO installer
just build-raw           # Build raw disk image

# Development
just lint                # Lint shell scripts
just format              # Format shell scripts  
just check               # Check Justfile syntax
just clean               # Clean build artifacts

# Testing
just run-vm-qcow2        # Run VM for testing
just spawn-vm            # Run VM with systemd-vmspawn
```

## Customization

To create your own variant:

1. **Fork this repository**
2. **Modify [build.sh](./build_files/build.sh)** to add/remove packages or configurations
3. **Update [Containerfile](./Containerfile)** if needed for different base images
4. **Adjust [Justfile](./Justfile)** to change the image name
5. **Configure GitHub Actions** for automated builds

## Container Registry

Pre-built images are available at:
- `ghcr.io/hanthor/oreon-immutable:latest`

Images are signed using cosign for security verification.

# Credits and Acknowledgments

Oreon Immutable OS is built upon the excellent work of several open source projects:

## Core Technologies

- **[AlmaLinux](https://almalinux.org/)**: The stable enterprise Linux base providing the foundation for Oreon
- **[bootc](https://github.com/bootc-dev/bootc)**: The innovative container-to-disk technology enabling immutable OS delivery
- **[Universal Blue](https://universal-blue.org/)**: The community project and template that inspired this distribution approach

## Build Infrastructure

- **[bootc-image-builder](https://osbuild.org/docs/bootc/)**: Tool for creating bootable disk images from container images
- **[Podman](https://podman.io/)**: Container engine used for building and running images
- **[GitHub Actions](https://github.com/features/actions)**: CI/CD platform powering automated builds

## Community Examples

These distributions served as inspiration and examples for bootc-based systems:
- [m2Giles' OS](https://github.com/m2giles/m2os)
- [bOS](https://github.com/bsherman/bos)  
- [Homer](https://github.com/bketelsen/homer/)
- [Amy OS](https://github.com/astrovm/amyos)
- [VeneOS](https://github.com/Venefilyn/veneos)

## License

This project maintains the same licensing as its upstream components. See [LICENSE](./LICENSE) for details.

## Contributing

Contributions are welcome! Please see the development section above for information on building and testing changes locally.

---

*Oreon Immutable OS represents the next generation of Linux distributions, combining proven enterprise stability with cutting-edge immutable infrastructure technology.*
