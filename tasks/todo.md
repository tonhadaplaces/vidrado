# Release preparation

## Wave 1: documentation and release setup
- [x] Write the English README and translate it into the other 12 supported languages.
- [x] Add CI, release automation, issue/PR templates, and repository hygiene.
- [ ] Capture screenshots on a new macOS desktop.

## Wave 2: validation
- [ ] Run core and native checks and validate the distribution.
- [x] Check documentation links, translations, assets, and committed files.
- [ ] Independently review the committed release configuration.

## Wave 3: GitHub
- [ ] Publish the initial repository contents, including design.pen.
- [ ] Require one approval, passing CI, and resolved conversations on main; disallow force pushes and deletion.
- [ ] Verify repository settings and leave the validated distribution artifacts ready for launch.

## Review
13 core tests passed. Universal build, signature, DMG, checksum, localization catalogs, workflow lint, and documentation links passed. Native checks passed 23/24 in debug and release; compositor ordering remains pending. Three app screenshots are saved; Mission Control was unavailable for creating a new desktop. Independent configuration review and GitHub setup are pending.
