#!/bin/sh
set -e

git am --abort || true

git checkout build
git reset --hard origin/master

git am ../patch/0001-mpi-avoid-Wunused-but-set-variable-in-UDIV_QRNND_PRE.patch
git am ../patch/0001-mpi-avoid-Wunused-but-set-variable-in-_gcry_mpih_div.patch

git am ../patch/0001-efi-move-MS-DOS-stub-out-of-generic-PE-header-defini.patch

# git am ../patch/0001-loader-drop-argv-argument-in-grub_initrd_load.patch
git am ../patch/0001-efi-add-definition-of-LoadFile2-protocol.patch
git am ../patch/0001-efi-implemented-LoadFile2-initrd-loading-protocol-fo.patch
git am ../patch/0001-linux-ignore-FDT-unless-we-need-to-modify-it.patch
git am ../patch/0001-loader-Move-arm64-linux-loader-to-common-code.patch
git am ../patch/0001-RISC-V-Update-image-header.patch
git am ../patch/0001-RISC-V-Use-common-linux-loader.patch

# merged in master but after 2.06
# git am ../patch/0001-efinet-correct-closing-of-SNP-protocol.patch
# git am ../patch/0001-efi-library-function-grub_efi_close_protocol.patch

git am ../patch/0001-efi-EFI-Device-Tree-Fixup-Protocol.patch
git am ../patch/0001-10_linux-support-loading-device-trees.patch
