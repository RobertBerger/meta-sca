# Configuration for jsonlint

## Supported environments/languages

* json

## Configuration

| var | purpose | type | default |
| ------------- |:-------------:| -----:| -----:
| SCA_BLACKLIST_jsonlint | Blacklist filter for this tool | space-separated-list | ""
| SCA_JSONLINT_EXTRA_FATAL | Extra error-ids leading to build termination when found | space-separated-list | ""
| SCA_JSONLINT_FILE_FILTER | List of file-extensions to be checked | space-separated-list | ".json"

## Supports

- [ ] suppression of ids
- [x] terminate build on fatal
- [x] run on recipe
- [x] run on image
- [x] run with SCA-layer default settings (see SCA_AVAILABLE_MODULES)

## Requires

- [ ] requires online access

## Known error-ids

* jsonlint.jsonlint.parsererror - Json is not parsable

## Checking scope

- [ ] security
- [x] functional defects
- [ ] style issues

## Statistics

 - ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ 10/10 Build Speed
 - ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ 10/10 Execution Speed
 - ⬛⬛⬛⬛⬛⬜⬜⬜⬜⬜ 05/10 Quality

## Score mapping

### Error considered as security relevant

* n.a.

### Error considered as functional defect

* jsonlint.jsonlint.E*

### Error considered as style issue

* n.a.