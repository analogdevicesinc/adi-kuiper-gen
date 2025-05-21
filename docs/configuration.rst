.. _configuration:

Configuration Guide
===================

Kuiper-gen's build process is controlled by settings defined in the 
``config`` file located in the root of the repository. This file contains 
bash variables that determine what features to include and how to build 
the image.

How to Configure
----------------

To modify the configuration:

#. Edit the ``config`` file in your preferred text editor
#. Set option values to ``y`` to enable features or ``n`` to disable them
#. Modify other values as needed for your build
#. Save the file and run the build script

After the build completes, you can find a copy of the used configuration 
in the root directory (``/``) of the built image.

You can also set the number of processors or cores you want to use for 
building by adding ``NUM_JOBS=[number]`` to the config file. By default, 
this uses all available cores (``$(nproc)``).

System Configuration
--------------------

These options control the fundamental aspects of your Kuiper image.

.. list-table::
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``TARGET_ARCHITECTURE``
     - ``armhf``
     - Target architecture: ``armhf`` (32-bit) or ``arm64`` (64-bit)
   * - ``DEBIAN_VERSION``
     - ``bookworm``
     - Debian version to use (e.g., ``bookworm``, ``bullseye``). Other 
       versions may have missing functionalities or unsupported tools

Build Process Options
---------------------

These options control how the Docker build process behaves.

.. list-table::
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``PRESERVE_CONTAINER``
     - ``n``
     - Keep the Docker container after building (``y``/``n``)
   * - ``CONTAINER_NAME``
     - ``debian_<DEBIAN_VERSION>_rootfs_container``
     - Name of the Docker container. Useful for building multiple images 
       in parallel
   * - ``EXPORT_SOURCES``
     - ``n``
     - Download source files for all packages in the image (``y``/``n``)

Desktop Environment
-------------------

.. list-table::
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``CONFIG_DESKTOP``
     - ``n``
     - Install XFCE desktop environment and X11VNC server (``y``/``n``)

When enabled, this adds a complete graphical desktop environment with 
remote access capabilities via VNC.

ADI Libraries and Tools
-----------------------

These options control which ADI libraries and tools are included in the 
image. Many tools have dependencies on other libraries.

Core Libraries
~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``CONFIG_LIBIIO``
     - ``n``
     - Install Libiio library (``y``/``n``)
   * - ``CONFIG_LIBIIO_CMAKE_ARGS``
     - ``"-DWITH_HWMON=ON -DWITH_SERIAL_BACKEND=ON -DWITH_MAN=ON 
       -DWITH_EXAMPLES=ON -DPYTHON_BINDINGS=ON -DCMAKE_BUILD_TYPE=Release 
       -DCMAKE_COLOR_MAKEFILE=OFF -Bbuild -H."``
     - CMake build arguments for Libiio
   * - ``BRANCH_LIBIIO``
     - ``libiio-v0``
     - Git branch to use for Libiio
   * - ``CONFIG_PYADI``
     - ``n``
     - Install Pyadi library (``y``/``n``). **Requires Libiio**
   * - ``BRANCH_PYADI``
     - ``main``
     - Git branch to use for Pyadi
   * - ``CONFIG_LIBM2K``
     - ``n``
     - Install Libm2k library (``y``/``n``). **Requires Libiio**
   * - ``CONFIG_LIBM2K_CMAKE_ARGS``
     - ``"-DENABLE_PYTHON=ON -DENABLE_CSHARP=OFF -DENABLE_EXAMPLES=ON 
       -DENABLE_TOOLS=ON -DINSTALL_UDEV_RULES=ON -Bbuild -H."``
     - CMake build arguments for Libm2k
   * - ``BRANCH_LIBM2K``
     - ``main``
     - Git branch to use for Libm2k

Device-Specific Libraries
~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``CONFIG_LIBAD9166_IIO``
     - ``n``
     - Install Libad9166 library for userspace calibration (``y``/``n``). 
       **Requires Libiio**
   * - ``CONFIG_LIBAD9166_IIO_CMAKE_ARGS``
     - ``"-DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release 
       -DCMAKE_COLOR_MAKEFILE=OFF -DPYTHON_BINDINGS=ON -DWITH_DOC=OFF 
       -Bbuild -H."``
     - CMake build arguments for Libad9166
   * - ``BRANCH_LIBAD9166_IIO``
     - ``libad9166-iio-v0``
     - Git branch to use for Libad9166
   * - ``CONFIG_LIBAD9361_IIO``
     - ``n``
     - Install Libad9361 library for multi-chip sync and FIR filters 
       (``y``/``n``). **Requires Libiio**
   * - ``CONFIG_LIBAD9361_IIO_CMAKE_ARGS``
     - ``"-DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release 
       -DCMAKE_COLOR_MAKEFILE=OFF -DPYTHON_BINDINGS=ON -DWITH_DOC=OFF 
       -Bbuild -H."``
     - CMake build arguments for Libad9361
   * - ``BRANCH_LIBAD9361_IIO``
     - ``libad9361-iio-v0``
     - Git branch to use for Libad9361

Advanced Libraries
~~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``CONFIG_GRM2K``
     - ``n``
     - Install GNU Radio blocks for ADALM-2000 (``y``/``n``). **Requires 
       Libiio, Libm2k, and Gnuradio**
   * - ``CONFIG_GRM2K_CMAKE_ARGS``
     - ``"-Bbuild -H."``
     - CMake build arguments for GRM2K
   * - ``BRANCH_GRM2K``
     - ``main``
     - Git branch to use for GRM2K
   * - ``CONFIG_LINUX_SCRIPTS``
     - ``n``
     - Install ADI scripts for Linux images (``y``/``n``)
   * - ``BRANCH_LINUX_SCRIPTS``
     - ``kuiper2.0``
     - Git branch to use for Linux scripts

ADI Applications
----------------

These options control which ADI applications are included in the image.

GUI Applications
~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``CONFIG_IIO_OSCILLOSCOPE``
     - ``n``
     - Install IIO Oscilloscope GTK+ application (``y``/``n``). **Requires 
       Libiio, Libad9166_IIO, and Libad9361_IIO**
   * - ``CONFIG_IIO_OSCILLOSCOPE_CMAKE_ARGS``
     - ``"-DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release 
       -DCMAKE_COLOR_MAKEFILE=OFF -Bbuild -H."``
     - CMake build arguments for IIO Oscilloscope
   * - ``BRANCH_IIO_OSCILLOSCOPE``
     - ``main``
     - Git branch to use for IIO Oscilloscope
   * - ``CONFIG_SCOPY``
     - ``n``
     - Install Scopy software oscilloscope and signal analysis toolset 
       (``y``/``n``)
   * - ``CONFIG_JESD_EYE_SCAN_GTK``
     - ``n``
     - Install JESD204 Eye Scan Visualization Utility (``y``/``n``)
   * - ``BRANCH_JESD_EYE_SCAN_GTK``
     - ``main``
     - Git branch to use for JESD Eye Scan GTK

Specialized Applications
~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``CONFIG_IIO_FM_RADIO``
     - ``n``
     - Install simple IIO FM Radio receive example (``y``/``n``)
   * - ``BRANCH_IIO_FM_RADIO``
     - ``main``
     - Git branch to use for IIO FM Radio
   * - ``CONFIG_FRU_TOOLS``
     - ``n``
     - Install tools to display/manipulate FMC FRU info (``y``/``n``)
   * - ``BRANCH_FRU_TOOLS``
     - ``main``
     - Git branch to use for FRU tools
   * - ``CONFIG_COLORIMETER``
     - ``n``
     - Install application for EVAL-CN0363-PMDZ (``y``/``n``). **Requires 
       Libiio**
   * - ``BRANCH_COLORIMETER``
     - ``main``
     - Git branch to use for Colorimeter

Non-ADI Applications
--------------------

These options control which non-ADI applications are included.

.. list-table::
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``CONFIG_GNURADIO``
     - ``n``
     - Install GNU Radio software development toolkit for software radios 
       (``y``/``n``)

Boot Configuration
------------------

These options control boot files and configurations for different 
hardware platforms.

Raspberry Pi Boot Files
~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``CONFIG_RPI_BOOT_FILES``
     - ``y``
     - Include Raspberry Pi boot files (``y``/``n``) - **Enabled by 
       default**
   * - ``BRANCH_RPI_BOOT_FILES``
     - ``rpi-6.1.y``
     - Git branch for Raspberry Pi boot files
   * - ``USE_ADI_REPO_RPI_BOOT``
     - ``y``
     - Install Raspberry Pi boot files from ADI repository (``y``/``n``)

Xilinx and Intel Boot Files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``CONFIG_XILINX_INTEL_BOOT_FILES``
     - ``y``
     - Include Xilinx and Intel boot files (``y``/``n``) - **Enabled by 
       default**
   * - ``RELEASE_XILINX_INTEL_BOOT_FILES``
     - ``2022_r2``
     - Release version of Xilinx/Intel boot files
   * - ``USE_ADI_REPO_CARRIERS_BOOT``
     - ``y``
     - Install carriers boot files from ADI repository (``y``/``n``)

Platform-Specific Configuration
-------------------------------

These options configure the target board and project.

.. list-table::
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``ADI_EVAL_BOARD``
     - *(empty)*
     - Configure which ADI evaluation board project the image will run. 
       Requires ``CONFIG_XILINX_INTEL_BOOT_FILES=y``
   * - ``CARRIER``
     - *(empty)*
     - Configure which board the image will boot on. Used together with 
       ``ADI_EVAL_BOARD``
   * - ``INSTALL_RPI_PACKAGES``
     - ``n``
     - Install Raspberry Pi specific packages (``y``/``n``) including: 
       raspi-config, GPIO-related tools (pigpio, python3-gpio, raspi-gpio, 
       python3-rpi.gpio), VideoCore debugging related (vcdbg), sense-hat, 
       sense-emu

Customization Options
---------------------

.. list-table::
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``EXTRA_SCRIPT``
     - *(empty)*
     - Path to a custom script inside the adi-kuiper-gen directory to run 
       during build for additional customization

Common Configuration Examples
-----------------------------

Building a 64-bit Image with Desktop Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   TARGET_ARCHITECTURE=arm64
   CONFIG_DESKTOP=y

Including IIO Tools and Libraries
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   CONFIG_LIBIIO=y                  # Enable core IIO library
   CONFIG_LIBAD9166_IIO=y           # Enable AD9166 support  
   CONFIG_LIBAD9361_IIO=y           # Enable AD9361 support
   CONFIG_IIO_OSCILLOSCOPE=y        # Enable GUI application
   CONFIG_PYADI=y                   # Enable Python interfaces

Building for a Specific ADI Evaluation Board
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   ADI_EVAL_BOARD=ad9361-fmcomms2
   CARRIER=zedboard

Complete Development Environment with GNU Radio
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   CONFIG_DESKTOP=y
   CONFIG_LIBIIO=y                  # Enable core IIO library
   CONFIG_LIBM2K=y
   CONFIG_GNURADIO=y
   CONFIG_GRM2K=y

Minimal Embedded System
~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   TARGET_ARCHITECTURE=armhf
   CONFIG_DESKTOP=n
   CONFIG_LIBIIO=y                  # Enable basic hardware interface
   # All other CONFIG_* options remain 'n' (default)

Configuration Dependencies
--------------------------

Understanding Tool Dependencies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Many ADI tools have dependencies on other libraries. Here are the key 
dependency relationships:

**Base Requirements:**
* Most ADI tools require ``CONFIG_LIBIIO=y`` (disabled by default - must be explicitly enabled)

**Library Dependencies:**
* ``CONFIG_PYADI`` requires ``CONFIG_LIBIIO=y``
* ``CONFIG_LIBM2K`` requires ``CONFIG_LIBIIO=y``
* ``CONFIG_LIBAD9166_IIO`` requires ``CONFIG_LIBIIO=y``
* ``CONFIG_LIBAD9361_IIO`` requires ``CONFIG_LIBIIO=y``
* ``CONFIG_COLORIMETER`` requires ``CONFIG_LIBIIO=y``

**Application Dependencies:**
* ``CONFIG_IIO_OSCILLOSCOPE`` requires ``CONFIG_LIBIIO=y``, 
  ``CONFIG_LIBAD9166_IIO=y``, and ``CONFIG_LIBAD9361_IIO=y``
* ``CONFIG_GRM2K`` requires ``CONFIG_LIBIIO=y``, ``CONFIG_LIBM2K=y``, 
  and ``CONFIG_GNURADIO=y``

**Boot Dependencies:**
* Setting ``ADI_EVAL_BOARD`` requires ``CONFIG_XILINX_INTEL_BOOT_FILES=y`` 
  (enabled by default)

Automatic Dependency Resolution
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The build system will automatically enable required dependencies when 
you enable a tool that depends on them. However, it's good practice to 
explicitly enable dependencies in your configuration for clarity.

Default Configuration Analysis
------------------------------

The default configuration provides a truly minimal image following the 
"MINIMAL" approach described in the config file:

**What's Included by Default:**
* Basic Debian system (``armhf``, ``bookworm``)
* Boot files for both Raspberry Pi and Xilinx/Intel platforms
* Essential system packages only

**What's Not Included by Default:**
* Desktop environment (enable with ``CONFIG_DESKTOP=y``)
* Any ADI libraries or tools (all CONFIG_* options default to ``n``)
* Libiio library (enable with ``CONFIG_LIBIIO=y``)
* Device-specific libraries
* Applications and GUI tools

This minimal default keeps build time short and image size small. Users 
must explicitly enable the ADI tools and libraries they need.

Custom Script Integration
-------------------------

Kuiper allows you to run additional scripts during the build process to 
customize the resulting image. This feature enables advanced 
customization beyond the standard configuration options.

Using the Example Script
~~~~~~~~~~~~~~~~~~~~~~~~

To use the provided example script:

#. In the ``config`` file, set the ``EXTRA_SCRIPT`` variable to:

   .. code-block:: bash

      EXTRA_SCRIPT=stages/07.extra-tweaks/01.extra-scripts/examples/extra-script-example.sh

#. If you need to pass ``config`` file parameters to the script, 
   uncomment the line where it sources the config file in the example 
   script.

#. Add your custom commands to the example script file.

Using Your Own Custom Script
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To use your own custom script:

#. Place your script file inside the ``adi-kuiper-gen/stages`` directory.

#. In the ``config`` file, set the ``EXTRA_SCRIPT`` variable to the path 
   of your script relative to the ``adi-kuiper-gen`` directory.

#. Make sure your script is executable (``chmod +x your-script.sh``).

Custom scripts are executed in the chroot environment of the target 
system during the build process, allowing you to install additional 
packages, modify system files, or perform any other customization.

Configuration Validation
-------------------------

Before starting a build, the system performs basic validation:

**Architecture Validation:**
* Only ``armhf`` and ``arm64`` are supported
* Unsupported architectures will cause the build to exit

**Debian Version Validation:**
* Only ``bullseye`` and ``bookworm`` are officially supported
* Other versions may work but are not guaranteed

**Path Validation:**
* Build paths cannot contain spaces
* Repository must be cloned to a valid path

**Permission Validation:**
* Build script must be run as root (with ``sudo``)
* Docker daemon must be accessible

For troubleshooting configuration issues, see the :ref:`troubleshooting` 
section.
