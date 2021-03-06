/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2018 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

MEMVAR _datdok

FUNCTION kalk_get_nabavna_prod( cIdFirma, cIdroba, cIdkonto, nKolicina, nKolZN, ;
      nNcZadnjaNabavka, nSrednjaNabavnaCijena, dDatNab, ;
      nSrednjaNcPoUlazima, nNabavnaVrijednost, lSilent )

   LOCAL nPom
   LOCAL nIzlNV
   LOCAL nIzlKol
   LOCAL nUlNV
   LOCAL nUlKol
   LOCAL nSkiniKol
   LOCAL nTmp, nLen
   LOCAL nUlaziNV := 0, nUlaziKolicina := 0

   nKolicina := 0
   hb_default( @lSilent, .F. )
/*
  -- IF lAutoObr == .T.

      IF knab_cache( cIdKonto, cIdroba, @nUlKol, @nIzlKol, @nKolicina,  @nUlNv, @nIzlNv, @nNc ) == 1 // uzmi stanje iz cache tabele
         SELECT kalk_pripr
         RETURN .F.
      ENDIF
   ENDIF
*/

   IF Empty( kalk_metoda_nc() )
      RETURN .F.
   ENDIF

   MsgO( "Proračun stanja u prodavnici: " + AllTrim( cIdKonto ) + "/" + cIdRoba )

   find_kalk_by_pkonto_idroba( cIdFirma, cIdKonto, cIdRoba )
   GO BOTTOM

   IF cIdfirma + cIdkonto + cIdroba == field->idfirma + field->pkonto + field->idroba .AND. _datdok < field->datdok
      error_bar( "KA_" + cIdfirma + "-" + Trim( cIdkonto )  + "-" + Trim( cIdroba ), ;
         " KA_PROD " + Trim( cIdkonto ) + "-" + Trim( cIdroba ) + " postoje stavke na datum " + DToC( field->datdok ) )
      // _ERROR := "1"
   ENDIF

   nLen := 1
   nKolicina := 0

   nIzlNV := 0 // ukupna izlazna nabavna vrijednost
   nIzlKol := 0 // ukupna izlazna kolicina
   nUlNV := 0
   nUlKol := 0 // ulazna kolicina
   nNcZadnjaNabavka := 0
   nKolZN := 0

   GO TOP
   DO WHILE !Eof() .AND. cIdFirma + cIdKonto + cIdroba == field->idFirma + field->pkonto + field->idroba ;
         .AND. _datdok >= field->datdok

      IF field->pu_i == "1" .OR. field->pu_i == "5"
         IF ( field->pu_i == "1" .AND. field->kolicina > 0 ) .OR. ( field->pu_i == "5" .AND. field->kolicina < 0 )
            nKolicina += Abs( field->kolicina )       // rad metode prve i zadnje nc moramo
            nUlKol    += Abs( field->kolicina )       // sve sto udje u magacin strpati pod
            nUlNV     += ( Abs( field->kolicina ) * field->nc )  // ulaznom kolicinom

            IF field->idvd $ "11#80#81" .AND. field->kolicina > 0
               nNcZadnjaNabavka := field->nc
               nKolZn := field->kolicina

               nUlaziNV += field->nc * field->kolicina
               nUlaziKolicina += field->kolicina
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

   IF Round( nUlaziKolicina, 4 ) <> 0
      nSrednjaNcPoUlazima := nUlaziNV / nUlaziKolicina
   ELSE
      nSrednjaNcPoUlazima := 0
   ENDIF

   nNabavnaVrijednost :=  ( nUlNv - nIzlNv  )

   // IF Round( nKol_poz, 8 ) == 0 // utvrdi srednju nabavnu cijenu na osnovu posljednjeg pozitivnog stanja
   IF Round( nKolicina, 4 ) == 0
      nSrednjaNabavnaCijena := 0
   ELSE
      // nSrednjaNabavnaCijena := ( nUVr_poz - nIVr_poz ) / nKol_poz // srednja nabavna cijena
      nSrednjaNabavnaCijena :=  nNabavnaVrijednost / nKolicina
      // IF nSrednjaNabavnaCijena < 0 // kartica je prolupala, srednja nabavna cijena negativna
      // nSrednjaNabavnaCijena := 0
      // ENDIF
   ENDIF

   nSrednjaNabavnaCijena := korekcija_nabavne_cijene_sa_zadnjom_ulaznom( nKolicina, nKolZN, nNcZadnjaNabavka, nSrednjaNabavnaCijena, lSilent )
   nKolicina := Round( nKolicina, 4 )
   nSrednjaNabavnaCijena := korekcija_nabavna_cijena_0( nSrednjaNabavnaCijena )

   IF Round( nSrednjaNabavnaCijena, 4 ) <= 0
      sumnjive_stavke_error()
   ENDIF

   SELECT kalk_pripr
   MsgC()

   RETURN .T.
