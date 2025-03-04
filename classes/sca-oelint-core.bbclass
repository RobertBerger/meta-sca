SCA_OELINT_EXTRA_SUPPRESS ?= ""
SCA_OELINT_EXTRA_FATAL ?= ""

DEPENDS += "${SCA_STD_PYTHON_INTERPRETER}-oelint-adv-native"

inherit sca-conv-to-export
inherit sca-datamodel
inherit sca-helper
inherit sca-license-filter
inherit ${@oe.utils.ifelse(d.getVar('SCA_STD_PYTHON_INTERPRETER') == 'python3', 'python3native', 'pythonnative')}

def do_sca_conv_oelint(d):
    import os
    import re

    package_name = d.getVar("PN", True)
    buildpath = d.getVar("SCA_SOURCES_DIR")

    items = []
    pattern = r"^(?P<file>.*):(?P<line>\d+):(?P<severity>(warning|error|info)):(?P<id>[a-z\.]*):(?P<message>.*)$"

    severity_map = {
        "error" : "error",
        "warning" : "warning",
        "info": "info"
    }
    _findings = []
    _suppress = get_suppress_entries(d)

    if os.path.exists(d.getVar("SCA_RAW_RESULT_FILE")):
        with open(d.getVar("SCA_RAW_RESULT_FILE"), "r") as f:
            for m in re.finditer(pattern, f.read(), re.MULTILINE):
                try:
                    g = sca_get_model_class(d,
                                            PackageName=package_name,
                                            Tool="oelint",
                                            File=m.group("file"),
                                            Line=m.group("line"),
                                            Message=m.group("message"),
                                            ID=m.group("id").replace(".", "_"),
                                            Severity=severity_map[m.group("severity")])
                    if g.GetFormattedID() in _suppress:
                        continue
                    if not sca_is_in_finding_scope(d, "oelint", g.GetFormattedID()):
                        continue
                    if g.Severity in sca_allowed_warning_level(d):
                        _findings.append(g)
                except Exception as exp:
                    bb.warn(str(exp))

    sca_add_model_class_list(d, _findings)
    return sca_save_model_to_string(d)


python do_sca_oelint_core() {
    import os
    import subprocess
    import glob

    d.setVar("SCA_EXTRA_SUPPRESS", d.getVar("SCA_OELINT_EXTRA_SUPPRESS"))
    d.setVar("SCA_EXTRA_FATAL", d.getVar("SCA_OELINT_EXTRA_FATAL"))
    d.setVar("SCA_SUPRESS_FILE", os.path.join(d.getVar("STAGING_DATADIR_NATIVE"), "oelint-{}-suppress".format(d.getVar("SCA_MODE"))))
    d.setVar("SCA_FATAL_FILE", os.path.join(d.getVar("STAGING_DATADIR_NATIVE"), "oelint-{}-fatal".format(d.getVar("SCA_MODE"))))

    result_raw_file = os.path.join(d.getVar("T"), "sca_raw_oelint.txt")
    d.setVar("SCA_RAW_RESULT_FILE", result_raw_file)

    _args = ['oelint-adv']
    _args += ["--output={}".format(result_raw_file)]
    _files = [x.strip() for x in d.getVar("BBINCLUDED").split(" ") if x.strip().endswith(".bb") or x.strip().endswith(".bbappend")]

    with open(d.getVar("SCA_RAW_RESULT_FILE"), "w") as o:
        o.write("")

    if any(_files):
        _args += _files
        try:
            subprocess.check_output(_args, universal_newlines=True, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            pass

    ## Create data model
    d.setVar("SCA_DATAMODEL_STORAGE", "{}/oelint.dm".format(d.getVar("T")))
    dm_output = do_sca_conv_oelint(d)
    with open(d.getVar("SCA_DATAMODEL_STORAGE"), "w") as o:
        o.write(dm_output)

    sca_task_aftermath(d, "oelint", get_fatal_entries(d))
}
