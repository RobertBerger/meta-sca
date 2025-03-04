## Add ids to suppress on a recipe level
SCA_GIXY_EXTRA_SUPPRESS ?= ""
## Add ids to lead to a fatal on a recipe level
SCA_GIXY_EXTRA_FATAL ?= ""
## Default ngixn config file to pick
SCA_GIXY_NGINX_CONF ?= "/etc/nginx/nginx.conf"

inherit sca-conv-to-export
inherit sca-datamodel
inherit sca-global
inherit sca-helper

def do_sca_conv_gixy(d, cmd_output=""):
    import os
    import re
    import json
    
    package_name = d.getVar("PN")
    buildpath = d.getVar("SCA_SOURCES_DIR")

    items = []
    pattern = r"^(?P<file>.*):(?P<line>\d+):(?P<column>\d+):\s+(?P<severity>\w+):\s+(?P<message>.*)\s\[-(?P<id>.*)\]"

    severity_map = {
        "HIGH" : "error",
        "MEDIUM" : "warning",
        "LOW" : "info",
        "ERROR" : "error",
    }

    _suppress = get_suppress_entries(d)
    _findings = []

    ## Result file parsing
    if os.path.exists(d.getVar("SCA_RAW_RESULT_FILE")):
        io = {}
        with open(d.getVar("SCA_RAW_RESULT_FILE")) as i:
            try:
                io = json.load(i)
            except:
                pass
        for item in io:
            try:
                g = sca_get_model_class(d,
                                        PackageName=package_name,
                                        Tool="gixy",
                                        File=item["path"],
                                        Message="{} {}".format(item["summary"], item["reason"]),
                                        ID=item["plugin"].replace(" ", "_"),
                                        Severity=severity_map[str(item["severity"])])
                if g.GetFormattedID() in _suppress:
                    continue
                if not sca_is_in_finding_scope(d, "gixy", g.GetFormattedID()):
                    continue
                if g.Severity in sca_allowed_warning_level(d):
                    _findings.append(g)
            except Exception as e:
                bb.note(str(e))

    ## Run log parsing
    pattern = r'^.*\[nginx_parser\]\s+(?P<severity>[A-Z]+)\s+Failed to parse config\s.(?P<file>.*)":\s+(?P<msg>.*)\s+\(line:(?P<line>\d+),\s+col:(?P<col>\d+)'
    for m in re.finditer(pattern, cmd_output.replace("\t", " "), re.MULTILINE):
        try:
            g = sca_get_model_class(d,
                                    PackageName=package_name,
                                    Tool="gixy",
                                    BuildPath=buildpath,
                                    Column=m.group("col"),
                                    Line=m.group("line"),
                                    File=m.group("file"),
                                    Message=m.group("msg"),
                                    ID="ParserFailure",
                                    Severity=severity_map[m.group("severity")])
            if g.GetPlainID() in __suppress:
                continue
            if not sca_is_in_finding_scope(d, "gixy", g.GetFormattedID()):
                continue
            if g.Severity in sca_allowed_warning_level(d):
                _findings.append(g)
        except Exception as e:
            bb.note(str(e))

    sca_add_model_class_list(d, _findings)
    return sca_save_model_to_string(d)

python do_sca_gixy() {
    import os
    import subprocess
    d.setVar("SCA_EXTRA_SUPPRESS", d.getVar("SCA_GIXY_EXTRA_SUPPRESS"))
    d.setVar("SCA_EXTRA_FATAL", d.getVar("SCA_GIXY_EXTRA_FATAL"))
    d.setVar("SCA_SUPRESS_FILE", os.path.join(d.getVar("STAGING_DATADIR_NATIVE", True), "gixy-{}-suppress".format(d.getVar("SCA_MODE"))))
    d.setVar("SCA_FATAL_FILE", os.path.join(d.getVar("STAGING_DATADIR_NATIVE", True), "gixy-{}-fatal".format(d.getVar("SCA_MODE"))))

    tmp_result = os.path.join(d.getVar("T", True), "sca_raw_gixy.json")
    d.setVar("SCA_RAW_RESULT_FILE", tmp_result)
    cmd_output = ""

    ## Run
    _file = d.getVar("SCA_GIXY_NGINX_CONF")
    if os.path.isabs(_file):
        _file = _file.lstrip("/")
    
    if os.path.exists(os.path.join(d.getVar("SCA_SOURCES_DIR"), _file)):
        _args = ["gixy"]
        _args += ["--root-dir={}".format(d.getVar("SCA_SOURCES_DIR"))]
        _args += ["-f", "json"]
        _args += ["-l"]
        _args += ["-o", tmp_result]
        _args += [d.getVar("SCA_GIXY_NGINX_CONF")]
        
        try:
            cmd_output = subprocess.check_output(_args, universal_newlines=True, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            cmd_output = e.stdout or ""
    
    if not os.path.exists(tmp_result):
        import json
        with open(tmp_result, "w") as o:
            json.dump([], o)
    
    ## Create data model
    d.setVar("SCA_DATAMODEL_STORAGE", "{}/gixy.dm".format(d.getVar("T")))
    dm_output = do_sca_conv_gixy(d, cmd_output)
    with open(d.getVar("SCA_DATAMODEL_STORAGE"), "w") as o:
        o.write(dm_output)

    sca_task_aftermath(d, "gixy", get_fatal_entries(d))
}

SCA_DEPLOY_TASK = "do_sca_deploy_gixy"

python do_sca_deploy_gixy() {
    sca_conv_deploy(d, "gixy", "json")
}

addtask do_sca_gixy before do_image_complete after do_image
addtask do_sca_deploy_gixy before do_image_complete after do_sca_gixy

do_sca_gixy[nostamp] = "${@sca_force_run(d)}"
do_sca_deploy_gixy[nostamp] = "${@sca_force_run(d)}"

DEPENDS += "${SCA_STD_PYTHON_INTERPRETER}-gixy-native sca-image-gixy-rules-native"
