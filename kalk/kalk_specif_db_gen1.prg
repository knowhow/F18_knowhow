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



FUNCTION GenRekap1( aUsl1, aUsl2, aUslR, cKartica, cVarijanta, cKesiraj, fSMark,  cK1, cK7, cK9, cIdKPovrata, aUslSez )

   LOCAL nSec

   IF ( cKesiraj = nil )
      cKesiraj := "N"
   ENDIF

   IF ( fSMark == nil )
      fSMark := .F.
   ENDIF

   IF ( cK1 == nil )
      cK1 := "9999"
   ENDIF

   IF ( cK7 == nil )
      cK7 := "N"
   ENDIF

   IF ( cK9 == nil )
      cK9 := "999"
   ENDIF

   IF ( cIdKPovrata == nil )
      cIdKPovrata := "XXXXXXXX"
   ENDIF

   IF ( aUslSez == nil )
      aUslSez := ".t."
   ENDIF

   nSec := Seconds()

   SELECT kalk
   SET ORDER TO

   PRIVATE cFilt1 := ""

   cFilt1 := "DatDok<=" + cm2str( dDatDo ) + ".and.(" + aUsl1 + ".or." + aUsl2 + ")"

   IF aUslr <> ".t."
      cFilt1 += ".and." + aUslR
   ENDIF

   IF aUslSez <> ".t."
      cFilt1 += ".and." + aUslSez
   ENDIF

   SELECT kalk
   SET FILTER to &cFilt1
   showkorner( rloptlevel() + 100, 1, 66 )

   GO TOP

   nStavki := 0
   Box(, 2, 70 )
   DO WHILE !Eof()
      IF fSMark .AND. SkLoNMark( "ROBA", kalk->idroba )
         SKIP
         LOOP
      ENDIF

      SELECT roba
      hseek kalk->( idroba )
      IF cK7 == "D" .AND. Empty( roba->k7 )
         SELECT kalk
         SKIP
         LOOP
      ENDIF


      IF ( cK1 <> "9999" .AND. !Empty( cK1 ) .AND. roba->k1 <> cK1 )
         SELECT kalk
         SKIP
         LOOP
      ENDIF

      IF ( cK9 <> "999" .AND. !Empty( cK9 ) .AND. roba->k9 <> cK9 )
         SELECT kalk
         SKIP
         LOOP
      ENDIF
	
      SELECT rekap1
      ScanMKonto( dDatOd, dDatDo, cIdKPovrata, cKartica, cVarijanta, cKesiraj )

      SELECT rekap1
      ScanPKonto( dDatOd, dDatDo, cIdKPovrata, cKartica, cVarijanta, cKesiraj )

      IF ( ( ++nStavki % 100 ) == 0 )
         @ m_x + 1, m_y + 2 SAY nStavki PICT "99999999999999"
      ENDIF

      SELECT kalk
      SKIP
   ENDDO

   nStavki := 0

   SELECT roba
   GO TOP
   DO WHILE !Eof()
      IF roba->tip == "N"
         // nova roba
         SELECT pobjekti
         GO TOP
         // za sve objekte
         DO WHILE !Eof()
            SELECT rekap1
            hseek pobjekti->idobj + roba->id
            IF !Found()
               APPEND BLANK
               REPLACE objekat WITH pobjekti->idobj
               REPLACE idroba WITH roba->id
               REPLACE idtarifa WITH roba->idtarifa
               REPLACE g1 WITH roba->k1
               field->mpc := roba->mpc
            ENDIF
            SELECT pobjekti
            SKIP
         ENDDO
      ENDIF
      @ m_x + 1, m_y + 2 SAY "***********************"
      @ m_x + 1, Col() + 2 SAY ++nStavki PICT "99999999999999"
      SELECT roba
      SKIP
   ENDDO

   BoxC()

   nSec := Seconds() -nSec
   IF ( nSec > 1 )
      // nemoj "brze izvjestaje"
      @ 23, 75 SAY nSec PICT "9999"
   ENDIF

   RETURN



FUNCTION ScanMKonto( dDatOd, dDatDo, cIdKPovrata, cKartica, cVarijanta, cKesiraj )

   LOCAL nGGOrd
   LOCAL nGGo
   LOCAL nMpc
   LOCAL cSeek
   LOCAL _rec

   IF Empty( kalk->mKonto )
      RETURN 0
   ENDIF

   hseek kalk->( mKonto + idroba )

   IF !Found()
	
      APPEND BLANK

      _rec := dbf_get_rec()
	
      // radi promjene tarifa promjenio sam kalk->idtarifa u roba->idtarifa
      // replace objekat with kalk->mKonto, idroba with kalk->idroba, idtarifa with kalk->idtarifa, g1 with roba->k1
	
      _rec[ "objekat" ] := kalk->mkonto
      _rec[ "idroba" ] := kalk->idroba
      _rec[ "idtarifa" ] := roba->idtarifa
      _rec[ "g1" ] := roba->k1
	
      IF ( cKartica == "D" )
         // ocitaj sa kartica
         nMpc := 0
         IF ( cVarijanta <> "1" )
            // varijanta="1" - pregled kretanja zaliha
            cSeek := kalk->( idfirma + mKonto + idroba )
            SELECT kalk
            nGGOrd := IndexOrd()
            nGGo := RecNo()
            SELECT koncij
            SEEK Trim( kalk->mKonto )
            SELECT kalk
            // dan prije inventure !!!
            FaktVPC( @nmpc, cSeek, dDatDo - 1 )
            dbSetOrder( nGGOrd )
            GO nGGo

            SELECT rekap1
            _rec[ "mpc" ] := nMpc

         ENDIF
      ELSE

         _rec[ "mpc" ] := roba->mpc

      ENDIF

   ELSE
      _rec := dbf_get_rec()
   ENDIF

   IF kalk->mu_i == "1"

      IF kalk->datdok <= dDatDo
         // stanje zalihe
         _rec[ "k2" ] := _rec[ "k2" ] + kalk->kolicina
      ENDIF

      IF cVarijanta <> "1"
         // u pregledu kretanja zaliha ovo nam ne treba
         IF ( kalk->datdok < dDatOd )
            // predhodno stanje
            _rec[ "k0" ] := _rec[ "k0" ] + kalk->kolicina
         ENDIF
         IF DInRange( kalk->datdok, dDatOd, dDatDo )
            // tekuci prijem
            _rec[ "k4" ] := _rec[ "k4" ] + kalk->kolicina
         ENDIF
      ENDIF

   ELSEIF kalk->mu_i == "5"
      // izlaz iz magacina
      IF cVarijanta <> "1"
         // u pregledu kretanja zaliha ovo nam ne treba
         IF ( kalk->datdok < dDatOd )
            // predhodno stanje
            _rec[ "k0" ] := _rec[ "k0" ] - kalk->kolicina
         ENDIF
      ENDIF
      IF kalk->datdok <= dDatDo
         // stanje trenutne zalihe
         _rec[ "k2" ] := _rec[ "k2" ] - kalk->kolicina
      ENDIF

      IF kalk->idvd $ "14#94"
         IF ( cVarijanta <> "1" )
            // u pregledu kretanja zaliha ovo nam ne treba
            IF ( kalk->datdok <= dDatDo )
               // kumulativna prodaja
               _rec[ "k3" ] := _rec[ "k3" ] + kalk->kolicina
            ENDIF
         ENDIF
         IF DInRange( kalk->datDok, dDatOd, dDatDo )
            // stanje trenutne prodaje
            _rec[ "k1" ] := _rec[ "k1" ] + kalk->kolicina
         ENDIF
      ENDIF

   ELSEIF ( kalk->mu_i == "3" )
      // nivelacija
      IF ( kalk->datDok = dDatDo )
         // dokument nivelacije na dan inventure
         IF ( cVarijanta <> "1" )
            _rec[ "novampc" ] := kalk->mpcsapp + kalk->vpc
         ENDIF
         _rec[ "mpc" ] := kalk->mpcsapp
      ENDIF
   ENDIF

   dbf_update_rec( _rec )

   RETURN 1



FUNCTION ScanPKonto( dDatOd, dDatDo, cIdKPovrata, cKartica, cVarijanta, cKesiraj )

   LOCAL nGGOrd
   LOCAL nGGo
   LOCAL nMpc
   LOCAL cSeek
   LOCAL _rec

   IF Empty( kalk->pkonto )
      RETURN 0
   ENDIF

   HSEEK kalk->( pkonto + idroba )

   IF !Found()

      APPEND BLANK

      _rec := dbf_get_rec()

      _rec[ "objekat" ] := kalk->pkonto
      _rec[ "idroba" ] := kalk->idroba
      _rec[ "idtarifa" ] := roba->idtarifa
      _rec[ "g1" ] := roba->k1
	
      IF ( cKartica == "D" )
         // ocitaj sa kartica
         nMpc := 0
         cSeek := kalk->( idfirma + pkonto + idroba )
         SELECT kalk
         nGGo := RecNo()
         nGGOrd := IndexOrd()
         SELECT koncij
         SEEK Trim( kalk->pkonto )
         SELECT kalk
         // dan prije inventure !!!
         FaktMPC( @nmpc, cSeek, dDatDo - 1 )
         dbSetOrder( nGGOrd )
         GO nGGo
         SELECT rekap1
         _rec[ "mpc" ] := nMpc
      ELSE
         _rec[ "mpc" ] := roba->mpc
      ENDIF

   ELSE

      _rec := dbf_get_rec()

   ENDIF

   IF ( kalk->pu_i == "1" .AND. kalk->kolicina > 0 )
	
      // ulaz moze biti po osnovu prijema, 80 - preknjizenja
      // odnosno internog dokumenta

      IF kalk->datdok <= dDatDo  // kumulativno stanje
         _rec[ "k2" ] += kalk->kolicina  // zalihe
      ENDIF
      IF ( cVarijanta <> "1" )
         IF kalk->datdok < dDatOd
            // predhodno stanje
            _rec[ "k0" ] += kalk->kolicina
         ENDIF
         IF DInRange( kalk->datdok, dDatOd, dDatDo )
            // tekuci prijem
            _rec[ "k4" ] += kalk->kolicina
         ENDIF
      ELSE
         IF DInRange( kalk->datdok, dDatOd, dDatDo )
            // tekuci prijem
            IF kalk->idvd == "80" .AND. !Empty( kalk->idkonto2 )
               // bilo je promjena po osnovu predispozicije
               _rec[ "k4pp" ] += kalk->kolicina
            ENDIF
         ENDIF
      ENDIF

   ELSEIF ( kalk->pu_i == "3" )

      // nivelacija
      IF kalk->datdok = dDatDo
         // dokument nivelacije na dan inventure
         IF cVarijanta <> "1"
            _rec[ "novampc" ] := kalk->( fcj + mpcsapp )
         ENDIF
         // stara cijena
         _rec[ "mpc" ] := kalk->fcj

      ENDIF

   ELSEIF kalk->pu_i == "5" .OR. ( kalk->pu_i == "1" .AND. kalk->kolicina < 0 )

      // izlaz iz prodavnice moze biti 42,41,11,12,13
      // f1 - tekuca prodaja, f2 zaliha, f3 - kumulativna prodaja
      // f4 - prijem u toku mjeseca
      // f6 - izlaz iz prodavnice po ostalim osnovama
      // f5 - reklamacije u toku mjeseca, f7 - reklamacije u toku godine

      IF ( cVarijanta <> "1" )
         IF kalk->datdok < dDatOd
            IF kalk->pu_i == "5"
               // predhodno stanje
               _rec[ "k0" ] -= kalk->kolicina
            ELSE
               _rec[ "k0" ] -= Abs( kalk->kolicina )
            ENDIF
         ENDIF
      ENDIF

      IF ( kalk->datdok <= dDatDo )
         IF kalk->pu_i == "5"
            // zaliha
            _rec[ "k2" ] -= kalk->kolicina
         ELSE
            _rec[ "k2" ] -= Abs( kalk->kolicina )
         ENDIF
      ENDIF

      IF ( kalk->idvd $ "41#42#43" )
         // prodaja
         IF DInRange( kalk->datdok, dDatOd, dDatDo )
            // tekuca prodaja
            _rec[ "k1" ] += kalk->kolicina
         ENDIF
         IF ( cVarijanta <> "1" )
            IF kalk->datdok <= dDatDo
               // kumulativna prodaja
               _rec[ "k3" ] += kalk->kolicina
            ENDIF
         ENDIF

      ELSE

         // izlazi iz prodavnice po ostalim osnovima
		
         IF ( cVarijanta <> "1" )
            IF ( kalk->idvd $ "11#12#13" .AND. kalk->mKonto == cIdKPovrata )
               // reklamacija
               IF DInRange( kalk->datdok, dDatOd, dDatDo )
                  // tekuce reklamacije
                  // reklamacije u mjesecu
                  _rec[ "k5" ] += Abs( kalk->kolicina )
               ENDIF
               IF kalk->datdok <= dDatDo
                  // kumulativno reklamacije
                  _rec[ "k7" ] += Abs( kalk->kolicina )
               ENDIF
            ELSE
               IF DInRange( kalk->datdok, dDatOd, dDatDo )
                  // izlaz-otprema po ostalim osnovama
                  _rec[ "k6" ] += Abs( kalk->kolicina )
               ENDIF
            ENDIF
         ELSE
            IF DInRange( kalk->datdok, dDatOd, dDatDo )
               IF kalk->idvd == "80" .AND. !Empty( kalk->idkonto2 )
                  // bilo je promjena po osnovu predispozicije
                  _rec[ "k4pp" ] += kalk->kolicina
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   dbf_update_rec( _rec )

   RETURN 1
