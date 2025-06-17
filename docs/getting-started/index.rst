.. _getting-started:

Getting Started with Kuiper
============================

Welcome to Kuiper! This section will guide you through building your first 
custom Debian OS image optimized for Analog Devices hardware.

What You'll Learn
-----------------

By following this getting started guide, you'll:

* ✅ **Set up your build environment** with all required dependencies
* ✅ **Build your first Kuiper image** using default settings  
* ✅ **Write the image to an SD card** and boot your hardware
* ✅ **Understand the build process** and key concepts
* ✅ **Know how to customize** builds for your specific needs

Prerequisites Overview
----------------------

Before you begin, you'll need:

* **Ubuntu 22.04 LTS** (recommended) or compatible Linux distribution
* **Docker 24.0.6+** for containerized builds
* **10GB+ free disk space** for build artifacts
* **Internet connection** for downloading packages
* **ARM emulation support** (qemu-user-static, binfmt-support)

.. important::
   **Time Investment:** Plan for 30-60 minutes for your first build, depending 
   on your system specifications and internet speed.

Learning Path
-------------

Follow these steps in order for the best experience:

.. grid:: 1 1 2 2
   :gutter: 3

   .. grid-item-card:: **1. Prerequisites**
      :link: prerequisites
      :link-type: doc

      Set up your build environment with all required software and 
      verify system compatibility.

      **⏱️ Time:** 10-15 minutes

   .. grid-item-card:: **2. Quick Start**  
      :link: quick-start
      :link-type: doc

      Build your first Kuiper image using the default configuration.

      **⏱️ Time:** 30-60 minutes

   .. grid-item-card:: **3. Using Images**
      :link: first-image  
      :link-type: doc

      Write your image to an SD card and boot your target hardware.

      **⏱️ Time:** 10-15 minutes

   .. grid-item-card:: **4. What's Next**
      :link: /user-guide/index
      :link-type: doc

      Learn about configuration options and customization.

      **⏱️ Time:** Ongoing

Default Build Overview
----------------------

Your first build will create a **Basic Kuiper Image** with:

.. list-table::
   :header-rows: 1
   :class: bold-header

   * - Component
     - Included
     - Description
   * - **Base System**
     - ✅ Yes
     - Minimal Debian with essential packages
   * - **User Account**
     - ✅ Yes
     - 'analog' user with sudo privileges
   * - **SSH Server**
     - ✅ Yes
     - Remote access enabled by default
   * - **Boot Files**
     - ✅ Yes
     - Raspberry Pi boot support
   * - **Desktop Environment**
     - ❌ No
     - Can be enabled with CONFIG_DESKTOP=y
   * - **ADI Tools**
     - ❌ No
     - Can be added with various CONFIG_* options

This basic image is perfect for:

* **Custom development** - Clean base to build upon
* **Learning the system** - Understand core functionality
* **Testing hardware** - Verify boot and basic operation
* **Embedded applications** - Minimal footprint

Ready to Begin?
---------------

.. button-ref:: prerequisites
   :color: primary
   :expand:

   🚀 **Start with Prerequisites**

**Already have prerequisites?**

.. button-ref:: quick-start
   :color: secondary
   :outline:

   ⚡ **Jump to Quick Start**

Need Help?
----------

If you encounter issues during the getting started process:

* :doc:`/reference/troubleshooting` - Common problems and solutions
* `GitHub Issues <https://github.com/analogdevicesinc/adi-kuiper-gen/issues>`__ - Report bugs or ask questions
* :ez:`fpga` - ADI Engineering Zone community support

Contents
--------

.. toctree::
   :maxdepth: 2

   prerequisites
   quick-start
   first-image

.. tip:: **Contributing**
   
   Found an error in this guide or have suggestions for improvement? 
   We welcome contributions! Check out our contribution guidelines on GitHub.