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


STATIC __stanje
STATIC __vrijednost
STATIC __dok_br



FUNCTION p_poc_stanje()

   LOCAL _params := hb_Hash()
   LOCAL _cnt := 0
   LOCAL _padr := 80

   __stanje := 0
   __vrijednost := 0
   __dok_br := ""

   // parametri prenosa...
   IF _get_vars( @_params ) == 0
      RETURN
   ENDIF

   // prenesi pocetno stanje...
   _cnt := pocetno_stanje_sql( _params )

   IF _cnt > 0
      _txt := "Izvrsen prenos pocetnog stanja, dokument 16-1 !"
   ELSE
      _txt := "Nema dokumenata za prenos !!!"
   ENDIF

   MsgBeep( _txt )

   RETURN


// --------------------------------------------
// parametri prenosa
// --------------------------------------------
STATIC FUNCTION _get_vars( params )

   LOCAL _x := 1
   LOCAL _box_x := 8
   LOCAL _box_y := 60
   LOCAL _dat_od, _dat_do, _id_pos, _dat_ps
   PRIVATE GetList := {}

   _dat_od := CToD( "01.01." + AllTrim( Str( Year( Date() ) -1 ) ) )
   _dat_do := CToD( "31.12." + AllTrim( Str( Year( Date() ) -1 ) ) )
   _dat_ps := CToD( "01.01." + AllTrim( Str( Year( Date() ) ) ) )
   _id_pos := gIdPos

   Box(, _box_x, _box_y )

   SET CURSOR ON

   @ m_x + _x, m_y + 2 SAY "Parametri prenosa u novu godinu" COLOR "BG+/B"

   _x += 2

   @ m_x + _x, m_y + 2 SAY "pos ID" GET _id_pos VALID !Empty( _id_pos )

   _x += 2

   @ m_x + _x, m_y + 2 SAY "Datum prenosa od:" GET _dat_od VALID !Empty( _dat_od )
   @ m_x + _x, Col() + 1 SAY "do:" GET _dat_do VALID !Empty( _dat_do )

   _x += 2

   @ m_x + _x, m_y + 2 SAY "Datum dokumenta pocetnog stanja:" GET _dat_ps VALID !Empty( _dat_ps )

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN 0
   ENDIF

   // snimi parametre
   params[ "datum_od" ] := _dat_od
   params[ "datum_do" ] := _dat_do
   params[ "id_pos" ] := _id_pos
   params[ "datum_ps" ] := _dat_ps

   RETURN 1


// ----------------------------------------------------------
// prebaci se na rad sa sezonskim podrucjem
// ----------------------------------------------------------
STATIC FUNCTION prebaci_se_u_bazu( db_params, database, year )

   IF year == NIL
      year := Year( Date() )
   ENDIF

   // 1) odjavi mi se iz tekuce sezone
   my_server_logout()

   IF year <> Year( Date() )
      // 2) xxxx_2013 => xxxx_2012
      db_params[ "database" ] := Left( database, Len( database ) - 4 ) + AllTrim( Str( year ) )
   ELSE
      db_params[ "database" ] := database
   ENDIF

   // 3) setuj parametre
   my_server_params( db_params )
   // 4) napravi login
   my_server_login( db_params )

   RETURN .T.



// -----------------------------------------------------
// pocetno stanje POS na osnovu sql upita...
// -----------------------------------------------------
STATIC FUNCTION pocetno_stanje_sql( param )

   LOCAL _db_params := my_server_params()
   LOCAL _tek_database := my_server_params()[ "database" ]
   LOCAL _date_from := PARAM[ "datum_od" ]
   LOCAL _date_to := PARAM[ "datum_do" ]
   LOCAL _date_ps := PARAM[ "datum_ps" ]
   LOCAL _year_sez := Year( _date_to )
   LOCAL _year_tek := Year( _date_ps )
   LOCAL _id_pos := PARAM[ "id_pos" ]
   LOCAL _qry, _table, _row
   LOCAL _count := 0
   LOCAL _rec, _id_roba, _kolicina, _vrijednost
   LOCAL _n_br_dok
   LOCAL lOk := .T.

   prebaci_se_u_bazu( _db_params, _tek_database, _year_sez )


   _qry := "SELECT " + ;
      "idroba, " + ;
      "SUM( CASE " + ;
      "WHEN idvd IN ('16', '00') THEN kolicina " + ;
      "WHEN idvd IN ('IN') THEN -(kolicina - kol2) " + ;
      "WHEN idvd IN ('42') THEN -kolicina " + ;
      "END ) as kolicina, " + ;
      "SUM( CASE  " + ;
      "WHEN idvd IN ('16', '00') THEN kolicina * cijena " + ;
      "WHEN idvd IN ('IN') THEN -(kolicina - kol2) * cijena " + ;
      "WHEN idvd IN ('42') THEN -kolicina * cijena " + ;
      "END ) as vrijednost " + ;
      "FROM " + F18_PSQL_SCHEMA_DOT + "pos_pos "

   _qry += " WHERE "
   _qry += _sql_cond_parse( "idpos", _id_pos )
   _qry += " AND " + _sql_date_parse( "datum", _date_from, _date_to )
   _qry += " GROUP BY idroba "
   _qry += " ORDER BY idroba "

   MsgO( "pocetno stanje sql query u toku..." )
   _table := run_sql_query( _qry )
   MsgC()

   prebaci_se_u_bazu( _db_params, _tek_database, _year_tek )

   O_POS
   O_POS_DOKS
   O_ROBA

   _n_br_dok := pos_novi_broj_dokumenta( _id_pos, "16", _date_ps )

   run_sql_query( "BEGIN" )
   IF !f18_lock_tables( { "pos_pos", "pos_doks" }, .T. )
      run_sql_query( "COMMIT" )
      MsgBeep( "Ne mogu zaključati tabele !#Prekidam operaciju." )
      RETURN .F.
   ENDIF

   MsgO( "Formiranje dokumenta početnog stanja u toku ..." )

   DO WHILE !_table:Eof()

      _row := _table:GetRow()

      _id_roba := hb_UTF8ToStr( _row:FieldGet( _row:FieldPos( "idroba" ) ) )

      _kolicina := _row:FieldGet( _row:FieldPos( "kolicina" ) )
      __stanje += _kolicina

      _vrijednost := _row:FieldGet( _row:FieldPos( "vrijednost" ) )
      __vrijednost += _vrijednost

      SELECT roba
      HSEEK _id_roba

      IF Round( _kolicina, 2 ) <> 0

         SELECT pos
         APPEND BLANK

         _rec := dbf_get_rec()

         _rec[ "idpos" ] := _id_pos
         _rec[ "idvd" ] := "16"
         _rec[ "brdok" ] := _n_br_dok
         _rec[ "rbr" ] := PadL( AllTrim( Str( ++_count ) ), 5 )
         _rec[ "idroba" ] := _id_roba
         _rec[ "kolicina" ] := _kolicina
         _rec[ "cijena" ] := pos_get_mpc()
         _rec[ "datum" ] := _date_ps
         _rec[ "idradnik" ] := "XXXX"
         _rec[ "idtarifa" ] := roba->idtarifa
         _rec[ "prebacen" ] := "1"
         _rec[ "smjena" ] := "1"
         _rec[ "mu_i" ] := "1"

         lOk := update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT" )

      ENDIF

      IF !lOk
         EXIT
      ENDIF

      _table:Skip()

   ENDDO

   IF lOk .AND. _count > 0

      SELECT pos_doks
      APPEND BLANK

      _rec := dbf_get_rec()

      _rec[ "idpos" ] := _id_pos
      _rec[ "idvd" ] := "16"
      _rec[ "brdok" ] := _n_br_dok
      _rec[ "datum" ] := _date_ps
      _rec[ "idradnik" ] := "XXXX"
      _rec[ "prebacen" ] := "1"
      _rec[ "smjena" ] := "1"

      lOk := update_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )

   ENDIF

   MsgC()

   IF lOk
      f18_free_tables( { "pos_pos", "pos_doks" } )
      run_sql_query( "COMMIT" )
   ELSE
      run_sql_query( "ROLLBACK" )
   ENDIF

   SELECT ( F_ROBA )
   USE
   SELECT ( F_POS_DOKS )
   USE
   SELECT ( F_POS )
   USE

   RETURN _count
