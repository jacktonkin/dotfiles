#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function doIt() {
	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		-avh --no-perms .[[:alpha:]]* bin ~;
	source ~/.bash_profile;
  cp LaunchAgents/*.plist ~/Library/LaunchAgents/;
  cp -r Services/*.workflow ~/Library/Services/;

  osascript -e 'tell application "System Preferences" to quit'
  defaults write pbs NSServicesStatus -dict-add "\"(null) - Launch Calculator - runWorkflowAsService\"" \
    "{key_equivalent = \"\\Uf713\"; presentation_modes = {ContextMenu = 1; ServicesMenu = 1; TouchBar = 1;};}"
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;
