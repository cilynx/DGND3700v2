DGND3700v2=DGND3700v2_V1.1.00.26_NA
DGND3700v2_ZIP=$(DGND3700v2)_20150901.zip
DGND3700v2_URL=http://www.downloads.netgear.com/files/GPL/$(DGND3700v2_ZIP)

BUILDROOT=buildroot-4.4.2-1

HOSTCC=gcc-4.9
HOSTCXX=g++-4.9
HOSTCPP=cpp-4.9

CFLAGS_FOR_BUILD='-g -O2 -std=c89'

TEMPDIR := $(shell mktemp -du)

all: .toolchain_built

.zip_fetched:
	wget $(DGND3700v2_URL)
	touch $@

.zip_extracted: .zip_fetched
	unzip $(DGND3700v2_ZIP)
	touch $@

.toolchain_extracted: .zip_extracted
	tar xvfz uclibc-crosstools-gcc-4.4.2-1-with-ftw.tar.bz2
	touch $@

.toolchain_patched: .toolchain_extracted
	sed -i '42s/$$/ \\/' $(BUILDROOT)/package/atk/atk.mk
	touch $@

.toolchain_configured: .toolchain_patched
	mkdir $(TEMPDIR)
	mv $(BUILDROOT)/.*config* $(TEMPDIR)
	mv $(BUILDROOT)/output/dl $(TEMPDIR)
	cd $(BUILDROOT) && sudo make distclean
	mv $(TEMPDIR)/.*config* $(BUILDROOT)
	mv $(TEMPDIR)/dl $(BUILDROOT)/output/
	rmdir $(TEMPDIR)
	touch $@

.toolchain_built: .toolchain_configured
	cd $(BUILDROOT) && sudo make -j HOSTCC=$(HOSTCC) HOSTCXX=$(HOSTCXX) HOSTCPP=$(HOSTCPP) # CFLAGS_FOR_BUILD=$(CFLAGS_FOR_BUILD)
	touch $@

clean:
	rm -rf .toolchain_extracted .toolchain_patched .toolchain_built
	sudo rm -rf $(BUILDROOT)

realclean: clean
	rm -rf .zip_extracted
	rm -rf $(DGND3700v2)_src.tar.bz2 uclibc-crosstools-gcc-4.4.2-1-with-ftw.tar.bz2 README.txt

distclean: realclean
	rm -rf .zip_fetched
	rm -rf $(DGND3700v2_ZIP)
