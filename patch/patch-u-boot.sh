#!/bin/sh
set -e

git am --abort || true

git am ../patch/0001-Debug-output-for-testing-device-tree-fixups.patch
