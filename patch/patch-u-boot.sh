#!/bin/sh
set -e

git am --abort || true

git am ../patch/0001-efi_loader-add-Linux-magic-to-RISC-V-crt0.patch
