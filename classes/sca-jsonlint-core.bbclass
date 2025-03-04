## Add ids to lead to a fatal on a recipe level
SCA_JSONLINT_EXTRA_FATAL ?= ""
## File extension filter list (whitespace separated)
SCA_JSONLINT_FILE_FILTER ?= ".json"

inherit sca-conv-to-export
inherit sca-datamodel
inherit sca-global
inherit sca-helper
inherit sca-license-filter

def do_sca_conv_jsonlint(d):
    import os
    import re
    
    package_name = d.getVar("PN")
    buildpath = d.getVar("SCA_SOURCES_DIR")

    items = []
    pattern = r"^(?P<file>.*):(?P<line>\d+):(?P<col>\d+):(?P<severity>(warning|error|info)):(?P<id>.*):(?P<message>.*)$"

    severity_map = {
        "error" : "error",
        "warning" : "warning",
        "info": "info"
    }
    _findings = []
    if os.path.exists(d.getVar("SCA_RAW_RESULT_FILE")):
        with open(d.getVar("SCA_RAW_RESULT_FILE"), "r") as f:
            for m in re.finditer(pattern, f.read(), re.MULTILINE):
                try:
                    g = sca_get_model_class(d,
                                            PackageName=package_name,
                                            Column=m.group("col"),
                                            Tool="jsonlint",
                                            BuildPath=buildpath,
                                            File=m.group("file"),
                                            Line=m.group("line"),
                                            Message=m.group("message"),
                                            ID=m.group("id"),
                                            Severity=severity_map[m.group("severity")])
                    if not sca_is_in_finding_scope(d, "jsonlint", g.GetFormattedID()):
                        continue
                    if g.Severity in sca_allowed_warning_level(d):
                        _findings.append(g)
                except Exception as exp:
                    bb.warn(str(exp))

    sca_add_model_class_list(d, _findings)
    return sca_save_model_to_string(d)

python do_sca_jsonlint_core() {
    import os
    import json

    d.setVar("SCA_EXTRA_FATAL", d.getVar("SCA_JSONLINT_EXTRA_FATAL"))
    d.setVar("SCA_FATAL_FILE", os.path.join(d.getVar("STAGING_DATADIR_NATIVE"), "jsonlint-{}-fatal".format(d.getVar("SCA_MODE"))))

    result_raw_file = os.path.join(d.getVar("T"), "sca_raw_jsonlint.txt")
    d.setVar("SCA_RAW_RESULT_FILE", result_raw_file)

    with open(result_raw_file, "w") as o:
        for _f in get_files_by_extention(d, d.getVar("SCA_SOURCES_DIR"), d.getVar("SCA_JSONLINT_FILE_FILTER").split(" "), 
                                            sca_filter_files(d, d.getVar("SCA_SOURCES_DIR"), clean_split(d, "SCA_FILE_FILTER_EXTRA"))):
            try:
                with open(_f) as i:
                    json.load(i)
            except json.JSONDecodeError as e:
                o.write("{}:{}:{}:error:jsonlint.parsererror:{}\n".format(e.doc, e.lineno, e.colno, e.msg))

    ## Create data model
    d.setVar("SCA_DATAMODEL_STORAGE", "{}/jsonlint.dm".format(d.getVar("T")))
    dm_output = do_sca_conv_jsonlint(d)
    with open(d.getVar("SCA_DATAMODEL_STORAGE"), "w") as o:
        o.write(dm_output)

    sca_task_aftermath(d, "jsonlint", get_fatal_entries(d))
}

DEPENDS += "jsonlint-sca-native"