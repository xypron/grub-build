#!/bin/sh
set -e

git am --abort || true

git am ../patch/0001-efi-device-tree-must-be-in-EfiACPIReclaimMemory.patch
git am ../patch/0001-lsefisystab-short-text-for-EFI_RT_PROPERTIES_TABLE_G.patch
git am ../patch/0001-efi-EFI-Device-Tree-Fixup-Protocol.patch
git am ../patch/0001-10_linux-support-loading-device-trees.patch
