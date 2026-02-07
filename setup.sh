#!/bin/bash
set -euo pipefail

# ==========================================================
# tmux-neovim-ide セットアップスクリプト
# ==========================================================
# Ghostty + tmux + Neovim で VSCode ライクなターミナル IDE を構築する
# シンボリックリンクで設定を配置するので、git pull で即更新できる

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
  --config-only    設定ファイルのリンクのみ（brew install をスキップ）
  --help           このヘルプを表示

Examples:
  ./setup.sh               # フルセットアップ（brew install + 設定配置）
  ./setup.sh --config-only # 設定ファイルのみ配置
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
  error "このスクリプトは macOS 専用です"
  exit 1
fi

# ==========================================================
# 1. brew install
# ==========================================================
install_tools() {
  info "ツールをインストール中..."

  if ! command -v brew &>/dev/null; then
    error "Homebrew がインストールされていません"
    echo "  → https://brew.sh からインストールしてください"
    exit 1
  fi

  local tools=(neovim tmux fzf fd ripgrep)
  for tool in "${tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
      ok "$tool は既にインストール済み"
    else
      info "$tool をインストール中..."
      brew install "$tool"
      ok "$tool をインストールしました"
    fi
  done

  # Ghostty は cask
  if [ -d "/Applications/Ghostty.app" ]; then
    ok "Ghostty は既にインストール済み"
  else
    info "Ghostty をインストール中..."
    brew install --cask ghostty
    ok "Ghostty をインストールしました"
  fi

  echo ""
}

# ==========================================================
# 2. バックアップ & シンボリックリンク
# ==========================================================
backup_and_link() {
  local src="$1"
  local dest="$2"
  local label="$3"

  # 既にこのリポジトリへのシンボリックリンクなら何もしない
  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    ok "$label は既にリンク済み"
    return
  fi

  # 既存ファイル/ディレクトリがあればバックアップ
  if [[ -e "$dest" ]] || [[ -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    warn "$label のバックアップを作成: $BACKUP_DIR/"
    mv "$dest" "$BACKUP_DIR/"
  fi

  # 親ディレクトリがなければ作成
  mkdir -p "$(dirname "$dest")"

  ln -sf "$src" "$dest"
  ok "$label → $dest"
}

link_configs() {
  info "設定ファイルをリンク中..."
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
# 3. PATH 設定
# ==========================================================
setup_path() {
  local shell_rc=""
  if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == */zsh ]]; then
    shell_rc="$HOME/.zshrc"
  elif [[ -n "${BASH_VERSION:-}" ]] || [[ "$SHELL" == */bash ]]; then
    shell_rc="$HOME/.bashrc"
  fi

  if [[ -z "$shell_rc" ]]; then
    warn "シェルの RC ファイルが特定できません。手動で PATH に追加してください:"
    echo '  export PATH="$HOME/.local/bin:$PATH"'
    return
  fi

  if grep -qF '$HOME/.local/bin' "$shell_rc" 2>/dev/null; then
    ok "PATH は既に設定済み ($shell_rc)"
  else
    echo '' >> "$shell_rc"
    echo '# tmux-neovim-ide' >> "$shell_rc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_rc"
    ok "PATH を $shell_rc に追加しました"
  fi
}

# ==========================================================
# 4. フォントチェック
# ==========================================================
check_font() {
  info "フォントを確認中..."
  if fc-list 2>/dev/null | grep -qi "PlemolJP" || system_profiler SPFontsDataType 2>/dev/null | grep -qi "PlemolJP"; then
    ok "PlemolJP Console NF がインストール済み"
  else
    warn "PlemolJP Console NF が見つかりません"
    echo "  → https://github.com/yuru7/PlemolJP/releases からインストールしてください"
    echo "  → または別のNerd Fontを使う場合は config/ghostty/config の font-family を変更してください"
  fi
  echo ""
}

# ==========================================================
# Main
# ==========================================================
echo ""
echo "=================================================="
echo "  tmux-neovim-ide セットアップ"
echo "=================================================="
echo ""

if [[ "$CONFIG_ONLY" == false ]]; then
  install_tools
fi

link_configs
setup_path
check_font

echo "=================================================="
echo -e "  ${GREEN}セットアップ完了！${NC}"
echo "=================================================="
echo ""
echo "  使い方:"
echo "    1. ターミナルを再起動（または source ~/.zshrc）"
echo "    2. ide コマンドでプロジェクトを選択"
echo "    3. tmux + Neovim の IDE が起動します"
echo ""
echo "  初回起動時は tmux プラグインと Neovim プラグインが"
echo "  自動でインストールされるので少し待ってください。"
echo ""
