#!/usr/bin/env bash

#==========================================
# 初始化脚本 - 配置开发环境
#==========================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() { echo -e "${RED}Error: $*$NC" >&2; exit 1; }
info() { echo -e "${GREEN}[INFO]$*${NC}"; }
warn() { echo -e "${YELLOW}[WARN]$*${NC}"; }

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"

#==========================================
# 安装基础工具
#==========================================
install_tools() {
    info "安装基础工具..."

    # fzf
    if [ ! -d "$HOME/.fzf" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all --no-bash --no-fish
    fi

    # ctags
    command -v ctags >/dev/null 2>&1 || sudo apt-get install -y universal-ctags

    # ag
    command -v ag >/dev/null 2>&1 || sudo apt-get install -y silversearcher-ag

    # ripgrep
    command -v rg >/dev/null 2>&1 || sudo apt-get install -y ripgrep
}

#==========================================
# 安装 Oh My Zsh
#==========================================
install_oh_my_zsh() {
    if [ -n "$ZSH" ]; then
        ZSH_PATH="$ZSH"
    else
        ZSH_PATH="$HOME/.oh-my-zsh"
    fi

    if [ -d "$ZSH_PATH" ]; then
        info "Oh My Zsh 已安装"
    else
        info "安装 Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

#==========================================
# 安装 Zsh 插件
#==========================================
install_zsh_plugins() {
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    PLUGINS_DIR="$ZSH_CUSTOM/plugins"

    mkdir -p "$PLUGINS_DIR"

    # zsh-autosuggestions
    if [ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
        info "安装 zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]; then
        info "安装 zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$PLUGINS_DIR/zsh-syntax-highlighting"
    fi
}

#==========================================
# 配置 ~/.zshrc（不再使用 patch）
#==========================================
configure_zshrc() {
    ZSHRC="$HOME/.zshrc"

    # 检查是否已包含配置
    if grep -q "my-oh-my-zsh-config" "$ZSHRC" 2>/dev/null; then
        info "zshrc 已配置"
    else
        info "配置 zshrc..."

        # 追加自定义配置
        cat >> "$ZSHRC" << 'EOF'

# ===== my-oh-my-zsh-config =====
# 插件配置
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# 禁用自动终端标题
export DISABLE_AUTO_TITLE=true

# 别名
alias tmux="tmux -2"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# ====================================
EOF
    fi
}

#==========================================
# 配置符号链接
#==========================================
setup_symlinks() {
    info "创建符号链接..."

    lnif() {
        if [ -e "$1" ]; then
            ln -sf "$1" "$2"
            info "链接: $2 -> $1"
        fi
    }

    lnif "$CURRENT_DIR/tigrc" "$HOME/.tigrc"
    lnif "$CURRENT_DIR/tigrc.theme" "$HOME/.tigrc.theme"
    lnif "$CURRENT_DIR/tmux.conf" "$HOME/.tmux.conf"
    lnif "$CURRENT_DIR/gitconfig" "$HOME/.gitconfig"
    lnif "$CURRENT_DIR/bashrc" "$HOME/.bashrc"
}

#==========================================
# 安装 Vim 配置
#==========================================
install_vim_config() {
    VIM_DIR="$CURRENT_DIR/vim_config"

    if [ -d "$VIM_DIR" ]; then
        info "vim 配置已存在"
    else
        info "克隆 vim 配置..."
        git clone https://github.com/andytian1991/space-vim.git "$VIM_DIR"
    fi

    if [ -f "$VIM_DIR/install.sh" ]; then
        info "安装 vim 配置..."
        cd "$VIM_DIR" && sh -c ./install.sh
    fi
}

#==========================================
# 安装 Tmux 插件
#==========================================
install_tmux_plugins() {
    TPM_DIR="$HOME/.tmux/plugins/tpm"

    if [ ! -d "$TPM_DIR" ]; then
        info "安装 tmux 插件管理器 (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    fi
}

#==========================================
# 切换默认 Shell
#==========================================
switch_to_zsh() {
    if [ -z "$ZSH" ]; then
        ZSH_PATH="$HOME/.oh-my-zsh"
    fi

    TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
    if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
        if command -v chsh >/dev/null 2>&1; then
            info "切换默认 shell 到 zsh..."
            chsh -s "$(grep /zsh$ /etc/shells | tail -1)"
        else
            warn "无法自动切换 shell，请手动执行: chsh -s \$(which zsh)"
        fi
    fi
}

#==========================================
# 主流程
#==========================================
main() {
    info "开始初始化开发环境..."

    # 检查是否为 root 用户
    if [ "$EUID" -eq 0 ]; then
        error "请不要使用 sudo 运行此脚本"
    fi

    install_tools
    install_oh_my_zsh
    install_zsh_plugins
    configure_zshrc
    setup_symlinks
    install_vim_config
    install_tmux_plugins
    switch_to_zsh

    info "初始化完成！请重新加载终端或执行: source ~/.zshrc"
}

main "$@"
