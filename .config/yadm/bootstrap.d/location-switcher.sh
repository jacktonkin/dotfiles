#!/usr/bin/env bash

system_type=$(uname -s)

if [ "$system_type" = "Darwin" ]; then
  # Create the Home network location if it does not alreadu exist.
  # Use the 1.1.1.1 DNS service there.
  if sudo networksetup -createlocation Home populate > /dev/null; then
    sudo networksetup -switchtolocation Home
    sudo networksetup -setdnsservers Wi-Fi 1.1.1.1
    sudo networksetup -switchtolocation Automatic
  fi


  # Load the uk.tonkin.Network.LocationChanger launch agent if not already
  # loaded.
  if ! launchctl list uk.tonkin.Network.LocationChanger 2> /dev/null; then
    launchctl load -F ~/Library/LaunchAgents/uk.tonkin.Network.LocationChanger.plist
  fi

fi
