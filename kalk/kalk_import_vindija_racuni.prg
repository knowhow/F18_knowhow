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


// stampanje dokumenata .t. or .f.
STATIC __stampaj

// ---------------------------------------------
// glavni meni importa
// ---------------------------------------------
FUNCTION meni_import_vindija()

   PRIVATE izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   __stampaj := .F.

   IF gAImpPrint == "D"
      __stampaj := .T.
   ENDIF

   AAdd( opc, "1. import vindija racun                 " )
   AAdd( opcexe, {|| ImpTxtDok() } )
   AAdd( opc, "2. import vindija partner               " )
   AAdd( opcexe, {|| ImpTxtPartn() } )
   AAdd( opc, "3. import vindija roba               " )
   AAdd( opcexe, {|| ImpTxtRoba() } )
   AAdd( opc, "4. popuna polja sifra dobavljaca " )
   AAdd( opcexe, {|| FillDobSifra() } )
   AAdd( opc, "5. nastavak obrade dokumenata ... " )
   AAdd( opcexe, {|| RestoreObrada() } )
   AAdd( opc, "6. podesenja importa " )
   AAdd( opcexe, {|| aimp_setup() } )
   AAdd( opc, "7. kreiraj pomocnu tabelu stanja" )
   AAdd( opcexe, {|| gen_cache() } )
   AAdd( opc, "8. pregled pomocne tabele stanja" )
   AAdd( opcexe, {|| brow_cache() } )

   Menu_SC( "itx" )

   RETURN .T.



// ----------------------------------
// podesenja importa
// ----------------------------------
STATIC FUNCTION aimp_setup()

   LOCAL nX
   LOCAL GetList := {}

   gAImpRKonto := PadR( gAImpRKonto, 7 )

   nX := 1

   Box(, 10, 70 )

   @ m_x + nX, m_y + 2 SAY "Podesenja importa ********"

   nX += 2
   @ m_x + nX, m_y + 2 SAY "Stampati dokumente pri auto obradi (D/N)" GET gAImpPrint VALID gAImpPrint $ "DN" PICT "@!"

   nX += 1
   @ m_x + nX, m_y + 2 SAY "Automatska ravnoteza naloga na konto: " GET gAImpRKonto

   nX += 1
   @ m_x + nX, m_y + 2 SAY "Provjera broj naloga (minus karaktera):" GET gAImpRight PICT "9"


   READ
   BoxC()

   IF LastKey() <> K_ESC

      O_PARAMS

      PRIVATE cSection := "7"
      PRIVATE cHistory := " "
      PRIVATE aHistory := {}

      WPar( "ap", gAImpPrint )
      WPar( "ak", gAImpRKonto )
      WPar( "ar", gAImpRight )

      SELECT params
      USE

   ENDIF

   RETURN .T.


/* ImpTxtDok()
 *     Import dokumenta
 */
FUNCTION ImpTxtDok()

   LOCAL cCtrl_art := "N"
   PRIVATE cExpPath
   PRIVATE cImpFile

   CrePripTDbf()

   // setuj varijablu putanje exportovanih fajlova
   GetExpPath( @cExpPath )

   // daj mi filter za import MP ili VP
   cFFilt := GetImpFilter()

   IF gNC_ctrl > 0 .AND. Pitanje(, "Ispusti artikle sa problematicnom nc (D/N)", ;
         "N" ) == "D"
      cCtrl_art := "D"
   ENDIF

   // daj mi pregled fajlova za import, te setuj varijablu cImpFile
   IF _gFList( cFFilt, cExpPath, @cImpFile ) == 0
      RETURN
   ENDIF

   // provjeri da li je fajl za import prazan
   IF CheckFile( cImpFile ) == 0
      MsgBeep( "Odabrani fajl je prazan!#!!! Prekidam operaciju !!!" )
      RETURN .F.
   ENDIF

   PRIVATE aDbf := {}
   PRIVATE aRules := {}
   PRIVATE aFaktEx
   PRIVATE lFtSkip := .F.
   PRIVATE lNegative := .F.


   SetTblDok( @aDbf ) // setuj polja temp tabele u matricu aDbf
   SetRuleDok( @aRules ) // setuj pravila upisa podataka u temp tabelu
   Txt2TTbl( aDbf, aRules, cImpFile ) // prebaci iz txt => temp tbl

   IF !CheckDok()
      MsgBeep( "Prekidamo operaciju !!!#Nepostojece sifre!!!" )
      RETURN .F.
   ENDIF

   IF CheckBrFakt( @aFaktEx ) == 0
      IF Pitanje(, "Preskociti ove dokumente prilikom importa (D/N)?", "D" ) == "D"
         lFtSkip := .T.
      ENDIF
   ENDIF

   lNegative := .F.

   IF Pitanje(, "Prebaciti prvo negatine dokumente (povrate) ?", "D" ) == "D"
      lNegative := .T.
   ENDIF

   IF TTbl2Kalk( aFaktEx, lFtSkip, lNegative, cCtrl_art ) == 0
      MsgBeep( "Operacija prekinuta!" )
      RETURN
   ENDIF

   // obrada dokumenata iz pript tabele
   MnuObrDok()

   TxtErase( cImpFile, .T. )

   RETURN



/* GetImpFilter()
 *     Vraca filter za naziv dokumenta u zavisnosti sta je odabrano VP ili MP
 */
STATIC FUNCTION GetImpFilter()

   cVPMP := "V"
   // pozovi box za izbor
   Box(, 5, 60 )
   @ 1 + m_x, 2 + m_y SAY "Importovati:"
   @ 2 + m_x, 2 + m_y SAY "----------------------------------"
   @ 3 + m_x, 2 + m_y SAY "Veleprodaja (V)"
   @ 4 + m_x, 2 + m_y SAY "Maloprodaja (M)"
   @ 5 + m_x, 17 + m_y SAY "izbor =>" GET cVPMP VALID cVPMP $ "MV" .AND. !Empty( cVPMP ) PICT "@!"
   READ
   BoxC()

   // filter za veleprodaju
   cRet := "R*.R??"

   // postavi filter za fajlove
   DO CASE
   CASE cVPMP == "M"
      cRet := "M*.M??"
   CASE cVPMP == "V"
      cRet := "R*.R??"
   ENDCASE

   RETURN cRet



/* MnuObrDok()
 *     Obrada dokumenata iz pomocne tabele
 */
STATIC FUNCTION MnuObrDok()

   IF Pitanje(, "Obraditi dokumente iz pomocne tabele (D/N)?", "D" ) == "D"
      ObradiImport( nil, nil, __stampaj )
   ELSE
      MsgBeep( "Dokumenti nisu obradjeni!#Obrada se moze uraditi i naknadno!" )
      my_close_all_dbf()
   ENDIF

   RETURN



/*
 *  Import sifrarnika partnera
 */
STATIC FUNCTION ImpTxtPartn()

   PRIVATE cExpPath
   PRIVATE cImpFile

   // setuj varijablu putanje exportovanih fajlova
   GetExpPath( @cExpPath )

   cFFilt := "p*.p??"

   // daj mi pregled fajlova za import, te setuj varijablu cImpFile
   IF _gFList( cFFilt, cExpPath, @cImpFile ) == 0
      RETURN
   ENDIF

   // provjeri da li je fajl za import prazan
   IF CheckFile( cImpFile ) == 0
      MsgBeep( "Odabrani fajl je prazan!#!!! Prekidam operaciju !!!" )
      RETURN
   ENDIF

   PRIVATE aDbf := {}
   PRIVATE aRules := {}

   // setuj polja temp tabele u matricu aDbf
   SetTblPartner( @aDbf )
   // setuj pravila upisa podataka u temp tabelu
   SetRulePartn( @aRules )

   // prebaci iz txt => temp tbl
   Txt2TTbl( aDbf, aRules, cImpFile )

   IF CheckPartn() > 0
      IF Pitanje(, "Izvrsiti import partnera (D/N)?", "D" ) == "N"
         MsgBeep( "Opcija prekinuta!" )
         RETURN
      ENDIF
   ELSE
      MsgBeep( "Nema novih partnera za import !" )
      RETURN
   ENDIF

   // ova opcija ipak i nije toliko dobra da se radi!
   //
   // lEdit := Pitanje(,"Izvrsiti korekcije postojecih podataka (D/N)?", "N") == "D"
   lEdit := .F.

   IF TTbl2Partn( lEdit ) == 0
      MsgBeep( "Operacija prekinuta!" )
      RETURN
   ENDIF

   MsgBeep( "Operacija zavrsena !" )

   TxtErase( cImpFile )

   RETURN



// ------------------------------------------
// import sifrarnika robe
// ------------------------------------------
STATIC FUNCTION ImpTxtRoba()

   PRIVATE cExpPath
   PRIVATE cImpFile

   // setuj varijablu putanje exportovanih fajlova
   GetExpPath( @cExpPath )

   cFFilt := "s*.s??"

   // daj mi pregled fajlova za import, te setuj varijablu cImpFile
   IF _gFList( cFFilt, cExpPath, @cImpFile ) == 0
      RETURN
   ENDIF

   // provjeri da li je fajl za import prazan
   IF CheckFile( cImpFile ) == 0
      MsgBeep( "Odabrani fajl je prazan!#!!! Prekidam operaciju !!!" )
      RETURN
   ENDIF

   PRIVATE aDbf := {}
   PRIVATE aRules := {}
   // setuj polja temp tabele u matricu aDbf
   SetTblRoba( @aDbf )
   // setuj pravila upisa podataka u temp tabelu
   SetRuleRoba( @aRules )

   // prebaci iz txt => temp tbl
   Txt2TTbl( aDbf, aRules, cImpFile )

   IF CheckRoba() > 0
      IF Pitanje(, "Importovati nove cijene u sifrarnika robe (D/N)?", "D" ) == "N"
         MsgBeep( "Opcija prekinuta!" )
         RETURN
      ENDIF
   ELSE
      MsgBeep( "Nema novih stavki za import !" )
      RETURN
   ENDIF

   lEdit := .F.

   IF TTbl2Roba( lEdit ) == 0
      MsgBeep( "Operacija prekinuta!" )
      RETURN
   ENDIF

   MsgBeep( "Operacija zavrsena !" )

   TxtErase( cImpFile )

   RETURN



/* SetTblDok(aDbf)
 *     Setuj matricu sa poljima tabele dokumenata RACUN
 *   param: aDbf - matrica
 */
STATIC FUNCTION SetTblDok( aDbf )

   AAdd( aDbf, { "idfirma", "C", 2, 0 } )
   AAdd( aDbf, { "idtipdok", "C", 2, 0 } )
   AAdd( aDbf, { "brdok", "C", 8, 0 } )
   AAdd( aDbf, { "datdok", "D", 8, 0 } )
   AAdd( aDbf, { "idpartner", "C", 6, 0 } )
   AAdd( aDbf, { "idpm", "C", 3, 0 } )
   AAdd( aDbf, { "dindem", "C", 3, 0 } )
   AAdd( aDbf, { "zaokr", "N", 1, 0 } )
   AAdd( aDbf, { "rbr", "C", 3, 0 } )
   AAdd( aDbf, { "idroba", "C", 10, 0 } )
   AAdd( aDbf, { "kolicina", "N", 14, 5 } )
   AAdd( aDbf, { "cijena", "N", 14, 5 } )
   AAdd( aDbf, { "rabat", "N", 14, 5 } )
   AAdd( aDbf, { "porez", "N", 14, 5 } )
   AAdd( aDbf, { "rabatp", "N", 14, 5 } )
   AAdd( aDbf, { "datval", "D", 8, 0 } )
   AAdd( aDbf, { "obrkol", "N", 14, 5 } )
   AAdd( aDbf, { "idpj", "C", 3, 0 } )
   AAdd( aDbf, { "dtype", "C", 3, 0 } )

   RETURN

/* SetTblPartner(aDbf)
 *     Set polja tabele partner
 *   param: aDbf - matrica sa def.polja
 */
STATIC FUNCTION SetTblPartner( aDbf )

   AAdd( aDbf, { "idpartner", "C", 6, 0 } )
   AAdd( aDbf, { "naz", "C", 25, 0 } )
   AAdd( aDbf, { "ptt", "C", 5, 0 } )
   AAdd( aDbf, { "mjesto", "C", 16, 0 } )
   AAdd( aDbf, { "adresa", "C", 24, 0 } )
   AAdd( aDbf, { "ziror", "C", 22, 0 } )
   AAdd( aDbf, { "telefon", "C", 12, 0 } )
   AAdd( aDbf, { "fax", "C", 12, 0 } )
   AAdd( aDbf, { "idops", "C", 4, 0 } )
   AAdd( aDbf, { "rokpl", "N", 5, 0 } )
   AAdd( aDbf, { "porbr", "C", 16, 0 } )
   AAdd( aDbf, { "idbroj", "C", 16, 0 } )
   AAdd( aDbf, { "ustn", "C", 20, 0 } )
   AAdd( aDbf, { "brupis", "C", 20, 0 } )
   AAdd( aDbf, { "brjes", "C", 20, 0 } )

   RETURN



// -------------------------------------
// matrica sa strukturom
// tabele ROBA
// -------------------------------------
STATIC FUNCTION SetTblRoba( aDbf )

   AAdd( aDbf, { "idpm", "C", 3, 0 } )
   AAdd( aDbf, { "datum", "C", 10, 0 } )
   AAdd( aDbf, { "sifradob", "C", 10, 0 } )
   AAdd( aDbf, { "naz", "C", 30, 0 } )
   AAdd( aDbf, { "mpc", "N", 15, 5 } )

   RETURN




/* SetRuleDok(aRule)
 *     Setovanje pravila upisa zapisa u temp tabelu
 *   param: aRule - matrica pravila
 */
STATIC FUNCTION SetRuleDok( aRule )

   // idfirma
   AAdd( aRule, { "SUBSTR(cVar, 1, 2)" } )
   // idtipdok
   AAdd( aRule, { "SUBSTR(cVar, 4, 2)" } )
   // brdok
   AAdd( aRule, { "SUBSTR(cVar, 7, 8)" } )
   // datdok
   AAdd( aRule, { "CTOD(SUBSTR(cVar, 16, 10))" } )
   // idpartner
   AAdd( aRule, { "SUBSTR(cVar, 27, 6)" } )
   // id pm
   AAdd( aRule, { "SUBSTR(cVar, 34, 3)" } )
   // dindem
   AAdd( aRule, { "SUBSTR(cVar, 38, 3)" } )
   // zaokr
   AAdd( aRule, { "VAL(SUBSTR(cVar, 42, 1))" } )
   // rbr
   AAdd( aRule, { "STR(VAL(SUBSTR(cVar, 44, 3)),3)" } )
   // idroba
   AAdd( aRule, { "ALLTRIM(SUBSTR(cVar, 48, 5))" } )
   // kolicina
   AAdd( aRule, { "VAL(SUBSTR(cVar, 54, 16))" } )
   // cijena
   AAdd( aRule, { "VAL(SUBSTR(cVar, 71, 16))" } )
   // rabat
   AAdd( aRule, { "VAL(SUBSTR(cVar, 88, 14))" } )
   // porez
   AAdd( aRule, { "VAL(SUBSTR(cVar, 103, 14))" } )
   // procenat rabata
   AAdd( aRule, { "VAL(SUBSTR(cVar, 118, 14))" } )
   // datum valute
   AAdd( aRule, { "CTOD(SUBSTR(cVar, 133, 10))" } )
   // obracunska kolicina
   AAdd( aRule, { "VAL(SUBSTR(cVar, 144, 16))" } )
   // poslovna jedinica "kod"
   AAdd( aRule, { "SUBSTR(cVar, 161, 3)" } )

   RETURN



/* SetRulePartn(aRule)
 *     Setovanje pravila upisa zapisa u temp tabelu
 *   param: aRule - matrica pravila
 */
STATIC FUNCTION SetRulePartn( aRule )

   // id
   AAdd( aRule, { "SUBSTR(cVar, 1, 6)" } )
   // naz
   AAdd( aRule, { "SUBSTR(cVar, 8, 25)" } )
   // ptt
   AAdd( aRule, { "SUBSTR(cVar, 34, 5)" } )
   // mjesto
   AAdd( aRule, { "SUBSTR(cVar, 40, 16)" } )
   // adresa
   AAdd( aRule, { "SUBSTR(cVar, 57, 24)" } )
   // ziror
   AAdd( aRule, { "SUBSTR(cVar, 82, 22)" } )
   // telefon
   AAdd( aRule, { "SUBSTR(cVar, 105, 12)" } )
   // fax
   AAdd( aRule, { "SUBSTR(cVar, 118, 12)" } )
   // idops
   AAdd( aRule, { "SUBSTR(cVar, 131, 4)" } )
   // rokpl
   AAdd( aRule, { "VAL(SUBSTR(cVar, 136, 5))" } )
   // porbr
   AAdd( aRule, { "SUBSTR(cVar, 143, 16)" } )
   // idbroj
   AAdd( aRule, { "SUBSTR(cVar, 160, 16)" } )
   // ustn
   AAdd( aRule, { "SUBSTR(cVar, 177, 20)" } )
   // brupis
   AAdd( aRule, { "SUBSTR(cVar, 198, 20)" } )
   // brjes
   AAdd( aRule, { "SUBSTR(cVar, 219, 20)" } )

   RETURN .T.



// ---------------------------------------------
// pravila za import tabele robe
// ---------------------------------------------
STATIC FUNCTION SetRuleRoba( aRule )

   // idpm
   AAdd( aRule, { "SUBSTR(cVar, 1, 3)" } )
   // datum
   AAdd( aRule, { "SUBSTR(cVar, 5, 10)" } )
   // sifra dobavljaca
   AAdd( aRule, { "SUBSTR(cVar, 16, 6)" } )
   // naziv
   AAdd( aRule, { "SUBSTR(cVar, 22, 30)" } )
   // mpc
   AAdd( aRule, { "VAL( STRTRAN( SUBSTR(cVar, 53, 10), ',', '.' ) )" } )

   RETURN





/* GetExpPath(cPath)
 *     Vraca podesenje putanje do exportovanih fajlova
 *   param: cPath - putanja, zadaje se sa argumentom @ kao priv.varijabla
 */
STATIC FUNCTION GetExpPath( cPath )

   cPath := fetch_metric( "kalk_import_txt_path", my_user(), "" )

   IF Empty( cPath ) .OR. cPath == NIL
      cPath := "c:" + SLASH + "liste" + SLASH
   ENDIF

   RETURN .T.



/* Txt2TTbl(aDbf, aRules, cTxtFile)
 *     Kreiranje temp tabele, te prenos zapisa iz text fajla "cTextFile" u tabelu putem aRules pravila
 *   param: aDbf - struktura tabele
 *   param: aRules - pravila upisivanja jednog zapisa u tabelu, princip uzimanja zapisa iz linije text fajla
 *   param: cTxtFile - txt fajl za import
 */
// /
STATIC FUNCTION Txt2TTbl( aDbf, aRules, cTxtFile )

   LOCAL _o_file

   // prvo kreiraj tabelu temp
   my_close_all_dbf()

   CreTemp( aDbf )
   O_TEMP

   IF !File( f18_ime_dbf( "TEMP" ) )
      MsgBeep( "Ne mogu kreirati fajl TEMP.DBF!" )
      RETURN .F.
   ENDIF

   // zatim iscitaj fajl i ubaci podatke u tabelu

   cTxtFile := AllTrim( cTxtFile )

   _o_file := TFileRead():New( cTxtFile )
   _o_file:Open()

   IF _o_file:Error()
      MsgBeep( _o_file:ErrorMsg( "Problem sa otvaranjem fajla: " ) )
   ENDIF

   // prodji kroz svaku liniju i insertuj zapise u temp.dbf
   WHILE _o_file:MoreToRead()

      // uzmi u cText liniju fajla
      cVar := hb_StrToUTF8( _o_file:ReadLine() )

      // selektuj temp tabelu
      SELECT temp
      // dodaj novi zapis
      APPEND BLANK

      FOR nCt := 1 TO Len( aRules )
         fname := FIELD( nCt )
         xVal := aRules[ nCt, 1 ]
         replace &fname with &xVal
      NEXT

   ENDDO

   _o_file:Close()

   SELECT temp

   // proði kroz temp i napuni da li je dtype pozitivno ili negativno
   // ali samo ako je u pitanju racun tabela... !
   IF temp->( FieldPos( "idtipdok" ) ) <> 0
      GO TOP
      my_flock()
      DO WHILE !Eof()
         IF field->idtipdok == "10" .AND. field->kolicina < 0
            REPLACE field->dtype WITH "0"
         ELSE
            REPLACE field->dtype WITH "1"
         ENDIF
         SKIP
      ENDDO
      my_unlock()
   ENDIF

   MsgBeep( "Import txt => temp - OK" )

   RETURN



/* CheckFile(cTxtFile)
 *     Provjerava da li je fajl prazan
 *   param: cTxtFile - txt fajl
 */
FUNCTION CheckFile( cTxtFile )

   nBrLin := BrLinFajla( cTxtFile )

   RETURN nBrLin



/* CreTemp(aDbf)
 *  brief Kreira tabelu PRIVPATH/TEMP.DBF prema definiciji polja iz aDbf
 *  param aDbf - def.polja
 */
STATIC FUNCTION CreTemp( aDbf )

   cTmpTbl := "temp"

   IF File( f18_ime_dbf( cTmpTbl ) ) .AND. FErase( f18_ime_dbf( cTmpTbl ) ) == -1
      MsgBeep( "Ne mogu izbrisati TEMP.DBF!" )

   ENDIF

   DbCreate2( cTmpTbl, aDbf )

   // provjeri jesu li partneri ili dokumenti ili je roba
   IF aDbf[ 1, 1 ] == "idpartner"
      // partner
      create_index( "1", "idpartner", cTmpTbl )
   ELSEIF aDbf[ 1, 1 ] == "idpm"
      // roba
      create_index( "1", "sifradob", cTmpTbl )
   ELSE
      // dokumenti
      create_index( "1", "idfirma+idtipdok+brdok+rbr", cTmpTbl )
      create_index( "2", "dtype+idfirma+idtipdok+brdok+rbr", cTmpTbl )
   ENDIF

   RETURN



FUNCTION CrePriptDbf()

   LOCAL _pript_tbl := "kalk_pript"

   my_close_all_dbf()

   FErase( my_home() + _pript_tbl + ".dbf" )
   FErase( my_home() + _pript_tbl + ".cdx" )

   O_KALK_PRIPR

   // napravi pript sa strukturom tabele kalk_pripr
   COPY STRUCTURE EXTENDED to ( my_home() + "struct" )
   CREATE ( my_home() + _pript_tbl ) from ( my_home() + "struct" )

   USE

   SELECT ( F_PRIPT )
   my_use_temp( "PRIPT", my_home() + _pript_tbl, .F., .T. )

   INDEX on ( idfirma + idvd + brdok ) TAG "1"
   INDEX on ( idfirma + idvd + brdok + idroba ) TAG "2"

   USE

   RETURN



/* CheckBrFakt()
 *     Provjeri da li postoji broj fakture u azuriranim dokumentima
 */
STATIC FUNCTION CheckBrFakt( aFakt )

   aPomFakt := FaktExist( gAImpRight )

   IF Len( aPomFakt ) > 0

      START PRINT CRET

      ?
      ? "Kontrola azuriranih dokumenata:"
      ? "-------------------------------"
      ? "Broj fakture => kalkulacija"
      ? "-------------------------------"
      ?

      FOR i := 1 TO Len( aPomFakt )
         ? aPomFakt[ i, 1 ] + " => " + aPomFakt[ i, 2 ]
      NEXT

      ?
      ? "Kontrolom azuriranih dokumenata, uoceno da se vec pojavljuju"
      ? "navedeni brojevi faktura iz fajla za import !"
      ?

      FF
      ENDPRINT

      aFakt := aPomFakt
      RETURN 0

   ENDIF

   aFakt := aPomFakt

   RETURN 1



/* CheckDok()
 *     Provjera da li postoje sve sifre u sifarnicima za dokumente
 */
STATIC FUNCTION CheckDok()

   LOCAL lSifDob := .T.

   aPomPart := ParExist()
   aPomArt  := TempArtExist( lSifDob )

   IF ( Len( aPomPart ) > 0 .OR. Len( aPomArt ) > 0 )

      START PRINT CRET

      IF ( Len( aPomPart ) > 0 )
         ? "Lista nepostojecih partnera:"
         ? "----------------------------"
         ?
         FOR i := 1 TO Len( aPomPart )
            ? aPomPart[ i, 1 ]
         NEXT
         ?
      ENDIF

      IF ( Len( aPomArt ) > 0 )
         ? "Lista nepostojecih artikala:"
         ? "----------------------------"
         ?
         FOR ii := 1 TO Len( aPomArt )
            ? aPomArt[ ii, 1 ]
         NEXT
         ?
      ENDIF

      FF
      ENDPRINT

      RETURN .F.
   ENDIF

   RETURN .T.




/* fn CheckPartn()
 *  Provjerava i daje listu nepostojecih partnera pri importu liste partnera
 */
STATIC FUNCTION CheckPartn()

   aPomPart := ParExist( .T. )

   IF ( Len( aPomPart ) > 0 )

      START PRINT CRET

      ? "Lista nepostojecih partnera:"
      ? "----------------------------"
      ?
      FOR i := 1 TO Len( aPomPart )
         ? aPomPart[ i, 1 ]
         ?? " " + aPomPart[ i, 2 ]
      NEXT
      ?

      FF
      ENDPRINT

   ENDIF

   RETURN Len( aPomPart )




// --------------------------------------------------------------------------
// Provjerava i daje listu promjena na robi
// --------------------------------------------------------------------------
STATIC FUNCTION CheckRoba()

   aPomRoba := SDobExist( .T. )

   IF ( Len( aPomRoba ) > 0 )

      START PRINT CRET

      ? "Lista promjena u sifrarniku robe:"
      ? "---------------------------------------------------------------------------"
      ? "sifradob    naziv                          stara cijena -> nova cijena "
      ? "---------------------------------------------------------------------------"
      ?

      FOR i := 1 TO Len( aPomRoba )

         ? aPomRoba[ i, 2 ]

         ?? " " + aPomRoba[ i, 9 ]

         IF aPomRoba[ i, 1 ] == "1"

            IF aPomRoba[ i, 3 ] == "001"
               // vpc
               nCijena := aPomRoba[ i, 6 ]
            ELSEIF aPomRoba[ i, 3 ] == "002"
               // vpc2
               nCijena := aPomRoba[ i, 7 ]
            ELSEIF aPomRoba[ i, 3 ] == "003"
               // mpc
               nCijena := aPomRoba[ i, 8 ]
            ENDIF

            ?? Str( nCijena, 12, 2 )
            ?? Str( aPomRoba[ i, 4 ], 12, 2 )

            IF nCijena = aPomRoba[ i, 4 ]
               ?? " x"
            ENDIF

         ELSE
            ?? " ovog artikla nema u sifrarniku !"
         ENDIF

      NEXT

      ?

      FF
      ENDPRINT

   ENDIF

   RETURN Len( aPomRoba )



// --------------------------------------------------------
// provjerava da li postoji roba po sifri dobavljaca
// --------------------------------------------------------
STATIC FUNCTION SDobExist()

   LOCAL aRet

   O_ROBA
   SELECT temp
   GO TOP

   aRet := {}

   DO WHILE !Eof()

      SELECT roba
      SET ORDER TO TAG "SIFRADOB"
      GO TOP

      SEEK temp->sifradob

      IF Found()
         cInd := "1"
      ELSE
         cInd := "0"
      ENDIF

      AAdd( aRet, { cInd, temp->sifradob, temp->idpm, temp->mpc, roba->id, ;
         roba->vpc, roba->vpc2, roba->mpc, temp->naz } )

      SELECT temp
      SKIP

   ENDDO

   RETURN aRet




STATIC FUNCTION ParExist( lPartNaz )

   O_PARTN
   SELECT temp
   GO TOP

   IF lPartNaz == nil
      lPartNaz := .F.
   ENDIF

   aRet := {}

   DO WHILE !Eof()
      SELECT partn
      GO TOP
      SEEK temp->idpartner
      IF !Found()
         IF lPartNaz
            AAdd( aRet, { temp->idpartner, temp->naz } )
         ELSE
            AAdd( aRet, { temp->idpartner } )
         ENDIF
      ENDIF
      SELECT temp
      SKIP
   ENDDO

   RETURN aRet



/* GetKTipDok(cFaktTD)
 *     Vraca kalk tip dokumenta na osnovu fakt tip dokumenta
 *   param: cFaktTD - fakt tip dokumenta
 */
STATIC FUNCTION GetKTipDok( cFaktTD, cPm )

   cRet := ""

   IF ( cFaktTD == "" .OR. cFaktTD == nil )
      RETURN "XX"
   ENDIF

   DO CASE
      // racuni VP
      // FAKT 10 -> KALK 14
   CASE cFaktTD == "10"
      cRet := "14"

      // diskont vindija
      // FAKT 11 -> KALK 41
   CASE ( cFaktTD == "11" .AND. cPm >= "200" )
      cRet := "41"

      // zaduzenje prodavnica
      // FAKT 13 -> KALK 11
   CASE ( cFaktTD == "11" .AND. cPm < "200" )
      cRet := "11"

      // kalo, rastur - otpis
      // radio se u kalku
   CASE cFaktTD $ "90#91#92"
      cRet := "95"

      // Knjizna obavjest
      // 70 -> KALK KO
   CASE cFaktTD == "70"
      cRet := "KO"

   ENDCASE

   RETURN cRet



// ---------------------------------------------------------------
// Vrati konto za prodajno mjesto Vindijine prodavnice
// cProd - prodajno mjesto C(3), npr "200"
// cPoslovnica - poslovnica sarajevo ili tuzla ili ....
// cita iz fmk.ini/kumpath
// [Vindija]
// VPR200_050=13200
// VPR201_050=13201
// itd....
// ---------------------------------------------------------------
STATIC FUNCTION GetVPr( cProd, cPoslovnica )

   LOCAL cRet

   IF cProd == "XXX"
      RETURN "XXXXX"
   ENDIF

   IF cProd == "" .OR. cProd == nil
      RETURN "XXXXX"
   ENDIF

   IF cPoslovnica == "" .OR. cPoslovnica == nil
      RETURN "XXXXX"
   ENDIF

   cRet := my_get_from_ini( "VINDIJA", "VPR" + cProd + "_" + cPoslovnica, "xxxx", KUMPATH )

   IF cRet == "" .OR. cRet == nil
      cRet := "XXXXX"
   ENDIF

   RETURN cRet


// -----------------------------------------------------------
// Vraca konto za odredjeni tipdokumenta
// cTipDok - tip dokumenta
// cTip - "Z" zaduzuje, "R" - razduzuje
// cPoslovnica -poslovnica vindije sarajevo, tuzla ili ...
// -----------------------------------------------------------
STATIC FUNCTION GetTdKonto( cTipDok, cTip, cPoslovnica )

   cRet := my_get_from_ini( "VINDIJA", "TD" + cTipDok + cTip + cPoslovnica, "xxxx", KUMPATH )

   // primjer:
   // TD14Z050=1310 // posl.sarajevo
   // TD14R050=1200
   // TD14R042=1201 // posl.tuzla npr...

   IF cRet == "" .OR. cRet == nil
      cRet := "XXXXX"
   ENDIF

   RETURN cRet




/* FaktExist()
 *     vraca matricu sa parovima faktura -> pojavljuje se u azur.kalk
 *   param: nRight - npr. bez zadnjih nRight brojeva
 */
STATIC FUNCTION FaktExist( nRight )

   LOCAL cBrFakt
   LOCAL cTDok

   IF nRight == nil
      nRight := 0
   ENDIF

   O_KALK_DOKS

   SELECT temp
   GO TOP

   aRet := {}
   cDok := "XXXXXX"

   DO WHILE !Eof()

      cBrFakt := AllTrim( temp->brdok )
      cBrOriginal := cBrFakt

      IF nRight > 0
         cBrFakt := PadR( cBrFakt, Len( cBrFakt ) - nRight )
      ENDIF

      cTDok := GetKTipDok( AllTrim( temp->idtipdok ), temp->idpm )

      IF cBrFakt == cDok
         SKIP
         LOOP
      ENDIF

      SELECT kalk_doks

      IF nRight > 0
         SET ORDER TO TAG "V_BRF2"
      ELSE
         SET ORDER TO TAG "V_BRF"
      ENDIF

      GO TOP

      IF nRight > 0
         SEEK cTDok + cBrFakt
      ELSE
         SEEK PadR( cBrFakt, 10 ) + cTDok
      ENDIF

      IF Found()
         AAdd( aRet, { cBrOriginal, ;
            doks->idfirma + "-" + ;
            doks->idvd + "-" + ;
            AllTrim( doks->brdok ) } )

      ENDIF

      SELECT temp
      SKIP

      cDok := cBrFakt

   ENDDO

   RETURN aRet


/* fn TTbl2Kalk(aFExist, lFSkip)
 *  brief kopira podatke iz pomocne tabele u tabelu KALK->PRIPT
 *  param aFExist matrica sa postojecim fakturama
 *  param lFSkip preskaci postojece fakture
 *  param lNegative - prvo prebaci negativne fakture
 *  param cCtrl_art - preskoci sporne artikle NC u hendeku ! na osnovu CACHE
 *         tabele
 */
STATIC FUNCTION TTbl2Kalk( aFExist, lFSkip, lNegative, cCtrl_art )

   LOCAL cBrojKalk
   LOCAL cTipDok
   LOCAL cIdKonto
   LOCAL cIdKonto2
   LOCAL cIdPJ
   LOCAL aArr_ctrl := {}
   LOCAL _id_konto, _id_konto2

   O_KALK_PRIPR
   O_KONCIJ
   O_KALK_DOKS
   O_KALK_DOKS2
   O_ROBA
   O_PRIPT

   SELECT temp

   IF lNegative == nil
      lNegative := .F.
   ENDIF

   IF lNegative == .T.
      SET ORDER TO TAG "2"
   ELSE
      SET ORDER TO TAG "1"
   ENDIF

   GO TOP

   nRbr := 0
   nUvecaj := 0
   nCnt := 0

   cPFakt := "XXXXXX"
   cPTDok := "XX"
   cPPm := "XXX"
   aPom := {}

   DO WHILE !Eof()

      cFakt := AllTrim( temp->brdok )
      cTDok := GetKTipDok( AllTrim( temp->idtipdok ), temp->idpm )
      cPm := temp->idpm
      cIdPJ := temp->idpj

      // pregledaj CACHE, da li treba preskociti ovaj artikal
      IF cCtrl_art == "D"

         nT_scan := 0

         cTmp_kto := GetKtKalk( cTDok, temp->idpm, "R", cIdPJ )

         SELECT roba
         SET ORDER TO TAG "ID_VSD"

         cTmp_dob := PadL( AllTrim( temp->idroba ), 5, "0" )

         SEEK cTmp_dob

         cTmp_roba := field->id

         O_CACHE
         SELECT cache
         SET ORDER TO TAG "1"
         GO TOP
         SEEK PadR( cTmp_kto, 7 ) + PadR( cTmp_roba, 10 )

         IF Found() .AND. gNC_ctrl > 0 .AND. ( field->odst > gNC_ctrl )
            // dodaj sporne u kontrolnu matricu

            nT_scan := AScan( aArr_ctrl, ;
               {| xVal| xVal[ 1 ] + PadR( xVal[ 2 ], 10 ) == ;
               cTDok + PadR( AllTrim( cFakt ), 10 ) } )

            IF nT_scan = 0
               AAdd( aArr_ctrl, { cTDok, ;
                  PadR( AllTrim( cFakt ), 10 ) } )
            ENDIF

         ENDIF

         SELECT temp
      ENDIF

      // ako je ukljucena opcija preskakanja postojecih faktura
      IF lFSkip
         // ako postoji ista u matrici
         IF Len( aFExist ) > 0
            nFExist := AScan( aFExist, {| aVal| AllTrim( aVal[ 1 ] ) == cFakt } )
            IF nFExist > 0
               // prekoci onda ovaj zapis i idi dalje
               SELECT temp
               SKIP
               LOOP
            ENDIF
         ENDIF
      ENDIF

      IF cTDok <> cPTDok
         nUvecaj := 0
      ENDIF

      IF cFakt <> cPFakt
         ++ nUvecaj
         cBrojKalk := GetNextKalkDoc( gFirma, cTDok, nUvecaj )
         nRbr := 0
         AAdd( aPom, { cTDok, cBrojKalk, cFakt } )
      ELSE
         // ako su diskontna zaduzenja razgranici ih putem polja prodajno mjesto
         IF cTDok == "11"
            IF cPm <> cPPm
               ++ nUvecaj
               cBrojKalk := GetNextKalkDoc( gFirma, cTDok, nUvecaj )
               nRbr := 0
               AAdd( aPom, { cTDok, cBrojKalk, cFakt } )
            ENDIF
         ENDIF
      ENDIF

      // pronadji robu
      SELECT roba
      SET ORDER TO TAG "ID_VSD"
      cTmpArt := PadL( AllTrim( temp->idroba ), 5, "0" )
      GO TOP
      SEEK cTmpArt


      // ovo dodaje datum valute itd...
      // bitno kod kontiranja kalk->fin
      // radi datuma valute
      IF cTDok == "14"

         SELECT kalk_doks2
         HSEEK gFirma + cTDok + cBrojKalk

         IF !Found()
            APPEND BLANK
            REPLACE idvd WITH "14"
            REPLACE brdok WITH cBrojKalk
            REPLACE idfirma WITH gFirma
         ENDIF

         REPLACE DatVal WITH temp->datval

      ENDIF

      // konta...
      _id_konto := GetKtKalk( cTDok, temp->idpm, "Z", cIdPJ )
      _id_konto2 := GetKtKalk( cTDok, temp->idpm, "R", cIdPJ )

      // pozicioniraj se na konto zaduzuje
      SELECT koncij
      SET ORDER TO TAG "ID"
      GO TOP
      SEEK _id_konto

      // dodaj zapis u kalk_pripr
      SELECT pript
      APPEND BLANK

      REPLACE idfirma WITH gFirma
      REPLACE rbr WITH Str( ++nRbr, 3 )

      // uzmi pravilan tip dokumenta za kalk
      REPLACE idvd WITH cTDok

      REPLACE brdok WITH cBrojKalk
      REPLACE datdok WITH temp->datdok
      REPLACE idpartner WITH temp->idpartner
      REPLACE idtarifa WITH ROBA->idtarifa
      REPLACE brfaktp WITH cFakt
      REPLACE datfaktp WITH temp->datdok

      // konta:
      // =====================
      // zaduzuje
      REPLACE idkonto WITH _id_konto
      // razduzuje
      REPLACE idkonto2 WITH _id_konto2

      REPLACE idzaduz2 WITH ""

      // spec.za tip dok 11
      IF cTDok $ "11#41"

         REPLACE tmarza2 WITH "A"
         REPLACE tprevoz WITH "A"

         IF cTDok == "11"
            // uzmi mpc iz sifrarnika roba prema podesenju u konciju...
            REPLACE mpcsapp WITH UzmiMpcSif()
         ELSE
            REPLACE mpcsapp WITH temp->cijena
         ENDIF

      ENDIF

      REPLACE kolicina WITH temp->kolicina
      REPLACE idroba WITH roba->id
      REPLACE nc WITH ROBA->nc
      REPLACE vpc WITH temp->cijena
      REPLACE rabatv WITH temp->rabatp
      REPLACE mpc WITH temp->porez

      cPFakt := cFakt
      cPTDok := cTDok
      cPPm := cPm

      ++ nCnt
      SELECT temp
      SKIP

   ENDDO

   // izvjestaj o prebacenim dokumentima....
   IF nCnt > 0

      ASort( aPom,,, {| x, y| x[ 1 ] + "-" + x[ 2 ] < y[ 1 ] + "-" + y[ 2 ] } )

      START PRINT CRET
      ? "========================================"
      ? "Generisani sljedeci dokumenti:          "
      ? "========================================"
      ? "Dokument     * Sporna NC"
      ? "----------------------------------------"

      FOR i := 1 TO Len( aPom )

         cT_tipdok := aPom[ i, 1 ]
         cT_brdok := aPom[ i, 2 ]
         cT_brfakt := aPom[ i, 3 ]
         cT_ctrl := ""

         IF cCtrl_art == "D" .AND. Len( aArr_ctrl ) > 0
            nT_scan := AScan( aArr_ctrl, ;
               {| xVal| xVal[ 1 ] + PadR( xVal[ 2 ], 10 ) == ;
               cT_tipdok + PadR( cT_brfakt, 10 ) } )

            IF nT_scan <> 0
               cT_ctrl := " !!! ERROR !!!"
            ENDIF
         ENDIF

         ? cT_tipdok + " - " + cT_brdok, cT_ctrl

      NEXT

      ?
      FF
      ENDPRINT

   ENDIF

   IF cCtrl_art == "D" .AND. Len( aArr_ctrl ) > 0

      START PRINT CRET

      ?
      ? "Ispusteni dokumenti:"
      ? "------------------------------------"

      FOR xy := 1 TO Len( aArr_ctrl )
         ? aArr_ctrl[ xy, 1 ] + "-" + aArr_ctrl[ xy, 2 ]
      NEXT

      FF
      ENDPRINT

   ENDIF

   // pobrisi ispustene dokumente
   IF cCtrl_art == "D" .AND. Len( aArr_ctrl ) > 0

      nT_scan := 0

      SELECT pript
      SET ORDER TO TAG "0"
      GO TOP

      DO WHILE !Eof()

         nT_scan := AScan( aArr_ctrl, ;
            {| xval| xval[ 1 ] + PadR( xval[ 2 ], 10 ) == ;
            field->idvd + PadR( field->brfaktp, 10 ) } )

         IF nT_scan <> 0
            DELETE
         ENDIF

         SKIP
      ENDDO

   ENDIF

   RETURN 1



/* GetKtKalk(cTipDok, cPm, cTip)
 *     Varaca konto za trazeni tip dokumenta i prodajno mjesto
 *   param: cTipDok - tip dokumenta
 *   param: cPm - prodajno mjesto
 *   param: cTip - tip "Z" zad. i "R" razd.
 *   param: cPoslovnica - poslovnica tuzla ili sarajevo
 */

STATIC FUNCTION GetKtKalk( cTipDok, cPm, cTip, cPoslovnica )

   DO CASE
   CASE cTipDok == "14"
      cRet := GetTDKonto( cTipDok, cTip, cPoslovnica )
   CASE cTipDok == "11"
      IF cTip == "R"
         cRet := GetTDKonto( cTipDok, cTip, cPoslovnica )
      ELSE
         cRet := GetVPr( cPm, cPoslovnica )
      ENDIF
   CASE cTipDok == "41"
      cRet := GetTDKonto( cTipDok, cTip, cPoslovnica )
   CASE cTipDok == "95"
      cRet := GetTDKonto( cTipDok, cTip, cPoslovnica )
   CASE cTipDok == "KO"
      cRet := GetTDKonto( cTipDok, cTip, cPoslovnica )

   ENDCASE

   RETURN cRet



/* TTbl2Partn(lEditOld)
 *     kopira podatke iz pomocne tabele u tabelu PARTN
 *   param: lEditOld - ispraviti stare zapise
 */
STATIC FUNCTION TTbl2Partn( lEditOld )

   O_PARTN
   O_SIFK
   O_SIFV

   SELECT temp
   GO TOP

   lNovi := .F.

   DO WHILE !Eof()

      // pronadji partnera
      SELECT partn
      cTmpPar := AllTrim( temp->idpartner )
      GO TOP
      SEEK cTmpPar

      // ako si nasao:
      // 1. ako je lEditOld .t. onda ispravi postojeci
      // 2. ako je lEditOld .f. onda preskoci
      IF Found()
         IF !lEditOld
            SELECT temp
            SKIP
            LOOP
         ENDIF
         lNovi := .F.
      ELSE
         lNovi := .T.
      ENDIF

      // dodaj zapis u partn
      SELECT partn

      IF lNovi
         APPEND BLANK
      ENDIF

      IF !lNovi .AND. !lEditOld
         SELECT temp
         SKIP
         LOOP
      ENDIF

      REPLACE id WITH temp->idpartner
      cNaz := temp->naz
      REPLACE naz WITH KonvZnWin( @cNaz, "8" )
      REPLACE ptt WITH temp->ptt
      cMjesto := temp->mjesto
      REPLACE mjesto WITH KonvZnWin( @cMjesto, "8" )
      cAdres := temp->adresa
      REPLACE adresa WITH KonvZnWin( @cAdres, "8" )
      REPLACE ziror WITH temp->ziror
      REPLACE telefon WITH temp->telefon
      REPLACE fax WITH temp->fax
      REPLACE idops WITH temp->idops
      // ubaci --vezane-- podatke i u sifK tabelu
      USifK( "PARTN", "ROKP", temp->idpartner, temp->rokpl )
      USifK( "PARTN", "PORB", temp->idpartner, temp->porbr )
      USifK( "PARTN", "REGB", temp->idpartner, temp->idbroj )
      USifK( "PARTN", "USTN", temp->idpartner, temp->ustn )
      USifK( "PARTN", "BRUP", temp->idpartner, temp->brupis )
      USifK( "PARTN", "BRJS", temp->idpartner, temp->brjes )

      SELECT temp
      SKIP
   ENDDO

   RETURN 1


// -----------------------------------------
// napuni iz tmp tabele u robu
// -----------------------------------------
STATIC FUNCTION TTbl2Roba()

   O_ROBA
   O_SIFK
   O_SIFV

   SELECT temp
   GO TOP

   DO WHILE !Eof()

      // pronadji robu
      SELECT roba
      SET ORDER TO TAG "SIFRADOB"

      cTmpSif := AllTrim( temp->sifradob )

      SEEK cTmpSif

      IF !Found()

         // da li treba dodavati novi zapis ...

      ELSE

         // mjenja se VPC
         IF temp->idpm == "001"
            IF field->vpc <> temp->mpc
               REPLACE field->vpc WITH temp->mpc
            ENDIF
            // mjenja se VPC2
         ELSEIF temp->idpm == "002"
            IF field->vpc2 <> temp->mpc
               REPLACE field->vpc2 WITH temp->mpc
            ENDIF
            // mjenja se MPC
         ELSEIF temp->idpm == "003"
            IF field->mpc <> temp->mpc
               REPLACE field->mpc WITH temp->mpc
            ENDIF
         ENDIF

      ENDIF

      SELECT temp
      SKIP
   ENDDO

   RETURN 1




/* GetKVars(dDatDok, cBrKalk, cTipDok, cIdKonto, cIdKonto2, cRazd)
 *     Setuj parametre prenosa TEMP->kalk_pripr(KALK)
 *   param: dDatDok - datum dokumenta
 *   param: cBrKalk - broj kalkulacije
 *   param: cTipDok - tip dokumenta
 *   param: cIdKonto - id konto zaduzuje
 *   param: cIdKonto2 - konto razduzuje
 *   param: cRazd - razdvajati dokumente po broju fakture (D ili N)
 */
STATIC FUNCTION GetKVars( dDatDok, cBrKalk, cTipDok, cIdKonto, cIdKonto2, cRazd )

   dDatDok := Date()
   cTipDok := "14"
   cIdFirma := gFirma
   cIdKonto := PadR( "1200", 7 )
   cIdKonto2 := PadR( "1310", 7 )
   cRazd := "D"
   O_KONTO
   O_KALK_DOKS
   cBrKalk := GetNextKalkDoc( cIdFirma, cTipDok )

   Box(, 15, 60 )
   @ m_x + 1, m_y + 2   SAY "Broj kalkulacije 14-" GET cBrKalk PICT "@!"
   @ m_x + 1, Col() + 2 SAY "Datum:" GET dDatDok
   @ m_x + 4, m_y + 2   SAY "Konto razduzuje:" GET cIdKonto2 PICT "@!" VALID P_Konto( @cIdKonto2 )
   @ m_x + 6, m_y + 2   SAY "Razdvajati kalkulacije po broju faktura" GET cRazd PICT "@!" VALID cRazd $ "DN"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN 0
   ENDIF

   RETURN 1




/* ObradiImport()
 *     Obrada importovanih dokumenata
 */
FUNCTION ObradiImport( nPocniOd, lAsPokreni, lStampaj )

   LOCAL cN_kalk_dok := ""
   LOCAL nUvecaj := 0

   O_KALK_PRIPR
   O_PRIPT

   IF lAsPokreni == nil
      lAsPokreni := .T.
   ENDIF
   IF lStampaj == nil
      lStampaj := .T.
   ENDIF

   IF nPocniOd == nil
      nPocniOd := 0
   ENDIF

   lAutom := .F.
   IF Pitanje(, "Automatski asistent i ažuriranje naloga (D/N)?", "D" ) == "D"
      lAutom := .T.
   ENDIF


   // iz kalk_pripr_temp prebaci u kalk_pripr jednu po jednu kalkulaciju
   SELECT pript
   SET ORDER TO TAG "1"

   IF nPocniOd == 0
      GO TOP
   ELSE
      GO nPocniOd
   ENDIF

   // uzmi parametre koje ces dokumente prenositi
   cBBTipDok := Space( 30 )
   Box(, 3, 60 )
   @ 1 + m_x, 2 + m_y SAY "Prenositi sljedece tipove dokumenata:"
   @ 3 + m_x, 2 + m_y SAY "Tip dokumenta (prazno-svi):" GET cBBTipDok PICT "@S25"
   READ
   BoxC()

   IF !Empty( cBBTipDok )
      cBBTipDok := AllTrim( cBBTipDok )
   ENDIF

   // SetKey(K_F3,{|| SaveObrada(nPTRec)})

   Box(, 10, 70 )
   @ 1 + m_x, 2 + m_y SAY "Obrada dokumenata iz pomocne tabele:" COLOR F18_COLOR_I
   @ 2 + m_x, 2 + m_y SAY "===================================="

   DO WHILE !Eof()

      nPTRec := RecNo()
      nPCRec := nPTRec
      cBrDok := field->brdok
      cFirma := field->idfirma
      cIdVd  := field->idvd

      IF !Empty( cBBTipDok ) .AND. !( cIdVd $ cBBTipDok )
         SKIP
         LOOP
      ENDIF

      // daj novi broj dokumenta kalk
      nT_area := Select()
      cN_kalk_dok := GetNextKalkDoc( cFirma, cIdVd, 1 )
      SELECT ( nT_area )

      @ 3 + m_x, 2 + m_y SAY "Prebacujem: " + cFirma + "-" + cIdVd + "-" + cBrDok

      nStCnt := 0
      DO WHILE !Eof() .AND. field->brdok = cBrDok .AND. field->idfirma = cFirma .AND. field->idvd = cIdVd

         // jedan po jedan row azuriraj u kalk_pripr
         SELECT kalk_pripr
         APPEND BLANK
         Scatter()
         SELECT pript
         Scatter()
         SELECT kalk_pripr
         _brdok := cN_kalk_dok
         Gather()

         SELECT pript
         SKIP
         ++ nStCnt

         nPTRec := RecNo()

         @ 5 + m_x, 13 + m_y SAY Space( 5 )
         @ 5 + m_x, 2 + m_y SAY "Broj stavki:" + AllTrim( Str( nStCnt ) )
      ENDDO

      // nakon sto smo prebacili dokument u kalk_pripremu obraditi ga
      IF lAutom
         // snimi zapis u params da znas dokle si dosao
         SaveObrada( nPCRec )
         ObradiDokument( cIdVd, lAsPokreni, lStampaj )
         SaveObrada( nPTRec )
         O_PRIPT
      ENDIF

      SELECT pript
      GO nPTRec

   ENDDO

   BoxC()

   // snimi i da je obrada zavrsena
   SaveObrada( 0 )

   MsgBeep( "Dokumenti obradjeni!" )

   RETURN .T.


/* fn SaveObrada()
 *  brief Snima momenat do kojeg je dosao pri obradi dokumenata
 */
STATIC FUNCTION SaveObrada( nPRec )

   LOCAL nArr

   nArr := Select()

   O_PARAMS
   SELECT params

   PRIVATE cSection := "K"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   Wpar( "is", nPRec )

   SELECT ( nArr )

   RETURN .T.



/* fn RestoreObrada()
 *  brief Pokrece ponovo obradu od momenta do kojeg je stao
 */
STATIC FUNCTION RestoreObrada()

   O_PARAMS
   SELECT params
   PRIVATE cSection := "K"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}
   PRIVATE nDosaoDo
   Rpar( "is", @nDosaoDo )

   IF nDosaoDo == nil
      MsgBeep( "Nema nista zapisano u parametrima!#Prekidam operaciju!" )
      RETURN
   ENDIF

   IF nDosaoDo == 0
      MsgBeep( "Nema zapisa o prekinutoj obradi!" )
      RETURN .F.
   ENDIF

   O_PRIPT
   SELECT pript
   SET ORDER TO TAG "1"
   GO nDosaoDo

   IF !Eof()
      MsgBeep( "Nastavljam od dokumenta#" + field->idfirma + "-" + field->idvd + "-" + field->brdok )
   ELSE
      MsgBeep( "Kraj tabele, nema nista za obradu!" )
      RETURN
   ENDIF

   IF Pitanje(, "Nastaviti sa obradom dokumenata", "D" ) == "N"
      MsgBeep( "Operacija prekinuta!" )
      RETURN
   ENDIF

   ObradiImport( nDosaoDo, nil, __stampaj )

   RETURN .T.



/* fn ObradiDokument(cIdVd)
 *  brief Obrada jednog dokumenta
 *  param cIdVd - id vrsta dokumenta
 */
STATIC FUNCTION ObradiDokument( cIdVd, lAsPokreni, lStampaj )

   // 1. pokreni asistenta
   // 2. azuriraj kalk
   // 3. azuriraj FIN

   PRIVATE lAsistRadi := .F.

   IF lAsPokreni == nil
      lAsPokreni := .T.
   ENDIF

   IF lStampaj == nil
      lStampaj := .T.
   ENDIF

   IF lAsPokreni
      // pozovi asistenta
      kalk_unos_stavki_dokumenta( .T. )
   ELSE
      o_kalk_edit()
   ENDIF

   IF lStampaj == .T.
      // odstampaj kalk
      kalk_stampa_dokumenta( nil, nil, .T. )
   ENDIF

   // azuriraj kalk
   kalk_azuriranje_dokumenta( .T. )

   o_kalk_edit()

   // ako postoje zavisni dokumenti non stop ponavljaj proceduru obrade
   PRIVATE nRslt

   DO WHILE ( ChkKkalk_pripr( cIdVd, @nRslt ) <> 0 )

      // vezni dokument u kalk_pripremi je ok
      IF nRslt == 1

         IF lAsPokreni
            // otvori kalk_pripremu
            kalk_unos_stavki_dokumenta( .T. )
         ELSE
            o_kalk_edit()
         ENDIF

         IF lStampaj == .T.
            kalk_stampa_dokumenta( nil, nil, .T. )
         ENDIF

         kalk_azuriranje_dokumenta( .T. )
         o_kalk_edit()

      ENDIF

      // vezni dokument ne pripada azuriranom dokumentu
      // sta sa njim

      IF nRslt >= 2

         MsgBeep( "Postoji dokument u kalk_pripremi koji je sumljiv!#Radi se o veznom dokumentu ili nekoj drugoj gresci...#Obradite ovaj dokument i autoimport ce nastaviti dalje sa radom !" )
         kalk_unos_stavki_dokumenta()
         o_kalk_edit()

      ENDIF
   ENDDO

   RETURN


/* ChkKkalk_pripr(cIdVd, nRes)
 *     Provjeri da li je kalk_priprema prazna
 *   param: cIdVd - id vrsta dokumenta
 */
STATIC FUNCTION ChkKkalk_pripr( cIdVd, nRes )

   // provjeri da li je kalk_priprema prazna, ako je prazna vrati 0
   SELECT kalk_pripr
   GO TOP

   IF RecCount() == 0
      // idi dalje...
      nRes := 0
      RETURN 0
   ENDIF

   // provjeri koji je dokument u kalk_pripremi u odnosu na cIdVd

   RETURN nRes := ChkTipDok( cIdVd )

   RETURN 0



/* ChkTipDok(cIdVd)
 *     Provjeri kalk_pripremu za tip dokumenta
 *   param: cIdVd - vrsta dokumenta
 */
STATIC FUNCTION ChkTipDok( cIdVd )

   nNrRec := RecCount()
   nTmp := 0
   cPrviDok := field->idvd
   nPrviDok := Val( cPrviDok )

   DO WHILE !Eof()
      nTmp += Val( field->idvd )
      SKIP
   ENDDO

   nUzorak := nPrviDok * nNrRec

   IF nUzorak <> nNrRec * nTmp
      // ako u kalk_pripremi ima vise dokumenata vrati 2
      RETURN 3
   ENDIF

   DO CASE
   CASE cIdVd == "14"
      RETURN ChkTD14( cPrviDok )
   CASE cIdVd == "41"
      RETURN ChkTD41( cPrviDok )
   CASE cIdVd == "11"
      RETURN ChkTD11( cPrviDok )
   CASE cIdVD == "95"
      RETURN ChkTD95( cPrviDok )
   ENDCASE

   RETURN 0



/* ChkTD14(cVezniDok)
 *     Provjeri vezne dokumente za tip dokumenta 14
 *   param: cVezniDok - dokument iz kalk_pripreme
 *  \result vraca 1 ako je sve ok, ili 2 ako vezni dokument ne odgovara
 */
STATIC FUNCTION ChkTD14( cVezniDok )

   IF cVezniDok $ "18#19#95#16#11"
      RETURN 1
   ENDIF

   RETURN 2


/* ChkTD41()
 *     Provjeri vezne dokumente za tip dokumenta 41
 */
STATIC FUNCTION ChkTD41( cVezniDok )

   IF cVezniDok $ "18#19#95#16#11"
      RETURN 1
   ENDIF

   RETURN 2


/* ChkTD11()
 *     Provjeri vezne dokumente za tip dokumenta 11
 */
STATIC FUNCTION ChkTD11( cVezniDok )

   IF cVezniDok $ "18#19#95#16#11"
      RETURN 1
   ENDIF

   RETURN 2


/* ChkTD95()
 *     Provjeri vezne dokumente za tip dokumenta 95
 */
STATIC FUNCTION ChkTD95( cVezniDok )

   IF cVezniDok $ "18#19#95#16#11"
      RETURN 1
   ENDIF

   RETURN 2



/* FillDobSifra()
 *     Popunjavanje polja sifradob prema kljucu
 */
STATIC FUNCTION FillDobSifra()

   IF !spec_funkcije_sifra( "FILLDOB" )
      MsgBeep( "Nemate ovlastenja za ovu opciju!!!" )
      RETURN .F.
   ENDIF

   O_ROBA

   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   cSifra := ""
   nCnt := 0
   aRpt := {}
   aSDob := {}

   Box(, 5, 60 )
   @ 1 + m_x, 2 + m_y SAY "Vrsim upis sifre dobavaljaca robe:"
   @ 2 + m_x, 2 + m_y SAY "==================================="

   DO WHILE !Eof()
      // ako je prazan zapis preskoci
      IF Empty( field->id )
         SKIP
         LOOP
      ENDIF

      cSStr := SubStr( field->id, 1, 1 )

      // provjeri karakteristicnost robe
      IF cSStr == "K" .OR. cSStr == "P"
         // roba KOKA LEN 5 sifradob
         cSifra := SubStr( RTrim( field->id ), -5 )
      ELSEIF cSStr == "V"
         // ostala roba
         cSifra := SubStr( RTrim( field->id ), -4 )
      ELSE
         SKIP
         LOOP
      ENDIF

      // upisi zapis
      Scatter()
      _sifradob := cSifra
      my_rlock()
      Gather()
      my_unlock()

      // potrazi sifru u matrici
      nRes := AScan( aSDob, {| aVal| aVal[ 1 ] == cSifra } )
      IF nRes == 0
         AAdd( aSDob, { cSifra, field->id } )
      ELSE
         AAdd( aRpt, { cSifra, aSDob[ nRes, 2 ] } )
         AAdd( aRpt, { cSifra, field->id } )
      ENDIF

      ++ nCnt

      @ 3 + m_x, 2 + m_y SAY "FMK sifra " + AllTrim( field->id ) + " => sifra dob. " + cSifra
      @ 5 + m_x, 2 + m_y SAY " => ukupno " + AllTrim( Str( nCnt ) )

      SKIP

   ENDDO

   BoxC()

   // ako je report matrica > 0 dakle postoje dupli zapisi
   IF Len( aRpt ) > 0
      START PRINT CRET
      ? "KONTROLA DULIH SIFARA VINDIJA_FAKT:"
      ? "==================================="
      ? "Sifra Vindija_FAKT -> Sifra FMK  "
      ?

      FOR i := 1 TO Len( aRpt )
         ? aRpt[ i, 1 ] + " -> " + aRpt[ i, 2 ]
      NEXT

      ?
      ? "Provjerite navedene sifre..."
      ?

      FF
      ENDPRINT
   ENDIF

   RETURN .T.
