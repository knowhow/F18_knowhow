/*
 * $Id: tsqlbrw.prg 14688 2010-06-04 13:32:23Z vszakats $
 */

/*
 * Harbour Project source code:
 * MySQL TBrowse
 * A TBrowse on a MySQL Table / query
 *
 * Copyright 2000 Maurilio Longo <maurilio.longo@libero.it>
 * www - http://harbour-project.org
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include "fmk.ch"
#include "hbclass.ch"
#include "common.ch"
#include "dbstruct.ch"
#include "setcurs.ch"
#include "f18_separator.ch"

/* NOTE:

   In fact no, the 'regular syntax is the same as the VO one,

   ACCESS Block METHOD Block()
   or
   ACCESS Block INLINE ::MyVal

   and

   ASSIGN Block( x ) METHOD Block( x )
   or
   ASSIGN Block( x ) INLINE ::MyVal := x

*/


CREATE CLASS TBColumnSQL FROM TBColumn

   VAR   oBrw                 // pointer to Browser containing this column, needed to be able to
                              // retreive field values from Browse instance variable oCurRow
// VAR   Picture              // From clipper 5.3
   VAR   nFieldNum            // This column maps field num from query

   MESSAGE  Block METHOD Block()          // When evaluating code block to get data from source this method
                                          // gets called. I need this since inside TBColumn Block I cannot
                                          // reference Column or Browser instance variables

   METHOD   New( cHeading, bBlock, oBrw )   // Saves inside column a copy of container browser

ENDCLASS


METHOD New( cHeading, bBlock, oBrw ) CLASS TBColumnSQL

   ::super:New( cHeading, bBlock )
   ::oBrw := oBrw

   RETURN Self


METHOD Block() CLASS TBColumnSQL

   LOCAL xValue := ::oBrw:oCurRow:FieldGet( ::nFieldNum )
   LOCAL xType := ::oBrw:oCurRow:FieldType( ::nFieldNum )

   DO CASE
   CASE xType == "N"
      xValue := "'" + Str( xValue, ::oBrw:oCurRow:FieldLen( ::nFieldNum ), ::oBrw:oCurRow:FieldDec( ::nFieldNum ) ) + "'"

   CASE xType == "D"
      xValue :=  "'" + DToC( xValue ) + "'"

   CASE xType == "L"
      xValue := iif( xValue, ".T.", ".F." )

   CASE xType == "C"
      // Chr(34) is a double quote
      // That is: if there is a double quote inside text substitute it with a string
      // which gets converted back to a double quote by macro operator. If not it would
      // give an error because of unbalanced double quotes.
      xValue := Chr( 34 ) + StrTran( hb_utf8tostr( xValue ), Chr( 34 ), Chr( 34 ) + "+Chr(34)+" + Chr( 34 ) ) + Chr( 34 )

   CASE xType == "M"
      xValue := "' <MEMO> '"

   OTHERWISE
      xValue := "'" + hb_utf8tostr( xValue ) + "'"
   ENDCASE

   RETURN hb_macroBlock( xValue )


/*--------------------------------------------------------------------------------------------------*/


/*
   This class is more or less like a TBrowseDB() object in that it receives an oQuery/oTable
   object and gives back a browseable view of it
*/
CREATE CLASS TBrowseSQL FROM TBrowse

    VAR      oCurRow                       // Active row inside table / sql query
    VAR      oQuery                        // Query / table object which we are browsing
    VAR      oQueryOriginal                // original query state
    VAR      codes_type_table
    VAR      browse_table
    VAR      browse_fields
    VAR      browse_order
    VAR      browse_key_fields
    VAR      last_key

    METHOD   New( nTop, nLeft, nBottom, nRight, oServer, oQuery, cTable )

    METHOD   EditField()                   // Editing of hilighted field, after editing does an update of
                                          // corresponding row inside table

    METHOD   BrowseTable( lCanEdit, aExitKeys ) // Handles standard moving inside table and if lCanEdit == .T.
                                               // allows editing of field. It is the stock ApplyKey() moved inside a table
                                               // if lCanEdit K_DEL deletes current row
                                               // When a key is pressed which is present inside aExitKeys it leaves editing loop

    METHOD   KeyboardHook( nKey )               // Where do all unknown keys go?


    // f18 methods...
    METHOD   editRow( lNew )
    METHOD   deleteRow()
    METHOD   deleteAll()
    METHOD   findRec()
    METHOD   revert_table_to_original_state()

    PROTECTED:

        METHOD browse_editrow_box()
        METHOD browse_editrow_box_getlist()
        METHOD set_global_vars_from_table( struct )
        METHOD get_table_global_memvars( struct )
        METHOD browse_editrow_box_getlist_defaults()
        METHOD field_list_from_array()
        METHOD findRec_where_constructor()

ENDCLASS


METHOD New( nTop, nLeft, nBottom, nRight, oServer, oQuery, cTable, fields, codes_type, key_fields, br_order ) CLASS TBrowseSQL
local i, oCol

HB_SYMBOL_UNUSED( oServer )
HB_SYMBOL_UNUSED( cTable )

::super:New( nTop, nLeft, nBottom, nRight )

::oQuery := oQuery
::oQueryOriginal := oQuery 

// Let's get a row to build needed columns
::oCurRow := ::oQuery:GetRow( 1 )

if codes_type == NIL
    codes_type := .f.
endif

// da li je rijec o sifrarniku ili o obicnom browse-u
::codes_type_table := codes_type
::browse_table := cTable
::browse_fields := fields
::browse_order := br_order
::browse_key_fields := key_fields
::last_key := NIL

// positioning blocks
::SkipBlock := {| n | ::oCurRow := Skipper( @n, ::oQuery ), n }
::GoBottomBlock := {|| ::oCurRow := ::oQuery:GetRow( ::oQuery:LastRec() ), 1 }
::GoTopBlock := {|| ::oCurRow := ::oQuery:GetRow( 1 ), 1 }

// Add a column for each field
FOR i := 1 TO ::oQuery:FCount()
 
    // dodavanje kolone
    //oCol := TBColumnSQL():New( ::oCurRow:FieldName( i ),, Self )
    oCol := TBColumnSQL():New( fields[ i, 1 ],, Self )

    IF !( ::oCurRow:FieldType( i ) == "M" )
        //oCol:Width := Max( ::oCurRow:FieldLen( i ), Len( oCol:Heading ) )
        oCol:Width := fields[ i, 2 ]
    ELSE
        oCol:Width := 10
    ENDIF

    // which field does this column display
    oCol:nFieldNum := i

    // Add a picture ?????
    // ovo mi nesto sumnjivo !!!!! pa iskljucio za string polja

    DO CASE
        CASE ::oCurRow:FieldType( i ) == "N"
            oCol:picture := Replicate( "9", oCol:Width )
        CASE ::oCurRow:FieldType( i ) $ "CM"
            oCol:picture := "@S" + ALLTRIM( STR( oCol:width ) ) //Replicate( "!", oCol:Width )
    ENDCASE

    ::AddColumn( oCol )

NEXT

::headSep := BROWSE_HEAD_SEP
::colSep := BROWSE_COL_SEP

RETURN Self



STATIC FUNCTION Skipper( nSkip, oQuery )
LOCAL i := 0

DO CASE
    CASE nSkip == 0 .OR. oQuery:LastRec() == 0
        oQuery:Skip( 0 )

    CASE nSkip > 0
        DO WHILE i < nSkip           // Skip Foward

            //DAVID: change in TMySQLquery:eof() definition  if oQuery:eof()
            IF oQuery:recno() == oQuery:lastrec()
                EXIT
            ENDIF
            oQuery:Skip( 1 )
            i++

        ENDDO

    CASE nSkip < 0
        DO WHILE i > nSkip           // Skip backward

            //DAVID: change in TMySQLquery:bof() definition  if oQuery:bof()
            IF oQuery:recno() == 1
                EXIT
            ENDIF

            oQuery:Skip( -1 )
            i--

        ENDDO
ENDCASE

nSkip := i

RETURN oQuery:GetRow( oQuery:RecNo() )



METHOD EditField() CLASS TBrowseSQL

   LOCAL oCol
   LOCAL aGetList
   LOCAL nKey
   LOCAL cMemoBuff, cMemo

   // Get the current column object from the browse
   oCol := ::getColumn( ::colPos )

   // Editing of a memo field requires a MemoEdit() window
   IF ::oCurRow:FieldType( oCol:nFieldNum ) == "M"

      /* save, clear, and frame window for memoedit */
      cMemoBuff := SaveScreen( 10, 10, 22, 69 )

      hb_Scroll( 10, 10, 22, 69, 0 )
      hb_DispBox( 10, 10, 22, 69 )

      /* use fieldspec for title */
      //@ 10, ( ( 76 - Len( ::oCurRow:FieldName( oCol:nFieldNum ) ) / 2 ) SAY "  " + ( ::oCurRow:FieldName( oCol:nFieldNum ) ) + "  "

      /* edit the memo field */
      cMemo := MemoEdit( ::oCurRow:FieldGet( oCol:nFieldNum ), 11, 11, 21, 68, .T. )

      IF Lastkey() == K_CTRL_END
         ::oCurRow:FieldPut( oCol:nFieldNum, cMemo )

         /* NOTE: To do in a better way */
         IF !::oQuery:Update( ::oCurRow )
            Alert( Left( ::oQuery:Error(), 60 ) )
         ENDIF
      ENDIF

      RestScreen( 10, 10, 22, 69, cMemoBuff )

   ELSE

      // Create a corresponding GET
      // NOTE: I need to use ::oCurRow:FieldPut(...) when changing values since message 
      //       redirection doesn't work at present
      //       time for write access to instance variables but only for reading them
      aGetList := { GetNew( Row(), Col(),;
                            {| xValue | iif( xValue == NIL, Eval( oCol:Block ), ;
                                ::oCurRow:FieldPut( oCol:nFieldNum, xValue ) ) },;
                            oCol:heading,;
                            oCol:picture,;
                            ::colorSpec ) }

      // Set initial cursor shape
      // SetCursor( iif( ReadInsert(), SC_INSERT, SC_NORMAL ) )
      ReadModal( aGetList )
      // SetCursor( SC_NONE )

      /* NOTE: To do in a better way */
      IF ! ::oQuery:Update( ::oCurRow )
         Alert( Left( ::oQuery:Error(), 60 ) )
      ENDIF

   endif

   IF !::oQuery:Refresh()
      Alert( ::oQuery:Error() )
   ENDIF

   ::RefreshAll()

   // Check exit key from get
   nKey := LastKey()
   IF nKey == K_UP   .OR. nKey == K_DOWN .OR. ;
      nKey == K_PGUP .OR. nKey == K_PGDN

      // Ugh
      KEYBOARD( Chr( nKey ) )

   ENDIF

   RETURN Self


METHOD BrowseTable( lCanEdit, aExitKeys ) CLASS TBrowseSQL
LOCAL nKey
LOCAL lKeepGoing := .t.

IF ! ISNUMBER( nKey )   
    nKey := NIL
ENDIF

IF ! ISLOGICAL( lCanEdit )
    lCanEdit := .f.
ENDIF

IF ! ISARRAY( aExitKeys )
    aExitKeys := { K_ESC }
ENDIF

DO WHILE lKeepGoing

    DO WHILE !::Stabilize() .AND. NextKey() == 0
    ENDDO

    nKey := Inkey( 0 )

    // misa necemo obradjivati, preskoci ga !
    IF nKey >= K_MINMOUSE .and. nKey <= K_MAXMOUSE
        LOOP
    ENDIF

    IF AScan( aExitKeys, nKey ) > 0
        lKeepGoing := .f.
        LOOP
    ENDIF

    DO CASE
        CASE nKey == K_DOWN
            ::down()

        CASE nKey == K_PGDN
            ::pageDown()

        CASE nKey == K_CTRL_PGDN
            ::goBottom()

        CASE nKey == K_UP
            ::up()

        CASE nKey == K_PGUP
            ::pageUp()

        CASE nKey == K_CTRL_PGUP
            ::goTop()

        CASE nKey == K_RIGHT
            ::right()

        CASE nKey == K_LEFT
            ::left()

        CASE nKey == K_HOME
            ::home()

        CASE nKey == K_END
            ::end()

        CASE nKey == K_CTRL_LEFT
            ::panLeft()

        CASE nKey == K_CTRL_RIGHT
            ::panRight()

        CASE nKey == K_CTRL_HOME
            ::panHome()

        CASE nKey == K_CTRL_END
            ::panEnd()

        CASE nKey == K_RETURN .AND. lCanEdit
            ::EditField()

    #if 0
        CASE nKey == K_DEL
            IF lCanEdit
                IF ! ::oQuery:Delete( ::oCurRow )
                    Alert( "not deleted " + ::oQuery:Error() )
                ENDIF
                IF !::oQuery:Refresh()
                    Alert( ::oQuery:Error() )
                ENDIF

                ::inValidate()
                ::refreshAll():forceStable()
            ENDIF
    #endif

        OTHERWISE
            ::KeyboardHook( nKey )
    ENDCASE
ENDDO

RETURN Self


// Empty method to be subclassed
METHOD KeyboardHook( nKey ) CLASS TBrowseSQL

// mozda se moze koristiti !
//HB_SYMBOL_UNUSED( nKey )

do case

    // funkcije bitne samo za tip = sifrarnik

    case ::codes_type_table .and. nKey == K_CTRL_T

        // brisanje zapisa
        if Pitanje(, "Sigurno zelite izbrisati ovaj zapis (D/N) ?" , "N" ) == "D"
            ::deleteRow() 
        endif

    case ::codes_type_table .and. nKey == K_CTRL_F9

        // brisanje kompletnog sifrarnika
        if Pitanje(, "Sigurno zelite izbrisati sve zapise tabele (D/N) ?", "N" ) == "D"
            ::deleteAll()
        endif

    case ::codes_type_table .and. nKey == K_CTRL_N

        // dodavanje novog zapisa
        ::last_key := nKey
        ::editRow( .t. )

    case ::codes_type_table .and. nKey == K_F2

        // dodavanje novog zapisa
        ::last_key := nKey
        ::editRow( .f. )

    // funkcije koje vaze za svaki browse...

    case UPPER( CHR( nKey ) ) == "F"

        // pretraga sifrarnika
        ::findRec()

    case nKey == K_F5

        // vrati na prvobitno stanje tabele - prije filtera
        ::revert_table_to_original_state()

    case nKey == K_CTRL_J

        // test funkcija - do uvodjenja...
        Msgbeep( "tabela: " + ::browse_table )
        
endcase

RETURN Self


// --------------------------------------------------------------------
// delete row
// --------------------------------------------------------------------
METHOD deleteRow() CLASS TBrowseSQL
local _field_val := ::oCurRow:FieldGet(1)
local _field_name := ::oCurRow:FieldPos(1)

IF ! ::oQuery:Delete( ::oCurRow )
    Alert( "Greska prilikom brisanja: " + ::oQuery:Error() )
    log_write( "F18_DOK_OPER, Greska prilikom brisanja zapisa tabele " + ::browse_table + ", " + ::oQuery:Error(), 3 )
    return Self
ENDIF
                
IF !::oQuery:Refresh()
    Alert( ::oQuery:Error() )
ENDIF

::inValidate()
::refreshAll():forceStable()
 
log_write( "F18_DOK_OPER, brisanje zapisa iz tabele " + ::browse_table + " - ok, " + _field_name + " = " + to_str( _field_val ) , 3 )

RETURN Self


// --------------------------------------------------------------------
// delete all
// --------------------------------------------------------------------
METHOD deleteAll() CLASS TBrowseSQL
local _server := my_server()
local _qry, _result, _data
local _table := ::browse_table

_qry := "DELETE FROM " + _table
_data := _sql_query( _server, _qry )
_result := _table:Fieldget(1)

if !::oQuery:Refresh()
    Alert( ::oQuery:Error() )
    log_write( "F18_DOK_OPER, brisanje kompletne tabele " + ::browse_table + " - error, " + ::oQuery:Error(), 3 )
    return Self
endif

::inValidate()
::refreshAll():forceStable()

log_write( "F18_DOK_OPER, brisanje kompletne tabele " + ::browse_table + " - ok", 3 )

RETURN Self



// --------------------------------------------------------------------
// edit row
// --------------------------------------------------------------------
METHOD editRow( lNew ) CLASS TBrowseSQL
local _struct := _sql_table_struct( ::browse_table )

// uzmi memorijske varijable...
::set_global_vars_from_table( _struct, lNew )

if lNew .and. ::browse_table == "fmk.roba"
    _idtarifa := PADR( "PDV17", 7 )
endif

// prikazi box
if ::browse_editrow_box( _struct, lNew )

    // daj mi sve iz memvars za ovaj zapis...
    _rec := ::get_table_global_memvars( _struct )

    if lNew
        sql_update_table_from_hash( ::browse_table, "ins", _rec, NIL )
    else
        sql_update_table_from_hash( ::browse_table, "upd", _rec, ::browse_key_fields )
    endif

    if !::oQuery:Refresh()
        Alert( ::oQuery:Error() )
    endif

    ::inValidate()
    ::RefreshAll():forcestable()

endif

RETURN Self


// -------------------------------------------------------------------
// vraca memorijske varijable u hash matricu
// -------------------------------------------------------------------
METHOD get_table_global_memvars( struct ) CLASS TBrowseSQL
local _hash := hb_hash()
local _i, _field
local _scan

for _i := 1 TO LEN( struct )

    _field := struct[ _i, 1 ]

    _scan := ASCAN( ::browse_fields, { | var | var[3] == _field  } )

    if _scan > 0
 
        _hash[ LOWER( _field ) ] := EVAL( MEMVARBLOCK( "x" + _field ) )
    
        // ukini memvar
        __MVXRELEASE( "x" + _field )

    endif

next

return _hash


// -------------------------------------------------------------------
// vraca memorijske varijable na osnovu strukture
// -------------------------------------------------------------------
METHOD set_global_vars_from_table( struct, new_rec ) CLASS TBrowseSQL
local _i
local _field, _var
local _prefix := "x"

for _i := 1 to LEN( struct )

    _field := struct[ _i, 1 ]

    _scan := ASCAN( ::browse_fields, { | var | var[3] == _field  } )

    if _scan > 0
    
        _var := _prefix + _field
        __MVPUBLIC( _var )

        if struct[ _i, 2 ] $ "C#M"
            EVAL( MEMVARBLOCK( _var ), ;
                if( new_rec, ;
                    PADR( "", struct[ _i, 3 ] ), ;
                    PADR( hb_utf8tostr( ::oCurRow:FieldGet( ::oCurRow:FieldPos( _field ) ) ), struct[ _i, 3 ] ) ; 
                ) ; 
                ) 
        elseif struct[ _i, 2 ] == "D"
            EVAL( MEMVARBLOCK( _var ), ;
                if( new_rec, ;
                    CTOD(""), ;
                    ::oCurRow:FieldGet( ::oCurRow:FieldPos( _field ) ) ; 
                ) ; 
                )  
        else
            EVAL( MEMVARBLOCK( _var ), ;
                if( new_rec, ;
                    0, ;
                    ::oCurRow:FieldGet( ::oCurRow:FieldPos( _field ) ) ;
                 ) ;
                ) 
        endif

    endif

next

// default vrijednosti za pojedine tabele itd...
// obraditi
if new_rec
    ::browse_editrow_box_getlist_defaults()
endif

return .t.


// ---------------------------------------------------------------------
// box edit-a
// ---------------------------------------------------------------------
METHOD browse_editrow_box( struct, new_rec ) CLASS TBrowseSQL
local _ok := .f.
local _x := 1
local _i
local _prefix := "x"
private GetList := {}

Box(, ::oQuery:FCount(), 70 )
    for _i := 1 to ::oQuery:FCount()
        _var := _prefix + ::browse_fields[ _i, 3 ]
        ::browse_editrow_box_getlist( _var, @GetList, _i, struct, new_rec )
    next
    read
BoxC()

if LastKeY() == K_ESC
    return _ok
endif

_ok := .t.

return _ok



// --------------------------------------------------------------------------
// get list....
// --------------------------------------------------------------------------
METHOD browse_editrow_box_getlist( var, get_list, curr_row, struct, new_rec ) CLASS TBrowseSQL
local bWhen, bValid
local _pict
local _when_block, _valid_block
local _m_block
local _row, _col
local _len_desc := 15
local _scan

// imamo ovdje i obradu lastkey()
// ::last_key = nKey

// when & valid blokovi
if LEN( ::browse_fields[ curr_row ] ) >= 5 .and. ::browse_fields[ curr_row, 5 ] <> NIL
    bWhen := ::browse_fields[ curr_row, 5 ]
else
    bWhen := { || .t. }
endif

if LEN( ::browse_fields[ curr_row ] ) >= 6 .and. ::browse_fields[ curr_row, 6 ] <> NIL
    bValid := ::browse_fields[ curr_row, 6 ]
else
    bValid := { || .t. }
endif

_m_block := MEMVARBLOCK( var )

_scan := ASCAN( struct, {|var| var[1] == ::browse_fields[ curr_row, 3 ] } )

do case

    case struct[ _scan, 2 ] == "C"
        _pict := "@S" + ALLTRIM( STR( struct[ _scan, 3 ] ) )

    case struct[ _scan, 2 ] == "N"
        _pict := REPLICATE( "9", struct[ _scan, 3 ] - struct[ _scan, 4 ] ) + "." + ;
                 REPLICATE( "9", struct[ _scan, 4 ] )
    otherwise
        _pict := ""

endcase

if LEN( ToStr( EVAL( _m_block ) ) ) > 50
    _pict := "@S50"
endif

_when_block := bWhen
_valid_block := bValid

@ m_x + curr_row, m_y + 2 SAY PADL( ALLTRIM( ::browse_fields[ curr_row, 1 ] ), _len_desc ) + " "

AADD( get_list, _GET_( &var, var, _pict, _valid_block, _when_block ) )
ATAIL( get_list ):display()

RETURN self


// ---------------------------------------------------------------------
// default vrijednosti za neka polja i neke tabele
// ---------------------------------------------------------------------
METHOD browse_editrow_box_getlist_defaults() CLASS TBrowseSQL

// setuju se varijable x + field_name

if ::browse_table == "fmk.roba"
    xidtarifa := PADR( "PDV17", 7 )
endif

return Self



// ---------------------------------------------------------------------
// pretraga podataka
// ---------------------------------------------------------------------
METHOD findRec() CLASS TBrowseSQL
local _server := my_server()
local _qry, _find_field
local oCol
local _find_what := SPACE(100)
local _field_type 

// Get the current column object from the browse
oCol := ::getColumn( ::colPos )

_find_field := ::oCurRow:FieldName( oCol:nFieldNum )
_field_type := ::oCurRow:FieldType( oCol:nFieldNum )

Box(, 5, 60 )

    @ m_x + 1, m_y + 2 SAY "PRETRAGA PODATAKA *****"

    @ m_x + 3, m_y + 2 SAY UPPER( _find_field ) + " -> "
    @ m_x + 3, col() + 1 GET _find_what PICT "@S40"

    read

BoxC()

if LastKey() == K_ESC
    return
endif

_qry := "SELECT " + ::field_list_from_array()
_qry += " FROM " + ::browse_table
_qry += " WHERE " + ::findRec_where_constructor( _find_field, _field_type, _find_what ) 
_qry += " ORDER BY " + ::browse_order

::oQuery := _sql_query( _server, _qry )

if !::oQuery:Refresh()
    Alert( ::oQuery:Error() )
    return
endif

::inValidate()
::refreshAll():forceStable()

@ m_x + 1, m_y + 2 SAY "filter / " + ALLTRIM( STR( ::oQuery:LastRec() ) )

return


// ---------------------------------------------------------------------
// konstruistanje where uslova po trazenim uslovima
// ---------------------------------------------------------------------
METHOD findRec_where_constructor( find_field, field_type, find_what ) CLASS TBrowseSQL
local _qry := ""
local _arr := toktoniz( find_what, ";" )
local _i
local _is_like := .f.

// obrada vise upita, obrada like itd...

if ( "%" $ find_what )
    _is_like := .t.
endif

for _i := 1 to LEN( _arr )

    // dodaj AND ako ima vise...
    if _i > 1
        _qry += " OR "
    endif

    
    // ako je polje numericko ili datumsko
    if field_type == "N" .or. field_type == "D"
        _qry += ALLTRIM( LOWER( find_field ) ) + "::char(30) "
    else
        _qry += ALLTRIM( LOWER( find_field ) ) + " "
    endif

    if _is_like
        _qry += " LIKE " 
    else
        _qry += " = "
    endif

    _qry += _sql_quote( ALLTRIM( _arr[ _i ] ) )

next

return _qry


// ----------------------------------------------------------------------
// vraca oQuery objekt u originalno stanje...
// ----------------------------------------------------------------------
METHOD revert_table_to_original_state() CLASS TBrowseSQL

// uzmi originalni...
::oQuery := ::oQueryOriginal

if !::oQuery:Refresh()
    Alert( ::oQuery:Error() )
    return Self
endif

::inValidate()
::refreshAll():forceStable()

return Self


// ---------------------------------------------------------------------
// pretraga podataka
// ---------------------------------------------------------------------
METHOD field_list_from_array() CLASS TBrowseSQL
local _ret := ""
local _i
local _arr := ::browse_fields

if _arr == NIL
    _ret := "*"
    return _ret
endif

for _i := 1 to LEN( _arr )

    _ret += _arr[ _i, 3 ]

    if _i <> LEN( _arr )
        _ret += ","
    endif

next

return _ret



