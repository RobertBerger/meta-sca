# Configuration examples for complete image monitoring

## Environment

* Languages: *
* Scope: final image + all used recipes
* New errors should abort the build
* If there are more than 5 new warning -> terminate the build
* Only components that are actually shipped should be monitored

## Recommended settings

### local.conf

```bitbake
INHERIT += "sca"
SCA_ENABLE = "1"
SCA_AUTO_INH_ON_IMAGE = "1"
SCA_AUTO_INH_ON_RECIPE = "1"
SCA_WARNING_LEVEL = "warning"
SCA_ENABLE_IMAGE_SUMMARY = "1"
SCA_ENABLE_BESTOF = "0"
SCA_ENABLE_SCORE = "0"
SCA_VERBOSE_OUTPUT = "0"
SCA_SCOPE_FILTER = "security functional"
SCA_ENABLED_MODULES_IMAGE = "\
                            ansible \
                            bandit \
                            bashate \
                            bitbake \
                            checkbashism \
                            detectsecrets \
                            eslint \
                            flake8 \
                            gixy \
                            htmlhint \
                            jsonlint \
                            mypy \
                            pyfindinjection \
                            pylint \
                            shellcheck \
                            standard \
                            stylelint \
                            systemdlint \
                            vulture \
                            xmllint \
                            yamllint \
                            "
SCA_ENABLED_MODULES_RECIPE = "\
                            alexkohler \
                            bandit \
                            bashate \
                            bitbake \
                            checkbashism \
                            cppcheck \
                            cpplint \
                            cvecheck \
                            darglint \
                            dennis \
                            detectsecrets \
                            eslint \
                            flake8 \
                            flint \
                            gcc \
                            golint \
                            gosec \
                            govet \
                            htmlhint \
                            jsonlint \
                            kconfighard \
                            npmaudit \
                            mypy \
                            pyfindinjection \
                            pylint \
                            pytype \
                            rats \
                            revive \
                            safety \
                            shellcheck \
                            sparse \
                            splint \
                            standard \
                            stylelint \
                            tscancode \
                            vulture \
                            xmllint \
                            yamllint \
                            zrd \
                            "
```

### Jenkins pipeline

```groovy
def deployDir = "$WORKSPACE/tmp/deploy/images/**";
def pokyDir = "$WORKSPACE/meta-poky/poky";
def buildDir = "$WORKSPACE/meta-poky/poky/build";
def pokyTarget = "fancy-company-image"

pipeline {
    agent any
    stages {
        stage('checkout') {
            echo "!!!Checkout your code out from your repo!!!"
        }
        stage('poky setup') {
            sh """
                cd ${pokyDir}
                . ./oe-init-build-env
            """
            sd """
                cd ${buildDir}
                echo "!!!Insert your build command line here!!!"
            """
        }
        stage('build') {
            steps {
                sh """
                cd ${pokyDir}
                . ./oe-init-build-env
                bitbake ${pokyTarget}
                """
            }
        }
    }
    post {
       always {
            recordIssues qualityGates: [
                [threshold: 1, type: 'NEW_ERROR', unstable: false],
                [threshold: 5, type: 'NEW_HIGH', unstable: false]
            ], tools: [checkStyle(pattern: '$deployDir/sca/image-summary/checkstyle/*.xml')]
       }
    }
}
```
