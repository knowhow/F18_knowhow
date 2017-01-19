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




FUNCTION unos_osnovnih_sredstava()

   LOCAL _rec
   LOCAL _id_am
   PRIVATE cId := Space( 10 )
   PRIVATE cIdRj := Space( 4 )

   Box( "#UNOS PROMJENA NAD STALNIM SREDSTVIMA", maxrows() -5, maxcols() -5 )

   DO WHILE .T.

      BoxCLS()

      _o_tables()

      SET CURSOR ON

      cPicSif := "@!"

      IF gIBJ == "D"

         @ m_x + 1, m_y + 2 SAY "Sredstvo:       " GET cId VALID P_OS( @cId, 1, 35 ) PICT cPicSif

         READ

         nDbfArea := Select()

         select_os_sii()
         GO TOP
         SEEK cId
         cIdRj := field->idrj
         _id_am := field->idam

         SELECT ( nDbfArea )

         @ m_x + 2, m_y + 2 SAY "Radna jedinica: " GET cIdRj VALID {|| P_RJ( @cIdRj, 2, 35 ), cIdRj := PadR( cIdRj, 4 ), .T. }
         READ

         ESC_BCR

      ELSE

         DO WHILE .T.

            @ m_x + 1, m_y + 2 SAY "Sredstvo:       " GET cId PICT cPicSif
            @ m_x + 2, m_y + 2 SAY "Radna jedinica: " GET cIdRj
            READ

            ESC_BCR

            select_os_sii()
            SEEK cId
            _id_am := field->idam

            DO WHILE !Eof() .AND. cId == field->id .AND. cIdRJ != field->idrj
               SKIP 1
            ENDDO

            IF cID != field->id .OR. cIdRJ != field->idrj
               Msg( "Izabrano sredstvo ne postoji!", 5 )
            ELSE
               SELECT RJ
               SEEK cIdRj

               IF gOsSii == "O"
                  @ m_x + 1, m_y + 35 SAY os->naz
               ELSE
                  @ m_x + 1, m_y + 35 SAY sii->naz
               ENDIF

               @ m_x + 2, m_y + 35 SAY RJ->naz

               EXIT

            ENDIF

         ENDDO

      ENDIF

      SELECT amort
      HSEEK _id_am

      select_os_sii()

      IF ( cIdrj <> field->idrj )

         IF Pitanje(, "Jeste li sigurni da zelite promijeniti radnu jedinicu ovom sredstvu? (D/N)", " " ) == "D"
            _rec := dbf_get_rec()
            _rec[ "idrj" ] := cIdRj
            update_rec_server_and_dbf( get_os_table_name( Alias() ), _rec, 1, "FULL" )
         ELSE
            cIdRj := field->idrj
            SELECT RJ
            SEEK cIdRj
            select_os_sii()
            @ m_x + 2, m_y + 2 SAY "Radna jedinica: " GET cIdRj
            @ m_x + 2, m_y + 35 SAY RJ->naz
            CLEAR GETS
         ENDIF
      ENDIF

      @ m_x + 3, m_y + 2 SAY "Datum nabavke: "
      ?? field->datum

      IF !Empty( field->datotp )
         @ m_x + 3, m_y + 38 SAY "Datum otpisa: "
         ?? field->datotp
      ENDIF

      @ m_x + 4, m_y + 2 SAY "Nabavna vr.:"
      ?? Transform( field->nabvr, gPicI )
      @ m_x + 4, Col() + 2 SAY "Ispravka vr.:"
      ?? Transform( field->otpvr, gPicI )
      aVr := { field->nabvr, field->otpvr, 0 }

      // recno(), datum, DatOtp, NabVr, OtpVr, KumAmVr
      aSred := { { 0, field->datum, field->datotp, field->nabvr, field->otpvr, 0 } }

      PRIVATE dDatNab := field->datum
      PRIVATE dDatOtp := field->datotp
      PRIVATE cOpisOtp := field->opisotp

      select_promj()

      ImeKol := {}

      AAdd( ImeKol, { "DATUM",            {|| datum }                          } )
      AAdd( ImeKol, { "OPIS",             {|| opis }                          } )
      AAdd( ImeKol, { PadR( "Nabvr", 11 ),   {|| Transform( nabvr, gpici ) }     } )
      AAdd( ImeKol, { PadR( "OtpVr", 11 ),   {|| Transform( otpvr, gpici ) }     } )
      AAdd( ImeKol, { PadR( "Kumul.SadVr", 11 ), {|| Transform( PSadVr(), gpici ) }     } )

      Kol := {}

      FOR i := 1 TO Len( ImeKol )
         AAdd( Kol, i )
      NEXT

      SET CURSOR ON

      @ m_x + 20, m_y + 2 SAY "<ENT> Ispravka, <c-T> Brisi, <c-N> Nove prom, <c-O> Otpis, <c-I> Novi ID"

      ShowSadVr()

      DO WHILE .T.
         BrowseKey( m_x + 8, m_y + 1, m_x + maxrows() - 5, m_y + maxcols() -5, ImeKol, {| Ch| unos_os_key_handler( Ch ) }, "id==cid", cId, 2, NIL, NIL, {|| PSadVr() < 0 } )
         IF ( aVr[ 1 ] -aVr[ 2 ] >= 0 )
            IF aVr[ 3 ] < 0
               MsgBeep( "Greska: sadasnja vrijednost sa uracunatom amortizacijom manja od nule! #Ispravite gresku!" )
            ELSE
               EXIT
            ENDIF
         ELSE
            MsgBeep( "Greska: sadasnja vrijednost manja od nule ! Ispravite gresku !" )
         ENDIF
         EXIT

      ENDDO

      my_close_all_dbf()
   ENDDO

   BoxC()

   my_close_all_dbf()

   RETURN


FUNCTION unos_os_key_handler( Ch )

   LOCAL cDn := "N"
   LOCAL nRet := DE_CONT
   LOCAL nRec0 := RecNo()
   LOCAL _rec
   LOCAL _t_rec
   LOCAL _novi
   LOCAL _prom_dat, _prom_opis, _prom_nv, _prom_ov

   DO CASE

   CASE ( Ch == K_ENTER .AND. !( Eof() .OR. Bof() ) ) .OR. Ch == K_CTRL_N

      IF Ch == K_CTRL_N
         GO BOTTOM
         SKIP 1
      ENDIF

      _rec := dbf_get_rec()

      _prom_dat := _rec[ "datum" ]
      _prom_opis := _rec[ "opis" ]
      _prom_nv := _rec[ "nabvr" ]
      _prom_ov := _rec[ "otpvr" ]

      Box(, 5, 50 )
      @ m_x + 1, m_y + 2 SAY "Datum:" GET _prom_dat VALID os_validate_date( @_prom_dat )
      @ m_x + 2, m_y + 2 SAY "Opis:"  GET _prom_opis
      @ m_x + 4, m_y + 2 SAY "nab vr" GET _prom_nv PICT "9999999.99"
      @ m_x + 5, m_y + 2 SAY "OTP vr" GET _prom_ov PICT "9999999.99"
      READ
      BoxC()

      IF LastKey() == K_ESC
         GO ( nRec0 )
         nRet := DE_CONT
      ELSE

         IF CH == K_CTRL_N
            APPEND BLANK
         ENDIF

         _rec[ "id" ] := cId
         _rec[ "opis" ] := _prom_opis
         _rec[ "datum" ] := _prom_dat
         _rec[ "nabvr" ] := _prom_nv
         _rec[ "otpvr" ] := _prom_ov

         update_rec_server_and_dbf( get_promj_table_name( Alias() ), _rec, 1, "FULL" )

         ShowSadVr()

         nRet := DE_REFRESH

      ENDIF

   CASE Ch == K_CTRL_T

      IF pitanje(, "Sigurno zelite izbrisati promjenu ?", "N" ) == "D"
         _rec := dbf_get_rec()
         delete_rec_server_and_dbf( get_promj_table_name( Alias() ), _rec, 1, "FULL" )
         ShowSadVr()
      ENDIF

      RETURN DE_REFRESH

   CASE Ch == K_CTRL_O

      select_os_sii()
      nKolotp := field->kolicina

      Box(, 5, 50 )

      @ m_x + 1, m_y + 2 SAY "Otpis sredstva"
      @ m_x + 3, m_y + 2 SAY "Datum: " GET dDatOtp VALID dDatOtp > dDatNab .OR. Empty( dDatOtp )
      @ m_x + 4, m_y + 2 SAY "Opis : " GET cOpisOtp

      IF field->kolicina > 1
         @ m_x + 5, m_y + 2 SAY "Kolicina koja se otpisuje:" GET nKolotp PICT "999999.99" VALID ( nKolotp <= field->kolicina .AND. nKolotp >= 1 )
      ENDIF

      READ

      BoxC()

      IF LastKey() == K_ESC
         select_promj()
         RETURN DE_CONT
      ENDIF

      fRastavljeno := .F.

      IF nKolotp < field->kolicina

         select_os_sii()

         _rec := dbf_get_rec()

         nNabVrJ := _rec[ "nabvr" ] / _rec[ "kolicina" ]
         nOtpVrJ := _rec[ "otpvr" ] / _rec[ "kolicina" ]

         // postojeci inv broj
         _rec[ "kolicina" ] := _rec[ "kolicina" ] - nKolOtp
         _rec[ "nabvr" ] := nNabVrj * _rec[ "kolicina" ]
         _rec[ "otpvr" ] := nOtpVrj * _rec[ "kolicina" ]

         update_rec_server_and_dbf( get_os_table_name( Alias() ), _rec, 1, "FULL" )

         // dodaj novi zapis...
         _rec := dbf_get_rec()

         APPEND BLANK

         _rec[ "kolicina" ] := nKolOtp
         _rec[ "nabvr" ] := nNabvrj * nKolotp
         _rec[ "otpvr" ] := nOtpvrj * nKolotp
         _rec[ "id" ] := Left( _rec[ "id" ], 9 ) + "O"
         _rec[ "datotp" ] := dDatotp
         _rec[ "opisotp" ] := cOpisOtp

         update_rec_server_and_dbf( get_os_table_name( Alias() ), _rec, 1, "FULL" )

         fRastavljeno := .T.

      ELSE

         select_os_sii()

         _rec := dbf_get_rec()
         _rec[ "datotp" ] := dDatOtp
         _rec[ "opisotp" ] := cOpisOtp

         update_rec_server_and_dbf( get_os_table_name( Alias() ), _rec, 1, "FULL" )

      ENDIF

      select_promj()

      @ m_x + 5, m_y + 38 SAY "Datum otpisa: "

      IF gOsSii == "O"
         ?? os->datotp
      ELSE
         ?? sii->datotp
      ENDIF

      IF fRastavljeno
         Msg( "Postojeci inv broj je rastavljen na dva-otpisani i neotpisani" )
         RETURN DE_ABORT
      ELSE
         RETURN DE_REFRESH
      ENDIF

   CASE Ch == K_CTRL_I

      Box(, 4, 50 )
      _novi := Space( 10 )
      @ m_x + 1, m_y + 2 SAY "Promjena inventurnog broja:"
      @ m_x + 3, m_y + 2 SAY "Novi inventurni broj:" GET _novi VALID !Empty( _novi )
      READ
      BoxC()

      ESC_RETURN DE_CONT

      select_os_sii()

      SEEK _novi

      IF Found()
         Beep( 1 )
         Msg( "Vec postoji sredstvo sa istim inventurnim brojem !" )
      ELSE

         select_promj()
         SEEK cId

         _t_rec := 0

         DO WHILE !Eof() .AND. cId == field->id
            SKIP
            _t_rec := RecNo()
            SKIP -1
            _rec := dbf_get_rec()
            _rec[ "id" ] := _novi
            update_rec_server_and_dbf( get_promj_table_name( Alias() ), _rec, 1, "FULL" )
            GO ( _t_rec )
         ENDDO
         SEEK _novi

         select_os_sii()
         SEEK cId
         _rec := dbf_get_rec()
         _rec[ "id" ] := _novi
         update_rec_server_and_dbf( get_os_table_name( Alias() ), _rec, 1, "FULL" )
         cId := _novi
      ENDIF

      select_promj()
      RETURN DE_REFRESH

   OTHERWISE
      RETURN DE_CONT

   ENDCASE

   RETURN nRet


// ------------------------------------------------------------------------
// 1) izracunaj i prikazi sadasnju vrijednost
// 2) izracunaj i kumulativ amortizacije u aSred
// ------------------------------------------------------------------------
FUNCTION ShowSadVr()

   LOCAL _arr := Select()
   LOCAL _t_rec := 0
   LOCAL nI := 0

   // polja os/sii
   aVr[ 1 ] := field->nabvr
   aVr[ 2 ] := field->otpvr

   select_promj()

   _t_rec := RecNo()

   SEEK cId

   FOR nI := Len( aSred ) TO 1 STEP -1
      IF aSred[ nI, 1 ] > 0 .AND. aSred[ nI, 1 ] < 999999
         ADel( aSred, nI )
         ASize( aSred, Len( aSred ) - 1 )
      ENDIF
   NEXT

   DO WHILE !Eof() .AND. field->id == cID
      aVr[ 1 ] += field->nabvr
      aVr[ 2 ] += field->otpvr
      AAdd( aSred, { RecNo(), field->datum, IF( gOsSii == "O", os->datotp, sii->datotp ), field->nabvr, field->otpvr, 0 } )
      SKIP 1
   ENDDO

   ASort( aSred,,, {| x, y| x[ 2 ] < y[ 2 ] } )

   nI := 1

   FOR nI := 1 TO Len( aSred )
      _nabvr := aSred[ nI, 4 ]
      _otpvr := aSred[ nI, 5 ]
      _amd := 0
      _amp := 0
      nOstalo := 0
      _datum := aSred[ nI, 2 ]
      _datotp := aSred[ nI, 3 ]
      izracunaj_os_amortizaciju( _datum, iif( !Empty( _datotp ), Min( os_datum_obracuna(), _datotp ), os_datum_obracuna() ), 100 )
      // napuni _amp
      aSred[ nI, 6 ] = _amp
   NEXT

   SKIP -1
   IF field->id == cId
      aVr[ 3 ] := PSadVr()
   ENDIF

   @ m_x + 6, m_y + 1 SAY " UKUPNO:   Nab.vr.="         COLOR "W+/B"
   @ Row(), Col()  SAY TRANS( aVr[ 1 ], "9999999.99" )        COLOR "GR+/B"
   @ Row(), Col()  SAY ",    Otp.vr.="         COLOR "W+/B"
   @ Row(), Col()  SAY TRANS( aVr[ 2 ], "9999999.99" )        COLOR "GR+/B"
   @ Row(), Col()  SAY ",    Sad.vr.="         COLOR "W+/B"
   @ Row(), Col()  SAY TRANS( aVr[ 1 ] - aVr[ 2 ], "9999999.99" ) COLOR IF( aVr[ 1 ] - aVr[ 2 ] < 0, "GR+/R", "GR+/B" )
   @ m_x + 7, m_y + 1 SAY "           Sadasnja vrijednost sa uracunatom amortizacijom=" COLOR "W+/B"
   @ Row(), Col()  SAY TRANS( aVr[ 3 ], "9999999.99" )        COLOR IF( aVr[ 3 ] < 0, "GR+/R", "GR+/B" )

   GO ( _t_rec )
   SELECT ( _arr )

   RETURN



FUNCTION PSadVr()

   LOCAL _n := 0
   LOCAL nI := 0

   FOR nI := 1 TO Len( aSred )
      _n += ( aSred[ nI, 4 ] -aSred[ nI, 5 ] -aSred[ nI, 6 ] )
      IF nI == Len( aSred )
         aVr[ 3 ] := _n
      ENDIF
      IF aSred[ nI, 1 ] == RecNo()
         EXIT
      ENDIF
   NEXT

   RETURN _n




FUNCTION os_validate_date( os_date )

   LOCAL _ret := .T.

   IF os_date <= dDatNab
      Beep( 1 )
      Msg( "Datum promjene mora biti veci od datuma nabavke !" )
      _ret := .F.
   ENDIF

   IF !Empty( dDatOtp ) .AND. os_date >= dDatOtp
      Beep( 1 )
      Msg( "Datum promjene mora biti manji od datuma otpisa !" )
      _ret := .F.
   ENDIF

   RETURN _ret



STATIC FUNCTION _o_tables()

   O_K1
   O_RJ
   o_konto()
   O_AMORT
   O_REVAL
   o_os_sii()
   o_os_sii_promj()

   RETURN
