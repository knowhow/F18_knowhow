/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fmk.ch"

function TDesktopNew()

local oObj

oObj:=TDesktop():new()

oObj:nRowLen:=MAXROWS()
oObj:nColLen:=MAXCOLS()

oObj:cColTitle := "GR+/N"
oObj:cColBorder:= "GR+/N"
oObj:cColFont := "W/N  ,R/BG ,,,B/W"
	
return oObj



#include "hbclass.ch"

CREATE CLASS TDesktop
  
  EXPORTED:
  VAR cColShema

  VAR cColTitle
  VAR cColBorder 
  VAR cColFont
	

  // tekuce koordinate
  VAR nRow
  VAR nCol
  VAR nRowLen
  VAR nColLen
  
  method getRow
  method getCol
  method showLine
  method setColors
  method showSezona
  method showMainScreen
  
END CLASS

*void TDesktop::getRow()
method getRow()
return ::nRow


*void TDesktop::getCol()
method getCol()
return ::nCol



*void TDesktop::showLine(string cTekst, string cRow)
method showLine(cTekst,cRow)
LOCAL nCol

if cTekst<>NIL
 if Len(cTekst)>80
   nCol:=0
 else
   nCol:=INT((MAXCOLS()-LEN(cTekst))/2)
 endif
 @ nRow,0 SAY REPLICATE(Chr(32), MAXCOLS())
 @ nRow,nCol SAY cTekst
endif

RETURN


*void TDesktop::SetColors(string cIzbor)
method setColors(cIzbor)
 
IF ISCOLOR()
   DO CASE
     CASE cIzbor=="B1"
        ::cColTitle := "GR+/N"
        ::cColBorder  := "GR+/N"
        ::cColFont := "W/N  ,R/BG ,,,B/W"
	
     CASE cIzbor=="B2"
        ::cColTitle := "N/G"
        ::cColBorder := "N/G"
        ::cColFont := "W+/G ,R/BG ,,,B/W"
     
     CASE cIzbor=="B3"
        ::cColTitle := "R+/N"
        ::cColBorder:= "R+/N"
        ::cColFont  := "N/GR ,R/BG ,,,B/W"
     
     CASE cIzbor=="B4"
        ::cColTitle := "B/BG"
        ::cColBorder  := "B/W"
        ::cColFont  := "B/W  ,R/BG ,,,B/W"
     
     CASE cIzbor=="B5"
        ::cColTitle := "B/W"
        ::cColBorder  := "R/W"
        ::cColFont  := "GR+/N,R/BG ,,,B/W"
     
     CASE cIzbor=="B6"
        ::cColTitle := "B/W"
        ::cColBorder  := "R/W"
        ::cColFont  := "W/N,R/BG ,,,B/W"
     CASE cIzbor=="B7"
        ::cColTitle := "B/W"
        ::cColBorder  := "R/W"
        ::cColFont  := "N/G,R+/N ,,,B/W"
     OTHERWISE
   ENDCASE

ELSE
        ::cColTitle := "N/W"
        ::cColBorder  := "N/W"
        ::cColFont  := "W/N  ,N/W  ,,,N/W"
ENDIF
::cColShema:=cIzbor
 
return cIzbor


method showSezona(cSezona)
@ 3, MAXCOLS()-10 SAY "Sez: "+cSezona COLOR INVERT
return


*void showMainScreen(bool lClear)
method showMainScreen( lClear )
local _ver_pos := 3

if lClear == NIL
	lClear := .f.
endif

if lClear
	clear
endif

@ 0, 2 SAY '<ESC> Izlaz' COLOR INVERT
@ 0, COL() + 2 SAY DATE()  COLOR INVERT

@ MAXROWS() - 1, MAXCOLS() - 16 SAY fmklibver()

DispBox( 2, 0, 4, MAXCOLS() - 1, B_DOUBLE + ' ', NORMAL )

if lClear
	DispBox( 5, 0, MAXROWS() - 1, MAXCOLS() - 1, B_DOUBLE + "±", INVERT )
endif

@ _ver_pos, 1 SAY PADC( gNaslov + ' Ver.' + gVerzija, MAXCOLS() - 8 ) COLOR NORMAL

// dodatni ispisi na glavnoj formi
// LOG level
f18_ispisi_status_log_levela()
// statu semafora
f18_ispisi_status_semafora()
// podrucje
f18_ispisi_status_podrucja( _ver_pos )
// ispisi status modula
f18_ispisi_status_modula()
// ispisi status baze
f18_ispisi_status_baze()

return


// --------------------------------------------------------------
// --------------------------------------------------------------
function f18_ispisi_status_log_levela()
@ MAXROWS()-1, 1 SAY "log level: " + ALLTRIM( STR( log_level() ) )
return


// --------------------------------------------------------------
// ispisuje status podrucja
// --------------------------------------------------------------
function f18_ispisi_status_podrucja( position )
local _database := my_server_params()["database"]
local _color := "GR+/B" 
local _txt := ""
local _c_tek_year := ALLTRIM( STR( YEAR( DATE() ) ) )
local _show := .f.

if !( _c_tek_year $ _database )
    _show := .t.
    _txt := "! SEZONSKO PODRUCJE: " + RIGHT( ALLTRIM( _database ), 4 ) + " !!!"
    _color := "W/R+"
endif

if _show
    @ position, MAXCOLS() - 35 SAY PADC( _txt, 30 ) COLOR _color
endif

return




function f18_ispisi_status_modula()
local _module := LOWER( goModul:cName )
local _in_use := f18_use_module( IF( _module == "tops", "pos", _module ) )
local _color := "GR+/B" 

if !_in_use
    _color := "W/R+"
	@ MAXROWS()-1, 25 SAY "!" COLOR _color
else
	@ MAXROWS()-1, 25 SAY " " COLOR _color
endif


return


function f18_ispisi_status_baze()
local _color := "GR+/B" 
local _db_lock := F18_DB_LOCK():New():is_locked()

if _db_lock
    _color := "W/R+"
	@ MAXROWS()-1, 30 SAY "LOCKED" COLOR _color
else
	@ MAXROWS()-1, 30 SAY "      " COLOR _color
endif


return




// --------------------------------------------------------------
// --------------------------------------------------------------
function f18_ispisi_status_semafora( status )
local _status := get_my_use_semaphore_status( status )
local _color := "GR+/B" 

if _status == "OFF"
    _color := "W/R+"
endif

@ MAXROWS()-1, 15 SAY "sem: " + PADR( _status, 3 ) COLOR _color

return



