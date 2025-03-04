inherit sca-conv-to-export
inherit sca-datamodel
inherit sca-blacklist

DEPENDS += "${@oe.utils.ifelse(sca_is_module_blacklisted(d, 'foo'), '', '${SCA_STD_PYTHON_INTERPRETER}-python-magic-native')}"

inherit ${@oe.utils.ifelse(d.getVar('SCA_STD_PYTHON_INTERPRETER') == 'python3', 'python3-dir', 'python-dir')}

def get_relative_source_path(d):
    import os
    source = d.getVar("S")
    dl_dir = d.getVar("DL_DIR")
    ## use build-dir as base
    dl_dir = os.path.dirname(dl_dir)
    common = os.path.commonprefix([source, dl_dir])
    return os.path.relpath(source, common)

def get_build_dir(d):
    import os
    source = d.getVar("S")
    dl_dir = d.getVar("DL_DIR")
    ## use build-dir as base
    dl_dir = os.path.dirname(dl_dir)
    return os.path.commonprefix([source, dl_dir])

def should_emit_to_console(d):
    if "bitbake" in d.getVar("SCA_ENABLED_MODULES").split(" "):
        return False
    return True

def intersect_lists(d, l1, l2):
    if isinstance(l1, str):
        l1 = [x for x in l1.split(" ") if x]
    if isinstance(l2, str):
        l2 = [x for x in l2.split(" ") if x]
    return sorted(list(set(l1).intersection(l2)))

def xml_combine(d, *args):
    import sys
    from xml.etree import ElementTree
    first = None
    for content in args:
        try:
            data = ElementTree.ElementTree(ElementTree.fromstring(content)).getroot()
            if first is None:
                first = data
            else:
                first.extend(data)
        except Exception as e:
            pass
    if first is not None:
        try:
            return ElementTree.tostring(first).decode("utf-8")
        except:
            return ElementTree.tostring(first)
    else:
        return ""

def _combine_x_entries(d, input_file, extra_key):
    import os
    _filename = d.getVar(input_file)
    _extra = d.getVar(extra_key) or ""
    res = []
    if _filename and os.path.isfile(_filename):
        _rules_file = _filename
        with open(_rules_file) as f:
            res = f.readlines()
    res += _extra.split(" ")
    res = [x.strip() for x in res if x]
    return res


SCA_LOCAL_FILE_FILTER ?= "\
                    ${RECIPE_SYSROOT} \
                    ${RECIPE_SYSROOT_NATIVE} \
                    ${T} \
    "


def get_files_by_shebang(d, path, pattern, excludes=[]):
    import os
    import re
    res = []
    local_dirs = clean_split(d, "SCA_LOCAL_FILE_FILTER")
    pattern = r"^#!\s*{}".format(pattern)
    for root, dirs, files in os.walk(path, topdown=True):
        for item in files:
            _filename = os.path.join(root, item)
            if any([_filename.startswith(x) for x in local_dirs]):
                continue
            if _filename in excludes:
                continue
            try:
                with open(_filename, "r") as f:
                    cnt = f.readlines()
                    if cnt:
                        cnt = cnt[0]
                        if re.match(pattern, cnt):
                            res.append(_filename)
            except:
                pass
    return [x for x in res if os.path.isfile(x)]

def get_files_by_mimetype(d, path, mime, excludes=[]):
    import os
    import sys
    sys.path.append(os.path.join(d.getVar("STAGING_DIR_NATIVE"), d.getVar("PYTHON_SITEPACKAGES_DIR")[1:]))
    try:
        import magic
        local_dirs = clean_split(d, "SCA_LOCAL_FILE_FILTER")
        res = []
        for root, dirs, files in os.walk(path, topdown=True):
            for item in files:
                _filename = os.path.join(root, item)
                if any([_filename.startswith(x) for x in local_dirs]):
                    continue
                if _filename in excludes:
                    continue
                try:
                    if magic.from_file(_filename, mime=True) in mime:
                        res.append(_filename)
                except:
                    pass
        return [x for x in res if os.path.isfile(x)]
    except ImportError:
        return []

def get_files_by_glob(d, pattern, excludes=[]):
    import os
    import glob
    res = []
    if isinstance(pattern, str):
        pattern = pattern.split(" ")
    res = []
    for p in pattern:
        res += glob.glob(p)
    return [x for x in res if os.path.isfile(x)]

def get_files_by_extention(d, path, pattern, excludes=[]):
    import os
    res = []
    if isinstance(pattern, str):
        pattern = pattern.split(" ")
    local_dirs = clean_split(d, "SCA_LOCAL_FILE_FILTER")
    for root, dirs, files in os.walk(path, topdown=True):
        for item in files:
            _filepath = os.path.join(root, item)
            if any([_filepath.startswith(x) for x in local_dirs]):
                continue
            if _filepath in excludes:
                continue
            _filename, _file_extension = os.path.splitext(_filepath)
            if _file_extension in pattern and pattern:
                res.append(_filepath)
    return [x for x in res if os.path.isfile(x)]

def get_files_by_extention_or_shebang(d, path, shebang, extentions, excludes=[]):
    res = get_files_by_shebang(d, path, shebang, excludes) + get_files_by_extention(d, path, extentions, excludes)
    return sorted(list(set(res)))

def get_suppress_entries(d):
    return _combine_x_entries(d, "SCA_SUPRESS_FILE", "SCA_EXTRA_SUPPRESS")

def get_fatal_entries(d):
    return _combine_x_entries(d, "SCA_FATAL_FILE", "SCA_EXTRA_FATAL")

def _get_x_from_result(d, lookup_key = "severity", match_key = ""):
    _dm = sca_get_datamodel(d, d.getVar("SCA_DATAMODEL_STORAGE"))
    res = [x for x in _dm if lookup_key in x.__dict__.keys() and x.__dict__[lookup_key] == match_key]
    return res

def get_warnings_from_result(d):
    return _get_x_from_result(d, match_key = "warning")

def get_errors_from_result(d):
    return _get_x_from_result(d, match_key = "error")

def get_fatal_from_result(d, fatal_ids):
    res = []
    for i in fatal_ids:
        res += _get_x_from_result(d, lookup_key = "source", match_key = i)
    return list(set(res))

def clean_split(d, _var):
    return [x for x in (d.getVar(_var) or "").split(" ") if x]

def sca_task_aftermath(d, tool, fatals=None):
    ## Write to final export
    result_file = os.path.join(d.getVar("T"), sca_conv_export_get_deployname(d, tool))
    d.setVar("SCA_RESULT_FILE", result_file)
    with open(result_file, "w") as o:
        o.write(sca_conv_to_export(d))

    ## Evaluate
    _warnings = get_warnings_from_result(d)
    _errors = get_errors_from_result(d)
    if fatals:
        _fatals = get_fatal_from_result(d, fatals)
    else:
        _fatals = []

    warn_log = []
    if any(_warnings) and should_emit_to_console(d):
        warn_log.append("{} warning(s)".format(len(_warnings)))
    if any(_errors) and should_emit_to_console(d):
        warn_log.append("{} error(s)".format(len(_errors)))
    if warn_log and should_emit_to_console(d):
        bb.warn("SCA has found {}".format(",".join(warn_log)))
    
    if any(_fatals):
        bb.build.exec_func(d.getVar("SCA_DEPLOY_TASK"), d)
        bb.error("SCA has following fatal errors: {}".format("\n".join(_fatals)))

def sca_force_run(d):
    status = d.getVar("SCA_FORCE_RUN") or "0"
    ## Issue a warning if rm_work has been found in INHERIT
    ## because it could significantly slow down building
    if "rm_work" in clean_split(d, "INHERIT") and status == "1":
        bb.warn("You inherited 'rm_work', so enabling SCA_FORCE_RUN could slow down your build significantly")
    return status

def get_bb_exec_ext_parameter_support(d):
    ## Since commit https://github.com/openembedded/bitbake/commit/cfeffb602dd5319f071cd6bcf84139ec77f2d170
    ## The support for pythonexception=True was removed from bb.build.exec_func 
    ## which this layer uses heavily
    ## so we need to probe here for it
    ## if we are able to pass it or not
    import bb
    import inspect
    res = {}
    x = inspect.getfullargspec(bb.build.exec_func)
    if "pythonexception" in x.args:
        res["pythonexception"] = True
    return res