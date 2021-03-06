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

FUNCTION BrowseRn()

   -- o_kalk()
   o_konto()
   cmkonto := Space( 7 )
   cIdFirma := self_organizacija_id()
   Box(, 7, 66, )
   SET CURSOR ON

   @ box_x_koord() + 1, box_y_koord() + 2 SAY "ISPRAVKA BROJA VEZE - RADNI NALOZI"
   IF gNW $ "DX"
      @ box_x_koord() + 3, box_y_koord() + 2 SAY "Firma "; ?? self_organizacija_id(), "-", self_organizacija_naziv()
   ELSE
      @ box_x_koord() + 3, box_y_koord() + 2 SAY "Firma: " GET cIdFirma valid {|| p_partner( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
   ENDIF
   @ box_x_koord() + 4, box_y_koord() + 2 SAY "Magacin Konto: " GET cMKonto   VALID  P_Konto( @cMKonto )
   read
   ESC_BCR

   BoxC()

   cIdFirma := Left( cIdFirma, 2 )

   o_kalk_doks()

   SELECT kalk_doks
   SET ORDER TO TAG "2"
   // CREATE_INDEX("DOKSi2","IdFirma+MKONTO+idzaduz2+idvd+brdok","DOKS")

   Box(, 19, 77 )

   ImeKol := {}
   AAdd( ImeKol, { "F",          {|| IdFirma }                          } )
   AAdd( ImeKol, { "VD  ",       {|| IdVD }                           } )
   AAdd( ImeKol, { "Broj  ",     {|| BrDok }                           } )
   AAdd( ImeKol, { "M.Konto",    {|| mkonto }                    } )
   AAdd( ImeKol, { "RN     ",    {|| IdZaduz2 }                    } )
   AAdd( ImeKol, { "Dat.Dok.",   {|| DatDok }                          } )
   AAdd( ImeKol, { "Nab.Vr",     {|| nv }                          } )
   Kol := {}
   FOR i := 1 TO Len( ImeKol ); AAdd( Kol, i ); NEXT

   SET CURSOR ON
   @ box_x_koord() + 1, box_y_koord() + 1 SAY "<F2> Ispravka dokumenta, <c-P> Print, <a-P> Print Br.Dok"
   @ box_x_koord() + 2, box_y_koord() + 1 SAY "<ENTER> Postavi/Ukini zatvaranje"
   @ box_x_koord() + 3, box_y_koord() + 1 SAY ""; ?? "Konto:", cMKonto
   BrowseKey( box_x_koord() + 4, box_y_koord() + 1, box_x_koord() + 19, box_y_koord() + 77, ImeKol, {| Ch| EdBRN( Ch ) }, "idFirma+mkonto=cidFirma+cmkonto", cidFirma + cmkonto, 2,,, {|| .F. } )

   BoxC()

   closeret

   RETURN



FUNCTION EdBrn( Ch )


   LOCAL cDn := "N", nRet := DE_CONT
   DO CASE
   CASE Ch == K_F2
      cIdzaduz2 := Idzaduz2
      dDatDok := datdok
      Box(, 5, 60, .F. )
      @ box_x_koord() + 1, box_y_koord() + 2 SAY "Broj RN:" GET cIdzaduz2 PICT "@!"
      READ
      BoxC()
      IF LastKey() <> K_ESC
         REPLACE idzaduz2 WITH cidzaduz2
      ENDIF
      SELECT kalk
      SEEK kalk_doks->( idfirma + idvD + brdok )
      DO WHILE  !Eof() .AND. idfirma + idvD + brdok == kalk_doks->( idfirma + idvD + brdok )
         skip; nTrec := RecNo() ; SKIP -1
         REPLACE idzaduz2  WITH cidzaduz2
         GO nTrec
      ENDDO
      SELECT doks

      nRet := DE_REFRESH
   CASE Ch == K_CTRL_P
      PushWA()
      cSeek := idfirma + idvd + brdok
      my_close_all_dbf()
      -- kalk_stampa_dokumenta( .T., cSeek )
      -- o_kalk()
      o_kalk_doks()
      PopWA()
      nRet := DE_REFRESH
   ENDCASE

   RETURN nRet

*/
