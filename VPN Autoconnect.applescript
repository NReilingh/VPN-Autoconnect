tell application "System Events"
	
	set vpnName to "Example VPN"
	set credentialName to "vpn.example.com"
	
	set quotedVpnName to quoted form of vpnName
	
	try
	
		try
			set vpnStatus to first word of (do shell script "scutil --nc status " & quotedVpnName)
		on error "No Service"
			set sysPrefButton to "Open System Preferences"
			set alertResult to display alert "Couldn't find " & vpnName & " service." message "The VPN service must be named " & quote & vpnName & quote & ". Services can be renamed in Network System Preferences by selecting the service and clicking the gear icon at the bottom of the list." buttons {sysPrefButton, "OK"}
			
			if button returned of alertResult is equal to sysPrefButton then
				tell application "System Preferences"
					activate
					set current pane to pane "com.apple.preference.network"
				end tell
			end if
			
			return
		end try
		
		if vpnStatus is equal to "Connected" then
			
			do shell script "scutil --nc stop " & quotedVpnName
			
		else if vpnStatus is equal to "Disconnected" then
			
			try
				
				set vpnPassword to do shell script "security find-generic-password -s " & credentialName & " -w"
				if length of vpnPassword < 1 then error number 501
				
			on error errMsg number errNum
				
				if errNum = 44 then
					set keychainButton to "Open Keychain Access"
					set alertResult to display alert credentialName & " not found in Keychain." message "Please use Keychain Access to store your VPN credential with the name " & quote & credentialName & quote & ". The \"security\" utility will request access; choose Always Allow to avoid being prompted in the future." buttons {keychainButton, "OK"}
					if button returned of alertResult is equal to keychainButton then activate application "Keychain Access"
				else if errNum = 501 then
					display alert "Retrieved password contains < 1 character. Please check the " & quote & credentialName & quote & " keychain item."
				else if errMsg = "The command exited with a non-zero status." then
					display alert "An unknown error occurred with the shell script. Perhaps try logging out and back in again to make sure your Keychain isn't temporarily messed up?" message "Exit code " & errNum
				else
					error errMsg number errNum
				end if
				
				return
				
			end try
			
			do shell script "scutil --nc start " & quotedVpnName
			
			set attempt to 1
			repeat until window 1 of application process "UserNotificationCenter" exists
				set attempt to attempt + 1
				if attempt > 10 then error "Couldn't find the VPN Connection window after 10 attempts." number 502
				delay 1
			end repeat
			
			tell window 1 of application process "UserNotificationCenter"
				if name of first static text is not equal to "VPN Connection" then error "Displayed window is not VPN Connection" number 503
				if subrole of text field 2 is not equal to "AXSecureTextField" then error "Can't enter password into insecure text field" number 504
				set value of text field 2 to vpnPassword
				click button "OK"
			end tell
			
		end if
		
	on error errMsg number errNum
		
		if errNum >= 500 and errNum < 600 then
			display alert errMsg message "Error number " & errNum
		else
			display alert "Error number " & errNum message errMsg
		end if
		
	end try
	
end tell