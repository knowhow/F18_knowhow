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


// --------------------------------------
// meni sifrarnik ugovora
// --------------------------------------
FUNCTION SifUgovori()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1
   LOCAL lPrev

   AAdd( _opc, "1. ugovori                                    " )
   AAdd( _opcexe, {|| lPrev := gMeniSif, gMeniSif := .T., P_Ugov(), gMeniSif := lPrev } )
   AAdd( _opc, "2. stampa naljepnica iz ugovora " )
   AAdd( _opcexe, {|| kreiraj_adrese_iz_ugovora() } )
   AAdd( _opc, "3. parametri ugovora" )
   AAdd( _opcexe, {|| DFTParUg( .F. ) } )
   AAdd( _opc, "4. grupna zamjena cijene artikla u ugovoru" )
   AAdd( _opcexe, {|| ug_ch_price() } )

   f18_menu( "mugo", .F., _izbor, _opc, _opcexe )

   my_close_all_dbf()

   RETURN .T.


// -------------------------------------------------------
// vraca naziv partnera
// -------------------------------------------------------
FUNCTION NazPartn()

   LOCAL cVrati
   LOCAL cPom

   cPom := Upper( AllTrim( mjesto ) )
   IF cPom $ Upper( naz ) .OR. cPom $ Upper( naz2 )
      cVrati := Trim( naz ) + " " + Trim( naz2 )
   ELSE
      cVrati := Trim( naz ) + " " + Trim( naz2 ) + " " + Trim( mjesto )
   ENDIF

   RETURN PadR( cVrati, 40 )


// -----------------------------------
// ??????
// -----------------------------------
FUNCTION MSAY2( x, y, c )

   @ x, y SAY c

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

   SELECT ftxt
   HSEEK cId
   xRet := Trim( naz )

   RETURN xRet


// -----------------------------------
// dodaj u polje txt tekst
// lVise - vise tekstova
// -----------------------------------
FUNCTION a_to_txt( cVal, lEmpty )

   LOCAL nTArr

   nTArr := Select()

   IF lEmpty == nil
      lEmpty := .F.
   ENDIF
   // ako je prazno nemoj dodavati
   IF !lEmpty .AND. Empty( cVal )
      RETURN
   ENDIF
   _txt += Chr( 16 ) + cVal + Chr( 17 )

   SELECT ( nTArr )

   RETURN


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
   O_RUGOV
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

   RETURN
