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

FUNCTION kalk_azuriranje_dokumenta( lAuto )

   LOCAL lViseDok := .F.
   LOCAL aRezim := {}
   LOCAL aOstaju := {}
   LOCAL lGenerisiZavisne := .F.
   LOCAL lBrStDoks := .F.

   IF ( lAuto == nil )
      lAuto := .F.
   ENDIF

   IF !lAuto .AND. Pitanje(, "Želite li izvrsiti ažuriranje KALK dokumenta (D/N) ?", "N" ) == "N"
      RETURN .F.
   ENDIF

   O_KALK_PRIPR
   SELECT kalk_pripr
   GO TOP

   IF kalk_dokument_postoji( kalk_pripr->idfirma, kalk_pripr->idvd, kalk_pripr->brdok )
      MsgBeep( "Dokument " + kalk_pripr->idfirma + "-" + kalk_pripr->idvd + "-" + ;
         AllTrim( kalk_pripr->brdok ) + " već postoji u bazi !#Promjenite broj dokumenta pa ponovite proceduru ažuriranja." )
      RETURN .F.
   ENDIF

   SELECT kalk_pripr
   GO TOP

   IF !provjeri_redni_broj()
      MsgBeep( "Redni brojevi dokumenta nisu ispravni !" )
      RETURN .F.
   ENDIF

   O_KALK_PRIPR2
   my_dbf_zap()
   USE

   lViseDok := kalk_provjeri_duple_dokumente( @aRezim )

   o_kalk_za_azuriranje( .T. )

   SELECT kalk_doks

   IF FieldPos( "ukstavki" ) <> 0
      lBrStDoks := .T.
   ENDIF

   IF gCijene == "2" .AND. !kalk_provjera_integriteta( @aOstaju, lViseDok )
      RETURN .F.
   ENDIF

   IF !kalk_provjera_cijena()
      RETURN .F.
   ENDIF

   lGenerisiZavisne := kalk_generisati_zavisne_dokumente( lAuto )

   IF lGenerisiZavisne == .T.
      kalk_zavisni_dokumenti()
   ENDIF

   IF kalk_azur_sql()

      o_kalk_za_azuriranje()

      IF !kalk_azur_dbf( lAuto, lViseDok, aOstaju, aRezim, lBrStDoks )
         MsgBeep( "Neuspješno ažuriranje KALK dokumenta u DBF tabele !" )
         RETURN .F.
      ENDIF

   ELSE
      MsgBeep( "Neuspješno ažuriranja KALK dokumenta u SQL bazu !" )
      RETURN .F.
   ENDIF

   DokAtributi():new( "kalk", F_KALK_ATRIB ):zapp_local_table()

   kalk_zavisni_nakon_azuriranja( lGenerisiZavisne, lAuto )

   IF lViseDok == .T. .AND. Len( aOstaju ) > 0
      kalk_ostavi_samo_duple( aOstaju )
   ELSE
      SELECT kalk_pripr
      my_dbf_zap()
   ENDIF

   IF lGenerisiZavisne == .T.
      kalk_vrati_iz_pripr2()
   ENDIF

   my_close_all_dbf()

   RETURN .T.



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
      IF kalk_pripr2->( reccount2() ) <> 0
         Beep( 1 )
         Box(, 4, 70 )
         @ m_x + 1, m_y + 2 SAY "1. Cijene robe su promijenjene."
         @ m_x + 2, m_y + 2 SAY "2. Formiran je dokument nivelacije:" + kalk_pripr2->( idfirma + "-" + idvd + "-" + brdok )
         @ m_x + 3, m_y + 2 SAY8 "3. Nove cijene su stavljene u šifarnik."
         @ m_x + 4, m_y + 2 SAY "4. Obradite ovaj dokument."
         Inkey( 0 )
         BoxC()
         lPrebaci := .T.
      ENDIF

   ELSEIF field->idvd $ "95"
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
         @ m_x + 2, m_y + 2 SAY8 "2. Formiran je dokument zaduženja:" + kalk_pripr2->( idfirma + "-" + idvd + "-" + brdok )
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

   RETURN .T.


// ------------------------------------------------------------------------
// generisanje zavisnih dokumenata nakon azuriranja kalkulacije
// mozda cemo dobiti i nove dokumente u pripremi
// ------------------------------------------------------------------------
STATIC FUNCTION kalk_zavisni_nakon_azuriranja( lGenerisi, lAuto )

   LOCAL lForm11 := .F.
   LOCAL cNext11 := ""
   LOCAL lgAFin := gAFin
   LOCAL lgAMat := gAMat

   o_kalk_za_azuriranje()

   IF Generisati11_ku()
      lForm11 := .T.
      cNext11 := SljBrKalk( "11", gFirma )
      Generisi11ku_iz10ke( cNext11 )
   ENDIF

   SELECT KALK

   IF lGenerisi = .T.

      RekapK()

      formiraj_finansijski_nalog( lAuto )

      gAFin := lgAFin
      gAMat := lgAMat

      formiraj_fakt_zavisne_dokumente()

   ENDIF

   IF lForm11
      Get11FromSmece( cNext11 )
   ENDIF

   RETURN


STATIC FUNCTION formiraj_finansijski_nalog( lAuto )

   IF !f18_use_module( "fin" )
      RETURN
   ENDIF

   IF ( gaFin == "D" .OR. gaMat == "D" )
      IF kalk_kontiranje_naloga( .T., lAuto )
         fin_nalog_priprema_kalk( lAuto )
      ENDIF
   ENDIF

   RETURN


STATIC FUNCTION formiraj_fakt_zavisne_dokumente()

   LOCAL cOdg := "D"

   O_KALK_PRIPR

   IF !f18_use_module( "fakt" )
      RETURN
   ENDIF

   IF gAFakt != "D"
      RETURN
   ENDIF

   IF field->idvd $ "10#12#13#16#11#95#96#97#PR#RN"

      IF field->idvd $ "16#96"
         cOdg := "N"
      ENDIF

      IF Pitanje(, "Formirati dokument u FAKT ?", cOdg ) == "D"
         P_Fakt()
         o_kalk_za_azuriranje()
      ENDIF

   ENDIF

   RETURN .T.


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

   RETURN .T.



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
         lGen := Pitanje(, "Želite li formirati zavisne dokumente pri ažuriranju (D/N) ?", "D" ) == "D"
      ENDIF
   ENDIF

   RETURN lGen



STATIC FUNCTION kalk_zavisni_dokumenti()


   Niv_11()
   Otprema()
   Iz13u11()
   InvManj()

   RETURN .T.



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

   MsgO( "Ažuriranje kalk pripr ->  DBF kalk ..." )

   SELECT kalk_pripr
   GO TOP

   cIdFirma := field->idfirma

   SELECT kalk_doks
   SET ORDER TO TAG "3"
   SEEK cIdfirma + DToS( kalk_pripr->datdok ) + Chr( 255 )
   SKIP -1

   IF field->datdok == kalk_pripr->datdok
      IF  kalk_pripr->idvd $ "18#19" .AND. kalk_pripr->TBankTr == "X"
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

      IF lViseDok .AND. AScan( aOstaju, cIdFirma + cIdVd + cBrDok ) <> 0 // preskoci postojece
         SKIP 1
         LOOP
      ENDIF

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

      SELECT kalk_pripr
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
            kalk_set_doks_total_fields( @nNv, @nVpv, @nMpv, @nRabat )
         ENDIF

         SKIP

      ENDDO

      SELECT kalk_doks  // azuriranje cijena
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
            MSG( "Izgenerisane stavke su ispravljane, ažuriranje neće biti izvršeno !", 6 )
            my_close_all_dbf()
            RETURN .F.
         ENDIF

         IF gMetodaNC <> " " .AND. field->error == "1"
            Beep( 2 )
            MSG( "Utvrđena greška pri obradi dokumenta, rbr: " + field->rbr, 6 )
            my_close_all_dbf()
            RETURN .F.
         ENDIF

         // TODO: cleanup sumnjive stavke
         // IF gMetodaNC <> " " .AND. field->error == " "
         //
         // MsgBeep( "Dokument je izgenerisan, pokrenuti opciju <A> za obradu", 6 )
         // my_close_all_dbf()
         // RETURN .F.
         // ENDIF

         IF dDatDok <> field->datdok
            Beep( 2 )
            IF Pitanje(, "Datum različit u odnosu na prvu stavku. Ispraviti (D/N) ?", "D" ) == "D"
               RREPLACE field->datdok WITH dDatDok
            ELSE
               my_close_all_dbf()
               RETURN .F.
            ENDIF
         ENDIF

         IF field->idvd <> "24" .AND. Empty( field->mu_i ) .AND. Empty( field->pu_i )
            Beep( 2 )
            Msg( "Stavka broj " + field->rbr + ". neobrađena , sa <A> pokrenite obradu" )
            my_close_all_dbf()
            RETURN .F.
         ENDIF

         IF cIdzaduz2 <> field->idzaduz2
            Beep( 2 )
            Msg( "Stavka broj " + field->rbr + ". različito polje RN u odnosu na prvu stavku" )
            my_close_all_dbf()
            RETURN .F.
         ENDIF

         SKIP

      ENDDO

      SELECT kalk
      SEEK cIdFirma + cIdVD + cBrDok

      IF Found()
         error_bar( cIdfirma + "-" + cIdvd + "-" + cBrdok, ;
         "Postoji dokument na stanju: " + cIdFirma + "-" + cIdvd + "-" + AllTrim( cBrDok ) )
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
      Msg( "U pripremi se nalazi više dokumenata.#Prebaci ih u smeće, pa obradi pojedinačno." )
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   my_close_all_dbf()

   RETURN .T.



STATIC FUNCTION kalk_provjeri_duple_dokumente( aRezim )

   LOCAL lViseDok := .F.

   O_KALK_PRIPR
   GO BOTTOM

   cTest := field->idfirma + field->idvd + field->brdok
   GO TOP

   // TODO: cleanup vise dokumenata u pripreme
   IF cTest <> field->idfirma + field->idvd + field->brdok
      // Beep( 1 )
      // Msg( "U pripremi je vise dokumenata! Ukoliko želite da ih ažurirate sve#" + ;
      // "odjednom (npr.ako ste ih preuzeli sa drugog racunara putem diskete)#" + ;
      // "na sljedeće pitanje odgovorite sa 'D' i dokumenti ce biti ažurirani#" + ;
      // "bez provjera koje se vrše pri redovnoj obradi podataka." )
      // IF Pitanje(, "Želite li bezuslovno dokumente azurirati? (D/N)", "N" ) == "D"

      lViseDok := .T.
      aRezim := {}

      AAdd( aRezim, gCijene )
      AAdd( aRezim, gMetodaNC )
      gCijene   := "1"
      gMetodaNC := " "
      // ENDIF

   ELSEIF gCijene == "2"
      // ako je samo jedan dokument u kalk_pripremi

      DO WHILE !Eof()

         // TODO: cleanup sumnjive stavke
         IF field->ERROR == "1"
            error_bar( field->idfirma + "-" + field->idvd + "-" + field->brdok, " /  Rbr." + field->rbr + " sumnjiva! ")
            IF Pitanje(, "Želite li dokument ažurirati bez obzira na sumnjive stavke? (D/N)", "N" ) == "D"
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



FUNCTION o_kalk_za_azuriranje( raspored_tr )

   IF raspored_tr == NIL
      raspored_tr := .F.
   ENDIF

   my_close_all_dbf()

   O_KALK_PRIPR
   O_KALK
   O_KALK_DOKS2
   O_KALK_DOKS

   IF raspored_tr
      kalk_raspored_troskova()
   ENDIF

   RETURN .T.


STATIC FUNCTION kalk_raspored_troskova()

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

   RETURN .T.



STATIC FUNCTION kalk_azur_sql()

   LOCAL _ok := .T.
   LOCAL lRet := .F.
   LOCAL _record_dok, _record_item
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
   LOCAL bDokument := {| cIdFirma, cIdVd, cBrDok |   cIdFirma == field->idFirma .AND. ;
      cIdVd == field->IdVd .AND. cBrDok == field->BrDok }
   LOCAL cIdVd, cIdFirma, cBrDok

   _tbl_kalk := "kalk_kalk"
   _tbl_doks := "kalk_doks"

   Box(, 5, 60 )

   _tmp_id := "x"

   o_kalk_za_azuriranje()

   run_sql_query( "BEGIN" )

   IF !f18_lock_tables( { _tbl_kalk, _tbl_doks }, .T. )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Ne mogu zaključati tabele !#Prekidam operaciju." )
      RETURN lRet
   ENDIF

   SELECT kalk_pripr
   GO TOP


   @ m_x + 1, m_y + 2 SAY "kalk_kalk -> server: " + _tmp_id

   DO WHILE !Eof()


      cIdFirma := field->idFirma
      cIdVd := field->idVd
      cBrDok := field->brDok

      _record_dok := hb_Hash()
      _record_dok[ "idfirma" ] := cIdFirma
      _record_dok[ "idvd" ] := cIdVd
      _record_dok[ "brdok" ] := cBrDok
      _record_dok[ "datdok" ] := field->datdok
      _record_dok[ "brfaktp" ] := field->brfaktp
      _record_dok[ "idpartner" ] := field->idpartner
      _record_dok[ "idzaduz" ] := field->idzaduz
      _record_dok[ "idzaduz2" ] := field->idzaduz2
      _record_dok[ "pkonto" ] := field->pkonto
      _record_dok[ "mkonto" ] := field->mkonto
      _record_dok[ "podbr" ] := field->podbr
      _record_dok[ "sifra" ] := Space( 6 )

      _tmp_id := _record_dok[ "idfirma" ] + _record_dok[ "idvd" ] + _record_dok[ "brdok" ]
      AAdd( _ids_kalk, "#2" + _tmp_id )  // kalk_kalk brisi sve stavke za jedan dokument
      _log_dok := _record_dok[ "idfirma" ] + "-" + _record_dok[ "idvd" ] + "-" + _record_dok[ "brdok" ]

      DO WHILE !Eof() .AND.  Eval( bDokument, cIdFirma, cIdVd, cBrDok )

         kalk_set_doks_total_fields( @_doks_nv, @_doks_vpv, @_doks_mpv, @_doks_rabat )

         _record_item := dbf_get_rec()
         IF !sql_table_update( "kalk_kalk", "ins", _record_item )
            _ok := .F.
            EXIT
         ENDIF

         IF _record_item[ "idvd" ] == "97"
            _record_item[ "tbanktr" ] := "X"
            _record_item[ "mkonto" ] := _record_item[ "idkonto" ]
            _record_item[ "mu_i" ] := "1"
            _record_item[ "rbr" ] := PadL( Str( 900 + Val( AllTrim( _record_item[ "rbr" ] ) ), 3 ), 3 )

            IF !sql_table_update( "kalk_kalk", "ins", _record_item )
               _ok := .F.
               EXIT
            ENDIF
         ENDIF
         SKIP
      ENDDO


      IF _ok = .T.

         _record_dok[ "nv" ] := _doks_nv
         _record_dok[ "vpv" ] := _doks_vpv
         _record_dok[ "rabat" ] := _doks_rabat
         _record_dok[ "mpv" ] := _doks_mpv

         _tmp_id := _record_dok[ "idfirma" ] + _record_dok[ "idvd" ] + _record_dok[ "brdok" ]
         AAdd( _ids_doks, _tmp_id )

         @ m_x + 2, m_y + 2 SAY "kalk_doks -> server: " + _tmp_id
         IF !sql_table_update( "kalk_doks", "ins", _record_dok )
            _ok := .F.
         ENDIF

      ENDIF

      IF _ok == .T.

         @ m_x + 3, m_y + 2 SAY "kalk_atributi -> server "
         oAtrib := DokAtributi():new( "kalk", F_KALK_ATRIB )
         oAtrib:dok_hash[ "idfirma" ] := _record_dok[ "idfirma" ]
         oAtrib:dok_hash[ "idtipdok" ] := _record_dok[ "idvd" ]
         oAtrib:dok_hash[ "brdok" ] := _record_dok[ "brdok" ]

         _ok := oAtrib:atrib_dbf_to_server()

      ENDIF

   ENDDO


   IF !_ok

      run_sql_query( "ROLLBACK" )

      _msg := "kalk ažuriranje, trasakcija " + _tmp_id + " neuspješna ?!"
      log_write( _msg, 2 )
      MsgBeep( _msg )

   ELSE

      @ m_x + 4, m_y + 2 SAY "push ids to semaphore"
      push_ids_to_semaphore( _tbl_kalk, _ids_kalk )
      push_ids_to_semaphore( _tbl_doks, _ids_doks  )

      @ m_x + 5, m_y + 2 SAY "update semaphore version"

      f18_unlock_tables( { _tbl_kalk, _tbl_doks } )
      run_sql_query( "COMMIT" )

      log_write( "F18_DOK_OPER: ažuriranje kalk dokumenta: " + _log_dok, 2 )

   ENDIF

   BoxC()

   RETURN _ok




FUNCTION kalk_dokumenti_iz_pripreme_u_matricu()

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
