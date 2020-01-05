SUMMARY = "A python documentation linter which checks that the docstring description matches the definition"
DESCRIPTION = "A python documentation linter which checks that the docstring description matches the definition"
HOMEPAGE = "https://github.com/terrencepreilly/darglint"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=909f5d1d9b02b61f9a881c944b0ec36a"

PYPI_PACKAGE = "darglint"

FILES_${PN} += "${datadir}"
SRC_URI += "git://github.com/terrencepreilly/darglint.git;protocol=https;tag=v${PV} \
            file://darglint.sca.description"

S = "${WORKDIR}/git"

inherit native
inherit sca-sanity
inherit setuptools3

do_install_append() {
    install -d ${D}${datadir}
    install ${WORKDIR}/darglint.sca.description ${D}${datadir}
}

SRC_URI[md5sum] = "6bece9ce12a7461266ecc1908da8d492"
SRC_URI[sha256sum] = "689de29ae747642ab230c6d37be2b969bf75663176658851f456619aacf27492"
