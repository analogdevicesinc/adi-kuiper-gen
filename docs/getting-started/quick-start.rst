Quick Start Guide
=================

This guide will help you build a basic Kuiper image with default settings. 
Following these steps, you'll have a bootable embedded Linux image in under 
an hour.

.. important::
   Before starting, ensure your build environment meets the 
   :doc:`prerequisites`. The build process requires specific system 
   configuration and will fail without proper setup.

Step 1: Clone the Repository
----------------------------

After ensuring your build environment meets the prerequisites, clone the 
repository:

.. code-block:: bash
   :caption: Clone the Kuiper repository

   git clone --depth 1 https://github.com/analogdevicesinc/adi-kuiper-gen
   cd adi-kuiper-gen

.. tip::
   **Why ``--depth 1``?** This creates a shallow clone that downloads only the 
   latest commit, saving time and bandwidth. For development work, you may want 
   to omit this flag to get the full Git history.

Step 2: Review Default Configuration
------------------------------------

The default configuration will build a basic 32-bit (armhf) Debian Bookworm 
image with Raspberry Pi boot files. For most users, this is sufficient to get 
started:

.. list-table:: Default Build Configuration
   :header-rows: 1
   :class: bold-header

   * - Setting
     - Value
     - Description
   * - **Target architecture**
     - ``armhf`` (32-bit)
     - Compatible with most ARM platforms
   * - **Debian version**
     - ``bookworm``
     - Latest stable Debian release
   * - **Essential boot files**
     - Yes
     - Raspberry Pi boot support included
   * - **Desktop environment**
     - No
     - Minimal system for embedded use
   * - **ADI tools**
     - None
     - Can be enabled as needed

.. dropdown:: 🔍 **What's a "Basic Image"?**

   This configuration creates what we call the "Basic Image" that includes only 
   essential components:
   
   * Core Debian system with essential packages
   * Network configuration (DHCP, SSH server)
   * User management (pre-configured 'analog' user)
   * Boot files for Raspberry Pi platforms
   * System utilities and basic tools
   
   For details on exactly what stages and components are included in this basic 
   build, see :doc:`../user-guide/kuiper-versions`.

.. note::
   **Want to customize?** For customization options, see 
   :doc:`../user-guide/configuration`. You can enable desktop environments, 
   ADI tools, and much more.

Step 3: Build the Image
-----------------------

Run the build script with sudo:

.. code-block:: bash
   :caption: Start the build process

   sudo ./build-docker.sh

.. warning::
   **Sudo required:** The build process needs elevated privileges to create 
   Docker containers, manage loop devices, and access kernel modules.

Build Process Overview
~~~~~~~~~~~~~~~~~~~~~~

The build process will:

1. **Create a Docker container** with the necessary build environment
2. **Set up a minimal Debian system** using debootstrap
3. **Configure system settings** (users, networking, SSH)
4. **Install selected components** based on your configuration
5. **Create a bootable image** with proper partitioning

.. grid:: 1 2 2 2
   :gutter: 2

   .. grid-item::
      :columns: 6

      **Build Time:**
      
      * First build: 30-60 minutes
      * Subsequent builds: 15-30 minutes
      * Depends on internet speed and system performance

   .. grid-item::  
      :columns: 6

      **Build Progress:**
      
      * Watch terminal output for stage progress
      * Each stage shows start/completion messages
      * Final image creation happens at the end

.. tip::
   **Build taking too long?** The first build downloads many packages and may 
   take longer. Subsequent builds reuse cached Docker layers and are much faster.

Step 4: Locate the Output
-------------------------

After a successful build, your Kuiper image will be available as a zip file in 
the ``kuiper-volume/`` directory within the repository.

**Output Structure:**

.. code-block:: text
   :caption: Build output location

   adi-kuiper-gen/
   └── kuiper-volume/
       ├── image_YYYY-MM-DD-ADI-Kuiper-Linux-[arch].zip  ← Your image!
       ├── build.log                                      ← Build log
       ├── ADI_repos_git_info.txt                        ← Version info
       └── licensing/                                     ← License files

The filename follows the pattern: 
``image_YYYY-MM-DD-ADI-Kuiper-Linux-[arch].zip``

**Example filename:** ``image_2025-01-15-ADI-Kuiper-Linux-armhf.zip``

.. dropdown:: 📁 **What else is in kuiper-volume/?**

   * **build.log** - Complete build log with timestamps
   * **ADI_repos_git_info.txt** - Git commit information for all tools
   * **licensing/** - License files for all included software
   * **sources/** - Source code (if ``EXPORT_SOURCES=y`` was set)

Troubleshooting Build Issues
----------------------------

.. collapse:: **Common Build Problems**

   **Build fails with permission errors:**
   
   .. code-block:: text
   
      permission denied while trying to connect to the Docker daemon
   
   *Solution:* Ensure Docker is running and you have proper permissions:
   
   .. code-block:: bash
   
      # Check Docker status
      sudo systemctl status docker
      
      # Start Docker if needed
      sudo systemctl start docker
   
   **Build fails with "No space left on device":**
   
   *Solution:* Free up disk space or clean Docker cache:
   
   .. code-block:: bash
   
      # Check available space
      df -h
      
      # Clean Docker cache
      sudo docker system prune -a
   
   **Cross-architecture emulation fails:**
   
   .. code-block:: text
   
      chroot: failed to run command '/bin/true': Exec format error
   
   *Solution:* Ensure qemu-user-static is properly installed:
   
   .. code-block:: bash
   
      sudo apt-get install qemu-user-static binfmt-support
      sudo modprobe binfmt_misc

Next Steps
----------

Congratulations! You've successfully built your first Kuiper image. Here's what 
to do next:

.. grid:: 1 2 2 2
   :gutter: 3

   .. grid-item-card:: 💾 **Write to SD Card**
      :link: first-image
      :link-type: doc

      Learn how to write your image to an SD card and boot your device. 
      Includes instructions for multiple operating systems.

   .. grid-item-card:: ⚙️ **Customize Your Build**
      :link: ../user-guide/configuration
      :link-type: doc

      Add desktop environments, ADI tools, and more. Explore the comprehensive 
      configuration options available.

   .. grid-item-card:: 🔍 **Understand the Process**
      :link: ../user-guide/build-process
      :link-type: doc

      Deep dive into how the build process works and what happens in each 
      stage.

   .. grid-item-card:: ❓ **Get Help**
      :link: ../reference/troubleshooting
      :link-type: doc

      Having issues? Check our troubleshooting guide for common problems 
      and solutions.

.. seealso::

   **Related Documentation:**
   
   * :doc:`prerequisites` - System requirements and setup
   * :doc:`first-image` - Using your generated image
   * :doc:`../user-guide/kuiper-versions` - Different image types available
   * :doc:`../examples/basic-builds` - Configuration examples