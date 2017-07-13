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

FUNCTION PrepisKumPr()

   LOCAL nSir := 80
   LOCAL nRobaSir := 40
   LOCAL cLm := Space( 5 )
   LOCAL cPicKol := "999999.999"

   START PRINT CRET

   IF gVrstaRS == "S"
      P_INI
      P_10CPI
   ELSE
      nSir := 40
      nRobaSir := 18
      cLM := ""
      cPicKol := "9999.999"
   ENDIF

   ZagFirma()

   IF Empty( pos_doks->IdPos )
      ? PadC( "KUMULATIV PROMETA " + AllTrim( pos_doks->BrDok ), nSir )
   ELSE
      ? PadC( "KUMULATIV PROMETA " + AllTrim( pos_doks->IdPos ) + "-" + AllTrim( pos_doks->BrDok ), nSir )
   ENDIF

   ?
   ? PadC( FormDat1( pos_doks->Datum ), nSir )
   ?
   SELECT VRSTEP
   HSEEK pos_doks->IdVrsteP

   IF gVrstaRS == "S"
      cPom := VRSTEP->Naz
   ELSE
      cPom := Left( VRSTEP->Naz, 23 )
   ENDIF

   ? cLM + "Vrsta placanja:", cPom

   select_o_partner( pos_doks->IdGost )

   IF gVrstaRS == "S"
      cPom := partn->Naz
   ELSE
      cPom := Left( partn->Naz, 23 )
   ENDIF

   ? cLM + "Gost / partner:", cPom

   IF pos_doks->Placen == PLAC_JEST .OR. pos_doks->IdVrsteP == gGotPlac
      ? cLM + "       Placeno:", "DA"
   ELSE
      ? cLM + "       Placeno:", "NE"
   ENDIF

   SELECT POS
   HSEEK pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )

   ? cLM
   IF gVrstaRS == "S"
      ?? "Sifra    Naziv                                    JMJ Cijena  Kolicina"
      m := cLM + "-------- ---------------------------------------- --- ------- ----------"
   ELSE
      ?? "Sifra    Naziv              JMJ Kolicina"
      m := cLM + "-------- ------------------ --- --------"
   ENDIF
   ? m

   nFin := 0
   SELECT POS

   DO WHILE !Eof() .AND. POS->( IdPos + IdVd + DToS( datum ) + BrDok ) == pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )
      IF gVrstaRS == "S" .AND. PRow() > 63 -dodatni_redovi_po_stranici()
         FF
      ENDIF
      ? cLM
      ?? IdRoba, ""
      select_o_roba( POS->IdRoba )
      ?? PadR( ROBA->Naz, nRobaSir ), ROBA->Jmj, ""
      SELECT POS
      IF gVrstaRS == "S"
         ?? TRANS( POS->Cijena, "9999.99" ), ""
      ENDIF
      ?? TRANS( POS->Kolicina, cPicKol )
      nFin += POS->( Kolicina * Cijena )
      SKIP
   ENDDO

   IF gVrstaRS == "S" .AND. PRow() > 63 -dodatni_redovi_po_stranici() -7
      FF
   ENDIF

   ? m
   ? cLM

   IF gVrstaRS == "S"
      ?? PadL( "IZNOS DOKUMENTA (" + Trim( gDomValuta ) + ")", 13 + nRobaSir ), TRANS( nFin, "999,999,999,999.99" )
   ELSE
      ?? PadL( "IZNOS DOKUMENTA (" + Trim( gDomValuta ) + ")", 10 + nRobaSir ), TRANS( nFin, "9,999,999.99" )
   ENDIF

   ? m

   IF gVrstaRS == "S"
      FF
   ELSE
      PaperFeed()
   ENDIF

   ENDPRINT
   SELECT pos_doks

   RETURN .T.
