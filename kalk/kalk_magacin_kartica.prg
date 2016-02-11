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

STATIC __line
STATIC __txt1
STATIC __txt2

FUNCTION kartica_magacin()

   PARAMETERS cIdFirma, cIdRoba, cIdKonto

   LOCAL nNV := 0
   LOCAL nVPV := 0
   LOCAL cLine
   LOCAL cTxt1
   LOCAL cTxt2
   PRIVATE fKNabC := .F.
   PRIVATE fVeci := .F.
   PRIVATE PicCDEM := Replicate( "9", Val( gFPicCDem ) ) + gPicCDEM
   PRIVATE PicProc := gPicProc
   PRIVATE PicDEM := Replicate( "9", Val( gFPicDem ) ) + gPicDem
   PRIVATE Pickol := "@Z " + Replicate( "9", Val( gFPicKol ) ) + gPickol

   close_open_kart_tables()

   IF cIdFirma != NIL
      dDatOd := CToD( "" )
   ELSE
      dDatOd := Date()
   ENDIF

   dDatDo := Date()
   cPredh := "N"

   PRIVATE cIdR := cIdRoba

   cBrFDa := "N"
   cPrikFCJ2 := "N"

   IF !Empty( cRNT1 )
      PRIVATE cRNalBroj := PadR( "", 40 )
   ENDIF

   cIdPArtner := Space( 6 )
   cPVSS := "D"

   IF cIdKonto == NIL

      cIdFirma := gFirma
      cIdRoba := Space( 10 )
      cIdKonto := PadR( "1320", gDuzKonto )

      cIdRoba := fetch_metric( "kalk_kartica_magacin_id_roba", my_user(), cIdRoba )
      cIdKonto := fetch_metric( "kalk_kartica_magacin_id_konto", my_user(), cIdKonto )
      dDatOd := fetch_metric( "kalk_kartica_magacin_datum_od", my_user(), dDatOd )
      dDatDo := fetch_metric( "kalk_kartica_magacin_datum_do", my_user(), dDatDo )
      cPredh := fetch_metric( "kalk_kartica_magacin_prethodni_promet", my_user(), cPredh )
      cBrFDa := fetch_metric( "kalk_kartica_magacin_prikaz_broja_fakture", my_user(), cBrFDa )
      cPrikFCJ2 := fetch_metric( "kalk_kartica_magacin_prikaz_fakturne_cijene", my_user(), cPrikFCJ2 )
      cPVSS := fetch_metric( "kalk_kartica_magacin_prikaz_samo_saldo", my_user(), cPVSS )
      cIdKonto := PadR( cIdKonto, gDuzKonto )

      Box(, 13, 60 )
      DO WHILE .T.
         IF gNW $ "DX"
            @ m_x + 1, m_y + 2 SAY "Firma "
            ?? gFirma, "-", gNFirma
         ELSE
            @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
         ENDIF
         @ m_x + 2, m_y + 2 SAY "Konto  " GET cIdKonto VALID P_Konto( @cIdKonto )
         IF lKoristitiBK
            @ m_x + 3, m_y + 2 SAY "Artikal" GET cIdRoba  PICT "@!" when {|| cIdRoba := PadR( cIdRoba, Val( gDuzSifIni ) ), .T. } valid {|| Empty( cIdRoba ), cIdRoba := iif( Len( Trim( cIdRoba ) ) <= 10, Left( cIdRoba, 10 ), cIdRoba ), Right( Trim( cIdRoba ), 1 ) $ ";>", P_ROBA( @cIdRoba ) }
         ELSE
            @ m_x + 3, m_y + 2 SAY "Artikal" GET cIdRoba  PICT "@!" VALID Empty( cIdRoba ) .OR. Right( Trim( cIdRoba ), 1 ) $ ";>" .OR. P_ROBA( @cIdRoba )
         ENDIF
		
         IF !Empty( cRNT1 )
            @ m_x + 4, m_y + 2 SAY "Broj radnog naloga:" GET cRNalBroj PICT "@S20"
         ENDIF
		
         @ m_x + 5, m_y + 2 SAY "Partner (prazno-svi)"  GET cIdPArtner  VALID Empty( cIdPartner ) .OR. P_Firma( @cIdPartner )  PICT "@!"
         @ m_x + 7, m_y + 2 SAY "Datum od " GET dDatOd
         @ m_x + 7, Col() + 2 SAY "do" GET dDatDo
         @ m_x + 8, m_y + 2 SAY "sa prethodnim prometom (D/N)" GET cPredh PICT "@!" VALID cpredh $ "DN"
         @ m_x + 9, m_y + 2 SAY "Prikaz broja fakt/otpremice D/N"  GET cBrFDa  VALID cBrFDa $ "DN" PICT "@!"
         @ m_x + 10, m_y + 2 SAY "Prikaz fakturne cijene kod ulaza (KALK 10) D/N"  GET cPrikFCJ2  VALID cPrikFCJ2 $ "DN" PICT "@!"
         IF !gVarEv == "2"
            @ m_x + 11, m_y + 2 SAY "Prikaz vrijednosti samo u saldu ? (D/N)"  GET cPVSS VALID cPVSS $ "DN" PICT "@!"
         ENDIF

         READ
         ESC_BCR
    		
         IF !Empty( cRnT1 ) .AND. !Empty( cRNalBroj )
            PRIVATE aUslRn := Parsiraj( cRNalBroj, "idzaduz2" )
         ENDIF
		
         IF ( Empty( cRNT1 ) .OR. Empty( cRNalBroj ) .OR. aUslRn <> NIL )
            EXIT
         ENDIF
      ENDDO
      BoxC()

      IF Empty( cIdRoba )
         IF pitanje(, "Niste zadali sifru artikla, izlistati sve kartice ?", "N" ) == "N"
            my_close_all_dbf()
            RETURN
         ELSE
            cIdR := cIdRoba
         ENDIF
      ELSE
         cIdr := cIdRoba
      ENDIF

      IF Right( Trim( cIdroba ), 1 ) == ";"
         fVeci := .F.
         cIdr := Trim( StrTran( cIdroba, ";", "" ) )
      ELSEIF Right( Trim( cIdRoba ), 1 ) == ">"
         cIdr := Trim( StrTran( cIdroba, ">", "" ) )
         fVeci := .T.
      ENDIF

      IF LastKey() <> K_ESC
         set_metric( "kalk_kartica_magacin_id_roba", my_user(), cIdRoba )
         set_metric( "kalk_kartica_magacin_id_konto", my_user(), cIdKonto )
         set_metric( "kalk_kartica_magacin_datum_od", my_user(), dDatOd )
         set_metric( "kalk_kartica_magacin_datum_do", my_user(), dDatDo )
         set_metric( "kalk_kartica_magacin_prethodni_promet", my_user(), cPredh )
         set_metric( "kalk_kartica_magacin_prikaz_broja_fakture", my_user(), cBrFDa )
         set_metric( "kalk_kartica_magacin_prikaz_fakturne_cijene", my_user(), cPrikFCJ2 )
         set_metric( "kalk_kartica_magacin_prikaz_samo_saldo", my_user(), cPVSS )
      ENDIF

   ENDIF

   lBezG2 := .F.
   nKolicina := 0

   SELECT kalk
   SET ORDER TO TAG "3"

   PRIVATE cFilt := ".t."

   IF !Empty( cIdPartner )
      cFilt += ".and.IdPartner==" + Cm2Str( cIdPartner )
   ENDIF

   IF !Empty( cRNT1 ) .AND. !Empty( cRNalBroj )
      cFilt += ".and." + aUslRn
   ENDIF

   IF !( cFilt == ".t." )
      SET FILTER to &cFilt
   ENDIF

   HSEEK cIdFirma + cIdKonto + cIdR
   EOF CRET

   SELECT koncij
   SEEK Trim( cIdKonto )

   SELECT kalk

   gaZagFix := { 7, 4 }

   START PRINT CRET

   nLen := 1

   _set_zagl( @cLine, @cTxt1, @cTxt2, cPvSS )
   __line := cLine
   __txt1 := cTxt1
   __txt2 := cTxt2
	
   PRIVATE nTStrana := 0

   zagl_mag_kart()

   DO WHILE !Eof() .AND. iif( fVeci, idfirma + mkonto + idroba >= cIdFirma + cIdKonto + cIdR, idfirma + mkonto + idroba = cIdFirma + cIdKonto + cIdR )

      IF field->mkonto <> cIdKonto .OR. field->idfirma <> cIdFirma
         EXIT
      ENDIF
	
      cIdRoba := idroba
      SELECT roba
      HSEEK cIdRoba

      SELECT tarifa
      HSEEK roba->idtarifa
      ? __line
      ? "Artikal:", cIdRoba, "-", Trim( Left( roba->naz, 40 ) ) + iif( lKoristitiBK, " BK:" + roba->barkod, "" ) + " (" + roba->jmj + ")"

      ? __line
      SELECT kalk

      nCol1 := 10
      nUlaz := nIzlaz := 0
      nRabat := nNV := nVPV := 0
      tnNVd := tnNVp := tnVPVd := tnVPVp := 0
      fPrviProl := .T.
      nColDok := 9
      nColFCJ2 := 68
      cLastPar := ""
      cSKGrup := ""

      DO WHILE !Eof() .AND. cIdFirma + cIdKonto + cIdRoba == idFirma + mkonto + idroba
         nNVd := nNVp := nVPVd := nVPVp := 0
         IF lBezG2 .AND. idvd == "14"
            IF !( cLastPar == idpartner )
               cLastPar := idpartner
               // uzmi iz sifk karakteristiku GRUP
               cSKGrup := IzSifKPartn( "GRUP", idpartner, .F. )
            ENDIF
            IF cSKGrup == "2"
               SKIP 1
               LOOP
            ENDIF
         ENDIF
         IF datdok < ddatod .AND. cPredh == "N"
            SKIP
            LOOP
         ENDIF
         IF datdok > ddatdo
            SKIP
            LOOP
         ENDIF

         IF cPredh == "D" .AND. datdok >= dDatod .AND. fPrviProl
        		
            // ispis predhodnog stanja
            fPrviprol := .F.
        		
            ? "Stanje do ", dDatOd
			
            @ PRow(), 35 SAY nulaz        PICT pickol
            @ PRow(), PCol() + 1 SAY nIzlaz       PICT pickol
            @ PRow(), PCol() + 1 SAY nUlaz - nIzlaz PICT pickol
        		
            // evidencija po cijenama
            IF gVarEv == "1"
               IF Round( nUlaz - nIzlaz, 4 ) <> 0
                  // NC
                  @ PRow(), PCol() + 1 SAY nNV / ( nUlaz - nIzlaz )    PICT pickol
               ELSE
                  @ PRow(), PCol() + 1 SAY 0          PICT pickol
               ENDIF
				
               IF cPVSS == "N" .AND. IsMagPNab()
                  // NV dug. NV pot.
                  @ PRow(), PCol() + 1 SAY tnNVd          PICT picdem
                  @ PRow(), PCol() + 1 SAY tnNVp          PICT picdem
               ENDIF
				
               // NV
               @ PRow(), PCol() + 1 SAY nNV PICT picdem
          			
               // if !IsMagPNab()
				
               // RABAT
               @ PRow(), PCol() + 1 SAY nRabat PICT pickol
            			
               // VPC
               IF Round( nUlaz - nIzlaz, 4 ) <> 0
                  @ PRow(), PCol() + 1 SAY nVPV / ( nUlaz - nIzlaz ) PICT piccdem
               ENDIF
				
               IF !IsMagPNab()
                  // VPV dug. VPV pot.
                  IF cPVSS == "N"
                     @ PRow(), PCol() + 1 SAY tnVPVd PICT picdem
                     @ PRow(), PCol() + 1 SAY tnVPVp PICT picdem
                  ENDIF
				
                  // VPV
                  @ PRow(), PCol() + 1 SAY nVPV PICT picdem
          			
                  // endif
               ENDIF
            ENDIF
         ENDIF
		
         IF PRow() -gPStranica > 62
            FF
            zagl_mag_kart()
         ENDIF
  		
         IF mu_i == "1" .AND. !( idvd $ "12#22#94" )
            nUlaz += kolicina - gkolicina - gkolicin2
            IF datdok >= ddatod
               ? datdok, idvd + "-" + brdok, idtarifa
               ?? "", idpartner
               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY kolicina - gkolicina - gkolicin2 PICT pickol
               @ PRow(), PCol() + 1 SAY 0    PICT pickol
               @ PRow(), PCol() + 1 SAY nUlaz - nIzlaz    PICT pickol
               // NC
               IF gVarEv == "1"
                  @ PRow(), PCol() + 1 SAY nc   PICT piccdem
               ENDIF
            ENDIF
			
            nNVd := nc * ( kolicina - gkolicina - gkolicin2 )
            tnNVd += nNVd
            nNV += nc * ( kolicina - gkolicina - gkolicin2 )
    			
            IF koncij->naz == "P2"
               nVPVd := roba->plc * ( kolicina - gkolicina - gkolicin2 )
               tnVPVd += nVPVd
               nVPV += roba->plc * ( kolicina - gkolicina - gkolicin2 )
            ELSE
               nVPVd := vpc * ( kolicina - gkolicina - gkolicin2 )
               tnVPVd += nVPVd
               nVPV += vpc * ( kolicina - gkolicina - gkolicin2 )
            ENDIF

            IF datdok >= ddatod
               IF gVarEv == "1"
       			
                  // NV dug. NV pot.
			
                  IF cPVSS == "N" .AND. IsMagPNab()
                     @ PRow(), PCol() + 1 SAY nNVd   PICT picdem
                     @ PRow(), PCol() + 1 SAY nNVp   PICT picdem
                  ENDIF
			
                  // NV
                  @ PRow(), PCol() + 1 SAY nNV   PICT picdem
       			
                  // RABAT
                  @ PRow(), PCol() + 1 SAY 0  PICT piccdem
        		
                  // VPC
                  IF koncij->naz == "P2"
                     @ PRow(), PCol() + 1 SAY roba->plc PICT piccdem
                  ELSE
                     @ PRow(), PCol() + 1 SAY vpc PICT piccdem
                  ENDIF
			
                  IF !IsMagPNab()
                     // VPV dug. VPV pot.
                     IF cPVSS == "N"
                        @ PRow(), PCol() + 1 SAY nVpvd PICT picdem
                        @ PRow(), PCol() + 1 SAY nVpvp PICT picdem
                     ENDIF
        		
                     // VPV
                     @ PRow(), PCol() + 1 SAY nVpv PICT picdem
       			
                  ENDIF
			
               ENDIF
			
               IF cBrFDa == "D"
                  @ PRow() + 1, nColDok SAY brfaktp
                  IF !Empty( idzaduz2 )
                     @ PRow(), PCol() + 1 SAY " RN: "
                     ?? idzaduz2
                  ENDIF
               ENDIF

               IF cPrikFCJ2 == "D" .AND. idvd == "10"
                  @ PRow() + IF( cBrFDa == "D", 0, 1 ), nColFCJ2 SAY fcj2 PICT piccdem
               ENDIF
            ENDIF

         ELSEIF mu_i == "5"

            nIzlaz += kolicina
            IF datdok >= ddatod
               ? datdok, idvd + "-" + brdok, idtarifa
               ?? "", idpartner
               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY 0         PICT pickol
               @ PRow(), PCol() + 1 SAY kolicina  PICT pickol
               @ PRow(), PCol() + 1 SAY nUlaz - nIzlaz    PICT pickol
      		
               // NC
               IF gVarEv == "1"
                  @ PRow(), PCol() + 1 SAY nc    PICT piccdem
               ENDIF
            ENDIF

            nNVp := nc * ( kolicina )
            tnNVp += nNVp
            nNV -= nc * ( kolicina )
            IF koncij->naz == "P2"
               nVPVp := roba->plc * ( kolicina )
               tnVPVp += nVPVp
               nVPV -= roba->plc * ( kolicina )
            ELSE
               nVPVp := vpc * ( kolicina )
               tnVPVp += nVPVp
               nVPV -= vpc * ( kolicina )
            ENDIF
            nRabat += vpc * rabatv / 100 * kolicina
            IF datdok >= ddatod
               IF gVarEv == "1"
                  // NV pot. NV dug.
                  IF cPVSS == "N" .AND. IsMagPNab()
                     @ PRow(), PCol() + 1 SAY nNVd PICT picdem
                     @ PRow(), PCol() + 1 SAY nNVp PICT picdem
                  ENDIF
                  // NV
                  @ PRow(), PCol() + 1 SAY nNV PICT picdem
                  // if !IsMagPNab()
			
                  // VPC
                  IF koncij->naz == "P2"
                     @ PRow(), PCol() + 1 SAY vpc * rabatv / 100 * kolicina  PICT piccdem
                     @ PRow(), PCol() + 1 SAY roba->plc  PICT piccdem
                  ELSE
                     @ PRow(), PCol() + 1 SAY vpc * rabatv / 100 * kolicina  PICT piccdem
                     @ PRow(), PCol() + 1 SAY vpc  PICT piccdem
                  ENDIF
			
                  IF !IsMagPNab()
                     IF cPVSS == "N"
                        // VPV dug. VPV pot.
                        @ PRow(), PCol() + 1 SAY nVpvd PICT picdem
                        @ PRow(), PCol() + 1 SAY nVpvp PICT picdem
                     ENDIF
         		
                     // VPV
                     @ PRow(), PCol() + 1 SAY nVpv PICT picdem
         		
                     IF idvd == "11"
                        // PC sa PDV
                        @ PRow(), PCol() + 1 SAY mpcsapp  PICT piccdem
                     ENDIF
			
                  ENDIF
			
                  // endif
			
               ENDIF
               IF cBrFDa == "D"
                  @ PRow() + 1, nColDok SAY brfaktp
                  IF !Empty( idzaduz2 )
                     @ PRow(), PCol() + 1 SAY " RN: "; ?? idzaduz2
                  ENDIF
               ENDIF
            ENDIF

         ELSEIF mu_i == "1" .AND. ( idvd $ "12#22#94" )    // povrat
            nIzlaz -= kolicina
            IF datdok >= ddatod
               ? datdok, idvd + "-" + brdok, idtarifa
               ?? "", idpartner
               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY 0          PICT pickol
               @ PRow(), PCol() + 1 SAY -kolicina  PICT pickol
               @ PRow(), PCol() + 1 SAY nUlaz - nIzlaz    PICT pickol
               IF gVarEv == "1"
      	
                  // NC
                  @ PRow(), PCol() + 1 SAY nc        PICT piccdem

                  // NC pot. NC dug.
                  IF cPVSS == "N" .AND. IsMagPNab()
                     @ PRow(), PCol() + 1 SAY nNVd   PICT picdem
                     @ PRow(), PCol() + 1 SAY nNVp   PICT picdem
                  ENDIF
	
                  // NV
                  @ PRow(), PCol() + 1 SAY nNV        PICT picdem
               ENDIF
            ENDIF
            nNVp := -nc * ( kolicina )
            tnNVp += nNVp
            nNV += nc * ( kolicina )
            IF koncij->naz == "P2"
               nVPVp := -roba->plc * ( kolicina )
               tnVPVp += nVPVp
               nVPV += roba->plc * ( kolicina )
            ELSE
               nVPVp := -vpc * ( kolicina )
               tnVPVp += nVPVp
               nVPV += vpc * ( kolicina )
            ENDIF
            IF datdok >= ddatod
               IF gVarEv == "1"
                  // RABAT
                  @ PRow(), PCol() + 1 SAY 0         PICT piccdem

                  // VPC
                  IF koncij->naz == "P2"
                     @ PRow(), PCol() + 1 SAY roba->plc     PICT piccdem
                  ELSE
                     @ PRow(), PCol() + 1 SAY vpc       PICT piccdem
                  ENDIF
	
                  IF !IsMagPNab()
                     IF cPVSS == "N"
                        // VPV dug. VPV pot.
                        @ PRow(), PCol() + 1 SAY nVpvd PICT picdem
                        @ PRow(), PCol() + 1 SAY nVpvp PICT picdem
                     ENDIF
	
                     // VPV
                     @ PRow(), PCol() + 1 SAY nVpv PICT picdem
                     IF !( idvd == "94" )
                        // PC sa PDV
                        @ PRow(), PCol() + 1 SAY mpcsapp   PICT piccdem
                     ENDIF
                  ENDIF

                  // endif

               ENDIF
               IF cBrFDa == "D"
                  @ PRow() + 1, nColDok SAY brfaktp
                  IF !Empty( idzaduz2 )
                     @ PRow(), PCol() + 1 SAY " RN: "; ?? idzaduz2
                  ENDIF
               ENDIF
            ENDIF // cpredh

         ELSEIF mu_i == "3"   // nivelacija

            IF datdok >= ddatod
               ? datdok, idvd + "-" + brdok, idtarifa
            ENDIF // cpredh

            nVPVd := vpc * ( kolicina )
            tnVPVd += nVPVd
            nVPV += vpc * ( kolicina )
            IF datdok >= ddatod

               @ PRow(), PCol() + 1 SAY PadR( "NIV   (" + Transform( kolicina, pickol ) + ")", Len( pickol ) * 2 + 1 )
               @ PRow(), PCol() + 1 SAY PadR( " stara VPC:", Len( pickol ) -2 )
               @ PRow(), PCol() + 1 SAY mpcsapp       PICT piccdem  // kod ove kalk to predstavlja staru vpc
               @ PRow(), PCol() + 1 SAY PadR( "nova VPC:", Len( piccdem ) + IF( cPVSS == "N" .AND. IsMagPNab(), 2 * ( Len( picdem ) + 1 ), 0 ) )
               @ PRow(), PCol() + 1 SAY vpc + mpcsapp PICT piccdem
               @ PRow(), PCol() + 1 SAY vpc         PICT piccdem

               IF !IsMagPNab()
                  IF cPVSS == "N"
                     @ PRow(), PCol() + 1 SAY nVpvd PICT picdem
                     @ PRow(), PCol() + 1 SAY nVpvp PICT picdem
                  ENDIF
                  @ PRow(), PCol() + 1 SAY nVpv PICT picdem
               ENDIF

               // endif
               IF cBrFDa == "D"
                  @ PRow() + 1, nColDok SAY brfaktp
                  IF !Empty( idzaduz2 )
                     @ PRow(), PCol() + 1 SAY " RN: "; ?? idzaduz2
                  ENDIF
               ENDIF
            ENDIF // cpredh

         ELSEIF mu_i == "8"
            // 15-ka

            nIzlaz +=  - kolicina
            nUlaz +=  - kolicina
            IF datdok >= ddatod
               ? datdok, idvd + "-" + brdok, idtarifa
               ?? "", idpartner
               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY -kolicina  PICT pickol
               @ PRow(), PCol() + 1 SAY -kolicina  PICT pickol
               @ PRow(), PCol() + 1 SAY nUlaz - nIzlaz    PICT pickol
               IF gVarEv == "1"
                  @ PRow(), PCol() + 1 SAY nc        PICT piccdem
               ENDIF
            ENDIF // cpredh

            nRabat += vpc * rabatv / 100 * kolicina
            IF datdok >= ddatod
               IF gVarEv == "1"
                  IF cPVSS == "N" .AND. IsMagPNab()
                     @ PRow(), PCol() + 1 SAY nNVd   PICT picdem
                     @ PRow(), PCol() + 1 SAY nNVp   PICT picdem
                  ENDIF
                  @ PRow(), PCol() + 1 SAY nnv        PICT picdem
                  IF koncij->naz == "P2"
                     @ PRow(), PCol() + 1 SAY vpc * rabatv / 100 * kolicina  PICT piccdem
                     @ PRow(), PCol() + 1 SAY roba->plc  PICT piccdem
                  ELSE
                     @ PRow(), PCol() + 1 SAY vpc * rabatv / 100 * kolicina  PICT piccdem
                     @ PRow(), PCol() + 1 SAY vpc  PICT piccdem
                  ENDIF

                  IF !IsMagPNab()
                     IF cPVSS == "N"
                        @ PRow(), PCol() + 1 SAY nVpvd PICT picdem
                        @ PRow(), PCol() + 1 SAY nVpvp PICT picdem
                     ENDIF
                     @ PRow(), PCol() + 1 SAY nVpv PICT picdem
                     IF idvd == "11"
                        @ PRow(), PCol() + 1 SAY mpcsapp  PICT piccdem
                     ENDIF
                  ENDIF
	
                  // endif
               ENDIF
               IF cBrFDa == "D"
                  @ PRow() + 1, nColDok SAY brfaktp
                  IF !Empty( idzaduz2 )
                     @ PRow(), PCol() + 1 SAY " RN: "; ?? idzaduz2
                  ENDIF
               ENDIF
            ENDIF
         ENDIF

         SKIP
         
      ENDDO
      

      ? __line
      ? "Ukupno:"
      @ PRow(), nCol1    SAY nulaz        PICT pickol
      @ PRow(), PCol() + 1 SAY nizlaz       PICT pickol
      @ PRow(), PCol() + 1 SAY nUlaz - nIzlaz PICT pickol

      IF gVarEv == "1"
         IF Round( nulaz - nizlaz, 4 ) <> 0
            @ PRow(), PCol() + 1 SAY nNV / ( nulaz - nizlaz )    PICT pickol
         ELSE
            @ PRow(), PCol() + 1 SAY 0          PICT pickol
         ENDIF
         IF cPVSS == "N" .AND. IsMagPNab()
            @ PRow(), PCol() + 1 SAY tnNVd          PICT picdem
            @ PRow(), PCol() + 1 SAY tnNVp          PICT picdem
         ENDIF
         @ PRow(), PCol() + 1 SAY nNV          PICT picdem
         @ PRow(), PCol() + 1 SAY nRabat       PICT pickol

         IF !IsMagPNab()

            IF Round( nulaz - nizlaz, 4 ) <> 0
               @ PRow(), PCol() + 1 SAY nVPV / ( nulaz - nizlaz ) PICT piccdem
            ELSEIF Round( nvpv, 3 ) <> 0
               @ PRow(), PCol() + 1 SAY PadC( "ERR", Len( piccdem ) )
            ELSE
               @ PRow(), PCol() + 1 SAY 0            PICT pickol
            ENDIF

            IF cPVSS == "N"
               @ PRow(), PCol() + 1 SAY tnVPVd          PICT picdem
               @ PRow(), PCol() + 1 SAY tnVPVp          PICT picdem
            ENDIF
            @ PRow(), PCol() + 1 SAY nVPV         PICT picdem

         ENDIF

      ENDIF

      ? __line
      ?
      ?

   ENDDO

   FF
   endprint

   my_close_all_dbf()

   RETURN



STATIC FUNCTION close_open_kart_tables()

   SELECT ( F_SIFK )
   IF Used()
      USE
   ENDIF

   SELECT ( F_SIFV )
   IF Used()
      USE
   ENDIF

   SELECT ( F_PARTN )
   IF Used()
      USE
   ENDIF

   SELECT ( F_TARIFA )
   IF Used()
      USE
   ENDIF

   SELECT ( F_ROBA )
   IF Used()
      USE
   ENDIF

   SELECT ( F_KONTO )
   IF Used()
      USE
   ENDIF

   SELECT ( F_KALK )
   IF Used()
      USE
   ENDIF

   SELECT ( F_KONCIJ )
   IF Used()
      USE
   ENDIF

   O_PARTN
   O_TARIFA
   O_SIFK
   O_SIFV
   O_ROBA
   O_KONTO
   O_KONCIJ
   O_KALK

   RETURN


STATIC FUNCTION _set_zagl( cLine, cTxt1, cTxt2, cPVSS, cPicKol, cPicCDem )

   LOCAL nPom
   LOCAL aKMag := {}

   nPom := 8
   // datum
   AAdd( aKMag, { nPom, PadC( "Datum", nPom ), PadC( "", nPom ) } )

   nPom := 11
   // dokument
   AAdd( aKMag, { nPom, PadC( "Dokument", nPom ), PadC( "", nPom ) } )

   nPom := 6
   // tarifa
   AAdd( aKMag, { nPom, PadC( "Tarifa", nPom ), PadC( "", nPom ) } )

   // partner
   AAdd( aKMag, { nPom, PadC( "Part-", nPom ), PadC( "ner", nPom ) } )

   nPom := Len( PicKol ) - 3
   // ulaz, izlaz, stanje
   AAdd( aKMag, { nPom, PadC( "Ulaz", nPom ), PadC( "1", nPom ) } )
   AAdd( aKMag, { nPom, PadC( "Izlaz", nPom ), PadC( "2", nPom ) } )
   AAdd( aKMag, { nPom, PadC( "Stanje", nPom ), PadC( "(1 - 2)", nPom ) } )

   IF gVarEv <> "2"

      nPom := Len( PicCDem )
      // NC, NV
      AAdd( aKMag, { nPom, PadC( "NC", nPom ), PadC( "", nPom ) } )
	
      IF cPVSS == "N" .AND. IsMagPNab()
		
         nPom := Len( PicDem )
         // nv.dug
         AAdd( aKMag, { nPom, PadC( "NV Dug.", nPom ), PadC( "", nPom ) } )
         // nv.pot
         AAdd( aKMag, { nPom, PadC( "NV Pot.", nPom ), PadC( "", nPom ) } )
		
      ENDIF
	
      nPom := Len( PicCDem )
      // NV
      AAdd( aKMag, { nPom, PadC( "NV", nPom ), PadC( "", nPom ) } )
	
      nPom := Len( PicKol ) - 3
      // RABAT
      AAdd( aKMag, { nPom, PadC( "RABAT", nPom ), PadC( "", nPom ) } )

      nPom := Len( PicDem )
      // PC
      AAdd( aKMag, { nPom, PadC( "PC", nPom ), PadC( "bez PDV", nPom ) } )
	
	
      IF !IsMagPNab()
		
         IF cPVSS == "N"
			
            AAdd( aKMag, { nPom, PadC( "PV Dug.", nPom ), PadC( "", nPom ) } )
            AAdd( aKMag, { nPom, PadC( "PV Pot.", nPom ), PadC( "", nPom ) } )
         ENDIF
		
         AAdd( aKMag, { nPom, PadC( "PV", nPom ), PadC( "", nPom ) } )
         AAdd( aKMag, { nPom, PadC( "PC", nPom ), PadC( "sa PDV", nPom ) } )
	
      ENDIF
	
   ENDIF

   cLine := SetRptLineAndText( aKMag, 0 )
   cTxt1 := SetRptLineAndText( aKMag, 1, "*" )
   cTxt2 := SetRptLineAndText( aKMag, 2, "*" )

   RETURN



STATIC FUNCTION zagl_mag_kart()

   SELECT konto
   HSEEK cIdKonto

   ?

   Preduzece()
   P_12CPI

   ?? "KARTICA MAGACIN za period", ddatod, "-", ddatdo, Space( 10 ), "Str:", Str( ++nTStrana, 3 )
   IspisNaDan( 5 )
   ? "Konto: ", cIdKonto, "-", konto->naz

   SELECT kalk

   IF gVarEv == "2"
      P_12CPI
   ELSEIF !IsMagPNab()
      IF cPVSS == "N"
         P_COND2
      ELSE
         P_COND
      ENDIF
   ELSE
      IF cPVSS == "N"
         P_COND2
      ELSE
         P_COND
      ENDIF
   ENDIF

   ? __line
   ? __txt1
   ? __txt2
   ? __line

   RETURN ( nil )




