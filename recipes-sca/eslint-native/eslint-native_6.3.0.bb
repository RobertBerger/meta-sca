SUMMARY = "A fully pluggable tool for identifying and reporting on patterns in JavaScript"
DESCRIPTION = "A fully pluggable tool for identifying and reporting on patterns in JavaScript"

SRC_URI = "git://github.com/eslint/eslint.git;protocol=https;tag=v${PV} \
           file://configs/* \
           file://eslint.sca.description \
           file://eslint.sca.score"

LICENSE = "MIT"
LIC_FILES_CHKSUM  = "file://git/LICENSE;md5=04d32f89e7aa1677f8a860eb0b6adb83"

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
    npm install --prefix ${D}${prefix} -g --arch=${NPM_ARCH} --target_arch=${NPM_ARCH} --production eslint-config-airbnb-base@14.0.0
    npm install --prefix ${D}${prefix} -g --arch=${NPM_ARCH} --target_arch=${NPM_ARCH} --production eslint-config-google@0.13.0
    npm install --prefix ${D}${prefix} -g --arch=${NPM_ARCH} --target_arch=${NPM_ARCH} --production eslint-config-standard@14.0.1
    npm install --prefix ${D}${prefix} -g --arch=${NPM_ARCH} --target_arch=${NPM_ARCH} --save-dev eslint-plugin-html@6.0.0
    npm install --prefix ${D}${prefix} -g --arch=${NPM_ARCH} --target_arch=${NPM_ARCH} --save-dev eslint-plugin-import@2.18.2
    npm install --prefix ${D}${prefix} -g --arch=${NPM_ARCH} --target_arch=${NPM_ARCH} --save-dev eslint-plugin-node@9.1.0
    npm install --prefix ${D}${prefix} -g --arch=${NPM_ARCH} --target_arch=${NPM_ARCH} --save-dev eslint-plugin-promise@4.2.1
    npm install --prefix ${D}${prefix} -g --arch=${NPM_ARCH} --target_arch=${NPM_ARCH} --save-dev eslint-plugin-react@7.14.3
    npm install --prefix ${D}${prefix} -g --arch=${NPM_ARCH} --target_arch=${NPM_ARCH} --save-dev eslint-plugin-standard@4.0.1
    npm install --prefix ${D}${prefix} -g --arch=${NPM_ARCH} --target_arch=${NPM_ARCH} --save-dev eslint-plugin-vue@5.2.3
	if [ -d ${D}${prefix}/etc ] ; then
		# This will be empty
		rmdir ${D}${prefix}/etc
	fi

    mkdir -p ${D}/${datadir}/eslint/configs
    for _f in ${WORKDIR}/configs/*; do
        install ${_f} ${D}/${datadir}/eslint/configs/
    done

    mkdir -p ${D}${datadir}
    
    install ${WORKDIR}/eslint.sca.description ${D}${datadir}
    install ${WORKDIR}/eslint.sca.score ${D}${datadir}
}

FILES_${PN} += "${datadir}"
