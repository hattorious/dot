# zsh functions

Loaded automatically by `runcom.zsh` via `init.zsh`. Cross-platform stuff lives in `common.zsh`; OS-specific stuff goes in the appropriate file.

```
functions/
├── init.zsh       # sources common + OS-specific files
├── common.zsh     # cross-platform
├── macos.zsh      # macOS only
└── ubuntu.zsh     # placeholder
```

## common.zsh

- OS detection: `is_interactive_shell`, `is_macos`, `is_ubuntu`, `get_os`, `read_os`
- `ref_dates` — date format reference table
- `read_file`, `getdrive` (needs curl + awk)
- `killgpg`, `yubistub` (needs gpg)
- `gcd` — cd to git repo root
- `ref_null_unset` — variable testing reference table

## macos.zsh

`is_macos_apple_silicon`, `kill_nsurlsessiond`, `dns_over_vpn`, `brewdepsinstalled`
