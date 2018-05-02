#! /usr/bin/osascript

(*
-- Copyright (C) 2011  Nik Friedman TeBockhorst nik@inik.net
-- Based on work copyright (C) 2010  Jason Kunesh jason@fuzzymath.com

-- 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>

-- v0. works but includes http:// as a base node *duh*
-- v1. removes http:// baseline, improves performance
-- v2. is a minor re-write
-- v3. removes notion of folder vs. uri shapes
-- prompt user to select sitemap.xml file

-- v6. Removed check for file type XML
-- v7. Applied GPL license
-- v8. Major update, fork of original:

* Changed name to "Omnigraffle Sitemap Generator"

* Converted code to plain text (.applescript)

* Added !# so it will run from terminal

* Created "on run" handler to simplify code navigation

* Changed parent identification to work through full linked URLs rather than object name

* Fixed link creation so that objects hyperlink to the actual URL

* Changed link creation so that it properly handles non-http protocol handlers (https://, telnet:, etc.)

* Added option to ignore certain page names so that index/default pages may be optionally excluded, defaults provided by defaultPageNamesList property

* Added option to download each page's text into the OmniGraffle comments field, controlled by global property "getPageText" -- nice for searching

* Made new document use a defined template, controlled by property documentTemplate, and style objects accordingly
*)

-- The default template and style to use for the sitemap, set to "Blank" for none. Must match the name of one of OG's templates exactly, including case.
property documentTemplate : "Hierarchical"

-- set this to true to download web page content into the Notes field for each page object
property getPageText : true

-- These are the automatically entered default page names when prompted
property defaultPageNamesList : {"index.html, index.php, default.html, index.htm, default.htm default.asp, default.aspx, index.jsp, default.jsp"}


-- RUN HANDLER
on run
	set defaultPageNames to {}
	set sitemapFile to choose file with prompt "Please select a sitemap.xml file. I don't test for file type, so make sure it's a text XML file."
	set {text returned:textReturned, button returned:buttonReturned} to display dialog "Are there any page names you want to omit from the sitemap? Enter a comma-separated list of any page names that should be suppressed." with title "Omit Pages Named" default answer defaultPageNamesList buttons {"Cancel", "Include All", "OK"} default button 3
	if buttonReturned is not in {"None", "Cancel"} then
		set oldDelims to AppleScript's text item delimiters
		set text item delimiters to ","
		
		set defaultPageNames to text items of textReturned
		
		
		set AppleScript's text item delimiters to oldDelims
		
		
	end if
	
	set sitemapXML to open for access sitemapFile
	
	set uriList to {}
	
	set isDone to false
	
	-- got to be a better way here.
	repeat until isDone -- end of sitemapXML
		try
			-- read up to a tag, and see what the tag is
			read sitemapXML before "<"
			set theTag to read sitemapXML before ">"
			
			-- if it is a <loc> tag, then read the contents
			if theTag is "loc" then
				-- jumps to next < start of tag
				-- Edit by Nik 2011-06-01: Save original URL, parse text later
				set theURI to read sitemapXML before "<"
				copy theURI to the end of uriList
			end if
			
		on error errStr number errorNumber
			-- you'll want the next line if you want to see error messages
			-- display dialog errorNumber
			set isDone to true
		end try
	end repeat
	close access sitemapXML
	
	
	makeNewSitemap()
	
	
	set nodeList to {}
	
	repeat with rawURI in uriList
		
		
		-- manage protocol handler		
		if (offset of "://" in rawURI) > 0 then
			set currentURI to text ((offset of "://" in rawURI) + 3) through (length of rawURI) of rawURI
			set uriProtocol to text 1 through ((offset of "://" in rawURI) + 2) of rawURI
		else if (offset of ":" in rawURI) > 0 then
			set currentURI to text ((offset of ":" in rawURI) + 1) through (length of rawURI) of rawURI
			set uriProtocol to text 1 through ((offset of ":" in rawURI) + 1) of rawURI
		else
			set currentURI to rawURI
			set uriProtocol to ""
		end if
		
		-- Create tree
		
		if last character of currentURI is "/" then
			set currentURI to text 1 thru ((length of currentURI) - 1) of currentURI
		end if
		
		set savedDelimiters to AppleScript's text item delimiters
		set text item delimiters to "/"
		
		set currentItems to text items of currentURI
		repeat with i from 1 to count of items in currentItems
			
			ignoring white space
				set isDefaultPage to item i of currentItems is in defaultPageNames
			end ignoring
			if isDefaultPage is false then
				set cItem to uriProtocol & (items 1 through i of currentItems as string)
				
				-- find the matching shape within the list, and make it the node parent node 				
				if cItem is in nodeList then
					-- nullop
				else
					-- add this item to the list of nodes
					copy contents of cItem to the end of nodeList
					-- create this shape
					set childNode to makeShape(cItem)
					if i is greater than 1 then
						-- this must be a child node, so we must find the previous node's shape
						set parentText to uriProtocol & (items 1 through (i - 1) of currentItems as string)
						set parentNode to findShape(parentText)
						drawConnectingLine(parentNode, childNode)
					end if
					
				end if
			end if
		end repeat
	end repeat
	
	set text item delimiters to savedDelimiters
	
	cleanupSitemap()
end run

-- function that draws each type of box
on makeShape(aURL)
	tell application "OmniGraffle Professional 5"
		tell canvas of front window
			set sText to last text item of aURL
			set sNotes to ""
			if getPageText is true then
				try
					do shell script "curl -L --max-time 1 \"" & aURL & "\" | textutil -convert txt -timeout 1 -stdin -stdout"
					set sNotes to result
					
				end try
			end if
			
			return make new shape with properties {text:sText, url:aURL, notes:sNotes, fill:solid fill, text placement:center, draws shadow:true, side padding:5, shadow color:{0, 0, 0}, stroke color:{0, 0, 0}, thickness:1.0, autosizing:full, vertical padding:5, fill color:{65535, 65535, 65535}, shadow fuzziness:8.0, draws stroke:true}
		end tell
	end tell
	
	
end makeShape

on findShape(aURL)
	tell application "OmniGraffle Professional 5"
		set matchingShapes to shapes of canvas of front window whose url is aURL
		if (count of matchingShapes) is greater than 0 then
			return item 1 of matchingShapes
		end if
	end tell
end findShape

on drawConnectingLine(aSource, aDestination)
	tell application "OmniGraffle Professional 5"
		tell aSource
			set aLine to connect to aDestination
		end tell
		set tail magnet of aLine to 1
	end tell
end drawConnectingLine

on makeNewSitemap()
	tell application "OmniGraffle Professional 5"
		activate
		make new document with properties {template:documentTemplate}
		tell layout info of canvas of front window
			set type to left to right
			-- set children to back to front ordering
		end tell
	end tell
end makeNewSitemap

on cleanupSitemap()
	
	-- Style all objects using UI scripting
	tell application "System Events"
		tell (first application process whose name is "Omnigraffle Professional")
			set frontmost to true
			click menu item "Select All" of menu "Edit" of menu bar 1
			click menu item "Restyle Selected Objects" of menu "Format" of menu bar 1
		end tell
	end tell
	
	tell application "OmniGraffle Professional 5"
		
		tell canvas of front window
			layout
			page adjust
		end tell
		
	end tell
end cleanupSitemap

