/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"
#include "f18_ver.ch"

#include "error.ch"
/*
#include "dbstruct.ch"
#include "set.ch"
*/

// ------------------------------------------
// ------------------------------------------
function MyErrorHandler(objErr, lLocalHandler)

local cOldDev
local cOldCon
local Odg
local nErr

 ? "Greska .......... myerrorhandler"
 sleep(5)
 
if lLocalHandler
  Break objErr
endif

cOldDev  := SET(_SET_DEVICE,"SCREEN")
cOldCon  := SET(_SET_CONSOLE,"ON")
cOldPrn  := SET(_SET_PRINTER,"")
cOldFile :=SET(_SET_PRINTFILE,"")
BEEP(5)

nErr:=objErr:genCode

 if objErr:genCode =EG_PRINT
     MsgO(objErr:description+':Greska sa stampacem !!!!')
 elseif ObjErr:genCode =EG_CREATE
     MsgO(ObjErr:description+':Ne mogu kreirati fajl !!!!')
 elseif objErr:genCode =EG_OPEN
     MsgO(ObjErr:description+':Ne mogu otvoriti fajl !!!!')
 elseif objErr:genCode =EG_CLOSE
     MsgO(objErr:description+':Ne mogu zatvoriti fajl !!!!')
 elseif objErr:genCode =EG_READ
     MsgO(objErr:description+':Ne mogu procitati fajl !!!!')
 elseif objErr:genCode =EG_WRITE
     MsgO(objErr:description+':Ne mogu zapisati u fajl !!!!')
 else
     MsgO(objErr:description+' Greska !!!!')
 endif


 INKEY(0)

 MsgC()

Odg:=Pitanje(,'Želite li pokušati ponovo (D/N) ?',' ')=="D"


if (Odg=='D')
   SET(_SET_DEVICE,cOldDev)
   SET(_SET_CONSOLE,cOldCon)
   SET(_SET_PRINTER,cOldPrn)
   SET(_SET_PRINTFILE,cOldFile)
   return .t.
else

  QUIT
  return .f.

endif

return .t.

// ---------------------------------------
// ---------------------------------------
function ShowFERROR()

LOCAL aGr:={ {  0, "Successful"},;
              {  2, "File not found"},;
              {  3, "Path not found"},;
              {  4, "Too many files open"},;
              {  5, "Access denied"},;
              {  6, "Invalid handle"},;
              {  8, "Insufficient memory"},;
              { 15, "Invalid drive specified"},;
              { 19, "Attempted to write to a write-protected"},;
              { 21, "Drive not ready"},;
              { 23, "Data CRC error"},;
              { 29, "Write fault"},;
              { 30, "Read fault"},;
              { 32, "Sharing violation"},;
              { 33, "Lock violation"} }
  LOCAL n:=0, k:=FERROR()
  n:=ASCAN(aGr,{|x| x[1]==k})
  IF n>0
    MsgBeep( "FERROR: " + ALLTRIM(STR(aGr[n,1])) + "-" + aGr[n,2] )
  ELSEIF k<>0
    MsgBeep( "FERROR: " + ALLTRIM(STR(k)) )
  ENDIF
RETURN


// ----------------------------------
// ----------------------------------
function MyErrH(o)

BREAK o
return

