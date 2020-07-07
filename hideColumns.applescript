-- hideColumns.applescript
-- myVinyl

--  Created by Leif Heflin on 5/9/10.
--  Copyright 2010 Leifertin. All rights reserved.

to hideColumnsMain(givenListType, visibleColumnsHave, visibleColumnsWant)
	set current tab view item of tab view 1 of view 1 of split view "mainSplitView" of window "mainList" to tab view item (givenListType & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList"
	set loopvar to 0
	if givenListType is "have" then
		copy visibleColumnsHave to myCurrentColumns
	else
		copy visibleColumnsWant to myCurrentColumns
	end if
	
	repeat with a in {"numColumn", "artistColumn", "titleColumn", "labelColumn", "catalogColumn", "countryColumn", "releasedateColumn", "formatColumn", "releaseIDColumn", "conditionColumn", "BPMColumn", "genreColumn", "styleColumn", "songPreferenceColumn", "keySignatureColumn", "commentsColumn", "energyRatingColumn"}
		set loopvar to (loopvar + 1)
		tell (view 1 of split view "topSplitView" of tab view item (givenListType & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
			if (item loopvar of myCurrentColumns) is "0" then
				set the_table to table view 1 of scroll view 1
				call method "setHidden:" of (table column a of the_table) with with parameter
			else
				set the_table to table view 1 of scroll view 1
				call method "setHidden:" of (table column a of the_table) without with parameter
			end if
		end tell
	end repeat
end hideColumnsMain
to hideColumnsPrefs(givenListType, visibleColumnsHave, visibleColumnsWant)
	if givenListType is "H" then
		copy visibleColumnsHave to myCurrentColumns
	else
		copy visibleColumnsWant to myCurrentColumns
	end if
	set myCurrentColumns to every character of myCurrentColumns
	set loopvar to 0
	repeat with hideLoop in {("visibleColumnNumber" & givenListType), ("visibleColumnArtist" & givenListType), ("visibleColumnTitle" & givenListType), ("visibleColumnLabel" & givenListType), ("visibleColumnCatalog" & givenListType), ("visibleColumnCountry" & givenListType), ("visibleColumnDate" & givenListType), ("visibleColumnFormat" & givenListType), ("visibleColumnReleaseID" & givenListType), ("visibleColumnCondition" & givenListType), ("visibleColumnBPM" & givenListType), ("visibleColumnGenre" & givenListType), ("visibleColumnStyle" & givenListType), ("visibleColumnSongPreference" & givenListType), ("visibleColumnKeySignature" & givenListType), ("visibleColumnComments" & givenListType), ("visibleColumnEnergyRating" & givenListType)}
		set loopvar to (loopvar + 1)
		tell tab view item givenListType of tab view 1 of window "prefsWindow"
			set state of button (hideLoop as string) to ((item loopvar of myCurrentColumns) as string)
		end tell
	end repeat
end hideColumnsPrefs
to hideColumnsSearchXML()
	set the_table to table view 1 of scroll view 1 of view 1 of split view 1 of window "searchXMLWindow"
	call method "setHidden:" of (table column "urli" of the_table) with with parameter
	call method "setHidden:" of (table column "summary" of the_table) without with parameter
end hideColumnsSearchXML