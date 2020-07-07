-- backupDB.applescript
-- myVinyl

--  Created by Leif Heflin on 5/9/10.
--  Copyright 2010 Leifertin. All rights reserved.

global appsup, pathTOCURLfile, pathTOCURLedfile, p7String, myAppSupportFolder, currentPID

on backup_DB(backupLoc)
	initializeMe()
	set exitLoop to true
	
	set o to backupLoc
	set bxd to common_split(o, "/")
	if item (count bxd) of bxd is "" then
		set bxd to reverse of rest of reverse of bxd
	end if
	set bxd to rest of bxd
	set measurethisDir to "/"
	repeat with aLoopVar from 1 to ((count bxd) - 1)
		set measurethisDir to (measurethisDir & item aLoopVar of bxd & "/") as string
	end repeat
	set measurethisDir to reverse of rest of reverse of every character of measurethisDir as string
	set measurethisDirSize to word 1 of (last paragraph of (do shell script "du -ck " & quoted form of (measurethisDir))) as integer
	set outSize to word 1 of (last paragraph of (do shell script "du -ck " & quoted form of (myAppSupportFolder))) as integer
	set totalsizes to (measurethisDirSize + outSize)
	
	repeat until exitLoop is false
		delay (1)
		--try
		set curOutFile to (do shell script "cat " & quoted form of (appsup & "tempLog.txt")) as string
		--end try
		--try
		set inSize to last paragraph of (do shell script "du -ck " & quoted form of (measurethisDir))
		set inSize to word 1 of inSize as integer
		set inSize to (totalsizes - inSize)
		--end try
		try
			set ss1 to (100 - (round ((inSize / outSize) * 100)))
			set ss2 to 85
			common_update_progress(ss1, ss2, "backupProgress")
		end try
		try
			set exitLoop2 to ((count of paragraphs in (do shell script "ps -p " & currentPID)) > 1)
		on error
			set exitLoop to false
			close panel window "backupProgress"
		end try
	end repeat
	
	common_displayDialog((localized string "dialog_FinishedBackup"), (localized string "button_Yay"), false, "")
end backup_DB

on choose menu item theObject
	if the name of theObject is "createBackup" then
		initializeMe()
		set backupLoc to POSIX path of (choose file name with prompt "Where should the backup be saved?" default name "MyVinyl Backup.7z")
		display panel window "backupProgress" attached to window "mainList"
		try
			do shell script ("rm " & quoted form of backupLoc)
		end try
		do shell script (quoted form of p7String & " a -t7z -mx3 " & quoted form of backupLoc & " " & quoted form of myAppSupportFolder & " &> " & quoted form of (((appsup & "tempLog.txt")) as string) & " & echo $!")
		set currentPID to result
		
		backup_DB(backupLoc)
		
	else if the name of theObject is "loadBackup" then
		initializeMe()
		set backupLoc to POSIX path of (choose file with prompt "Where is your backup?")
		set myAppSupportFolderUp to myAppSupportFolder
		set myAppSupportFolderUp to reverse of every character of myAppSupportFolderUp
		set myAppSupportFolderUp to rest of myAppSupportFolderUp
		repeat until item 1 of myAppSupportFolderUp is "/"
			set myAppSupportFolderUp to rest of myAppSupportFolderUp
		end repeat
		set myAppSupportFolderUp to reverse of myAppSupportFolderUp
		set myAppSupportFolderUp to myAppSupportFolderUp as string
		try
			do shell script ("rm -r " & quoted form of myAppSupportFolder)
		end try
		do shell script (quoted form of p7String & " x -y -o" & quoted form of myAppSupportFolderUp & " " & quoted form of backupLoc)
		common_displayDialog((localized string "dialog_QuitAfterBackup"), (localized string "button_Quit"), true, "")
	end if
end choose menu item

on clicked theObject
	if the name of theObject is "upgradeDB_backup" then
		initializeMe()
		hide window "upgradeDBWindow"
		set backupLoc to POSIX path of (choose file name with prompt "Where should the backup be saved?" default name "MyVinyl Backup.7z")
		show window "upgradeDBWindow"
		
		display panel window "backupProgress" attached to window "upgradeDBWindow"
		try
			do shell script ("rm " & quoted form of backupLoc)
		end try
		do shell script (quoted form of p7String & " a -t7z -mx3 " & quoted form of backupLoc & " " & quoted form of myAppSupportFolder & " &> " & quoted form of (((appsup & "tempLog.txt")) as string) & " & echo $!")
		set currentPID to result
		
		backup_DB(backupLoc)
	end if
end clicked

on initializeMe()
	set appsup to ((POSIX path of (path to me)) & ("Contents/Resources/")) as string
	set p7String to (appsup & "7za")
	set pathTOCURLfile to (appsup & "dp.pl")
	set pathTOCURLfileZIP to (appsup & "dpZIP.pl")
	set pathTOCURLedfile to (appsup & "CURLfile.yah")
	set pathTOHURLfile to (appsup & "rl.pl")
	set cancelImportVar to false
	----------
	
	set prefsFile to (quoted form of (POSIX path of (path to home folder) & "Library/Application Support/MyVinyl.prefs"))
	set o to appsup
	
	try
		set prefsfileR to do shell script "cat " & prefsFile
		try
			set currentHaveColumn to item 2 of common_split(prefsfileR, "<haveColumn>") as string
		on error
			set currentHaveColumn to "numColumn"
		end try
		try
			set currentWantColumn to item 2 of common_split(prefsfileR, "<wantColumn>") as string
		on error
			set currentWantColumn to "numColumn"
		end try
		try
			set myAZorderH to item 2 of common_split(prefsfileR, "<myAZH>") as string
		on error
			set myAZorderH to "a"
		end try
		try
			set myAZorderW to item 2 of common_split(prefsfileR, "<myAZW>") as string
		on error
			set myAZorderW to "a"
		end try
		try
			set myAppSupportFolder to item 2 of common_split(prefsfileR, "<pathToMyCollection>") as string
		on error
			set myAppSupportFolder to ((POSIX path of (path to home folder)) & "Library/Application Support/myVinyl/") as string
		end try
		
		try
			set visibleColumnsWant to item 2 of common_split(prefsfileR, "<visibleWantColumns>") as string
		on error
			set visibleColumnsWant to "1111111101"
		end try
		try
			set visibleColumnsHave to item 2 of common_split(prefsfileR, "<visibleHaveColumns>") as string
		on error
			set visibleColumnsHave to "1111111101"
		end try
	on error
		set currentHaveColumn to "numColumn"
		set currentWantColumn to "numColumn"
		set myAZorderH to "a"
		set myAZorderW to "a"
		set visibleColumnsWant to "1111111101"
		set visibleColumnsHave to "1111111101"
		set myAppSupportFolder to ((POSIX path of (path to home folder)) & "Library/Application Support/myVinyl/") as string
	end try
	
	if (count every character of visibleColumnsWant) is less than 10 then
		set visibleColumnsWant to (visibleColumnsWant & "1")
	end if
	if (count every character of visibleColumnsHave) is less than 10 then
		set visibleColumnsHave to (visibleColumnsHave & "1")
	end if
	set contents of text field "visiblePathToCollection" of window "prefsWindow" to myAppSupportFolder
	set myVinylList to (myAppSupportFolder & "myVinylList.txt") as string
	set myVinylWantList to (myAppSupportFolder & "myVinylWantList.txt") as string
	set myRecentActivityList to (myAppSupportFolder & "recentActivity.txt") as string
	
	return false
end initializeMe

on common_displayDialog(thediatext, butttext, cancelenabled, headerText)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to displayDialog(thediatext, butttext, cancelenabled, headerText)
end common_displayDialog

on common_update_progress(iteration, total_count, windowVar)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to update_progress(iteration, total_count, windowVar)
end common_update_progress

on common_split(someText, delimiter)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to split(someText, delimiter)
end common_split

on useOtherScript(scriptNameID)
	tell me
		set otherScript to POSIX file ((appsup & "Scripts/" & scriptNameID & ".scpt") as string)
		--set otherScript to ((path for script scriptNameID) as string)
	end tell
	set otherScript to load script (otherScript)
	return otherScript
end useOtherScript