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



STATIC FUNCTION _o_tables()

   O_ODJ
   O_KASE
   O_SIFK
   O_SIFV
   O_ROBA
   o_pos_pos()
   o_pos_doks()

   RETURN .T.



FUNCTION pos_top_narudzbe()

   LOCAL aNiz := {}, cPor, cZaduz, aVrsteP
   PRIVATE cIdPos, cRoba := Space( 60 ), dDat0, dDat1, nTop := 10, cSta := "I"

   dDat0 := dDat1 := Date ()

   aDbf := {}
   AAdd ( aDbf, { "IdRoba",   "C", 10, 0 } )
   AAdd ( aDbf, { "Kolicina", "N", 15, 3 } )
   AAdd ( aDbf, { "Iznos",    "N", 20, 3 } )
   AAdd ( aDbf, { "Iznos2",    "N", 20, 3 } )
   AAdd ( aDbf, { "Iznos3",    "N", 20, 3 } )
   pos_cre_pom_dbf( aDbf )

   SELECT ( F_POM )
   IF Used()
      USE
   ENDIF

   my_use_temp( "POM", my_home() + "pom", .F., .T. )

   INDEX on ( idroba ) TAG "1"
   INDEX on ( Str( iznos, 20, 3 ) ) TAG "2"
   INDEX on ( Str( kolicina, 15, 3 ) ) TAG "3"

   SET ORDER TO TAG "1"

   _o_tables()

   PRIVATE cIdPOS := gIdPos
   IF gVrstaRS <> "K"
      aNiz := { { "Prodajno mjesto", "cIdPos", "cidpos='X' .or. Empty(cIdPos).or.P_Kase(@cIdPos)",, } }
   ENDIF
   AAdd ( aNiz, { "Roba (prazno-sve)", "cRoba",, "@!S30", } )
   AAdd ( aNiz, { "Pregled po Iznosu/Kolicini/Oboje (I/K/O)", "cSta", "cSta$'IKO'", "@!", } )
   AAdd ( aNiz, { "Izvjestaj se pravi od datuma", "dDat0",,, } )
   AAdd ( aNiz, { "                   do datuma", "dDat1",,, } )
   AAdd ( aNiz, { "Koliko artikala ispisati?", "nTop", "nTop > 0",, } )
   DO WHILE .T.
      IF !VarEdit( aNiz, 10, 5, 19, 74, ;
            'USLOVI ZA IZVJESTAJ "NAJPROMETNIJI ARTIKLI"', ;
            "B1" )
         CLOSERET
      ENDIF
      aUsl1 := Parsiraj( cRoba, "IdRoba", "C" )
      IF aUsl1 <> NIL .AND. dDat0 <= dDat1
         EXIT
      ELSEIF aUsl1 == NIL
         Msg( "Kriterij za robu nije korektno postavljen!" )
      ELSE
         Msg( "'Datum do' ne smije biti stariji nego 'datum od'!" )
      ENDIF
   ENDDO // .t.

   nTotal := 0

   SELECT POS
   IF !( aUsl1 == ".t." )
      SET FILTER to &aUsl1
   ENDIF

   SELECT pos_doks
   SET ORDER TO TAG "2"
   // IdVd+DTOS (Datum)+Smjena

   START PRINT CRET
   ?
   ZagFirma()

   ? PadC ( "NAJPROMETNIJI ARTIKLI", 40 )
   ? PadC ( "-----------------------", 40 )
   ? PadC ( "NA DAN: " + FormDat1 ( gDatum ), 40 )
   ?
   ? PadC ( "Za period od " + FormDat1 ( dDat0 ) + " do " + FormDat1 ( dDat1 ), 40 )
   ?

   TopNizvuci ( VD_RN, dDat0 )
   TopNizvuci ( VD_PRR, dDat0 )

   // stampa izvjestaja
   SELECT POM
   IF cSta $ "IO"
      ?
      ? PadC ( "POREDAK PO IZNOSU", 40 )
      ?
      ? PadR( "ID ROBA", 10 ), PadR ( "Naziv robe", 20 ), PadC ( "Vrijednost", 19 )
      ? REPL( "-", 10 ), REPL ( "-", 20 ), REPL ( "-", 19 )
      nCnt := 1
      SET ORDER TO TAG "2"
      GO BOTTOM
      DO WHILE !Bof() .AND. nCnt <= nTop
         SELECT roba
         HSEEK POM->IdRoba
         ? roba->Id, Left ( roba->Naz, 20 ), Str ( POM->Iznos, 19, 2 )
         SELECT POM
         nCnt ++
         SKIP -1
      ENDDO
   ENDIF

   IF cSta $ "KO"

      SELECT POM
      ?
      ? PadC ( "POREDAK PO KOLICINI", 40 )
      ?
      ? PadR( "ID ROBA", 10 ), PadR ( "Naziv robe", 20 ), PadC ( "Kolicina", 15 )
      ? REPL( "-", 10 ), REPL ( "-", 20 ), REPL ( "-", 15 )

      nCnt := 1

      SET ORDER TO TAG "3"
      GO BOTTOM

      DO WHILE !Bof() .AND. nCnt <= nTop
         SELECT roba
         HSEEK POM->IdRoba
         ? roba->Id, Left ( roba->Naz, 20 ), Str ( POM->Kolicina, 15, 3 )
         SELECT POM
         nCnt ++
         SKIP -1
      ENDDO

   ENDIF

   ?

   IF gVrstaRS == "K"
      PaperFeed ()
   ENDIF

   ENDPRINT

   CLOSE ALL

   RETURN



/* TopNizvuci(cIdVd,dDat0)
 *     Punjenje pomocne baze realizacijom po robama
 */

FUNCTION TopNizvuci( cIdVd, dDat0 )

   SELECT pos_doks
   SEEK cIdVd + DToS ( dDat0 )

   DO WHILE !Eof() .AND. pos_doks->IdVd == cIdVd .AND. pos_doks->Datum <= dDat1

      IF ( !pos_admin() .AND. pos_doks->idpos = "X" ) .OR. ;
            ( pos_doks->IdPos = "X" .AND. AllTrim( cIdPos ) <> "X" ) .OR. ;
            ( !Empty( cIdPos ) .AND. pos_doks->IdPos <> cIdPos )
         SKIP
         LOOP
      ENDIF

      SELECT POS
      SEEK pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )

      WHILE !Eof() .AND. POS->( IdPos + IdVd + DToS( datum ) + BrDok ) == pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )

         SELECT roba
         HSEEK pos->idroba
         IF roba->( FieldPos( "idodj" ) ) <> 0
            SELECT odj
            HSEEK roba->idodj
         ENDIF
         nNeplaca := 0
         IF Right( odj->naz, 5 ) == "#1#0#"  // proba!!!
            nNeplaca := pos->( Kolicina * Cijena )
         ELSEIF Right( odj->naz, 6 ) == "#1#50#"
            nNeplaca := pos->( Kolicina * Cijena ) / 2
         ENDIF

         IF gPopVar = "P"
            nNeplaca += pos->( kolicina * NCijena )
         ENDIF

         SELECT POM
         GO TOP
         HSEEK POS->IdRoba

         IF !Found ()
            APPEND BLANK
            REPLACE IdRoba   WITH POS->IdRoba, ;
               Kolicina WITH POS->Kolicina, ;
               Iznos    WITH POS->Kolicina * POS->Cijena, ;
               iznos3   WITH nNeplaca
            IF gPopVar == "P"
               REPLACE iznos2   WITH pos->ncijena * pos->kolicina
            ENDIF
         ELSE
            REPLACE Kolicina WITH Kolicina + POS->Kolicina, ;
               Iznos WITH Iznos + POS->Kolicina * POS->Cijena, ;
               iznos3 WITH iznos3 + nNePlaca
            IF gPopVar == "P"
               REPLACE iznos2   WITH iznos2 + pos->ncijena * pos->kolicina
            ENDIF
         END

         SELECT POS
         SKIP

      ENDDO
      SELECT pos_doks
      SKIP

   ENDDO

   RETURN
// }
