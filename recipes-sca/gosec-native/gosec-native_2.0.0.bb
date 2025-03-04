SUMMARY = "Golang security checker"
HOMEPAGE = "https://github.com/securego/gosec"

SRC_URI = "file://gosec.sca.description \
           file://gosec.sca.score \
           git://${GO_IMPORT};protocol=https;tag=${PV}"

GO_IMPORT = "github.com/securego/gosec"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM  = "file://src/${GO_IMPORT}/LICENSE.txt;md5=d3999b969cc50f5755737db7ce41ca2e"

inherit go
inherit native

FILES_${PN} += "${datadir}"

DEPENDS += "\
            github.com-davecgh-go-spew-native \
            github.com-golang-protobuf-native \
            github.com-kr-pretty-native \
            github.com-lib-pq-native \
            github.com-mozilla-tls-observatory-native \
            github.com-nbutton23-zxcvbn-go-native \
            github.com-onsi-ginkgo-native \
            github.com-onsi-gomega-native \
            github.com-ryanuber-go-glob-native \
            github.com-stretchr-testify-native \
            golang.org-x-net-native \
            golang.org-x-sys-native \
            golang.org-x-tools-native \
            gopkg.in-check.v1-native \
            gopkg.in-yaml.v2-native \
           "

do_install_append() {
    install -d ${D}${datadir}
    install ${WORKDIR}/gosec.sca.description ${D}${datadir}/
    install ${WORKDIR}/gosec.sca.score ${D}${datadir}/
}

