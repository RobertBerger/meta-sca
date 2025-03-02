SUMMARY = "Safety checks your installed dependencies for known security vulnerabilities"
DESCRIPTION = "Safety checks your installed dependencies for known security vulnerabilities"
HOMEPAGE = "https://github.com/pyupio/safety"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=558baaefeb02113f2331ea2fd536fa86"

SRC_URI += "file://safety.sca.description \
            file://safety.sca.score"

DEPENDS += "\
            ${PYTHON_PN}-click-native \
            ${PYTHON_PN}-requests-native \
            ${PYTHON_PN}-packaging-native \
            ${PYTHON_PN}-dparse-native \
            "

PYPI_PACKAGE = "safety"

FILES_${PN} += "${datadir}"

inherit pypi
inherit native

do_install_append() {
    install -d ${D}${datadir}
    install ${WORKDIR}/safety.sca.description ${D}${datadir}
    install ${WORKDIR}/safety.sca.score ${D}${datadir}
}
