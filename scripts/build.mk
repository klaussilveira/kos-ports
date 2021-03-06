# kos-ports ##version##
#
# scripts/build.mk
# Copyright (C) 2015 Lawrence Sebald
#

KOS_MAKEFILE ?= KOSMakefile.mk

ifneq ($(PORT_AUTOTOOLS), 1)
build-stamp: fetch validate-dist unpack copy-kos-files
	@if [ -z "${DISTFILE_DIR}" ] ; then \
		$(MAKE) -C build/${PORTNAME}-${PORTVERSION} -f ${KOS_MAKEFILE} ; \
	else \
		$(MAKE) -C build/${DISTFILE_DIR} -f ${KOS_MAKEFILE} ; \
	fi
	touch build-stamp
else
build-stamp: fetch validate-dist unpack copy-kos-files
	@if [ -z "${DISTFILE_DIR}" ] ; then \
		cd build/${PORTNAME}-${PORTVERSION} ; \
		CC=kos-cc ${CONFIGURE_DEFS} ./configure --prefix=${KOS_PORTS}/${PORTNAME}/inst --host=${AUTOTOOLS_HOST} ${CONFIGURE_ARGS} ; \
		$(MAKE) ${MAKE_TARGET} ; \
	else \
		cd build/${DISTFILE_DIR} ; \
		CC=kos-cc ${CONFIGURE_DEFS} ./configure --prefix=${KOS_PORTS}/${PORTNAME}/inst --host=${AUTOTOOLS_HOST} ${CONFIGURE_ARGS} ; \
		$(MAKE) ${MAKE_TARGET} ; \
	fi
	touch build-stamp
endif

install: setup-check version-check depends-check force-install

force-install: build-stamp $(PREINSTALL)
	@if [ ! -d "inst" ] ; then \
		mkdir inst ; \
	fi

	@cd inst ; \
	if [ ! -d "lib" ] ; then \
		mkdir lib ; \
	fi ; \
	if [ ! -d "include" ] ; then \
		mkdir include ; \
	fi

	@echo "Installing..."
	@cd build ; \
	if [ -z "${DISTFILE_DIR}" ] ; then \
		cd ${PORTNAME}-${PORTVERSION} ; \
	else \
		cd ${DISTFILE_DIR} ; \
	fi ;\
	cp ${TARGET} ../../inst/lib ; \
	for _file in ${INSTALLED_HDRS}; do \
		cp $$_file ../../inst/include ; \
	done ; \
	if [ -n "${HDR_DIRECTORY}" ] ; then \
		cp -R ${HDR_DIRECTORY}/. ../../inst/include ; \
	fi ; \
	if [ -n "${EXAMPLES_DIR}" ] ; then \
		cp -R ${EXAMPLES_DIR}/. ../../inst/examples ; \
	fi

	@if [ -n "${HDR_COMDIR}" ] ; then \
		mkdir -p ${KOS_PORTS}/include/${HDR_COMDIR} ; \
		for _file in ${KOS_PORTS}/${PORTNAME}/inst/include/*; do \
			rm -f ${KOS_PORTS}/include/${HDR_COMDIR}/`basename $$_file` ; \
			ln -s $$_file ${KOS_PORTS}/include/${HDR_COMDIR} ; \
		done ; \
	elif [ -n "${HDR_INSTDIR}" ] ; then \
		rm -f ${KOS_PORTS}/include/${HDR_INSTDIR} ; \
		ln -s ${KOS_PORTS}/${PORTNAME}/inst/include ${KOS_PORTS}/include/${HDR_INSTDIR} ; \
	else \
		rm -f ${KOS_PORTS}/include/${PORTNAME} ; \
		ln -s ${KOS_PORTS}/${PORTNAME}/inst/include ${KOS_PORTS}/include/${PORTNAME} ; \
	fi

	@rm -f ${KOS_PORTS}/lib/${TARGET}
	@ln -s ${KOS_PORTS}/${PORTNAME}/inst/lib/${TARGET} ${KOS_PORTS}/lib/${TARGET}

	@rm -f ${KOS_PORTS}/examples/${PORTNAME}

	@if [ -n "${EXAMPLES_DIR}" ] ; then \
		ln -s ${KOS_PORTS}/${PORTNAME}/inst/examples ${KOS_PORTS}/examples/${PORTNAME} ; \
	fi

	@echo "Marking ${PORTNAME} ${PORTVERSION} as installed."
	@echo "${PORTVERSION}" > "${KOS_PORTS}/lib/.kos-ports/${PORTNAME}"
