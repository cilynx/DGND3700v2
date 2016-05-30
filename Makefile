DGND3700v2=DGND3700v2_V1.1.00.26_NA
DGND3700v2_ZIP=$(DGND3700v2)_20150901.zip
DGND3700v2_URL=http://www.downloads.netgear.com/files/GPL/$(DGND3700v2_ZIP)

BUILDROOT=buildroot-4.4.2-1

all: .dgnd3700v2_source

.deps_installed:
	sudo aptitude install unzip bison flex build-essential libncurses5-dev gettext zlib1g-dev zip
	touch $@

.zip_fetched: .deps_installed
	wget $(DGND3700v2_URL)
	touch $@

.zip_extracted: .zip_fetched
	unzip $(DGND3700v2_ZIP)
	touch $@

.toolchain_extracted: .zip_extracted
	tar xvfz uclibc-crosstools-gcc-4.4.2-1-with-ftw.tar.bz2
	touch $@

.toolchain_built: .toolchain_extracted
	cd $(BUILDROOT) && sudo make 
	sudo ln -s /opt/toolchains/uclibc-crosstools-gcc-4.4.2-1-with-ftw /opt/toolchains/uclibc-crosstools-gcc-4.4.2-1
	touch $@

.dgnd3700v2_extracted: .toolchain_built
	tar xvfj $(DGND3700v2)_src.tar.bz2
	sed -i 's/.\/\$$(FLEX)/flex/' $(DGND3700v2)_src_bak/Source/apps/flex-2.5.4/Makefile
	sed -i '215s/$$/)/' $(DGND3700v2)_src_bak/Source/apps/flex-2.5.4/Makefile
	sed -i 's/\/usr\/lib/..\/..\/..\/target\/lib/' $(DGND3700v2)_src_bak/Source/apps/ppp-2.4.1.pppoe4.orig/pppd/Makefile.linux
	touch $@

.dgnd3700v2_kernel: .dgnd3700v2_extracted
	cd $(DGND3700v2)_src_bak && sudo make kernel
	touch $@

.dgnd3700v2_source: .dgnd3700v2_kernel
	cd $(DGND3700v2)_src_bak && sudo make source SHELL=/bin/bash
	touch $@

clean:
	rm -rf .dgnd3700v2_extracted .dgnd3700v2_kernel .dgnd3700v2_source
	sudo rm -rf $(DGND3700v2)_src_bak

realclean: clean
	rm -rf .zip_extracted
	rm -rf $(DGND3700v2)_src.tar.bz2 uclibc-crosstools-gcc-4.4.2-1-with-ftw.tar.bz2 README.txt
	rm -rf .toolchain_extracted .toolchain_built
	sudo rm -rf $(BUILDROOT)

distclean: realclean
	rm -rf .zip_fetched
	rm -rf $(DGND3700v2_ZIP)
