#############################################################
#
# erlang
#
#############################################################

ERLANG_VERSION = R15B
ERLANG_SITE = http://erlang.org/download
ERLANG_SOURCE = otp_src_$(ERLANG_VERSION).tar.gz
ERLANG_DEPENDENCIES = ncurses
HOST_ERLANG_CONF_OPT = --disable-hipe \
                --disable-dynamic-ssl-lib --without-termcap --without-javac \
                --without-ssl

define ERLANG_SAVE_ORIG_FILE
        # After patches are applied, this file gets removed because of
        # its .orig extension. Save a copy so that we can brint it back.
        cp $(@D)/lib/tools/emacs/test.erl.orig $(@D)/lib/tools/emacs/test.erl.orig.donotdelete
endef

define ERLANG_RESTORE_ORIG_FILE
        cp $(@D)/lib/tools/emacs/test.erl.orig.donotdelete $(@D)/lib/tools/emacs/test.erl.orig
endef

HOST_ERLANG_POST_EXTRACT_HOOKS += ERLANG_SAVE_ORIG_FILE
HOST_ERLANG_POST_PATCH_HOOKS += ERLANG_RESTORE_ORIG_FILE
ERLANG_POST_EXTRACT_HOOKS += ERLANG_SAVE_ORIG_FILE
ERLANG_POST_PATCH_HOOKS += ERLANG_RESTORE_ORIG_FILE

ERLANG_XCOMP_CONF = $(ERLANG_DIR)/xcomp/erl-xcomp-buildroot.conf

ERLANG_CONFIGURE_FLAGS = --prefix=/usr \
                --exec-prefix=/usr \
                --sysconfdir=/etc \
                --program-prefix="" \
                $(DISABLE_DOCUMENTATION) \
                $(DISABLE_NLS) \
                $(DISABLE_LARGEFILE) \
                $(DISABLE_IPV6) \
                $(SHARED_STATIC_LIBS_OPTS) \
                $(QUIET) 

ERLANG_CONFIGURE_FLAGS += --disable-hipe --disable-threads --disable-smp \
		--disable-megaco-flex-scanner-lineno \
		--disable-megaco-reentrant-flex-scanner \
		--disable-dynamic-ssl-lib --without-termcap --without-javac \
		--without-ssl

TARGET_CROSS_NAME = $(shell basename $(TARGET_CROSS) | sed "s/\-$$//")
define ERLANG_CONFIGURE_CMDS
	echo "erl_xcomp_build=guess" > $(ERLANG_XCOMP_CONF)
	echo "erl_xcomp_host=$(TARGET_CROSS_NAME)" >> $(ERLANG_XCOMP_CONF)
	echo "erl_xcomp_configure_flags=$(ERLANG_CONFIGURE_FLAGS)" >> $(ERLANG_XCOMP_CONF)
	echo "CC=$(TARGET_CC)" >> $(ERLANG_XCOMP_CONF)
	echo "CFLAGS=$(TARGET_CFLAGS)" >> $(ERLANG_XCOMP_CONF)
	echo "CPP=$(TARGET_CPP)" >> $(ERLANG_XCOMP_CONF)
	echo "CXX=$(TARGET_CXX)" >> $(ERLANG_XCOMP_CONF)
	echo "LD=$(TARGET_LD)" >> $(ERLANG_XCOMP_CONF)
	echo "RANLIB=$(TARGET_RANLIB)" >> $(ERLANG_XCOMP_CONF)
	echo "AR=$(TARGET_AR)" >> $(ERLANG_XCOMP_CONF)
	echo "erl_xcomp_sysroot=$(STAGING_DIR)" >> $(ERLANG_XCOMP_CONF)
	cd $(@D) && ./otp_build configure --xcomp-conf=$(ERLANG_XCOMP_CONF)
endef

define ERLANG_BUILD_CMDS
	cd $(@D) && ./otp_build boot
	cd $(@D) && ./otp_build release
endef

define ERLANG_INSTALL_TARGET_CMDS
	-rm $(@D)/release/*/bin/runtest
	cd $(@D)/release/* && ./Install -cross -minimal /usr
	cp -a $(@D)/release/*/* $(TARGET_DIR)/usr
endef

$(eval $(call GENTARGETS))
$(eval $(call AUTOTARGETS,host))
