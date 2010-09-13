# Taken from telepathy-glib. The only change is to remove the option to install # the data files.
#
# PLEASE DO NOT MODIFY THIS CONNECTION MANAGER. Either subclass it,
# copy-and-modify (moving it to a better namespace), or make changes in the
# copy in telepathy-glib first.

VALAFLAGS += \
	--vapidir=. \
	--pkg gobject-2.0 \
	--pkg gio-2.0 \
	--pkg gee-1.0 \
	--pkg gmodule-2.0 \
	--pkg dbus-glib-1 \
	--pkg telepathy-glib \
	$(NULL)

noinst_LTLIBRARIES = libtp-test-contactlist.la

libtp_test_contactlist_la_SOURCES = \
        _gen/param-spec-struct.h \
        account.c \
        account.h \
        account-manager.c \
        account-manager.h \
        conn.c \
        conn.h \
        contact-list.c \
        contact-list.h \
        contact-list-manager.c \
        contact-list-manager.h \
	$(NULL)

libtp_test_contactlist_la_CFLAGS = $(TP_GLIB_CFLAGS)
libtp_test_contactlist_la_LIBADD = $(TP_GLIB_LIBS)

_gen/tp_test_contact_list.manager _gen/param-spec-struct.h: \
			manager-file.py $(top_srcdir)/tests/tools/manager-file.py
		$(AM_V_at)$(mkdir_p) _gen
		$(AM_V_GEN)$(PYTHON) $(top_srcdir)/tests/tools/manager-file.py \
			$(srcdir)/manager-file.py _gen

DISTCHECK_CONFIGURE_FLAGS = --enable-introspection

-include $(INTROSPECTION_MAKEFILE)
INTROSPECTION_GIRS =
INTROSPECTION_SCANNER_ARGS = --add-include-path=$(srcdir)
INTROSPECTION_COMPILER_ARGS = --includedir=$(srcdir)

tp-test-contactlist.gir: libtp-test-contactlist.la
tp_test_contactlist_gir_INCLUDES = GObject-2.0 TelepathyGLib-0.12
tp_test_contactlist_gir_CFLAGS = $(TP_GLIB_CFLAGS)
tp_test_contactlist_gir_LIBS = libtp-test-contactlist.la
tp_test_contactlist_gir_FILES = $(libtp_test_contactlist_la_SOURCES)
tp_test_contactlist_gir_NAMESPACE = TpTest
INTROSPECTION_GIRS += tp-test-contactlist.gir

tp-test-contactlist.vapi: tp-test-contactlist.gir
	$(AM_V_GEN)$(VAPIGEN) $(VALAFLAGS) --library tp-test-contactlist \
		tp-test-contactlist.gir

BUILT_SOURCES = \
    tp-test-contactlist.vapi \
    $(NULL)

CLEANFILES = \
	$(BUILT_SOURCES) \
	_gen/param-spec-struct.h \
	_gen/tp_test_contact_list.manager \
	$(INTROSPECTION_GIRS) \
	tp-test-contactlist.vapi \
	$(gir_DATA) \
	$(typelib_DATA) \
	$(NULL)

EXTRA_DIST = \
    manager-file.py \
    tp-test-contactlist.h \
    $(NULL)

clean-local:
	rm -rf _gen

-include $(top_srcdir)/git.mk