BACKEND_NAME = "tracker"

folks_trackerdir = $(libdir)
folks_tracker_LTLIBRARIES = libfolks-tracker.la

pkgconfig_in = folks-tracker.pc.in
pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = $(pkgconfig_in:.in=)

libfolks_tracker_la_SOURCES = \
	trf-namespace.vala \
	trf-persona.vala \
	trf-persona-store.vala \
	trf-util.vala \
	$(NULL)

libfolks_tracker_la_VALAFLAGS = \
	$(AM_VALAFLAGS) \
	$(ERROR_VALAFLAGS) \
	--vapidir=. \
	--vapidir=$(top_srcdir)/folks \
	--pkg folks \
	--pkg folks-generics \
	--pkg folks-internal \
	--pkg gobject-2.0 \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--pkg tracker-sparql-$(TRACKER_SPARQL_MAJOR) \
	--includedir folks \
	--gir FolksTracker-$(API_VERSION_DOT).gir \
	--library folks-tracker \
	--vapi folks-tracker.vapi \
	-H folks/folks-tracker.h \
	$(NULL)

libfolks_tracker_la_CPPFLAGS = \
	-I$(top_srcdir) \
	-I$(top_srcdir)/folks \
	-include $(CONFIG_HEADER) \
	-include $(top_srcdir)/folks/warnings.h \
	-DPACKAGE_DATADIR=\"$(pkgdatadir)\" \
	-DBACKEND_NAME=\"$(BACKEND_NAME)\" \
	-DG_LOG_DOMAIN=\"$(BACKEND_NAME)\" \
	$(NULL)

libfolks_tracker_la_CFLAGS = \
	$(AM_CFLAGS) \
	$(ERROR_CFLAGS) \
	$(CODE_COVERAGE_CFLAGS) \
	$(GIO_CFLAGS) \
	$(GLIB_CFLAGS) \
	$(GEE_CFLAGS) \
	$(TRACKER_SPARQL_CFLAGS) \
	$(NULL)

libfolks_tracker_la_LIBADD = \
	$(AM_LIBADD) \
	$(GIO_LIBS) \
	$(GLIB_LIBS) \
	$(GEE_LIBS) \
	$(top_builddir)/folks/libfolks.la \
	$(TRACKER_SPARQL_LIBS) \
	$(NULL)

# The quoting here is unnecessary but harmless, and has the useful side-effect
# that vim quickfix mode (:make) doesn't interpret the libtool --mode=link
# command as an error message in a bizarrely named file
libfolks_tracker_la_LDFLAGS = \
	$(AM_LDFLAGS) \
	$(CODE_COVERAGE_LDFLAGS) \
	-version-info "$(LT_CURRENT)":"$(LT_REVISION)":"$(LT_AGE)" \
	-export-symbols-regex "^(TRF|trf)_.*|" \
	$(NULL)

folks_tracker_includedir = $(includedir)/folks
folks_tracker_include_HEADERS = \
	folks/folks-tracker.h \
	$(NULL)

vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = \
	folks-tracker.vapi \
	folks-tracker.deps \
	$(NULL)

##################################################################
# General
##################################################################

CLEANFILES =
MAINTAINERCLEANFILES =
EXTRA_DIST = \
	$(pkgconfig_in) \
	$(MAINTAINERCLEANFILES) \
	$(NULL)

##################################################################
# Introspection
##################################################################
-include $(INTROSPECTION_MAKEFILE)
INTROSPECTION_SCANNER_ARGS = \
	$(ERROR_INTROSPECTION_SCANNER_ARGS) \
	--add-include-path=$(srcdir) \
	--add-include-path=$(abs_top_builddir)/folks \
	--warn-all \
	$(NULL)

INTROSPECTION_COMPILER_ARGS = \
	--includedir=$(srcdir) \
	--includedir=$(abs_top_builddir)/folks \
	$(NULL)

if HAVE_INTROSPECTION
FolksTracker-$(API_VERSION_DOT).gir: libfolks-tracker.la
GIRS = FolksTracker-$(API_VERSION_DOT).gir

girdir = $(datadir)/gir-1.0
dist_gir_DATA = $(GIRS)

MAINTAINERCLEANFILES += $(dist_gir_DATA)

typelibdir = $(libdir)/girepository-1.0
nodist_typelib_DATA = $(GIRS:.gir=.typelib)

CLEANFILES += $(nodist_typelib_DATA)
endif

##################################################################
# Common
##################################################################

-include $(top_srcdir)/git.mk
