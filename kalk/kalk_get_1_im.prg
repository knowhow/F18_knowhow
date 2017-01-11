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

STATIC aPorezi := {}

FUNCTION kalk_get_1_im()

   LOCAL nFaktVPC

   _DatFaktP := _datdok

   @ m_x + 8, m_y + 2  SAY "Konto koji zaduzuje" GET _IdKonto VALID  P_Konto( @_IdKonto, 21, 5 ) PICT "@!"
   // IF gNW <> "X"
   // @ m_x + 8, m_y + 35  SAY "Zaduzuje: "   GET _IdZaduz  PICT "@!" VALID Empty( _idZaduz ) .OR. p_partner( @_IdZaduz, 21, 5 )
   // ENDIF
   READ
   ESC_RETURN K_ESC

   @ m_x + 10, m_y + 66 SAY "Tarif.br->"

   kalk_pripr_form_get_roba( @_idRoba, @_idTarifa, _IdVd, kalk_is_novi_dokument(), m_x + 10, m_y + 2, @aPorezi )

   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   READ
   ESC_RETURN K_ESC
   IF roba_barkod_pri_unosu()
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   SELECT tarifa
   HSEEK _IdTarifa
   SELECT kalk_pripr

   // DuplRoba()
   @ m_x + 13, m_y + 2   SAY "Knjizna kolicina " GET _GKolicina PICTURE PicKol WHEN {|| iif( kalk_metoda_nc() == " ", .T., .F. ) }
   @ m_x + 13, Col() + 2 SAY "Popisana Kolicina" GET _Kolicina PICTURE PicKol
   @ m_x + 15, m_y + 2    SAY "CIJENA" GET _vpc PICT picdem

   READ
   ESC_RETURN K_ESC

   _MKonto := _Idkonto


   _MU_I := "I" // inventura

   _PKonto := ""
   _PU_I := ""

   nStrana := 3

   RETURN LastKey()
