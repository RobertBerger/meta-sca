SCA_PROSELINT_EXTRA_SUPPRESS ?= ""
SCA_PROSELINT_EXTRA_FATAL ?= ""
SCA_PROSELINT_FILE_FILTER ?= ".txt .md .rst .me"

inherit sca-conv-to-export
inherit sca-datamodel
inherit sca-global
inherit sca-helper
inherit sca-license-filter

inherit ${@oe.utils.ifelse(d.getVar('SCA_STD_PYTHON_INTERPRETER') == 'python3', 'python3native', 'pythonnative')}

DEPENDS += "${SCA_STD_PYTHON_INTERPRETER}-proselint-native"

def do_sca_conv_proselint(d):
    import os
    import re
    import json

    package_name = d.getVar("PN")
    buildpath = d.getVar("SCA_SOURCES_DIR")

    items = []
    pattern = r"^(?P<file>.*):(?P<line>\d+):(?P<column>\d+):\s+(?P<severity>\w+):\s+(?P<message>.*)\s\[-(?P<id>.*)\]"

    _suppress = get_suppress_entries(d)
    _findings = []

    if os.path.exists(d.getVar("SCA_RAW_RESULT_FILE")):
        jobj = {}
        try:
            with open(d.getVar("SCA_RAW_RESULT_FILE")) as f:
                jobj = json.load(f)
        except Exception as e:
            pass
        for _file, _vals in jobj.items():
            if "data" in _vals.keys() and "errors" in _vals["data"].keys():
                for item in _vals["data"]["errors"]:
                    try:
                        g = sca_get_model_class(d,
                                                PackageName=package_name,
                                                Tool="proselint",
                                                BuildPath=buildpath,
                                                File=_file,
                                                Column=str(item["column"]),
                                                Line=str(item["line"]),
                                                Message=item["message"],
                                                ID=item["check"],
                                                Severity=item["severity"])
                        if g.GetFormattedID() in _suppress:
                            continue
                        if not sca_is_in_finding_scope(d, "proselint", g.GetFormattedID()):
                            continue
                        if g.Severity in sca_allowed_warning_level(d):
                            _findings.append(g)
                    except Exception as exp:
                        bb.warn(str(exp))

    sca_add_model_class_list(d, _findings)
    return sca_save_model_to_string(d)

python do_sca_proselint_core() {
    import os
    import subprocess
    import json

    d.setVar("SCA_EXTRA_SUPPRESS", d.getVar("SCA_PROSELINT_EXTRA_SUPPRESS"))
    d.setVar("SCA_EXTRA_FATAL", d.getVar("SCA_PROSELINT_EXTRA_FATAL"))
    d.setVar("SCA_SUPRESS_FILE", os.path.join(d.getVar("STAGING_DATADIR_NATIVE"), "proselint-{}-suppress".format(d.getVar("SCA_MODE"))))
    d.setVar("SCA_FATAL_FILE", os.path.join(d.getVar("STAGING_DATADIR_NATIVE"), "proselint-{}-fatal".format(d.getVar("SCA_MODE"))))

    result_raw_file = os.path.join(d.getVar("T"), "sca_raw_proselint.json")
    d.setVar("SCA_RAW_RESULT_FILE", result_raw_file)

    _args = [os.path.join(d.getVar("STAGING_BINDIR_NATIVE"), "proselint")]
    _args += ["-j"]
    _files = get_files_by_extention(d, d.getVar("SCA_SOURCES_DIR"), d.getVar("SCA_PROSELINT_FILE_FILTER"),
                                sca_filter_files(d, d.getVar("SCA_SOURCES_DIR"), clean_split(d, "SCA_FILE_FILTER_EXTRA")))

    json_output = {}
    try:
        _ = subprocess.check_output(["proselint", "--clean"], universal_newlines=True)
    except subprocess.CalledProcessError as e:
        pass

    for _f in _files:
        try:
            cmd_output = subprocess.check_output(_args + [_f], universal_newlines=True, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            cmd_output = e.stdout or ""
        try:
            if not cmd_output.startswith("{"):
                cmd_output = cmd_output[cmd_output.find("{"):]
            x = json.loads(cmd_output)
            json_output[_f] = x
        except Exception as e:
            bb.warn(cmd_output)
            bb.warn(str(e))

    try:
        _ = subprocess.check_output(["proselint", "--clean"], universal_newlines=True)
    except subprocess.CalledProcessError as e:
        pass

    with open(d.getVar("SCA_RAW_RESULT_FILE"), "w") as o:
        json.dump(json_output, o)

    ## Create data model
    d.setVar("SCA_DATAMODEL_STORAGE", "{}/proselint.dm".format(d.getVar("T")))
    dm_output = do_sca_conv_proselint(d)
    with open(d.getVar("SCA_DATAMODEL_STORAGE"), "w") as o:
        o.write(dm_output)

    sca_task_aftermath(d, "proselint", get_fatal_entries(d))
}
