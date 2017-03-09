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



FUNCTION kalk_get_1_ip()

   LOCAL nFaktVPC
   LOCAL _x := 8
   LOCAL _pos_x, _pos_y
   LOCAL _left := 25
   PRIVATE aPorezi := {}

   _datfaktp := _datdok

   @ m_x + _x, m_y + 2 SAY "Konto koji zaduzuje" GET _IdKonto  VALID P_Konto( @_IdKonto, _x, 35 ) PICT "@!"

   // IF gNW <> "X"
   // @ m_x + _x, m_y + 35 SAY "Zaduzuje: " GET _idzaduz PICT "@!" ;
   // VALID Empty( _idzaduz ) .OR. p_partner( @_idzaduz, _x, 35 )
   // ENDIF

   READ
   ESC_RETURN K_ESC

   _x += 2
   _pos_x := m_x + _x

   kalk_pripr_form_get_roba( @_idRoba, @_idTarifa, _IdVd, kalk_is_novi_dokument(), m_x + _x, m_y + 2, @aPorezi )


   @ m_x + _x, m_y + ( MAXCOLS() -20 ) SAY "Tarifa:" GET _idtarifa WHEN gPromTar == "N" VALID P_Tarifa( @_idtarifa )

   READ

   ESC_RETURN K_ESC

   IF roba_barkod_pri_unosu()
      _idroba := Left( _idroba, 10 )
   ENDIF

/*
   // proracunava knjizno stanje robe na prodavnici
   // kada je dokument prenesen iz tops-a onda ovo ne bi trebalo da radi
   IF !Empty( kalk_metoda_nc() ) .AND. _nc == 0 .AND. _mpcsapp == 0
      knjizno_stanje_prodavnica()
   ENDIF
*/

   SELECT tarifa
   HSEEK _idtarifa

   select_o_roba( _idroba )

   _mpcsapp := kalk_get_mpc_by_koncij_pravilo( _IdKonto )

   SELECT kalk_pripr


   // DuplRoba()

   ++_x
   ++_x

   @ m_x + _x, m_y + 2 SAY PadL( "KNJIZNA KOLICINA:", _left ) GET _gkolicina PICT PicKol  ;
      WHEN {|| iif( kalk_metoda_nc() == " ", .T., .F. ) }

   @ m_x + _x, Col() + 2 SAY "POPISANA KOLICINA:" GET _kolicina VALID VKol() PICT PicKol


   _tmp := "P.CIJENA (SA PDV):"


   ++_x
   ++_x
   @ m_x + _x, m_y + 2 SAY PadL( "NABAVNA CIJENA:", _left ) GET _nc PICT picdem

   ++_x
   ++_x
   @ m_x + _x, m_y + 2 SAY PadL( _tmp, _left ) GET _mpcsapp PICT picdem

   READ

   ESC_RETURN K_ESC

   // _fcj - knjizna prodajna vrijednost
   // _fcj3 - knjizna nabavna vrijednost

   _gkolicin2 := _gkolicina - _kolicina // ovo je kolicina izlaza koja nije proknjizena
   _mkonto := ""
   _pkonto := _idkonto

   _mu_i := ""
   _pu_i := "I" // inventura

   nStrana := 3

   RETURN LastKey()



FUNCTION kalk_generisi_ip()

   LOCAL cIdFirma, cIdKonto, cIdRoba, dDatDok, cNulirati

   o_konto()
   o_tarifa()
   o_sifk()
   o_sifv()
//   o_roba()

   Box(, 4, 50 )

   cIdFirma := self_organizacija_id()
   cIdkonto := PadR( "1330", 7 )
   dDatDok := Date()
   cNulirati := "N"

   @ m_x + 1, m_Y + 2 SAY "Prodavnica:" GET  cIdkonto VALID P_Konto( @cIdkonto )
   @ m_x + 2, m_Y + 2 SAY "Datum     :  " GET  dDatDok
   @ m_x + 3, m_Y + 2 SAY "Nulirati lager (D/N)" GET cNulirati VALID cNulirati $ "DN" PICT "@!"

   READ
   ESC_BCR

   BoxC()

   o_koncij()
   o_kalk_pripr()
   // o_kalk()

   PRIVATE cBrDok := kalk_get_next_broj_v5( cIdFirma, "IP", NIL )

   nRbr := 0

   SET ORDER TO TAG "4"

   MsgO( "Generacija dokumenta IP - " + cBrdok )

   SELECT koncij
   SEEK Trim( cIdkonto )

   find_kalk_by_pkonto_idroba( cIdFirma, cIdKonto )

   DO WHILE !Eof() .AND. cIdfirma + cIdkonto == field->idfirma + field->pkonto

      cIdRoba := kalk->idroba
      nUlaz := nIzlaz := 0
      nMPVU := nMPVI := nNVU := nNVI := 0
      nRabat := 0

      select_o_roba( cIdroba )

      SELECT kalk

      DO WHILE !Eof() .AND. cIdfirma + cIdkonto + cIdroba == idFirma + pkonto + idroba

         IF ddatdok < datdok  // preskoci
            SKIP
            LOOP
         ENDIF

         IF roba->tip $ "UT"
            SKIP
            LOOP
         ENDIF

         IF pu_i == "1"
            nUlaz += field->kolicina - field->GKolicina - field->GKolicin2
            nMPVU += field->mpcsapp * field->kolicina
            nNVU += field->nc * field->kolicina

         ELSEIF pu_i == "5"  .AND. !( idvd $ "12#13#22" )
            nIzlaz += field->kolicina
            nMPVI += field->mpcsapp * field->kolicina
            nNVI += field->nc * field->kolicina

         ELSEIF pu_i == "5"  .AND. ( idvd $ "12#13#22" )
            // povrat
            nUlaz -= field->kolicina
            nMPVU -= field->mpcsapp * field->kolicina
            nNvu -= field->nc * field->kolicina

         ELSEIF pu_i == "3"    // nivelacija
            nMPVU += field->mpcsapp * field->kolicina

         ELSEIF pu_i == "I"
            nIzlaz += field->gkolicin2
            nMPVI += field->mpcsapp * field->gkolicin2
            nNVI += field->nc * field->gkolicin2
         ENDIF
         SKIP
      ENDDO

      IF ( Round( nUlaz - nIzlaz, 4 ) <> 0 ) .OR. ( Round( nMpvu - nMpvi, 4 ) <> 0 )

         select_o_roba(  cIdroba )

         SELECT kalk_pripr
         scatter()
         APPEND ncnl
         _idfirma := cIdfirma; _idkonto := cIdkonto; _pkonto := cIdkonto; _pu_i := "I"
         _idroba := cIdroba
         _idtarifa := roba->idtarifa
         _idvd := "IP"
         _brdok := cBrdok

         _rbr := RedniBroj( ++nRbr )
         _kolicina := _gkolicina := nUlaz - nIzlaz
         IF cNulirati == "D"
            _kolicina := 0
         ENDIF
         _datdok := _DatFaktP := dDatdok
         _ERROR := ""

         _fcj := nMpvu - nMpvi // stanje mpvsapp
         IF Round( nUlaz - nIzlaz, 4 ) <> 0
            _mpcsapp := Round( ( nMPVU - nMPVI ) / ( nUlaz - nIzlaz ), 3 )
            _nc := Round( ( nNvu - nNvi ) / ( nUlaz - nIzlaz ), 3 )
         ELSE
            _mpcsapp := 0
         ENDIF
         Gather2()
         SELECT kalk
      ENDIF

   ENDDO

   MsgC()

   my_close_all_dbf()

   RETURN .T.






/* --------------------------------------------------------------------------
// generacija inventure - razlike postojece inventure
// postojeca inventura se kopira u pomocnu tabelu i sluzi kao usporedba
// svi artikli koji se nadju unutar ove inventure ce biti preskoceni
// i zanemareni u novoj inventuri
*/

FUNCTION gen_ip_razlika()

   LOCAL hRec
   LOCAL nUlaz
   LOCAL nIzlaz
   LOCAL nMPVU
   LOCAL nMPVI
   LOCAL nNVU
   LOCAL nNVI
   LOCAL nRabat
   LOCAL _cnt := 0

   o_konto()

   Box(, 4, 50 )

   cIdFirma := self_organizacija_id()
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
      RETURN .F.
   ENDIF

   MsgO( "kopiram postojecu inventuru ... " )

   // prvo izvuci postojecu inventuru u PRIPT
   // ona ce sluziti za usporedbu...
   IF !kalk_copy_kalk_azuriran_u_pript( cIdFirma, cIdVd, cOldBrDok )
      MsgC()
      RETURN .F.
   ENDIF

   MsgC()

   // otvori potrebne tabele
   o_tarifa()
   o_sifk()
   o_sifv()
//   o_roba()
   o_koncij()
   o_kalk_pripr()
   o_kalk_pript()
   // o_kalk()

   // sljedeci broj kalkulacije IP
   PRIVATE cBrDok := kalk_get_next_broj_v5( cIdFirma, "IP", NIL )

   nRbr := 0

   // SELECT kalk
   // SET ORDER TO TAG "4"

   Box( , 3, 60 )

   @ m_x + 1, m_y + 2 SAY "generacija IP-" + AllTrim( cBrDok ) + " u toku..."

   SELECT koncij
   SEEK Trim( cIdKonto )

   // SELECT kalk
   // HSEEK cIdFirma + cIdKonto
   find_kalk_by_pkonto_idroba( cIdFirma, cIdKonto )
   GO TOP

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

      select_o_roba( cIdRoba )

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
            nUlaz += field->kolicina - field->GKolicina - field->GKolicin2
            nMPVU += field->mpcsapp * field->kolicina
            nNVU += field->nc * field->kolicina
         ELSEIF field->pu_i == "5"  .AND. !( field->idvd $ "12#13#22" )
            nIzlaz += field->kolicina
            nMPVI += field->mpcsapp * field->kolicina
            nNVI += field->nc * field->kolicina
         ELSEIF field->pu_i == "5"  .AND. ( field->idvd $ "12#13#22" )
            // povrat
            nUlaz -= field->kolicina
            nMPVU -= field->mpcsapp * field->kolicina
            nNvu -= field->nc * field->kolicina
         ELSEIF field->pu_i == "3"
            // nivelacija
            nMPVU += field->mpcsapp * field->kolicina
         ELSEIF field->pu_i == "I"
            nIzlaz += field->gkolicin2
            nMPVI += field->mpcsapp * field->gkolicin2
            nNVI += field->nc * field->gkolicin2
         ENDIF

         SKIP

      ENDDO

      IF ( Round( nUlaz - nIzlaz, 4 ) <> 0 ) .OR. ( Round( nMpvu - nMpvi, 4 ) <> 0 )

         select_o_roba(  cIdRoba )

         SELECT kalk_pripr
         APPEND BLANK

         hRec := dbf_get_rec()

         hRec[ "idfirma" ] := cIdfirma
         hRec[ "idkonto" ] := cIdkonto
         hRec[ "mkonto" ] := ""
         hRec[ "pkonto" ] := cIdkonto
         hRec[ "mu_i" ] := ""
         hRec[ "pu_i" ] := "I"
         hRec[ "idroba" ] := cIdroba
         hRec[ "idtarifa" ] := roba->idtarifa
         hRec[ "idvd" ] := "IP"
         hRec[ "brdok" ] := cBrdok
         hRec[ "rbr" ] := RedniBroj( ++nRbr )

         // kolicinu odmah setuj na 0
         hRec[ "kolicina" ] := 0

         // popisana kolicina je trenutno stanje
         hRec[ "gkolicina" ] := nUlaz - nIzlaz

         hRec[ "datdok" ] := dDatDok
         hRec[ "datfaktp" ] := dDatdok

         hRec[ "error" ] := ""
         hRec[ "fcj" ] := nMpvu - nMpvi


         IF Round( nUlaz - nIzlaz, 4 ) <> 0 // stanje mpvsapp
            // treba li ovo zaokruzivati ????
            hRec[ "mpcsapp" ] := Round( ( nMPVU - nMPVI ) / ( nUlaz - nIzlaz ), 3 )
            hRec[ "nc" ] := Round( ( nNvu - nNvi ) / ( nUlaz - nIzlaz ), 3 )
         ELSE
            hRec[ "mpcsapp" ] := 0
         ENDIF

         dbf_update_rec( hRec )

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

   RETURN .T.





STATIC FUNCTION VKol()

   LOCAL lMoze := .T.

   IF ( glZabraniVisakIP )
      IF ( _kolicina > _gkolicina )
         MsgBeep( "Nije dozvoljeno evidentiranje viska na ovaj nacin!" )
         lMoze := .F.
      ENDIF
   ENDIF

   RETURN lMoze
