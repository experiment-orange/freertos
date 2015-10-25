# According to http://www.gnu.org/software/make/manual/html_node/Errors.html:
# > This is almost always what you want make to do, but it is not historical
# > practice; so for compatibility, you must explicitly request it.
.DELETE_ON_ERROR :

# DESTDIR is respected, when figuring out where to install the targets
DESTDIR ?= /

# Some targets in the Makefile are purely to supplement the PKGBUILD.
# They will be called in silent mode and we must make sure that no other
# output appears
ifeq ($(filter s,$(MAKEFLAGS)),s)
  diagnostics := @:
  V :=
else
  diagnostics := @echo
endif

# Normally, ${Q} should be used instead of @ before shell commands, so
# more verbose output may be enabled
ifeq ($(V),1)
  Q :=
else
  Q := @
endif

# Implicit rule to build dependency lists
%.d : %.c
	${diagnostics} DEP $<
	${Q} ${CC} ${CFLAGS} -MT $(patsubst %.d,%.o,$@) -MP -M $< >$@

# Implicit rule to create an object file
%.o : %.c
	${diagnostics} CC $<
	${Q} $(COMPILE.c) $(OUTPUT_OPTION) $<

# Tailored install command
INSTALL := install -C
