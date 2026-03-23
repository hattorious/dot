# Dotfiles
After cloning this repo, run `install` to automatically set up the development
environment. Note that the install script is idempotent: it can safely be run
multiple times.

Dotfiles uses [Dotbot](https://github.com/anishathalye/dotbot) for installation.

## Zsh Configuration

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

### Utility Functions Toolkit

The zsh configuration includes a comprehensive modular toolkit of utility functions in `zsh/functions/`. The toolkit follows the repository's established pattern of common + OS-specific organization:

#### Structure
- **`common.zsh`** - Functions that work across all operating systems
- **`macos.zsh`** - macOS-specific functions (only loads on macOS)
- **`ubuntu.zsh`** - Ubuntu-specific functions (only loads on Ubuntu)
- **`init.zsh`** - Main loader that sources common + OS-specific files

#### Loading Pattern
The toolkit follows the repository's pattern of loading common functionality first, then OS-specific overrides:
1. **common.zsh** - Loaded first, contains cross-platform functions
2. **OS-specific files** - Loaded based on detected OS

#### Key Functions by Category

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

#### Usage

All functions are automatically loaded and available in your shell session. Each function includes detailed technical documentation and usage examples. Run any function without arguments to see its help information.

For detailed documentation about the toolkit structure and how to add new functions, see `zsh/functions/README.md`.
