#! /bin/bash
set -euo pipefail

# This script will remove automatic association for all networks not listed in the whitelist
# passed as the first argument. Passwords will NOT be removed from the Keychain.
#
# Alternatively, you can untick "Remember networks" in Network Preferences > Wi-Fi > Advanced,
# but then you won't be able to auto-join networks even temporarily, and you might already
# have a long list to go through.
#
# Having automatic association for open or known-password networks is dangerous as it
# allows an attacker to force you on their network by simple proximity.
#
# You'll have to run this as sudo not to be prompted at every entry.

DEVICE="en0"

networksetup -listpreferredwirelessnetworks "$DEVICE" | tail -n +2 | cut -d$'\t' -f2- | \
while IFS= read -r network
do
        grep -Fxe "$network" "$1" > /dev/null || (
                networksetup -removepreferredwirelessnetwork "$DEVICE" "$network"
        )
done