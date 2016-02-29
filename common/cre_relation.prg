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


// -----------------------------------------
// kreiranje tabele relacija
// -----------------------------------------
FUNCTION cre_relation( ver )

   LOCAL aDbf
   LOCAL _table_name, _alias, _created

   aDbf := g_rel_tbl()

   _table_name := "relation"
   _alias := "RELATION"

   IF_NOT_FILE_DBF_CREATE


   CREATE_INDEX( "1", "TFROM+TTO+TFROMID", _alias )
   CREATE_INDEX( "2", "TTO+TFROM+TTOID", _alias )
   AFTER_CREATE_INDEX

   RETURN .T.


// ------------------------------------------
// struktura tabele relations
// ------------------------------------------
STATIC FUNCTION g_rel_tbl()

   LOCAL aDbf := {}

   // TABLE FROM
   AAdd( aDbf, { "TFROM", "C", 10, 0 } )
   // TABLE TO
   AAdd( aDbf, { "TTO", "C", 10, 0 } )
   // TABLE FROM ID
   AAdd( aDbf, { "TFROMID", "C", 10, 0 } )
   // TABLE TO ID
   AAdd( aDbf, { "TTOID", "C", 10, 0 } )

   // structure example:
   // -------------------------------------------
   // TFROM    | TTO     | TFROMID  | TTOID
   // ------------------- -----------------------
   // ARTICLES | ROBA    |    123   |  22TX22
   // CUSTOMS  | PARTN   |     22   |  1CT02
   // .....

   RETURN aDbf


// ---------------------------------------------
// vraca vrijednost za zamjenu
// cType - '1' = TBL1->TBL2, '2' = TBL2->TBL1
// cFrom - iz tabele
// cTo - u tabelu
// cId - id za pretragu
// ---------------------------------------------
FUNCTION g_rel_val( cType, cFrom, cTo, cId )

   LOCAL xVal := ""
   LOCAL nTArea := Select()

   IF cType == nil
      cType := "1"
   ENDIF

   O_RELATION
   SET ORDER TO tag &cType
   GO TOP

   SEEK PadR( cFrom, 10 ) + PadR( cTo, 10 ) + PadR( cId, 10 )

   IF Found() .AND. field->tfrom == PadR( cFrom, 10 ) ;
         .AND. field->tto == PadR( cTo, 10 ) ;
         .AND. field->tfromid == PadR( cId, 10 )

      IF cType == "1"
         xVal := field->ttoid
      ELSE
         xVal := field->tfromid
      ENDIF

   ENDIF

   SELECT ( nTArea )

   RETURN xVal



// ------------------------------
// dodaj u relacije
// ------------------------------
FUNCTION add_to_relation( f_from, f_to, f_from_id, f_to_id )

   LOCAL _t_area := Select()
   LOCAL _rec

   SELECT ( F_RELATION )
   IF !Used()
      O_RELATION
   ENDIF

   SELECT RELATION

   APPEND BLANK
   _rec := dbf_get_rec()

   _rec[ "tfrom" ] := PadR( f_from, 10 )
   _rec[ "tto" ] := PadR( f_to, 10 )
   _rec[ "tfromid" ] := PadR( f_from_id, 10 )
   _rec[ "ttoid" ] := PadR( f_to_id, 10 )

   update_rec_server_and_dbf( "relation", _rec, 1, "FULL" )

   SELECT ( _t_area )

   RETURN



// ---------------------------------------------
// otvara tabelu relacija
// ---------------------------------------------
FUNCTION p_relation( cId, dx, dy )

   LOCAL nTArea := Select()
   LOCAL i
   LOCAL bFrom
   LOCAL bTo
   PRIVATE ImeKol
   PRIVATE Kol

   SELECT ( F_RELATION )
   IF !Used()
      O_RELATION
   ENDIF

   ImeKol := {}
   Kol := {}

   AAdd( ImeKol, { "Tab.1", {|| tfrom }, "tfrom", {|| .T. }, {|| !Empty( wtfrom ) } } )
   AAdd( ImeKol, { "Tab.2", {|| tto   }, "tto", {|| .T. }, {|| !Empty( wtto ) } } )
   AAdd( ImeKol, { "Tab.1 ID", {|| tfromid }, "tfromid" } )
   AAdd( ImeKol, { "Tab.2 ID", {|| ttoid }, "ttoid" } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   SELECT ( nTArea )

   RETURN PostojiSifra( F_RELATION, 1, 10, 65, "Lista relacija konverzije", @cId, dx, dy )




// ---------------------------------------------
// vraca cijenu artikla iz sifrarnika robe
// ---------------------------------------------
FUNCTION g_art_price( cId, cPriceType )

   LOCAL nPrice := 0
   LOCAL nTArea := Select()

   IF cPriceType == nil
      cPriceType := "VPC1"
   ENDIF

   SELECT ( F_ROBA )
   IF !Used()
      O_ROBA
   ENDIF

   SELECT roba
   SEEK cId

   IF Found() .AND. field->id == cID
      DO CASE
      CASE cPriceType == "VPC1"
         nPrice := field->vpc
      CASE cPriceType == "VPC2"
         nPrice := field->vpc2
      CASE cPriceType == "MPC1"
         nPrice := field->mpc
      CASE cPriceType == "MPC2"
         nPrice := field->mpc2
      CASE cPriceType == "NC"
         nPrice := field->nc
      ENDCASE
   ENDIF

   RETURN nPrice
