SUMMARY = "Ruleset for cppcheck"
DESCRIPTION = " Rules to configure how cppcheck is affecting the build"

SRC_URI = "file://suppress \
           file://fatal \
           file://empty-catch-block.rule \
           file://strlen-empty-str.rule"

LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${SCA_LAYERDIR}/LICENSE;md5=e926c89aceef6c1a4247d5df08f94533"

inherit native

def find_cfgs(d):
    sources=src_patches(d, True)
    ## Find all files in files-dir with ends on ".rule"
    return sorted([x for x in sources if x.endswith('.rule')])

do_configure () {
    rules="${@" ".join(find_cfgs(d))}"
    rulefile="${WORKDIR}/user-rules.xml"
    echo "<?xml version=\"1.0\"?>" > "${rulefile}"
    if [ ! -z "${rules}" ]; then
        for r in ${@" ".join(find_cfgs(d))}; do
            cat ${r} >> "${rulefile}" 
        done
    fi
}

do_install() {
    install -d "${D}${datadir}"
    install "${WORKDIR}/suppress" "${D}${datadir}/cppcheck-recipe-suppress"
    install "${WORKDIR}/fatal" "${D}${datadir}/cppcheck-recipe-fatal"
    install "${WORKDIR}/user-rules.xml" "${D}${datadir}/cppcheck-user-rules.xml"
}

FILES_${PN} = "${datadir}/**"