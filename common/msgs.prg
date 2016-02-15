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

REQUEST ARRAYRDD

MEMVAR Invert, Normal

STATIC aErrors := {}
STATIC aInfos := {}

STATIC aStruct := { ;
      { "TIME", "C", 8, 0 }, ;
      { "DOC", "C", 18, 0 }, ;
      { "MESSAGE", "C", 50, 0 } ;
      }

FUNCTION empty_info_tab()

   aErrors := {}

   RETURN .T.


FUNCTION empty_error_tab()

   aInfos := {}

   RETURN .T.



FUNCTION info_tab( cDoc, cMsg )

   hb_default( @cMsg, "" )

   @ maxrows() -1, 18 SAY8  "> " + PadC( cMsg, maxcols() - 28 ) + " <" COLOR Normal

   IF Len( aInfos ) > INFO_MESSAGES_LENGTH
      ADel( aInfos, 1 )
      ASize( aInfos, Len( aInfos ) - 1 )
   ENDIF
   AAdd( aInfos, { Time(), cDoc, cMsg } )

   RETURN .T.



FUNCTION error_tab( cDoc, cMsg )

   Beep( 2 )
   @ maxrows(), 4 SAY8  ">> " + PadC( cMsg, maxcols() - 10 ) + " <<" COLOR Invert

   IF Len( aErrors ) > ERROR_MESSAGES_LENGTH
      ADel( aErrors, 1 )
      ASize( aErrors, Len( aErrors ) - 1 )
   ENDIF
   AAdd( aErrors, { Time(), cDoc, cMsg } )

   RETURN .F.  // ako se koristi u validaciji treba da vrati .F.


FUNCTION show_infos()

   LOCAL cScr

   PushWA()

   dbCreate( "a_infos.dbf", aStruct, "ARRAYRDD", .T., "a_infos" ) // Create it and leave opened
   AEval( aInfos, {| item |  dbAppend(), field->time := item[ 1 ], field->doc := item[ 2 ], field->message := _u( item[ 3 ] ) } )
   SAVE SCREEN TO cScr
   dbEdit()
   RESTORE SCREEN FROM cScr
   USE

   PopWa()

   RETURN .T.

FUNCTION show_errors()

   LOCAL cScr

   PushWa()

   dbCreate( "a_errors.dbf", aStruct, "ARRAYRDD", .T., "a_errors" )
   AEval( aErrors, {| item |  dbAppend(), field->time := item[ 1 ], field->doc := item[ 2 ], field->message := _u( item[ 3 ] ) } )
   SAVE SCREEN TO cScr
   dbEdit()
   RESTORE SCREEN FROM cScr
   USE

   PopWa()

   RETURN .T.
