#!/bin/sh
set -e

git am --abort || true

git am ../patch/0001-efi_loader-only-check-size-if-EFI_DT_APPLY_FIXUPS.patch
git am ../patch/0001-efi_loader-install-UEFI-System-Partition-GUID.patch
git am ../patch/0001-efi_selftest-use-GUID-to-find-ESP-in-dtbdump.patch
