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



// ------------------------------------------------
// prelged sifrarnika shema generacije za kuf i kif
// ------------------------------------------------
FUNCTION p_epdv_sheme_generacije( cTabela, cId, dx, dy )

   LOCAL nArea
   LOCAL cHeader

   cHeader := "Lista: shema generacije "
   cHeader += cTabela

   PRIVATE Kol
   PRIVATE ImeKol

   IF ( cTabela == "SG_KIF" )
      nArea := F_SG_KIF
   ELSE
      nArea := F_SG_KUF
   ENDIF

   SELECT ( F_PARTN )
   IF !Used()
      O_PARTN
   ENDIF


   O_SIFK
   O_SIFV


   SELECT ( nArea )

   IF !Used()
      IF ( cTabela == "SG_KIF" )
         O_SG_KIF
      ELSE
         O_SG_KUF
      ENDIF
   ENDIF


   set_a_kol( @Kol, @ImeKol )

   RETURN PostojiSifra( nArea, 1, MAXROWS() - 10, MAXCOLS() - 10, cHeader,   @cId, dx, dy, ;
      {| Ch| k_handler( Ch ) } )



STATIC FUNCTION set_a_kol( aKol, aImeKol )

   aImeKol := {}

   AAdd( aImeKol, { "ID", {|| id }, "id", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { "Opis", {|| naz }, "naz", {|| .T. }, {|| .T. } } )

   // tip: sifrarnik setuje varijable sa "W" prefixom za tekuca polja
   AAdd( aImeKol, { "src", {|| src }, "src", {|| .T. }, {|| !Empty( g_src_modul( wSrc, .T. ) ) } } )
   AAdd( aImeKol, { "src TD", {|| td_src }, "td_src", {|| .T. }, {|| .T. } } )


   // AAdd( aImeKol, { "Src.Lokacija.", {|| s_path }, "s_path", {|| .T. }, {|| .T. } } )
   // AAdd( aImeKol, { "Src.lok. sif", {|| s_path_s }, "s_path_s", {|| .T. }, {|| .T. } } )

   AAdd( aImeKol, { "For.B.PDV vr.", {|| form_b_pdv }, "form_b_pdv", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { "For.PDV vr.", {|| form_pdv }, "form_pdv", {|| .T. }, {|| .T. } } )

   AAdd( aImeKol, { "Usl.tar.", {|| id_tar }, "id_tar", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { "Usl.kto", {|| id_kto }, "id_kto", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { "Kto.naz", {|| id_kto }, "id_kto_naz", {|| .T. }, {|| .T. } } )

   AAdd( aImeKol, { "Razb.tar.", {|| razb_tar }, "razb_tar", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { "Razb.kto.", {|| razb_kto }, "razb_kto", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { "Razb.dan.", {|| razb_dan }, "razb_dan", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { "Kat.part.", {|| epdv_get_kateg_partner( kat_p ) }, "kat_p", {|| info_partner(), .T. }, {|| !Empty( epdv_get_kateg_partner( wkat_p, .T. ) ) } } )
   AAdd( aImeKol, { "Kat.part.2", {|| g_kat_p_2( kat_p_2 ) }, "kat_p_2", {|| .T. }, {|| !Empty( g_kat_p_2( wkat_p_2, .T. ) ) } } )
   AAdd( aImeKol, { "Zaok c*kol", {|| zaok }, "zaok", {|| wzaok := iif( wzaok == 0, 2, wzaok ), .T. }, {|| .T. } } )
   AAdd( aImeKol, { "Zaok dok", {|| zaok2 }, "zaok2", {|| wzaok2 := iif( wzaok2 == 0, 2, wzaok2 ), .T. }, {|| .T. } } )

   // setuj id tar u kuf/kif
   AAdd( aImeKol, { "Set.Tar", {|| s_id_tar }, "s_id_tar", {|| .T. }, {|| .T. } } )

   // setuj id tar u kuf/kif
   AAdd( aImeKol, { "Set.Par", {|| s_id_part }, "s_id_part", {|| .T. }, {|| Empty( ws_id_part ) .OR. p_partner( @ws_id_part ), .T. } } )

   // setuj id tar u kuf/kif
   AAdd( aImeKol, { "Set.Br.Dok", {|| s_br_dok }, "s_br_dok", {|| .T. }, {|| .T. } } )

   AAdd( aImeKol, { "Aktivan", {|| aktivan }, "aktivan", {|| waktivan := iif( waktivan == " ", "D", waktivan ), .T. }, {|| .T. } } )

   aKol := {}
   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN .T.


FUNCTION info_partner()

   RETURN MsgBeep( "Partn:#0-bez pdv#9-pdv#1-pdv obveznik#2-nepdv obveznik#3-ino" )


// ------------------------------------
// gen shema kif keyboard handler
// ------------------------------------
STATIC FUNCTION k_handler( Ch )

   RETURN DE_CONT
