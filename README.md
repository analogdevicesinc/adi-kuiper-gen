# kuiper-gen

Tool used to create Debian OS images.

## Dependencies

kuiper-gen runs on linux-based operating systems.
To use `kuiper-gen` you need Docker. The Kuiper image is built inside Docker. 
In case you don't have Docker installed or you can't build Kuiper with you current version of Docker,
follow the build steps provided on the official website: https://docs.docker.com/engine/install/ .
The version used for Docker is 24.0.6. Other versions might not work as expected.

## Getting started with building your images

To get started you need to clone this repository on your build machine.
The build machine should have Ubuntu 22.04 OS. Other distros or versions might not work as expected.
There is no support for Windows OS yet.
You can clone the repository with:

```bash
git clone --depth 1 https://github.com/analogdevicesinc/adi-kuiper-gen
```

Using `--depth 1` with `git clone` will create a shallow clone, only containing
the latest revision of the repository.

Also, be careful to clone the repository to a base path **NOT** containing spaces.
This configuration is not supported by debootstrap and will lead to `kuiper-gen` not
running.

After cloning the repository, you can move to the next step and start configuring
your build.

## Config

Upon execution, `kuiper-stages.sh` will source the file `config` in the current
working directory.  This bash shell fragment is intended to set needed
environment variables. There are variables that are set on to a default value. 
The variables that are set to 'n' do not install aditional tools and files.
If the tools are needed, the corresponding configuration variable should be set to 'y'. The 
correspondig cmake arguments, branch name or version can also be customized.

The following environment variables are supported:
   
* `TARGET_ARCHITECTURE` (Default: armhf)

   The base image for Kuiper can be build on 32 bits architecture and 64 bits architecture.
   The default value corresponds to the 32 bits rootfs. For 64 bits you need to set the variable to 'arm64'.  

* `DEBIAN_VERSION` (Default: bookworm)

   If you want to use other version you need to modify this variable. (e.g. 'DEBIAN_VERSION=bullseye'). In this case
   you may expect missing functionalities or unsupported tools.
   
* `PRESERVE_CONTAINER` (Default: n)

   If you want to preserve the Docker container after building an image you can set this variable to 'y'. 
   This ensures that the container and the volumes attached to it will not be autoremoved.
   
* `CONTAINER_NAME` (Default: debian_<DEBIAN_VERSION>_rootfs_container)

   This is useful if you want to build multiple Kuiper images in parallel or preserve the containers.
   
* `CONFIG_DESKTOP` (Default: n)

   Selects the installation of XFCE desktop environment and X11VNC server.
   
* `CONFIG_LIBIIO` (Default: n)

   Selects the installation of Libiio.
   
* `CONFIG_LIBIIO_CMAKE_ARGS`

   The cmake build arguments of the library. A default value can be found in 'config'.
   
* `BRANCH_LIBIIO` (Default: libiio-v0)

   The branch for the library.
   
* `CONFIG_PYADI` (Default: n)
   
   Selects the installation of Pyadi library.
   
* `BRANCH_PYADI` (Default: main)
   
   The branch for the library.
   
* `CONFIG_LIBM2K` (Default: n)
   
   Selects the installation of Libm2k.

* `CONFIG_LIBM2K_CMAKE_ARGS`

   The cmake build arguments of the library. A default value can be found in 'config'.

* `BRANCH_LIBM2K` (Default: master)

   The branch for the library.
 
* `CONFIG_LIBAD9166` (Default: n)

   Selects the installation of Libad9166.
 
* `CONFIG_LIBAD9166_CMAKE_ARGS`

   The cmake build arguments of the library. A default value can be found in 'config'.

* `BRANCH_LIBAD9166` (Default: libad9166-iio-v0)

   The branch for the library.
 
* `CONFIG_LIBAD9361` (Default: n)

   Selects the installation of Libad9361.  

* `CONFIG_LIBAD9361_CMAKE_ARGS`

   The cmake build arguments of the library. A default value can be found in 'config'.

* `BRANCH_LIBAD9361` (Default: libad9361-iio-v0)

   The branch for the library.
 
* `CONFIG_IIO_OSCILLOSCOPE` (Default: n)

   Selects the installation of IIO Oscilloscope.
 
* `CONFIG_IIO_OSCILLOSCOPE_CMAKE_ARGS`

   The cmake build arguments of the library. A default value can be found in 'config'.
 
* `BRANCH_IIO_OSCILLOSCOPE` (Default: main)

   The branch for the library.

* `CONFIG_IIO_FM_RADIO` (Default: n)

   Selects the installation of IIO FM Radio.
 
* `BRANCH_IIO_FM_RADIO` (Default: main)

   The branch for the library.
 
* `CONFIG_FRU_TOOLS` (Default: n)

   Selects the installation of Fru tools.
 
* `BRANCH_FRU_TOOLS` (Default: main)

   The branch for the library.
   
* `CONFIG_JESD_EYE_SCAN_GTK` (Default: n)

   Selects the installation of JESD Eye Scan GTK.
   
* `CONFIG_COLORIMETER` (Default: n)

   Selects the installation of Colorimeter.
 
* `BRANCH_JESD_EYE_SCAN_GTK` (Default: main)

   The branch for the library.
   
* `CONFIG_SCOPY` (Default: n)

   Selects the installation of Scopy.
   
* `CONFIG_GNURADIO` (Default: n)

   Selects the installation of Gnuradio.
   
* `CONFIG_GRM2K` (Default: n)
   
   Selects the installation of Grm2k.

* `CONFIG_GRM2K_CMAKE_ARGS`

   The cmake build arguments of the library. A default value can be found in 'config'.

* `BRANCH_GRM2K` (Default: master)

   The branch for the library.

* `CONFIG_RPI_BOOT_FILES` (Default: n)

   Selects if the image should contain boot files for Raspberry PI.
 
* `BRANCH_RPI_BOOT_FILES` (Default: rpi-6.1.y)

   The branch for the Raspberry PI boot files.

* `USE_ADI_REPO_RPI_BOOT` (Default: y)

   Installs ADI Raspberry PI boot files package from the ADI repository, corresponding to the configured branch.
 
* `CONFIG_XILINX_INTEL_BOOT_FILES` (Default: n)

   Selects if the image should contain boot files for Xilinx and Intel.
 
* `RELEASE_XILINX_INTEL_BOOT_FILES` (Default: 2022_r2)

   The release version of the boot files for Xilinx and Intel.

* `USE_ADI_REPO_CARRIERS_BOOT` (Default: y)

   Installs carriers boot files package from the ADI repository, corresponding to the configured release.
 
* `EXPORT_SOURCES` (Default: n)

   Selects if the source files of all packages in the image should be downloaded.
 
If you want to change one of the variables you need to modify the 'config' file.
You can also set the number of processors or cores you want to use for building the image. This can be done
by adding the following line in the config file: NUM_JOBS=[number]. 
By default NUM_JOBS has the value returned by '$(nproc)'.

After the Kuiper is built, you can find the configuration file in '/' (root).
 
## Build Flow

The `build-docker.sh` script builds the base Debian image and starts a docker container. 
Inside the container runs 'kuiper-stages.sh'. This script is responsible with running all the scripts inside
the stages directory and with exporting the Kuiper image.
 
### Docker Build

Docker is used to perform the build inside a container. This partially isolates
the build from the host system, and allows using the script on non-debian based
systems (e.g. Fedora Linux). The isolation is not total due to the need to use
some kernel level services for arm emulation (binfmt) and loop devices (losetup).

To build:

```bash
sudo bash build-docker.sh
```

Your Kuiper image will be in the `kuiper-volume/` folder inside the cloned repository on you machine.
After successful build, the image and the build container are removed if `PRESERVE_CONTAINER=n`.
If needed, you can remove the build container with:

```bash
docker rm -v debian_<DEBIAN_VERSION>_rootfs_container`
```

If you choose to preserve the Docker container, you can access the Kuiper root filesystem by copying 
it from the container to your machine with this command:

```bash
CONTAINER_ID=$(docker inspect --format="{{.Id}}" debian_<DEBIAN_VERSION>_rootfs_container)
sudo docker cp $CONTAINER_ID:<TARGET_ARCH>_rootfs .
```

You need to replace <DEBIAN_VERSION> and <TARGET_ARCH> with the ones in the configuration file.

Example:

```bash
CONTAINER_ID=$(docker inspect --format="{{.Id}}" debian_bookworm_rootfs_container)
sudo docker cp $CONTAINER_ID:armhf_rootfs .
```

### Passing arguments to Docker

When the docker image is run various required command line arguments are provided.
For example the system mounts the `/dev` directory to the `/dev` directory within the docker container. 
The `--name` and `--privileged` options are already set by the script and should not be redefined.
 
## How the build process works inside Docker

The following process is used to build images:

 * Loop through the stage directory in alphanumeric order

 * Loop through each subdirectory and then run each of the install scripts it contains, in alphanumeric order.
   There are a number of different files and directories which can be used to control different parts of the 
   build process:

     - **run.sh** - a unix shell script that will run inside the Docker image.

     - **run-chroot.sh** - a unix shell script which will be run using 'chroot' inside the Kuiper image.

     - **packages-[*]** - a list of required packages to install in the Kuiper image using 
       the ```--no-install-recommends``` parameter to apt-get.

     - **packages-[*]-with-recommends** - as 'packages', except these will be installed along with the recommended packages.
       
     [*]: desktop, libiio, pyadi, iio-oscilloscope, libm2k, fru-tools, jesd-eye-scan-gtk, colorimeter.
     The packages are installed if the corresponding configuration is set to 'y'.

## Stage Anatomy

### Debian Stage Overview

The build of Kuiper is divided up into several stages for logical clarity
and modularity.  This causes some initial complexity, but it simplifies
maintenance and customization.

 - **01.bootstrap** - the primary purpose of this stage is to create a usable filesystem.
   This is accomplished largely through the use of `debootstrap` command, which creates a minimal filesystem 
   suitable for use on Debian systems. The minimal core is installed but not configured, and 
   the system will not quite boot yet.

 - **02.set-locale-and-timezone** - this stage installs packages like locales and dialog, 
   configures locale variables and sets the timezone. At this stage mandatory packages for a system are installed.

 - **03.system-users-and-autologin** - this stage creates a user with sudo rights and gives the root a password.
   The username is 'analog' and the password is 'analog'. Root has the same password.
   It also sets the hostname, ensures root autologin and configures root login via ssh.
 
 - **04.configure-desktop-env** - this stage installs and configures XFCE desktop enviroment with automatic
   login for the 'analog' user. It also installs and configures X11VNC server.

 - **05.adi-tools** - this stage installs the following ADI tools: libiio, pyadi, libm2k, libad9361, libad9166,
   iio-oscilloscope, iio-fm-radio, fru_tools, jesd-eye-scan-gtk, colorimeter, Scopy, Gnuradio and gr-m2k based on settings from config. 
   A file with all the tools installed, their branches and SHAs is created in the same stage.

 - **06.boot-partition** - this stage adds the Intel, Xilinx and Raspberry Pi boot binaries that will be in the 
   BOOT partition. It also configures files so that the image is bootable on RPI by default.

 - **07.export-stage** - this stage downloads sources for the ADI tools, debootstrap command 
   and all packages installed in Kuiper. The sources can be found in `kuiper-volume/sources` inside the cloned repository on you machine. 
   This stage installs the 'extend-rootfs' script that extends the rootfs partition to the dimension of the SD 
   card. This is also the stage where the scripts for adi update tools are installed in the Kuiper image.
   After this stage the full Kuiper image is built and exported. It can be found in `kuiper-volume/`. 
 
## Kuiper versions

   Depending on the configuration file, the following stages and substages are included. 
   You cand also mix them to obtain a Kuiper image with exactly the tools and packages you need.

 * `Basic image` 

   This is the default version and it contains only basic packages and configuration so the system
   will boot and run properly. Any other configuration will be added on top of the basic image.
   The corresponding stages are:
   - **01.bootstrap**
   - **02.set-locale-and-timezone**
   - **03.system-users-and-autologin**
   - **05.adi-tools** - substage **13.write-git-logs**
   - **06.boot-partition** - substages **01.adi-boot-files**, **02.rpi-boot-files** (depending on 'config' file), **03.add-fstab**
   - **07.export-stage** - substages **01.extend-rootfs**, **03.export-image**
 
 * `Kuiper with desktop environment:` 

   - **04.configure-desktop-env** - substages **01.desktop-env**, **02.vnc-server**, **03.cosmetic**

 * `Kuiper with ADI tool:` 

   - **05.adi-tools** - substage **xx.install-[adi tool]**

 * `Kuiper with exported sources:` 

   - **07.export-stage** - substage **02.export-sources**

# ADI APT Repository

ADI APT repository is a collection of Debian package files that facilitates the distribution and installation 
of ADI software packages. The repository contains .deb packages with boot files for carriers and Raspberry Pi.

Advantages of using this APT repository:
   - **easy installation, removal and upgrade (apt install, apt remove, apt upgrade)**
   - **easy versioning**
   - **package manager resolves (or indicates) conflicts between packages**
   - **apt manages dependencies for packages to be installed**

Installing packages from the repository in Kuiper:
   - **sudo apt update**
   - **sudo apt install [*]**

[*]: adi-carriers-boot-2022.r2, adi-carriers-boot-main, adi-rpi-boot-5.15.y, adi-rpi-boot-6.1.

# Troubleshooting

### `binfmt_misc`

Linux is able execute binaries from other architectures, meaning that it should be
possible to make use of `kuiper-gen` on an x86_64 system, even though it will be running
ARM binaries. This requires support from the [`binfmt_misc`](https://en.wikipedia.org/wiki/Binfmt_misc)
kernel module.

You may see one of the following errors:

```
update-binfmts: warning: Couldn't load the binfmt_misc module.
```
```
W: Failure trying to run: chroot chroot "//armhf_rootfs" /bin/true
and/or
chroot: failed to run command '/bin/true': Exec format error
```

To resolve this, ensure that the following files are available (install them if necessary):

```
/lib/modules/$(uname -r)/kernel/fs/binfmt_misc.ko
/usr/bin/qemu-arm-static
```

You may also need to load the module by hand - run `modprobe binfmt_misc`.

If you are using WSL to build you may have to enable the service `sudo update-binfmts --enable`

