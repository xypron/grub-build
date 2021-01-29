# Build GRUB for ARM64
.POSIX:

NPROC=${shell nproc}

MK_ARCH="${shell uname -m}"
ifeq ("aarch64", $(MK_ARCH))
	undefine CROSS_COMPILE
	export KVM=-enable-kvm -cpu host
else
	export CROSS_COMPILE=aarch64-linux-gnu-
	export KVM=-cpu cortex-a53
endif
undefine MK_ARCH

all:
	make prepare
	make build-u-boot
	make build-grub

prepare:
	test -d u-boot || git clone -v \
	https://gitlab.denx.de/u-boot/u-boot.git u-boot
	test -d grub || git clone -v \
	git://git.savannah.gnu.org/grub.git grub
	mkdir -p mnt
	mkdir -p tftp

build-u-boot:
	cd u-boot && \
		git fetch --prune && \
		git checkout master && \
		git reset --hard origin/master && \
		make qemu_arm64_defconfig && \
		make -j $(NPROC)

build-grub:
	cd grub && \
		git fetch --prune && \
		git checkout master && \
		git reset --hard origin/master && \
		../patch/patch-grub.sh
	cd grub && \
		./bootstrap
	cd grub && \
		./configure --target=aarch64 --with-platform=efi \
		CC=gcc \
		TARGET_CC=$(CROSS_COMPILE)gcc \
		TARGET_OBJCOPY=$(CROSS_COMPILE)objcopy \
		TARGET_STRIP=$(CROSS_COMPILE)strip \
		TARGET_NM=$(CROSS_COMPILE)nm \
		TARGET_RANLIB=$(CROSS_COMPILE)ranlib
	cd grub && \
		make -j $(NPROC)
	cd grub && \
		./grub-mkimage -O arm64-efi -o ../tftp/grubaa64.efi \
		--prefix= -d \
		grub-core cat chain configfile echo efinet ext2 fat fdt halt \
		help linux lsefisystab loadenv lvm minicmd normal part_msdos \
		part_gpt reboot search search_fs_file search_fs_uuid \
		search_label serial sleep test true
	
check:
	qemu-system-aarch64 -machine virt -m 1G -smp cores=2 \
	-bios u-boot/u-boot.bin $(KVM) -nographic -gdb tcp::1234 \
	-netdev user,id=eth0,tftp=tftp -device e1000,netdev=eth0 \
	-drive if=none,file=arm64.img,format=raw,id=mydisk \
	-device virtio-rng-pci \
	-device ich9-ahci,id=ahci -device ide-hd,drive=mydisk,bus=ahci.0
