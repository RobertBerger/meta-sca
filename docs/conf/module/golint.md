# Configuration for govet

## Supported environments/languages

* GO

## Configuration

| var | purpose | type | default |
| ------------- |:-------------:| -----:| -----:
| SCA_BLACKLIST_golint | Blacklist filter for this tool | space-separated-list | "linux-*"
| SCA_GOLINT_EXTRA_FATAL | Extra error-ids leading to build termination when found | space-separated-list | ""
| SCA_GOLINT_EXTRA_SUPPRESS | Extra error-ids to be suppressed | space-separated-list | ""
| SCA_GOLINT_FILE_FILTER | List of file-extensions to be checked | space-separated-list | ".go"

## Supports

- [x] suppression of ids
- [x] terminate build on fatal
- [x] run on recipe
- [ ] run on image
- [x] run with SCA-layer default settings (see SCA_AVAILABLE_MODULES)

## Requires

- [ ] requires online access

## Known error-ids

__tbd__

## Checking scope

- [ ] security
- [ ] functional defects
- [x] style issues

## Statistics

 - ⬛⬛⬛⬛⬛⬛⬜⬜⬜⬜ 06/10 Build Speed
 - ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ 10/10 Execution Speed
 - ⬛⬛⬛⬛⬛⬛⬛⬜⬜⬜ 07/10 Quality

## Score mapping

### Error considered as security relevant

* n.a.

### Error considered as functional defect

* n.a.

### Error considered as style issue

* golint.golint.*
