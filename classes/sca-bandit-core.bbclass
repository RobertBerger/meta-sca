SCA_BANDIT_EXTRA_SUPPRESS ?= ""
SCA_BANDIT_EXTRA_FATAL ?= ""

inherit sca-conv-to-export
inherit sca-datamodel
inherit sca-global
inherit sca-helper
inherit sca-license-filter

DEPENDS += "${SCA_STD_PYTHON_INTERPRETER}-bandit-native"

def do_sca_conv_bandit(d):
    import os
    import re
    import json
    
    package_name = d.getVar("PN")
    buildpath = d.getVar("SCA_SOURCES_DIR")

    severity_map = {
        "LOW" : "info",
        "MEDIUM" : "warning",
        "HIGH": "error"
    }

    _findings = []
    _suppress = get_suppress_entries(d)

    if os.path.exists(d.getVar("SCA_RAW_RESULT_FILE")):
        with open(d.getVar("SCA_RAW_RESULT_FILE")) as f:
            try:
                jobj = json.load(f)
            except Exception as e:
                bb.warn(str(e))
                pass
            if isinstance(jobj, dict):
                if "results" in jobj.keys():
                    for item in jobj["results"]:
                        try:
                            filename = item["filename"]
                            if filename.startswith("./"):
                                filename = os.path.join(buildpath, filename[2:])
                            g = sca_get_model_class(d,
                                                    PackageName=package_name,
                                                    Tool="bandit",
                                                    BuildPath=buildpath,
                                                    File=filename,
                                                    Line=str(item["line_number"]),
                                                    Message=item["issue_text"],
                                                    ID=item["test_id"],
                                                    Severity=severity_map[item["issue_severity"]])
                            if g.GetFormattedID() in _suppress:
                                continue
                            if not sca_is_in_finding_scope(d, "bandit", g.GetFormattedID()):
                                continue
                            if g.Severity in sca_allowed_warning_level(d):
                                _findings.append(g)
                        except Exception as exp:
                            bb.warn(str(exp))
    sca_add_model_class_list(d, _findings)
    return sca_save_model_to_string(d)

python do_sca_bandit_core() {
    import os
    import subprocess
    import json

    d.setVar("SCA_EXTRA_SUPPRESS", d.getVar("SCA_BANDIT_EXTRA_SUPPRESS"))
    d.setVar("SCA_EXTRA_FATAL", d.getVar("SCA_BANDIT_EXTRA_FATAL"))
    d.setVar("SCA_SUPRESS_FILE", os.path.join(d.getVar("STAGING_DATADIR_NATIVE"), "bandit-{}-suppress".format(d.getVar("SCA_MODE"))))
    d.setVar("SCA_FATAL_FILE", os.path.join(d.getVar("STAGING_DATADIR_NATIVE"), "bandit-{}-fatal".format(d.getVar("SCA_MODE"))))

    
    result_raw_file = os.path.join(d.getVar("T"), "sca_raw_bandit.json")
    d.setVar("SCA_RAW_RESULT_FILE", result_raw_file)

    _args = ["bandit"]
    _args += ["-f", "json"]
    _args += ["-o", result_raw_file]
    _files = get_files_by_extention_or_shebang(d, d.getVar("SCA_SOURCES_DIR"), d.getVar("SCA_PYTHON_SHEBANG"), ".py",
                                sca_filter_files(d, d.getVar("SCA_SOURCES_DIR"), clean_split(d, "SCA_FILE_FILTER_EXTRA")))

    with open(d.getVar("SCA_RAW_RESULT_FILE"), "w") as o:
        json.dump([], o)

    if any(_files):
        _args += _files
        cmd_output = ""
        try:
            cmd_output = subprocess.check_output(_args, universal_newlines=True, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            cmd_output = e.stdout or ""

    ## Create data model
    d.setVar("SCA_DATAMODEL_STORAGE", "{}/bandit.dm".format(d.getVar("T")))
    dm_output = do_sca_conv_bandit(d)
    with open(d.getVar("SCA_DATAMODEL_STORAGE"), "w") as o:
        o.write(dm_output)

    sca_task_aftermath(d, "bandit", get_fatal_entries(d))
}
