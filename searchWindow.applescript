-- searchWindow.applescript
-- myVinyl

--  Created by Leif Heflin on 5/9/10.
--  Copyright 2010 Leifertin. All rights reserved.

global appsup, theSearchDataSource, currentlisttype, myAppSupportFolder, myVinylList, myVinylWantList, myVinylListCatalog, myVinylWantListCatalog

on action theObject
	set appsup to (POSIX path of (path to me) & ("Contents/Resources/")) as string
	if the name of theObject is "searchBox" then
		set visible of scroll view 1 of window "searchWindow" to false
		initializeMe()
		set searchString to contents of text field "searchBox" of window "searchWindow" as string
		if (name of current tab view item of tab view 1 of view 1 of split view "mainSplitView" of window "mainList") is "haveTab" then
			set currentlisttype to "have"
		else
			set currentlisttype to "want"
		end if
		try
			delete data source theSearchDataSource
		end try
		if (searchString) is not "" then
			set theSearchDataSource to make new data source at end of data sources
			tell theSearchDataSource
				make new data column at end of data columns with properties {name:"catalog", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"info", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
			end tell
			
			set data source of table view 1 of scroll view 1 of window "searchWindow" to theSearchDataSource
			set mySearchResults to (do shell script ("cd " & quoted form of appsup & ";ksh searchLPS" & currentlisttype & ".sh " & quoted form of (searchString))) as string
			--set mySearchResults to snr(mySearchResults, (ASCII character 10), (ASCII character 13))
			set mySearchResults to every paragraph of mySearchResults
			
			if (count mySearchResults) is less than 1 then
				set visible of scroll view 1 of window "searchWindow" to false
			else
				set visible of scroll view 1 of window "searchWindow" to true
			end if
			
			--FILTER OUT "</trackTitle>" Items
			
			set myCatalogColumns to {}
			set myInfoColumns to {}
			
			repeat with myRepeatVar from 1 to (count mySearchResults)
				set currentSplitCells to (split((item myRepeatVar of mySearchResults), "	"))
				set (item 1 of currentSplitCells) to snr((item 1 of currentSplitCells), "~", " ")
				set (item 1 of currentSplitCells) to snr((item 1 of currentSplitCells), "....", "/")
				set (item 1 of currentSplitCells) to snr((item 1 of currentSplitCells), "..+", "....")
				set myCatalogColumn to (item 1 of currentSplitCells) as string
				set myInfoColumn to (last item of currentSplitCells as string)
				
				if myInfoColumn ends with "</trackTitle>" then
					set myInfoColumn to ""
					set myCatalogColumn to ""
				else
					set myInfoColumn to split(myInfoColumn, "<trackPosition>") as string
					set myInfoColumn to split(myInfoColumn, "</trackPosition>") as string
				end if
				
				set myCatalogColumns to myCatalogColumns & {myCatalogColumn}
				set myInfoColumns to myInfoColumns & {myInfoColumn}
			end repeat
			
			set myCatalogColumns to common_cleanMyList(myCatalogColumns, {""})
			set myInfoColumns to common_cleanMyList(myInfoColumns, {""})
			
			--POPULATE DATA SOURCE
			
			repeat with myRepeatVar from 1 to (count myCatalogColumns)
				tell theSearchDataSource
					make new data row at end of data rows
					set contents of data cell "catalog" of data row myRepeatVar to (item myRepeatVar of myCatalogColumns as string)
					set contents of data cell "info" of data row myRepeatVar to (item myRepeatVar of myInfoColumns as string)
				end tell
			end repeat
			
		end if
	end if
end action

on should close theObject
	if the name of theObject is "searchWindow" then
		hide window "searchWindow"
		return false
	end if
end should close

on column clicked theObject table column tableColumn
	--try
	-- Get the data source of the table view
	set theDataSource to data source of theObject
	
	-- Get the identifier of the clicked table column
	set theColumnIdentifier to identifier of tableColumn
	
	set the sort column of theDataSource to data column theColumnIdentifier of theDataSource
	set the sort case sensitivity of the sort column of theDataSource to case sensitive
	set sorted of theDataSource to true
	
	-- Get the current sort column of the data source
	set theSortColumn to sort column of theDataSource
	
	-- If the current sort column is not the same as the clicked column then switch the sort column
	if (name of theSortColumn) is not equal to theColumnIdentifier then
		set the sort column of theDataSource to data column theColumnIdentifier of theDataSource
	else
		-- Otherwise change the sort order
		if sort order of theSortColumn is ascending then
			set the sort case sensitivity of theSortColumn to case sensitive
			set sort order of theSortColumn to descending
		else
			set the sort case sensitivity of theSortColumn to case sensitive
			set sort order of theSortColumn to ascending
		end if
	end if
	
	-- We need to update the table view (so it will be redrawn)
	update theObject
	--end try
	set theSearchDataSource to data source of table view 1 of scroll view 1 of window "searchWindow"
end column clicked

on double clicked theObject
	--some text here
end double clicked

on clicked theObject
	if the name of theObject is "closeSearchWindow" then
		close panel window "searchWindow"
	end if
end clicked

on split(someText, delimiter)
	set AppleScript's text item delimiters to delimiter
	set someText to someText's text items
	set AppleScript's text item delimiters to {""}
	return someText
end split
on snr(the_string, search_string, replace_string)
	tell (a reference to my text item delimiters)
		set {old_tid, contents} to {contents, search_string}
		set {the_string, contents} to {the_string's text items, replace_string}
		set {the_string, contents} to {"" & the_string, old_tid}
	end tell
	return the_string
end snr

on initializeMe()
	set currentlisttype to "have"
	set currentFolderType to "Collection"
	set currentBottomType to "credits"
	set skipTheRest to false
	set appsup to ((POSIX path of (path to me)) & ("Contents/Resources/")) as string
	set p7String to (appsup & "7za")
	set pathTOCURLfile to (appsup & "dp.pl")
	set pathTOCURLedfile to (appsup & "CURLfile.yah")
	set pathTOHURLfile to (appsup & "rl.pl")
	set cancelImportVar to false
	set userListFail to false
	----------
	
	set prefsFile to (quoted form of (POSIX path of (path to home folder) & "Library/Application Support/MyVinyl.prefs"))
	set o to appsup
	
	try
		set prefsfileR to do shell script "cat " & prefsFile
		try
			set myAppSupportFolder to item 2 of split(prefsfileR, "<pathToMyCollection>") as string
		on error
			set myAppSupportFolder to ((POSIX path of (path to home folder)) & "Library/Application Support/myVinyl/") as string
		end try
		
	on error
		set myAppSupportFolder to ((POSIX path of (path to home folder)) & "Library/Application Support/myVinyl/") as string
	end try
	
	set myVinylList to (myAppSupportFolder & "myVinylList.txt") as string
	set myVinylWantList to (myAppSupportFolder & "myVinylWantList.txt") as string
	set myRecentActivityList to (myAppSupportFolder & "recentActivity.txt") as string
	return false
end initializeMe

----
----
----
on useOtherScript(scriptNameID)
	tell me
		set otherScript to POSIX file ((appsup & "Scripts/" & scriptNameID & ".scpt") as string)
		--set otherScript to ((path for script scriptNameID) as string)
	end tell
	set otherScript to load script (otherScript)
	return otherScript
end useOtherScript

on common_cleanMyList(theList, itemsToDelete)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to cleanMyList(theList, itemsToDelete)
end common_cleanMyList
