# ZSH Functions Toolkit

This directory contains a modular toolkit of utility functions organized following the repository's pattern of common + OS-specific files. Each file contains related functions with detailed documentation and usage examples.

## Structure

```
functions/
├── init.zsh              # Main loader - sources common + OS-specific files
├── common.zsh            # Functions that work across all operating systems
├── macos.zsh             # macOS-specific functions
├── ubuntu.zsh            # Ubuntu-specific functions (future)
└── README.md             # This file
```

## Files

### common.zsh
Functions that work across all operating systems:
- **Shell and OS Detection**: `is_interactive_shell()`, `is_macos()`, `is_ubuntu()`, `get_os()`, `read_os()`
- **Date and Time**: `ref_dates()`
- **File and System**: `read_file()`, `getdrive()`
- **Security**: `killgpg()`, `yubistub()`
- **Git**: `gcd()`
- **Development**: `ref_null_unset()`

### macos.zsh
Functions specific to macOS systems (only loads on macOS):
- **Apple Silicon Detection**: `is_macos_apple_silicon()`
- **System Management**: `kill_nsurlsessiond()`, `dns_over_vpn()`
- **Homebrew**: `brewdepsinstalled()`

### ubuntu.zsh
Functions specific to Ubuntu systems (only loads on Ubuntu):
- *Future: Ubuntu-specific functions will be added here*

## Loading Pattern

The toolkit follows the repository's established pattern of loading common functionality first, then OS-specific overrides:

1. **common.zsh** - Loaded first, contains cross-platform functions
2. **OS-specific files** - Loaded based on detected OS (macos.zsh, ubuntu.zsh, etc.)

This pattern matches the bash configuration structure and allows for:
- Consistent behavior across operating systems
- OS-specific optimizations and features
- Easy addition of new OS support

## Key Functions

### Shell and OS Detection
- `is_interactive_shell()` - Check if running in interactive mode
- `is_macos()` - Detect macOS systems
- `is_ubuntu()` - Detect Ubuntu systems
- `is_macos_apple_silicon()` - Detect Apple Silicon Macs
- `get_os()` - Get current operating system name
- `read_os()` - Read variables from system os-release file

### Date and Time
- `ref_dates()` - Display reference table of date format patterns

### File and System
- `read_file()` - Safely read files line by line
- `getdrive()` - Download files from Google Drive using file ID

### Security
- `killgpg()` - Kill and restart GPG agent
- `yubistub()` - Regenerate GPG key stubs for YubiKey

### macOS-Specific
- `kill_nsurlsessiond()` - Kill bandwidth-hogging URL session daemon
- `dns_over_vpn()` - Route DNS through VPN interface
- `brewdepsinstalled()` - Check Homebrew formula dependencies

### Git
- `gcd()` - Change to git repository root directory

### Development
- `ref_null_unset()` - Reference table for variable testing behavior

## Usage

The toolkit is automatically loaded by the main zsh configuration. All functions are available in your shell session.

### Manual Loading

To load specific files manually:

```zsh
# Load all functions (common + OS-specific)
source ~/.dotfiles/zsh/functions/init.zsh

# Load only common functions
source ~/.dotfiles/zsh/functions/common.zsh

# Load only macOS functions (will only work on macOS)
source ~/.dotfiles/zsh/functions/macos.zsh
```

### Adding New Functions

To add new functions:

1. **Cross-platform functions**: Add to `common.zsh`
2. **OS-specific functions**: Add to the appropriate OS file (`macos.zsh`, `ubuntu.zsh`, etc.)
3. **New OS support**: Create a new OS file (e.g., `debian.zsh`) and update the loader in `init.zsh`

### Function Documentation Format

Each function should include:
- Clear description of what it does
- Usage examples with actual commands
- Technical details explaining how it works
- Parameter descriptions where applicable

Example:
```zsh
function my_function() {
  # Brief description of what the function does
  #
  # Arguments:
  #   $1 - Description of first argument
  #   $2 - Description of second argument (optional)
  #
  # Usage:
  #   my_function arg1 arg2
  #   my_function arg1  # Second argument is optional
  #
  # Technical details:
  # - Explanation of how the function works
  # - Important implementation notes
  # - Dependencies or requirements

  # Function implementation here
}
```

## Dependencies

Most functions use standard Unix tools and zsh built-ins. Some functions have specific dependencies:

- `brewdepsinstalled()` - Requires Homebrew
- `killgpg()`, `yubistub()` - Require GPG
- `kill_nsurlsessiond()`, `dns_over_vpn()` - macOS only
- `getdrive()` - Requires curl and awk

## Contributing

When adding new functions:
1. Follow the existing documentation format
2. Test functions on both macOS and Linux where applicable
3. Include error handling and appropriate return codes
4. Add functions to the appropriate file (common.zsh or OS-specific)
5. Update this README if adding new OS support
