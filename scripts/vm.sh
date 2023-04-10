#!/bin/bash
# dd if=../build/main_floppy.img of=../vm/output.iso bs=4M status=progress
# qemu-system-x86_64 -fda ../vm/output.iso # -boot menu=on

qemu-system-x86_64 -fda ../build/main_floppy.img