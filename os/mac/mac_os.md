# macOS Essentials

## Quick Setup
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Essential Commands

**System Info**
```bash
sw_vers                    # macOS version
system_profiler SPHardwareDataType  # Hardware info
top -l 1 | grep PhysMem   # Memory usage
```

**Files & Directories**
```bash
open .                    # Open current folder in Finder
pwd | pbcopy             # Copy current path
qlmanage -p file.txt     # Quick preview file
```

**Network**
```bash
sudo dscacheutil -flushcache  # Flush DNS
ping google.com               # Test connection
```

## Must-Have Tools
```bash
# Development
brew install git node python
brew install --cask visual-studio-code docker

# Productivity  
brew install --cask rectangle iterm2 alfred vlc

# Utilities
brew install htop tree wget jq
```

## Useful Shortcuts
- `⌘ + Space` - Spotlight
- `⌘ + ⇧ + .` - Toggle hidden files
- `⌘ + ⇧ + 4` - Screenshot selection
- `⌃ + A/E` - Start/end of line in Terminal

## Quick Tweaks
```bash
# Auto-hide Dock
defaults write com.apple.dock autohide -bool true; killall Dock

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true; killall Finder
```

## Maintenance
```bash
brew update && brew upgrade    # Update packages
brew cleanup                   # Remove old versions
df -h                         # Check disk space
```
