.PHONY : all install check depends makedepends

all : libfreertos.a

provides conflicts :
	@echo freertos

check checkdepends depends makedepends :

options :
	@echo !strip

SOURCE_DIR := ../freertos-src/FreeRTOS/Source
DESTDIR ?= /

CFLAGS += -I. -I${SOURCE_DIR}/include
CFLAGS += -MT $@ -MD -MP -MF $@.Td 
SYSROOT := $(shell ${CC} ${CFLAGS} -print-sysroot)
MULTIOS := $(shell ${CC} ${CFLAGS} -print-multi-os-directory)

ALL_OBJECTS := $(addprefix ${SOURCE_DIR}/,croutine.o event_groups.o list.o queue.o tasks.o timers.o)

../.config :
	@echo "../.config file must be present"
	@exit 1

FreeRTOSConfig.h : ../.config
	@./generator <$^ >$@

%.o.d : FreeRTOSConfig.h ;

%.o : %.c %.o.d
	${CC} ${CFLAGS} -c -o $@ $<
	mv $@.Td $@.d

libfreertos.a : ${ALL_OBJECTS}
	${AR} -cr $@ $^

ALL_INCLUDES := $(addprefix ${SOURCE_DIR}/include/, FreeRTOS.h StackMacros.h croutine.h deprecated_definitions.h event_groups.h list.h mpu_wrappers.h portable.h projdefs.h queue.h semphr.h stdint.readme task.h timers.h) FreeRTOSConfig.h portmacro.h

install : libfreertos.a
	install -m755 -d ${DESTDIR}${SYSROOT}/lib/${MULTIOS}
	install -m644 -t ${DESTDIR}${SYSROOT}/lib/${MULTIOS} $<
	install -m755 -d ${DESTDIR}${SYSROOT}/include
	install -m644 -t ${DESTDIR}${SYSROOT}/include ${ALL_INCLUDES}

-include $(addsuffix .d, ${ALL_OBJECTS})
