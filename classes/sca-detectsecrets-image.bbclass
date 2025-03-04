inherit sca-helper
inherit sca-global
inherit sca-detectsecrets-core
inherit sca-conv-to-export

SCA_DEPLOY_TASK = "do_sca_deploy_detectsecrets_image"

python do_sca_deploy_detectsecrets_image() {
    sca_conv_deploy(d, "detectsecrets", "json")
}

addtask do_sca_detectsecrets_core before do_image_complete after do_image
addtask do_sca_deploy_detectsecrets_image before do_image_complete after do_sca_detectsecrets_core

do_sca_detectsecrets_core[nostamp] = "${@sca_force_run(d)}"
do_sca_deploy_detectsecrets_image[nostamp] = "${@sca_force_run(d)}"

DEPENDS += "sca-image-detectsecrets-rules-native"
