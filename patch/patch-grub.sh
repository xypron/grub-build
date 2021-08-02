#!/bin/sh
set -e

git am --abort || true

git am ../patch/0001-efi-device-tree-must-be-in-EfiACPIReclaimMemory.patch
git am ../patch/0001-lsefisystab-short-text-for-EFI_RT_PROPERTIES_TABLE_G.patch
git am ../patch/0001-efi-EFI-Device-Tree-Fixup-Protocol.patch
git am ../patch/0001-10_linux-support-loading-device-trees.patch

git am ../patch/0001-loader-drop-argv-argument-in-grub_initrd_load.patch
git am ../patch/0002-efi-add-definition-of-LoadFile2-protocol.patch
git am ../patch/0003-efi-implemented-LoadFile2-initrd-loading-protocol-fo.patch
git am ../patch/0004-linux-ignore-FDT-unless-we-need-to-modify-it.patch
git am ../patch/0005-loader-Move-arm64-linux-loader-to-common-code.patch
git am ../patch/0006-RISC-V-Update-image-header.patch
git am ../patch/0007-RISC-V-Use-common-linux-loader.patch
