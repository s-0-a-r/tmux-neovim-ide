#!/bin/bash
set -euo pipefail

# ==========================================================
# tmux-neovim-ide setup script
# ==========================================================
# Builds a VSCode-like terminal IDE with Ghostty + tmux + Neovim.
# Config files are deployed as symlinks so git pull updates everything instantly.

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.config/tmux-neovim-ide-backup/$(date +%Y%m%d_%H%M%S)"

# -- Colors --
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# -- Usage --
usage() {
  cat <<EOF
Usage: ./setup.sh [OPTIONS]

Options:
  --config-only    Link config files only (skip brew install)
  --help           Show this help

Examples:
  ./setup.sh               # Full setup (brew install + config linking)
  ./setup.sh --config-only # Link config files only
EOF
}

# -- Parse args --
CONFIG_ONLY=false
for arg in "$@"; do
  case $arg in
    --config-only) CONFIG_ONLY=true ;;
    --help) usage; exit 0 ;;
    *) error "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

# -- OS check --
if [[ "$(uname)" != "Darwin" ]]; then
  error "This script requires macOS"
  exit 1
fi

# ==========================================================
# 1. brew install
# ==========================================================
install_tools() {
  info "Installing tools..."

  if ! command -v brew &>/dev/null; then
    error "Homebrew is not installed"
    echo "  → Install from https://brew.sh"
    exit 1
  fi

  local tools=(neovim tmux fzf fd ripgrep)
  for tool in "${tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
      ok "$tool already installed"
    else
      info "Installing $tool..."
      brew install "$tool"
      ok "$tool installed"
    fi
  done

  # Ghostty is a cask
  if [ -d "/Applications/Ghostty.app" ]; then
    ok "Ghostty already installed"
  else
    info "Installing Ghostty..."
    brew install --cask ghostty
    ok "Ghostty installed"
  fi

  echo ""
}

# ==========================================================
# 2. Backup & symlink
# ==========================================================
backup_and_link() {
  local src="$1"
  local dest="$2"
  local label="$3"

  # Already linked to this repo — nothing to do
  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    ok "$label already linked"
    return
  fi

  # Back up existing file/directory
  if [[ -e "$dest" ]] || [[ -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    warn "Backing up $label to $BACKUP_DIR/"
    mv "$dest" "$BACKUP_DIR/"
  fi

  # Create parent directory if missing
  mkdir -p "$(dirname "$dest")"

  ln -sf "$src" "$dest"
  ok "$label → $dest"
}

link_configs() {
  info "Linking config files..."
  echo ""

  # tmux
  backup_and_link "$REPO_DIR/config/tmux.conf" "$HOME/.tmux.conf" "tmux.conf"

  # Neovim
  backup_and_link "$REPO_DIR/config/nvim" "$HOME/.config/nvim" "nvim/"

  # Ghostty
  local ghostty_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
  backup_and_link "$REPO_DIR/config/ghostty/config" "$ghostty_dir/config" "ghostty/config"

  # ide script
  mkdir -p "$HOME/.local/bin"
  backup_and_link "$REPO_DIR/bin/ide" "$HOME/.local/bin/ide" "bin/ide"
  chmod +x "$REPO_DIR/bin/ide"

  echo ""
}

# ==========================================================
# 3. PATH setup
# ==========================================================
setup_path() {
  local shell_rc=""
  if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == */zsh ]]; then
    shell_rc="$HOME/.zshrc"
  elif [[ -n "${BASH_VERSION:-}" ]] || [[ "$SHELL" == */bash ]]; then
    shell_rc="$HOME/.bashrc"
  fi

  if [[ -z "$shell_rc" ]]; then
    warn "Could not detect shell RC file. Add PATH manually:"
    echo '  export PATH="$HOME/.local/bin:$PATH"'
    return
  fi

  if grep -qF '$HOME/.local/bin' "$shell_rc" 2>/dev/null; then
    ok "PATH already configured ($shell_rc)"
  else
    echo '' >> "$shell_rc"
    echo '# tmux-neovim-ide' >> "$shell_rc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_rc"
    ok "PATH added to $shell_rc"
  fi
}

# ==========================================================
# 4. Font check
# ==========================================================
check_font() {
  info "Checking fonts..."
  if fc-list 2>/dev/null | grep -qi "PlemolJP" || system_profiler SPFontsDataType 2>/dev/null | grep -qi "PlemolJP"; then
    ok "PlemolJP Console NF installed"
  else
    warn "PlemolJP Console NF not found"
    echo "  → Install from https://github.com/yuru7/PlemolJP/releases"
    echo "  → Or change font-family in config/ghostty/config to another Nerd Font"
  fi
  echo ""
}

# ==========================================================
# Main
# ==========================================================
echo ""
echo "=================================================="
echo "  tmux-neovim-ide setup"
echo "=================================================="
echo ""

if [[ "$CONFIG_ONLY" == false ]]; then
  install_tools
fi

link_configs
setup_path
check_font

echo "=================================================="
echo -e "  ${GREEN}Setup complete!${NC}"
echo "=================================================="
echo ""
echo "  Next steps:"
echo "    1. Restart your terminal (or run: source ~/.zshrc)"
echo "    2. Run the ide command to select a project"
echo "    3. tmux + Neovim IDE will launch"
echo ""
echo "  On first launch, tmux and Neovim plugins will be"
echo "  installed automatically — please wait a moment."
echo ""
