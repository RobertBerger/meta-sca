SUMMARY = "scanner detecting the use of JavaScript libraries with known vulnerabilities"
HOMEPAGE = "https://github.com/RetireJS/retire.js"

SRC_URI = "git://github.com/RetireJS/retire.js.git;protocol=https;tag=${PV} \
           file://retire.sca.description \
           file://retire.sca.score"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM  = "file://git/LICENSE.md;md5=6ab42c2b3308255529a8db4ee37e13a1"

DEPENDS += "nodejs-native"

inherit native

S = "${WORKDIR}"

do_compile() {
    :
}

do_install() {
    export HOME=${WORKDIR}
    cd ${WORKDIR}
	mkdir -p ${D}${libdir}/node_modules
    npm install --prefix ${D}${prefix} -g --arch=${NPM_ARCH} --target_arch=${NPM_ARCH} --production ${BPN}@${PV}
	if [ -d ${D}${prefix}/etc ] ; then
		# This will be empty
		rmdir ${D}${prefix}/etc
	fi

    mkdir -p ${D}${datadir}

    install ${WORKDIR}/retire.sca.description ${D}${datadir}
    install ${WORKDIR}/retire.sca.score ${D}${datadir}
}

FILES_${PN} += "${datadir}"