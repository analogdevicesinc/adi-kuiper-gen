.. _getting-started:

Getting Started
===============

Kuiper-gen is a build tool for creating customized Debian OS images 
optimized for Analog Devices hardware. Kuiper images can be configured 
with various ADI libraries, tools, and board-specific boot files for 
seamless hardware integration.

Prerequisites
-------------

Build Environment
~~~~~~~~~~~~~~~~~

* **Operating System**: Ubuntu 22.04 LTS is recommended. Other Linux 
  distributions or versions may not work as expected.
* **Important**: Windows is not supported.
* **Space Requirements**: At least 10GB of free disk space for building 
  images.
* **Path Requirements**: Clone this repository to a path **without 
  spaces**. Paths with spaces are not supported by debootstrap.

Required Software
~~~~~~~~~~~~~~~~~

Docker
++++++

Docker version 24.0.6 or compatible is required to build Kuiper images.
If you don't have Docker installed, follow the installation steps at: 
https://docs.docker.com/engine/install/

Cross-Architecture Support
++++++++++++++++++++++++++

These packages are necessary to build ARM-based images on x86 systems:

* ``qemu-user-static``: For emulating ARM architecture
* ``binfmt_misc``: Kernel module to run binaries from different 
  architectures

You can install them on Debian/Ubuntu with:

.. code-block:: bash

   sudo apt-get update
   sudo apt-get install qemu-user-static binfmt-support

To ensure the binfmt_misc module is loaded:

.. code-block:: bash

   sudo modprobe binfmt_misc

If using WSL, you may need to enable the service:

.. code-block:: bash

   sudo update-binfmts --enable

Quick Start Guide
-----------------

This guide will help you build a basic Kuiper image with default settings.

Step 1: Clone the Repository
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After ensuring your build environment meets the prerequisites, clone the 
repository:

.. code-block:: bash

   git clone --depth 1 https://github.com/analogdevicesinc/adi-kuiper-gen
   cd adi-kuiper-gen

Step 2: Review Default Configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The default configuration builds a basic 32-bit (armhf) Debian Bookworm 
image with Raspberry Pi boot files. For most users, this is sufficient 
to get started:

* Target architecture: ``armhf`` (32-bit)
* Debian version: ``bookworm``
* Essential boot files included: Yes
* Desktop environment: No
* ADI tools: Basic set enabled

This configuration creates a "Basic Image" with only essential components.

Step 3: Build the Image
~~~~~~~~~~~~~~~~~~~~~~~

Run the build script with sudo:

.. code-block:: bash

   sudo ./build-docker.sh

.. note::

   This process typically takes 30-60 minutes depending on your system 
   and internet speed. The script will show progress as it works.

The build process will:

#. Create a Docker container with the necessary build environment
#. Set up a minimal Debian system
#. Configure system settings
#. Install selected components based on your configuration
#. Create a bootable image

Step 4: Locate Your Image
~~~~~~~~~~~~~~~~~~~~~~~~~

After a successful build, your Kuiper image will be available as a zip 
file in the ``kuiper-volume/`` directory. The filename follows the 
pattern ``image_YYYY-MM-DD-ADI-Kuiper-Linux-[arch].zip``.

You should see output similar to:

.. code-block:: text

   Build completed successfully!
   Image location: kuiper-volume/image_2024-01-15-ADI-Kuiper-Linux-armhf.zip

Writing the Image to Hardware
-----------------------------

Extract the Image
~~~~~~~~~~~~~~~~~

The build produces a zip file in the ``kuiper-volume/`` directory. 
Extract it:

.. code-block:: bash

   cd kuiper-volume
   unzip image_YYYY-MM-DD-ADI-Kuiper-Linux-[arch].zip

Flash to SD Card
~~~~~~~~~~~~~~~~

Using Balena Etcher (Recommended)
++++++++++++++++++++++++++++++++++

`Balena Etcher <https://www.balena.io/etcher/>`_ provides a simple, 
graphical interface and is the recommended method:

#. Download and install `Balena Etcher <https://www.balena.io/etcher/>`_
#. Launch Etcher and click "Flash from file"
#. Select the extracted ``.img`` file
#. Select your SD card as the target
#. Click "Flash" and wait for completion

Using Command Line (Linux)
+++++++++++++++++++++++++++

For command line users:

#. Insert your SD card and identify the device:

   .. code-block:: bash

      sudo fdisk -l

   Look for a device like ``/dev/sdX`` or ``/dev/mmcblkX`` matching 
   your SD card's size.

#. Unmount any auto-mounted partitions:

   .. code-block:: bash

      sudo umount /dev/sdX*

#. Write the image:

   .. code-block:: bash

      sudo dd if=image_YYYY-MM-DD-ADI-Kuiper-Linux-[arch].img \
         of=/dev/sdX bs=4M status=progress conv=fsync

#. Sync and eject:

   .. code-block:: bash

      sudo sync
      sudo eject /dev/sdX

.. warning::

   Replace ``/dev/sdX`` with your actual device path. Double-check the 
   device name to avoid overwriting the wrong drive!

First Boot and Access
---------------------

Boot Your Device
~~~~~~~~~~~~~~~~

#. Insert the SD card into your target device
#. Connect required peripherals (power, display, keyboard if needed)
#. Power on the device

The first boot may take longer as the system automatically resizes the 
root partition to use the full SD card capacity.

Login Credentials
~~~~~~~~~~~~~~~~~

* **Username**: ``analog``
* **Password**: ``analog``

Root access is available using the same password with ``sudo`` or by 
logging in directly as root.

Access Methods
~~~~~~~~~~~~~~

Console Access
++++++++++++++

Connect directly with a keyboard and display if your hardware supports it.

SSH Access
++++++++++

If your device is connected to a network:

.. code-block:: bash

   ssh analog@<device-ip-address>

Replace ``<device-ip-address>`` with your device's actual IP address.

Verify Your Installation
~~~~~~~~~~~~~~~~~~~~~~~~

To confirm your Kuiper image is working:

#. Check system information:

   .. code-block:: bash

      cat /etc/os-release
      uname -a

#. Test hardware detection:

   .. code-block:: bash

      # List connected IIO devices (if hardware is connected)
      iio_info

Understanding the Build Process
------------------------------

How It Works
~~~~~~~~~~~~

Kuiper uses Docker to create a controlled build environment. The process 
follows these stages:

#. **Bootstrap**: Creates a minimal Debian filesystem
#. **Configuration**: Sets up locale, timezone, and users
#. **System Setup**: Configures networking and core services
#. **Tool Installation**: Adds ADI libraries and applications (if enabled)
#. **Boot Setup**: Adds platform-specific boot files
#. **Image Creation**: Packages everything into a bootable image

Each stage is modular and can be customized through the ``config`` file.

Common Issues and Solutions
---------------------------

Build Fails with ARM Emulation Errors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Symptoms**: Error messages like:

.. code-block:: text

   chroot: failed to run command '/bin/true': Exec format error

**Solution**: Install and configure cross-architecture support:

.. code-block:: bash

   sudo apt-get install qemu-user-static binfmt-support
   sudo modprobe binfmt_misc

Docker Permission Denied
~~~~~~~~~~~~~~~~~~~~~~~~

**Symptoms**:

.. code-block:: text

   permission denied while trying to connect to the Docker daemon socket

**Solutions**:

#. Use sudo (recommended for build scripts):

   .. code-block:: bash

      sudo ./build-docker.sh

#. Or add your user to the docker group (requires logout/login):

   .. code-block:: bash

      sudo usermod -aG docker $USER

Build Fails with Path Errors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Symptoms**: Debootstrap errors during build.

**Solution**: Ensure your repository is cloned to a path without spaces. 
Debootstrap does not support paths containing spaces.

Next Steps
----------

Congratulations! You now have a working Kuiper image. Here's what you 
can do next:

* **Customize your build**: Learn about configuration options to add 
  desktop environments, ADI tools, and specialized features
* **Explore ADI libraries**: Discover libiio, libm2k, and other tools 
  for working with ADI hardware
* **Hardware-specific setup**: Configure for specific ADI evaluation 
  boards and carrier platforms
* **Advanced customization**: Write custom build scripts and create 
  specialized images

For detailed information on these topics, see the other sections of this 
documentation.