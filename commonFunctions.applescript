-- commonFunctions.applescript
-- myVinyl

--  Created by Leif Heflin on 5/9/10.
--  Copyright 2010 Leifertin. All rights reserved.

on displayDialog(thediatext, butttext, cancelenabled, headerText)
	set visible of button 2 of window "dialogwindow" to cancelenabled
	set the title of button "confirmdialog" of window "dialogwindow" to butttext
	set the contents of text field "textofdialogwindow" of window "dialogwindow" to thediatext
	set the contents of text field "dialogHeader" of window "dialogwindow" to headerText
	if visible of window "mainList" is false then
		display panel window "dialogwindow" attached to window 1
	else
		display panel window "dialogwindow" attached to window "mainList"
	end if
end displayDialog

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

on findCatalogDupes(getSelected, currentFType, t_releaseCatalog, myAppSupportFolder, currentlisttype)
	set anInfinite to 0
	set myCatalogs to every paragraph of (do shell script ("ls " & quoted form of (myAppSupportFolder & currentFType & "/")))
	
	repeat
		set myCommonCatalogs to 0
		repeat with loopy from 1 to (count myCatalogs)
			if ((item loopy of myCatalogs) as string) is (t_releaseCatalog) then
				set myCommonCatalogs to (myCommonCatalogs + 1)
				exit repeat
			end if
		end repeat
		if myCommonCatalogs is greater than 0 then
			set anInfinite to (anInfinite + 1)
			set t_releaseCatalog to (item 1 of split(t_releaseCatalog, (" (~"))) as string
			set t_releaseCatalog to (t_releaseCatalog & (" (~" & (anInfinite) & "~)")) as string
		else
			do shell script (("cd " & quoted form of (myAppSupportFolder & currentFType & "/") & ";mkdir " & quoted form of (t_releaseCatalog & "/") as string))
			if getSelected is "both" then
				set t_releaseCatalog to catalogFlip(t_releaseCatalog, "view")
				tell (view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
					set contents of data cell "catalogColumn" of selected data row of (table view 1 of scroll view 1) to t_releaseCatalog
				end tell
			end if
			exit repeat
		end if
	end repeat
	return t_releaseCatalog
end findCatalogDupes

on placeZeros(myDataSource, a, endVal)
	set myCellWrite to getZeros(a, endVal)
	set contents of data cell "numColumn" of data row a of myDataSource to (myCellWrite as string)
end placeZeros

on getZeros(a, endVal)
	set a to a as integer
	if (a is less than 10) then
		set myCellWrite to ("00000" & a)
	else if (a is less than 100) then
		set myCellWrite to ("0000" & a)
	else if (a is less than 1000) then
		set myCellWrite to ("000" & a)
	else if (a is less than 10000) then
		set myCellWrite to ("00" & a)
	else if (a is less than 100000) then
		set myCellWrite to ("0" & a)
	else
		set myCellWrite to (a)
	end if
	
	if (endVal as integer) is less than 10 then
		set myTakeAmt to 5
	else if (endVal as integer) is less than 100 then
		set myTakeAmt to 4
	else if (endVal as integer) is less than 1000 then
		set myTakeAmt to 3
	else if (endVal as integer) is less than 10000 then
		set myTakeAmt to 2
	else if (endVal as integer) is less than 100000 then
		set myTakeAmt to 1
	end if
	
	set myCellWrite to every character of myCellWrite
	repeat with barI from 1 to myTakeAmt
		set myCellWrite to rest of myCellWrite
		---
	end repeat
	set myCellWrite to myCellWrite as string
	return myCellWrite
end getZeros

on catalogFlip(tmp_releaseCatalog, flipDirection)
	if flipDirection is "file" then
		set tmp_releaseCatalog to snr(tmp_releaseCatalog, "....", "..+")
		set tmp_releaseCatalog to snr(tmp_releaseCatalog, "/", "....")
		return tmp_releaseCatalog
	else if flipDirection is "view" then
		set tmp_releaseCatalog to snr(tmp_releaseCatalog, "....", "/")
		set tmp_releaseCatalog to snr(tmp_releaseCatalog, "..+", "....")
		return tmp_releaseCatalog
	else
		return "error, dude."
	end if
end catalogFlip

on cleanMyList(theList, itemsToDelete)
	set cleanList to {}
	repeat with i from 1 to count theList
		if {theList's item i} is not in itemsToDelete then set cleanList's end to theList's item i
	end repeat
	return cleanList
end cleanMyList

on cleanMyHTML(cleanString)
	set myCleanHTMLr to {"&", "<", ">", " ", "¢", "£", "¥", "€", "§", "©", "®", "™", "", "", "", "", "", ""}
	set myI to 0
	repeat with myCleanHTMLi in {"&amp;", "&lt;", "&gt;", "&nbsp;", "&cent;", "&pound;", "&yen;", "&euro;", "&sect;", "&copy;", "&reg;", "&trade;", "<b>", "</b>", "<i>", "</i>", "<small>", "</small>"}
		set myI to (myI + 1)
		set cleanString to snr(cleanString, myCleanHTMLi, ((item myI of myCleanHTMLr) as string))
	end repeat
	return cleanString
end cleanMyHTML

on alphabetize(the_list)
	set ascii_10 to ASCII character 10
	tell (a reference to my text item delimiters)
		set {old_atid, contents} to {contents, ascii_10}
		set {the_list, contents} to {the_list as Unicode text, old_atid}
	end tell
	set the_list to (do shell script "echo " & quoted form of the_list & " | sort")'s paragraphs
end alphabetize

on update_progress(iteration, total_count, windowVar)
	tell window windowVar
		if iteration = 1 then
			tell progress indicator 1 to start
			set indeterminate of progress indicator 1 to true
		else
			tell progress indicator 1 to stop
			set indeterminate of progress indicator 1 to false
		end if
		set maximum value of progress indicator 1 to total_count
		set content of progress indicator 1 to iteration
		update
	end tell
end update_progress

on totalCountText(haveORwant, emptyTotal, myTempListCatalog)
	if haveORwant is "have" then
		if emptyTotal is true then
			set visible of text field "collectionCount" of window "mainList" to false
			set the contents of text field "collectionCount" of window "mainList" to snr((localized string "misc_HaveTotal"), "500", "0")
		else
			set visible of text field "collectionCount" of window "mainList" to true
			set the contents of text field "collectionCount" of window "mainList" to snr((localized string "misc_HaveTotal"), "500", ((count myTempListCatalog) as string))
		end if
	else if haveORwant is "want" then
		if emptyTotal is true then
			set visible of text field "collectionCount" of window "mainList" to false
			set the contents of text field "collectionCount" of window "mainList" to snr((localized string "misc_WantTotal"), "500", "0")
		else
			set visible of text field "collectionCount" of window "mainList" to true
			set the contents of text field "collectionCount" of window "mainList" to snr((localized string "misc_WantTotal"), "500", ((count myTempListCatalog) as string))
		end if
	end if
end totalCountText