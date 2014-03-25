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

   // RJ

   _alias := "RJ"
   _table_name := "rj"

   aDBf := {}
   AAdd( aDBf, { 'ID', 'C',   6,  0 } )
   add_f_mcode( @aDbf )
   AAdd( aDBf, { 'NAZ', 'C',  35,  0 } )
   AAdd( aDBf, { 'TIP', 'C',   2,  0 } )
   AAdd( aDBf, { 'KONTO', 'C',   7,  0 } )

   IF_NOT_FILE_DBF_CREATE

   // 0.8.7
   IF ver[ "current" ] > 0 .AND. ver[ "current" ] < 0807
      modstru( { "*" + _table_name, "A TIP C 2 0", "A KONTO C 7 0" } )
   ENDIF

   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "NAZ", "NAZ", _alias )
   index_mcode( my_home(), _alias )

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

   // VALUTE

   _alias := "VALUTE"
   _table_name := "valute"

   aDbf := {}
   AAdd( aDBf, { 'ID', 'C',   4,  0 } )
   add_f_mcode( @aDbf )
   AAdd( aDBf, { 'NAZ', 'C',  30,  0 } )
   AAdd( aDBf, { 'NAZ2', 'C',   4,  0 } )
   AAdd( aDBf, { 'DATUM', 'D',   8,  0 } )
   AAdd( aDBf, { 'KURS1', 'N',  10,  6 } )
   AAdd( aDBf, { 'KURS2', 'N',  10,  6 } )
   AAdd( aDBf, { 'KURS3', 'N',  10,  6 } )
   AAdd( aDBf, { 'TIP', 'C',   1,  0 } )

   IF_NOT_FILE_DBF_CREATE

   // 0.8.8
   IF ver[ "current" ] > 0 .AND. ver[ "current" ] < 0808
      modstru( { "*" + _table_name, ;
         "C KURS1 N 10 5 KURS1 N 10 6", ;
         "C KURS2 N 10 5 KURS2 N 10 6", ;
         "C KURS3 N 10 5 KURS3 N 10 6" } )
   ENDIF

   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "NAZ", "tip+id+dtos(datum)", _alias )
   CREATE_INDEX( "ID2", "id+dtos(datum)", _alias )
   index_mcode( my_home(), _alias  )

   // upisi default valute ako ne postoje
   fill_tbl_valute()


   // OPS

   _alias := "OPS"
   _table_name := "ops"

   aDBf := {}
   AAdd( aDBf, { 'ID', 'C',   4,  0 } )
   AAdd( aDBf, { 'IDJ', 'C',   3,  0 } )
   add_f_mcode( @aDbf )
   AAdd( aDBf, { 'IdN0', 'C',   1,  0 } )
   AAdd( aDBf, { 'IdKan', 'C',   2,  0 } )
   AAdd( aDBf, { 'NAZ', 'C',  20,  0 } )
   AAdd( aDBf, { 'ZIPCODE', 'C',   5,  0 } )
   AAdd( aDBf, { 'PUCCANTON', 'C',   2,  0 } )
   AAdd( aDBf, { 'PUCCITY', 'C',   5,  0 } )
   AAdd( aDBf, { 'REG', 'C',   1,  0 } )

   IF_NOT_FILE_DBF_CREATE
   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "IDJ", "idj", _alias )
   CREATE_INDEX( "IDKAN", "idKAN", _alias )
   CREATE_INDEX( "IDN0", "IDN0", _alias )
   CREATE_INDEX( "NAZ", "naz", _alias )
   index_mcode( my_home(), _alias )

   // BANKE

   _alias := "BANKE"
   _table_name := "banke"

   aDbf := {}
   AAdd( aDBf, { 'ID', 'C',   3,  0 } )
   add_f_mcode( @aDbf )
   AAdd( aDBf, { 'NAZ', 'C',  45,  0 } )
   AAdd( aDBf, { 'Mjesto', 'C',  20,  0 } )
   AAdd( aDBf, { 'Adresa', 'C',  30,  0 } )

   IF_NOT_FILE_DBF_CREATE
   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "NAZ", "naz", _alias )
   index_mcode( my_home(),  _alias )


   // REFER

   _alias := "REFER"
   _table_name := "refer"

   aDBf := {}
   AAdd( aDBf, { 'ID', 'C',  10,  0 } )
   AAdd( aDBf, { 'IDOPS', 'C',   4,  0 } )
   AAdd( aDBf, { 'NAZ', 'C',  40,  0 } )

   IF_NOT_FILE_DBF_CREATE
   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "NAZ", "naz", _alias )

   // VRSTEP

   _alias := "VRSTEP"
   _table_name := "vrstep"

   aDbf := {}
   AAdd( aDbf, { "ID","C", 2, 0 } )
   AAdd( aDbf, { "NAZ", "C", 20, 0 } )
	
   IF_NOT_FILE_DBF_CREATE
   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "Id", _alias )



   // ------------------------------------------------
   // KONCIJ
   // ------------------------------------------------
   _alias := "KONCIJ"
   _table_name := "koncij"

   aDbf := {}

   AAdd( aDBf, { 'ID', 'C',   7,  0 } )
   add_f_mcode( @aDbf )
   AAdd( aDBf, { 'SHEMA', 'C',   1,  0 } )
   AAdd( aDBf, { 'NAZ', 'C',   2,  0 } )
   AAdd( aDBf, { 'IDPRODMJES', 'C',   2,  0 } )
   AAdd( aDBf, { 'REGION', 'C',   2,  0 } )
   AAdd( aDBf, { 'SUFIKS', 'C',   3,  0 } )

   IF_NOT_FILE_DBF_CREATE

   // 0.4.7
   IF ver[ "current" ] > 0 .AND. ver[ "current" ] < 0407
      modstru( { "*" + _table_name, "A SUFIKS C 3 0" } )
   ENDIF

   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "id", _alias )
   index_mcode( NIL, _alias )


   // PKONTO

   _alias := "PKONTO"
   _table_name := "pkonto"

   aDbf := {}
   AAdd( aDBf, { "ID", "C",  7,  0 } )
   AAdd( aDBf, { "TIP", "C",  1,   0 } )

   IF_NOT_FILE_DBF_CREATE
   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "ID", _alias )
   CREATE_INDEX( "NAZ", "TIP", _alias )


   // TRFP

   _alias := "TRFP"
   _table_name := "trfp"

   aDbf := {}
   AAdd( aDBf, { 'ID', 'C',  60,  0 } )
   add_f_mcode( @aDbf )
   AAdd( aDBf, { 'SHEMA', 'C',   1,  0 } )
   AAdd( aDBf, { 'NAZ', 'C',  20,  0 } )
   AAdd( aDBf, { 'IDKONTO', 'C',   7,  0 } )
   AAdd( aDBf, { 'DOKUMENT', 'C',   1,  0 } )
   AAdd( aDBf, { 'PARTNER', 'C',   1,  0 } )
   AAdd( aDBf, { 'D_P', 'C',   1,  0 } )
   AAdd( aDBf, { 'ZNAK', 'C',   1,  0 } )
   AAdd( aDBf, { 'IDVD', 'C',   2,  0 } )
   AAdd( aDBf, { 'IDVN', 'C',   2,  0 } )
   AAdd( aDBf, { 'IDTARIFA', 'C',   6,  0 } )

   IF_NOT_FILE_DBF_CREATE
   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "idvd+shema+Idkonto+id+idtarifa+idvn+naz", _alias )
   index_mcode( NIL, _alias )


   // TRFP2

   _alias := "TRFP2"
   _table_name := "trfp2"

   aDbf := {}
   AAdd( aDBf, { "ID", "C",  60,  0 } )
   AAdd( aDBf, { "SHEMA", "C",   1,  0 } )
   AAdd( aDBf, { "NAZ", "C",  20,  0 } )
   AAdd( aDBf, { "IDKONTO", "C",   7,  0 } )
   AAdd( aDBf, { "DOKUMENT", "C",   1,  0 } )
   AAdd( aDBf, { "PARTNER", "C",   1,  0 } )
   AAdd( aDBf, { "D_P", "C",   1,  0 } )
   AAdd( aDBf, { "ZNAK", "C",   1,  0 } )
   AAdd( aDBf, { "IDVD", "C",   2,  0 } )
   AAdd( aDBf, { "IDVN", "C",   2,  0 } )
   AAdd( aDBf, { "IDTARIFA", "C",   6,  0 } )

   IF_NOT_FILE_DBF_CREATE
   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "idvd+shema+Idkonto+id+idtarifa+idvn+naz", _alias )

   // TRFP3
   _alias := "TRFP3"
   _table_name := "trfp3"

   aDbf := {}
   AAdd( aDBf, { "ID", "C",  60,  0 } )
   AAdd( aDBf, { "SHEMA", "C",   1,  0 } )
   AAdd( aDBf, { "NAZ", "C",  20,  0 } )
   AAdd( aDBf, { "IDKONTO", "C",   7,  0 } )
   AAdd( aDBf, { "D_P", "C",   1,  0 } )
   AAdd( aDBf, { "ZNAK", "C",   1,  0 } )
   AAdd( aDBf, { "IDVN", "C",   2,  0 } )

   IF_NOT_FILE_DBF_CREATE
   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "shema+Idkonto", _alias )


   // kamate - sifrarnik kamata

   _alias := "KS"
   _table_name := "KS"

   aDbf := {}
   AAdd( aDBf, { "ID", "C",   3,  0 } )
   AAdd( aDBf, { "NAZ", "C",   2,  0 } )
   AAdd( aDBf, { "DATOD", "D",   8,  0 } )
   AAdd( aDBf, { "DATDO", "D",   8,  0 } )
   AAdd( aDBf, { "STREV", "N",   8,  4 } )
   AAdd( aDBf, { "STKAM", "N",   8,  4 } )
   AAdd( aDBf, { "DEN", "N",  15,  6 } )
   AAdd( aDBf, { "TIP", "C",   1,  0 } )
   AAdd( aDBf, { "DUZ", "N",   4,  0 } )

   IF_NOT_FILE_DBF_CREATE
   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "Id", _alias )
   CREATE_INDEX( "2", "dtos(datod)", _alias )


   // objekti
   _alias := "OBJEKTI"
   _table_name := "objekti"

   aDbf := {}
   AAdd( aDbf, { "id", "C", 2, 0 } )
   AAdd( aDbf, { "naz", "C", 10, 0 } )
   AAdd( aDbf, { "IdObj", "C", 7, 0 } )

   IF_NOT_FILE_DBF_CREATE
   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "ID", _alias )
   CREATE_INDEX( "NAZ", "NAZ", _alias )
   CREATE_INDEX( "IdObj", "IdObj", _alias )


   // fakt objekti
   _alias := "FAKT_OBJEKTI"
   _table_name := "fakt_objekti"

   aDbf := {}
   AAdd( aDBf, { 'ID', 'C',   10,  0 } )
   AAdd( aDBf, { 'NAZ', 'C',  100,  0 } )

   IF_NOT_FILE_DBF_CREATE
   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "ID", _alias )
   CREATE_INDEX( "NAZ", "NAZ", _alias )


   // kreiraj lokal tabelu : LOKAL
   cre_lokal( ver )

   // kreiraj tabele dok_src : DOK_SRC
   cre_doksrc( ver )

   // kreiraj relacije : RELATION
   cre_relation( ver )

   // kreiraj pravila : RULES
   cre_fmkrules( ver )

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
