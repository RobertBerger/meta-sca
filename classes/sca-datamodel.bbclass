inherit sca-helper

__SCA_DATAMODEL_STORAGE = "[]"

def sca_severity_transformation(d):
    res = {}
    for i in clean_split(d, "SCA_SEVERITY_TRANSFORM") + clean_split(d, "SCA_SEVERITY_TRANSFORM_EXTRA"):
        if "=" not in i:
            continue
        k,v = i.split("=")
        res[k] = v
    return res

def sca_get_model_class(d, **kwargs):
    __SevTrans = sca_severity_transformation(d)

    class SCADataModel():
        def __init__(self, *args, **kwargs):
            self.__File = ""
            self.__BuildPath = ""
            self.__Line = "1"
            self.__Column = "1"
            self.__Severity = ""
            self.__Message = ""
            self.__ID = ""
            self.__PackageName = ""
            self.__Tool = ""
            self.__SevTrans = {}
            for k,v in kwargs.items():
                x = getattr(self, k)
                if x is not None:
                    setattr(self, k, v)

        @property
        def File(self):
            return self.__File
        
        @File.setter
        def File(self, value):
            self.__File = value
            self.__fixupPaths()

        @property
        def BuildPath(self):
            return self.__BuildPath
        
        @BuildPath.setter
        def BuildPath(self, value):
            self.__BuildPath = value
            self.__fixupPaths()

        @property
        def Line(self):
            return self.__Line
        
        @Line.setter
        def Line(self, value):
            self.__Line = value

        @property
        def Column(self):
            return self.__Column
        
        @Column.setter
        def Column(self, value):
            self.__Column = value
        
        @property
        def Severity(self):
            return self.__Severity
        
        @Severity.setter
        def Severity(self, value):
            self.__Severity = value
            self.__sev_transform()

        @property
        def Message(self):
            return self.__Message
        
        @Message.setter
        def Message(self, value):
            self.__Message = value

        @property
        def ID(self):
            return self.__ID
        
        @ID.setter
        def ID(self, value):
            self.__ID = value
            self.__sev_transform()

        @property
        def PackageName(self):
            return self.__PackageName
        
        @PackageName.setter
        def PackageName(self, value):
            self.__PackageName = value

        @property
        def Tool(self):
            return self.__Tool
        
        @Tool.setter
        def Tool(self, value):
            self.__Tool = value
        
        @property
        def SevTrans(self):
            return self.__SevTrans
        
        @SevTrans.setter
        def SevTrans(self, value):
            self.__SevTrans = value
            self.__sev_transform()
        
        def __fixupPaths(self):
            if self.__File:
                if self.__BuildPath:
                    if self.__File.startswith(self.__BuildPath):
                        self.__File = self.__File.replace(self.__BuildPath, "")
                    if self.__File.startswith(self.__BuildPath[1:]):
                        self.__File = self.__File.replace(self.__BuildPath[1:], "")
                if self.__File.startswith("."):
                    self.__File = self.__File.lstrip(".")
                if self.__File.startswith("/"):
                    self.__File = self.__File.lstrip("/")

        def __sev_transform(self):
            import re
            if self.__SevTrans and self.__ID and self.__Severity:
                __id = self.GetFormattedID()
                for k, v in self.__SevTrans.items():
                    if re.match(k, __id):
                        if self.__SevTrans != v:
                            self.__Severity = v
                        break

        def GetPlainID(self):
            tmp = self.__ID or ""
            tool_prefix = [x for x in tmp.split(".") if x == self.__Tool or x.lower() == self.__Tool.lower()]
            _id = [x for x in tmp.split(".") if x != self.__Tool]
            if any(tool_prefix):
                return "{}.{}".format(".".join(tool_prefix), "_".join(_id))
            return "_".join(_id)

        def GetFormattedMessage(self):
            return "[Package:{} Tool:{}] {}".format(self.__PackageName, self.__Tool, self.__Message)
        
        def GetFormattedID(self):
            res = self.GetPlainID()
            if res.startswith("{}.{}".format(self.__Tool, self.__Tool)):
                pass
            elif res.startswith("{}".format(self.__Tool)):
                res = "{}.{}".format(self.__Tool, res)
            else:
                res = "{}.{}.{}".format(self.__Tool, self.__Tool, res)
            return res

        def GetPath(self, exportPath=None):
            return os.path.join(exportPath or self.__BuildPath or "", self.__File)

        def __repr__(self):
            return "{}:{}:{} [{}]: {} ({})".format(self.__File, self.__Line, self.__Column, self.__Severity, self.__Message, self.__ID)

        def __eq__(self, other):
            if isinstance(other, SCADataModel) or issubclass(other, SCADataModel):
                return str(other) == str(self)
            else:
                return False

        def __ne__(self, other):
            return (not self.__eq__(other))

        def __hash__(self):
            return hash(self.__repr__())

        @staticmethod
        def FromDict(_in):
            return SCADataModel(**_in)
        
        @staticmethod
        def FromList(_in):
            return [SCADataModel.FromDict(x) for x in _in]
        
        def ToDict(self):
            return {k:getattr(self,k) for k in ["File", "BuildPath", "Line", "Column", "Severity", "Message", "ID", "PackageName", "Tool"] if getattr(self,k)}

    return SCADataModel(SevTrans=__SevTrans, **kwargs)

def __sca_model_to_list(d, list):
    return [x.ToDict() for x in list]

def sca_get_datamodel(d, path):
    import json
    with open(path, "r") as o:
        _m = sca_get_model_class(d)
        return _m.FromList(json.load(o))
    return []

def sca_add_model_class(d, item):
    import json
    _m = sca_get_model_class(d)
    _t = _m.FromList(json.loads(d.getVar("__SCA_DATAMODEL_STORAGE")))
    _t.append(item)
    d.setVar("__SCA_DATAMODEL_STORAGE", json.dumps(__sca_model_to_list(d, _t)))

def sca_add_model_class_list(d, _list):
    import json
    _m = sca_get_model_class(d)
    _t = _m.FromList(json.loads(d.getVar("__SCA_DATAMODEL_STORAGE")))
    _t += _list
    d.setVar("__SCA_DATAMODEL_STORAGE", json.dumps(__sca_model_to_list(d, _t)))

def __sca_unique_model(d):
    import json
    _m = sca_get_model_class(d)
    _t = _m.FromList(json.loads(d.getVar("__SCA_DATAMODEL_STORAGE")))
    _t = list(set(_t))
    return __sca_model_to_list(d, _t)

def sca_save_model_to_file(d, path):
    import json
    _t = sca_save_model_to_string(d)
    with open(path, "w") as o:
        bb.warn(str(_t))
        json.dump(_t, o, indent=2, sort_keys=True)

def sca_save_model_to_string(d, model=None):
    import json
    if not model:
        return json.dumps(__sca_unique_model(d))
    else:
        return json.dumps([x.ToDict() for x in model])
