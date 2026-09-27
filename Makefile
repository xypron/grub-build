# Build GRUB for ARM64
.POSIX:

NPROC=${shell nproc}

MK_ARCH="${shell uname -m}"
ifeq ("riscv64", $(MK_ARCH))
	undefine CROSS_COMPILE
	export KVM=-enable-kvm -cpu host
else
	export CROSS_COMPILE=riscv64-linux-gnu-
	export KVM=-cpu cortex-a53
endif
undefine MK_ARCH

all:
	make prepare
	make build-u-boot
	make update-grub
	make build-grub

prepare:
	test -d u-boot || git clone -v \
	https://git.u-boot-project.org/u-boot/u-boot.git
	test -d grub || git clone -v \
	https://gitlab.freedesktop.org/gnu-grub/grub.git
	test -d opensbi || git clone -v \
	https://github.com/riscv/opensbi.git
	mkdir -p mnt
	mkdir -p tftp

build-opensbi:
	cd opensbi && \
		git fetch --prune && \
		git checkout master && \
		git reset --hard origin/master && \
		../patch/opensbi.sh && \
		make PLATFORM=generic \
		  -j $(NPROC)

build-u-boot:
	cd u-boot && \
		git fetch --prune && \
		git checkout main && \
		git reset --hard origin/main && \
		../patch/patch-u-boot.sh && \
		make qemu-riscv64_smode_defconfig && \
		OPENBSI=../opensbi/build  make -j $(NPROC)

update-grub:
	cd grub && \
		git fetch --prune && \
		git checkout master && \
		git reset --hard origin/master && \
		../patch/patch-grub.sh

build-grub:
	cd grub && \
		./bootstrap
	cd grub && \
		./configure --target=riscv64 --with-platform=efi \
		CC=gcc \
		TARGET_CC=$(CROSS_COMPILE)gcc \
		TARGET_OBJCOPY=$(CROSS_COMPILE)objcopy \
		TARGET_STRIP=$(CROSS_COMPILE)strip \
		TARGET_NM=$(CROSS_COMPILE)nm \
		TARGET_RANLIB=$(CROSS_COMPILE)ranlib
	cd grub && \
		make -j $(NPROC)
	cd grub && \
		./grub-mkimage -O riscv64-efi -o ../tftp/grubriscv64.efi \
		--prefix= --sbat ../sbat.csv -d \
		grub-core cat chain configfile echo efinet ext2 fat fdt halt \
		help gzio iso9660 linux lsefisystab loadenv lvm minicmd net \
		normal part_msdos part_gpt reboot search search_fs_file \
		search_fs_uuid search_label serial sleep test tftp true
	
check:
	qemu-system-riscv64 -machine virt -m 1G -smp cores=2 \
	-bios opensbi/build/platform/generic/firmware/fw_jump.bin \
	-kernel u-boot/u-boot.bin -gdb tcp::1234 -nographic \
	-netdev user,id=eth0,tftp=tftp \
	-device e1000,netdev=eth0,romfile= \
	-drive if=none,file=riscv64.img,format=raw,id=mydisk \
	-device virtio-rng-pci \
	-device ich9-ahci,id=ahci -device ide-hd,drive=mydisk,bus=ahci.0

mount:
	mkdir -p mnt
	sudo mount riscv64.img mnt -o offset=$$((34*512))

umount:
	sudo umount mnt
