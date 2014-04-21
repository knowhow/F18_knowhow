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



FUNCTION AnaKart()

   O_KONCIJ
   O_SIFK
   O_SIFV
   O_ROBA
   O_KALK
   IF Pitanje(, "Prodji kroz neobradjene stavke", "N" ) = "D"
      SET ORDER TO
      GO TOP
      MsgO( "Prolaz#................" )
      nCnt := 0
      DO WHILE !Eof() .AND. IspitajPrekid()

         IF Empty( mu_i ) .AND. Empty( pu_i )
            @ m_x + 2, m_y + 4 SAY ++nCnt
            IF idvd == "10"
               REPLACE mu_i WITH "1", mkonto WITH idkonto
            ELSEIF idvd == "11"
               REPLACE mu_i WITH "5", mkonto WITH idkonto2, ;
                  pu_i WITH "1", pkonto WITH idkonto
            ELSEIF idvd $ "14#96"
               REPLACE mu_i WITH "5", mkonto WITH idkonto2
            ELSEIF idvd == "18"
               REPLACE mu_i WITH "3", mkonto WITH idkonto
            ELSEIF idvd == "19"
               REPLACE pu_i WITH "3", pkonto WITH idkonto
            ELSEIF idvd $ "41#42#43"
               REPLACE pu_i WITH "5", pkonto WITH idkonto
            ENDIF
         ENDIF
         SKIP
      ENDDO
      Msgc()
   ENDIF

   SET ORDER TO TAG "3"
   // CREATE_INDEX("3","idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD",KUMPATH+"KALK")
   GO TOP
   aDbf := {}
   AAdd( aDbf, { "ID", "C", 10, 0 } )     // roba
   AAdd( aDbf, { "stanje", "N", 15, 3 } )
   AAdd( aDbf, { "VPV", "N", 15, 3 } )
   AAdd( aDbf, { "NV", "N", 15, 3 } )
   AAdd( aDbf, { "VPC", "N", 15, 3 } )
   AAdd( aDbf, { "MPC", "N", 15, 3 } )
   AAdd( aDbf, { "MPV", "N", 15, 3 } )
   AAdd( aDbf, { "recno", "N", 6, 0 } )
   dbcreate2( PRIVPATH + "LLM", aDbf )

   SELECT 70
   usex ( PRIVPATH + "llm" )
   INDEX ON id TAG "ID"
   INDEX ON brisano TAG "BRISAN"
   SET ORDER TO TAG "ID"

   PRIVATE cIdFirma := gFirma
   PRIVATE cMkonto := PadR( "1310", gDuzKonto )
   Box(, 2, 50 )
   @ m_x + 1, m_y + 2 SAY "Konto:" GET cMkonto
   READ
   BoxC()
   SELECT kalk
   SEEK cidfirma + cmkonto
   DO WHILE !Eof() .AND. IspitajPrekid()
      cIdroba := idroba
      cmkonto := mkonto
      cidfirma := idfirma
      SELECT kalk
      SEEK cidfirma + cmkonto + cidroba
      nStanje := nNV := nVPV := 0
      nReckalk := 0
      DO WHILE !Eof() .AND. idfirma + mkonto + idroba == cidfirma + cmkonto + cidroba .AND. IspitajPrekid()
         nRecKalk := RecNo()
         cId := idfirma + idvd + brdok + rbr
         IF mu_i == "1"
            nStanje += kolicina - gkolicina - gkolicin2
            nVPV += vpc * ( kolicina - gkolicina - gkolicin2 )
            nNV += nc * ( kolicina - gkolicina - gkolicin2 )
         ELSEIF mu_i == "3"
            nVPV += vpc * kolicina
         ELSEIF mu_i == "5"
            nStanje -= kolicina
            nVPV -= vpc * kolicina
            nNV -= nc * kolicina
         ENDIF
         SKIP
      ENDDO    // cidroba

      SELECT llm
      APPEND BLANK
      REPLACE id WITH cidroba, stanje WITH nstanje, vpv WITH nVPV, ;
         recno WITH nRecKalk
      IF nStanje <> 0
         REPLACE vpc WITH nVPV / nStanje
      ENDIF
      SELECT kalk

   ENDDO

   SELECT llm

   ImeKol := {}
   AAdd( ImeKol, { "IdRoba",    {|| id }                         } )
   AAdd( ImeKol, { "Stanje", {|| llm->stanje } } )
   AAdd( ImeKol, { "VPC po Kartici", {|| llm->vpc } } )
   AAdd( ImeKol, { "VPV po kartici", {|| llm->vpv } } )


   Kol := {}; FOR i := 1 TO Len( Imekol ); AAdd( Kol, i ); NEXT

   Box(, 20, 77 )
   ObjDbedit( "anm", 20, 77, {|| EdLLM() }, "", "...", , , , , 3 )
   BoxC()
   closeret

   RETURN
// }




/*! \fn EdLLM()
 *  \brief Obrada opcija u browse-u tabele LLM
 */

FUNCTION EdLLM()

   // {
   LOCAL cDn := "N", nTrecDok := 0, nRet := DE_CONT
   DO CASE
   CASE Ch == K_ENTER
      SELECT kalk; SET ORDER TO TAG "3"
      // CREATE_INDEX("3","idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD",KUMPATH+"KALK")
      GO llm->recno
      BrowseKart()
      SELECT llm
      nRet := DE_REFRESH

   CASE Ch == K_CTRL_P
      nRet := DE_REFRESH
   ENDCASE

   RETURN nRet
// }
