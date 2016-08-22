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



FUNCTION kalk_generisi_ip()

   O_KONTO
   O_TARIFA
   O_SIFK
   O_SIFV
   O_ROBA

   Box(, 4, 50 )

   cIdFirma := gFirma
   cIdkonto := PadR( "1320", 7 )
   dDatDok := Date()
   cNulirati := "N"

   @ m_x + 1, m_Y + 2 SAY "Prodavnica:" GET  cidkonto VALID P_Konto( @cidkonto )
   @ m_x + 2, m_Y + 2 SAY "Datum     :  " GET  dDatDok
   @ m_x + 3, m_Y + 2 SAY "Nulirati lager (D/N)" GET cNulirati VALID cNulirati $ "DN" PICT "@!"

   READ
   ESC_BCR

   BoxC()

   o_koncij()
   o_kalk_pripr()
   //o_kalk()

   PRIVATE cBrDok := kalk_get_next_broj_v5( cIdFirma, "IP", NIL )

   nRbr := 0

   SET ORDER TO TAG "4"

   MsgO( "Generacija dokumenta IP - " + cbrdok )

   SELECT koncij
   SEEK Trim( cidkonto )
   SELECT kalk

   HSEEK cIdfirma + cIdkonto

   DO WHILE !Eof() .AND. cidfirma + cidkonto == idfirma + pkonto

      cIdRoba := Idroba
      nUlaz := nIzlaz := 0
      nMPVU := nMPVI := nNVU := nNVI := 0
      nRabat := 0

      SELECT roba
      HSEEK cIdroba

      SELECT kalk

      DO WHILE !Eof() .AND. cidfirma + cidkonto + cidroba == idFirma + pkonto + idroba

         IF ddatdok < datdok  // preskoci
            SKIP
            LOOP
         ENDIF

         IF roba->tip $ "UT"
            SKIP
            LOOP
         ENDIF

         IF pu_i == "1"
            nUlaz += kolicina - GKolicina - GKolicin2
            nMPVU += mpcsapp * kolicina
            nNVU += nc * kolicina

         ELSEIF pu_i == "5"  .AND. !( idvd $ "12#13#22" )
            nIzlaz += kolicina
            nMPVI += mpcsapp * kolicina
            nNVI += nc * kolicina

         ELSEIF pu_i == "5"  .AND. ( idvd $ "12#13#22" )
            // povrat
            nUlaz -= kolicina
            nMPVU -= mpcsapp * kolicina
            nNvu -= nc * kolicina

         ELSEIF pu_i == "3"    // nivelacija
            nMPVU += mpcsapp * kolicina

         ELSEIF pu_i == "I"
            nIzlaz += gkolicin2
            nMPVI += mpcsapp * gkolicin2
            nNVI += nc * gkolicin2
         ENDIF
         SKIP
      ENDDO

      IF ( Round( nulaz - nizlaz, 4 ) <> 0 ) .OR. ( Round( nmpvu - nmpvi, 4 ) <> 0 )
         SELECT roba
         HSEEK cidroba
         SELECT kalk_pripr
         scatter()
         APPEND ncnl
         _idfirma := cidfirma; _idkonto := cidkonto; _pkonto := cidkonto; _pu_i := "I"
         _idroba := cidroba; _idtarifa := roba->idtarifa
         _idvd := "IP"; _brdok := cbrdok

         _rbr := RedniBroj( ++nrbr )
         _kolicina := _gkolicina := nUlaz - nIzlaz
         IF cNulirati == "D"
            _kolicina := 0
         ENDIF
         _datdok := _DatFaktP := ddatdok
         _ERROR := ""
         _fcj := nmpvu - nmpvi // stanje mpvsapp
         IF Round( nulaz - nizlaz, 4 ) <> 0
            _mpcsapp := Round( ( nMPVU - nMPVI ) / ( nulaz - nizlaz ), 3 )
            _nc := Round( ( nnvu - nnvi ) / ( nulaz - nizlaz ), 3 )
         ELSE
            _mpcsapp := 0
         ENDIF
         Gather2()
         SELECT kalk
      ENDIF

   ENDDO

   MsgC()

   my_close_all_dbf()

   RETURN


// ---------------------------------------------------------------------------
// inventurno stanje artikla
// ---------------------------------------------------------------------------
FUNCTION kalk_ip_roba( id_konto, id_roba, dat_dok, kolicina, nc, fc, mpcsapp )

   LOCAL _t_area := Select()
   LOCAL _ulaz, _izlaz, _mpvu, _mpvi, _rabat, _nvu, _nvi

   _ulaz := 0
   _izlaz := 0
   _mpvu := 0
   _mpvi := 0
   _rabat := 0
   _nvu := 0
   _nvi := 0

   kolicina := 0
   nc := 0
   fc := 0
   mpcsapp := 0

   SELECT roba
   HSEEK id_roba

   IF roba->tip $ "UI"
      SELECT ( _t_area )
      RETURN
   ENDIF

   SELECT koncij
   HSEEK id_konto

   SELECT kalk
   SET ORDER TO TAG "4"
   HSEEK gFirma + id_konto + id_roba

   DO WHILE !Eof() .AND. field->idfirma == gFirma .AND. field->pkonto == id_konto .AND. field->idroba == id_roba

      IF dat_dok < field->datdok
         // preskoci
         SKIP
         LOOP
      ENDIF

      IF field->pu_i == "1"
         _ulaz += field->kolicina - field->gkolicina - field->gkolicin2
         _mpvu += field->mpcsapp * field->kolicina
         _nvu += field->nc * field->kolicina

      ELSEIF field->pu_i == "5" .AND. !( field->idvd $ "12#13#22" )
         _izlaz += field->kolicina
         _mpvi += field->mpcsapp * field->kolicina
         _nvi += field->nc * field->kolicina

      ELSEIF field->pu_i == "5" .AND. ( field->idvd $ "12#13#22" )
         // povrat
         _ulaz -= field->kolicina
         _mpvu -= field->mpcsapp * field->kolicina
         _nvu -= field->nc * field->kolicina

      ELSEIF field->pu_i == "3"
         // nivelacija
         _mpvu += field->mpcsapp * field->kolicina

      ELSEIF field->pu_i == "I"
         _izlaz += field->gkolicin2
         _mpvi += field->mpcsapp * field->gkolicin2
         _nvi += field->nc * field->gkolicin2
      ENDIF

      SKIP

   ENDDO

   IF Round( _ulaz - _izlaz, 4 ) <> 0

      kolicina := _ulaz - _izlaz
      fcj := _mpvu - _mpvi
      mpcsapp := Round( ( _mpvu - _mpvi ) / ( _ulaz - _izlaz ), 3 )
      nc := Round( ( _nvu - _nvi ) / ( _ulaz - _izlaz ), 3 )

   ENDIF

   RETURN



// --------------------------------------------------------------------------
// generacija inventure - razlike postojece inventure
// postojeca inventura se kopira u pomocnu tabelu i sluzi kao usporedba
// svi artikli koji se nadju unutar ove inventure ce biti preskoceni
// i zanemareni u novoj inventuri
// --------------------------------------------------------------------------
FUNCTION gen_ip_razlika()

   LOCAL _rec
   LOCAL nUlaz
   LOCAL nIzlaz
   LOCAL nMPVU
   LOCAL nMPVI
   LOCAL nNVU
   LOCAL nNVI
   LOCAL nRabat
   LOCAL _cnt := 0

   O_KONTO

   Box(, 4, 50 )

   cIdFirma := gFirma
   cIdkonto := PadR( "1330", 7 )
   dDatDok := Date()
   cOldBrDok := Space( 8 )
   cIdVd := "IP"

   @ m_x + 1, m_y + 2 SAY "Prodavnica:" GET cIdKonto VALID P_Konto( @cIdKonto )
   @ m_x + 2, m_y + 2 SAY "Datum do  :" GET dDatDok
   @ m_x + 3, m_y + 2 SAY "Dokument " + cIdFirma + "-" + cIdVd GET cOldBrDok

   READ
   ESC_BCR

   BoxC()

   IF Pitanje(, "Generisati inventuru (D/N)", "D" ) == "N"
      RETURN
   ENDIF

   MsgO( "kopiram postojecu inventuru ... " )

   // prvo izvuci postojecu inventuru u PRIPT
   // ona ce sluziti za usporedbu...
   IF cp_dok_pript( cIdFirma, cIdVd, cOldBrDok ) == 0
      MsgC()
      RETURN .F.
   ENDIF

   MsgC()

   // otvori potrebne tabele
   O_TARIFA
   O_SIFK
   O_SIFV
   O_ROBA
   o_koncij()
   o_kalk_pripr()
   o_kalk_pript()
   //o_kalk()

   // sljedeci broj kalkulacije IP
   PRIVATE cBrDok := kalk_get_next_broj_v5( cIdFirma, "IP", NIL )

   nRbr := 0

   //SELECT kalk
   //SET ORDER TO TAG "4"

   Box( , 3, 60 )

   @ m_x + 1, m_y + 2 SAY "generacija IP-" + AllTrim( cBrDok ) + " u toku..."

   SELECT koncij
   SEEK Trim( cIdKonto )

   //SELECT kalk
   //HSEEK cIdFirma + cIdKonto
   find_kalk_by_pkonto_idroba( cIdFirma, cIdKonto )

   DO WHILE !Eof() .AND. cIdFirma + cIdKonto == idfirma + pkonto

      cIdRoba := field->idroba

      SELECT pript
      SET ORDER TO TAG "2"
      HSEEK cIdFirma + "IP" + cOldBrDok + cIdRoba

      // ako nadjes robu u dokumentu u pript prekoci ga u INVENTURI!!!
      IF Found()
         SELECT kalk
         SKIP
         LOOP
      ENDIF

      nUlaz := 0
      nIzlaz := 0
      nMPVU := 0
      nMPVI := 0
      nNVU := 0
      nNVI := 0
      nRabat := 0

      SELECT roba
      HSEEK cIdRoba

      SELECT koncij
      HSEEK cIdKonto

      SELECT kalk

      DO WHILE !Eof() .AND. cIdfirma + cIdkonto + cIdroba == idFirma + pkonto + idroba

         IF dDatdok < field->datdok
            // preskoci
            SKIP
            LOOP
         ENDIF

         IF roba->tip $ "UT"
            SKIP
            LOOP
         ENDIF

         IF field->pu_i == "1"
            nUlaz += kolicina - GKolicina - GKolicin2
            nMPVU += mpcsapp * kolicina
            nNVU += nc * kolicina
         ELSEIF field->pu_i == "5"  .AND. !( field->idvd $ "12#13#22" )
            nIzlaz += kolicina
            nMPVI += mpcsapp * kolicina
            nNVI += nc * kolicina
         ELSEIF field->pu_i == "5"  .AND. ( field->idvd $ "12#13#22" )
            // povrat
            nUlaz -= kolicina
            nMPVU -= mpcsapp * kolicina
            nNvu -= nc * kolicina
         ELSEIF field->pu_i == "3"
            // nivelacija
            nMPVU += mpcsapp * kolicina
         ELSEIF field->pu_i == "I"
            nIzlaz += gkolicin2
            nMPVI += mpcsapp * gkolicin2
            nNVI += nc * gkolicin2
         ENDIF

         SKIP

      ENDDO

      IF ( Round( nUlaz - nIzlaz, 4 ) <> 0 ) .OR. ( Round( nMpvu - nMpvi, 4 ) <> 0 )

         SELECT roba
         HSEEK cIdRoba

         SELECT kalk_pripr
         APPEND BLANK

         _rec := dbf_get_rec()

         _rec[ "idfirma" ] := cIdfirma
         _rec[ "idkonto" ] := cIdkonto
         _rec[ "mkonto" ] := ""
         _rec[ "pkonto" ] := cIdkonto
         _rec[ "mu_i" ] := ""
         _rec[ "pu_i" ] := "I"
         _rec[ "idroba" ] := cIdroba
         _rec[ "idtarifa" ] := roba->idtarifa
         _rec[ "idvd" ] := "IP"
         _rec[ "brdok" ] := cBrdok
         _rec[ "rbr" ] := RedniBroj( ++nRbr )

         // kolicinu odmah setuj na 0
         _rec[ "kolicina" ] := 0

         // popisana kolicina je trenutno stanje
         _rec[ "gkolicina" ] := nUlaz - nIzlaz

         _rec[ "datdok" ] := dDatDok
         _rec[ "datfaktp" ] := dDatdok

         _rec[ "error" ] := ""
         _rec[ "fcj" ] := nMpvu - nMpvi

         // stanje mpvsapp
         IF Round( nUlaz - nIzlaz, 4 ) <> 0
            // treba li ovo zaokruzivati ????
            _rec[ "mpcsapp" ] := Round( ( nMPVU - nMPVI ) / ( nUlaz - nIzlaz ), 3 )
            _rec[ "nc" ] := Round( ( nNvu - nNvi ) / ( nUlaz - nIzlaz ), 3 )
         ELSE
            _rec[ "mpcsapp" ] := 0
         ENDIF

         dbf_update_rec( _rec )

         @ m_x + 2, m_y + 2 SAY "Broj stavki: " + PadR( AllTrim( Str( ++_cnt, 12, 0 ) ), 20 )
         @ m_x + 3, m_y + 2 SAY "    Artikal: " + PadR( AllTrim( cIdroba ), 20 )

         SELECT kalk

      ENDIF

   ENDDO

   BoxC()

   SELECT kalk_pripr

   IF RecCount() > 0
      MsgBeep( "Dokument inventure formiran u pripremi, obradite ga!" )
   ENDIF

   my_close_all_dbf()

   RETURN




// ---------------------------------------
// forma za unos dokument
// ---------------------------------------
FUNCTION Get1_IP()

   LOCAL nFaktVPC
   LOCAL _x := 8
   LOCAL _pos_x, _pos_y
   LOCAL _left := 25
   PRIVATE aPorezi := {}

   _datfaktp := _datdok

   @ m_x + _x, m_y + 2 SAY "Konto koji zaduzuje" GET _IdKonto ;
      VALID P_Konto( @_IdKonto, _x, 35 ) PICT "@!"

   //IF gNW <> "X"
  //    @ m_x + _x, m_y + 35 SAY "Zaduzuje: " GET _idzaduz PICT "@!" ;
  //       VALID Empty( _idzaduz ) .OR. P_Firma( @_idzaduz, _x, 35 )
   //ENDIF

   READ
   ESC_RETURN K_ESC

   ++ _x
   ++ _x

   _pos_x := m_x + _x

   IF lKoristitiBK
      @ m_x + _x, m_y + 2 SAY "Artikal  " GET _idroba PICT "@!S10" ;
         WHEN {|| _idroba := PadR( _idroba, Val( gDuzSifIni ) ), .T. } ;
         VALID {|| vroba( .F. ), ispisi_naziv_sifre( F_ROBA, _idroba, _pos_x, 25, 40 ), .T.  }
   ELSE
      @ m_x + _x, m_y + 2 SAY "Artikal  " GET _idroba PICT "@!" ;
         VALID {|| vroba( .F. ), ispisi_naziv_sifre( F_ROBA, _idroba, _pos_x, 25, 40 ), .T.  }
   ENDIF

   @ m_x + _x, m_y + ( MAXCOLS() - 20 ) SAY "Tarifa:" GET _idtarifa ;
      WHEN gPromTar == "N" VALID P_Tarifa( @_idtarifa )

   READ

   ESC_RETURN K_ESC

   IF lKoristitiBK
      _idroba := Left( _idroba, 10 )
   ENDIF

   // proracunava knjizno stanje robe na prodavnici
   // kada je dokument prenesen iz tops-a onda ovo ne bi trebalo da radi
   IF !Empty( gMetodaNC ) .AND. _nc = 0 .AND. _mpcsapp = 0
      knjizst()
   ENDIF

   SELECT tarifa
   HSEEK _idtarifa

   SELECT kalk_pripr

   // provjeri duplu robu...
   DuplRoba()

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY PadL( "KNJIZNA KOLICINA:", _left ) GET _gkolicina PICT PicKol  ;
      WHEN {|| iif( gMetodaNC == " ", .T., .F. ) }

   @ m_x + _x, Col() + 2 SAY "POPISANA KOLICINA:" GET _kolicina VALID VKol() PICT PicKol

   IF IsPDV()
      _tmp := "P.CIJENA (SA PDV):"
   ELSE
      _tmp := " CIJENA (MPCSAPP):"
   ENDIF

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY PadL( "NABAVNA CIJENA:", _left ) GET _nc PICT picdem

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY PadL( _tmp, _left ) GET _mpcsapp PICT picdem

   READ

   ESC_RETURN K_ESC

   // _fcj - knjizna prodajna vrijednost
   // _fcj3 - knjizna nabavna vrijednost

   _gkolicin2 := _gkolicina - _kolicina

   // ovo je kolicina izlaza koja nije proknjizena
   _mkonto := ""
   _pkonto := _idkonto

   _mu_i := ""
   _pu_i := "I"
   // inventura

   nStrana := 3

   RETURN LastKey()




STATIC FUNCTION VKol()

   LOCAL lMoze := .T.

   IF ( glZabraniVisakIP )
      IF ( _kolicina > _gkolicina )
         MsgBeep( "Ne dozvoljavam evidentiranje viska na ovaj nacin!" )
         lMoze := .F.
      ENDIF
   ENDIF

   RETURN lMoze
