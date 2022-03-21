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
	make build-grub

prepare:
	test -d u-boot || echo git clone -v \
	https://gitlab.denx.de/u-boot/u-boot.echo git u-boot
	test -d grub || echo git clone -v \
	git://git.savannah.gnu.org/grub.echo git grub
	test -d opensbi || echo git clone -v \
	https://github.com/riscv/opensbi.git
	mkdir -p mnt
	mkdir -p tftp

build-u-boot:
	cd u-boot && \
		echo git fetch --prune && \
		echo git checkout master && \
		echo git reset --hard origin/master && \
		make qemu-riscv64_smode_defconfig && \
		make -j $(NPROC)

build-opensbi:
	cd opensbi && \
		echo git fetch --prune && \
		echo git checkout master && \
		echo git reset --hard origin/master && \
		make PLATFORM=generic FW_PAYLOAD_PATH=../u-boot/u-boot.bin \
		  -j $(NPROC)

build-grub:
	cd grub && \
		echo git fetch --prune && \
		echo git checkout master && \
		echo git reset --hard origin/master && \
		../patches/series.sh
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
		grub-core cat chain configfile echo efinet ext2 fat fdt \
		efifwsetup halt help linux lsefisystab loadenv lvm minicmd \
		net normal part_msdos part_gpt reboot search search_fs_file \
		search_fs_uuid search_label serial sleep test tftp true

configure:
	cd grub && \
		./configure --target=riscv64 --with-platform=efi \
		--prefix=/usr \
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
		./grub-mkimage -O riscv64-efi -o ../tftp/grubriscv64.efi \
		--prefix= --sbat ../sbat.csv -d \
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
	qemu-system-riscv64 -machine virt -m 1G -smp cores=8 \
	-bios opensbi/build/platform/generic/firmware/fw_jump.bin \
	-kernel u-boot/u-boot.bin -gdb tcp::1234 -nographic \
	-netdev user,id=eth0,tftp=tftp -device e1000,netdev=eth0 \
	-device virtio-rng-pci \
	-net nic,model=virtio -net user \
	-drive file=image.img,format=raw,if=none,id=NVME2 \
	-device nvme,drive=NVME2,serial=nvme-2

sct:
	qemu-system-riscv64 -machine virt -m 1G -smp cores=8 \
	-bios opensbi/build/platform/generic/firmware/fw_jump.bin \
	-kernel u-boot/u-boot.bin -gdb tcp::1234 -nographic \
	-netdev user,id=eth0,tftp=tftp -device e1000,netdev=eth0 \
	-device virtio-rng-pci \
	-net nic,model=virtio -net user \
	-drive file=sct-riscv64.img,format=raw,if=none,id=NVME2 \
	-device nvme,drive=NVME2,serial=nvme-2

mount:
	mkdir -p mnt
	sudo mount riscv64.img mnt -o offset=$$((34*512))

umount:
	sudo umount mnt
