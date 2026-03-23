# ZSH Configuration

This directory contains the zsh shell configuration and utility functions toolkit.

## Structure

```
zsh/
├── runcom.zsh              # Main zsh configuration file
├── sensible/               # Sensible zsh defaults and options
│   └── sensible.zsh       # Sensible zsh configuration
├── zshrc.local.example     # Example local configuration file
├── functions/              # Utility functions toolkit
│   ├── init.zsh           # Main loader for all function modules
│   ├── common.zsh         # Functions that work across all operating systems
│   ├── macos.zsh          # macOS-specific functions
│   ├── ubuntu.zsh         # Ubuntu-specific functions (future)
│   └── README.md          # Functions toolkit documentation
├── zim/                   # Zim framework configuration
└── README.md              # This file
```

## Configuration Files

### runcom.zsh
The main zsh configuration file that:
- Sources the utility functions toolkit
- Loads sensible zsh defaults
- Initializes the Zim framework
- Loads local customizations

### sensible/sensible.zsh
A comprehensive set of sensible zsh defaults and options that improve the shell experience. Based on the bash-sensible project, translated and enhanced for zsh. Includes:

**General Options:**
- Prevent file overwrite on stdout redirection
- Enable history expansion with space
- Recursive globbing with `**`
- Case-insensitive globbing

**Smart Tab Completion:**
- Case-insensitive file completion
- Treat hyphens and underscores as equivalent
- Menu selection for completions
- Completion caching

**Sane History Defaults:**
- Large history size (500,000 entries)
- Avoid duplicate entries
- Ignore certain commands
- Incremental history search

**Better Directory Navigation:**
- Auto-cd for directory names
- Spelling correction
- Directory bookmarks with named directories

**Zsh-Specific Improvements:**
- Extended globbing
- Better job control
- Improved completion system
- Enhanced history search

### zshrc.local.example
Example file showing how to create machine-specific customizations that won't be overwritten by dotfiles updates.

## Local Customizations

The zsh configuration supports an optional `.zshrc.local` file for machine-specific customizations. This file is sourced at the end of the main zsh configuration and allows you to add custom aliases, functions, environment variables, and other settings that won't be overwritten by the dotfiles installation.

To use this feature:
1. Copy `zsh/zshrc.local.example` to `~/.zshrc.local`
2. Add your customizations to the file
3. Restart your shell or run `source ~/.zshrc.local`

Example customizations:
- Custom aliases
- Machine-specific environment variables
- Custom functions
- Additional configuration file sources
- Prompt or theme overrides

## Utility Functions Toolkit

The zsh configuration includes a comprehensive modular toolkit of utility functions in `zsh/functions/`. The toolkit follows the repository's established pattern of common + OS-specific organization:

### Structure
- **`common.zsh`** - Functions that work across all operating systems
- **`macos.zsh`** - macOS-specific functions (only loads on macOS)
- **`ubuntu.zsh`** - Ubuntu-specific functions (only loads on Ubuntu)
- **`init.zsh`** - Main loader that sources common + OS-specific files

### Loading Pattern
The toolkit follows the repository's pattern of loading common functionality first, then OS-specific overrides:
1. **common.zsh** - Loaded first, contains cross-platform functions
2. **OS-specific files** - Loaded based on detected OS

### Key Functions by Category

**Shell and OS Detection:**
- `is_interactive_shell()` - Check if running in interactive mode
- `is_macos()`, `is_ubuntu()` - OS detection functions
- `is_macos_apple_silicon()` - Detect Apple Silicon Macs
- `get_os()` - Get current operating system name
- `read_os()` - Read variables from system os-release file

**Date and Time:**
- `ref_dates()` - Display reference table of date format patterns

**File and System:**
- `read_file()` - Safely read files line by line
- `getdrive()` - Download files from Google Drive using file ID

**Security:**
- `killgpg()` - Kill and restart GPG agent
- `yubistub()` - Regenerate GPG key stubs for YubiKey

**macOS-Specific:**
- `kill_nsurlsessiond()` - Kill bandwidth-hogging URL session daemon
- `dns_over_vpn()` - Route DNS through VPN interface
- `brewdepsinstalled()` - Check Homebrew formula dependencies

**Git:**
- `gcd()` - Change to git repository root directory

**Development:**
- `ref_null_unset()` - Reference table for variable testing behavior

### Usage

All functions are automatically loaded and available in your shell session. Each function includes detailed technical documentation and usage examples. Run any function without arguments to see its help information.

For detailed documentation about the toolkit structure and how to add new functions, see `zsh/functions/README.md`.

## Zim Framework

This configuration uses the [Zim framework](https://github.com/zimfw/zimfw) for zsh configuration management. The Zim configuration is in the `zim/` directory.

## Installation

The zsh configuration is automatically installed when you run the main `install` script. The configuration follows the same modular pattern as the rest of the dotfiles repository, with OS-specific considerations and local customization support.

## Dependencies

The sensible.zsh configuration creates a cache directory at `~/.zsh/cache` for completion caching. This directory is automatically created during installation.
