-- playlist.applescript
-- myVinyl

--  Created by Leif Heflin on 5/9/10.
--  Copyright 2010 Leifertin. All rights reserved.

global fromPlaylist

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

on exportToHTML(myPlaylist, myAppSupportFolder, appsup, currentlisttype, myVinylList, myVinylWantList)
	set currentFolderType to get_currentFolderType(currentlisttype)
	set pathToHTMLExportFolder to (appsup & "MyVinyl HTML/") as string
	set pathToHTMLExportHaveFolder to (pathToHTMLExportFolder & currentlisttype & "/")
	set pathToHTMLExportHaveImageFolder to (pathToHTMLExportFolder & currentlisttype & "/images/")
	set new_pathToHTMLExportFolder to (POSIX path of (choose folder with prompt "Export to..." default location the path to the desktop)) as string
	set new_pathToHTMLExportHaveFolder to (new_pathToHTMLExportFolder & currentlisttype & "/")
	set new_pathToHTMLExportHaveImageFolder to (new_pathToHTMLExportFolder & currentlisttype & "/images/")
	
	if myPlaylist is "Library" then
		if currentlisttype is "have" then
			set myPlaylistFile to myVinylList
		else if currentlisttype is "want" then
			set myPlaylistFile to myVinylWantList
		end if
	else
		set myPlaylistFile to (myAppSupportFolder & "Playlists/" & currentlisttype & "/" & myPlaylist & ".myvy")
	end if
	set myPlaylistFileContents to (do shell script ("cat " & quoted form of myPlaylistFile))
	set myPlaylistCatalog to every paragraph of myPlaylistFileContents
	
	repeat with a from 1 to (count myPlaylistCatalog)
		set item a of myPlaylistCatalog to item 2 of split((item a of myPlaylistCatalog), "::	.:.	:")
	end repeat
	
	set exportLimiter to (count myPlaylistCatalog)
	try
		do shell script ("rm -r " & quoted form of pathToHTMLExportFolder)
	end try
	do shell script ("mkdir " & quoted form of pathToHTMLExportFolder)
	do shell script ("cd " & quoted form of pathToHTMLExportFolder & ";mkdir " & currentlisttype)
	do shell script ("cd " & quoted form of pathToHTMLExportHaveFolder & ";mkdir images")
	set pageCount to truncate(((exportLimiter) / 20), 0) + 1
	
	--INDEX FILE
	set writeText to "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 TRANSITIONAL//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
<html>

	<head>
		<title> </title><meta http-equiv=\"refresh\" content=\"0;url=list_1.html\">
	</head>
	<body bgcolor=\"000000\">
	</body>
</html>"
	do shell script ("echo " & quoted form of writeText & " > " & quoted form of (pathToHTMLExportHaveFolder & "index.html"))
	try
		do shell script ("cp " & quoted form of (appsup & "HTML_BG.jpg") & " " & quoted form of (pathToHTMLExportHaveImageFolder & "HTML_BG.jpg"))
	end try
	set currentNum to 0
	display panel window "exportingProgress" attached to window "mainList"
	if currentlisttype is "want" then
		set totalHTMLHeader to snr((localized string "misc_WantTotal"), "500", ((exportLimiter) as string))
	else if currentlisttype is "have" then
		set totalHTMLHeader to snr((localized string "misc_HaveTotal"), "500", ((exportLimiter) as string))
	end if
	repeat with l from 1 to pageCount
		update_progress(l, pageCount, "exportingProgress")
		--LIST FILE
		set writeText to "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 TRANSITIONAL//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
<html>

	<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">
		<title>MyVinyl</title>
		<style>
		body
{
background-image:url('images/HTML_BG.jpg');
background-repeat:repeat;
background-position:right top;
}
a:link,a:visited {color:#999999; background-color:transparent}
a:hover,a:active {color:#666666; background-color:transparent}
		</style>
	</head>
	<body bgcolor=\"000000\"><font face=\"verdana\" color=\"ffffff\"><center><br><span width=\"90%\"><font size=\"6\">" & totalHTMLHeader & "</font></span><br><br>
<table border=0 cellspacing=5 cellpadding=10 width=90%>"
		repeat with i from 1 to 20
			set currentNum to (currentNum + 1)
			if currentNum is greater than exportLimiter then exit repeat
			tell (data source of table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
				set releaseArtist to (contents of data cell "artistColumn" of data row currentNum)
				set releaseAlbum to (contents of data cell "titleColumn" of data row currentNum)
				set releaseCatalog to (contents of data cell "catalogColumn" of data row currentNum)
				set releaseLABEL to (contents of data cell "labelColumn" of data row currentNum)
				set releaseCountry to (contents of data cell "countryColumn" of data row currentNum)
				set releaseDate to (contents of data cell "releaseDateColumn" of data row currentNum)
				set releaseFormat to (contents of data cell "formatColumn" of data row currentNum)
				set releaseID to (contents of data cell "releaseIDColumn" of data row currentNum)
				set releaseCondition to (contents of data cell "conditionColumn" of data row currentNum)
			end tell
			set writeText to (writeText & "
<tr>
<td valign=top width=180><a href=\"images/" & snr(releaseCatalog, "/", "....") & ".jpeg\"><img src=\"images/" & snr(releaseCatalog, "/", "....") & ".jpeg\" border=0 width=\"180\" height=\"180\"></a></td>
<td valign=top width=100%>
" & releaseArtist & " - " & releaseAlbum & "<br><br>
Label: " & releaseLABEL & "<br>
Catalog#: " & releaseCatalog & "<br>
Country: " & releaseCountry & "<br>
Date: " & releaseDate & "<br>")
			
			if releaseID is not "" then
				set writeText to writeText & "Discogs Release ID: <a href=\"http://www.discogs.com/release/" & releaseID & "\">" & releaseID & "</a><br>"
			end if
			if releaseCondition is not "" then
				set writeText to writeText & "Condition: " & releaseCondition & "<br>"
			end if
			
			set writeText to writeText & "Format: " & releaseFormat & "
</td>"
			
			-----
			try
				do shell script ("cp " & quoted form of (myAppSupportFolder & currentFolderType & "/" & snr(releaseCatalog, "/", "....") & "/image.jpeg") & " " & quoted form of (pathToHTMLExportHaveImageFolder & snr(releaseCatalog, "/", "....") & ".jpeg"))
			end try
		end repeat
		set writeText to writeText & "
</table>
<br><Br>
<span width=\"90%\">Navigation<br>"
		
		if l is not 1 then
			set writeText to writeText & "<a href=list_1.html>first</a>&nbsp;."
			set writeText to writeText & "&nbsp;<a href=list_" & (l - 1) & ".html>previous</a>&nbsp;."
		end if
		
		if l is not pageCount then
			set writeText to writeText & "&nbsp;<a href=list_" & (l + 1) & ".html>next</a>&nbsp;."
			set writeText to writeText & "&nbsp;<a href=list_" & pageCount & ".html>last</a>"
		end if
		set writeText to writeText & "</span>
<br><br><br>

</font>
	</body>
</html>"
		do shell script ("echo " & quoted form of writeText & " > " & quoted form of (pathToHTMLExportHaveFolder & "list_" & l & ".html"))
		set writeText to ""
	end repeat
	
	close panel window "exportingProgress"
	do shell script ("mv " & quoted form of (pathToHTMLExportFolder) & " " & quoted form of (new_pathToHTMLExportFolder))
end exportToHTML

on exportXLS_HTML(myPlaylist, appsup, currentlisttype, myVinylListCatalog, myVinylWantListCatalog, theHaveListDataSource, theWantListDataSource)
	if currentlisttype is "have" then
		if myPlaylist is "Library" then
			set exportAmount to (count myVinylListCatalog)
			set myDataSource to theHaveListDataSource
		else
			set exportAmount to (count myPlaylistCatalog)
			set myDataSource to data source of (table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
		end if
	else if currentlisttype is "want" then
		if myPlaylist is "Library" then
			set exportAmount to (count myVinylWantListCatalog)
			set myDataSource to theWantListDataSource
		else
			set exportAmount to (count myPlaylistCatalog)
			set myDataSource to data source of (table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
		end if
	end if
	if currentlisttype is "want" then
		set pathToExportedFile to snr((localized string "misc_WantTotal"), "500", ((exportAmount) as string))
	else if currentlisttype is "have" then
		set pathToExportedFile to snr((localized string "misc_HaveTotal"), "500", ((exportAmount) as string))
	end if
	set pathToExportedFile to (POSIX path of (choose file name default name (pathToExportedFile & "xls")))
	set myExportText to ("<html><head><meta http-equiv=\"Content-Type\" content=\"application/vnd.ms-excel;\" charset=\"utf-8\"></head><body><table border=\"1\">
<tr bgcolor=\"#eeeeee\"><td>Catalog#</td><td>Artist</td><td>Title</td><td>Label</td><td>Format</td><td>Rating</td><td>Released</td><td>release_id</td><td>Collection Folder</td><td>Collection Media Condition</td><td>Collection Sleeve Condition</td><td>Collection Notes</td></tr>")
	display panel window "exportingProgress" attached to window "mainList"
	
	repeat with currentNum from 1 to exportAmount
		update_progress(currentNum, exportAmount, "exportingProgress")
		set releaseArtist to (contents of data cell "artistColumn" of data row currentNum of myDataSource)
		set releaseAlbum to (contents of data cell "titleColumn" of data row currentNum of myDataSource)
		set releaseCatalog to (contents of data cell "catalogColumn" of data row currentNum of myDataSource)
		set releaseLABEL to (contents of data cell "labelColumn" of data row currentNum of myDataSource)
		set releaseCountry to (contents of data cell "countryColumn" of data row currentNum of myDataSource)
		set releaseDate to (contents of data cell "releaseDateColumn" of data row currentNum of myDataSource)
		set releaseFormat to (contents of data cell "formatColumn" of data row currentNum of myDataSource)
		set releaseID to (contents of data cell "releaseIDColumn" of data row currentNum of myDataSource)
		set releaseCondition to (contents of data cell "conditionColumn" of data row currentNum of myDataSource)
		set myExportText to (myExportText & "
<tr><td>" & releaseCatalog & "</td><td>" & releaseArtist & "</td><td>" & releaseAlbum & "</td><td>" & releaseLABEL & "</td><td>" & releaseFormat & "</td><td>None</td><td>" & releaseDate & "</td><td>" & releaseID & "</td><td>" & myPlaylist & "</td><td>" & releaseCondition & "</td><td>None</td><td>None</td></tr>")
	end repeat
	set myExportText to (myExportText & "</table></body></html>")
	do shell script ("echo " & quoted form of myExportText & " > " & quoted form of (pathToExportedFile))
	close panel window "exportingProgress"
end exportXLS_HTML

on exportXLSBinary(myPlaylist, appsup, currentlisttype, myVinylListCatalog, myVinylWantListCatalog, theHaveListDataSource, theWantListDataSource)
	if currentlisttype is "have" then
		if myPlaylist is "Library" then
			set exportAmount to (count myVinylListCatalog)
			set myDataSource to theHaveListDataSource
		else
			set exportAmount to (count myPlaylistCatalog)
			set myDataSource to data source of (table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
		end if
	else if currentlisttype is "want" then
		if myPlaylist is "Library" then
			set exportAmount to (count myVinylWantListCatalog)
			set myDataSource to theWantListDataSource
		else
			set exportAmount to (count myPlaylistCatalog)
			set myDataSource to data source of (table view 1 of scroll view 1 of view 1 of split view "topSplitView" of tab view item (currentlisttype & "Tab") of tab view 1 of view 1 of split view "mainSplitView" of window "mainList")
		end if
	end if
	if currentlisttype is "want" then
		set pathToExportedFile to snr((localized string "misc_WantTotal"), "500", ((exportAmount) as string))
	else if currentlisttype is "have" then
		set pathToExportedFile to snr((localized string "misc_HaveTotal"), "500", ((exportAmount) as string))
	end if
	copy pathToExportedFile to headerName
	set pathToExportedFile to (POSIX path of (choose file name default name (pathToExportedFile & "xls")))
	display panel window "exportingProgress" attached to window "mainList"
	
	set myExportText to ("#!/usr/bin/perl -w

use strict;
use Spreadsheet::WriteExcel;
my $workbook  = Spreadsheet::WriteExcel->new('simple.xls');
$workbook->compatibility_mode();
my $worksheet = $workbook->add_worksheet();
my $header1 = q{&C" & headerName & " (" & myPlaylist & ")};
$worksheet->set_header($header1);
$worksheet->set_column('A:A', 5);
$worksheet->set_column('B:B', 30);
$worksheet->set_column('C:C', 35);
$worksheet->set_column('D:D', 20);
$worksheet->set_column('E:E', 26);
$worksheet->set_column('F:F', 10);
$worksheet->set_column('G:G', 12);
$worksheet->set_column('H:H', 30);
$worksheet->set_column('I:I', 8);
$worksheet->set_column('J:J', 14);
")
	repeat with currentNum from 1 to exportAmount
		update_progress(currentNum, exportAmount, "exportingProgress")
		set releaseArtist to (contents of data cell "artistColumn" of data row currentNum of myDataSource)
		set releaseAlbum to (contents of data cell "titleColumn" of data row currentNum of myDataSource)
		set releaseCatalog to (contents of data cell "catalogColumn" of data row currentNum of myDataSource)
		set releaseLABEL to (contents of data cell "labelColumn" of data row currentNum of myDataSource)
		set releaseCountry to (contents of data cell "countryColumn" of data row currentNum of myDataSource)
		set releaseDate to (contents of data cell "releaseDateColumn" of data row currentNum of myDataSource)
		set releaseFormat to (contents of data cell "formatColumn" of data row currentNum of myDataSource)
		set releaseID to (contents of data cell "releaseIDColumn" of data row currentNum of myDataSource)
		set releaseCondition to (contents of data cell "conditionColumn" of data row currentNum of myDataSource)
		set myExportText to (myExportText & "$worksheet->write_string(" & (currentNum - 1) & ",0,q{" & currentNum & "});
")
		set i to 0
		repeat with excelColumns in {releaseArtist, releaseAlbum, releaseCatalog, releaseLABEL, releaseCountry, releaseDate, releaseFormat}
			set i to i + 1
			set myExportText to (myExportText & "$worksheet->write_string(" & (currentNum - 1) & "," & i & ",q{" & excelColumns & "});
")
		end repeat
		if releaseID is not "" then
			set myExportText to (myExportText & "$worksheet->write_url(" & (currentNum - 1) & ",9,q{http://www.discogs.com/release/" & releaseID & "},q{View on Discogs});
")
		else
			set myExportText to (myExportText & "$worksheet->write(" & (currentNum - 1) & ",9,'N/A');
")
		end if
		
		set myExportText to (myExportText & "$worksheet->write_string(" & (currentNum - 1) & ",8,q{" & releaseCondition & "});
")
	end repeat
	do shell script ("echo " & quoted form of myExportText & " > " & (quoted form of (appsup & "createBinaryXLS.temp.pl")))
	try
		do shell script ("cd " & appsup & ";perl createBinaryXLS.temp.pl")
		set myReturn to "good"
	on error number 2
		set myReturn to "error"
	end try
	close panel window "exportingProgress"
	if myReturn is "good" then
		do shell script ("cd " & appsup & ";mv simple.xls " & quoted form of pathToExportedFile)
	end if
	try
		do shell script ("cd " & appsup & ";mv createBinaryXLS.temp.pl ~/.Trash/")
	end try
	return myReturn
end exportXLSBinary

on placeZeros(myDataSource, a)
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
	
	if (count every data row of myDataSource) is less than 10 then
		set myTakeAmt to 5
	else if (count every data row of myDataSource) is less than 100 then
		set myTakeAmt to 4
	else if (count every data row of myDataSource) is less than 1000 then
		set myTakeAmt to 3
	else if (count every data row of myDataSource) is less than 10000 then
		set myTakeAmt to 2
	else if (count every data row of myDataSource) is less than 100000 then
		set myTakeAmt to 1
	end if
	
	set myCellWrite to every character of myCellWrite
	repeat with barI from 1 to myTakeAmt
		set myCellWrite to rest of myCellWrite
		---
	end repeat
	set myCellWrite to myCellWrite as string
	set contents of data cell "numColumn" of data row a of myDataSource to myCellWrite
end placeZeros

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

on catalogFlip(releaseCatalog, flipDirection)
	if flipDirection is "file" then
		set releaseCatalog to snr(releaseCatalog, "....", "..+")
		set releaseCatalog to snr(releaseCatalog, "/", "....")
		return releaseCatalog
	else if flipDirection is "view" then
		set releaseCatalog to snr(releaseCatalog, "....", "/")
		set releaseCatalog to snr(releaseCatalog, "..+", "....")
		return releaseCatalog
	else
		return "error, dude."
	end if
end catalogFlip

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

on get_currentFolderType(currentlisttype)
	if currentlisttype is "have" then
		set currentFolderType to "Collection"
	else if currentlisttype is "want" then
		set currentFolderType to "Wanted"
	end if
end get_currentFolderType