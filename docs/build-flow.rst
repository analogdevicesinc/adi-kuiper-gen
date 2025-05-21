.. _build-flow:

Build Flow
==========

This section provides detailed technical information about Kuiper's build 
system architecture, processes, and components. This reference is intended 
for advanced users, contributors, and those who need to understand or 
extend the build system.

Build Flow Overview
-------------------

The Kuiper build process uses Docker to create a controlled environment 
for building Debian-based images for Analog Devices products. The build 
follows these high-level steps:

#. ``build-docker.sh`` creates a Docker container with all necessary build 
   dependencies
#. Inside the container, ``kuiper-stages.sh`` orchestrates a series of 
   build stages
#. Each stage performs specific tasks like system configuration, tool 
   installation, and boot setup
#. The final image is exported as a zip file to the ``kuiper-volume`` 
   directory on your host machine

This approach ensures consistent builds across different host systems 
while allowing full customization through the ``config`` file.

The ``config`` file is first read by ``build-docker.sh`` on the host 
system to set up environment variables and Docker options. It is then 
copied into the container where ``kuiper-stages.sh`` reads it again to 
determine which stages to execute and how to configure them.

Docker Build Environment
------------------------

Docker is used to perform the build inside a container, which partially 
isolates the build from the host system. This allows the script to work 
on non-Debian based systems (e.g., Fedora Linux). The isolation is not 
total due to the need to use some kernel-level services for ARM emulation 
(binfmt) and loop devices (losetup).

Running the Build
~~~~~~~~~~~~~~~~~

To build:

.. code-block:: bash

   sudo bash build-docker.sh

or

.. code-block:: bash

   sudo ./build-docker.sh

Your Kuiper image will be in the ``kuiper-volume/`` folder inside the 
cloned repository on your machine as a zip file named 
``image_YYYY-MM-DD-ADI-Kuiper-Linux-[arch].zip``. After successful build, 
the Docker image and the build container are removed if 
``PRESERVE_CONTAINER=n``.

If needed, you can remove the build container with:

.. code-block:: bash

   docker rm -v debian_<DEBIAN_VERSION>_rootfs_container

If you choose to preserve the Docker container, you can access the Kuiper 
root filesystem by copying it from the container to your machine with this 
command:

.. code-block:: bash

   CONTAINER_ID=$(docker inspect --format="{{.Id}}" debian_<DEBIAN_VERSION>_rootfs_container)
   sudo docker cp $CONTAINER_ID:<TARGET_ARCHITECTURE>_rootfs .

You need to replace ``<DEBIAN_VERSION>`` and ``<TARGET_ARCHITECTURE>`` 
with the ones in the configuration file.

Example:

.. code-block:: bash

   CONTAINER_ID=$(docker inspect --format="{{.Id}}" debian_bookworm_rootfs_container)
   sudo docker cp $CONTAINER_ID:armhf_rootfs .

Docker Container Configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When the Docker container is run, various required command line arguments 
are provided:

- ``-t``: Allocates a pseudo-TTY allowing interaction with container's shell
- ``--privileged``: Provides elevated privileges required by the chroot 
  command
- ``-v /dev:/dev``: Mounts the host system's device directory
- ``-v /lib/modules:/lib/modules``: Mounts kernel modules from the host
- ``-v ./kuiper-volume:/kuiper-volume``: Creates a shared volume for the 
  output
- ``-e "DEBIAN_VERSION={value}"``: Sets environment variables from the 
  config file

The ``--name`` and ``--privileged`` options are already set by the script 
and should not be redefined.

Stage-Based Build Process
-------------------------

Inside the Docker container, ``kuiper-stages.sh`` orchestrates the entire 
build process. This script reads the ``config`` file, sets up environment 
variables, and executes a series of stages in a specific order.

How Stages Are Processed
~~~~~~~~~~~~~~~~~~~~~~~~

The build process follows these steps inside the Docker container:

#. ``kuiper-stages.sh`` loops through the ``stages`` directory in 
   alphanumeric order
#. Within each stage, it processes subdirectories in alphanumeric order
#. For each subdirectory, it runs the following files if they exist:

   - ``run.sh`` - A shell script executed in the Docker container's context
   - ``run-chroot.sh`` - A shell script executed within the Kuiper image 
     using chroot
   - Package installation files:

     - ``packages-[*]`` - Lists packages to install with 
       ``--no-install-recommends``
     - ``packages-[*]-with-recommends`` - Lists packages to install with 
       their recommended dependencies

The package installation files (``packages-[*]``) are processed if the 
corresponding configuration option is enabled. For example, 
``packages-desktop`` is only processed if ``CONFIG_DESKTOP=y`` in the 
config file.

Stage Execution Logic
~~~~~~~~~~~~~~~~~~~~~

The ``kuiper-stages.sh`` script contains a helper function called 
``install_packages`` that handles package installation for each stage. 
This function:

#. Checks if package files exist for the current stage
#. Verifies if the corresponding configuration option is enabled
#. Installs the packages using the appropriate apt-get command

The script then executes each stage's ``run.sh`` script, which may perform 
additional configuration steps, compile software from source, or prepare 
files for the final image.

This modular approach allows users to easily customize the build process 
by modifying existing stages or adding new ones.

Build Stages Reference
----------------------

The build process is divided into several stages for logical clarity and 
modularity. Each stage contains multiple substages that handle specific 
aspects of the build process.

Stage 01: Bootstrap
~~~~~~~~~~~~~~~~~~~

**Purpose**: Create a usable minimal filesystem

**Key operations**:

- Uses ``debootstrap`` to create a minimal Debian filesystem
- Sets up core system components
- Prepares for configuration in later stages

The minimal core is installed but not configured at this stage, and the 
system is not yet bootable.

Stage 02: Set Locale and Timezone
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Purpose**: Configure system localization

**Key operations**:

- Installs localization packages (locales, dialog)
- Configures locale variables
- Sets the system timezone
- Installs mandatory system packages

**Related config options**: None (always executed)

Stage 03: System Tweaks
~~~~~~~~~~~~~~~~~~~~~~~

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

Stage 04: Configure Desktop Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Purpose**: Set up graphical interface (optional)

**Key operations**:

- Installs XFCE desktop environment
- Configures automatic login for 'analog' user
- Sets up X11VNC server for remote access
- Applies visual customizations

**Related config options**:

- ``CONFIG_DESKTOP=y`` - Enable/disable entire stage

Stage 05: ADI Tools
~~~~~~~~~~~~~~~~~~~~

**Purpose**: Install Analog Devices libraries and applications

**Key operations**:

- Installs selected ADI libraries: libiio, pyadi, libm2k, libad9361, 
  libad9166, gr-m2k
- Installs selected ADI applications: iio-oscilloscope, iio-fm-radio, 
  fru_tools, jesd-eye-scan-gtk, colorimeter, Scopy
- Installs non-ADI applications: GNU Radio
- Clones Linux scripts repository
- Creates log file with installed tools, branches, and commit hashes

**Related config options**: Multiple tool-specific options

- ``CONFIG_LIBIIO``, ``CONFIG_PYADI``, ``CONFIG_LIBM2K``, etc.

Stage 06: Boot Partition
~~~~~~~~~~~~~~~~~~~~~~~~~

**Purpose**: Prepare boot files for different platforms

**Key operations**:

- Adds Intel and Xilinx boot binaries (if configured)
- Adds Raspberry Pi boot files (if configured)
- Creates and configures fstab for mounting partitions
- Sets up default boot configuration for Raspberry Pi

**Related config options**:

- ``CONFIG_RPI_BOOT_FILES`` - Include Raspberry Pi boot files
- ``CONFIG_XILINX_INTEL_BOOT_FILES`` - Include Xilinx and Intel boot files

Stage 07: Extra Tweaks
~~~~~~~~~~~~~~~~~~~~~~~

**Purpose**: Apply custom configurations and additions

**Key operations**:

- Runs custom user scripts (if specified)
- Installs Raspberry Pi specific packages (if configured)
- Installs Raspberry Pi WiFi firmware (if Raspberry Pi boot files are 
  configured)

**Related config options**:

- ``EXTRA_SCRIPT`` - Path to custom script
- ``INSTALL_RPI_PACKAGES`` - Install Raspberry Pi specific packages
- ``CONFIG_RPI_BOOT_FILES`` - Install Raspberry Pi WiFi firmware

Stage 08: Export Stage
~~~~~~~~~~~~~~~~~~~~~~

**Purpose**: Finalize and export the image

**Key operations**:

- Installs scripts to extend rootfs partition on first boot
- Exports source code for all packages (if configured)
- Generates license information
- Prepares boot partition for target hardware
- Creates and compresses the final disk image into a zip file

**Related config options**:

- ``EXPORT_SOURCES`` - Download source files for all packages
- ``ADI_EVAL_BOARD`` and ``CARRIER`` - Configure for specific hardware

Package Repositories
---------------------

Kuiper uses multiple package repositories to install and update software. 
These repositories are configured during the build process in the 
bootstrap stage.

ADI Repository
~~~~~~~~~~~~~~

The ADI APT repository is a collection of Debian package files that 
facilitates the distribution and installation of Analog Devices software 
packages. The repository contains .deb packages with boot files for 
carriers and Raspberry Pi.

**Advantages of using the ADI repository:**

- Easy installation, removal, and upgrading of packages (``apt install``, 
  ``apt remove``, ``apt upgrade``)
- Simplified version management
- Package manager handles dependency resolution and conflict detection
- Centralized distribution of ADI-specific packages

**Available packages include:**

- ``adi-carriers-boot-2022.r2``
- ``adi-carriers-boot-main``
- ``adi-rpi-boot-5.15.y``
- ``adi-rpi-boot-6.1``

Raspberry Pi Repository
~~~~~~~~~~~~~~~~~~~~~~~

By default, the Kuiper image includes the official Raspberry Pi package 
repository in ``/etc/apt/sources.list.d/raspi.list``. This repository 
provides access to Pi-specific packages and optimizations.

**Using the Raspberry Pi repository:**

#. Edit ``/etc/apt/sources.list.d/raspi.list`` and uncomment the first line
#. Update the package lists: ``sudo apt update``
#. Install packages as needed: ``sudo apt install <package-name>``

This gives you access to RPI-specific packages such as GPIO libraries, 
VideoCore tools, and other hardware-specific packages.

Installing Packages
~~~~~~~~~~~~~~~~~~~~

To install packages from either repository on your running Kuiper system:

.. code-block:: bash

   sudo apt update
   sudo apt install <package-name>

For example, to install Raspberry Pi boot files from the ADI repository:

.. code-block:: bash

   sudo apt update
   sudo apt install adi-rpi-boot-6.1

Kuiper Image Versions
---------------------

Depending on your configuration choices, different combinations of build 
stages and substages will be included. Here are the common build 
configurations:

Basic Image (Default)
~~~~~~~~~~~~~~~~~~~~~

The default configuration includes only the essential packages and 
configuration needed for a functional system:

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

  - Substage **03.install-rpi-wifi-firmware** - WiFi support (if needed)

- **08.export-stage**

  - Substage **01.extend-rootfs** - Root filesystem expansion script
  - Substage **03.generate-license** - License generation
  - Substage **04.export-image** - Final image creation

Optional Components
~~~~~~~~~~~~~~~~~~~

These components can be added on top of the basic image:

**Desktop Environment** (``CONFIG_DESKTOP=y``):

- **04.configure-desktop-env**

  - Substage **01.desktop-env** - XFCE desktop
  - Substage **02.vnc-server** - Remote display access
  - Substage **03.cosmetic** - Visual customizations

**ADI Tools** (various ``CONFIG_*`` options):

- **05.adi-tools**

  - Substages for each tool (libiio, pyadi, libm2k, etc.)

**Source Code Export** (``EXPORT_SOURCES=y``):

- **08.export-stage**

  - Substage **02.export-sources** - Package source code collection

**Custom Scripts** (``EXTRA_SCRIPT`` set):

- **07.extra-tweaks**

  - Substage **01.extra-scripts** - Custom script execution

**Raspberry Pi Packages** (``INSTALL_RPI_PACKAGES=y``):

- **07.extra-tweaks**

  - Substage **02.install-rpi-packages** - RPI-specific packages

Build System Environment Variables
----------------------------------

The build system uses several environment variables that are set during 
the build process:

**Core Variables:**

- ``TARGET_ARCHITECTURE`` - armhf or arm64
- ``BUILD_DIR`` - ``${TARGET_ARCHITECTURE}_rootfs``
- ``IMG_FILE`` - ``image_$(date +%Y-%m-%d)-ADI-Kuiper-Linux-$TARGET_ARCHITECTURE.img``
- ``NUM_JOBS`` - Number of parallel jobs (defaults to ``$(nproc)``)

**Repository URLs:**

- ``GITHUB_ANALOG_DEVICES`` - ``https://github.com/analogdevicesinc``
- ``ADI_REPOS`` - ``ADI_repos_git_info.txt``

**Configuration Variables:**
All ``CONFIG_*`` variables from the config file are exported as environment 
variables and used throughout the build process to determine which 
components to include.

**Branch Variables:**
All ``BRANCH_*`` variables specify which git branches to use for each 
component, allowing builds from different development branches or releases.

For a complete list of configuration variables, see the 
:ref:`configuration` section.
