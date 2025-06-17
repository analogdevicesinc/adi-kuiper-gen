Configuration
=============

Kuiper-gen's build process is controlled by settings defined in the ``config`` 
file located in the root of the repository. This file contains bash variables 
that determine what features to include and how to build the image.

.. contents:: Configuration Topics
   :local:
   :depth: 2

How to Configure
----------------

To modify the configuration:

1. **Edit the config file** in your preferred text editor
2. **Set option values** to ``y`` to enable features or ``n`` to disable them
3. **Modify other values** as needed for your build
4. **Save the file** and run the build script

.. code-block:: bash
   :caption: Basic configuration workflow

   # Edit the configuration
   nano config
   
   # Build with your settings
   sudo ./build-docker.sh

.. tip::
   **Configuration persistence:** After the build completes, you can find a 
   copy of the used configuration in the root directory (``/``) of the built 
   image.

Performance Optimization
~~~~~~~~~~~~~~~~~~~~~~~~

You can also set the number of processors or cores you want to use for building 
by adding ``NUM_JOBS=[number]`` to the config file. By default, this uses all 
available cores (``$(nproc)``).

.. code-block:: bash
   :caption: Example performance settings

   # Use 4 cores for building
   NUM_JOBS=4
   
   # Use all available cores (default)
   NUM_JOBS=$(nproc)

System Configuration
--------------------

These options control the fundamental aspects of your Kuiper image:

.. list-table:: System Configuration Options
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

.. important::
   **Architecture choice:** ``armhf`` (32-bit) provides broader hardware 
   compatibility, while ``arm64`` (64-bit) offers better performance on 
   modern processors.

Build Process Options
---------------------

These options control how the Docker build process behaves:

.. list-table:: Build Process Options
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

.. dropdown:: 🔍 **When to use these options**

   **PRESERVE_CONTAINER=y:** Useful for debugging build issues or examining 
   the intermediate build state. The container will remain after build 
   completion for inspection.
   
   **Custom CONTAINER_NAME:** Essential when building multiple images 
   simultaneously to avoid container name conflicts.
   
   **EXPORT_SOURCES=y:** Required for compliance scenarios where you need 
   access to all source code used in the image.

Desktop Environment
-------------------

.. list-table:: Desktop Environment Options
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``CONFIG_DESKTOP``
     - ``n``
     - Install XFCE desktop environment and X11VNC server (``y``/``n``)

.. grid:: 1 2 2 2
   :gutter: 2

   .. grid-item::
      :columns: 6

      **Desktop Disabled (Default):**
      
      * Minimal system footprint
      * Command-line interface only
      * Suitable for embedded applications
      * Faster boot times

   .. grid-item::
      :columns: 6

      **Desktop Enabled:**
      
      * Full XFCE desktop environment
      * X11VNC server for remote access
      * Development tools and GUI applications
      * Larger image size (~500MB additional)

ADI Libraries and Tools
-----------------------

These options control which ADI libraries and tools are included in the image:

Core Libraries
~~~~~~~~~~~~~~

.. list-table:: Core ADI Libraries
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Branch
     - Description
   * - ``CONFIG_LIBIIO``
     - ``n``
     - ``libiio-v0``
     - Install Libiio library (``y``/``n``)
   * - ``CONFIG_PYADI``
     - ``n``
     - ``main``
     - Install Pyadi library (``y``/``n``). **Requires Libiio**
   * - ``CONFIG_LIBM2K``
     - ``n``
     - ``main``
     - Install Libm2k library (``y``/``n``). **Requires Libiio**

.. important::
   **Dependency chain:** Most ADI libraries require ``CONFIG_LIBIIO=y`` as a 
   foundation. Enable Libiio first, then add other libraries as needed.

Device-Specific Libraries
~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: Device-Specific Libraries
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Branch
     - Description
   * - ``CONFIG_LIBAD9166_IIO``
     - ``n``
     - ``libad9166-iio-v0``
     - Install Libad9166 library (``y``/``n``). **Requires Libiio**
   * - ``CONFIG_LIBAD9361_IIO``
     - ``n``
     - ``libad9361-iio-v0``
     - Install Libad9361 library (``y``/``n``). **Requires Libiio**
   * - ``CONFIG_GRM2K``
     - ``n``
     - ``main``
     - Install GRM2K (``y``/``n``). **Requires Libiio, Libm2k, and Gnuradio**

System Integration
~~~~~~~~~~~~~~~~~~

.. list-table:: System Integration Tools
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Branch
     - Description
   * - ``CONFIG_LINUX_SCRIPTS``
     - ``n``
     - ``kuiper2.0``
     - Install ADI Linux scripts (``y``/``n``)

.. dropdown:: ⚙️ **Advanced CMake Configuration**

   Each library supports custom CMake arguments for advanced builds:
   
   * ``CONFIG_LIBIIO_CMAKE_ARGS`` - CMake build arguments for Libiio
   * ``CONFIG_LIBM2K_CMAKE_ARGS`` - CMake build arguments for Libm2k  
   * ``CONFIG_LIBAD9166_IIO_CMAKE_ARGS`` - CMake build arguments for Libad9166
   * ``CONFIG_LIBAD9361_IIO_CMAKE_ARGS`` - CMake build arguments for Libad9361
   * ``CONFIG_GRM2K_CMAKE_ARGS`` - CMake build arguments for GRM2K
   
   See the ``config`` file for current defaults and examples.

ADI Applications
----------------

These options control which ADI applications are included in the image:

.. list-table:: ADI Applications
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Branch
     - Dependencies
     - Description
   * - ``CONFIG_IIO_OSCILLOSCOPE``
     - ``n``
     - ``main``
     - Libiio, Libad9166_IIO, Libad9361_IIO
     - Install IIO Oscilloscope (``y``/``n``)
   * - ``CONFIG_IIO_FM_RADIO``
     - ``n``
     - ``main``
     - None
     - Install IIO FM Radio (``y``/``n``)
   * - ``CONFIG_FRU_TOOLS``
     - ``n``
     - ``main``
     - None
     - Install FRU tools (``y``/``n``)
   * - ``CONFIG_JESD_EYE_SCAN_GTK``
     - ``n``
     - ``main``
     - None
     - Install JESD Eye Scan GTK (``y``/``n``)
   * - ``CONFIG_COLORIMETER``
     - ``n``
     - ``main``
     - Libiio
     - Install Colorimeter (``y``/``n``)
   * - ``CONFIG_SCOPY``
     - ``n``
     - N/A
     - None
     - Install Scopy (``y``/``n``)

.. tip::
   **Application selection:** These applications provide GUI tools for testing 
   and measurement. Enable ``CONFIG_DESKTOP=y`` to use them with the graphical 
   interface.

Non-ADI Applications
--------------------

These options control which non-ADI applications are included in the image:

.. list-table:: Third-Party Applications
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``CONFIG_GNURADIO``
     - ``n``
     - Install GNU Radio (``y``/``n``)

.. note::
   **GNU Radio integration:** GNU Radio is a powerful software-defined radio 
   toolkit that integrates well with ADI's RF and mixed-signal devices.

Boot Configuration
------------------

These options control boot files and configurations:

.. list-table:: Boot Configuration Options
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``CONFIG_RPI_BOOT_FILES``
     - ``y``
     - Include Raspberry Pi boot files (``y``/``n``) - **Enabled by default**
   * - ``BRANCH_RPI_BOOT_FILES``
     - ``rpi-6.1.y``
     - Git branch for Raspberry Pi boot files
   * - ``USE_ADI_REPO_RPI_BOOT``
     - ``y``
     - Install Raspberry Pi boot files from ADI repository (``y``/``n``)
   * - ``CONFIG_XILINX_INTEL_BOOT_FILES``
     - ``y``
     - Include Xilinx and Intel boot files (``y``/``n``) - **Enabled by default**
   * - ``RELEASE_XILINX_INTEL_BOOT_FILES``
     - ``2022_r2``
     - Release version of Xilinx/Intel boot files
   * - ``USE_ADI_REPO_CARRIERS_BOOT``
     - ``y``
     - Install carriers boot files from ADI repository (``y``/``n``)

.. important::
   **Default boot support:** Both Raspberry Pi and Xilinx/Intel boot files are 
   enabled by default, providing broad hardware compatibility out of the box.

Platform-Specific Configuration
-------------------------------

These options configure the target board and project:

.. list-table:: Platform-Specific Options
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
       python3-rpi.gpio), VideoCore debugging (vcdbg), sense-hat, and sense-emu

.. dropdown:: 🔧 **Evaluation Board Examples**

   Common evaluation board configurations:
   
   **FMCOMMS2/3/4:**
   
   .. code-block:: bash
   
      ADI_EVAL_BOARD=ad9361-fmcomms2
      CARRIER=zedboard
   
   **FMCOMMS5:**
   
   .. code-block:: bash
   
      ADI_EVAL_BOARD=ad9361-fmcomms5
      CARRIER=zedboard
   
   **ADRV9009:**
   
   .. code-block:: bash
   
      ADI_EVAL_BOARD=adrv9009-zu11eg
      CARRIER=adrv9009-zu11eg

Customization
-------------

.. list-table:: Customization Options
   :header-rows: 1
   :class: bold-header

   * - Option
     - Default
     - Description
   * - ``EXTRA_SCRIPT``
     - *(empty)*
     - Path to a custom script inside the adi-kuiper-gen directory to run 
       during build for additional customization

.. seealso::
   For details on creating custom scripts, see :doc:`customization`.

Common Configuration Examples
-----------------------------

Here are proven configuration patterns for common use cases:

.. tab-set::

   .. tab-item:: Desktop Development
      :sync: desktop-dev

      **64-bit image with desktop environment:**

      .. code-block:: bash
         :caption: Desktop development configuration

         TARGET_ARCHITECTURE=arm64
         CONFIG_DESKTOP=y

      **Use case:** Development work requiring graphical interface and modern 
      64-bit performance.

   .. tab-item:: IIO Development
      :sync: iio-dev

      **Including IIO tools and libraries:**

      .. code-block:: bash
         :caption: IIO development configuration

         CONFIG_LIBIIO=y
         CONFIG_IIO_OSCILLOSCOPE=y  # This will require LIBAD9166_IIO and LIBAD9361_IIO

      **Use case:** Working with ADI's Industrial I/O devices and need 
      measurement tools.

   .. tab-item:: Board-Specific
      :sync: board-specific

      **Building for a specific ADI evaluation board:**

      .. code-block:: bash
         :caption: Board-specific configuration

         ADI_EVAL_BOARD=ad9361-fmcomms2
         CARRIER=zedboard

      **Use case:** Targeting a specific hardware platform with optimized 
      boot files and drivers.

   .. tab-item:: Complete Development
      :sync: complete-dev

      **Complete development environment with GNU Radio:**

      .. code-block:: bash
         :caption: Complete development environment

         CONFIG_DESKTOP=y
         CONFIG_LIBIIO=y
         CONFIG_LIBM2K=y
         CONFIG_GNURADIO=y
         CONFIG_GRM2K=y

      **Use case:** Full-featured development environment for complex 
      software-defined radio applications.

Configuration Validation
-------------------------

.. important::
   **Dependency checking:** The build system will automatically detect and 
   install required dependencies. For example, enabling ``CONFIG_IIO_OSCILLOSCOPE`` 
   will automatically enable the required ``CONFIG_LIBAD9166_IIO`` and 
   ``CONFIG_LIBAD9361_IIO`` libraries.

.. tip::
   **Configuration testing:** Start with a basic configuration and add features 
   incrementally to identify which components you actually need for your use case.

Next Steps
----------

.. grid:: 1 2 2 2
   :gutter: 3

   .. grid-item-card:: 🚀 **Build Your Image**
      :link: ../getting-started/quick-start
      :link-type: doc

      Ready to build? Follow the quick start guide with your custom 
      configuration.

   .. grid-item-card:: 🔍 **Understand the Process**
      :link: build-process
      :link-type: doc

      Learn how the build system processes your configuration choices.

   .. grid-item-card:: 📋 **See Examples**
      :link: ../examples/basic-builds
      :link-type: doc

      Browse more configuration examples for specific use cases.

   .. grid-item-card:: ⚙️ **Advanced Customization**
      :link: customization
      :link-type: doc

      Learn about custom scripts and advanced configuration techniques.

.. seealso::

   **Related Documentation:**
   
   * :doc:`kuiper-versions` - Understanding different image types
   * :doc:`build-process` - How configuration affects the build process
   * :doc:`../examples/advanced-scenarios` - Complex configuration examples