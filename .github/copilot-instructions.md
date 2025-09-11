# Oreon Immutable OS

Oreon Immutable OS is a custom bootc-based (container-to-disk) operating system derived from AlmaLinux 10. It builds a custom immutable OS image using container technology that can be deployed as bootable disk images (QCOW2, ISO, raw) or run as containers.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Prerequisites and Setup
- **Install just command runner**: `wget -qO- https://github.com/casey/just/releases/download/1.36.0/just-1.36.0-x86_64-unknown-linux-musl.tar.gz | sudo tar xz -C /usr/local/bin`
- **Install shfmt formatter**: `go install mvdan.cc/sh/v3/cmd/shfmt@latest && sudo cp ~/go/bin/shfmt /usr/local/bin/`
- **Podman**: Available system-wide but has cgroupv2 warnings (non-critical)
- **Host System**: Ubuntu 24.04.3 LTS with systemd user session

### Build and Test Process
1. **Container Image Build**:
   - `just build` -- **CRITICAL LIMITATION**: Build fails in sandbox environments due to network restrictions
   - **Network Issues**: 
     - `cdn01.quay.io` DNS resolution blocked/refused
     - Cannot access quay.io CDN endpoints for base image `quay.io/almalinuxorg/almalinux-bootc:10`
     - Also affects bootc-image-builder: `quay.io/centos-bootc/bootc-image-builder:latest`
   - **Expected time when working**: 15-30 minutes. NEVER CANCEL. Set timeout to 45+ minutes.
   - **Container runtime issues**: systemd user session warnings and permission denied errors during builds

2. **Bootable Image Creation** (only when container build succeeds):
   - `just build-qcow2` -- builds QCOW2 VM image. Takes 45-90 minutes. NEVER CANCEL. Set timeout to 120+ minutes.
   - `just build-iso` -- builds bootable ISO installer. Takes 45-90 minutes. NEVER CANCEL. Set timeout to 120+ minutes.
   - `just build-raw` -- builds raw disk image. Takes 45-90 minutes. NEVER CANCEL. Set timeout to 120+ minutes.
   - **Dependencies**: Requires successful container build first

3. **Virtual Machine Testing** (only when images are built):
   - `just run-vm-qcow2` -- runs QCOW2 image in VM using qemu container
   - `just spawn-vm` -- runs VM using systemd-vmspawn
   - VM runs on auto-selected port starting from 8006, accessible via web browser

### Validation Commands (THESE WORK)
- `just lint` -- runs shellcheck on all bash scripts. Takes < 1 minute. ✓ WORKS
- `just format` -- runs shfmt formatting on bash scripts. Takes < 1 minute. ✓ WORKS  
- `just check` -- validates Justfile syntax. Takes < 30 seconds. ✓ WORKS
- `just fix` -- auto-fixes Justfile formatting. Takes < 30 seconds. ✓ WORKS
- `just clean` -- removes build artifacts. Takes < 1 minute. ✓ WORKS
- `bash -n build_files/build.sh` -- validate build script syntax. ✓ WORKS

### CRITICAL Build Limitations
- **NETWORK RESTRICTION**: All container builds fail due to blocked quay.io CDN access
- **DNS ISSUE**: `cdn01.quay.io` resolution returns "server misbehaving" or "REFUSED"
- **Runtime Issues**: Container builds also fail due to systemd/cgroup permission errors
- **TESTING WORKAROUND**: Use `podman pull docker.io/hello-world && podman run hello-world` to verify basic podman works
- **BUILD VALIDATION**: When network works, expect builds to complete but document timing carefully

## Validation Scenarios
When making changes to this repository:

1. **Always run linting first**: `just lint && just format && just check`
2. **Test container build**: `just build` (may fail due to network restrictions - document this)
3. **If container build succeeds**: Test one disk image type: `just build-qcow2`
4. **Manual validation**: If VM building works, run `just run-vm-qcow2` and verify the OS boots correctly
5. **Check build scripts**: Any changes to `build_files/build.sh` require manual verification of package installations

## Common Tasks and Timing

### Repository Structure
```
/home/runner/work/oreon-immutable/oreon-immutable/
├── Containerfile              # Container image definition
├── Justfile                   # Build automation (uses just command runner)
├── build_files/
│   └── build.sh               # Main OS configuration script
├── disk_config/
│   ├── disk.toml              # QCOW2/raw disk configuration
│   ├── iso.toml               # ISO installer configuration
│   └── iso-kde.toml           # KDE ISO variant configuration
├── .github/workflows/
│   ├── build.yml              # Container image CI/CD
│   └── build-disk.yml         # Disk image builds
└── cosign.pub                 # Container signing public key
```

### Key Build Commands with Timing
- `just --list` -- shows all available commands (< 5 seconds)
- `just build` -- container build: 15-30 minutes when working, often fails due to network restrictions
- `just build-qcow2` -- QCOW2 VM build: 45-90 minutes. NEVER CANCEL.
- `just build-iso` -- ISO build: 45-90 minutes. NEVER CANCEL.
- `just run-vm-qcow2` -- VM startup: 2-5 minutes for VM to boot
- `just lint` -- linting: < 1 minute
- `just format` -- formatting: < 1 minute
- `just clean` -- cleanup: < 1 minute

### Important Files to Monitor
- Always check `build_files/build.sh` when making package or configuration changes
- Monitor `Containerfile` for base image changes
- Review `disk_config/*.toml` when changing disk image parameters
- Check `.github/workflows/build.yml` for CI/CD pipeline changes

### GitHub Actions and CI
- **build.yml**: Builds and publishes container images to GitHub Container Registry
- **build-disk.yml**: Creates disk images using bootc-image-builder
- **Timing**: GitHub Actions builds take 30-60 minutes for containers, 60-120 minutes for disk images
- **Signing**: Uses cosign for container signing (requires SIGNING_SECRET)

## Network and Environment Limitations

### Confirmed Network Issues
- **CDN Blocking**: All quay.io CDN endpoints (`cdn01.quay.io`) are blocked/refused
- **DNS Resolution**: Even with Google DNS (8.8.8.8), cannot resolve quay.io CDN
- **Affected Images**: 
  - `quay.io/almalinuxorg/almalinux-bootc:10` (base image)
  - `quay.io/centos-bootc/bootc-image-builder:latest` (build tool)
- **Working Registries**: docker.io (Docker Hub) works fine
- **Test Command**: `podman pull docker.io/hello-world && podman run hello-world` ✓ WORKS

### Container Runtime Issues
- **systemd warnings**: "cgroupv2 manager is set to systemd but there is no systemd user session available"
- **Permission errors**: "Interactive authentication required.: Permission denied" during RUN steps
- **Workaround**: Use `loginctl enable-linger` but may not work in all sandbox environments
- **Impact**: Even with network access, container builds may fail due to runtime restrictions

### Testing Strategy
1. **Basic validation**: Always start with `podman pull docker.io/hello-world && podman run hello-world`
2. **Build attempt**: Try `just build` and document specific failure mode
3. **Fallback validation**: Use `just lint`, `just format`, `just check` to validate repository health
4. **Alternative testing**: If you have pre-built images, test with those
5. **Documentation**: Always document network/runtime limitations encountered

## Project Structure and Navigation
This is a **bootc-based OS image template** that:
1. Takes AlmaLinux 10 as base
2. Applies Oreon-specific customizations via shell scripts
3. Outputs as container images that can be converted to bootable disk images
4. Uses GitHub Actions for automated building and publishing
5. Supports multiple output formats: containers, QCOW2 VMs, raw disks, ISO installers

The main workflow is: `Containerfile` → `podman build` → `bootc-image-builder` → bootable images.