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


// --------------------------------------------
// kreiranje pomocne tabele
// --------------------------------------------
STATIC FUNCTION cre_tmp( cPath )

   LOCAL aDbf := {}

   AAdd( aDbf, { "idfirma", "C", 2, 0  } )
   AAdd( aDbf, { "idkonto", "C", 7, 0  } )
   AAdd( aDbf, { "kto_opis", "C", 100, 0  } )
   AAdd( aDbf, { "opis", "C", 100, 0  } )
   AAdd( aDbf, { "dug", "N", 15, 5  } )
   AAdd( aDbf, { "pot", "N", 15, 5  } )
   AAdd( aDbf, { "saldo", "N", 15, 5  } )

   t_exp_create( aDbf )

   o_tmp( cPath )

   RETURN


// -----------------------------------------------
// otvori i indeksiraj pomocnu tabelu
// -----------------------------------------------
STATIC FUNCTION o_tmp( cPath )

   SELECT ( 248 )
   USE ( cPath + "r_export" ) ALIAS "r_export"
   INDEX ON idfirma + idkonto TAG "1"

   RETURN


// -----------------------------------------------------
// specifikacija po analitickim kontima
// -----------------------------------------------------
FUNCTION spec_an()

   LOCAL cSK := "N"
   LOCAL nYearFrom
   LOCAL nYearTo
   LOCAL i
   LOCAL lSilent
   LOCAL lWriteKParam
   LOCAL cP_path := PRIVPATH
   LOCAL cT_sez := tekuca_sezona()

   PRIVATE nC := 66

   // formiraj pomocnu tabelu
   cre_tmp( cP_path )

   cIdFirma := gFirma
   picBHD := FormPicL( "9 " + gPicBHD, 20 )

   O_PARTN

   dDatOd := dDatDo := CToD( "" )

   qqKonto := Space( 100 )

   cTip := "1"

   Box( "", 10, 65 )
   SET CURSOR ON
   cNula := "N"
   DO WHILE .T.
      @ m_x + 1, m_y + 6 SAY "SPECIFIKACIJA ANALITICKIH KONTA"
      IF gNW == "D"
         @ m_x + 3, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 3, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 4, m_y + 2 SAY "Konto " GET qqKonto  PICT "@!S50"
      @ m_x + 5, m_y + 2 SAY "Datum od" GET dDatOd
      @ m_x + 5, Col() + 2 SAY "do" GET dDatDo
      IF fin_dvovalutno()
         @ m_x + 6, m_y + 2 SAY "Obracun za " + AllTrim( ValDomaca() ) + "/" + AllTrim( ValPomocna() ) + " (1/2):" GET cTip VALID ctip $ "12"
      ENDIF
      @ m_x + 7, m_y + 2 SAY "Prikaz sintetickih konta (D/N):" GET cSK PICT "@!" VALID cSK $ "DN"
      @ m_x + 9, m_y + 2 SAY "Prikaz stavki sa saldom 0 D/N" GET cNula PICT "@!" VALID cNula  $ "DN"
      cIdRJ := ""
      IF gRJ == "D" .AND. gSAKrIz == "D"
         cIdRJ := "999999"
         @ m_x + 10, m_y + 2 SAY "Radna jedinica (999999-sve): " GET cIdRj
      ENDIF

      READ

      ESC_BCR

      aUsl1 := Parsiraj( qqKonto, "IdKonto" )

      IF aUsl1 <> NIL
         EXIT
      ENDIF
   ENDDO
   BoxC()

   // godina od - do
   nYearFrom := Year( dDatOd )
   nYearTo := Year( dDatDo )
   lInSez := .F.

   IF ( nYearTo - nYearFrom ) <> 0 .AND. nYearTo = Year( Date() )
      // ima vise godina, prosetaj sezone
      lInSez := .T.
   ENDIF

   IF cIdRj == "999999"
      cIdRj := ""
   ENDIF

   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. "." $ cidrj
      cIdRj := Trim( StrTran( cidrj, ".", "" ) )
      // odsjeci ako je tacka.
      // prakticno "01. " -> sve koje pocinju sa  "01"
   ENDIF

   cIdFirma := Left( cIdFirma, 2 )

   // prodji sada kroz godine i napravi selekciju podataka ...

   lSilent := .T.
   lWriteKParam := .T.

   FOR i := nYearFrom TO nYearTo

      IF lInSez = .T.
         // str(i) je sezona koju ganjamo...
         goModul:oDataBase:logAgain( AllTrim( Str( i ) ), ;
            lSilent, lWriteKParam )

         // otvori pomocnu tabelu opet
         o_tmp( cP_path )

      ENDIF

      O_KONTO

      IF gRJ == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
         otvori_sint_anal_kroz_temp( .F., "IDRJ='" + cIdRJ + "'" )
      ELSE
         O_ANAL
      ENDIF

      SELECT anal
      SET ORDER TO 1

      cFilt1 := "IdFirma==" + dbf_quote( cIdFirma )

      IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
         cFilt1 += ( ".and.DatNal>=" + dbf_quote( dDatOd ) + ".and.DatNal<=" + dbf_quote( dDatDo ) )
      ENDIF

      IF aUsl1 <> ".t."
         cFilt1 += ( ".and." + aUsl1 )
      ENDIF

      SET FILTER to &cFilt1
      GO TOP

      DO WHILE !Eof()

         cIdKonto := field->idkonto

         nd := 0
         np := 0

         DO WHILE !Eof() .AND. cIdKonto == field->idkonto

            IF lInSez = .T.

               // ako saltas po sezonama
               // preskoci pocetna stanja...

               IF field->idvn == "00"
                  SKIP
                  LOOP
               ENDIF
            ENDIF

            IF cTip == "1"
               nd += dugbhd
               np += potbhd
            ELSE
               nd += dugdem
               np += potdem
            ENDIF

            SKIP
         ENDDO

         SELECT konto
         HSEEK cIdKonto

         SELECT anal

         IF cNula == "D" .OR. Round( nd - np, 3 ) <> 0

            SELECT r_export
            GO TOP
            SEEK cIdFirma + cIdKonto

            my_flock()

            IF !Found()

               APPEND BLANK

               REPLACE field->idfirma WITH cIdFirma
               REPLACE field->idkonto WITH cIdKonto
               REPLACE field->kto_opis WITH AllTrim( konto->naz )
            ENDIF

            REPLACE field->dug WITH field->dug + nd
            REPLACE field->pot WITH field->pot + np
            REPLACE field->saldo WITH field->saldo + ( nd - np )

            my_unlock()

            SELECT anal

         ENDIF
      ENDDO
   NEXT

/*
   TODO: izbaciti
   // uvijek na kraju budi u trenutnom radnom podrucju
   IF lInSez = .T.
      goModul:oDataBase:logAgain( cT_sez, lSilent, lWriteKParam )
      // otvori pomocnu tabelu opet...
      o_tmp( cP_path )
   ENDIF
*/

   Pic := PicBhd

   START PRINT CRET

   m := "------ --------------------------------------------------------- --------------------- -------------------- --------------------"
   nStr := 0

   nud := 0
   nup := 0

   SELECT r_export
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      cSin := Left( field->idkonto, 3 )

      nkd := 0
      nkp := 0

      DO WHILE !Eof() .AND. cSin == Left( field->idkonto, 3 )

         cIdKonto := field->idkonto

         IF PRow() == 0
            Header()
         ENDIF

         IF PRow() > 63 + dodatni_redovi_po_stranici()
            FF
            Header()

         ENDIF

         IF cNula == "D" .OR. field->saldo <> 0

            ? field->idkonto, PadR( field->kto_opis, 57 )

            nC := PCol() + 1

            @ PRow(), PCol() + 1 SAY field->dug PICT pic
            @ PRow(), PCol() + 1 SAY field->pot PICT pic
            @ PRow(), PCol() + 1 SAY ( field->dug - field->pot ) ;
               PICT pic

            nkd += field->dug
            nkp += field->pot

         ENDIF

         SKIP

      ENDDO

      IF PRow() > 61 + dodatni_redovi_po_stranici()
         FF
         Header()
      ENDIF

      IF cSK == "D" .AND. ( nkd != 0 .OR. nkp != 0 )

         O_KONTO
         SELECT konto
         HSEEK cSin
         SELECT r_export

         ? m
         ?  "SINT.K.", cSin, ":", PadR( konto->naz, 50 )
         @ PRow(), nC       SAY nkd PICT pic
         @ PRow(), PCol() + 1 SAY nkp PICT pic
         @ PRow(), PCol() + 1 SAY nkd - nkp PICT pic
         ? m

      ENDIF

      nud += nkd
      nup += nkp

   ENDDO

   IF PRow() > 61 + dodatni_redovi_po_stranici()
      FF
      Header()
   ENDIF

   ? m
   ? " UKUPNO:"
   @ PRow(), nC       SAY nud PICT pic
   @ PRow(), PCol() + 1 SAY nup PICT pic
   @ PRow(), PCol() + 1 SAY nud - nup PICT pic
   ? m

   FF
   ENDPRINT

   closeret

   RETURN


// ------------------------------
// zaglavlje izvjestaja
// ------------------------------
STATIC FUNCTION Header()

   ?
   P_COND
   ?? "FIN.P:SPECIFIKACIJA ANALITI�KIH KONTA  ZA", AllTrim( iif( cTip == "1", ValDomaca(), ValPomocna() ) )
   IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      ?? "  ZA NALOGE U PERIODU ", dDatOd, "-", dDatDo
   ENDIF
   ?? " NA DAN: "; ?? Date()

   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )

   IF gNW == "D"
      ? "Firma:", gFirma, gNFirma
   ELSE
      SELECT PARTN; HSEEK cIdFirma
      ? "Firma:", cidfirma, PadR( partn->naz, 25 ), partn->naz2
   ENDIF

   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
      ? "Radna jedinica ='" + cIdRj + "'"
   ENDIF

   SELECT r_export
   ? m
   ? "KONTO      N A Z I V                                                           duguje            potra�uje                saldo"
   ? m

   RETURN
