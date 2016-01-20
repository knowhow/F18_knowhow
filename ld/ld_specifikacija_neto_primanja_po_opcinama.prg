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


STATIC cLinija
STATIC nStranica := 0


STATIC FUNCTION otvori_tabele()

   tipprn_use()

   O_OPS
   O_KBENEF
   O_VPOSLA
   O_LD_RJ
   O_RADN
   O_LD

   RETURN



FUNCTION ld_specifikacija_neto_primanja_po_opcinama()

   LOCAL nC1 := 20
   LOCAL cKBenef := " ", cVPosla := "  "

   cIdRadn := Space( _LR_ )
   cIdRj := gRj
   cMjesec := gMjesec
   cGodina := gGodina
   cObracun := gObracun
   cVarSort := fetch_metric( "ld_specifikacija_neto_po_opcini_sort", my_user(), "2" )

   otvori_tabele()

   Box(, 8, 50 )
   @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno-sve): "  GET cIdRJ
   @ m_x + 2, m_y + 2 SAY "Mjesec: "  GET  cmjesec  PICT "99"
   @ m_x + 2, Col() + 2 SAY8 "Obračun: " GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   @ m_x + 3, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   @ m_x + 4, m_y + 2 SAY8 "Koeficijent benef.radnog staža (prazno-svi): "  GET  cKBenef VALID Empty( cKBenef ) .OR. P_KBenef( @cKBenef )
   @ m_x + 5, m_y + 2 SAY "Vrsta posla (prazno-svi): "  GET  cVPosla
   @ m_x + 8, m_y + 2 SAY8 "Sortirati po(1-šifri,2-prezime+ime)"  GET cVarSort VALID cVarSort $ "12"  PICT "9"
   READ 
   clvbox()
   ESC_BCR
   BoxC()

   set_metric( "ld_specifikacija_neto_po_opcini_sort", my_user(), cVarSort )

   IF !Empty( cKbenef )
      SELECT kbenef
      hseek  cKbenef
   ENDIF
   IF !Empty( cVPosla )
      SELECT vposla
      hseek  cVposla
   ENDIF

   napravi_filter_na_tabeli_ld( cIdRj, cGodina, cMjesec, cObracun, cVarSort )

   EOF CRET

   nStrana := 0

   cLinija := "----- ------ ---------------------------------- ------- ----------- ----------- -----------"

   bZagl := {|| zaglavlje_izvjestaja( cVPosla, cKBenef ) }

   SELECT ld_rj
   hseek ld->idrj

   SELECT ld

   START PRINT CRET
   P_12CPI

   Eval( bZagl )

   nRbr := 0
   nT2a := nT2b := 0
   nT1 := nT2 := nT3 := nT3b := nT4 := 0
   nVanP := 0  // van neta plus
   nVanM := 0  // van neta minus

   DO WHILE !Eof()

      cTekOpSt := SortOpSt( IDRADN )

      SELECT OPS
      SEEK cTekOpSt

      ?
      ?U "OPŠTINA STANOVANJA: " + ID + " - " + NAZ
      ? "-----------------------------------------------"

      SELECT LD

      nRbr := 0
      nT2a := nT2b := 0
      nT1 := nT2 := nT3 := nT3b := nT4 := 0
      nVanP := 0  // van neta plus
      nVanM := 0  // van neta minus

      DO WHILE !Eof() .AND. SortOpSt( IDRADN ) == cTekOpSt

         ScatterS( godina, mjesec, idrj, idradn )

         SELECT radn
         hseek _idradn
         SELECT vposla
         hseek _idvposla
         SELECT kbenef
         hseek vposla->idkbenef
         SELECT ld
         IF !Empty( cVPosla ) .AND. cVPosla <> Left( _idvposla, 2 )
            SKIP
            LOOP
         ENDIF
         IF !Empty( cKBenef ) .AND. cKBenef <> kbenef->id
            SKIP
            LOOP
         ENDIF

         nVanP := 0
         nVanM := 0

         FOR i := 1 TO cLDPolja

            cPom := PadL( AllTrim( Str( i ) ), 2, "0" )

            SELECT tippr
            SEEK cPom
            SELECT ld

            IF tippr->( Found() ) .AND. tippr->aktivan == "D"
               nIznos := _i&cpom
               IF tippr->uneto == "N" .AND. nIznos <> 0
                  IF nIznos > 0
                     nVanP += nIznos
                  ELSE
                     nVanM += nIznos
                  ENDIF
               ELSEIF tippr->uneto == "D" .AND. nIznos <> 0
               ENDIF
            ENDIF
         NEXT

         IF PRow() > RPT_PAGE_LEN + gPStranica
            FF
            Eval( bZagl )
         ENDIF

         ? Str( ++nRbr, 4 ) + ".", idradn, RADNIK
         nC1 := PCol() + 1
         @ PRow(), PCol() + 1 SAY _usati  PICT gpics
         @ PRow(), PCol() + 1 SAY _uneto  PICT gpici
         @ PRow(), PCol() + 1 SAY nVanP + nVanM   PICT gpici
         @ PRow(), PCol() + 1 SAY _uiznos PICT gpici

         nT1 += _usati
         nT2 += _uneto
         nT3 += nVanP
         nT3b += nVanM
         nT4 += _uiznos

         SKIP 1

      ENDDO


      IF PRow() > 60 + gpStranica
          FF
          Eval( bZagl )
      ENDIF

      ? cLinija
      ? " UKUPNO:"
      @ PRow(), nC1 SAY  nT1 PICT gpics
      @ PRow(), PCol() + 1 SAY  nT2 PICT gpici
      @ PRow(), PCol() + 1 SAY  nT3 + nT3b PICT gpici
      @ PRow(), PCol() + 1 SAY  nT4 PICT gpici
      ? cLinija

   ENDDO

   FF
   END PRINT

   my_close_all_dbf()

   RETURN 



STATIC FUNCTION napravi_filter_na_tabeli_ld( cIdRj, cGodina, cMjesec, cObracun, cVarSort )

   LOCAL nSlog
   LOCAL nUkupno
   LOCAL cSort1, cFilt

   SELECT ld

   IF Empty( cIdRj )
      cIdrj := ""
      IF cVarSort == "1"
         Box(, 2, 30 )
         nSlog := 0
         nUkupno := RECCOUNT2()
         cSort1 := "SortOpSt(IDRADN)+idradn"
         cFilt := IF( Empty( cMjesec ), ".t.", "MJESEC==cMjesec" ) + ".and." + ;
            IF( Empty( cGodina ), ".t.", "GODINA==cGodina" )
         IF !Empty( cObracun )
            cFilt += ( ".and. OBR==" + cm2str( cObracun ) )
         ENDIF
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ELSE
         Box(, 2, 30 )
         nSlog := 0
         nUkupno := RECCOUNT2()
         cSort1 := "SortOpSt(IDRADN)+SortPrez(IDRADN)"
         cFilt := IF( Empty( cMjesec ), ".t.", "MJESEC==cMjesec" ) + ".and." + ;
            IF( Empty( cGodina ), ".t.", "GODINA==cGodina" )
         IF !Empty( cObracun )
            cFilt += ( ".and. OBR==" + cm2str( cObracun ) )
         ENDIF
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ENDIF
   ELSE
      IF cVarSort == "1"
         Box(, 2, 30 )
         nSlog := 0
         nUkupno := RECCOUNT2()
         cSort1 := "SortOpSt(IDRADN)+idradn"
         cFilt := "IDRJ==cIdRj.and." + ;
            IF( Empty( cMjesec ), ".t.", "MJESEC==cMjesec" ) + ".and." + ;
            IF( Empty( cGodina ), ".t.", "GODINA==cGodina" )
         IF !Empty( cObracun )
            cFilt += ( ".and. OBR==" + cm2str( cObracun ) )
         ENDIF
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ELSE
         Box(, 2, 30 )
         nSlog := 0
         nUkupno := RECCOUNT2()
         cSort1 := "SortOpSt(IDRADN)+SortPrez(IDRADN)"
         cFilt := "IDRJ==cIdRj.and." + ;
            IF( Empty( cMjesec ), ".t.", "MJESEC==cMjesec" ) + ".and." + ;
            IF( Empty( cGodina ), ".t.", "GODINA==cGodina" )
         IF !Empty( cObracun )
            cFilt += ( ".and. OBR==" + cm2str( cObracun ) )
         ENDIF
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ENDIF
   ENDIF

   RETURN



STATIC FUNCTION zaglavlje_izvjestaja( cVPosla, cKBenef )

   P_COND
   ? Upper( gTS ) + ":", gnFirma
   ?

   IF Empty( cidrj )
      ? "Pregled za sve RJ ukupno:"
   ELSE
      ? "RJ:", cidrj, ld_rj->naz
   ENDIF

   ?? "  Mjesec:", Str( cmjesec, 2 ) + IspisObr()
   ?? "    Godina:", Str( cGodina, 5 )

   DevPos( PRow(), 74 )

   ?? "Str.", Str( ++ nStranica, 3 )

   IF !Empty( cvposla )
      ? "Vrsta posla:", cvposla, "-", vposla->naz
   ENDIF

   IF !Empty( cKBenef )
      ?U "Stopa beneficiranog r.staža:", ckbenef, "-", kbenef->naz, ":", kbenef->iznos
   ENDIF

   ? cLinija
   ?U " Rbr * Šifra*         Naziv radnika            *  Sati *   Neto    *  Odbici   * ZA ISPLATU*"
   ? "     *      *                                  *       *           *           *           *"
   ? cLinija

   RETURN




