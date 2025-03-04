# Configuration for alexkohler

alexkohler is a collection of analyzer tools by Alex Kohler

## Supported environments/languages

* GO

## Configuration

| var | purpose | type | default |
| ------------- |:-------------:| -----:| -----:
| SCA_BLACKLIST_alexkohler | Blacklist filter for this tool | space-separated-list | "linux-*"
| SCA_ALEXKOHLER_EXTRA_FATAL | Extra error-ids leading to build termination when found | space-separated-list | ""
| SCA_ALEXKOHLER_EXTRA_SUPPRESS | Extra error-ids to be suppressed | space-separated-list | ""
| SCA_ALEXKOHLER_FILE_FILTER | List of file-extensions to be checked | space-separated-list | ".go"
| SCA_ALEXKOHLER_MODULES | List of tools to run | space-separated-list | "noret nargs nakedret dogsled prealloc identypo unimport"

## Supports

- [x] suppression of ids
- [x] terminate build on fatal
- [x] run on recipe
- [ ] run on image
- [x] run with SCA-layer default settings (see SCA_AVAILABLE_MODULES)

## Requires

- [ ] requires online access

## Known error-ids

* alexkohler.alexkohler.noret
* alexkohler.alexkohler.nargs
* alexkohler.alexkohler.nakedret
* alexkohler.alexkohler.dogsled
* alexkohler.alexkohler.prealloc
* alexkohler.alexkohler.identypo
* alexkohler.alexkohler.unimport

## Checking scope

- [ ] security
- [ ] functional defects
- [x] style issues

## Statistics

 - ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜ 09/10 Build Speed
 - ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜ 09/10 Execution Speed
 - ⬛⬛⬛⬛⬛⬛⬛⬛⬜⬜ 08/10 Quality

## Score mapping

### Error considered as security relevant

* n.a.

### Error considered as functional defect

* n.a.

### Error considered as style issue

* alexkohler.alexkohler.*
