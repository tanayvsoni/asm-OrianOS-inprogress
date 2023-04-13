#!/bin/bash

# dd if=../build/main.bin of=/dev/sdd bs=4M status=progress
# qemu-system-x86_64 -fddda ../vm/output.iso # -boot menu=on

qemu-system-x86_64 -fda build/main_floppy.img