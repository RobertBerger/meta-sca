inherit sca-checkbashism-core
inherit sca-global

SCA_DEPLOY_TASK = "do_sca_deploy_checkbashism_recipe"

python do_sca_deploy_checkbashism_recipe() {
   sca_conv_deploy(d, "checkbashism", "txt")
}

addtask do_sca_checkbashism_core before do_install after do_compile
addtask do_sca_deploy_checkbashism_recipe before do_package after do_sca_checkbashism_core

do_sca_checkbashism_core[nostamp] = "${@sca_force_run(d)}"
do_sca_deploy_checkbashism_recipe[nostamp] = "${@sca_force_run(d)}"

DEPENDS += "sca-recipe-checkbashism-rules-native"