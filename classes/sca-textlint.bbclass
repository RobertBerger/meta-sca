# Following plugins are disabled by default
# because they tend to take very long to compute
# textlint-rule-en-capitalization
SCA_TEXTLINT_RULES ?= "\
                        textlint-rule-abbr-within-parentheses \
                        textlint-rule-apostrophe \
                        textlint-rule-common-misspellings \
                        textlint-rule-date-weekday-mismatch \
                        textlint-rule-diacritics \
                        textlint-rule-en-max-word-count \
                        textlint-rule-max-comma \
                        textlint-rule-alex \
                        textlint-rule-max-number-of-lines \
                        textlint-rule-ng-word \
                        textlint-rule-no-dead-link \
                        textlint-rule-no-empty-section \
                        textlint-rule-no-exclamation-question-mark \
                        textlint-rule-no-nfd \
                        textlint-rule-no-start-duplicated-conjunction \
                        textlint-rule-no-surrogate-pair \
                        textlint-rule-no-todo \
                        textlint-rule-period-in-list-item \
                        textlint-rule-rousseau \
                        textlint-rule-stop-words \
                        textlint-rule-terminology \
                        textlint-rule-unexpanded-acronym \
                        textlint-rule-write-good \
                    "

inherit sca-conv-to-export
inherit sca-datamodel
inherit sca-global
inherit sca-helper
inherit sca-license-filter

def write_config(_base, _extra_dicts, _target):
    import os
    import json
    import copy
    obj = copy.deepcopy(_base)
    for k, v in _extra_dicts.items():
        obj["dictionaries"].append(k)
        obj["dictionaryDefinitions"].append(v)
    with open(_target, "w") as o:
        json.dump(obj, o)

def do_sca_conv_textlint(d):
    import os
    import re
    import json
    
    package_name = d.getVar("PN")
    buildpath = d.getVar("SCA_SOURCES_DIR")

    severity_map = {
        "0" : "info",
        "1" : "warning",
        "2": "warning" ## Originally this is error
    }

    _suppress = get_suppress_entries(d)
    _excludes = sca_filter_files(d, d.getVar("SCA_SOURCES_DIR"), clean_split(d, "SCA_FILE_FILTER_EXTRA"))
    _findings = []

    if os.path.exists(d.getVar("SCA_RAW_RESULT_FILE")):
        jobj = []
        with open(d.getVar("SCA_RAW_RESULT_FILE")) as f:
            try:
                jobj = json.load(f)
            except Exception as e:
                pass
        for item in jobj:
            g_files = item["filePath"]
            for msg in item["messages"]:
                try:
                    g = sca_get_model_class(d,
                                            PackageName=package_name,
                                            Tool="textlint",
                                            File=g_files,
                                            BuildPath=buildpath,
                                            Column=str(msg["column"]),
                                            Line=str(msg["line"]),
                                            Message=msg["message"],
                                            ID=msg["ruleId"],
                                            Severity=severity_map[str(msg["severity"])])
                    if g.File in _excludes:
                        continue
                    if g.GetFormattedID() in _suppress:
                        continue
                    if not sca_is_in_finding_scope(d, "textlint", g.GetFormattedID()):
                        continue
                    if g.Severity in sca_allowed_warning_level(d):
                        _findings.append(g)
                except Exception as exp:
                    bb.warn(str(exp))
    
    sca_add_model_class_list(d, _findings)
    return sca_save_model_to_string(d)

python do_sca_textlint() {
    import os
    import subprocess
    import json

    d.setVar("SCA_EXTRA_SUPPRESS", d.getVar("SCA_SHELLCHECK_EXTRA_SUPPRESS"))
    d.setVar("SCA_EXTRA_FATAL", d.getVar("SCA_SHELLCHECK_EXTRA_FATAL"))
    d.setVar("SCA_SUPRESS_FILE", os.path.join(d.getVar("STAGING_DATADIR_NATIVE"), "textlint-{}-suppress".format(d.getVar("SCA_MODE"))))
    d.setVar("SCA_FATAL_FILE", os.path.join(d.getVar("STAGING_DATADIR_NATIVE"), "textlint-{}-fatal".format(d.getVar("SCA_MODE"))))

    _config = {
        "filters": { "textlint-filter-rule-comments": True },
        "plugins": [
            "html"
        ],
        "rules": {

        }
    }

    _config_file = os.path.join(d.getVar("T"), "textlint_config.json")
    with open(_config_file, "w") as o:
        for _rule in clean_split(d, "SCA_TEXTLINT_RULES"):
            _config["rules"][_rule] = True
        json.dump(_config, o)

    result_raw_file = os.path.join(d.getVar("T"), "sca_raw_textlint.json")
    d.setVar("SCA_RAW_RESULT_FILE", result_raw_file)

    _args = ["textlint"]
    _args += ["-c", _config_file]
    _args += ["--no-color"]
    _args += ["--debug"]
    _args += ["-f", "json"]
    _args += ["-o", result_raw_file]
    _files = get_files_by_extention(d, d.getVar("SCA_SOURCES_DIR"), "",
                                sca_filter_files(d, d.getVar("SCA_SOURCES_DIR"), clean_split(d, "SCA_FILE_FILTER_EXTRA")))

    cmd_output = ""
    if any(_files):
        try:
            cmd_output += subprocess.check_output(_args + _files, universal_newlines=True, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            cmd_output += e.stdout or ""
        
    ## Create data model
    d.setVar("SCA_DATAMODEL_STORAGE", "{}/textlint.dm".format(d.getVar("T")))
    dm_output = do_sca_conv_textlint(d)
    with open(d.getVar("SCA_DATAMODEL_STORAGE"), "w") as o:
        o.write(dm_output)

    sca_task_aftermath(d, "textlint", get_fatal_entries(d))
}

SCA_DEPLOY_TASK = "do_sca_deploy_textlint"

python do_sca_deploy_textlint() {
    sca_conv_deploy(d, "textlint", "json")
}

addtask do_sca_textlint before do_install after do_compile
addtask do_sca_deploy_textlint before do_package after do_sca_textlint

do_sca_textlint[nostamp] = "${@sca_force_run(d)}"
do_sca_deploy_textlint[nostamp] = "${@sca_force_run(d)}"

DEPENDS += "textlint-native sca-recipe-textlint-rules-native"
