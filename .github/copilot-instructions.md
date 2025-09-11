# Oreon Immutable OS

**ALWAYS follow these instructions first.** Only search for additional context or run exploratory bash commands if the information below is incomplete or found to be incorrect.

Oreon Immutable OS is a custom bootc-based (container-to-disk) operating system derived from AlmaLinux 10. It builds a custom immutable OS image using container technology that can be deployed as bootable disk images (QCOW2, ISO, raw) or run as containers.

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
- **Bootc Container Validation**: `podman run --rm ghcr.io/hanthor/oreon-immutable:latest bootc container lint` ✓ WORKS
  - This validates the container follows bootc best practices
  - Shows warnings about /boot contents, sysusers, and tmpfiles.d entries
  - Critical for ensuring the image will work properly as a bootc container

### CRITICAL Build Limitations
- **NETWORK RESTRICTION**: All container builds fail due to blocked quay.io CDN access
- **DNS ISSUE**: `cdn01.quay.io` resolution returns "server misbehaving" or "REFUSED"
- **Runtime Issues**: Container builds also fail due to systemd/cgroup permission errors
- **TESTING WORKAROUND**: Use `podman pull docker.io/hello-world && podman run hello-world` to verify basic podman works
- **BUILD VALIDATION**: When network works, expect builds to complete but document timing carefully

## Validation Scenarios
When making changes to this repository:

1. **Always run linting first**: `just lint && just format && just check` ✓ ALL WORK
2. **Test basic podman**: `podman pull docker.io/hello-world && podman run hello-world` ✓ WORKS  
3. **Test pre-built image**: `podman pull ghcr.io/hanthor/oreon-immutable:latest` ✓ WORKS
4. **Test bootc functionality**: `podman run --rm ghcr.io/hanthor/oreon-immutable:latest bootc container lint` ✓ WORKS
5. **Attempt container build**: `just build` (expect to fail due to network restrictions but document the failure)
6. **Alternative build tools**: Test `podman pull ghcr.io/lorbuschris/bootc-image-builder:20250608` ✓ WORKS
7. **Manual validation**: If disk building works, run `just build-qcow2` (requires successful container build first)
8. **Check build scripts**: Any changes to `build_files/build.sh` require syntax validation: `bash -n build_files/build.sh` ✓ WORKS

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
- `just --list` -- shows all available commands (< 5 seconds) ✓ WORKS
- `just build` -- container build: 15-30 minutes when working, **FAILS due to quay.io CDN restrictions**
- `just lint` -- shellcheck validation: < 1 minute ✓ WORKS
- `just format` -- shfmt formatting: < 1 minute ✓ WORKS  
- `just check` -- Justfile syntax: < 30 seconds ✓ WORKS
- `just fix` -- Justfile formatting: < 30 seconds ✓ WORKS
- `just clean` -- cleanup: < 1 minute ✓ WORKS
- `bash -n build_files/build.sh` -- build script syntax: < 5 seconds ✓ WORKS
- `podman pull ghcr.io/hanthor/oreon-immutable:latest` -- pull pre-built: 2-5 minutes ✓ WORKS
- `podman run --rm ghcr.io/hanthor/oreon-immutable:latest bootc container lint` -- validate image: < 30 seconds ✓ WORKS
- `just build-qcow2` -- QCOW2 VM build: 45-90 minutes (requires successful container build first)
- `just build-iso` -- ISO build: 45-90 minutes (requires successful container build first)
- `just run-vm-qcow2` -- VM startup: 2-5 minutes for VM to boot (requires built images)

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
- **Working Registries**: docker.io (Docker Hub) and ghcr.io (GitHub Container Registry) work perfectly
- **Pre-built Alternative**: Repository already has pre-built image at `ghcr.io/hanthor/oreon-immutable:latest` ✓ WORKS
- **Build Tool Alternative**: `.github/workflows/build-disk.yml` uses `ghcr.io/lorbuschris/bootc-image-builder:20250608` ✓ WORKS

### Container Runtime Issues
- **systemd warnings**: "cgroupv2 manager is set to systemd but there is no systemd user session available"
- **Permission errors**: "Interactive authentication required.: Permission denied" during RUN steps
- **Workaround**: Use `loginctl enable-linger` but may not work in all sandbox environments
- **Impact**: Even with network access, container builds may fail due to runtime restrictions

### Testing Strategy
1. **Basic validation**: Always start with `podman pull docker.io/hello-world && podman run hello-world` ✓ WORKS
2. **Pre-built image testing**: `podman pull ghcr.io/hanthor/oreon-immutable:latest` ✓ WORKS (pulls successfully)
3. **Bootc validation**: `podman run --rm ghcr.io/hanthor/oreon-immutable:latest bootc container lint` ✓ WORKS
4. **Build attempt**: Try `just build` and document specific failure mode (expect quay.io CDN failure)
5. **Repository validation**: Use `just lint`, `just format`, `just check` ✓ ALL WORK
6. **Alternative build tools**: `podman pull ghcr.io/lorbuschris/bootc-image-builder:20250608` ✓ WORKS

## Project Structure and Navigation
This is a **bootc-based OS image template** that:
1. Takes AlmaLinux 10 as base
2. Applies Oreon-specific customizations via shell scripts
3. Outputs as container images that can be converted to bootable disk images
4. Uses GitHub Actions for automated building and publishing
5. Supports multiple output formats: containers, QCOW2 VMs, raw disks, ISO installers

The main workflow is: `Containerfile` → `podman build` → `bootc-image-builder` → bootable images.