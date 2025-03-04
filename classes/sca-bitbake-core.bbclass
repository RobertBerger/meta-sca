## This class does parse the bitbake log for WARNING and ERROR strings
CONLOG = "${LOG_DIR}/cooker/${MACHINE}/console-latest.log"

inherit sca-conv-to-export
inherit sca-datamodel
inherit sca-global
inherit sca-helper

SCA_BITBAKE_HARDENING ?= "\
                          debug_tweaks \
                          insane_skip \
                          security_flags \
                          "

def do_sca_bitbake_hardening(d):
    package_name = d.getVar("PN")
    buildpath = d.getVar("SCA_SOURCES_DIR")
    _modules = clean_split(d, "SCA_BITBAKE_HARDENING")
    _findings = []
    _suppress = get_suppress_entries(d)

    if "debug_tweaks" in _modules:
        ## debug_tweaks in IMAGE_FEATURES isn't used in release build
        if "debug_tweaks" in clean_split(d, "IMAGE_FEATURES") and d.getVar("DEBUG_BUILD") != "1":
            g = sca_get_model_class(d,
                                    PackageName=package_name,
                                    Tool="bitbake",
                                    BuildPath=buildpath,
                                    File=d.getVar("FILE"),
                                    Message="debug_tweaks is set in IMAGE_FEATURES",
                                    ID="hardening.debug_tweaks",
                                    Severity="warning")
            if not g.GetFormattedID() in _suppress and sca_is_in_finding_scope(d, "bitbake", g.GetFormattedID()):
                if g.Severity in sca_allowed_warning_level(d):
                    _findings.append(g)
    if "insane_skip" in _modules:
        ## INSANE_SKIP isn't used anywhere
        if clean_split(d, "INSANE_SKIP_{}".format(d.getVar("PN"))):
            g = sca_get_model_class(d,
                                    PackageName=package_name,
                                    Tool="bitbake",
                                    BuildPath=buildpath,
                                    File=d.getVar("FILE"),
                                    Message="INSANE_SKIP is used in recipe",
                                    ID="hardening.insane_skip",
                                    Severity="warning")
            if not g.GetFormattedID() in _suppress and sca_is_in_finding_scope(d, "bitbake", g.GetFormattedID()):
                if g.Severity in sca_allowed_warning_level(d):
                    _findings.append(g)
    if "security_flags" in _modules:
        _files = clean_split(d, "BBINCLUDED")
        ## Check that security_flags from poky are somehow included
        if not any([x for x in _files if x.endswith("meta/conf/distro/include/security_flags.inc")]):
            g = sca_get_model_class(d,
                                    PackageName=package_name,
                                    Tool="bitbake",
                                    BuildPath=buildpath,
                                    File=d.getVar("FILE"),
                                    Message="security_flags.inc aren't used for building this recipe",
                                    ID="hardening.insane_skip",
                                    Severity="warning")
            if not g.GetFormattedID() in _suppress and sca_is_in_finding_scope(d, "bitbake", g.GetFormattedID()):
                if g.Severity in sca_allowed_warning_level(d):
                    _findings.append(g)

    sca_add_model_class_list(d, _findings)
    return sca_save_model_to_string(d)

def do_sca_conv_bitbake(d):
    import os
    import re
    
    package_name = d.getVar("PN")
    buildpath = d.getVar("SCA_SOURCES_DIR")

    pattern = r"^(?P<severity>WARNING|ERROR):\s+{}-{}-{}\s+(?P<task>.*):\s+(?P<message>.*)$".format(d.getVar("PN"), d.getVar("PKGV"), d.getVar("PR"))

    severity_map = {
        "ERROR" : "error",
        "WARNING" : "warning",
    }

    _suppress = get_suppress_entries(d)
    _excludes = sca_filter_files(d, d.getVar("SCA_SOURCES_DIR"), clean_split(d, "SCA_FILE_FILTER_EXTRA"))

    _findings = []
    if os.path.exists(d.getVar("SCA_RAW_RESULT_FILE")):
        with open(d.getVar("SCA_RAW_RESULT_FILE"), "r") as f:
            for m in re.finditer(pattern, f.read(), re.MULTILINE):
                try:
                    g = sca_get_model_class(d,
                                            PackageName=package_name,
                                            Tool="bitbake",
                                            BuildPath=buildpath,
                                            File=d.getVar("FILE"),
                                            Message="{}: {}".format(m.group("task"), m.group("message")),
                                            ID=m.group("severity"),
                                            Severity=severity_map[m.group("severity")])
                    if g.File in _excludes:
                        continue
                    if g.GetFormattedID() in _suppress:
                        continue
                    if not sca_is_in_finding_scope(d, "bitbake", g.GetFormattedID()):
                        continue
                    if g.Severity in sca_allowed_warning_level(d):
                        _findings.append(g)
                except Exception as exp:
                    bb.warn(str(exp))

    sca_add_model_class_list(d, _findings)
    return sca_save_model_to_string(d)

python do_sca_bitbake () {
    content = ""
    with open(d.getVar("CONLOG")) as f:
        content = f.read()
    result_raw_file = os.path.join(d.getVar("T"), "sca_raw_bitbake.txt")
    d.setVar("SCA_RAW_RESULT_FILE", result_raw_file)
    with open(result_raw_file, "w") as o:
        o.write(content)

    ## Create data model
    d.setVar("SCA_DATAMODEL_STORAGE", "{}/bitbake.dm".format(d.getVar("T")))
    dm_output = do_sca_conv_bitbake(d)
    dm_output = do_sca_bitbake_hardening(d)
    with open(d.getVar("SCA_DATAMODEL_STORAGE"), "w") as o:
        o.write(dm_output)

    sca_task_aftermath(d, "bitbake", get_fatal_entries(d))
}

SCA_DEPLOY_TASK = "do_sca_deploy_gcc"

python do_sca_deploy_bitbake() {
    sca_conv_deploy(d, "bitbake", "txt")
}

DEPENDS += "bitbake-sca-native"