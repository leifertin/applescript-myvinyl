-- register.applescript
-- myVinyl

--  Created by Leif Heflin on 5/9/10.
--  Copyright 2010 Leifertin. All rights reserved.

global theGoAhead

property homeRootURL : "http://grayarea.be/app/MyVinyl/"

on choose menu item theObject
	if the name of theObject is "registerMenu" then
		set the clipboard to ""
		show window "registerWindow"
	else if the name of theObject is "regPaypal" then
		open location "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=X2UJ8NLZE92NJ"
	end if
end choose menu item

on action theObject
	set usrEmail to the contents of text field "emailAdd" of window "registerWindow"
	set usrSerial to the contents of text field "serialNum" of window "registerWindow"
	
	set theGoAhead to getGoAhead(usrEmail, usrSerial, "5")
	if theGoAhead is 0 then
		set contents of text field "regStatus" of window "registerWindow" to "X"
	else
		set enabled of menu item "regPaypal" of menu 6 of main menu to false
		set title of menu item "registerMenu" of menu 6 of main menu to (localized string "menu_ViewSerialNumber")
		--say "hey"
		savePrefs(usrEmail, usrSerial)
	end if
end action

on should close theObject
	hide theObject
	return false
end should close

on savePrefs(usrEmail, usrSerial)
	try
		set prefsFile to (quoted form of (POSIX path of (path to home folder) & "Library/Application Support/MyVinyl.prefs"))
		set prefsfileR to (do shell script "cat " & prefsFile)
		
		set usrEmail_f to (item 2 of split(prefsfileR, "<userEmail>")) as string
		set usrSerial_f to (item 2 of split(prefsfileR, "<userSerial>")) as string
		
		set prefsfileR to snr(prefsfileR, usrEmail_f, usrEmail)
		set prefsfileR to snr(prefsfileR, usrSerial_f, usrSerial)
		--display dialog "prefsfileR" default answer prefsfileR
		--say usrEmail
		do shell script ("echo " & quoted form of prefsfileR & " > " & prefsFile)
	end try
end savePrefs

on useOtherScript(scriptNameID)
	set appsup to ((POSIX path of (path to me)) & ("Contents/Resources/")) as string
	tell me
		set otherScript to POSIX file ((appsup & "Scripts/" & scriptNameID & ".scpt") as string)
		--set otherScript to ((path for script scriptNameID) as string)
	end tell
	set otherScript to load script (otherScript)
	return otherScript
end useOtherScript

on getGoAhead(usrEmail, usrSerial, myTimeout)
	set theGoAhead to 0
	
	set usrEmail to snr(usrEmail, "&", "0")
	set usrSerial to snr(usrSerial, "&", "0")
	set usrEmail to snr(usrEmail, "?", "0")
	set usrSerial to snr(usrSerial, "?", "0")
	
	set myHomeDate to (get (month of (current date)) as integer) as string
	set myInfoURL to (homeRootURL & "new_login.php") as string
	try
		set theResultingMonth to (do shell script ("curl --data " & quoted form of ("email=" & usrEmail & "&serial=" & usrSerial & "&month=" & myHomeDate) & " -e 'MyVinyl.login' " & quoted form of myInfoURL & " -m " & myTimeout)) as string
	on error
		set theResultingMonth to "15"
	end try
	
	if theResultingMonth is "15" then
		if (myTimeout as integer) is greater than 4 then
			set myOtherScript to useOtherScript("commonFunctions")
			tell myOtherScript to displayDialog((localized string "dialog_LeifertinDown"), (localized string "button_Oh"), false, (localized string "dialogHeader_Error"))
		else
			if usrEmail contains "@" then
				if usrSerial contains "-" then
					if (myTimeout as integer) is less than 5 then
						tell window "registerWindow"
							set editable of text field "emailAdd" to false
							set editable of text field "serialNum" to false
							set contents of text field "regStatus" to "√"
						end tell
						set enabled of menu item "regPaypal" of menu 6 of main menu to false
						set title of menu item "registerMenu" of menu 6 of main menu to (localized string "menu_ViewSerialNumber")
					end if
					set theGoAhead to 1
				end if
			end if
		end if
	else
		if (theResultingMonth as integer) is equal to (myHomeDate as integer) then
			if usrEmail contains "@" then
				if usrSerial contains "-" then
					if (myTimeout as integer) is greater than 3 then
						tell window "registerWindow"
							set editable of text field "emailAdd" to false
							set editable of text field "serialNum" to false
							set contents of text field "regStatus" to "√"
						end tell
						set enabled of menu item "regPaypal" of menu 6 of main menu to false
						set title of menu item "registerMenu" of menu 6 of main menu to (localized string "menu_ViewSerialNumber")
					end if
					set theGoAhead to 1
				end if
			end if
		end if
	end if
	
	return theGoAhead
end getGoAhead

on snr(the_string, search_string, replace_string)
	tell (a reference to my text item delimiters)
		set {old_tid, contents} to {contents, search_string}
		set {the_string, contents} to {the_string's text items, replace_string}
		set {the_string, contents} to {"" & the_string, old_tid}
	end tell
	return the_string
end snr

on split(someText, delimiter)
	set AppleScript's text item delimiters to delimiter
	set someText to someText's text items
	set AppleScript's text item delimiters to {""}
	return someText
end split