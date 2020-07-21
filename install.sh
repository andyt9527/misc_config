#!/usr/bin/env zsh


#git clone https://github.com/vim/vim.git
#cd vim
#git checkout -b v8-1453 v8.0.1453
#./configure --with-features=huge  --enable-multibyte   --enable-rubyinterp=yes   --enable-pythoninterp=yes  --enable-python3interp=yes --with-python3-config-dir=/usr/lib/python3.5/config  --enable-perlinterp=yes  --enable-luainterp=yes --enable-gui=gtk2 --enable-cscope --prefix=/usr --enable-fail-if-missing
#make VIMRUNTIMEDIR=/usr/share/vim/vim80
#sudo make install

CURRENT_DIR=`pwd`

# Red bold error
function error() {
  echo
  echo "$fg_bold[red]Error: $* $reset_color"
  echo
}

# Green bold message
function message() {
  echo
  echo "$fg_bold[green]Message: $* $reset_color"
  echo
}

lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
}

CHECK_ZSH_INSTALLED=$(grep /zsh$ /etc/shells | wc -l)
if [ ! $CHECK_ZSH_INSTALLED -ge 1 ]; then
  error "Zsh is not installed! Please install zsh first!"
  exit
fi
unset CHECK_ZSH_INSTALLED

if [ ! -n "$ZSH" ]; then
  ZSH=~/.oh-my-zsh
fi

if [ -d "$ZSH" ]; then
  message "You already have Oh My Zsh installed."
  message "You'll need to remove $ZSH if you want to re-install."
else
  message "no oh_my_zsh found, install it"
  git clone https://github.com/robbyrussell/oh-my-zsh.git $ZSH

  # Source ~/.zshrc because we need oh-my-zsh variables
  source $ZSH/templates/zshrc.zsh-template ~/.zshrc

  # apply patches needed
  #cd $ZSH
  #git am $CURRENT_DIR/omz_patches/0001-hack-for-prompt-show-down-due-to-git-status-stuff.patch
  #git am $CURRENT_DIR/omz_patches/0002-add-my-OMZ-theme.patch
  git am $CURRENT_DIR/omz_patches/0003-Do-not-use-less-to-show-git-log-message.patch

  # If folder isn't exist, then make it
  [ -d $ZSH_CUSTOM/plugins ] || mkdir $ZSH_CUSTOM/plugins
  # clone plugins needed
  git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

  # If this user's login shell is not already "zsh", attempt to switch.
  TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
  if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
    # If this platform provides a "chsh" command (not Cygwin), do it, man!
    if hash chsh >/dev/null 2>&1; then
      message "Time to change your default shell to zsh!"
     ##### chsh -s $(grep /zsh$ /etc/shells | tail -1)
    # Else, suggest the user do so manually.
    else
      message "I can't change your shell automatically because this system does not have chsh."
      message "Please manually change your default shell to zsh!"
    fi
  fi
fi

# use symblink for all configs
MYBASH_RC="$HOME/.bashrc"
MYZSH_RC="$HOME/.zshrc"
MYTIG_RC="$HOME/.tigrc"
MYTIG_THEME="$HOME/.tigrc.theme"
MYTMUX_CONF="$HOME/.tmux.conf"
MYGIT_CONF="$HOME/.gitconfig"

lnif $CURRENT_DIR/bashrc $MYBASH_RC
lnif $CURRENT_DIR/zshrc $MYZSH_RC
lnif $CURRENT_DIR/tigrc $MYTIG_RC
lnif $CURRENT_DIR/tigrc.theme $MYTIG_THEME
lnif $CURRENT_DIR/tmux.conf $MYTMUX_CONF
lnif $CURRENT_DIR/gitconfig $MYGIT_CONF

MYVIM_DIR="$CURRENT_DIR/vim_config"

if [ -d $MYVIM_DIR ]; then
  message "vim config exists"
else
  message "no vim configs, clone it"
  git clone https://github.com/andytian1991/vim_config.git $MYVIM_DIR
fi

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

message "update vimrc/bundle"
cd $MYVIM_DIR
sh -c ./install.sh

message "Done! Please reload your terminal."
