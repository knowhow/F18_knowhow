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


THREAD STATIC  __get_list


// state variables for active READ
STATIC FORMAT
STATIC Updated := .F.
STATIC KillReadSC
STATIC BumpTop
STATIC BumpBot
STATIC LastExit
STATIC LastPos
STATIC ActiveGet
STATIC ReadProcName
STATIC ReadProcLine


// Modifications
#ifndef NOCHANGES

// Time-out variable
STATIC lTimedOut := .F.
STATIC nTimeOut

// GOTOGET and START AT get variable
STATIC nToGet

// Exit at Get variable
STATIC nAtGet

#endif

/***
* ReadModal()
* Standard modal READ on an array of GETs.
*/

FUNCTION ReadModSC( GetList, nTime, nStartAt )

   LOCAL GET
   LOCAL pos
   LOCAL savedGetSysVars

   nTimeOut := iif( nTime == NIL, 0, nTime )
   lTimedOut := .F.


   IF ( ValType( Format ) == "B" )
      Eval( Format )
   ENDIF

   IF ( Empty( getList ) )
      // S87 compat.
      SetPos( MaxRow() -1, 0 )
      // NOTE
      RETURN ( .F. )
   ENDIF


   // preserve state vars
   savedGetSysVars := ClrGetSysVarSC()

   // set these for use in SET KEYs
   ReadProcName := ProcName( 1 )
   ReadProcLine := ProcLine( 1 )


   IF ( nStartAt != NIL )
      pos := nStartAt
   ELSE
      // set initial GET to be read
      pos := SettleSC( Getlist, 0 )

   ENDIF

   DO WHILE ( pos <> 0 )


      // get next GET from list and post it as the active GET
      get := GetList[ pos ]
      PstActGetSc( get )


      // read the GET
      IF ( ValType( get:reader ) == "B" )
         // use custom reader block
         Eval( get:reader, get )
      ELSE

         GetReadSC( get )
      ENDIF


      nAtGet := pos

      // move to next GET based on exit condition
      pos := SettleSC( GetList, pos )

   ENDDO


   // restore state vars
   RstGetSysVarSC( savedGetSysVars )

   // S87 compat.
   SetPos( MaxRow() -1, 0 )

   RETURN ( Updated )



/***
* GetReadSC()
* Standard modal read of a single GET.
*/
PROCEDURE getReadSC( get )

   // read the GET if the WHEN condition is satisfied
   IF ( GetPreValSC( get ) )

      // activate the GET for reading
      get:SetFocus()


      DO WHILE ( get:exitState == GE_NOEXIT )


         // check for initial typeout (no editable positions)
         IF ( get:typeOut )
            get:exitState := GE_ENTER
         ENDIF

         // apply keystrokes until exit
         DO WHILE ( get:exitState == GE_NOEXIT )
            GetApplyKSC( get, MyInKeySC() )
         ENDDO

         // disallow exit if the VALID condition is not satisfied
         IF ( !GetPstValSC( get ) )
            get:exitState := GE_NOEXIT
         ENDIF

      END

      // de-activate the GET
      get:KillFocus()

   ENDIF

   RETURN



/***
* GetApplyKSC()
* Apply a single Inkey() keystroke to a GET.
*
* NOTE: GET must have focus.
*/
PROCEDURE GetApplyKSC( get, key )

   LOCAL cKey
   LOCAL bKeyBlock

   // check for SET KEY first
   IF ( ( bKeyBlock := SetKey( key ) ) <> NIL )

      GetDoSetKSC( bKeyBlock, get )
      RETURN         // NOTE

   ENDIF


   DO CASE


      //
      // Time-out
      //
   CASE ( lTimedOut )
      // MsgBeep("lTimedOut=True")
      get:undo()
      get:exitState := GE_ESCAPE

   CASE ( key == K_UP )
      get:exitState := GE_UP

   CASE ( key == K_SH_TAB )
      get:exitState := GE_UP

   CASE ( key == K_DOWN )
      get:exitState := GE_DOWN

   CASE ( key == K_TAB )
      get:exitState := GE_DOWN

   CASE ( key == K_ENTER )
      get:exitState := GE_ENTER

   CASE ( key == K_ESC )

      // MsgBeep("pritisnut ESCAPE")
      IF ( Set( _SET_ESCAPE ) )
         get:undo()
         get:exitState := GE_ESCAPE
      ENDIF

   CASE ( key == K_PGUP )
      get:exitState := GE_WRITE

   CASE ( key == K_PGDN )
      get:exitState := GE_WRITE

   CASE ( key == K_CTRL_HOME )
      get:exitState := GE_TOP


#ifdef CTRL_END_SPECIAL

      // both ^W and ^End go to the last GET
   CASE ( key == K_CTRL_END )
      get:exitState := GE_BOTTOM

#else

      // both ^W and ^End terminate the READ (the default)
   CASE ( key == K_CTRL_W )
      get:exitState := GE_WRITE

#endif

#ifdef __PLATFORM__DARWIN
   CASE ( key == K_F12)
#else
   CASE ( key == K_INS )
#endif
      show_insert_over_stanje()


   CASE ( key == K_UNDO )
      get:Undo()

   CASE ( key == K_HOME )
      get:Home()

   CASE ( key == K_END )
      get:End()

   CASE ( key == K_RIGHT )
      get:Right()

   CASE ( key == K_LEFT )
      get:Left()

   CASE ( key == K_CTRL_RIGHT )
      get:WordRight()

   CASE ( key == K_CTRL_LEFT )
      get:WordLeft()

   CASE ( key == K_BS )
      get:BackSpace()

   CASE ( key == K_DEL )
      get:Delete()

   CASE ( key == K_CTRL_T )
      get:DelWordRight()

   CASE ( key == K_CTRL_Y )
      get:DelEnd()

   CASE ( key == K_CTRL_BS )
      get:DelWordLeft()

   OTHERWISE

      IF ( key >= 32 .AND. key <= 255 )

         cKey := Chr( key )

         IF ( get:type == "N" .AND. ( cKey == "." .OR. cKey == "," ) )
            get:ToDecPos()

         ELSE
            IF ( Set( _SET_INSERT ) )
               get:Insert( cKey )
            ELSE
               get:Overstrike( cKey )
            ENDIF

            IF ( get:typeOut .AND. !Set( _SET_CONFIRM ) )
               IF ( Set( _SET_BELL ) )
                  ?? Chr( 7 )
               END

               get:exitState := GE_ENTER
            ENDIF

         ENDIF

      ENDIF

   ENDCASE

   RETURN



/***
* GetPreValidate()
* Test entry condition (WHEN clause) for a GET.
*/
FUNCTION GetPreValSC( get )

   LOCAL saveUpdated
   LOCAL lWhen := .T.

   IF ( get:preBlock <> NIL )

      saveUpdated := Updated

      lWhen := Eval( get:preBlock, get )

      get:Display()

      ShowScoreBoard()
      Updated := saveUpdated

   ENDIF


   IF ( KillReadSC )
      // MsgBeep("KillreadSC=.t./1")
      lWhen := .F.
      get:exitState := GE_ESCAPE
      // provokes ReadModal() exit

   ELSEIF ( !lWhen )
      get:exitState := GE_WHEN
      // indicates failure

   ELSE
      get:exitState := GE_NOEXIT
      // prepares for editing

   ENDIF

   RETURN ( lWhen )



/***
* GetPstValSC()
* Test exit condition (VALID clause) for a GET.
*
* NOTE: bad dates are rejected in such a way as to preserve edit buffer.
*/
FUNCTION GetPstValSC( get )

   LOCAL saveUpdated
   LOCAL changed, valid := .T.

   IF ( get:exitState == GE_ESCAPE )
      RETURN ( .T. )
      // NOTE
   ENDIF

   IF ( get:BadDate() )
      get:Home()
      DateMsg()
      ShowScoreboard()
      RETURN ( .F. )     // NOTE
   ENDIF


   // if editing occurred, assign the new value to the variable
   IF ( get:changed )
      get:Assign()
      Updated := .T.
   ENDIF


   // reform edit buffer, set cursor to home position, redisplay
   get:Reset()


   // check VALID condition if specified
   IF ( get:postBlock <> NIL )

      saveUpdated := Updated

      // S87 compat.
      SetPos( get:row, get:col + Len( get:buffer ) )

      valid := Eval( get:postBlock, get )

      // reset compat. pos
      SetPos( get:row, get:col )

      ShowScoreBoard()
      get:UpdateBuffer()

      Updated := saveUpdated

      IF ( KillReadSC )

         // MsgBeep("KillreadSC=.t./2")

         // provokes ReadModal() exit
         get:exitState := GE_ESCAPE
         valid := .T.
      END

   ENDIF

   RETURN ( valid )




/***
* GetDoSetKSC()
* Process SET KEY during editing.
*/
FUNCTION GetDoSetKSC( keyBlock, get )

   LOCAL saveUpdated

   // if editing has occurred, assign variable
   IF ( get:changed )
      get:Assign()
      Updated := .T.
   END


   saveUpdated := Updated

   Eval( keyBlock, ReadProcName, ReadProcLine, ReadVar() )

   ShowScoreboard()
   get:UpdateBuffer()

   Updated := saveUpdated


   IF ( KillReadSC )

      // MsgBeep("KillreadSC=.t. / 3")
      get:exitState := GE_ESCAPE  // provokes ReadModal() exit
   END

   RETURN



/*
*
* READ services
*
*/


/***
* SettleSC()
*
* Returns new position in array of Get objects, based on
*
*  - current position
*  - exitState of Get object at current position
*
* NOTE return value of 0 indicates termination of READ
* NOTE exitState of old Get is transferred to new Get
*/
STATIC FUNCTION SettleSC( GetList, pos )

   LOCAL lExitState

   // MsgBeep(STR(Len(GetList)))


   IF ( pos == 0 )
      lExitState := GE_DOWN
   ELSE
      lExitState := GetList[ pos ]:exitState
   ENDIF


   IF ( lExitState == GE_ESCAPE )
      // MsgBeep("escape ...")
      RETURN 0
   ENDIF

   IF ( lExitState == GE_WRITE )
      // MsgBeep("pg_down")
      RETURN 0
   ENDIF


   IF ( lExitState <> GE_WHEN )
      // reset state info
      LastPos := pos
      BumpTop := .F.
      BumpBot := .F.

   ELSE
      // re-use last exitState, do not disturb state info
      lExitState := LastExit

   ENDIF


/***
* move
*/
   DO CASE
   CASE ( lExitState == GE_UP )
      pos --

   CASE ( lExitState == GE_DOWN )
      pos ++

   CASE ( lExitState == GE_TOP )
      pos := 1
      BumpTop := .T.
      exitState := GE_DOWN

   CASE ( lExitState == GE_BOTTOM )
      pos := Len( GetList )
      BumpBot := .T.
      lExitState := GE_UP

   CASE ( lExitState == GE_ENTER )
      pos ++

   CASE ( lExitState < 0 .AND. -lExitState <= Len( GetList ) )
      pos := -lExitState
      lExitState := GE_NOEXIT


   ENDCASE


/**
 * bounce
*/
   IF ( pos == 0 )
      // bumped top

      IF ( !ReadExitSC() .AND. !BumpBot )
         BumpTop := .T.
         pos := LastPos
         lExitState := GE_DOWN
      ENDIF

   ELSEIF ( pos == Len( GetList ) + 1 )
      // bumped bottom

      IF ( !ReadExitSC() .AND. lExitState <> GE_ENTER .AND. !BumpTop )
         BumpBot := .T.
         pos := LastPos
         lExitState := GE_UP
      ELSE

         // MsgBeep("settle 0-2")
         pos := 0
      ENDIF
   ENDIF


   // record exit state
   LastExit := lExitState

   IF ( pos <> 0 )
      GetList[ pos ]:exitState := lExitState
   ENDIF

   RETURN ( pos )



/***
* PstActGetSc()
* Post active GET for ReadVar(), GetActive().
*/
STATIC PROCEDURE PstActGetSC( get )

   GetActive( get )
   ReadVar( GetReadVSC( get ) )

   ShowScoreBoard()

   RETURN



/***
* ClrGetSysVarSC()
* Save and clear READ state variables. Return array of saved values.
*
* NOTE: 'Updated' status is cleared but not saved (S87 compat.).
*/
STATIC FUNCTION ClrGetSysVarSC()

   LOCAL saved[ GSV_COUNT ]

   saved[ GSV_KILLREAD ] := KillReadSC
   KillReadSC := .F.

   saved[ GSV_BUMPTOP ] := BumpTop
   BumpTop := .F.

   saved[ GSV_BUMPBOT ] := BumpBot
   BumpBot := .F.

   saved[ GSV_LASTEXIT ] := LastExit
   LastExit := 0

   saved[ GSV_LASTPOS ] := LastPos
   LastPos := 0

   saved[ GSV_ACTIVEGET ] := GetActive( NIL )

   saved[ GSV_READVAR ] := ReadVar( "" )

   saved[ GSV_READPROCNAME ] := ReadProcName
   ReadProcName := ""

   saved[ GSV_READPROCLINE ] := ReadProcLine
   ReadProcLine := 0

   Updated := .F.

   RETURN ( saved )



/***
*   RstGetSysVarSC()
* Restore READ state variables from array of saved values.
*
* NOTE: 'Updated' status is not restored (S87 compat.).
*/
STATIC FUNCTION RstGetSysVarSC( saved )

   KillReadSC := saved[ GSV_KILLREAD ]

   BumpTop := saved[ GSV_BUMPTOP ]

   BumpBot := saved[ GSV_BUMPBOT ]

   LastExit := saved[ GSV_LASTEXIT ]

   LastPos := saved[ GSV_LASTPOS ]

   GetActive( saved[ GSV_ACTIVEGET ] )

   ReadVar( saved[ GSV_READVAR ] )

   ReadProcName := saved[ GSV_READPROCNAME ]

   ReadProcLine := saved[ GSV_READPROCLINE ]

   RETURN



/***
* GetReadVSC()
* Set READVAR() value from a GET.
*/
STATIC FUNCTION GetReadVSC( get )

   LOCAL name := Upper( get:name )
   LOCAL i

   // #ifdef SUBSCRIPT_IN_READVAR

 /***
 * The following code includes subscripts in the name returned by
 * this function, if the get variable is an array element.
 *
 * Subscripts are retrieved from the get:subscript instance variable.
 *
 * NOTE: incompatible with Summer 87
 */

   IF ( get:subscript <> NIL )
      FOR i := 1 TO Len( get:subscript )
         name += "[" + LTrim( Str( get:subscript[ i ] ) ) + "]"
      NEXT
   END

   // #endif

   RETURN ( name )



/*
*
* system services
*
*/



/***
* __KillReadSC()
*   CLEAR GETS service
*/
FUNCTION __KillReadSC()

   KillReadSC := .T.

   // MsgBeep("KillreadSC=.t./4")

   RETURN





/***
* ReadExitSC()
*/
FUNCTION ReadExitSC( lNew )
   RETURN ( Set( _SET_EXIT, lNew ) )



/*
*
* wacky compatibility services
*
*/


// display coordinates for SCOREBOARD
#define SCORE_ROW  0
#define SCORE_COL  60


/***
*   ShowScoreboard()
*/
STATIC PROCEDURE ShowScoreboard()

   LOCAL nRow, nCol

   IF ( Set( _SET_SCOREBOARD ) )
      nRow := Row()
      nCol := Col()

      SetPos( SCORE_ROW, SCORE_COL )
      DispOut( if( Set( _SET_INSERT ), "Ins", "   " ) )
      SetPos( nRow, nCol )
   ENDIF

   RETURN



/***
* DateMsg()
*/
STATIC PROCEDURE DateMsg()

   LOCAL nRow, nCol

   IF ( Set( _SET_SCOREBOARD ) )
      nRow := Row()
      nCol := Col()

      SetPos( SCORE_ROW, SCORE_COL )
      DispOut( "Invalid Date" )
      SetPos( nRow, nCol )

      WHILE ( NextKey() == 0 )
      END

      SetPos( SCORE_ROW, SCORE_COL )
      DispOut( "            " )
      SetPos( nRow, nCol )

   END

   RETURN



//
// Time-Out?
//
// /

FUNCTION TimedOut()
   RETURN ( lTimedOut )

/**
 *
 * Time-Out feature
 *
 */

STATIC FUNCTION MyInKeySc()

   LOCAL nKey
   LOCAL nBroji2
   LOCAL nCursor

   nBroji2 := Seconds()
   nTimeout := Seconds()

   nKey := Inkey()

   RETURN ( nKey )

/*
 * Go to a particular get
 */

FUNCTION GoToGet( nGet )

   GetActive():exitState := -nGet

   // !!!!NOTE!!!!

   RETURN ( .T. )

/*
 *
 * What was the Get?
 *
 */

FUNCTION ExitAtGet()
   RETURN ( nAtGet )


FUNCTION ShowGets()

   AEval( GetList, {| oE|  oE:Display() } )

   RETURN .T.

FUNCTION RefreshGets()

   AEval( MGetList, {| oE|  oE:Display() } )

   RETURN .T.


// -----------------------------
// -----------------------------
FUNCTION InkeySc( nSec )

   IF ( nSec == 0 )
      RETURN Inkey()
   ELSE
      RETURN Inkey( nSec )
   ENDIF


   // --------------------------------------------------------------------
   // sva polja disableujemo osim onoga na koje zelimo "skociti"
   // -------------------------------------------------------------------

FUNCTION get_field_set_focus( f_name )

   LOCAL _i

   __get_list := {}

   FOR _i := 1 TO Len( GetList )
      AAdd( __get_list, GetList[ _i ]:PreBlock )

      IF GetList[ _i ]:name() == f_name
         GetList[ _i ]:PreBlock := {|| restore_get_list(), .T. }
      ELSE
         GetList[ _i ]:PreBlock := {|| .F. }
      ENDIF
   NEXT

FUNCTION restore_get_list()

   LOCAL _i

   FOR _i := 1 TO Len( GetList )
      GetList[ _i ]:PreBlock := __get_list[ _i ]
   NEXT

   FOR _i := Len( GetList ) TO 1 STEP -1
      ADel( __get_list, _i )
   NEXT

   __get_list := NIL

   RETURN .T.



FUNCTION read_dn_parametar( caption, xpos, ypos, value )

   @ xpos, ypos SAY8 caption + " (D/N) ?" GET value VALID value $ "DN" PICT "@!"

   RETURN value
