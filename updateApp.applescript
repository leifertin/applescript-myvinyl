-- updateApp.applescript
-- myVinyl

--  Created by Leif Heflin on 5/9/10.
--  Copyright 2010 Leifertin. All rights reserved.

global theDownloadGo, appsup, pathTOCURLfile, pathTOCURLedfile, thedownloadsite, ver, update_v

property current_version : "2.34"

on updateMePlus()
	initializeMe_SM()
	set visible of progress indicator 1 of window "updatewindow" to false
	set the text color of text view 1 of scroll view 1 of window "updatewindow" to "white"
	set title of button 1 of window "updatewindow" to (localized string "button_Close")
	set the contents of text view 1 of scroll view 1 of window "updatewindow" to ""
	try
		set update_f to "http://grayarea.be/app/MyVinyl/toDofor2.html" as string
		try
			do shell script ("rm " & quoted form of (pathTOCURLedfile))
		end try
		set pingMySite to (do shell script "ping -t3 -o grayarea.be") as string
		do shell script ("perl " & quoted form of pathTOCURLfile & " " & quoted form of update_f & " " & quoted form of (pathTOCURLedfile))
		set update_c to do shell script ("cat " & quoted form of (pathTOCURLedfile))
		do shell script ("rm " & quoted form of (pathTOCURLedfile))
		set current_version_int to cv_string2int(current_version)
	on error
		lastCheckForConnection()
	end try
	
	set update_c_download to (item 2 of split(update_c, "<!--download-->")) as string
	set update_c_complete to (item 2 of split(update_c, "<!--complete-->")) as string
	set update_c_incomplete to (item 2 of split(update_c, "<!--incomplete-->")) as string
	
	set update_c to ""
	
	set update_v to (item 1 of split(update_c_download, "<br><br>")) as string
	set update_v to (last item of split(update_v, "<!--v")) as string
	set update_v to split(update_v, "-->") as string
	set update_v_int to cv_string2int(update_v)
	--GOT VERSION
	
	display panel window "updatewindow" attached to window "mainList"
	
	set changelog_text to update_c_complete
	set changelog_text to item 1 of split(changelog_text, ("<!--v" & current_version & "-->")) as string
	try
		set changelog_text_splitter to item 2 of split(changelog_text, ("<h4>")) as string
		set changelog_text_splitter to item 1 of split(changelog_text_splitter, (" />")) as string
		set changelog_text to snr(changelog_text, changelog_text_splitter, "") as string
	end try
	
	set changelog_text to snr(changelog_text, "	", "")
	set changelog_text to snr(changelog_text, "<li>", " • ")
	set changelog_text to snr(changelog_text, "</li>", "")
	set changelog_text to snr(changelog_text, "<i>", "(")
	set changelog_text to snr(changelog_text, "</i>", ")")
	set changelog_text to snr(changelog_text, "<ul>", "<br>")
	set changelog_text to snr(changelog_text, "</b>", "")
	set changelog_text to snr(changelog_text, "</ul>", "<br>")
	set changelog_text to snr(changelog_text, "<b>", "")
	set changelog_text to snr(changelog_text, "</ul>", "")
	set changelog_text to snr(changelog_text, "<br><br>", "	")
	set changelog_text to snr(changelog_text, "<div style=\"margin-top:5px; display:none; border:0px;\"><p>", "")
	set changelog_text to snr(changelog_text, "<h4> />", "")
	set changelog_text to snr(changelog_text, "</h4>", "")
	set changelog_text to snr(changelog_text, "</p>", "")
	set changelog_text to snr(changelog_text, "</div>", "")
	
	set update_v_int_1 to (item 1 of split(update_v_int, ",")) as string
	set current_version_int_1 to (item 1 of split(current_version_int, ",")) as string
	set update_v_int_2 to (item 2 of split(update_v_int, ",")) as string
	set current_version_int_2 to (item 2 of split(current_version_int, ",")) as string
	
	set update_v_int_2 to split(update_v_int_2, ".") as string
	set current_version_int_2 to split(current_version_int_2, ".") as string
	
	--MATCH 1st Items
	if (count (every character of current_version_int_1)) is greater than (count (every character of update_v_int_1)) then
		repeat with artichoke from 1 to ((count (every character of current_version_int_1)) - (count (every character of update_v_int_1)))
			set update_v_int_1 to (update_v_int_1 & "0") as string
		end repeat
	else if (count (every character of current_version_int_1)) is less than (count (every character of update_v_int_1)) then
		repeat with artichoke from 1 to ((count (every character of update_v_int_1)) - (count (every character of current_version_int_1)))
			set current_version_int_1 to (current_version_int_1 & "0") as string
		end repeat
	end if
	
	--MATCH 2nd Items
	if (count (every character of current_version_int_2)) is greater than (count (every character of update_v_int_2)) then
		repeat with artichoke from 1 to ((count (every character of current_version_int_2)) - (count (every character of update_v_int_2)))
			if update_v_int_2 is not "!" then
				set update_v_int_2 to (update_v_int_2 & "0") as string
			end if
		end repeat
	else if (count (every character of current_version_int_2)) is less than (count (every character of update_v_int_2)) then
		repeat with artichoke from 1 to ((count (every character of update_v_int_2)) - (count (every character of current_version_int_2)))
			if current_version_int_2 is not "!" then
				set current_version_int_2 to (current_version_int_2 & "0") as string
			end if
		end repeat
	end if
	
	
	if (update_v_int_1) is greater than (current_version_int_1) then
		set changelog_text to item 1 of split(changelog_text, ("<!--v" & current_version & "-->")) as string
		finishUpdateLoad(update_c_download)
	else if (update_v_int_1) is less than (current_version_int_1) then
		set changelog_text to item 1 of split(changelog_text, ("<!--v" & update_v & "-->")) as string
		set contents of (text field 1 of window "updatewindow") to "You are using the newest version in existence!"
	else if (update_v_int_1) is equal to (current_version_int_1) then
		--CHECK OTHER SIDE
		if (update_v_int_2) is equal to (current_version_int_2) then
			set changelog_text to item 1 of split(changelog_text, ("<!--v" & update_v & "-->")) as string
			set contents of (text field 1 of window "updatewindow") to "You are using the newest version in existence!"
		else if (update_v_int_2) is "!" then
			set changelog_text to item 1 of split(changelog_text, ("<!--v" & current_version & "-->")) as string
			finishUpdateLoad(update_c_download)
		else if (current_version_int_2) is "!" then
			set changelog_text to item 1 of split(changelog_text, ("<!--v" & update_v & "-->")) as string
			set contents of (text field 1 of window "updatewindow") to "You are using the newest version in existence!"
		else if (update_v_int_2 as integer) is greater than (current_version_int_2 as integer) then
			set changelog_text to item 1 of split(changelog_text, ("<!--v" & current_version & "-->")) as string
			finishUpdateLoad(update_c_download)
		else if (update_v_int_2 as integer) is less than (current_version_int_2 as integer) then
			set changelog_text to item 1 of split(changelog_text, ("<!--v" & update_v & "-->")) as string
			set contents of (text field 1 of window "updatewindow") to "You are using the newest version in existence!"
		end if
	end if
	
	set changelog_text_l to every paragraph of changelog_text
	repeat with ch_loopV from 1 to (count changelog_text_l)
		if ((item ch_loopV of changelog_text_l) as string) starts with "<!--v" then
			set (item ch_loopV of changelog_text_l) to ""
		end if
	end repeat
	set changelog_text to changelog_text_l as string
	
	set changelog_text to snr(changelog_text, "<br>", "
")
	set the contents of text view 1 of scroll view 1 of window "updatewindow" to changelog_text
end updateMePlus

on choose menu item theObject
	if the name of theObject is "update" then
		updateMePlus()
	else if the name of theObject is "homepageMenuItem" then
		open location "http://grayarea.be"
	else if the name of theObject is "contactdev" then
		open location "mailto:leifh90@gmail.com?Subject=MyVinyl Feedback (v" & current_version & ")"
	end if
end choose menu item

on clicked theObject
	if the name of theObject is "closeupdate" then
		set theDownloadGo to false
		close panel window "updatewindow"
		set enabled of button "downloadupdate" of window "updatewindow" to false
	else if the name of theObject is "downloadupdate" then
		set enabled of button "downloadupdate" of window "updatewindow" to false
		set abxi to ("curl " & thedownloadsite & " -o " & quoted form of ((POSIX path of (path to desktop)) & "MyVinyl " & update_v & ".dmg") & " &> " & quoted form of (appsup & "updateLog.txt") & " & echo $!")
		do shell script abxi
		set updatePID to result
		set theDownloadGo to true
		
		set visible of progress indicator 1 of window "updatewindow" to true
		set visible of button "downloadupdate" of window "updatewindow" to false
		set theDownloadGo to true
		set (the contents of text field 1 of window "updatewindow") to (localized string "dialog_DownloadingDesktop")
		
		repeat until theDownloadGo is false
			delay (0.5)
			try
				set curOutUpdateFile to (do shell script "cat " & quoted form of (appsup & "updateLog.txt")) as string
				set curOutUpdateFile to (word 1 of (the last paragraph of curOutUpdateFile)) as string
			end try
			common_update_progress(curOutUpdateFile, 100, "updatewindow")
			set thisWeirdNumber to (100 - curOutUpdateFile)
			set (the contents of text field 1 of window "updatewindow") to ((localized string "dialog_DownloadingDesktop") & thisWeirdNumber & "% " & snr((localized string "dialog_DownloadingRemaining"), "50%", ""))
			try
				((count of paragraphs in (do shell script "ps -p " & updatePID)) > 1)
			on error
				set (the contents of text field 1 of window "updatewindow") to ""
				set theDownloadGo to false
				set curOutUpdateFile to (do shell script "cat " & quoted form of (appsup & "updateLog.txt")) as string
				common_update_progress(0, 100, "updatewindow")
				set visible of progress indicator 1 of window "updatewindow" to false
				set title of button 1 of window "updatewindow" to (localized string "button_Close")
			end try
		end repeat
		try
			do shell script "kill " & updatePID
		end try
		set theDownloadGo to false
	end if
end clicked

on common_update_progress(iteration, total_count, windowVar)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to update_progress(iteration, total_count, windowVar)
end common_update_progress

on initializeMe_SM()
	set theDownloadGo to false
	set appsup to ((POSIX path of (path to me)) & ("Contents/Resources/")) as string
	set p7String to (appsup & "7za")
	set pathTOCURLfile to (appsup & "dp.pl")
	set pathTOCURLfileZIP to (appsup & "dpZIP.pl")
	set pathTOCURLedfile to (appsup & "CURLfile.yah")
	set pathTOHURLfile to (appsup & "rl.pl")
end initializeMe_SM

on common_displayDialog(thediatext, butttext, cancelenabled, headerText)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to displayDialog(thediatext, butttext, cancelenabled, headerText)
end common_displayDialog

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

on cv_string2int(cv_string)
	set cv_int to snr(cv_string, ",", "")
	set cv_int to snr(cv_int, "b", ",") as string
	
	if cv_int does not contain "," then
		set cv_int to (cv_int & ",!") as string
	end if
	return cv_int
end cv_string2int

on finishUpdateLoad(update_c_download)
	set contents of (text field 1 of window "updatewindow") to "You are using v" & current_version & ".
You could be using v" & update_v & "."
	set update_dlURL to (item 2 of split(update_c_download, ("<!--v" & update_v & "-->")))
	set update_dlURL to (item 1 of split(update_dlURL, ("\">")))
	set update_dlURL to (item 2 of split(update_dlURL, ("<a href=\""))) as string
	set thedownloadsite to update_dlURL as string
	set enabled of button "downloadupdate" of window "updatewindow" to true
	set visible of button "downloadupdate" of window "updatewindow" to true
end finishUpdateLoad

on lastCheckForConnection()
	try
		set bcs to (do shell script "ping -t4 -o google.com") as string
	on error
		common_displayDialog((localized string "dialog_InternetDown"), (localized string "button_Oh"), false, "")
		error number -128
	end try
	common_displayDialog((localized string "dialog_LeifertinDown"), (localized string "button_Oh"), false, "")
	error number -128
end lastCheckForConnection

on useOtherScript(scriptNameID)
	tell me
		set otherScript to POSIX file ((appsup & "Scripts/" & scriptNameID & ".scpt") as string)
		--set otherScript to ((path for script scriptNameID) as string)
	end tell
	set otherScript to load script (otherScript)
	return otherScript
end useOtherScript