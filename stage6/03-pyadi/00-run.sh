#!/bin/bash -e

on_chroot << EOF

pip3 install pyadi-iio
echo "export PYTHONPATH=\"${PYTHONPATH}:/lib/python3.7/site-packages\"" >> /home/analog/.bashrc

EOF
