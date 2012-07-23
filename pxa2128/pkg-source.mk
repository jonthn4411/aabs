include core/pkg-source.mk

EXCLUDE_VCS=--exclude-vcs --exclude=.repo

DROID_BASE:=android-4.1.1_r1
KERNEL_BASE_COMMIT:=5e4fcd2c556e25e1b6787dcd0c97b06e29e42292
UBOOT_BASE_COMMIT:=b20a91d81fbdf9402df5425126bdee3368f10044

HEAD_MANIFEST:=head_manifest.default

.PHONY:pkgsrc
pkgsrc:
	$(log) Marvell will never need this target soon!
