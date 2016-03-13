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


FUNCTION proizvoljni_izvjestaji()

   LOCAL cScr := SaveScreen( 1, 0, 1, 79 )
   LOCAL GetList := {}
   LOCAL _my_user := my_user()
   LOCAL _i
   PRIVATE cV1, cV2, cV3, cV4, cV5, cV6
   PRIVATE opc[ 10 ]
   PRIVATE Izbor
   PRIVATE nTekIzv := 1
   PRIVATE cBrI := fetch_metric( "proiz_broj_izvjestaja", _my_user, "01" )
   PRIVATE cPotrazKon := fetch_metric( "proiz_kto_potrazuje", _my_user, "7;811;812;" )
   PRIVATE gnPorDob := fetch_metric( "proiz_por_dob", _my_user, 30 )
   PRIVATE cPIKPolje := ""
   PRIVATE cPIKBaza := ""
   PRIVATE cPIKIndeks := ""
   PRIVATE cPITipTab := ""
   PRIVATE cPIKSif := ""
   PRIVATE cPIImeKP := ""

   IF tekuci_modul() == "KALK"
      OtBazPIKalk()
   ELSE
      OtBazPIFin()
   ENDIF

   // # hash na pocetku kaze - obavezno browsaj !
   P_Proizv( @cBrI, NIL, NIL, "#Odaberi izvjestaj :" )

   nTokens := NumToken( izvje->naz, "#" )

   IF nTokens > 1

      Box(, nTokens + 1, 75 )

      @ m_x + 0, m_y + 3 SAY "Unesi varijable0 izvjestaja:"

      // popuni ini fajl vrijednostima
      // formira varijable cV1, cV2 redom !!!!1

      FOR i := 2 TO nTokens
         cPom := "cV" + AllTrim( Str( i - 1 ) )
         &cPom := PadR( UzmiIzIni( EXEPATH + 'ProIzvj.ini', 'Varijable0', AllTrim( Token( izvje->naz, "#", i ) ), "", 'READ' ), 45 )
      NEXT


      FOR i := 2 TO nTokens
         cPom := "cV" + AllTrim( Str( i - 1 ) )
         @ m_X + i, m_y + 2 SAY PadR( Token( izvje->naz, "#", i ), 20 )
         @ m_x + i, Col() + 2 GET &cPom
      NEXT

      READ

      BoxC()

      // popuni ini fajl vrijednostima
      FOR i := 2 TO nTokens
         cPom := "cV" + AllTrim( Str( i - 1 ) )
         UzmiIzIni( EXEPATH + 'ProIzvj.ini', 'Varijable0', AllTrim( Token( izvje->naz, "#", i ) ), &cPom, 'WRITE' )
      NEXT

   ENDIF

   // snimi sql parametre
   set_metric( "proiz_broj_izvjestaja", _my_user, cBrI )
   set_metric( "proiz_kto_potrazuje", _my_user, cPotrazKon )
   set_metric( "proiz_por_dob", _my_user, gnPorDob )

   nTekIzv := Val( cBrI )

   opc[ 1 ] := "1. generisanje izvještaja                       "
   opc[ 2 ] := "2. šifarnik izvjestaja"
   opc[ 3 ] := "3. redovi izvjestaja"
   opc[ 4 ] := "4. zaglavlje izvjestaja"
   opc[ 5 ] := "5. kolone izvjestaja"
   opc[ 6 ] := "6. parametri (svi izvjestaji) "
   opc[ 7 ] := "7. tekuci izvjestaj: " + Str( nTekIzv, 2 )
   opc[ 8 ] := "8. preuzimanje definicija izvjestaja sa diskete"
   opc[ 9 ] := "9. promjeni broj izvjestaja"
   opc[ 10 ] := "A. ispravka proizvj.ini"

   izbor := 1

   PrikaziTI( cBrI )

   IF tekuci_modul() == "KALK"
      GenProIzvKalk()
      OtBazPIKalk()
   ELSEIF tekuci_modul() == "FIN"
      GenProIzvFin()
      OtBazPIFin()
   ENDIF

   FOR _i := 1 TO Len( opc )
      AAdd( h, "" )
   NEXT

   DO WHILE .T.

      izbor := Menu( "ProIzv", opc, izbor, .F. )

      DO CASE
      CASE izbor == 0
         EXIT
      CASE izbor == 1
         IF tekuci_modul() == "KALK"
            GenProIzvKalk()
            OtBazPIKalk()
         ELSEIF tekuci_modul() == "FIN"
            GenProIzvFin()
            OtBazPIFin()
         ENDIF

      CASE izbor == 2
         P_ProIzv()
         PrikaziTI( cBrI )
      CASE izbor == 3
         P_KonIz()
      CASE izbor == 4
         P_ZagProIzv()
      CASE izbor == 5
         P_KolProIzv()
      CASE izbor == 6
         IF tekuci_modul() == "KALK"
            ParSviIzvjKalk()
         ELSEIF tekuci_modul() == "FIN"
            ParSviIzvjFin()
         ENDIF
      CASE izbor == 7
         Box(, 3, 70 )
         @ m_x + 2, m_y + 2 SAY "Izaberite tekuci izvjestaj (1-99):" GET nTekIzv VALID nTekIzv > 0 .AND. nTekIzv < 100 PICT "99"
         READ
         BoxC()
         IF LastKey() != K_ESC
            opc[ 7 ] := "7. tekuci izvjestaj: " + Str( nTekIzv, 2 )
            cBrI := Right( "00" + AllTrim( Str( nTekIzv ) ), 2 )
            PrikaziTI( cBrI )
            UzmiIzIni( EXEPATH + 'ProIzvj.ini', 'Varijable', 'OznakaIzvj', cBrI, 'WRITE' )
            set_metric( "proiz_broj_izvjestaja", _my_user, cBrI )
         ENDIF
      CASE izbor == 8
         MsgBeep( "nije implementirano !!!!" )
      CASE izbor == 9
         PromBroj()
      CASE izbor == 10
         MsgBeep( "nije implementirano !!!!" )

      ENDCASE

   ENDDO

   RestScreen( 1, 0, 1, 79, cScr )

   my_close_all_dbf()

   RETURN




STATIC FUNCTION P_ProIzv( cId, dx, dy, cNaslov )

   LOCAL i := 0
   PRIVATE imekol := {}, kol := {}

   ImeKol := { { "Sifra", {|| id     }, "ID",, {|| vpsifra ( wId ) } }, ;
      { "Naziv", {|| naz    }, "NAZ"     }, ;
      { "Filter klj.baze", {|| uslov  }, "USLOV"   }, ;
      { "Kljucno polje", {|| kpolje }, "KPOLJE"  }, ;
      { "Opis klj.polja", {|| imekp  }, "IMEKP"   }, ;
      { "Baza sif.k.polja", {|| ksif   }, "KSIF"    }, ;
      { "Kljucna baza", {|| kbaza  }, "KBAZA"   }, ;
      { "Kljucni indeks", {|| kindeks }, "KINDEKS" }, ;
      { "Tip tabele", {|| tiptab }, "TIPTAB"  };
      }

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   aDefSpremBaz := { { F_Baze( "KONIZ" ), "ID", "IZV", "" }, ;
      { F_Baze( "KOLIZ" ), "ID", "ID", "" }, ;
      { F_Baze( "ZAGLI" ), "ID", "ID", "" } }
   IF cNaslov = NIL
      cNaslov := "Izvjestaji"
   ENDIF

   RETURN PostojiSifra( F_Baze( "IZVJE" ), 1, 10, 77, cNaslov, @cId, dx, dy )





STATIC FUNCTION P_ZagProIzv( cId, dx, dy, lSamoStampaj )

   LOCAL i := 0

   IF lSamoStampaj == NIL
      lSamoStampaj := .F.
   ENDIF

   PRIVATE imekol := {}, kol := {}

   SELECT ZAGLI
   SET FILTER TO
   SET FILTER TO ID == cBrI
   dbGoTop()

   ImeKol := { { "Sifra", {|| Id }, "id", {|| wId := cBrI, .T. }, {|| .T. } }, ;
      { "Koord.x", {|| x1 }, "x1"     }, ;
      { "Koord.y", {|| y1 }, "y1"     }, ;
      { "IZRAZ", {|| izraz }, "izraz"  };
      }

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   IF lSamoStampaj
      dbGoTop()
      P_12CPI
      QOPodv( "Izvjestaj " + cBrI + "(" + Trim( DoHasha( IZVJE->naz ) ) + ") - definicija zaglavlja izvjestaja" )
      QOPodv( "ZAGLI.DBF, (KUMPATH='" + Trim( KUMPATH ) + "')" )
      ?
      print_lista(,,, .F., .T. )
      RETURN
   ENDIF

   RETURN PostojiSifra( F_Baze( "ZAGLI" ), "1", 10, 77, "ZAGLAVLJE IZVJESTAJA BR." + AllTrim( Str( nTekIzv ) ),@cId, dx, dy, {| Ch| APBlok( Ch ) } )


STATIC FUNCTION APBlok( Ch )

   LOCAL lVrati := DE_CONT, nRec := 0, i := 0

   IF Ch == K_ALT_P
      IF Pitanje(, "Želite li preuzeti podatke iz drugog izvjestaja? (D/N)", "N" ) == "D"
         i := 1
         Box(, 3, 60 )
         @ m_x + 2, m_y + 2 SAY "Preuzeti podatke iz izvjestaja br.? (1-99)" GET i VALID i > 0 .AND. i < 100 .AND. i <> nTekIzv PICT "99"
         READ
         BoxC()
         IF LastKey() != K_ESC
            SET FILTER TO
            dbGoTop()
            DO WHILE !Eof()
               SKIP 1; nRec := RecNo(); SKIP -1
               IF id == Right( "00" + AllTrim( Str( i ) ), 2 )
                  Scatter()
                  _id := cBrI
                  APPEND BLANK
                  Gather()
               ENDIF
               GO ( nRec )
            ENDDO
            lVrati := DE_REFRESH
            SET FILTER TO ID == cBrI
            dbGoTop()
         ENDIF
      ENDIF
   ENDIF

   RETURN lVrati



STATIC FUNCTION P_KolProIzv( cId, dx, dy, lSamoStampaj )

   LOCAL i := 0

   IF lSamoStampaj == NIL; lSamoStampaj := .F. ; ENDIF
   PRIVATE imekol := {}, kol := {}
   SELECT KOLIZ
   SET FILTER TO
   SET FILTER TO ID == cBrI
   dbGoTop()
   ImeKol := { { "Sifra", {|| Id      }, "id", {|| wId := cBrI, .T. }, {|| .T. } }, ;
      { "Red.broj", {|| RBR     }, "RBR"      }, ;
      { "Ime kol.", {|| NAZ     }, "NAZ"      }, ;
      { "Formula", {|| FORMULA }, "FORMULA"  }, ;
      { "Uslov", {|| KUSLOV  }, "KUSLOV"   }, ;
      { "Izraz zbrajanja", {|| SIZRAZ  }, "SIZRAZ"   }, ;
      { "Tip", {|| TIP     }, "TIP"      }, ;
      { "Sirina", {|| SIRINA  }, "SIRINA"   }, ;
      { "Decimale", {|| DECIMALE }, "DECIMALE" }, ;
      { "Sumirati", {|| SUMIRATI }, "SUMIRATI" }, ;
      { "K1", {|| K1      }, "K1"       }, ;
      { "K2", {|| K2      }, "K2"       }, ;
      { "N1", {|| N1      }, "N1"       }, ;
      { "N2", {|| N2      }, "N2"       };
      }
   IF lSamoStampaj
      dbGoTop()
      P_12CPI
      QOPodv( "Izvjestaj " + cBrI + "(" + Trim( DoHasha( IZVJE->naz ) ) + ") - definicija kolona izvjestaja" )
      QOPodv( "KOLIZ.DBF, (KUMPATH='" + Trim( KUMPATH ) + "')" )
      P_COND2
      ?
      ? ".........................................."
      DO WHILE !Eof()

         IF ( PRow() > 50 + dodatni_redovi_po_stranici() )
            FF
            P_12CPI
            QOPodv( "Izvjestaj " + cBrI + "(" + Trim( DoHasha( IZVJE->naz ) ) + ") - definicija kolona izvjestaja" )
            QOPodv( "KOLIZ.DBF, (KUMPATH='" + Trim( KUMPATH ) + "')" )
            P_COND2
            ?
            ? ".........................................."
         ENDIF
         ? PadR( "Redni broj     :", 16 ); ?? RBR
         ? PadR( "Ime kolone     :", 16 ); ?? NAZ
         ? PadR( "Formula        :", 16 ); ?? Trim( FORMULA )
         ? PadR( "Uslov          :", 16 ); ?? KUSLOV
         ? PadR( "Izraz zbrajanja:", 16 ); ?? SIZRAZ
         ? PadR( "Tip            :", 16 ); ?? TIP
         ? PadR( "Sirina         :", 16 ); ?? SIRINA
         ? PadR( "Decimale       :", 16 ); ?? DECIMALE
         ? PadR( "Sumirati       :", 16 ); ?? SUMIRATI
         ? PadR( "K1             :", 16 ); ?? K1
         ? PadR( "K2             :", 16 ); ?? K2
         ? PadR( "N1             :", 16 ); ?? N1
         ? PadR( "N2             :", 16 ); ?? N2
         ? ".........................................."

         SKIP 1
      ENDDO
      RETURN
   ENDIF
   FOR i := 1 TO Len( ImeKol ); AAdd( Kol, i ); NEXT

   RETURN PostojiSifra( F_Baze( "KOLIZ" ), "1", 10, 77, "KOLONE IZVJESTAJA BR." + AllTrim( Str( nTekIzv ) ),@cId, dx, dy, {| Ch| APBlok( Ch ) } )





STATIC PROCEDURE P_KonIz()

   LOCAL i := 0
   PRIVATE ImeKol := {}, Kol := {}

   IF LastKey() == K_ESC; RETURN; ENDIF

   SELECT KONIZ
   SET ORDER TO TAG "1"
   SET FILTER TO
   SET FILTER TO IZV == cBrI
   dbGoTop()

   AAdd( ImeKol, { "IZVJ.", {|| IZV }, "IZV"  } )
   AAdd( ImeKol, { cPIImeKP, {|| ID  }, "ID"   } )
   AAdd( ImeKol, { "R.BROJ", {|| RI  }, "RI"   } )
   AAdd( ImeKol, { "K(  /Sn/An)", {|| K   }, "K"    } )
   AAdd( ImeKol, { "FORMULA", {|| FI  }, "FI"   } )
   AAdd( ImeKol, { "PREDZNAK", {|| PREDZN }, "PREDZN"   } )
   AAdd( ImeKol, { "OPIS", {|| OPIS }, "OPIS", {|| .T. }, {|| .T. }  } )
   AAdd( ImeKol, { cPIImeKP + "2", {|| ID2 }, "ID2"  } )
   AAdd( ImeKol, { "K2(  /Sn/An)", {|| K2  }, "K2"   } )
   AAdd( ImeKol, { "FORMULA2", {|| FI2 }, "FI2"  } )
   AAdd( ImeKol, { "PREDZNAK2", {|| PREDZN2 }, "PREDZN2"   } )
   AAdd( ImeKol, { "PODVUCI", {|| PODVUCI }, "PODVUCI"   } )
   IF FieldPos( "K1" ) <> 0
      AAdd( ImeKol, { "K1", {|| K1      }, "K1"        } )
      AAdd( ImeKol, { "U1", {|| U1      }, "U1"        } )
   ENDIF

   FOR i := 1 TO Len( ImeKol ); AAdd( Kol, i ); NEXT

   Box(, 20, 77 )
   @ m_x + 18, m_y + 2 SAY "<a-P> popuni bazu iz sifrarnika   <a-N> preuzmi iz drugog izvjestaja"
   @ m_x + 19, m_y + 2 SAY "<c-N> nova stavka                 <c-I> nuliranje po uslovu         "
   @ m_x + 20, m_y + 2 SAY "<c-T> brisi stavku              <Enter> ispravka stavke             "
   my_db_edit( "PKONIZ", 20, 77, {|| KonIzBlok() }, "", "Priprema redova za izvjestaj br." + cBrI + "ÍÍÍÍÍ<c-P> vidi komplet definiciju", , , , , 3 )
   BoxC()

   RETURN



STATIC FUNCTION KonIzBlok()

   LOCAL GetList := {}
   LOCAL lVrati := DE_CONT, i := 0, nRec := 0, n0 := 0, n1 := 0, nSRec := 0, cUslov := ""
   PRIVATE aUslov := ""

   DO CASE
   CASE Ch == K_CTRL_P

      // --------- stampanje definicije izvjestaja ---------
      // ---------------------------------------------------
      SELECT IZVJE
      SEEK cBrI
      StartPrint()

      P_12CPI
      QOPodv( "Izvjestaj " + cBrI + "(" + Trim( DoHasha( IZVJE->naz ) ) + ") - osnovna definicija izvjestaja" )
      QOPodv( "IZVJE.DBF, (KUMPATH='" + Trim( KUMPATH ) + "')" )

      ?
      ? PadL( "Sifra",17 ); ?? ":", id
      ? PadL( "Naziv",17 ); ?? ":", Trim( naz )
      ? PadL( "Filter klj.baze",17 ); ?? ":", Trim( uslov )
      ? PadL( "Kljucno polje",17 ); ?? ":", Trim( kpolje )
      ? PadL( "Opis klj.polja",17 ); ?? ":", Trim( imekp )
      ? PadL( "Baza sif.k.polja", 17 ); ?? ":", Trim( ksif )
      ? PadL( "Kljucna baza",17 ); ?? ":", Trim( kbaza )
      ? PadL( "Kljucni indeks",17 ); ?? ":", Trim( kindeks )
      ? PadL( "Tip tabele",17 ); ?? ":", tiptab


      FF

      P_ZagProizv(,,, .T. ); FF

      P_KolProizv(,,, .T. ); FF

      P_12CPI
      QOPodv( "Izvjestaj " + cBrI + "(" + Trim( DoHasha( IZVJE->naz ) ) + ") - definicija redova izvjestaja" )
      QOPodv( "KONIZ.DBF, (KUMPATH='" + Trim( KUMPATH ) + "')" )
      SELECT KONIZ; nRec := RecNo()
      dbGoTop()
      ?
      ? ".........................................."
      DO WHILE !Eof()
         IF PRow() > 50 + dodatni_redovi_po_stranici()
            P_12CPI
            FF
            QOPodv( "Izvjestaj " + cBrI + "(" + Trim( DoHasha( IZVJE->naz ) ) + ") - definicija redova izvjestaja" )
            QOPodv( "KONIZ.DBF, (KUMPATH='" + Trim( KUMPATH ) + "')" )
            ?
            ? ".........................................."
         ENDIF
         ?  "Redni broj  :"           ; ?? ri
         ?  PadR( cPIImeKP, 12 ) + ":"     ; ?? id
         ?  "K(  /Sn/An) :"           ; ?? k
         ?  "Formula     :"           ; ?? fi
         ?  "Predznak    :"           ; ?? predzn
         ?  PadR( cPIImeKP + "2", 12 ) + ":" ; ?? id2
         ?  "K2(  /Sn/An):"           ; ?? k2
         ?  "Formula2    :"           ; ?? fi2
         ?  "Predznak2   :"           ; ?? predzn2
         ?  "OPIS        :"           ; ?? opis
         ?  "PODVUCI( /x):"           ; ?? podvuci
         IF FieldPos( "K1" ) <> 0
            ? "K1          :"          ; ?? k1
            ? "U1 ( ,>0,<0):"          ; ?? u1
         ENDIF
         ? ".........................................."
         SKIP 1
      ENDDO
      FF

      EndPrint()
      SELECT KONIZ; GO ( nRec )

   CASE Ch == K_ALT_P      // popuni nanovo iz sifrarnika kljucnog polja
      IF cPIKSif != "BEZ" .AND. Pitanje( , "Želite li obrisati bazu i formirati novu na osnovu sifrar.klj.polja?(D/N)", "N" ) == "D"
         SELECT KONIZ
         my_dbf_zap()

         O_KSIF()
         dbGoTop()
         DO WHILE !Eof()
            ++i
            SELECT KONIZ
            APPEND BLANK
            REPLACE izv WITH Right( "00" + AllTrim( Str( nTekIzv ) ), 2 ), ;
               id WITH IzKSIF( "id" ),  ri WITH i
            SEL_KSif()
            SKIP 1
         ENDDO
         USE      // zatvaram KONTO.DBF
         SELECT KONIZ; dbGoTop()
         lVrati := DE_REFRESH
      ENDIF
   CASE Ch == K_ALT_N      // popuni iz drugog izvjestaja
      IF Pitanje(, "Želite li postojeće zamijeniti podacima iz drugog izvještaja?(D/N)", "N" ) == "D"
         i := 1
         Box(, 3, 60 )
         @ m_x + 2, m_y + 2 SAY "Preuzeti podatke iz izvjestaja br.? (1-99)" GET i VALID i > 0 .AND. i < 100 .AND. i <> nTekIzv PICT "99"
         READ
         BoxC()
         IF LastKey() != K_ESC
            SELECT KONIZ
            dbGoTop()
            DO WHILE !Eof() .AND. izv == cBrI
               SKIP 1; nRec := RecNo(); SKIP -1; DELETE; GO ( nRec )
            ENDDO
            SET FILTER TO
            SEEK Right( "00" + AllTrim( Str( i ) ), 2 )
            DO WHILE !Eof() .AND. izv == Right( "00" + AllTrim( Str( i ) ), 2 )
               SKIP 1; nRec := RecNo(); SKIP -1
               Scatter()
               _IZV := cBrI
               APPEND BLANK
               Gather()
               GO ( nRec )
            ENDDO
            SET FILTER TO izv == cBrI
            dbGoTop()
            lVrati := DE_REFRESH
         ENDIF
      ENDIF
   CASE Ch == K_ENTER              // ispravka
      Box(, 15, 77 )
      Scatter()
      n0 := _ri
      @ m_x, m_y + 2 SAY "ISPRAVKA STAVKE - IZVJESTAJ " + cBrI
      @ m_x + 2, m_y + 2 SAY "Redni broj  :" GET _ri PICT "9999"
      @ m_x + 3, m_y + 2 SAY PadR( cPIImeKP, 12 ) + ":" GET _id
      @ m_x + 4, m_y + 2 SAY "K(  /Sn/An) :" GET _k
      @ m_x + 5, m_y + 2 SAY "Formula     :" GET _fi PICT "@S60"
      @ m_x + 6, m_y + 2 SAY "Predznak    :" GET _predzn VALID _predzn <= 1 .AND. _predzn >= -1 PICT "99"
      @ m_x + 7, m_y + 2 SAY PadR( cPIImeKP + "2", 12 ) + ":" GET _id2
      @ m_x + 8, m_y + 2 SAY "K2(  /Sn/An):" GET _k2
      @ m_x + 9, m_y + 2 SAY "Formula2    :" GET _fi2 PICT "@S60"
      @ m_x + 10, m_y + 2 SAY "Predznak2   :" GET _predzn2 VALID _predzn2 <= 1 .AND. _predzn2 >= -1 PICT "99"
      @ m_x + 11, m_y + 2 SAY "OPIS        :" GET _opis  when {|| .T. } valid {|| .T. }
      @ m_x + 12, m_y + 2 SAY "PODVUCI( /x):" GET _podvuci
      IF FieldPos( "K1" ) <> 0
         @ m_x + 13, m_y + 2 SAY "K1          :" GET _k1
         @ m_x + 14, m_y + 2 SAY "U1 ( ,>0,<0):" GET _u1
      ENDIF
      READ
      BoxC()
      n1 := _ri
      IF LastKey() != K_ESC
         Gather()
         // DbfRBrSort(n0,n1,"RI",RECNO())
         lVrati := DE_REFRESH
      ENDIF
   CASE Ch == K_CTRL_N             // nova stavka
      Box(, 15, 77 )
      SET KEY K_ALT_R TO UzmiIzPreth()
      DO WHILE .T.
         nRec := RecNo()
         GO BOTTOM
         i := ri; SKIP 1
         Scatter()
         _izv := cBrI
         _ri := i + 1
         n0 := _ri
         @ m_x, m_y + 2 SAY "UNOS NOVE STAVKE - IZVJESTAJ " + cBrI
         @ m_x + 2, m_y + 2 SAY "Redni broj  :" GET _ri PICT "9999"
         @ m_x + 3, m_y + 2 SAY PadR( cPIImeKP, 12 ) + ":" GET _id
         @ m_x + 4, m_y + 2 SAY "K(  /Sn/An) :" GET _k
         @ m_x + 5, m_y + 2 SAY "Formula     :" GET _fi PICT "@S60"
         @ m_x + 6, m_y + 2 SAY "Predznak    :" GET _predzn VALID _predzn <= 1 .AND. _predzn >= -1 PICT "99"
         @ m_x + 7, m_y + 2 SAY PadR( cPIImeKP + "2", 12 ) + ":" GET _id2
         @ m_x + 8, m_y + 2 SAY "K2(  /Sn/An):" GET _k2
         @ m_x + 9, m_y + 2 SAY "Formula2    :" GET _fi2 PICT "@S60"
         @ m_x + 10, m_y + 2 SAY "Predznak2   :" GET _predzn2 VALID _predzn2 <= 1 .AND. _predzn2 >= -1 PICT "99"
         @ m_x + 11, m_y + 2 SAY "OPIS        :" GET _opis  when {|| .T. } valid {|| .T. }
         @ m_x + 12, m_y + 2 SAY "PODVUCI( /x):" GET _podvuci
         IF FieldPos( "K1" ) <> 0
            @ m_x + 13, m_y + 2 SAY "K1          :" GET _k1
            @ m_x + 14, m_y + 2 SAY "U1 ( ,>0,<0):" GET _u1
         ENDIF
         READ
         n1 := _ri
         IF LastKey() != K_ESC
            APPEND BLANK
            Gather()
            // DbfRBrSort(n0,n1,"RI",RECNO())
            lVrati := DE_REFRESH
         ELSE
            GO BOTTOM
            EXIT
         ENDIF
      ENDDO
      SET KEY K_ALT_R TO
      BoxC()
   CASE Ch == K_CTRL_I             // iskljucenje (nuliranje) po uslovu
      cUslov := Space( 80 )
      Box(, 4, 77 )
      DO WHILE .T.
         @ m_x + 2, m_y + 2 SAY "Uslov za nuliranje stavki (za " + cPIImeKP + "):"
         @ m_x + 3, m_y + 2 GET cUslov PICT "@S70"
         READ
         aUslov := Parsiraj( cUslov, "ID", "C" )
         IF aUslov <> NIL .OR. LastKey() == K_ESC; EXIT; ENDIF
      ENDDO
      BoxC()
      IF LastKey() != K_ESC
         i := 0
         dbGoTop()
         SEEK cBrI
         DO WHILE !Eof() .AND. izv == cBrI
            SKIP 1; nSRec := RecNo(); SKIP -1
            IF ri <> 0 .AND. &aUslov
               Scatter(); _ri := 0; Gather()
            ELSEIF ri <> 0
               ++i
               Scatter(); _ri := i; Gather()
            ENDIF
            GO ( nSRec )
         ENDDO
         lVrati := DE_REFRESH
      ENDIF

   CASE Ch == K_CTRL_T
      IF Pitanje(, "Želite li izbrisati ovu stavku ?", "D" ) == "D"
         n0 := ri
         DELETE
         // DbfRBrSort(n0,0,"ri",RECNO())     // recno() je ovdje nebitan
         lVrati := DE_REFRESH
      ENDIF
   ENDCASE

   RETURN lVrati





STATIC PROCEDURE UzmiIzPreth()

   LOCAL nRec := RecNo()

   GO BOTTOM
   _id := id; _id2 := id2; _k := k; _k2 := k2; _fi := fi; _fi2 := fi2; _opis := opis
   _predzn := predzn; _predzn2 := predzn2; _podvuci := podvuci
   GO ( nRec )
   AEval( GetList, {| o| o:display() } )

   RETURN




FUNCTION TxtUKod( cTxt, cBUI )

   LOCAL lPrinter := Set( _SET_PRINTER, .T. )
   LOCAL nRow := PRow(), nCol := PCol()

   IF "B" $ cBUI; gPB_ON(); ENDIF
   IF "U" $ cBUI; gPU_ON(); ENDIF
   IF "I" $ cBUI; gPI_ON(); ENDIF
   SetPRC( nRow, nCol )
   SET( _SET_PRINTER, lPrinter )
   ?? cTxt
   lPrinter := Set( _SET_PRINTER, .T. ); nRow := PRow(); nCol := PCol()
   IF "B" $ cBUI; gPB_OFF(); ENDIF
   IF "U" $ cBUI; gPU_OFF(); ENDIF
   IF "I" $ cBUI; gPI_OFF(); ENDIF
   SetPRC( nRow, nCol )
   SET( _SET_PRINTER, lPrinter )

   RETURN ""



FUNCTION StKod( cKod )

   Setpxlat(); QQOut( cKod )

   RETURN ""




PROCEDURE RazvijUslove( cUsl )

   LOCAL nPoz := 0, i := 0
   PRIVATE cPom := ""

   DO WHILE .T.
      nPoz := At( "#", cUsl )
      cPom := "USL" + AllTrim( Str( ++i ) )
      IF nPoz > 0
         REPLACE &cPom WITH Left( cUsl, nPoz - 1 )
         cUsl := SubStr( cUsl, nPoz + 1 )
      ELSE
         REPLACE &cPom WITH Trim( cUsl )
         EXIT
      ENDIF
   ENDDO

   RETURN



FUNCTION PreformIznos( x, y, z )

   LOCAL xVrati := ""

   IF Int( x ) == x     // moze format bez decimala
      xVrati := Str( x, y )
   ELSE             // ide format sa decimalama ukoliko su zadane
      xVrati := Str( x, y, z )
   ENDIF

   RETURN xVrati



STATIC FUNCTION RacForm( cForm, cSta )

   LOCAL nVrati := 0, nRec := RecNo(), nPoz := 0, cAOP := ""
   PRIVATE cForm77 := AllTrim( SubStr( cForm, 2 ) )

   DO WHILE .T.
      nPoz := At( "ST", cForm77 )
      IF nPoz > 0
         cAOP := ""
         DO WHILE .T.
            IF Len( cForm77 ) >= nPoz + 2 .AND. SubStr( cForm77, nPoz + 2, 1 ) $ "0123456789"
               cAOP += SubStr( cForm77, nPoz + 2, 1 )
               ++nPoz
            ELSE
               EXIT
            ENDIF
         ENDDO
         cForm77 := StrTran( cForm77, "ST" + cAOP, "(" + AllTrim( Str( CupajAOP( cAOP, cSta ) ) ) + ")", 1, 1 )
         IF !lObradjen
            EXIT
         ENDIF
      ELSE
         EXIT
      ENDIF
   ENDDO
   IF lObradjen
      nVrati := &cForm77
   ENDIF
   GO ( nRec )

   RETURN nVrati


STATIC FUNCTION CupajAOP( cAOP, cSta )

   LOCAL nVrati := 0
   PRIVATE cSta77 := cSta

   HSEEK PadL( cAOP, 5 )
   IF Found()
      IF Empty( U1 )
         nVrati := &cSta77
      ELSE
         cPUTS := cSta77 + Trim( U1 )
         IF &cPUTS
            nVrati := &cSta77
         ENDIF
      ENDIF
      IF Left( uslov, 1 ) == "="
         lObradjen := .F.
      ENDIF
   ENDIF

   RETURN nVrati




// -------------------------------------------------------------
// otvara tabelu sifranika koja je zadata u definicijama
// -------------------------------------------------------------
FUNCTION O_KSif()

   LOCAL _area := F_KSif()

   SELECT ( _area )

   my_use( Lower( cPIKSif ) )
   SET ORDER TO TAG "ID"

   RETURN


// -------------------------------------------------------------
// vraca podrucje sifrarnika zadatog u definicijama
// -------------------------------------------------------------
FUNCTION F_KSif()
   RETURN F_Baze( cPIKSif )





// -------------------------------------------------------------
// selektuje bazu zadatu definicijom
// -------------------------------------------------------------
FUNCTION Sel_KSif()

   Sel_Bazu( cPIKSif )

   RETURN




// -------------------------------------------------------------
// vraca vrijednost polja iz tabele zadate definicijom
// -------------------------------------------------------------
FUNCTION IzKSif( cPolje )

   PRIVATE cPom := cPIKSif + "->" + cPolje

   RETURN ( &cPom )




// -------------------------------------------------------------
// otvara kumulativnu bazu zadatu u definicijama
// -------------------------------------------------------------
FUNCTION O_KBaza()

   LOCAL _area := F_KBAZA()

   SELECT ( _area )
   my_use( Lower( cPIKBaza ) )

   RETURN


// -------------------------------------------------------------
// vraca podrucje kumulativne baze
// -------------------------------------------------------------
FUNCTION F_KBaza()
   RETURN F_Baze( cPIKBaza )



// -------------------------------------------------------------
// selektuje kumulativnu bazu
// -------------------------------------------------------------
FUNCTION Sel_KBaza()

   Sel_Bazu( cPIKBaza )

   RETURN



// -------------------------------------------------------------
// vraca polje iz kumulativne tabele
// -------------------------------------------------------------
FUNCTION IzKBaza( cPolje )

   PRIVATE cPom := cPIKBaza + "->" + cPolje

   RETURN ( &cPom )




FUNCTION PripKBPI()

   IF cPIKSif != "BEZ"
      O_KSif()
   ENDIF

   SELECT IZVJE                    // u sifrarniku pozicioniramo se
   SET ORDER TO TAG "ID"

   SEEK cBrI                       // na trazeni izvjestaj
   IF !Empty( IZVJE->uslov )
      cFilter += ".and.(" + AllTrim( IZVJE->uslov ) + ")"
   ENDIF

   cFilter := CistiTacno( cFilter )

   O_KBaza()

   IF cPIKIndeks == "BEZ"
      SET ORDER TO
      SET FILTER TO
      SET FILTER TO &cFilter
   ELSEIF Upper( Left( cPIKIndeks, 3 ) ) == "TAG"
      SET ORDER TO TAG ( SubStr( cPIKIndeks, 4 ) )     // idkonto
      SET FILTER TO
      SET FILTER TO &cFilter
   ELSE
      INDEX ON &cPIKIndeks TO "KBTEMP" FOR &cFilter
   ENDIF

   RETURN




FUNCTION StTabPI()

   LOCAL nRed := 1
   LOCAL aKol := {}

   SELECT KOLIZ
   dbGoTop()

   DO WHILE !Eof()

      IF AllTrim( KOLIZ->formula ) == '"#"'
         ++nRed
      ELSE
         nRed := 1
      ENDIF

      cPom77 := "{|| " + KOLIZ->formula + " }"

      AAdd( aKol, { KOLIZ->naz, &cPom77., KOLIZ->sumirati == "D",;
         AllTrim( KOLIZ->tip ), KOLIZ->sirina, KOLIZ->decimale,;
         nRed, KOLIZ->rbr  } )
      SKIP 1
   ENDDO

   IF lIzrazi
      // potrebna dorada ka univerzalnosti (polje TEKSUMA ?)
      // ---------------------------------------------------
      SELECT POM
      SET ORDER TO TAG "3"

      nProlaz := 0
      DO WHILE .T.

         lJos := .F.

         ++nProlaz

         IF nProlaz > 10
            MsgBeep( "Greska! Rekurzija(samopozivanje) u formulama tipa '=STXXX+STYYY...'!" )
            EXIT
         ENDIF

         dbGoTop()
         DO WHILE !Eof()
            IF Left( uslov, 1 ) == "="
               PRIVATE lObradjen := .T.
               REPLACE POM->TEKSUMA WITH RacForm( uslov, "TEKSUMA" )
               IF lObradjen
                  REPLACE uslov WITH SubStr( uslov, 2 )
               ELSE
                  lJos := .T.
                  SKIP 1
                  LOOP
               ENDIF
            ENDIF

            IF !Empty( U1 )
               PRIVATE cPUTS
               cPUTS := "TEKSUMA" + Trim( U1 )  // U1 JE USLOV
               IF &cPUTS
                  uTekSuma := Abs( TEKSUMA )
               ELSE
                  uTekSuma := 0
               ENDIF
               REPLACE TEKSUMA WITH uTekSuma, ;
                  U1      WITH Space( Len( U1 ) )
            ENDIF

            SKIP 1
         ENDDO

         IF !lJos
            EXIT
         ENDIF

      ENDDO

   ENDIF

   SELECT POM
   SET ORDER TO
   dbGoTop()

   cPodvuci := " "
   IF cPrikBezDec == "D"
      gbFIznos := {| x, y, z| PreformIznos( x, y, z ) }
   ELSE
      gbFIznos := NIL
   ENDIF

   PRIVATE uTekSuma := 0

   print_lista_2( aKol, {|| FSvakiPI() },, gTabela,,,, {|| FForPI() }, IF( gOstr == "D",, -1 ),,,,, )

   IF nBrRedStr > -99
      gPO_Port()
      //dodatni_redovi_po_stranici() := nBrRedStr
   ENDIF

   EndPrint()

   RETURN .T.


FUNCTION StZagPI()

   LOCAL xKOT := 0

   StartPrint()

   SELECT ZAGLI
   SET FILTER TO
   SET FILTER TO id == cBrI
   SET ORDER TO TAG "1"

   dbGoTop()
   xKOT := PRow()
   DO WHILE !Eof()
      IF "GPO_LAND()" $ Upper( ZAGLI->izraz )
         nBrRedStr  := dodatni_redovi_po_stranici()
         //dodatni_redovi_po_stranici() := nKorZaLands
      ENDIF
      cPom77 := ZAGLI->izraz
      @ xKOT + ZAGLI->x1, ZAGLI->y1 SAY ""
      @ xKOT + ZAGLI->x1, ZAGLI->y1 SAY &cPom77
      SKIP 1
   ENDDO

   RETURN


STATIC FUNCTION prombroj()

   LOCAL i, cstbroj, cnbroj

   MsgBeep( "Nije jos implementirano ..." )

   RETURN




FUNCTION QOPodv( cT )

   ? cT
   ? REPL( "-", Len( cT ) )

   RETURN

FUNCTION DoHasha( cT )

   LOCAL n := At( "#", cT )

   RETURN IF( n = 0, cT, Left( cT, n - 1 ) )



FUNCTION CistiTacno( cFilter )

   LOCAL nT := 0, cSta := "", nZ := 0, nP := 0, cPom := ""

   cSta := "Tacno("
   nT := At( cSta, cFilter )
   IF nT > 0
      nZ := 1
      nP := nT + Len( cSta )
      DO WHILE nZ > 0
         cPom := SubStr( cFilter, nP, 1 )
         IF cPom == "("; ++nZ; ENDIF
         IF cPom == ")"; --nZ; ENDIF
         IF Len( cPom ) < 1; EXIT; ENDIF
         IF nZ > 0; ++nP; ENDIF
      ENDDO
      cSta := SubStr( cFilter, nT, nP - nT + 1 )
      cPom777 := SubStr( cSta, 7 ); cPom777 := Left( cPom777, Len( cPom777 ) -1 )
      cFilter := StrTran( cFilter, cSta, &cPom777 )
   ENDIF

   RETURN cFilter




FUNCTION OProizv()

   O_KOLIZ
   O_KONIZ
   O_ZAGLI
   O_IZVJE

   RETURN
