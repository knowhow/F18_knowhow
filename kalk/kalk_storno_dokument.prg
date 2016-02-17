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


FUNCTION storno_kalk_dokument()

   // {
   o_kalk_edit()
   cIdFirma := gFirma
   cIdVdU   := "  "
   cBrDokU  := Space( Len( kalk_pripr->brdok ) )
   dDatDok    := CToD( "" )

   Box(, 6, 75 )
   @ m_x + 0, m_y + 5 SAY "STORNO DOKUMENTA PROMJENOM PREDZNAKA NA KOLICINI"
   @ m_x + 2, m_y + 2 SAY "Dokument: " + cIdFirma + "-"
   @ Row(), Col() GET cIdVdU
   @ Row(), Col() SAY "-" GET cBrDokU VALID postoji_kalk_dok( cIdFirma + cIdVdU + cBrDokU )
   @ m_x + 4, m_y + 2 SAY "Datum dokumenta koji se formira" GET dDatDok VALID !Empty( dDatDok )
   READ; ESC_BCR
   BoxC()

   // utvrdimo broj nove kalkulacije
   SELECT kalk_doks; SEEK cIdFirma + cIdVdU + Chr( 255 ); SKIP -1
   IF cIdFirma + cIdVdU == IDFIRMA + IDVD
      cBrDokI := brdok
   ELSE
      cBrDokI := Space( 8 )
   ENDIF
   cBrDokI := UBrojDok( Val( Left( cBrDokI, 5 ) ) + 1, 5, Right( cBrDokI, 3 ) )

   // pocnimo sa generacijom dokumenta
   SELECT KALK
   SEEK cIdFirma + cIdVDU + cBrDokU
   DO WHILE !Eof() .AND. cIdFirma + cIdVDU + cBrDokU == IDFIRMA + IDVD + BRDOK
      PushWA()
      Scatter()
      SELECT kalk_pripr; APPEND BLANK
      _brdok     := cBrDokI
      _datdok    := dDatDok
      _brfaktp   := Trim( _BrFaktP ) + "/STORNO"
      _kolicina  := -_kolicina
      _error     := "0"
      Gather()
      SELECT KALK; PopWA()
      SKIP 1
   ENDDO

   CLOSERET

   RETURN
// }



/*! \fn postoji_kalk_dok(cDok)
 *  \brief Ispituje postojanje zadanog dokumenta medju azuriranim
 */

FUNCTION postoji_kalk_dok( cDok )

   // {
   LOCAL lVrati := .F., nArr := Select()
   SELECT kalk_doks
   HSEEK cDok
   IF Found()
      lVrati := .T.
   ELSE
      MsgBeep( "Dokument pod brojem koji ste unijeli ne postoji!" )
   ENDIF
   SELECT ( nArr )

   RETURN lVrati
// }
