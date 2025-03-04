# Configuration for splint

## Supported environments/languages

* C

## Configuration

| var | purpose | type | default |
| ------------- |:-------------:| -----:| -----:
| SCA_BLACKLIST_splint | Blacklist filter for this tool | space-separated-list | "linux-.*"
| SCA_SPLINT_EXTRA_FATAL | Extra error-ids leading to build termination when found | space-separated-list | "":
| SCA_SPLINT_EXTRA_SUPPRESS | Extra error-ids to be suppressed | space-separated-list | ""
| SCA_SPLINT_FILE_FILTER | File extensions to check on | space-separated-list | ".c"
| SCA_SPLINT_INTENSITY | Check intensity, higher value = longer runtime | int: 1-4 | "2"

## Supports

- [x] suppression of ids
- [x] terminate build on fatal
- [x] run on recipe
- [ ] run on image
- [x] run with SCA-layer default settings (see SCA_AVAILABLE_MODULES)

## Requires

- [ ] requires online access

## Known error-ids

__TDB__

## Checking scope

- [x] security
- [x] functional defects
- [x] style issues

## Statistics

 - ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜ 09/10 Build Speed
 - ⬛⬛⬛⬛⬜⬜⬜⬜⬜⬜ 04/10 Execution Speed
 - ⬛⬛⬛⬛⬛⬛⬛⬜⬜⬜ 07/10 Quality

## Score mapping

### Error considered as security relevant

* splint.splint.allocmismatch
* splint.splint.bitwisesigned
* splint.splint.boolcompare
* splint.splint.boundsread
* splint.splint.boundswrite
* splint.splint.bufferoverflow
* splint.splint.bufferoverflowhigh
* splint.splint.evalorder
* splint.splint.evalorderuncon
* splint.splint.exitarg
* splint.splint.freshtrans
* splint.splint.fullinitblock
* splint.splint.globstate
* splint.splint.infloops
* splint.splint.infloopsuncon
* splint.splint.initsize
* splint.splint.its4low
* splint.splint.its4moderate
* splint.splint.its4mostrisky
* splint.splint.its4risky
* splint.splint.its4veryrisky
* splint.splint.likelyboundsread
* splint.splint.likelyboundswrite
* splint.splint.macroparens
* splint.splint.macroret
* splint.splint.memimp
* splint.splint.multithreaded
* splint.splint.null
* splint.splint.nullassign
* splint.splint.nullderef
* splint.splint.nullinit
* splint.splint.nullpass
* splint.splint.nullptrarith
* splint.splint.nullret
* splint.splint.nullstate
* splint.splint.nullterminated
* splint.splint.portability
* splint.splint.shiftimplementation
* splint.splint.shiftnegative
* splint.splint.toctou
* splint.splint.usedef
* splint.splint.voidabstract

### Error considered as functional defect

* splint.splint.abstract
* splint.splint.abstractcompare
* splint.splint.aliasunique
* splint.splint.alwaysexits
* splint.splint.annotationerror
* splint.splint.boolops
* splint.splint.branchstate
* splint.splint.casebreak
* splint.splint.castexpose
* splint.splint.checkedglobalias
* splint.splint.checkmodglobalias
* splint.splint.checkstrictglobalias
* splint.splint.checkstrictglobs
* splint.splint.cppnames
* splint.splint.declundef
* splint.splint.duplicatecases
* splint.splint.duplicatequals
* splint.splint.elseifcomplete
* splint.splint.emptyret
* splint.splint.exportany
* splint.splint.exportconst
* splint.splint.exportfcn
* splint.splint.exportheader
* splint.splint.exportheadervar
* splint.splint.exportiter
* splint.splint.exportlocal
* splint.splint.exportmacro
* splint.splint.exporttype
* splint.splint.exportvar
* splint.splint.exposetrans
* splint.splint.fcnderef
* splint.splint.firstcase
* splint.splint.forblock
* splint.splint.forempty
* splint.splint.formatcode
* splint.splint.formattype
* splint.splint.forwarddecl
* splint.splint.globuse
* splint.splint.hasyield
* splint.splint.ifblock
* splint.splint.ifempty
* splint.splint.immediatetrans
* splint.splint.imptype
* splint.splint.incompletetype
* splint.splint.incondefs
* splint.splint.incondefslib
* splint.splint.isoreserved
* splint.splint.isoreservedinternal
* splint.splint.iterbalance
* splint.splint.iteryield
* splint.splint.looploopbreak
* splint.splint.looploopcontinue
* splint.splint.loopswitchbreak
* splint.splint.macroredef
* splint.splint.macrostmt
* splint.splint.macrounrecog
* splint.splint.matchfields
* splint.splint.misscase
* splint.splint.mustdefine
* splint.splint.mustnotalias
* splint.splint.mutrep
* splint.splint.nestedextern
* splint.splint.noeffect
* splint.splint.noeffectuncon
* splint.splint.noparams
* splint.splint.noret
* splint.splint.onlytrans
* splint.splint.onlyunqglobaltrans
* splint.splint.overload
* splint.splint.ownedtrans
* splint.splint.preproc
* splint.splint.ptrarith
* splint.splint.ptrcompare
* splint.splint.ptrnegate
* splint.splint.readonlystrings
* splint.splint.readonlytrans
* splint.splint.realcompare
* splint.splint.realrelatecompare
* splint.splint.redecl
* splint.splint.redef
* splint.splint.redundantsharequal
* splint.splint.refcounttrans
* splint.splint.retalias
* splint.splint.retexpose
* splint.splint.retimponly
* splint.splint.retval
* splint.splint.retvalbool
* splint.splint.retvalint
* splint.splint.retvalother
* splint.splint.sefparams
* splint.splint.sefuncon
* splint.splint.shadow
* splint.splint.sizeofformalarray
* splint.splint.sizeoftype
* splint.splint.specundecl
* splint.splint.specundef
* splint.splint.stackref
* splint.splint.staticinittrans
* splint.splint.statictrans
* splint.splint.strictbranchstate
* splint.splint.strictops
* splint.splint.strictusereleased
* splint.splint.stringliteralnoroom
* splint.splint.stringliteralnoroomfinalnull
* splint.splint.stringliteralsmaller
* splint.splint.stringliteraltoolong
* splint.splint.structimponly
* splint.splint.switchloopbreak
* splint.splint.switchswitchbreak
* splint.splint.syntax
* splint.splint.topuse
* splint.splint.trytorecover
* splint.splint.type
* splint.splint.typeprefixexclude
* splint.splint.typeuse
* splint.splint.uncheckedglobalias
* splint.splint.uniondef
* splint.splint.unqualifiedinittrans
* splint.splint.unqualifiedtrans
* splint.splint.unreachable
* splint.splint.unrecog
* splint.splint.unrecogdirective
* splint.splint.unsignedcompare
* splint.splint.usevarargs
* splint.splint.whileblock
* splint.splint.whileempty

### Error considered as style issue

* splint.splint..*
