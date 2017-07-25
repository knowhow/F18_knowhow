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



FUNCTION ugov_sif_meni()

   LOCAL aOpc := {}
   LOCAL aOpcExe := {}
   LOCAL nIzbor := 1
   LOCAL lPrev

   AAdd( aOpc, "1. ugovori                                    " )
   AAdd( aOpcExe, {|| lPrev := gPregledSifriIzMenija, gPregledSifriIzMenija := .T., P_Ugov(), gPregledSifriIzMenija := lPrev } )
   AAdd( aOpc, "2. štampa naljepnica iz ugovora " )
   AAdd( aOpcExe, {|| ugov_stampa_naljenica() } )
   AAdd( aOpc, "3. parametri ugovora" )
   AAdd( aOpcExe, {|| DFTParUg( .F. ) } )
   AAdd( aOpc, "4. grupna zamjena cijene artikla u ugovoru" )
   AAdd( aOpcExe, {|| ug_ch_price() } )

   f18_menu( "mugo", .F., nIzbor, aOpc, aOpcExe )

   my_close_all_dbf()

   RETURN .T.


FUNCTION o_ugov()

   Select( F_UGOV )
   my_use  ( "ugov" )
   SET ORDER TO TAG "ID"

   RETURN .T.

FUNCTION o_rugov()

   Select( F_RUGOV )
   my_use  ( "rugov" )
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION MSAY2( x, y, c, nDuzina )

   LOCAL cSay

   IF nDuzina == NIL
      cSay := c
   ELSE
      cSay := LEFT( c, nDuzina )
   ENDIF

   @ x, y SAY cSay

   RETURN .T.


// --------------------------------
// konvertuj string #ZA_MJ#
// --------------------------------
FUNCTION str_za_mj( cStr, nMjesec, nGodina )

   LOCAL cRet
   LOCAL cPom
   LOCAL cSrc := "#ZA_MJ#"
   LOCAL cMjesec
   LOCAL cGodina

   cMjesec := AllTrim( Str( nMjesec ) )
   cGodina := AllTrim( Str( nGodina ) )

   cPom := "za mjesec "
   cPom += cMjesec
   cPom += "/"
   cPom += cGodina

   cRet := StrTran( cStr, cSrc, cPom )

   RETURN cRet


// ----------------------------------------
// _txt djokeri, obrada
// ----------------------------------------
FUNCTION txt_djokeri( nSaldoKup, nSaldoDob, ;
      dPUplKup, dPPromKup, ;
      dPPromDob, dLUplata, ;
      cPartner )

   LOCAL cPom

   // saldo
   cPom := AllTrim( Str( nSaldoKup ) )
   _txt := StrTran( _txt, "#SALDO_KUP_DOB#", cPom )

   // datum posljednje uplate kupca
   cPom := DToC( dPUplKup )
   _txt := StrTran( _txt, "#D_P_UPLATA_KUP#", cPom )

   // datum posljednje promjene kupac
   cPom := DToC( dPPromKup )
   _txt := StrTran( _txt, "#D_P_PROMJENA_KUP#", cPom )

   // datum posljednje promjene dobavljac
   cPom := DToC( dPPromDob )
   _txt := StrTran( _txt, "#D_P_PROMJENA_DOB#", cPom )

   // id partner
   cPom := cPartner
   _txt := StrTran( _txt, "#U_PARTNER#", cPom )

   RETURN


// ----------------------------------------
// pronadji i vrati tekst iz FTXT
// ----------------------------------------
FUNCTION f_ftxt( cId )

   LOCAL xRet := ""

   select_o_ftxt( cId )
   xRet := Trim( ftxt->naz )

   RETURN xRet


// -----------------------------------
// dodaj u polje txt tekst
// lVise - vise tekstova
// -----------------------------------
FUNCTION fakt_a_to_public_var_txt( cVal, lEmpty )

   LOCAL nTArr

   nTArr := Select()

   IF lEmpty == nil
      lEmpty := .F.
   ENDIF
   // ako je prazno nemoj dodavati
   IF !lEmpty .AND. Empty( cVal )
      RETURN .F.
   ENDIF
   _txt += Chr( 16 ) + cVal + Chr( 17 )

   SELECT ( nTArr )

   RETURN .T.


// ---------------------------------------------
// stampa dokumenta od do - iscitaj iz GEN_UG
// ---------------------------------------------
FUNCTION ug_st_od_do( cBrOd, cBrDo )

   dDatGen := Date()
   cBrOd := Space( 8 )
   cBrDo := Space( 8 )

   Box(, 5, 60 )

   @ m_x + 2, m_y + 2 SAY "DATUM GENERACIJE" GET dDatGen
   READ

   O_GEN_UG
   SELECT gen_ug
   SET ORDER TO TAG "dat_gen"
   SEEK DToS( dDatGen )

   IF !Found()
      GO BOTTOM
   ENDIF

   cBrOd := field->brdok_od
   cBrDo := field->brdok_do

   @ m_x + 4, m_y + 2 SAY "FAKTURE OD BROJA" GET cBrOd
   @ m_x + 4, Col() + 2 SAY "DO BROJA" GET cBrDo

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN 0
   ENDIF

   RETURN 1


// ----------------------------------------------------------
// promjena cijene na artiklu unutar ugovora - grupno
// ----------------------------------------------------------
FUNCTION ug_ch_price()

   LOCAL cArtikal := Space( 10 )
   LOCAL nCijena := 0
   LOCAL nCnt
   LOCAL GetList := {}

   Box(, 1, 60 )
   @ m_x + 1, m_y + 2 SAY "Artikal:" GET cArtikal VALID !Empty( cArtikal )
   @ m_x + 1, Col() + 2 SAY "-> cijena:" GET nCijena PICT "99999.999"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   // ako je sve ok
   o_rugov()
   SELECT rugov
   GO TOP

   nCnt := 0

   Box(, 1, 50 )
   DO WHILE !Eof()

      IF field->idroba == cArtikal
         REPLACE field->cijena WITH nCijena

         ++nCnt
         @ m_x + 1, m_y + 2 SAY "zamjenjeno ukupno: " + AllTrim( Str( nCnt ) )
      ENDIF

      SKIP

   ENDDO
   BoxC()

   RETURN .T.
