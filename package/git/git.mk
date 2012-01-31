#############################################################
#
# git
#
#############################################################
GIT_VERSION = 1.7.8.4
GIT_SOURCE = git-$(GIT_VERSION).tar.gz
GIT_SITE = http://git-core.googlecode.com/files

GIT_DEPENDENCIES += openssl curl zlib expat
GIT_CONF_ENV = ac_cv_snprintf_returns_bogus="no ac_cv_c_c99_format=yes" \
               ac_cv_fread_reads_directories=yes
#GIT_CONF_OPT = 

$(eval $(call AUTOTARGETS))
