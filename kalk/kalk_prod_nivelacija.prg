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

// ---------------------------------------------------------------------
// automatsko formiranje nivelacije na osnovu ulaznog dokumenta
// ---------------------------------------------------------------------
FUNCTION kalk_nivelacija_11()

   LOCAL _sufix, _rec

   O_TARIFA
   o_koncij()
   o_kalk_pripr2()
   o_kalk_pripr()

   O_SIFK
   O_SIFV
   O_ROBA

   SELECT kalk_pripr
   GO TOP

   PRIVATE cIdFirma := field->idfirma
   PRIVATE cIdVD := field->idvd
   PRIVATE cBrDok := field->brdok

   IF !( cIdvd $ "11#81" ) .AND. !Empty( gMetodaNC )
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   PRIVATE cBrNiv := "0"

   SELECT kalk
   SEEK cIdFirma + "19" + Chr( 254 )
   SKIP -1

   IF idvd <> "19"
      cBrNiv := Space( 8 )
   ELSE
      cBrNiv := brdok
   ENDIF

   _sufix := SufBrKalk( kalk_pripr->idkonto )
   SELECT kalk_pripr

   cBrNiv := kalk_sljedeci_brdok( "19", gFirma, _sufix )
   // cBrNiv := UBrojDok(val(left(cBrNiv,5))+1,5,right(cBrNiv,3))

   SELECT kalk_pripr
   GO TOP
   PRIVATE nRBr := 0
   cPromCj := "D"
   fNivelacija := .F.

   DO WHILE !Eof() .AND. cIdFirma == idfirma .AND. cIdvd == idvd .AND. cBrdok == brdok

      _rec := dbf_get_rec()

      scatter()

      SELECT koncij
      SEEK Trim( _rec[ "idkonto" ] )

      SELECT roba
      HSEEK _rec[ "idroba" ]

      SELECT tarifa
      HSEEK roba->idtarifa

      SELECT roba

      PRIVATE nMPC := 0
      nMPC := UzmiMPCSif()

      IF dozvoljeno_azuriranje_sumnjivih_stavki()
         faktMPC( @nMPC, _rec[ "idfirma" ] + _rec[ "pkonto" ] + _rec[ "idroba" ] )
         SELECT kalk_pripr
      ENDIF

      IF _rec[ "mpcsapp" ] <> nMPC
         // izvrsiti nivelaciju

         IF !fNivelacija
            // prva stavka za nivelaciju
            cPromCj := Pitanje(, "Postoje promjene cijena. Staviti nove cijene u sifrarnik ?", "D" )
         ENDIF
         fNivelacija := .T.

         PRIVATE nKolZn := nKols := nc1 := nc2 := 0
         PRIVATE dDatNab := CToD( "" )

         kalk_nabavna_prod( _rec[ "idfirma" ], _rec[ "idroba" ], _rec[ "idkonto" ], @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )

         IF dDatNab > _rec[ "datdok" ]
            Beep( 1 )
            Msg( "Datum nabavke je " + DToC( dDatNab ), 4 )
            _rec[ "error" ] := "1"
         ENDIF

         SELECT kalk_pripr2
         // append blank

         _rec[ "idpartner" ] := ""
         _rec[ "vpc" ] := 0
         _rec[ "gkolicina" ] := 0
         _rec[ "gkolicin2" ] := 0
         _rec[ "marza2" ] := 0
         _rec[ "tmarza2" ] := "A"

         PRIVATE cOsn := "2", nStCj := nNCJ := 0

         nStCj := nMPC

         nNCJ := kalk_pripr->MPCSaPP

         _rec[ "mpcsapp" ] := nNCj - nStCj
         _rec[ "mpc" ] := 0
         _rec[ "fcj" ] := nStCj

         IF _rec[ "mpc" ] <> 0
            _rec[ "mpcsapp" ] := ( 1 + tarifa->opp / 100 ) * _rec[ "mpc" ] * ( 1 + tarifa->ppp / 100 )
         ELSE
            _rec[ "mpc" ] := _rec[ "mpcsapp" ] / ( 1 + tarifa->opp / 100 ) / ( 1 + tarifa->ppp / 100 )
         ENDIF

         IF cPromCj == "D"
            SELECT koncij
            SEEK Trim( _rec[ "idkonto" ] )
            SELECT roba
            StaviMPCSif( _rec[ "fcj" ] + _rec[ "mpcsapp" ] )
         ENDIF

         SELECT kalk_pripr2

         _rec[ "pkonto" ] := _rec[ "idkonto" ]
         _rec[ "pu_i" ] := "3"
         _rec[ "mkonto" ] := ""
         _rec[ "mu_i" ] := ""

         _rec[ "kolicina" ] := nKolS
         _rec[ "brdok" ] := cBrniv
         _rec[ "idvd" ] := "19"

         _rec[ "tbanktr" ] := "X"
         _rec[ "error" ] := ""

         IF Round( _rec[ "kolicina" ], 3 ) <> 0
            APPEND ncnl
            _rec[ "rbr" ] := Str( ++nRbr, 3 )
            dbf_update_rec( _rec )
         ENDIF

      ENDIF

      SELECT kalk_pripr
      SKIP

   ENDDO

   my_close_all_dbf()

   RETURN
