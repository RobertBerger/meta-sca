## Add ids to suppress on a recipe level
SCA_SPLINT_EXTRA_SUPPRESS ?= ""
## Add ids to lead to a fatal on a recipe level
SCA_SPLINT_EXTRA_FATAL ?= ""
## File extension filter list (whitespace separated)
SCA_SPLINT_FILE_FILTER ?= ".c"
## Check intensivity (1-4)
SCA_SPLINT_INTENSITY ?= "2"

inherit sca-conv-to-export
inherit sca-datamodel
inherit sca-global
inherit sca-helper

def do_sca_conv_splint(d):
    import os
    import csv
    
    package_name = d.getVar("PN")
    buildpath = d.getVar("SCA_SOURCES_DIR")

    items = []

    severity_map = {
        "1" : "error",
        "2" : "warning",
        "3" : "info"
    }

    _suppress = get_suppress_entries(d)
    _findings = []

    if os.path.exists(d.getVar("SCA_RAW_RESULT_FILE")):
        with open(d.getVar("SCA_RAW_RESULT_FILE"), "r") as f:
            reader = csv.DictReader(f)
            for row in reader:
                try:
                    g = sca_get_model_class(d,
                                            PackageName=package_name,
                                            Tool="splint",
                                            BuildPath=buildpath,
                                            File=os.path.join(d.getVar("TOPDIR"), row["File"]),
                                            Line=row["Line"],
                                            Column=row["Column"],
                                            Message=row["Warning Text"],
                                            ID=row["Flag Name"],
                                            Severity=severity_map[row["Priority"].strip()])
                    if g.GetFormattedID() in _suppress:
                        continue
                    if not sca_is_in_finding_scope(d, "splint", g.GetFormattedID()):
                        continue
                    if g.Severity in sca_allowed_warning_level(d):
                        _findings.append(g)
                except Exception as e:
                    bb.warn(str(e))
    sca_add_model_class_list(d, _findings)
    return sca_save_model_to_string(d)

def get_local_includes(path):
    import glob
    res = set()
    for g in ["*.h", "**/*.h"]:
        for i in glob.glob(os.path.join(path, g), recursive=True):
            chunks = i.split("/")
            limit = len(chunks)
            if "include" in chunks:
                limit = len(chunks) - 1 - chunks[::-1].index("include")
            for l in range(len(chunks), limit, -1):
                _incpath = os.path.dirname("/".join(chunks[:l]))
                res.add(_incpath)
    return res

python do_sca_splint() {
    import os
    import subprocess
    from multiprocessing import Pool

    d.setVar("SCA_EXTRA_SUPPRESS", d.getVar("SCA_SPLINT_EXTRA_SUPPRESS"))
    d.setVar("SCA_EXTRA_FATAL", d.getVar("SCA_SPLINT_EXTRA_FATAL"))
    d.setVar("SCA_SUPRESS_FILE", os.path.join(d.getVar("STAGING_DATADIR_NATIVE", True), "splint-{}-suppress".format(d.getVar("SCA_MODE"))))
    d.setVar("SCA_FATAL_FILE", os.path.join(d.getVar("STAGING_DATADIR_NATIVE", True), "splint-{}-fatal".format(d.getVar("SCA_MODE"))))

    _args = ["splint"]
    _args += ["-tmpdir", d.getVar("T")]
    _args += ["-nof"]
    _args += ["-linelen", "100000"]
    _args += ["bugslimit", "100000"]
    _int = d.getVar("SCA_SPLINT_INTENSITY")
    if _int == "1":
        _args += ["-weak"]
    elif _int == "2":
        _args += ["-standard"]
    elif _int == "3":
        _args += ["-checks"]
    else:
        _args += ["-strict"]
    for i in get_local_includes(d.getVar("SCA_SOURCES_DIR")):
        _args += ["-I{}".format(i)]
    for i in get_local_includes(d.getVar("STAGING_INCDIR")):
        _args += ["-I{}".format(i)]

    _files = get_files_by_extention(d, 
                                    d.getVar("SCA_SOURCES_DIR"), 
                                    clean_split(d, "SCA_SPLINT_FILE_FILTER"), 
                                    sca_filter_files(d, d.getVar("SCA_SOURCES_DIR"), clean_split(d, "SCA_FILE_FILTER_EXTRA")))

    tmp_result = os.path.join(d.getVar("T"), "sca_raw_splint.csv")
    d.setVar("SCA_RAW_RESULT_FILE", tmp_result)
    cmd_output = ["Warning,Flag Code,Flag Name,Priority,File,Line,Column,Warning Text,Additional Text"]
    
    ## Run
    for f in _files:
        _targs = _args + ["+csv", os.path.join(d.getVar("T"), "sca_raw_splint_tmp.csv")]
        try:
            subprocess.check_call(_targs + [f], universal_newlines=True, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            pass
        with open(os.path.join(d.getVar("T"), "sca_raw_splint_tmp.csv")) as i:
            cmd_output += [x for x in i.readlines()[1:] if x]
        try:
            os.remove(os.path.join(d.getVar("T"), "sca_raw_splint_tmp.csv"))
        except:
            pass
    with open(tmp_result, "w") as o:
        o.write("\n".join(cmd_output))
    
    ## Create data model
    d.setVar("SCA_DATAMODEL_STORAGE", "{}/splint.dm".format(d.getVar("T")))
    dm_output = do_sca_conv_splint(d)
    with open(d.getVar("SCA_DATAMODEL_STORAGE"), "w") as o:
        o.write(dm_output)

    sca_task_aftermath(d, "splint", get_fatal_entries(d))
}

SCA_DEPLOY_TASK = "do_sca_deploy_splint"

python do_sca_deploy_splint() {
    sca_conv_deploy(d, "splint", "csv")
}

addtask do_sca_splint before do_install after do_compile
addtask do_sca_deploy_splint after do_sca_splint before do_package

do_sca_splint[nostamp] = "${@sca_force_run(d)}"
do_sca_deploy_splint[nostamp] = "${@sca_force_run(d)}"

DEPENDS += "splint-native sca-recipe-splint-rules-native"
