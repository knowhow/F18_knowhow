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


#include "kalk.ch"


// ---------------------------------------------------------------------
// centralna funkcija za azuriranje kalkulacije
// poziva raznorazne funkcije, generisanje dokumenata, provjere
// azuriranje u dbf, sql itd...
// ---------------------------------------------------------------------
FUNCTION azur_kalk( lAuto )

   LOCAL lViseDok := .F.
   LOCAL aRezim := {}
   LOCAL aOstaju := {}
   LOCAL lGenerisiZavisne := .F.
   LOCAL lBrStDoks := .F.

   IF ( lAuto == nil )
      lAuto := .F.
   ENDIF

   IF !lAuto .AND. Pitanje(, "Želite li izvrsiti ažuriranje KALK dokumenta (D/N) ?", "N" ) == "N"
      RETURN
   ENDIF

   O_KALK_PRIPR
   SELECT kalk_pripr
   GO TOP

   IF kalk_doc_exist( kalk_pripr->idfirma, kalk_pripr->idvd, kalk_pripr->brdok )
      MsgBeep( "Dokument " + kalk_pripr->idfirma + "-" + kalk_pripr->idvd + "-" + ;
         AllTrim( kalk_pripr->brdok ) + " vec postoji u bazi !#Promjenite broj dokumenta pa ponovite proceduru." )
      RETURN
   ENDIF

   SELECT kalk_pripr
   GO TOP

   // provjeri redne brojeve
   IF !provjeri_redni_broj()
      MsgBeep( "Redni brojevi dokumenta nisu ispravni !!!" )
      RETURN
   ENDIF

   // isprazni kalk_pripr2
   // trebat ce nam poslije radi generisanja zavisnih dokumenata
   O_KALK_PRIPR2
   my_dbf_zap()
   USE

   lViseDok := kalk_provjeri_duple_dokumente( @aRezim )

   // otvori potrebne tabele za azuriranje
   // parametar .t. je radi rasporeda troskova
   // to odradi samo jednom

   o_kalk_za_azuriranje( .T. )

   SELECT kalk_doks

   IF FieldPos( "ukstavki" ) <> 0
      lBrStDoks := .T.
   ENDIF

   // provjeri razne uslove, metode itd...
   IF gCijene == "2" .AND. !kalk_provjera_integriteta( @aOstaju, lViseDok )
      // nisu zadovoljeni uslovi, bjaži...
      RETURN
   ENDIF

   // provjeri vpc, itd...
   IF !kalk_provjera_cijena()
      // nisu zadovoljeni uslovi, bjaži....
      RETURN
   ENDIF

   // treba li generisati šta-god ?
   lGenerisiZavisne := kalk_generisati_zavisne_dokumente( lAuto )

   IF lGenerisiZavisne = .T.
      // generiši, 11-ke, 96-ce itd...
      kalk_zavisni_dokumenti()
   ENDIF

   // azuriraj kalk dokument !
   IF kalk_azur_sql()

      o_kalk_za_azuriranje()

      IF !kalk_azur_dbf( lAuto, lViseDok, aOstaju, aRezim, lBrStDoks )
         MsgBeep( "Neuspjesno KALK/DBF azuriranje !?" )
         RETURN
      ENDIF

   ELSE
      MsgBeep( "Neuspjesno KALK/SQL azuriranje !?" )
      RETURN
   ENDIF

   // pobrisi mi fakt_atribute takodjer
   F18_DOK_ATRIB():new( "kalk", F_KALK_ATRIB ):zapp_local_table()

   // generisi zavisne dokumente nakon azuriranja kalkulacije
   kalk_zavisni_nakon_azuriranja( lGenerisiZavisne, lAuto )

   // ostavi duple dokumente ili pobrisi pripemu
   IF lViseDok == .T. .AND. Len( aOstaju ) > 0
      kalk_ostavi_samo_duple( aOstaju )
   ELSE
      // pobrisi kalk_pripr
      SELECT kalk_pripr
      my_dbf_zap()

   ENDIF

   IF lGenerisiZavisne = .T.
      // vrati iz pripr2 dokumente, ako postoje !
      kalk_vrati_iz_pripr2()
   ENDIF

   my_close_all_dbf()

   RETURN



// ---------------------------------------------------------------------
// vraca iz tabele kalk_pripr2 sve sto je generisano
// da bi se moglo naknadno obraditi
// recimo kalk 16/96 itd...
// ---------------------------------------------------------------------
STATIC FUNCTION kalk_vrati_iz_pripr2()

   LOCAL lPrebaci := .F.
   LOCAL _rec

   O_KALK_PRIPR
   O_KALK_PRIPR2

   IF field->idvd $ "18#19"
      // otprema
      IF kalk_pripr2->( reccount2() ) <> 0
         Beep( 1 )
         Box(, 4, 70 )
         @ m_x + 1, m_y + 2 SAY "1. Cijene robe su promijenjene."
         @ m_x + 2, m_y + 2 SAY "2. Formiran je dokument nivelacije:" + kalk_pripr2->( idfirma + "-" + idvd + "-" + brdok )
         @ m_x + 3, m_y + 2 SAY "3. Nove cijene su stavljene u sifrarnik."
         @ m_x + 4, m_y + 2 SAY "3. Obradite ovaj dokument."
         Inkey( 0 )
         BoxC()
         lPrebaci := .T.
      ENDIF

   ELSEIF field->idvd $ "95"
      // otprema
      IF kalk_pripr2->( reccount2() ) <> 0
         Beep( 1 )
         Box(, 4, 70 )
         @ m_x + 1, m_y + 2 SAY "1. Formiran je dokument 95 na osnovu inventure."
         @ m_x + 4, m_y + 2 SAY "3. Obradite ovaj dokument."
         Inkey( 0 )
         BoxC()
         lPrebaci := .T.
      ENDIF

   ELSEIF field->idvd $ "16" .AND. gGen16 == "1"
      // nakon otpreme doprema
      IF kalk_pripr2->( reccount2() ) <> 0
         Beep( 1 )
         Box(, 4, 70 )
         @ m_x + 1, m_y + 2 SAY "1. Roba je otpremljena u magacin " + kalk_pripr2->idkonto
         @ m_x + 2, m_y + 2 SAY "2. Formiran je dokument dopreme:" + kalk_pripr2->( idfirma + "-" + idvd + "-" + brdok )
         @ m_x + 3, m_y + 2 SAY "3. Obradite ovaj dokument."
         Inkey( 0 )
         BoxC()
         lPrebaci := .T.
      ENDIF

   ELSEIF field->idvd $ "11"
      // nakon povrata unos u drugu prodavnicu
      IF kalk_pripr2->( reccount2() ) <> 0
         Beep( 1 )
         Box(, 4, 70 )
         @ m_x + 1, m_y + 2 SAY "1. Roba je prenesena u prodavnicu " + kalk_pripr2->idkonto
         @ m_x + 2, m_y + 2 SAY "2. Formiran je dokument zaduzenja:" + kalk_pripr2->( idfirma + "-" + idvd + "-" + brdok )
         @ m_x + 3, m_y + 2 SAY "3. Obradite ovaj dokument."
         Inkey( 0 )
         BoxC()
         lPrebaci := .T.
      ENDIF
   ENDIF

   IF lPrebaci == .T.

      SELECT kalk_pripr2
      DO WHILE !Eof()

         _rec := dbf_get_rec()
         SELECT kalk_pripr
         APPEND BLANK
         dbf_update_rec( _rec )
         SELECT kalk_pripr2
         SKIP

      ENDDO

      SELECT kalk_pripr2
      my_dbf_zap()

   ENDIF

   RETURN


// ------------------------------------------------------------------------
// generisanje zavisnih dokumenata nakon azuriranja kalkulacije
// mozda cemo dobiti i nove dokumente u pripremi
// ------------------------------------------------------------------------
STATIC FUNCTION kalk_zavisni_nakon_azuriranja( lGenerisi, lAuto )

   LOCAL lForm11 := .F.
   LOCAL cNext11 := ""
   LOCAL cOdg := "D"
   LOCAL lgAFin := gAFin
   LOCAL lgAMat := gAMat

   o_kalk_za_azuriranje()

   // generisanje 11-ke iz 10-ke
   IF Generisati11_ku()
      lForm11 := .T.
      cNext11 := SljBrKalk( "11", gFirma )
      Generisi11ku_iz10ke( cNext11 )
   ENDIF

   SELECT KALK

   IF lGenerisi = .T.

      RekapK()

      IF ( gaFin == "D" .OR. gaMat == "D" )
         IF kalk_kontiranje_naloga( .T., lAuto )
            fin_nalog_priprema_kalk( lAuto )
         ENDIF
      ENDIF

      gAFin := lgAFin
      gAMat := lgAMat

      O_KALK_PRIPR

      IF field->idvd $ "10#12#13#16#11#95#96#97#PR#RN" .AND. gAFakt == "D"

         IF field->idvd $ "16#96"
            cOdg := "N"
         ENDIF

         IF Pitanje(, "Formirati dokument u FAKT ?", cOdg ) == "D"

            P_Fakt()
            o_kalk_za_azuriranje()

         ENDIF

      ENDIF

   ENDIF

   // 11-ku obradi iz smeca
   IF lForm11 == .T.
      Get11FromSmece( cNext11 )
   ENDIF

   RETURN


// ----------------------------------------------------------------
// ova opcija ce pobrisati iz pripreme samo one dokumente koji
// postoje medju azuriranim
// ----------------------------------------------------------------
STATIC FUNCTION kalk_ostavi_samo_duple( lViseDok, aOstaju )

   // izbrisi samo azurirane
   SELECT kalk_pripr

   GO TOP
   my_flock()
   DO WHILE !Eof()
      SKIP 1
      nRecNo := RecNo()
      SKIP -1
      IF AScan( aOstaju, field->idfirma + field->idvd + field->brdok ) = 0
         DELETE
      ENDIF
      GO ( nRecNo )
   ENDDO
   my_unlock()
   my_dbf_pack()

   MsgBeep( "U kalk_pripremi su ostali dokumenti koji izgleda da vec postoje medju azuriranim!" )

   RETURN



// -------------------------------------------------------
// treba li generisati dokumente ?
// -------------------------------------------------------
STATIC FUNCTION kalk_generisati_zavisne_dokumente( lAuto )

   LOCAL lGen := .F.

   IF gCijene == "2"
      lGen := .T.
   ELSE
      IF gMetodaNC == " "
         lGen := .F.
      ELSEIF lAuto == .T.
         lGen := .T.
      ELSE
         lGen := Pitanje(, "Želite li formirati zavisne dokumente pri ažuriranju", "D" ) == "D"
      ENDIF
   ENDIF

   RETURN lGen



// ---------------------------------------------------------
// generisanje zavisnih dokumenata
// prije azuriranja kalkulacije u dbf i sql
// ---------------------------------------------------------
STATIC FUNCTION kalk_zavisni_dokumenti()

   IF !( IsMagPNab() .OR. IsMagSNab() )
      // ako nije slucaj da je
      // 1. pdv rezim magacin po nabavnim cijenama
      // ili
      // 2. magacin samo po nabavnim cijenama

      // nivelacija 10,94,16
      Niv_10()
   ENDIF

   Niv_11()
   // nivelacija 11,81

   Otprema()
   // iz otpreme napravi ulaza
   Iz13u11()
   // prenos iz prodavnice u prodavnicu

   // inventura magacina - manjak / visak
   InvManj()

   RETURN



// ----------------------------------------------------------------------------
// azuriranje podataka u dbf
// ----------------------------------------------------------------------------
STATIC FUNCTION kalk_azur_dbf( lAuto, lViseDok, aOstaju, aRezim, lBrStDoks )

   LOCAL cIdFirma, _rec
   LOCAL cIdVd
   LOCAL cBrDok
   LOCAL cNPodBr
   LOCAL nNv := 0
   LOCAL nVpv := 0
   LOCAL nMpv := 0
   LOCAL nRabat := 0
   LOCAL cOpis
   LOCAL nBrStavki

   Tone( 360, 2 )

   MsgO( "Azuriram pripremu u DBF tabele..." )

   SELECT kalk_pripr
   GO TOP

   cIdFirma := field->idfirma

   SELECT kalk_doks
   SET ORDER TO TAG "3"
   SEEK cIdfirma + DToS( kalk_pripr->datdok ) + Chr( 255 )
   SKIP -1

   IF field->datdok == kalk_pripr->datdok
      IF  kalk_pripr->idvd $ "18#19" .AND. kalk_pripr->TBankTr == "X"
         // rijec je o izgenerisanom dokumentu
         IF Len( field->podbr ) > 1
            cNPodbr := chr256( asc256( field->podbr ) -3 )
         ELSE
            cNPodbr := Chr( Asc( field->podbr ) -3 )
         ENDIF
      ELSE
         IF Len( field->podbr ) > 1
            cNPodbr := chr256( asc256( field->podbr ) + 6 )
         ELSE
            cNPodbr := Chr( Asc( field->podbr ) + 6 )
         ENDIF
      ENDIF
   ELSE
      IF Len( field->podbr ) > 1
         cNPodbr := chr256( 30 * 256 + 30 )
      ELSE
         cNPodbr := Chr( 30 )
      ENDIF
   ENDIF

   SELECT kalk_pripr
   GO TOP

   DO WHILE !Eof()

      cIdFirma := field->idfirma
      cBrDok := field->brdok
      cIdvd := field->idvd

      IF lViseDok .AND. AScan( aOstaju, cIdFirma + cIdVd + cBrDok ) <> 0
         // preskoci postojece
         SKIP 1
         LOOP
      ENDIF

      // azuriranje tabele KALK_DOKS.DBF

      SELECT kalk_doks
      APPEND BLANK

      _rec := dbf_get_rec()
      _rec[ "idfirma" ] := cIdFirma
      _rec[ "idvd" ] := cIdVd
      _rec[ "brdok" ] := cBrDok
      _rec[ "datdok" ] := kalk_pripr->datdok
      _rec[ "idpartner" ] := kalk_pripr->idpartner
      _rec[ "mkonto" ] := kalk_pripr->mkonto
      _rec[ "pkonto" ] := kalk_pripr->pkonto
      _rec[ "idzaduz" ] := kalk_pripr->idzaduz
      _rec[ "idzaduz2" ] := kalk_pripr->idzaduz2
      _rec[ "brfaktp" ] := kalk_pripr->brfaktp

      dbf_update_rec( _rec, .T. )

      IF Logirati( goModul:oDataBase:cName, "DOK", "AZUR" )

         cOpis := cIDFirma + "-" + cIdVd + "-" + AllTrim( cBrDok )

         EventLog( nUser, goModul:oDataBase:cName, "DOK", "AZUR", nil, nil, nil, nil, cOpis, "", "", kalk_pripr->datdok, Date(), "", "Azuriranje dokumenta" )

      ENDIF

      // azuriranje tabele KALK_KALK.DBF

      SELECT kalk_pripr
      GO TOP

      nBrStavki := 0

      DO WHILE !Eof() .AND. cIdfirma == field->idfirma .AND. cBrdok == field->brdok .AND. cIdvd == field->idvd

         ++ nBrStavki
         _rec := dbf_get_rec()
         _rec[ "podbr" ] := cNPodbr

         SELECT kalk
         APPEND BLANK

         dbf_update_rec( _rec, .T. )

         IF cIdVd == "97"

            _rec := dbf_get_rec()
            APPEND BLANK

            _rec[ "tbanktr" ] := "X"
            _rec[ "mkonto" ] := _idkonto
            _rec[ "mu_i" ] := "1"
            _rec[ "rbr" ] := PadL( Str( 900 + Val( AllTrim( _rbr ) ), 3 ), 3 )

            dbf_update_rec( _rec, .T. )

         ENDIF

         SELECT kalk_pripr

         IF !( cIdVd $ "97" )
            // setuj nnv, nmpv ....
            kalk_set_doks_total_fields( @nNv, @nVpv, @nMpv, @nRabat )
         ENDIF

         SKIP

      ENDDO

      SELECT kalk_doks

      _rec := dbf_get_rec()

      _rec[ "nv" ] := nNv
      _rec[ "vpv" ] := nVpv
      _rec[ "rabat" ] := nRabat
      _rec[ "mpv" ] := nMpv
      _rec[ "podbr" ] := cNPodBr

      IF lBrStDoks
         _rec[ "ukstavki" ] := nBrStavki
      ENDIF

      dbf_update_rec( _rec, .T. )

      SELECT kalk_pripr

   ENDDO

   MsgC()

   RETURN .T.



STATIC FUNCTION kalk_provjera_cijena()

   LOCAL cIdFirma
   LOCAL cIdVd
   LOCAL cBrDok

   O_KALK_PRIPR

   SELECT kalk_pripr
   GO TOP

   DO WHILE !Eof()

      cIdFirma := field->idfirma
      cIdVd := field->idvd
      cBrDok := field->brdok

      DO WHILE !Eof() .AND. cIdfirma == field->idfirma .AND. cIdvd == field->idvd .AND. cBrdok == field->brdok
         IF field->idvd == "11" .AND. field->vpc == 0
            Beep( 1 )
            Msg( 'VPC = 0, pozovite "savjetnika" sa <Alt-H>!' )
            my_close_all_dbf()
            RETURN .F.
         ENDIF
         SKIP
      ENDDO

      SELECT kalk_pripr

   ENDDO

   RETURN .T.


// ------------------------------------------------------------
// ------------------------------------------------------------
STATIC FUNCTION kalk_provjera_integriteta( aDoks, lViseDok )

   LOCAL nBrDoks
   LOCAL cIdFirma
   LOCAL cIdVd
   LOCAL cBrDok
   LOCAL dDatDok
   LOCAL cIdZaduz2

   o_kalk_za_azuriranje()

   SELECT kalk_pripr
   GO TOP

   nBrDoks := 0

   DO WHILE !Eof()

      ++ nBrDoks

      cIdFirma := field->idfirma
      cIdVd := field->idvd
      cBrDok := field->brdok
      dDatDok := field->datdok
      cIdzaduz2 := field->idzaduz2

      DO WHILE !Eof() .AND. cIdFirma == field->idfirma .AND. cIdVd == field->idvd .AND. cBrdok == field->brdok

         IF gMetodaNC <> " " .AND. ( field->error == "1" .AND. field->tbanktr == "X" )
            Beep( 2 )
            MSG( "Izgenerisane stavke su ispravljane, azuriranje nece biti izvrseno", 6 )
            my_close_all_dbf()
            RETURN .F.
         ENDIF

         IF gMetodaNC <> " " .AND. field->error == "1"
            Beep( 2 )
            MSG( "Utvrdjena greska pri obradi dokumenta, rbr: " + rbr, 6 )
            my_close_all_dbf()
            RETURN .F.
         ENDIF

         IF gMetodaNC <> " " .AND. field->error == " "
            Beep( 2 )
            MSG( "Dokument je izgenerisan, pokrenuti opciju <A> za obradu", 6 )
            my_close_all_dbf()
            RETURN .F.
         ENDIF
         IF dDatDok <> field->datdok
            Beep( 2 )
            IF Pitanje(, "Datum razlicit u odnosu na prvu stavku. Ispraviti ?", "D" ) == "D"
               RREPLACE field->datdok WITH dDatDok
            ELSE
               my_close_all_dbf()
               RETURN .F.
            ENDIF
         ENDIF

         IF field->idvd <> "24" .AND. Empty( field->mu_i ) .AND. Empty( field->pu_i )
            Beep( 2 )
            Msg( "Stavka broj " + field->rbr + ". neobradjena , sa <A> pokrenite obradu" )
            my_close_all_dbf()
            RETURN .F.
         ENDIF

         IF cIdzaduz2 <> field->idzaduz2
            Beep( 2 )
            Msg( "Stavka broj " + field->rbr + ". razlicito polje RN u odnosu na prvu stavku" )
            my_close_all_dbf()
            RETURN .F.
         ENDIF

         SKIP

      ENDDO

      SELECT kalk
      SEEK cIdFirma + cIdVD + cBrDok

      IF Found()
         Beep( 1 )
         Msg( "Vec postoji dokument pod brojem " + cIdFirma + "-" + cIdvd + "-" + AllTrim( cBrDok ) )
         IF !lViseDok
            my_close_all_dbf()
            RETURN .F.
         ELSE
            AAdd( aDoks, cIdFirma + cIdVd + cBrDok )
         ENDIF
      ENDIF

      SELECT kalk_pripr

   ENDDO

   IF gMetodaNC <> " " .AND. nBrDoks > 1
      Beep( 1 )
      Msg( "U kalk_pripremi je vise dokumenata.Prebaci ih u smece, pa obradi pojedinacno" )
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   my_close_all_dbf()

   RETURN .T.



// provjerava da li u pripremi postoji vise dokumeata
STATIC FUNCTION kalk_provjeri_duple_dokumente( aRezim )

   LOCAL lViseDok := .F.

   O_KALK_PRIPR
   GO BOTTOM

   cTest := field->idfirma + field->idvd + field->brdok

   GO TOP

   IF cTest <> field->idfirma + field->idvd + field->brdok
      Beep( 1 )
      Msg( "U kalk_pripremi je vise dokumenata! Ukoliko zelite da ih azurirate sve#" + ;
         "odjednom (npr.ako ste ih preuzeli sa drugog racunara putem diskete)#" + ;
         "na sljedece pitanje odgovorite sa 'D' i dokumenti ce biti azurirani#" + ;
         "bez provjera koje se vrse pri redovnoj obradi podataka." )
      IF Pitanje(, "Zelite li bezuslovno dokumente azurirati? (D/N)", "N" ) == "D"

         lViseDok := .T.
         aRezim := {}

         AAdd( aRezim, gCijene )
         AAdd( aRezim, gMetodaNC )
         gCijene   := "1"
         gMetodaNC := " "
      ENDIF

   ELSEIF gCijene == "2"
      // ako je samo jedan dokument u kalk_pripremi

      DO WHILE !Eof()
         // i strogi rezim rada
         IF ERROR == "1"
            Beep( 1 )
            Msg( "Program je kontrolisuci redom stavke utvrdio da je stavka#" + ;
               "br." + rbr + " sumnjiva! Ukoliko bez obzira na to zelite da izvrsite#" + ;
               "azuriranje ovog dokumenta, na sljedece pitanje odgovorite#" + ;
               "sa 'D'." )
            IF Pitanje(, "Zelite li dokument azurirati bez obzira na upozorenje? (D/N)", "N" ) == "D"
               aRezim := {}
               AAdd( aRezim, gCijene )
               AAdd( aRezim, gMetodaNC )
               gCijene   := "1"
            ENDIF
            EXIT
         ENDIF
         SKIP 1
      ENDDO

   ENDIF

   RETURN lViseDok



// -------------------------------------------------
// otvori tabele za azuriranje
// -------------------------------------------------
STATIC FUNCTION o_kalk_za_azuriranje( raspored_tr )

   IF raspored_tr == NIL
      raspored_tr := .F.
   ENDIF

   // prvo zatvori sve tabele
   my_close_all_dbf()

   O_KALK_PRIPR
   O_KALK
   O_KALK_DOKS2
   O_KALK_DOKS

   // vidi treba li rasporediti troskove
   IF raspored_tr
      _raspored_troskova()
   ENDIF

   RETURN


// ----------------------------------------------------------------
// raspored troskova
// ----------------------------------------------------------------
STATIC FUNCTION _raspored_troskova()

   SELECT kalk_pripr

   IF ( ( field->tprevoz == "R" .OR. field->TCarDaz == "R" .OR. field->TBankTr == "R" .OR. ;
         field->TSpedTr == "R" .OR. field->TZavTr == "R" ) .AND. field->idvd $ "10#81" )  .OR. ;
         field->idvd $ "RN"

      O_SIFK
      O_SIFV
      O_ROBA
      O_TARIFA
      O_KONCIJ

      SELECT kalk_pripr
      RaspTrosk( .T. )

   ENDIF

   RETURN




// ----------------------
// ----------------------
STATIC FUNCTION kalk_azur_sql()

   LOCAL _ok := .T.
   LOCAL _record := hb_Hash()
   LOCAL _doks_nv := 0
   LOCAL _doks_vpv := 0
   LOCAL _doks_mpv := 0
   LOCAL _doks_rabat := 0
   LOCAL _tbl_kalk
   LOCAL _tbl_doks
   LOCAL _i, _n
   LOCAL _tmp_id
   LOCAL _ids := {}
   LOCAL _ids_kalk := {}
   LOCAL _ids_doks := {}
   LOCAL _log_dok
   LOCAL oAtrib

   _tbl_kalk := "kalk_kalk"
   _tbl_doks := "kalk_doks"

   Box(, 5, 60 )

   _tmp_id := "x"

   // otvori tabele
   o_kalk_za_azuriranje()

   IF !f18_lock_tables( { _tbl_kalk, _tbl_doks } )
      MsgBeep( "lock tabela neuspjesan, azuriranje prekinuto" )
      RETURN .F.
   ENDIF

   // end lock semaphores --------------------------------------------------

   sql_table_update( nil, "BEGIN" )

   SELECT kalk_pripr
   GO TOP

   _record := dbf_get_rec()
   // algoritam 2 - dokument nivo
   _tmp_id := _record[ "idfirma" ] + _record[ "idvd" ] + _record[ "brdok" ]
   AAdd( _ids_kalk, "#2" + _tmp_id )

   _log_dok := _record[ "idfirma" ] + "-" + _record[ "idvd" ] + "-" + _record[ "brdok" ]

   @ m_x + 1, m_y + 2 SAY "kalk_kalk -> server: " + _tmp_id

   DO WHILE !Eof()

      // setuj total varijable za upisivanje u tabelu doks
      kalk_set_doks_total_fields( @_doks_nv, @_doks_vpv, @_doks_mpv, @_doks_rabat )

      _record := dbf_get_rec()

      IF !sql_table_update( "kalk_kalk", "ins", _record )
         _ok := .F.
         EXIT
      ENDIF

      IF _record[ "idvd" ] == "97"

         // dodaj zapis za 97-cu
         _record[ "tbanktr" ] := "X"
         _record[ "mkonto" ] := _record[ "idkonto" ]
         _record[ "mu_i" ] := "1"
         _record[ "rbr" ] := PadL( Str( 900 + Val( AllTrim( _record[ "rbr" ] ) ), 3 ), 3 )

         IF !sql_table_update( "kalk_kalk", "ins", _record )
            _ok := .F.
            EXIT
         ENDIF

      ENDIF

      SKIP

   ENDDO

   IF _ok = .T.

      // ubaci zapis u tabelu doks
      SELECT kalk_pripr
      GO TOP

      _record := hb_Hash()

      _record[ "idfirma" ] := field->idfirma
      _record[ "idvd" ] := field->idvd
      _record[ "brdok" ] := field->brdok
      _record[ "datdok" ] := field->datdok
      _record[ "brfaktp" ] := field->brfaktp
      _record[ "idpartner" ] := field->idpartner
      _record[ "idzaduz" ] := field->idzaduz
      _record[ "idzaduz2" ] := field->idzaduz2
      _record[ "pkonto" ] := field->pkonto
      _record[ "mkonto" ] := field->mkonto
      _record[ "nv" ] := _doks_nv
      _record[ "vpv" ] := _doks_vpv
      _record[ "rabat" ] := _doks_rabat
      _record[ "mpv" ] := _doks_mpv
      _record[ "podbr" ] := field->podbr
      _record[ "sifra" ] := Space( 6 )

      // za ids-ove
      _tmp_id := _record[ "idfirma" ] + _record[ "idvd" ] + _record[ "brdok" ]
      AAdd( _ids_doks, _tmp_id )

      @ m_x + 2, m_y + 2 SAY "kalk_doks -> server: " + _tmp_id

      IF !sql_table_update( "kalk_doks", "ins", _record )
         _ok := .F.
      ENDIF

   ENDIF

   IF _ok == .T.

      @ m_x + 3, m_y + 2 SAY "kalk_atributi -> server "

      oAtrib := F18_DOK_ATRIB():new( "kalk", F_KALK_ATRIB )
      oAtrib:dok_hash[ "idfirma" ] := _record[ "idfirma" ]
      oAtrib:dok_hash[ "idtipdok" ] := _record[ "idvd" ]
      oAtrib:dok_hash[ "brdok" ] := _record[ "brdok" ]

      _ok := oAtrib:atrib_dbf_to_server()

   ENDIF


   IF !_ok

      _msg := "kalk azuriranje, trasakcija " + _tmp_id + " neuspjesna ?!"

      log_write( _msg, 2 )
      MsgBeep( _msg )
      // transakcija neuspjesna
      // server nije azuriran
      sql_table_update( nil, "ROLLBACK" )
      f18_free_tables( { _tbl_kalk, _tbl_doks } )

   ELSE

      @ m_x + 4, m_y + 2 SAY "push ids to semaphore"
      push_ids_to_semaphore( _tbl_kalk, _ids_kalk )
      push_ids_to_semaphore( _tbl_doks, _ids_doks  )

      // kalk
      @ m_x + 5, m_y + 2 SAY "update semaphore version"

      f18_free_tables( { _tbl_kalk, _tbl_doks } )
      sql_table_update( nil, "END" )

      // logiraj operaciju
      log_write( "F18_DOK_OPER: azuriranje kalk dokumenta: " + _log_dok, 2 )

   ENDIF

   BoxC()

   RETURN _ok



// -----------------------------------------------------------
// napuni matricu sa podacima pripreme
// -----------------------------------------------------------
STATIC FUNCTION _pripr_2_arr()

   LOCAL _arr := {}
   LOCAL _scan

   SELECT kalk_pripr
   GO TOP

   DO WHILE !Eof()

      _scan := AScan( _arr, {| var | VAR[ 1 ] == field->idfirma .AND. ;
         VAR[ 2 ] == field->idvd .AND. ;
         VAR[ 3 ] == field->brdok  } )

      IF _scan == 0
         AAdd( _arr, { field->idfirma, field->idvd, field->brdok, 0 } )
      ENDIF

      SKIP

   ENDDO

   RETURN _arr


// ----------------------------------------------------------
// provjeri da li već postoje dokumenti u smeću
// ----------------------------------------------------------
STATIC FUNCTION _provjeri_smece( arr )

   LOCAL _i
   LOCAL _ctrl

   FOR _i := 1 TO Len( arr )

      _ctrl := arr[ _i, 1 ] + arr[ _i, 2 ] + arr[ _i, 3 ]

      SELECT kalk_pripr9
      SEEK _ctrl

      IF Found()
         // setuj u matrici da ovaj dokument postoji
         arr[ _i, 4 ] := 1
      ENDIF

   NEXT

   RETURN




// ------------------------------------------------------------
// azuriranje kalk_pripr9 tabele
// koristi se za smece u vecini slucajeva
// ------------------------------------------------------------
FUNCTION azur_kalk_pripr9()

   LOCAL lGen := .F.
   LOCAL cPametno := "D"
   LOCAL cIdFirma
   LOCAL cIdvd
   LOCAL cBrDok
   LOCAL _a_pripr
   LOCAL _i, _rec, _scan
   LOCAL _id_firma, _id_vd, _br_dok

   O_KALK_PRIPR9
   O_KALK_PRIPR

   SELECT kalk_pripr
   GO TOP

   IF kalk_pripr->( RecCount() ) == 0
      RETURN
   ENDIF

   IF Pitanje( "p1", "Zelite li pripremu prebaciti u smece (D/N) ?", "N" ) == "N"
      RETURN
   ENDIF

   // prebaci iz pripreme dokumente u matricu
   _a_pripr := _pripr_2_arr()

   // usaglasi dokumente sa smecem
   // da li vec neki dokumenti postoje
   _provjeri_smece( @_a_pripr )

   // sada imamo stanje sta treba prenjeti a sta ne...

   SELECT kalk_pripr
   GO TOP

   DO WHILE !Eof()

      _scan := AScan( _a_pripr, {|var| VAR[ 1 ] == field->idfirma .AND. ;
         VAR[ 2 ] == field->idvd .AND. ;
         VAR[ 3 ] == field->brdok } )

      IF _scan > 0 .AND. _a_pripr[ _scan, 4 ] == 0

         // treba ga prebaciti !
         _id_firma := field->idfirma
         _id_vd := field->idvd
         _br_dok := field->brdok

         DO WHILE !Eof() .AND. field->idfirma + field->idvd + field->brdok == _id_firma + _id_vd + _br_dok

            _rec := dbf_get_rec()

            SELECT kalk_pripr9
            APPEND BLANK

            dbf_update_rec( _rec )

            SELECT kalk_pripr
            SKIP

         ENDDO

         log_write( "F18_DOK_OPER: kalk, prenos dokumenta iz pripreme u smece: " + _id_firma + "-" + _id_vd + "-" + _br_dok, 2 )

      ENDIF

   ENDDO

   SELECT kalk_pripr
   my_dbf_zap()

   my_close_all_dbf()

   RETURN



// -------------------------------------------------------
// povrat kalkulacije u tabelu pripreme
// -------------------------------------------------------
FUNCTION povrat_kalk_dokumenta()

   LOCAL _brisi_kum
   LOCAL _rec
   LOCAL _id_firma
   LOCAL _id_vd
   LOCAL _br_dok
   LOCAL _del_rec, _ok
   LOCAL _t_rec
   LOCAL _dok_hash, oAtrib

   _brisi_kum := .F.

   IF gCijene == "2" .AND. Pitanje(, "Zadati broj (D) / Povrat po hronologiji obrade (N) ?", "D" ) = "N"
      Beep( 1 )
      PNajn()
      my_close_all_dbf()
      RETURN
   ENDIF

   O_KALK_DOKS
   O_KALK_DOKS2
   O_KALK
   SET ORDER TO TAG "1"

   O_KALK_PRIPR

   SELECT KALK
   SET ORDER TO TAG "1"

   _id_firma := gfirma
   _id_vd := Space( 2 )
   _br_dok := Space( 8 )

   Box( "", 1, 35 )
   @ m_x + 1, m_y + 2 SAY "Dokument:"
   IF gNW $ "DX"
      @ m_x + 1, Col() + 1 SAY _id_firma
   ELSE
      @ m_x + 1, Col() + 1 GET _id_firma
   ENDIF
   @ m_x + 1, Col() + 1 SAY "-" GET _id_vd PICT "@!"
   @ m_x + 1, Col() + 1 SAY "-" GET _br_dok
   READ
   ESC_BCR
   BoxC()

   // ako je uslov sa tackom, vrati sve nabrojane u pripremu...
   IF _br_dok = "."
      povrat_vise_dokumenata()
      my_close_all_dbf()
      RETURN
   ENDIF

   IF Pitanje( "", "Kalk. " + _id_firma + "-" + _id_vd + "-" + _br_dok + " povuci u pripremu (D/N) ?", "D" ) == "N"
      my_close_all_dbf()
      RETURN
   ENDIF

   _brisi_kum := Pitanje(, "Izbrisati dokument iz kumulativne tabele ?", "D" ) == "D"

   SELECT kalk
   hseek _id_firma + _id_vd + _br_dok

   EOF CRET

   MsgO( "Prebacujem u pripremu..." )

   DO WHILE !Eof() .AND. _id_firma == field->IdFirma .AND. _id_vd == field->IdVD .AND. _br_dok == field->BrDok

      SELECT kalk
      _rec := dbf_get_rec()
      SELECT kalk_pripr

      IF ! ( _rec[ "idvd" ] $ "97" .AND. _rec[ "tbanktr" ] == "X" )
         APPEND ncnl
         _rec[ "error" ] := ""
         dbf_update_rec( _rec )
      ENDIF

      SELECT kalk
      SKIP

   ENDDO

   MsgC()

   // kalk atributi....
   _dok_hash := hb_Hash()
   _dok_hash[ "idfirma" ] := _id_firma
   _dok_hash[ "idtipdok" ] := _id_vd
   _dok_hash[ "brdok" ] := _br_dok

   oAtrib := F18_DOK_ATRIB():new( "kalk", F_KALK_ATRIB )
   oAtrib:dok_hash := _dok_hash
   oAtrib:atrib_server_to_dbf()


   IF _brisi_kum

      IF !f18_lock_tables( { "kalk_doks", "kalk_kalk", "kalk_doks2" } )
         MsgBeep( "ne mogu lockovati kalk tabele ?!" )
         RETURN .F.
      ELSE
         o_kalk_za_azuriranje()
      ENDIF

      MsgO( "Brisem dokument iz KALK-a" )

      sql_table_update( nil, "BEGIN" )

      SELECT kalk
      hseek _id_firma + _id_vd + _br_dok

      IF Found()

         log_write( "F18_DOK_OPER: kalk povrat dokumenta: " + _id_firma + "-" + _id_vd + "-" + _br_dok, 2 )

         _del_rec := dbf_get_rec()

         _ok := .T.

         // pobrisi atribute ih sa servera...
         _ok := _ok .AND.  oAtrib:delete_atrib_from_server()

         _ok := delete_rec_server_and_dbf( "kalk_kalk", _del_rec, 2, "CONT" )

         SELECT kalk_doks
         hseek _id_firma + _id_vd + _br_dok

         IF Found()

            _del_rec := dbf_get_rec()
            _ok := .T.
            _ok := delete_rec_server_and_dbf( "kalk_doks", _del_rec, 1, "CONT" )

         ENDIF

         SELECT kalk_doks2
         hseek _id_firma + _id_vd + _br_dok

         IF Found()

            _del_rec := dbf_get_rec()
            _ok := .T.
            _ok := delete_rec_server_and_dbf( "kalk_doks2", _del_rec, 1, "CONT" )

         ENDIF

      ENDIF

      MsgC()

      IF _ok
         f18_free_tables( { "kalk_doks", "kalk_kalk", "kalk_doks2" } )
         sql_table_update( nil, "END" )
      ELSE

         sql_table_update( nil, "ROLLBACK" )
         f18_free_tables( { "kalk_doks", "kalk_kalk", "kalk_doks2" } )

         msgbeep( "Brisanje KALK dokumenta neuspjesno !?" )
         my_close_all_dbf()
         RETURN
      ENDIF

   ENDIF

   SELECT kalk_doks
   USE

   SELECT kalk
   USE

   my_close_all_dbf()

   RETURN


// -----------------------------------------------------
// povrat vise dokumenata od jednom...
// -----------------------------------------------------
STATIC FUNCTION povrat_vise_dokumenata()

   LOCAL _br_dok := Space( 80 )
   LOCAL _dat_dok := Space( 80 )
   LOCAL _id_vd := Space( 80 )
   LOCAL _usl_br_dok
   LOCAL _usl_dat_dok
   LOCAL _usl_id_vd
   LOCAL _brisi_kum := .F.
   LOCAL _filter
   LOCAL _id_firma := gFirma
   LOCAL _rec
   LOCAL _del_rec, _ok
   LOCAL _dok_hash, oAtrib, __firma, __idvd, __brdok

   IF !SigmaSif()
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   Box(, 3, 60 )
   DO WHILE .T.
      @ m_x + 1, m_y + 2 SAY "Vrste kalk.    " GET _id_vd PICT "@S40"
      @ m_x + 2, m_y + 2 SAY "Broj dokumenata" GET _br_dok PICT "@S40"
      @ m_x + 3, m_y + 2 SAY "Datumi         " GET _dat_dok PICT "@S40"
      READ
      _usl_br_dok := Parsiraj( _br_dok, "BrDok", "C" )
      _usl_dat_dok := Parsiraj( _dat_dok, "DatDok", "D" )
      _usl_id_vd := Parsiraj( _id_vd, "IdVD", "C" )
      IF _usl_br_dok <> NIL .AND. _usl_dat_dok <> NIL .AND. _usl_id_vd <> NIL
         EXIT
      ENDIF
   ENDDO
   Boxc()

   IF Pitanje(, "Povuci u pripremu kalk sa ovim kriterijom ?", "N" ) == "D"

      _brisi_kum := Pitanje(, "Izbrisati dokument iz kumulativne tabele ?", "D" ) == "D"

      SELECT kalk

      _filter := "IDFIRMA==" + cm2str( _id_firma ) + ".and." + _usl_br_dok + ".and." + _usl_id_vd + ".and." + _usl_dat_dok
      _filter := StrTran( _filter, ".t..and.", "" )

      IF !( _filter == ".t." )
         SET FILTER TO &( _filter )
      ENDIF

      SELECT kalk
      GO TOP

      MsgO( "Prolaz kroz kumulativnu datoteku KALK..." )

      // vrati prvo dokumente u pripremu...
      DO WHILE !Eof()

         SELECT kalk

         __firma := field->idfirma
         __idvd := field->idvd
         __brdok := field->brdok

         _rec := dbf_get_rec()

         SELECT kalk_pripr

         IF ! ( _rec[ "idvd" ] $ "97" .AND. _rec[ "tbanktr" ] == "X" )

            APPEND ncnl
            _rec[ "error" ] := ""
            dbf_update_rec( _rec )

            // kalk atributi....
            _dok_hash := hb_Hash()
            _dok_hash[ "idfirma" ] := __firma
            _dok_hash[ "idtipdok" ] := __idvd
            _dok_hash[ "brdok" ] := __brdok

            oAtrib := F18_DOK_ATRIB():new( "kalk", F_KALK_ATRIB )
            oAtrib:dok_hash := _dok_hash
            oAtrib:atrib_server_to_dbf()

         ENDIF

         SELECT kalk
         SKIP

      ENDDO

      MsgC()

      SELECT kalk
      SET ORDER TO TAG "1"
      GO TOP

      // ako ne treba brisati kumulativ
      IF !_brisi_kum
         my_close_all_dbf()
         RETURN .F.
      ENDIF

      MsgO( "update server kalk" )

      IF !f18_lock_tables( { "kalk_doks", "kalk_kalk", "kalk_doks2" } )
         RETURN .F.
      ENDIF

      sql_table_update( nil, "BEGIN" )

      // idemo sada na brisanje dokumenata
      DO WHILE !Eof()

         _id_firma := field->idfirma
         _id_vd := field->idvd
         _br_dok := field->brdok

         _del_rec := dbf_get_rec()

         // prodji kroz dokument do kraja...
         DO WHILE !Eof() .AND. field->idfirma == _id_firma .AND. field->idvd == _id_vd .AND. field->brdok == _br_dok
            SKIP
         ENDDO

         _t_rec := RecNo()

         _ok := .T.

         _dok_hash := hb_Hash()
         _dok_hash[ "idfirma" ] := _id_firma
         _dok_hash[ "idtipdok" ] := _id_vd
         _dok_hash[ "brdok" ] := _br_dok

         oAtrib := F18_DOK_ATRIB():new( "kalk", F_KALK_ATRIB )
         oAtrib:dok_hash := _dok_hash

         _ok := _ok .AND.  oAtrib:delete_atrib_from_server()

         _ok := delete_rec_server_and_dbf( "kalk_kalk", _del_rec, 2, "CONT" )

         IF _ok
            // pobrsi mi sada tabelu kalk_doks
            SELECT kalk_doks
            GO TOP
            SEEK _id_firma + _id_vd + _br_dok

            IF Found()

               log_write( "F18_DOK_OPER: kalk brisanje vise dokumenata: " + _id_firma + _id_vd + _br_dok, 2 )

               _del_rec := dbf_get_rec()
               // brisi prvo tabelu kalk_doks
               _ok := .T.
               _ok :=  delete_rec_server_and_dbf( "kalk_doks", _del_rec, 1, "CONT" )

            ENDIF

         ENDIF


         IF !_ok
            MsgC()
            MsgBeep( "Problem sa brisanjem tabele kalk !!!" )
            my_close_all_dbf()
            RETURN .F.
         ENDIF

         SELECT kalk
         GO ( _t_rec )

      ENDDO

      MsgC()

      f18_free_tables( { "kalk_doks", "kalk_kalk", "kalk_doks2" } )
      sql_table_update( nil, "END" )


   ENDIF

   my_close_all_dbf()

   RETURN .T.




// ------------------------------------------------------------------
// iz kalk_pripr 9 u kalk_pripr
// ------------------------------------------------------------------
FUNCTION Povrat9( cIdFirma, cIdVd, cBrDok )

   LOCAL nRec
   LOCAL _rec

   lSilent := .T.

   O_KALK_PRIPR9
   O_KALK_PRIPR

   SELECT kalk_pripr9
   SET ORDER TO TAG "1"
   // idFirma+IdVD+BrDok+RBr

   IF ( ( cIdFirma == nil ) .AND. ( cIdVd == nil ) .AND. ( cBrDok == nil ) )
      lSilent := .F.
   ENDIF

   IF !lSilent
      cIdFirma := gFirma
      cIdVD := Space( 2 )
      cBrDok := Space( 8 )
   ENDIF

   IF !lSilent
      Box( "", 1, 35 )
      @ m_x + 1, m_y + 2 SAY "Dokument:"
      IF gNW $ "DX"
         @ m_x + 1, Col() + 1 SAY cIdFirma
      ELSE
         @ m_x + 1, Col() + 1 GET cIdFirma
      ENDIF
      @ m_x + 1, Col() + 1 SAY "-" GET cIdVD
      @ m_x + 1, Col() + 1 SAY "-" GET cBrDok
      READ
      ESC_BCR
      BoxC()

      IF cBrDok = "."
         PRIVATE qqBrDok := qqDatDok := qqIdvD := Space( 80 )
         qqIdVD := PadR( cidvd + ";", 80 )
         Box(, 3, 60 )
         DO WHILE .T.
            @ m_x + 1, m_y + 2 SAY "Vrste dokum.   "  GET qqIdVD PICT "@S40"
            @ m_x + 2, m_y + 2 SAY "Broj dokumenata"  GET qqBrDok PICT "@S40"
            @ m_x + 3, m_y + 2 SAY "Datumi         " GET  qqDatDok PICT "@S40"
            READ
            PRIVATE aUsl1 := Parsiraj( qqBrDok, "BrDok", "C" )
            PRIVATE aUsl2 := Parsiraj( qqDatDok, "DatDok", "D" )
            PRIVATE aUsl3 := Parsiraj( qqIdVD, "IdVD", "C" )
            IF aUsl1 <> NIL .AND. aUsl2 <> NIL .AND. ausl3 <> NIL
               EXIT
            ENDIF
         ENDDO
         Boxc()

         IF Pitanje(, "Povuci u pripremu dokumente sa ovim kriterijom ?", "N" ) == "D"
            SELECT kalk_pripr9
            PRIVATE cFilt1 := ""
            cFilt1 := "IDFIRMA==" + cm2str( cIdFirma ) + ".and." + aUsl1 + ".and." + aUsl2 + ".and." + aUsl3
            cFilt1 := StrTran( cFilt1, ".t..and.", "" )
            IF !( cFilt1 == ".t." )
               SET FILTER TO &cFilt1
            ENDIF

            GO TOP
            MsgO( "Prolaz kroz SMECE..." )

            DO WHILE !Eof()
               SELECT kalk_pripr9
               Scatter()
               SELECT kalk_pripr
               APPEND ncnl
               _ERROR := ""
               Gather2()
               SELECT kalk_pripr9
               SKIP
               nRec := RecNo()
               SKIP -1
               my_delete()
               GO nRec
            ENDDO
            MsgC()
         ENDIF
         my_close_all_dbf()
         RETURN
      ENDIF
   ENDIF

   IF Pitanje( "", "Iz smeca " + cIdFirma + "-" + cIdVD + "-" + cBrDok + " povuci u pripremu (D/N) ?", "D" ) == "N"
      IF !lSilent
         my_close_all_dbf()
         RETURN
      ELSE
         RETURN
      ENDIF
   ENDIF

   SELECT kalk_pripr9

   hseek cIdFirma + cIdVd + cBrDok
   EOF CRET

   MsgO( "PRIPREMA" )

   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVD == IdVD .AND. cBrDok == BrDok
      SELECT kalk_pripr9
      Scatter()
      SELECT kalk_pripr
      APPEND ncnl
      _ERROR := ""
      Gather2()
      SELECT kalk_pripr9
      SKIP
   ENDDO

   SELECT kalk_pripr9
   SEEK cidfirma + cidvd + cBrDok
   my_flock()
   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVD == IdVD .AND. cBrDok == BrDok
      SKIP 1
      nRec := RecNo()
      SKIP -1
      my_delete()
      GO nRec
   ENDDO
   my_unlock()
   USE
   MsgC()

   log_write( "F18_DOK_OPER: kalk, povrat dokumenta iz smeca: " + cIdFirma + "-" + cIdVd + "-" + cBrDok, 2 )

   IF !lSilent
      my_close_all_dbf()
      RETURN
   ENDIF

   O_KALK_PRIPR9
   SELECT kalk_pripr9

   RETURN



// ------------------------------------------------------------------
// iz kalk_pripr 9 u kalk_pripr najstariju kalkulaciju
// ------------------------------------------------------------------
FUNCTION P9najst()

   LOCAL nRec

   O_KALK_PRIPR9
   O_KALK_PRIPR

   SELECT kalk_pripr9
   SET ORDER TO TAG "3"
   cidfirma := gfirma
   cIdVD := Space( 2 )
   cBrDok := Space( 8 )

   IF Pitanje(, "Povuci u pripremu najstariji dokument ?", "N" ) == "N"
      my_close_all_dbf()
      RETURN
   ENDIF

   SELECT kalk_pripr9
   GO TOP

   cidfirma := idfirma
   cIdVD := idvd
   cBrDok := brdok

   MsgO( "PRIPREMA" )

   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVD == IdVD .AND. cBrDok == BrDok
      SELECT kalk_pripr9
      Scatter()
      SELECT kalk_pripr
      APPEND BLANK
      _ERROR := ""
      Gather()
      SELECT kalk_pripr9
      SKIP
   ENDDO

   SET ORDER TO TAG "1"
   SELECT kalk_pripr9
   SEEK cidfirma + cidvd + cBrDok

   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVD == IdVD .AND. cBrDok == BrDok
      SKIP 1
      nRec := RecNo()
      SKIP -1
      my_delete()
      GO nRec
   ENDDO
   USE
   MsgC()

   my_close_all_dbf()

   RETURN




// ------------------------------------------------------------------
// iz kalk u kalk_pripr najnoviju kalkulaciju
// ------------------------------------------------------------------
FUNCTION Pnajn()

   LOCAL nRec
   LOCAL cBrsm
   LOCAL fbof
   LOCAL nVraceno := 0
   LOCAL _rec, _del_rec

   O_KALK_DOKS
   O_KALK
   O_KALK_PRIPR

   SELECT kalk
   SET ORDER TO TAG "5"
   // str(datdok)
   cIdfirma := gfirma
   cIdVD := Space( 2 )
   cBrDok := Space( 8 )

   GO BOTTOM
   cIdfirma := idfirma
   dDatDok := datdok

   IF Eof()
      Msg( "Na stanju nema dokumenata.." )
      my_close_all_dbf()
      RETURN
   ENDIF

   IF Pitanje(, "Vratiti u pripremu dokumente od " + DToC( dDatDok ) + " ?", "N" ) == "N"
      my_close_all_dbf()
      RETURN
   ENDIF

   SELECT kalk

   MsgO( "Povrat dokumenata od " + DToC( dDatDok ) + " u pripremu" )

   DO WHILE !Bof() .AND. cIdFirma == IdFirma .AND. datdok == dDatDok
      cIDFirma := idfirma
      cIdvd := idvd
      cBrDok := brdok
      cBrSm := ""

      DO WHILE !Bof() .AND. cIdFirma == IdFirma .AND. cidvd == idvd .AND. cbrdok == brdok

         SELECT kalk

         _rec := dbf_get_rec()

         IF !( _rec[ "tbanktr" ] == "X" )

            SELECT kalk_pripr
            APPEND BLANK

            _rec[ "error" ] := ""
            dbf_update_rec( _rec )

            nVraceno ++

         ELSEIF _rec[ "tbanktr" ] == "X" .AND. ( _rec[ "mu_i" ] == "5" .OR. _rec[ "pu_i" ] == "5" )

            SELECT kalk_pripr

            IF rbr <> _rec[ "rbr" ] .OR. ( idfirma + idvd + brdok ) <> _rec[ "idfirma" ] + _rec[ "idvd" ] + _rec[ "brdok" ]
               nVraceno++
               APPEND BLANK
               _rec[ "error" ] := ""
            ELSE
               _rec[ "kolicinai" ] += kalk_pripr->kolicina
            ENDIF

            _rec[ "error" ] := ""
            _rec[ "tbanktr" ] := ""

            dbf_update_rec( _rec )

         ELSEIF _rec[ "tbanktr" ] == "X" .AND. ( _rec[ "mu_i" ] == "3" .OR. _rec[ "pu_i" ] == "3" )
            IF cBrSm <> ( cBrSm := idfirma + "-" + idvd + "-" + brdok )
               Beep( 1 )
               Msg( "Dokument: " + cbrsm + " je izgenerisan,te je izbrisan bespovratno" )
            ENDIF
         ENDIF

         SELECT kalk
         SKIP -1

         IF Bof()
            fBof := .T.
            nRec := 0
         ELSE
            fBof := .F.
            nRec := RecNo()
            SKIP 1
         ENDIF

         SELECT kalk_doks
         SEEK kalk->( idfirma + idvd + brdok )

         IF Found()
            _del_rec := dbf_get_rec()
            delete_rec_server_and_dbf( "kalk_doks", _del_rec, 1, "FULL" )
         ENDIF

         SELECT kalk
         _del_rec := dbf_get_rec()
         delete_rec_server_and_dbf( "kalk_kalk", _del_rec, 1, "FULL" )

         GO nRec

         IF fBof
            EXIT
         ENDIF

      ENDDO

   ENDDO

   MsgC()

   my_close_all_dbf()

   RETURN
