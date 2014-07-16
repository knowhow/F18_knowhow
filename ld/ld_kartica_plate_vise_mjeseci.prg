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



FUNCTION ld_kartica_plate_za_vise_mjeseci()

   LOCAL nC1 := 20
   LOCAL i

   cIdRadn := Space( _LR_ )
   cIdRj := gRj
   cMjesec := gMjesec
   cMjesec2 := gmjesec
   cGodina := gGodina
   cObracun := gObracun
   cRazdvoji := "N"

   O_LD

   napravi_pomocnu_tabelu()

   my_use( "_ld" )
   INDEX ON idradn + idrj TAG "1"

   my_close_all_dbf()
   O_PAROBR
   O_LD_RJ
   O_RADN
   O_VPOSLA
   O_RADKR
   O_KRED
   O__LD
   SET ORDER TO TAG "1"

   O_LD

   cIdRadn := Space( _LR_ )
   cSatiVO := "S"

   Box(, 6, 77 )
   @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno-sve rj): "  GET cIdRJ VALID Empty( cidrj ) .OR. P_LD_RJ( @cidrj )
   @ m_x + 2, m_y + 2 SAY "od mjeseca: "  GET  cmjesec  PICT "99"
   @ m_x + 2, Col() + 2 SAY "do"  GET  cmjesec2  PICT "99"
   @ m_x + 2, Col() + 2 SAY8 "Obračun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   @ m_x + 3, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   @ m_x + 4, m_y + 2 SAY "Radnik (prazno-svi radnici):" GET cIdRadn  VALID Empty( cIdRadn ) .OR. P_Radn( @cIdRadn )
   @ m_x + 5, m_y + 2 SAY "Razdvojiti za radnika po RJ:" GET cRazdvoji PICT "@!";
      WHEN Empty ( cIdRj ) VALID cRazdvoji $ "DN"
   READ
   clvbox()
   ESC_BCR
   IF Empty( cObracun )
      @ m_x + 6, m_y + 2 SAY8 "Prikaz sati (S-sabrati sve obračune , 1-obračun 1 , 2-obračun 2, ... )" GET cSatiVO VALID cSatiVO $ "S123456789" PICT "@!"
      READ
      ESC_BCR
   ENDIF
   BoxC()

   tipprn_use()

   SELECT LD

   IF !Empty( cObracun )
      SET FILTER TO obr = cObracun
   ENDIF

   cIdRadn := Trim( cidradn )
   IF Empty( cidrj )
      SET ORDER TO tag ( TagVO( "4" ) )
      SEEK Str( cGodina, 4 ) + cIdRadn
      cIdrj := ""
   ELSE
      SET ORDER TO tag ( TagVO( "3" ) )
      SEEK Str( cGodina, 4 ) + cidrj + cIdRadn
   ENDIF
   EOF CRET

   nStrana := 0

   IF cRazdvoji == "N"
      bZagl := {|| ;
         QQOut( "OBRACUN" + iif( lViseObr, IF( Empty( cObracun ), " ' '(SVI)", " '" + cObracun + "'" ), "" ) + Lokal( " PLATE ZA PERIOD" ) + Str( cmjesec, 2 ) + "-" + Str( cmjesec2, 2 ) + "/" + Str( godina, 4 ), " ZA " + Upper( Trim( gTS ) ) + " ", gNFirma ), ;
         QOut( "RJ:", idrj, ld_rj->naz ), ;
         QOut( idradn, "-", RADNIK, "Mat.br:", radn->matbr, " STR.SPR:", IDSTRSPR ), ;
         QOut( Lokal( "Broj knjizice:" ), RADN->brknjiz ), ;
         QOut( "Vrsta posla:", idvposla, vposla->naz, Lokal( "        U radnom odnosu od " ), radn->datod );
         }
   ELSE
      bZagl := {|| ;
         QQOut( Lokal( "OBRACUN" ) + iif( lViseObr, iif( Empty( cObracun ), " ' '(SVI)", " '" + cObracun + "'" ), "" ) + Lokal( " PLATE ZA PERIOD" ) + Str( cmjesec, 2 ) + "-" + Str( cmjesec2, 2 ) + "/" + Str( godina, 4 ), " ZA " + Upper( Trim( gTS ) ) + " ", gNFirma ), ;
         QOut( idradn, "-", RADNIK, "Mat.br:", radn->matbr, " STR.SPR:", IDSTRSPR ), ;
         QOut( "Broj knjizice:", RADN->brknjiz ), ;
         QOut( "Vrsta posla:", idvposla, vposla->naz, Lokal( "        U radnom odnosu od " ), radn->datod );
         }
   ENDIF

   SELECT vposla
   hseek ld->idvposla
   SELECT ld_rj
   hseek ld->idrj
   SELECT ld

   IF PCount() == 4
      START PRINT RET
   ELSE
      START PRINT CRET
      ?
   ENDIF

   SELECT ld
   nT1 := nT2 := nT3 := nT4 := 0
   DO WHILE !Eof() .AND.  cgodina == godina .AND. idrj = cidrj .AND. idradn = cIdRadn

      xIdRadn := idradn
      IF cRazdvoji == "N"
         Scatter( "w" )
         FOR i := 1 TO cLDPolja
            cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
            ws&cPom := 0
            wi&cPom := 0
            wUNeto := wUSati := wUIznos := 0
         NEXT
      ENDIF

      IF cRazdvoji == "N"
         SELECT radn; hseek xidradn
         SELECT vposla; hseek ld->idvposla
         SELECT ld_rj; hseek ld->idrj; SELECT ld
         Eval( bZagl )
      ENDIF
      DO WHILE !Eof() .AND.  cgodina == godina .AND. idrj = cidrj .AND. idradn == xIdRadn

         m := "----------------------- --------  ----------------   ------------------"

         SELECT radn; hseek xidradn; SELECT ld

         IF ( mjesec < cmjesec .OR. mjesec > cmjesec2 )
            skip; LOOP
         ENDIF
         Scatter()
         IF cRazdvoji == "D"
            SELECT _LD
            HSEEK xIdRadn + LD->IdRj
            IF ! Found()
               APPEND BLANK
            ENDIF
            Scatter ( "w" )
            FOR i := 1 TO cLDpolja
               cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
               IF !lViseObr .OR. cSatiVO == "S" .OR. cSatiVO == _obr
                  ws&cPom += _s&cPom
               ENDIF
               wi&cPom += _i&cPom
            NEXT
            wUIznos += _UIznos
            IF !lViseObr .OR. cSatiVO == "S" .OR. cSatiVO == _obr
               wUSati += _USati
            ENDIF
            wUNeto += _UNeto
            wIdRj := _IdRj
            wIdRadn := xIdRadn
            Gather( "w" )
            SELECT LD
            SKIP; LOOP
         ENDIF

         cUneto := "D"
         FOR i := 1 TO cLDPolja
            cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
            SELECT tippr; SEEK cPom
            IF !lViseObr .OR. cSatiVO == "S" .OR. cSatiVO == _obr
               ws&cPom += _s&cPom
            ENDIF
            wi&cPom += _i&cPom
         NEXT
         SELECT ld
         wUIznos += _UIznos
         IF !lViseObr .OR. cSatiVO == "S" .OR. cSatiVO == _obr
            wUSati += _USati
         ENDIF
         wUNeto += _UNeto
         SKIP
      ENDDO

      IF cRazdvoji == "N"
         ? m
         ? Lokal( " Vrsta                  Opis         sati/iznos             ukupno" )
         ? m
         cUneto := "D"
         FOR i := 1 TO cLDPolja
            cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
            SELECT tippr; SEEK cPom
            IF tippr->uneto == "N" .AND. cUneto == "D"
               cUneto := "N"
               ? m
               ? Lokal( "UKUPNO NETO:" )
               @ PRow(), nC1 + 8  SAY  wUSati  PICT gpics
               ?? Lokal( " sati" )
               @ PRow(), 60 SAY wUNeto PICT gpici; ?? "", gValuta
               ? m
            ENDIF

            IF tippr->( Found() ) .AND. tippr->aktivan == "D"
               IF wi&cpom <> 0 .OR. ws&cPom <> 0
                  ? tippr->id + "-" + tippr->naz, tippr->opis
                  nC1 := PCol()
                  IF tippr->fiksan $ "DN"
                     @ PRow(), PCol() + 8 SAY ws&cPom  PICT gpics; ?? " s"
                     @ PRow(), 60 SAY wi&cPom        PICT gpici
                  ELSEIF tippr->fiksan == "P"
                     @ PRow(), PCol() + 8 SAY ws&cPom  PICT "999.99%"
                     @ PRow(), 60 SAY wi&cPom        PICT gpici
                  ELSEIF tippr->fiksan == "B"
                     @ PRow(), PCol() + 8 SAY ws&cPom  PICT "999999"; ?? " b"
                     @ PRow(), 60 SAY wi&cPom        PICT gpici
                  ELSEIF tippr->fiksan == "C"
                     @ PRow(), 60 SAY wi&cPom        PICT gpici
                  ENDIF
               ENDIF
            ENDIF
         NEXT
         ? m
         ?  Lokal( "UKUPNO ZA ISPLATU" )
         @ PRow(), 60 SAY wUIznos PICT gpici; ?? "", gValuta
         ? m
         IF PRow() > 31
            FF
         ELSE
            ?
            ?
            ?
            ?
         ENDIF
      ELSE
         SELECT _LD
         GO TOP
         SELECT radn; hseek _LD->idradn
         SELECT vposla; hseek _LD->idvposla
         SELECT _LD
         Eval( bZagl )
         ?
         WHILE ! Eof()
            SELECT ld_rj; hseek _ld->idrj; SELECT _ld
            QOut( "RJ:", idrj, ld_rj->naz )
            ? m
            ? Lokal( " Vrsta                  Opis         sati/iznos             ukupno" )
            ? m
            //
            Scatter( "w" )
            cUneto := "D"
            FOR i := 1 TO cLDPolja
               cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
               SELECT tippr; SEEK cPom
               IF tippr->uneto == "N" .AND. cUneto == "D"
                  cUneto := "N"
                  ? m
                  ? Lokal( "UKUPNO NETO:" )
                  @ PRow(), nC1 + 8  SAY  wUSati  PICT gpics; ?? " sati"
                  @ PRow(), 60 SAY wUNeto PICT gpici; ?? "", gValuta
                  ? m
               ENDIF

               IF tippr->( Found() ) .AND. tippr->aktivan == "D"
                  IF wi&cpom <> 0 .OR. ws&cPom <> 0
                     ? tippr->id + "-" + tippr->naz, tippr->opis
                     nC1 := PCol()
                     IF tippr->fiksan $ "DN"
                        @ PRow(), PCol() + 8 SAY ws&cPom  PICT gpics; ?? " s"
                        @ PRow(), 60 SAY wi&cPom        PICT gpici
                     ELSEIF tippr->fiksan == "P"
                        @ PRow(), PCol() + 8 SAY ws&cPom  PICT "999.99%"
                        @ PRow(), 60 SAY wi&cPom        PICT gpici
                     ELSEIF tippr->fiksan == "B"
                        @ PRow(), PCol() + 8 SAY ws&cPom  PICT "999999"; ?? " b"
                        @ PRow(), 60 SAY wi&cPom        PICT gpici
                     ELSEIF tippr->fiksan == "C"
                        @ PRow(), 60 SAY wi&cPom        PICT gpici
                     ENDIF
                  ENDIF
               ENDIF
            NEXT
            ? m
            ?  "UKUPNO ZA ISPLATU U RJ", _LD->IdRj
            @ PRow(), 60 SAY wUIznos PICT gpici
            ?? "", gValuta
            ? m
            IF PRow() > 60 + gPstranica
               FF
            ELSE
               ?
               ?
            ENDIF
            SELECT _LD
            SKIP
         ENDDO
      ENDIF
      SELECT ld

   ENDDO

   FF
   END PRINT
   my_close_all_dbf()

   RETURN



STATIC FUNCTION napravi_pomocnu_tabelu()

   LOCAL _i, _struct
   LOCAL _table := "_ld"
   LOCAL _ret := .T.

   IF File( my_home() + _table + ".dbf" )
      FErase( my_home() + _table + ".dbf" )
   ENDIF

   _struct := LD->( dbStruct() )

   FOR _i := 1 TO Len( _struct )
      IF _struct[ _i, 2 ] == "N" .AND. !( Upper( AllTrim( _struct[ _i, 1 ] ) ) $ "GODINA#MJESEC" )
         _struct[ _i, 3 ] += 4
      ENDIF
   NEXT

   dbCreate( my_home() + _table + ".dbf", _struct )

   IF !File( my_home() + _table + ".dbf" )
      MsgBeep( "Ne postoji " + _table + ".dbf !!!" )
      _ret := .F.
   ENDIF

   RETURN _ret




