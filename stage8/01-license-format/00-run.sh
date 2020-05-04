#!/bin/bash -e

install -d "${ROOTFS_DIR}/home/analog/img"

install -m 644 img/*.* "${ROOTFS_DIR}/home/analog/img"
