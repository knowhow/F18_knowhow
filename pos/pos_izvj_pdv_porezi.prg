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


STATIC LEN_TRAKA := 40


FUNCTION PDVPorPoTar

   PARAMETERS cDat0, cDat1, cIdPos, cNaplaceno, cIdOdj

   LOCAL aNiz := {}
   LOCAL fSolo
   LOCAL aTarife := {}

   PRIVATE cTarife := Space ( 30 )
   PRIVATE aUsl := ".t."

   IF cNaplaceno == nil
      cNaplaceno := "1"
   ENDIF

   IF ( PCount() == 0 )
      fSolo := .T.
   ELSE
      fSolo := .F.
   ENDIF

   IF fSolo
      PRIVATE cDat0 := gDatum
      PRIVATE cDat1 := gDatum
      PRIVATE cIdPos := Space( 2 )
      PRIVATE cNaplaceno := "1"
   ENDIF

   IF ( cIdOdj == nil )
      cIdOdj := Space( 2 )
   ENDIF

  // o_tarifa()

   IF fSolo
    //  o_sifk()
    //  o_sifv()
      o_pos_kase()
    //  o_roba()
      o_pos_odj()
      o_pos_doks()
      o_pos_pos()
   ENDIF

   IF gVrstaRS <> "S"
      cIdPos := gIdPos
   ENDIF

   IF fSolo
      IF gVrstaRS <> "K"
         AAdd ( aNiz, { "Prod.mjesto (prazno-svi)    ", "cIdPos", "cIdPos='X' .or. empty(cIdPos).or.P_Kase(cIdPos)", "@!", } )
      ENDIF

      IF gVodiOdj == "D"
         AAdd ( aNiz, { "Odjeljenje (prazno-sva)", "cIdOdj", ".t.", "@!", } )
      ENDIF

      AAdd ( aNiz, { "Tarife (prazno sve)", "cTarife",, "@S10", } )
      AAdd ( aNiz, { "Izvjestaj se pravi od datuma", "cDat0",,, } )
      AAdd ( aNiz, { "                   do datuma", "cDat1",,, } )

      DO WHILE .T.
         IF !VarEdit( aNiz, 10, 5, 17, 74, 'USLOVI ZA IZVJESTAJ "POREZI PO TARIFAMA"', "B1" )
            CLOSERET
         ENDIF
         aUsl := Parsiraj( cTarife, "IdTarifa" )
         IF aUsl <> NIL .AND. cDat0 <= cDat1
            EXIT
         ELSEIF aUsl == nil
            MsgBeep ( "Kriterij za tarife nije korektno postavljen!" )
         ELSE
            Msg( "'Datum do' ne smije biti stariji nego 'datum od'!" )
         ENDIF
      ENDDO

      START PRINT CRET
      ZagFirma()

   ENDIF // fsolo


   DO WHILE .T.

      // petlja radi popusta
      aTarife := {}  // inicijalizuj matricu tarifa

      IF fSolo
         ?? gP12cpi

         IF cNaplaceno == "3"
            ? PadC( "**** OBRACUN ZA NAPLACENI IZNOS ****", LEN_TRAKA )
         ENDIF

         ? PadC( "POREZI PO TARIFAMA NA DAN " + FormDat1( gDatum ), LEN_TRAKA )
         ? PadC( "-------------------------------------", LEN_TRAKA )
         ?
         ? "PROD.MJESTO: "

         IF gVrstaRS <> "K"
            ?? cIdPos + "-"
            IF ( Empty( cIdPos ) )
               ?? "SVA"
            ELSE
               ?? cIdPos + "-" + AllTrim ( find_pos_kasa_naz( cIdPos ) )
            ENDIF
         ELSE
            ?? gPosNaz
         ENDIF

         IF !Empty( cIdOdj )
            ? "  Odjeljenje:", cIdOdj
         ENDIF

         ? "     Tarife:", iif ( Empty ( cTarife ), "SVE", cTarife )
         ? "PERIOD: " + FormDat1( cDat0 ) + " - " + FormDat1( cDat1 )
         ?

      ELSE // fsolo
         IF ( grbReduk < 1 )
            ?
         ENDIF
         IF cNaplaceno == "3"
            ? PadC( "**** OBRACUN ZA NAPLACENI IZNOS ****", LEN_TRAKA )
         ENDIF
         ? PadC ( "REKAPITULACIJA POREZA PO TARIFAMA", LEN_TRAKA )
         IF ( grbReduk < 1 )
            ? PadC ( "---------------------------------", LEN_TRAKA )
         ENDIF
      ENDIF // fsolo

      SELECT POS
      SET ORDER TO TAG "1"

      PRIVATE cFilter := ".t."

      IF !( aUsl == ".t." )
         cFilter += ".and." + aUsl
      ENDIF

      IF !Empty( cIdOdj )
         cFilter += ".and. IdOdj=" + dbf_quote( cIdOdj )
      ENDIF

      IF !( cFilter == ".t." )
         SET FILTER to &cFilter
      ENDIF

      SELECT pos_doks
      SET ORDER TO TAG "2"

      m := Replicate( "-", 12 ) + " " + Replicate( "-", 12 ) + " " + Replicate( "-", 12 )

      nTotOsn := 0
      nTotPDV := 0

      // matrica je lok var : aTarife:={}
      // filuj za poreze, VD_PRR - realizacija iz predhodnih sezona
      aTarife := Porezi( VD_RN, cDat0, aTarife, cNaplaceno )
      aTarife := Porezi( VD_PRR, cDat0, aTarife, cNaplaceno )

      ASort ( aTarife,,, {| x, y| x[ 1 ] < y[ 1 ] } )

      ? m

      ? "Tarifa (Stopa %)"
      ? PadL ( "MPV bez PDV", 12 ), PadL ( "PDV", 12 ), PadL( "MPV sa PDV", 12 )

      ? m

      FOR nCnt := 1 TO Len( aTarife )

         select_o_tarifa( aTarife[ nCnt ][ 1 ] )
         nPDV := tarifa->opp
         SELECT pos_doks

         // ispisi opis i na realizaciji kao na racunu
         ? aTarife[ nCnt ][ 1 ], "(" + Str( nPDV ) + "%)"

         ? Str( aTarife[ nCnt ][ 2 ], 12, 2 ), Str( aTarife[ nCnt ][ 3 ], 12, 2 ), Str( Round( aTarife[ nCnt ][ 6 ], 2 ), 12, 2 )

         nTotOsn += Round( aTarife[ nCnt ][ 6 ], 2 ) -Round( aTarife[ nCnt ][ 3 ], 2 )
         nTotPDV += Round( aTarife[ nCnt ][ 3 ], 2 )
      NEXT

      ? m
      ? "UKUPNO:"
      ? Str ( nTotOsn, 12, 2 ), Str ( nTotPDV, 12, 2 ), Str( nTotOsn + nTotPDV, 12, 2 )
      ? m
      ?
      ?

      IF !fsolo
         EXIT
      ENDIF

      IF cNaplaceno == "1"  // prvi krug u dowhile petlji
         cNaplaceno := "3"
      ELSE
         // vec odradjen drugi krug
         EXIT
      ENDIF

   ENDDO // petlja radi popusta

   SELECT pos
   SET FILTER TO

   IF gVrstaRS <> "S"
      PaperFeed ()
   ENDIF

   IF fSolo
      ENDPRINT
   ENDIF

   CLOSE ALL

   RETURN .T.
