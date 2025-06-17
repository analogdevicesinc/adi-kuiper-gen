Prerequisites
=============

Before building Kuiper images, ensure your system meets the requirements below. 
Following these prerequisites will help avoid common build issues and ensure a 
smooth development experience.

.. important::
   **Windows is not supported.** Kuiper requires a Linux environment with 
   specific kernel features for cross-architecture builds.

Build Environment
-----------------

Operating System
~~~~~~~~~~~~~~~~

**Ubuntu 22.04 LTS is recommended.** Other Linux distributions or versions may 
not work as expected.

While Kuiper may work on other distributions, Ubuntu 22.04 LTS provides the 
most tested and stable environment. If you encounter issues on other 
distributions, consider using Ubuntu 22.04 LTS in a virtual machine.

Space Requirements
~~~~~~~~~~~~~~~~~~

**At least 10GB of free disk space** is required for building images. The build 
process creates:

* Base Debian filesystem (~2GB)
* Downloaded packages and dependencies (~3GB)
* Compiled tools and libraries (~2GB)  
* Final image files (~1-3GB depending on configuration)

.. tip::
   **Recommended:** Have 15-20GB available to accommodate multiple builds and 
   avoid running out of space during the process.

Repository Path
~~~~~~~~~~~~~~~

.. warning::
   **Critical:** Ensure you clone this repository to a path **without spaces**. 
   Paths with spaces are not supported by debootstrap and will cause build 
   failures.

   **Examples:**
   
   * ✅ ``/home/user/adi-kuiper-gen``
   * ✅ ``/opt/kuiper-build``
   * ❌ ``/home/user/My Projects/adi-kuiper-gen``
   * ❌ ``/mnt/shared drive/kuiper``

Required Software
-----------------

Docker
~~~~~~

**Docker version 24.0.6 or compatible** is required to build Kuiper images.

Docker provides the containerized build environment that ensures consistent 
results across different host systems. The build process requires elevated 
privileges within the container.

**Installation:**

If you don't have Docker installed, follow the official installation guide:

https://docs.docker.com/engine/install/

**Verification:**

After installation, verify Docker is working:

.. code-block:: bash

   # Check Docker version
   docker --version
   
   # Test Docker functionality (should print "Hello from Docker!")
   sudo docker run hello-world

Cross-Architecture Support
~~~~~~~~~~~~~~~~~~~~~~~~~~

These packages are necessary to build ARM-based images on x86 systems:

.. list-table:: Cross-Architecture Packages
   :header-rows: 1
   :class: bold-header

   * - Package
     - Purpose
     - Description
   * - ``qemu-user-static``
     - ARM Emulation
     - Allows execution of ARM binaries on x86 systems
   * - ``binfmt-support``
     - Binary Format Support
     - Kernel module to run binaries from different architectures

**Installation on Debian/Ubuntu:**

.. code-block:: bash

   sudo apt-get update
   sudo apt-get install qemu-user-static binfmt-support

**Enable the binfmt_misc module:**

.. code-block:: bash

   sudo modprobe binfmt_misc

**For WSL users:**

If using Windows Subsystem for Linux, you may need to enable the service:

.. code-block:: bash

   sudo update-binfmts --enable

**Verification:**

Verify the setup is working:

.. code-block:: bash

   # Check if binfmt_misc is loaded
   lsmod | grep binfmt_misc
   
   # Should show ARM interpreters
   ls /proc/sys/fs/binfmt_misc/qemu-*

System Configuration
--------------------

User Permissions
~~~~~~~~~~~~~~~~

The build process requires **root/sudo access** for:

* Running Docker containers with privileged mode
* Managing loop devices for image creation
* Accessing kernel modules

Ensure your user account has sudo privileges:

.. code-block:: bash

   # Test sudo access
   sudo echo "Sudo access confirmed"

Network Requirements
~~~~~~~~~~~~~~~~~~~~

An active **internet connection** is required during builds for:

* Downloading Debian packages
* Cloning ADI software repositories  
* Installing build dependencies

.. note::
   **Firewall considerations:** Ensure Docker can access external repositories. 
   Some corporate firewalls may block the required connections.

Troubleshooting Prerequisites
-----------------------------

Common Issues
~~~~~~~~~~~~~

**Docker permission denied:**

.. code-block:: text

   permission denied while trying to connect to the Docker daemon socket

*Solution:* Add your user to the docker group or use sudo:

.. code-block:: bash

   # Option 1: Add user to docker group (requires logout/login)
   sudo usermod -aG docker $USER
   
   # Option 2: Use sudo with docker commands
   sudo ./build-docker.sh

**qemu-user-static not working:**

.. code-block:: text

   update-binfmts: warning: Couldn't load the binfmt_misc module

*Solution:* Manually load the kernel module:

.. code-block:: bash

   sudo modprobe binfmt_misc
   
   # Make it persistent across reboots
   echo 'binfmt_misc' | sudo tee -a /etc/modules

**Insufficient disk space:**

.. code-block:: text

   No space left on device

*Solution:* Free up disk space or use a different build location:

.. code-block:: bash

   # Check available space
   df -h
   
   # Clean Docker cache if needed
   sudo docker system prune -a

Next Steps
----------

Once your system meets all prerequisites:

1. **Continue to:** :doc:`quick-start` - Build your first Kuiper image
2. **Or explore:** :doc:`../user-guide/configuration` - Learn about customization options
3. **Need help?** :doc:`../reference/troubleshooting` - Common build issues and solutions

.. seealso::
   
   **Related Documentation:**
   
   * :doc:`../user-guide/build-process` - Understanding how builds work
   * :doc:`../reference/troubleshooting` - Detailed troubleshooting guide