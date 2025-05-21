.. _troubleshooting:

Troubleshooting
===============

This section provides solutions to common problems encountered when 
building and using Kuiper images. The troubleshooting guide is organized 
by problem category to help you quickly find solutions to specific issues.

Build Environment Issues
------------------------

Cross-Architecture Build Issues
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you encounter errors related to ARM emulation, first ensure you've 
properly set up the prerequisites as described in the 
:ref:`getting-started` section.

**Common error messages and their solutions:**

**Error**: ``update-binfmts: warning: Couldn't load the binfmt_misc module.``

**Error**: ``W: Failure trying to run: chroot chroot "//armhf_rootfs" /bin/true``

**Error**: ``chroot: failed to run command '/bin/true': Exec format error``

**Solution**:

#. Verify these specific files exist on your system:

   .. code-block:: bash

      /lib/modules/$(uname -r)/kernel/fs/binfmt_misc.ko
      /usr/bin/qemu-arm-static

#. If necessary, install the missing packages and load the module:

   .. code-block:: bash

      sudo apt-get install qemu-user-static binfmt-support
      sudo modprobe binfmt_misc

#. For WSL users, you may need to enable the service:

   .. code-block:: bash

      sudo update-binfmts --enable

**Additional troubleshooting steps:**

- Restart your terminal session after installing packages
- Verify that the binfmt_misc module is loaded:

  .. code-block:: bash

     lsmod | grep binfmt_misc

- Check if qemu-arm-static is properly installed:

  .. code-block:: bash

     ls -la /usr/bin/qemu-arm-static

Docker Issues
-------------

Docker Permission Denied
~~~~~~~~~~~~~~~~~~~~~~~~~

**Error**: ``permission denied while trying to connect to the Docker daemon socket``

**Solutions**:

**Option 1 (Recommended)**: Use sudo with build scripts:

.. code-block:: bash

   sudo ./build-docker.sh

**Option 2**: Add your user to the docker group (requires logout/login):

.. code-block:: bash

   sudo usermod -aG docker $USER

After running this command, you must log out and log back in for the 
changes to take effect.

Docker Service Not Running
~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Error**: ``Cannot connect to the Docker daemon at unix:///var/run/docker.sock``

**Solution**: Start the Docker service:

.. code-block:: bash

   sudo systemctl start docker
   sudo systemctl enable docker

Docker Container Issues
~~~~~~~~~~~~~~~~~~~~~~~

**Error**: Container fails to start or exits immediately

**Troubleshooting steps**:

#. Check if the container name conflicts with existing containers:

   .. code-block:: bash

      docker ps -a | grep debian_bookworm_rootfs_container

#. Remove conflicting containers:

   .. code-block:: bash

      docker rm -v debian_bookworm_rootfs_container

#. Check available disk space:

   .. code-block:: bash

      df -h

   Ensure you have at least 10GB of free space.

#. Verify Docker installation:

   .. code-block:: bash

      docker --version
      docker info

Build Process Issues
--------------------

Build Fails with Path Errors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Error**: Debootstrap errors during build

**Symptoms**:
- Build fails during the bootstrap stage
- Error messages mentioning path issues
- Debootstrap cannot create filesystem

**Solution**: Ensure your repository is cloned to a path without spaces. 
Debootstrap does not support paths containing spaces.

**Examples of problematic paths**:
- ``/home/user/My Documents/adi-kuiper-gen/``
- ``/home/user/Projects and Stuff/kuiper/``

**Examples of correct paths**:
- ``/home/user/adi-kuiper-gen/``
- ``/home/user/projects/kuiper/``

If your current path contains spaces, clone the repository to a new 
location:

.. code-block:: bash

   cd /home/user/
   git clone --depth 1 https://github.com/analogdevicesinc/adi-kuiper-gen
   cd adi-kuiper-gen

Insufficient Disk Space
~~~~~~~~~~~~~~~~~~~~~~~~

**Error**: Build fails with "No space left on device"

**Solution**:

#. Check available disk space:

   .. code-block:: bash

      df -h

#. Ensure you have at least 10GB of free space in the build directory

#. Clean up Docker images and containers if needed:

   .. code-block:: bash

      docker system prune -a

#. Remove old Kuiper builds:

   .. code-block:: bash

      rm -rf kuiper-volume/image_*.zip

Memory Issues
~~~~~~~~~~~~~

**Error**: Build fails due to insufficient memory

**Symptoms**:
- Build process is killed unexpectedly
- Out of memory errors in build logs
- System becomes unresponsive during build

**Solutions**:

#. Reduce the number of parallel jobs:

   .. code-block:: bash

      # Add to config file
      NUM_JOBS=2

#. Increase swap space:

   .. code-block:: bash

      sudo fallocate -l 2G /swapfile
      sudo chmod 600 /swapfile
      sudo mkswap /swapfile
      sudo swapon /swapfile

#. Close unnecessary applications during build

Network and Download Issues
---------------------------

Git Clone Failures
~~~~~~~~~~~~~~~~~~~

**Error**: ``fatal: unable to access 'https://github.com/...': Could not resolve host``

**Solutions**:

#. Check internet connectivity:

   .. code-block:: bash

      ping github.com

#. Try cloning with a different protocol:

   .. code-block:: bash

      git clone https://github.com/analogdevicesinc/adi-kuiper-gen.git

#. If behind a corporate firewall, configure git proxy settings:

   .. code-block:: bash

      git config --global http.proxy http://proxy.company.com:port

Package Download Failures
~~~~~~~~~~~~~~~~~~~~~~~~~~

**Error**: ``E: Failed to fetch`` or package installation errors

**Solutions**:

#. Update package lists and retry:

   .. code-block:: bash

      sudo apt update

#. Check if repositories are accessible:

   .. code-block:: bash

      curl -I https://deb.debian.org/debian/

#. For ADI repository issues, verify connectivity:

   .. code-block:: bash

      curl -I https://analogdevicesinc.github.io/

#. Configure alternative mirrors if needed

Configuration Issues
--------------------

Invalid Configuration Values
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Error**: Build fails due to configuration errors

**Common configuration mistakes**:

- Setting ``TARGET_ARCHITECTURE`` to unsupported values
- Using unsupported Debian versions
- Enabling tools without required dependencies

**Solutions**:

#. Verify architecture setting:

   .. code-block:: bash

      # Valid values only
      TARGET_ARCHITECTURE=armhf  # or arm64

#. Check Debian version:

   .. code-block:: bash

      # Supported versions only
      DEBIAN_VERSION=bookworm    # or bullseye

#. Review dependency requirements in the :ref:`configuration` section

#. Validate configuration before building:

   .. code-block:: bash

      # Check for syntax errors
      bash -n config

Missing Dependencies
~~~~~~~~~~~~~~~~~~~~

**Error**: Tools fail to build due to missing dependencies

**Example**: ``CONFIG_IIO_OSCILLOSCOPE=y`` fails because required 
libraries are not enabled.

**Solution**: Enable required dependencies explicitly:

.. code-block:: bash

   CONFIG_LIBIIO=y
   CONFIG_LIBAD9166_IIO=y
   CONFIG_LIBAD9361_IIO=y
   CONFIG_IIO_OSCILLOSCOPE=y

Refer to the dependency information in the :ref:`configuration` section 
for complete dependency chains.

Runtime Issues
--------------

Image Won't Boot
~~~~~~~~~~~~~~~~

**Symptoms**:
- SD card LED activity stops quickly
- No display output
- Device doesn't respond to network

**Troubleshooting steps**:

#. Verify image was written correctly:

   .. code-block:: bash

      # Check if image file is complete
      ls -la kuiper-volume/image_*.img
      
      # Verify SD card write was successful
      sudo fdisk -l /dev/sdX

#. Check SD card compatibility:
   - Use a high-quality SD card (Class 10 or better)
   - Ensure SD card is at least 8GB
   - Try a different SD card

#. Verify boot files are present:
   - Mount the SD card on your computer
   - Check that boot partition contains necessary files

#. Check power supply:
   - Ensure adequate power for your target device
   - Use official power supplies when possible

SSH Access Issues
~~~~~~~~~~~~~~~~~

**Error**: Cannot connect via SSH to Kuiper device

**Troubleshooting steps**:

#. Verify device is on the network:

   .. code-block:: bash

      # Find device IP
      nmap -sn 192.168.1.0/24
      
      # Or check router's connected devices

#. Test network connectivity:

   .. code-block:: bash

      ping <device-ip>

#. Verify SSH service is running on the device (console access needed):

   .. code-block:: bash

      sudo systemctl status ssh
      sudo systemctl start ssh

#. Check SSH configuration:

   .. code-block:: bash

      # Try connecting with verbose output
      ssh -v analog@<device-ip>

Performance Issues
------------------

Slow Build Times
~~~~~~~~~~~~~~~~

**Symptoms**: Build takes significantly longer than expected (over 2 hours)

**Solutions**:

#. Increase parallel jobs (if you have sufficient RAM):

   .. code-block:: bash

      # Add to config file
      NUM_JOBS=4

#. Use faster storage:
   - Build on SSD instead of HDD
   - Ensure sufficient free space

#. Check system resources during build:

   .. code-block:: bash

      htop
      iostat -x 1

#. Disable unnecessary services during build

#. Use a wired internet connection for faster downloads

Slow Runtime Performance
~~~~~~~~~~~~~~~~~~~~~~~~

**Symptoms**: Kuiper image runs slowly on target hardware

**Solutions**:

#. Use faster SD card (Class 10, UHS-I, or better)

#. Ensure adequate cooling for target device

#. Check for background processes consuming resources:

   .. code-block:: bash

      top
      ps aux --sort=-%cpu

#. Consider building with minimal configuration to reduce resource usage

Advanced Troubleshooting
------------------------

Build Log Analysis
~~~~~~~~~~~~~~~~~~

The build process creates a log file at ``kuiper-volume/build.log``. This 
file contains detailed information about each build stage.

**Common log analysis techniques**:

#. Check for error patterns:

   .. code-block:: bash

      grep -i error kuiper-volume/build.log
      grep -i fail kuiper-volume/build.log

#. Review the last few lines before failure:

   .. code-block:: bash

      tail -50 kuiper-volume/build.log

#. Look for specific stage failures:

   .. code-block:: bash

      grep "End stage" kuiper-volume/build.log

Debugging Build Stages
~~~~~~~~~~~~~~~~~~~~~~

If a specific stage fails, you can debug it by preserving the container:

#. Set ``PRESERVE_CONTAINER=y`` in the config file

#. Run the build and let it fail

#. Access the container for debugging:

   .. code-block:: bash

      docker exec -it debian_bookworm_rootfs_container /bin/bash

#. Manually run stage commands to identify the issue

Container Filesystem Access
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To examine the built filesystem before image creation:

.. code-block:: bash

   # Get container ID
   CONTAINER_ID=$(docker inspect --format="{{.Id}}" debian_bookworm_rootfs_container)
   
   # Copy filesystem to host
   sudo docker cp $CONTAINER_ID:armhf_rootfs ./debug_rootfs
   
   # Examine the filesystem
   ls -la debug_rootfs/

Clean Build Environment
~~~~~~~~~~~~~~~~~~~~~~~

If you encounter persistent issues, try a clean build environment:

#. Remove all Docker containers and images:

   .. code-block:: bash

      docker system prune -a

#. Clean the kuiper-volume directory:

   .. code-block:: bash

      rm -rf kuiper-volume/*

#. Re-clone the repository to a fresh location

#. Verify prerequisites are correctly installed

Getting Additional Help
-----------------------

Community Support
~~~~~~~~~~~~~~~~~

If the solutions in this guide don't resolve your issue:

#. **Search existing issues**: Check the `GitHub Issues 
   <https://github.com/analogdevicesinc/adi-kuiper-gen/issues>`_ page 
   for similar problems

#. **Create a new issue**: If you can't find a solution, open a new issue 
   with:
   - Detailed problem description
   - Your configuration file
   - Relevant log output
   - System information (OS, Docker version, etc.)

#. **Provide system information**:

   .. code-block:: bash

      # Include this information in issue reports
      uname -a
      docker --version
      lsb_release -a
      df -h

Log Collection for Bug Reports
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When reporting issues, include:

#. **Build log**: ``kuiper-volume/build.log``

#. **Configuration**: Your modified ``config`` file

#. **System info**:

   .. code-block:: bash

      echo "=== System Information ===" > debug_info.txt
      uname -a >> debug_info.txt
      lsb_release -a >> debug_info.txt
      docker --version >> debug_info.txt
      docker info >> debug_info.txt
      df -h >> debug_info.txt
      free -h >> debug_info.txt

#. **Error reproduction steps**: Exact commands that led to the issue

**Important**: Remove any sensitive information (passwords, tokens, etc.) 
from logs before sharing.

Quick Reference
---------------

Emergency Build Recovery
~~~~~~~~~~~~~~~~~~~~~~~~

If your build environment becomes corrupted:

.. code-block:: bash

   # Nuclear option: clean everything
   docker system prune -a -f
   rm -rf kuiper-volume/*
   sudo modprobe binfmt_misc
   sudo systemctl restart docker

Most Common Solutions
~~~~~~~~~~~~~~~~~~~~~

**90% of build issues are resolved by**:

#. Installing cross-architecture support:

   .. code-block:: bash

      sudo apt-get install qemu-user-static binfmt-support
      sudo modprobe binfmt_misc

#. Using sudo with build commands:

   .. code-block:: bash

      sudo ./build-docker.sh

#. Ensuring path has no spaces:

   .. code-block:: bash

      pwd  # Should not contain spaces

#. Having sufficient disk space (10GB minimum):

   .. code-block:: bash

      df -h .

For configuration and usage questions, refer to :ref:`configuration` and 
:ref:`getting-started` sections respectively.
