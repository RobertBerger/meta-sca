## Add ids to suppress on a recipe level
SCA_ANSIBLE_EXTRA_SUPPRESS ?= ""
## Add ids to lead to a fatal on a recipe level
SCA_ANSIBLE_EXTRA_FATAL ?= ""

SCA_ANSIBLE_PATH_base_prefix ?= "${SCA_SOURCES_DIR}${base_prefix}"
SCA_ANSIBLE_PATH_prefix ?= "${SCA_SOURCES_DIR}${prefix}"
SCA_ANSIBLE_PATH_exec_prefix ?= "${SCA_SOURCES_DIR}${exec_prefix}"
SCA_ANSIBLE_PATH_base_bindir ?= "${SCA_SOURCES_DIR}${base_bindir}"
SCA_ANSIBLE_PATH_base_sbindir ?= "${SCA_SOURCES_DIR}${base_sbindir}"
SCA_ANSIBLE_PATH_base_libdir ?= "${SCA_SOURCES_DIR}${base_libdir}"
SCA_ANSIBLE_PATH_nonarch_base_libdir ?= "${SCA_SOURCES_DIR}${nonarch_base_libdir}"
SCA_ANSIBLE_PATH_sysconfdir ?= "${SCA_SOURCES_DIR}${sysconfdir}"
SCA_ANSIBLE_PATH_servicedir ?= "${SCA_SOURCES_DIR}${servicedir}"
SCA_ANSIBLE_PATH_sharedstatedir ?= "${SCA_SOURCES_DIR}${sharedstatedir}"
SCA_ANSIBLE_PATH_localstatedir ?= "${SCA_SOURCES_DIR}${localstatedir}"
SCA_ANSIBLE_PATH_datadir ?= "${SCA_SOURCES_DIR}${datadir}"
SCA_ANSIBLE_PATH_infodir ?= "${SCA_SOURCES_DIR}${infordir}"
SCA_ANSIBLE_PATH_mandir ?= "${SCA_SOURCES_DIR}${mandir}"
SCA_ANSIBLE_PATH_docdir ?= "${SCA_SOURCES_DIR}${docdir}"
SCA_ANSIBLE_PATH_systemd_unitdir ?= "${SCA_SOURCES_DIR}${systemd_unitdir}"
SCA_ANSIBLE_PATH_systemd_system_unitdir ?= "${SCA_SOURCES_DIR}${systemd_system_unitdir}"
SCA_ANSIBLE_PATH_nonarch_libdir ?= "${SCA_SOURCES_DIR}${nonarch_libdir}"
SCA_ANSIBLE_PATH_systemd_user_unitdir ?= "${SCA_SOURCES_DIR}${systemd_user_unitdir}"
SCA_ANSIBLE_PATH_bindir ?= "${SCA_SOURCES_DIR}${bindir}"
SCA_ANSIBLE_PATH_sbindir ?= "${SCA_SOURCES_DIR}${sbindir}"
SCA_ANSIBLE_PATH_libdir ?= "${SCA_SOURCES_DIR}${libdir}"
SCA_ANSIBLE_PATH_libexecdir ?= "${SCA_SOURCES_DIR}${libexecdir}"
SCA_ANSIBLE_PATH_includedir ?= "${SCA_SOURCES_DIR}${includedir}"
SCA_ANSIBLE_PATH_oldincludedir ?= "${SCA_SOURCES_DIR}${oldincludedir}"
SCA_ANSIBLE_PATH_localedir ?= "${SCA_SOURCES_DIR}${localedir}"

_SCA_ANSIBLE_GLOBAL_VARS = "base_prefix prefix exec_prefix base_bindir base_sbindir \
                            base_libdir nonarch_base_libdir sysconfdir servicedir \
                            sharedstatedir localstatedir datadir infodir mandir docdir \
                            systemd_unitdir systemd_system_unitdir nonarch_libdir \
                            systemd_user_unitdir bindir sbindir libdir libexecdir \
                            includedir oldincludedir localedir"

SCA_ANSIBLE_PLAYBOOKS ?= "*.yaml"

inherit sca-conv-to-export
inherit sca-datamodel
inherit sca-global
inherit sca-helper

inherit ${@oe.utils.ifelse(d.getVar('SCA_STD_PYTHON_INTERPRETER') == 'python3', 'python3-dir', 'python-dir')}

def create_inventory(d, target_path):
    import sys
    sys.path.append(os.path.join(d.getVar("STAGING_DIR_NATIVE"), d.getVar("PYTHON_SITEPACKAGES_DIR")[1:]))
    import yaml
    inv = {
        "all": {
            "vars": {

            }
        }
    }
    for item in clean_split(d, "_SCA_ANSIBLE_GLOBAL_VARS"):
        inv["all"]["vars"][item] = d.getVar("SCA_ANSIBLE_PATH_{}".format(item))
    
    with open(target_path, "w") as out:
        yaml.dump(inv, out)

def _split_name(_in):
    import re
    m = re.match(r"^\[(?P<severity>.*)\]\s*(?P<msg>.*)", _in)
    return (m.group("severity"), m.group("msg"))

def _get_clean_name(_in):
    import string
    res = ""
    for i in _in:
        if i in string.ascii_letters or i in string.digits:
            res += i
    return res.lower()

def _get_finding_id(d, pb_key, tk_node, item):
    res = [_get_clean_name(pb_key["name"])]
    _, msg = _split_name(tk_node["name"])
    res.append(_get_clean_name(msg))
    return ".".join(res)

def _get_finding_filename(d, pb_key, tk_node, item):
    return item["path"]

def _get_finding_message(d, pb_key, tk_node, item):
    res = []
    for k,v in item["diff"]["after"].items():
        if k == "path":
            continue
        res.append("{} should be {}".format(k,v))
    return ",".join(res)

def _get_finding_severity(d, pb_key, tk_node, item):
    sev, _ = _split_name(tk_node["name"])
    return sev

def do_sca_conv_ansible(d):
    import os
    import re
    import json
    
    package_name = d.getVar("PN")
    buildpath = d.getVar("SCA_SOURCES_DIR")

    severity_map = {
        "error" : "error",
        "warning" : "warning",
        "info": "info"
    }

    __suppress = get_suppress_entries(d)
    __excludes = sca_filter_files(d, d.getVar("SCA_SOURCES_DIR"), clean_split(d, "SCA_FILE_FILTER_EXTRA"))

    _findings = []
    if os.path.exists(d.getVar("SCA_RAW_RESULT_FILE")):
        jobj = []
        with open(d.getVar("SCA_RAW_RESULT_FILE")) as f:
            try:
                jobj = json.load(f)
            except Exception as e:
                bb.note(str(e))
        for k, v in jobj.items():
            for _play in v["plays"]:
                _pb_key = _play["play"]
                for _task in _play["tasks"]:
                    _tk_node = _task["task"]
                    try:
                        _items =  _task["hosts"]["127.0.0.1"]
                        if "results" in _items.keys():
                            _items = _items["results"]
                        for item in _items:
                            if not isinstance(item, dict):
                                continue
                            if not "changed" in item or not item["changed"]:
                                continue
                            g = sca_get_model_class(d,
                                                    PackageName=package_name,
                                                    Tool="ansible",
                                                    BuildPath=buildpath,
                                                    File=_get_finding_filename(d, _pb_key, _tk_node, item),
                                                    Message=_get_finding_message(d, _pb_key, _tk_node, item),
                                                    ID=_get_finding_id(d, _pb_key, _tk_node, item),
                                                    Severity=_get_finding_severity(d, _pb_key, _tk_node, item))
                            if g.GetFormattedID() in __suppress:
                                continue
                            if g.File in __excludes:
                                continue
                            if not sca_is_in_finding_scope(d, "ansible", g.GetFormattedID()):
                                continue
                            if g.Severity in sca_allowed_warning_level(d):
                                _findings.append(g)
                    except Exception as e:
                        bb.note(str(e))
    sca_add_model_class_list(d, _findings)
    return sca_save_model_to_string(d)

python do_sca_ansible() {
    import os
    import json
    import glob
    import subprocess
    d.setVar("SCA_EXTRA_SUPPRESS", d.getVar("SCA_CPPCHECK_EXTRA_SUPPRESS"))
    d.setVar("SCA_EXTRA_FATAL", d.getVar("SCA_CPPCHECK_EXTRA_FATAL"))
    d.setVar("SCA_SUPRESS_FILE", os.path.join(d.getVar("STAGING_DATADIR_NATIVE", True), "ansible-{}-suppress".format(d.getVar("SCA_MODE"))))
    d.setVar("SCA_FATAL_FILE", os.path.join(d.getVar("STAGING_DATADIR_NATIVE", True), "ansible-{}-fatal".format(d.getVar("SCA_MODE"))))

    _inventory = "ansible_inv.yaml"
    create_inventory(d, _inventory)

    os.environ["ANSIBLE_STDOUT_CALLBACK"] = "json"
    os.environ["ANSIBLE_ACTION_WARNINGS"] = "False"
    os.environ["ANSIBLE_COMMAND_WARNINGS"] = "False"
    os.environ["ANSIBLE_LOCALHOST_WARNING"] = "False"
    _args = ["ansible-playbook"]
    _args += ["--check"]
    _args += ["--flush-cache"]
    _args += ["-i", _inventory]

    result_raw_file = os.path.join(d.getVar("T", True), "sca_raw_ansible.json")
    d.setVar("SCA_RAW_RESULT_FILE", result_raw_file)
    json_output = {}

    for pb_glob in clean_split(d, "SCA_ANSIBLE_PLAYBOOKS"):
        for playbook in glob.glob(os.path.join(d.getVar("STAGING_DATADIR_NATIVE"), "ansible_sec") + "/" + pb_glob):
            _t_args = _args + [playbook]
            try:
                cmd_output = subprocess.check_output(_t_args, universal_newlines=True)
            except subprocess.CalledProcessError as e:
                cmd_output = e.stdout or ""
            if cmd_output.find("{") != -1:
                cmd_output = cmd_output[cmd_output.find("{"):]
            try:
                json_output[os.path.basename(playbook)] = json.loads(cmd_output)
            except:
                pass

    with open(result_raw_file, "w") as o:
        json.dump(json_output, o)
    
    os.remove(_inventory)

    ## Create data model
    d.setVar("SCA_DATAMODEL_STORAGE", "{}/ansible.dm".format(d.getVar("T")))
    dm_output = do_sca_conv_ansible(d)
    with open(d.getVar("SCA_DATAMODEL_STORAGE"), "w") as o:
        o.write(dm_output)

    sca_task_aftermath(d, "ansible", get_fatal_entries(d))
}

SCA_DEPLOY_TASK = "do_sca_deploy_ansible"

python do_sca_deploy_ansible() {
    sca_conv_deploy(d, "ansible", "json")
}

addtask do_sca_ansible before do_image_complete after do_image
addtask do_sca_deploy_ansible before do_image_complete after do_sca_ansible

do_sca_ansible[nostamp] = "${@sca_force_run(d)}"
do_sca_deploy_ansible[nostamp] = "${@sca_force_run(d)}"

DEPENDS += "python-ansible-native ansible-sca-native ${SCA_STD_PYTHON_INTERPRETER}-pyyaml-native sca-image-ansible-rules-native"
