#!/usr/bin/env bash

system_type=$(uname -s)

if [ "$system_type" = "Darwin" ]; then
  # Quit the settings app to avoid overwriting our changes.
  osascript -e 'tell application "System Preferences" to quit'

  # Load the uk.tonkin.Keyboard.CalculatorF16 launch agent if not already
  # loaded. This uses `hidutil` to remap keys as follows:
  # 1. Calculator to F16 (see https://apple.stackexchange.com/a/414903)
  # 2. F22 to Dictation
  # 3. F23 to Do not Disturb
  # 4. F24 to Globe
  if ! launchctl list uk.tonkin.Keyboard.CalculatorF16 2> /dev/null; then
    launchctl load -F ~/Library/LaunchAgents/uk.tonkin.Keyboard.CalculatorF16.plist
  fi

  # Assign keyboard shortcut F16 to the `Launch Calculator` Automator quick
  # action (see "~/Library/Services/Launch Calculator.workflow").
  defaults write pbs NSServicesStatus -dict-add "\"(null) - Launch Calculator - runWorkflowAsService\"" \
    "{key_equivalent = \"\\Uf713\";}"
}
