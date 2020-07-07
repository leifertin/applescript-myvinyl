-- upgradeDB.applescript
-- myVinyl

--  Created by Leif Heflin on 5/9/10.
--  Copyright 2010 Leifertin. All rights reserved.

to upgradeDBMain(myAppSupportFolder)
	repeat with abab in {"have", "want"}
		copy myAppSupportFolder to myFolderPath
		copy myFolderPath to rootfolder
		
		if (abab as string) is "have" then
			set myFolderPath to (myFolderPath & "Collection/")
			set myVinylListy to (rootfolder & "myVinylList.txt")
		else if (abab as string) is "want" then
			set myFolderPath to (myFolderPath & "Wanted/")
			set myVinylListy to (rootfolder & "myVinylWantList.txt")
		end if
		
		try
			set myCatalogList to do shell script ("cat " & quoted form of myVinylListy)
		on error
			set myCatalogList to "NOLIST"
		end try
		
		if myCatalogList is "NOLIST" then
			display dialog ("You don't have a \"" & abab & "\" list.") buttons {(localized string "button_Oh")} default button 1
		else if myCatalogList contains "::	.:.	:" then
			display dialog ("Your \"" & abab & "\" list has already been upgraded.") buttons {(localized string "button_Oh")} default button 1
		else
			set myCatalogList to split(myCatalogList, "<ALBNM-->")
			set myCatalogList to rest of myCatalogList
			
			repeat with iVar from 1 to (count myCatalogList)
				set item iVar of myCatalogList to item 2 of split((item iVar of myCatalogList), "<CATNUM-->")
			end repeat
			
			repeat with iVar from 1 to ((count myCatalogList) - 1)
				set item iVar of myCatalogList to (placeZeros_alt(myCatalogList, iVar) & "::	.:.	:" & (item iVar of myCatalogList) & "
")
			end repeat
			set item (count myCatalogList) of myCatalogList to (placeZeros_alt(myCatalogList, (count myCatalogList)) & "::	.:.	:" & (item (count myCatalogList) of myCatalogList))
			set myCatalogList to myCatalogList as string
			
			do shell script ("echo " & (quoted form of myCatalogList) & " > " & (quoted form of myVinylListy))
			display dialog ("Finished upgrading \"" & abab & "\" list.") buttons {(localized string "button_Yay")} default button 1
		end if
	end repeat
end upgradeDBMain
to upgradeDBPlaylists(myAppSupportFolder)
	copy myAppSupportFolder to myFolderPath
	copy myFolderPath to rootfolder
	set myFolderPath to (myFolderPath & "Playlists/")
	
	repeat with abab in {"have", "want"}
		set myCurrentFolderPath to ((myFolderPath & abab & "/") as string)
		set myCatalogList to every paragraph of (do shell script ("ls " & quoted form of myCurrentFolderPath))
		if myCatalogList is not {} then
			set skippedList to ""
			repeat with b from 1 to (count myCatalogList)
				if (item b of myCatalogList) ends with ".myvy" then
					set currentListItem to (item b of myCatalogList) as string
					set currentListItemContents to do shell script ("cat " & quoted form of (myCurrentFolderPath & currentListItem))
					if currentListItemContents is not "" then
						if currentListItemContents contains "::	.:.	:" then
							if skippedList is "" then
								set skippedList to (currentListItem)
							else
								set skippedList to (skippedList & currentListItem & ", ")
							end if
						else
							set currentListItemContents to split(currentListItemContents, "<ALBNM-->")
							set currentListItemContents to rest of currentListItemContents
							
							repeat with iVar from 1 to (count currentListItemContents)
								set item iVar of currentListItemContents to item 2 of split((item iVar of currentListItemContents), "<CATNUM-->")
							end repeat
							
							repeat with iVar from 1 to ((count currentListItemContents) - 1)
								set item iVar of currentListItemContents to (placeZeros_alt(currentListItemContents, iVar) & "::	.:.	:" & (item iVar of currentListItemContents) & "
")
							end repeat
							set item (count currentListItemContents) of currentListItemContents to (placeZeros_alt(currentListItemContents, (count currentListItemContents)) & "::	.:.	:" & (item (count currentListItemContents) of currentListItemContents))
							set currentListItemContents to currentListItemContents as string
							do shell script ("echo " & (quoted form of currentListItemContents) & " > " & quoted form of (myCurrentFolderPath & currentListItem))
						end if
					else
						set skippedList to (skippedList & currentListItem & ", ")
					end if
				end if
			end repeat
			if skippedList ends with ", " then
				set skippedList to every character of skippedList
				set skippedList to reverse of skippedList
				set skippedList to rest of rest of skippedList
				
				set skippedList to reverse of skippedList as string
			end if
			display dialog ("Skipped Playlists: " & skippedList) buttons {(localized string "button_Oh")} default button 1
		else
			display dialog ("You have no \"" & abab & "\" playlists.") buttons {(localized string "button_Oh")} default button 1
		end if
	end repeat
end upgradeDBPlaylists
to upgradeDBTracks(myAppSupportFolder)
	repeat with abab in {"have", "want"}
		copy myAppSupportFolder to myFolderPath
		copy myFolderPath to rootfolder
		
		if (abab as string) is "have" then
			set myFolderPath to (myFolderPath & "Collection/")
		else if (abab as string) is "want" then
			set myFolderPath to (myFolderPath & "Wanted/")
		end if
		set myCatalogs to every paragraph of (do shell script ("ls " & quoted form of myFolderPath))
		
		
		repeat with myUPTracksLoop from 1 to (count myCatalogs)
			set skipTheRest to false
			set currentTrackItem_f to (myFolderPath & (item myUPTracksLoop of myCatalogs) & "/details.txt") as string
			try
				set currentTrackItem_c to do shell script ("cat " & quoted form of currentTrackItem_f)
			on error number (1)
				set skipTheRest to true
			end try
			if skipTheRest is false then
				if currentTrackItem_c does not contain "<--TRACKLIST-->" then
					set currentTrackItem_c_t to rest of (split(currentTrackItem_c, "<track!Item.>"))
					set currentTrackItem_c_top to item 1 of (split(currentTrackItem_c, "<track!Item.>")) as string
					
					set trackPositions to {}
					set trackTitles to {}
					set tracksList to ("<--TRACKLIST-->" & (ASCII character 10))
					repeat with myUPTracksLoopSub from 1 to (count currentTrackItem_c_t)
						set currentTrack to (item myUPTracksLoopSub of currentTrackItem_c_t) as string
						try
							set trackTitles to trackTitles & (item 2 of split(currentTrack, " - "))
							set trackPositions to trackPositions & (item 1 of split(currentTrack, " - "))
						on error number (-1728)
							set trackTitles to trackTitles & (currentTrack)
							set trackPositions to trackPositions & ("")
						end try
						
						set tracksList to tracksList & ("<trackPosition>" & (item myUPTracksLoopSub of trackPositions) & "</trackPosition><trackTitle>" & (item myUPTracksLoopSub of trackTitles) & "</trackTitle>" & (ASCII character 10))
					end repeat
					
					
					set tracksList to (tracksList & ("<--TRACKLIST-->")) as string
					set tracksDeposit to (currentTrackItem_c_top & tracksList) as string
					do shell script ("echo " & (quoted form of tracksDeposit) & " > " & (quoted form of currentTrackItem_f))
				end if
			end if
		end repeat
		display dialog ("Finished upgrading \"" & abab & "\" tracks.") buttons {(localized string "button_Yay")} default button 1
	end repeat
end upgradeDBTracks




on split(someText, delimiter)
	set AppleScript's text item delimiters to delimiter
	set someText to someText's text items
	set AppleScript's text item delimiters to {""}
	return someText
end split

on placeZeros_alt(myDataSource, a)
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
	
	if (count myDataSource) is less than 10 then
		set myTakeAmt to 5
	else if (count myDataSource) is less than 100 then
		set myTakeAmt to 4
	else if (count myDataSource) is less than 1000 then
		set myTakeAmt to 3
	else if (count myDataSource) is less than 10000 then
		set myTakeAmt to 2
	else if (count myDataSource) is less than 100000 then
		set myTakeAmt to 1
	end if
	
	set myCellWrite to every character of myCellWrite
	repeat with barI from 1 to myTakeAmt
		set myCellWrite to rest of myCellWrite
		---
	end repeat
	set myCellWrite to myCellWrite as string
	return myCellWrite
end placeZeros_alt