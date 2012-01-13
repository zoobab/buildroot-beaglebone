#############################################################
#
# erlang
#
#############################################################

ERLANG_VERSION = R15B
ERLANG_SITE = http://erlang.org/download
ERLANG_SOURCE = otp_src_$(ERLANG_VERSION).tar.gz
#ERLANG_INSTALL_STAGING = YES
#HOST_ERLANG_AUTORECONF = YES
ERLANG_DEPENDENCIES = host-erlang
#RUBY_MAKE_ENV = $(TARGET_MAKE_ENV)
#RUBY_CONF_OPT = --disable-install-doc --disable-rpath
HOST_ERLANG_CONF_OPT = --disable-hipe \
                --disable-dynamic-ssl-lib --without-termcap --without-javac \
                --without-ssl

define ERLANG_SAVE_ORIG_FILE
        # After patches are applied, this file gets removed because of
        # its .orig extension. Save a copy so that we can brint it back.
        cp $(@D)/lib/tools/emacs/test.erl.orig $(@D)/lib/tools/emacs/test.erl.orig.donotdelete
endef

define ERLANG_RESTORE_ORIG_FILE
        # After patches are applied, this file gets removed because of
        # its .orig extension. Save a copy so that we can brint it back.
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

define ERLANG_CONFIGURE_CMDS
	cp package/erlang/erl-xcomp-buildroot.conf.in $(ERLANG_XCOMP_CONF)
	sed -i -e 's/@BUILD@/$(GNU_HOST_NAME)/' $(ERLANG_XCOMP_CONF)
	sed -i -e 's/@HOST@/$(GNU_TARGET_NAME)/' $(ERLANG_XCOMP_CONF)
	sed -i -e 's#@CONFIGURE_FLAGS@#$(ERLANG_CONFIGURE_FLAGS)#' $(ERLANG_XCOMP_CONF)
	sed -i -e 's/@CFLAGS@/$(TARGET_CFLAGS)/' $(ERLANG_XCOMP_CONF)
	cd $(@D) && ERL_TOP=$(@D) $(@D)/otp_build configure --xcomp-conf=$(ERLANG_XCOMP_CONF)
endef

define ERLANG_BUILD_CMDS
	cd $(@D) && ./otp_build boot
	cd $(@D) && ./otp_build release
endef

define ERLANG_INSTALL_TARGET_CMDS
	-rm $(@D)/release/*/bin/runtest
	cd $(@D)/release/* && ./Install -cross -minimal $(TARGET_DIR)/usr/erlang
	mkdir -p $(TARGET_DIR)/usr/erlang
	cp -a $(@D)/release/*/* $(TARGET_DIR)/usr/erlang
endef

$(eval $(call GENTARGETS))
$(eval $(call AUTOTARGETS,host))
