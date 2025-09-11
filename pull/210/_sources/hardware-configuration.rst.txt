.. _hardware-configuration:

Hardware Configuration
======================

Kuiper allows you to configure your image to work with specific ADI 
evaluation boards and carrier platforms both during the build process and 
after deployment. This flexibility lets you create images that are ready for 
your primary hardware while maintaining the ability to reconfigure for 
different hardware later.

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
   Use the built-in ``configure-setup.sh`` script to configure or 
   reconfigure your Kuiper image for different hardware combinations after 
   deployment. This script is always installed and available, regardless of 
   whether you used build-time configuration.

**Key Benefits:**

- **Set defaults at build time** for your primary hardware target
- **Reconfigure anytime** for testing different evaluation boards
- **Use the same image** across multiple hardware platforms
- **No rebuilding required** when switching hardware configurations

----

Using Hardware Configuration
----------------------------

When to Configure Hardware
~~~~~~~~~~~~~~~~~~~~~~~~~~

Hardware configuration and reconfiguration is useful when you need to:

- **Set up your primary hardware** during the build process for immediate 
  use
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

----

Automated Hardware Reconfiguration
----------------------------------

The recommended method for configuring your Kuiper image is the automated 
``configure-setup.sh`` script. This script handles all the technical details 
of copying files, updating configurations, and preparing your system for 
different hardware combinations.

Discovering Available Hardware Combinations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Before reconfiguring your hardware setup, you need to know what 
combinations are supported by your Kuiper image. The configuration script 
includes a discovery feature that shows all available options.

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

This output shows all the evaluation board and carrier combinations that 
your specific Kuiper image can support.

Automated Reconfiguration Process
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hardware reconfiguration requires root access to your Kuiper system (the 
``analog`` user has sudo privileges) and that your system is running from 
an SD card or storage device. The process varies depending on whether you're 
switching to different physical hardware or reconfiguring for the same 
hardware.

Follow these steps:

#. **Log into your current Kuiper system** via console, SSH, or VNC

#. **Check available configurations** (if you haven't already):

   .. code-block:: bash

      sudo configure-setup.sh --help

#. **Run the configuration command** on your current system with your 
   desired hardware combination:

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

What Happens During Automated Reconfiguration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When you run the configuration script, it automatically handles all the 
technical details of preparing your system for the target hardware:

**File Management**
   The script identifies and copies all required files for your specific 
   hardware combination, including kernels, device trees, and boot 
   configurations.

**Platform Adaptation**
   Different hardware platforms require different boot procedures - the script 
   handles these variations automatically, including special requirements for 
   Intel-based systems.

**Verification and Feedback**
   The script reports success or failure for each operation, allowing you to 
   confirm the configuration completed properly before rebooting.

Examples and Common Use Cases
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Same Hardware Reconfiguration**

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

**Different Hardware Platforms**

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

**Development and Testing Workflow**

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

Manual Configuration (Advanced)
-------------------------------

While the automated ``configure-setup.sh`` script handles most configuration 
scenarios, there are situations where manual configuration is necessary or 
preferred. Manual configuration is particularly useful when:

- The automated script fails or reports errors
- You need to perform custom modifications with specific file versions
- Your Kuiper system is not functioning properly and the script is 
  unavailable
- You're working on a host PC to prepare SD cards before deployment
- You need to understand the boot process for development or debugging

The manual process involves the same file operations that the automated 
script performs, but gives you direct control over each step.

Understanding What configure-setup.sh Does
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For manual configuration, it's helpful to understand the technical process 
that the automated script performs:

1. **Project Discovery**: Searches `/boot` for JSON files containing metadata 
   about available hardware combinations, matching your specified evaluation 
   board and carrier.

2. **File Selection**: Extracts file paths from the JSON metadata, identifying 
   which kernel (Image/uImage/zImage), device tree, and boot files are needed 
   for your specific hardware.

3. **Boot Partition Updates**: Copies all required files to `/boot`, 
   including platform-specific files like BOOT.BIN, device trees, and common 
   files like kernel images and U-Boot configurations.

4. **Platform-Specific Operations**: For Intel platforms, creates extlinux 
   directories and writes preloader files to the dedicated bootloader 
   partition (typically `/dev/mmcblk0p3`) using low-level disk operations.

5. **Validation**: Verifies each file operation completed successfully and 
   reports any errors that would prevent proper booting.

Understanding these steps helps when performing manual configuration or 
troubleshooting automated configuration failures.

Platform-Specific Manual Steps
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. important::

   Manual configuration requires working with the SD card's boot partition. 
   Always ensure the SD card is properly unmounted from your target hardware 
   before modifying files on a host PC.

.. note::

   If the required boot files are missing from your Kuiper image, you can 
   install them using the ADI package repository. See the :doc:`Repositories 
   <repositories>` section for detailed instructions on installing 
   architecture-specific boot packages.

AMD/Xilinx Platforms
+++++++++++++++++++++

**For Zynq projects** (ZedBoard, ZC702, ZC706, etc.), copy these files to 
the root of the BOOT FAT32 partition:

1. `<target>/BOOT.BIN` - First stage bootloader with FPGA bitstream
2. `<target>/<specific_folder>/devicetree.dtb` - Device tree for your 
   specific project
3. `zynq-common/uImage` - Kernel image for Zynq platforms
4. `zynq-common/uEnv.txt` - U-Boot environment configuration

**For ZynqMP projects** (ZCU102, ADRV9009-ZU11EG, etc.), copy these files 
to the root of the BOOT FAT32 partition:

1. `<target>/BOOT.BIN` - First stage bootloader with FPGA bitstream
2. `<target>/<specific_folder>/system.dtb` - Device tree for your specific 
   project
3. `zynqmp-common/Image` - Kernel image for ZynqMP platforms
4. `zynqmp-common/uEnv.txt` - U-Boot environment configuration

**For Versal projects** (VCK190, VPK180, etc.), copy these files to the 
root of the BOOT FAT32 partition:

1. `<target>/BOOT.BIN` - Platform Loader and Manager (PLM) and boot 
   components
2. `<target>/<specific_folder>/system.dtb` - Device tree for your specific 
   project
3. `<target>/boot.scr` - U-Boot script for Versal boot sequence
4. `versal-common/Image` - Kernel image for Versal platforms

Intel/Altera Platforms
+++++++++++++++++++++++

**For Arria10 SoC projects**, copy these files to the root of the BOOT 
FAT32 partition:

1. `<target>/fit_spl_fpga.itb` - FPGA configuration and SPL image
2. `<target>/socfpga_arria10_socdk_sdmmc.dtb` - Device tree
3. `<target>/u-boot.img` - U-Boot proper
4. `socfpga_arria10_common/zImage` - Kernel image
5. Create an `extlinux` folder and copy `socfpga_arria10_common/extlinux.conf` 
   into it

Then write the preloader:

.. code-block:: bash

   # Write preloader to the bootloader partition (replace mmcblkXp3 with your actual device)
   sudo dd if=<target>/fit_spl_fpga.itb of=/dev/mmcblk0p3 oflag=sync status=progress

**For Cyclone5 projects** (DE10-Nano, Cyclone V SoC Kit, etc.), copy these 
files to the root of the BOOT FAT32 partition:

1. `<target>/soc_system.rbf` - FPGA bitstream
2. `<target>/socfpga.dtb` - Device tree
3. `<target>/u-boot.scr` - U-Boot script
4. `<target>/u-boot-with-spl.sfp` - SPL and U-Boot combined
5. `socfpga_cyclone5_common/zImage` - Kernel image
6. Create an `extlinux` folder and copy 
   `socfpga_cyclone5_common/extlinux.conf` into it

Then write the preloader:

.. code-block:: bash

   # Write preloader to bootloader partition (replace mmcblkXp3 with your actual device)
   sudo dd if=<target>/u-boot-with-spl.sfp of=/dev/mmcblk0p3 oflag=sync status=progress

Finding the Correct Partition for Preloader
+++++++++++++++++++++++++++++++++++++++++++

For Intel platforms, you need to write the preloader to the correct 
partition. To identify it:

.. code-block:: bash

   # Find your SD card device
   lsblk

Example output on PC:

.. code-block:: text

   NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
   sdb      8:16   1  29.7G  0 disk 
   ├─sdb1   8:17   1   256M  0 part /media/user/BOOT
   ├─sdb2   8:18   1  29.2G  0 part /media/user/rootfs
   └─sdb3   8:19   1     4M  0 part 

In this case, `/dev/sdb3` is the 4MB bootloader partition.

Example output on target board:

.. code-block:: text

   NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
   mmcblk0     179:0    0 29.7G  0 disk 
   ├─mmcblk0p1 179:1    0  256M  0 part /mnt/BOOT
   ├─mmcblk0p2 179:2    0 29.2G  0 part 
   └─mmcblk0p3 179:3    0    4M  0 part

In this case, `/dev/mmcblk0p3` is the 4MB bootloader partition.
