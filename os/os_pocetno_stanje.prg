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

#include "f18.ch"

STATIC __table_os
STATIC __table_promj
STATIC __table_os_alias
STATIC __table_promj_alias



// -----------------------------------------------------
// generisanje pocetnog stanja
// -----------------------------------------------------
FUNCTION os_generacija_pocetnog_stanja()

   LOCAL _info := {}
   LOCAL _ok
   LOCAL _pos_x, _pos_y
   LOCAL _dat_ps := Date()
   LOCAL _db_params := my_server_params()
   LOCAL _tek_database := my_server_params()[ "database" ]
   LOCAL _year_tek := Year( _dat_ps )
   LOCAL _year_sez := _year_tek - 1

   ps_info()

   IF AllTrim( Str( _year_sez ) ) $ _tek_database
      // ne moze se raditi razdvajanje u 2012
      MsgBeep( "Ne mogu vrsti prenos u sezonskim podacima..." )
      RETURN _ok
   ENDIF

   IF Pitanje(, "Generisati pocetno stanje (D/N) ?", "N" ) == "N"
      RETURN
   ENDIF

   // sifra za koristenje...
   IF !spec_funkcije_sifra( "OSGEN" )
      MsgBeep( "Opcija onemogucena !!!" )
      RETURN
   ENDIF

   // setuj staticke varijable na koje se tabele odnosi...
   // nakon ovoga su nam dostupne
   // __table_os, __table_promj
   _set_os_promj_tables()

   Box(, 10, 60 )

   @ _pos_x := m_x + 1, _pos_y := m_y + 2 SAY "... prenos pocetnog stanja u toku" COLOR F18_COLOR_I

   // 1) pobrisati tekucu godinu
   _ok := _os_brisi_tekucu_godinu( @_info )

   // prebaciti iz prethodne godine tabele os/promj
   IF _ok
      _ok := _os_prebaci_iz_prethodne( @_info )
   ENDIF

   // napraviti generaciju podataka
   IF _ok
      _ok := _os_generacija_nakon_ps( @_info )
   ENDIF

   // pakuj tabele...
   IF _ok
      _pakuj_tabelu( __table_os_alias, __table_os )
      _pakuj_tabelu( __table_promj_alias, __table_promj )
   ENDIF

   IF _ok
      @ _pos_x + 8, m_y + 2 SAY "... operacija uspjesna"
   ELSE
      @ _pos_x + 8, m_y + 2 SAY "... operacija NEUSPJESNA !!!"
   ENDIF

   @ _pos_x + 9, m_y + 2 SAY "Pritisnite <ESC> za izlazak i pregled rezulatata."

   // cekam ESC
   WHILE Inkey( 0.1 ) != K_ESC
   END

   BoxC()

   my_close_all_dbf()

   IF Len( _info ) > 0
      _rpt_info( _info )
   ENDIF

   RETURN



STATIC FUNCTION ps_info()

   LOCAL _msg := "Opcija vrsi prebacivanje pocetnog stanja iz prethodne godine.#1. opcija se vrsi iz nove sezone 2. brisu se podaci tekuce godine#3. prebacuju se podaci iz prethodne godine"

   RETURN MsgBeep( _msg )



// ---------------------------------------------------------------
// setuju se staticke varijable na koji modul se odnosi...
// ---------------------------------------------------------------
STATIC FUNCTION _set_os_promj_tables()

   my_close_all_dbf()

   o_os_sii()
   o_os_sii_promj()

   // tabela OS_OS/SII_SII
   select_os_sii()
   __table_os := get_os_table_name( Alias() )
   __table_os_alias := Alias()

   // tabela OS_PROMJ/SII_PROMJ
   select_promj()
   __table_promj := get_promj_table_name( Alias() )
   __table_promj_alias := Alias()

   my_close_all_dbf()

   RETURN


// ------------------------------------------------------
// pregled efekata prenosa pocetnog stanja
// ------------------------------------------------------
STATIC FUNCTION _rpt_info( info )

   LOCAL _i

   START PRINT CRET

   ?
   ? "Pregled efekata prenosa u novu godinu:"
   ? Replicate( "-", 70 )
   ? "Operacija                        Iznos       Ostalo"
   ? Replicate( "-", 70 )

   FOR _i := 1 TO Len( info )
      ? PadR( info[ _i, 1 ], 50 ), info[ _i, 2 ], PadR( info[ _i, 3 ], 30 )
   NEXT

   FF
   ENDPRINT

   RETURN


// ---------------------------------------------------
// brisanje podataka tekuce godine
// ---------------------------------------------------
STATIC FUNCTION _os_brisi_tekucu_godinu( info )

   LOCAL _ok := .F.
   LOCAL _table, _table_promj
   LOCAL _count := 0
   LOCAL _count_promj := 0
   LOCAL _t_rec
   LOCAL _pos_x, _pos_y

   my_close_all_dbf()

   o_os_sii()
   o_os_sii_promj()

   IF !f18_lock_tables( { __table_os, __table_promj } )
      MsgBeep( "Problem sa lokovanjem tabela " + __table_os + ", " + __table_promj + " !!!#Prekidamo proceduru." )
      RETURN _ok
   ENDIF

   run_sql_query( "BEGIN" )

   select_os_sii()
   SET ORDER TO TAG "1"
   GO TOP

   @ _pos_x := m_x + 2, _pos_y := m_y + 2 SAY PadR( "1) Brisem podatke tekuce godine ", 40, "." )

   DO WHILE !Eof()

      SKIP
      _t_rec := RecNo()
      SKIP -1

      _rec := dbf_get_rec()
      delete_rec_server_and_dbf( __table_os, _rec, 1, "CONT" )

      ++ _count

      GO ( _t_rec )

   ENDDO

   select_promj()
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      SKIP
      _t_rec := RecNo()
      SKIP -1

      _rec := dbf_get_rec()

      delete_rec_server_and_dbf( __table_promj, _rec, 1, "CONT" )

      ++ _count_promj

      GO ( _t_rec )

   ENDDO

   f18_unlock_tables( { __table_os, __table_promj } )
   run_sql_query( "COMMIT" )

   @ _pos_x, _pos_y + 55 SAY "OK"

   AAdd( info, { "1) izbrisano sredstava:", _count, ""  } )
   AAdd( info, { "2) izbrisano promjena:", _count_promj, ""  } )

   _ok := .T.

   my_close_all_dbf()

   RETURN _ok




// -------------------------------------------------------
// prebaci podatke iz prethodne sezone u tekucu
// -------------------------------------------------------
STATIC FUNCTION _os_prebaci_iz_prethodne( info )

   LOCAL _ok := .F.
   LOCAL _data_os, _data_promj
   LOCAL _qry_os, _qry_promj, _where
   LOCAL _dat_ps := Date()
   LOCAL _db_params := my_server_params()
   LOCAL _tek_database := my_server_params()[ "database" ]
   LOCAL _year_tek := Year( _dat_ps )
   LOCAL _year_sez := _year_tek - 1
   LOCAL _table, _table_promj
   LOCAL _pos_x, _pos_y

   // query za OS/PROMJ
   _qry_os := " SELECT * FROM " + F18_PSQL_SCHEMA_DOT + "" + __table_os
   _qry_promj := " SELECT * FROM " + F18_PSQL_SCHEMA_DOT + "" + __table_promj

   // 1) predji u sezonsko podrucje
   // ------------------------------------------------------------
   // prebaci se u sezonu
   switch_to_database( _db_params, _tek_database, _year_sez )



   @ _pos_x := m_x + 3, _pos_y := m_y + 2 SAY PadR( "2) vrsim sql upit ", 40, "." )

   // podaci pocetnog stanja su ovdje....
   _data_os := run_sql_query( _qry_os )
   _data_promj := run_sql_query( _qry_promj )

   @ _pos_x, _pos_y + 55 SAY "OK"

   // 3) vrati se u tekucu bazu...
   // ------------------------------------------------------------
   switch_to_database( _db_params, _tek_database, _year_tek )

   IF sql_error_in_query ( _data_os )
      MsgBeep( "SQL ERR OS" )
      RETURN .F.
   ENDIF

   // ubaci sada podatke u OS/PROMJ

   IF !f18_lock_tables( { __table_os, __table_promj } )
      MsgBeep( "Problem sa lokovanjem tabela..." )
      RETURN _ok
   ENDIF

   run_sql_query( "BEGIN" )

   @ _pos_x := m_x + 4, _pos_y := m_y + 2 SAY PadR( "3) insert podataka u novoj sezoni ", 40, "." )

   _insert_into_os( _data_os )
   _insert_into_promj( _data_promj )

   f18_unlock_tables( { __table_os, __table_promj } )
   run_sql_query( "COMMIT" )

   @ _pos_x, _pos_y + 55 SAY "OK"

   AAdd( info, { "3) prebacio iz prethodne godine sredstva", _data_os:LastRec(), "" } )
   AAdd( info, { "4) prebacio iz prethodne godine promjene", _data_promj:LastRec(), "" } )

   _ok := .T.

   RETURN _ok



// -----------------------------------------------------
// uzima row i vraca kao hb_hash
// -----------------------------------------------------
STATIC FUNCTION _row_to_rec( row )

   LOCAL _rec := hb_Hash()
   LOCAL _field_name
   LOCAL _field_val

   FOR _i := 1 TO row:FCount()

      _field_name := row:FieldName( _i )
      _field_value := row:FieldGet( _i )

      IF ValType( _field_value ) == "C"
         _field_value := hb_UTF8ToStr( _field_value )
      ENDIF

      _rec[ _field_name ] := _field_value

   NEXT

   hb_HDel( _rec, "match_code" )

   RETURN _rec



// -----------------------------------------------------
// insert podataka u tabelu os
// -----------------------------------------------------
STATIC FUNCTION _insert_into_os( data )

   LOCAL _i
   LOCAL _table
   LOCAL _row, _rec

   my_close_all_dbf()
   o_os_sii()

   data:GoTo(1)

   DO WHILE !data:Eof()

      _row := data:GetRow()
      _rec := _row_to_rec( _row )

      // sredi neka polja...
      _rec[ "naz" ] := PadR( _rec[ "naz" ], 30 )

      select_os_sii()
      APPEND BLANK

      update_rec_server_and_dbf( __table_os, _rec, 1, "CONT" )

      @ m_x + 5, m_y + 2 SAY "  " + __table_os + "/ sredstvo: " + _rec[ "id" ]

      data:Skip()

   ENDDO

   my_close_all_dbf()

   RETURN


// -----------------------------------------------------
// insert podataka u tabelu os_promj
// -----------------------------------------------------
STATIC FUNCTION _insert_into_promj( data )

   LOCAL _i
   LOCAL _table
   LOCAL _row, _rec

   my_close_all_dbf()
   o_os_sii_promj()

   data:GoTo(1)

   DO WHILE !data:Eof()

      _row := data:GetRow()
      _rec := _row_to_rec( _row )

      select_promj()
      APPEND BLANK

      update_rec_server_and_dbf( __table_promj, _rec, 1, "CONT" )

      @ m_x + 5, m_y + 2 SAY __table_promj + "/ promjena za sredstvo: " + _rec[ "id" ]

      data:Skip()

   ENDDO

   my_close_all_dbf()

   RETURN




// ------------------------------------------------------
// regenerisanje podataka u novoj sezoni
// ------------------------------------------------------
STATIC FUNCTION _os_generacija_nakon_ps( info )

   LOCAL _t_rec
   LOCAL _rec, _r_br
   LOCAL _sr_id
   LOCAL _table
   LOCAL _ok := .F.
   LOCAL _table_promj
   LOCAL _data := {}
   LOCAL _i, _count, _otpis_count
   LOCAL _pos_x, _pos_y

   // nalazim se u tekucoj godini, zelim "slijepiti" promjene i izbrisati
   // otpisana sredstva u protekloj godini

   my_close_all_dbf()
   o_os_sii()
   o_os_sii_promj()

   select_os_sii()
   GO TOP

   IF !f18_lock_tables( { __table_os, __table_promj } )
      MsgBeep( "Problem sa lokovanjem OS tabela !!!" )
      RETURN _ok
   ENDIF

   run_sql_query( "BEGIN" )

   _otpis_count := 0

   @ _pos_x := m_x + 6, _pos_y := m_y + 2 SAY PadR( "4) generacija podataka za novu sezonu ", 40, "." )

   DO WHILE !Eof()

      _sr_id := field->id
      _r_br := 0

      SKIP
      _t_rec := RecNo()
      SKIP -1

      // uzmi zapis...
      _rec := dbf_get_rec()

      _rec[ "nabvr" ] := _rec[ "nabvr" ] + _rec[ "revd" ]
      _rec[ "otpvr" ] := _rec[ "otpvr" ] + _rec[ "revp" ] + _rec[ "amp" ]

      // brisi sta je otpisano
      // ali samo osnovna sredstva, sitan inventar ostaje u bazi...
      IF !Empty( _rec[ "datotp" ] ) .AND. gOsSii == "O"

         AAdd( info, { "     sredstvo: " + _rec[ "id" ] + "-" + PadR( _rec[ "naz" ], 30 ), 0, "OTPIS" } )

         ++ _otpis_count

         delete_rec_server_and_dbf( __table_os, _rec, 1, "CONT" )

         GO _t_rec
         LOOP

      ENDIF

      select_promj()
      SET ORDER TO TAG "1"
      GO TOP
      SEEK _sr_id

      DO WHILE !Eof() .AND. field->id == _sr_id
         _rec[ "nabvr" ] += field->nabvr + field->revd
         _rec[ "otpvr" ] += field->otpvr + field->revp + field->amp
         SKIP
      ENDDO

      select_os_sii()

      _rec[ "amp" ] := 0
      _rec[ "amd" ] := 0
      _rec[ "revd" ] := 0
      _rec[ "revp" ] := 0

      // update zapisa...
      update_rec_server_and_dbf( __table_os, _rec, 1, "CONT" )

      GO _t_rec

   ENDDO

   @ _pos_x, _pos_y + 55 SAY "OK"

   AAdd( info, { "5) broj otpisanih sredstava u novoj godini", _otpis_count, "" } )

   // pobrisi sve promjene...
   select_promj()
   SET ORDER TO TAG "1"
   GO TOP

   @ _pos_x := m_x + 7, _pos_y := m_y + 2 SAY PadR( "5) brisem promjene u novoj sezoni ", 40, "." )

   DO WHILE !Eof()

      SKIP 1
      _t_rec := RecNo()
      SKIP -1

      _rec := dbf_get_rec()
      delete_rec_server_and_dbf( __table_promj,  _rec, 1, "CONT" )

      GO ( _t_rec )

   ENDDO

   @ _pos_x, _pos_y + 55 SAY "OK"

   f18_unlock_tables( { __table_os, __table_promj } )
   run_sql_query( "COMMIT" )

   my_close_all_dbf()

   _ok := .T.

   RETURN _ok


// -------------------------------------------------------------
// pakovanje tabele...
// -------------------------------------------------------------
STATIC FUNCTION _pakuj_tabelu( alias, table )

   SELECT ( F_TMP_1 )
   USE

   my_use_temp( alias, my_home() + table + ".dbf", .F., .T. )

   PACK
   USE

   RETURN
