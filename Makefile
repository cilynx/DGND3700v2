DGND3700v2=DGND3700v2_V1.1.00.26_NA
DGND3700v2_ZIP=$(DGND3700v2)_20150901.zip
DGND3700v2_URL=http://www.downloads.netgear.com/files/GPL/$(DGND3700v2_ZIP)

DNSMASQ=dnsmasq-2.76
DNSMASQ_URL=http://www.thekelleys.org.uk/dnsmasq/$(DNSMASQ).tar.gz

DROPBEAR=dropbear-2016.73
DROPBEAR_URL=https://matt.ucc.asn.au/dropbear/releases/$(DROPBEAR).tar.bz2

BUSYBOX=busybox-1.19.0
BUSYBOX_OLD=busybox-1.13
BUSYBOX_URL=https://www.busybox.net/downloads/$(BUSYBOX).tar.bz2

BUILDROOT=buildroot-4.4.2-1

HOST=mips-linux-uclibc
TOOLPATH=/opt/toolchains/uclibc-crosstools-gcc-4.4.2-1
TOOLCHAIN=$(TOOLPATH)/usr/bin/$(HOST)

RC_APP=target/usr/sbin/rc_app
APPS=$(DGND3700v2)_src_bak/Source/apps

all: DGND3700v2.img

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
	sudo make -C $(BUILDROOT)
	sudo ln -s $(TOOLPATH)-with-ftw $(TOOLPATH)
	touch $@

.dgnd3700v2_extracted: .toolchain_built
	tar xvfj $(DGND3700v2)_src.tar.bz2
	sed -i 's/.\/\$$(FLEX)/flex/' $(APPS)/flex-2.5.4/Makefile
	sed -i '215s/$$/)/' $(APPS)/flex-2.5.4/Makefile
	sed -i 's/\/usr\/lib/..\/..\/..\/target\/lib/' $(APPS)/ppp-2.4.1.pppoe4.orig/pppd/Makefile.linux
	touch $@

.busybox_extracted: .dgnd3700v2_extracted
	wget -q -O - $(BUSYBOX_URL) | tar jxvC $(APPS)
	cp $(APPS)/$(BUSYBOX_OLD)/.config $(APPS)/$(BUSYBOX)
	make -C $(APPS)/$(BUSYBOX) defconfig
	sed -i 's/$(BUSYBOX_OLD)/$(BUSYBOX)/' $(APPS)/Makefile

.dnsmasq_extracted: .dgnd3700v2_extracted
	wget -q -O - $(DNSMASQ_URL) | tar zxvC $(APPS)
	sed -i '80iGPL += $(DNSMASQ)' $(APPS)/Makefile
	sed -i 's/usr\/local//' $(APPS)/$(DNSMASQ)/Makefile
	sed -i '29s/$$/-DNO_INOTIFY/' $(APPS)/$(DNSMASQ)/Makefile
	sed -i '26s/$$/..\/..\/target/' $(APPS)/$(DNSMASQ)/Makefile
	sed -i '94i\\tcp apps/$(DNSMASQ)/contrib/wrt/lease_update.sh target/usr/sbin/' $(APPS)/../Makefile
	sed -i '95i\\trm $(RC_APP)/rc_dnrd' $(APPS)/../Makefile
	sed -i '96i\\trm $(RC_APP)/rc_dhcpd' $(APPS)/../Makefile
	sed -i '97i\\tcp ../../rc_dnsmasq $(RC_APP)/' $(APPS)/../Makefile
	sed -i '98i\\tln -s rc_dnsmasq $(RC_APP)/rc_dnrd' $(APPS)/../Makefile
	sed -i '99i\\tln -s rc_dnsmasq $(RC_APP)/rc_dhcpd' $(APPS)/../Makefile
	touch $@

.dropbear_extracted: .dgnd3700v2_extracted
	wget -q -O - $(DROPBEAR_URL) | tar jxvC $(APPS)
	sed -i '80iGPL += $(DROPBEAR)' $(APPS)/Makefile
	touch $@

.dropbear_configured: .dropbear_extracted
	cd $(APPS)/$(DROPBEAR) && ./configure --host=$(HOST) --prefix=/ --disable-zlib CC=$(TOOLCHAIN)-cc LD=$(TOOLCHAIN)-ld 
	sed -i '88iDESTDIR=../../target' $(APPS)/$(DROPBEAR)/Makefile
	touch $@

.dgnd3700v2_kernel: .dgnd3700v2_extracted
	sudo make -C $(DGND3700v2)_src_bak kernel
	touch $@

#.dgnd3700v2_source: .dgnd3700v2_kernel .dnsmasq_extracted .dropbear_configured .busybox_extracted
.dgnd3700v2_source: .dgnd3700v2_kernel .dnsmasq_extracted 
	sudo make -C $(DGND3700v2)_src_bak source SHELL=/bin/bash
	touch $@

DGND3700v2.img: .dgnd3700v2_source
	cp $(APPS)/../image/DGND3700v2.img .

clean:
	rm -rf .dgnd3700v2_* .dropbear_* .dnsmasq_*
	sudo rm -rf $(DGND3700v2)_src_bak

realclean: clean
	rm -rf .zip_extracted
	rm -rf $(DGND3700v2)_src.tar.bz2 uclibc-crosstools-gcc-4.4.2-1-with-ftw.tar.bz2 README.txt
	rm -rf .toolchain_extracted .toolchain_built
	sudo rm -rf $(BUILDROOT)

distclean: realclean
	rm -rf .zip_fetched .deps_installed
	rm -rf $(DGND3700v2_ZIP)
