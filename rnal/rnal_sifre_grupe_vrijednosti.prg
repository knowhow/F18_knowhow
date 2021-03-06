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

STATIC _e_gr_at
STATIC __wo_id

// -------------------------------------------------------------
// otvara sifrarnik artikala
// -------------------------------------------------------------
FUNCTION s_e_gr_val( cId, nE_gr_at_id, cE_gr_vl_desc, lwo_ID, dx, dy )

   LOCAL nTArea
   LOCAL cHeader
   LOCAL nCdx := 1
   PRIVATE ImeKol
   PRIVATE Kol
   PRIVATE GetList := {}

   nTArea := Select()

   O_E_GR_VAL

   cHeader := "Elementi - atributi, vrijednosti atributa /"

   IF nE_gr_at_id == nil
      nE_gr_at_id := -1
   ENDIF

   IF cE_gr_vl_desc == nil
      cE_gr_vl_desc := ""
   ENDIF

   IF lwo_ID == nil
      lwo_ID := .F.
   ENDIF

   _e_gr_at := nE_gr_at_id
   __wo_id := lwo_ID

   SELECT e_gr_val
   SET ORDER TO TAG "1"

   set_a_kol( @ImeKol, @Kol )
   gr_att_filter( nE_gr_at_id, cE_gr_vl_desc )

   GO TOP

   cRet := p_sifra( F_E_GR_VAL, 1, f18_max_rows() -10, f18_max_cols() -5, cHeader, @cId, dx, dy, {|| key_handler( Ch ) } )

   IF ValType( cE_gr_vl_desc ) == "N"
      cE_gr_vl_desc := Str( cE_gr_vl_desc, 10 )
   ENDIF

   IF nE_gr_at_id > 0 .OR. cE_gr_vl_desc <> ""
      SET FILTER TO
   ENDIF

   SELECT ( nTArea )

   RETURN cRet


// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
STATIC FUNCTION set_a_kol( aImeKol, aKol )

   aKol := {}
   aImeKol := {}

   IF __wo_id == .F.
      AAdd( aImeKol, { PadC( "ID/MC", 10 ), {|| PadR( sif_idmc( e_gr_vl_id ), 10 ) }, "e_gr_vl_id", {|| rnal_uvecaj_id( @wE_gr_vl_id, "E_GR_VL_ID" ), .F. }, {|| .T. } } )
   ENDIF

   AAdd( aImeKol, { PadC( "Grupa/atribut", 15 ), {|| "(" + AllTrim( g_egr_by_att( e_gr_at_id ) ) + ") / " + PadR( g_gr_at_desc( e_gr_at_id ), 15 ) }, "e_gr_at_id", {|| set_e_gr_at( @we_gr_at_id ) }, {|| s_e_gr_att( @we_gr_at_id ), show_it( g_gr_at_desc( we_gr_at_id ) ) } } )

   AAdd( aImeKol, { PadC( "Vrijednost", 20 ), {|| PadR( e_gr_vl_fu, 28 ) + ".." }, "e_gr_vl_fu" } )

   AAdd( aImeKol, { PadC( "Skr. opis (sifra)", 20 ), {|| PadR( e_gr_vl_de, 10 ) }, "e_gr_vl_de" } )

   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN

// ---------------------------------------------------
// setuje polje e_gr_at_id pri unosu automatski
// ---------------------------------------------------
STATIC FUNCTION set_e_gr_at( nE_gr_at )

   IF _e_gr_at > 0
      nE_gr_at := _e_gr_at
      RETURN .F.
   ELSE
      RETURN .T.
   ENDIF

   RETURN




// ------------------------------------------------------
// filter po polju e_gr_at_id
//
// nE_gr_at_id - id atributa grupe
// nE_gr_vl_desc - description vrijednosti...
// ------------------------------------------------------
STATIC FUNCTION gr_att_filter( nE_gr_at_id, cE_gr_vl_desc )

   LOCAL cFilter := ""

   IF nE_gr_at_id > 0
      cFilter += "e_gr_at_id == " + e_gr_at_str( nE_gr_at_id )
   ENDIF

   IF !Empty( cE_gr_vl_desc )

      IF !Empty( cFilter )
         cFilter += " .and. "
      ENDIF

      cFilter += "UPPER( e_gr_vl_fu ) = " + _filter_quote( Upper( AllTrim( cE_gr_vl_desc ) ) )
   ENDIF

   IF !Empty( cFilter )
      SET FILTER TO
      SET FILTER to &cFilter
      GO TOP
   ENDIF

   RETURN


// -----------------------------------------
// key handler funkcija
// -----------------------------------------
STATIC FUNCTION key_handler( Ch )

   DO CASE

   CASE Ch == K_CTRL_N .OR. Ch == K_F4
      __wo_ID := .F.
      set_a_kol( @ImeKol, @Kol )
      RETURN DE_CONT

   ENDCASE

   RETURN DE_CONT


// -------------------------------
// convert e_gr_val_id to string
// -------------------------------
FUNCTION e_gr_vl_str( nId )
   RETURN Str( nId, 10 )


// -------------------------------
// get e_gr_desc by e_gr_id
// -------------------------------
FUNCTION g_e_gr_vl_desc( nE_gr_vl_id, lEmpty, lFullDesc )

   LOCAL cEGrValDesc := "?????"
   LOCAL nTArea := Select()

   IF lEmpty == nil
      lEmpty := .F.
   ENDIF

   IF lEmpty == .T.
      cEGrValDesc := ""
   ENDIF

   IF lFullDesc == nil
      lFullDesc := .T.
   ENDIF

   O_E_GR_VAL
   SELECT e_gr_val
   SET ORDER TO TAG "1"
   GO TOP
   SEEK e_gr_vl_str( nE_gr_vl_id )

   IF Found()
      IF lFullDesc == .T.
         IF !Empty( field->e_gr_vl_fu )
            cEGrValDesc := AllTrim( field->e_gr_vl_fu )
         ENDIF
      ELSE
         IF !Empty( field->e_gr_vl_de )
            cEGrValDesc := AllTrim( field->e_gr_vl_de )
         ENDIF
      ENDIF
   ENDIF

   SELECT ( nTArea )

   RETURN cEGrValDesc


// --------------------------------------------------
// vra�a grupu elementa po vrijednosti atributa
// --------------------------------------------------
FUNCTION g_egr_by_att( nE_gr_att, lEmpty, lFullDesc )

   LOCAL cGr := "?????"
   LOCAL nTArea := Select()
   LOCAL nTRec := RecNo()

   IF lEmpty == nil
      lEmpty := .F.
   ENDIF

   IF lEmpty == .T.
      cGr := ""
   ENDIF

   SELECT e_gr_att
   SET ORDER TO TAG "1"
   GO TOP
   SEEK e_gr_at_str( nE_gr_att )

   IF Found()
      cGr := AllTrim( g_e_gr_desc( field->e_gr_id, lEmpty, lFullDesc ) )
   ENDIF

   SELECT ( nTArea )
   GO ( nTRec )

   RETURN cGr



// -------------------------------------------------
// vraca atribut grupe elementa iz tabele e_gr_val
// -------------------------------------------------
FUNCTION g_gr_att_val( nE_gr_val )

   LOCAL nE_gr_att := 0
   LOCAL nTArea := Select()

   SELECT e_gr_val
   SET ORDER TO TAG "1"
   GO TOP
   SEEK e_gr_vl_str( nE_gr_val )

   IF Found()
      nE_gr_att := field->e_gr_at_id
   ENDIF

   SELECT ( nTArea )

   RETURN nE_gr_att
