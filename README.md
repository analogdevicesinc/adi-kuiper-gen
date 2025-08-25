# kuiper-gen

[![Kuiper2.0](https://github.com/analogdevicesinc/adi-kuiper-gen/actions/workflows/kuiper2_0-build.yml/badge.svg?branch=main)](https://github.com/analogdevicesinc/adi-kuiper-gen/actions/workflows/kuiper2_0-build.yml)

A build tool for creating customized Debian OS images optimized for Analog Devices hardware. Kuiper images can be configured with various ADI libraries, tools, and board-specific boot files for seamless hardware integration.

## Prerequisites

### Build Environment

- **Operating System**: Ubuntu 22.04 LTS is recommended. Other Linux distributions or versions may not work as expected.
- **Important**: Windows is not supported.
- **Space Requirements**: At least 10GB of free disk space for building images.
- **Note**: Ensure you clone this repository to a path **without spaces**. Paths with spaces are not supported by debootstrap.

### Required Software

1. **Docker**:

   - Docker version 24.0.6 or compatible is required to build Kuiper images.
   - If you don't have Docker installed, follow the installation steps at: <https://docs.docker.com/engine/install/>

2. **Cross-Architecture Support**:

   - These packages are necessary to build ARM-based images on x86 systems:
     - `qemu-user-static`: For emulating ARM architecture
     - `binfmt_misc`: Kernel module to run binaries from different architectures

   You can install them on Debian/Ubuntu with:

   ```bash
   sudo apt-get update
   sudo apt-get install qemu-user-static binfmt-support
   ```

   To ensure the binfmt_misc module is loaded:

   ```bash
   sudo modprobe binfmt_misc
   ```

   If using WSL, you may need to enable the service:

   ```bash
   sudo update-binfmts --enable
   ```

## Quick Start Guide

This guide will help you build a basic Kuiper image with default settings.

### 1. Clone the Repository

After ensuring your build environment meets the [prerequisites](#prerequisites), clone the repository:

```bash
git clone --depth 1 https://github.com/analogdevicesinc/adi-kuiper-gen
cd adi-kuiper-gen
```

### 2. Review Default Configuration

The default configuration will build a basic 32-bit (armhf) Debian Bookworm image with Raspberry Pi boot files. For most users, this is sufficient to get started:

- Target architecture: `armhf` (32-bit)
- Debian version: `bookworm`
- Essential boot files included: Yes
- Desktop environment: No
- ADI tools: None (can be enabled as needed)

This configuration creates what we call the "Basic Image" that includes only essential components. For details on exactly what stages and components are included in this basic build, see the [Basic Image section](#basic-image-default) under Kuiper Versions.

For customization options, see the [Configuration](#configuration) section.

### 3. Build the Image

Run the build script with sudo:

```bash
sudo ./build-docker.sh
```

The build process will:

1. Create a Docker container with the necessary build environment
2. Set up a minimal Debian system
3. Configure system settings
4. Install selected components based on your configuration
5. Create a bootable image

This process typically takes 30-60 minutes depending on your system and internet speed.

### 4. Locate the Output

After a successful build, your Kuiper image will be available as a zip file in the `kuiper-volume/` directory within the repository. The filename will follow the pattern `image_YYYY-MM-DD-ADI-Kuiper-Linux-[arch].zip`.

### Next Steps

- To write the image to an SD card and boot your device, see the [Using the Generated Image](#using-the-generated-image) section
- To customize your build with additional tools or settings, see the [Configuration](#configuration) section
- To understand how the build process works, see the [Build Flow](#build-flow) section
- For troubleshooting build issues, see the [Troubleshooting](#troubleshooting) section

## Configuration

Kuiper-gen's build process is controlled by settings defined in the `config` file located in the root of the repository. This file contains bash variables that determine what features to include and how to build the image.

### How to Configure

To modify the configuration:

1. Edit the `config` file in your preferred text editor
2. Set option values to 'y' to enable features or 'n' to disable them
3. Modify other values as needed for your build
4. Save the file and run the build script

After the build completes, you can find a copy of the used configuration in the root directory ('/') of the built image.

You can also set the number of processors or cores you want to use for building by adding `NUM_JOBS=[number]` to the config file. By default, this uses all available cores (`$(nproc)`).

### System Configuration

These options control the fundamental aspects of your Kuiper image:

| Option                | Default    | Description                                                                                                                |
| --------------------- | ---------- | -------------------------------------------------------------------------------------------------------------------------- |
| `TARGET_ARCHITECTURE` | `armhf`    | Target architecture: `armhf` (32-bit) or `arm64` (64-bit)                                                                  |
| `DEBIAN_VERSION`      | `bookworm` | Debian version to use (e.g., `bookworm`, `bullseye`). Other versions may have missing functionalities or unsupported tools |

### Build Process Options

These options control how the Docker build process behaves:

| Option               | Default                                    | Description                                                                   |
| -------------------- | ------------------------------------------ | ----------------------------------------------------------------------------- |
| `PRESERVE_CONTAINER` | `n`                                        | Keep the Docker container after building (`y`/`n`)                            |
| `CONTAINER_NAME`     | `debian_<DEBIAN_VERSION>_rootfs_container` | Name of the Docker container. Useful for building multiple images in parallel |
| `EXPORT_SOURCES`     | `n`                                        | Download source files for all packages in the image (`y`/`n`)                 |

### Desktop Environment

| Option           | Default | Description                                                  |
| ---------------- | ------- | ------------------------------------------------------------ |
| `CONFIG_DESKTOP` | `n`     | Install XFCE desktop environment and X11VNC server (`y`/`n`) |

### ADI Libraries and Tools

These options control which ADI libraries and tools are included in the image:

| Option                            | Default             | Description                                                    |
| --------------------------------- | ------------------- | -------------------------------------------------------------- |
| `CONFIG_LIBIIO`                   | `n`                 | Install Libiio library (`y`/`n`)                               |
| `CONFIG_LIBIIO_CMAKE_ARGS`        | _(see config file)_ | CMake build arguments for Libiio                               |
| `BRANCH_LIBIIO`                   | `libiio-v0`         | Git branch to use for Libiio                                   |
| `CONFIG_PYADI`                    | `n`                 | Install Pyadi library (`y`/`n`). Requires Libiio               |
| `BRANCH_PYADI`                    | `main`              | Git branch to use for Pyadi                                    |
| `CONFIG_LIBM2K`                   | `n`                 | Install Libm2k library (`y`/`n`). Requires Libiio              |
| `CONFIG_LIBM2K_CMAKE_ARGS`        | _(see config file)_ | CMake build arguments for Libm2k                               |
| `BRANCH_LIBM2K`                   | `main`              | Git branch to use for Libm2k                                   |
| `CONFIG_LIBAD9166_IIO`            | `n`                 | Install Libad9166 library (`y`/`n`). Requires Libiio           |
| `CONFIG_LIBAD9166_IIO_CMAKE_ARGS` | _(see config file)_ | CMake build arguments for Libad9166                            |
| `BRANCH_LIBAD9166_IIO`            | `libad9166-iio-v0`  | Git branch to use for Libad9166                                |
| `CONFIG_LIBAD9361_IIO`            | `n`                 | Install Libad9361 library (`y`/`n`). Requires Libiio           |
| `CONFIG_LIBAD9361_IIO_CMAKE_ARGS` | _(see config file)_ | CMake build arguments for Libad9361                            |
| `BRANCH_LIBAD9361_IIO`            | `libad9361-iio-v0`  | Git branch to use for Libad9361                                |
| `CONFIG_GRM2K`                    | `n`                 | Install GRM2K (`y`/`n`). Requires Libiio, Libm2k, and Gnuradio |
| `CONFIG_GRM2K_CMAKE_ARGS`         | _(see config file)_ | CMake build arguments for GRM2K                                |
| `BRANCH_GRM2K`                    | `main`              | Git branch to use for GRM2K                                    |
| `CONFIG_LINUX_SCRIPTS`            | `n`                 | Install ADI Linux scripts (`y`/`n`)                            |
| `BRANCH_LINUX_SCRIPTS`            | `kuiper2.0`         | Git branch to use for Linux scripts                            |

### ADI Applications

These options control which ADI applications are included in the image:

| Option                                | Default             | Description                                                                           |
| ------------------------------------  | ------------------- | ------------------------------------------------------------------------------------- |
| `CONFIG_IIO_OSCILLOSCOPE`             | `n`                 | Install IIO Oscilloscope (`y`/`n`). Requires Libiio, Libad9166_IIO, and Libad9361_IIO |
| `CONFIG_IIO_OSCILLOSCOPE_CMAKE_ARGS`  | _(see config file)_ | CMake build arguments for IIO Oscilloscope                                            |
| `BRANCH_IIO_OSCILLOSCOPE`             | `main`              | Git branch to use for IIO Oscilloscope                                                |
| `CONFIG_IIO_FM_RADIO`                 | `n`                 | Install IIO FM Radio (`y`/`n`)                                                        |
| `BRANCH_IIO_FM_RADIO`                 | `main`              | Git branch to use for IIO FM Radio                                                    |
| `CONFIG_FRU_TOOLS`                    | `n`                 | Install FRU tools (`y`/`n`)                                                           |
| `BRANCH_FRU_TOOLS`                    | `main`              | Git branch to use for FRU tools                                                       |
| `CONFIG_JESD_EYE_SCAN_GTK`            | `n`                 | Install JESD Eye Scan GTK (`y`/`n`)                                                   |
| `CONFIG_JESD_EYE_SCAN_GTK_CMAKE_ARGS` | _(see config file)_ | CMake build arguments for JESD Eye Scan GTK                                           |
| `BRANCH_JESD_EYE_SCAN_GTK`            | `main`              | Git branch to use for JESD Eye Scan GTK                                               |
| `CONFIG_COLORIMETER`                  | `n`                 | Install Colorimeter (`y`/`n`). Requires Libiio                                        |
| `BRANCH_COLORIMETER`                  | `main`              | Git branch to use for Colorimeter                                                     |
| `CONFIG_SCOPY`                        | `n`                 | Install Scopy (`y`/`n`)                                                               |

### Non-ADI Applications

These options control which non-ADI applications are included in the image:

| Option            | Default | Description                 |
| ----------------- | ------- | --------------------------- |
| `CONFIG_GNURADIO` | `n`     | Install GNU Radio (`y`/`n`) |

### Boot Configuration

These options control boot files and configurations:

| Option                            | Default     | Description                                                            |
| --------------------------------- | ----------- | ---------------------------------------------------------------------- |
| `CONFIG_RPI_BOOT_FILES`           | `y`         | Include Raspberry Pi boot files (`y`/`n`) - **Enabled by default**     |
| `BRANCH_RPI_BOOT_FILES`           | `rpi-6.1.y` | Git branch for Raspberry Pi boot files                                 |
| `USE_ADI_REPO_RPI_BOOT`           | `y`         | Install Raspberry Pi boot files from ADI repository (`y`/`n`)          |
| `CONFIG_XILINX_INTEL_BOOT_FILES`  | `y`         | Include Xilinx and Intel boot files (`y`/`n`) - **Enabled by default** |
| `RELEASE_XILINX_INTEL_BOOT_FILES` | `2022_r2`   | Release version of Xilinx/Intel boot files                             |
| `USE_ADI_REPO_CARRIERS_BOOT`      | `y`         | Install carriers boot files from ADI repository (`y`/`n`)              |

### Platform-Specific Configuration

These options configure the target board and project:

| Option                 | Default   | Description                                                                                                                                                                                              |
| ---------------------- | --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ADI_EVAL_BOARD`       | _(empty)_ | Configure which ADI evaluation board project the image will run. Requires `CONFIG_XILINX_INTEL_BOOT_FILES=y`                                                                                             |
| `CARRIER`              | _(empty)_ | Configure which board the image will boot on. Used together with `ADI_EVAL_BOARD`                                                                                                                        |
| `INSTALL_RPI_PACKAGES` | `n`       | Install Raspberry Pi specific packages (`y`/`n`) including: raspi-config, GPIO-related tools (pigpio, python3-gpio, raspi-gpio, python3-rpi.gpio), VideoCore debugging (vcdbg), sense-hat, and sense-emu |

### Customization

| Option         | Default   | Description                                                                                                  |
| -------------- | --------- | ------------------------------------------------------------------------------------------------------------ |
| `EXTRA_SCRIPT` | _(empty)_ | Path to a custom script inside the adi-kuiper-gen directory to run during build for additional customization |

### Common Configuration Examples

**Building a 64-bit image with desktop environment:**

```bash
TARGET_ARCHITECTURE=arm64
CONFIG_DESKTOP=y
```

**Including IIO tools and libraries:**

```bash
CONFIG_LIBIIO=y
CONFIG_IIO_OSCILLOSCOPE=y  # This will require LIBAD9166_IIO and LIBAD9361_IIO
```

**Building for a specific ADI evaluation board:**

```bash
ADI_EVAL_BOARD=ad9361-fmcomms2
CARRIER=zedboard
```

**Complete development environment with GNU Radio:**

```bash
CONFIG_DESKTOP=y
CONFIG_LIBIIO=y
CONFIG_LIBM2K=y
CONFIG_GNURADIO=y
CONFIG_GRM2K=y
```

## Build Flow

### Overview

The Kuiper build process uses Docker to create a controlled environment for building Debian-based images for Analog Devices products. The build follows these high-level steps:

1. `build-docker.sh` creates a Docker container with all necessary build dependencies
2. Inside the container, `kuiper-stages.sh` orchestrates a series of build stages
3. Each stage performs specific tasks like system configuration, tool installation, and boot setup
4. The final image is exported as a zip file to the `kuiper-volume` directory on your host machine

This approach ensures consistent builds across different host systems while allowing full customization through the `config` file.

The `config` file is first read by `build-docker.sh` on the host system to set up environment variables and Docker options. It is then copied into the container where `kuiper-stages.sh` reads it again to determine which stages to execute and how to configure them.

```diagram
┌──────────────────────────────────────────────────┐
│ Host System                                      │
│                                                  │
│  ┌─────────────────┐        ┌─────────────────┐  │
│  │ build-docker.sh │◄───────┤ config          │  │
│  └─────────────────┘        └─────────────────┘  │
│          │                          │            │
│          │                          │            │
│          │                          │            │
│          ▼                          ▼            │
│  ┌───────────────────────────────────────────┐   │
│  │ Docker Container                          │   │
│  │                                           │   │
│  │  ┌─────────────────┐   ┌─────────────────┐│   │
│  │  │kuiper-stages.sh │◄──┤ config (copy)   ││   │
│  │  └─────────────────┘   └─────────────────┘│   │
│  │         │                                 │   │
│  │         ▼                                 │   │
│  │  ┌─────────────────┐                      │   │
│  │  │ Stage Execution │                      │   │
│  │  └─────────────────┘                      │   │
│  │         │                                 │   │
│  │         ▼                                 │   │
│  │  ┌─────────────────┐                      │   │
│  │  │ Image Creation  │                      │   │
│  │  └─────────────────┘                      │   │
│  └───────────────────────────────────────────┘   │
│                    │                             │
│                    ▼                             │
│  ┌─────────────────────────────────────────┐     │
│  │ kuiper-volume/                          │     │
│  │ ├── image_YYYY-MM-DD-ADI-Kuiper-        │     │
│  │ │   Linux-[arch].zip                    │     │
│  │ ├── build.log                           │     │
│  │ ├── ADI_repos_git_info.txt              │     │
│  │ ├── licensing/                          │     │
│  │ └── sources/                            │     │
│  └─────────────────────────────────────────┘     │
└──────────────────────────────────────────────────┘
```

### Docker Build Environment

Docker is used to perform the build inside a container, which partially isolates the build from the host system. This allows the script to work on non-Debian based systems (e.g., Fedora Linux). The isolation is not total due to the need to use some kernel-level services for ARM emulation (binfmt) and loop devices (losetup).

The `build-docker.sh` script handles:

- Checking prerequisites and permissions
- Building a Docker image with all necessary dependencies
- Running a Docker container with appropriate options
- Mounting volumes to share data between the host and container
- Setting environment variables based on the `config` file
- Starting the internal build process by calling `kuiper-stages.sh`
- Cleaning up the container after completion (if `PRESERVE_CONTAINER=n`)

#### Running the Build

To build:

```bash
sudo bash build-docker.sh
```

or

```bash
sudo ./build-docker.sh
```

Your Kuiper image will be in the `kuiper-volume/` folder inside the cloned repository on your machine as a zip file named `image_YYYY-MM-DD-ADI-Kuiper-Linux-[arch].zip`. After successful build, the Docker image and the build container are removed if `PRESERVE_CONTAINER=n`.

If needed, you can remove the build container with:

```bash
docker rm -v debian_<DEBIAN_VERSION>_rootfs_container
```

If you choose to preserve the Docker container, you can access the Kuiper root filesystem by copying it from the container to your machine with this command:

```bash
CONTAINER_ID=$(docker inspect --format="{{.Id}}" debian_<DEBIAN_VERSION>_rootfs_container)
sudo docker cp $CONTAINER_ID:<TARGET_ARCHITECTURE>_rootfs .
```

You need to replace `<DEBIAN_VERSION>` and `<TARGET_ARCHITECTURE>` with the ones in the configuration file.

Example:

```bash
CONTAINER_ID=$(docker inspect --format="{{.Id}}" debian_bookworm_rootfs_container)
sudo docker cp $CONTAINER_ID:armhf_rootfs .
```

#### Docker Container Configuration

When the Docker container is run, various required command line arguments are provided:

- `-t`: Allocates a pseudo-TTY allowing interaction with container's shell
- `--privileged`: Provides elevated privileges required by the chroot command
- `-v /dev:/dev`: Mounts the host system's device directory
- `-v /lib/modules:/lib/modules`: Mounts kernel modules from the host
- `-v ./kuiper-volume:/kuiper-volume`: Creates a shared volume for the output
- `-e "DEBIAN_VERSION={value}"`: Sets environment variables from the config file

The `--name` and `--privileged` options are already set by the script and should not be redefined.

### Stage-Based Build Process

Inside the Docker container, `kuiper-stages.sh` orchestrates the entire build process. This script reads the `config` file, sets up environment variables, and executes a series of stages in a specific order.

#### How Stages Are Processed

The build process follows these steps inside the Docker container:

1. `kuiper-stages.sh` loops through the `stages` directory in alphanumeric order
2. Within each stage, it processes subdirectories in alphanumeric order
3. For each subdirectory, it runs the following files if they exist:
   - `run.sh` - A shell script executed in the Docker container's context
   - `run-chroot.sh` - A shell script executed within the Kuiper image using chroot
   - Package installation files:
     - `packages-[*]` - Lists packages to install with `--no-install-recommends`
     - `packages-[*]-with-recommends` - Lists packages to install with their recommended dependencies

The package installation files (`packages-[*]`) are processed if the corresponding configuration option is enabled. For example, `packages-desktop` is only processed if `CONFIG_DESKTOP=y` in the config file.

#### Key Stages Overview

The build process is divided into several stages for logical clarity and modularity:

1. **01.bootstrap** - Creates a usable filesystem using `debootstrap`
2. **02.set-locale-and-timezone** - Configures system locale and timezone settings
3. **03.system-tweaks** - Sets up users, passwords, and system configuration
4. **04.configure-desktop-env** - Installs and configures desktop environment (if enabled)
5. **05.adi-tools** - Installs Analog Devices libraries and tools (based on config)
6. **06.boot-partition** - Adds boot files for different platforms
7. **07.extra-tweaks** - Applies custom scripts and additional configurations
8. **08.export-stage** - Creates and exports the final image

Each stage contains multiple substages that handle specific aspects of the build process. The stages are designed to be modular, allowing for easy customization and extension.

For a more detailed description of each stage and its purpose, see the [Stage Anatomy](#stage-anatomy) section.

#### Stage Execution Logic

The `kuiper-stages.sh` script contains a helper function called `install_packages` that handles package installation for each stage. This function:

1. Checks if package files exist for the current stage
2. Verifies if the corresponding configuration option is enabled
3. Installs the packages using the appropriate apt-get command

The script then executes each stage's `run.sh` script, which may perform additional configuration steps, compile software from source, or prepare files for the final image.

This modular approach allows users to easily customize the build process by modifying existing stages or adding new ones.

## Stage Anatomy

The Kuiper build is divided into several stages for logical clarity and modularity. This section describes each stage in detail, helping you understand the complete build process.

### Stage 01: Bootstrap

**Purpose**: Create a usable minimal filesystem

**Key operations**:

- Uses `debootstrap` to create a minimal Debian filesystem
- Sets up core system components
- Prepares for configuration in later stages

The minimal core is installed but not configured at this stage, and the system is not yet bootable.

### Stage 02: Set Locale and Timezone

**Purpose**: Configure system localization

**Key operations**:

- Installs localization packages (locales, dialog)
- Configures locale variables
- Sets the system timezone
- Installs mandatory system packages

**Related config options**: None (always executed)

### Stage 03: System Tweaks

**Purpose**: Configure core system settings and users

**Key operations**:

- Creates 'analog' user with sudo rights (password: 'analog')
- Sets root password (same as user: 'analog')
- Configures hostname
- Sets up root autologin
- Enables SSH root login
- Configures network settings
- Sets up automounting for external devices

**Related config options**: None (always executed)

### Stage 04: Configure Desktop Environment

**Purpose**: Set up graphical interface (optional)

**Key operations**:

- Installs XFCE desktop environment
- Configures automatic login for 'analog' user
- Sets up X11VNC server for remote access
- Applies visual customizations

**Related config options**:

- `CONFIG_DESKTOP=y` - Enable/disable entire stage

### Stage 05: ADI Tools

**Purpose**: Install Analog Devices libraries and applications

**Key operations**:

- Installs selected ADI libraries: libiio, pyadi, libm2k, libad9361, libad9166, gr-m2k
- Installs selected ADI applications: iio-oscilloscope, iio-fm-radio, fru_tools, jesd-eye-scan-gtk, colorimeter, Scopy
- Installs non-ADI applications: GNU Radio
- Clones Linux scripts repository
- Creates log file with installed tools, branches, and commit hashes

**Related config options**: Multiple tool-specific options

- `CONFIG_LIBIIO`, `CONFIG_PYADI`, `CONFIG_LIBM2K`, etc.
- See [ADI Libraries and Tools](#adi-libraries-and-tools), [ADI Applications](#adi-applications) and [Non-ADI Applications](#non-adi-applications) in Configuration section

### Stage 06: Boot Partition

**Purpose**: Prepare boot files for different platforms

**Key operations**:

- Adds Intel and Xilinx boot binaries (if configured)
- Adds Raspberry Pi boot files (if configured)
- Creates and configures fstab for mounting partitions
- Sets up default boot configuration for Raspberry Pi

**Related config options**:

- `CONFIG_RPI_BOOT_FILES` - Include Raspberry Pi boot files
- `CONFIG_XILINX_INTEL_BOOT_FILES` - Include Xilinx and Intel boot files

### Stage 07: Extra Tweaks

**Purpose**: Apply custom configurations and additions

**Key operations**:

- Runs custom user scripts (if specified)
- Installs Raspberry Pi specific packages (if configured)
- Installs Raspberry Pi WiFi firmware (if Raspberry Pi boot files are configured)

**Related config options**:

- `EXTRA_SCRIPT` - Path to custom script
- `INSTALL_RPI_PACKAGES` - Install Raspberry Pi specific packages
- `CONFIG_RPI_BOOT_FILES` - Install Raspberry Pi WiFi firmware

### Stage 08: Export Stage

**Purpose**: Finalize and export the image

**Key operations**:

- Installs scripts to extend rootfs partition on first boot
- Exports source code for all packages (if configured)
- Generates license information
- Prepares boot partition for target hardware
- Creates and compresses the final disk image into a zip file

**Related config options**:

- `EXPORT_SOURCES` - Download source files for all packages
- `ADI_EVAL_BOARD` and `CARRIER` - Configure for specific hardware

## Kuiper Versions

Depending on your configuration choices, different combinations of build stages and substages will be included. Here are the common build configurations:

### Basic Image (Default)

The default configuration includes only the essential packages and configuration needed for a functional system:

- **01.bootstrap** - Core filesystem setup
- **02.set-locale-and-timezone** - Basic system localization
- **03.system-tweaks** - User and system configuration
- **05.adi-tools**
  - Substage **14.write-git-logs** - Build information tracking
- **06.boot-partition**
  - Substage **01.adi-boot-files** - Intel/Xilinx boot files (if enabled)
  - Substage **02.rpi-boot-files** - Raspberry Pi boot files (if enabled)
  - Substage **03.add-fstab** - Filesystem table configuration
- **07.extra-tweaks**
  - Substage **03.install-rpi-firmware** - WiFi and bluetooth support (if needed)
- **08.export-stage**
  - Substage **01.extend-rootfs** - Root filesystem expansion script
  - Substage **03.generate-license** License generation
  - Substage **04.export-image** - Final image creation

### Optional Components

These components can be added on top of the basic image:

- **Desktop Environment** (`CONFIG_DESKTOP=y`):

  - **04.configure-desktop-env**
    - Substage **01.desktop-env** - XFCE desktop
    - Substage **02.vnc-server** - Remote display access
    - Substage **03.cosmetic** - Visual customizations

- **ADI Tools** (various CONFIG\_\* options):

  - **05.adi-tools**
    - Substages for each tool (libiio, pyadi, libm2k, etc.)

- **Source Code Export** (`EXPORT_SOURCES=y`):

  - **08.export-stage**
    - Substage **02.export-sources** - Package source code collection

- **Custom Scripts** (`EXTRA_SCRIPT` set):

  - **07.extra-tweaks**
    - Substage **01.extra-scripts** - Custom script execution
  - For detailed instructions, see the [Custom Script Integration](#custom-script-integration) section.

- **Raspberry Pi Packages** (`INSTALL_RPI_PACKAGES=y`):
  - **07.extra-tweaks**
    - Substage **02.install-rpi-packages** - RPI-specific packages

## Custom Script Integration

Kuiper allows you to run additional scripts during the build process to customize the resulting image. This feature enables advanced customization beyond the standard configuration options.

### Using the Example Script

To use the provided example script:

1. In the `config` file, set the `EXTRA_SCRIPT` variable to:

   ```bash
   EXTRA_SCRIPT=stages/07.extra-tweaks/01.extra-scripts/examples/extra-script-example.sh
   ```

2. If you need to pass `config` file parameters to the script, uncomment the line where it sources the config file in the example script.

3. Add your custom commands to the example script file.

### Using Your Own Custom Script

To use your own custom script:

1. Place your script file inside the `adi-kuiper-gen/stages` directory.

2. In the `config` file, set the `EXTRA_SCRIPT` variable to the path of your script relative to the `adi-kuiper-gen` directory.

3. Make sure your script is executable (`chmod +x your-script.sh`).

Custom scripts are executed in the chroot environment of the target system during the build process, allowing you to install additional packages, modify system files, or perform any other customization.

## Using the Generated Image

After successfully building your Kuiper image, you'll need to write it to an SD card or storage device and boot your target hardware. This section guides you through that process.

### Extracting the Image

The build process produces a zip file in the `kuiper-volume/` directory. Extract it using:

```bash
# Navigate to the kuiper-volume directory
cd kuiper-volume

# Extract the image
unzip image_YYYY-MM-DD-ADI-Kuiper-Linux-[arch].zip
```

### Writing the Image to an SD Card

#### Using Balena Etcher (Recommended)

[Balena Etcher](https://www.balena.io/etcher/) provides a simple, graphical interface for writing images to SD cards and is the recommended method:

1. **Download and install** [Balena Etcher](https://www.balena.io/etcher/).
2. **Launch Etcher** and click "Flash from file".
3. **Select the image file** you extracted from the zip.
4. **Select your SD card** as the target.
5. **Click "Flash"** and wait for the process to complete.

#### Using Command Line on Linux

For users who prefer command line tools:

1. **Insert your SD card** into your computer.
2. **Identify the device name** of your SD card:

   ```bash
   sudo fdisk -l
   ```

   Look for a device like `/dev/sdX` or `/dev/mmcblkX` (where X is a letter or number) that matches your SD card's size.

3. **Unmount any auto-mounted partitions**:

   ```bash
   sudo umount /dev/sdX*
   ```

   Replace `/dev/sdX` with your actual device path.

4. **Write the image to the SD card**:

   ```bash
   sudo dd if=image_YYYY-MM-DD-ADI-Kuiper-Linux-[arch].img of=/dev/sdX bs=4M status=progress conv=fsync
   ```

   Replace `/dev/sdX` with your actual device path, and update the image filename accordingly.

5. **Ensure all data is written**:

   ```bash
   sudo sync
   ```

6. **Eject the SD card**:

   ```bash
   sudo eject /dev/sdX
   ```

### Booting Your Device

1. **Insert the SD card** into your target device.
2. **Connect required peripherals** (power, display, keyboard if needed).
3. **Power on the device**.
4. The first boot may take longer as the system automatically resizes the root partition to use the full SD card capacity.

### Login Information

- **Username**: analog
- **Password**: analog

Root access is available using the same password with `sudo` or by logging in directly as root.

### Accessing Your Kuiper System

#### Console Access

Connect directly with a keyboard and display if your hardware supports it.

#### SSH Access

If your device is connected to a network, you can access it via SSH:

```bash
ssh analog@<device-ip-address>
```

Replace `<device-ip-address>` with the actual IP address of your device.

#### VNC Access (If desktop environment was enabled)

If you built your image with `CONFIG_DESKTOP=y`, you can access the graphical environment via VNC:

1. Connect to your device using a VNC client (like RealVNC, TigerVNC, or Remmina).
2. Use the device's IP address and port 5900 (e.g., `192.168.1.100:5900`).

### Verifying Your Installation

To verify that your Kuiper image is working correctly:

1. **Check system information**:

   ```bash
   cat /etc/os-release
   uname -a
   ```

2. **Verify ADI tools** (if you included them in your build):

   ```bash
   # For libiio (if installed)
   iio_info -h

   # For IIO Oscilloscope (if installed)
   osc -h
   ```

3. **Check available hardware**:

   ```bash
   # List connected IIO devices (if libiio installed)
   iio_info
   ```

## Repositories

Kuiper uses multiple package repositories to install and update software. These repositories are configured during the build process in the bootstrap stage.

### ADI Repository

The ADI APT repository is a collection of Debian package files that facilitates the distribution and installation of Analog Devices software packages. The repository contains .deb packages with boot files for carriers and Raspberry Pi.

**Advantages of using the ADI repository:**

- Easy installation, removal, and upgrading of packages (`apt install`, `apt remove`, `apt upgrade`)
- Simplified version management
- Package manager handles dependency resolution and conflict detection
- Centralized distribution of ADI-specific packages

**Available packages include:**

- `adi-carriers-boot-2022.r2`
- `adi-carriers-boot-main`
- `adi-rpi-boot-5.15.y`
- `adi-rpi-boot-6.1`

### Raspberry Pi Repository

By default, the Kuiper image includes the official Raspberry Pi package repository in `/etc/apt/sources.list.d/raspi.list`. This repository provides access to Pi-specific packages and optimizations.

**Using the Raspberry Pi repository:**

1. Edit `/etc/apt/sources.list.d/raspi.list` and uncomment the first line
2. Update the package lists: `sudo apt update`
3. Install packages as needed: `sudo apt install <package-name>`

This gives you access to RPI-specific packages such as GPIO libraries, VideoCore tools, and other hardware-specific packages.

### Installing Packages

To install packages from either repository on your running Kuiper system:

```bash
sudo apt update
sudo apt install <package-name>
```

For example, to install Raspberry Pi boot files from the ADI repository:

```bash
sudo apt update
sudo apt install adi-rpi-boot-6.1
```

## Troubleshooting

### Cross-Architecture Build Issues

If you encounter errors related to ARM emulation, first ensure you've properly set up the prerequisites as described in the [Prerequisites section](#prerequisites).

Common error messages and their solutions:

```bash
update-binfmts: warning: Couldn't load the binfmt_misc module.
```

OR

```bash
W: Failure trying to run: chroot chroot "//armhf_rootfs" /bin/true
```

OR

```bash
chroot: failed to run command '/bin/true': Exec format error
```

**Solution**:

1. Verify these specific files exist on your system:

   ```bash
   /lib/modules/$(uname -r)/kernel/fs/binfmt_misc.ko
   /usr/bin/qemu-arm-static
   ```

2. If necessary, install the missing packages and load the module:

   ```bash
   sudo apt-get install qemu-user-static binfmt-support
   sudo modprobe binfmt_misc
   ```

### Docker Permission Issues

If you encounter permission errors when running Docker commands:

```bash
permission denied while trying to connect to the Docker daemon socket
```

**Solution**:

1. Either prefix commands with `sudo` as shown in the build instructions

2. Or add your user to the docker group (requires logout/login):

   ```bash
   sudo usermod -aG docker $USER
   ```

### Build Path Issues

If the build fails with debootstrap errors, check if your path contains spaces. As mentioned in the prerequisites, the build path must not contain spaces.

### Other Issues

For other issues not covered here, please check the [GitHub Issues](https://github.com/analogdevicesinc/adi-kuiper-gen/issues) page or open a new issue with details about your problem.
