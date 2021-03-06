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


#include "f18.ch"

/*
STATIC aPorezi := {}



FUNCTION get_nivel_p()


   LOCAL aProd // matrica sa prodavnicama
   LOCAL cProd // prodavnica
   LOCAL cPKonto
   LOCAL dDatDok
   LOCAL cGlStanje := "D"


   o_konto()

   Box(, 4, 70 )
   cProd := Space( 7 )
   dDatDok := Date()
   @ box_x_koord() + 1, box_y_koord() + 2 SAY "Prodavnica (prazno-sve)" GET cProd VALID Empty( cProd ) .OR. P_Konto( @cProd )
   @ box_x_koord() + 2, box_y_koord() + 2 SAY "Datum" GET dDatDok
   @ box_x_koord() + 3, box_y_koord() + 2 SAY "Nivelisati samo robu na stanju (D/N)?" GET cGlStanje VALID cGlStanje $ "DN" PICT "@!"
   READ
   ESC_BCR
   BoxC()

   IF Pitanje(, "Generisati nivelacije (D/N)?", "D" ) == "N"
      RETURN
   ENDIF

   aProd := {}

   IF Empty( AllTrim( cProd ) )
      // napuni matricu sa prodavnckim kontima
      GetProdKto( @aProd )
   ELSE
      AAdd( aProd, { cProd } )
   ENDIF

   // provjeri velicinu matrice
   IF Len( aProd ) == 0
      MsgBeep( "Ne postoje definisane prodavnice u KONCIJ-u!" )
      RETURN
   ENDIF

   lGlStanje := .T.

   IF cGlStanje == "N"
      lGlStanje := .F.
   ENDIF

   // kreiraj tabelu PRIPT
   cre_kalk_priprt()

   // pokreni generisanje nivelacija
   Box(, 2, 65 )
   @ 1 + box_x_koord(), 2 + box_y_koord() SAY "Vrsim generisanje nivelacije za " + AllTrim( Str( Len( aProd ) ) ) + " prodavnicu..."

   o_kalk_doks()

   nUvecaj := 1
   FOR nCnt := 1 TO Len( aProd )
      // daj broj kalkulacije
      cBrKalk := kalk_get_next_kalk_doc_uvecaj( self_organizacija_id(), "19", nUvecaj )
      cPKonto := aProd[ nCnt, 1 ]

      @ 2 + box_x_koord(), 2 + box_y_koord() SAY Str( nCnt, 3 ) + " Prodavnica: " + AllTrim( cPKonto ) + "   dokument: " + self_organizacija_id() + "-19-" + AllTrim( cBrKalk )

      gen_nivel_p( cPKonto, dDatDok, cBrKalk, lGlStanje )

      ++ nUvecaj
   NEXT

   BoxC()

   result_nivel_p()

   RETURN




// --------------------------------------------------------------------
// generisanje nivalacije za prodavnicu
// cPKonto - prodavnicki konto
// dDatDok - datum dokumenta nivelacije
// cBrKalk - broj dokumenta nivelacije
// lGledajStanje - .t. - gledaj sta je na stanju pa to nivelisi
// --------------------------------------------------------------------
FUNCTION gen_nivel_p( cPKonto, dDatDok, cBrKalk, lGledajStanje )

   LOCAL nRbr
   LOCAL cIdFirma
   LOCAL cIdVd
   LOCAL cIdRoba
   LOCAL nNivCijena
   LOCAL nStCijena

   o_kalk_pript()
   -- o_kalk()
==   o_roba()
   o_konto()
   o_koncij()
   o_tarifa()

   nRbr := 0

   cIdFirma := self_organizacija_id()

--   SELECT koncij
--   SEEK Trim( cPKonto )

   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP
   DO WHILE !Eof()

      // provjeri polje ROBA->ZANIVEL
      // ako je prazno preskoci
      IF field->tip $ "UT"
         SKIP
         LOOP
      ENDIF

      IF Round( field->zanivel, 4 ) == 0
         SKIP
         LOOP
      ENDIF

      cIdRoba := field->id
      nNivCijena := field->zanivel
      // uzmi MPC iz sifrarnika
      nStCijena := kalk_get_mpc_by_koncij_pravilo()

      nUlaz := 0
      nIzlaz := 0

      SELECT kalk
      SET ORDER TO TAG "4"
      // "KALKi4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALK")

      SEEK cIdFirma + cPkonto + cIdRoba

      DO WHILE !Eof() .AND. cIdFirma + cPKonto + cIdRoba == field->idFirma + field->pkonto + field->idroba

         IF field->datdok > dDatDok  // preskoci
            SKIP
            LOOP
         ENDIF

         IF pu_i == "1"
            nUlaz += kolicina - GKolicina - GKolicin2
         ELSEIF pu_i == "5"  .AND. !( idvd $ "12#13#22" )
            nIzlaz += kolicina
         ELSEIF pu_i == "5"  .AND. ( idvd $ "12#13#22" )    // povrat
            nUlaz -= kolicina
         ELSEIF pu_i == "3"    // nivelacija
            // nMPVU+=mpcsapp*kolicina
         ELSEIF pu_i == "I"
            nIzlaz += gkolicin2
         ENDIF

         SKIP
      ENDDO // po orderu 4

      // ako je Stanje <> 0 preskoci
      IF Round( nUlaz - nIzlaz, 4 ) == 0
         IF lGledajStanje
            SELECT roba
            SKIP
            LOOP
         ENDIF
      ENDIF

      // upisi u pript
      SELECT pript
      // scatter()
      // append ncnl
      APPEND BLANK
      Scatter()
      _idfirma := cIdFirma
      _idkonto := cPKonto
      _pkonto := cPKonto
      _pu_i := "3"
      _idroba := cIdRoba
      _idtarifa := set_pdv_array_by_koncij_region_roba_idtarifa_2_3( cPKonto, cIdRoba, @aPorezi, roba->idtarifa )
      _idvd := "19"
      _brdok := cBrKalk
      _tmarza2 := "A"
      _rbr := RedniBroj( ++nRbr )
      _kolicina := nUlaz - nIzlaz
      _datdok := dDatDok
      _datfaktp := dDatDok
      _MPCSaPP := nNivCijena - nStCijena
      _MPC := 0
      _fcj := nStCijena
      _mpc := MpcBezPor( nNivCijena, aPorezi, , _nc ) - MpcBezPor( nStCijena, aPorezi, , _nc )

      _error := "0"

      Gather()

      SELECT roba
      SKIP
   ENDDO

   RETURN


// prebaci iz zanivel2 u zanivel
FUNCTION zaniv2_zaniv()

   IF !spec_funkcije_sifra( "NIVEL" )
      MsgBeep( "Ne cackaj!" )
      RETURN
   ENDIF

   MsgBeep( "Ova opcija ce kopirati postojece vrijednosti polja N.CIJENA 2#u polje N.CIJENA 1!" )

   IF Pitanje(, "Kopirati vrijednosti", "N" ) == "N"
      RETURN
   ENDIF

   IF !Used( F_ROBA )
==      o_roba()
   ENDIF

   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   Box(, 3, 70 )
   DO WHILE !Eof()

      IF Round( field->zaniv2, 4 ) == 0
         SKIP
         LOOP
      ENDIF

      @ 1 + box_x_koord(), 2 + box_y_koord() SAY "ID roba: " + field->id

      REPLACE zanivel WITH zaniv2

      @ 2 + box_x_koord(), 2 + box_y_koord() SAY "Update cijena " + AllTrim( Str( field->zanivel ) )
      SKIP
   ENDDO

   BoxC()


   MsgBeep( "Zavrseno kopiranje !" )

   RETURN



// ----------------------------------------------
// setuj mpc na osnovu postojeceg polja
// ----------------------------------------------
FUNCTION set_mpc_2()

   LOCAL cSetCj := "3"
   LOCAL cUzCj := "1"
   LOCAL nUvecaj := 0
   LOCAL nZaok := 2

   IF !spec_funkcije_sifra( "SETMPC" )
      MsgBeep( "Ne cackaj!" )
      RETURN
   ENDIF

   Box(, 4, 55 )

   @ box_x_koord() + 1, box_y_koord() + 2 SAY "        Setuj MPC (1,2,3):" GET cSetCj ;
      VALID cSetCj $ "12345"
   @ box_x_koord() + 2, box_y_koord() + 2 SAY "    Na osnovu MPC (1,2,3):" GET cUzCJ ;
      VALID cUzCj $ "12345"
   @ box_x_koord() + 3, box_y_koord() + 2 SAY "                   za (%):" GET nUvecaj ;
      PICT "999.999"
   @ box_x_koord() + 4, box_y_koord() + 2 SAY "  novu cijenu zaokruzi na:" GET nZaok ;
      PICT "9"
   READ
   BoxC()


   IF nUvecaj = 0 .OR. Pitanje(, "Setovati cijene", "N" ) == "N"
      RETURN
   ENDIF

   IF !Used( F_ROBA )
  ==    o_roba()
   ENDIF

   IF cUzCj == "1"
      cUField := "MPC"
   ELSE
      cUField := "MPC" + cUzCj
   ENDIF

   IF cSetCj == "1"
      cSField := "MPC"
   ELSE
      cSField := "MPC" + cSetCj
   ENDIF

   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   Box(, 1, 70 )

   DO WHILE !Eof()

      // ako je uzorak cijena = 0 preskoci
      if &cUField = 0
         SKIP
         LOOP
      ENDIF

      @ 1 + box_x_koord(), 2 + box_y_koord() SAY "ID roba: " + field->id

      replace &cSField WITH Round( &cUField * nUvecaj, nZaok )

      SKIP
   ENDDO

   BoxC()

   MsgBeep( "Zavrseno setovanje cijena!" )

   RETURN




// setuj mpc iz polja zanivel nakon nivelacije
FUNCTION set_mpc_iz_zanivel()

   LOCAL cSetCj := "1"

   IF !spec_funkcije_sifra( "SETMPC" )
      MsgBeep( "Ne cackaj!" )
      RETURN
   ENDIF

   MsgBeep( "Ova opcija se iskljucivo pokrece#nakon obradjenih nivelacija!" )


   Box(, 1, 55 )
   @ box_x_koord() + 1, box_y_koord() + 2 SAY "Setovati MPC(1, 2, 3, 4) ?" GET cSetCj VALID cSetCj $ "12345"

   READ
   BoxC()


   IF Pitanje(, "Setovati nove cijene", "N" ) == "N"
      RETURN
   ENDIF

   IF !Used( F_ROBA )
      o_roba()
   ENDIF


   IF cSetCj == "1"
      cField := "MPC"
   ELSE
      cField := "MPC" + cSetCj
   ENDIF

   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   Box(, 3, 70 )
   DO WHILE !Eof()

      IF Round( field->zanivel, 4 ) == 0
         SKIP
         LOOP
      ENDIF

      @ 1 + box_x_koord(), 2 + box_y_koord() SAY "ID roba: " + field->id

      // sacuvaj backup u zaniv2
      REPLACE zaniv2 with &cField
      // prebaci iz zanivel u mpc
      replace &cField WITH zanivel

      @ 2 + box_x_koord(), 2 + box_y_koord() SAY "Update cijena " + AllTrim( Str( field->zanivel ) ) + " -> " + AllTrim( Str( &cField ) )

      SKIP
   ENDDO

   BoxC()

   MsgBeep( "Zavrseno setovanje cijena!" )

   RETURN



// generisanje nivelacije sa zadzavanjem cijena
FUNCTION gen_zcnivel( cPKonto, dDatDok, cBrKalk )

   // {
   LOCAL nRbr
   LOCAL cIdFirma
   LOCAL cIdVd
   LOCAL cIdRoba
   LOCAL cIdTarifa
   LOCAL nNivCijena
   LOCAL nStCijena

   o_kalk_pript()
   -- o_kalk()
   o_roba()
   o_konto()
   o_koncij()
   o_tarifa()

   nRbr := 0

   cIdFirma := self_organizacija_id()

  -- SELECT koncij
   SEEK Trim( cPKonto )


   SELECT kalk
   SET ORDER TO TAG "4"
   GO TOP
   // "KALKi4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALK")

   SEEK cIdFirma + cPkonto

   DO WHILE !Eof() .AND. cIdFirma + cPKonto == field->idFirma + field->pkonto

      cIdRoba := field->idroba

      nUlaz := 0
      nIzlaz := 0

      DO WHILE !Eof() .AND. cIdFirma + cPKonto + cIdRoba == field->idfirma + field->pkonto + field->idroba

         IF field->datdok > dDatDok
            // preskoci
            SKIP
            LOOP
         ENDIF

         IF pu_i == "1"
            nUlaz += kolicina - GKolicina - GKolicin2
         ELSEIF pu_i == "5"  .AND. !( idvd $ "12#13#22" )
            nIzlaz += kolicina
         ELSEIF pu_i == "5"  .AND. ( idvd $ "12#13#22" )
            // povrat
            nUlaz -= kolicina
         ELSEIF pu_i == "3"
            // nivelacija
            // nMPVU+=mpcsapp*kolicina
         ELSEIF pu_i == "I"
            nIzlaz += gKolicin2
         ENDIF

         SKIP

      ENDDO

      // ako je Stanje <> 0 preskoci
      IF Round ( nUlaz - nIzlaz, 4 ) == 0
         SELECT kalk
         LOOP
      ENDIF

      // nadji robu
      SELECT roba
      SET ORDER TO TAG "ID"
  --    HSEEK cIdRoba
      cIdTarifa := roba->idtarifa

      // nadji tarifu
  --    SELECT tarifa
      SET ORDER TO TAG "ID"
  --    HSEEK cIdTarifa
      nTarStopa := tarifa->opp

      SELECT kalk

      // stara cijena !!!
      // ako KARTICA NE VALJA OVAJ DOKUMENT NECE VALJATI
      // prije pokretanja ove nivelacije mora se provjeriti
      // da li ima ERR na lager listi !!!!!
      // ako ima mora se ta greska ispraviti
      nStCijena := roba->mpc

      // maloprodajna cijena bez poreza PP
      nMpcbpPP := nStCijena / ( 1 + ( nTarStopa / 100 ) )
      // maloprodajna cijena bez poreza PDV
      nMpcbpPDV := nStCijena / ( 1 + ( 17 / 100 ) )

      // razlika bez poreza
      nCRazlbp := nMpcbpPDV - nMpcbpPP
      // razlika sa uracunatim porezom
      nCRazlsp := nCRazlbp * ( 1 + ( nTarStopa / 100 ) )
      // nova cijena je stara mpc + razlika sa porezom
      nNivCijena := nStCijena + nCRazlsp

      // upisi u pript
      SELECT pript
      APPEND BLANK
      Scatter()
      _idfirma := cIdFirma
      _idkonto := cPKonto
      _pkonto := cPKonto
      _pu_i := "3"
      _idroba := cIdRoba
      _idtarifa := set_pdv_array_by_koncij_region_roba_idtarifa_2_3( cPKonto, cIdRoba, @aPorezi, cIdTarifa )
      _idvd := "19"
      _brdok := cBrKalk
      _tmarza2 := "A"
      _rbr := RedniBroj( ++nRbr )
      _kolicina := nUlaz - nIzlaz
      _datdok := dDatDok
      _datfaktp := dDatDok
      // _MPCSaPP := nNivCijena - nStCijena
      // _MPC := 0
      _MPCSaPP := nCRazlsp
      _fcj := nStCijena
      // _MPC := MpcBezPor(nNivCijena, aPorezi, , _nc) - MpcBezPor(nStCijena, aPorezi, , _nc)
      _MPC := nCRazlbp
      _error := "0"
      Gather()

      SELECT kalk
   ENDDO

   RETURN
// }




FUNCTION result_nivel_p()


   LOCAL cVarijanta
   LOCAL cKolNula

   IF Pitanje(, "Izvrsiti uvid u rezultate nivelacija (D/N)?", "D" ) == "N"
      RETURN
   ENDIF

   Box(, 5, 65 )
   cVarijanta := "2"
   cKolNula := "N"
   @ 1 + box_x_koord(), 2 + box_y_koord() SAY "Varijanta prikaza:"
   @ 2 + box_x_koord(), 2 + box_y_koord() SAY "  - sa detaljima (1)"
   @ 3 + box_x_koord(), 2 + box_y_koord() SAY "  - bez detalja  (2)" GET cVarijanta VALID !Empty( cVarijanta ) .AND. cVarijanta $ "12"
   @ 5 + box_x_koord(), 2 + box_y_koord() SAY "Prikaz kolicina 0 (D/N)" GET cKolNula VALID !Empty( cKolNula ) .AND. cKolNula $ "DN" PICT "@!"
   READ
   ESC_BCR
   BoxC()

   st_res_niv_p( cVarijanta, cKolNula )

   RETURN


// -----------------------------------------
// obrada nivelacije iz PRIPT tabele
// -----------------------------------------
FUNCTION obr_nivel_p()

   LOCAL nRecP
   LOCAL lGenFinFakt
   LOCAL lStampati

   IF Pitanje(, "Obraditi nivelaciju iz pomocne tabele (D/N)?", "N" ) == "N"
      RETURN
   ENDIF

   o_kalk_pript()
   nRecP := RecCount()

   IF nRecP == 0
      MsgBeep( "Nije generisana nivelacija, opcija 9. !" )
      RETURN
   ENDIF

   lStampati := .T.

   IF Pitanje(, "Stampati dokumente (D/N)", "N" ) == "N"
      lStampati := .F.
   ENDIF

   lGenFinFakt := .F.

   IF Pitanje(, "Generisati FIN/FAKT dokumente (D/N)", "N" ) == "D"
      lGenFinFakt := .T.
   ENDIF

   IF !lGenFinFakt
      // snimi stanje parametara
      cTmpFin := gAFin
      cTmpMat := gAMat
      cTmpFakt := gAFakt

      gAFin := "0"
      gAMat := "N"
      gAFakt := "N"
   ENDIF

   // pokreni obradu pript bez asistenta
   --kalk_imp_obradi_sve_dokumente_iz_pript( 0, nemavise.F., lStampati )

   IF !lGenFinFakt
      // vrati parametre...
      gAFin := cTmpFin
      gAMat := cTmpMat
      gAFakt := cTmpFakt
   ENDIF

   RETURN



// -----------------------------------------
// stampa rezultata - efekata nivelacije
// cVar - varijanta
// cKolNula -
// -----------------------------------------
FUNCTION st_res_niv_p( cVar, cKolNula )

   LOCAL cIdFirma
   LOCAL cIdVd
   LOCAL cBrDok
   LOCAL cIdRoba
   LOCAL cRobaNaz
   LOCAL cProd
   LOCAL cPorez
   LOCAL nUStVrbpdv
   LOCAL nUStVrspdv
   LOCAL nUNVrbpdv
   LOCAL nUNVrspdv
   LOCAL nURazlbpdv
   LOCAL nURazlspdv

   o_kalk_pript()
   kalk_o_pobjekti()
   o_roba()
   o_tarifa()

   --IF IsPDV()
      cPorez := "PDV"
   ELSE
      cPorez := "PP"
   ENDIF

   SELECT pript
   SET ORDER TO TAG "1"
   GO TOP

   START PRINT CRET

   ?
   ? "Prikaz efekata nivelacije za sve prodavnice, na dan " + DToC( Date() )
   ?

   cLine := Replicate( "-", 10 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 15 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 35 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 35 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 35 )
   cLine += Space( 1 )

   st_zagl( cLine )

   // total varijable
   nTStVrbpdv := 0
   nTStVrspdv := 0
   nTNVrbpdv := 0
   nTNVrspdv := 0
   nTRazlbpdv := 0
   nTRazlspdv := 0

   DO WHILE !Eof()

      cIdFirma := field->idfirma
      cIdVd := field->idvd
      cBrDok := field->brdok

      nUStVrbpdv := 0
      nUStVrspdv := 0
      nUNVrbpdv := 0
      nUNVrspdv := 0
      nURazlbpdv := 0
      nURazlspdv := 0

      cProd := field->pkonto

      DO WHILE !Eof() .AND. pript->( idfirma + idvd + brdok ) == cIdFirma + cIdVd + cBrDok
         cIdRoba := field->idroba
         cIdTar := field->idtarifa

         SELECT roba
         SET ORDER TO TAG "ID"
      --   HSEEK cIdRoba

      --   SELECT tarifa
         SEEK cIdTar

         SELECT pript

         // kolicina
         nKolicina := field->kolicina

         // da li je kolicina 0
         IF cKolNula == "N"
            IF Round( nKolicina, 4 ) == 0
               SKIP
               LOOP
            ENDIF
         ENDIF

         // stara cijena sa pdv
         nSCijspdv := field->fcj

         // nova cijena sa pdv
         nNCijspdv := field->fcj + field->mpcsapp

         // RUC sa pdv
         nRazlCij := nSCijspdv - nNCijspdv

         // stara vrijednost sa pdv
         nStVrspdv := nKolicina * ( field->fcj )

         // stara vrijednost bez pdv
         nStVrbpdv := nKolicina * ( field->fcj / ( 1 + ( tarifa->opp / 100 ) ) )

         // vrijednost nova cijena sa pdv
         nNVrspdv := nKolicina * nNCijspdv

         // vrijednost nova bez pdv
         nNVrbpdv := nKolicina * ( nNCijspdv / ( 1 + ( tarifa->opp / 100 ) ) )

         // razlika sa pdv
         nRazlspdv := nStVrspdv - nNVrspdv

         // razlika bez pdv
         nRazlbpdv := nStVrbpdv - nNVrbpdv

         IF cVar == "1"
            // vidi da li treba nova strana
            nstr( cLine )

            // prikazi stavku
            ? cIdRoba
            ?? Space( 1 )
            ?? PadR( roba->naz, 15 )

            // cijene
            @ PRow(), PCol() + 2 SAY Round( nSCijspdv, 3 ) PICT kalk_pic_cijena_bilo_gpiccdem()
            @ PRow(), PCol() + 2 SAY Round( nNCijspdv, 3 ) PICT kalk_pic_cijena_bilo_gpiccdem()
            @ PRow(), PCol() + 2 SAY Round( nRazlCij, 3 ) PICT kalk_pic_cijena_bilo_gpiccdem()
            // sa pdv
            @ PRow(), PCol() + 2 SAY Round( nStVrspdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
            @ PRow(), PCol() + 2 SAY Round( nNVrspdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
            @ PRow(), PCol() + 2 SAY Round( nRazlspdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
            // bez pdv
            @ PRow(), PCol() + 2 SAY Round( nStVrbpdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
            @ PRow(), PCol() + 2 SAY Round( nNVrbpdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
            @ PRow(), PCol() + 2 SAY Round( nRazlbpdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
         ENDIF

         // dodaj ukupno prodavnica
         nUStVrbpdv += nStVrbpdv
         nUNVrbpdv += nNVrbpdv
         nUStVrspdv += nStVrspdv
         nUNVrspdv += nNVrspdv
         nURazlbpdv += nRazlbpdv
         nURazlspdv += nRazlspdv

         // dodaj na total
         nTStVrbpdv += nStVrbpdv
         nTNVrbpdv += nNVrbpdv
         nTStVrspdv += nStVrspdv
         nTNVrspdv += nNVrspdv
         nTRazlbpdv += nRazlbpdv
         nTRazlspdv += nRazlspdv

         SKIP
      ENDDO

      IF cVar == "1"
         ? cLine
      ENDIF

      // vidi da li treba nova strana
      nstr( cLine )

      // uzmi naziv objekta
      cObjNaz := g_obj_naz( cProd )

      ? PadR( "UKUPNO " + AllTrim( cProd ) + "-" + AllTrim( cObjNaz ), 26 )
      @ PRow(), PCol() + 2 SAY Space( Len( kalk_pic_cijena_bilo_gpiccdem() ) )
      @ PRow(), PCol() + 2 SAY Space( Len( kalk_pic_cijena_bilo_gpiccdem() ) )
      @ PRow(), PCol() + 2 SAY Space( Len( kalk_pic_cijena_bilo_gpiccdem() ) )
      // sa pdv
      @ PRow(), PCol() + 2 SAY Round( nUStVrspdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
      @ PRow(), PCol() + 2 SAY Round( nUNVrspdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
      @ PRow(), PCol() + 2 SAY Round( nURazlspdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
      // bez pdv
      @ PRow(), PCol() + 2 SAY Round( nUStVrbpdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
      @ PRow(), PCol() + 2 SAY Round( nUNVrbpdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
      @ PRow(), PCol() + 2 SAY Round( nURazlbpdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()

      IF cVar == "1"
         ? cLine
      ENDIF
   ENDDO

   // provjeri za novi red
   nstr( cLine )

   ? cLine

   // total - sve prodavnice
   ? PadR( "SVE PRODAVNICE UKUPNO:", 26 )
   @ PRow(), PCol() + 2 SAY Space( Len( kalk_pic_cijena_bilo_gpiccdem() ) )
   @ PRow(), PCol() + 2 SAY Space( Len( kalk_pic_cijena_bilo_gpiccdem() ) )
   @ PRow(), PCol() + 2 SAY Space( Len( kalk_pic_cijena_bilo_gpiccdem() ) )
   // sa pdv
   @ PRow(), PCol() + 2 SAY Round( nTStVrspdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
   @ PRow(), PCol() + 2 SAY Round( nTNVrspdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
   @ PRow(), PCol() + 2 SAY Round( nTRazlspdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
   // bez pdv
   @ PRow(), PCol() + 2 SAY Round( nTStVrbpdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
   @ PRow(), PCol() + 2 SAY Round( nTNVrbpdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()
   @ PRow(), PCol() + 2 SAY Round( nTRazlbpdv, 3 ) PICT kalk_pic_iznos_bilo_gpicdem()

   ? cLine


   FF

   ENDPRINT

   RETURN



// stampa zaglavlja
STATIC FUNCTION st_zagl( cLine )

   LOCAL cHead1
   LOCAL cHead2
   LOCAL cSep := "*"

   P_COND

   ? cLine

   // prva linija headera
   cHead1 := PadC( "SIFRA", 10 )
   cHead1 += cSep
   cHead1 += PadC( "NAZIV", 15 )
   cHead1 += cSep
   cHead1 += PadC( "CIJENE SA PDV", 35 )
   cHead1 += cSep
   cHead1 += PadC( "VRIJEDNOST SA PDV", 35 )
   cHead1 += cSep
   cHead1 += PadC( "VRIJEDNOST BEZ PDV", 35 )
   cHead1 += cSep

   // druga linija headera
   cHead2 := PadC( "ARTIKLA", 10 )
   cHead2 += cSep
   cHead2 += PadC( "ARTIKLA", 15 )
   cHead2 += cSep
   cHead2 += PadC( "STARA", 11 )
   cHead2 += cSep
   cHead2 += PadC( "NOVA", 11 )
   cHead2 += cSep
   cHead2 += PadC( "RAZLIKA", 11 )
   cHead2 += cSep
   cHead2 += PadC( "STARA C", 11 )
   cHead2 += cSep
   cHead2 += PadC( "NOVA C", 11 )
   cHead2 += cSep
   cHead2 += PadC( "RAZLIKA", 11 )
   cHead2 += cSep
   cHead2 += PadC( "STARA C", 11 )
   cHead2 += cSep
   cHead2 += PadC( "NOVA C", 11 )
   cHead2 += cSep
   cHead2 += PadC( "RAZLIKA", 11 )
   cHead2 += cSep

   ? cHead1
   ? cHead2

   ? cLine

   RETURN


// prelaz na novu stranicu
STATIC FUNCTION nstr( cLine )

   IF PRow() > 58
      FF
      st_zagl( cLine )
   ENDIF

   RETURN


// obrazac o promjeni cijena za sve prodavnice
FUNCTION o_pr_cijena()

   LOCAL cProred
   LOCAL cPodvuceno
   LOCAL aDoks
   LOCAL i

   cProred := "N"
   cPodvuceno := "N"

   MsgBeep( "Opcija stampa obrasce o promjeni cijena#na osnovu generisane nivelacije!" )

   Box(, 2, 60 )
   @ box_x_koord() + 1, box_y_koord() + 2 SAY "Prikazati sa proredom:" GET cProred VALID cProred $ "DN" PICT "@!"
   @ box_x_koord() + 2, box_y_koord() + 2 SAY "Prikazati podvuceno  :" GET cPodvuceno VALID cPodvuceno $ "DN" PICT "@!"
   READ
   ESC_BCR
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   o_partner()
   o_roba()
   o_tarifa()
   o_kalk_pript()

   // uzmi u matricu prodavnice
   g_pript_doks( @aDoks )

   // ima li dokumenata
   IF Len( aDoks ) == 0
      MsgBeep( "Nema dokumenata!" )
      RETURN
   ENDIF

   // prodji po dokumentima
   FOR i := 1 TO Len( aDoks )

      // upit za stampu
      Box(, 5, 60 )
      cOdgovor := "D"
      @ box_x_koord() + 1, box_y_koord() + 2 SAY "Stampati obrazac za dokument: 19-" + AllTrim( aDoks[ i, 1 ] )
      @ box_x_koord() + 3, box_y_koord() + 2 SAY "D/N (X - prekini)" GET cOdgovor VALID cOdgovor $ "DNX" PICT "@!"
      READ
      BoxC()

      // ako je X - izadji skroz
      IF cOdgovor == "X"
         EXIT
      ENDIF

      // ako je N - izadji samo iz tekuceg
      IF cOdgovor == "N"
         LOOP
      ENDIF

      // stampaj obrazac
      st_pr_cijena( self_organizacija_id(), "19", aDoks[ i, 1 ], cPodvuceno, cProred )
   NEXT

   RETURN


// vrati u matricu brojeve dokumenata
STATIC FUNCTION g_pript_doks( aArr )

   aArr := {}
   SELECT pript
   GO TOP

   DO WHILE !Eof()
      IF AScan( aArr, {| xVar| xVar[ 1 ] == field->brdok } ) == 0
         AAdd( aArr, { field->brdok } )
      ENDIF
      SKIP
   ENDDO

   RETURN



// stampa obrasca o promjeni cijena
FUNCTION st_pr_cijena( cFirma, cIdTip, cBrDok, cPodvuceno, cProred )

   LOCAL nCol1 := 0
   LOCAL nCol2 := 0
   LOCAL nPom := 0

   SELECT PRIPT
   SET ORDER TO TAG "1"
   GO TOP
   SEEK cFirma + cIdTip + cBrDok

   nStr := 0

   cIdKonto := IdKonto
   cObjNaz := g_obj_naz( cIdKonto )

   START PRINT CRET

   ?

   Preduzece()

   P_10CPI
   B_ON
   ? PadL( "Prodavnica: " + AllTrim( cIdKonto ) + "-" + AllTrim( cObjNaz ), 74 )
   ?
   ?
   ? PadC( "PROMJENA CIJENA U PRODAVNICI ___________________, Datum _________", 80 )
   ?
   B_OFF

   P_COND

   ?

   @ PRow(), 110 SAY "Str:" + Str( ++nStr, 3 )

   m := "--- --------------------------------------------------- ---------- ---------- ---------- ------------- ------------- -------------"

   ? m

   ? "*R *  Sifra   *        Naziv                           *  STARA   *   NOVA   * promjena *  zaliha     *   iznos     *  ukupno    *"
   ? "*BR*          *                                        *  cijena  *  cijena  *  cijene  * (kolicina)  *   poreza    * promjena   *"

   ? m

   DO WHILE !Eof() .AND. cFirma == pript->IdFirma .AND.  cBrDok == pript->BrDok .AND. cIdTip == pript->IdVD

      SELECT ROBA
      HSEEK PRIPT->IdRoba

    --  SELECT TARIFA
  --    HSEEK PRIPT->IdTarifa

      SELECT PRIPT

      print_nova_strana( 110, @nStr, iif( cProred == "D", 2, 1 ) )

      ?

      IF cPodvuceno == "D"
         U_ON
      ENDIF

      ?? field->rbr + " " + field->idroba + " " + PadR( Trim( Left( ROBA->naz, 35 ) ) + " (" + ROBA->jmj + ")", 40 )

      @ PRow(), PCol() + 1 SAY field->FCJ PICT kalk_pic_cijena_bilo_gpiccdem()
      @ PRow(), PCol() + 1 SAY field->MPCSAPP + FCJ PICT kalk_pic_cijena_bilo_gpiccdem()
      @ PRow(), PCol() + 1 SAY field->MPCSAPP PICT kalk_pic_cijena_bilo_gpiccdem()

      IF cPodvuceno == "D"
         U_OFF
      ENDIF

      @ PRow(), PCol() + 1 SAY "_____________"
      @ PRow(), PCol() + 1 SAY "_____________"
      @ PRow(), PCol() + 1 SAY "_____________"

      IF cProred == "D"
         ?
      ENDIF

      SKIP
   ENDDO

   print_nova_strana( 110, @nStr, 12 )

   ? m
   ? " UKUPNO "
   ? m
   ?
   ?
   ?
   P_10CPI

   PrnClanoviKomisije()

   ENDPRINT

   RETURN
*/


/* ------------------------------------------------------
 stampa rekapitulacije stara cijena -> nova cijena

FUNCTION rpt_zanivel()

   LOCAL nTArea := Select()
   LOCAL cZagl
   LOCAL cLine
   LOCAL cRazmak := Space( 1 )
   LOCAL nCnt

   o_roba()
   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   // ako ne postoji polje u robi, nista...
   IF roba->( FieldPos( "zanivel" ) ) == 0
      RETURN
   ENDIF

   cZagl := PadC( "R.br", 6 )
   cZagl += cRazmak
   cZagl += PadC( "ID", 10 )
   cZagl += cRazmak
   cZagl += PadC( "Naziv", 20 )
   cZagl += cRazmak
   cZagl += PadC( "Stara cijena", 15 )
   cZagl += cRazmak
   cZagl += PadC( "Nova cijena", 15 )

   cLine := Replicate( "-", Len( cZagl ) )

   START PRINT CRET

   ? "Pregled promjene cijena u sifrarniku robe"
   ?
   ? cLine
   ? cZagl
   ? cLine

   nCnt := 0

   DO WHILE !Eof()

      IF field->zanivel == 0
         SKIP
         LOOP
      ENDIF

      ++ nCnt

      ? PadL( Str( nCnt, 5 ) + ".", 6 ), PadR( field->id, 10 ), PadR( field->naz, 20 ), PadL( Str( field->mpc, 12, 2 ), 15 ), PadL( Str( field->zanivel, 12, 2 ), 15 )

      SKIP

   ENDDO

   FF
   ENDPRINT

   SELECT ( nTArea )

   RETURN .T.
*/
