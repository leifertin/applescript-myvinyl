-- myVinyl.applescript
-- myVinyl

--  Created by Leif Heflin on 5/9/10.
--  Copyright 2010 Leifertin. All rights reserved.

global currentItemNo, albumNo, currentlisttype, appsup, origReleaseID, p7String, myAppSupportFolder, myVinylList, myVinylWantList, myVinylWantListCatalog, thisVinylListCatalog, myVinylListCatalog, prefsFile, myVinylWantListContents, myVinylListContents
global releaseNotes, releaseArtist, releaseAlbum, releaseLABEL, releaseID, releaseCatalog, myCurrentListItemFile, releaseFormat, releaseIMG, releaseCountry, releaseDate, releaseName, trackChosen, trackLISTstring, albumChosen, myCurrentListItemFileContents, nlMasta, currentFolderType, numberOfTracks
global theHaveListDataSource, theWantListDataSource, myRecentActivityList, myRecentActivityListContents, currentPID, currentAction, backupLoc, cancelImportVar, theCurrentDataSource, currentHaveColumn, currentWantColumn, myAZorderH, myAZorderW
global pathTOCURLfile, pathTOCURLedfile, pathTOHURLfile, releaseLimiter, releaseList, visibleColumnsHave, visibleColumnsWant, importRawListSplit, releasejumble, myDataSource, releaseCondition, myPlaylistFile, myPlaylist, myPlaylistCatalog, infoFileContents, currentBottomType, releaseCredits
global theSearchDataSource, foundIT, firstRun, myCountCat, pathTOCURLfileZIP, theTrackListDataSource, updt_tracks, updt_tempFileContents, updt_tempFile, destCat
global myBPM, myGenre, myStyle, mySongPreference, myKeySignature, myComments, myEnergyRating

on choose menu item theObject
	if visible of window "upgradeDBWindow" is false then
		if the name of theObject is "aboutWindowMenu" then
			display panel window "aboutWindow" attached to window "mainList"
		else if the name of theObject is "submitTranslation" then
			open location "http://grayarea.be/app/MyVinyl/Localize.html"
		else if the name of theObject is "importCollectionList" then
			importDiscogsXML("have", "!")
		else if the name of theObject is "importWishlistList" then
			importDiscogsXML("want", "!")
		else if the name of theObject is "buySellEbay" then
			if currentlisttype is "have" then
				open location "http://sell.ebay.com/sell"
			else if currentlisttype is "want" then
				set albumChosenURL to snr(albumChosen, " - ", " ")
				set albumChosenURL to snr(albumChosenURL, " ", "+")
				open location ("http://music.shop.ebay.com/Records-/306/i.html?_nkw=" & albumChosenURL & "&_catref=1&_fln=1")
			end if
		else if the name of theObject is "buySellDiscogs" then
			if releaseID is not "" then
				if currentlisttype is "have" then
					open location ("http://www.discogs.com/sell/post?release_id=" & releaseID)
				else if currentlisttype is "want" then
					open location ("http://www.discogs.com/sell/list?release_id=" & releaseID)
				end if
			else
				common_displayDialog((localized string "dialog_NonDiscogsBuySell"), (localized string "button_Oh"), false, "")
			end if
		else if the name of theObject is "buySellAmazon" then
			
			set albumChosenURL to snr(albumChosen, " - ", " ")
			set albumChosenURL to snr(albumChosenURL, " ", "+")
			if currentlisttype is "have" then
				open location ("https://sellercentral.amazon.com/gp/ezdpc-gui/start.html?forceListingPipe=1")
			else if currentlisttype is "want" then
				open location ("http://www.amazon.com/gp/search?__mk_us_US=Amazon&search-alias=popular&chooser-format=field-binding%21vinyl&field-keywords=" & albumChosenURL & "&mysubmitbutton1.x=46&mysubmitbutton1.y=10")
			end if
		else if the name of theObject is "buySellMyVinyl" then
			if currentlisttype is "want" then
				open location ("http://www.my-vinyl.fr/unity_vinyl_record_cutting/po.php")
			end if
		else if the name of theObject is "exportToHTMLList" then
			export_toHTML()
		else if the name of theObject is "recentActivityMenuItem" then
			show window "recentActivityWindow"
		else if the name of theObject is "viewOnDiscogs" then
			open location ("http://www.discogs.com/release/" & releaseID)
		else if the name of theObject is "editOnDiscogs" then
			if releaseID is not "" then
				open location ("http://www.discogs.com/release/edit/" & releaseID)
			else
				open location ("http://www.discogs.com/release/add")
			end if
		else if the name of theObject is "prefsMenu" then
			display panel window "prefsWindow" attached to window "mainList"
		else if the name of theObject is "exportToXLSList" then
			export_toXLS_HTML()
		else if the name of theObject is "revealArtwork" then
			try
				set myFinderPath to POSIX file (myAppSupportFolder & currentFolderType & "/" & common_catalogFlip(releaseCatalog, "file") & "/") as alias
			on error
				error number -128
			end try
			tell application "Finder"
				reveal myFinderPath
				activate
			end tell
		else if the name of theObject is "playlistMenu" then
			set myPlaylist to get_myPlaylist()
			tell (view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
				if myPlaylist is "Library" then
					set enabled of button "deletePlaylist" to false
				else
					set enabled of button "deletePlaylist" to true
				end if
				if myPlaylist is equal to (the title of popup button "moveToPlaylistMenu" as string) then
					set visible of button "moveToPlaylist" to false
				else
					if (visible of popup button "moveToPlaylistMenu") is true then
						set visible of button "moveToPlaylist" to true
					else
						set visible of button "moveToPlaylist" to false
					end if
				end if
			end tell
			
			playlist_Show(myPlaylist)
			
		else if the name of theObject is "moveToPlaylistMenu" then
			tell (view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
				if (the title of popup button "playlistMenu" as string) is equal to (the title of popup button "moveToPlaylistMenu" as string) then
					set visible of button "moveToPlaylist" to false
				else
					set visible of button "moveToPlaylist" to true
				end if
			end tell
		else if the name of theObject is "searchType" then
			set title of header cell of table column 2 of control 1 of scroll view 1 of window "searchWindow" to (title of theObject as string)
			tell control 1 of scroll view 1 of window "searchWindow" to update
		else if the name of theObject is "searchMenuItem" then
			display panel window "searchWindow" attached to window "mainList"
		else if the name of theObject is "searchXMLMenuItem" then
			display panel window "searchXMLWindow" attached to window "mainList"
		else if the name of theObject is "exportToXLSListB" then
			export_toXLS_Binary()
		else if the name of theObject is "randomAlbumMenu" then
			selectionDiffer("random")
		end if
	end if
end choose menu item

on clicked theObject
	if the name of theObject is "addAlbumOnlineCancel" then
		close panel window "addAlbumWindow"
	else if the name of theObject is "addAlbumOfflineCancel" then
		close panel window "addAlbumWindow"
	else if the name of theObject is "editNotesCancel" then
		close panel window "editNotesWindow"
	else if the name of theObject is "addAlbumOfflineSubmit" then
		set releaseArtist to contents of text field "addAlbumOfflineArtist" of tab view item 1 of tab view 1 of window "addAlbumWindow"
		set releaseAlbum to contents of text field "addAlbumOfflineAlbumTitle" of tab view item 1 of tab view 1 of window "addAlbumWindow"
		set releaseLABEL to contents of text field "addAlbumOfflineLabel" of tab view item 1 of tab view 1 of window "addAlbumWindow"
		set releaseFormat to contents of text field "addAlbumOfflineFormat" of tab view item 1 of tab view 1 of window "addAlbumWindow"
		set releaseCountry to contents of text field "addAlbumOfflineCountry" of tab view item 1 of tab view 1 of window "addAlbumWindow"
		set releaseDate to contents of text field "addAlbumOfflineReleaseDate" of tab view item 1 of tab view 1 of window "addAlbumWindow"
		set releaseCatalog to contents of text field "addAlbumOfflineCatalog" of tab view item 1 of tab view 1 of window "addAlbumWindow"
		set releaseID to ""
		set releaseNotes to ""
		set releaseCredits to ""
		set releaseIMG to "none"
		set releaseCondition to ""
		--
		--
		--BLANK NEW COLUMNS
		
		set myBPM to ""
		set myGenre to ""
		set myStyle to ""
		set mySongPreference to ""
		set myKeySignature to ""
		set myComments to ""
		set myEnergyRating to ""
		
		
		--
		--
		set trackLISTstring to "<--TRACKLIST--><--TRACKLIST-->"
		
		set testlist to {releaseArtist, releaseAlbum, releaseLABEL, releaseCatalog, releaseFormat, releaseCountry, releaseDate}
		repeat with a from 1 to (count testlist)
			if item a of testlist is "" then
				display alert "All fields are required."
				error number -128
			end if
		end repeat
		close panel window "addAlbumWindow"
		
		
		set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
		
		set releaseName to {releaseArtist, " - ", releaseAlbum} as string
		set releaseCatalog to common_findCatalogDupes("first", currentFolderType, releaseCatalog)
		set detailsPrep to longDetailsPrep()
		set detailsPrep to snr(detailsPrep, trackLISTstring, "")
		set trackLISTstring to "<--TRACKLIST--><--TRACKLIST-->"
		
		set myCurrentListItemFile to (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/details.txt")
		do shell script ("echo " & quoted form of detailsPrep & " > " & quoted form of (myCurrentListItemFile))
		
		addAlbumOff_Contents(currentlisttype)
		fillDataSourcesOffline(currentlisttype)
		
		if currentlisttype is "have" then
			copy myVinylListCatalog to myTempListCatalog
		else
			copy myVinylWantListCatalog to myTempListCatalog
		end if
		
		common_totalCountText(currentlisttype, false, myTempListCatalog)
		set (content of table view "trackListTableView" of scroll view "trackListScrollView" of drawer "trackListView" of window "mainList") to {}
		
		set myOFFDS to (data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
		repeat with a from 1 to (count myTempListCatalog)
			try
				common_placeZeros(myOFFDS, a, (count myTempListCatalog))
			on error number (-1719)
				exit repeat
			end try
		end repeat
		selectionDiffer("add")
	else if the name of theObject is "saveChanges" then
		try
			set releaseName to getMyAlbum()
		on error
			error number -128
		end try
		set albumChosen to releaseName
		if (currentBottomType) is "notes" then
			set releaseNotes to (contents of text view 1 of scroll view 1 of tab view item 2 of tab view 1 of view 2 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList")
		else if (currentBottomType) is "credits" then
			set releaseCredits to (contents of text view 1 of scroll view 1 of tab view item 1 of tab view 1 of view 2 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList")
		end if
		---ADD TO LIST FILE
		set myCurrentListItemFileContents to (do shell script "cat " & quoted form of myCurrentListItemFile) as string
		set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
		set detailsPrep to longDetailsPrep()
		do shell script ("echo " & quoted form of detailsPrep & " > " & quoted form of (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/details.txt"))
		set releaseCatalog to common_catalogFlip(releaseCatalog, "view")
	else if the name of theObject is "closeAboutWindow" then
		close panel window "aboutWindow"
	else if the name of theObject is "deleteAlbumEntry" then
		if (title of window "mainList") is not (".:MyVinyl:.") then
			try
				set albumChosen to getMyAlbum()
			on error
				error number -128
			end try
			set myPlaylist to get_myPlaylist()
			if myPlaylist is "Library" then
				if currentlisttype is "want" then
					set myDialog to snr((localized string "dialog_RemoveWant"), "thisAlbum", albumChosen)
					common_displayDialog(myDialog, (localized string "button_Yes"), true, "")
				else if currentlisttype is "have" then
					set myDialog to snr((localized string "dialog_RemoveHave"), "thisAlbum", albumChosen)
					common_displayDialog(myDialog, (localized string "button_Yes"), true, "")
				end if
			else
				--
				playlist_DeleteItem(releaseCatalog, myPlaylistFile)
				deleteVisibleTraces()
				------
			end if
			
		end if
	else if the name of theObject is "addAlbumButton" then
		display panel window "addAlbumWindow" attached to window "mainList"
	else if the name of theObject is "deleteTrackButton" then
		try
			if trackChosen is not false then
				set myDia to snr((localized string "dialog_RemoveTrack"), "chosenTrack", trackChosen)
				common_displayDialog(myDia, (localized string "button_Yes"), true, "")
			end if
		on error
			error number -128
		end try
	else if the name of theObject is "addTrackButton" then
		try
			set trackLISTstring to refreshTracks(myCurrentListItemFileContents, false)
		on error
			set trackLISTstring to "<--TRACKLIST--><--TRACKLIST-->"
		end try
		set numberOfTracks to (count every paragraph of trackLISTstring)
		
		try
			set trackLISTstring to (trackLISTstring & (ASCII character 10) & "<trackPosition></trackPosition><trackTitle>--Untitled Track " & (random number from 100 to 9999) & " --</trackTitle>")
		on error
			error number -128
		end try
		
		set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
		
		set detailsPrep to longDetailsPrep()
		
		if currentlisttype is "have" then
			do shell script ("echo " & quoted form of detailsPrep & " > " & quoted form of (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/details.txt"))
		else if currentlisttype is "want" then
			do shell script ("echo " & quoted form of detailsPrep & " > " & quoted form of (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/details.txt"))
		end if
		try
			set myCurrentListItemFileContents to (do shell script "cat " & quoted form of myCurrentListItemFile) as string
		on error
			error number -128
		end try
		refreshTracks(myCurrentListItemFileContents, true)
	else if the name of theObject is "moveToOtherListButton" then
		if (title of window "mainList") is not (".:MyVinyl:.") then
			
			--deleteAlbumPrimer()
			if currentlisttype is "have" then
				set myVinylListContents to do shell script ("cat " & quoted form of myVinylList)
				set myVinylListContents to refreshList_Contents_Catalog(myVinylListContents, releaseCatalog, myVinylList, true, "have")
				do shell script ("echo " & quoted form of myVinylListContents & " > " & quoted form of myVinylList)
				delete_dataRow(myVinylListCatalog, releaseCatalog)
			else if currentlisttype is "want" then
				set myVinylWantListContents to do shell script ("cat " & quoted form of myVinylWantList)
				set myVinylWantListContents to refreshList_Contents_Catalog(myVinylWantListContents, releaseCatalog, myVinylWantList, true, "want")
				do shell script ("echo " & quoted form of myVinylWantListContents & " > " & quoted form of myVinylWantList)
				delete_dataRow(myVinylWantListCatalog, releaseCatalog)
			end if
			
			set theHaveListDataSource to data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 1 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
			set theWantListDataSource to data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 2 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
			
			
			set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
			
			if currentlisttype is "have" then
				moveMyAlbum("Wanted")
				---DONE MOVING
				
				set releaseCatalog to destCat
				set detailsPrep to longDetailsPrep()
				do shell script ("echo " & quoted form of detailsPrep & " > " & quoted form of (myAppSupportFolder & "Wanted/" & releaseCatalog & "/details.txt"))
				
				addAlbumOff_Contents("want")
				--set myVinylWantListContents to refreshList_Contents_Catalog("", "", myVinylWantList, false, "want")
				--set myVinylListContents to refreshList_Contents_Catalog("", "", myVinylList, false, "have")
				
				--remove from myvinyllist
				--set myVinylListContents to snr
				--set myVinylListCatalog to myVinylListCatalog&{releaseCatalog}
				
				repeat with a from 1 to (count myVinylListCatalog)
					try
						common_placeZeros(theHaveListDataSource, a, (count myVinylListCatalog))
					on error number (-1719)
						exit repeat
					end try
				end repeat
				set releaseCatalog to common_catalogFlip(releaseCatalog, "view")
				fillDataSourcesOffline("want")
				addToRecentActivity("Moved", "want")
				------
			else if currentlisttype is "want" then
				moveMyAlbum("Collection")
				---DONE MOVING
				
				set releaseCatalog to destCat
				set detailsPrep to longDetailsPrep()
				do shell script ("echo " & quoted form of detailsPrep & " > " & quoted form of (myAppSupportFolder & "Collection/" & releaseCatalog & "/details.txt"))
				
				addAlbumOff_Contents("have")
				--set myVinylListContents to refreshList_Contents_Catalog("", "", myVinylList, false, "have")
				--set myVinylWantListContents to refreshList_Contents_Catalog("", "", myVinylWantList, false, "want")
				repeat with a from 1 to (count myVinylWantListCatalog)
					try
						common_placeZeros(theWantListDataSource, a, (count myVinylWantListCatalog))
					on error number (-1719)
						exit repeat
					end try
				end repeat
				set releaseCatalog to common_catalogFlip(releaseCatalog, "view")
				fillDataSourcesOffline("have")
				addToRecentActivity("Moved", "have")
				------
			end if
			
			set theHaveListDataSource to data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 1 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
			set theWantListDataSource to data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 2 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
			
			--set myVinylWantListContents to refreshList_Contents_Catalog("", "", myVinylWantList, false, "want")
			--set myVinylListContents to refreshList_Contents_Catalog("", "", myVinylList, false, "have")
			
			if myVinylListCatalog is {} then
				common_totalCountText("have", true, myVinylListCatalog)
			else
				common_totalCountText("have", false, myVinylListCatalog)
			end if
			if myVinylWantListCatalog is {} then
				common_totalCountText("want", true, myVinylWantListCatalog)
			else
				common_totalCountText("want", false, myVinylWantListCatalog)
			end if
			
			do shell script ("echo " & quoted form of myVinylWantListContents & " > " & quoted form of myVinylWantList)
			do shell script ("echo " & quoted form of myVinylListContents & " > " & quoted form of myVinylList)
			
			deleteVisibleTraces()
			
			set data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item "haveTab" of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to theHaveListDataSource
			set data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item "wantTab" of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to theWantListDataSource
			
			--selectionDiffer("change")
		end if
	else if the name of theObject is "confirmdialog" then
		try
			say (title of theObject as string)
		end try
		close panel window "dialogwindow"
		set diaText to (the contents of text field 1 of window "dialogWindow")
		if diaText ends with (localized string "endsWith_FromTrackList") then
			tell (table view "trackListTableView" of scroll view "trackListScrollView" of drawer 1 of window "mainList")
				set trackPos_old to (contents of data cell "trackPosition" of selected data row)
				set trackTit_old to (contents of data cell "trackTitle" of selected data row)
			end tell
			modifyTrack(myCurrentListItemFileContents, "deleteTrack", "", "", trackPos_old, trackTit_old)
		else if diaText contains (localized string "contains_NoLongerHave") then
			deleteAlbumHaveList()
		else if diaText contains (localized string "contains_NoLongerWant") then
			deleteAlbumWantList()
		else if diaText is (localized string "dialog_DiscogsSyncSafari") then
			----
			----ADDTO LISTS
			
			set useThisList to (contents of data cell 1 of every data row of data source of table view 1 of scroll view 1 of window "recentActivityWindow")
			set nextRecent to false
			repeat with a from 1 to (count useThisList)
				set currentScopeItem to (item a of useThisList)
				set urlType to "http://www.discogs.com/list/"
				try
					set rID to (word 2 of currentScopeItem)
					set rID to rID as string
				on error
					set nextRecent to true
				end try
				try
					set rID2 to (word 4 of currentScopeItem)
					set rID2 to rID2 as string
				end try
				if nextRecent is false then
					if currentScopeItem starts with "Added " then
						if currentScopeItem ends with "have list." then
							set urlType to (urlType & "coll_add?release_id=" & rID)
						else if currentScopeItem ends with "want list." then
							set urlType to (urlType & "want_add?release_id=" & rID)
						end if
						tell application "Safari" to open location urlType
						delay 1
						tell application "Safari" to close front window
					else if currentScopeItem starts with "Removed " then
						if currentScopeItem ends with "have list." then
							set urlType to (urlType & "coll_remove?release_id=" & rID & "&inst=1")
						else if currentScopeItem ends with "want list." then
							set urlType to (urlType & "want_remove?release_id=" & rID)
						end if
						tell application "Safari" to open location urlType
						delay 1
						tell application "Safari" to close front window
					else if currentScopeItem starts with "Moved " then
						if currentScopeItem ends with "have list." then
							set urlType to (urlType & "want_remove?release_id=" & rID)
							tell application "Safari" to open location urlType
							delay 1
							tell application "Safari" to close front window
							set urlType to "http://www.discogs.com/list/"
							set urlType to (urlType & "coll_add?release_id=" & rID)
							tell application "Safari" to open location urlType
							delay 1
							tell application "Safari" to close front window
						else if currentScopeItem ends with "want list." then
							set urlType to (urlType & "coll_remove?release_id=" & rID & "&inst=1")
							tell application "Safari" to open location urlType
							delay 1
							tell application "Safari" to close front window
							set urlType to "http://www.discogs.com/list/"
							set urlType to (urlType & "want_add?release_id=" & rID)
							tell application "Safari" to open location urlType
							delay 1
							tell application "Safari" to close front window
						end if
					else if currentScopeItem starts with "Changed " then
						if currentScopeItem ends with "have list." then
							if rID is not "none" then
								set urlType to (urlType & "coll_remove?release_id=" & rID & "&inst=1")
								tell application "Safari" to open location urlType
								delay 1
								tell application "Safari" to close front window
							end if
							if rID2 is not "none" then
								set urlType to "http://www.discogs.com/list/"
								set urlType to (urlType & "coll_add?release_id=" & rID2)
								tell application "Safari" to open location urlType
								delay 1
								tell application "Safari" to close front window
							end if
						else if currentScopeItem ends with "want list." then
							if rID is not "" then
								set urlType to (urlType & "want_remove?release_id=" & rID)
								tell application "Safari" to open location urlType
								delay 1
								tell application "Safari" to close front window
							end if
							if rID2 is not "none" then
								set urlType to "http://www.discogs.com/list/"
								set urlType to (urlType & "want_add?release_id=" & rID2)
								tell application "Safari" to open location urlType
								delay 1
								tell application "Safari" to close front window
							end if
						end if
					end if
				end if
			end repeat
			common_displayDialog((localized string "dialog_FinishedSync"), (localized string "button_ClearRecent"), true, "")
		else if the title of theObject is (localized string "button_Quit") then
			tell me to quit
		else if the title of theObject is (localized string "button_ClearRecent") then
			set myRecentActivityListContents to ""
			do shell script ("echo " & quoted form of myRecentActivityListContents & " > " & quoted form of myRecentActivityList)
			set (content of table view 1 of scroll view 1 of window "recentActivityWindow") to {}
			set content of text field "recentActivityCountBox" of window "recentActivityWindow" to ("0 items")
		end if
	else if the name of theObject is "canceldialog" then
		close panel window "dialogwindow"
		error number -128
	else if the name of theObject is "cancel-importWindow" then
		close panel window "importOnOpenWindow"
	else if the name of theObject is "collection-importWindow" then
		close panel window "importOnOpenWindow"
		importDiscogsXML("have", (item 1 of nlMasta as string))
	else if the name of theObject is "wantlist-importWindow" then
		close panel window "importOnOpenWindow"
		importDiscogsXML("want", (item 1 of nlMasta as string))
	else if the name of theObject is "showArtWindowButton" then
		if visible of (split view 1 of window "mainList") is true then
			set visible of split view 1 of window "mainList" to false
			set visible of (image view "bigMainListArtBox" of window "mainList") to true
		else
			set visible of (image view "bigMainListArtBox" of window "mainList") to false
			set visible of split view 1 of window "mainList" to true
		end if
	else if the name of theObject is "addAlbumOnlineReleaseIDSubmit" then
		close panel window "addAlbumWindow"
		set releaseID to (contents of text field "addAlbumOnlineReleaseNumber" of tab view item 2 of tab view 1 of window "addAlbumWindow" as string)
		set releaseCatalog to onlineAddFunction(releaseID)
		
		if result is "ERROR_Discogs_Fail" then
			display alert "Discogs is not responding."
			set releaseCatalog to ""
			deleteVisibleTraces()
		else
			selectionDiffer("change")
		end if
	else if the name of theObject is "playTrackButton" then
		try
			set albumChosen to getMyAlbum()
		on error
			error number -128
		end try
		
		if releaseArtist ends with ", The" then
			set artistName to item 1 of split(releaseArtist, ", The")
			set artistName to ("The " & artistName)
		else
			set artistName to releaseArtist
		end if
		
		set albumName to releaseAlbum
		try
			copy trackChosen to trackName
		on error
			error number -128
		end try
		tell application "iTunes"
			set results to (every file track of playlist "Library" whose name contains trackName and artist contains artistName and album contains albumName)
			repeat with t in results
				play t
			end repeat
		end tell
	else if the name of theObject is "clearActivityListButton" then
		set myRecentActivityListContents to ""
		do shell script ("echo " & quoted form of myRecentActivityListContents & " > " & quoted form of myRecentActivityList)
		set (content of table view 1 of scroll view 1 of window "recentActivityWindow") to {}
		set content of text field "recentActivityCountBox" of window "recentActivityWindow" to ("0 items")
		------
	else if the name of theObject is "importCancel" then
		close panel window 1
		set cancelImportVar to true
	else if the name of theObject is "updateEntry" then
		if releaseID is not "" then
			set visible of text field "loadingUpdateItem" of window "updateAlbumWindow" to true
			show window "updateAlbumWindow"
			set updt_catalog to onlineAddFunction(releaseID)
			if result is "ERROR_Discogs_Fail" then
				display alert "Discogs is not responding."
			else
				set updt_tempFile to (myAppSupportFolder & currentFolderType & "/_temp." & releaseID & ".details.txt")
				set updt_tempFileContents to (do shell script ("cat " & quoted form of updt_tempFile))
				
				--CATALOG
				set updt_catalog to item 2 of split(updt_tempFileContents, "<--CATALOG-->")
				set updt_catalog to common_catalogFlip(updt_catalog, "view")
				
				--<--CONDITION-->
				try
					set updt_condition to item 2 of split(updt_tempFileContents, "<--CONDITION-->")
				on error
					set updt_condition to ""
				end try
				
				--<--RELEASEID-->
				try
					set updt_releaseID to item 2 of split(updt_tempFileContents, "<--RELEASEID-->")
				on error
					set updt_releaseID to ""
				end try
				
				--<--FORMAT-->
				try
					set updt_format to item 2 of split(updt_tempFileContents, "<--FORMAT-->")
				on error
					set updt_format to ""
				end try
				
				--DATE
				try
					set updt_date to item 2 of split(updt_tempFileContents, "<--RELEASED-->")
				on error
					set updt_date to ""
				end try
				
				--COUNTRY
				try
					set updt_country to item 2 of split(updt_tempFileContents, "<--COUNTRY-->")
				on error
					set updt_country to ""
				end try
				
				--LABEL
				try
					set updt_label to item 2 of split(updt_tempFileContents, "<--LABEL-->")
				on error
					set updt_label to ""
				end try
				
				--NAME
				set updt_artist to item 2 of split(updt_tempFileContents, "<--NAME-->")
				--ALBUM
				set updt_album to item 2 of split(updt_artist, " - ")
				--ARTIST
				set updt_artist to item 1 of split(updt_artist, " - ")
				
				--NOTES
				try
					set updt_notes to item 2 of split(updt_tempFileContents, "<--NOTES-->")
				on error
					set updt_notes to ""
				end try
				
				--CREDITS
				try
					set updt_credits to item 2 of split(updt_tempFileContents, "<--CREDITS-->")
				on error
					set updt_credits to ""
				end try
				
				--IMGHREF
				try
					set updt_image to item 2 of split(updt_tempFileContents, "<--IMGHREF-->")
					if updt_image is not "" then
						do shell script ("cd " & quoted form of (appsup) & ";curl " & updt_image & " -o updt_img.jpeg")
						set image of image view "updt_artView" of window "updateAlbumWindow" to load image (appsup & "updt_img.jpeg")
					else
						delete image of image view "updt_artView" of window "updateAlbumWindow"
					end if
				on error
					set updt_image to ""
				end try
				
				
				---DEFINE TRACKLISTSTRING HERE
				try
					set trackLISTstring to refreshTracks(myCurrentListItemFileContents, false)
				on error
					set trackLISTstring to "<--TRACKLIST--><--TRACKLIST-->"
				end try
				set updt_tracks to refreshTracks(updt_tempFileContents, true)
				
				tell window "updateAlbumWindow"
					set contents of text field "updateAlbumArtist" to updt_artist
					set contents of text field "updateAlbumTitle" to updt_album
					set contents of text field "updateAlbumLabel" to updt_label
					set contents of text field "updateAlbumCountry" to updt_country
					set contents of text field "updateAlbumCatalog" to updt_catalog
					set contents of text field "updateAlbumDate" to updt_date
					set contents of text field "updateAlbumFormat" to updt_format
					set contents of text field "updateAlbumNotes" to updt_notes
					set contents of text field "updateAlbumCredits" to updt_credits
				end tell
			end if
			set visible of text field "loadingUpdateItem" of window "updateAlbumWindow" to false
		else
			common_displayDialog((localized string "dialog_OnlyDiscogsUpdate"), (localized string "button_Oh"), false, "")
		end if
	else if the name of theObject is "updateAlbumSubmit" then
		close window "updateAlbumWindow"
		
		if currentlisttype is "have" then
			set temp_dataSrc to theHaveListDataSource
			set temp_vinyList to myVinylListCatalog
		else
			set temp_dataSrc to theWantListDataSource
			set temp_vinyList to myVinylWantListCatalog
		end if
		
		if state of button "updateAlbumArtistBox" of window "updateAlbumWindow" is 1 then
			set releaseArtist to contents of text field "updateAlbumArtist" of window "updateAlbumWindow"
			set (contents of data cell "artistColumn" of data row (albumNo as integer) of temp_dataSrc) to releaseArtist
		end if
		
		if state of button "updateAlbumTitleBox" of window "updateAlbumWindow" is 1 then
			set releaseAlbum to contents of text field "updateAlbumTitle" of window "updateAlbumWindow"
			set (contents of data cell "titleColumn" of data row (albumNo as integer) of temp_dataSrc) to releaseAlbum
		end if
		
		if state of button "updateAlbumLabelBox" of window "updateAlbumWindow" is 1 then
			set releaseLABEL to (contents of text field "updateAlbumLabel" of window "updateAlbumWindow")
			set (contents of data cell "labelColumn" of data row (albumNo as integer) of temp_dataSrc) to releaseLABEL
		end if
		
		if state of button "updateAlbumCountryBox" of window "updateAlbumWindow" is 1 then
			set releaseCountry to contents of text field "updateAlbumCountry" of window "updateAlbumWindow"
			set (contents of data cell "countryColumn" of data row (albumNo as integer) of temp_dataSrc) to releaseCountry
		end if
		
		if state of button "updateAlbumDateBox" of window "updateAlbumWindow" is 1 then
			set releaseDate to contents of text field "updateAlbumDate" of window "updateAlbumWindow"
			set (contents of data cell "releaseDateColumn" of data row (albumNo as integer) of temp_dataSrc) to releaseDate
		end if
		
		if state of button "updateAlbumFormatBox" of window "updateAlbumWindow" is 1 then
			set releaseFormat to contents of text field "updateAlbumFormat" of window "updateAlbumWindow"
			set (contents of data cell "formatColumn" of data row (albumNo as integer) of temp_dataSrc) to releaseFormat
		end if
		
		if state of button "updateAlbumNotesBox" of window "updateAlbumWindow" is 1 then
			set releaseNotes to contents of text field "updateAlbumNotes" of window "updateAlbumWindow"
			set (contents of text view 1 of scroll view 1 of tab view item 2 of tab view 1 of view 2 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList") to releaseNotes
		end if
		
		if state of button "updateAlbumCreditsBox" of window "updateAlbumWindow" is 1 then
			set releaseCredits to contents of text field "updateAlbumCredits" of window "updateAlbumWindow"
			set (contents of text view 1 of scroll view 1 of tab view item 1 of tab view 1 of view 2 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList") to releaseCredits
		end if
		
		set skipCat to true
		set albumOrigCatalog to ""
		
		if state of button "updateAlbumCatalogBox" of window "updateAlbumWindow" is 1 then
			if (releaseCatalog is not equal to (contents of text field "updateAlbumCatalog" of window "updateAlbumWindow")) then
				--new cat
				set skipCat to false
				set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
				copy releaseCatalog to albumOrigCatalog
				set releaseCatalog to contents of text field "updateAlbumCatalog" of window "updateAlbumWindow"
				set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
				set releaseCatalog to common_findCatalogDupes("first", currentFolderType, releaseCatalog)
				set releaseCatalog to common_catalogFlip(releaseCatalog, "view")
				
				
				
				set (contents of data cell "catalogColumn" of data row (albumNo as integer) of temp_dataSrc) to releaseCatalog
				
				set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
				updatePlaylistCat(albumOrigCatalog)
				updateCatalogNo(albumOrigCatalog)
			end if
		end if
		
		set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
		
		set releaseName to {releaseArtist, " - ", releaseAlbum} as string
		copy releaseName to albumChosen
		
		if state of button "updateAlbumTracklistBox" of window "updateAlbumWindow" is 1 then
			try
				set trackLISTstring to refreshTracks(updt_tempFileContents, true)
			on error
				set trackLISTstring to "<--TRACKLIST--><--TRACKLIST-->"
			end try
		else
			try
				set trackLISTstring to refreshTracks(myCurrentListItemFileContents, true)
			on error
				set trackLISTstring to "<--TRACKLIST--><--TRACKLIST-->"
			end try
		end if
		
		set detailsPrep to longDetailsPrep()
		
		if skipCat is false then
			try
				do shell script "mv " & quoted form of (myAppSupportFolder & currentFolderType & "/" & albumOrigCatalog & "/details.txt") & " " & quoted form of (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/details.txt")
				do shell script "mv " & quoted form of (myAppSupportFolder & currentFolderType & "/" & albumOrigCatalog & "/image.jpeg") & " " & quoted form of (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/image.jpeg")
			end try
			try
				do shell script "rm -r " & quoted form of (myAppSupportFolder & currentFolderType & "/" & albumOrigCatalog & "/")
			end try
		end if
		
		do shell script ("echo " & quoted form of detailsPrep & " > " & quoted form of (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/details.txt"))
		
		if state of button "updateAlbumArtBox" of window "updateAlbumWindow" is 1 then
			try
				do shell script "mv " & quoted form of (appsup & "updt_img.jpeg") & " " & quoted form of (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/image.jpeg")
				set image of image view "bigMainListArtBox" of window "mainList" to load image (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/image.jpeg")
				set image of image view "mainListArtBox" of (view 1 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList") to load image (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/image.jpeg")
			on error
				clearArt()
			end try
		end if
		
		set myCurrentListItemFile to (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/details.txt") as string
		set myCurrentListItemFileContents to (do shell script "cat " & quoted form of myCurrentListItemFile) as string
		set releaseCatalog to common_catalogFlip(releaseCatalog, "view")
		updateReleaseNameBoxes()
		
		close window "updateAlbumWindow"
	else if the name of theObject is "applyActivityListButton" then
		set myRecentActivityListContents to (do shell script "cat " & quoted form of myRecentActivityList)
		
		if myRecentActivityListContents is not "" then
			common_displayDialog((localized string "dialog_DiscogsSyncSafari"), (localized string "button_Yes"), true, "")
		else
			common_displayDialog((localized string "dialog_NothingToSync"), (localized string "button_Oh"), false, "")
		end if
	else if the name of theObject is "closePrefs" then
		close panel window "prefsWindow"
		set myAppSupportFolderB to contents of text field "visiblePathToCollection" of window "prefsWindow"
		if myAppSupportFolderB is "~/Library/Application Support/myVinyl/" then
			set myAppSupportFolderB to ((POSIX path of (path to home folder)) & "Library/Application Support/myVinyl/") as string
		end if
		if myAppSupportFolder is not equal to myAppSupportFolderB then
			try
				do shell script ("cd " & quoted form of myAppSupportFolder & ";mv Collection " & quoted form of myAppSupportFolderB)
				do shell script ("cd " & quoted form of myAppSupportFolder & ";mv Wanted " & quoted form of myAppSupportFolderB)
				do shell script ("cd " & quoted form of myAppSupportFolder & ";mv myVinylList.txt " & quoted form of myAppSupportFolderB)
				do shell script ("cd " & quoted form of myAppSupportFolder & ";mv myVinylWantList.txt " & quoted form of myAppSupportFolderB)
			end try
			try
				do shell script ("cd " & quoted form of myAppSupportFolder & ";mv recentActivity.txt " & quoted form of myAppSupportFolderB)
				try
					do shell script ("cd " & quoted form of myAppSupportFolder & ";mv Playlists " & quoted form of myAppSupportFolderB)
				end try
			end try
		end if
		set myAppSupportFolder to myAppSupportFolderB
		savePrefs()
	else if the name of theObject is "choosePathToCollection" then
		set contents of text field "visiblePathToCollection" of window "prefsWindow" to ((POSIX path of (choose folder)) as string)
	else if the name of theObject is "importContinue" then
		close panel window "importingChooseAmount"
		display panel window "importing" attached to window "mainList"
		set startVal to (contents of text field "importFromValue" of window "importingChooseAmount")
		set endVal to (contents of text field "importToValue" of window "importingChooseAmount")
		
		if (startVal as integer) is less than 2 then
			set startVal to "1"
		end if
		if (endVal as integer) is greater than releaseLimiter then
			close panel window "importing"
			common_displayDialog((localized string "dialog_ImpossibleRange"), (localized string "button_Oh"), false, "")
			error number -128
		end if
		if (startVal as integer) is greater than (endVal as integer) then
			close panel window "importing"
			common_displayDialog((localized string "dialog_ImpossibleRange"), (localized string "button_Oh"), false, "")
			error number -128
		end if
		if (startVal as integer) is greater than ((myCountCat) + 1) then
			close panel window "importing"
			common_displayDialog((localized string "dialog_ImpossibleRange"), (localized string "button_Oh"), false, "")
			error number -128
		end if
		
		if startVal is "1" then
			try
				do shell script "rm -r " & quoted form of (myAppSupportFolder & currentFolderType & "/")
			end try
			if currentlisttype is "have" then
				set myVinylListContents to ""
				set myVinylListCatalog to {}
				set content of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 1 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to {}
				try
					do shell script "rm -r " & quoted form of (myVinylList)
				end try
			else if currentlisttype is "want" then
				set myVinylWantListContents to ""
				set myVinylWantListCatalog to {}
				set content of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 2 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to {}
				try
					do shell script "rm -r " & quoted form of (myVinylWantList)
				end try
			end if
			try
				do shell script "mkdir " & quoted form of (myAppSupportFolder & currentFolderType & "/")
			end try
		end if
		set fromVal to (contents of text field "importFromValue" of window "importingChooseAmount")
		
		if currentlisttype is "have" then
			try
				set myVinylListContents to (do shell script "cat " & quoted form of myVinylList) as string
			on error number (1)
				set myVinylListContents to ""
			end try
			
			set myVinylKeep to common_cleanMyList(every paragraph of myVinylListContents, {""})
			if myVinylListCatalog is not {} then
				if startVal is not "1" then
					set myVinylKeep to myImportKeep(myVinylKeep)
					do shell script ("echo " & quoted form of (item 1 of myVinylKeep as string) & " > " & quoted form of myVinylList)
				end if
			else
				if startVal is not "1" then
					close panel window "importing"
					common_displayDialog((localized string "dialog_StartAtOne"), (localized string "button_Oh"), false, "")
					error number -128
				end if
			end if
			
			importLastPhase(myVinylKeep, startVal, endVal)
		else if currentlisttype is "want" then
			try
				set myVinylWantListContents to (do shell script "cat " & quoted form of myVinylWantList) as string
			on error number (1)
				set myVinylWantListContents to ""
			end try
			
			set myVinylKeep to common_cleanMyList(every paragraph of myVinylWantListContents, {""})
			if myVinylWantListCatalog is not {} then
				if startVal is not "1" then
					set myVinylKeep to myImportKeep(myVinylKeep)
					do shell script ("echo " & quoted form of (item 1 of myVinylKeep as string) & " > " & quoted form of myVinylWantList)
				end if
			else
				if startVal is not "1" then
					close panel window "importing"
					common_displayDialog((localized string "dialog_StartAtOne"), (localized string "button_Oh"), false, "")
					error number -128
				end if
			end if
			
			importLastPhase(myVinylKeep, startVal, endVal)
			
		end if
		close panel window "importing"
		common_displayDialog((localized string "dialog_QuitAfterImport"), (localized string "button_Quit"), true, "")
	else if the name of theObject is "addPlaylist" then
		display panel window "newPlaylist" attached to window "mainList"
	else if the name of theObject is "createPlaylist" then
		playlist_Create()
		
	else if the name of theObject is "deletePlaylist" then
		playlist_Delete()
		
		set playlistName to (title of popup button "playlistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
		playlist_Show(playlistName)
		
	else if the name of theObject is "moveToPlaylist" then
		playlist_MoveItem()
	else if the name of theObject is "deleteRecentEntry" then
		try
			set myRecentActivityListContents to (do shell script "cat " & quoted form of myRecentActivityList)
			--updateRecentList()
		on error
			set myRecentActivityListContents to ""
		end try
		if (myRecentActivityListContents) is not "" then
			try
				set myRecentItem to ((contents of data cell 1 of selected data row of table view 1 of scroll view 1 of window "recentActivityWindow") as string)
			on error
				error number -128
			end try
			set myRecentActivityListContents to snr(myRecentActivityListContents, ("<..change!-...>" & myRecentItem), "") as string
			do shell script ("echo " & quoted form of myRecentActivityListContents & " > " & quoted form of myRecentActivityList)
			try
				set myRecentActivityListContents to (do shell script "cat " & quoted form of myRecentActivityList)
				updateRecentList()
			on error
				set myRecentActivityListContents to ""
			end try
		end if
	else if the name of theObject is "upgradeDB_quit" then
		--hide window "upgradeDBWindow"
		tell me to quit
	else if the name of theObject is "upgradeDB_upgrade" then
		set otherScript to useOtherScript("upgradeDB")
		tell otherScript
			upgradeDBMain(myAppSupportFolder)
			upgradeDBPlaylists(myAppSupportFolder)
			upgradeDBTracks(myAppSupportFolder)
		end tell
		
		common_displayDialog("Finished upgrading!", (localized string "button_Yay"), false, "")
		
	else if the name of theObject is "addFromSearch" then
		set theSearchXMLDataSource to data source of table view 1 of scroll view 1 of view 1 of split view 1 of window "searchXMLWindow"
		
		tell (table view 1 of scroll view 1 of view 1 of split view 1 of window "searchXMLWindow")
			set sel to selected rows
		end tell
		if sel is not {} then
			set myChosenRType to content of data cell "type" of selected data row of (table view 1 of scroll view 1 of view 1 of split view 1 of window "searchXMLWindow")
			set myChosenURL to content of data cell "urli" of selected data row of (table view 1 of scroll view 1 of view 1 of split view 1 of window "searchXMLWindow")
			
			if myChosenRType is not "release" then
				open location ("http://www.discogs.com/" & myChosenRType & "/" & myChosenURL)
			else
				onlineAddFunction(myChosenURL)
				if result is "ERROR_Discogs_Fail" then
					display alert "Discogs is not responding."
				end if
			end if
		end if
		
		try
			(do shell script ("rm " & quoted form of updt_tempFile))
		end try
	else if the name of theObject is "closeSearchXMLWindow" then
		try
			do shell script ("cd " & quoted form of (myAppSupportFolder & currentFolderType & "/") & (";rm _temp.*.details.txt"))
		end try
		close panel window "searchXMLWindow"
	end if
end clicked


on selection changed theObject
	if the name of theObject is "mainWindowList" then
		selectionDiffer("change")
	else if the name of theObject is "trackListTableView" then
		try
			set trackChosen to ((contents of data cell "trackTitle" of selected data row of table view "trackListTableView" of scroll view "trackListScrollView" of drawer "trackListView" of window "mainList") as string)
		on error
			set trackChosen to false
		end try
	else if the name of theObject is "searchXMLTable" then
		set visible of button "addFromSearch" of window "searchXMLWindow" to false
		set old_size_searchXML to (size of view 2 of split view 1 of window "searchXMLWindow")
		set (size of view 2 of split view 1 of window "searchXMLWindow") to {((item 1 of old_size_searchXML) as integer), 0}
		
		try
			(do shell script ("rm " & quoted form of updt_tempFile))
		end try
		set currentTab to name of current tab view item of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
		try
			set sel to selected row of theObject
		end try
		if sel is not {} then
			try
				set myChosenRType to content of data cell "type" of selected data row of theObject
				set myChosenURL to content of data cell "urli" of selected data row of theObject
				
				if myChosenRType is "release" then
					if currentTab is "haveTab" then
						set title of button "addFromSearch" of window "searchXMLWindow" to (localized string "button_IHaveThis")
					else
						set title of button "addFromSearch" of window "searchXMLWindow" to (localized string "button_IWantThis")
					end if
				else
					set title of button "addFromSearch" of window "searchXMLWindow" to (localized string ("misc_ViewOnDiscogs"))
				end if
				
				
				--SET WEB VIEW
				if myChosenRType is "release" then
					tell (progress indicator 1 of view 1 of split view 1 of window "searchXMLWindow")
						start
						set visible to true
					end tell
					
					onlineAddFunction(myChosenURL)
					
					if myChosenURL is not "" then
						set updt_catalog to onlineAddFunction(myChosenURL)
						if result is "ERROR_Discogs_Fail" then
							display alert "Discogs is not responding."
						else
							set updt_tempFile to (myAppSupportFolder & currentFolderType & "/_temp." & myChosenURL & ".details.txt")
							set updt_tempFileContents to (do shell script ("cat " & quoted form of updt_tempFile))
							
							--CATALOG
							set updt_catalog to item 2 of split(updt_tempFileContents, "<--CATALOG-->")
							set updt_catalog to common_catalogFlip(updt_catalog, "view")
							
							--<--RELEASEID-->
							try
								set updt_releaseID to item 2 of split(updt_tempFileContents, "<--RELEASEID-->")
							on error
								set updt_releaseID to ""
							end try
							
							--<--FORMAT-->
							try
								set updt_format to item 2 of split(updt_tempFileContents, "<--FORMAT-->")
							on error
								set updt_format to ""
							end try
							
							--DATE
							try
								set updt_date to item 2 of split(updt_tempFileContents, "<--RELEASED-->")
							on error
								set updt_date to ""
							end try
							
							--COUNTRY
							try
								set updt_country to item 2 of split(updt_tempFileContents, "<--COUNTRY-->")
							on error
								set updt_country to ""
							end try
							
							--LABEL
							try
								set updt_label to item 2 of split(updt_tempFileContents, "<--LABEL-->")
							on error
								set updt_label to ""
							end try
							
							--NAME
							set updt_artist to item 2 of split(updt_tempFileContents, "<--NAME-->")
							--ALBUM
							set updt_album to item 2 of split(updt_artist, " - ")
							--ARTIST
							set updt_artist to item 1 of split(updt_artist, " - ")
							
							--NOTES
							try
								set updt_notes to item 2 of split(updt_tempFileContents, "<--NOTES-->")
							on error
								set updt_notes to ""
							end try
							
							
							--IMGHREF
							try
								set updt_image to item 2 of split(updt_tempFileContents, "<--IMGHREF-->")
								if updt_image is not "" then
									do shell script ("cd " & quoted form of (appsup) & ";curl " & updt_image & " -o updt_img.jpeg")
									tell tab view item 3 of tab view 1 of view 2 of split view 1 of window "searchXMLWindow"
										set image of image view "searchXML_artView" to load image (appsup & "updt_img.jpeg")
									end tell
								else
									tell tab view item 3 of tab view 1 of view 2 of split view 1 of window "searchXMLWindow"
										delete image of image view "searchXML_artView"
									end tell
								end if
							on error
								set updt_image to ""
							end try
							
							tell view 2 of split view 1 of window "searchXMLWindow"
								--set contents of text field "searchXMLAlbumArtist" to ((localized string "album_Artist") & ": " & updt_artist)
								--set contents of text field "searchXMLAlbumTitle" to ((localized string "album_Title") & ": " & updt_album)
								tell tab view 1
									tell tab view item 1
										set contents of text field "searchXMLAlbumTitleArtist" to (updt_artist & " - " & updt_album)
										set contents of text field "searchXMLAlbumLabel" to ((localized string "album_Label") & ": " & updt_label)
										set contents of text field "searchXMLAlbumCountry" to ((localized string "album_Country") & ": " & updt_country)
										set contents of text field "searchXMLAlbumCatalog" to ((localized string "album_Catalog") & ": " & updt_catalog)
										set contents of text field "searchXMLAlbumDate" to ((localized string "album_Date") & ": " & updt_date)
										set contents of text field "searchXMLAlbumFormat" to ((localized string "album_Format") & ": " & updt_format)
									end tell
									tell tab view item 2
										set contents of text field "searchXMLAlbumNotes" to (updt_notes)
									end tell
								end tell
							end tell
							set visible of tab view 1 of view 2 of split view 1 of window "searchXMLWindow" to true
							
							set mySplitSize to (size of split view 1 of window "searchXMLWindow")
							set myNewHeight to (item 2 of (mySplitSize)) as integer
							set myNewHeight to ((myNewHeight / 4) * 3)
							set (size of view 2 of split view 1 of window "searchXMLWindow") to {((item 1 of old_size_searchXML) as integer), myNewHeight}
						end if
					else
						common_displayDialog((localized string "dialog_OnlyDiscogsUpdate"), (localized string "button_Oh"), false, "")
					end if
				end if
				set visible of button "addFromSearch" of window "searchXMLWindow" to true
				--loadPage from ("http://www.discogs.com/" & myChosenRType & "/" & myChosenURL)
			on error number (-1728)
				set visible of button "addFromSearch" of window "searchXMLWindow" to false
			end try
		else
			set visible of button "addFromSearch" of window "searchXMLWindow" to false
		end if
		try
			tell (progress indicator 1 of view 1 of split view 1 of window "searchXMLWindow")
				stop
				set visible to false
			end tell
		end try
	end if
end selection changed

on should quit after last window closed theObject
	return true
end should quit after last window closed

on drop theObject drag info dragInfo
	if the name of theObject is "mainListArtBox" then
		dropAlbumArt(dragInfo, "main")
	else if the name of theObject is "bigMainListArtBox" then
		dropAlbumArt(dragInfo, "main")
	else if the name of theObject is "updt_artView" then
		dropAlbumArt(dragInfo, "updateItem")
	end if
end drop

on change cell value theObject row theRow table column tableColumn value theValue
	if the name of theObject is "trackListTableView" then
		set trackPos_old to (contents of data cell "trackPosition" of selected data row of theObject)
		set trackTit_old to (contents of data cell "trackTitle" of selected data row of theObject)
		modifyTrack(myCurrentListItemFileContents, "editTrack", theValue, tableColumn, trackPos_old, trackTit_old)
	else if the name of theObject is "updt_trackListTableView" then
		set trackPos_old to (contents of data cell "trackPosition" of selected data row of theObject)
		set trackTit_old to (contents of data cell "trackTitle" of selected data row of theObject)
		modifyTrack(updt_tempFileContents, "editTrack", theValue, tableColumn, trackPos_old, trackTit_old)
	end if
end change cell value
on will select tab view item theObject tab view item tabViewItem
	if name of tabViewItem = "haveTab" then
		set currentlisttype to "have"
		if myVinylListCatalog is {} then
			common_totalCountText("have", true, myVinylListCatalog)
		else
			common_totalCountText("have", false, myVinylListCatalog)
		end if
		set currentFolderType to "Collection"
		set theCurrentDataSource to theHaveListDataSource
		try
			selectionDiffer("change")
		end try
		set title of button "moveToOtherListButton" of window "mainList" to (localized string "button_IWantThis")
		set title of menu item "buySellMenuItem" of menu 2 of main menu to (localized string "menu_SellOn")
	else if name of tabViewItem = "wantTab" then
		set currentlisttype to "want"
		if myVinylWantListCatalog is {} then
			common_totalCountText("want", true, myVinylWantListCatalog)
		else
			common_totalCountText("want", false, myVinylWantListCatalog)
		end if
		set currentFolderType to "Wanted"
		set theCurrentDataSource to theWantListDataSource
		try
			selectionDiffer("change")
		end try
		set title of button "moveToOtherListButton" of window "mainList" to (localized string "button_IHaveThis")
		set title of menu item "buySellMenuItem" of menu 2 of main menu to (localized string "menu_BuyFrom")
	else if name of tabViewItem = "creditsTab" then
		set currentBottomType to "credits"
	else if name of tabViewItem = "notesTab" then
		set currentBottomType to "notes"
	end if
end will select tab view item


on cell value changed theObject row theRow table column tableColumn value theValue
	if the name of theObject is "mainWindowList" then
		set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
		copy releaseCatalog to albumOrigCatalog
		copy albumNo to origAlbumNo
		copy releaseID to origReleaseID
		
		if currentlisttype is "have" then
			set theCurrentDataSource to table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 1 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
		else if currentlisttype is "want" then
			set theCurrentDataSource to table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 2 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
		end if
		set releaseNotes to contents of text view 1 of scroll view 1 of tab view item 2 of tab view 1 of view 2 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList"
		
		set bab to name of (tableColumn) as string
		
		if bab is "artistColumn" then
			set releaseArtist to theValue
		else if bab is "titleColumn" then
			set releaseAlbum to theValue
		else if bab is "catalogColumn" then
			set releaseCatalog to theValue
			set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
		else if bab is "labelColumn" then
			set releaseLABEL to theValue
		else if bab is "countryColumn" then
			set releaseCountry to theValue
		else if bab is "releaseDateColumn" then
			set releaseDate to theValue
		else if bab is "formatColumn" then
			set releaseFormat to theValue
		else if bab is "releaseIDColumn" then
			set releaseID to theValue
		else if bab is "conditionColumn" then
			set releaseCondition to theValue
		else if bab is "numColumn" then
			set albumNo to theValue
			
		else if bab is "BPMColumn" then
			set myBPM to theValue
		else if bab is "genreColumn" then
			set myGenre to theValue
		else if bab is "styleColumn" then
			set myStyle to theValue
		else if bab is "songPreferenceColumn" then
			set mySongPreference to theValue
		else if bab is "keySignatureColumn" then
			set myKeySignature to theValue
		else if bab is "commentsColumn" then
			set myComments to theValue
		else if bab is "energyRatingColumn" then
			set myEnergyRating to theValue
		end if
		
		
		
		set releaseName to {releaseArtist, " - ", releaseAlbum} as string
		if albumOrigCatalog is equal to releaseCatalog then
			set skipCat to true
		else
			set skipCat to false
		end if
		if skipCat is false then
			set releaseCatalog to common_findCatalogDupes("both", currentFolderType, releaseCatalog)
			set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
		end if
		
		set detailsPrep to longDetailsPrep()
		--set albumOrigCatalog to common_catalogFlip(albumOrigCatalog, "file")
		
		if skipCat is false then
			updateCatalogNo(albumOrigCatalog)
			updatePlaylistCat(albumOrigCatalog)
			try
				do shell script "mv " & quoted form of (myAppSupportFolder & currentFolderType & "/" & albumOrigCatalog & "/details.txt") & " " & quoted form of (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/details.txt")
				do shell script "mv " & quoted form of (myAppSupportFolder & currentFolderType & "/" & albumOrigCatalog & "/image.jpeg") & " " & quoted form of (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/image.jpeg")
			end try
			try
				do shell script "rm -r " & quoted form of (myAppSupportFolder & currentFolderType & "/" & albumOrigCatalog & "/")
			end try
		end if
		
		do shell script ("echo " & quoted form of detailsPrep & " > " & quoted form of (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/details.txt"))
		
		set myVinylListContents to do shell script ("cat " & quoted form of myVinylList)
		set myVinylWantListContents to do shell script ("cat " & quoted form of myVinylWantList)
		
		copy detailsPrep to myCurrentListItemFileContents
		set releaseCatalog to common_catalogFlip(releaseCatalog, "view")
		try
			refreshTracks(myCurrentListItemFileContents, true)
		end try
		updateReleaseNameBoxes()
		if origReleaseID is "" then set origReleaseID to "none"
		if releaseID is "" then set releaseID to "none"
		
		if bab is "releaseIDColumn" then
			addToRecentActivity("Changed", "")
		end if
		if releaseID is "none" then set releaseID to ""
		set myPlaylist to get_myPlaylist()
		
		set myIMPTable to (table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
		
		if bab is "numColumn" then
			if myPlaylist is "Library" then
				if currentlisttype is "have" then
					copy myVinylListContents to myCurrentTempList_c
					copy myVinylList to myCurrentTempList_f
				else
					copy myVinylWantListContents to myCurrentTempList_c
					copy myVinylWantList to myCurrentTempList_f
				end if
			else
				set myPlaylistFileContents to (do shell script ("cat " & quoted form of myPlaylistFile))
				copy myPlaylistFileContents to myCurrentTempList_c
				copy myPlaylistFile to myCurrentTempList_f
			end if
			
			set myListCount to common_cleanMyList((every paragraph of myCurrentTempList_c), {""})
			set myListCount to (count myListCount)
			
			if (albumNo as integer) is greater than myListCount then
				set albumNo to myListCount as string
			end if
			if (albumNo as integer) is less than 1 then
				set albumNo to "1"
			end if
			
			set myCurrentTempList_c to snr(myCurrentTempList_c, (origAlbumNo & "::	.:.	:"), (albumNo & "myvT::	.:.	:"))
			set myCurrentTempList_c to snr(myCurrentTempList_c, (albumNo & "::	.:.	:"), (origAlbumNo & "::	.:.	:"))
			set myCurrentTempList_c to snr(myCurrentTempList_c, (albumNo & "myvT::	.:.	:"), (albumNo & "::	.:.	:"))
			
			do shell script ("echo " & quoted form of myCurrentTempList_c & " > " & quoted form of myCurrentTempList_f)
			
			if myPlaylist is "Library" then
				if currentlisttype is "have" then
					set myVinylListContents to refreshList_Contents_Catalog("", "", myCurrentTempList_f, false, currentlisttype)
				else
					set myVinylWantListContents to refreshList_Contents_Catalog("", "", myCurrentTempList_f, false, currentlisttype)
				end if
			else
				set myPlaylistFileContents to renew_myListContents("", "", myCurrentTempList_f, false)
			end if
			set myCurrentTempList_c to result
			
			set myCurrentTempList_l to every paragraph of myCurrentTempList_c
			set myCurrentTempList_l to common_cleanMyList(myCurrentTempList_l, {""})
			set myCurrentTempList_count to count myCurrentTempList_l
			
			
			tell data row (origAlbumNo as integer) of data source of myIMPTable
				set myBackupTableList to {(contents of data cell "artistColumn"), (contents of data cell "titleColumn"), (contents of data cell "catalogColumn"), (contents of data cell "labelColumn"), (contents of data cell "countryColumn"), (contents of data cell "releasedateColumn"), (contents of data cell "formatColumn"), (contents of data cell "releaseIDColumn"), (contents of data cell "conditionColumn"), (contents of data cell "BPMColumn"), (contents of data cell "genreColumn"), (contents of data cell "styleColumn"), (contents of data cell "songPreferenceColumn"), (contents of data cell "keySignatureColumn"), (contents of data cell "commentsColumn"), (contents of data cell "energyRatingColumn")}
			end tell
			
			set num_ch1 to common_getZeros(origAlbumNo, myCurrentTempList_count)
			set num_ch2 to common_getZeros(albumNo, myCurrentTempList_count)
			
			tell data source of myIMPTable
				set (contents of data cell "artistColumn" of data row (origAlbumNo as integer)) to (contents of data cell "artistColumn" of data row (albumNo as integer))
				set (contents of data cell "titleColumn" of data row (origAlbumNo as integer)) to (contents of data cell "titleColumn" of data row (albumNo as integer))
				set (contents of data cell "catalogColumn" of data row (origAlbumNo as integer)) to (contents of data cell "catalogColumn" of data row (albumNo as integer))
				set (contents of data cell "labelColumn" of data row (origAlbumNo as integer)) to (contents of data cell "labelColumn" of data row (albumNo as integer))
				set (contents of data cell "countryColumn" of data row (origAlbumNo as integer)) to (contents of data cell "countryColumn" of data row (albumNo as integer))
				set (contents of data cell "releasedateColumn" of data row (origAlbumNo as integer)) to (contents of data cell "releasedateColumn" of data row (albumNo as integer))
				set (contents of data cell "formatColumn" of data row (origAlbumNo as integer)) to (contents of data cell "formatColumn" of data row (albumNo as integer))
				set (contents of data cell "releaseIDColumn" of data row (origAlbumNo as integer)) to (contents of data cell "releaseIDColumn" of data row (albumNo as integer))
				set (contents of data cell "conditionColumn" of data row (origAlbumNo as integer)) to (contents of data cell "conditionColumn" of data row (albumNo as integer))
				set (contents of data cell "numColumn" of data row (origAlbumNo as integer)) to num_ch1
				
				set (contents of data cell "BPMColumn" of data row (origAlbumNo as integer)) to (contents of data cell "BPMColumn" of data row (albumNo as integer))
				set (contents of data cell "genreColumn" of data row (origAlbumNo as integer)) to (contents of data cell "genreColumn" of data row (albumNo as integer))
				set (contents of data cell "styleColumn" of data row (origAlbumNo as integer)) to (contents of data cell "styleColumn" of data row (albumNo as integer))
				set (contents of data cell "songPreferenceColumn" of data row (origAlbumNo as integer)) to (contents of data cell "songPreferenceColumn" of data row (albumNo as integer))
				set (contents of data cell "keySignatureColumn" of data row (origAlbumNo as integer)) to (contents of data cell "keySignatureColumn" of data row (albumNo as integer))
				set (contents of data cell "commentsColumn" of data row (origAlbumNo as integer)) to (contents of data cell "commentsColumn" of data row (albumNo as integer))
				set (contents of data cell "energyRatingColumn" of data row (origAlbumNo as integer)) to (contents of data cell "energyRatingColumn" of data row (albumNo as integer))
			end tell
			tell data row (albumNo as integer) of data source of myIMPTable
				set (contents of data cell "artistColumn") to (item 1 of myBackupTableList) as string
				set (contents of data cell "titleColumn") to (item 2 of myBackupTableList) as string
				set (contents of data cell "catalogColumn") to (item 3 of myBackupTableList) as string
				set (contents of data cell "labelColumn") to (item 4 of myBackupTableList) as string
				set (contents of data cell "countryColumn") to (item 5 of myBackupTableList) as string
				set (contents of data cell "releasedateColumn") to (item 6 of myBackupTableList) as string
				set (contents of data cell "formatColumn") to (item 7 of myBackupTableList) as string
				set (contents of data cell "releaseIDColumn") to (item 8 of myBackupTableList) as string
				set (contents of data cell "conditionColumn") to (item 9 of myBackupTableList) as string
				set (contents of data cell "numColumn") to num_ch2
				
				set (contents of data cell "BPMColumn") to (item 10 of myBackupTableList) as string
				set (contents of data cell "genreColumn") to (item 11 of myBackupTableList) as string
				set (contents of data cell "styleColumn") to (item 12 of myBackupTableList) as string
				set (contents of data cell "songPreferenceColumn") to (item 13 of myBackupTableList) as string
				set (contents of data cell "keySignatureColumn") to (item 14 of myBackupTableList) as string
				set (contents of data cell "commentsColumn") to (item 15 of myBackupTableList) as string
				set (contents of data cell "energyRatingColumn") to (item 16 of myBackupTableList) as string
			end tell
		else
			if myPlaylist is not "Library" then
				if currentlisttype is "have" then
					set temp_dataSrc to theHaveListDataSource
					set temp_vinyList to myVinylListCatalog
				else
					set temp_dataSrc to theWantListDataSource
					set temp_vinyList to myVinylWantListCatalog
				end if
				
				set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
				--set albumOrigCatalog to common_catalogFlip(albumOrigCatalog, "view")
				
				repeat with cv_chLoop from 1 to (count temp_vinyList)
					if ((item cv_chLoop of temp_vinyList) as string) is releaseCatalog then
						set myD_row to cv_chLoop
						exit repeat
					end if
				end repeat
				
				set releaseCatalog to common_catalogFlip(releaseCatalog, "view")
				tell data row myD_row of temp_dataSrc
					set contents of data cell "artistColumn" to releaseArtist
					set contents of data cell "titleColumn" to releaseAlbum
					set contents of data cell "catalogColumn" to releaseCatalog
					set contents of data cell "labelColumn" to releaseLABEL
					set contents of data cell "countryColumn" to releaseCountry
					set contents of data cell "releasedateColumn" to releaseDate
					set contents of data cell "formatColumn" to releaseFormat
					set contents of data cell "releaseIDColumn" to releaseID
					set contents of data cell "conditionColumn" to releaseCondition
					
					set contents of data cell "BPMColumn" to myBPM
					set contents of data cell "genreColumn" to myGenre
					set contents of data cell "styleColumn" to myStyle
					set contents of data cell "songPreferenceColumn" to mySongPreference
					set contents of data cell "keySignatureColumn" to myKeySignature
					set contents of data cell "commentsColumn" to myComments
					set contents of data cell "energyRatingColumn" to myEnergyRating
				end tell
				
				playlist_Show(myPlaylist)
			end if
		end if
		--set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
	end if
end cell value changed

on column clicked theObject table column tableColumn
	try
		-- Get the data source of the table view
		set theDataSource to data source of theObject
		
		-- Get the identifier of the clicked table column
		set theColumnIdentifier to identifier of tableColumn
		
		if theDataSource is theHaveListDataSource then
			set currentHaveColumn to theColumnIdentifier
		else if theDataSource is theWantListDataSource then
			set currentWantColumn to theColumnIdentifier
		end if
		
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
	end try
	if theDataSource is theHaveListDataSource then
		set myAZorderH to (sort order of theSortColumn)
		if myAZorderH is ascending then
			set myAZorderH to "d"
		else
			set myAZorderH to "a"
		end if
		set theHaveListDataSource to data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 1 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
	else if theDataSource is theWantListDataSource then
		set myAZorderW to (sort order of theSortColumn)
		if myAZorderW is ascending then
			set myAZorderW to "d"
		else
			set myAZorderW to "a"
		end if
		set theWantListDataSource to data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 2 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
	end if
	set theSearchXMLDataSource to data source of table view 1 of scroll view 1 of view 1 of split view 1 of window "searchXMLWindow"
	if theObject is not "trackListTableView" then
		savePrefs()
	end if
end column clicked

on mouse entered theObject event theEvent
	if the name of theObject is "updateEntry" then
		set contents of text field "buttonHoverText" of window "mainList" to (localized string ("hover_UpdateItem"))
	else if theObject is (split view 1 of window "mainList") then
		set contents of text field "buttonHoverText" of window "mainList" to ""
	else if the name of theObject is "bigMainListArtBox" then
		set contents of text field "buttonHoverText" of window "mainList" to ""
	else if the name of theObject is "buttonHoverText" then
		set contents of text field "buttonHoverText" of window "mainList" to ""
	else if the name of theObject is "deleteAlbumEntry" then
		set contents of text field "buttonHoverText" of window "mainList" to (localized string ("hover_DeleteItem"))
	else if the name of theObject is "addAlbumButton" then
		set contents of text field "buttonHoverText" of window "mainList" to (localized string ("hover_AddItem"))
	else if the name of theObject is "showArtWindowButton" then
		set contents of text field "buttonHoverText" of window "mainList" to (localized string ("hover_ToggleArt"))
	else if the name of theObject is "showTrackList" then
		set contents of text field "buttonHoverText" of window "mainList" to (localized string ("hover_ToggleTracks"))
	end if
end mouse entered


on should close theObject
	if the name of theObject is "updateAlbumWindow" then
		try
			do shell script ("rm " & quoted form of updt_tempFile)
		end try
		set trackLISTstring to refreshTracks(myCurrentListItemFileContents, false)
	end if
	hide theObject
	return false
end should close

on launched theObject
	set haltLaunch to initializeMe()
	tell (tab view 1 of view 2 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList")
		set the contents of text view 1 of scroll view 1 of tab view item 2 to ""
	end tell
	
	updateLaunchLoading(0)
	
	set visible of control "greenBar" of window "launchLoading" to true
	set visible of progress indicator 1 of window "launchLoading" to true
	
	
	-----------HAVELIST
	set foundIT to false
	try
		set myVinylListContents to (do shell script "cat " & quoted form of myVinylList) as string
		set foundIT to true
	end try
	if foundIT is true then
		if myVinylListContents does not contain "::	.:.	:" then
			show window "upgradeDBWindow"
			set haltLaunch to true
			set foundIT to false
		else
			set firstRun to false
			set myVinylListContents to renew_myListContents("", "", myVinylList, false)
			
			set myVinylListCatalog to (every paragraph of myVinylListContents)
			
			repeat with a from 1 to (count myVinylListCatalog)
				set item a of myVinylListCatalog to item 2 of split((item a of myVinylListCatalog), "::	.:.	:")
			end repeat
			--CLEAR LISTS
			set myVinylListArtist to {}
			set myVinylListAlbum to {}
			set myVinylListLabel to {}
			set myVinylListCountry to {}
			set myVinylListDate to {}
			set myVinylListFormat to {}
			set myVinylListReleaseID to {}
			set myVinylListCondition to {}
			
			--((1))
			set myVinylListBPM to {}
			set myVinylListGenre to {}
			set myVinylListStyle to {}
			set myVinylListSongPreference to {}
			set myVinylListKeySignature to {}
			set myVinylListComments to {}
			set myVinylListEnergyRating to {}
			
			
			---
		end if
	else
		set myVinylListCatalog to {}
		common_totalCountText("have", true, myVinylListCatalog)
		try
			do shell script "mkdir " & quoted form of (myAppSupportFolder)
		end try
		try
			do shell script "mkdir " & quoted form of (myAppSupportFolder & currentFolderType & "/")
		end try
		set myVinylListContents to ""
	end if
	
	
	try
		if haltLaunch is false then
			-------CREATE DATA SOURCE
			set theHaveListDataSource to make new data source at end of data sources
			tell theHaveListDataSource
				make new data column at end of data columns with properties {name:"numColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"artistColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"titleColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"labelColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"catalogColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"countryColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"releasedateColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"formatColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"releaseIDColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"conditionColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				
				--((2))
				make new data column at end of data columns with properties {name:"BPMColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"genreColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"styleColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"songPreferenceColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"keySignatureColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"commentsColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"energyRatingColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				
			end tell
			if foundIT is true then
				repeat with a from 1 to (count myVinylListCatalog)
					tell theHaveListDataSource
						make new data row at end of data rows
					end tell
				end repeat
			end if
		end if
	end try
	
	if foundIT is true then
		try
			set visible of window "launchLoading" to true
		end try
		repeat with a from 1 to (count myVinylListCatalog)
			--try
			set myCurrentListItemFile to (myAppSupportFolder & "Collection/" & (item a of myVinylListCatalog) & "/details.txt") as string
			set continueWithItem to true
			try
				set myCurrentListItemFileContents to do shell script "cat " & quoted form of myCurrentListItemFile
			on error number 1
				display alert "Couldn't find (# " & a & ") in \"Collection\" folder."
				--set myvinylTempRead to (do shell script "cat " & myVinylList)
				--set myvinylTempRead to split(myvinylTempRead, (a & ("::	.:.	:") & ((item a of myVinylListCatalog) as string))) as string
				--do shell script "echo " & quoted form of myvinylTempRead & " > " & myVinylList
				set continueWithItem to false
			end try
			if continueWithItem is false then
				
				set releaseArtist to "Unknown"
				set myVinylListArtist to myVinylListArtist & {releaseArtist}
				set releaseAlbum to "Unknown"
				set myVinylListAlbum to myVinylListAlbum & {releaseAlbum}
				set releaseLABEL to ""
				set myVinylListLabel to myVinylListLabel & {releaseLABEL}
				set releaseCountry to ""
				set myVinylListCountry to myVinylListCountry & {releaseCountry}
				set releaseDate to ""
				set myVinylListDate to myVinylListDate & {releaseDate}
				set releaseFormat to ""
				set myVinylListFormat to myVinylListFormat & {releaseFormat}
				set releaseCondition to ""
				set myVinylListCondition to myVinylListCondition & {releaseCondition}
				set releaseID to ""
				set myVinylListReleaseID to myVinylListReleaseID & {releaseID}
				
				--((3))
				set myBPM to ""
				set myVinylListBPM to myVinylListBPM & {myBPM}
				set myGenre to ""
				set myVinylListGenre to myVinylListGenre & {myGenre}
				set myStyle to ""
				set myVinylListStyle to myVinylListStyle & {myStyle}
				set mySongPreference to ""
				set myVinylListSongPreference to myVinylListSongPreference & {mySongPreference}
				set myKeySignature to ""
				set myVinylListKeySignature to myVinylListKeySignature & {myKeySignature}
				set myComments to ""
				set myVinylListComments to myVinylListComments & {myComments}
				set myEnergyRating to ""
				set myVinylListEnergyRating to myVinylListEnergyRating & {myEnergyRating}
				
				set (item a of myVinylListCatalog) to "Unknown"
			else
				if myCurrentListItemFileContents contains "<track!Item.>" then
					show window "upgradeDBWindow"
					set haltLaunch to true
					set foundIT to false
					hide window "launchLoading"
					exit repeat
				else
					set releaseArtist to (item 1 of split(item 2 of split(myCurrentListItemFileContents, ("<--NAME-->")), " - "))
					set myVinylListArtist to myVinylListArtist & {releaseArtist}
					set releaseAlbum to (item 2 of split(item 2 of split(myCurrentListItemFileContents, ("<--NAME-->")), " - "))
					set myVinylListAlbum to myVinylListAlbum & {releaseAlbum}
					set releaseLABEL to item 2 of split(myCurrentListItemFileContents, ("<--LABEL-->"))
					set myVinylListLabel to myVinylListLabel & {releaseLABEL}
					set releaseCountry to item 2 of split(myCurrentListItemFileContents, ("<--COUNTRY-->"))
					set myVinylListCountry to myVinylListCountry & {releaseCountry}
					set releaseDate to item 2 of split(myCurrentListItemFileContents, ("<--RELEASED-->"))
					set myVinylListDate to myVinylListDate & {releaseDate}
					set releaseFormat to item 2 of split(myCurrentListItemFileContents, ("<--FORMAT-->"))
					set myVinylListFormat to myVinylListFormat & {releaseFormat}
					
					try
						set releaseCondition to item 2 of split(myCurrentListItemFileContents, ("<--CONDITION-->"))
					on error
						set releaseCondition to ""
					end try
					set myVinylListCondition to myVinylListCondition & {releaseCondition}
					--
					try
						set releaseID to item 2 of split(myCurrentListItemFileContents, ("<--RELEASEID-->"))
					on error
						set releaseID to ""
					end try
					set myVinylListReleaseID to myVinylListReleaseID & {releaseID}
					--
					--((4))
					--
					--
					try
						set myBPM to item 2 of split(myCurrentListItemFileContents, ("<--BPM_COUNT-->"))
					on error
						set myBPM to ""
					end try
					set myVinylListBPM to myVinylListBPM & {myBPM}
					--
					--
					try
						set myGenre to item 2 of split(myCurrentListItemFileContents, ("<--ALB_GENRE-->"))
					on error
						set myGenre to ""
					end try
					set myVinylListGenre to myVinylListGenre & {myGenre}
					--
					--
					try
						set myStyle to item 2 of split(myCurrentListItemFileContents, ("<--ALB_STYLE-->"))
					on error
						set myStyle to ""
					end try
					set myVinylListStyle to myVinylListStyle & {myStyle}
					--
					--
					try
						set mySongPreference to item 2 of split(myCurrentListItemFileContents, ("<--SNG_PREFERENCE-->"))
					on error
						set mySongPreference to ""
					end try
					set myVinylListSongPreference to myVinylListSongPreference & {mySongPreference}
					--
					--
					try
						set myKeySignature to item 2 of split(myCurrentListItemFileContents, ("<--ALB_KEY_SIGNATURE-->"))
					on error
						set myKeySignature to ""
					end try
					set myVinylListKeySignature to myVinylListKeySignature & {myKeySignature}
					--
					--
					try
						set myComments to item 2 of split(myCurrentListItemFileContents, ("<--ALB_COMMENTS-->"))
					on error
						set myComments to ""
					end try
					set myVinylListComments to myVinylListComments & {myComments}
					--
					--
					try
						set myEnergyRating to item 2 of split(myCurrentListItemFileContents, ("<--ALB_ENRGYRATING-->"))
					on error
						set myEnergyRating to ""
					end try
					set myVinylListEnergyRating to myVinylListEnergyRating & {myEnergyRating}
					--
					
					--CountString DIVIDER
					set myTotalCountString to split((localized string "misc_partOfWhole"), "1") as string
					set myTotalCountStringDivider to split(myTotalCountString, "2") as string
					--
					
					set contents of text field "launchLoadingText1" of window "launchLoading" to (localized string "misc_RememberHave") & " (" & a & myTotalCountStringDivider & (count myVinylListCatalog) & ")"
					set contents of text field "launchLoadingText2" of window "launchLoading" to ((item a of myVinylListArtist) & " - " & (item a of myVinylListAlbum))
					common_update_progress(a, (count myVinylListCatalog), "launchLoading")
					
					---------FILL DATA SOURCE
					common_placeZeros(theHaveListDataSource, a, (count myVinylListCatalog))
					set (item a of myVinylListCatalog) to snr((item a of myVinylListCatalog as string), "....", "/")
					set (item a of myVinylListCatalog) to snr((item a of myVinylListCatalog as string), "..+", "....")
					tell theHaveListDataSource
						set contents of data cell "artistColumn" of data row a to (item a of myVinylListArtist)
						set contents of data cell "titleColumn" of data row a to (item a of myVinylListAlbum)
						set contents of data cell "catalogColumn" of data row a to (item a of myVinylListCatalog)
						set contents of data cell "labelColumn" of data row a to (item a of myVinylListLabel)
						set contents of data cell "countryColumn" of data row a to (item a of myVinylListCountry)
						set contents of data cell "releasedateColumn" of data row a to (item a of myVinylListDate)
						set contents of data cell "formatColumn" of data row a to (item a of myVinylListFormat)
						set contents of data cell "releaseIDColumn" of data row a to (item a of myVinylListReleaseID)
						set contents of data cell "conditionColumn" of data row a to (item a of myVinylListCondition)
						
						--((5))
						set contents of data cell "BPMColumn" of data row a to (item a of myVinylListBPM)
						set contents of data cell "genreColumn" of data row a to (item a of myVinylListGenre)
						set contents of data cell "styleColumn" of data row a to (item a of myVinylListStyle)
						set contents of data cell "songPreferenceColumn" of data row a to (item a of myVinylListSongPreference)
						set contents of data cell "keySignatureColumn" of data row a to (item a of myVinylListKeySignature)
						set contents of data cell "commentsColumn" of data row a to (item a of myVinylListComments)
						set contents of data cell "energyRatingColumn" of data row a to (item a of myVinylListEnergyRating)
						
					end tell
					--on error
					--	exit repeat
					--end try
				end if
			end if
		end repeat
		common_totalCountText("have", false, myVinylListCatalog)
	end if
	
	updateLaunchLoading(1)
	
	
	-----------
	-----------
	-----------WANTLIST
	set foundIT to false
	try
		set myVinylWantListContents to (do shell script "cat " & quoted form of myVinylWantList) as string
		set foundIT to true
	end try
	if foundIT is true then
		if myVinylWantListContents does not contain "::	.:.	:" then
			show window "upgradeDBWindow"
			set haltLaunch to true
			set foundIT to false
		else
			set firstRun to false
			set visible of control "greenBar" of window "launchLoading" to true
			set visible of progress indicator 1 of window "launchLoading" to true
			
			set myVinylWantListContents to renew_myListContents("", "", myVinylWantList, false)
			set myVinylWantListCatalog to (every paragraph of myVinylWantListContents)
			
			repeat with a from 1 to (count myVinylWantListCatalog)
				set item a of myVinylWantListCatalog to item 2 of split((item a of myVinylWantListCatalog), "::	.:.	:")
			end repeat
			--CLEAR LISTS
			set myVinylWantListArtist to {}
			set myVinylWantListAlbum to {}
			set myVinylWantListLabel to {}
			set myVinylWantListCountry to {}
			set myVinylWantListDate to {}
			set myVinylWantListFormat to {}
			set myVinylWantListReleaseID to {}
			set myVinylWantListCondition to {}
			---
			
			--((1))
			set myVinylWantListBPM to {}
			set myVinylWantListGenre to {}
			set myVinylWantListStyle to {}
			set myVinylWantListSongPreference to {}
			set myVinylWantListKeySignature to {}
			set myVinylWantListComments to {}
			set myVinylWantListEnergyRating to {}
			
		end if
	else
		set myVinylWantListCatalog to {}
		common_totalCountText("want", true, myVinylWantListCatalog)
		try
			do shell script "mkdir " & quoted form of (myAppSupportFolder)
		end try
		try
			do shell script "mkdir " & quoted form of (myAppSupportFolder & "Wanted/")
		end try
		set myVinylWantListContents to ""
	end if
	
	try
		if haltLaunch is false then
			-------CREATE DATA SOURCE
			set theWantListDataSource to make new data source at end of data sources
			tell theWantListDataSource
				make new data column at end of data columns with properties {name:"numColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"artistColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"titleColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"labelColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"catalogColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"countryColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"releasedateColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"formatColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"releaseIDColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"conditionColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				
				--((2))
				make new data column at end of data columns with properties {name:"BPMColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"genreColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"styleColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"songPreferenceColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"keySignatureColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"commentsColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"energyRatingColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
			end tell
			if foundIT is true then
				repeat with a from 1 to (count myVinylWantListCatalog)
					tell theWantListDataSource
						make new data row at end of data rows
					end tell
				end repeat
			end if
		end if
	end try
	if foundIT is true then
		try
			set visible of window "launchLoading" to true
		end try
		repeat with a from 1 to (count myVinylWantListCatalog)
			--try
			
			set myCurrentListItemFile to (myAppSupportFolder & "Wanted/" & (item a of myVinylWantListCatalog) & "/details.txt") as string
			set continueWithItem to true
			try
				set myCurrentListItemFileContents to do shell script "cat " & quoted form of myCurrentListItemFile
			on error number 1
				display alert "Couldn't find (# " & a & ") in \"Wanted\" folder."
				--set myvinylTempRead to (do shell script "cat " & myVinylWantList)
				--set myvinylTempRead to split(myvinylTempRead, (a & ("::	.:.	:") & ((item a of myVinylWantListCatalog) as string))) as string
				--do shell script "echo " & quoted form of myvinylTempRead & " > " & myVinylWantList
				set continueWithItem to false
			end try
			if continueWithItem is false then
				set releaseArtist to "Unknown"
				set myVinylWantListArtist to myVinylWantListArtist & {releaseArtist}
				set releaseAlbum to "Unknown"
				set myVinylWantListAlbum to myVinylWantListAlbum & {releaseAlbum}
				set releaseLABEL to ""
				set myVinylWantListLabel to myVinylWantListLabel & {releaseLABEL}
				set releaseCountry to ""
				set myVinylWantListCountry to myVinylWantListCountry & {releaseCountry}
				set releaseDate to ""
				set myVinylWantListDate to myVinylWantListDate & {releaseDate}
				set releaseFormat to ""
				set myVinylWantListFormat to myVinylWantListFormat & {releaseFormat}
				set releaseCondition to ""
				set myVinylWantListCondition to myVinylWantListCondition & {releaseCondition}
				set releaseID to ""
				set myVinylWantListReleaseID to myVinylWantListReleaseID & {releaseID}
				
				--((3))
				set myBPM to ""
				set myVinylWantListBPM to myVinylWantListBPM & {myBPM}
				set myGenre to ""
				set myVinylWantListGenre to myVinylWantListGenre & {myGenre}
				set myStyle to ""
				set myVinylWantListStyle to myVinylWantListStyle & {myStyle}
				set mySongPreference to ""
				set myVinylWantListSongPreference to myVinylWantListSongPreference & {mySongPreference}
				set myKeySignature to ""
				set myVinylWantListKeySignature to myVinylWantListKeySignature & {myKeySignature}
				set myComments to ""
				set myVinylWantListComments to myVinylWantListComments & {myComments}
				set myEnergyRating to ""
				set myVinylWantListEnergyRating to myVinylWantListEnergyRating & {myEnergyRating}
				set (item a of myVinylWantListCatalog) to "Unknown"
			else
				if myCurrentListItemFileContents contains "<track!Item.>" then
					show window "upgradeDBWindow"
					set haltLaunch to true
					set foundIT to false
					hide window "launchLoading"
					exit repeat
				else
					set releaseArtist to (item 1 of split(item 2 of split(myCurrentListItemFileContents, ("<--NAME-->")), " - "))
					set myVinylWantListArtist to myVinylWantListArtist & {releaseArtist}
					set releaseAlbum to (item 2 of split(item 2 of split(myCurrentListItemFileContents, ("<--NAME-->")), " - "))
					set myVinylWantListAlbum to myVinylWantListAlbum & {releaseAlbum}
					set releaseLABEL to item 2 of split(myCurrentListItemFileContents, ("<--LABEL-->"))
					set myVinylWantListLabel to myVinylWantListLabel & {releaseLABEL}
					set releaseCountry to item 2 of split(myCurrentListItemFileContents, ("<--COUNTRY-->"))
					set myVinylWantListCountry to myVinylWantListCountry & {releaseCountry}
					set releaseDate to item 2 of split(myCurrentListItemFileContents, ("<--RELEASED-->"))
					set myVinylWantListDate to myVinylWantListDate & {releaseDate}
					set releaseFormat to item 2 of split(myCurrentListItemFileContents, ("<--FORMAT-->"))
					set myVinylWantListFormat to myVinylWantListFormat & {releaseFormat}
					
					try
						set releaseCondition to item 2 of split(myCurrentListItemFileContents, ("<--CONDITION-->"))
					on error
						set releaseCondition to ""
					end try
					set myVinylWantListCondition to myVinylWantListCondition & {releaseCondition}
					try
						set releaseID to item 2 of split(myCurrentListItemFileContents, ("<--RELEASEID-->"))
					on error
						set releaseID to ""
					end try
					set myVinylWantListReleaseID to myVinylWantListReleaseID & {releaseID}
					
					
					
					--((4))
					--
					--
					try
						set myBPM to item 2 of split(myCurrentListItemFileContents, ("<--BPM_COUNT-->"))
					on error
						set myBPM to ""
					end try
					set myVinylWantListBPM to myVinylWantListBPM & {myBPM}
					--
					--
					try
						set myGenre to item 2 of split(myCurrentListItemFileContents, ("<--ALB_GENRE-->"))
					on error
						set myGenre to ""
					end try
					set myVinylWantListGenre to myVinylWantListGenre & {myGenre}
					--
					--
					try
						set myStyle to item 2 of split(myCurrentListItemFileContents, ("<--ALB_STYLE-->"))
					on error
						set myStyle to ""
					end try
					set myVinylWantListStyle to myVinylWantListStyle & {myStyle}
					--
					--
					try
						set mySongPreference to item 2 of split(myCurrentListItemFileContents, ("<--SNG_PREFERENCE-->"))
					on error
						set mySongPreference to ""
					end try
					set myVinylWantListSongPreference to myVinylWantListSongPreference & {mySongPreference}
					--
					--
					try
						set myKeySignature to item 2 of split(myCurrentListItemFileContents, ("<--ALB_KEY_SIGNATURE-->"))
					on error
						set myKeySignature to ""
					end try
					set myVinylWantListKeySignature to myVinylWantListKeySignature & {myKeySignature}
					--
					--
					try
						set myComments to item 2 of split(myCurrentListItemFileContents, ("<--ALB_COMMENTS-->"))
					on error
						set myComments to ""
					end try
					set myVinylWantListComments to myVinylWantListComments & {myComments}
					--
					--
					try
						set myEnergyRating to item 2 of split(myCurrentListItemFileContents, ("<--ALB_ENRGYRATING-->"))
					on error
						set myEnergyRating to ""
					end try
					set myVinylWantListEnergyRating to myVinylWantListEnergyRating & {myEnergyRating}
					
					
					--CountString DIVIDER
					set myTotalCountString to split((localized string "misc_partOfWhole"), "1") as string
					set myTotalCountStringDivider to split(myTotalCountString, "2") as string
					--
					
					set contents of text field "launchLoadingText1" of window "launchLoading" to (localized string "misc_RememberWant") & " (" & a & myTotalCountStringDivider & (count myVinylWantListCatalog) & ")"
					set contents of text field "launchLoadingText2" of window "launchLoading" to ((item a of myVinylWantListArtist) & " - " & (item a of myVinylWantListAlbum))
					common_update_progress(a, (count myVinylWantListCatalog), "launchLoading")
					
					---------FILL DATA SOURCE
					common_placeZeros(theWantListDataSource, a, (count myVinylWantListCatalog))
					set (item a of myVinylWantListCatalog) to snr((item a of myVinylWantListCatalog as string), "....", "/")
					set (item a of myVinylWantListCatalog) to snr((item a of myVinylWantListCatalog as string), "..+", "....")
					tell theWantListDataSource
						set contents of data cell "artistColumn" of data row a to (item a of myVinylWantListArtist)
						set contents of data cell "titleColumn" of data row a to (item a of myVinylWantListAlbum)
						set contents of data cell "catalogColumn" of data row a to (item a of myVinylWantListCatalog)
						set contents of data cell "labelColumn" of data row a to (item a of myVinylWantListLabel)
						set contents of data cell "countryColumn" of data row a to (item a of myVinylWantListCountry)
						set contents of data cell "releasedateColumn" of data row a to (item a of myVinylWantListDate)
						set contents of data cell "formatColumn" of data row a to (item a of myVinylWantListFormat)
						set contents of data cell "releaseIDColumn" of data row a to (item a of myVinylWantListReleaseID)
						set contents of data cell "conditionColumn" of data row a to (item a of myVinylWantListCondition)
						
						--((5))
						set contents of data cell "BPMColumn" of data row a to (item a of myVinylWantListBPM)
						set contents of data cell "genreColumn" of data row a to (item a of myVinylWantListGenre)
						set contents of data cell "styleColumn" of data row a to (item a of myVinylWantListStyle)
						set contents of data cell "songPreferenceColumn" of data row a to (item a of myVinylWantListSongPreference)
						set contents of data cell "keySignatureColumn" of data row a to (item a of myVinylWantListKeySignature)
						set contents of data cell "commentsColumn" of data row a to (item a of myVinylWantListComments)
						set contents of data cell "energyRatingColumn" of data row a to (item a of myVinylWantListEnergyRating)
					end tell
					--on error
					--	exit repeat
					--end try
				end if
			end if
		end repeat
		common_totalCountText("want", false, myVinylWantListCatalog)
	end if
	
	
	--CLEAR LISTS
	set myVinylListArtist to {}
	set myVinylListAlbum to {}
	set myVinylListLabel to {}
	set myVinylListCountry to {}
	set myVinylListDate to {}
	set myVinylListFormat to {}
	set myVinylListReleaseID to {}
	set myVinylListCondition to {}
	---
	set myVinylListBPM to {}
	set myVinylListGenre to {}
	set myVinylListStyle to {}
	set myVinylListSongPreference to {}
	set myVinylListKeySignature to {}
	set myVinylListComments to {}
	set myVinylListEnergyRating to {}
	
	
	
	
	--CLEAR LISTS
	set myVinylWantListArtist to {}
	set myVinylWantListAlbum to {}
	set myVinylWantListLabel to {}
	set myVinylWantListCountry to {}
	set myVinylWantListDate to {}
	set myVinylWantListFormat to {}
	set myVinylWantListReleaseID to {}
	set myVinylWantListCondition to {}
	---
	set myVinylWantListBPM to {}
	set myVinylWantListGenre to {}
	set myVinylWantListStyle to {}
	set myVinylWantListSongPreference to {}
	set myVinylWantListKeySignature to {}
	set myVinylWantListComments to {}
	set myVinylWantListEnergyRating to {}
	
	
	
	updateLaunchLoading(2)
	
	---
	if haltLaunch is false then
		
		playlist_Load("launch")
		
		lastToInitialize()
	end if
	
end launched

on open theObject
	set nlMasta to {}
	repeat with a from 1 to count theObject
		set nlMasta to nlMasta & {(POSIX path of item a of theObject)}
	end repeat
	if (count nlMasta) is greater than 1 then
		common_displayDialog((localized string "dialog_OnlyOneImport"), (localized string "button_Oh"), false, "")
	else
		display panel window "importOnOpenWindow" attached to window "mainList"
	end if
end open

on should quit theObject
	return true
end should quit

on mouse exited theObject event theEvent
	(*Add your script here.*)
end mouse exited

on will quit theObject
	if name of window 1 is not "launchLoading" then
		if visible of window "upgradeDBWindow" is false then
			if visible of window "launchLoading" is false then
				try
					savePrefs()
				end try
			end if
		end if
	end if
	return true
end will quit

---------------------------
---------------------------
----START CUSTOM FUNCTIONS
---------------------------
---------------------------

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

on savePrefs()
	
	--try
	copy (every character of visibleColumnsHave) to old_visibleColumnsHave
	copy (every character of visibleColumnsWant) to old_visibleColumnsWant
	--end try
	
	tell tab view 1 of window "prefsWindow"
		tell tab view item 1
			set visibleColumnsHave to {state of button "visibleColumnNumberH" as string, state of button "visibleColumnArtistH" as string, state of button "visibleColumnTitleH" as string, state of button "visibleColumnLabelH" as string, state of button "visibleColumnCatalogH" as string, state of button "visibleColumnCountryH" as string, state of button "visibleColumnDateH" as string, state of button "visibleColumnFormatH" as string, state of button "visibleColumnReleaseIDH" as string, state of button "visibleColumnConditionH" as string, state of button "visibleColumnBPMH" as string, state of button "visibleColumnGenreH" as string, state of button "visibleColumnStyleH" as string, state of button "visibleColumnSongPreferenceH" as string, state of button "visibleColumnKeySignatureH" as string, state of button "visibleColumnCommentsH" as string, state of button "visibleColumnEnergyRatingH" as string}
		end tell
		tell tab view item 2
			set visibleColumnsWant to {state of button "visibleColumnNumberW" as string, state of button "visibleColumnArtistW" as string, state of button "visibleColumnTitleW" as string, state of button "visibleColumnLabelW" as string, state of button "visibleColumnCatalogW" as string, state of button "visibleColumnCountryW" as string, state of button "visibleColumnDateW" as string, state of button "visibleColumnFormatW" as string, state of button "visibleColumnReleaseIDW" as string, state of button "visibleColumnConditionW" as string, state of button "visibleColumnBPMW" as string, state of button "visibleColumnGenreW" as string, state of button "visibleColumnStyleW" as string, state of button "visibleColumnSongPreferenceW" as string, state of button "visibleColumnKeySignatureW" as string, state of button "visibleColumnCommentsW" as string, state of button "visibleColumnEnergyRatingW" as string}
		end tell
	end tell
	
	set otherScript to useOtherScript("hideColumns")
	
	if old_visibleColumnsHave is not equal to visibleColumnsHave then
		tell otherScript to hideColumnsMain("have", visibleColumnsHave, visibleColumnsWant)
	end if
	
	if old_visibleColumnsWant is not equal to visibleColumnsWant then
		tell otherScript to hideColumnsMain("want", visibleColumnsHave, visibleColumnsWant)
	end if
	
	set visibleColumnsHave to visibleColumnsHave as string
	set visibleColumnsWant to visibleColumnsWant as string
	
	set writeThisStuff to "<haveColumn>" & currentHaveColumn & "<haveColumn> <wantColumn>" & currentWantColumn & "<wantColumn>"
	set writeThisStuff to writeThisStuff & "<pathToMyCollection>" & myAppSupportFolder & "<pathToMyCollection> <myAZW>" & myAZorderW & "<myAZW>"
	set writeThisStuff to writeThisStuff & "<myAZH>" & myAZorderH & "<myAZH>"
	set writeThisStuff to writeThisStuff & "<visibleHaveColumns>" & visibleColumnsHave & "<visibleHaveColumns> <visibleWantColumns>" & visibleColumnsWant & "<visibleWantColumns>"
	
	do shell script "echo " & quoted form of writeThisStuff & " > " & prefsFile
	
end savePrefs


on common_update_progress(iteration, total_count, windowVar)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to update_progress(iteration, total_count, windowVar)
end common_update_progress

on common_displayDialog(thediatext, butttext, cancelenabled, headerText)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to displayDialog(thediatext, butttext, cancelenabled, headerText)
end common_displayDialog

on importDiscogsXML(givenListType, b)
	set current tab view item of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to tab view item (givenListType & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
	
	if givenListType is "want" then
		copy theWantListDataSource to theCurrentDataSource
		set myCountCat to (count myVinylWantListCatalog)
	else
		copy theHaveListDataSource to theCurrentDataSource
		set myCountCat to (count myVinylListCatalog)
	end if
	
	set myImportCount to importMidProcess(b)
	
	if cancelImportVar is false then
		set releaseLimiter to myImportCount
		set contents of text field "importFromValue" of window "importingChooseAmount" to myCountCat
		set contents of text field "importToValue" of window "importingChooseAmount" to releaseLimiter
		display panel window "importingChooseAmount" attached to window "mainList"
	else
		set cancelImportVar to false
	end if
end importDiscogsXML

on deleteAlbumHaveList()
	
	set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
	do shell script "rm -r " & quoted form of (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/")
	
	set myVinylListContents to do shell script ("cat " & quoted form of myVinylList)
	refreshList_Contents_Catalog(myVinylListContents, releaseCatalog, myVinylList, true, currentlisttype)
	
	delete_dataRow(myVinylListCatalog, releaseCatalog)
	
	do shell script ("echo " & quoted form of myVinylListContents & " > " & quoted form of myVinylList)
	refreshList_Contents_Catalog("", "", myVinylList, false, currentlisttype)
	
	set releaseCatalog to common_catalogFlip(releaseCatalog, "view")
	
	if myVinylListCatalog is {} then
		common_totalCountText("have", true, myVinylListCatalog)
	else
		common_totalCountText("have", false, myVinylListCatalog)
	end if
	
	deleteVisibleTraces()
	addToRecentActivity("Removed", "from")
	
	repeat with a from 1 to (count myVinylListCatalog)
		try
			common_placeZeros(theHaveListDataSource, a, (count myVinylListCatalog))
		on error number (-1719)
			exit repeat
		end try
	end repeat
	
end deleteAlbumHaveList

on deleteAlbumWantList()
	
	set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
	do shell script "rm -r " & quoted form of (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/")
	
	set myVinylWantListContents to do shell script ("cat " & quoted form of myVinylWantList)
	refreshList_Contents_Catalog(myVinylWantListContents, releaseCatalog, myVinylWantList, true, "want")
	
	delete_dataRow(myVinylWantListCatalog, releaseCatalog)
	
	do shell script ("echo " & quoted form of myVinylWantListContents & " > " & quoted form of myVinylWantList)
	refreshList_Contents_Catalog("", "", myVinylWantList, false, "want")
	
	set releaseCatalog to common_catalogFlip(releaseCatalog, "view")
	
	if myVinylWantListCatalog is {} then
		common_totalCountText("want", true, myVinylWantListCatalog)
	else
		common_totalCountText("want", false, myVinylWantListCatalog)
	end if
	
	deleteVisibleTraces()
	addToRecentActivity("Removed", "from")
	
	repeat with a from 1 to (count myVinylWantListCatalog)
		try
			common_placeZeros(theWantListDataSource, a, (count myVinylWantListCatalog))
		on error number (-1719)
			exit repeat
		end try
	end repeat
	
end deleteAlbumWantList

on onlineAddFunction(releaseID)
	set releaseID to snr(releaseID, "[", "")
	set releaseID to snr(releaseID, "r", "")
	set releaseID to snr(releaseID, "]", "")
	
	if releaseID is not "" then
		--set myReleaseURL to ("http://www.discogs.com/release/" & releaseID & "?f=xml&api_key=55487673c2")
		set myReleaseURL to ("http://api.discogs.com/release/" & releaseID & "?f=xml")
		try
			do shell script ("perl " & quoted form of pathTOCURLfileZIP & " " & quoted form of myReleaseURL & " " & quoted form of (pathTOCURLedfile))
			set releaseText to do shell script ("cat " & quoted form of (pathTOCURLedfile))
		on error
			error number -128
		end try
	else
		error number -128
	end if
	
	if currentlisttype is "have" then
		set releasejumble to (count myVinylListCatalog)
		set myOnlineAddDS to theHaveListDataSource
	else
		set releasejumble to (count myVinylWantListCatalog)
		set myOnlineAddDS to theWantListDataSource
	end if
	
	set otherScript to useOtherScript("addXMLitem")
	tell otherScript to addXMLItem(releasejumble, releaseText, currentlisttype, myAppSupportFolder, releasejumble, "add")
	set myNewCat to result
	
	if myNewCat is not "ERROR_Discogs_Fail" then
		set myNewCat to snr(myNewCat, "....", "..+")
		set myNewCat to snr(myNewCat, "/", "....")
		repeat with a from 1 to (releasejumble + 1)
			try
				common_placeZeros(myOnlineAddDS, a, (releasejumble + 1))
			on error number (-1719)
				exit repeat
			end try
		end repeat
	end if
	return myNewCat
end onlineAddFunction
on truncate(aNumber, decimalPlaces)
	
	set aNumeral to "" & aNumber
	
	if aNumeral does not contain "." then
		set aNumeral to aNumeral & "."
	end if
	
	repeat with i from 1 to decimalPlaces
		set aNumeral to aNumeral & "0"
	end repeat
	
	repeat with i from 1 to length of aNumeral
		if characters i thru -1 of aNumeral does not contain "." then exit repeat
	end repeat
	try
		return (characters (1) thru (i + (decimalPlaces - 1)) of aNumeral as string) + 0
	end try
end truncate
on selectionDiffer(addorchange)
	if currentlisttype is "have" then
		set thisCurrentCount to (count myVinylListCatalog)
	else if currentlisttype is "want" then
		set thisCurrentCount to (count myVinylWantListCatalog)
	end if
	if addorchange is not "add" then
		if addorchange is "random" then
			set bb to (random number from 1 to thisCurrentCount)
			
			tell data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
				set releaseArtist to (contents of data cell "artistColumn" of data row bb)
				set releaseAlbum to (contents of data cell "titleColumn" of data row bb)
				set releaseCatalog to (contents of data cell "catalogColumn" of data row bb)
				set releaseLABEL to (contents of data cell "labelColumn" of data row bb)
				set releaseCountry to (contents of data cell "countryColumn" of data row bb)
				set releaseDate to (contents of data cell "releaseDateColumn" of data row bb)
				set releaseFormat to (contents of data cell "formatColumn" of data row bb)
				set releaseID to (contents of data cell "releaseIDColumn" of data row bb)
				set releaseCondition to (contents of data cell "conditionColumn" of data row bb)
				set albumNo to (contents of data cell "numColumn" of data row bb)
				
				set myBPM to (contents of data cell "BPMColumn" of data row bb)
				set myGenre to (contents of data cell "genreColumn" of data row bb)
				set myStyle to (contents of data cell "styleColumn" of data row bb)
				set mySongPreference to (contents of data cell "songPreferenceColumn" of data row bb)
				set myKeySignature to (contents of data cell "keySignatureColumn" of data row bb)
				set myComments to (contents of data cell "commentsColumn" of data row bb)
				set myEnergyRating to (contents of data cell "energyRatingColumn" of data row bb)
			end tell
			
		else
			try
				set albumChosen to getMyAlbum()
			on error
				error number -128
			end try
			tell table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
				set releaseArtist to (contents of data cell "artistColumn" of selected data row)
				set releaseAlbum to (contents of data cell "titleColumn" of selected data row)
				set releaseCatalog to (contents of data cell "catalogColumn" of selected data row)
				set releaseLABEL to (contents of data cell "labelColumn" of selected data row)
				set releaseCountry to (contents of data cell "countryColumn" of selected data row)
				set releaseDate to (contents of data cell "releaseDateColumn" of selected data row)
				set releaseFormat to (contents of data cell "formatColumn" of selected data row)
				set releaseID to (contents of data cell "releaseIDColumn" of selected data row)
				set releaseCondition to (contents of data cell "conditionColumn" of selected data row)
				set albumNo to (contents of data cell "numColumn" of selected data row)
				
				set myBPM to (contents of data cell "BPMColumn" of selected data row)
				set myGenre to (contents of data cell "genreColumn" of selected data row)
				set myStyle to (contents of data cell "styleColumn" of selected data row)
				set mySongPreference to (contents of data cell "songPreferenceColumn" of selected data row)
				set myKeySignature to (contents of data cell "keySignatureColumn" of selected data row)
				set myComments to (contents of data cell "commentsColumn" of selected data row)
				set myEnergyRating to (contents of data cell "energyRatingColumn" of selected data row)
			end tell
			
		end if
		set visible of button "moveToOtherListButton" of window "mainList" to true
	else
		(*try
			set albumChosen to getMyAlbum()
		on error
			error number -128
		end try*)
		--set thisCurrentCount to (thisCurrentCount + 1)
		tell data source of (table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
			set releaseArtist to (contents of data cell "artistColumn" of data row (thisCurrentCount))
			set releaseAlbum to (contents of data cell "titleColumn" of data row (thisCurrentCount))
			set releaseCatalog to (contents of data cell "catalogColumn" of data row (thisCurrentCount))
			set releaseLABEL to (contents of data cell "labelColumn" of data row (thisCurrentCount))
			set releaseCountry to (contents of data cell "countryColumn" of data row (thisCurrentCount))
			set releaseDate to (contents of data cell "releaseDateColumn" of data row (thisCurrentCount))
			set releaseFormat to (contents of data cell "formatColumn" of data row (thisCurrentCount))
			set releaseID to (contents of data cell "releaseIDColumn" of data row (thisCurrentCount))
			set releaseCondition to (contents of data cell "conditionColumn" of data row (thisCurrentCount))
			set albumNo to (contents of data cell "numColumn" of data row (thisCurrentCount))
			
			set myBPM to (contents of data cell "BPMColumn" of data row (thisCurrentCount))
			set myGenre to (contents of data cell "genreColumn" of data row (thisCurrentCount))
			set myStyle to (contents of data cell "styleColumn" of data row (thisCurrentCount))
			set mySongPreference to (contents of data cell "songPreferenceColumn" of data row (thisCurrentCount))
			set myKeySignature to (contents of data cell "keySignatureColumn" of data row (thisCurrentCount))
			set myComments to (contents of data cell "commentsColumn" of data row (thisCurrentCount))
			set myEnergyRating to (contents of data cell "energyRatingColumn" of data row (thisCurrentCount))
		end tell
		set visible of button "moveToOtherListButton" of window "mainList" to false
	end if
	
	
	
	tell tab view 1 of view 2 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList"
		set visible of button "saveChanges" of tab view item 1 to true
		set visible of button "saveChanges" of tab view item 2 to true
	end tell
	
	set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
	
	set myCurrentListItemFile to (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/details.txt") as string
	
	try
		set myCurrentListItemFileContents to (do shell script "cat " & quoted form of myCurrentListItemFile) as string
	on error
		error number -128
	end try
	
	--NOTES
	try
		set releaseNotes to item 2 of split(myCurrentListItemFileContents, ("<--NOTES-->"))
		set the contents of text view 1 of scroll view 1 of tab view item 2 of tab view 1 of view 2 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList" to releaseNotes
	on error
		set releaseNotes to ""
		set the contents of text view 1 of scroll view 1 of tab view item 2 of tab view 1 of view 2 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList" to releaseNotes
	end try
	--CREDITS
	try
		set releaseCredits to item 2 of split(myCurrentListItemFileContents, ("<--CREDITS-->"))
		set the contents of text view 1 of scroll view 1 of tab view item 1 of tab view 1 of view 2 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList" to releaseCredits
	on error
		set releaseCredits to ""
		set the contents of text view 1 of scroll view 1 of tab view item 1 of tab view 1 of view 2 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList" to releaseCredits
	end try
	
	---DEFINE TRACKLISTSTRING HERE
	try
		set trackLISTstring to refreshTracks(myCurrentListItemFileContents, true)
	on error
		set trackLISTstring to "<--TRACKLIST--><--TRACKLIST-->"
	end try
	
	set releaseName to {releaseArtist, " - ", releaseAlbum} as string
	updateReleaseNameBoxes()
	
	try
		set image of image view "bigMainListArtBox" of window "mainList" to load image (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/image.jpeg")
		set image of image view "mainListArtBox" of (view 1 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList") to load image (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/image.jpeg")
	on error
		clearArt()
	end try
	
	try
		if releaseID is "" then
			set title of menu item "editOnDiscogs" of menu 2 of main menu to (localized string "menu_SubmitDiscogs")
			set enabled of menu item "viewOnDiscogs" of menu 2 of main menu to false
		else
			set title of menu item "editOnDiscogs" of menu 2 of main menu to (localized string "menu_EditDiscogs")
			set enabled of menu item "viewOnDiscogs" of menu 2 of main menu to true
		end if
	end try
	try
		set title of menu item "itemSelectedMenu" of menu 2 of main menu to releaseAlbum
	end try
	set releaseCatalog to common_catalogFlip(releaseCatalog, "view")
end selectionDiffer

on common_placeZeros(myDataSource, a, endVal)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to placeZeros(myDataSource, a, endVal)
end common_placeZeros

on common_getZeros(a, endVal)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to getZeros(a, endVal)
end common_getZeros

on common_findCatalogDupes(getSelected, currentFType, t_releaseCatalog)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to findCatalogDupes(getSelected, currentFType, t_releaseCatalog, myAppSupportFolder, currentlisttype)
end common_findCatalogDupes

on common_catalogFlip(tmp_releaseCatalog, flipDirection)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to catalogFlip(tmp_releaseCatalog, flipDirection)
end common_catalogFlip

on importMidProcess(b)
	if b is "!" then
		set b to (POSIX path of (choose file))
	end if
	set b2 to do shell script "cat " & quoted form of b
	if paragraph 1 of b2 contains "<releases num=" then
		set b to b2
	else
		set ssScript to (quoted form of p7String & " l " & quoted form of (b))
		try
			set viewResults to (do shell script ssScript)
		on error
			common_displayDialog((localized string "dialog_UnknownFile"), "?", false, "")
			error number -128
		end try
		set viewResults to item 2 of split(viewResults, "------------------- ----- ------------ ------------  ------------------------") as string
		set viewResults to every paragraph of viewResults
		set viewResults to rest of viewResults
		set resultingItem to last item of split(item 1 of viewResults, " ")
		set ssScript to (quoted form of p7String & " x -y -o" & quoted form of appsup & " " & quoted form of b)
		try
			do shell script ssScript
		end try
		set b to (do shell script "cat " & quoted form of (appsup & resultingItem)) as string
		do shell script ("rm " & quoted form of (appsup & resultingItem))
	end if
	copy b to importRawList
	common_update_progress(0, 0, "importing")
	set contents of text field "importCountBox" of window "importing" to ((localized string "misc_Loading") & "...")
	set contents of text field "timeRemainingImport" of window "importing" to ""
	--display panel window "importing" attached to window "mainList"
	set myImportCount to item 1 of split((paragraph 1 of b), "\">")
	set myImportCount to item 2 of split(myImportCount, "<releases num=\"")
	
	set importRawListSplit to split(importRawList, "</release>")
	
	try
		clearArt()
	end try
	deleteVisibleTraces()
	
	--close panel window "importing"
	return myImportCount
end importMidProcess
on updateRecentList()
	set skipMe to false
	try
		set myRecentCount to (rest of (split(myRecentActivityListContents, ("<..change!-...>"))))
	on error
		set myRecentCount to {}
	end try
	set (content of table view 1 of scroll view 1 of window "recentActivityWindow") to myRecentCount
	if (count myRecentCount) is equal to 1 then
		set content of text field "recentActivityCountBox" of window "recentActivityWindow" to snr((localized string "misc_OneItem"), "1", ((count myRecentCount) as string))
	else if (count myRecentCount) is equal to 0 then
		set content of text field "recentActivityCountBox" of window "recentActivityWindow" to snr((localized string "misc_ZeroItems"), "0", ((count myRecentCount) as string))
	else
		set content of text field "recentActivityCountBox" of window "recentActivityWindow" to snr((localized string "misc_MoreItems"), "0", ((count myRecentCount) as string))
	end if
end updateRecentList

-----------------
--START PLAYLISTS
-----------------

on playlist_Load(myLastAction)
	set otherScript to useOtherScript("playlist")
	tell otherScript to loadPlaylists(myLastAction, myAppSupportFolder, currentlisttype)
end playlist_Load

on playlist_Show(myPlaylist)
	set otherScript to useOtherScript("playlist")
	tell otherScript to displayPlaylist(myPlaylist, myAppSupportFolder, currentlisttype, theHaveListDataSource, theWantListDataSource)
end playlist_Show

on playlist_Create()
	set otherScript to useOtherScript("playlist")
	tell otherScript to newPlaylist(myAppSupportFolder, currentlisttype)
end playlist_Create

on playlist_MoveItem()
	set otherScript to useOtherScript("playlist")
	tell otherScript to movePlaylistItem(myAppSupportFolder, currentlisttype, releaseCatalog, myVinylListCatalog, myVinylWantListCatalog)
end playlist_MoveItem

on playlist_Delete()
	set otherScript to useOtherScript("playlist")
	tell otherScript to removePlaylist(myAppSupportFolder, currentlisttype)
	playlist_Load("delete")
end playlist_Delete

on playlist_DeleteItem(releaseCatalog, myPlaylistFile)
	set otherScript to useOtherScript("playlist")
	tell otherScript to removeFromPlaylist(releaseCatalog, myPlaylistFile, currentlisttype)
end playlist_DeleteItem

-----------------
----END PLAYLISTS
-----------------

-----------------
-----START EXPORT
-----------------

on export_toHTML()
	set myPlaylist to get_myPlaylist()
	set otherScript to useOtherScript("export")
	tell otherScript to exportToHTML(myPlaylist, myAppSupportFolder, appsup, currentlisttype, myVinylList, myVinylWantList)
	common_displayDialog((localized string "dialog_FinishedExportingHTML"), (localized string "button_Yay"), false, "")
end export_toHTML

on export_toXLS_HTML()
	set myPlaylist to get_myPlaylist()
	set otherScript to useOtherScript("export")
	tell otherScript to exportXLS_HTML(myPlaylist, appsup, currentlisttype, myVinylListCatalog, myVinylWantListCatalog, theHaveListDataSource, theWantListDataSource)
	common_displayDialog((localized string "dialog_FinishedExportingXLS"), (localized string "button_Yay"), false, "")
end export_toXLS_HTML

on export_toXLS_Binary()
	set myPlaylist to get_myPlaylist()
	set otherScript to useOtherScript("export")
	tell otherScript to exportXLSBinary(myPlaylist, appsup, currentlisttype, myVinylListCatalog, myVinylWantListCatalog, theHaveListDataSource, theWantListDataSource)
	if result is "error" then
		common_displayDialog((localized string "dialog_errorNoXLSBin"), (localized string "button_Oh"), false, "")
	else
		common_displayDialog((localized string "dialog_FinishedExportingXLS"), (localized string "button_Yay"), false, "")
	end if
end export_toXLS_Binary

-----------------
-------END EXPORT
-----------------

on getMyAlbum()
	return ((contents of data cell "artistColumn" of selected data row of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList") & " - " & (contents of data cell "titleColumn" of selected data row of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")) as string
end getMyAlbum

on longDetailsPrep()
	
	set myDetails to ("<--NAME-->" & releaseName & "<--NAME-->
<--LABEL-->" & releaseLABEL & "<--LABEL-->
<--CATALOG-->" & releaseCatalog & "<--CATALOG-->
<--COUNTRY-->" & releaseCountry & "<--COUNTRY-->
<--RELEASED-->" & releaseDate & "<--RELEASED-->
<--CONDITION-->" & releaseCondition & "<--CONDITION-->
<--RELEASEID-->" & releaseID & "<--RELEASEID-->
<--NOTES-->" & releaseNotes & "<--NOTES-->
<--CREDITS-->" & releaseCredits & "<--CREDITS-->
<--FORMAT-->" & releaseFormat & "<--FORMAT-->
<--TRACKLIST-->" & (ASCII character 10) & trackLISTstring & (ASCII character 10) & "<--TRACKLIST-->") as string
	
	set myDetails to myDetails & ("<--BPM_COUNT-->" & myBPM & "<--BPM_COUNT-->
<--ALB_GENRE-->" & myGenre & "<--ALB_GENRE-->
<--ALB_STYLE-->" & myStyle & "<--ALB_STYLE-->
<--SNG_PREFERENCE-->" & mySongPreference & "<--SNG_PREFERENCE-->
<--ALB_KEY_SIGNATURE-->" & myKeySignature & "<--ALB_KEY_SIGNATURE-->
<--ALB_COMMENTS-->" & myComments & "<--ALB_COMMENTS-->
<--ALB_ENRGYRATING-->" & myEnergyRating & "<--ALB_ENRGYRATING-->") as string
	
	if (count split(myDetails, "<--NAME-->")) is greater than 3 then
		set myDetails to item 3 of split(myDetails, "<--NAME-->")
		set myDetails to ("<--NAME-->" & releaseName & "<--NAME-->" & myDetails & trackLISTstring) as string
	end if
	return myDetails
end longDetailsPrep

on common_totalCountText(haveORwant, emptyTotal, myTempListCatalog)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to totalCountText(haveORwant, emptyTotal, myTempListCatalog)
end common_totalCountText

on refreshTracks(myCurrentWorkFile, displayTracks)
	copy myCurrentWorkFile to trackLISTstring
	set trackLISTstring to (item 2 of split(trackLISTstring, ("<--TRACKLIST-->"))) as string
	set myTempTracks to every paragraph of (trackLISTstring)
	set myTempTracks to common_cleanMyList(myTempTracks, {""})
	
	copy myTempTracks to releaseTrackList_positions
	copy myTempTracks to releaseTrackList_titles
	
	set trackLISTstring to ""
	repeat with myRefTracks from 1 to (count myTempTracks)
		set trackLISTstring to (trackLISTstring & (item myRefTracks of myTempTracks)) as string
		if myRefTracks is less than (count myTempTracks) then
			set trackLISTstring to (trackLISTstring & (ASCII character 10)) as string
		end if
	end repeat
	
	repeat with arbatraryL from 1 to (count myTempTracks)
		set (item arbatraryL of releaseTrackList_positions) to item 1 of split((item arbatraryL of releaseTrackList_positions), "</trackPosition>")
		set (item arbatraryL of releaseTrackList_positions) to item 2 of split((item arbatraryL of releaseTrackList_positions), "<trackPosition>")
	end repeat
	
	repeat with arbatraryL from 1 to (count myTempTracks)
		set (item arbatraryL of releaseTrackList_titles) to item 1 of split((item arbatraryL of releaseTrackList_titles), "</trackTitle>")
		set (item arbatraryL of releaseTrackList_titles) to item 2 of split((item arbatraryL of releaseTrackList_titles), "<trackTitle>")
	end repeat
	
	if displayTracks is true then
		if visible of window "updateAlbumWindow" is false then
			--DELETE OLD DATA SOURCE
			try
				delete data source theTrackListDataSource
			end try
			--CREATE NEW ONE
			set theTrackListDataSource to make new data source at end of data sources
			tell theTrackListDataSource
				make new data column at end of data columns with properties {name:"trackPosition", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"trackTitle", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
			end tell
			
			set data source of (table view "trackListTableView" of scroll view "trackListScrollView" of drawer "trackListView" of window "mainList") to theTrackListDataSource
			
			--POPULATE DATA SOURCE
			
			repeat with myRepeatVar from 1 to (count myTempTracks)
				tell theTrackListDataSource
					make new data row at end of data rows
					set contents of data cell "trackPosition" of data row myRepeatVar to (item myRepeatVar of releaseTrackList_positions as string)
					set contents of data cell "trackTitle" of data row myRepeatVar to (item myRepeatVar of releaseTrackList_titles as string)
				end tell
			end repeat
		else
			--DELETE OLD DATA SOURCE
			try
				delete data source theTrackListUPDataSource
			end try
			--CREATE NEW ONE
			set theTrackListUPDataSource to make new data source at end of data sources
			tell theTrackListUPDataSource
				make new data column at end of data columns with properties {name:"trackPosition", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				make new data column at end of data columns with properties {name:"trackTitle", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
			end tell
			
			set data source of (table view "updt_trackListTableView" of scroll view 1 of window "updateAlbumWindow") to theTrackListUPDataSource
			
			--POPULATE DATA SOURCE
			
			repeat with myRepeatVar from 1 to (count myTempTracks)
				tell theTrackListUPDataSource
					make new data row at end of data rows
					set contents of data cell "trackPosition" of data row myRepeatVar to (item myRepeatVar of releaseTrackList_positions as string)
					set contents of data cell "trackTitle" of data row myRepeatVar to (item myRepeatVar of releaseTrackList_titles as string)
				end tell
			end repeat
		end if
	end if
	return trackLISTstring
end refreshTracks

on initializeMe()
	set firstRun to true
	set currentlisttype to "have"
	set currentFolderType to "Collection"
	set currentBottomType to "credits"
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
			set currentHaveColumn to item 2 of split(prefsfileR, "<haveColumn>") as string
		on error
			set currentHaveColumn to "numColumn"
		end try
		try
			set currentWantColumn to item 2 of split(prefsfileR, "<wantColumn>") as string
		on error
			set currentWantColumn to "numColumn"
		end try
		try
			set myAZorderH to item 2 of split(prefsfileR, "<myAZH>") as string
		on error
			set myAZorderH to "a"
		end try
		try
			set myAZorderW to item 2 of split(prefsfileR, "<myAZW>") as string
		on error
			set myAZorderW to "a"
		end try
		try
			set myAppSupportFolder to item 2 of split(prefsfileR, "<pathToMyCollection>") as string
		on error
			set myAppSupportFolder to ((POSIX path of (path to home folder)) & "Library/Application Support/myVinyl/") as string
		end try
		
		try
			set visibleColumnsWant to item 2 of split(prefsfileR, "<visibleWantColumns>") as string
		on error
			set visibleColumnsWant to "11111111010000000"
		end try
		try
			set visibleColumnsHave to item 2 of split(prefsfileR, "<visibleHaveColumns>") as string
		on error
			set visibleColumnsHave to "11111111010000000"
		end try
	on error
		set currentHaveColumn to "numColumn"
		set currentWantColumn to "numColumn"
		set myAZorderH to "a"
		set myAZorderW to "a"
		set visibleColumnsWant to "11111111010000000"
		set visibleColumnsHave to "11111111010000000"
		set myAppSupportFolder to ((POSIX path of (path to home folder)) & "Library/Application Support/myVinyl/") as string
	end try
	
	
	
	
	if (count every character of visibleColumnsWant) is less than 10 then
		set visibleColumnsWant to (visibleColumnsWant & "1")
	end if
	if (count every character of visibleColumnsHave) is less than 10 then
		set visibleColumnsHave to (visibleColumnsHave & "1")
	end if
	
	
	if (count every character of visibleColumnsWant) is less than 16 then
		set visibleColumnsWant to (visibleColumnsWant & "0000000")
	end if
	if (count every character of visibleColumnsHave) is less than 16 then
		set visibleColumnsHave to (visibleColumnsHave & "0000000")
	end if
	
	
	
	
	set contents of text field "visiblePathToCollection" of window "prefsWindow" to myAppSupportFolder
	set myVinylList to (myAppSupportFolder & "myVinylList.txt") as string
	set myVinylWantList to (myAppSupportFolder & "myVinylWantList.txt") as string
	set myRecentActivityList to (myAppSupportFolder & "recentActivity.txt") as string
	
	return false
end initializeMe

on lastToInitialize()
	set theCurrentDataSource to theHaveListDataSource
	-----------
	
	set data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item "haveTab" of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to theHaveListDataSource
	set data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item "wantTab" of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to theWantListDataSource
	
	---LOAD RECENT ACTIVITY
	try
		set myRecentActivityListContents to (do shell script "cat " & quoted form of myRecentActivityList)
		updateRecentList()
	on error
		set myRecentActivityListContents to ""
	end try
	
	set releaseID to ""
	
	-----
	repeat with aaaLoop from 1 to 2
		if aaaLoop is 1 then
			set theDataSource to theHaveListDataSource
			set theColumnIdentifier to currentHaveColumn
			set myAZorder to myAZorderH
		else
			set theDataSource to theWantListDataSource
			set theColumnIdentifier to currentWantColumn
			set myAZorder to myAZorderW
		end if
		
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
			if myAZorder is "a" then
				set the sort case sensitivity of theSortColumn to case sensitive
				set sort order of theSortColumn to descending
			else
				set the sort case sensitivity of theSortColumn to case sensitive
				set sort order of theSortColumn to ascending
			end if
		end if
		
	end repeat
	
	update (table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 1 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
	update (table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 2 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
	set theHaveListDataSource to data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 1 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
	set theWantListDataSource to data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 2 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
	
	set otherScript to useOtherScript("hideColumns")
	tell otherScript
		hideColumnsPrefs("H", visibleColumnsHave, visibleColumnsWant)
		hideColumnsMain("have", visibleColumnsHave, visibleColumnsWant)
		
		hideColumnsPrefs("W", visibleColumnsHave, visibleColumnsWant)
		hideColumnsMain("want", visibleColumnsHave, visibleColumnsWant)
		hideColumnsSearchXML()
	end tell
	
	tell tab view 1 of view 2 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList"
		set text color of text view 1 of scroll view 1 of tab view item 1 to "white"
		set text color of text view 1 of scroll view 1 of tab view item 2 to "white"
	end tell
	
	deleteVisibleTraces()
	--
	set releaseCondition to ""
	set releaseCredits to ""
	
	set current tab view item of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to tab view item "haveTab" of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
	
	set visible of window "mainList" to true
	set visible of window "launchLoading" to false
	
	
	activate window "mainList"
	
	if firstRun is true then
		set myFirstName to (word 1 of (long user name of (system info) as string)) as string
		set myFirstLine to ((localized string "button_Hey") & " " & myFirstName) as string
		common_displayDialog((localized string "dialog_Welcome"), (localized string "button_Hey"), false, myFirstLine)
	end if
end lastToInitialize

on dropAlbumArt(dragInfo, switchType)
	try
		set albumChosen to getMyAlbum()
	on error
		common_displayDialog((localized string "dialog_NoAlbum"), (localized string "button_Oh"), false, "")
		error number -128
	end try
	set preferred type of pasteboard of dragInfo to "file names"
	set fileinfo to (contents of pasteboard of dragInfo) as string
	tell application "System Events"
		set dropKind to (kind of (POSIX file (fileinfo) as alias))
	end tell
	set dropKind to changeCase_lower(dropKind) as string
	
	if dropKind is "jpeg image" then
		set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
		if switchType is "updateItem" then
			
			do shell script "cp -f " & quoted form of fileinfo & " " & quoted form of (appsup & "updt_img.jpeg")
			try
				set image of image view "updt_artView" of window "updateAlbumWindow" to load image (appsup & "updt_img.jpeg")
			end try
		else
			do shell script "cp -f " & quoted form of fileinfo & " " & quoted form of (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/image.jpeg")
			try
				set image of image view "bigMainListArtBox" of window "mainList" to load image (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/image.jpeg")
			end try
			try
				set image of image view "mainListArtBox" of (view 1 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList") to load image (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/image.jpeg")
			end try
		end if
		set releaseCatalog to common_catalogFlip(releaseCatalog, "view")
		
		
	else
		common_displayDialog((localized string "dialog_OnlyJPEG"), (localized string "button_Oh"), false, "")
		clearArt()
	end if
end dropAlbumArt
on updateReleaseNameBoxes()
	set title of window "mainList" to releaseAlbum
end updateReleaseNameBoxes
on updateCatalogNo(albumOrigCatalog)
	set find1 to (albumNo & "::	.:.	:" & albumOrigCatalog)
	set find2 to (albumNo & "::	.:.	:" & releaseCatalog)
	
	if currentlisttype is "have" then
		set myVinylListContents to do shell script ("cat " & quoted form of myVinylList)
		set myVinylListContents to snr(myVinylListContents, find1, find2) as string
		do shell script ("echo " & quoted form of myVinylListContents & " > " & quoted form of myVinylList)
		
		set myVinylListCatalog to every paragraph of myVinylListContents
		repeat with a from 1 to (count myVinylListCatalog)
			set item a of myVinylListCatalog to item 2 of split((item a of myVinylListCatalog), "::	.:.	:")
		end repeat
	else if currentlisttype is "want" then
		set myVinylWantListContents to do shell script ("cat " & quoted form of myVinylWantList)
		set myVinylWantListContents to snr(myVinylWantListContents, find1, find2) as string
		do shell script ("echo " & quoted form of myVinylWantListContents & " > " & quoted form of myVinylWantList)
		
		set myVinylWantListCatalog to every paragraph of myVinylWantListContents
		repeat with a from 1 to (count myVinylWantListCatalog)
			set item a of myVinylWantListCatalog to item 2 of split((item a of myVinylWantListCatalog), "::	.:.	:")
		end repeat
	end if
end updateCatalogNo
on renew_myListContents(temp_myListContents, temp_releaseCat, temp_myList, deleteLineBoolean)
	if deleteLineBoolean is false then
		if (temp_releaseCat as string) is "" then
			set temp_myListContents to (do shell script ("cat " & quoted form of temp_myList))
		end if
		set temp_myListContents to every paragraph of temp_myListContents
		set temp_myListContents to common_alphabetize(common_cleanMyList(temp_myListContents, {""}))
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
			if deleteLineBoolean is false then
				repeat with rmLoop from 1 to (count temp_myListContents2)
					set myCompare to ((item rmLoop of temp_myListContents2) as string)
					if myCompare is equal to temp_releaseCat then
						set currentItemNo to (common_getZeros(rmLoop, (count temp_myListContents2))) as string
						exit repeat
					end if
				end repeat
			else
				set currentItemNo to albumNo
			end if
		end if
		
		if deleteLineBoolean is true then
			set myFINDstring to (currentItemNo & "::	.:.	:" & common_catalogFlip(temp_releaseCat, "file")) as string
			set temp_myListContents to split(temp_myListContents, myFINDstring) as string
			set temp_myListContents to common_cleanMyList((every paragraph of temp_myListContents), {""})
		else
			if temp_myList ends with ".myvy" then
				set currentItemNo to ((count temp_myListContents) + 1)
			end if
		end if
		--FIX LIST
		repeat with rmLoop from 1 to (count temp_myListContents)
			set myReplaceNum to common_getZeros(rmLoop, (count temp_myListContents))
			set myReplaceItem to (item rmLoop of temp_myListContents) as string
			if deleteLineBoolean is true then
				set myReplaceItem to (item 2 of split(myReplaceItem, "::	.:.	:")) as string
			end if
			set myReplaceItem to (myReplaceNum & ("::	.:.	:") & myReplaceItem) as string
			if rmLoop is less than (count temp_myListContents) then
				set myReplaceItem to ((myReplaceItem) & (ASCII character 10)) as string
			end if
			set (item rmLoop of temp_myListContents) to myReplaceItem
		end repeat
		--DONE FIXIN
		
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
on deleteVisibleTraces()
	tell (tab view 1 of view 2 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList")
		set the contents of text view 1 of scroll view 1 of tab view item 2 to ""
		set the contents of text view 1 of scroll view 1 of tab view item 1 to ""
		set visible of button "saveChanges" of tab view item 1 to false
		set visible of button "saveChanges" of tab view item 2 to false
	end tell
	set title of menu item "itemSelectedMenu" of menu 2 of main menu to (localized string "misc_NothingSelected")
	set (content of table view "trackListTableView" of scroll view "trackListScrollView" of drawer "trackListView" of window "mainList") to {""}
	set title of window "mainList" to (".:MyVinyl:.")
	set visible of button "moveToOtherListButton" of window "mainList" to false
	clearArt()
end deleteVisibleTraces
on clearArt()
	set image of image view "bigMainListArtBox" of window "mainList" to load image ("NSApplicationIcon")
	set image of image view "mainListArtBox" of (view 1 of split view "bottomSplitView" of view 2 of split view "mainSplitView" of window "mainList") to load image ("NSApplicationIcon")
end clearArt

on common_cleanMyList(theList, itemsToDelete)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to cleanMyList(theList, itemsToDelete)
end common_cleanMyList

on common_alphabetize(the_list)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to alphabetize(the_list)
end common_alphabetize


on addToRecentActivity(ra_word1, ra_word2)
	try
		set myRecentActivityListContents to (do shell script "cat " & quoted form of myRecentActivityList)
	on error
		set myRecentActivityListContents to ""
	end try
	------ADD TO RECENT ACTIVITY
	if releaseID is not "" then
		---
		set releaseID to snr(releaseID, "[", "")
		set releaseID to snr(releaseID, "r", "")
		set releaseID to snr(releaseID, "]", "")
		---
		if ra_word1 is "Changed" then
			set myRecentActivityListContents to (myRecentActivityListContents & "<..change!-...>Changed " & origReleaseID & " to " & releaseID & " in " & currentlisttype & " list.")
		else if ra_word1 is "Moved" then
			set myRecentActivityListContents to (myRecentActivityListContents & "<..change!-...>Moved " & releaseID & " to " & ra_word2 & " list.")
		else
			set myRecentActivityListContents to (myRecentActivityListContents & "<..change!-...>" & ra_word1 & " " & releaseID & " " & ra_word2 & " " & currentlisttype & " list.")
		end if
		updateRecentList()
		do shell script ("echo " & quoted form of myRecentActivityListContents & " > " & quoted form of myRecentActivityList)
	end if
end addToRecentActivity
on useOtherScript(scriptNameID)
	tell me
		set otherScript to POSIX file ((appsup & "Scripts/" & scriptNameID & ".scpt") as string)
		--set otherScript to ((path for script scriptNameID) as string)
	end tell
	set otherScript to load script (otherScript)
	return otherScript
end useOtherScript
on get_myPlaylist()
	tell (view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
		set myPlaylist to (the title of popup button "playlistMenu")
	end tell
	return myPlaylist
end get_myPlaylist
on refreshList_Contents_Catalog(rfVar1, rfVar2, rfVar3, rfVar4, givenListType)
	if givenListType is "have" then
		set myVinylListContents to renew_myListContents(rfVar1, rfVar2, rfVar3, rfVar4)
		
		set myVinylListCatalog to every paragraph of myVinylListContents
		set myVinylListCatalog to common_cleanMyList(myVinylListCatalog, {""})
		
		repeat with rmLoop from 1 to count myVinylListCatalog
			set (item rmLoop of myVinylListCatalog) to (item 2 of split((item rmLoop of myVinylListCatalog), "::	.:.	:"))
		end repeat
		
		return myVinylListContents
	else
		set myVinylWantListContents to renew_myListContents(rfVar1, rfVar2, rfVar3, rfVar4)
		
		set myVinylWantListCatalog to every paragraph of myVinylWantListContents
		set myVinylWantListCatalog to common_cleanMyList(myVinylWantListCatalog, {""})
		
		repeat with rmLoop from 1 to count myVinylWantListCatalog
			set (item rmLoop of myVinylWantListCatalog) to (item 2 of split((item rmLoop of myVinylWantListCatalog), "::	.:.	:"))
		end repeat
		
		return myVinylWantListContents
	end if
end refreshList_Contents_Catalog
on fillDataSourcesOffline(myGivenList)
	
	if myGivenList is "have" then
		tell theHaveListDataSource
			make new data row at end of data rows
		end tell
		common_placeZeros(theHaveListDataSource, (count myVinylListCatalog), (count myVinylListCatalog))
		tell theHaveListDataSource
			set contents of data cell "artistColumn" of data row (count myVinylListCatalog) to releaseArtist
			set contents of data cell "titleColumn" of data row (count myVinylListCatalog) to releaseAlbum
			set contents of data cell "labelColumn" of data row (count myVinylListCatalog) to releaseLABEL
			set contents of data cell "catalogColumn" of data row (count myVinylListCatalog) to releaseCatalog
			set contents of data cell "formatColumn" of data row (count myVinylListCatalog) to releaseFormat
			set contents of data cell "countryColumn" of data row (count myVinylListCatalog) to releaseCountry
			set contents of data cell "releasedateColumn" of data row (count myVinylListCatalog) to releaseDate
			set contents of data cell "releaseIDColumn" of data row (count myVinylListCatalog) to releaseID
		end tell
	else if myGivenList is "want" then
		tell theWantListDataSource
			make new data row at end of data rows
		end tell
		common_placeZeros(theWantListDataSource, (count myVinylWantListCatalog), (count myVinylWantListCatalog))
		tell theWantListDataSource
			set contents of data cell "artistColumn" of data row (count myVinylWantListCatalog) to releaseArtist
			set contents of data cell "titleColumn" of data row (count myVinylWantListCatalog) to releaseAlbum
			set contents of data cell "labelColumn" of data row (count myVinylWantListCatalog) to releaseLABEL
			set contents of data cell "catalogColumn" of data row (count myVinylWantListCatalog) to releaseCatalog
			set contents of data cell "formatColumn" of data row (count myVinylWantListCatalog) to releaseFormat
			set contents of data cell "countryColumn" of data row (count myVinylWantListCatalog) to releaseCountry
			set contents of data cell "releasedateColumn" of data row (count myVinylWantListCatalog) to releaseDate
			set contents of data cell "releaseIDColumn" of data row (count myVinylWantListCatalog) to releaseID
		end tell
	end if
	
end fillDataSourcesOffline
on delete_dataRow(thisVinylListCatalog, temp_RC)
	set temp_RC to common_catalogFlip(temp_RC, "view")
	set myTempDataSource to (data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
	tell myTempDataSource
		repeat with aar from 1 to ((count thisVinylListCatalog) + 1)
			if (contents of data cell "catalogColumn" of data row (aar) is temp_RC) then
				delete data row aar
				exit repeat
			end if
		end repeat
	end tell
	
	try
		set (data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item "haveTab" of tab view 1 of view 1 of split view "mainSplitView" of window "mainList") to theHaveListDataSource
	end try
	try
		set (data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item "wantTab" of tab view 1 of view 1 of split view "mainSplitView" of window "mainList") to theWantListDataSource
	end try
end delete_dataRow
on addAlbumOff_Contents(myGivenList)
	if myGivenList is "have" then
		set myVinylListCatalog to myVinylListCatalog & {releaseCatalog}
		set data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 1 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to theHaveListDataSource
		
		set myLstCount to (count myVinylListCatalog)
		set myVinylListContents to (myVinylListContents & "
" & common_getZeros(myLstCount, (myLstCount + 1)) & "::	.:.	:" & releaseCatalog) as string
		do shell script ("echo " & quoted form of myVinylListContents & " > " & quoted form of myVinylList)
	else if myGivenList is "want" then
		set myVinylWantListCatalog to myVinylWantListCatalog & {releaseCatalog}
		set data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item 2 of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to theWantListDataSource
		
		set myLstCount to (count myVinylWantListCatalog)
		set myVinylWantListContents to (myVinylWantListContents & "
" & common_getZeros(myLstCount, (myLstCount + 1)) & "::	.:.	:" & releaseCatalog) as string
		do shell script ("echo " & quoted form of myVinylWantListContents & " > " & quoted form of myVinylWantList)
	end if
end addAlbumOff_Contents
on myImportKeep(myVinylKeep)
	set startVal to (contents of text field "importFromValue" of window "importingChooseAmount") as integer
	set endVal to (contents of text field "importToValue" of window "importingChooseAmount") as integer
	
	set myVinylKeep_pt1 to (items 1 thru (startVal - 1) of myVinylKeep)
	if endVal is less than (count myVinylKeep) then
		set myVinylKeep_pt2 to (items (endVal + 1) thru (count myVinylKeep) of myVinylKeep)
	else
		set myVinylKeep_pt2 to {}
	end if
	if endVal is less than (count myVinylKeep) then
		set myVinylDontKeep to (items startVal thru endVal of myVinylKeep)
	else
		set myVinylDontKeep to (items startVal thru (count myVinylKeep) of myVinylKeep)
	end if
	
	repeat with mySTRIPloop from 1 to (count myVinylKeep_pt1)
		set currentKeep to ((item mySTRIPloop of myVinylKeep_pt1) as string)
		set currentKeep to ((ASCII character 10) & currentKeep) as string
		set (item mySTRIPloop of myVinylKeep_pt1) to currentKeep
	end repeat
	
	repeat with mySTRIPloop from 1 to (count myVinylKeep_pt2)
		set currentKeep to ((item mySTRIPloop of myVinylKeep_pt2) as string)
		set currentKeep to ((ASCII character 10) & currentKeep) as string
		set (item mySTRIPloop of myVinylKeep_pt2) to currentKeep
	end repeat
	
	set myVinylKeep to {myVinylKeep_pt1, myVinylDontKeep, myVinylKeep_pt2}
	return myVinylKeep
end myImportKeep
on importLastPhase(myVinylKeep, startVal, endVal)
	set cancelImportVar to false
	set myAddedCats to {}
	
	if currentlisttype is "have" then
		set myCurrentCat to myVinylListCatalog
	else if currentlisttype is "want" then
		set myCurrentCat to myVinylWantListCatalog
	end if
	
	--------
	--CountString DIVIDER
	set myTotalCountString to split((localized string "misc_partOfWhole"), "1") as string
	set myTotalCountStringDivider to split(myTotalCountString, "2") as string
	--
	
	set myOldCompare to (count myCurrentCat)
	repeat with releasejumble from startVal to endVal
		if cancelImportVar is true then
			exit repeat
		end if
		
		common_update_progress(releasejumble, endVal, "importing")
		set contents of text field "importCountBox" of window "importing" to ((releasejumble & myTotalCountStringDivider & endVal) as string)
		--set timeRemain to ((((endVal / 60) - (releasejumble / 60)) * 2) * 2) as string
		set timeRemain to (((endVal - releasejumble) / 60) * 5) + 1 as string
		set timeRemain to snr(timeRemain, ",", ".")
		set timeRemain to truncate(timeRemain, 0) as string
		set contents of text field "timeRemainingImport" of window "importing" to (snr((localized string "misc_TimeRemaining"), "0.4", ((timeRemain) as string)))
		set otherScript to useOtherScript("addXMLitem")
		if releasejumble is greater than myOldCompare then
			tell otherScript
				set myaddedCat to addXMLItem(releasejumble, (item releasejumble of importRawListSplit), currentlisttype, myAppSupportFolder, endVal, "add")
			end tell
		else
			if endVal is greater than (count myCurrentCat) then
				tell otherScript
					set myaddedCat to addXMLItem(releasejumble, (item releasejumble of importRawListSplit), currentlisttype, myAppSupportFolder, endVal, "replace")
				end tell
			else
				tell otherScript
					set myaddedCat to addXMLItem(releasejumble, (item releasejumble of importRawListSplit), currentlisttype, myAppSupportFolder, (count myCurrentCat), "replace")
				end tell
			end if
		end if
		if myaddedCat is "ERROR_Discogs_Fail" then
			display alert "Discogs is not responding."
			set cancelImportVar to true
		else if myaddedCat is "REG_error" then
			set cancelImportVar to true
		else
			set myAddedCats to myAddedCats & {myaddedCat}
		end if
	end repeat
	if cancelImportVar is false then
		if startVal is not "1" then
			set myVinylDontKeep to (item 2 of myVinylKeep)
			repeat with randRL from 1 to (count myVinylDontKeep)
				set currentExperiment to (item randRL of myVinylDontKeep) as string
				set currentExperiment to snr(currentExperiment, ((item 2 of split(currentExperiment, "::	.:.	:")) as string), ((item randRL of myAddedCats) as string)) as string
				set (item randRL of myVinylDontKeep) to currentExperiment
			end repeat
			
			if (count myAddedCats) is greater than (count myVinylDontKeep) then
				repeat with randRL from ((count myVinylDontKeep) + 1) to (count myAddedCats)
					set currentExperiment to (common_getZeros(randRL, (count myAddedCats)) & "::	.:.	:" & ((item randRL of myAddedCats) as string))
					set myVinylDontKeep to myVinylDontKeep & {currentExperiment}
				end repeat
			end if
			set item 2 of myVinylKeep to myVinylDontKeep
			
			repeat with randRL2 in (items 1 thru 2 of myVinylKeep)
				repeat with randRL from 1 to (count randRL2)
					set currentExperiment to (item randRL of randRL2) as string
					set currentExperiment to (currentExperiment & (ASCII character 10)) as string
					set (item randRL of randRL2) to currentExperiment
				end repeat
			end repeat
			
			if (item 3 of myVinylKeep) is not {} then
				set myVinylKeep to ((item 3 of myVinylKeep) as string)
			else
				set myVinylKeep to ""
			end if
			
			if currentlisttype is "have" then
				set myVinylListContents to ((do shell script "cat " & quoted form of myVinylList) & myVinylKeep) as string
				set myListCount to (count (every paragraph of myVinylListContents))
				set myIMPTable to (table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
				repeat with myIMPFillLVar from 1 to myListCount
					common_placeZeros((data source of myIMPTable), myIMPFillLVar, myListCount)
				end repeat
				
				do shell script ("echo " & quoted form of myVinylListContents & " > " & quoted form of myVinylList)
				set myVinylListContents to refreshList_Contents_Catalog("", "", myVinylList, false, currentlisttype)
				common_totalCountText(currentlisttype, false, myVinylListCatalog)
			else
				set myVinylWantListContents to ((do shell script "cat " & quoted form of myVinylWantList) & myVinylKeep) as string
				set myListCount to (count (every paragraph of myVinylWantListContents))
				set myIMPTable to (table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
				repeat with myIMPFillLVar from 1 to myListCount
					common_placeZeros((data source of myIMPTable), myIMPFillLVar, myListCount)
				end repeat
				
				do shell script ("echo " & quoted form of myVinylWantListContents & " > " & quoted form of myVinylWantList)
				set myVinylWantListContents to refreshList_Contents_Catalog("", "", myVinylWantList, false, currentlisttype)
				common_totalCountText(currentlisttype, false, myVinylWantListCatalog)
			end if
		end if
	end if
end importLastPhase
on moveMyAlbum(albumListType)
	set destCat to common_findCatalogDupes("first", albumListType, releaseCatalog)
	set dir1 to (myAppSupportFolder & currentFolderType & "/" & releaseCatalog & "/")
	set dir2 to (myAppSupportFolder & "/")
	try
		do shell script "mv " & quoted form of (dir1 & "image.jpeg") & " " & quoted form of dir2
	end try
	do shell script "mv " & quoted form of dir1 & " " & quoted form of dir2
	
	set dir1 to (myAppSupportFolder & releaseCatalog & "/")
	set dir2 to (myAppSupportFolder & "." & destCat & "/")
	do shell script "mv " & quoted form of dir1 & " " & quoted form of dir2
	set dir1 to (myAppSupportFolder & "." & destCat & "/")
	set dir2 to (myAppSupportFolder & albumListType & "/")
	do shell script "mv " & quoted form of dir1 & " " & quoted form of dir2
	set dir1 to (myAppSupportFolder & albumListType & "/")
	do shell script "cd " & quoted form of dir1 & ";mv " & quoted form of ("." & destCat & "/") & " " & quoted form of (destCat & "/")
	try
		do shell script ("cd " & quoted form of myAppSupportFolder & ";mv image.jpeg " & quoted form of (albumListType & "/" & destCat & "/"))
	end try
end moveMyAlbum
on changeCase_lower(myCHString)
	return (do shell script " echo " & myCHString & " | tr '[:upper:]' '[:lower:]'")
end changeCase_lower
on updateLaunchLoading(myDoubleValue)
	set double value of control "greenBar" of window "launchLoading" to (myDoubleValue)
	set contents of text field "launchLoadingText1" of window "launchLoading" to ((localized string "misc_Loading") & "...")
	set contents of text field "launchLoadingText2" of window "launchLoading" to ""
end updateLaunchLoading

on updatePlaylistCat(albumOrigCatalog)
	try
		set myPlaylists to (do shell script ("ls " & quoted form of (myAppSupportFolder & "Playlists/" & currentlisttype & "/")))
		set myPlaylists to every paragraph of myPlaylists
		try
			repeat with bb from 1 to (count myPlaylists)
				set myPlaylistFile to (myAppSupportFolder & "Playlists/" & currentlisttype & "/" & (item bb of myPlaylists as string))
				set myPlaylistFileContents to (do shell script "cat " & quoted form of myPlaylistFile) as string
				set myPlaylistFileContents to snr(myPlaylistFileContents, ("::	.:.	:" & albumOrigCatalog), ("::	.:.	:" & releaseCatalog)) as string
				do shell script ("echo " & quoted form of myPlaylistFileContents & " > " & myPlaylistFile)
			end repeat
		end try
	end try
end updatePlaylistCat


on modifyTrack(myMainSearchItem, actionType, theValue, tableColumn, trackPos_old, trackTit_old)
	set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
	try
		set trackLISTstring to refreshTracks(myMainSearchItem, false)
	on error
		set trackLISTstring to "<--TRACKLIST--><--TRACKLIST-->"
	end try
	
	set searchTracks_s to ("<trackPosition>" & trackPos_old & "</trackPosition><trackTitle>" & trackTit_old & "</trackTitle>") as string
	if actionType is "editTrack" then
		set myTC to (name of tableColumn) as string
		
		if myTC is "trackPosition" then
			set searchTracks_r to ("<trackPosition>" & theValue & "</trackPosition><trackTitle>" & trackTit_old & "</trackTitle>") as string
		else if myTC is "trackTitle" then
			set searchTracks_r to ("<trackPosition>" & trackPos_old & "</trackPosition><trackTitle>" & theValue & "</trackTitle>") as string
		end if
	else if actionType is "deleteTrack" then
		set searchTracks_r to ("") as string
	end if
	set trackLISTstring to snr(trackLISTstring, searchTracks_s, searchTracks_r)
	
	set myWindow to (name of window 1) as string
	
	set detailsPrep to longDetailsPrep()
	if myWindow is not "updateAlbumWindow" then
		do shell script ("echo " & quoted form of detailsPrep & " > " & quoted form of (myCurrentListItemFile))
		try
			set myCurrentListItemFileContents to (do shell script "cat " & quoted form of myCurrentListItemFile) as string
		on error
			error number -128
		end try
		try
			set trackLISTstring to refreshTracks(myCurrentListItemFileContents, true)
		on error
			set trackLISTstring to "<--TRACKLIST--><--TRACKLIST-->"
		end try
	else
		do shell script ("echo " & quoted form of detailsPrep & " > " & quoted form of (updt_tempFile))
		try
			set updt_tempFileContents to (do shell script "cat " & quoted form of updt_tempFile) as string
		on error
			error number -128
		end try
		try
			set trackLISTstring to refreshTracks(updt_tempFileContents, true)
		on error
			set trackLISTstring to "<--TRACKLIST--><--TRACKLIST-->"
		end try
	end if
	set releaseCatalog to common_catalogFlip(releaseCatalog, "view")
	set trackChosen to false
end modifyTrack
---------------------------
---------------------------
-------END CUSTOM FUNCTIONS
---------------------------
---------------------------