#!/bin/sh
set -e

git am --abort || true

git am ../patch/0001-efi-device-tree-must-be-in-EfiACPIReclaimMemory.patch
