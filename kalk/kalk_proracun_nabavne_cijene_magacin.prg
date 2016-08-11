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

/*
  Racuna nabavnu cijenu i stanje robe u magacinu
   kalk_get_nabavna_mag(cIdFirma, cIdRoba, cIdKonto, 4-nKolicina, 5-nKolZN, 6-nNC, 7-nSrednjaNabavnaCijena, 8-dDatNab)

  4) kolicina na stanju
  5) nKolZN - kolicina koja je na stanju od zadnje nabavke
  6) nNC - zadnja nabavna cijena
  7) nSrednjaNabavnaCijena - srednja nabavna cijena
  8) param dDatNab - datum nabavke

*/

FUNCTION kalk_get_nabavna_mag( cIdFirma, cIdRoba, cIdKonto, nKolicina, nKolZN, nNC, nSrednjaNabavnaCijena, dDatNab )

   LOCAL nPom
   LOCAL fProso
   LOCAL nIzlNV
   LOCAL nIzlKol
   LOCAL nUlNV
   LOCAL nUlKol
   LOCAL nSkiniKol
   LOCAL nKolNeto
   LOCAL nZadnjaUlaznaNC
   LOCAL nKol_poz := 0 // posljednje pozitivno stanje
   LOCAL nUVr_poz, nIVr_poz
   LOCAL nUKol_poz, nIKol_poz
   LOCAL nTmp
   LOCAL nTmp_n_stanje, nTmp_n_nv, nTmp_s_nv

   nKolicina := 0

   IF lAutoObr == .T.

      IF knab_cache( cIdKonto, cIdroba, @nUlKol, @nIzlKol, @nKolicina, @nUlNv, @nIzlNv, @nSrednjaNabavnaCijena ) == 1   // uzmi stanje iz cache tabele
         SELECT kalk_pripr
         RETURN .T.
      ENDIF
   ENDIF

   my_use_refresh_stop()


   find_kalk_by_mkonto_idroba( cIdFirma, cIdKonto, cIdRoba )
   GO BOTTOM

   IF ( ( cIdFirma + cIdKonto + cIdRoba ) == ( field->idfirma + field->mkonto + field->idroba ) ) .AND. _datdok < field->datdok
      error_bar( "KA_" + cIdfirma + "/" + cIdKonto + "/" + cIdRoba, "Postoji dokument " + field->idfirma + "-" + field->idvd + "-" + field->brdok + " na datum: " + DToC( field->datdok ), 4 )
      _ERROR := "1"
   ENDIF

   nLen := 1

   nKolicina := 0
   nIzlNV := 0  // ukupna izlazna nabavna vrijednost
   nUlNV := 0
   nIzlKol := 0 // ukupna izlazna kolicina
   nUlKol := 0 // ulazna kolicina
   nZadnjaUlaznaNC := 0


   // ovo je prvi prolaz, u njemu se proracunava totali za jednu karticu
   GO TOP
   DO WHILE !Eof() .AND. ( ( cIdFirma + cIdKonto + cIdRoba ) == ( idFirma + mkonto + idroba ) ) .AND. _datdok >= datdok

      IF field->mu_i == "1" .OR. field->mu_i == "5"

         IF field->IdVd == "10"
            // kod 10-ki je originalno predvidjeno gubitak kolicine (kalo i rastur)
            // mislim da ovo niko i ne koristi, ali eto neka stoji
            nKolNeto := Abs( field->kolicina - field->gKolicina - field->gKolicin2 )
         ELSE
            nKolNeto := Abs( field->kolicina )
         ENDIF

         IF ( field->mu_i == "1" .AND.  field->kolicina > 0 ) .OR. ( field->mu_i == "5" .AND. field->kolicina < 0 )


            nKolicina += nKolNeto // ulazi plus, storno izlaza
            nUlKol    += nKolNeto
            nUlNV     += ( nKolNeto * field->nc )


            IF field->idvd $ "10#16#96" // zapamti uvijek zadnju ulaznu NC
               nZadnjaUlaznaNC := field->nc
            ENDIF

         ELSE

            nKolicina -= nKolNeto
            nIzlKol   += nKolNeto
            nIzlNV    += ( nKolNeto * field->nc )

         ENDIF


         IF Round( nKolicina, 8 ) > 0  // ako je kolicinsko stanje pozitivno zapamti ga

            nKol_poz := nKolicina

            nUKol_poz := nUlKol
            nIKol_poz := nIzlKol

            nUVr_poz := nUlNv
            nIVr_poz := nIzlNv
         ENDIF


      ENDIF
      SKIP

   ENDDO // ovo je bio prvi prolaz

   IF Round( nKol_poz, 8 ) == 0 // utvrdi srednju nabavnu cijenu na osnovu posljednjeg pozitivnog stanja
      nSrednjaNabavnaCijena := 0
   ELSE
      nSrednjaNabavnaCijena := ( nUVr_poz - nIVr_poz ) / nKol_poz // srednja nabavna cijena
   ENDIF


   IF prag_odstupanja_nc_sumnjiv() > 0 .AND. nSrednjaNabavnaCijena <> 0 .AND. nZadnjaUlaznaNC <> 0 // ako se koristi kontrola NC

      nTmp := Round( nSrednjaNabavnaCijena, 4 ) - Round( nZadnjaUlaznaNC, 4 )
      nOdst := ( nTmp / Round( nZadnjaUlaznaNC, 4 ) ) * 100

      IF Abs( nOdst ) > prag_odstupanja_nc_sumnjiv()

         Beep( 4 )
         IF nije_dozvoljeno_azuriranje_sumnjivih_stavki()
            CLEAR TYPEAHEAD
         ENDIF

         MsgBeep( "Odstupanje u odnosu na zadnji ulaz je#" + AllTrim( Str( Abs( nOdst ) ) ) + " %" + "#" + ;
            "artikal: " + AllTrim( _idroba ) + " " + PadR( roba->naz, 15 ) + " nc:" + AllTrim( Str( nSrednjaNabavnaCijena, 12, 2 ) ) )

         // a_nc_ctrl( @aNC_ctrl, idroba, nKolicina, ;
         // nSrednjaNabavnaCijena, nZadnjaUlaznaNC )


         IF Pitanje(, "Napraviti korekciju NC (D/N)?", "N" ) == "D"

            nTmp_n_stanje := ( nKolicina - _kolicina )
            nTmp_n_nv := ( nTmp_n_stanje * nZadnjaUlaznaNC )
            nTmp_s_nv := ( nKolicina * nSrednjaNabavnaCijena )

            nSrednjaNabavnaCijena := ( ( nTmp_s_nv - nTmp_n_nv ) / _kolicina )

         ENDIF
      ENDIF

   ENDIF

   nKolicina := Round( nKolicina, 4 )

   // ako je nabavna cijena 0, ponuditi cijenu koja je roba.vpc / ( 1 + standardna_stopa_marze )
   // npr. vpc=1, standarna_stopa_marze = 20%, nc=0.8
   IF Abs( Round( nSrednjaNabavnaCijena, 4 ) ) == 0 .AND. roba->vpc != 0
      nSrednjaNabavnaCijena := Round( roba->vpc / ( 1 + standardna_stopa_marze() / 100 ), 4 )
   ENDIF

   SELECT kalk_pripr
   my_use_refresh_start()

   RETURN .T.
