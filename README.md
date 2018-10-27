# VPN Autoconnect

This is an AppleScript that does UI scripting to work around VPN configurations
that disallow saved passwords.

It expects that you have a VPN configured in Network Preferences
that prompts only for a password when connecting --
the username should already be saved.

To accomplish this, the script accesses a credential stored in Keychain,
and does UI scripting to enter the password into the dialog box once it displays.
Lots of error checking is done to lead you through the required configuration.

To configure, do a find/replace in the script for `vpn.example.com`
to match the name of the credential you will store in Keychain,
and another for `Example VPN` for the name of the service in Network Preferences.
