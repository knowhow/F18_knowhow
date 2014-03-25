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

#include "fmk.ch"
#include "cre_all.ch"


// -----------------------------------
// kreiranje tabela - svi moduli
// -----------------------------------
FUNCTION cre_sifrarnici_1( ver )

   LOCAL _created
   LOCAL _table_name
   LOCAL _alias
   LOCAL aDbf

   // KONTO

   _alias := "KONTO"
   _table_name := "konto"

   aDbf := {}
   AAdd( aDBf, { 'ID', 'C',   7,  0 } )
   add_f_mcode( @aDbf )
   AAdd( aDBf, { 'NAZ', 'C',  57,  0 } )
   AAdd( aDBf, { "POZBILU", "C",   3,  0 } )
   AAdd( aDBf, { "POZBILS", "C",   3,  0 } )

   IF_NOT_FILE_DBF_CREATE
   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "NAZ", "naz", _alias )
   index_mcode( my_home(), _alias )

   // upisi default valute ako ne postoje
   fill_tbl_valute()

   // kreiranje tabela ugovora
   db_cre_ugov( ver )

   RETURN .T.



// ----------------------------------------
// dodaj defaut valute u sifrarnik valuta
// ----------------------------------------
FUNCTION fill_tbl_valute()

   LOCAL _rec

   CLOSE ALL
   O_VALUTE

   IF RecCount() <> 0
      CLOSE ALL
      RETURN .T.
   ENDIF

   IF !f18_lock_tables( { "valute" } )
      CLOSE ALL
      RETURN .T.
   ENDIF

   sql_table_update( nil, "BEGIN" )

   APPEND BLANK
   _rec := dbf_get_rec()
   _rec[ "id" ]    := "000"
   _rec[ "naz" ]   := "KONVERTIBILNA MARKA"
   _rec[ "naz2" ]  := "KM"
   _rec[ "datum" ] := CToD( "01.01.04" )
   _rec[ "tip" ]   := "D"
   _rec[ "kurs1" ] := 1
   _rec[ "kurs2" ] := 1
   _rec[ "kurs3" ] := 1
   update_rec_server_and_dbf( 'valute', _rec, 1, "CONT" )

   APPEND BLANK
   _rec := dbf_get_rec()
   _rec[ "id" ]    := "978"
   _rec[ "naz" ]   := "EURO"
   _rec[ "naz2" ]  := "EUR"
   _rec[ "datum" ] := CToD( "01.01.04" )
   _rec[ "tip" ]   := "P"
   _rec[ "kurs1" ] := 0.51128
   _rec[ "kurs2" ] := 0.51128
   _rec[ "kurs3" ] := 0.51128
   update_rec_server_and_dbf( 'valute', _rec, 1, "CONT" )


   f18_free_tables( { "valute" } )
   sql_table_update( nil, "END" )

   CLOSE ALL

   RETURN .T.
