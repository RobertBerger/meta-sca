# Configuration for stylelint

## Supported environments/languages

* css
* scss

## Configuration

| var | purpose | type | default |
| ------------- |:-------------:| -----:| -----:
| SCA_BLACKLIST_stylelint | Blacklist filter for this tool | space-separated-list | ""
| SCA_STYLELINT_CONFIG | Config to use | 'stylelint-config-standard' or 'stylelint-config-recommended' | "stylelint-config-standard"
| SCA_STYLELINT_EXTRA_FATAL | Extra error-ids leading to build termination when found | space-separated-list | "":
| SCA_STYLELINT_EXTRA_SUPPRESS | Extra error-ids to be suppressed | space-separated-list | ""
| SCA_STYLELINT_FILE_FILTER | Files to scan | space-separated-list | ".css .scss .html .htm"

## Supports

- [x] suppression of ids
- [x] terminate build on fatal
- [x] run on recipe
- [x] run on image
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

 - ⬛⬛⬛⬛⬛⬛⬛⬛⬜⬜ 08/10 Build Speed
 - ⬛⬛⬛⬛⬛⬛⬜⬜⬜⬜ 06/10 Execution Speed
 - ⬛⬛⬛⬛⬛⬛⬛⬛⬜⬜ 08/10 Quality

## Score mapping

### Error considered as security relevant

* n.a.

### Error considered as functional defect

* n.a.

### Error considered as style issue

* stylelint.stylelint.*