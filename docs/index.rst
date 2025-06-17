Kuiper - Embedded Linux for Analog Devices Products
===================================================

.. raw:: html

   <div class="hero-banner">
      <h2>Build Custom Embedded Linux Images in Minutes</h2>
      <p>Kuiper is a powerful, Docker-based build tool that creates customized 
         Debian OS images optimized for Analog Devices hardware. Choose exactly 
         which ADI libraries, tools, and board configurations you need.</p>
   </div>

.. image:: _static/kuiper-build-flow.svg
   :align: center
   :alt: Kuiper build process - from configuration to bootable image
   :width: 100%

----

Why Choose Kuiper?
==================

.. grid:: 1 2 2 2
   :gutter: 3

   .. grid-item-card:: 🔧 **Highly Customizable**

      Configure precisely which ADI tools to include: libiio, pyadi-iio, 
      IIO Oscilloscope, Scopy, GNU Radio, and more. Build exactly what 
      you need, nothing more.

   .. grid-item-card:: 🖥️ **Multi-Platform Support**

      Supports ARM 32-bit and 64-bit architectures with board-specific 
      boot files for Raspberry Pi, Xilinx Zynq, and Intel platforms.

   .. grid-item-card:: 🐳 **Consistent Builds**

      Docker-based build environment ensures reproducible results across 
      different host systems. Build on Ubuntu, run anywhere.

   .. grid-item-card:: 🧩 **Modular Architecture**

      Stage-based build process is easy to understand, customize, and 
      extend with your own scripts and configurations.

----

Quick Start
===========

Get your first Kuiper image built in under 10 minutes:

.. code-block:: bash
   :caption: Build a basic Kuiper image

   # Clone the repository (ensure path has no spaces!)
   git clone --depth 1 https://github.com/analogdevicesinc/adi-kuiper-gen
   cd adi-kuiper-gen
   
   # Build with default configuration (32-bit, Raspberry Pi support)
   sudo ./build-docker.sh

.. tip::
   **First time?** The default build creates a minimal but functional image 
   with Raspberry Pi boot files. Perfect for getting started!

Your image will be ready in ``kuiper-volume/image_YYYY-MM-DD-ADI-Kuiper-Linux-armhf.zip``

.. button-ref:: getting-started/quick-start
   :color: primary
   :outline:
   :expand:

   🚀 **Detailed Quick Start Guide**

----

Popular Build Configurations
============================

.. tab-set::

   .. tab-item:: Basic Image
      :sync: basic

      Minimal system with boot files - perfect for custom development:

      .. code-block:: bash
         :caption: config file settings

         TARGET_ARCHITECTURE=armhf
         CONFIG_DESKTOP=n
         CONFIG_RPI_BOOT_FILES=y

      **Includes:** Core system, networking, SSH, Raspberry Pi boot support

   .. tab-item:: Desktop Development
      :sync: desktop

      Full development environment with graphical interface:

      .. code-block:: bash
         :caption: config file settings

         CONFIG_DESKTOP=y
         CONFIG_LIBIIO=y
         CONFIG_IIO_OSCILLOSCOPE=y
         CONFIG_GNURADIO=y

      **Includes:** XFCE desktop, VNC server, ADI tools, GNU Radio

   .. tab-item:: Embedded Target
      :sync: embedded

      Optimized for specific ADI evaluation boards:

      .. code-block:: bash
         :caption: config file settings

         TARGET_ARCHITECTURE=arm64
         ADI_EVAL_BOARD=ad9361-fmcomms2
         CARRIER=zedboard
         CONFIG_LIBIIO=y

      **Includes:** Board-specific boot files, IIO libraries, optimizations

.. button-ref:: examples/basic-builds
   :color: secondary
   :outline:

   💻 **More Configuration Examples**

----

What's Included
===============

.. dropdown:: 🔧 **ADI Libraries & Tools**
   :open:

   .. list-table::
      :header-rows: 1
      :class: bold-header

      * - Library/Tool
        - Description
        - Use Case
      * - **libiio**
        - Industrial I/O library
        - Device communication, data streaming
      * - **pyadi-iio**
        - Python bindings for libiio
        - Rapid prototyping, scripting
      * - **IIO Oscilloscope**
        - Graphical test & measurement tool
        - Real-time signal analysis
      * - **Scopy**
        - Multi-instrument suite
        - Complete test bench replacement
      * - **GNU Radio**
        - Software-defined radio toolkit
        - Signal processing, RF applications

.. dropdown:: 🖥️ **Desktop Environment (Optional)**

   When ``CONFIG_DESKTOP=y``:
   
   * **XFCE Desktop** - Lightweight, responsive interface
   * **X11VNC Server** - Remote desktop access
   * **Development Tools** - Editors, terminals, file managers
   * **Auto-login** - Boots directly to desktop as 'analog' user

.. dropdown:: 🛠️ **System Features**

   Every Kuiper image includes:
   
   * **SSH Server** - Remote access enabled by default
   * **User Management** - Pre-configured 'analog' user with sudo
   * **Network Configuration** - DHCP, WiFi support (RPi)
   * **Auto-resize** - Root partition expands on first boot
   * **Package Repositories** - ADI and Debian repositories configured

----

Build Process Overview
======================

Kuiper uses a sophisticated **8-stage build process** that's both powerful 
and easy to understand:

.. mermaid::
   :caption: Kuiper Build Pipeline

   flowchart TD
       A[01. Bootstrap] --> B[02. Locale & Timezone]
       B --> C[03. System Tweaks]
       C --> D[04. Desktop Environment]
       D --> E[05. ADI Tools]
       E --> F[06. Boot Partition]
       F --> G[07. Extra Tweaks]
       G --> H[08. Export Image]
       
       style A fill:#e1f5fe
       style E fill:#f3e5f5
       style H fill:#e8f5e8

Each stage is **modular** and **configurable** - only the components you 
need are built and included.

.. button-ref:: user-guide/build-process
   :color: info
   :outline:

   🔍 **Detailed Build Process**

----

System Requirements
===================

.. important::
   **Supported Host OS:** Ubuntu 22.04 LTS is recommended. Other Linux 
   distributions may work but are not officially supported.

.. grid:: 1 2 2 2
   :gutter: 2

   .. grid-item::
      :columns: 6

      **Required Software:**
      
      * Docker 24.0.6+
      * qemu-user-static
      * binfmt-support
      * 10GB+ free disk space

   .. grid-item::
      :columns: 6

      **Important Notes:**
      
      * Windows is **not supported**
      * Repository path must have **no spaces**
      * Root/sudo access required
      * Internet connection needed

.. button-ref:: getting-started/prerequisites
   :color: warning
   :outline:

   📋 **Complete Prerequisites**

----

Ready to Build?
===============

.. grid:: 1 2 2 2
   :gutter: 3

   .. grid-item-card:: 🎯 **I'm New to Kuiper**
      :link: getting-started/index
      :link-type: doc

      Start with our step-by-step getting started guide. We'll walk you 
      through your first build and explain the key concepts.

   .. grid-item-card:: 📖 **I Need Configuration Help**
      :link: user-guide/configuration
      :link-type: doc

      Explore our comprehensive configuration reference. Every option 
      is documented with examples and use cases.

   .. grid-item-card:: 💻 **I Want to See Examples**
      :link: examples/index
      :link-type: doc

      Browse real-world configuration examples for common scenarios 
      and advanced use cases.

   .. grid-item-card:: ❓ **I Need Help**
      :link: reference/troubleshooting
      :link-type: doc

      Check our troubleshooting guide or browse the reference 
      documentation for detailed technical information.

----

Build Status & Community
========================

.. grid:: 1 2 2 2
   :gutter: 2

   .. grid-item::
      :columns: 8

      .. image:: https://github.com/analogdevicesinc/adi-kuiper-gen/actions/workflows/kuiper2_0-build.yml/badge.svg?branch=main
         :target: https://github.com/analogdevicesinc/adi-kuiper-gen/actions/workflows/kuiper2_0-build.yml
         :alt: Kuiper2.0 Build Status

      Latest builds are automatically tested on GitHub Actions.

   .. grid-item::
      :columns: 4

      **🌐 Community Links:**

      * `GitHub Repository <https://github.com/analogdevicesinc/adi-kuiper-gen>`__
      * `Issue Tracker <https://github.com/analogdevicesinc/adi-kuiper-gen/issues>`__
      * `ADI Engineering Zone <https://ez.analog.com/fpga>`__

.. tip:: **Contributing**
   
   Found an issue or want to contribute? Open an issue on GitHub or 
   check out our contribution guidelines.

----

Contents
========

.. toctree::
   :maxdepth: 2
   :caption: Documentation Sections

   getting-started/index
   user-guide/index
   user-guide/configuration
   reference/index
   examples/index

.. toctree::
   :maxdepth: 1
   :caption: Quick Reference
   :hidden:

   GitHub Repository <https://github.com/analogdevicesinc/adi-kuiper-gen>
   Issue Tracker <https://github.com/analogdevicesinc/adi-kuiper-gen/issues>
   ADI Engineer Zone <https://ez.analog.com>
