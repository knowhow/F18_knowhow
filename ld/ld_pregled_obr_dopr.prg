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

#include "ld.ch"


FUNCTION ld_pregled_obr_doprinosa()

   LOCAL cTipRada := " "

   cIdRj    := gRj
   cGodina  := gGodina
   cObracun := gObracun
   cMjesecOd := cMjesecDo := gMjesec
   cObracun := " "
   cDopr   := "90;"
   cNazDopr := "ZDRAVSTVENO OSIGURANJE"
   cPoOps := "S"

   O_PAROBR
   O_LD_RJ
   O_OPS
   O_RADN
   O_LD
   O_POR
   O_DOPR

   O_PARAMS
   PRIVATE cSection := "5", cHistory := " ", aHistory := {}

   cMjesecOd := Str( cMjesecOd, 2 )
   cMjesecDo := Str( cMjesecDo, 2 )
   cGodina   := Str( cGodina,4 )

   RPar( "p1", @cMjesecOd )
   RPar( "p2", @cMjesecDo )
   RPar( "p3", @cGodina  )
   RPar( "p4", @cIdRj    )
   RPar( "p5", @cDopr    )
   RPar( "p6", @cNazDopr )
   RPar( "p7", @cPoOps )

   cMjesecOd := Val( cMjesecOd )
   cMjesecDo := Val( cMjesecDo )
   cGodina   := Val( cGodina  )
   cDopr     := PadR( cDopr, 40 )
   cNazDopr  := PadR( cNazDopr, 40 )

   Box( "#Uslovi za izvjestaj o obracunatim doprinosima", 8, 75 )
   @ m_x + 1, m_y + 2   SAY "Tip rada: "   GET cTipRada VALID val_tiprada( cTipRada )
   @ m_x + 2, m_y + 2   SAY "Radna jedinica (prazno-sve): "   GET cIdRJ
   @ m_x + 3, m_y + 2   SAY "Mjesec od: "                     GET cMjesecOd PICT "99"
   @ m_x + 3, Col() + 2 SAY "do"                              GET cMjesecDo PICT "99"
   @ m_x + 4, m_y + 2   SAY "Godina: "                        GET cGodina   PICT "9999"
   @ m_x + 4, Col() + 2 SAY "Obracun: "                       GET cObracun
   @ m_x + 5, m_y + 2   SAY "Doprinosi (npr. '3X;')"          GET cDopr PICT "@!"
   @ m_x + 6, m_y + 2   SAY "Obracunati doprinosi za (naziv)" GET cNazDopr PICT "@!"
   @ m_x + 7, m_y + 2   SAY "Po kantonu (S-stanovanja,R-rada)" GET cPoOps VALID cPoOps $ "SR" PICT "@!"
   READ; ESC_BCR
   BoxC()

   cMjesecOd := Str( cMjesecOd, 2 )
   cMjesecDo := Str( cMjesecDo, 2 )
   cGodina   := Str( cGodina,4 )
   cDopr     := Trim( cDopr )
   cNazDopr  := Trim( cNazDopr )

   WPar( "p1", cMjesecOd )
   WPar( "p2", cMjesecDo )
   WPar( "p3", cGodina  )
   WPar( "p4", cIdRj    )
   WPar( "p5", cDopr    )
   WPar( "p6", cNazDopr )
   WPar( "p7", cPoOps )
   SELECT PARAMS
   USE

   cMjesecOd := Val( cMjesecOd )
   cMjesecDo := Val( cMjesecDo )
   cGodina   := Val( cGodina  )

   SELECT RADN

   IF cPoOps == "R"
      SET RELATION TO idopsrad INTO ops
   ELSE
      SET RELATION TO idopsst INTO ops
   ENDIF

   SELECT LD
   SET RELATION TO idradn INTO radn

   cSort := "OPS->idkan+SortPre2()+str(mjesec)"
   cFilt := "godina==cGodina .and. mjesec>=cMjesecOd .and. mjesec<=cMjesecDo"

   IF cDopr == "71;"
      cFilt += " .and. radn->k4 = 'BF'"
   ENDIF

   IF gVarObracun == "2"
      IF Empty( cTipRada )
         cFilt += " .and. radn->tiprada $ ' #N#I' "
      ELSE
         cFilt += " .and. radn->tiprada == " + cm2str( cTipRada )
      ENDIF
   ENDIF

   IF !Empty( cIdRj )
      cFilt += " .and. idrj=cIdRJ"
   ENDIF

   INDEX ON &cSort TO "tmpld" FOR &cFilt

   GO TOP

   IF Eof()
      MsgBeep( "Nema podataka!" )
      my_close_all_dbf()
      RETURN
   ENDIF

   START PRINT CRET

   gOstr := "D"
   gTabela := 1
   
   cKanton := cRadnik := ""; lSubTot7 := .F. ; cSubTot7 := ""

   aKol := { { "PREZIME (IME RODITELJA) IME", {|| cRadnik   }, .F., "C", 32, 0, 1, 1 } }

   nKol := 1

   FOR i := cMjesecOd TO cMjesecDo
      cPom := "xneto" + AllTrim( Str( i ) )
      &cPom := 0
      AAdd( aKol, { ld_naziv_mjeseca( i ), {|| &cPom. }, .T., "N", 9, 2, 1, ++nKol } )
      cPom := "xdopr" + AllTrim( Str( i ) )
      &cPom := 0
      AAdd( aKol, { "NETO/DOPR", {|| &cPom. }, .T., "N", 9, 2, 2,   nKol } )
   NEXT

   xnetoUk := xdoprUk := 0
   AAdd( aKol, { "UKUPNO", {|| xnetoUk }, .T., "N", 10, 2, 1, ++nKol } )
   AAdd( aKol, { "NETO/DOPR", {|| xdoprUk }, .T., "N", 10, 2, 2,   nKol } )

   P_10CPI

   ?? gnFirma
   ?
   ? "Mjesec: od", Str( cMjesecOd, 2 ) + ".", "do", Str( cMjesecDo, 2 ) + "."
   ?? "    Godina:", Str( cGodina, 4 )
   ? "Obuhvacene radne jedinice: "; ?? IF( !Empty( cIdRJ ), "'" + cIdRj + "'", "SVE" )
   ? "Obuhvaceni doprinosi (sifre):", "'" + cDopr + "'"
   ?

   SELECT LD

   StampaTabele( aKol, {|| NIL },, gTabela,, ;
      , "IZVJESTAJ O OBRACUNATIM DOPRINOSIMA ZA " + cNazDopr, ;
      {|| FFor7() }, IF( gOstr == "D",, -1 ),,, {|| SubTot7() },, )

   FF
   END PRINT
   
   my_close_all_dbf()
   RETURN



STATIC FUNCTION FFor7()

   IF OPS->idkan <> cKanton .AND. Len( cKanton ) > 0
      lSubTot7 := .T.
      cSubTot7 := cKanton
   ENDIF

   cKanton := OPS->idkan
   xNetoUk := xDoprUk := 0
   cRadnik := RADN->( PadR(  Trim( naz ) + " (" + Trim( imerod ) + ") " + ime, 32 ) )
   cIdRadn := IDRADN
   nKLO := 0
   cTipRada := ""

   IF gVarObracun == "2"
      nKLO := radn->klo
      cTipRada := g_tip_rada( ld->idradn, ld->idrj )
   ENDIF

   FOR i := cMjesecOd TO cMjesecDo
      cPom := "xneto" + AllTrim( Str( i ) ); &cPom := 0
      cPom := "xdopr" + AllTrim( Str( i ) ); &cPom := 0
   NEXT

   DO WHILE !Eof() .AND. OPS->idkan == cKanton .AND. IDRADN == cIdRadn
      nTekMjes := mjesec
      _uneto := 0
      DO WHILE !Eof() .AND. OPS->idkan == cKanton .AND. IDRADN == cIdRadn .AND. mjesec == nTekMjes
         _uneto += uneto
         SKIP 1
      ENDDO
      SKIP -1
      // neto
      cPom    := "xneto" + AllTrim( Str( mjesec ) )
      &cPom   := _uneto
      xnetoUk += _uneto
      // doprinos
      PoDoIzSez( godina, mjesec )
      nDopr   := IzracDopr( cDopr, nKLO, cTipRada )
      cPom    := "xdopr" + AllTrim( Str( mjesec ) )
      &cPom   := nDopr
      xdoprUk += nDopr
      SKIP 1
   ENDDO

   SKIP -1

   RETURN .T.




STATIC FUNCTION SubTot7()

   LOCAL aVrati := { .F., "" }

   IF lSubTot7 .OR. Eof()
      aVrati := { .T., "UKUPNO KANTON '" + IF( Eof(), cKanton, cSubTot7 ) + "'" }
      lSubTot7 := .F.
   ENDIF

   RETURN aVrati



