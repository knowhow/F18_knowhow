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


#include "fakt.ch"

// -------------------------------------------------------
// import dokumenta iz txt fajla sa barkod terminala
// -------------------------------------------------------
FUNCTION fakt_import_bterm()

   LOCAL nRet
   LOCAL cFile

   // importuj podatke u pomocnu tabelu TEMP.DBF
   nRet := import_BTerm_data( @cFile )

   IF nRet = 0
      RETURN
   ENDIF

   // prebaci podatke u pripremu FAKT
   bterm_to_pripr()

   // pobrisi txt fajl
   TxtErase( cFile, .T. )

   RETURN


// ----------------------------------------
// export podataka za terminal
// ----------------------------------------
FUNCTION fakt_export_bterm()

   LOCAL nRet

   nRet := export_BTerm_data()

   RETURN


// -----------------------------------------------
// kopira TEMP.DBF -> PRIPR.DBF
// -----------------------------------------------
STATIC FUNCTION bterm_to_pripr()

   LOCAL aParams := {}
   LOCAL nCnt := 0
   LOCAL cSave

   PRIVATE cTipVPC := "1"

   O_FAKT_DOKS
   O_FAKT_PRIPR
   O_FAKT
   O_ROBA
   O_RJ
   O_PARTN

   SELECT ( F_TMP_1 )
   USE

   my_use_temp( "temp", my_home() + "temp" )

   IF _gForm( @aParams ) = 0
      RETURN 0
   ENDIF

   // sacuvaj parametar cijene
   cSave := g13dcij

   // setuj tip cijene koja se koristi
   g13dcij := AllTrim( aParams[ 12 ] )

   SELECT temp
   // idroba
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()
	
      cTrm_roba := field->idroba
      nTrm_qtty := 0
	
      // saberi iste artikle
      DO WHILE !Eof() .AND. field->idroba == cTrm_roba
         nTrm_qtty += field->kolicina
         SKIP
      ENDDO

      // imam konacan artikal
      SELECT fakt_pripr
      APPEND BLANK

      scatter()

      _idfirma := aParams[ 2 ]
      _idtipdok := aParams[ 3 ]
      _brdok := aParams[ 4 ]
      _datdok := aParams[ 5 ]
      _rbr := Str( ++nCnt, 3 )
      _idroba := cTrm_roba
      _kolicina := nTrm_qtty
      _idpartner := aParams[ 8 ]
      _dindem := "KM "
      _zaokr := 2
      _txt := ""

      // ovo setuje cijenu
      v_kolicina( "1" )
      SELECT fakt_pripr

      // 1 roba tip U - nista
      a_to_txt( "", .T. )
      // 2 dodatni tekst otpremnice - nista
      a_to_txt( "", .T. )
      // 3 naziv partnera
      a_to_txt( aParams[ 9 ], .T. )
      // 4 adresa
      a_to_txt( aParams[ 10 ], .T. )
      // 5 ptt i mjesto
      a_to_txt( aParams[ 11 ], .T. )
      // 6 broj otpremnice
      a_to_txt( "", .T. )
      // 7 datum  otpremnice
      a_to_txt( DToC( aParams[ 6 ] ), .T. )
      // 8 broj ugovora - nista
      a_to_txt( "", .T. )
      // 9 datum isporuke - nista
      a_to_txt( DToC( aParams[ 7 ] ), .T. )
      // 10 datum valute - nista
      a_to_txt( "", .T. )

      gather()

      SELECT temp

   ENDDO

   // vrati parametar cijene
   g13dcij := cSave

   msgbeep( "Kreiran je novi dokument i nalazi se u pripremi." )

   RETURN 1



// -----------------------------------------------
// forma uslova prenosa
// -----------------------------------------------
STATIC FUNCTION _gForm( aParam )

   LOCAL GetList := {}
   LOCAL nX := 1
   LOCAL cVpMp := "1"
   LOCAL cFirma := gFirma
   LOCAL cTipDok := Space( 2 )
   LOCAL cBrDok := Space( 8 )
   LOCAL cPartner := Space( 6 )
   LOCAL dDatdok := Date()
   LOCAL dDatOtpr := Date()
   LOCAL dDatIsp := Date()
   LOCAL nTArea := Select()
   LOCAL cGen := "D"
   LOCAL cMPCSet := " "

   Box(, 15, 67 )
	
   @ m_x + nX, m_y + 2 SAY "Generisanje podataka iz barkod terminala:"

   ++nX
   ++nX

   @ m_x + nX, m_y + 2 SAY "(1) Veleprodaja"
	
   ++nX
	
   @ m_x + nX, m_y + 2 SAY "(2) Maloprodaja" GET cVpMp ;
      VALID cVpMp $ "12"

   READ

   ++ nX
   ++ nX

   // datum dokumenta
	
   @ m_x + nX, m_y + 2 SAY "Datum dok.:" GET dDatDok
   @ m_x + nX, Col() + 1 SAY "Datum otpr.:" GET dDatOtpr
   @ m_x + nX, Col() + 1 SAY "Datum isp.:" GET dDatIsp

   ++ nX
   ++ nX

   // vrsta i broj dokumenta
	
   // koji je tip dokumenta
   cTipDok := _gtdok( cVpMp )

   @ m_x + nX, m_y + 2 SAY "Dokument broj:" GET cFirma
   @ m_x + nX, Col() + 1 SAY "-" GET cTipDok ;
      VALID _nBrDok( cFirma, cTipDok, @cBrDok )
   @ m_x + nX, Col() + 1 SAY "-" GET cBrDok
	
   ++nX
   ++nX

   // partner
   @ m_x + nX, m_y + 2 SAY "Partner:" GET cPartner ;
      VALID Empty( cPartner ) .OR. p_firma( @cPartner )

   ++ nX
   ++ nX

   IF cVpMp == "2"

      // tip cijena
      @ m_x + nX, m_y + 2 SAY "Koristiti MPC ( /1/2/3...)" ;
         GET cMPCSet ;
         VALID cMPCSet $ " 123456"
	
      ++ nX
      ++ nX
	
   ENDIF

   @ m_x + nX, m_y + 2 SAY "Izvrsiti transfer (D/N)?" GET cGen ;
      VALID cGen $ "DN" PICT "@!"

   READ
   BoxC()

   IF cGen == "N"
      RETURN 0
   ENDIF

   IF LastKey() <> K_ESC

      // snimi parametre
      // [1]
      AAdd( aParam, cVpMp )
      // [2]
      AAdd( aParam, cFirma )
      // [3]
      AAdd( aParam, cTipDok )
      // [4]
      AAdd( aParam, cBrDok )
      // [5]
      AAdd( aParam, dDatDok )
      // [6]
      AAdd( aParam, dDatOtpr )
      // [7]
      AAdd( aParam, dDatIsp )
      // [8]
      AAdd( aParam, cPartner )

      SELECT partn
      GO TOP
      SEEK cPartner

      // [9]
      AAdd( aParam, AllTrim( field->naz ) )
      // [10]
      AAdd( aParam, AllTrim( field->adresa ) )
      // [11]
      AAdd( aParam, AllTrim( field->ptt ) )

      // [12]
      AAdd( aParam, cMPCSet )

   ELSE
      RETURN 0
   ENDIF

   SELECT ( nTArea )

   RETURN 1


// -----------------------------------------------
// vraca novi broj dokumenta
// -----------------------------------------------
STATIC FUNCTION _nBrDok( cFirma, cTip, cBrDok )

   cBrDok := PadR( Replicate( "0", gNumDio ), 8 )

   RETURN .T.


// -------------------------------------------------
// vraca tip dokumenta na osnovu tipa importa
// -------------------------------------------------
STATIC FUNCTION _gTdok( cTip )

   LOCAL cRet := ""

   DO CASE
   CASE cTip == "1"
      // veleprodaja - direktno racun
      cRet := "10"
   CASE cTip == "2"
      // maloprodaja
      cRet := "13"
   ENDCASE

   RETURN cRet