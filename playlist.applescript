-- playlist.applescript
-- myVinyl

--  Created by Leif Heflin on 5/9/10.
--  Copyright 2010 Leifertin. All rights reserved.

global fromPlaylist, currentItemNo, currentlisttype, myVinylListCatalog, myVinylWantListCatalog, myPlaylistFile, myPlaylistDataSource, appsup

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
on initializeMe_SM()
	set theDownloadGo to false
	set appsup to ((POSIX path of (path to me)) & ("Contents/Resources/")) as string
	set p7String to (appsup & "7za")
	set pathTOCURLfile to (appsup & "dp.pl")
	set pathTOCURLfileZIP to (appsup & "dpZIP.pl")
	set pathTOCURLedfile to (appsup & "CURLfile.yah")
	set pathTOHURLfile to (appsup & "rl.pl")
end initializeMe_SM

--LOAD
on loadPlaylists(myLastAction, myAppSupportFolder, currentlisttype)
	set playlistsExist to true
	try
		set myPlaylists to (do shell script ("ls " & quoted form of (myAppSupportFolder & "Playlists/" & currentlisttype & "/")))
	on error number 1
		set playlistsExist to false
	end try
	if playlistsExist then
		set myPlaylists to every paragraph of myPlaylists
		--choose from list result
		copy myPlaylists to newPlaylists
		set newPlaylists to {"Library"} & newPlaylists
		if (count newPlaylists) is greater than 1 then
			set visible of button "moveToPlaylist" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to true
			set visible of popup button "moveToPlaylistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to true
			repeat with a from 1 to (count newPlaylists)
				set playlistName to (item a of newPlaylists as string)
				
				set playlistName_t to snr(playlistName, ".myvy", "")
				if (playlistName is equal to playlistName_t) then
					--removePlaylist(myAppSupportFolder, currentlisttype)
				else
					copy playlistName_t to playlistName
					tell menu of popup button "playlistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
						if a is 1 then
							delete every menu item
						end if
						make new menu item at the end of menu items with properties {title:(playlistName as Unicode text)}
					end tell
				end if
			end repeat
			repeat with a from 1 to (count newPlaylists)
				set playlistName to (item a of newPlaylists as string)
				set playlistName_t to snr(playlistName, ".myvy", "")
				if (playlistName is equal to playlistName_t) then
					--removePlaylist(myAppSupportFolder, currentlisttype)
				else
					copy playlistName_t to playlistName
					tell menu of popup button "moveToPlaylistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
						if a is 1 then
							delete every menu item
						else
							make new menu item at the end of menu items with properties {title:(playlistName as Unicode text)}
						end if
					end tell
				end if
			end repeat
		else
			set visible of button "moveToPlaylist" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to false
			set visible of popup button "moveToPlaylistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to false
		end if
		
		if myLastAction is "delete" then
			set (title of popup button "playlistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList") to "Library"
		else if myLastAction is "create" then
			set (title of popup button "playlistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList") to fromPlaylist
		end if
		if (title of popup button "playlistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList") is "Library" then
			set enabled of button "deletePlaylist" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to false
		end if
	end if
end loadPlaylists

--SHOW
on displayPlaylist(myPlaylist, myAppSupportFolder, currentlisttype, theHaveListDataSource, theWantListDataSource)
	set currentFolderType to get_currentFolderType(currentlisttype)
	set myPlaylistCatalog to {}
	if myPlaylist is "Library" then
		set enabled of button "updateEntry" of window "mainList" to true
		set enabled of button "addAlbumButton" of window "mainList" to true
		if currentlisttype is "have" then
			set data source of (table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList") to theHaveListDataSource
		else if currentlisttype is "want" then
			set data source of (table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList") to theWantListDataSource
		end if
	else
		set enabled of button "addAlbumButton" of window "mainList" to false
		set enabled of button "updateEntry" of window "mainList" to false
		set myPlaylistFile to (myAppSupportFolder & "Playlists/" & currentlisttype & "/" & myPlaylist & ".myvy")
		
		set myPlaylistFileContents to (do shell script ("cat " & quoted form of myPlaylistFile))
		if myPlaylistFileContents is not "" then
			set myPlaylistCatalog to every paragraph of myPlaylistFileContents
			set myPlaylistCatalog to common_cleanMyList(myPlaylistCatalog, {""})
			repeat with a from 1 to (count myPlaylistCatalog)
				set item a of myPlaylistCatalog to item 2 of split((item a of myPlaylistCatalog), "::	.:.	:")
			end repeat
			
			set myPlaylistArtist to {}
			set myPlaylistAlbum to {}
			set myPlaylistLabel to {}
			set myPlaylistCountry to {}
			set myPlaylistDate to {}
			set myPlaylistFormat to {}
			set myPlaylistReleaseID to {}
			set myPlaylistCondition to {}
			
			set myPlaylistBPM to {}
			set myPlaylistGenre to {}
			set myPlaylistStyle to {}
			set myPlaylistSongPreference to {}
			set myPlaylistKeySignature to {}
			set myPlaylistComments to {}
			set myPlaylistEnergyRating to {}
			
			set myMissingPlaylistItems to {}
			repeat with a from 1 to (count myPlaylistCatalog)
				
				set myCurrentListItemFile to (myAppSupportFolder & currentFolderType & "/" & (item a of myPlaylistCatalog) & "/details.txt") as string
				try
					set myCurrentListItemFileContents to do shell script "cat " & quoted form of myCurrentListItemFile
				on error
					--removeFromPlaylist(, myPlaylistFile, currentlisttype)
					set myMissingPlaylistItems to myMissingPlaylistItems & {a}
					set item a of myPlaylistCatalog to ""
					set myCurrentListItemFileContents to ""
				end try
				if myCurrentListItemFileContents is not "" then
					set releaseArtist to item 2 of split(myCurrentListItemFileContents, "<--NAME-->")
					try
						set releaseAlbum to item 2 of split(releaseArtist, " - ")
					on error
						set releaseAlbum to ""
					end try
					set myPlaylistAlbum to myPlaylistAlbum & {releaseAlbum}
					
					try
						set releaseArtist to item 1 of split(releaseArtist, " - ")
					on error
						set releaseArtist to ""
					end try
					set myPlaylistArtist to myPlaylistArtist & {releaseArtist}
					
					try
						set releaseLABEL to item 2 of split(myCurrentListItemFileContents, ("<--LABEL-->"))
					on error
						set releaseLABEL to ""
					end try
					set myPlaylistLabel to myPlaylistLabel & {releaseLABEL}
					
					try
						set releaseCountry to item 2 of split(myCurrentListItemFileContents, ("<--COUNTRY-->"))
					on error
						set releaseCountry to ""
					end try
					set myPlaylistCountry to myPlaylistCountry & {releaseCountry}
					
					try
						set releaseDate to item 2 of split(myCurrentListItemFileContents, ("<--RELEASED-->"))
					on error
						set releaseDate to ""
					end try
					set myPlaylistDate to myPlaylistDate & {releaseDate}
					
					try
						set releaseFormat to item 2 of split(myCurrentListItemFileContents, ("<--FORMAT-->"))
					on error
						set releaseFormat to ""
					end try
					set myPlaylistFormat to myPlaylistFormat & {releaseFormat}
					
					try
						set releaseCondition to item 2 of split(myCurrentListItemFileContents, ("<--CONDITION-->"))
					on error
						set releaseCondition to ""
					end try
					set myPlaylistCondition to myPlaylistCondition & {releaseCondition}
					
					try
						set releaseID to item 2 of split(myCurrentListItemFileContents, ("<--RELEASEID-->"))
					on error
						set releaseID to ""
					end try
					set myPlaylistReleaseID to myPlaylistReleaseID & {releaseID}
					
					
					
					--((4))
					--
					--
					try
						set myBPM to item 2 of split(myCurrentListItemFileContents, ("<--BPM_COUNT-->"))
					on error
						set myBPM to ""
					end try
					set myPlaylistBPM to myPlaylistBPM & {myBPM}
					--
					--
					try
						set myGenre to item 2 of split(myCurrentListItemFileContents, ("<--ALB_GENRE-->"))
					on error
						set myGenre to ""
					end try
					set myPlaylistGenre to myPlaylistGenre & {myGenre}
					--
					--
					try
						set myStyle to item 2 of split(myCurrentListItemFileContents, ("<--ALB_STYLE-->"))
					on error
						set myStyle to ""
					end try
					set myPlaylistStyle to myPlaylistStyle & {myStyle}
					--
					--
					try
						set mySongPreference to item 2 of split(myCurrentListItemFileContents, ("<--SNG_PREFERENCE-->"))
					on error
						set mySongPreference to ""
					end try
					set myPlaylistSongPreference to myPlaylistSongPreference & {mySongPreference}
					--
					--
					try
						set myKeySignature to item 2 of split(myCurrentListItemFileContents, ("<--ALB_KEY_SIGNATURE-->"))
					on error
						set myKeySignature to ""
					end try
					set myPlaylistKeySignature to myPlaylistKeySignature & {myKeySignature}
					--
					--
					try
						set myComments to item 2 of split(myCurrentListItemFileContents, ("<--ALB_COMMENTS-->"))
					on error
						set myComments to ""
					end try
					set myPlaylistComments to myPlaylistComments & {myComments}
					--
					--
					try
						set myEnergyRating to item 2 of split(myCurrentListItemFileContents, ("<--ALB_ENRGYRATING-->"))
					on error
						set myEnergyRating to ""
					end try
					set myPlaylistEnergyRating to myPlaylistEnergyRating & {myEnergyRating}
					--
					
				end if
			end repeat
		end if
		set myPlaylistCatalog to common_cleanMyList(myPlaylistCatalog, {""})
		
		if currentlisttype is "have" then
			try
				delete data source havePlaylistDataSource
			end try
			--try
			-------CREATE DATA SOURCE
			set havePlaylistDataSource to make new data source at end of data sources
			if myPlaylistFileContents is not "" then
				tell havePlaylistDataSource
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
					
					make new data column at end of data columns with properties {name:"BPMColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"genreColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"styleColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"songPreferenceColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"keySignatureColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"commentsColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"energyRatingColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				end tell
				repeat with a from 1 to (count myPlaylistCatalog)
					tell havePlaylistDataSource
						make new data row at end of data rows
					end tell
				end repeat
				---------FILL DATA SOURCE
				
				repeat with a from 1 to (count myPlaylistCatalog)
					common_placeZeros(havePlaylistDataSource, a, (count myPlaylistCatalog))
					set (item a of myPlaylistCatalog) to snr((item a of myPlaylistCatalog as string), "....", "/")
					set (item a of myPlaylistCatalog) to snr((item a of myPlaylistCatalog as string), "..+", "....")
					tell havePlaylistDataSource
						set contents of data cell "artistColumn" of data row a to (item a of myPlaylistArtist)
						set contents of data cell "titleColumn" of data row a to (item a of myPlaylistAlbum)
						set contents of data cell "catalogColumn" of data row a to (item a of myPlaylistCatalog)
						set contents of data cell "labelColumn" of data row a to (item a of myPlaylistLabel)
						set contents of data cell "countryColumn" of data row a to (item a of myPlaylistCountry)
						set contents of data cell "releasedateColumn" of data row a to (item a of myPlaylistDate)
						set contents of data cell "formatColumn" of data row a to (item a of myPlaylistFormat)
						set contents of data cell "releaseIDColumn" of data row a to (item a of myPlaylistReleaseID)
						set contents of data cell "conditionColumn" of data row a to (item a of myPlaylistCondition)
						
						set contents of data cell "BPMColumn" of data row a to (item a of myPlaylistBPM)
						set contents of data cell "genreColumn" of data row a to (item a of myPlaylistGenre)
						set contents of data cell "styleColumn" of data row a to (item a of myPlaylistStyle)
						set contents of data cell "songPreferenceColumn" of data row a to (item a of myPlaylistSongPreference)
						set contents of data cell "keySignatureColumn" of data row a to (item a of myPlaylistKeySignature)
						set contents of data cell "commentsColumn" of data row a to (item a of myPlaylistComments)
						set contents of data cell "energyRatingColumn" of data row a to (item a of myPlaylistEnergyRating)
					end tell
				end repeat
			end if
			set data source of (table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList") to havePlaylistDataSource
			set myPlaylistDataSource to havePlaylistDataSource
			--end try
		else
			try
				delete data source wantPlaylistDataSource
			end try
			--try
			
			-------CREATE DATA SOURCE
			set wantPlaylistDataSource to make new data source at end of data sources
			if myPlaylistFileContents is not "" then
				tell wantPlaylistDataSource
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
					
					make new data column at end of data columns with properties {name:"BPMColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"genreColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"styleColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"songPreferenceColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"keySignatureColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"commentsColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
					make new data column at end of data columns with properties {name:"energyRatingColumn", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
				end tell
				repeat with a from 1 to (count myPlaylistCatalog)
					tell wantPlaylistDataSource
						make new data row at end of data rows
					end tell
				end repeat
				---------FILL DATA SOURCE
				repeat with a from 1 to (count myPlaylistCatalog)
					common_placeZeros(wantPlaylistDataSource, a, (count myPlaylistCatalog))
					set (item a of myPlaylistCatalog) to snr((item a of myPlaylistCatalog as string), "....", "/")
					set (item a of myPlaylistCatalog) to snr((item a of myPlaylistCatalog as string), "..+", "....")
					tell wantPlaylistDataSource
						set contents of data cell "artistColumn" of data row a to (item a of myPlaylistArtist)
						set contents of data cell "titleColumn" of data row a to (item a of myPlaylistAlbum)
						set contents of data cell "catalogColumn" of data row a to (item a of myPlaylistCatalog)
						set contents of data cell "labelColumn" of data row a to (item a of myPlaylistLabel)
						set contents of data cell "countryColumn" of data row a to (item a of myPlaylistCountry)
						set contents of data cell "releasedateColumn" of data row a to (item a of myPlaylistDate)
						set contents of data cell "formatColumn" of data row a to (item a of myPlaylistFormat)
						set contents of data cell "releaseIDColumn" of data row a to (item a of myPlaylistReleaseID)
						set contents of data cell "conditionColumn" of data row a to (item a of myPlaylistCondition)
						
						set contents of data cell "BPMColumn" of data row a to (item a of myPlaylistBPM)
						set contents of data cell "genreColumn" of data row a to (item a of myPlaylistGenre)
						set contents of data cell "styleColumn" of data row a to (item a of myPlaylistStyle)
						set contents of data cell "songPreferenceColumn" of data row a to (item a of myPlaylistSongPreference)
						set contents of data cell "keySignatureColumn" of data row a to (item a of myPlaylistKeySignature)
						set contents of data cell "commentsColumn" of data row a to (item a of myPlaylistComments)
						set contents of data cell "energyRatingColumn" of data row a to (item a of myPlaylistEnergyRating)
						
					end tell
				end repeat
			end if
			set data source of (table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList") to wantPlaylistDataSource
			set myPlaylistDataSource to wantPlaylistDataSource
			--end try
		end if
		
		set myPlaylistCatalog_c to count myPlaylistCatalog
		set myPlaylistFileContents_temp to {}
		repeat with myMissingPlaylistItemsLoop from 1 to myPlaylistCatalog_c
			set myCurrentZNUM to common_getZeros(myMissingPlaylistItemsLoop, myPlaylistCatalog_c)
			set myCurrentAdd to ((myCurrentZNUM & "::	.:.	:") & (item myMissingPlaylistItemsLoop of myPlaylistCatalog)) as string
			if myMissingPlaylistItemsLoop is less than myPlaylistCatalog_c then
				set myPlaylistFileContents_temp to myPlaylistFileContents_temp & {myCurrentAdd & (ASCII character 10)}
			else
				set myPlaylistFileContents_temp to myPlaylistFileContents_temp & {myCurrentAdd}
			end if
		end repeat
		set myPlaylistFileContents to (myPlaylistFileContents_temp as string)
		
		--WRITE MYPLAYLISTFILECONTENTS TO FILE!!!!
		do shell script ("echo " & quoted form of myPlaylistFileContents & " > " & quoted form of myPlaylistFile)
		
		
	end if
end displayPlaylist

--CREATE
on newPlaylist(myAppSupportFolder, currentlisttype)
	close panel window "newPlaylist"
	set playlistName to contents of text field "playlistTitle" of window "newPlaylist"
	set playlistName to snr(playlistName, "/", "")
	set playlistName to snr(playlistName, "~", "-")
	
	try
		do shell script "mkdir " & quoted form of (myAppSupportFolder & "Playlists/")
	end try
	try
		do shell script "mkdir " & quoted form of (myAppSupportFolder & "Playlists/have/")
	end try
	try
		do shell script "mkdir " & quoted form of (myAppSupportFolder & "Playlists/want/")
	end try
	
	set playlistName to findPlaylistDupes(playlistName, myAppSupportFolder, currentlisttype)
	
	tell menu of popup button "playlistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
		make new menu item at the end of menu items with properties {title:(playlistName as Unicode text)}
	end tell
	tell menu of popup button "moveToPlaylistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
		make new menu item at the end of menu items with properties {title:(playlistName as Unicode text)}
	end tell
	set visible of popup button "moveToPlaylistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to true
	set fromPlaylist to (title of popup button "playlistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
	set toPlaylist to (title of popup button "moveToPlaylistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
	if fromPlaylist is equal to toPlaylist then
		set visible of button "moveToPlaylist" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to false
	else
		set visible of button "moveToPlaylist" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to true
	end if
	loadPlaylists("create", myAppSupportFolder, currentlisttype)
end newPlaylist

--REMOVE ITEM
on removeFromPlaylist(releaseCatalog, myPlaylistFile, currentlisttype)
	set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
	set myPlaylistFileContents to (do shell script ("cat " & quoted form of myPlaylistFile))
	
	set myPlaylistCatalog to every paragraph of myPlaylistFileContents
	set myPlaylistCatalog to common_cleanMyList(myPlaylistCatalog, {""})
	repeat with rmLoop from 1 to count myPlaylistCatalog
		set (item rmLoop of myPlaylistCatalog) to (item 2 of split((item rmLoop of myPlaylistCatalog), "::	.:.	:"))
	end repeat
	
	
	set myDS to (data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
	
	set releaseCatalog to common_catalogFlip(releaseCatalog, "view")
	repeat with aar from 1 to (count myPlaylistCatalog)
		if (contents of data cell "catalogColumn" of data row (aar) of myDS is common_catalogFlip(releaseCatalog, "view")) then
			set aarString to common_getZeros(aar, (count myPlaylistCatalog))
			set sp_Temp to (aarString & "::	.:.	:" & releaseCatalog) as string
			
			set myPlaylistFileContents to split(myPlaylistFileContents, sp_Temp) as string
			delete data row aar of myDS
			exit repeat
		end if
	end repeat
	
	set myPlaylistDataSource to data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
	
	set myPlaylistCatalog to every paragraph of myPlaylistFileContents
	set myPlaylistCatalog to common_cleanMyList(myPlaylistCatalog, {""})
	set myPlaylistCatalog to common_alphabetize(myPlaylistCatalog)
	repeat with iVar from 1 to ((count myPlaylistCatalog) - 1)
		set item iVar of myPlaylistCatalog to ((item iVar of myPlaylistCatalog) & "
")
	end repeat
	
	
	copy myPlaylistCatalog to myPlaylistFileContents
	set myPlaylistFileContents to myPlaylistFileContents as string
	do shell script ("echo " & quoted form of myPlaylistFileContents & " > " & quoted form of myPlaylistFile)
	set myPlaylistCatalog to every paragraph of myPlaylistFileContents
	set myPlaylistCatalog to common_cleanMyList(myPlaylistCatalog, {""})
	repeat with rmLoop from 1 to count myPlaylistCatalog
		set (item rmLoop of myPlaylistCatalog) to (item 2 of split((item rmLoop of myPlaylistCatalog), "::	.:.	:"))
	end repeat
	set myPlaylistFileContents to renew_myListContents("", "", myPlaylistFile, false)
	
	repeat with a from 1 to (count myPlaylistCatalog)
		try
			common_placeZeros(myPlaylistDataSource, a, (count myPlaylistCatalog))
		on error (-1719)
			exit repeat
		end try
	end repeat
	set releaseCatalog to common_catalogFlip(releaseCatalog, "view")
end removeFromPlaylist

--REMOVE PLAYLIST
on removePlaylist(myAppSupportFolder, currentlisttype)
	set playlistName to (title of popup button "playlistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
	try
		do shell script ("rm " & quoted form of (myAppSupportFolder & "Playlists/" & currentlisttype & "/" & playlistName & ".myvy"))
	on error
		try
			do shell script ("rm " & quoted form of (myAppSupportFolder & "Playlists/" & currentlisttype & "/" & playlistName))
		end try
	end try
end removePlaylist

--MOVE PLAYLIST ITEM
on movePlaylistItem(myAppSupportFolder, currentlisttype, releaseCatalog, myVinylListCatalog, myVinylWantListCatalog)
	set fromPlaylist to (title of popup button "playlistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
	set toPlaylist to (title of popup button "moveToPlaylistMenu" of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
	set toPlaylistFile to (myAppSupportFolder & "Playlists/" & currentlisttype & "/" & toPlaylist & ".myvy") as string
	set toPlaylistFileContents to do shell script ("cat " & quoted form of toPlaylistFile)
	set releaseCatalog to common_catalogFlip(releaseCatalog, "file")
	--display dialog result
	set toPlaylistFileContents to renew_myListContents(toPlaylistFileContents, releaseCatalog, toPlaylistFile, false)
	--display dialog ""default answer result
	set mywriteString to ((ASCII character 10) & currentItemNo & "::	.:.	:" & releaseCatalog) as string
	set mywriteString to (toPlaylistFileContents & mywriteString)
	do shell script ("echo " & quoted form of mywriteString & " > " & quoted form of toPlaylistFile)
	
	set releaseCatalog to common_catalogFlip(releaseCatalog, "view")
	
end movePlaylistItem

on findPlaylistDupes(getSelected, myAppSupportFolder, currentlisttype)
	set anInfinite to 0
	set myPlaylists to {"Library.myvy"} & (every paragraph of (do shell script ("ls " & quoted form of (myAppSupportFolder & "Playlists/" & currentlisttype & "/"))))
	repeat
		set myCommonPlaylists to 0
		repeat with loopy from 1 to (count myPlaylists)
			set currPlaylist to split((item loopy of myPlaylists as string), ".myvy") as string
			if currPlaylist is equal to getSelected then
				set myCommonPlaylists to (myCommonPlaylists + 1)
				exit repeat
			end if
		end repeat
		
		if myCommonPlaylists is greater than 0 then
			set anInfinite to (anInfinite + 1)
			set getSelected to (item 1 of split(getSelected, (" (~"))) as string
			set getSelected to (getSelected & (" (~" & (anInfinite) & "~)")) as string
		else
			do shell script (("cd " & quoted form of (myAppSupportFolder & "Playlists/" & currentlisttype & "/") & ";echo > " & quoted form of (myAppSupportFolder & "Playlists/" & currentlisttype & "/" & getSelected & ".myvy")))
			exit repeat
		end if
	end repeat
	return getSelected
end findPlaylistDupes

on common_placeZeros(myDataSource, a, endVal)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to placeZeros(myDataSource, a, endVal)
end common_placeZeros

on get_currentFolderType(currentlisttype)
	if currentlisttype is "have" then
		set currentFolderType to "Collection"
	else if currentlisttype is "want" then
		set currentFolderType to "Wanted"
	end if
end get_currentFolderType

on common_catalogFlip(tmp_releaseCatalog, flipDirection)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to catalogFlip(tmp_releaseCatalog, flipDirection)
end common_catalogFlip

on common_getZeros(a, endVal)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to getZeros(a, endVal)
end common_getZeros

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

on common_cleanMyList(theList, itemsToDelete)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to cleanMyList(theList, itemsToDelete)
end common_cleanMyList

on get_myPlaylist()
	tell (view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
		set myPlaylist to (the title of popup button "playlistMenu")
	end tell
	return myPlaylist
end get_myPlaylist

on common_alphabetize(the_list)
	set otherScript to useOtherScript("commonFunctions")
	tell otherScript to alphabetize(the_list)
end common_alphabetize

on useOtherScript(scriptNameID)
	initializeMe_SM()
	tell me
		set otherScript to POSIX file ((appsup & "Scripts/" & scriptNameID & ".scpt") as string)
		--set otherScript to ((path for script scriptNameID) as string)
	end tell
	set otherScript to load script (otherScript)
	return otherScript
end useOtherScript


on clicked theObject
	if the name of theObject is "cancelCreatePlaylist" then
		close panel window "newPlaylist"
	end if
end clicked