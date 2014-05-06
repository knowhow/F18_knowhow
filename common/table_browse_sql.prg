/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"
#include "hbclass.ch"
#include "common.ch"
#include "f18_separator.ch"


CLASS F18TableBrowse

   METHOD New()
   METHOD initialize()
   METHOD show()

   DATA pos_x
   DATA pos_y
   DATA browse_params
   DATA browse_columns
   DATA browse_return_value
   DATA browse_codes_commands
   DATA current_row
   DATA select_all_query
   DATA select_filtered_query

   PROTECTED:

   METHOD box_desc_text_print()
   METHOD box_desc_options_print()
   METHOD select_all_rec()
   METHOD select_filtered()
   METHOD table_order_by()
   METHOD field_list_from_array()
   METHOD get_option_box_lines()

ENDCLASS



METHOD F18TableBrowse:New()

   // incijalizacija browse parametara
   // setuj default vrijednosti...
   ::browse_params := hb_Hash()
   ::initialize()
   ::browse_columns := {}

   // koordinate ispisa naziva
   ::pos_x := NIL
   ::pos_y := NIL

   // ostalo
   ::browse_return_value := NIL
   ::browse_codes_commands := ::browse_params[ "codes_commands" ]

   RETURN SELF



// -----------------------------------------------------------
// inicijalizacija hash matrice
// -----------------------------------------------------------
METHOD F18TableBrowse:initialize()

   ::browse_params[ "table_name" ] := ""
   ::browse_params[ "table_order_fields" ] := { "id" }
   ::browse_params[ "table_browse_return_field" ] := "id"
   ::browse_params[ "key_fields" ] := { "id" }
   ::browse_params[ "table_browse_fields" ] := NIL
   ::browse_params[ "form_width" ] := MAXCOLS() - 15
   ::browse_params[ "form_height" ] := MAXROWS() - 15
   ::browse_params[ "table_filter" ] := NIL
   ::browse_params[ "direct_sql" ] := NIL
   ::browse_params[ "codes_type" ] := .T.
   ::browse_params[ "read_sifv" ] := .F.
   ::browse_params[ "key_options" ] := NIL
   ::browse_params[ "key_options_column_count" ] := NIL
   ::browse_params[ "user_functions" ] := NIL
   ::browse_params[ "header_text" ] := ""
   ::browse_params[ "footer_text" ] := ""
   ::browse_params[ "restricted_keys" ] := NIL
   ::browse_params[ "invert_row_block" ] := NIL
   ::browse_params[ "codes_commands" ] := ;
      { "<c+N> Novi", "<F2>  Ispravka", "<ENT> Odabir", ;
      _to_str( "<c-T> Briši" ), "<c-P> Print", ;
      "<F4>  Dupliciraj", _to_str( "<c-F9> Briši SVE" ), ;
      _to_str( "<F> Traži" ), "<a-R> Zamjena vrij.", "<F5> Refresh" }

   RETURN







// ---------------------------------------------------------
// vraca ORDER BY strukturu po trazenom polju
// ---------------------------------------------------------
METHOD F18TableBrowse:table_order_by( order_field )

   LOCAL _order
   LOCAL _i

   _order := " ORDER BY "

   IF ValType( order_field ) == "A"
      FOR _i := 1 TO Len( order_field )
         _order += order_field[ _i ]
         IF _i < Len( order_field )
            _order += ", "
         ENDIF
      NEXT
   ELSE
      _order += order_field
   ENDIF

   RETURN _order




// -----------------------------------------------------------
// select svih podataka baze
// -----------------------------------------------------------
METHOD F18TableBrowse:select_all_rec()

   LOCAL _qry, _i

   _qry := "SELECT " + ::field_list_from_array()
   _qry += " FROM " + ::browse_params[ "table_name" ]

   // ima li dodatnih where uslova ?
   if ::browse_params[ "table_filter" ] <> NIL .AND. Len( ::browse_params[ "table_filter" ] ) > 0
      _qry += " WHERE "
      FOR _i := 1 TO Len( ::browse_params[ "table_filter" ] )
         _qry += " " + ::browse_params[ "table_filter" ][ _i ] + " "
         IF _i < Len( ::browse_params[ "table_filter" ] )
            _qry += " OR "
         ENDIF
      NEXT
   ENDIF

   _qry += ::table_order_by( ::browse_params[ "table_order_fields" ] )

   // imamo li direktni upit ? ako imamo onda cemo koristiti taj !
   if ::browse_params[ "direct_sql" ] <> NIL .AND. !Empty( ::browse_params[ "direct_sql" ] )
      _qry := ::browse_params[ "direct_sql" ]
   ENDIF

   ::select_all_query := _qry

   RETURN Self




// -----------------------------------------------------------
// select sa where klauzulom
// -----------------------------------------------------------
METHOD F18TableBrowse:select_filtered( search_value )

   LOCAL _qry
   LOCAL _where := ""
   LOCAL _order_field := ::browse_params[ "table_order_fields" ]

   IF !Empty( search_value )

      IF Right( AllTrim( search_value ), 2 ) == ".."
         // pretraga po nazivu
         search_value := AllTrim( StrTran( search_value, "..", "" ) )
         _where += ::browse_params[ "key_fields" ][ 2 ] + " LIKE " + _sql_quote( search_value + "%" )
         _order_field := ::browse_params[ "key_fields" ][ 2 ]

      ELSEIF Right( AllTrim( search_value ), 1 ) == "."
         // pretraga po sifri
         search_value := AllTrim( StrTran( search_value, ".", "" ) )
         _where += ::browse_params[ "key_fields" ][ 1 ] + " LIKE " + _sql_quote( search_value + "%" )
      ELSE
         // klasicna pretraga po iskljucivoj sifri
         _where += ::browse_params[ "key_fields" ][ 1 ] + " = " + _sql_quote( search_value )
      ENDIF

   ENDIF

   // ima li dodatnih where uslova ?
   if ::browse_params[ "table_filter" ] <> NIL .AND. Len( ::browse_params[ "table_filter" ] ) > 0

      IF !Empty( _where )
         _where += " AND "
      ENDIF

      FOR _i := 1 TO Len( ::browse_params[ "table_filter" ] )
         _where += " " + ::browse_params[ "table_filter" ][ _i ] + " "
         IF _i < Len( ::browse_params[ "table_filter" ] )
            _where += " OR "
         ENDIF
      NEXT

   ENDIF

   _qry := "SELECT " + ::field_list_from_array()
   _qry += " FROM " + ::browse_params[ "table_name" ]
   _qry += " WHERE " + _where

   _qry += ::table_order_by( _order_field )

   // imamo li direktni upit ? ako imamo onda cemo koristiti taj !
   if ::browse_params[ "direct_sql" ] <> NIL .AND. !Empty( ::browse_params[ "direct_sql" ] )
      _qry := ::browse_params[ "direct_sql" ]
   ENDIF

   ::select_filtered_query := _qry

   RETURN Self


// ----------------------------------------------------------
// ispis pomocnog teksta na box-u
// ----------------------------------------------------------
METHOD F18TableBrowse:box_desc_text_print()

   // tip browse-a i naziv tabele
   @ m_x + 0, m_y + 2 SAY "SQLBrowse [" + ::browse_params[ "table_name" ] + "]" COLOR "I"

   // header
   IF !Empty( ::browse_params[ "header_text" ] )
      @ m_x + 2, m_y + 2 SAY AllTrim( ::browse_params[ "header_text" ] )
   ENDIF

   // footer
   IF !Empty( ::browse_params[ "footer_text" ] )
      @ m_x + ::browse_params[ "form_height" ], m_y + 2 SAY AllTrim( ::browse_params[ "footer_text" ] )
   ENDIF

   // broj zapisa
   @ m_x + 1, m_y + ::browse_params[ "form_width" ] - 20 SAY "broj zapisa: " + AllTrim( Str( table_count( ::browse_params[ "table_name" ] ) ) )

   RETURN Self




// -----------------------------------------------------------
// prikazi tabelu u box-u
// -----------------------------------------------------------
METHOD F18TableBrowse:show( return_value, pos_x, pos_y )

   LOCAL _srv := pg_server()
   LOCAL _data
   LOCAL _qry
   LOCAL _brw
   LOCAL _found
   LOCAL _value
   LOCAL _ret := 0
   LOCAL _x_pos, _y_pos
   LOCAL _opt_key_rows := 0

   // postojeca pozicija
   _x_pos := m_x
   _y_pos := m_y
   // setuj koordinate ispisa...
   IF pos_x <> NIL
      ::pos_x := pos_x
   ENDIF
   IF pos_y <> NIL
      ::pos_y := pos_y
   ENDIF

   if ::browse_params[ "table_browse_fields" ] == NIL
      ::browse_params[ "table_browse_fields" ] := ::browse_columns
   ENDIF

   if ::browse_params[ "key_options" ] <> NIL
      _opt_key_rows := ::get_option_box_lines()
   ENDIF

   // 1) postavi mi querije...

   // SELECT ( bez WHERE )
   ::select_all_rec()
   _qry := ::select_all_query

   // SELECT ( sa WHERE )
   // ovo samo za tip - sifrarnik
   IF !Empty( return_value ) .AND. ::browse_params[ "codes_type" ]
      ::select_filtered( @return_value )
      _qry := ::select_filtered_query
   ENDIF

   // 2) postavi upit
   _data := _sql_query( _srv, _qry )

   // 3) provjeri rezultat
   IF ValType( _data ) == "L"
      MsgBeep( "Postoji problem sa upitom !" )
      _ret := -1
      RETURN _ret
   ENDIF

   // 4) refresh podataka i pozicioniranje na prvi zapis
   _data:Refresh()
   _data:GoTo( 1 )

   // 5) ako su sifrarnici u pitanju provjeri da li treba raditi browse kompletan
   // ili si pronasao zapis...
   if ::browse_params[ "codes_type" ]

      // pronasao sam samo jedan zapis
      IF _data:LastRec() == 1

         oRow := _data:GetRow( 1 )
         _value := oRow:FieldGet( oRow:FieldPos( ::browse_params[ "key_fields" ][ 1 ] ) )

         IF _value == return_value

            // pronasao sam taj zapis... nemam sta traziti to je to
            // ne moram raditi browse...
            return_value := _value

            // imamo li ispisati sta ?
            if ::pos_x <> NIL
               IF Len( ::browse_params[ "key_fields" ] ) > 1
                  @ m_x + ::pos_x, m_y + ::pos_y SAY ;
                     PadR( hb_UTF8ToStr( ;
                     oRow:FieldGet( oRow:FieldPos( ::browse_params[ "key_fields" ][ 2 ] ) ) ), ;
                     30 )
               ENDIF
            ENDIF

            RETURN _ret

         ENDIF

      ELSEIF _data:LastRec() == 0

         // napravi upit za listu kompletnog sifrarnika....
         _qry := ::select_all_query
         _data := _sql_query( _srv, _qry )
         _data:Refresh()
         _data:GoTo( 1 )

      ENDIF

   ENDIF

   Box(, ::browse_params[ "form_height" ], ;
      ::browse_params[ "form_width" ], ;
      if( ::browse_params[ "codes_type" ], .T., .F. ), ;
      if( ::browse_params[ "codes_type" ], ::browse_codes_commands, NIL ) )

   // 6) linija za podvlacenje
   if ::browse_params[ "key_options" ] <> NIL
      @ m_x + ( ::browse_params[ "form_height" ] - ( _opt_key_rows - 1 ) ), m_y + 1 SAY Replicate( BROWSE_PODVUCI, ::browse_params[ "form_width" ] )
   ENDIF

   // 7) ispis dodatni/pomocni tekst na sifrarniku...
   ::box_desc_text_print()
   ::box_desc_options_print( _opt_key_rows )

   // 8) idemo na pregled tabele
   _brw := TBrowseSQL():new( ;
      m_x + 2, ;
      m_y + 1, ;
      m_x + ::browse_params[ "form_height" ] - IF( ::browse_params[ "key_options" ] <> NIL, _opt_key_rows, 0 ), ;
      m_y + ::browse_params[ "form_width" ], ;
      _srv, ;
      _data, ;
      ::browse_params )

   _brw:BrowseTable( .F., NIL, @return_value, @::current_row, ::pos_x, ::pos_y )

   BoxC()

   // vrati koordinate
   m_x := _x_pos
   m_y := _y_pos

   _ret := 1

   RETURN _ret




// -------------------------------------------------------
// ispis opcija na box-u
// -------------------------------------------------------
METHOD F18TableBrowse:box_desc_options_print( lines_count )

   LOCAL _opt_in_row
   LOCAL _opt_space
   LOCAL _i, _n, _tmp
   LOCAL _a_opts := {}

   if ::browse_params[ "key_options" ] == NIL
      RETURN Self
   ENDIF

   // predvidjamo 3 kolone za opcije... ali moze biti i vise...
   _opt_in_row := 3

   if ::browse_params[ "key_options_column_count" ] <> NIL
      // imamo zadato parametrom
      _opt_in_row := ::browse_params[ "key_options_column_count" ]
   ENDIF

   _opt_space := ( MAXCOLS() / _opt_in_row ) - 2

   _tmp := ""

   // napravi mi prvo pomocnu matricu po 4 opcije u redu
   FOR _i := 1 TO Len( ::browse_params[ "key_options" ] )

      // dodaj uspravnu crtu
      IF !Empty( _tmp )
         _tmp += BROWSE_COL_SEP
      ENDIF

      _tmp += PadR( ::browse_params[ "key_options" ][ _i ], _opt_space )

      IF _i % _opt_in_row = 0 .OR. _i == Len( ::browse_params[ "key_options" ] )
         AAdd( _a_opts, _tmp )
         _tmp := ""
      ENDIF

   NEXT

   // ispisi red po red !
   FOR _n := 1 TO Len( _a_opts )
      @ m_x + ( ::browse_params[ "form_height" ] - ( lines_count - 1 ) + _n ), m_y + 2 SAY _a_opts[ _n ]
   NEXT

   RETURN Self




// -------------------------------------------------------
// kalkulise broj linija za opcije unutar box-a
// -------------------------------------------------------
METHOD F18TableBrowse:get_option_box_lines()

   LOCAL _lines := 1
   LOCAL _opt_in_row := 4
   LOCAL _len

   _len := Len( ::browse_params[ "key_options" ] )

   DO CASE

   CASE _len <= _opt_in_row
      _lines := 1
   CASE ( _len > _opt_in_row ) .AND. ( _len <= ( _opt_in_row * 2 ) )
      _lines := 2
   CASE ( _len > _opt_in_row * 2 ) .AND. ( _len <= ( _opt_in_row * 3 ) )
      _lines := 3
   CASE ( _len > _opt_in_row * 3 ) .AND. ( _len <= ( _opt_in_row * 4 ) )
      _lines := 4
   CASE ( _len > _opt_in_row * 4 ) .AND. ( _len <= ( _opt_in_row * 5 ) )
      _lines := 5

   ENDCASE

   ++ _lines

   RETURN _lines





// -------------------------------------------------------
// vraca listu polja na osnovu matrice
// -------------------------------------------------------
METHOD F18TableBrowse:field_list_from_array()

   LOCAL _ret := ""
   LOCAL _i
   LOCAL _arr := ::browse_params[ "table_browse_fields" ]

   IF _arr == NIL
      _ret := "*"
      RETURN _ret
   ENDIF

   FOR _i := 1 TO Len( _arr )

      _ret += _arr[ _i, 3 ]

      IF _i <> Len( _arr )
         _ret += ","
      ENDIF

   NEXT

   RETURN _ret
