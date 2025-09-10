.. _hardware-configuration:

Hardware Configuration
======================

Kuiper allows you to configure your image to work with specific ADI evaluation 
boards and carrier platforms both during the build process and after 
deployment. This flexibility lets you create images that are ready for your 
primary hardware while maintaining the ability to reconfigure for different 
hardware later.

.. description::

   Configure Kuiper images for different ADI evaluation boards and carrier 
   platforms using build-time configuration and runtime reconfiguration

----

How Hardware Configuration Works
--------------------------------

Kuiper uses a unified approach to hardware configuration that works at both 
build time and runtime:

**Build-Time Configuration (Optional)**
   Set ``ADI_EVAL_BOARD`` and ``CARRIER`` parameters in your config file 
   before building. Your image will be automatically configured for that 
   specific hardware combination during the build process. See the 
   :doc:`Configuration <configuration>` section for details on these 
   parameters.

**Runtime Reconfiguration (Always Available)**
   Use the built-in ``configure-setup.sh`` script to configure or reconfigure 
   your Kuiper image for different hardware combinations after deployment. 
   This script is always installed and available, regardless of whether you 
   used build-time configuration.

**Key Benefits:**

- **Set defaults at build time** for your primary hardware target
- **Reconfigure anytime** for testing different evaluation boards
- **Use the same image** across multiple hardware platforms
- **No rebuilding required** when switching hardware configurations

Using Hardware Configuration
----------------------------

When to Configure Hardware
~~~~~~~~~~~~~~~~~~~~~~~~~~

Hardware configuration and reconfiguration is useful when you need to:

- **Set up your primary hardware** during the build process for immediate use
- **Test multiple evaluation boards** with the same Kuiper installation
- **Switch between development and production hardware** without rebuilding 
  images
- **Explore different ADI evaluation projects** on various carrier boards
- **Use a single image** across multiple hardware setups in your lab or 
  production environment

Common Workflows
~~~~~~~~~~~~~~~~

**Single Hardware Target**
   Set ``ADI_EVAL_BOARD`` and ``CARRIER`` during build for automatic 
   configuration. Your image boots ready to use with your hardware.

**Multi-Hardware Development**  
   Build with your primary hardware configured, then use runtime 
   reconfiguration to test other combinations as needed.

**Flexible Lab Image**
   Build without specifying hardware (leave ``ADI_EVAL_BOARD`` and 
   ``CARRIER`` empty), then configure each deployment using the runtime 
   script.

Discovering Available Hardware Combinations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Before reconfiguring your hardware setup, you need to know what combinations 
are supported by your Kuiper image. The configuration script includes a 
discovery feature that shows all available options.

To see what hardware combinations your image supports:

.. code-block:: bash

   sudo configure-setup.sh --help

Output example:

.. code-block:: text

   Usage:
     sudo configure-setup.sh [OPTIONS] [ARGUMENTS]

   Description:
     Script that prepares Kuiper image to boot on a carrier board.

   Arguments:
     eval-board	Name of the project
     carrier	Carrier board name

   Options:
     -h, --help	Show this help message

   Example:
     sudo configure-setup.sh ad4003 zed


   Available projects in your Kuiper image:

   ADI Eval Board    Carrier
   ad9361-fmcomms2   zed
   ad9361-fmcomms2   zc706
   ad4003            zed
   adrv9009-zu11eg   adrv9009-zu11eg-revb

This output shows all the evaluation board and carrier combinations that your 
specific Kuiper image can support.

Reconfiguring Your Hardware Setup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hardware reconfiguration requires root access to your Kuiper system (the 
``analog`` user has sudo privileges) and that your system is running from an 
SD card or storage device. The process varies depending on whether you're 
switching to different physical hardware or reconfiguring for the same 
hardware.

Follow these steps:

#. **Log into your current Kuiper system** via console, SSH, or VNC

#. **Check available configurations** (if you haven't already):

   .. code-block:: bash

      sudo configure-setup.sh --help

#. **Run the configuration command** on your current system with your desired 
   hardware combination:

   .. code-block:: bash

      sudo configure-setup.sh <eval-board> <carrier>

   For example, to configure for the AD9361-FMCOMMS2 evaluation board on a 
   ZedBoard carrier:

   .. code-block:: bash

      sudo configure-setup.sh ad9361-fmcomms2 zed

   Output:

   .. code-block:: text

      Successfully prepared boot partition for running project ad9361-fmcomms2 on zedboard.

#. **Shutdown your system** (for hardware changes) or **reboot** (for same 
   hardware):

   For different hardware platforms:

   .. code-block:: bash

      sudo shutdown -h now

   For same hardware reconfiguration:

   .. code-block:: bash

      sudo reboot

#. **Move the SD card** (only if switching to different hardware):

   * Remove the SD card from your current hardware
   * Insert it into your target hardware platform
   * Skip this step if reconfiguring for the same hardware

#. **Boot your target system**:

   * Power on the target hardware
   * The system will boot with the new configuration

.. important::

   * Configuration changes take effect only after a complete boot cycle
   * When switching between different carrier boards (e.g., ZedBoard to 
     ZC706), the SD card must be physically moved to the new hardware
   * For same-hardware reconfigurations, you can use ``reboot`` instead of 
     the full shutdown/move/boot process
   * Always use ``shutdown -h now`` when moving to different physical 
     hardware to ensure proper system state

What Happens During Reconfiguration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When you run the configuration script, it performs several operations to 
prepare your system for the target hardware:

**File Operations**
   - Copies the appropriate kernel image to the boot partition
   - Copies device tree files and boot configuration files specific to your 
     hardware
   - Updates boot loader configurations as needed

**Platform-Specific Setup**
   For Intel-based platforms, the script performs additional steps including 
   updating the boot loader in the dedicated boot loader partition.

**Verification**
   The script provides feedback on the success or failure of each operation, 
   allowing you to verify that the configuration completed properly.

----

Examples and Common Use Cases
-----------------------------

Same Hardware Reconfiguration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When testing different evaluation board projects on the same carrier board, 
you can use the simple reboot workflow since no physical hardware changes:

.. code-block:: bash

   # Test AD4003 project on ZedBoard
   sudo configure-setup.sh ad4003 zed

Output:

.. code-block:: text

   Successfully prepared boot partition for running project ad4003 on zed.

----

.. code-block:: bash

   sudo reboot

----

.. code-block:: bash

   # Later, switch to AD9361-FMCOMMS2 on the same ZedBoard
   sudo configure-setup.sh ad9361-fmcomms2 zed

Output:

.. code-block:: text

   Successfully prepared boot partition for running project ad9361-fmcomms2 on zedboard.

----

.. code-block:: bash

   sudo reboot

Different Hardware Platforms
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When switching between different carrier boards, follow the complete 
shutdown/move/boot workflow:

.. code-block:: bash

   # Configure for AD9361-FMCOMMS2 on ZedBoard
   sudo configure-setup.sh ad9361-fmcomms2 zed

Output:

.. code-block:: text

   Successfully prepared boot partition for running project ad9361-fmcomms2 on zedboard.

----

.. code-block:: bash

   sudo shutdown -h now

----

After shutdown, remove the SD card from the ZedBoard and insert it into your 
ZC706 carrier board, then power on the ZC706.

----

.. code-block:: bash

   # Later, reconfigure for the same project on ZC706
   sudo configure-setup.sh ad9361-fmcomms2 zc706

Output:

.. code-block:: text

   Successfully prepared boot partition for running project ad9361-fmcomms2 on zc706.

----

.. code-block:: bash

   sudo shutdown -h now

Again, move the SD card from ZC706 to your target hardware and power on.

Development and Testing Workflow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A common development workflow combines both scenarios - testing on 
development hardware, then deploying to production hardware:

.. code-block:: bash

   # Development phase: test different projects on ZedBoard
   sudo configure-setup.sh ad9361-fmcomms2 zed
   sudo reboot
   # ... run development tests ...

   sudo configure-setup.sh ad4003 zed
   sudo reboot
   # ... test different evaluation board ...

When ready for production deployment:

.. code-block:: bash

   # Configure for production hardware
   sudo configure-setup.sh ad9361-fmcomms2 zc706
   sudo shutdown -h now

Remove SD card from ZedBoard, insert into ZC706 production hardware, and 
power on.

.. code-block:: bash

   # On production hardware, verify configuration
   sudo configure-setup.sh --help
   # Confirm your project shows in the available list

----

Next Steps
----------

For troubleshooting hardware configuration issues, see the 
:doc:`Troubleshooting <troubleshooting>` section.

To learn more about build-time configuration options, see the 
:doc:`Configuration <configuration>` section.
