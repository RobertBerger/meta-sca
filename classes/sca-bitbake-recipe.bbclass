inherit sca-bitbake-core

addtask do_sca_bitbake after do_package_qa do_compile do_install
addtask do_sca_deploy_bitbake after do_sca_bitbake before do_package_write_rpm do_package_write_deb do_package_write_tar do_package_write_ipk

do_sca_bitbake[nostamp] = "${@sca_force_run(d)}"
do_sca_deploy_bitbake[nostamp] = "${@sca_force_run(d)}"