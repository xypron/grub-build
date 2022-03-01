#!/bin/sh
set -e

git am --abort || true

git am ../patch/0001-efi-EFI-Device-Tree-Fixup-Protocol.patch
git am ../patch/0001-10_linux-support-loading-device-trees.patch

git am ../patch/0001-loader-drop-argv-argument-in-grub_initrd_load.patch
git am ../patch/0001-efi-add-definition-of-LoadFile2-protocol.patch
git am ../patch/0001-efi-implemented-LoadFile2-initrd-loading-protocol-fo.patch
git am ../patch/0001-linux-ignore-FDT-unless-we-need-to-modify-it.patch
git am ../patch/0001-loader-Move-arm64-linux-loader-to-common-code.patch
git am ../patch/0001-RISC-V-Update-image-header.patch
git am ../patch/0001-RISC-V-Use-common-linux-loader.patch

git am ../patch/0001-commands-efi-lsefisystab-short-text-EFI_IMAGE_SECURI.patch
