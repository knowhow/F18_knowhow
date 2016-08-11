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

FUNCTION kalk_get_nabavna_prod( cIdFirma, cIdroba, cIdkonto, nKolicina, nKolZN, nNC, nSrednjaNabavnaCijena, dDatNab )

   LOCAL nPom, fProso
   LOCAL nIzlNV
   LOCAL nIzlKol
   LOCAL nUlNV
   LOCAL nUlKol
   LOCAL nSkiniKol
   LOCAL nZadnjaUlaznaNC
   LOCAL nTmp
   LOCAL nTmp_n_stanje, nTmp_n_nv, nTmp_s_nv

   nKolicina := 0

   IF lAutoObr == .T.

      IF knab_cache( cIdKonto, cIdroba, @nUlKol, @nIzlKol, @nKolicina,  @nUlNv, @nIzlNv, @nNc ) == 1 // uzmi stanje iz cache tabele
         SELECT kalk_pripr
         RETURN .F.
      ENDIF
   ENDIF

   find_kalk_by_pkonto_idroba( cIdFirma, cIdKonto, cIdRoba )
   GO BOTTOM

   IF cIdfirma + cIdkonto + cIdroba == field->idfirma + field->pkonto + field->idroba .AND. _datdok < field->datdok

      error_bar( "KA_" + cIdfirma + "-" + cIdkonto + "-" + cIdroba, " KA_KART_PROD " + cIdkonto + "-" + Trim( cIdroba ) + " postoje stavke na datum< " + DToC( field->datdok ) )
      _ERROR := "1"
   ENDIF


   nLen := 1

   nKolicina := 0


   nIzlNV := 0 // ukupna izlazna nabavna vrijednost
   nIzlKol := 0 // ukupna izlazna kolicina
   nUlNV := 0
   nUlKol := 0 // ulazna kolicina
   nZadnjaUlaznaNC := 0


   GO TOP
   DO WHILE !Eof() .AND. cIdFirma + cIdKonto + cIdroba == idFirma + pkonto + idroba .AND. _datdok >= datdok

      IF field->pu_i == "1" .OR. field->pu_i == "5"
         IF ( field->pu_i == "1" .AND. field->kolicina > 0 ) .OR. ( field->pu_i == "5" .AND. field->kolicina < 0 )
            nKolicina += Abs( field->kolicina )       // rad metode prve i zadnje nc moramo
            nUlKol    += Abs( field->kolicina )       // sve sto udje u magacin strpati pod
            nUlNV     += ( Abs( field->kolicina ) * field->nc )  // ulaznom kolicinom

            IF field->idvd $ "10#16#96"
               nZadnjaUlaznaNC := field->nc
            ENDIF

         ELSE
            nKolicina -= Abs( field->kolicina )
            nIzlKol   += Abs( field->kolicina )
            nIzlNV    += ( Abs( field->kolicina ) * field->nc )
         ENDIF

      ELSEIF field->pu_i == "I"
         nKolicina -= field->gkolicin2
         nIzlKol += field->gkolicin2
         nIzlNV += field->nc * field->gkolicin2
      ENDIF
      SKIP

   ENDDO


   IF Round( nKolicina, 5 ) == 0
      nSrednjaNabavnaCijena := 0
   ELSE
      nSrednjaNabavnaCijena := ( nUlNV - nIzlNV ) / nKolicina
   ENDIF


   IF prag_odstupanja_nc_sumnjiv() > 0 .AND. nSrednjaNabavnaCijena <> 0 .AND. nZadnjaUlaznaNC <> 0  // ako se koristi kontrola NC

      nTmp := Round( nSrednjaNabavnaCijena, 4 ) - Round( nZadnjaUlaznaNC, 4 )
      nOdst := ( nTmp / Round( nZadnjaUlaznaNC, 4 ) ) * 100

      IF Abs( nOdst ) > prag_odstupanja_nc_sumnjiv()

         Beep( 4 )
         IF nije_dozvoljeno_azuriranje_sumnjivih_stavki()
            CLEAR TYPEAHEAD // zaustavi asistenta
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

   IF Abs( Round( nSrednjaNabavnaCijena, 4 ) ) == 0 .AND. roba->vpc != 0
      nSrednjaNabavnaCijena := Round( roba->vpc / ( 1 + standardna_stopa_marze() / 100 ), 4 )
   ENDIF
   SELECT kalk_pripr

   RETURN .T.
