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

THREAD STATIC F_POS_RN := "POS_RN" // pos komande


// --------------------------------------------------------
// fiskalni racun pos (FLINK)
// cFPath - putanja do fajla
// cFName - naziv fajla
// aData - podaci racuna
// lStorno - da li se stampa storno ili ne (.T. ili .F. )
// --------------------------------------------------------
FUNCTION fc_pos_rn( cFPath, cFName, aData, lStorno, cError )

   LOCAL cSep := ";"
   LOCAL aPosData := {}
   LOCAL aStruct := {}
   LOCAL nErr := 0

   IF lStorno == nil
      lStorno := .F.
   ENDIF

   IF cError == nil
      cError := "N"
   ENDIF


   fl_d_tmp() // pobrisi temp fajlove

   // naziv fajla
   cFName := f_filepos( aData[ 1, 1 ] )

   // izbrisi fajl greske odmah na pocetku ako postoji
   _f_err_delete( cFPath, cFName )

   // uzmi strukturu tabele za pos racun
   aStruct := _g_f_struct( F_POS_RN )

   // iscitaj pos matricu
   aPosData := __pos_rn( aData, lStorno )

   cTmp_date := DToC( Date() )
   cTmp_time := Time()

   _a_to_file( cFPath, cFName, aStruct, aPosData )

   IF cError == "D"
      MsgO( "...provjeravam greske..." )
      Sleep( 3 )
      MsgC()
      // provjeri da li je racun odstampan
      nErr := fc_pos_err( cFPath, cFName, cTmp_date, cTmp_time )
   ENDIF

   RETURN nErr

// ---------------------------------------------------
// citanje log fajla
// ---------------------------------------------------
FUNCTION fc_pos_err( cFPath, cFName, cDate, cTime )

   LOCAL nErr := 0
   LOCAL aDir := {}
   LOCAL cTmp
   LOCAL cE_date

   // error file time-hour, min, sec.
   LOCAL cE_th
   LOCAL cE_tm
   LOCAL cE_ts
   // origin file time-hour, min, sec.
   LOCAL cF_th := SubStr( cTime, 1, 2 )
   LOCAL cF_tm := SubStr( cTime, 4, 2 )
   LOCAL cF_ts := SubStr( cTime, 7, 2 )
   LOCAL i

   IF !Empty( AllTrim( gFc_path2 ) )
      cTmp := cFPath + AllTrim( gFc_path2 ) + SLASH + cFName
   ELSE
      cTmp := cFPath + "printe~1\" + cFName
   ENDIF

   aDir := Directory( cTmp )

   // nema fajla...
   IF Len( aDir ) = 0
      RETURN nErr
   ENDIF

   // napravi pattern za pretragu unutar matrice
   // <filename> + <date> + <file hour> + <file minute>
   // primjer:
   //
   // 21100000.inp + 10.10.10 + 12 + 15 = "21100000.inp10.10.101215"

   cF_patt := AllTrim( Upper( cFName ) ) + cDate + cF_th + cF_tm

   // ima fajla...
   // provjeri jos samo datum i vrijeme

   FOR i := 1 TO Len( aDir )

      cE_name := Upper( AllTrim( aDir[ i, 1 ] ) )
      // datum fajla
      cE_date := DToC( aDir[ i, 3 ] )
      // vrijeme fajla
      cE_th := SubStr( AllTrim( aDir[ i, 4 ] ), 1, 2 )
      cE_tm := SubStr( AllTrim( aDir[ i, 4 ] ), 4, 2 )
      cE_ts := SubStr( AllTrim( aDir[ i, 4 ] ), 7, 2 )

      // patern pretrage
      cE_patt := AllTrim( cE_name ) + cE_date + cE_th + cE_tm

      IF cE_patt == cF_patt
         // imamo error fajl !!!
         nErr := 1
         EXIT
      ENDIF
   NEXT

   RETURN nErr

// --------------------------------------------------------
// brisi fajl greske ako postoji prije kucanja racuna
// --------------------------------------------------------
STATIC FUNCTION _f_err_delete( cFPath, cFName )

   LOCAL cTmp := cFPath + "printe~1\" + cFName

   FErase( cTmp )

   RETURN


// ----------------------------------------
// fajl za pos fiskalni stampac
// ----------------------------------------
STATIC FUNCTION f_filepos( cBrRn )

   LOCAL cRet := PadL( AllTrim( cBrRn ), 8, "0" ) + ".inp"

   RETURN cRet



// ----------------------------------------------
// brise fajlove iz ulaznog direktorija
// ----------------------------------------------
STATIC FUNCTION fl_d_tmp()

   LOCAL cTmp

   MsgO( "brisem tmp fajlove..." )

   cF_path := AllTrim( gFc_path )
   cTmp := "*.inp"

   AEval( Directory( cF_path + cTmp ), {| aFile| FErase( cF_path + ;
      AllTrim( aFile[ 1 ] ) ) } )

   Sleep( 1 )

   MsgC()

   RETURN




// -----------------------------------------------------
// fiskalno upisivanje robe
// cFPath - putanja do fajla
// aData - podaci racuna
// -----------------------------------------------------
FUNCTION fc_pos_art( cFPath, cFName, aData )

   LOCAL cSep := ";"
   LOCAL aPosData := {}
   LOCAL aStruct := {}

   // uzmi strukturu tabele za pos racun
   aStruct := _g_f_struct( F_POS_RN )

   // iscitaj pos matricu
   aPosData := __pos_art( aData )

   _a_to_file( cFPath, cFName, aStruct, aPosData )

   RETURN


// ------------------------------------------------------
// vraca popunjenu matricu za upis artikla u memoriju
// ------------------------------------------------------
STATIC FUNCTION __pos_art( aData )

   LOCAL aArr := {}
   LOCAL cTmp := ""
   LOCAL cLogic
   LOCAL cLogSep := ","
   LOCAL cSep := ";"
   LOCAL i

   // ocekivana struktura
   // aData = { idroba, nazroba, cijena, kolicina, porstopa, plu }

   // nemam pojma sta ce ovdje biti logic ?
   cLogic := "1"

   FOR i := 1 TO Len( aData )

      cTmp := "U"
      cTmp += cLogSep
      cTmp += cLogic
      cTmp += cLogSep
      cTmp += Replicate( "_", 6 )
      cTmp += cLogSep
      cTmp += Replicate( "_", 1 )
      cTmp += cLogSep
      cTmp += Replicate( "_", 2 )
      cTmp += cSep
      // naziv artikla
      cTmp += AllTrim( aData[ i, 2 ] )
      cTmp += cSep
      // cjena 0-99999.99
      cTmp += AllTrim( Str( aData[ i, 3 ], 12, 2 ) )
      cTmp += cSep
      // kolicina 0-99999.99
      cTmp += AllTrim( Str( aData[ i, 4 ], 12, 2 ) )
      cTmp += cSep
      // stand od 1-9
      cTmp += "1"
      cTmp += cSep
      // grupa artikla 1-99
      cTmp += "1"
      cTmp += cSep
      // poreska grupa artikala 1 - 4
      cTmp += "1"
      cTmp += cSep
      // 0 ???
      cTmp += "0"
      cTmp += cSep
      // kod PLU
      cTmp += AllTrim( aData[ i, 1 ] )
      cTmp += cSep

      AAdd( aArr, { cTmp } )

   NEXT

   RETURN aArr


// ----------------------------------------
// vraca popunjenu matricu za ispis racuna
// ----------------------------------------
STATIC FUNCTION __pos_rn( aData, lStorno )

   LOCAL aArr := {}
   LOCAL cTmp := ""
   LOCAL cLogic
   LOCAL cLogSep := ","
   LOCAL cSep := ";"
   LOCAL i
   LOCAL cRek_rn := ""
   LOCAL cRnBroj
   LOCAL nTotal := 0

   // ocekuje se matrica formata
   // aData { brrn, rbr, idroba, nazroba, cijena, kolicina, porstopa, rek_rn, plu, cVrPlacanja, nTotal }

   // !!! nije broj racuna !!!!
   // prakticno broj racuna
   // cLogic := ALLTRIM( aData[1, 1] )

   // broj racuna
   cRnBroj := AllTrim( aData[ 1, 1 ] )

   // logic je uvijek "1"
   cLogic := "1"

   IF lStorno == .T.

      cRek_rn := AllTrim( aData[ 1, 8 ] )

      cTmp := "K"
      cTmp += cLogSep
      cTmp += cLogic
      cTmp += cLogSep
      cTmp += Replicate( "_", 6 )
      cTmp += cLogSep
      cTmp += Replicate( "_", 1 )
      cTmp += cLogSep
      cTmp += Replicate( "_", 2 )
      cTmp += cSep
      cTmp += cRek_rn

      AAdd( aArr, { cTmp } )

   ENDIF

   FOR i := 1 TO Len( aData )

      cT_porst := aData[ i, 7 ]

      cTmp := "S"
      cTmp += cLogSep
      cTmp += cLogic
      cTmp += cLogSep
      cTmp += Replicate( "_", 6 )
      cTmp += cLogSep
      cTmp += Replicate( "_", 1 )
      cTmp += cLogSep
      cTmp += Replicate( "_", 2 )
      cTmp += cSep
      // naziv artikla
      cTmp += AllTrim( aData[ i, 4 ] )
      cTmp += cSep
      // cjena 0-99999.99
      cTmp += AllTrim( Str( aData[ i, 5 ], 12, 2 ) )
      cTmp += cSep
      // kolicina 0-99999.99
      cTmp += AllTrim( Str( aData[ i, 6 ], 12, 2 ) )
      cTmp += cSep
      // stand od 1-9
      cTmp += PadR( "1", 1 )
      cTmp += cSep
      // grupa artikla 1-99
      cTmp += "1"
      cTmp += cSep
      // poreska grupa artikala 1 - 4
      IF cT_porst == "E"
         cTmp += "2"
      ELSE
         cTmp += "1"
      ENDIF
      cTmp += cSep
      // -0 ???
      cTmp += "-0"
      cTmp += cSep
      // kod PLU
      cTmp += AllTrim( aData[ i, 3 ] )
      cTmp += cSep

      AAdd( aArr, { cTmp } )

   NEXT

   // podnozje
   cTmp := "Q"
   cTmp += cLogSep
   cTmp += cLogic
   cTmp += cLogSep
   cTmp += Replicate( "_", 6 )
   cTmp += cLogSep
   cTmp += Replicate( "_", 1 )
   cTmp += cLogSep
   cTmp += Replicate( "_", 2 )
   cTmp += cSep
   cTmp += "1"
   cTmp += cSep
   cTmp += "pos rn: " + cRnBroj

   AAdd( aArr, { cTmp } )

   // vrsta placanja
   IF aData[ 1, 10 ] <> "0"

      nTotal := aData[ 1, 11 ]

      // zatvaranje racuna
      cTmp := "T"
      cTmp += cLogSep
      cTmp += cLogic
      cTmp += cLogSep
      cTmp += Replicate( "_", 6 )
      cTmp += cLogSep
      cTmp += Replicate( "_", 1 )
      cTmp += cLogSep
      cTmp += Replicate( "_", 2 )
      cTmp += cSep
      cTmp += aData[ 1, 10 ]
      cTmp += cSep
      cTmp += AllTrim( Str( aData[ 1, 11 ], 12, 2 ) )
      cTmp += cSep

      AAdd( aArr, { cTmp } )

   ENDIF

   // zatvaranje racuna
   cTmp := "T"
   cTmp += cLogSep
   cTmp += cLogic
   cTmp += cLogSep
   cTmp += Replicate( "_", 6 )
   cTmp += cLogSep
   cTmp += Replicate( "_", 1 )
   cTmp += cLogSep
   cTmp += Replicate( "_", 2 )
   cTmp += cSep

   AAdd( aArr, { cTmp } )

   RETURN aArr



// ----------------------------------------------------
// flink: unos pologa u printer
// ----------------------------------------------------
FUNCTION fl_polog( cFPath, cFName, nPolog )

   LOCAL cSep := ";"
   LOCAL aPolog := {}
   LOCAL aStruct := {}

   IF nPolog == nil
      nPolog := 0
   ENDIF

   // ako je polog 0, pozovi formu za unos
   IF nPolog = 0

      Box(, 1, 60 )
      @ m_x + 1, m_y + 2 SAY "Zaduzujem kasu za:" GET nPolog ;
         PICT "999999.99"
      READ
      BoxC()

      IF nPolog = 0
         MsgBeep( "Polog mora biti <> 0 !" )
         RETURN
      ENDIF

      IF LastKey() == K_ESC
         RETURN
      ENDIF

   ENDIF

   cFName := f_filepos( "0" )

   // pobrisi ulazni direktorij
   fl_d_tmp()

   // izbrisi fajl greske odmah na pocetku ako postoji
   _f_err_delete( cFPath, cFName )

   // uzmi strukturu tabele za pos racun
   aStruct := _g_f_struct( F_POS_RN )

   // iscitaj pos matricu
   aPolog := _fl_polog( nPolog )

   _a_to_file( cFPath, cFName, aStruct, aPolog )

   RETURN



// ----------------------------------------------------
// flink: reset racuna
// ----------------------------------------------------
FUNCTION fl_reset( cFPath, cFName )

   LOCAL cSep := ";"
   LOCAL aReset := {}
   LOCAL aStruct := {}

   // pobrisi ulazni direktorij
   fl_d_tmp()

   cFName := f_filepos( "0" )

   // izbrisi fajl greske odmah na pocetku ako postoji
   _f_err_delete( cFPath, cFName )

   // uzmi strukturu tabele za pos racun
   aStruct := _g_f_struct( F_POS_RN )

   // iscitaj pos matricu
   aReset := _fl_reset()

   _a_to_file( cFPath, cFName, aStruct, aReset )

   RETURN



// ----------------------------------------------------
// flink: dnevni izvjestaji
// ----------------------------------------------------
FUNCTION fl_daily( cFPath, cFName )

   LOCAL cSep := ";"
   LOCAL aRpt := {}
   LOCAL aStruct := {}
   LOCAL cRpt := "Z"

   Box(, 6, 60 )

   @ m_x + 1, m_y + 2 SAY "Dnevni izvjestaji..."
   @ m_x + 3, m_y + 2 SAY "Z - dnevni izvjestaj"
   @ m_x + 4, m_y + 2 SAY "X - presjek stanja"
   @ m_x + 6, m_y + 2 SAY "         ------------>" GET cRpt ;
      VALID cRpt $ "ZX" PICT "@!"


   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   // pobrisi ulazni direktorij
   fl_d_tmp()

   cFName := f_filepos( "0" )

   // izbrisi fajl greske odmah na pocetku ako postoji
   _f_err_delete( cFPath, cFName )

   // uzmi strukturu tabele za pos racun
   aStruct := _g_f_struct( F_POS_RN )

   // iscitaj pos matricu
   aRpt := _fl_daily( cRpt )

   _a_to_file( cFPath, cFName, aStruct, aRpt )

   RETURN



// ---------------------------------------------------
// unos pologa u printer
// ---------------------------------------------------
STATIC FUNCTION _fl_polog( nIznos )

   LOCAL cTmp := ""
   LOCAL cLogic
   LOCAL cLogSep := ","
   LOCAL cSep := ";"
   LOCAL aArr := {}
   LOCAL cZnak := "0"

   // :tip
   // 0 - uplata
   // 1 - isplata

   IF nIznos < 0
      cZnak := "1"
   ENDIF

   cLogic := "1"

   cTmp := "I"
   cTmp += cLogSep
   cTmp += cLogic
   cTmp += cLogSep
   cTmp += Replicate( "_", 6 )
   cTmp += cLogSep
   cTmp += Replicate( "_", 1 )
   cTmp += cLogSep
   cTmp += Replicate( "_", 2 )
   cTmp += cSep
   cTmp += cZnak
   cTmp += cSep
   cTmp += AllTrim( Str( Abs( nIznos ) ) )
   cTmp += cSep

   AAdd( aArr, { cTmp } )

   RETURN aArr



// ---------------------------------------------------
// dnevni izvjestaj x i z
// ---------------------------------------------------
STATIC FUNCTION _fl_daily( cTip )

   LOCAL cTmp := ""
   LOCAL cLogic
   LOCAL cLogSep := ","
   LOCAL cSep := ";"
   LOCAL aArr := {}

   cLogic := "1"

   cTmp := cTip
   cTmp += cLogSep
   cTmp += cLogic
   cTmp += cLogSep
   cTmp += Replicate( "_", 6 )
   cTmp += cLogSep
   cTmp += Replicate( "_", 1 )
   cTmp += cLogSep
   cTmp += Replicate( "_", 2 )
   cTmp += cSep

   AAdd( aArr, { cTmp } )

   RETURN aArr


// ---------------------------------------------------
// reset otvorenog racuna
// ---------------------------------------------------
STATIC FUNCTION _fl_reset()

   LOCAL cTmp := ""
   LOCAL cLogic
   LOCAL cLogSep := ","
   LOCAL cSep := ";"
   LOCAL aArr := {}

   cLogic := "1"

   cTmp := "N"
   cTmp += cLogSep
   cTmp += cLogic
   cTmp += cLogSep
   cTmp += Replicate( "_", 6 )
   cTmp += cLogSep
   cTmp += Replicate( "_", 1 )
   cTmp += cLogSep
   cTmp += Replicate( "_", 2 )
   cTmp += cSep

   AAdd( aArr, { cTmp } )

   RETURN aArr
