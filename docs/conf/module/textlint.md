# Configuration for textlint

## Supported environments/languages

* spelling

## Configuration

| var | purpose | type | default |
| ------------- |:-------------:| -----:| -----:
| SCA_BLACKLIST_textlint | Blacklist filter for this tool | space-separated-list | ""
| SCA_TEXTLINT_EXTRA_FATAL | Extra error-ids leading to build termination when found | space-separated-list | ""
| SCA_TEXTLINT_EXTRA_SUPPRESS | Extra error-ids to be suppressed | space-separated-list | ""
| SCA_TEXTLINT_ONLINE | Allow rules which requires online access to work | 0 or 1 | "1"
| SCA_TEXTLINT_RULES | List of rules to check on | space-separated-list | see sca-textlint.bbclass for details

## Supports

- [x] suppression of ids
- [x] terminate build on fatal
- [x] run on recipe
- [ ] run on image
- [x] run with SCA-layer default settings (see SCA_AVAILABLE_MODULES)

## Requires

- [x] requires online access

## Known error-ids

__tbd__

## Checking scope

- [ ] security
- [ ] functional defects
- [x] style issues

## Statistics

 - ⬛⬛⬛⬛⬛⬛⬜⬜⬜⬜ 06/10 Build Speed
 - ⬛⬛⬛⬛⬛⬛⬜⬜⬜⬜ 06/10 Execution Speed
 - ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ 10/10 Quality

## Score mapping

### Error considered as security relevant

* n.a.

### Error considered as functional defect

* n.a.

### Error considered as style issue

* textlint.textlint.*