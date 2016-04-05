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


FUNCTION pos_kartica_artikla()

   LOCAL nStanje
   LOCAL nSign := 1
   LOCAL cSt
   LOCAL nVrijednost
   LOCAL nCijena := 0
   LOCAL cRSdbf
   LOCAL cLM := ""
   LOCAL nSir := 40
   LOCAL cSiroki := "D"
   LOCAL cPPar
   PRIVATE cIdDio := Space( 2 )
   PRIVATE cIdOdj := Space( 2 )
   PRIVATE cDat0 := gDatum
   PRIVATE cDat1 := gDatum
   PRIVATE cPocSt := "D"

   nMDBrDok := 6

   O_KASE
   O_DIO
   O_SIFK
   O_SIFV
   O_ROBA
   O_POS

   cRoba := Space( 10 )
   cIdPos := gIdPos

   cDat0 := fetch_metric( "pos_kartica_datum_od", my_user(), cDat0 )
   cDat1 := fetch_metric( "pos_kartica_datum_do", my_user(), cDat1 )
   cRoba := fetch_metric( "pos_kartica_artikal", my_user(), cRoba )
   cPPar := fetch_metric( "pos_kartica_prikaz_partnera", my_user(), "N" )

   SET CURSOR ON

   Box(, 11, 60 )

   aNiz := {}

   IF gVrstaRS <> "K"
      @ m_x + 1, m_y + 2 SAY "Prod.mjesto (prazno-svi) "  GET  cIdPos  VALID Empty( cIdPos ) .OR. P_Kase( cIdPos ) PICT "@!"
   ENDIF

   READ

   @ m_x + 5, m_y + 6 SAY "Sifra artikla (prazno-svi)" GET cRoba VALID Empty( cRoba ) .OR. P_Roba( @cRoba ) PICT "@!"
   @ m_x + 7, m_y + 2 SAY "za period " GET cDat0
   @ m_x + 7, Col() + 2 SAY "do " GET cDat1
   @ m_x + 9, m_y + 2 SAY "sa pocetnim stanjem D/N ?" GET cPocSt VALID cpocst $ "DN" PICT "@!"
   @ m_x + 10, m_y + 2 SAY "Prikaz partnera D/N ?" GET cPPar VALID cPPar $ "DN" PICT "@!"
   @ m_x + 11, m_y + 2 SAY "Siroki papir    D/N ?" GET cSiroki VALID cSiroki $ "DN" PICT "@!"

   READ

   ESC_BCR

   set_metric( "pos_kartica_datum_od", my_user(), cDat0 )
   set_metric( "pos_kartica_datum_do", my_user(), cDat1 )
   set_metric( "pos_kartica_artikal", my_user(), cRoba )
   set_metric( "pos_kartica_prikaz_partnera", my_user(), "N" )

   BoxC()

   cZaduzuje := "R"
   cU := R_U
   cI := R_I
   cRSdbf := "ROBA"

   IF gVrstaRS == "S"
      cLM := Space( 5 )
      nSir := 80
   ENDIF


   IF cPPar == "D"
      O_POS_DOKS
      SELECT ( F_POS_DOKS )
      SET ORDER TO TAG "1"
   ENDIF

   SELECT POS
   SET ORDER TO TAG "2"

   IF Empty( cRoba )
      Seek2( cIdOdj )
   ELSE
      Seek2( cIdOdj + cRoba )
      IF pos->idroba <> cRoba
         MsgBeep( "Ne postoje traženi podaci !" )
         RETURN
      ENDIF
   ENDIF

   EOF CRET

   START PRINT CRET

   ZagFirma()

   ? PadC( "KARTICE ARTIKALA NA DAN " + FormDat1( gDatum ), nSir )
   ? PadC( "-----------------------------------", nSir )

   IF gVrstaRS <> "K"
      IF Empty( cIdPos )
         ? cLM + "PROD.MJESTO: " + cidpos + "-" + "SVE"
      ELSE
         ? cLM + "PROD.MJESTO: " + cidpos + "-" + Ocitaj( F_KASE, cIdPos, "Naz" )
      ENDIF
   ENDIF

   ? cLM + "ARTIKAL    : " + IF( Empty( cRoba ), "SVI", RTrim( cRoba ) )
   ? cLM + "PERIOD     : " + FormDat1( cDat0 ) + " - " + FormDat1( cDat1 )
   ?

   IF gVrstaRS == "S"
      cLM := Space( 5 )
      ? cLM
   ELSE
      cLM := ""
      ?
   ENDIF

   ?? "Artikal"

   IF cSiroki == "D"
      ? cLM + " Datum   Dokum." + Space( nMDBrDok - 4 ) + "     Ulaz       Izlaz     Stanje"
   ELSE
      ? cLM + "Dokum." + Space( nMDBrDok - 4 ) + "     Ulaz       Izlaz     Stanje"
   ENDIF

   IF gVrstaRS == "S"
      ?? "    Vrijednost"
   ENDIF

   IF cPPar == "D"
      ?? "   Partner"
   ENDIF

   IF gVrstaRS == "S"
      m := cLM
      IF cSiroki == "D"
         m := m + Replicate( "-", 8 ) + " "  // datum
      ENDIF
      m := m + "---" + REPL( "-", nMDBrDok ) + " ---------- ---------- ---------- ------------"
   ELSE
      m := ""
      IF cSiroki == "D"
         m := m + Replicate( "-", 8 ) + " "  // datum
      ENDIF
      m := m + "---" + REPL( "-", nMDBrDok ) + " ---------- ---------- ----------"
   ENDIF

   IF cPPar == "D"
      m += " --------"
   ENDIF


   DO WHILE !Eof() .AND. POS->IdOdj == cIdOdj
      nStanje := 0
      nVrijednost := 0
      fSt := .T.
      cIdRoba := POS->IdRoba
      nUlaz := nIzlaz := 0
      SELECT POS

      DO WHILE !Eof() .AND. POS->( IdOdj + IdRoba ) == ( cIdOdj + cIdRoba )
         IF ( cZaduzuje == "R" .AND. pos->idvd == "96" ) .OR. ( cZaduzuje == "S" .AND. pos->idvd $ "42#01" )
            SKIP
            LOOP
         ENDIF

         IF cPocSt == "N"
            SELECT ( cRSdbf )
            HSEEK cIdRoba
            nCijena1 := pos_get_mpc()
            SELECT POS
            nStanje := 0
            nVrijednost := 0
            SEEK cIdOdj + cIdRoba + DToS( cDat0 )
         ELSE
            DO WHILE !Eof() .AND. POS->( IdOdj + IdRoba ) == ( cIdOdj + cIdRoba ) .AND. POS->Datum < cDat0
               IF !Empty( cIdDio ) .AND. POS->IdDio <> cIdDio
                  SKIP
                  LOOP
               ENDIF
               IF ( !pos_admin() .AND. pos->idpos = "X" ) .OR. ( !Empty( cIdPos ) .AND. IdPos <> cIdPos )
                  SKIP
                  LOOP
               ENDIF

               IF ( cZaduzuje == "R" .AND. pos->idvd == "96" ) .OR. ( cZaduzuje == "S" .AND. pos->idvd $ "42#01" )
                  SKIP
                  LOOP
               ENDIF

               IF pos->idvd $ DOK_ULAZA
                  nStanje += POS->Kolicina

               ELSEIF pos->idvd $ "IN"

                  nStanje -= ( POS->Kolicina - POS->Kol2 )
                  nVrijednost += ( POS->Kol2 - POS->Kolicina ) * POS->Cijena

               ELSEIF pos->idvd $ DOK_IZLAZA
                  nStanje -= POS->Kolicina

               ELSEIF pos->IdVd == "NI"
                  // ne mijenja kolicinu
               ENDIF

               SKIP
            ENDDO

            SELECT ( cRSdbf )
            HSEEK cIdRoba
            nCijena1 := pos_get_mpc()

            IF fSt
               IF gVrstaRS == "S" .AND. PRow() > 63 -dodatni_redovi_po_stranici() - 3
                  FF
               ENDIF
               ? m
               ? cLM
               IF cSiroki == "D"
                  ?? Space( 8 ) + " "
               ENDIF
               ?? cIdRoba, PadR ( AllTrim ( Naz ) + " (" + AllTrim ( Jmj ) + ")", 32 )
               ? m
               nVrijednost := nStanje * nCijena1
               IF gVrstaRS == "S"
                  ? cLM
               ELSE
                  ?
               ENDIF
               ?? PadL ( "Stanje do " + FormDat1 ( cDat0 ), 29 ), ""
               ?? Str ( nStanje, 10, 3 )
               IF gVrstaRS == "S"
                  ?? " " + Str ( nCijena1 * nStanje, 12, 3 )
               ENDIF
               fSt := .F.
            ENDIF
            SELECT POS
         ENDIF // cPocSt

         DO WHILE !Eof() .AND. POS->( IdOdj + IdRoba ) == ( cIdOdj + cIdRoba ) .AND. POS->Datum <= cDat1

            IF !Empty( cIdDio ) .AND. POS->IdDio <> cIdDio
               SKIP
               LOOP
            ENDIF

            IF ( !pos_admin() .AND. pos->idpos = "X" ) .OR. ( !Empty( cIdPos ) .AND. IdPos <> cIdPos )
               // (POS->IdPos="X" .and. AllTrim (cIdPos)<>"X") .or. ;  // ?MS
               SKIP
               LOOP
            ENDIF

            IF ( cZaduzuje == "R" .AND. pos->idvd == "96" ) .OR. ( cZaduzuje == "S" .AND. pos->idvd $ "42#01" )
               SKIP
               LOOP
            ENDIF

            IF fSt
               SELECT ( cRSdbf )
               HSEEK cIdRoba
               IF gVrstaRS == "S" .AND. PRow() > 63 -dodatni_redovi_po_stranici() - 3
                  FF
               ENDIF
               ? m
               ? cLM + cIdRoba, PadR( AllTrim( Naz ) + " (" + AllTrim( Jmj ) + ")", 32 )
               ? m
               SELECT POS
               fSt := .F.
            ENDIF

            IF POS->idvd $ DOK_ULAZA

               ? cLM

               IF cSiroki == "D"
                  ?? DToC( pos->datum ) + " "
               ENDIF

               ?? POS->IdVd + "-" + PadR( AllTrim( POS->BrDok ), nMDBrDok ), ""

               ?? Str ( POS->Kolicina, 10, 3 ), Space ( 10 ), ""
               nUlaz += POS->Kolicina

               nStanje += POS->Kolicina
               ?? Str ( nStanje, 10, 3 )

               IF gVrstaRS == "S"
                  ?? "", Str ( nCijena1 * nStanje, 12, 3 )
               ENDIF

            ELSEIF POS->IdVd == "NI"

               ? cLM

               IF cSiroki == "D"
                  ?? DToC( pos->datum ) + " "
               ENDIF

               ?? POS->IdVd + "-" + PadR ( AllTrim( POS->BrDok ), nMDBrDok ), ""
               ?? "S:", Str ( POS->Cijena, 7, 2 ), "N:", Str ( POS->Ncijena, 7, 2 ), ;
                  Str ( nStanje, 10, 3 )

               IF gVrstaRS == "S"
                  ?? "", Str ( nCijena1 * nStanje, 12, 3 )
               ENDIF

               SKIP
               LOOP

            ELSEIF POS->idvd $ "IN" + DOK_IZLAZA

               IF pos->idvd $ DOK_IZLAZA
                  nKol := POS->Kolicina
               ELSEIF POS->IdVd == "IN"
                  nKol := ( POS->Kolicina - POS->Kol2 )
               ENDIF

               IF pos->idvd == "IN" .AND. pos->kolicina == 0
                  nIzlaz += nStanje - nKol
                  nStanje -= nStanje - Abs( nKol )
               ELSE
                  nIzlaz += nKol
                  nStanje -= nKol
               ENDIF

               IF gVrstaRS == "S" .AND. PRow() > 63 -dodatni_redovi_po_stranici() - 3
                  FF
               ENDIF

               ? cLM

               IF cSiroki == "D"
                  ?? DToC( pos->datum ) + " "
               ENDIF

               ?? POS->IdVd + "-" + PadR( AllTrim( POS->BrDok ), nMDBrDok ), ""
               ?? Space ( 10 ), Str ( nKol, 10, 3 ), Str ( nStanje, 10, 3 )

               IF gVrstaRS == "S"
                  ?? "", Str ( nCijena1 * nStanje, 12, 3 )
               ENDIF

            ENDIF // izlaz, in

            IF cPPar == "D"
               ?? " "
               ?? Ocitaj( F_POS_DOKS, POS->( IdPos + IdVd + DToS( datum ) + BrDok ), "idgost" )
            ENDIF


            SKIP
         ENDDO

         ? m
         ? cLM

         IF cSiroki == "D"
            ?? Space( 8 ) + " "
         ENDIF

         ?? " UKUPNO", Str( nUlaz, 10, 3 ), Str( nIzlaz, 10, 3 ), Str( nStanje, 10, 3 )

         IF gVrstaRS == "S"
            ?? "", Str ( nCijena1 * nStanje, 12, 3 )
         ELSE
            IF cSiroki == "D"
               ?  Space( 9 ) + "  Cij:", Str( nCijena1, 8, 2 ), "Ukupno:", Str ( nCijena1 * nStanje, 12, 3 )
            ELSE
               ?  "  Cij:", Str( nCijena1, 8, 2 ), "Ukupno:", Str ( nCijena1 * nStanje, 12, 3 )
            ENDIF
         ENDIF

         ? m
         ?

         DO WHILE !Eof() .AND. POS->( IdOdj + IdRoba ) == ( cIdOdj + cIdRoba ) .AND. POS->Datum > cDat1
            SKIP
         ENDDO

      ENDDO

      IF !Empty( cRoba )
         EXIT
      ENDIF

   ENDDO

   PaperFeed()
   ENDPRINT

   CLOSE ALL

   RETURN
