# Configuration for cpplint

## Supported environments/languages

* C
* C++

## Configuration

| var | purpose | type | default |
| ------------- |:-------------:| -----:| -----:
| SCA_BLACKLIST_cpplint | Blacklist filter for this tool | space-separated-list | "linux-*"
| SCA_CPPLINT_EXTRA_FATAL | Extra error-ids leading to build termination when found | space-separated-list | ""
| SCA_CPPLINT_EXTRA_SUPPRESS | Extra error-ids to be suppressed | space-separated-list | ""
| SCA_CPPLINT_FILE_FILTER | List of file-extensions to be checked | space-separated-list | ".c .cpp .h .hpp"

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

- [x] security
- [x] functional defects
- [x] style issues

## Statistics

 - ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ 10/10 Build Speed
 - ⬛⬛⬛⬛⬜⬜⬜⬜⬜⬜ 04/10 Execution Speed
 - ⬛⬛⬛⬛⬛⬛⬛⬜⬜⬜ 07/10 Quality

## Score mapping

### Error considered as security relevant

* cpplint.cpplint.runtime.threadsafe_fn
* cpplint.cpplint.runtime.member_string_references
* cpplint.cpplint.runtime.operator

### Error considered as functional defect

* cpplint.cpplint.build.header_guard
* cpplint.cpplint.build.printf_format
* cpplint.cpplint.runtime.memset

### Error considered as style issue

* cpplint.cpplint.*