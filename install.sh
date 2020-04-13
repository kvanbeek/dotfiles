DOTFILES=$HOME/.dotfiles

command_exists() {
    type "$1" > /dev/null 2>&1
}

echo "Installing dotfiles."

# only perform macOS-specific install
if [ "$(uname)" == "Darwin" ]; then
    echo -e "\\n\\nRunning on macOS"

    if test ! "$( command -v brew )"; then
        echo "Installing homebrew"
        ruby -e "$( curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install )"
    fi

    # # install brew dependencies from Brewfile
    brew bundle

    # # install oh my zsh and change shell to zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Oh My ZSH already exists"
    else
        echo "Installing Oh My Zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    # After the install, setup fzf
    echo -e "\\n\\nRunning fzf install script..."
    echo "=============================="
    /usr/local/opt/fzf/install --all --no-bash --no-fish

    echo -e "\\n\\ninstalling to ~/.config"
    echo "=============================="
    if [ ! -d "$HOME/.config" ]; then
        echo "Creating ~/.config"
        mkdir -p "$HOME/.config"
    fi

    config_files=$( find "$DOTFILES/config" -maxdepth 1 2>/dev/null )
    for config in $config_files; do
        target="$HOME/.config/$( basename "$config" )"
        if [ -e "$target" ]; then
            echo "~${target#$HOME} already exists... Skipping."
        else
            echo "Creating symlink for $config ~${target#$HOME}"
            ln -s "$config" "$target"
        fi
    done

    echo -e "\\n\\nCreating vim symlinks"
    echo "=============================="
    VIMFILES=( "$HOME/.vim:$DOTFILES/config/nvim"
        "$HOME/.vimrc:$DOTFILES/config/nvim/init.vim" )

    for file in "${VIMFILES[@]}"; do
        KEY=${file%%:*}
        VALUE=${file#*:}
        if [ -e "${KEY}" ]; then
            echo "${KEY} already exists... skipping."
        else
            echo "Creating symlink for $KEY"
            ln -s "${VALUE}" "${KEY}"
        fi
    done

    # # After the install, setup fzf
    # echo -e "\\n\\nRunning fzf install script..."
    # echo "=============================="
    # /usr/local/opt/fzf/install --all --no-bash --no-fish
fi

# Add base16
if [ ! -d "$HOME/.config/base16-shell" ]; then
    echo "Creating ~/.config/base16-shell"
    git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
    echo 'BASE16_SHELL="$HOME/.config/base16-shell/"
            [ -n "$PS1" ] && \
                [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
                    eval "$("$BASE16_SHELL/profile_helper.sh")"
    ' >> ~/.zshrc
fi 

# echo "creating vim directories"
# mkdir -p ~/.vim-tmp

# if ! command_exists zsh; then
#     echo "zsh not found. Please install and then re-run installation scripts"
#     exit 1
# elif ! [[ $SHELL =~ .*zsh.* ]]; then
#     echo "Configuring zsh as default shell"
#     chsh -s "$(command -v zsh)"
# fi

# # Change the default shell to zsh
# zsh_path="$( command -v zsh )"
# if ! grep "$zsh_path" /etc/shells; then
#     echo "adding $zsh_path to /etc/shells"
#     echo "$zsh_path" | sudo tee -a /etc/shells
# fi

# if [[ "$SHELL" != "$zsh_path" ]]; then
#     chsh -s "$zsh_path"
#     echo "default shell changed to $zsh_path"
# fi

echo "Done. Reload your terminal."

