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
   LOCAL nRbr, dDatDo, nOdstupanje

   hParams[ "idkonto" ] := PadR( "13202", 7 )
   hParams[ "datdok" ] := Date()
   hParams[ "prag" ] := prag_odstupanja_nc_sumnjiv()


   select_o_kalk_pripr()
   IF reccount2() > 0
      IF Pitanje(, "Brisati pripremu ?", "N" ) == "D"
         my_dbf_zap()
      ELSE
         MsgBeep( "kalk priprema nije prazna!# STOP" )
         RETURN .F.
      ENDIF
   ENDIF

   IF !get_vars( @hParams )
      RETURN .F.
   ENDIF
   cBrDok := kalk_get_next_broj_v5( cIdFirma, "95", NIL )


   MsgO( "Preuzimanje podataka sa servera ..." )
   find_kalk_by_mkonto_idroba( cIdFirma, hParams[ "idkonto" ], NIL, ;
      "kalk_kalk.idroba,kalk_kalk.mkonto", NIL, "kalk_select", "kalk_kalk.idroba" )
   // ( cIdFirma, cIdKonto, cIdRoba, cOrderBy, lReport, cAlias )
   GO TOP
   MsgC()

   select_o_roba()
   select_o_koncij()
   select_o_tarifa()

   SELECT kalk_select

   nRbr := 1
   DO WHILE !kalk_select->( Eof() )

      cIdroba := field->idroba
      dDatDo := hParams[ "datdok" ]
      Scatter() // public vars zapisa
      kalk_pozicioniraj_roba_tarifa_by_kalk_fields()

      kalk_get_nabavna_mag( dDatDo, cIdFirma, cIdRoba, hParams[ "idkonto" ], ;
         @nKolicina, @nKolZN, @nNcZadnjaNabavka, @nSrednjaNabavnaCijena, @dDatNab, ;
         @nNabavnaVrijednost, @nSrednjaNcPoUlazima, .T. )

      SELECT kalk_pripr

      hRec := dbf_get_rec()
      hRec[ "idfirma" ] := cIdFirma
      hRec[ "idvd" ] := "95"
      hRec[ "brdok" ] := cBrDok
      hRec[ "brfaktp" ] := "NC" + DToS( hParams[ "datdok" ] )
      hRec[ "idkonto2" ] := hParams[ "idkonto" ]
      hRec[ "mkonto" ] := hParams[ "idkonto" ]
      hRec[ "mu_i" ] := "5"
      IF Round( nKolicina, 3 ) == 0
         hRec[ "kolicina" ] := 1
         IF Round( nNabavnaVrijednost, 3 ) == 0
            nOdstupanje := 0
         ELSE
            hRec[ "nc" ] := nNabavnaVrijednost + 0.000001 // kartica ima NV, a kolicinu 0, popraviti
            nOdstupanje := 1000
         ENDIF
      ELSE
         hRec[ "kolicina" ] := nKolicina
         hRec[ "nc" ] := nNabavnaVrijednost / nKolicina // srednja nc po kartici
         nOdstupanje := Min( Abs( nSrednjaNcPoUlazima ), Abs( hRec[ "nc" ] ) )
         IF nOdstupanje > 0 // procenat odstupanja srednje nc po ulazima od srednje nc po kartici
            nOdstupanje := Abs( nSrednjaNcPoUlazima - hRec[ "nc" ] ) / nOdstupanje * 100
         ENDIF
      ENDIF

      IF nOdstupanje < hParams[ "prag" ] // nije znacajno odstupanje
         SELECT kalk_select
         SKIP
         LOOP
      ENDIF

      hRec[ "idroba" ] := cIdRoba
      hRec[ "datdok" ] := hParams[ "datdok" ]
      hRec[ "rbr" ] := Str( nRbr++, 3 )
      hRec[ "idtarifa" ] := roba->idtarifa


      SELECT kalk_pripr
      APPEND BLANK
      dbf_update_rec( hRec )

      APPEND BLANK
      IF Abs( Round( nKolicina, 3 ) ) == 0
         hRec[ "kolicina" ] := -1
         hRec[ "nc" ] := 0.000001
      ELSE
         hRec[ "kolicina" ] := -nKolicina
         hRec[ "nc" ] := nSrednjaNcPoUlazima
      ENDIF
      hRec[ "rbr" ] := Str( nRbr++, 3 )
      dbf_update_rec( hRec )

      SELECT kalk_select
      SKIP
   ENDDO

   RETURN .T.


STATIC FUNCTION get_vars( hParams )

   Box( "bv", 10, 80 )
   @ m_x + 1, m_y + 2 SAY "  Magacinski konto: " GET  hParams[ "idkonto" ]
   @ m_x + 2, m_y + 2 SAY "   Datum dokumenta: " GET hParams[ "datdok" ]
   @ m_x + 3, m_y + 2 SAY "prag odstupanja NC: " GET hParams[ "prag" ]


   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   RETURN .T.
