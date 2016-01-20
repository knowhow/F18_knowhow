/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"
#include "achoice.ch"
#include "fileio.ch"


/*! \fn UBrojDok(nBroj,nNumDio,cOstatak)
 * \brief Pretvara Broj podbroj u string format "Broj dokumenta"
 * \code
 * UBrojDok ( 123,  5, "/99" )   =>   00123/99
 * \encode
 */

FUNCTION UBrojDok( nBroj, nNumdio, cOstatak )

   RETURN PadL( AllTrim( Str( nBroj ) ), nNumDio, "0" ) + cOstatak


/*! \fn Calc()
 *  \brief Kalkulator
 */
FUNCTION Calc()

   LOCAL GetList := {}
   PRIVATE cIzraz := Space( 40 )

   bKeyOld1 := SetKey( K_ALT_K, {|| Konv() } )
   bKeyOld2 := SetKey( K_ALT_V, {|| DefKonv() } )

   Box(, 3, 60 )
	
   SET CURSOR ON
	
   DO WHILE .T.
  		
      @ m_x, m_y + 42 SAY "<a-K> kursiranje"
      @ m_x + 4, m_y + 30 SAY "<a-V> programiranje kursiranja"
      @ m_x + 1, m_y + 2 SAY "KALKULATOR: unesite izraz, npr: '(1+33)*1.2' :"
      @ m_x + 2, m_y + 2 GET cIzraz
  		
      READ
  		
      // ako je ukucan "," zamjeni sa tackom "."
      cIzraz := StrTran( cIzraz, ",", "." )
		
      @ m_x + 3, m_y + 2 SAY Space( 20 )
      IF Type( cIzraz ) <> "N"
    			
         IF Upper( Left( cIzraz, 1 ) ) <> "K"
            @ m_x + 3, m_y + 2 SAY "ERR"
         ELSE
            @ m_x + 3, m_y + 2 SAY kbroj( SubStr( cizraz, 2 ) )
         ENDIF
			
         // cIzraz:=space(40)
      ELSE
         @ m_x + 3, m_y + 2 SAY &cIzraz PICT "99999999.9999"
         cIzraz := PadR( AllTrim( Str( &cizraz, 18, 5 ) ), 40 )
      ENDIF

      IF LastKey() == 27
         EXIT
      ENDIF
  		
      Inkey()
  		
   ENDDO
   BoxC()

   IF Type( cIzraz ) <> "N"
      IF Upper( Left( cIzraz, 1 ) ) <> "K"
         SetKey( K_ALT_K, bKeyOld1 ); SetKey( K_ALT_V, bKeyOld2 )
         RETURN 0
      ELSE
         PRIVATE cVar := ReadVar()
         Inkey()
         // inkey(0)
         IF Type( cVar ) == "C" .OR. ( Type( "fUmemu" ) == "L" .AND. fUMemu )
            KEYBOARD KBroj( SubStr( cIzraz, 2 ) )
         ENDIF
         SetKey( K_ALT_K, bKeyOld1 )
         SetKey( K_ALT_V, bKeyOld2 )
         RETURN 0
      ENDIF
   ELSE
      PRIVATE cVar := ReadVar()
      IF Type( cVar ) == "N"
         &cVar := &cIzraz
      ENDIF
      SetKey( K_ALT_K, bKeyOld1 )
      SetKey( K_ALT_V, bKeyOld2 )
      return &cizraz
   ENDIF

   RETURN



// -----------------------------------
// auto valute convert
// -----------------------------------
FUNCTION a_val_convert()

   PRIVATE cVar := ReadVar()
   PRIVATE nIzraz := &cVar
   PRIVATE cIzraz

   // samo ako je varijabla numericka....
   IF Type( cVar ) == "N"
	
      // cIzraz := ALLTRIM( STR( nIzraz ) )
	
      nIzraz := Round( nIzraz * omjerval( ValDomaca(), ValPomocna(), Date() ), 5 )
      // konvertuj ali bez ENTER-a
      // konv( .f. )
	
      // nIzraz := VAL( cIzraz )
	
      &cVar := nIzraz
	
   ENDIF
   	
   RETURN


// ----------------------------------------
// ----------------------------------------
FUNCTION kbroj( cSifra )

   LOCAL i, cPom, nPom, nKontrola, nPom3

   cSifra := AllTrim( cSifra )
   cSifra := StrTran( cSifra, "/", "-" )
   cPom := ""
   FOR i := 1 TO Len( cSifra )
      IF !IsDigit( SubStr( cSifra, i, 1 ) )
         ++i
         DO WHILE .T.
            IF Val( SubStr( cSifra, i, 1 ) ) = 0 .AND. i < Len( cSifra )
               i++
            ELSE
               cPom += SubStr( cSifra, i, 1 )
               EXIT // izadji iz izbijanja
            ENDIF
         ENDDO
      ELSE
         cPom += SubStr( cSifra, i, 1 )
      ENDIF
   NEXT
   nPom := Val( cPom )
   nP3 := 0
   nKontrola := 0
   FOR i := 1 TO 9
      nPom3 := nPom % 10 // cifra pod rbr i
      nPom := Int( nPom / 10 )
      nKontrola += nPom3 * ( i + 1 )
   NEXT
   nKontrola := nKontrola % 11
   nKontrola := 11 -nKontrola
   IF Round( nkontrola, 2 ) >= 10
      nKontrola := 0
   ENDIF

   RETURN cSifra + AllTrim( Str( nKontrola, 0 ) )



FUNCTION round2( nizraz, niznos )

   //
   // pretpostavlja definisanu globalnu varijablu g50F
   // za g50F="5" vrçi se zaokru§enje na 0.5
   // =" " odraÐuje obini round()

   LOCAL npom, npom2, nznak
   IF g50f = "5"

      npom := Abs( nizraz - Int( nizraz ) )
      nznak = nizraz - Int( nizraz )
      IF nznak > 0
         nznak := 1
      ELSE
         nznak := -1
      ENDIF
      npom2 := Int( nizraz )
      IF npom <= 0.25
         nizraz := npom2
      ELSEIF npom > 0.25 .AND. npom <= 0.75
         nizraz := npom2 + 0.5 * nznak
      ELSE
         nIzraz := npom2 + 1 * nznak
      ENDIF
      RETURN nizraz
   ELSE
      RETURN Round( nizraz, niznos )
   ENDIF

   RETURN



// --------------------------------------
// kovertuj valutu
// --------------------------------------
STATIC FUNCTION Konv( lEnter )

   LOCAL nDuz := Len( cIzraz )
   LOCAL lOtv := .T.
   LOCAL nK1 := 0
   LOCAL nK2 := 0

   IF lEnter == nil
      lEnter := .T.
   ENDIF

   IF !File( ToUnix( SIFPATH + "VALUTE.DBF" ) )
      RETURN
   ENDIF

   PushWA()

   SELECT VALUTE
   PushWA()
   SET ORDER TO TAG "ID"

   GO TOP
   dbSeek( gValIz, .F. )
   nK1 := VALUTE->&( "kurs" + gKurs )
   GO TOP
   dbSeek( gValU, .F. )
   nK2 := VALUTE->&( "kurs" + gKurs )

   IF nK1 == 0 .OR. Type( cIzraz ) <> "N"
      IF !lOtv
         USE
      ELSE
         PopWA()
      ENDIF
      PopWA()
      RETURN
   ENDIF
   cIzraz := &( cIzraz ) * nK2 / nK1
   cIzraz := PadR( cIzraz, nDuz )
   IF !lOtv
      USE
   ELSE
      PopWA()
   ENDIF
   PopWA()
   IF lEnter == .T.
      KEYBOARD Chr( K_ENTER )
   ENDIF

   RETURN



STATIC FUNCTION DefKonv()

   LOCAL GetList := {}, bKeyOld := SetKey( K_ALT_V, NIL )

   PushWA()
   SELECT 99
   IF Used()
      fUsed := .T.
   ELSE
      fUsed := .F.
      O_PARAMS
   ENDIF

   PRIVATE cSection := "1", cHistory := " "; aHistory := {}
   RPAR( "vi", @gValIz )
   RPAR( "vu", @gValU )
   RPAR( "vk", @gKurs )

   Box(, 5, 65 )
   SET CURSOR ON
   @ m_x, m_y + 19 SAY "PROGRAMIRANJE KURSIRANJA"
   @ m_x + 2, m_y + 2 SAY "Oznaka valute iz koje se vrsi konverzija:" GET gValIz
   @ m_x + 3, m_y + 2 SAY "Oznaka valute u koju se vrsi konverzija :" GET gValU
   @ m_x + 4, m_y + 2 SAY "Kurs po kome se vrsi konverzija (1/2/3) :" GET gKurs VALID gKurs $ "123" PICT "9"
   READ
   IF LastKey() <> K_ESC
      WPAR( "vi", gValIz )
      WPAR( "vu", gValU )
      WPAR( "vk", gKurs )
   ENDIF
   BoxC()

   SELECT params
   IF !fUsed
      SELECT params; USE
   ENDIF
   PopWA()
   SetKey( K_ALT_V, bKeyOld )

   RETURN



FUNCTION Adresar()

   PushWa()

   SELECT ( F_ADRES )
   IF !Used()
      O_ADRES
   ENDIF

   SELECT( F_SIFK )
   IF !Used()
      O_SIFK
   ENDIF

   SELECT( F_SIFV )
   IF !Used()
      use_sql_sifv( PadR( "ADRES", 8 ) )
   ENDIF

   P_Adres()

   USE

   PopWa()

   RETURN NIL


// --------------------------------
// --------------------------------
FUNCTION P_Adres( cId, dx, dy )

   LOCAL fkontakt := .F.
   PRIVATE ImeKol := {}
   PRIVATE Kol := {}

   IF FieldPos( "Kontakt" ) <> 0
      fKontakt := .T.
   ENDIF

   AAdd( ImeKol, { "Naziv firme", {|| id     }, "id" } )
   AAdd( ImeKol, { "Telefon ", {|| naz }, "naz" } )
   AAdd( ImeKol, { "Telefon 2", {|| tel2 }, "tel2" } )
   AAdd( ImeKol, { "FAX      ", {|| tel3 }, "tel3" } )
   IF fkontakt
      AAdd( ImeKol, { "RJ ", {|| rj  }, "rj" } )
   ENDIF
   AAdd( ImeKol, { "Adresa", {|| adresa  }, "adresa"   } )
   AAdd( ImeKol, { "Mjesto", {|| mjesto  }, "mjesto"   } )
   IF fkontakt
      AAdd( ImeKol, { "PTT", {|| PTT }, "PTT"  } )
      AAdd( ImeKol, { "Drzava", {|| drzava     }, "drzava"  } )
   ENDIF
   AAdd( ImeKol, { "Dev.ziro-r.", {|| ziror   }, "ziror"   } )
   AAdd( ImeKol, { "Din.ziro-r.", {|| zirod  },  "zirod"   } )

   IF fkontakt
      AAdd( ImeKol, { "Kontakt", {|| kontakt     }, "kontakt"  } )
      AAdd( ImeKol, { "K7", {|| k7 }, "k7"  } )
      AAdd( ImeKol, { "K8", {|| k8 }, "k8"  } )
      AAdd( ImeKol, { "K9", {|| k9 }, "k9"  } )
   ENDIF

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   PushWa()

   sif_sifk_fill_kol( PadR( "ADRES", 8 ), @ImeKol, @Kol )

   PopWa()

   RETURN PostojiSifra( F_ADRES, 1, MAXROWS() -15, MAXCOLS() -3, "Adresar:", @cId, dx, dy, {| Ch| AdresBlok( Ch ) } )



// ----------------------------------------------------
// ----------------------------------------------------
FUNCTION Pkoverte()

   IF Pitanje(, "Stampati koverte ?", "N" ) == "N"
      RETURN DE_CONT
   ENDIF

   aDBF := {}
   AAdd( aDBf, { 'ID', 'C',  50,   0 } )
   AAdd( aDBf, { 'RJ', 'C',  30,   0 } )
   AAdd( aDBf, { 'KONTAKT', 'C',  30,   0 } )
   AAdd( aDBf, { 'NAZ', 'C',  15,   0 } )
   AAdd( aDBf, { 'TEL2', 'C',  15,   0 } )
   AAdd( aDBf, { 'TEL3', 'C',  15,   0 } )
   AAdd( aDBf, { 'MJESTO', 'C',  15,   0 } )
   AAdd( aDBf, { 'PTT', 'C',  6,   0 } )
   AAdd( aDBf, { 'ADRESA', 'C',  50,   0 } )
   AAdd( aDBf, { 'DRZAVA', 'C',  22,   0 } )
   AAdd( aDBf, { 'ziror', 'C',  30,   0 } )
   AAdd( aDBf, { 'zirod', 'C',  30,   0 } )
   AAdd( aDBf, { 'K7', 'C',  1,   0 } )
   AAdd( aDBf, { 'K8', 'C',  2,   0 } )
   AAdd( aDBf, { 'K9', 'C',  3,   0 } )
   DBCREATE2( "koverte", aDBf )

   usex ( "koverte", NIL, .T. )
   my_dbf_zap()

   INDEX ON  "id+naz"  TAG "ID"

   SELECT adres
   GO TOP
   MsgO( "Priprema koverte.dbf" )

   cIniName := my_home() + 'ProIzvj.ini'

   cWinKonv := IzFmkIni( "DelphiRb", "Konverzija", "3" )
   DO WHILE !Eof()
      Scatter()
      SELECT koverte
      APPEND BLANK
      KonvZnWin( @_Id, cWinKonv )
      KonvZnWin( @_Adresa, cWinKonv )
      KonvZnWin( @_Naz, cWinKonv )
      KonvZnWin( @_RJ, cWinKonv )
      KonvZnWin( @_KONTAKT, cWinKonv )
      KonvZnWin( @_Mjesto, cWinKonv )
      Gather()
      SELECT adres
      SKIP
   ENDDO

   MsgC()

   SELECT koverte
   USE

   f18_rtm_print( "adres", "koverte", "id" )

   RETURN DE_CONT


FUNCTION AdresBlok( Ch )

   IF Ch == K_F8  // koverte
      PKoverte()
   ENDIF

   RETURN DE_CONT


PROCEDURE DiskSezona ()

   LOCAL nSlobodno, pDirPriv, pDirRad, pDirSif, cSezBris

   cSezBris := Space ( 4 )
   nSlobodno := DiskSpace () / ( 1024 * 1024 )

   // nSlobodno se daje u MB
   MsgBeep ( "Postoji jos " + Str ( nSlobodno, 10, 2 ) + ;
      " MB slobodnog prostora na disku!" + ;
      iif ( nSlobodno < 20, "#Preporucuje se brisanje najstarije sezone#" + ;
      "kako bi se oslobodio prostor i ubrzao rad!";
      , "" ) )
   IF Pitanje ( "bss", "Želite li izbrisati staru sezonu?", "N" ) == "D"
      Box(, 2, 60 )
      @ m_x + 1, m_y + 1 SAY "Sezona koju zelite obrisati" GET cSezBris ;
         VALID NijeRTS ( cSezBris )
      READ
      BoxC()
      IF LastKey() == K_ESC
         RETURN
      ENDIF
      pDirPriv := cDirPriv
      pDirRad  := cDirRad
      pDirSif  := cDirSif
      IF Empty ( gSezonDir )
         pDirPriv := pDirPriv + "\" + AllTrim ( cSezBris )
         pDirRad  := pDirRad + "\" + AllTrim ( cSezBris )
         pDirSif  := pDirSif + "\" + AllTrim ( cSezBris )
      ELSE
         pDirPriv := StrTran ( pDirPriv, gSezonDir, "\" + AllTrim ( cSezBris ) )
         pDirRad  := StrTran ( pDirRad, gSezonDir, "\" + AllTrim ( cSezBris ) )
         pDirSif  := StrTran ( pDirSif, gSezonDir, "\" + AllTrim ( cSezBris ) )
      ENDIF
      BrisiIzDir ( pDirPriv )
      BrisiIzDir ( pDirRad )
      BrisiIzDir ( pDirSif )
      //
      // vidjeti za removing directories
      //
   ENDIF

   RETURN

FUNCTION NijeRTS ( cSez )

   IF gSezona == cSez
      MsgBeep ( "Ne mozete obrisati tekucu sezonu!!!" )
      RETURN .F.
   ENDIF
   IF gRadnoPodr == cSez
      MsgBeep ( "Ne mozete obrisati sezonu u kojoj radite!!!" )
      RETURN .F.
   ENDIF

   RETURN .T.


FUNCTION BrisiIzDir ( cDir )

   LOCAL aFiles, nCnt, nRes

   Beep ( 4 )
   Box (, 1, 60 )
   @ m_x, m_y + 1 SAY "Direktorij " + AllTrim ( cDir ) COLOR Invert
   aFiles := Directory ( cDir + SLASH + "*.*" )
   FOR nCnt := 1 TO Len ( aFiles )
      nRes := FErase ( cDir + SLASH + aFiles[nCnt ][ F_NAME ] )
      IF nRes == 0
         @ m_x + 1, m_y + 1 SAY PadC ( "Obrisana datoteka " + aFiles[nCnt ][ F_NAME ], 60 )
      ELSE
         @ m_x + 1, m_y + 1 SAY PadC ( "NIJE OBRISANA " + aFiles[nCnt ][ F_NAME ], 60 )
      ENDIF
   NEXT
   BoxC()

   RETURN
