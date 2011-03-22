VALAFLAGS += \
	--library=tracker-test \
	--header=tracker-test.h \
	--vapidir=$(top_srcdir)/folks \
	--vapidir=$(top_srcdir)/backends/tracker/lib \
	--vapidir=. \
	--pkg gobject-2.0 \
	--pkg gio-2.0 \
	--pkg gee-1.0 \
	--pkg folks \
	--pkg tracker-sparql-0.10 \
	--pkg folks-tracker \
	$(NULL)

noinst_LTLIBRARIES = libtracker-test.la

libtracker_test_la_SOURCES = \
	backend.vala \
	$(NULL)

libtracker_test_la_CFLAGS = \
	$(GLIB_CFLAGS) \
	$(GEE_CFLAGS) \
	$(TRACKER_SPARQL_CFLAGS) \
	-I$(top_srcdir)/folks \
	-I$(top_srcdir)/backends/tracker/lib \
	$(NULL)

libtracker_test_la_LIBADD = \
	$(GLIB_LIBS) \
	$(GEE_LIBS) \
	$(top_builddir)/folks/libfolks.la \
	$(top_builddir)/backends/tracker/libfolks-backend-tracker.la \
	$(NULL)

MAINTAINERCLEANFILES = \
	tracker-test.vapi \
	tracker-test.h \
	$(NULL)

EXTRA_DIST = \
	tracker-test.vapi \
	tracker-test.h \
	$(NULL)

GITIGNOREFILES = \
	$(libtracker_test_la_SOURCES:.vala=.c) \
	libtracker_test_la_vala.stamp \
	$(NULL)

-include $(top_srcdir)/git.mk