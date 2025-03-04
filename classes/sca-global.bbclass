SCA_ENABLE ?= "1"
SCA_EXPORT_DIR ?= "${DEPLOY_DIR_IMAGE}/sca"
SCA_EXPORT_FINDING_SRC = "1"
SCA_EXPORT_FINDING_DIR ?= "${DEPLOY_DIR_IMAGE}/sca/sources/${PN}/"

SCA_EXPORT_FORMAT ?= "checkstyle"
SCA_EXPORT_FORMAT_SUFFIX_checkstyle = "xml"

SCA_AUTO_INH_ON_IMAGE ?= "1"
SCA_AUTO_INH_ON_RECIPE ?= "1"

## Just apply the one of the following license (regex)
SCA_AUTO_LICENSE_FILTER ?= ".*"

## All findings below this level will be dropped
## from checkstyle-result
## possible options error, warning or info
SCA_WARNING_LEVEL ?= "warning"

## Enable an extra report per image
SCA_ENABLE_IMAGE_SUMMARY ?= "1"

## Enable an extra report from bestof-module
SCA_ENABLE_BESTOF ?= "0"

## Enable an score calculation
SCA_ENABLE_SCORE ?= "1"

## Standard python interpreter to be used in SCA
SCA_STD_PYTHON_INTERPRETER ?= "python3"

## Shebang for python interpreter
SCA_PYTHON_SHEBANG = ".*${SCA_STD_PYTHON_INTERPRETER}"

## Cleanup old files before exporting
SCA_CLEAN_BEFORE_EXPORT ?= "1"

## Force run of SCA
SCA_FORCE_RUN ??= "0"

## Verbose output of SCA invocation
SCA_VERBOSE_OUTPUT ??= "1"

## Filter by scope
SCA_SCOPE_FILTER ?= "security functional style"

## List of rules for transforming severity
## example: pylint.pylint.C0103=error
SCA_SEVERITY_TRANSFORM ?= ""

## List of overall available modules
SCA_AVAILABLE_MODULES ?= "\
                          alexkohler \
                          ansible \
                          ansiblelint \
                          bandit \
                          bashate \
                          bitbake \
                          checkbashism \
                          cppcheck \
                          cpplint \
                          cqmetrics \
                          cspell \
                          cvecheck \
                          darglint \
                          dennis \
                          detectsecrets \
                          eslint \
                          flake8 \
                          flint \
                          gcc \
                          gixy \
                          golint \
                          gosec \
                          govet \
                          htmlhint \
                          jsonlint \
                          kconfighard \
                          npmaudit \
                          mypy \
                          oelint \
                          proselint \
                          pyfindinjection \
                          pylint \
                          pysymcheck \
                          pytype \
                          radon \
                          rats \
                          retire \
                          revive \
                          ropgadget \
                          safety \
                          shellcheck \
                          sparse \
                          splint \
                          standard \
                          stank \
                          stylelint \
                          systemdlint \
                          textlint \
                          tscancode \
                          vulture \
                          xmllint \
                          yamllint \
                          zrd"

SCA_ENABLED_MODULES := "${SCA_ENABLED_MODULES_${SCA_MODE_UPPER}}"