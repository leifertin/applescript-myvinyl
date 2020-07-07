-- searchXML.applescript
-- myVinyl

--  Created by Leif Heflin on 5/9/10.
--  Copyright 2010 Leifertin. All rights reserved.

global allOfMyTypes, appsup, allOfMyTitles, allOfMySummaries, pathTOCURLedfile, pathTOCURLfileZIP, mySMTotal, allOfMyURLs, pageGrabberLoop, myRecentActivityListContents, theSearchXMLDataSource, searchString, searchType, myNumberOfResults

on action theObject
	if the name of theObject is "searchBox" then
		initializeMe_SM()
		set pageGrabberLoop to 1
		set mySMTotal to 0
		set searchString to contents of text field "searchBox" of window "searchXMLWindow" as string
		set searchType to title of popup button "searchType" of window "searchXMLWindow" as string
		set searchType to changeCase_lower(searchType)
		
		if searchType is "Needs Vote" then
			set searchType to "needsvote"
		else if searchType is "Catalog" then
			set searchType to "catno"
		else if searchType is "For Sale" then
			set searchType to "forsale"
		end if
		set visible of tab view 1 of view 2 of split view 1 of window "searchXMLWindow" to false
		--set visible of button "moreSearchResults" of view 1 of split view 1 of window "searchXMLWindow" to true
		set visible of button "addFromSearch" of window "searchXMLWindow" to false
		set the contents of text field "searchCountBox" of view 1 of split view 1 of window "searchXMLWindow" to ""
		
		if searchString is "" then
			set myNumberOfResults to 0
		else
			set myNumberOfResults to searchDiscogsXML(searchType, searchString)
		end if
		
		
		if myNumberOfResults is "ERROR_Discogs_Fail" then
			display alert "Discogs is not responding."
		else
			if myNumberOfResults is less than 1 then
				set visible of split view 1 of window "searchXMLWindow" to false
			else
				set visible of split view 1 of window "searchXMLWindow" to true
				
				try
					delete data source theSearchXMLDataSource
				end try
				set theSearchXMLDataSource to make new data source at end of data sources
				tell theSearchXMLDataSource
					make new data column at end of data columns with properties {name:"type", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"title", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"summary", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"urli", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				end tell
				
				set data source of table view 1 of scroll view 1 of view 1 of split view 1 of window "searchXMLWindow" to theSearchXMLDataSource
				--POPULATE DATA SOURCE
				
				repeat with myRepeatVar from 1 to myNumberOfResults
					tell theSearchXMLDataSource
						try
							set haha to (item myRepeatVar of allOfMyTypes as string)
							make new data row at end of data rows
							set contents of data cell "type" of data row myRepeatVar to (item myRepeatVar of allOfMyTypes as string)
							set contents of data cell "title" of data row myRepeatVar to (item myRepeatVar of allOfMyTitles as string)
							set contents of data cell "summary" of data row myRepeatVar to (item myRepeatVar of allOfMySummaries as string)
							set contents of data cell "urli" of data row myRepeatVar to (item myRepeatVar of allOfMyURLs as string)
						on error number (-1700)
							set myRepeatVar to (myRepeatVar - 1)
							exit repeat
						end try
					end tell
				end repeat
				set mySMTotal to myRepeatVar
				if myNumberOfResults is 0 then
					set myItemsString to (localized string "misc_ZeroItems")
				else
					set myItemsString to (localized string "misc_MoreItems")
				end if
				
				set myItemsString to split(myItemsString, "0 ") as string
				
				set myTotalCountString to split((localized string "misc_partOfWhole"), "1") as string
				set myTotalCountString to split(myTotalCountString, "2") as string
				set myTotalCountString to ((mySMTotal & myTotalCountString & myNumberOfResults & " " & myItemsString) as string)
				
				set the contents of text field "searchCountBox" of view 1 of split view 1 of window "searchXMLWindow" to myTotalCountString
			end if
		end if
	end if
end action

on should close theObject
	(**)
end should close

on column clicked theObject table column tableColumn
	(*
	
	*)
end column clicked

on clicked theObject
	if the name of theObject is "moreSearchResults" then
		--set the contents of text field "searchCountBox" of view 1 of split view 1 of window "searchXMLWindow" to ""
		if searchString is "" then
			set myNumberOfResults to 0
		else
			set myNumberOfResults to searchDiscogsXML(searchType, searchString)
		end if
		
		if myNumberOfResults is "ERROR_Discogs_Fail" then
			display alert "Discogs is not responding."
		else
			if myNumberOfResults is less than 1 then
				set visible of split view 1 of window "searchXMLWindow" to false
			else
				set visible of split view 1 of window "searchXMLWindow" to true
				--set the contents of text field "searchCountBox" of view 1 of split view 1 of window "searchXMLWindow" to ((myNumberOfResults) as string)
				
				try
					delete data source theSearchXMLDataSource
				end try
				set theSearchXMLDataSource to make new data source at end of data sources
				tell theSearchXMLDataSource
					make new data column at end of data columns with properties {name:"type", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"title", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"summary", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"urli", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				end tell
				
				set data source of table view 1 of scroll view 1 of view 1 of split view 1 of window "searchXMLWindow" to theSearchXMLDataSource
				--POPULATE DATA SOURCE
				
				repeat with myRepeatVar from 1 to myNumberOfResults
					tell theSearchXMLDataSource
						try
							set haha to (item myRepeatVar of allOfMyTypes as string)
							make new data row at end of data rows
							set contents of data cell "type" of data row myRepeatVar to (item myRepeatVar of allOfMyTypes as string)
							set contents of data cell "title" of data row myRepeatVar to (item myRepeatVar of allOfMyTitles as string)
							set contents of data cell "summary" of data row myRepeatVar to (item myRepeatVar of allOfMySummaries as string)
							set contents of data cell "urli" of data row myRepeatVar to (item myRepeatVar of allOfMyURLs as string)
						on error number (-1700)
							set myRepeatVar to (myRepeatVar - 1)
							exit repeat
						end try
					end tell
				end repeat
				set mySMTotal to myRepeatVar
				
				set myItemsString to (localized string "misc_MoreItems")
				set myItemsString to split(myItemsString, "0 ") as string
				
				set myTotalCountString to split((localized string "misc_partOfWhole"), "1") as string
				set myTotalCountString to split(myTotalCountString, "2") as string
				set myTotalCountString to ((mySMTotal & myTotalCountString & myNumberOfResults & " " & myItemsString) as string)
				
				set the contents of text field "searchCountBox" of view 1 of split view 1 of window "searchXMLWindow" to myTotalCountString
				
			end if
		end if
	end if
end clicked

on selection changed theObject
	(*
	
*)
end selection changed

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

on searchDiscogsXML(searchType, searchQ)
	--initializeMe_SM()
	set searchQ to snr(searchQ, space, "+")
	--set myTotalURL to ("http://www.discogs.com/search?type=" & searchType & "&q=" & searchQ & "&f=xml&api_key=55487673c2&page=" & pageGrabberLoop)
	set myTotalURL to ("http://api.discogs.com/search?type=" & searchType & "&q=" & searchQ & "&f=xml&page=" & pageGrabberLoop)
	
	try
		set mySearchResults to do shell script ("rm " & quoted form of (pathTOCURLedfile))
	end try
	
	do shell script ("perl " & quoted form of pathTOCURLfileZIP & " " & quoted form of myTotalURL & " " & quoted form of (pathTOCURLedfile))
	set mySearchResults to do shell script ("cat " & quoted form of (pathTOCURLedfile))
	
	--display dialog "" default answer mySearchResults
	
	if mySearchResults contains "Discogs is currently unavailable while we perform system maintenance. We will be back to normal shortly." then
		set visible of button "moreSearchResults" of view 1 of split view 1 of window "searchXMLWindow" to false
		return "ERROR_Discogs_Fail" as string
	else
		set mySearchResults to split(mySearchResults, "</result>")
		set xxx to 0
		repeat with pageGrabSubLoop in mySearchResults
			set xxx to xxx + 1
			if pageGrabSubLoop contains "numResults=" then
				set myNumberOfResults to (item 2 of split((item xxx of mySearchResults), "numResults=\""))
				exit repeat
			end if
		end repeat
		
		set myStartNum to word 1 of (item 2 of split(myNumberOfResults, "\" start=\"")) as integer
		set myNumberOfResults to (item 1 of split(myNumberOfResults, "\" start=\"")) as integer
		
		if myStartNum is less than or equal to myNumberOfResults then
			if myNumberOfResults is less than 21 then
				set visible of button "moreSearchResults" of view 1 of split view 1 of window "searchXMLWindow" to false
			else
				set visible of button "moreSearchResults" of view 1 of split view 1 of window "searchXMLWindow" to true
			end if
			if myNumberOfResults is equal to mySMTotal then
				set visible of button "moreSearchResults" of view 1 of split view 1 of window "searchXMLWindow" to false
			end if
			set mySearchResults to common_cleanMyList(mySearchResults, {"", "</searchresults></resp>"})
			
			if myNumberOfResults is not 0 then
				if pageGrabberLoop is 1 then
					set allOfMyTypes to {}
					set allOfMyTitles to {}
					set allOfMySummaries to {}
					set allOfMyURLs to {}
				end if
				
				set pageGrabberLoop to (pageGrabberLoop + 1)
				
				repeat with mySearchLoop from 1 to (count mySearchResults)
					set myCurrentResultItem to (item mySearchLoop of mySearchResults)
					
					set titleOfItem to item 2 of split(myCurrentResultItem, "<title>")
					set titleOfItem to item 1 of split(titleOfItem, "</title>") as string
					set titleOfItem to common_cleanMyHTML(titleOfItem)
					
					try
						set summaryOfItem to item 2 of split(myCurrentResultItem, "<summary>")
						set summaryOfItem to item 1 of split(summaryOfItem, "</summary>") as string
						set summaryOfItem to common_cleanMyHTML(summaryOfItem)
					on error
						set summaryOfItem to ""
					end try
					
					set rIDOfItem to item 2 of split(myCurrentResultItem, "<uri>")
					set rIDOfItem to item 1 of split(rIDOfItem, "</uri>")
					set myrIDOSplit to split(rIDOfItem, "/")
					set rIDOfItem to last item of myrIDOSplit as string
					
					set rTypeOfItem to item ((count myrIDOSplit) - 1) of myrIDOSplit as string
					
					if summaryOfItem is not "" then
						if ((state of button "vinylOnly" of window "searchXMLWindow") as string) is "1" then
							if summaryOfItem contains "Vinyl" then
								set allOfMyTypes to allOfMyTypes & {rTypeOfItem}
								set allOfMyTitles to allOfMyTitles & {titleOfItem}
								set allOfMySummaries to allOfMySummaries & {summaryOfItem}
								set allOfMyURLs to allOfMyURLs & {rIDOfItem}
							end if
						else
							set allOfMyTypes to allOfMyTypes & {rTypeOfItem}
							set allOfMyTitles to allOfMyTitles & {titleOfItem}
							set allOfMySummaries to allOfMySummaries & {summaryOfItem}
							set allOfMyURLs to allOfMyURLs & {rIDOfItem}
						end if
					end if
				end repeat
			end if
		else
			set visible of button "moreSearchResults" of view 1 of split view 1 of window "searchXMLWindow" to false
		end if
		return myNumberOfResults
	end if
end searchDiscogsXML

on loadPage from theURL
	set URLWithString to call method "URLWithString:" of class "NSURL" with parameter theURL
	set requestWithURL to call method "requestWithURL:" of class "NSURLRequest" with parameter URLWithString
	tell view 2 of split view 1 of window "searchXMLWindow"
		set mainFrame to call method "mainFrame" of object (view "searchXMLWebView")
	end tell
	call method "loadRequest:" of mainFrame with parameter requestWithURL
end loadPage

on common_cleanMyHTML(cleanString)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to cleanMyHTML(cleanString)
end common_cleanMyHTML

on common_cleanMyList(theList, itemsToDelete)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to cleanMyList(theList, itemsToDelete)
end common_cleanMyList

on useOtherScript(scriptNameID)
	initializeMe_SM()
	tell me
		set otherScript to POSIX file ((appsup & "Scripts/" & scriptNameID & ".scpt") as string)
		--set otherScript to ((path for script scriptNameID) as string)
	end tell
	set otherScript to load script (otherScript)
	return otherScript
end useOtherScript

on initializeMe_SM()
	set theDownloadGo to false
	set appsup to ((POSIX path of (path to me)) & ("Contents/Resources/")) as string
	set p7String to (appsup & "7za")
	set pathTOCURLfile to (appsup & "dp.pl")
	set pathTOCURLfileZIP to (appsup & "dpZIP.pl")
	set pathTOCURLedfile to (appsup & "CURLfile.yah")
	set pathTOHURLfile to (appsup & "rl.pl")
end initializeMe_SM

on changeCase_lower(myCHString)
	return (do shell script " echo " & myCHString & " | tr '[:upper:]' '[:lower:]'")
end changeCase_lower
----
----
----