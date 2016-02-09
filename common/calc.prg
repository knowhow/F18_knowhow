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

STATIC s_lInCalculator := .F.


FUNCTION in_calc()
   RETURN s_lInCalculator


/* fn Calc()
 *  brief Kalkulator
 */
FUNCTION Calc()

   LOCAL GetList := {}
   PRIVATE cIzraz := Space( 40 )


   IF s_lInCalculator
      RETURN .F.
   ENDIF

altd()

   s_lInCalculator := .T.

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
         s_lInCalculator := .F.
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
         s_lInCalculator := .F.
         RETURN 0
      ENDIF
   ELSE
      PRIVATE cVar := ReadVar()
      IF Type( cVar ) == "N"
         &cVar := &cIzraz
      ENDIF
      SetKey( K_ALT_K, bKeyOld1 )
      SetKey( K_ALT_V, bKeyOld2 )
      s_lInCalculator := .F.
      return &cIzraz
   ENDIF

   s_lInCalculator := .F.

   RETURN 1



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

   RETURN .T.



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
