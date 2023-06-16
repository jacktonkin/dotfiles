#!/bin/sh

system_type=$(uname -s)

if [ "$system_type" = "Darwin" ]; then

  # install homebrew if it's missing
  if ! command -v brew >/dev/null 2>&1; then
    echo "Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [ -f "$HOME/.Brewfile" ]; then
    echo "Updating homebrew bundle"
    brew bundle --global

    # Switch to using brew-installed bash as default shell
    BREW_BASH="$(brew --prefix)/bin/bash"
    if ! fgrep -q "$BREW_BASH" /etc/shells; then
      echo "$BREW_BASH" | sudo tee -a /etc/shells;
      chsh -s "$BREW_BASH";
    fi;

  fi

fi
