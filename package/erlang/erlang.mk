#############################################################
#
# erlang
#
#############################################################

ERLANG_VERSION = R15B
ERLANG_SITE = http://erlang.org/download
ERLANG_SOURCE = otp_src_$(ERLANG_VERSION).tar.gz
#ERLANG_INSTALL_STAGING = YES
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
	ERL_TOP=$(@D) $(@D)/otp_build configure --xcomp-conf=$(ERLANG_XCOMP_CONF)
endef

define ERLANG_BUILD_CMDS
	ERL_TOP=$(@D) $(@D)/otp_build boot

	ERL_TOP=$(@D) $(@D)/otp_build release
endef

define ERLANG_INSTALL_TARGET_CMDS

	$(@D)/release/$(GNU_TARGET_NAME)/Install -cross -minimal $(TARGET_DIR)/usr/erlang

endef

$(eval $(call GENTARGETS))
