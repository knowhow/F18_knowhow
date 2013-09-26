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
    VAR      browse_last_rec_value
    VAR      last_key
    VAR      table_struct
    VAR      table_sifv_struct
    VAR      new_record
    VAR      user_functions_block
    VAR      invert_row_block
    VAR      restricted_keys   
    VAR      sifk_rec_count
    VAR      sifk_var_fields
    VAR      sifk_data
    VAR      read_sifv_data

    METHOD   New( nTop, nLeft, nBottom, nRight, oServer, oQuery, cTable )

    METHOD   EditField()                   // Editing of hilighted field, after editing does an update of
                                          // corresponding row inside table

    METHOD   BrowseTable( lCanEdit, aExitKeys, cur_row ) // Handles standard moving inside table and if lCanEdit == .T.
                                               // allows editing of field. It is the stock ApplyKey() moved inside a table
                                               // if lCanEdit K_DEL deletes current row
                                               // When a key is pressed which is present inside aExitKeys it leaves editing loop

    METHOD   KeyboardHook( nKey )               // Where do all unknown keys go?

    // f18 methods...
    METHOD   editRow()
    METHOD   deleteRow()
    METHOD   deleteAll()
    METHOD   findRec()
    METHOD   replaceRec()
    METHOD   revert_table_to_original_state()
    METHOD   browse_print()

    PROTECTED:

        METHOD browse_editrow_box()
        METHOD browse_editrow_box_getlist()
        METHOD set_global_vars_from_table()
        METHOD get_table_global_memvars()
        METHOD get_sifv_table_global_memvars()
        METHOD browse_editrow_box_getlist_defaults()
        METHOD field_list_from_array()
        METHOD findRec_where_constructor()
        METHOD rec_position()
        METHOD new_id_for_rec()
        METHOD select_from_sifv()
        METHOD insert_into_sifv()
        METHOD delete_from_sifv()
        METHOD get_data_from_sifv()
        METHOD set_special_keys()
        METHOD unset_special_keys()
        METHOD new_codes_id()

ENDCLASS


METHOD New( nTop, nLeft, nBottom, nRight, oServer, oQuery, params ) CLASS TBrowseSQL
local i, oCol
local _table
local _br_fields
local _codes_type
local _key_fields
local _br_order_fields, _user_f, _restricted_keys
local _invert_row_block, _read_sifv_data

HB_SYMBOL_UNUSED( oServer )

// setuj iz hash parametara...
_table := params["table_name"]
_br_fields := params["table_browse_fields"]
_codes_type := params["codes_type"]
_key_fields := params["key_fields"]
_br_order_fields := params["table_order_field"]
_user_f := params["user_functions"]
_restricted_keys := params["restricted_keys"]
_invert_row_block := params["invert_row_block"]
_read_sifv_data := params["read_sifv"]

::super:New( nTop, nLeft, nBottom, nRight )

::oQuery := oQuery
::oQueryOriginal := oQuery 

// Let's get a row to build needed columns
::oCurRow := ::oQuery:GetRow( 1 )

if _codes_type == NIL
    _codes_type := .f.
endif

// da li je rijec o sifrarniku ili o obicnom browse-u
::codes_type_table := _codes_type
::browse_table := _table
::browse_fields := _br_fields
::browse_order := _br_order_fields
::browse_key_fields := _key_fields
::user_functions_block := _user_f
::restricted_keys := _restricted_keys
::invert_row_block := _invert_row_block
::read_sifv_data := _read_sifv_data

::browse_last_rec_value := NIL
::last_key := NIL
::new_record := .f.
::sifk_rec_count := 0
::sifk_var_fields := NIL
::sifk_data := NIL

::table_struct := _sql_table_struct( ::browse_table ) 

// positioning blocks
::SkipBlock := {| n | ::oCurRow := Skipper( @n, ::oQuery ), n }
::GoBottomBlock := {|| ::oCurRow := ::oQuery:GetRow( ::oQuery:LastRec() ), 1 }
::GoTopBlock := {|| ::oCurRow := ::oQuery:GetRow( 1 ), 1 }

// Add a column for each field
FOR i := 1 TO ::oQuery:FCount()
 
    // dodavanje kolone
    oCol := TBColumnSQL():New( ::browse_fields[ i, 1 ],, Self )

    IF !( ::oCurRow:FieldType( i ) == "M" )
        oCol:Width := ::browse_fields[ i, 2 ]
    ELSE
        oCol:Width := 10
    ENDIF

    // which field does this column display
    oCol:nFieldNum := i

    // ovo treba napraviti !!!
    //IF ::invert_row_block <> NIL
    //    oCol:colorBlock := { || IF( EVAL( ::invert_row_block ), { 5, 2 }, { 1, 2 } ) }
    //ENDIF

    // Add a picture
    DO CASE
        CASE ::oCurRow:FieldType( i ) == "N"
            oCol:picture := Replicate( "9", oCol:Width )
        CASE ::oCurRow:FieldType( i ) $ "CM"
            oCol:picture := "@S" + ALLTRIM( STR( oCol:width ) ) 
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


METHOD BrowseTable( lCanEdit, aExitKeys, return_val, cur_row, x_pos, y_pos ) CLASS TBrowseSQL
local nKey
local lKeepGoing := .t.
local _user_f

private Ch := 0

IF ! ISNUMBER( nKey )   
    nKey := NIL
ENDIF

IF ! ISLOGICAL( lCanEdit )
    lCanEdit := .f.
ENDIF

IF ! ISARRAY( aExitKeys )
    aExitKeys := { K_ESC }
ENDIF

IF ! ISARRAY( ::restricted_keys )
    ::restricted_keys := {}
ENDIF


DO WHILE lKeepGoing

    DO WHILE !::Stabilize() .AND. NextKey() == 0
    ENDDO

    nKey := Inkey(0)
    Ch := nKey

    // misa necemo obradjivati, preskoci ga !
    IF nKey >= K_MINMOUSE .and. nKey <= K_MAXMOUSE
        LOOP
    ENDIF

    IF AScan( aExitKeys, nKey ) > 0
        lKeepGoing := .f.
        LOOP
    ENDIF

    // zabranjene opcije...
    IF AScan( ::restricted_keys, nKey ) > 0
        MsgBeep( "Ova opcija je zabranjena !" )
        LOOP
    ENDIF

    // ovo je globalna koju ce F18browsesql da koristi 
    cur_row := ::oCurRow
    
    // obrada korisnickih funkcija / izvan glavne petlje browse funkcija
    _user_f := NIL
    if ::user_functions_block <> NIL
        _user_f := EVAL( ::user_functions_block )
    endif

    
    DO CASE

        CASE ( _user_f <> NIL .and. _user_f == DE_REFRESH )
            ::refreshAll()

        CASE ( _user_f <> NIL .and. _user_f == DE_ABORT )
            lKeepGoing := .f.
            LOOP

        CASE ::codes_type_table .and. !return_val == NIL .and. ( nKey == K_RETURN .or. nKey == K_ENTER )

            return_val := ::oCurRow:FieldGet( ::oCurRow:FieldPos( ::browse_key_fields[1] ) )

            // ispis ako treba... kljuc polje 2 je uvijek "naz" ili koje vec
            if x_pos <> NIL
                if LEN( ::browse_key_fields ) > 1
                    @ m_x + x_pos, m_y + y_pos SAY ;
                        PADR( hb_utf8tostr( ;
                            ::oCurRow:FieldGet( ::oCurRow:FieldPos( ::browse_key_fields[2] ) ) ), ;
                        30 )
                endif
            endif
            
            lKeepGoing := .f.
            LOOP

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

        OTHERWISE

            // ostale tipke...
            ::KeyboardHook( nKey )

    ENDCASE


ENDDO

RETURN Self


// Empty method to be subclassed
METHOD KeyboardHook( nKey ) CLASS TBrowseSQL
local _last_rec := ::oQuery:recno()
local _data

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
        ::new_record := .t.
        _data := ::editRow()
        ::rec_position( _data )

    case ::codes_type_table .and. nKey == K_F2

        // dodavanje novog zapisa
        ::last_key := nKey
        ::new_record := .f.
        _data := ::editRow()

    case ::codes_type_table .and. nKey == K_F4

        // dupliciranje zapisa
        ::last_key := nKey
        ::new_record := .f.
        _data := ::editRow()
        
        if _data <> NIL .and. Pitanje(, "Pozicionirati se na novi zapis (D/N) ?", "D" ) == "D"
            ::rec_position( _data )
        endif

    case ::codes_type_table .and. nKey == K_ENTER

        // odabir stavke...
        // sta ? nista ?
    
    
    case ::codes_type_table .and. nKey == K_CTRL_P

        // printanje browse-a
        ::browse_print()


    // funkcije koje vaze za svaki browse...

    case nKey == K_SH_F1
    
        // kalkulator
        calc()

    case nKey == K_ALT_R
        
        // trazi/zamjeni
        ::replaceRec()

    case UPPER( CHR( nKey ) ) == "F"

        // pretraga sifrarnika
        ::findRec()

    case nKey == K_F5

        // vrati na prvobitno stanje tabele - prije filtera
        ::revert_table_to_original_state()

    case nKey == K_CTRL_J

        // test funkcija - do uvodjenja...
        Msgbeep( "tabela: " + ::browse_table )

        MsgBeep( "recno " + ALLTRIM( STR( ::oQuery:recno() ))  )
        
endcase

RETURN Self


// --------------------------------------------------------------------
// delete row
// --------------------------------------------------------------------
METHOD deleteRow() CLASS TBrowseSQL
local _field_val := ::oCurRow:FieldGet( ::oCurRow:FieldPos( ::browse_key_fields[1] ) )
local _field_name := ::oCurRow:FieldName( ::oCurRow:FieldPos( ::browse_key_fields[1] ) )

IF ! ::oQuery:Delete( ::oCurRow )
    Alert( "Greska prilikom brisanja: " + ::oQuery:Error() )
    log_write( "F18_DOK_OPER, Greska prilikom brisanja zapisa tabele " + ::browse_table + ", " + ::oQuery:Error(), 3 )
    return Self
ENDIF

// moram brisati i SIFV tabelu takodjer
IF ::codes_type_table .and. ::read_sifv_data
    // brisi mi i SIFK za ovaj zapis...
    ::delete_from_sifv( _field_val )
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

_qry := "DELETE FROM " + _table + "; "
_qry += "DELETE FROM fmk.sifv " 
_qry += "WHERE lower( 'fmk.' || id ) = " + _sql_quote( ::browse_table )
_qry += "; "

_sql_query( _server, "BEGIN;" )

_data := _sql_query( _server, _qry )
if VALTYPE( _data ) == "L"
    _sql_query( _server, "ROLLBACK;" )
else
    _sql_query( _server, "COMMIT;" )
endif

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
METHOD editRow() CLASS TBrowseSQL
local _data := NIL
local _rec, _rec_sifv
local _key_field

// uzmi memorijske varijable...
::set_global_vars_from_table()

// prikazi box
if ::browse_editrow_box()

    // kljucno polje
    _key_field := & ( "x" + ::browse_key_fields[1] )

    // daj mi sve iz memvars za ovaj zapis...
    _rec := ::get_table_global_memvars()

    if ::new_record .or. ( !::new_record .and. ::last_key == K_F4 )
        _data := sql_update_table_from_hash( ::browse_table, "ins", _rec, NIL )
    else
        _data := sql_update_table_from_hash( ::browse_table, "upd", _rec, ::browse_key_fields )
    endif

    // napravi update sifv podataka ako je potrebno
    if VALTYPE( _data ) == "O" .and. ::codes_type_table .and. ::read_sifv_data
        _rec_sifv := ::get_sifv_table_global_memvars()
        ::insert_into_sifv( _rec_sifv, _key_field )
    endif

    if !::oQuery:Refresh()
        Alert( ::oQuery:Error() )
    endif

    ::inValidate()
    ::RefreshAll():forcestable()

endif

RETURN _data



// -------------------------------------------------------------------
// vraca memorijske varijable u hash matricu
// -------------------------------------------------------------------
METHOD get_sifv_table_global_memvars() CLASS TBrowseSQL
local _hash := hb_hash()
local _i, _field
local _scan
local _prefix := "sifv_"
local _struct := ::sifk_var_fields

for _i := 1 TO LEN( _struct )

    _field := _struct[ _i ]
    _hash[ LOWER( _field ) ] := EVAL( MEMVARBLOCK( _prefix + LOWER( _field ) ) )
    
    // ukini memvar
    __MVXRELEASE( _prefix + LOWER( _field ) )

next

return _hash



// -------------------------------------------------------------------
// vraca memorijske varijable u hash matricu
// -------------------------------------------------------------------
METHOD get_table_global_memvars() CLASS TBrowseSQL
local _hash := hb_hash()
local _i, _field
local _scan
local _struct := ::table_struct

for _i := 1 TO LEN( _struct )

    _field := _struct[ _i, 1 ]

    _scan := ASCAN( ::browse_fields, { | var | var[3] == _field  } )

    if _scan > 0
 
        _hash[ LOWER( _field ) ] := EVAL( MEMVARBLOCK( "x" + _field ) )
    
        // ukini memvar
        __MVXRELEASE( "x" + _field )

    endif

next

return _hash



// -------------------------------------------------------------------
// vraca podatke iz sifv tabele
// -------------------------------------------------------------------
METHOD get_data_from_sifv( marker, field_id ) CLASS TBrowseSQL
local _val
local _server := my_server()
local _qry

_qry := "SELECT naz FROM fmk.sifv "
_qry += "WHERE lower( 'fmk.' || id ) = " + _sql_quote( ::browse_table )
_qry += " AND oznaka = " + _sql_quote( marker )
_qry += " AND idsif = " + _sql_quote( field_id )
_qry += " LIMIT 1; "

_val := _sql_query( _server, _qry ):GetRow(1):FieldGet(1)

return _val



// -------------------------------------------------------------------
// vraca podatke iz sifv tabele
// -------------------------------------------------------------------
METHOD select_from_sifv() CLASS TBrowseSQL
local _sifk_data 
local _server := my_server()
local _qry, _scan
local _prefix := "sifv_"
local _var, oRow, _field, _field_value, _field_type
local _field_len, _field_dec

_qry := "SELECT "
_qry += " sifk.id, "
_qry += " sifk.sort, "
_qry += " sifk.naz, "
_qry += " sifk.oznaka, "
_qry += " sifk.tip, "
_qry += " sifk.duzina, "
_qry += " sifk.f_decimal "
_qry += "FROM fmk.sifk sifk "
_qry += "WHERE lower( 'fmk.' || sifk.id ) = " + _sql_quote( ::browse_table )
_qry += " ORDER BY sifk.oznaka, sifk.sort; "

_sifk_data := _sql_query( _server, _qry )
_sifk_data:Refresh()

if VALTYPE( _sifk_data ) == "L"
    return NIL
endif

// setuj broj zapisa u sifv_tabeli
::sifk_rec_count := _sifk_data:LastRec()
// uzmimo i zapise, mogu zatrebati
::sifk_data := _sifk_data
// polja tabele sifv
::sifk_var_fields := {}

// prodji kroz tabelu i setuj varijable
_sifk_data:GoTo(1)

do while !_sifk_data:EOF()

    oRow := _sifk_data:GetRow()

    _field := oRow:FieldGet( oRow:FieldPos( "oznaka" ) )
    _field_type := oRow:FieldGet( oRow:FieldPos( "tip" ) )
    _field_len := oRow:FieldGet( oRow:FieldPos( "duzina" ) )
    _field_dec := oRow:FieldGet( oRow:FieldPos( "f_decimal" ) )
 
    _var := _prefix + _field
    __MVPUBLIC( _var )

    if _field_type $ "C#M"

        EVAL( MEMVARBLOCK( _var ), ;
                if( ::new_record, ;
                    PADR( "", _field_len ), ;
                    PADR( hb_utf8tostr( ::get_data_from_sifv( _field, ::oCurRow:FieldGet( ::oCurRow:FieldPos( ::browse_key_fields[1] ) ) ) ), _field_len ) ; 
                ) ; 
                ) 
    elseif _field_type == "D"

        EVAL( MEMVARBLOCK( _var ), ;
                if( ::new_record, ;
                    CTOD(""), ;
                    ::get_data_from_sifv( _field, ::oCurRow:FieldGet( ::oCurRow:FieldPos( ::browse_key_fields[1] ) ) ) ; 
                ) ; 
                ) 
 
    else

        EVAL( MEMVARBLOCK( _var ), ;
                if( ::new_record, ;
                    0, ;
                    ::get_data_from_sifv( _field, ::oCurRow:FieldGet( ::oCurRow:FieldPos( ::browse_key_fields[1] ) ) ) ; 
                ) ; 
                ) 
 
    endif

    // dodaj u matricu sifv polja...
    AADD( ::sifk_var_fields, _field )

    // dodaj na browse_fields takodjer i ove stavke iz sifk
    _scan := ASCAN( ::browse_fields, { |var| var[1] == _field } )
    if _scan == 0
        AADD( ::browse_fields, { _field, _field_len, _prefix + ALLTRIM( LOWER( _field ) ) } )
    endif

    _sifk_data:Skip()

enddo
    
return Self


// -------------------------------------------------------------------
// brisanje zapisa iz tabele SIFV
// -------------------------------------------------------------------
METHOD delete_from_sifv( id_field ) CLASS TBrowseSQL
local _data 
local _qry, _server

_server := my_server()

_qry := "DELETE FROM fmk.sifv "
_qry += "WHERE lower( 'fmk.' || id ) = " + _sql_quote( ::browse_table )
_qry += " AND idsif = " + _sql_quote( id_field )
_qry += "; "

log_write( "F18_DOK_OPER, delete SIFK " + id_field, 3 )

_sql_query( _server, "BEGIN;" )

_data := _sql_query( _server, _qry )

if VALTYPE( _data ) == "L"
    _sql_query( _server, "ROLLBACK;" )
else
    _sql_query( _server, "COMMIT;" )
endif

return _data





// -------------------------------------------------------------------
// upisuje podatke za sifv
// -------------------------------------------------------------------
METHOD insert_into_sifv( hash_data, key_field ) CLASS TBrowseSQL
local _data 
local _qry, _server, _key

_server := my_server()

_qry := ""

for each _key in hash_data:keys

    _qry += "DELETE FROM fmk.sifv "
    _qry += "WHERE lower( 'fmk.' || id ) = " + _sql_quote( ::browse_table )
    _qry += " AND idsif = " + _sql_quote( key_field  )
    _qry += " AND oznaka = " + _sql_quote( UPPER( _key ) )
    _qry += "; "
    _qry += "INSERT INTO fmk.sifv ( id, idsif, oznaka, naz ) "
    _qry += "VALUES( " 
    _qry += _sql_quote( UPPER( TokToNiz( ::browse_table, "." )[2] ) )
    _qry += ", "
    _qry += _sql_quote( key_field )
    _qry += ", "
    _qry += _sql_quote( UPPER( _key ) )
    _qry += ", "
    _qry +=   + if( VALTYPE( hash_data[ _key ] ) == "C", _sql_quote( hash_data[ _key ] ), STR( hash_data[ _key ] ) ) 
    _qry += " ) "
    _qry += "; "

next

log_write( "F18_DOK_OPER, delete/insert SIFK " + _qry, 3 )

if !EMPTY( _qry )

    _sql_query( _server, "BEGIN;" )

    _data := _sql_query( _server, _qry )

    if VALTYPE( _data ) == "L"
        _sql_query( _server, "ROLLBACK;" )
    else
        _sql_query( _server, "COMMIT;" )
    endif

endif

return _data



// -------------------------------------------------------------------
// vraca memorijske varijable na osnovu strukture
// -------------------------------------------------------------------
METHOD set_global_vars_from_table() CLASS TBrowseSQL
local _i
local _field, _var
local _prefix := "x"
local _struct := ::table_struct

for _i := 1 to LEN( _struct )

    _field := _struct[ _i, 1 ]

    _scan := ASCAN( ::browse_fields, { | var | var[3] == _field  } )

    if _scan > 0
    
        _var := _prefix + _field
        __MVPUBLIC( _var )

        if _struct[ _i, 2 ] $ "C#M"
            EVAL( MEMVARBLOCK( _var ), ;
                if( ::new_record, ;
                    PADR( "", _struct[ _i, 3 ] ), ;
                    PADR( hb_utf8tostr( ::oCurRow:FieldGet( ::oCurRow:FieldPos( _field ) ) ), _struct[ _i, 3 ] ) ; 
                ) ; 
                ) 
        elseif _struct[ _i, 2 ] == "D"
            EVAL( MEMVARBLOCK( _var ), ;
                if( ::new_record, ;
                    CTOD(""), ;
                    ::oCurRow:FieldGet( ::oCurRow:FieldPos( _field ) ) ; 
                ) ; 
                )  
        else
            EVAL( MEMVARBLOCK( _var ), ;
                if( ::new_record, ;
                    0, ;
                    ::oCurRow:FieldGet( ::oCurRow:FieldPos( _field ) ) ;
                 ) ;
                ) 
        endif

    endif

next

// ovdje treba obraditi i SIFK tabelu
if ::codes_type_table .and. ::read_sifv_data
    ::select_from_sifv()
endif

// default vrijednosti za pojedine tabele itd...
// obraditi
if ::new_record
    ::browse_editrow_box_getlist_defaults()
endif

return .t.


// ---------------------------------------------------------------------
// box edit-a
// ---------------------------------------------------------------------
METHOD browse_editrow_box() CLASS TBrowseSQL
local _ok := .f.
local _x := 1
local _i, _n
local _row_count := 0
local _prefix := "x"
local _prefix_sifv := "sifv_"
private GetList := {}

// setuj tipku F8 za pronalazenje nove sifre automatski

Box(, ::oQuery:FCount() + ::sifk_rec_count, 70 )

    for _i := 1 to ::oQuery:FCount()
        ++ _row_count
        _var := _prefix + ::browse_fields[ _i, 3 ]
        ::browse_editrow_box_getlist( _var, @GetList, _row_count )
    next

    if ::sifk_var_fields <> NIL .and. ::sifk_rec_count > 0
        for _n := 1 to LEN( ::sifk_var_fields )
            ++ _row_count
            _var := _prefix_sifv + LOWER( ::sifk_var_fields[ _n ] )
            ::browse_editrow_box_getlist( _var, @GetList, _row_count )
        next
    endif

    ::set_special_keys() 

    read

    ::unset_special_keys()

BoxC()

if LastKeY() == K_ESC
    return _ok
endif

_ok := .t.

return _ok



// --------------------------------------------------------------------------
// setovanje specijalnih tipki na unosu/ispravke sifre
// --------------------------------------------------------------------------
METHOD new_codes_id() CLASS TBrowseSQL
local _var 
local _type

_var := &( "x" + ::browse_key_fields[1] )

// pretrazi putem sql-a novi zapis...
MsgBeep( "Funkcija u izradi ..." )

return Self




// --------------------------------------------------------------------------
// setovanje specijalnih tipki na unosu/ispravke sifre
// --------------------------------------------------------------------------
METHOD set_special_keys() CLASS TBrowseSQL

// ! ne zaboravi da sve sto setujes, ponovo iskljucis u ::unset_special_keys()

if ::codes_type_table
    SET KEY K_F8 TO ::new_codes_id()
endif

return Self


// --------------------------------------------------------------------------
// ponisti setovanje specijalnih tipki na unosu/ispravke sifre
// --------------------------------------------------------------------------
METHOD unset_special_keys() CLASS TBrowseSQL

if ::codes_type_table
    SET KEY K_F8 TO
endif

return Self




// --------------------------------------------------------------------------
// get list....
// --------------------------------------------------------------------------
METHOD browse_editrow_box_getlist( var, get_list, curr_row ) CLASS TBrowseSQL
local bWhen, bValid
local _pict
local _when_block, _valid_block
local _m_block
local _row, _col
local _len_desc := 15
local _scan
local _struct := ::table_struct

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

_scan := ASCAN( _struct, {|var| var[1] == ::browse_fields[ curr_row, 3 ] } )

if _scan > 0

  do case

    case _struct[ _scan, 2 ] == "C"
        _pict := "@S" + ALLTRIM( STR( _struct[ _scan, 3 ] ) )

    case _struct[ _scan, 2 ] == "N"
        _pict := REPLICATE( "9", _struct[ _scan, 3 ] - _struct[ _scan, 4 ] ) + ;
                IF( _struct[ _scan, 4 ] > 0, "." + REPLICATE( "9", _struct[ _scan, 4 ] ), "" )
    otherwise
        _pict := ""

  endcase

else
    _pict := ""
endif

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
local GetList := {}

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


// -----------------------------------------------------------------
// metoda pozicioniranja kursora na trazeni zapis...
// -----------------------------------------------------------------
METHOD rec_position( data ) CLASS TBrowseSQL
local _key_fields := ::browse_key_fields // { "id", "naz", itd... } 
local _last_rec_value 
local _search_key
local _search_value
local _i

if data == NIL
    return Self
endif

_last_rec_value := data:GetRow(1):FieldGet(FieldPos( ::browse_key_fields[1] )) 

::goTop()

::hitBottom := .f.
::hitTop := .f.

MsgO( "P O Z I C I O N I R A N J E   U   T O K U  . . ." )

do while ! ( ::hitBottom .or. ::hitTop )

    if ::oCurRow:FieldGet( ::oCurRow:FieldPos( ::browse_key_fields[1] ) ) == _last_rec_value
        exit
    endif

    ::down()
    ::stabilize()

enddo

MsgC()

return Self



// -----------------------------------------------------------------
// metoda zamjene zapisa u tabeli...
// -----------------------------------------------------------------
METHOD replaceRec() CLASS TBrowseSQL
local _server := my_server()
local _qry, _find_value, _replace_value
local oCol
local _field_type, _find_type 
local _struct := ::table_struct
local _f_type, _f_dec, _f_len

// daj tekuci zapis i kolonu
oCol := ::getColumn( ::colPos )

// uzmi podake polja, naziv, vrijednost
_find_field := ::oCurRow:FieldName( oCol:nFieldNum )
_find_value := ::oCurRow:FieldGet( ::oCurRow:FieldPos( _find_field ) )

// pronadji mi u strukturi podatke o polju
_scan := ASCAN( _struct, { |var| var[1] == _find_field } )
_f_type := _struct[ _scan, 2 ]
_f_len := _struct[ _scan, 3 ]
_f_dec := _struct[ _scan, 4 ]

// sredi mi pict i vrijednosti varijabli
if _f_type == "C"

    _find_value := hb_strtoutf8( _find_value )
    _replace_value := SPACE( _f_len )
    _picture := "@S" + ALLTRIM( STR( if( _f_len > 50, 50, _f_len ) ) )

elseif _f_type == "N"

    _replace_value := 0
    _picture := REPLICATE( "9", _f_len - _f_dec ) + if( _f_dec > 0, "." + REPLICATE( "9", _f_dec ), "" )

elseif _f_type == "D"
    
    _replace_value := CTOD("")
    _picture := ""

else

    MsgBeep( "Ovaj tip nije podrzan !!!")
    return Self

endif

Box(, 5, 65 )

    @ m_x + 1, m_y + 2 SAY "ZAMJENA PODATAKA U TABELI *****"

    @ m_x + 3, m_y + 2 SAY "  TRAZI ->"
    @ m_x + 3, col() + 1 GET _find_value PICT _picture

    @ m_x + 4, m_y + 2 SAY "ZAMJENI ->"
    @ m_x + 4, col() + 1 GET _replace_value PICT _picture

    @ m_x + 5, m_y + 2 SAY "  ( ... polje: " + _find_field + " )"

    read

BoxC()

if LastKey() == K_ESC
    return
endif

_qry := "WITH tmp AS ( "
_qry += "UPDATE " + ::browse_table 
_qry += " SET " + _find_field + " = " + if( _f_type $ "CD", _sql_quote( _replace_value ), STR( _replace_value ) )
_qry += " WHERE " + _find_field + " = " + if( _f_type $ "CD", _sql_quote( _find_value ), STR( _find_value ) )
_qry += " RETURNING * "
_qry += " ) "
_qry += " SELECT COUNT(*) FROM tmp;"

_sql_query( _server, "BEGIN;" )
_result := _sql_query( _server, _qry )

if VALTYPE( _result ) == "L"
    _sql_query( _server, "ROLLBACK;" )
else
    _sql_query( _server, "COMMIT;" )
endif

if !::oQuery:Refresh()
    Alert( ::oQuery:Error() )
    return
endif

::goTop()
::inValidate()
::refreshAll():forceStable()

if VALTYPE( _result ) == "O"
    MsgBeep( "Zamjena uradjena na " + ALLTRIM( STR( _result:GetRow(1):FieldGet(1) ) ) + " zapisa !" )
endif

return Self



// ------------------------------------------------------------------
// dodjeljivanje novog ID-a za zapis
// ------------------------------------------------------------------
METHOD new_id_for_rec() CLASS TBrowseSQL

return Self



// -----------------------------------------------------------------
// printanje browse-a
// nikakav je ! :) ali kakav-takav
// -----------------------------------------------------------------
METHOD browse_print() CLASS TBrowseSQL
local _i
local oRow
local _scan, _len, _field

START PRINT CRET

?

P_COND2
? gPo_land

? "STAMPA TABELE " + ::browse_table
? REPLICATE( "-", 50 )

::oQuery:goTo(1)

// uzmimo prvi red za header
oRow := ::oQuery:GetRow(1)

_tmp := ""

for _i := 1 to oRow:FCount()

    _field := oRow:FieldName( _i )
    
    _scan := ASCAN( ::table_struct, { |var| var[1] == _field } )
    _len := ::table_struct[ _scan, 3 ]

    _tmp += PADR( _field, if( _len > 50, 50, _len ) )
    _tmp += " "

next

?
? REPLICATE( "-", LEN( _tmp ) )
? _tmp
? REPLICATE( "-", LEN( _tmp ) )

_i := 1

do while !::oQuery:EOF()

    oRow := ::oQuery:GetRow()

    _tmp := ""

    for _i := 1 to oRow:FCount()

        _type := oRow:FieldType( _i )
        _field := oRow:FieldName( _i )

        _scan := ASCAN( ::table_struct, { |var| var[1] == _field } )
        _len := ::table_struct[ _scan, 3 ]
        _dec := ::table_struct[ _scan, 4 ]

        if _type $ "CM"
            _tmp += PADR( hb_utf8tostr( oRow:FieldGet( _i ) ), if( _len > 50, 50, _len ) )
        elseif _type == "N"
            _tmp += PADL( ALLTRIM( STR( oRow:FieldGet( _i ), _len, _dec ) ), _len )
        elseif _type == "D"
            _tmp += DTOC( oRow:FieldGet( _i ) )
        endif

        _tmp += " "

    next 

    ? _tmp

    ::oQuery:Skip()

enddo

FF
END PRINT

return Self


