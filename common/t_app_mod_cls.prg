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


FUNCTION TAppModNew( oParent, cVerzija, cPeriod, cKorisn, cSifra, p3, p4, p5, p6, p7 )

   LOCAL oObj

   oObj := TAppMod():new()

   RETURN oObj


CLASS TAppMod

   DATA cName
   DATA oParent
   DATA oDesktop
   DATA cVerzija
   DATA cPeriod
   DATA cKorisn
   DATA cSifra
   DATA cP3
   DATA cP4
   DATA cP5
   DATA cP6
   DATA cP7
   DATA cSqlLogBase
   DATA lSqlDirektno
   DATA lStarted
   DATA lTerminate

   METHOD NEW
   METHOD hasParent
   METHOD setParent
   METHOD getParent
   METHOD setName
   METHOD RUN
   METHOD QUIT
   METHOD gProc
   METHOD gParams
   METHOD setTGVars

ENDCLASS



METHOD new( oParent, cModul, cVerzija, cPeriod, cKorisn, cSifra, p3, p4, p5, p6, p7 ) CLASS TAppMod

   ::lStarted := nil

   ::cName := cModul
   ::oParent := oParent
   ::cVerzija := cVerzija
   ::cPeriod := cPeriod
   ::cKorisn := cKorisn
   ::cSifra := cSifra
   ::cP3 := p3
   ::cP4 := p4
   ::cP5 := p5
   ::cP6 := p6
   ::cP7 := p7
   ::lTerminate := .F.

   RETURN .T.


/*! \fn *bool TAppMod::hasParent()
 *  \brief ima li objekat "roditelja"
 */

// bool TAppMod::hasParent()

METHOD hasParent()

   RETURN !( ::oParent == nil )



/*! \fn *TObject TAppMod::setParent(TObject oParent)
 *  \brief postavi roditelja ovog objekta
 *
 *  Roditelj je programski modul (objekat) koji je izvrsio kreiranje ovog objekta. To bi znacilo za oPos to parent oFMK - "master" aplikacijski modul koji poziva pojedinacne programske module (oFIN, oKALK, oFAKT)
 */
// TObject TAppMod::setParent(TObject oParent)

METHOD setParent( oParent )

   ::parent := oParent

   RETURN .T.


/*! \fn *TObject TAppMod::getParent()
 *  \brief Daj mi roditelja ovog objekta
 */

// TObject TAppMod::getParent()

METHOD getParent()
   return ::oParent



// string TAppMod::setName(string cName)

METHOD setName()

   ::cName := "SCAPP"

   RETURN .T.


// void TAppMod::run()

METHOD run()

   if ::oDesktop == NIL
      ::oDesktop := TDesktopNew()
   ENDIF

   if ::lStarted == NIL
      ::lStarted := .F.
   ENDIF

   start_module( self, .T. )

   // da se zna da je objekat jednom vec startovan
   ::lStarted := .T.

   if ::lTerminate
      ::quit()
      RETURN .F.
   ENDIF

   ::MMenu()

   RETURN .T.



// -----------------------------------------
// *void TAppMod::gProc(char Ch)
// -----------------------------------------

METHOD gProc( Ch )

   LOCAL lPushWa
   LOCAL i

   DO CASE

   CASE ( Ch == K_SH_F1 )
      Calc()

   CASE ( Ch == K_SH_F6 )
      f18_old_session()

   CASE ( Ch == K_SH_F2 .OR. Ch == K_CTRL_F2 )
      PPrint()

   CASE Ch == K_SH_F10
      ::gParams()

   CASE Ch == K_SH_F9
      Adresar()

   OTHERWISE
      IF !( "U" $ Type( "gaKeys" ) )
         FOR i := 1 TO Len( gaKeys )
            IF ( Ch == gaKeys[ i, 1 ] )
               Eval( gaKeys[ i, 2 ] )
            ENDIF
         NEXT
      ENDIF
   ENDCASE

   RETURN .T.



/*! \fn *void TAppMod::quit(bool lVratiseURP)
 *  \brief izlazak iz aplikacijskog modula
 *  \param lVratiSeURP - default vrijednost .t.; kada je .t. vrati se u radno podrucje; .f. ne mjenjaj radno podrucje
 *
 *  \todo proceduru izlaska revidirati, izbaciti Rad.sys iz upotrebe, kao i korisn.dbf
 */

// void TAppMod::quit(bool lVratiSeURP)

METHOD quit( lVratiseURP )

   LOCAL cKontrDbf

   my_close_all_dbf()

   IF ( lVratiseURP == nil )
      lVratiseURP := .T.
   ENDIF

   SetColor( StaraBoja )



   ::lTerminate := .T.

   CLEAR SCREEN

   IF !( ::hasParent() )
      IF !gReadonly
         IF Found()
            SELECT korisn
            IF RLock()
               REPLACE field->nk WITH .F.
            ENDIF
         ELSE
            QUIT
         ENDIF
         USE
         MsgO( "Brisem RAD.SYS ..." )
         ERASE Rad.sys
         MsgC()
      ENDIF
      QUIT
   ENDIF

   RETURN



// void TAppMod::gParams()

METHOD gParams()

   LOCAL cFMKINI := "N"
   LOCAL cPosebno := "N"
   LOCAL cOldBoje := SetColor( INVERT )
   LOCAL cInstall := "N"
   LOCAL lPushWa := .F.
   PRIVATE GetList := {}

   IF Used()
      lPushWa := .T.
      PushWA()
   ELSE
      lPushWa := .F.
   ENDIF

   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   SELECT ( F_PARAMS )
   USE
   O_PARAMS

   RPar( "p?", @cPosebno )

   gArhDir := PadR( gArhDir, 100 )
   gPFont := PadR( gPFont, 20 )

   Box(, 20, 70 )
   SET CURSOR ON
   @ m_x + 1, m_y + 2 SAY "Parametre pohraniti posebno za korisnika "  GET cPosebno VALID cPosebno $ "DN" PICT "@!"
   READ
   WPAr( "p?", cPosebno )
   SELECT params
   USE
   IF cPosebno == "D"
      SELECT ( F_GPARAMSP )
      USE
      O_GPARAMSP
   ELSE
      SELECT ( F_GPARAMS )
      USE
      O_GPARAMS
   ENDIF

   gPtkonv := PadR( gPtkonv, 2 )
   gLokal := PadR( gLokal, 2 )
   @ m_x + 3, m_y + 2 SAY "Konverzija znakova BEZ, 7-852, 7-A, 852-7, 852-A"
   @ m_x + 4, m_y + 2 SAY "                    0  / 1   /  2  / 3   /   4  "  GET gPTKonv PICT "@!" VALID subst( gPtkonv, 2, 1 ) $ " 1"
   @ m_x + 6, m_y + 2 SAY "Unos podataka u sifrarnike velika/mala slova/konv.u 852 (V/M/8)"  GET gPicSif VALID gpicsif $ "VM8" PICT "@!"
   @ m_x + 7, m_y + 2 SAY "Stroga kontrola ispravki/brisanja sifara     (D/N)"  GET gSKSif VALID gSKSif $ "DN" PICT "@!"
   @ m_x + 8, m_y + 2 SAY "Direktorij pomocne kopije podataka" GET gArhDir PICT "@S20"
   @ m_x + 9, m_y + 2 SAY "Default odgovor na pitanje 'Izlaz direktno na printer?' (D/N/V/E)" GET gcDirekt VALID gcDirekt $ "DNVER" PICT "@!"
   @ m_x + 10, m_y + 2 SAY "Shema boja za prikaz na ekranu 'V' (B1/B2/.../B7):" GET gShemaVF
   @ m_x + 11, m_y + 2 SAY "Windows font:" GET gPFont
   @ m_x + 12, m_y + 2 SAY "Kodna strana:" GET gKodnaS VALID gKodnaS $ "78" PICT "9"
   @ m_x + 12, Col() + 2 SAY "Word 97  D/N:" GET gWord97 VALID gWord97 $ "DN" PICT "@!"
   @ m_x + 12, Col() + 2 SAY "Zaok 50f (5):" GET g50f    VALID g50f    $ " 5" PICT "9"
   @ m_x + 14, m_y + 2 SAY "Omoguciti kolor-prikaz? (D/N)" GET gFKolor VALID gFKolor $ "DN" PICT "@!"
   @ m_x + 15, Col() + 2 SAY "SQL log ? (D/N)" GET gSql PICT "@!"

   @ m_x + 16, m_y + 2 SAY "PDV rezim rada? (D/N)" GET gPDV PICT "@!" VALID gPDV $ "DN"

   @ m_x + 17, m_y + 2 SAY "Lokalizacija 0/hr/ba/en/sr " GET gLokal ;
      VALID gLokal $ "0 #hr#ba#sr#en" ;

      @ m_x + 18, m_y + 2 SAY "PDF stampa (N/D/X)?" GET gPDFPrint VALID {|| gPDFPrint $ "DNX" .AND. if( gPDFPrint $ "XD", pdf_box(), .T. ) } PICT "@!"

   @ m_x + 20, m_y + 2 SAY "Ispravka FMK.INI (D/S/P/K/M/N)" GET cFMKINI VALID cFMKINI $ "DNSPKM" PICT "@!"
   @ m_x + 20, m_y + 36 SAY "M - FMKMREZ"


   READ
   BoxC()

   IF cFMKIni $ "DSPKM"
      PRIVATE cKom := "q "
      IF cFMKINI == "D"
         cKom += EXEPATH
      ELSEIF  cFMKINI == "K"
         cKom += KUMPATH
      ELSEIF  cFMKINI == "P"
         cKom += PRIVPATH
      ELSEIF  cFMKINI == "S"
         cKom += SIFPATH
      ENDIF
      // -- M je za ispravku FMKMREZ.BAT
      IF cFMKINI == "M"
         cKom += EXEPATH + "FMKMREZ.BAT"
      ELSE
         cKom += "FMK.INI"
      ENDIF

      Box(, 25, 80 )
      f18_run( ckom )
      BoxC()
      IniRefresh() // izbrisi iz cache-a
   ENDIF


   IF LastKey() <> K_ESC
      Wpar( "pt", gPTKonv )
      Wpar( "pS", gPicSif )
      Wpar( "SK", gSKSif )
      Wpar( "DO", gcDirekt )
      Wpar( "FK", gFKolor )
      Wpar( "S9", gSQL )
      UzmiIzIni( KUMPATH + "fmk.ini", "Svi", "SqlLog", gSql, "WRITE" )
      Wpar( "SB", gShemaVF )
      Wpar( "Ad", Trim( gArhDir ) )
      Wpar( "FO", Trim( gPFont ) )
      Wpar( "KS", gKodnaS )
      Wpar( "W7", gWord97 )
      Wpar( "5f", g50f )
      Wpar( "pR", gPDFPrint )
      WPar( "L8", AllTrim( gLokal ) )
   ENDIF

   KonvTable()

   SELECT gparams
   USE

   SetColor( cOldBoje )

   IF lPushWa
      PopWa()
   ENDIF

   RETURN

// ------------------------------------------------------------
// prikaz dodatnog box-a za stimanje parametara PDF stampe
// ------------------------------------------------------------
STATIC FUNCTION pdf_box()

   LOCAL nX := 1
   PRIVATE GetList := {}

   IF Pitanje(, "Podesiti parametre PDF stampe (D/N) ?", "D" ) == "N"
      RETURN .T.
   ENDIF

   Box(, 10, 75 )

   @ m_x + nX, m_y + 2 SAY "Podesavanje parametara PDF stampe *******"

   nX += 2

   @ m_x + nX, m_y + 2 SAY "PDF preglednik:" GET gPDFViewer VALID _g_pdf_viewer( @gPDFViewer ) PICT "@S56"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "Printanje PDF-a bez poziva preglednika (D/N)?" GET gPDFPAuto VALID gPDFPAuto $ "DN" PICT "@!"

   nX += 2

   @ m_x + nX, m_y + 2 SAY "Default printer:" GET gDefPrinter PICT "@S55"


   READ
   BoxC()

   IF LastKey() <> K_ESC

      // generisi yml fajl iz parametara
      wr_to_yml()

      // snimi parametre.....
      Wpar( "pV", gPDFViewer )
      Wpar( "dP", gDefPrinter )
      Wpar( "pA", gPDFPAuto )

   ENDIF

   RETURN .T.


// ---------------------------------------------
// upisi u yml fajl podesenja
// ---------------------------------------------
STATIC FUNCTION wr_to_yml( cFName )

   LOCAL nH
   LOCAL cParams := ""
   LOCAL cNewRow := Chr( 13 ) + Chr( 10 )

   IF cFName == nil
      cFName := "fmk_pdf.yml"
   ENDIF

   // write params to yml
   cParams += "pdf_viewer: " + AllTrim( gPDFviewer )
   cParams += cNewRow
   cParams += "print_to: " + AllTrim( gDefPrinter )

   // kreiraj fajl
   nH := FCreate( EXEPATH + cFName )
   // upisi u fajl
   FWrite( nH, cParams )
   // zatvori fajl
   FClose( EXEPATH + cFName )

   RETURN



// -------------------------------------------
// vraca lokaciju pdf viewera
// -------------------------------------------
STATIC FUNCTION _g_pdf_viewer( cViewer )

   LOCAL cViewName := "acrord32.exe"
   LOCAL cViewPath := "c:\progra~1\adobe\"
   LOCAL aPath := Directory( cViewPath + "*.*", "D" )
   LOCAL cPom

   IF !Empty( cViewer )
      RETURN .T.
   ENDIF

   ASort( aPath, {| x, y| x[ 1 ] < y[ 1 ] } )

   nScan := AScan( aPath, {| xVal| Upper( xVal[ 1 ] ) = "ACRO" } )

   IF nScan > 0
      cPom := AllTrim( aPath[ nScan, 1 ] )

      cViewer := cViewPath + cPom
      cViewer += SLASH + "reader" + SLASH
      cViewer += cViewName

      cViewer := PadR( cViewer, 150 )

   ENDIF

   IF !Empty( cViewer ) .AND. !File( cViewer )
      msgbeep( "Ne mogu naci Acrobat Reader!#Podesite rucno lokaciju preglednika..." )
   ENDIF

   RETURN .T.


/*! \fn TAppMod::setTGVars()
 *  \brief Setuje globalne varijable, te setuje incijalne vrijednosti objekata koji pripadaju glavnom app objektu
 */

// void TAppMod::setTGVars()

METHOD setTGVars()

   ::cSqlLogBase := IzFmkIni( "Sql", "SqlLogBase", "c:" + SLASH + "sigma" )
   gSqlLogBase := ::cSqlLogBase

   IF IzFmkIni( "Sql", "SqlDirektno", "D" ) == "D"
      ::lSqlDirektno := .T.
   ELSE
      ::lSqlDirektno := .F.
   ENDIF

   IF ( ::oDesktop != nil )
      ::oDesktop := nil
   ENDIF

   ::oDesktop := TDesktopNew()

   RETURN
