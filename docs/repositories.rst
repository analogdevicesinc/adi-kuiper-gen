.. _repositories:

Repositories
============

Kuiper uses multiple package repositories to install and update software. 
These repositories are configured during the build process in the bootstrap stage.

----

ADI Repository
--------------

The ADI APT repository is a collection of Debian package files that facilitates 
the distribution and installation of Analog Devices software packages. The 
repository contains .deb packages with boot files for carriers and Raspberry Pi.

**Advantages of using the ADI repository:**

- Easy installation, removal, and upgrading of packages (``apt install``, ``apt remove``, ``apt upgrade``)
- Simplified version management
- Package manager handles dependency resolution and conflict detection
- Centralized distribution of ADI-specific packages

**Available packages include:**

- ``adi-carriers-boot-2022.r2``
- ``adi-carriers-boot-main``
- ``adi-rpi-boot-5.15.y``
- ``adi-rpi-boot-6.1``

----

Raspberry Pi Repository
-----------------------

By default, the Kuiper image includes the official Raspberry Pi package 
repository in ``/etc/apt/sources.list.d/raspi.list``. This repository provides 
access to Pi-specific packages and optimizations.

**Using the Raspberry Pi repository:**

1. Edit ``/etc/apt/sources.list.d/raspi.list`` and uncomment the first line
2. Update the package lists: ``sudo apt update``
3. Install packages as needed: ``sudo apt install <package-name>``

This gives you access to RPI-specific packages such as GPIO libraries, 
VideoCore tools, and other hardware-specific packages.

----

Installing Packages
-------------------

To install packages from either repository on your running Kuiper system:

.. code-block:: bash

   sudo apt update
   sudo apt install <package-name>

For example, to install Raspberry Pi boot files from the ADI repository:

.. code-block:: bash

   sudo apt update
   sudo apt install adi-rpi-boot-6.1
