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

MEMVAR gFirma

FUNCTION kalk_gen_uskladjenje_nc_95()

   LOCAL cIdFirma := gFirma, cIdRoba
   LOCAL cBrDok
   LOCAL hParams := hb_Hash(), hRec
   LOCAL nKolicina, nKolZn, nNcZadnjaNabavka, nSrednjaNabavnaCijena, dDatNab
   LOCAL nNabavnaVrijednost, nSrednjaNcPoUlazima
   LOCAL nRbr

   hParams[ "idkonto" ] := PadR( "13202", 7 )
   hParams[ "datdok" ] := Date()


   select_o_kalk_pripr()
   IF reccount2() > 0
      MsgBeep( "kalk priprema nije prazna!# STOP" )
      RETURN .F.
   ENDIF

   IF !get_vars( @hParams )
      RETURN .F.
   ENDIF
   cBrDok := kalk_get_next_broj_v5( cIdFirma, "95", NIL )


   MsgO( "Preuzimanje podataka sa servera ..." )
   AltD()
   find_kalk_by_mkonto_idroba( cIdFirma, hParams[ "idkonto" ], PadR( "V104050", 10 ), ;
      "kalk_kalk.idroba,kalk_kalk.mkonto", NIL, "kalk_select", "kalk_kalk.idroba" )
   // ( cIdFirma, cIdKonto, cIdRoba, cOrderBy, lReport, cAlias )
   GO TOP
   MsgC()

   select_o_roba()
   select_o_koncij()
   select_o_tarifa()

   SELECT kalk_select
   AltD()

   nRbr := 1
   DO WHILE !kalk_select->( Eof() )

      cIdroba := field->idroba
      Scatter() // public vars zapisa
      kalk_get_nabavna_mag( cIdFirma, cIdRoba, hParams[ "idkonto" ], ;
         @nKolicina, @nKolZN, @nNcZadnjaNabavka, @nSrednjaNabavnaCijena, @dDatNab, @nNabavnaVrijednost, @nSrednjaNcPoUlazima )

      SELECT kalk_pripr
      APPEND BLANK
      hRec := dbf_get_rec()
      hRec[ "idfirma" ] := cIdFirma
      hRec[ "idvd" ] := "95"
      hRec[ "brdok" ] := cBrDok
      hRec[ "brfaktp" ] := "NC" + DToS( hParams[ "datdok" ] )
      hRec[ "idkonto2" ] := hParams[ "idkonto" ]
      hRec[ "mkonto" ] := hParams[ "idkonto" ]

      IF Abs( Round( nKolicina, 4 ) ) == 0
         hRec[ "nc" ] := nNabavnaVrijednost
         hRec[ "kolicina" ] := -1
      ELSE
         hRec[ "kolicina" ] := -nKolicina
         hRec[ "nc" ] := nNabavnaVrijednost / nKolicina // srednja nc po kartici
      ENDIF
      hRec[ "idroba" ] := cIdRoba
      hRec[ "datdok" ] := hParams[ "datdok" ]
      hRec[ "rbr" ] := Str( nRbr++, 3 )
      hRec[ "idtarifa" ] := roba->idtarifa
      kalk_pozicioniraj_roba_tarifa_by_kalk_fields()
      dbf_update_rec( hRec )

      APPEND BLANK
      IF Abs( Round( nKolicina, 4 ) ) == 0
         hRec[ "kolicina" ] := 1
         hRec[ "nc" ] := 0
      ELSE
         hRec[ "nc" ] := 0
         hRec[ "kolicina" ] := nSrednjaNcPoUlazima
      ENDIF

      hRec[ "rbr" ] := Str( nRbr++, 3 )
      dbf_update_rec( hRec )

      SELECT kalk_select
      SKIP
   ENDDO

   RETURN .T.


STATIC FUNCTION get_vars( hParams )

   Box( "bv", 10, 80 )
   @ m_x + 1, m_y + 2 SAY " Magacinski konto: " GET  hParams[ "idkonto" ]
   @ m_x + 2, m_y + 2 SAY " Datum dokumenta " GET hParams[ "datdok" ]

   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   RETURN .T.
