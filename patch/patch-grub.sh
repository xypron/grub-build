#!/bin/sh
set -e

git am --abort || true

git am ../patch/0001-loader-efi-linux-print-image-start-and-size.patch
