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
	test -d u-boot || echo git clone -v \
	https://gitlab.denx.de/u-boot/u-boot.git u-boot
	test -d grub || echo git clone -v \
	git://git.savannah.gnu.org/grub.git grub
	mkdir -p mnt
	mkdir -p tftp

build-u-boot:
	cd u-boot && \
		echo git fetch --prune && \
		echo git checkout master && \
		echo git reset --hard origin/master && \
		make qemu_arm64_defconfig && \
		make -j $(NPROC)

build-grub:
	cd grub && \
		echo git fetch --prune && \
		echo git checkout master && \
		echo git reset --hard origin/master && \
		../patches/series.sh
	cd grub && \
		./bootstrap
	cd grub && \
		./configure --target=arm64 --with-platform=efi \
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
		--prefix= --sbat ../sbat.csv -d \
		grub-core cat chain configfile echo efinet ext2 fat fdt \
		efifwsetup halt help linux lsefisystab loadenv lvm minicmd \
		net normal part_msdos part_gpt reboot search search_fs_file \
		search_fs_uuid search_label serial sleep test tftp true

configure:
	cd grub && \
		./configure --target=aarch64 --with-platform=efi \
		CC=gcc \
		TARGET_CC=$(CROSS_COMPILE)gcc \
		TARGET_OBJCOPY=$(CROSS_COMPILE)objcopy \
		TARGET_STRIP=$(CROSS_COMPILE)strip \
		TARGET_NM=$(CROSS_COMPILE)nm \
		TARGET_RANLIB=$(CROSS_COMPILE)ranlib
rebuild:
	cd grub && \
		make -j $(NPROC)
	cd grub && \
		./grub-mkimage -O arm64-efi -o ../tftp/grubaa64.efi \
		--prefix= --sbat ../sbat.csv -d grub-core \
		all_video boot btrfs cat chain configfile echo efifwsetup \
		efinet ext2 fat font gettext gfxmenu gfxterm \
		gfxterm_background gzio halt help hfsplus iso9660 jpeg \
		keystatus loadenv loopback linux ls lsefi lsefimmap \
		lsefisystab lssal memdisk minicmd normal ntfs part_apple \
		part_msdos part_gpt password_pbkdf2 png probe reboot regexp \
		search search_fs_uuid search_fs_file search_label sleep \
		smbios squash4 test true video xfs zfs zfscrypt zfsinfo
	
.PHONY: image
image:
	rm -rf mnt
	mkdir -p mnt/EFI/boot/
	mkdir -p mnt/boot
	cp vmlinuz mnt/boot/
	cp initrd.img mnt/boot/
	cp tftp/grubriscv64.efi mnt/EFI/boot/bootriscv64.EFI
	cp grub.cfg mnt/EFI/boot/
	virt-make-fs --partition=gpt --size=256M --type=vfat mnt riscv64.img

check:
	qemu-system-aarch64 -machine virt -m 1G -smp cores=2 \
	-bios u-boot/u-boot.bin $(KVM) -nographic -gdb tcp::1234 \
	-device virtio-rng-pci \
	-net nic,model=virtio -net user,tftp=tftp \
	-drive file=image.img,format=raw,if=none,id=NVME1 \
	-device nvme,drive=NVME1,serial=nvme-1

sct:
	qemu-system-aarch64 -machine virt -m 1G -smp cores=2 \
	-bios opensbi/build/platform/generic/firmware/fw_jump.bin \
	-kernel u-boot/u-boot.bin -gdb tcp::1234 -nographic \
	-device virtio-rng-pci \
	-net nic,model=virtio -net user,tftp=tftp \
	-drive file=sct-riscv64.img,format=raw,if=none,id=NVME2 \
	-device nvme,drive=NVME2,serial=nvme-2

mount:
	mkdir -p mnt
	sudo mount riscv64.img mnt -o offset=$$((34*512))

umount:
	sudo umount mnt
