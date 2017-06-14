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


/* GetKalkVars(cFirma, cKonto, cPath)
 *     Vraca osnovne var.za rad sa kalk-om
 *   param: cFirma - id firma kalk
 *   param: cKonto - konto prodavnice u kalk-u
 *   param: cPath - putanja do kalk.dbf
 */
FUNCTION GetKalkVars( cFirma, cKonto, cPath )

   // firma je uvijek 50
   cFirma := "50"
   // konto prodavnicki
   cKonto := my_get_from_ini( "TOPS", "TopsKalkKonto", "13270", KUMPATH )
   cKonto := PadR( cKonto, 7 )
   // putanja
   cPath := my_get_from_ini( "TOPS", "KalkKumPath", "i:\sigma", KUMPATH )

   RETURN



/* IntegTekGod()
 *     Vraca tekucu godinu, ako je tek.datum veci od 10.01.TG onda je godina = TG, ako je tek.datum <= 10.01.TG onda je godina (TG - 1)
 *  \return string cYear
 */
FUNCTION IntegTekGod()


   LOCAL dTDate
   LOCAL dPDate
   LOCAL dTYear
   LOCAL cYear

   dTYear := Year( Date() ) // tekuca godina
   dPDate := SToD( AllTrim( Str( dTYear ) ) + "0110" ) // preracunati datum
   dTDate := Date() // tekuci datum

   IF dTDate > dPDate
      cYear := AllTrim( Str( Year( Date() ) ) )
   ELSE
      cYear := AllTrim( Str( Year( Date() ) - 1 ) )
   ENDIF

   RETURN cYear
// }

/* IntegTekDat()
 *     Vraca datum od kada pocinje tekuca godina TOPS, 01.01.TG
 */
FUNCTION IntegTekDat()

   // {
   LOCAL dYear
   LOCAL cDate

   dYear := Year( Date() )
   cDate := AllTrim( IntegTekGod() ) + "0101"

   RETURN SToD( cDate )
// }

/* AddToErrors(cType, cIdRoba, cDoks, cOpis)
 *     dodaj zapis u tabelu errors
 */
FUNCTION AddToErrors( cType, cIDroba, cDoks, cOpis )

   // {
   O_ERRORS
   APPEND BLANK
   REPLACE field->TYPE WITH cType
   REPLACE field->idroba WITH cIdRoba
   REPLACE field->doks WITH cDoks
   REPLACE field->opis WITH cOpis

   RETURN
// }


/* GetErrorDesc(cType)
 *     Vrati naziv greske po cType
 *   param: cType - tip greske, C, W, N ...
 */
FUNCTION GetErrorDesc( cType )

   // {
   cRet := ""
   DO CASE
   CASE cType == "C"
      cRet := "Critical:"
   CASE cType == "N"
      cRet := "Normal:  "
   CASE cType == "W"
      cRet := "Warrning:"
   CASE cType == "P"
      cRet := "Probably OK:"
   ENDCASE

   RETURN cRet
// }


/* RptInteg()
 *     report nakon testa integ1
 *   param: lFilter - filter za kriticne greske
 *   param: lAutoSent - automatsko slanje email-a
 */
FUNCTION RptInteg( lFilter, lAutoSent )

   // {
   IF ( lFilter == nil )
      lFilter := .F.
   ENDIF
   IF ( lAutoSent == nil )
      lAutoSent := .F.
   ENDIF

   O_ERRORS
   SELECT errors
   SET ORDER TO TAG "1"
   IF RecCount() == 0
      MsgBeep( "Integritet podataka ok" )
      // return
   ENDIF

   lOnlyCrit := .F.
   IF lFilter .AND. Pitanje(, "Prikazati samo critical errors (D/N)?", "N" ) == "D"
      lOnlyCrit := .T.
   ENDIF

   START PRINT CRET

   ? "Rezultati analize integriteta podataka"
   ? "===================================================="
   ?

   nCrit := 0
   nNorm := 0
   nWarr := 0
   nPrOk := 0
   nCnt := 1
   cTmpDoks := "XXXX"


   GO TOP
   DO WHILE !Eof()
      cErRoba := field->idroba
      IF lOnlyCrit .AND. AllTrim( field->type ) == "C"
         ? Str( nCnt, 4 ) + ". " + AllTrim( field->idroba )
      ENDIF
      IF !lOnlyCrit
         ? Str( nCnt, 4 ) + ". " + AllTrim( field->idroba )
      ENDIF

      DO WHILE !Eof() .AND. field->idroba == cErRoba

         IF lOnlyCrit .AND. AllTrim( field->type ) <> "C"
            SKIP
            LOOP
         ENDIF

         // ako je prazno DOKSERR onda fali doks
         IF cErRoba = "DOKSERR"
            IF AllTrim( field->doks ) == cTmpDoks
               SKIP
               LOOP
            ENDIF
         ENDIF

         cTmpDoks := AllTrim( field->doks )

         ++nCnt

         ? Space( 5 ) + GetErrorDesc( AllTrim( field->type ) ), AllTrim( field->doks ), AllTrim( field->opis )

         IF AllTrim( field->type ) == "C"
            ++ nCrit
         ENDIF
         IF AllTrim( field->type ) == "N"
            ++ nNorm
         ENDIF
         IF AllTrim( field->type ) == "W"
            ++ nWarr
         ENDIF
         IF AllTrim( field->type ) == "P"
            ++ nPrOk
         ENDIF

         SKIP
      ENDDO
   ENDDO

   ?
   ? "-----------------------------------------"
   ? "Critical errors:", AllTrim( Str( nCrit ) )
   ? "Normal errors:", AllTrim( Str( nNorm ) )
   ? "Warrnings:", AllTrim( Str( nWarr ) )
   ? "Probably OK:", AllTrim( Str( nPrOK ) )
   ?
   ?

   FF
   ENDPRINT

   RptSendEmail( lAutoSent )

   RETURN
// }

/* RptSendEmail()
 *     Slanje reporta na email
 */
FUNCTION RptSendEmail( lAuto )


   LOCAL cScript
   LOCAL cPSite
   LOCAL cRptFile

   IF ( lAuto == nil )
      lAuto := .F.
   ENDIF
   // postavi pitanje ako nije lAuto
   IF !lAuto .AND. Pitanje(, "Proslijediti report email-om (D/N)?", "D" ) == "N"
      RETURN
   ENDIF

   // setuj varijable
   //GetSendVars( @cScript, @cPSite, @cRptFile )
   // komanda je sljedeca
   cKom := cScript + " " + cPSite + " " + cRptFile

   // snimi sliku i ocisti ekran
   SAVE SCREEN TO cRbScr
   CLEAR SCREEN

   ? "err2mail send..."
   // pokreni komandu
   f18_run( cKom )

   Sleep( 3 )
   // vrati staro stanje ekrana
   RESTORE SCREEN FROM cRbScr

   RETURN



/* GetSendVars(cScript)
 *   param: cScript - ruby skripta
 *   param: cPSite - prodavnicki site
 *   param: cRptFile - report fajl
 */
FUNCTION GetSendVars( cScript, cPSite, cRptFile )

   cScript := my_get_from_ini( "Ruby", "Err2Mail", "c:\sigma\err2mail.rb", EXEPATH )
   cPSite := ""
   cRptFile := my_home() + "outf.txt"

   RETURN .T.



/* BrisiError()
 *     Brisanje tabele Errors.dbf
 */
FUNCTION BrisiError()

   O_ERRORS
   SELECT errors
   zapp()

   RETURN

/* EmptDInt(nInteg)
 *     Da li je prazna tabela dinteg
 */
FUNCTION EmptDInt( nInteg )

   // {
   LOCAL cInteg := AllTrim( Str( nInteg ) )
   LOCAL cTbl := "DINTEG" + cInteg
   O_DINTEG1
   O_DINTEG2
   select &cTbl

   IF RecCount() == 0
      MsgBeep( "Tabela " + cTbl + " je prazna !!!" )
      RETURN .T.
   ELSE
      RETURN .F.
   ENDIF

   RETURN
// }



FUNCTION SetGenSif1()

   // {
   // da li je generisan log
   IF AllTrim( integ1->c3 ) == "G"
      RETURN .T.
   ELSE
      REPLACE integ1->c3 WITH "G"
      RETURN .F.
   ENDIF

   RETURN .F.
// }


FUNCTION SetGenSif2()

   // {
   // da li je generisan log
   IF AllTrim( integ2->c3 ) == "G"
      RETURN .T.
   ELSE
      REPLACE integ2->c3 WITH "G"
      RETURN .F.
   ENDIF

   RETURN .F.
// }


// provjera tabele robe
FUNCTION roba_integ( cPKonto, cFmkSifPath, cPosSifPath, cPosKumPath )

   LOCAL cRobaName := "ROBA"
   LOCAL cPosName := "POS"

   cFmkSifPath := AllTrim( cFmkSifPath )
   AddBS( @cFmkSifPath )

   cPosSifPath := AllTrim( cPosSifPath )
   AddBS( @cPosSifPath )

   cPosKumPath := AllTrim( cPosKumPath )
   AddBS( @cPosKumPath )

   // FMK roba
   SELECT ( F_ROBA )
   USE ( cFmkSifPath + cRobaName )
   SET ORDER TO TAG "ID"

   // POS roba
   SELECT ( 0 )
   USE ( cPosSifPath + cRobaName ) ALIAS P_ROBA
   SET ORDER TO TAG "ID"

   // POS kumulativ
   SELECT ( 249 )
   USE ( cPosKumPath + cPosName ) ALIAS P_POS
   // idroba
   SET ORDER TO TAG "6"

   MsgO( "integritet roba pos->fmk...." )
   // provjeri u smijeru pos->fmk
   pos_fmk_roba( cPKonto )
   MsgC()

   // zatvori tabele
   SELECT roba
   USE

   SELECT p_roba
   USE

   SELECT p_pos
   USE

   RETURN


// provjera u smijeru pos->fmk
STATIC FUNCTION pos_fmk_roba( cPKonto )

   LOCAL cRTemp

   SELECT p_roba
   GO TOP

   DO WHILE !Eof()

      cRTemp := field->id

      // provjeri da li se spominje u POS-u
      SELECT p_pos
      HSEEK cRTemp

      // ako se ne spominje i preskoci ga, ovo je nebitna sifra...
      IF !Found()
         SELECT p_roba
         SKIP
         LOOP
      ENDIF

      SELECT roba
      HSEEK cRTemp

      IF !Found()
         AddToErrors( "C", cRTemp, "", "Konto: " + AllTrim( cPKonto ) + ", FMK, nepostojeca sifra artikla !!!" )
      ENDIF

      SELECT p_roba
      SKIP
   ENDDO

   RETURN


// provjera u smijeru fmk->pos
STATIC FUNCTION fmk_pos_roba( cSifra )

   SELECT p_roba
   GO TOP
   SEEK cSifra

   IF !Found()
      AddToErrors( "C", cSifra, "", "TOPSK, nepostojeca sifra artikla !!!" )
   ENDIF

   RETURN
