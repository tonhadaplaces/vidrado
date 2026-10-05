# Release preparation

## Wave 1: documentation and release setup
- [x] Write the English README and translate it into the other 12 supported languages.
- [x] Add CI, release automation, issue/PR templates, and repository hygiene.
- [ ] Capture screenshots on a new macOS desktop.

## Wave 2: validation
- [x] Run core and native checks and validate the distribution.
- [x] Check documentation links, translations, assets, and committed files.
- [ ] Independently review the committed release configuration.

## Wave 3: GitHub
- [ ] Publish the initial repository contents, including design.pen.
- [ ] Require one approval, passing CI, and resolved conversations on main; disallow force pushes and deletion.
- [ ] Verify repository settings and leave the validated distribution artifacts ready for launch.

## Review
13 core tests and all 24 native checks passed in both debug and release. Universal build, signature, DMG, checksum, localization catalogs, workflow lint, and documentation links passed. Three app screenshots are saved; Mission Control was unavailable for creating a new desktop. Independent review identified the version-bump documentation issue; it was corrected in all 13 READMEs. GitHub CI passed on the preparation branch. Final independent review and main protection are pending.
