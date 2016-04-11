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


FUNCTION create_porezna_faktura_temp_dbfs()

   LOCAL cDRnName := "drn"
   LOCAL cRnName := "rn"
   LOCAL cDRTxtName := "drntext"
   LOCAL aDRnField := {}
   LOCAL aRnField := {}
   LOCAL aDRTxtField := {}

   get_drn_fields( @aDRnField )
   IF !File( f18_ime_dbf( cDRnName ) )
      DbCreate2( cDRnName, aDRnField )
   ELSE
      IF !is_dbf_struktura_polja_identicna( cDRnName, "BRDOK", 8, 0 )
         ferase_dbf( cDRnName, .T. )
         DbCreate2( cDRnName, aDRnField )
      ENDIF
   ENDIF

   get_rn_fields( @aRnField )
   IF !File( f18_ime_dbf( cRnName ) )
      DbCreate2( cRnName, aRnField )
   ELSE
      IF !is_dbf_struktura_polja_identicna( cRnName, "BRDOK", 8, 0 )
         ferase_dbf( cRnName, .T. )
         DbCreate2( cRnName, aRnField )
      ENDIF
   ENDIF

   IF !File( f18_ime_dbf( cDRTxtName ) )
      get_dtxt_fields( @aDRTxtField )
      DbCreate2( cDRTxtName, aDRTxtField )
   ENDIF

   CREATE_INDEX( "1", "brdok+DToS(datdok)", "drn" )
   CREATE_INDEX( "1", "brdok+rbr+podbr", "rn" )
   CREATE_INDEX( "IDROBA", "idroba", "rn" )
   CREATE_INDEX( "1", "tip", "drntext" )

   RETURN


FUNCTION get_drn_fields( aArr )

   AAdd( aArr, { "BRDOK",   "C",  8, 0 } )
   AAdd( aArr, { "DATDOK",  "D",  8, 0 } )
   AAdd( aArr, { "DATVAL",  "D",  8, 0 } )
   AAdd( aArr, { "DATISP",  "D",  8, 0 } )
   AAdd( aArr, { "VRIJEME", "C",  5, 0 } )
   AAdd( aArr, { "ZAOKR",   "N", 10, 5 } )
   AAdd( aArr, { "UKBEZPDV", "N", 15, 5 } )
   AAdd( aArr, { "UKPOPUST", "N", 15, 5 } )
   AAdd( aArr, { "UKPOPTP", "N", 15, 5 } )
   AAdd( aArr, { "UKBPDVPOP", "N", 15, 5 } )
   AAdd( aArr, { "UKPDV",   "N", 15, 5 } )
   AAdd( aArr, { "UKUPNO",  "N", 15, 5 } )
   AAdd( aArr, { "UKKOL",   "N", 14, 2 } )
   AAdd( aArr, { "CSUMRN",  "N",  6, 0 } )

   RETURN


FUNCTION get_rn_fields( aArr )

   AAdd( aArr, { "BRDOK",   "C",  8, 0 } )
   AAdd( aArr, { "RBR",     "C",  3, 0 } )
   AAdd( aArr, { "PODBR",   "C",  2, 0 } )
   AAdd( aArr, { "IDROBA",  "C", 10, 0 } )
   AAdd( aArr, { "ROBANAZ", "C", 200, 0 } )
   AAdd( aArr, { "JMJ",     "C",  3, 0 } )
   AAdd( aArr, { "KOLICINA", "N", 15, 5 } )
   AAdd( aArr, { "CJENPDV", "N", 15, 5 } )
   AAdd( aArr, { "CJENBPDV", "N", 15, 5 } )
   AAdd( aArr, { "CJEN2PDV", "N", 15, 5 } )
   AAdd( aArr, { "CJEN2BPDV", "N", 15, 5 } )
   AAdd( aArr, { "POPUST",   "N", 8, 3 } )
   AAdd( aArr, { "PPDV",     "N", 8, 3 } )
   AAdd( aArr, { "VPDV",     "N", 15, 5 } )
   AAdd( aArr, { "UKUPNO",    "N", 15, 5 } )
   AAdd( aArr, { "POPTP",   "N", 8, 3 } )
   AAdd( aArr, { "VPOPTP",   "N", 15, 5 } )
   AAdd( aArr, { "C1",   "C", 100, 0 } )
   AAdd( aArr, { "C2",   "C", 100, 0 } )
   AAdd( aArr, { "C3",   "C", 100, 0 } )
   AAdd( aArr, { "OPIS",   "C", 200, 0 } )

   RETURN



FUNCTION get_dtxt_fields( aArr )

   AAdd( aArr, { "TIP",   "C",   3, 0 } )
   AAdd( aArr, { "OPIS",  "C", 200, 0 } )

   RETURN


FUNCTION add_drntext( cTip, cOpis )

   LOCAL lFound

   IF !Used( F_DRNTEXT )
      O_DRNTEXT
      SET ORDER TO TAG "ID"
   ENDIF

   SELECT drntext
   GO TOP


   SEEK cTip

   IF !Found()
      APPEND BLANK
   ENDIF

   REPLACE tip WITH cTip
   REPLACE opis WITH cOpis

   RETURN


FUNCTION add_drn( cBrDok, dDatDok, dDatVal, dDatIsp, cTime, nUBPDV, nUPopust, nUBPDVPopust, nUPDV, nUkupno, nCSum, nUPopTp, nZaokr, nUkkol )

   LOCAL cnt1

   IF !Used( F_DRN )
      O_DRN
   ENDIF

   SELECT drn
   APPEND BLANK

   REPLACE brdok WITH cBrDok
   REPLACE datdok WITH dDatDok
   IF ( dDatVal <> nil )
      REPLACE datval WITH dDatVal
   ENDIF
   IF ( dDatIsp <> nil )
      REPLACE datisp WITH dDatIsp
   ENDIF
   REPLACE vrijeme WITH cTime
   REPLACE ukbezpdv WITH nUBPDV
   REPLACE ukpopust WITH nUPopust
   REPLACE ukbpdvpop WITH nUBPDVPopust
   REPLACE ukpdv WITH nUPDV
   REPLACE ukupno WITH nUkupno
   REPLACE csumrn WITH nCSum
   REPLACE zaokr WITH nZaokr
   REPLACE ukkol WITH nUkKol

   // popust na teret prodavca
   REPLACE ukpoptp WITH nUPopTp

   RETURN

FUNCTION add_drn_datum_isporuke( dDatIsp )

   IF !Used( F_DRN )
      O_DRN
   ENDIF

   SELECT DRN
   IF Empty( brdok )
      APPEND BLANK
   ENDIF

   IF FieldPos( "datisp" ) <> 0
      REPLACE datisp WITH dDatIsp
   ENDIF

   RETURN


FUNCTION get_drn_datum_isporuke()

   LOCAL xRet

   PushWA()

   IF !Used( F_DRN )
      O_DRN
   ENDIF

   SELECT drn
   IF Empty( drn->BrDok )
      xRet := nil
   ELSE

      IF Empty( datisp )
         xRet := datdok
      ELSE
         xRet := datisp
      ENDIF
   ENDIF

   PopWa()

   RETURN xRet


FUNCTION dodaj_stavku_racuna( cBrDok, cRbr, cPodBr, cIdRoba, cRobaNaz, cJmj, nKol, nCjenPdv, nCjenBPdv, nCjen2Pdv, nCjen2BPdv, nPopust, nPPdv, nVPdv, nUkupno, nPopNaTeretProdavca, nVPopNaTeretProdavca, cC1, cC2, cC3, cOpis )

   O_RN

   IF cC1 == nil
      cC1 := ""
   ENDIF
   IF cC2 == nil
      cC2 := ""
   ENDIF
   IF cC3 == nil
      cC3 := ""
   ENDIF
   IF cOpis == nil
      cOpis := ""
   ENDIF

   SELECT rn
   APPEND BLANK

   REPLACE brdok WITH cBrDok
   REPLACE rbr WITH cRbr
   REPLACE podbr WITH cPodBr
   REPLACE idroba WITH cIdRoba
   REPLACE robanaz WITH cRobaNaz
   REPLACE jmj WITH cJmj
   REPLACE c1 WITH cC1
   REPLACE c2 WITH cC2
   REPLACE c3 WITH cC3
   REPLACE opis WITH cOpis
   REPLACE kolicina WITH nKol
   REPLACE cjenpdv WITH nCjenPdv
   REPLACE cjenbpdv WITH nCjenBPdv
   REPLACE cjen2pdv WITH nCjen2Pdv
   REPLACE cjen2bpdv WITH nCjen2BPdv
   REPLACE popust WITH nPopust
   REPLACE ppdv WITH nPPdv
   REPLACE vpdv WITH nVPdv
   REPLACE ukupno WITH nUkupno

   IF ( Round( nPopNaTeretProdavca, 4 ) <> 0 )
      // popust na teret prodavca
      IF FieldPos( "poptp" ) <> 0
         REPLACE poptp WITH nPopNaTeretProdavca
         REPLACE vpoptp WITH nVPopNaTeretProdavca
      ELSE
         MsgBeep( "Tabela RN ne sadrzi POPTP - popust na teret prodavca" )
      ENDIF
   ENDIF

   RETURN


// isprazni drn tabele
FUNCTION zap_racun_tbl()

   SELECT drn
   my_dbf_zap()

   SELECT rn
   my_dbf_zap()

   SELECT drntext
   my_dbf_zap()

   RETURN


// otvori rn tabele
FUNCTION close_open_racun_tbl()

   SELECT ( F_DRN )
   USE
   O_DRN

   SELECT ( F_DRNTEXT )
   USE
   O_DRNTEXT

   SELECT ( F_RN )
   USE
   O_RN

   RETURN


// provjera checksum-a
FUNCTION racun_tbl_checksum()

   LOCAL nCSum
   LOCAL nRNSum

   // uzmi csumrn iz DRN
   SELECT drn
   GO TOP
   nCSum := field->csumrn

   // uzmi broj zapisa iz RN
   SELECT rn
   nRNSum := RecCount2()

   IF nRNSum == nCSum
      RETURN .T.
   ENDIF

   RETURN .F.


// vrati vrijednost polja opis iz tabele drntext.dbf po id kljucu
FUNCTION get_dtxt_opis( cTip )

   LOCAL cRet

   O_DRNTEXT
   SELECT drntext
   SET ORDER TO TAG "1"
   HSEEK cTip

   IF !Found()
      RETURN "-"
   ENDIF
   cRet := RTrim( opis )

   RETURN cRet

// ---------------------------------------------
// azuriranje podataka o kupcu
// ---------------------------------------------
FUNCTION AzurKupData( cIdPos )

   LOCAL cKNaziv
   LOCAL cKAdres
   LOCAL cKIdBroj
   LOCAL _rec
   LOCAL _ok
   LOCAL _tbl := "pos_dokspf"

   O_DRN
   O_DRNTEXT

   cKNaziv := get_dtxt_opis( "K01" )
   cKAdres := get_dtxt_opis( "K02" )
   cKIdBroj := get_dtxt_opis( "K03" )
   dDatIsp := get_drn_datum_isporuke()

   // nema porezne fakture
   IF cKNaziv == "???"
      RETURN
   ENDIF

   O_DOKSPF

   IF !f18_lock_tables( { _tbl } )
      MsgBeep( "Ne mogu lock-ovati dokspf tabelu !!!" )
   ENDIF

   run_sql_query( "BEGIN" )

   SELECT drn
   GO TOP

   SELECT dokspf
   SEEK cIdPos + "42" + DToS( drn->datdok ) + drn->brdok

   IF !Found()
      APPEND BLANK
   ENDIF

   _rec := dbf_get_rec()
   _rec[ "idpos" ] := cIdPos
   _rec[ "idvd" ] := "42"
   _rec[ "brdok" ] := drn->brdok
   _rec[ "datum" ] := drn->datdok

   IF hb_HHasKey( _rec, "datisp" )
      IF dDatIsp <> nil
         _rec[ "datisp" ] := dDatIsp
      ENDIF
   ENDIF

   _rec[ "knaz" ] := cKNaziv
   _rec[ "kadr" ] := cKAdres
   _rec[ "kidbr" ] := cKIdBroj

   update_rec_server_and_dbf( _tbl, _rec, 1, "CONT" )

   run_sql_query( "COMMIT" )
   f18_unlock_tables( { _tbl } )

   RETURN .T.

// pretrazi tabelu kupaca i napuni matricu
FUNCTION fnd_kup_data( cKupac )

   LOCAL aRet := {}
   LOCAL nArr
   LOCAL cFilter := ""
   LOCAL cPartData
   LOCAL cTmp

   IF Right( AllTrim( cKupac ), 2 ) <> ".."
      RETURN aRet
   ENDIF

   // prvo ukini tacku sa kupca
   cKupac := StrTran( AllTrim( cKupac ), "..", ";" )

   nArr := Select()

   O_DOKSPF
   SELECT dokspf

   cFilter := Parsiraj( Lower( cKupac ), "lower(knaz)" )

   SET FILTER to &cFilter
   SET ORDER TO TAG "2"
   GO TOP

   cTmp := "XXX"

   IF !Eof()
      DO WHILE !Eof()

         cPartData := field->knaz + field->kadr + field->kidbr

         IF cPartData == cTmp
            SKIP
            LOOP
         ENDIF

         AAdd( aRet, { field->knaz, field->kadr, field->kidbr } )

         cTmp := cPartData

         SKIP
      ENDDO
   ENDIF

   SET FILTER TO

   SELECT ( nArr )

   RETURN aRet
