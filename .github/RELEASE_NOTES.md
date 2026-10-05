Native macOS focus with blur, dimming, app rules, grayscale app icons, and 13 interface languages.

- Requires macOS 14 or later.
- The DMG contains a universal app for Apple silicon and Intel.
- The app is ad hoc signed and is not notarized by Apple.

Install by opening the DMG and dragging Vidrado to Applications. If macOS quarantines this copy, remove that attribute from Vidrado only:

```sh
xattr -dr com.apple.quarantine /Applications/Vidrado.app
```

Verify the download with both files in the same folder:

```sh
shasum -a 256 -c Vidrado.dmg.sha256
```

Read the [README](https://github.com/tonhadaplaces/vidrado#readme) for use, privacy, and implementation limits.
