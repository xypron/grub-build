#!/bin/sh
set -e

git am --abort || true

git am ../patch/0001-efi-EFI-Device-Tree-Fixup-Protocol.patch
git am ../patch/0001-10_linux-support-loading-device-trees.patch

git am ../patch/0001-libgcrypt-avoid-Wsign-compare-in-rijndael-do_setkey.patch
git am ../patch/0001-libgcrypt-avoid-Wempty-body-in-rijndael-do_setkey.patch
git am ../patch/0001-mpi-avoid-Wunused-but-set-variable-in-UDIV_QRNND_PRE.patch
git am ../patch/0001-mpi-avoid-Wunused-but-set-variable-in-_gcry_mpih_div.patch

git am ../patch/0001-loader-drop-argv-argument-in-grub_initrd_load.patch
git am ../patch/0001-efi-add-definition-of-LoadFile2-protocol.patch
git am ../patch/0001-efi-implemented-LoadFile2-initrd-loading-protocol-fo.patch
git am ../patch/0001-linux-ignore-FDT-unless-we-need-to-modify-it.patch
git am ../patch/0001-loader-Move-arm64-linux-loader-to-common-code.patch
git am ../patch/0001-RISC-V-Update-image-header.patch
git am ../patch/0001-RISC-V-Use-common-linux-loader.patch

