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



FUNCTION cre_sif_konto( ver )

   LOCAL _created
   LOCAL _table_name
   LOCAL _alias
   LOCAL aDbf

   _alias := "KONTO"
   _table_name := "konto"

   aDbf := {}
   AAdd( aDBf, { 'ID', 'C',   7,  0 } )
   add_f_mcode( @aDbf )
   AAdd( aDBf, { 'NAZ', 'C',  57,  0 } )
   AAdd( aDBf, { "POZBILU", "C",   3,  0 } )
   AAdd( aDBf, { "POZBILS", "C",   3,  0 } )

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "NAZ", "naz", _alias )
   index_mcode( my_home(), _alias )

   AFTER_CREATE_INDEX

   RETURN .T.




FUNCTION fill_tbl_valute()

   LOCAL _rec, _tmp, _id, _qry
   LOCAL _table := F18_PSQL_SCHEMA_DOT + "valute"

   _tmp := table_count( _table )

   IF _tmp == 0

      _qry := "INSERT INTO " + _table
      _qry += " ( id, naz, naz2, datum, tip, kurs1, kurs2, kurs3 ) "
      _qry += " VALUES( "
      _qry += " '000', "
      _qry += " 'KONVERTIBILNA MARKA', "
      _qry += " 'KM ', "
      _qry += sql_quote( CToD( "01.01.04" ) ) + ", "
      _qry += " 'D', "
      _qry += " 1, 1, 1 "
      _qry += " ); "
      _qry += "INSERT INTO " + _table
      _qry += " ( id, naz, naz2, datum, tip, kurs1, kurs2, kurs3 ) "
      _qry += " VALUES( "
      _qry += " '978', "
      _qry += " 'EURO', "
      _qry += " 'EUR', "
      _qry += sql_quote( CToD( "01.01.04" ) ) + ", "
      _qry += " 'P', "
      _qry += " 0.51128, 0.51128, 0.51128 "
      _qry += " ); "

      run_sql_query( _qry )

   ENDIF

   RETURN .T.
