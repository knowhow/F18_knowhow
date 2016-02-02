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



FUNCTION MyErrorHandler( objErr, lLocalHandler )

   LOCAL cOldDev
   LOCAL cOldCon
   LOCAL Odg
   LOCAL nErr

   ? "Greska .......... myerrorhandler"
   sleep( 5 )

   IF lLocalHandler
      Break objErr
   ENDIF

   cOldDev  := Set( _SET_DEVICE, "SCREEN" )
   cOldCon  := Set( _SET_CONSOLE, "ON" )
   cOldPrn  := Set( _SET_PRINTER, "" )
   cOldFile := Set( _SET_PRINTFILE, "" )
   altd()
   BEEP( 5 )

   nErr := objErr:genCode

   IF objErr:genCode = EG_PRINT
      MsgO( objErr:description + ':Greska sa stampacem !' )
   ELSEIF ObjErr:genCode = EG_CREATE
      MsgO( ObjErr:description + ':Ne mogu kreirati fajl !' )
   ELSEIF objErr:genCode = EG_OPEN
      MsgO( ObjErr:description + ':Ne mogu otvoriti fajl !' )
   ELSEIF objErr:genCode = EG_CLOSE
      MsgO( objErr:description + ':Ne mogu zatvoriti fajl !' )
   ELSEIF objErr:genCode = EG_READ
      MsgO( objErr:description + ':Ne mogu procitati fajl !' )
   ELSEIF objErr:genCode = EG_WRITE
      MsgO( objErr:description + ':Ne mogu zapisati u fajl !' )
   ELSE
      MsgO( objErr:description + ' Greska !!!!' )
   ENDIF


   Inkey( 0 )

   MsgC()

   Odg := Pitanje(, 'Želite li pokušati ponovo (D/N) ?', ' ' ) == "D"


   IF ( Odg == 'D' )
      Set( _SET_DEVICE, cOldDev )
      Set( _SET_CONSOLE, cOldCon )
      Set( _SET_PRINTER, cOldPrn )
      Set( _SET_PRINTFILE, cOldFile )
      RETURN .T.
   ELSE

      QUIT
      RETURN .F.

   ENDIF

   RETURN .T.

FUNCTION ShowFERROR()

   LOCAL aGr := ;
   { {  0, "Successful" }, ;
      {  2, "File not found" }, ;
      {  3, "Path not found" }, ;
      {  4, "Too many files open" }, ;
      {  5, "Access denied" }, ;
      {  6, "Invalid handle" }, ;
      {  8, "Insufficient memory" }, ;
      { 15, "Invalid drive specified" }, ;
      { 19, "Attempted to write to a write-protected" }, ;
      { 21, "Drive not ready" }, ;
      { 23, "Data CRC error" }, ;
      { 29, "Write fault" }, ;
      { 30, "Read fault" }, ;
      { 32, "Sharing violation" }, ;
      { 33, "Lock violation" } }

   LOCAL n1 := 0
   LOCAL k := FError()

   nErr := ASCAN( aGr, { |x| x[1] == k } )

   IF nErr > 0
      MsgBeep( "FERROR: " + AllTrim( Str( aGr[ nErr, 1 ] ) ) + "-" + aGr[ nErr, 2 ] )
   ELSEIF k <> 0
      MsgBeep( "FERROR: " + AllTrim( Str( k ) ) )
   ENDIF

   RETURN .T.


FUNCTION MyErrH( o )

   BREAK o

   RETURN .T.
