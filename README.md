# oChat (SwiftUI)

## SetUP

### Installing dependencies

**Install Homebrew**  
Homebrew is a package manager for macOS, required for installing other tools. Run the following command to install it:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, update Homebrew to ensure you have the latest package definitions:

```bash
brew update
```

**Install mise**  
[mise](https://github.com/tuist/mise) is used for managing Tuist versions. Install it with Homebrew:

```bash
brew install mise
```

**Install Tuist**  
Tuist is a tool for managing iOS projects. Use mise to install Tuist:

```bash
mise install tuist
```

**Install SwiftLint**
SwiftLint is a tool to enforce Swift style and conventions. You can install SwiftLint using Homebrew:
```
brew install swiftlint
```

### Start project

**Generate the Project**  
After installing the required tools, you can prepare the project by running the following commands:

```bash
tuist clean
tuist install
tuist generate --no-open
```

![Tuist badge](https://img.shields.io/badge/Powered%20by-Tuist-blue)


