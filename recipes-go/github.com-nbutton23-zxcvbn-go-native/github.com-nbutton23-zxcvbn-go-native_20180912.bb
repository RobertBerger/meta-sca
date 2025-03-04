SUMMARY = "zxcvbn password complexity algorithm in golang "
HOMEPAGE = "https://github.com/nbutton23/zxcvbn-go"

SRC_URI = "git://${GO_IMPORT};protocol=https"
SRCREV = "ae427f1e4c1d66674cc457c6c3822de13ccb8777"

GO_IMPORT = "github.com/nbutton23/zxcvbn-go"

LICENSE = "MIT"
LIC_FILES_CHKSUM  = "file://src/${GO_IMPORT}/LICENSE.txt;md5=558605e5a5fcd98c3b50715b84e80882"

inherit go
inherit native