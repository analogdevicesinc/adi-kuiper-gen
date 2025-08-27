.. _quick-start:

Quick Start
============

This guide will help you build a basic Kuiper image with default settings.

----

1. Clone the Repository
-----------------------

After ensuring your build environment meets the :doc:`prerequisites <prerequisites>`, clone the repository:

.. code-block:: bash

   git clone --depth 1 https://github.com/analogdevicesinc/adi-kuiper-gen
   cd adi-kuiper-gen

----

2. Review Default Configuration
-------------------------------

The default configuration will build a basic 32-bit (armhf) Debian Bookworm image with Raspberry Pi boot files. For most users, this is sufficient to get started:

- Target architecture: ``armhf`` (32-bit)
- Debian version: ``bookworm``
- Essential boot files included: Yes
- Desktop environment: No
- ADI tools: None (can be enabled as needed)

This configuration creates what we call the "Basic Image" that includes only essential components. For details on exactly what stages and components are included in this basic build, see the Basic Image section under Kuiper Versions.

For customization options, see the :doc:`Configuration <configuration>` section.

----

3. Build the Image
------------------

Run the build script with sudo:

.. code-block:: bash

   sudo ./build-docker.sh

The build process will:

1. Create a Docker container with the necessary build environment
2. Set up a minimal Debian system
3. Configure system settings
4. Install selected components based on your configuration
5. Create a bootable image

This process typically takes 30-60 minutes depending on your system and internet speed.

----

4. Locate the Output
--------------------

After a successful build, your Kuiper image will be available as a zip file in the ``kuiper-volume/`` directory within the repository. The filename will follow the pattern ``image_YYYY-MM-DD-ADI-Kuiper-Linux-[arch].zip``.

----

Next Steps
----------

- To write the image to an SD card and boot your device, see the :doc:`Using the Generated Image <use-image>` section
- To customize your build with additional tools or settings, see the :doc:`Configuration <configuration>` section
- To understand how the build process works, see the :doc:`Build Flow <build-flow>` section
- For troubleshooting build issues, see the :doc:`Troubleshooting <troubleshooting>` section
