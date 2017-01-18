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




FUNCTION realizacija_odjeljenja()

   LOCAL   nSir := iif ( gVrstaRS == "S", 80, 40 )
   PRIVATE cIdOdj := Space( 2 ), cPrikRobe := "D"
   PRIVATE cSmjena := Space( 1 ), cIdPos := gIdPos, cIdDio := gIdDio
   PRIVATE dDat0 := gDatum, dDat1 := gDatum, aNiz, cRoba := Space ( 60 )

   aDbf := {}
   AAdd ( aDbf, { "IdOdj", "C",  2, 0 } )
   AAdd ( aDbf, { "IdDio", "C",  2, 0 } )
   AAdd ( aDbf, { "IdPos", "C",  2, 0 } )
   AAdd ( aDbf, { "IdRoba", "C",  8, 0 } )
   AAdd ( aDbf, { "IdCijena", "C",  1, 0 } )
   AAdd ( aDbf, { "Kolicina", "N", 15, 3 } )
   AAdd ( aDbf, { "Iznos",    "N", 20, 5 } )
   AAdd ( aDbf, { "Iznos2",    "N", 20, 5 } )
   AAdd ( aDbf, { "Iznos3",    "N", 20, 5 } )

   pos_cre_pom_dbf( aDbf )

   SELECT ( F_POM )
   my_use_temp( "POM", my_home() + "pom", .F., .F. )

   INDEX on ( "idodj+iddio+idpos+idroba+idcijena" ) TAG "1"
   INDEX on ( "idodj+iddio+idroba+idcijena" ) TAG "2"

   SET ORDER TO TAG "1"

   // otvori ponovo tabele radi gornjeg indeksa
   _o_tables()

   aNiz := {}
   cIdPos := gIdPos
   IF gVrstaRS <> "K"
      AAdd ( aNiz, { "Prod. mjesto (prazno-sve)", "cIdPos", "cidpos='X' .or. empty(cIdPos).or.P_Kase(@cIdPos)", "@!", } )
   ELSE
      cIdPos := gIdPos
      cIdDio := gIdDio
   ENDIF
   IF gvodiodj == "D"
      AAdd ( aNiz, { "Odjeljenje (prazno-sva)", "cIdOdj", "empty(cIdOdj) .or. P_Odj(@cIdOdj)", "@!", } )
   ENDIF
   AAdd ( aNiz, { "Roba (prazno-sve)", "cRoba",, "@!S30", } )
   AAdd ( aNiz, { "Izvjestaj se pravi od datuma", "dDat0",,, } )
   AAdd ( aNiz, { "                   do datuma", "dDat1",,, } )
   AAdd( aNiz,  { "Prikazi robe D/N",            "cPrikRobe", "cPrikRobe$'DN'", "@!", } )
   DO WHILE .T.
      IF !VarEdit( aNiz, 10, 5, 20, 74, ;
            'USLOVI ZA IZVJESTAJ "REALIZACIJA ODJELJENJA"', ;
            "B1" )
         CLOSERET
      ENDIF
      aUsl1 := Parsiraj( cRoba, "idroba" )
      IF aUsl1 <> NIL .AND. dDat0 <= dDat1
         EXIT
      ELSEIF aUsl1 == NIL
         Msg( "Kriterij za robu nije korektno postavljen!" )
      ELSE
         Msg( "'Datum do' ne smije biti stariji nego 'datum od'!" )
      ENDIF
   ENDDO

   // pravljenje izvjestaja
   START PRINT CRET

   ZagFirma()

   P_10CPI
   ?
   ? PadC( "REALIZACIJA ODJELJENJA", nSir )
   ? PadC ( "NA DAN " + FormDat1( Date() ), nSir )
   ? PadC( "-------------------------------------", nSir )
   ? "PROD.MJESTO: " + cidpos + "-" + IF( Empty( cIdPos ), "SVA", Ocitaj ( F_KASE, cIdPos, "Naz" ) )
   IF gvodiodj == "D"
      ? "ODJELJENJA : " + IF( Empty( cIdOdj ), "SVA", Ocitaj ( F_ODJ, cIdOdj, "Naz" ) )
   ENDIF
   ? "PERIOD     : " + FormDat1( dDat0 ) + " - " + FormDat1( dDat1 )

   SELECT pos_doks
   SET ORDER TO TAG "2"
   // "DOKSi2", "IdVd+DTOS (Datum)+Smjena"

   OdjIzvuci ( VD_PRR )
   OdjIzvuci ( VD_RN )

   // stampa izvjestaja
   SELECT POM
   SET ORDER TO TAG "1"
   GO TOP
   nTotal := 0
   nTotal2 := 0
   nTotal3 := 0

   nTotOdj := 0
   nTotOdj2 := 0
   nTotOdj3 := 0

   nTotPos := 0
   nTotPos2 := 0
   nTotPos3 := 0

   DO WHILE !Eof()
      SELECT ODJ
      HSEEK POM->IdOdj
      ?
      ? POM->IdOdj, ODJ->Naz
      ? REPL ( "-", 40 )
      SELECT POM
      _IdOdj := POM->IdOdj
      nTotOdj := 0
      nTotOdj2 := 0
      nTotOdj3 := 0
      DO WHILE !Eof() .AND. POM->IdOdj == _IdOdj
         _IdDio := POM->IdDio
         IF ! Empty ( _IdDio )
            SELECT DIO
            HSEEK _IdDio
            ? Space ( 5 ) + DIO->Naz
            ? Space ( 5 ) + REPL ( "-", 35 )
            SELECT POM
         ENDIF
         nTotDio := 0
         nTotDio2 := 0
         nTotDio3 := 0
         DO WHILE !Eof() .AND. POM->( IdOdj + IdDio ) == ( _IdOdj + _IdDio )
            _IdPos := POM->IdPos
            SELECT KASE
            HSEEK _IdPos
            ? Space( 1 ) + _idpos + ":", + KASE->Naz
            SELECT POM
            nTotPos := 0
            nTotPos2 := 0
            nTotPos3 := 0
            DO  WHILE !Eof() .AND. POM->( IdOdj + IdDio + IdPos ) == ( _IdOdj + _IdDio + _IdPos )
               nTotPos += POM->Iznos
               nTotPos2 += POM->Iznos2
               nTotPos3 += POM->Iznos3
               SKIP
            ENDDO
            ?? Str ( nTotPos, 20, 2 )
            nTotDio += nTotPos
            nTotDio2 += nTotPos2
            nTotDio3 += nTotPos3
         END
         IF ! Empty ( _idDio )
            ? Space ( 5 ) + REPL ( "-", 35 )
            ? Space ( 5 ) + PadL ( "UKUPNO", 15 ) + Str ( nTotDio, 20, 2 )
         ENDIF
         nTotOdj += nTotDio
         nTotOdj2 += nTotDio2
         nTotOdj3 += nTotDio3
      END
      ? REPL ( "-", 40 )
      ? PadC ( "UKUPNO ODJELJENJE", 20 ) + Str ( nTotOdj, 20, 2 )
      IF nTotodj2 <> 0
         ? PadL ( "PARTICIPACIJA:", 20 ), Str ( nTotOdj2, 20, 2 )
      ENDIF
      IF nTotOdj3 <> 0
         ? PadL ( NenapPop(), 20 ), Str ( nTotOdj3, 20, 2 )
         ? PadL ( "UKUPNO NAPLATA:", 20 ), Str ( nTotOdj - nTotOdj3 + nTotOdj2, 20, 2 )
      ENDIF
      ? REPL ( "-", 40 )
      nTotal += nTotOdj
      nTotal2 += nTotOdj2
      nTotal3 += nTotOdj3
   END
   IF Empty ( cIdOdj )
      ? REPL ( "=", 40 )
      ? PadC ( "SVA ODJELJENJA", 20 ) + Str ( nTotal, 20, 2 )
      IF nTotal2 <> 0
         ? PadL ( "PARTICIPACIJA:", 20 ), Str ( nTotal2, 20, 2 )
      ENDIF
      IF nTotal3 <> 0
         ? PadL ( NenapPop(), 20 ), Str ( nTotal3, 20, 2 )
         ? PadL ( "UKUPNO NAPLATA:", 20 ), Str ( nTotal - nTotal3 + nTotal2, 20, 2 )
      ENDIF
      ? REPL ( "=", 40 )
   ENDIF

   IF cPrikRobe == "D"
      nTotal := 0
      nTotal2 := 0
      nTotal3 := 0
      SELECT POM
      SET ORDER TO TAG "2"
      GO TOP
      DO WHILE !Eof()
         _IdOdj := POM->IdOdj
         SELECT ODJ
         HSEEK _IdOdj
         ? ODJ->Naz
         ? REPL ( "-", 40 )
         SELECT POM
         nTotOdj := 0
         nTotOdj2 := 0
         nTotOdj3 := 0
         DO WHILE !Eof() .AND. POM->IdOdj == _IdOdj
            _IdDio := POM->IdDio
            IF !Empty ( _IdDio )
               SELECT DIO; HSEEK ( _IdDio )
               ? Space ( 5 ) + DIO->Naz
               ? Space ( 5 ) + REPL ( "-", 35 )
               SELECT POM
            ENDIF
            nTotDio := 0
            nTotDio2 := 0
            nTotDio3 := 0
            DO WHILE !Eof() .AND. POM->( IdOdj + IdDio ) == ( _IdOdj + _IdDio )
               _IdRoba := POM->IdRoba
               SELECT roba
               HSEEK _IdRoba
               ? Space ( 5 ) + _IdRoba, Left ( roba->Naz, 26 )
               SELECT POM
               DO WHILE !Eof() .AND. ;
                     POM->( IdOdj + IdDio + IdRoba ) == ( _IdOdj + _IdDio + _IdRoba )
                  _idCijena := POM->IdCijena
                  nKol := 0
                  nIzn := 0
                  nIzn2 := 0
                  nIzn3 := 0
                  DO WHILE !Eof() .AND. ;
                        POM->( IdOdj + IdDio + IdRoba + IdCijena ) == ( _IdOdj + _IdDio + _IdRoba + _IdCijena )
                     nKol += POM->Kolicina
                     nIzn += POM->Iznos
                     nIzn2 += POM->Iznos2
                     nIzn3 += POM->Iznos3
                     SKIP
                  ENDDO
                  ? Space ( 10 ) + _IdCijena, Str ( nKol, 12, 3 ), Str ( nIzn, 15, 2 )
                  nTotDio += nIzn
                  nTotDio2 += nIzn2
               END
            END
            IF ! Empty ( _IdDio )
               ? Space ( 5 ) + PadC ( "UKUPNO", 19 ), Str ( nTotDio, 15, 2 )
            ENDIF
            nTotOdj += nTotDio
            nTotOdj2 += nTotDio2
         END
         ? REPL ( "-", 40 )
         ? PadC ( "UKUPNO ODJELJENJE", 25 ) + Str ( nTotOdj, 15, 2 )
         IF nTotOdj2 <> 0
            ? PadL ( "PARTICIPACIJA:", 20 ), Str ( nTotOdj2, 15, 2 )
         ENDIF
         IF nTotOdj3 <> 0
            ? PadL ( NenapPop(), 20 ), Str ( nTotOdj3, 15, 2 )
            ? PadL ( "UKUPNO NAPLATA:", 20 ), Str ( nTotOdj - nTotOdj3 + nTotOdj2, 15, 2 )
         ENDIF
         ? REPL ( "-", 40 )
         nTotal += nTotOdj
         nTotal2 += nTotOdj2
         nTotal3 += nTotOdj3
      END
      IF Empty ( cIdDio )
         ? REPL ( "=", 40 )
         ? PadC ( "SVA ODJELJENJA", 25 ) + Str ( nTotal, 15, 2 )
         IF nTotal2 <> 0
            ? PadL ( "PARTICIPACIJA:", 20 ), Str ( nTotal2, 15, 2 )
         ENDIF
         IF nTotal3 <> 0
            ? PadL ( NenapPop(), 20 ), Str ( nTotal3, 15, 2 )
            ? PadL ( "UKUPNO NAPLATA:", 20 ), Str ( nTotal - nTotal3 + nTotal2, 15, 2 )
         ENDIF
         ? REPL ( "=", 40 )
      ENDIF
   ENDIF
   ENDPRINT

   CLOSERET



/* DioIzvuci(cIdVd)
 *     Punjenje pomocne baze realizacijom dijelova odjeljenja
 */

FUNCTION DioIzvuci( cIdVd )

   IF cGotZir == nil
      cGotZir := " "
   ENDIF
   SEEK cIdVd + DToS ( dDat0 )
   DO WHILE ! Eof() .AND. pos_doks->IdVd == cIdVd .AND. pos_doks->Datum <= dDat1
      IF ( !pos_admin() .AND. pos_doks->idpos = "X" ) .OR. ;
            ( pos_doks->IdPos = "X" .AND. AllTrim ( cIdPos ) <> "X" ) .OR. ;
            ( ! Empty ( cIdPos ) .AND. pos_doks->IdPos <> cIdPos ) .OR. ;
            !Empty( cGotZir ) .AND. ( cGotZir == "Z" .AND. pos_doks->placen <> "Z" .OR. cGotZir <> "Z" .AND. pos_doks->placen == "Z" )
         Skip; LOOP
      ENDIF
      Scatter()

      SELECT POS
      SEEK pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )
      DO WHILE ! Eof() .AND. POS->( IdPos + IdVd + DToS( datum ) + BrDok ) == pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )
         IF ( !Empty ( cIdOdj ) .AND. POS->IdOdj <> cIdOdj ) .OR. ;
               ( !Empty ( cIdDio ) .AND. POS->IdDio <> cIdDio ) .OR. ;
               !Tacno ( aUsl1 )
            Skip; LOOP
         ENDIF

         SELECT roba; HSEEK pos->idroba
         SELECT odj; HSEEK roba->idodj
         nNeplaca := 0
         IF Right( odj->naz, 5 ) == "#1#0#"  // proba!!!
            nNeplaca := pos->( Kolicina * Cijena )
         ELSEIF Right( odj->naz, 6 ) == "#1#50#"
            nNeplaca := pos->( Kolicina * Cijena ) / 2
         ENDIF
         IF gPopVar = "P"; nNeplaca += pos->( kolicina * NCijena ); ENDIF

         Scatter()
         SELECT POM; APPEND BLANK
         _Iznos := POS->Kolicina * POS->Cijena
         _Iznos2 := POS->( ncijena * kolicina )
         IF gPopVar == "A"
            _iznos3 := nNeplaca
         ENDIF
         Gather()
         SELECT POS
         SKIP
      ENDDO
      SELECT pos_doks
      SKIP
   ENDDO

   RETURN


FUNCTION realizacija_dio_objekta

   PARAMETERS cPrikRobe
   PRIVATE cIdDio := Space( 2 )
   PRIVATE cSmjena := Space( 1 ), cIdPos := gIdPos, cIdOdj := Space ( 2 )
   PRIVATE dDat0 := gDatum, dDat1 := gDatum, aNiz, cRoba := Space ( 60 )
   PRIVATE cIdRadnik := Space ( 4 ), cIdVrsteP := Space ( 2 ), cGotZir := " "

   cPrikRobe := iif ( cPrikRobe == NIL, "N", cPrikRobe )

   O_DIO
   O_ODJ
   O_OSOB
   SET ORDER TO tag ( "NAZ" )
   O_VRSTEP
   O_KASE
   o_sifk()
   O_SIFV
   O_ROBA
   o_pos_pos()
   o_pos_doks()

   aDbf := {}
   AAdd ( aDbf, { "IdDio", "C",  2, 0 } )
   AAdd ( aDbf, { "IdOdj", "C",  2, 0 } )
   AAdd ( aDbf, { "IdPos", "C",  2, 0 } )
   AAdd ( aDbf, { "IdRadnik", "C",  4, 0 } )
   AAdd ( aDbf, { "IdVrsteP", "C",  2, 0 } )
   AAdd ( aDbf, { "IdRoba", "C", 10, 0 } )
   AAdd ( aDbf, { "IdCijena", "C",  1, 0 } )
   AAdd ( aDbf, { "Kolicina", "N", 15, 3 } )
   AAdd ( aDbf, { "Iznos",    "N", 20, 5 } )
   AAdd ( aDbf, { "Iznos2",    "N", 20, 5 } )
   AAdd ( aDbf, { "Iznos3",    "N", 20, 5 } )
   pos_cre_pom_dbf ( aDbf )
   O_POM
   INDEX ON IdDio + IdPos + IdVrsteP TAG ( "1" ) TO ( my_home() + "POM" )
   INDEX ON IdDio + IdRadnik + IdVrsteP TAG ( "2" ) TO ( my_home() + "POM" )
   INDEX ON IdDio + IdVrsteP TAG ( "3" ) TO ( my_home() + "POM" )
   INDEX ON IdDio + IdOdj TAG ( "4" ) TO ( my_home() + "POM" )
   INDEX ON IdDio + IdRoba + IdCijena TAG ( "5" ) TO ( my_home() + "POM" )
   SET ORDER TO TAG "1"

   aNiz := {}
   cIdPos := gIdPos
   IF gVrstaRS <> "K"
      AAdd ( aNiz, { "Prod. mjesto (prazno-sve)", "cIdPos", "cidpos='X' .or. empty(cIdPos).or.P_Kase(@cIdPos)", "@!", } )
   ELSE
      cIdPos := gIdPos
   ENDIF
   AAdd ( aNiz, { "Dio objekta (prazno-svi)", "cIdDio", "Empty (cIdDio).or.P_Dio(@cIdDio)", "@!", } )
   IF gvodiodj == "D"
      AAdd ( aNiz, { "Odjeljenje (prazno-sva)", "cIdOdj", "Empty (cIdOdj).or.P_Odj(@cIdOdj)", "@!", } )
   ENDIF
   AAdd ( aNiz, { "Radnik (prazno-svi)", "cIdRadnik", "Empty (cIdRadnik).or.P_Osob(@cIdRadnik)", "@!", } )
   AAdd ( aNiz, { "Vrste placanja(prazno-sve)", "cIdVrsteP", "Empty (cIdVrsteP).or.P_Osob(@cIdVrsteP)", "@!", } )
   AAdd ( aNiz, { "Roba (prazno-sve)", "cRoba",, "@!S30", } )
   AAdd ( aNiz, { "Izvjestaj se pravi od datuma", "dDat0",,, } )
   AAdd ( aNiz, { "                   do datuma", "dDat1",,, } )
   AAdd( aNiz,  { "Prikazi robe D/N",            "cPrikRobe",, "@!", } )
   DO WHILE .T.
      IF !VarEdit( aNiz, 9, 5, 21, 74, ;
            'USLOVI ZA IZVJESTAJ "REALIZACIJA DIJELA OBJEKTA"', ;
            "B1" )
         CLOSERET
      ENDIF
      aUsl1 := Parsiraj( cRoba, "idroba" )
      IF aUsl1 <> NIL .AND. dDat0 <= dDat1
         EXIT
      ELSEIF aUsl1 == NIL
         Msg( "Kriterij za robu nije korektno postavljen!" )
      ELSE
         Msg( "'Datum do' ne smije biti stariji nego 'datum od'!" )
      ENDIF
   ENDDO

   // pravljenje izvjestaja
   SELECT pos_doks
   SET ORDER TO TAG "2"
   // "DOKSi2", "IdVd+DTOS (Datum)+Smjena"

   EOF CRET

   START PRINT CRET
   ZagFirma()
   ?
   ? PadC( "REALIZACIJA DIJELA OBJEKTA", 40 )
   ? PadC ( "NA DAN " + FormDat1( Date() ), 40 )
   ? PadC( "-------------------------------------", 40 )
   ? "PROD.MJESTO: " + cidpos + "-" + IF( Empty( cIdPos ), "SVA", Ocitaj ( F_KASE, cIdPos, "Naz" ) )
   IF gvodiodj == "D"
      ? "ODJELJENJA : " + IF( Empty( cIdOdj ), "SVA", Ocitaj ( F_ODJ, cIdOdj, "Naz" ) )
   ENDIF
   ? "RADNIK     : " + IF( Empty( cIdRadnik ), "svi", ;
      cIdRadnik + "-" + RTrim( Ocitaj( F_OSOB, cIdRadnik, "naz" ) ) )
   ? "VR.PLACANJA: " + IF( Empty( cIdVrsteP ), "sve", RTrim( cIdVrsteP ) )
   ? "PERIOD     : " + FormDat1( dDat0 ) + " - " + FormDat1( dDat1 )

   DioIzvuci ( VD_PRR )
   DioIzvuci ( VD_RN )

   // stampa izvjestaja
   // ////////////////////
   // 1) Rekapitulacija po kasama i vrstama placanja
   ?
   ? PadC ( "REKAPITULACIJA PO KASAMA", 40 )
   ? PadC ( "--------------------------", 40 )
   ?
   nTotal := 0
   nTotal2 := 0
   nTotal3 := 0
   SELECT POM
   SET ORDER TO TAG "1"
   GO TOP
   DO WHILE !Eof()
      _IdDio := POM->IdDio
      IF Empty ( cIdDio )
         SELECT DIO
         HSEEK ( _IdDio )
         ? REPL ( "-", 40 )
         ? DIO->Naz
         ? REPL ( "-", 40 )
         SELECT POM
      ENDIF
      nTotDio := 0
      nTotDio2 := 0
      nTotDio3 := 0
      DO WHILE !Eof() .AND. POM->IdDio == _IdDio
         _IdPos := POM->IdPos
         SELECT KASE
         HSEEK _IdPos
         ? Space( 1 ) + _idpos + ":", + KASE->Naz
         ? Space ( 5 ) + REPL ( "-", 35 )
         SELECT POM
         nTotPos := 0
         nTotPos2 := 0
         nTotPos3 := 0
         DO WHILE !Eof() .AND. POM->( IdDio + IdPos ) == ( _IdDio + _IdPos )
            nTotVP := 0
            nTotVP2 := 0
            nTotVP3 := 0
            _IdVrsteP := POM->IdVrsteP
            SELECT VRSTEP
            HSEEK _IdVrsteP
            ? Space ( 5 ) + PadR ( VRSTEP->Naz, 20 )
            SELECT POM
            DO WHILE !Eof() .AND. POM->( IdDio + IdPos + IdVrsteP ) == ( _IdDio + _IdPos + _IdVrsteP )
               nTotVP += POM->Iznos
               nTotVP2 += POM->Iznos2
               nTotVP3 += POM->Iznos3
               SKIP
            ENDDO
            ?? Str ( nTotVP, 15, 2 )
            nTotPos += nTotVP
            nTotPos2 += nTotVP2
            nTotPos3 += nTotVP3
         ENDDO
         ? Space ( 5 ) + REPL ( "-", 35 )
         ? Space ( 5 ) + PadR ( "UKUPNO KASA " + _idpos, 20 ) + Str ( nTotPos, 15, 2 )
         ? Space ( 5 ) + REPL ( "-", 35 )
         IF nTotPos2 <> 0
            ? PadL ( "PARTICIPACIJA:", 20 ), Str ( nTotPos2, 15, 2 )
         ENDIF
         IF nTotPos3 <> 0
            ? PadL ( NenapPop(), 20 ), Str ( nTotPos3, 15, 2 )
            ? PadL ( "UKUPNO NAPLATA:", 20 ), Str ( nTotPos - nTotPos3 + nTotPos2, 15, 2 )
         ENDIF

         nTotDio += nTotPos
         nTotDio2 += nTotPos2
         nTotDio3 += nTotPos3
      ENDDO
      ? REPL ( "-", 40 )
      ? PadC ( "UKUPNO DIO OBJEKTA", 25 ) + Str ( nTotDio, 15, 2 )
      ? REPL ( "-", 40 )
      nTotal += nTotDio
      nTotal2 += nTotDio2
      nTotal2 += nTotDio3
   ENDDO
   IF Empty ( cIdDio )
      ? REPL ( "=", 40 )
      ? PadC ( "UKUPNO OBJEKAT", 25 ) + Str ( nTotal, 15, 2 )
      IF nTotal2 <> 0
         ? PadL ( "PARTICIPACIJA:", 25 ), Str ( nTotal2, 15, 2 )
      ENDIF
      IF nTotPos3 <> 0
         ? PadL ( NenapPop(), 25 ), Str ( nTotal3, 15, 2 )
         ? PadL ( "UKUPNO NAPLATA:", 25 ), Str ( nTotal - nTotal3 + nTotal2, 15, 2 )
      ENDIF
      ? REPL ( "=", 40 )
   ENDIF

   // 2) Rekapitulacija po radnicima i vrstama placanja
   ?
   ? PadC ( "REKAPITULACIJA PO RADNICIMA", 40 )
   ? PadC ( "--------------------------", 40 )
   ?
   nTotal := 0
   nTotal2 := 0
   nTotal3 := 0
   SELECT POM
   SET ORDER TO TAG "2"
   GO TOP
   DO WHILE !Eof()
      _IdDio := POM->IdDio
      IF Empty ( cIdDio )
         SELECT DIO
         HSEEK ( _IdDio )
         ? REPL ( "-", 40 )
         ? DIO->Naz
         ? REPL ( "-", 40 )
         SELECT POM
      ENDIF
      nTotDio := 0
      nTotDio2 := 0
      nTotDio3 := 0
      DO WHILE !Eof() .AND. POM->IdDio == _IdDio
         _IdRadnik := POM->IdRadnik
         SELECT OSOB
         HSEEK _IdRadnik
         ? Space ( 5 ) + OSOB->Naz
         ? Space ( 5 ) + REPL ( "-", 35 )
         SELECT POM
         nTotRadnik := 0
         nTotRadn2 := 0
         nTotRadn3 := 0
         DO WHILE !Eof() .AND. POM->( IdDio + IdRadnik ) == ( _IdDio + _IdRadnik )
            nTotVP := 0
            nTotVP2 := 0
            nTotVP3 := 0
            _IdVrsteP := POM->IdVrsteP
            SELECT VRSTEP
            HSEEK _IdVrsteP
            ? Space ( 5 ) + PadR ( VRSTEP->Naz, 20 )
            SELECT POM
            DO WHILE !Eof() .AND. ;
                  POM->( IdDio + IdRadnik + IdVrsteP ) == ( _IdDio + _IdRadnik + _IdVrsteP )
               nTotVP += POM->Iznos
               nTotVP2 += POM->Iznos2
               nTotVP3 += POM->Iznos3
               SKIP
            ENDDO
            ?? Str ( nTotVP, 15, 2 )
            nTotRadnik += nTotVP
            nTotRadn2 += nTotVP2
            nTotRadn3 += nTotVP3
         ENDDO
         ? Space ( 5 ) + REPL ( "-", 35 )
         ? Space ( 5 ) + PadR ( "UKUPNO RADNIK", 20 ) + Str ( nTotRadnik, 15, 2 )
         ? Space ( 5 ) + REPL ( "-", 35 )
         nTotDio += nTotRadnik
         nTotDio2 += nTotRadn2
         nTotDio3 += nTotRadn3
      ENDDO
      ? REPL ( "-", 40 )
      ? PadC ( "UKUPNO DIO OBJEKTA", 25 ) + Str ( nTotDio, 15, 2 )
      ? REPL ( "-", 40 )
      nTotal += nTotDio
      nTotal2 += nTotDio2
      nTotal3 += nTotDio3
   ENDDO
   IF Empty ( cIdDio )
      ? REPL ( "=", 40 )
      ? PadC ( "UKUPNO OBJEKAT", 25 ) + Str ( nTotal, 15, 2 )
      IF nTotal2 <> 0
         ? PadL ( "PARTICIPACIJA:", 25 ) + Str ( nTotal2, 15, 2 )
      ENDIF
      IF nTotal3 <> 0
         ? PadL ( NenapPop(), 25 ) + Str ( nTotal3, 15, 2 )
         ? PadL ( "UKUPNO NAPLATA:", 25 ), Str ( nTotal - nTotal3 + nTotal2, 15, 2 )
      ENDIF
      ? REPL ( "=", 40 )
   ENDIF

   // 3) Rekapitulacija po vrstama placanja
   ?
   ? PadC ( "REKAPITULACIJA PO VRSTAMA PLACANJA", 40 )
   ? PadC ( "--------------------------", 40 )
   ?
   nTotal := 0
   nTotal2 := 0
   nTotal3 := 0
   SELECT POM
   SET ORDER TO TAG "3"
   GO TOP
   DO WHILE !Eof()
      _IdDio := POM->IdDio
      IF Empty ( cIdDio )
         SELECT DIO
         HSEEK ( _IdDio )
         ? REPL ( "-", 40 )
         ? DIO->Naz
         ? REPL ( "-", 40 )
         SELECT POM
      ENDIF
      nTotDio := 0
      nTotDio2 := 0
      nTotDio3 := 0
      DO WHILE !Eof() .AND. POM->IdDio == _IdDio
         _IdVrsteP := POM->IdVrsteP
         SELECT VRSTEP
         HSEEK _IdVrsteP
         ? Space ( 5 ) + PadR ( VrsteP->Naz, 20 )
         SELECT POM
         nTotVrsteP := 0
         nTotVrste2 := 0
         nTotVrste3 := 0
         DO WHILE !Eof() .AND. POM->( IdDio + IdVrsteP ) == ( _IdDio + _IdVrsteP )
            nTotVrsteP += POM->Iznos
            nTotVrste2 += POM->Iznos2
            nTotVrste3 += POM->Iznos3
            SKIP
         ENDDO
         ?? Str ( nTotVrsteP, 15, 2 )
         nTotDio += nTotVrsteP
         nTotDio2 += nTotVrste2
         nTotDio3 += nTotVrste3
      ENDDO
      ? REPL ( "-", 40 )
      ? PadC ( "UKUPNO DIO OBJEKTA", 25 ) + Str ( nTotDio, 15, 2 )
      ? REPL ( "-", 40 )
      nTotal += nTotDio
      nTotal2 += nTotDio2
      nTotal3 += nTotDio3
   ENDDO
   IF Empty ( cIdDio )
      ? REPL ( "=", 40 )
      ? PadC ( "UKUPNO OBJEKAT", 25 ) + Str ( nTotal, 15, 2 )
      IF nTotal2 <> 0
         ? PadL ( "PARTICIPACIJA:", 25 ) + Str ( nTotal2, 15, 2 )
      ENDIF
      IF nTotal3 <> 0
         ? PadL ( NenapPop(), 25 ) + Str ( nTotal3, 15, 2 )
         ? PadL ( "UKUPNO NAPLATA:", 25 ), Str ( nTotal - nTotal3 + nTotal2, 15, 2 )
      ENDIF
      ? REPL ( "=", 40 )
   ENDIF

   // 4) Rekapitulacija po odjeljenjima
   ?
   ? PadC ( "REKAPITULACIJA PO ODJELJENJIMA", 40 )
   ? PadC ( "--------------------------", 40 )
   ?
   nTotal := 0
   SELECT POM
   SET ORDER TO TAG "4"
   GO TOP
   DO WHILE !Eof()
      _IdDio := POM->IdDio
      IF Empty ( cIdDio )
         SELECT DIO
         HSEEK ( _IdDio )
         ? REPL ( "-", 40 )
         ? DIO->Naz
         ? REPL ( "-", 40 )
         SELECT POM
      ENDIF
      nTotDio := 0
      DO WHILE !Eof() .AND. POM->IdDio == _IdDio
         _IdOdj := POM->IdOdj
         SELECT ODJ
         HSEEK _IdOdj
         ? Space ( 5 ) + PadR ( ODJ->Naz, 20 )
         SELECT POM
         nTotOdj := 0
         DO WHILE !Eof() .AND. POM->( IdDio + IdOdj ) == ( _IdDio + _IdOdj )
            nTotOdj += POM->Iznos
            SKIP
         ENDDO
         ?? Str ( nTotOdj, 15, 2 )
         nTotDio += nTotOdj
      ENDDO
      ? REPL ( "-", 40 )
      ? PadC ( "UKUPNO DIO OBJEKTA", 25 ) + Str ( nTotDio, 15, 2 )
      ? REPL ( "-", 40 )
      nTotal += nTotDio
   ENDDO
   IF Empty ( cIdDio )
      ? REPL ( "=", 40 )
      ? PadC ( "UKUPNO OBJEKAT", 25 ) + Str ( nTotal, 15, 2 )
      IF nTotal2 <> 0
         ? PadL ( "PARTICIPACIJA:", 25 ) + Str ( nTotal2, 15, 2 )
      ENDIF
      IF nTotal3 <> 0
         ? PadL ( NenapPop(), 25 ) + Str ( nTotal3, 15, 2 )
         ? PadL ( "UKUPNO NAPLATA:", 25 ), Str ( nTotal - nTotal3 + nTotal2, 15, 2 )
      ENDIF
      ? REPL ( "=", 40 )
   ENDIF

   // 5) Rekapitulacija po robama
   IF cPrikRobe == "D"
      ?
      ? PadC ( "REKAPITULACIJA PO ODJELJENJIMA", 40 )
      ? PadC ( "--------------------------", 40 )
      ?
      SELECT POM
      SET ORDER TO TAG "5"
      GO TOP
      WHILE ! Eof()
         _IdDio := POM->IdDio
         IF Empty ( cIdDio )
            SELECT DIO
            HSEEK _IdDio
            ? DIO->Naz
            ? REPL ( "-", 40 )
            SELECT POM
         ENDIF
         nTotDio := 0
         nTotDio2 := 0
         nTotDio3 := 0
         DO WHILE !Eof() .AND. POM->IdDio == _IdDio
            _IdRoba := POM->IdRoba
            SELECT roba
            HSEEK _IdRoba
            ? Space ( 5 ) + _IdRoba, Left ( roba->Naz, 28 ), "(" + roba->Jmj + ")"
            SELECT POM
            nRobaKol := 0
            nRobaIzn := 0
            nSetova  := 0
            DO WHILE !Eof() .AND. POM->( IdDio + IdRoba ) == ( _IdDio + _IdRoba )
               _IdCijena := POM->IdCijena
               nKol := 0
               nIzn := 0
               nIzn2 := 0
               nIzn3 := 0
               DO WHILE !Eof() .AND. ;
                     POM->( IdDio + IdRoba + IdCijena ) == ( _IdDio + _IdRoba + _IdCijena )
                  nKol += POM->Kolicina
                  nIzn += POM->Iznos
                  nIzn2 += POM->Iznos2
                  nIzn3 += POM->Iznos3
                  SKIP
               ENDDO
               ? Space ( 10 ) + _IdCijena, Str ( nKol, 12, 3 ), Str ( nIzn, 15, 2 )
               nSetova++
               nRobaKol += nKol
               nRobaIzn += nIzn
               nRobaIzn2 += nIzn2
               nRobaIzn3 += nIzn3
               SELECT POM
            END
            nTotDio += nRobaIzn
            nTotDio2 += nRobaIzn2
            nTotDio3 += nRobaIzn3
            IF nSetova > 1
               ? PadL ( "Ukupno roba:", 16 ), Str ( nRobaKol, 12, 3 ), ;
                  Str ( nRobaIzn, 15, 2 )
            ENDIF
         END
         ? REPL ( "=", 40 )
         ? PadC ( "UKUPNO DIO OBJEKTA", 24 ), Str ( nTotDio, 15, 2 )
         ? REPL ( "=", 40 )
         nTotal += nTotDio
         nTotal2 += nTotDio2
         nTotal3 += nTotDio3
      END
      IF Empty ( cIdDio )
         ? REPL ( "*", 40 )
         ? PadC ( "UKUPNO OBJEKAT", 24 ), Str ( nTotDio, 15, 2 )
         IF nTotDio2 <> 0
            ? PadL ( "PARTICIPACIJA:", 29 ), Str ( nTotDio2, 10, 2 )
         ENDIF
         IF nTotDio3 <> 0
            ? PadL ( NenapPop(), 29 ), Str ( nTotDio3, 10, 2 )
            ? PadL ( "UKUPNO NAPLATA:", 29 ), Str ( nTotDio - nTotDio3 + nTotDio2, 10, 2 )
         ENDIF
         ? REPL ( "*", 40 )
      ENDIF
   ENDIF
   ENDPRINT
   CLOSERET
   // }


/* OdjIzvuci(cIdVd)
 *     Punjenje pomocne baze realizacijom odjeljenja
 */

FUNCTION OdjIzvuci( cIdVd )

   SELECT pos_doks
   SEEK cIdVd + DToS( dDat0 )

   DO WHILE !Eof() .AND. pos_doks->IdVd == cIdVd .AND. pos_doks->Datum <= dDat1

      IF ( pos_doks->IdPos = "X" .AND. AllTrim ( cIdPos ) <> "X" ) .OR. ;
            ( ! Empty ( cIdPos ) .AND. pos_doks->IdPos <> cIdPos )
         SKIP
         LOOP
      ENDIF

      SELECT POS
      SEEK pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )
      DO WHILE !Eof() .AND. POS->( IdPos + IdVd + DToS( datum ) + BrDok ) == pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )
         IF ( !Empty ( cIdOdj ) .AND. POS->IdOdj <> cIdOdj ) .OR. ;
               ( !Empty ( cIdDio ) .AND. POS->IdDio <> cIdDio ) .OR. ;
               !Tacno ( aUsl1 )
            SKIP
            LOOP
         ENDIF

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
            nNeplaca += pos->( Kolicina * NCijena )
         ENDIF

         SELECT POM
         Hseek POS->( IdOdj + IdDio + IdPos + IdRoba + IdCijena )

         IF Found()
            REPLACE Kolicina WITH Kolicina + POS->Kolicina, ;
               Iznos    WITH Iznos + POS->Kolicina * POS->Cijena, ;
               iznos3   WITH nNeplaca
            IF gPopVar == "A"
               REPLACE Iznos2   WITH pos->( ncijena )
            ENDIF

         ELSE
            APPEND BLANK
            REPLACE IdOdj  WITH POS->IdOdj,   IdDio    WITH POS->IdDio, ;
               IdRoba WITH POS->IdRoba,  IdCijena WITH POS->IdCijena, ;
               IdPos  WITH pos_doks->IdPos,  Kolicina WITH POS->Kolicina, ;
               Iznos  WITH POS->Kolicina * POS->Cijena, ;
               iznos3 WITH iznos3 + nNeplaca
            IF gPopVar == "A"
               REPLACE iznos2 WITH iznos2 + pos->( ncijena )
            ENDIF
         ENDIF

         SELECT POS
         SKIP

      ENDDO

      SELECT pos_doks
      SKIP

   ENDDO

   RETURN .T.


STATIC FUNCTION _o_tables()

   O_DIO
   O_ODJ
   o_sifk()
   O_SIFV
   O_KASE
   O_ROBA
   o_pos_pos()
   o_pos_doks()

   RETURN .T.
