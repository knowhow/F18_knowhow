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

FUNCTION KonvZnWin( txt )
   RETURN txt

/*! \fn KonvZnWin(cTekst, cWinKonv)
 *  \brief Konverzija znakova u stringu
 *  \param cTekst - tekst
 *  \param cWinKonv - tip konverzije
 */
FUNCTION KonvZnWin_old( cTekst, cWinKonv )

   LOCAL aNiz := {}
   LOCAL i
   LOCAL j

   AAdd( aNiz, { "[", "�", Chr( 138 ), "S", "�" } )
   AAdd( aNiz, { "{", "�", Chr( 154 ), "s", "�" } )
   AAdd( aNiz, { "}", "�", Chr( 230 ), "c", "�" } )
   AAdd( aNiz, { "]", "�", Chr( 198 ), "C", "�" } )
   AAdd( aNiz, { "^", "�", Chr( 200 ), "C", "�" } )
   AAdd( aNiz, { "~", "�", Chr( 232 ), "c", "�" } )
   AAdd( aNiz, { "`", "�", Chr( 158 ), "z", "�" } )
   AAdd( aNiz, { "@", "�", Chr( 142 ), "Z", "�" } )
   AAdd( aNiz, { "|", "�", Chr( 240 ), "dj", "�" } )
   AAdd( aNiz, { "\", "�", Chr( 208 ), "DJ", "�" } )

   IF cWinKonv = NIL
      cWinKonv := my_get_from_ini( "DelphiRb", "Konverzija", "5" )
   ENDIF

   i := 1
   j := 1

   IF cWinKonv == "1"
      i := 1
      j := 2
   ELSEIF cWinKonv == "2"
      // 7->A
      i := 1
      j := 4
   ELSEIF cWinKonv == "3"
      // 852->7
      i := 2
      j := 1
   ELSEIF cWinKonv == "4"
      // 852->A
      i := 2
      j := 4
   ELSEIF cWinKonv == "5"
      // 852->win1250
      i := 2
      j := 3
   ELSEIF cWinKonv == "6"
      // 7->win1250
      i := 1
      j := 3
   ELSEIF cWinKonv == "8"
      i := 3
      j := 5
   ENDIF

   IF i <> j
      AEval( aNiz, {| x| cTekst := StrTran( cTekst, x[ i ], x[ j ] ) } )
   ENDIF

   RETURN cTekst

// -----------------------
// -----------------------
FUNCTION StrKZN( cInput )
   RETURN cInput


/*! \fn StrKZN(cInput, cIz, cU)
 *  \brief Vrsi zamjenu cInputa
 */
FUNCTION StrKZN_old( cInput, cIz, cU )

   LOCAL a852 := { "�", "�", "�", "�", "�", "�", "�", "�", "�", "�" }
   LOCAL a437 := { "[", "\", "^", "]", "@", "{", "|", "~", "}", "`" }
   LOCAL aEng := { "S", "D", "C", "C", "Z", "s", "d", "c", "c", "z" }
   LOCAL aEngB := { "SS", "DJ", "CH", "CC", "ZZ", "ss", "dj", "ch", "cc", "zz" }
   LOCAL aWin := { "�", "�", "�", "�", "�", "�", "�", "�", "�", "�" }
   LOCAL aUTF := { "&#352;", "&#272;", "&#268;", "&#262;", "&#381;", "&#353;", ;
      "&#273;", "&#269;", "&#263;", "&#382;" }

   LOCAL i := 0, aIz := {}, aU := {}

   IF cIz == "7"
      aIz := a437
   ELSEIF cIz == "8"
      aIz := a852
   ELSEIF ( tekuci_modul() == "LD" .AND. cIz == "B" )
      aIz := aEngB
   ELSEIF ( cIz == "W" )
      aIz := aWin
   ELSE
      aIz := aEng
   ENDIF

   IF cU == "7"
      aU := a437
   ELSEIF cU == "8"
      aU := a852
   ELSEIF cU == "U"
      aU := aUTF
   ELSEIF tekuci_modul() == "LD" .AND. cU == "B"
      aU := aEngB
   ELSE
      aU := aEng
   ENDIF

   // Ove dvije linije zamjenio sa gornjim kodom
   // aIz:=IF(cIz=="7", a437, IF(cIz=="8", a852, aEng))
   // aU:=IF(cU=="7", a437, IF(cU=="8", a852, aEng))

   cPocStanjeSif := cInput

   FOR i := 1 TO 10
      IF ( tekuci_modul() == "LD" .AND. i == 5 )
         IF At( "D@", cInput ) <> 0
            cInput := StrTran( cInput, "D@", "DZ" )
         ELSEIF At( "D|", cInput ) <> 0
            cInput := StrTran( cInput, "D|", "DZ" )
         ENDIF
      ENDIF
      IF ( tekuci_modul() == "LD" .AND. i == 10 )
         IF At( "d�", cInput ) <> 0
            cInput := StrTran( cInput, "d�", "dz" )
         ELSEIF At( "d`", cInput ) <> 0
            cInput := StrTran( cInput, "d`", "dz" )
         ENDIF
      ENDIF

      cInput := StrTran( cInput, aIz[ i ], aU[ i ] )
   NEXT


   IF ( cU == "B" .AND. Len( AllTrim( cInput ) ) > 6 )
      // provjeri da li ovaj par postoji u nizu
      nPos := AScan( aKonvZN, {| aVal| aVal[ 1 ] == cPocStanjeSif } )
      IF nPos > 0
         cRet := aKonvZN[ nPos, 2 ]
      ELSE
         cNoviId := Space( 6 )
         Box(, 3, 25 )
         @ 1 + m_x, 2 + m_y SAY "Unesi novi ID za sifru: "
         @ 2 + m_x, 2 + m_y SAY "Stari ID: " + cPocStanjeSif
         @ 3 + m_x, 2 + m_y SAY "Novi ID: " GET cNoviID
         READ
         BoxC()
         AAdd( aKonvZN, { cPocStanjeSif, cNoviId } )
         cRet := cNoviID
      ENDIF
   ELSE
      cRet := cInput
   ENDIF

   cKrajnjeStanjeSif := cRet

   RETURN cRet


FUNCTION KSto7( cStr )
   RETURN cStr

// --------------------------------
// --------------------------------
FUNCTION KSto7_old( cStr )

   cStr := StrTran( cStr, "�", "{" )
   cStr := StrTran( cStr, "�", "|" )
   cStr := StrTran( cStr, "�", "`" )
   cStr := StrTran( cStr, "�", "~" )
   cStr := StrTran( cStr, "�", "}" )
   cStr := StrTran( cStr, "�", "[" )
   cStr := StrTran( cStr, "�", "\" )
   cStr := StrTran( cStr, "�", "@" )
   cStr := StrTran( cStr, "�", "^" )
   cStr := StrTran( cStr, "�", "]" )

   RETURN cStr


// ---------------------------------------------------
// konverzija u utf-8
// ---------------------------------------------------
FUNCTION strkznutf8( cInput, cIz )

   LOCAL aWin := {}
   LOCAL aUTF := {}
   LOCAL a852 := {}
   LOCAL aTmp := {}

   // windows kodovi...
   AAdd( aWin, "&" )
   AAdd( aWin, "�" )
   AAdd( aWin, "�" )
   AAdd( aWin, "�" )
   AAdd( aWin, "�" )
   AAdd( aWin, "�" )
   AAdd( aWin, "�" )
   AAdd( aWin, "�" )
   AAdd( aWin, "�" )
   AAdd( aWin, "�" )
   AAdd( aWin, "�" )
   AAdd( aWin, "!" )
   AAdd( aWin, '"' )
   AAdd( aWin, "'" )
   AAdd( aWin, "," )
   AAdd( aWin, "-" )
   AAdd( aWin, "." )
   AAdd( aWin, "\" )
   AAdd( aWin, "/" )
   AAdd( aWin, "=" )
   AAdd( aWin, "(" )
   AAdd( aWin, ")" )
   AAdd( aWin, "[" )
   AAdd( aWin, "]" )
   AAdd( aWin, "{" )
   AAdd( aWin, "}" )
   AAdd( aWin, "<" )
   AAdd( aWin, ">" )

   // pandan 852 je...
   AAdd( a852, "&" ) // feature
   AAdd( a852, "�" ) // SS
   AAdd( a852, "�" ) // DJ
   AAdd( a852, "�" ) // CC
   AAdd( a852, "�" ) // CH
   AAdd( a852, "�" ) // ZZ
   AAdd( a852, "�" ) // ss
   AAdd( a852, "�" ) // dj
   AAdd( a852, "�" ) // cc
   AAdd( a852, "�" ) // ch
   AAdd( a852, "�" ) // zz
   AAdd( a852, "!" ) // uzvicnik
   AAdd( a852, '"' ) // navodnici
   AAdd( a852, "'" ) // jedan navodnik
   AAdd( a852, "," ) // zarez
   AAdd( a852, "-" ) // minus
   AAdd( a852, "." ) // tacka
   AAdd( a852, "\" ) // b.slash
   AAdd( a852, "/" ) // slash
   AAdd( a852, "=" ) // jedanko
   AAdd( a852, "(" ) // otv.zagrada
   AAdd( a852, ")" ) // zatv.zagrada
   AAdd( a852, "[" ) // otv.ugl.zagrada
   AAdd( a852, "]" ) // zatv.ugl.zagrada
   AAdd( a852, "{" ) // otv.vit.zagrada
   AAdd( a852, "}" ) // zatv.vit.zagrada
   AAdd( a852, "<" ) // manje
   AAdd( a852, ">" ) // vece
   // itd...

   // pandan UTF je...
   AAdd( aUTF, "&#38;" )
   AAdd( aUTF, "&#352;" )
   AAdd( aUTF, "&#272;" )
   AAdd( aUTF, "&#268;" )
   AAdd( aUTF, "&#262;" )
   AAdd( aUTF, "&#381;" )
   AAdd( aUTF, "&#353;" )
   AAdd( aUTF, "&#273;" )
   AAdd( aUTF, "&#269;" )
   AAdd( aUTF, "&#263;" )
   AAdd( aUTF, "&#382;" )
   AAdd( aUTF, "&#33;" )
   AAdd( aUTF, "&quot;" )
   AAdd( aUTF, "&#39;" )
   AAdd( aUTF, "&#44;" )
   AAdd( aUTF, "&#45;" )
   AAdd( aUTF, "&#46;" )
   // AADD( aUTF, "&#92;" )
   AAdd( aUTF, "\" )
   // AADD( aUTF, "&#97;" )
   AAdd( aUTF, "/" )
   AAdd( aUTF, "&#8215;" )
   AAdd( aUTF, "&#40;" )
   AAdd( aUTF, "&#41;" )
   AAdd( aUTF, "&#91;" )
   AAdd( aUTF, "&#93;" )
   AAdd( aUTF, "&#123;" )
   AAdd( aUTF, "&#125;" )
   AAdd( aUTF, "&#60;" )
   AAdd( aUTF, "&#62;" )

   IF cIz == "8"
      aTmp := a852
   ELSEIF cIz == "W"
      aTmp := aWin
   ENDIF

   cRet := strkzn( cInput, cIz, "U", aTmp, aUtf )

   RETURN cRet
