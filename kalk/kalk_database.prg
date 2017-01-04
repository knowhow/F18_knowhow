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


FUNCTION kalk_kol_stanje_artikla_magacin( m_konto, id_roba, datum_do )

   LOCAL _qry, _qry_ret, _table
   LOCAL _data := {}
   LOCAL oRow
   LOCAL _stanje

   IF datum_do == NIL
      datum_do := Date()
   ENDIF

   _qry := "SELECT " + ;
      " SUM( " + ;
      " CASE " + ;
      " WHEN mu_i = '1' AND idvd NOT IN ('12', '22', '94') THEN kolicina " + ;
      " WHEN mu_i = '1' AND idvd IN ('12', '22', '94') THEN -kolicina " + ;
      " WHEN mu_i = '5' THEN -kolicina " + ;
      " WHEN mu_i = '8' THEN -kolicina " + ;
      " END ) as stanje_m " + ;
      " FROM " + F18_PSQL_SCHEMA_DOT + "kalk_kalk " + ;
      " WHERE " + ;
      " idfirma = " + sql_quote( self_organizacija_id() ) + ;
      " AND mkonto = " + sql_quote( m_konto ) + ;
      " AND idroba = " + sql_quote( id_roba ) + ;
      " AND " + _sql_date_parse( "datdok", CToD( "" ), datum_do )

   _table := run_sql_query( _qry )

   oRow := _table:GetRow( 1 )

   _stanje := oRow:FieldGet( oRow:FieldPos( "stanje_m" ) )

   IF ValType( _stanje ) == "L"
      _stanje := 0
   ENDIF

   RETURN _stanje




FUNCTION kalk_kol_stanje_artikla_prodavnica( p_konto, id_roba, datum_do )

   LOCAL _qry, _qry_ret, _table
   LOCAL _data := {}
   LOCAL oRow
   LOCAL _stanje

   IF datum_do == NIL
      datum_do := Date()
   ENDIF

   _qry := "SELECT SUM( CASE WHEN pu_i = '1' THEN kolicina-gkolicina-gkolicin2 " + ;
      " WHEN pu_i = '5' THEN -kolicina " + ;
      " WHEN pu_i = 'I' THEN -gkolicin2 ELSE 0 END ) as stanje_p " + ;
      " FROM " + F18_PSQL_SCHEMA_DOT + "kalk_kalk " + ;
      " WHERE " + ;
      " idfirma = " + sql_quote( self_organizacija_id() ) + ;
      " AND pkonto = " + sql_quote( p_konto ) + ;
      " AND idroba = " + sql_quote( id_roba ) + ;
      " AND " + _sql_date_parse( "datdok", CToD( "" ), datum_do )

   _table := run_sql_query( _qry )

   oRow := _table:GetRow( 1 )

   _stanje := oRow:FieldGet( oRow:FieldPos( "stanje_p" ) )

   IF ValType( _stanje ) == "L"
      _stanje := 0
   ENDIF

   RETURN _stanje
