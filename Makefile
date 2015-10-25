include lib.mk

all : libfreertos.a

provides conflicts :
	@echo freertos

options :
	@echo !strip

SOURCE_DIR := ../freertos-src/FreeRTOS/Source

CFLAGS += -I. -I${SOURCE_DIR}/include
SYSROOT := $(shell ${CC} ${CFLAGS} -print-sysroot)
MULTIOS := $(shell ${CC} ${CFLAGS} -print-multi-os-directory)

ALL_OBJECTS := $(addprefix ${SOURCE_DIR}/,croutine.o event_groups.o list.o queue.o tasks.o timers.o)
ALL_DEPS := $(patsubst %.o,%.d,${ALL_OBJECTS})

../.config :
	@echo "../.config file must be present" 1>&2
	${Q} exit 1

FreeRTOSConfig.h : ../.config
	${Q} ./generator <$^ >$@

${ALL_DEPS} : FreeRTOSConfig.h

libfreertos.a : ${ALL_OBJECTS}
	${Q} ${AR} -cr $@ $^

ALL_INCLUDES := $(addprefix ${SOURCE_DIR}/include/, FreeRTOS.h StackMacros.h croutine.h deprecated_definitions.h event_groups.h list.h mpu_wrappers.h portable.h projdefs.h queue.h semphr.h stdint.readme task.h timers.h) FreeRTOSConfig.h portmacro.h

freertos.pc :
	${diagnostics} GEN $@
	@echo "Name: freertos" >$@
	@echo "Cflags: -I${SYSROOT}/include/freertos" >>$@
	@echo "Libs: -lfreertos" >>$@

install : libfreertos.a ${ALL_INCLUDES} freertos.pc
	${Q} ${INSTALL} -m755 -d ${DESTDIR}${SYSROOT}/lib/${MULTIOS}
	${Q} ${INSTALL} -m644 -t ${DESTDIR}${SYSROOT}/lib/${MULTIOS} libfreertos.a
	${Q} ${INSTALL} -m755 -d ${DESTDIR}${SYSROOT}/include/freertos
	${Q} ${INSTALL} -m644 -t ${DESTDIR}${SYSROOT}/include/freertos ${ALL_INCLUDES}
	${Q} ${INSTALL} -m755 -d ${DESTDIR}usr/share/pkgconfig
	${Q} ${INSTALL} -m644 -t ${DESTDIR}usr/share/pkgconfig freertos.pc

-include ${ALL_DEPS}
