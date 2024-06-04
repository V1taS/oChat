# oChat (SwiftUI)

## SetUP

### Installing dependencies

**Install Tuist**

To install Tuist, simply open the terminal at your project's root directory and run the following script:
```
bash Scripts/install-tuist.sh
```

This script will download and set up Tuist in your system. Note that during the installation, you may be prompted to enter your administrator password to allow the necessary changes.

Make sure you have an active internet connection and are ready to enter your administrator password when prompted to ensure the successful installation of dependencies.

**Install SwiftLint**

SwiftLint is a tool to enforce Swift style and conventions. You can install SwiftLint using Homebrew:
```
brew install swiftlint
```

### Start project

To generate and run the project, execute the following commands in your terminal:
```
tuist fetch
tuist generate
```

By running these commands, you will fetch all necessary project dependencies and generate the project files needed to open and run your project in Xcode.

**Generates three files**

This script scans the current directory for localization files (.strings) and images (.png, .jpg), 
and generates three files:
- GeneratedLocalizedStrings.swift - contains localized strings.
- GeneratedImageAssets.swift - contains references to images.
- GeneratedBundleAccessor.swift - provides access to the bundle.

To use: save this script and run it in the terminal with the command `swift CreateLocalizedStrings.swift`.

![Tuist badge](https://img.shields.io/badge/Powered%20by-Tuist-blue)
