SUMMARY = "Static analyzer for C/C++ based on the theory of Abstract Interpretation."

HOMEPAGE = "https://github.com/nasa-sw-vnv/ikos"
LICENSE = "NASA"

SRC_URI = "git://github.com/NASA-SW-VnV/ikos.git;protocol=https;tag=v${PV} \
           file://ikos.sca.description"

S = "${WORKDIR}/git"
B = "${S}"

LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=8e59a2e7eca93bf552009706554bb526"

EXTRA_OECMAKE += "\
                  -DBUILD_SHARED_LIBS=On \
                  -DIKOS_LINK_LLVM_DYLIB=On \
                  "

inherit native
inherit cmake
inherit sca-sanity

DEPENDS += " \
            boost-native \
            clang-native \
            gmp-native \
            python3-native \
            sqlite3-native \
            tbb-native \
            "

FILES_${PN} += "${datadir}"

do_install_append() {
    install -d ${D}${datadir}

    install ${WORKDIR}/ikos.sca.description ${D}${datadir}
}
