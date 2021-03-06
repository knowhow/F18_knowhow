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
FUNCTION GenProizvodnja()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1


   //AAdd( _opc, "1. generisi 96 na osnovu 47 po normativima" )
   //AAdd( _opcexe, {|| Iz47u96Norm() } )

   f18_menu( "kkno", .F.,  _izbor, _opc, _opcexe )

   my_close_all_dbf()

   RETURN .T.

*/

/*


FUNCTION Iz47u96Norm()

   LOCAL cIdFirma := self_organizacija_id(), cBrDok := cBrKalk := Space( 8 )

   o_kalk_pripr()
   -- o_kalk()
   //o_roba()
   o_konto()
   o_partner()
   o_tarifa()
   o_sastavnice()

   XO_KALK

   dDatKalk := Date()
   cIdKonto := PadR( "", 7 )
   cIdKonto2 := PadR( "1010", 7 )
   cIdZaduz2 := Space( 6 )

   cBrkalk := Space( 8 )
   IF gBrojacKalkulacija == "D"
      SELECT kalk
      SET ORDER TO TAG "1"
      SEEK cidfirma + "96X"
      SKIP -1
      IF idvd <> "96"
         cbrkalk := Space( 8 )
      ELSE
         cbrkalk := brdok
      ENDIF
   ENDIF

   Box(, 15, 60 )

   IF gBrojacKalkulacija == "D"
    --  cbrkalk := UBrojDok( Val( Left( cbrkalk, 5 ) ) + 1, 5, Right( cBrKalk, 3 ) )
   ENDIF

   DO WHILE .T.

      nRBr := 0
      @ box_x_koord() + 1, box_y_koord() + 2   SAY "Broj kalkulacije 96 -" GET cBrKalk PICT "@!"
      @ box_x_koord() + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ box_x_koord() + 3, box_y_koord() + 2   SAY "Konto razduzuje:" GET cIdKonto2 PICT "@!" VALID P_Konto( @cIdKonto2 )
      --IF gNW <> "X"
         @ box_x_koord() + 3, Col() + 2 SAY "Razduzuje:" GET cIdZaduz2  PICT "@!"      VALID Empty( cidzaduz2 ) .OR. p_partner( @cIdZaduz2 )
      ENDIF
      @ box_x_koord() + 4, box_y_koord() + 2   SAY "Konto zaduzuje :" GET cIdKonto  PICT "@!" VALID Empty( cIdKonto ) .OR. P_Konto( @cIdKonto )

      cBrDok47 := Space( 8 )
      @ box_x_koord() + 7, box_y_koord() + 2 SAY "Broj dokumenta 47:" GET cBrDok47
      READ
      IF LastKey() == K_ESC; exit; ENDIF

      SELECT kalk2
      SEEK cIDFirma + '47' + cBrDok47
      dDatKalk := datdok
    --  IF !provjerisif_izbaciti_ovu_funkciju( "!eof() .and. '" + cIDFirma + "47" + cBrDok47 + "'==IdFirma+IdVD+BrDok", "IDROBA", F_ROBA )
         MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
         LOOP
      ENDIF
      DO WHILE !Eof() .AND. cIDFirma + '47' + cBrDok47 == idfirma + idvd + brdok

      --   SELECT ROBA; HSEEK kalk2->idroba

         SELECT sast
         HSEEK  kalk2->idroba
         DO WHILE !Eof() .AND. id == kalk2->idroba // setaj kroz sast
            SELECT roba; HSEEK sast->id2
            SELECT kalk_pripr
            LOCATE FOR idroba == sast->id2
            IF Found()
               RREPLACE kolicina WITH kolicina + kalk2->kolicina * sast->kolicina
            ELSE
               SELECT kalk_pripr
               APPEND BLANK
               REPLACE idfirma WITH cIdFirma, ;
                  rbr     WITH Str( ++nRbr, 3 ), ;
                  idvd WITH "96", ;   // izlazna faktura
               brdok WITH cBrKalk, ;
                  datdok WITH dDatKalk, ;
                  idtarifa WITH ROBA->idtarifa, ;
                  brfaktp WITH "", ;
                  datfaktp WITH dDatKalk, ;
                  idkonto   WITH cidkonto, ;
                  idkonto2  WITH cidkonto2, ;
                  idzaduz2  WITH cidzaduz2, ;
                  kolicina WITH kalk2->kolicina * sast->kolicina, ;
                  idroba WITH sast->id2, ;
                  nc  WITH ROBA->nc
            ENDIF
            SELECT sast
            SKIP
         ENDDO

         SELECT kalk2
         SKIP
      ENDDO

      @ box_x_koord() + 10, box_y_koord() + 2 SAY "Dokument je prenesen !!"
      IF gBrojacKalkulacija == "D"
      --   cbrkalk := UBrojDok( Val( Left( cbrkalk, 5 ) ) + 1, 5, Right( cBrKalk, 3 ) )
      ENDIF
      Inkey( 4 )
      @ box_x_koord() + 8, box_y_koord() + 2 SAY Space( 30 )

   ENDDO
   Boxc()
   SELECT kalk2; USE
   closeret

   RETURN


*/
