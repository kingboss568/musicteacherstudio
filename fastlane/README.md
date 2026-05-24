fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios validate_submission_package

```sh
[bundle exec] fastlane ios validate_submission_package
```

Validate metadata, public pages, IAP definitions, and required screenshots

### ios validate_metadata

```sh
[bundle exec] fastlane ios validate_metadata
```

Validate everything except screenshots, useful before simulator capture is available

### ios capture_app_store_screenshots

```sh
[bundle exec] fastlane ios capture_app_store_screenshots
```

Capture iPhone 6.9-inch and iPad 13-inch App Store screenshots

### ios build_for_review

```sh
[bundle exec] fastlane ios build_for_review
```

Build a signed App Store IPA for review

### ios prepare_review

```sh
[bundle exec] fastlane ios prepare_review
```

One-command local preparation: screenshots, validation, then IPA build

### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

Upload metadata and screenshots to App Store Connect without binary

### ios upload_build

```sh
[bundle exec] fastlane ios upload_build
```

Upload a signed IPA to App Store Connect

### ios submit_review

```sh
[bundle exec] fastlane ios submit_review
```

Submit the prepared app version for review after metadata, screenshots, IAPs, and build are ready

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
