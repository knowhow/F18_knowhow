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

/*
   pozvati iz f18_init procedure
   1)  kreira partn.sifk polja PDVB, IDBR ako ne postoje
   2)  ako nisu postojali PDVB, IDBR onda puni za sve partnere ova polja na osnovu legacy REGB polja

*/

FUNCTION kreiraj_pa_napuni_partn_idbr_pdvb()

   LOCAL lDodano

   lDodano := fill_sifk_partn_idbr()
   lDodano := lDodano .AND. fill_sifk_partn_pdvb()

   IF lDodano
      RETURN fill_all_partneri_idbr_pdvb()
   ENDIF

   RETURN .F.


/*
   prodji kroz tabelu partnera i popuni IDBR, PDVB
*/

FUNCTION fill_all_partneri_idbr_pdvb()

   LOCAL nCnt := 0

   O_PARTN
   SELECT partn



   ?E  "Podešavam identifikacijski i PDV broj za sve partnere  /",  partn->( RecCount() )

   DO WHILE !Eof()
      ++nCnt
      ?E "fill_all_partneri_idbr_pdvb",  nCnt
      update_idbr_pdvb_from_regb()
      SKIP
   ENDDO


   delete_sifk_partner_regb()

   RETURN .T.


/*
    partn.sifk PDVB, IDBR
*/

FUNCTION fill_sifk_partn_idbr()

   RETURN fill_sifk_partn( "IDBR", "Identfikacijski broj:", "07", 13 )


FUNCTION fill_sifk_partn_pdvb()

   RETURN fill_sifk_partn( "PDVB", "PDV broj:", "08", 12 )


/*
   vidi #34188
   puni partn.sifk IDBR, PDVB na osnovu REGB polja
*/

FUNCTION update_idbr_pdvb_from_regb()

   LOCAL oPartnId, cRegB, cIdBr, cPdvBr

   PushWA()

   SELECT PARTN

   oPartnId := Unicode():New( partn->id, is_partn_sql() )
   cRegB := get_partn_regb( oPartnId )
   cIdBr := get_partn_idbr( oPartnId )
   cPdvBr := get_partn_pdvb( oPartnId )


   IF !Empty( cIdBr ) .OR. !Empty( cPdvBr )
      RETURN .F.
   ENDIF

   SWITCH Len( cRegB )

   CASE 12

      USifK( "PARTN", "IDBR", oPartnID, "4" + cRegB )
      USifK( "PARTN", "PDVB", oPartnID, cRegB )
      EXIT

   CASE 13

      USifK( "PARTN", "IDBR", oPartnId, cRegB )
      USifK( "PARTN", "PDVB", oPartnId, "" )
      EXIT

   CASE 0

      // ne upisivati prazan string
      EXIT

   OTHERWISE

      USifK( "PARTN", "IDBR", oPartnId, cRegB )
      USifK( "PARTN", "PDVB", oPartnId, "" )

   ENDSWITCH

   PopWa()

   RETURN .T.


FUNCTION fill_sifk_partn( cIdSifk, cNazSifk, cSort, nLen )

   LOCAL lFound
   LOCAL cSeek
   LOCAL cNaz
   LOCAL cId

   O_SIFK

   // id + SORT + naz
   SET ORDER TO TAG "ID"

   cId := PadR( "PARTN", SIFK_LEN_DBF )
   cNaz := PadR( cNazSifk, Len( field->naz ) )
   cSeek :=  cId + cSort + cNaz

   SEEK cSeek

   IF !Found()

      APPEND BLANK

      _rec := dbf_get_rec()
      _rec[ "id" ] := cId
      _rec[ "naz" ] := cNaz
      _rec[ "oznaka" ] := cIdSifk
      _rec[ "sort" ] := cSort
      _rec[ "tip" ] := "C"
      _rec[ "duzina" ] := nLen
      _rec[ "veza" ] := "1"

      IF !update_rec_server_and_dbf( "sifk", _rec, 1, "FULL" )
         delete_with_rlock()
      ENDIF

      RETURN .T.
   ENDIF

   RETURN .F.



/*
   Opis: vraća id broj iz šifranika partnera na osnovu SIFK->REGB
        ukoliko je unešen PDV broj dužine 12, dodaje se "4" ispred

*/

FUNCTION firma_id_broj( partn_id )

   LOCAL cBroj

   cBroj := get_partn_idbr( partn_id )

   RETURN cBroj


/*
   Opis: vraća id broj unešen u šifarnik partnera kroz polje SIFK->REGB
         ukoliko je broj > 13 vraća se prazno
*/

FUNCTION firma_pdv_broj( partn_id )

   LOCAL cBroj

   cBroj := get_partn_pdvb( partn_id )

   RETURN cBroj


/*
   Opis: vraća karaketristiku REGB iz tabele SIFK za partnera
*/

FUNCTION get_partn_regb( partn_id )

   RETURN AllTrim( IzSifKPartn( "REGB", partn_id, .F. ) )


FUNCTION get_partn_pdvb( partn_id )

   RETURN AllTrim( IzSifKPartn( "PDVB", partn_id, .F. ) )


FUNCTION get_partn_idbr( partn_id )

   RETURN AllTrim( IzSifKPartn( "IDBR", partn_id, .F. ) )


/*
    partn.sifk/REGB - legacy !

    koristiti PDVB, IDBR
*/

FUNCTION fill_partn_sifk_regb()

   RETURN fill_sifk_partn( "REGB", "ID broj", "01", 13 )


FUNCTION delete_sifk_partner_regb()

   LOCAL cQuery

   cQuery := "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "sifk WHERE oznaka='REGB'"

   RETURN run_sql_query( cQuery )
