-- addXMLitem.applescript
-- myVinyl

--  Created by Leif Heflin on 5/9/10.
--  Copyright 2010 Leifertin. All rights reserved.

global currentlisttype, appsup, myVinylListCatalog, myVinylWantListCatalog, add_releaseName, add_releaseLABEL, add_releaseCatalog, add_releaseCountry, add_releaseDate, add_releaseID, add_releaseNotes, add_releaseCredits, add_releaseFormat, add_releaseArtist, add_releaseIMG, add_trackLISTstring, currentFolderType, myAppSupportFolder

on longDetailsPrep()
	set myDetails to ("<--NAME-->" & add_releaseName & "<--NAME-->
<--LABEL-->" & add_releaseLABEL & "<--LABEL-->
<--CATALOG-->" & add_releaseCatalog & "<--CATALOG-->
<--COUNTRY-->" & add_releaseCountry & "<--COUNTRY-->
<--RELEASED-->" & add_releaseDate & "<--RELEASED-->
<--CONDITION--><--CONDITION-->
<--RELEASEID-->" & add_releaseID & "<--RELEASEID-->
<--NOTES-->" & add_releaseNotes & "<--NOTES-->
<--CREDITS-->" & add_releaseCredits & "<--CREDITS-->
<--FORMAT-->" & add_releaseFormat & "<--FORMAT-->
<--TRACKLIST-->" & (ASCII character 10) & add_trackLISTstring & (ASCII character 10) & "<--TRACKLIST-->") as string
	if visible of window "updateAlbumWindow" is true then
		set myDetails to (myDetails & ("<--IMGHREF-->" & add_releaseIMG & "<--IMGHREF-->" & (ASCII character 10))) as string
	else if visible of (progress indicator 1 of view 1 of split view 1 of window "searchXMLWindow") is true then
		set myDetails to (myDetails & ("<--IMGHREF-->" & add_releaseIMG & "<--IMGHREF-->" & (ASCII character 10))) as string
	end if
	return myDetails
end longDetailsPrep

on addXMLItem(releasejumble, importRawListSplit, currentlisttype, myAppSupportFolder, endVal, addOrReplace)
	if visible of window "importing" is true then
		set myLimiter to 50
	else
		set myLimiter to 49
	end if
	
	if endVal is greater than myLimiter then
		restOfAddXMLItem(releasejumble, importRawListSplit, currentlisttype, myAppSupportFolder, endVal, addOrReplace)
		
	else if releasejumble is greater than myLimiter then
		restOfAddXMLItem(releasejumble, importRawListSplit, currentlisttype, myAppSupportFolder, endVal, addOrReplace)
		
	else
		restOfAddXMLItem(releasejumble, importRawListSplit, currentlisttype, myAppSupportFolder, endVal, addOrReplace)
	end if
end addXMLItem

on restOfAddXMLItem(releasejumble, importRawListSplit, currentlisttype, myAppSupportFolder, endVal, addOrReplace)
	if currentlisttype is "have" then
		set currentFolderType to "Collection"
	else
		set currentFolderType to "Wanted"
	end if
	set myVinylList to (myAppSupportFolder & "myVinylList.txt") as string
	set myVinylWantList to (myAppSupportFolder & "myVinylWantList.txt") as string
	try
		set myVinylListContents to do shell script ("cat " & quoted form of myVinylList)
	on error
		set myVinylListContents to ""
	end try
	try
		set myVinylWantListContents to do shell script ("cat " & quoted form of myVinylWantList)
	on error
		set myVinylWantListContents to ""
	end try
	copy myVinylListContents to myVinylListCatalog
	copy myVinylWantListContents to myVinylWantListCatalog
	
	if myVinylListContents is not "" then
		set myVinylListCatalog to common_alphabetize(every paragraph of myVinylListCatalog)
		repeat with iVar from 1 to ((count myVinylListCatalog) - 1)
			set item iVar of myVinylListCatalog to ((item iVar of myVinylListCatalog) & "
")
		end repeat
		set item (count myVinylListCatalog) of myVinylListCatalog to (item (count myVinylListCatalog) of myVinylListCatalog)
		if item 1 of myVinylListCatalog does not contain "::	.:.	:" then
			set myVinylListCatalog to rest of myVinylListCatalog
		end if
		do shell script ("echo " & (quoted form of (myVinylListCatalog as string)) & " > " & myVinylList)
		
		repeat with a from 1 to (count myVinylListCatalog)
			set item a of myVinylListCatalog to item 2 of split((item a of myVinylListCatalog), "::	.:.	:")
		end repeat
		
		repeat with a from 1 to (count myVinylListCatalog)
			try
				set myVinylListCatalogItem to (item a of myVinylListCatalog) as string
				set myVinylListCatalogItem to split(myVinylListCatalogItem, "
") as string
				set item a of myVinylListCatalog to myVinylListCatalogItem
			end try
		end repeat
	else
		set myVinylListCatalog to {}
	end if
	
	if myVinylWantListContents is not "" then
		set myVinylWantListCatalog to common_alphabetize(every paragraph of myVinylWantListCatalog)
		repeat with iVar from 1 to ((count myVinylWantListCatalog) - 1)
			set item iVar of myVinylWantListCatalog to ((item iVar of myVinylWantListCatalog) & "
")
		end repeat
		set item (count myVinylWantListCatalog) of myVinylWantListCatalog to (item (count myVinylWantListCatalog) of myVinylWantListCatalog)
		if item 1 of myVinylWantListCatalog does not contain "::	.:.	:" then
			set myVinylWantListCatalog to rest of myVinylWantListCatalog
		end if
		do shell script ("echo " & (quoted form of (myVinylWantListCatalog as string)) & " > " & myVinylWantList)
		
		repeat with a from 1 to (count myVinylWantListCatalog)
			set item a of myVinylWantListCatalog to item 2 of split((item a of myVinylWantListCatalog), "::	.:.	:")
		end repeat
		
		repeat with a from 1 to (count myVinylWantListCatalog)
			try
				set myVinylWantListCatalogItem to (item a of myVinylWantListCatalog) as string
				set myVinylWantListCatalogItem to split(myVinylWantListCatalogItem, "
") as string
				set item a of myVinylWantListCatalog to myVinylWantListCatalogItem
			end try
		end repeat
	else
		set myVinylWantListCatalog to {}
	end if
	
	if visible of window "importing" is true then
		set importRawListItem to importRawListSplit
	else
		if importRawListSplit contains "<resp stat=\"ok\"" then
			set importRawListItem to importRawListSplit
			set releasejumble to (releasejumble + 1)
		else
			set importRawListItem to "fail"
		end if
	end if
	
	if importRawListItem is not "fail" then
		--Get add_releaseID
		set add_releaseID to (item 2 of split(importRawListItem, "<release id=\""))
		set add_releaseID to (item 1 of split(add_releaseID, "\" status=\""))
		
		--Get Image
		set add_releaseIMG to getXMLitem_Image(importRawListItem)
		
		--Get Artist
		try
			set add_releaseArtist to getXMLitem_Artist(importRawListItem)
		on error
			set add_releaseArtist to ""
		end try
		try
			set add_releaseArtist to (item 2 of split(add_releaseArtist, "</id>"))
		end try
		
		--Get Title
		try
			set add_releaseAlbum to (item 2 of split(importRawListItem, "><title>"))
			set add_releaseAlbum to (item 1 of split(add_releaseAlbum, "</title><"))
		on error
			set add_releaseAlbum to ""
		end try
		
		--Get Catalog
		try
			set add_releaseCatalog to getXMLitem_Catalog(importRawListItem)
		on error
			set add_releaseCatalog to "Unknown"
		end try
		
		--Get Label
		try
			set add_releaseLABEL to getXMLitem_Label(importRawListItem)
		on error
			set add_releaseLABEL to ""
		end try
		
		--Get Credits
		try
			getXMLitem_Credits(importRawListItem)
		on error
			set add_releaseCredits to ""
		end try
		
		--Get Track Credits
		try
			set add_releaseTrackCredits to getXMLitem_TrackCredits(importRawListItem) as string
		on error
			set add_releaseTrackCredits to ""
		end try
		
		set add_releaseCredits to (add_releaseCredits & add_releaseTrackCredits) as string
		
		
		--Get Format
		try
			set add_releaseFormat to getXMLitem_Format(importRawListItem)
		on error
			set add_releaseFormat to ""
		end try
		
		--Get Country
		try
			set add_releaseCountry to (item 2 of split(importRawListItem, "><country>"))
			set add_releaseCountry to (item 1 of split(add_releaseCountry, "</country><"))
		on error
			set add_releaseCountry to ""
		end try
		
		--Get Date
		try
			set add_releaseDate to (item 2 of split(importRawListItem, "><released>"))
			set add_releaseDate to (item 1 of split(add_releaseDate, "</released><"))
		on error
			set add_releaseDate to ""
		end try
		
		--Get Notes
		try
			getXMLitem_Notes(importRawListItem)
		on error
			set add_releaseNotes to ""
		end try
		
		--Get Tracks
		getXMLitem_Tracks(importRawListItem)
		
		set add_releaseName to {add_releaseArtist, " - ", add_releaseAlbum} as string
		
		
		set add_releaseCatalog to common_catalogFlip(add_releaseCatalog, "file")
		
		--MAKE SURE THERE IS A COLLECTION AND WANTED FOLDER
		try
			do shell script "mkdir " & quoted form of (myAppSupportFolder & currentFolderType & "/")
		end try
		
		
		set add_releaseArtist to common_cleanMyHTML(add_releaseArtist)
		set add_releaseAlbum to common_cleanMyHTML(add_releaseAlbum)
		set add_releaseLABEL to common_cleanMyHTML(add_releaseLABEL)
		set add_releaseCatalog to common_cleanMyHTML(add_releaseCatalog)
		set add_releaseCountry to common_cleanMyHTML(add_releaseCountry)
		set add_releaseDate to common_cleanMyHTML(add_releaseDate)
		set add_trackLISTstring to common_cleanMyHTML(add_trackLISTstring)
		set add_releaseCredits to common_cleanMyHTML(add_releaseCredits)
		set add_releaseNotes to common_cleanMyHTML(add_releaseNotes)
		set add_releaseName to common_cleanMyHTML(add_releaseName)
		
		if visible of window "updateAlbumWindow" is false then
			if visible of (progress indicator 1 of view 1 of split view 1 of window "searchXMLWindow") is false then
				
				--if addOrReplace is "add" then
				set add_releaseCatalog to common_findCatalogDupes("first", currentFolderType, add_releaseCatalog)
				--end if
				
				set detailsPrep to longDetailsPrep()
				set myAddString to (common_getZeros(releasejumble, (endVal + 1)) & "::	.:.	:" & add_releaseCatalog) as string
				if currentlisttype is "have" then
					set myVinylListContents to (myVinylListContents & "
" & myAddString) as string
					do shell script ("echo " & quoted form of myVinylListContents & " > " & quoted form of myVinylList)
				else if currentlisttype is "want" then
					set myVinylWantListContents to (myVinylWantListContents & "
" & myAddString) as string
					do shell script ("echo " & quoted form of myVinylWantListContents & " > " & quoted form of myVinylWantList)
				end if
				
				set myCurrentListItemFile to (myAppSupportFolder & currentFolderType & "/" & add_releaseCatalog & "/details.txt")
				do shell script ("echo " & quoted form of detailsPrep & " > " & quoted form of (myCurrentListItemFile))
				
				
				if currentlisttype is "have" then
					set myVinylListCatalog to myVinylListCatalog & {add_releaseCatalog}
					set theHaveListDataSource to data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 1 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
					common_totalCountText("have", false, myVinylListCatalog)
					set myVinylListContents to renew_myListContents("", "", myVinylList, false)
				else if currentlisttype is "want" then
					set myVinylWantListCatalog to myVinylWantListCatalog & {add_releaseCatalog}
					set theWantListDataSource to data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 2 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
					common_totalCountText("want", false, myVinylWantListCatalog)
					set myVinylWantListContents to renew_myListContents("", "", myVinylWantList, false)
				end if
				
				set add_releaseCatalog to common_catalogFlip(add_releaseCatalog, "view")
				if addOrReplace is "add" then
					tell (data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
						make new data row at end of data rows
					end tell
				end if
				common_placeZeros((data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"), releasejumble, (endVal + 1))
				tell (data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
					set contents of data cell "artistColumn" of data row (releasejumble) to add_releaseArtist
					set contents of data cell "titleColumn" of data row (releasejumble) to add_releaseAlbum
					set contents of data cell "labelColumn" of data row (releasejumble) to add_releaseLABEL
					set contents of data cell "catalogColumn" of data row (releasejumble) to add_releaseCatalog
					set contents of data cell "formatColumn" of data row (releasejumble) to add_releaseFormat
					set contents of data cell "countryColumn" of data row (releasejumble) to add_releaseCountry
					set contents of data cell "releaseDateColumn" of data row (releasejumble) to add_releaseDate
					set contents of data cell "releaseIDColumn" of data row (releasejumble) to add_releaseID
				end tell
				set add_releaseCatalog to common_catalogFlip(add_releaseCatalog, "file")
				if add_releaseIMG is not "none" then
					try
						do shell script "cd " & quoted form of (myAppSupportFolder & currentFolderType & "/" & add_releaseCatalog & "/") & ";curl " & add_releaseIMG & " -o image.jpeg"
						if visible of window "importing" is false then
							set image of image view "mainListArtBox" of window "bigAlbumArt" to load image (myAppSupportFolder & currentFolderType & "/" & add_releaseCatalog & "/image.jpeg")
							set image of image view "mainListArtBox" of view 2 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to load image (myAppSupportFolder & currentFolderType & "/" & add_releaseCatalog & "/image.jpeg")
						end if
					end try
				end if
				if visible of window "importing" is not true then
					addToRecentActivity("Added", "to")
				end if
			else
				set detailsPrep to longDetailsPrep()
				set myCurrentListItemFile to (myAppSupportFolder & currentFolderType & "/_temp." & add_releaseID & ".details.txt")
				
				do shell script ("echo " & quoted form of detailsPrep & " > " & quoted form of (myCurrentListItemFile))
				set add_releaseCatalog to common_catalogFlip(add_releaseCatalog, "view")
			end if
		else
			set detailsPrep to longDetailsPrep()
			set myCurrentListItemFile to (myAppSupportFolder & currentFolderType & "/_temp." & add_releaseID & ".details.txt")
			
			do shell script ("echo " & quoted form of detailsPrep & " > " & quoted form of (myCurrentListItemFile))
			set add_releaseCatalog to common_catalogFlip(add_releaseCatalog, "view")
		end if
		return add_releaseCatalog
	else
		return "ERROR_Discogs_Fail" as string
	end if
end restOfAddXMLItem

on getXMLitem_Artist(importRawListItem)
	set add_releaseArtist to (item 2 of split(importRawListItem, "<artists>"))
	set add_releaseArtist to (item 1 of split(add_releaseArtist, "</artists>"))
	set add_releaseArtist to snr(add_releaseArtist, "<join>", " ")
	set add_releaseArtist to snr(add_releaseArtist, "</join>", " ")
	
	set add_releaseArtist to split(add_releaseArtist, "<artist>") as string
	set add_releaseArtist to split(add_releaseArtist, "<name>") as string
	set add_releaseArtist to split(add_releaseArtist, "</artist>") as string
	set add_releaseArtist to split(add_releaseArtist, "</name>") as string
	
	set add_releaseArtist to snr(add_releaseArtist, "<anv>", " (")
	set add_releaseArtist to snr(add_releaseArtist, "</anv>", ")")
	set add_releaseArtist to snr(add_releaseArtist, "<anv />", "")
	set add_releaseArtist to snr(add_releaseArtist, "<join />", "")
	set add_releaseArtist to snr(add_releaseArtist, "<role />", "")
	set add_releaseArtist to snr(add_releaseArtist, "<tracks />", "")
end getXMLitem_Artist

on getXMLitem_Catalog(importRawListItem)
	set add_releaseCatalog to (rest of split(importRawListItem, "<label catno=\""))
	
	repeat with myRCGETLoop from 1 to (count add_releaseCatalog)
		set myRCGETLooper to (item 1 of split((item myRCGETLoop of add_releaseCatalog), "\" name=\"")) as string
		set item myRCGETLoop of add_releaseCatalog to myRCGETLooper
	end repeat
	
	repeat with myRCGETLoop from 1 to ((count add_releaseCatalog) - 1)
		set myRCGETLooper to (item myRCGETLoop of add_releaseCatalog) as string
		set item myRCGETLoop of add_releaseCatalog to (myRCGETLooper & ", ") as string
	end repeat
	set add_releaseCatalog to add_releaseCatalog as string
	return add_releaseCatalog
end getXMLitem_Catalog

on getXMLitem_Credits(importRawListItem)
	set add_releaseCredits to (item 1 of split(importRawListItem, "<formats>")) as string
	try
		set add_releaseCredits to (item 1 of split(add_releaseCredits, "</extraartists>")) as string
	on error
		set add_releaseCredits to ""
	end try
	if add_releaseCredits is not "" then
		set add_releaseCredits to (item 2 of split(add_releaseCredits, "<extraartists>")) as string
		
		set add_releaseCredits to snr(add_releaseCredits, "<tracks>", " (Tracks: ")
		set add_releaseCredits to snr(add_releaseCredits, "</tracks>", ")")
		set add_releaseCredits to snr(add_releaseCredits, "<artist>", "")
		set add_releaseCredits to split(add_releaseCredits, "</artist>")
		set add_releaseCredits to common_cleanMyList(add_releaseCredits, {""})
		
		set myRCCount to (count add_releaseCredits)
		repeat with imI from 1 to myRCCount
			set currentImpItem to (item imI of add_releaseCredits) as string
			set currentImpItems to split(currentImpItem, "<role>")
			set myCurrentRole to ((item 2 of currentImpItems) as string)
			set myCurrentRole to split(myCurrentRole, "</role>") as string
			
			set myCurrentName to ((item 1 of currentImpItems) as string)
			set myCurrentName to item 1 of split(myCurrentName, "</name>")
			set myCurrentName to item 2 of split(myCurrentName, "<name>") as string
			
			if imI is not equal to myRCCount then
				set (item imI of add_releaseCredits) to ((myCurrentRole & " - " & myCurrentName & "
") as string)
			else
				set (item imI of add_releaseCredits) to ((myCurrentRole & " - " & myCurrentName) as string)
			end if
		end repeat
		set add_releaseCredits to (add_releaseCredits) as string
		set add_releaseCredits to snr(add_releaseCredits, "<tracks />", "") as string
	end if
end getXMLitem_Credits

on getXMLitem_Format(importRawListItem)
	set add_releaseFormat to (item 2 of split(importRawListItem, "<formats><"))
	set add_releaseFormat to (item 1 of split(add_releaseFormat, "></formats>"))
	copy (item 2 of split(add_releaseFormat, "format name=\"")) to add_releaseFormatMain
	set add_releaseFormatMain to (item 1 of split(add_releaseFormatMain, "\" qty=\""))
	copy (item 1 of split(add_releaseFormat, "\"><descriptions>")) to add_releaseFormatAmt
	set add_releaseFormatAmt to split(add_releaseFormatAmt, ("format name=\"" & add_releaseFormatMain & "\" qty=\"")) as string
	set add_releaseFormat to (item 2 of split(add_releaseFormat, "><descriptions>"))
	set add_releaseFormat to (item 1 of split(add_releaseFormat, "</descriptions></format"))
	set add_releaseFormat to snr(add_releaseFormat, "</description><description>", ", ")
	set add_releaseFormat to split(add_releaseFormat, "<description>") as string
	set add_releaseFormat to split(add_releaseFormat, "</description>") as string
	copy (add_releaseFormatAmt & " x " & add_releaseFormatMain & ", " & add_releaseFormat) to add_releaseFormatAll
	set add_releaseFormatAll to add_releaseFormatAll as string
	copy add_releaseFormatAll to add_releaseFormat
end getXMLitem_Format

on getXMLitem_Image(importRawListItem)
	if (split(importRawListItem, "<images>") as string) is equal to (importRawListItem as string) then
		set add_releaseIMG to ""
	else
		set add_releaseIMG to item 2 of split(importRawListItem, "<images>")
	end if
	
	if add_releaseIMG is not "" then
		set add_releaseIMG to (item 1 of split(add_releaseIMG, "</images>"))
		set add_releaseIMG to split(add_releaseIMG, ("<image height=\""))
		set add_releaseIMG to rest of add_releaseIMG
		repeat with XMLimgLoop from 1 to (count add_releaseIMG)
			set myXMLimgLoop to (item XMLimgLoop of add_releaseIMG) as string
			if myXMLimgLoop contains ("\" type=\"primary\" uri=") then
				copy myXMLimgLoop to add_releaseIMG
				exit repeat
			else
				if XMLimgLoop is equal to (count add_releaseIMG) then
					set add_releaseIMG to (item 1 of add_releaseIMG) as string
				end if
			end if
		end repeat
		set add_releaseIMG to (item 2 of split(add_releaseIMG, "uri="))
		set add_releaseIMG to (item 1 of split(add_releaseIMG, "uri150="))
	end if
	return add_releaseIMG
end getXMLitem_Image

on getXMLitem_Label(importRawListItem)
	set add_releaseLABEL to (item 2 of split(importRawListItem, "><label catno=\""))
	set add_releaseLABEL to (item 1 of split(add_releaseLABEL, "</labels>"))
	set add_releaseLABEL to (item 2 of split(add_releaseLABEL, "name=\""))
	set add_releaseLABEL to (item 1 of split(add_releaseLABEL, "\" /"))
end getXMLitem_Label

on getXMLitem_Notes(importRawListItem)
	set add_releaseNotes to (item 2 of split(importRawListItem, "><notes>"))
	set add_releaseNotes to (item 1 of split(add_releaseNotes, "</notes><"))
	set add_releaseNotes to every paragraph of add_releaseNotes
	set cnt_rn to ((count add_releaseNotes) - 1)
	repeat with xmlN from 1 to cnt_rn
		if xmlN is not equal to cnt_rn then
			set (item xmlN of add_releaseNotes) to ((item xmlN of add_releaseNotes) & (ASCII character 10)) as string
		end if
		if ((item xmlN of add_releaseNotes) as string) is "" then
			if xmlN is not equal to cnt_rn then
				if ((item (xmlN + 1) of add_releaseNotes) as string) is not "" then
					set (item xmlN of add_releaseNotes) to ASCII character 10
				end if
			end if
		end if
	end repeat
	set rmString to (last item of add_releaseNotes) as string
	if rmString is "" then
		set add_releaseNotes to reverse of rest of reverse of add_releaseNotes
	end if
	set add_releaseNotes to add_releaseNotes as string
end getXMLitem_Notes

on getXMLitem_Tracks(importRawListItem)
	set add_trackLISTstring to (item 2 of split(importRawListItem, "><tracklist>"))
	set add_trackLISTstring to (item 1 of split(add_trackLISTstring, "</tracklist><")) as string
	set add_trackLISTstring to rest of split(add_trackLISTstring, "<track>")
	repeat with trackLoop from 1 to (count add_trackLISTstring)
		
		set myCurrentTrack to (item trackLoop of add_trackLISTstring) as string
		
		set myTrackPosition to (item 1 of split(myCurrentTrack, "</position>")) as string
		set myTrackPosition to split((myTrackPosition), "<position>") as string
		
		set myTrackTitle to (item 1 of split(myCurrentTrack, "</title>")) as string
		try
			set myTrackTitle to (item 2 of split((myTrackTitle), "<title>")) as string
		on error
			set myTrackTitle to ""
		end try
		if myTrackPosition starts with "<position /><title>" then
			set (item trackLoop of add_trackLISTstring) to ("<trackPosition></trackPosition><trackTitle>" & myTrackTitle & "</trackTitle>" & (ASCII character 10)) as string
		else
			if myTrackPosition is "<position /><title /><duration /></track>" then
				set myTrackPosition to ""
			end if
			set (item trackLoop of add_trackLISTstring) to ("<trackPosition>" & myTrackPosition & "</trackPosition><trackTitle>" & myTrackTitle & "</trackTitle>" & (ASCII character 10)) as string
		end if
	end repeat
	set add_trackLISTstring to add_trackLISTstring as string
end getXMLitem_Tracks

on getXMLitem_TrackCredits(importRawListItem)
	set add_releaseTrackCredits to (item 1 of split(importRawListItem, "</tracklist>")) as string
	set add_releaseTrackCredits to (item 2 of split(add_releaseTrackCredits, "<tracklist>")) as string
	set add_releaseTrackCredits to split(add_releaseTrackCredits, "<track>")
	
	set add_releaseTrackCredits to common_cleanMyList(add_releaseTrackCredits, {""})
	repeat with r_cred_trim from 1 to (count add_releaseTrackCredits)
		set r_cred_trim_i to (item r_cred_trim of add_releaseTrackCredits)
		set r_cred_trim_i to (item 1 of split(r_cred_trim_i, "</track>"))
		set (item r_cred_trim of add_releaseTrackCredits) to r_cred_trim_i
	end repeat
	
	--position
	set add_releaseTrackCredits_pos to split(add_releaseTrackCredits as string, "<position>")
	set add_releaseTrackCredits_pos to common_cleanMyList(add_releaseTrackCredits_pos, {""})
	
	repeat with r_cred_trim from 1 to (count add_releaseTrackCredits_pos)
		set r_cred_trim_i to (item r_cred_trim of add_releaseTrackCredits_pos)
		set r_cred_trim_i to (item 1 of split(r_cred_trim_i, "</position>")) as string
		if r_cred_trim_i does not contain "<position />" then
			set (item r_cred_trim of add_releaseTrackCredits_pos) to r_cred_trim_i
		else
			set (item r_cred_trim of add_releaseTrackCredits_pos) to ""
		end if
	end repeat
	set add_releaseTrackCredits_pos to common_cleanMyList(add_releaseTrackCredits_pos, {""})
	
	--title
	copy add_releaseTrackCredits to add_releaseTrackCredits_title
	
	repeat with r_cred_trim from 1 to (count add_releaseTrackCredits_title)
		set r_cred_trim_i to (item r_cred_trim of add_releaseTrackCredits_title)
		if r_cred_trim_i starts with "<position />" then
			set (item r_cred_trim of add_releaseTrackCredits_title) to ""
		else
			set r_cred_trim_i to (item 1 of split(r_cred_trim_i, "</title>")) as string
			set r_cred_trim_i to (item 2 of split(r_cred_trim_i, "<title>")) as string
			set (item r_cred_trim of add_releaseTrackCredits_title) to r_cred_trim_i
		end if
	end repeat
	set add_releaseTrackCredits_title to common_cleanMyList(add_releaseTrackCredits_title, {""})
	
	--artistNo
	set add_releaseTrackCredits_artistNo to {}
	repeat with r_cred_trim from 1 to (count add_releaseTrackCredits)
		set r_cred_trim_i to (item r_cred_trim of add_releaseTrackCredits)
		if r_cred_trim_i starts with "<position />" then
			set temp_artNo to ""
		else
			if r_cred_trim_i contains "<extraartists>" then
				set temp_artNo to ((count split(r_cred_trim_i, "<artist>")) - 1)
			else
				set temp_artNo to 0
			end if
		end if
		set add_releaseTrackCredits_artistNo to add_releaseTrackCredits_artistNo & {temp_artNo}
	end repeat
	set add_releaseTrackCredits_artistNo to common_cleanMyList(add_releaseTrackCredits_artistNo, {""})
	
	set add_releaseTrackCredits to rest of split(add_releaseTrackCredits as string, "<extraartists>")
	set add_releaseTrackCredits to common_cleanMyList(add_releaseTrackCredits, {""})
	
	--Further parse
	repeat with r_cred_trim from 1 to (count add_releaseTrackCredits)
		set r_cred_trim_i to (item r_cred_trim of add_releaseTrackCredits)
		set r_cred_trim_i to (item 1 of split(r_cred_trim_i, "</extraartists>")) as string
		set (item r_cred_trim of add_releaseTrackCredits) to r_cred_trim_i
	end repeat
	
	--artist
	set add_releaseTrackCredits_artist to split(add_releaseTrackCredits as string, "<artist>")
	set add_releaseTrackCredits_artist to common_cleanMyList(add_releaseTrackCredits_artist, {""})
	
	repeat with r_cred_trim from 1 to (count add_releaseTrackCredits_artist)
		set r_cred_trim_i to (item r_cred_trim of add_releaseTrackCredits_artist)
		set r_cred_trim_i to (item 1 of split(r_cred_trim_i, "</artist>")) as string
		
		set (item r_cred_trim of add_releaseTrackCredits_artist) to r_cred_trim_i
	end repeat
	
	--role
	set add_releaseTrackCredits_role to rest of split(add_releaseTrackCredits_artist as string, "<role>")
	set add_releaseTrackCredits_role to common_cleanMyList(add_releaseTrackCredits_role, {""})
	
	repeat with r_cred_trim from 1 to (count add_releaseTrackCredits_role)
		set r_cred_trim_i to (item r_cred_trim of add_releaseTrackCredits_role)
		set r_cred_trim_i to (item 1 of split(r_cred_trim_i, "</role>")) as string
		
		set (item r_cred_trim of add_releaseTrackCredits_role) to r_cred_trim_i
	end repeat
	
	--name
	set add_releaseTrackCredits_name to rest of split(add_releaseTrackCredits_artist as string, "<name>")
	set add_releaseTrackCredits_name to common_cleanMyList(add_releaseTrackCredits_name, {""})
	
	repeat with r_cred_trim from 1 to (count add_releaseTrackCredits_name)
		set r_cred_trim_i to (item r_cred_trim of add_releaseTrackCredits_name)
		set r_cred_trim_i to (item 1 of split(r_cred_trim_i, "</name>")) as string
		set (item r_cred_trim of add_releaseTrackCredits_name) to r_cred_trim_i
	end repeat
	
	if add_releaseCredits is not "" then
		set add_releaseTrackCredits_out to ((ASCII character 10) & (ASCII character 10) & "----------" & (ASCII character 10) & "Tracks" & (ASCII character 10) & "----------" & (ASCII character 10) & (ASCII character 10)) as string
	else
		set add_releaseTrackCredits_out to ("----------" & (ASCII character 10) & "Tracks" & (ASCII character 10) & "----------" & (ASCII character 10) & (ASCII character 10)) as string
	end if
	
	set old_TrackVarCount to 0
	repeat with relTrack_loop from 1 to (count add_releaseTrackCredits_pos)
		if (old_TrackVarCount) is 0 then set old_TrackVarCount to 1
		set subloopend to ((item relTrack_loop of add_releaseTrackCredits_artistNo) as integer)
		if subloopend is greater than 0 then
			set add_releaseTrackCredits_out to (add_releaseTrackCredits_out & (item relTrack_loop of add_releaseTrackCredits_pos) & " - " & (item relTrack_loop of add_releaseTrackCredits_title) & (ASCII character 10) & (ASCII character 10)) as string
			repeat with relTrack_subloop from old_TrackVarCount to ((subloopend + old_TrackVarCount) - 1)
				set temp_role to (item relTrack_subloop of add_releaseTrackCredits_role) as string
				set temp_name to (item relTrack_subloop of add_releaseTrackCredits_name) as string
				try
					set add_releaseTrackCredits_out to (add_releaseTrackCredits_out & temp_role & " - " & temp_name & (ASCII character 10)) as string
				end try
			end repeat
			if relTrack_loop is less than (count add_releaseTrackCredits_pos) then
				set add_releaseTrackCredits_out to (add_releaseTrackCredits_out & (ASCII character 10)) as string
			end if
		end if
		set old_TrackVarCount to (old_TrackVarCount + (subloopend))
	end repeat
	
	return add_releaseTrackCredits_out
end getXMLitem_TrackCredits

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

on common_placeZeros(myDataSource, a, endVal)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to placeZeros(myDataSource, a, endVal)
end common_placeZeros

on common_getZeros(a, endVal)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to getZeros(a, endVal)
end common_getZeros

on common_alphabetize(the_list)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to alphabetize(the_list)
end common_alphabetize

on common_totalCountText(haveORwant, emptyTotal, myTempListCatalog)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to totalCountText(haveORwant, emptyTotal, myTempListCatalog)
end common_totalCountText

on common_cleanMyHTML(cleanString)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to cleanMyHTML(cleanString)
end common_cleanMyHTML

on common_findCatalogDupes(getSelected, currentFType, t_releaseCatalog)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to findCatalogDupes(getSelected, currentFType, t_releaseCatalog, myAppSupportFolder, currentlisttype)
end common_findCatalogDupes

on common_catalogFlip(tmp_releaseCatalog, flipDirection)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to catalogFlip(tmp_releaseCatalog, flipDirection)
end common_catalogFlip

on renew_myListContents(temp_myListContents, temp_releaseCat, temp_myList, deleteLineBoolean)
	if deleteLineBoolean is false then
		if (temp_releaseCat as string) is "" then
			set temp_myListContents to (do shell script ("cat " & quoted form of temp_myList))
		end if
		set temp_myListContents to every paragraph of temp_myListContents
		set temp_myListContents to common_cleanMyList(temp_myListContents, {""})
	end if
	
	if temp_myListContents is not {} then
		if deleteLineBoolean is false then
			repeat with rmLoop from 1 to (count temp_myListContents)
				try
					set (item rmLoop of temp_myListContents) to item 2 of split((item rmLoop of temp_myListContents), "::	.:.	:")
				end try
			end repeat
		end if
		
		if (temp_releaseCat as string) is not "" then
			if currentlisttype is "have" then
				copy myVinylListCatalog to temp_myListContents2
			else
				copy myVinylWantListCatalog to temp_myListContents2
			end if
			
			repeat with rmLoop from 1 to (count temp_myListContents2)
				set myCompare to ((item rmLoop of temp_myListContents2) as string)
				if myCompare is equal to temp_releaseCat then
					set currentItemNo to (common_getZeros(rmLoop, (count temp_myListContents2))) as string
					exit repeat
				end if
			end repeat
			
		end if
		
		if deleteLineBoolean is true then
			set temp_myListContents to split(temp_myListContents, (currentItemNo & "::	.:.	:" & temp_releaseCat)) as string
			set temp_myListContents to every paragraph of temp_myListContents
			
			repeat with rmLoop from 1 to (count temp_myListContents)
				set myReplaceNum to common_getZeros(rmLoop, (count temp_myListContents))
				set myReplaceItem to (item rmLoop of temp_myListContents) as string
				if myReplaceItem is not "" then
					set myReplaceItem to item 2 of split((myReplaceItem), "::	.:.	:") as string
					set myReplaceItem to (myReplaceNum & ("::	.:.	:") & myReplaceItem) as string
					if rmLoop is less than (count temp_myListContents) then
						set myReplaceItem to ((myReplaceItem) & (ASCII character 10)) as string
					end if
				end if
				set (item rmLoop of temp_myListContents) to myReplaceItem
			end repeat
		else
			
			if temp_myList ends with ".myvy" then
				set currentItemNo to ((count temp_myListContents) + 1)
			end if
			
			
			--FIX LIST
			repeat with rmLoop from 1 to (count temp_myListContents)
				set myReplaceNum to common_getZeros(rmLoop, (count temp_myListContents))
				set myReplaceItem to (item rmLoop of temp_myListContents) as string
				set myReplaceItem to (myReplaceNum & ("::	.:.	:") & myReplaceItem) as string
				if rmLoop is less than (count temp_myListContents) then
					set myReplaceItem to ((myReplaceItem) & (ASCII character 10)) as string
				end if
				set (item rmLoop of temp_myListContents) to myReplaceItem
			end repeat
			--DONE FIXIN
		end if
		
	else
		set temp_myListContents to ""
		set currentItemNo to 1
	end if
	
	set temp_myListContents to temp_myListContents as string
	if (temp_releaseCat as string) is "" then
		do shell script ("echo " & quoted form of temp_myListContents & " > " & quoted form of temp_myList)
	end if
	
	return temp_myListContents
end renew_myListContents

on common_cleanMyList(theList, itemsToDelete)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to cleanMyList(theList, itemsToDelete)
end common_cleanMyList

on addToRecentActivity(ra_word1, ra_word2)
	------ADD TO RECENT ACTIVITY
	set myRecentActivityList to (myAppSupportFolder & "recentActivity.txt") as string
	try
		set myRecentActivityListContents to (do shell script "cat " & quoted form of myRecentActivityList)
	on error
		set myRecentActivityListContents to ""
	end try
	if add_releaseID is not "" then
		---
		set add_releaseID to snr(add_releaseID, "[", "")
		set add_releaseID to snr(add_releaseID, "r", "")
		set add_releaseID to snr(add_releaseID, "]", "")
		---
		set myRecentActivityListContents to (myRecentActivityListContents & "<..change!-...>" & ra_word1 & " " & add_releaseID & " " & ra_word2 & " " & currentlisttype & " list.")
		updateRecentList(myRecentActivityListContents)
		do shell script ("echo " & quoted form of myRecentActivityListContents & " > " & quoted form of myRecentActivityList)
	end if
end addToRecentActivity
on updateRecentList(myRecentActivityListContents)
	set skipMe to false
	try
		set myRecentCount to (rest of (split(myRecentActivityListContents, ("<..change!-...>"))))
	on error
		set myRecentCount to {}
	end try
	set (content of table view 1 of scroll view 1 of window "recentActivityWindow") to myRecentCount
	if (count myRecentCount) is equal to 1 then
		set content of text field "recentActivityCountBox" of window "recentActivityWindow" to snr((localized string "misc_OneItem"), "1", ((count myRecentCount) as string))
	else
		set content of text field "recentActivityCountBox" of window "recentActivityWindow" to snr((localized string "misc_MoreItems"), "0", ((count myRecentCount) as string))
	end if
end updateRecentList

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
	
	set prefsFile to (quoted form of (POSIX path of (path to home folder) & "Library/Application Support/MyVinyl.prefs"))
	set prefsfileR to do shell script "cat " & prefsFile
	try
		set usrEmail to (item 2 of split(prefsfileR, "<userEmail>")) as string
		set usrSerial to (item 2 of split(prefsfileR, "<userSerial>")) as string
	on error
		set usrEmail to "Email Address"
		set usrSerial to "Serial Number"
	end try
end initializeMe_SM

on common_getGoAhead(usrEmail, usrSerial, myTimeout)
	set otherScript to useOtherScript("register")
	tell otherScript to getGoAhead(usrEmail, usrSerial, myTimeout)
end common_getGoAhead