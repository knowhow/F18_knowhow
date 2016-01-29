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


#define NL Chr(13)+Chr(10)
#define MM 56.69895


// aRow[1] = { 10 mm, { "b", "s", 0.1 } , { "t", "s", 0.1} }
// pozicija s lijeva

FUNCTION WWRowDef( aRows, nLeft, ntrgaph, nHigh )

   LOCAL nrow, i

   ?? "\trowd "
   IF nTrGaph == NIL
      nTrGaph := 1
   ENDIF
   ?? "\trgaph" + Top( nTrgaph )

   IF nLeft == NIL
      nLeft := 0
   ENDIF
   ?? "\trleft" + ToP( nLeft )

   IF nHigh <> NIL
      ?? "\trrh" + ToP( nHigh )
   ENDIF

   nTekPos := nLeft
   FOR nrow := 1 TO Len( aRows )
      FOR i := 2 TO Len( aRows[ nRow ] )
         ?? "\clbrdr" + aRows[ nRow, i, 1 ]
         ?? "\brdr" + aRows[ nRow, i, 2 ]
         ?? "\brdrw" + ToP( aRows[ nRow, i, 3 ] )
      NEXT
      nTekPos += aRows[ nRow, 1 ]
      ?? "\cellx" + ToP( nTekPos ) + NL
   NEXT
   ?? "\pard\intbl "

   RETURN


FUNCTION WWCells( aCells )

   //
   //

   FOR i := 1 TO Len( aCells )
      ?? aCells[ i ] + "\cell "
   NEXT
   ?? "\pard\intbl\row" + NL

FUNCTION WWTBox( nL, nT, nWX, nWY, cTxt, cTipL, aCL, nWL, ;
      aCF, aCB, cPatt )

   //
   //

   ?? "{\*\do\dobxpage\dobypage\dptxbx\dptxbxmar20{\dptxbxtext \pard\plain" + NL
   ??  cTxt + "\par}" + NL
   ?? "\dpx" + ToP( nL ) + "\dpy" + ToP( nT ) + "\dpxsize" + ToP( nWX ) + "\dpysize" + ToP( nWY )
   ?? "\dpline"
   IF cTipL == "0"
      ?? "hollow"
   ELSEIF cTipL == "1"
      ?? "solid"
   ELSEIF cTipL == "2"
      ?? "dadodo"
   ELSEIF cTipL == "3"
      ?? "dado"
   ELSEIF cTipL == "4"
      ?? "dot"
   ELSEIF cTipL == "5"
      ?? "hash"
   ENDIF
   ?? "\dplinecor" + AllTrim( Str( aCL[ 1 ], 3, 0 ) )
   ?? "\dplinecog" + AllTrim( Str( aCL[ 2 ], 3, 0 ) )
   ?? "\dplinecob" + AllTrim( Str( aCL[ 3 ], 3, 0 ) )
   ?? "\dplinew" + ToP( nWL )
   ?? "\dpfillfgcr" + AllTrim( Str( aCF[ 1 ], 3, 0 ) )
   ?? "\dpfillfgcg" + AllTrim( Str( aCF[ 2 ], 3, 0 ) )
   ?? "\dpfillfgcb" + AllTrim( Str( aCF[ 3 ], 3, 0 ) )
   ?? "\dpfillbgcr" + AllTrim( Str( aCB[ 1 ], 3, 0 ) )
   ?? "\dpfillbgcg" + AllTrim( Str( aCB[ 2 ], 3, 0 ) )
   ?? "\dpfillbgcb" + AllTrim( Str( aCB[ 3 ], 3, 0 ) )
   ?? "\dpfillpat" + cPatt + "}" + NL

FUNCTION WWInit0()

   //

   ?? "{\rtf1\ansi\ansicpg1250\deff4\deflang1050"

   RETURN NIL


FUNCTION WWinit1()

   //

   ?? "\windowctrl\ftnbj\aenddoc\formshade \fet0\sectd\linex0\endnhere\pard\plain\f1\fs20" + NL

   RETURN NIL



FUNCTION WWFontTbl()

   //

   ?? "{\fonttbl{\f1\fswiss\fcharset238\fprq2 Arial CE;}{\f2\fswiss\fcharset238\fprq2 " + Trim( gPFont ) + ";}}"
   ?? NL

   RETURN


FUNCTION WWStyleTbl()

   //

   ?? "{\stylesheet {\f2\fs20 \snext0 Normal;}{\*\cs10 \additive Default Paragraph Font;}"
   ?? "{\s20\qc\sb40\sa0\sl-400\slmult0 \f2\fs20 \sbasedon0\snext20 estyle1;}}" + NL

FUNCTION WWEnd()

   ?? "\par}"

FUNCTION WWSetMarg( nLeft, nTop, nRight, nBottom )

   //

   IF nLeft <> NIL
      ?? "\marglsxn" + ToP( nLeft )
   ENDIF
   IF nRight <> NIL
      ?? "\margrsxn" + ToP( nRight )
   ENDIF
   IF nTop <> NIL
      ?? "\margtsxn" + ToP( nTop )
   ENDIF
   IF nTop <> NIL
      ?? "\margbsxn" + ToP( nBottom )
   ENDIF

FUNCTION ToP( nMilim )

   //

   RETURN AllTrim( Str ( Round( nMilim * MM, 0 ) ) )


FUNCTION ToRtfstr( cStr )

   LOCAL cPom, i, cChar

   cPom := ""
   FOR i := 1 TO Len( cStr )
      cChar := SubStr( cStr, i, 1 )
      IF cChar == "{"
         cPom += "\{"
      ELSEIF cChar == "}"
         cPom += "\}"
      ELSEIF cChar == "\"
         cPom += "\\"
      ELSEIF cChar $ "�"
         cPom += "\'9a"
      ELSEIF cChar $ "�"
         cPom += "\'8a"
      ELSEIF cChar $ "�"
         IF gWord97 == "D"
            cPom += "\u263\'63"
         ELSE
            cPom += "\'e6"
         ENDIF
      ELSEIF cChar $ "�"
         IF gWord97 == "D"
            cPom += "\u262\'43"
         ELSE
            cPom += "\'c6"
         ENDIF
      ELSEIF cChar $ "�"
         IF gWord97 == "D"
            cPom += "\u269\'63"
         ELSE
            cPom += "\'e8"
         ENDIF
      ELSEIF cChar $ "�"
         IF gWord97 == "D"
            cPom += "\u268\'43"
         ELSE
            cPom += "\'c8"
         ENDIF
      ELSEIF cChar $ "�"
         IF gWord97 == "D"
            cPom += "\u273\'64"
         ELSE
            cPom += "\'f0"
         ENDIF
      ELSEIF cChar $ "�"
         IF gWord97 == "D"
            cPom += "\u272\'do"
         ELSE
            cPom += "\'d0"
         ENDIF
      ELSEIF cChar $ "�"
         cPom += "\'9e"
      ELSEIF cChar $ "�"
         cPom += "\'8e"
      ELSEIF SubStr( cStr, i, 2 ) == NL
         cPom += "\par "
         ++i
      ELSE
         cPom += SubStr( cStr, i, 1 )
      ENDIF
   NEXT

   RETURN cPom


FUNCTION WWSetPage( cFormat, cPL )

   //
   //

   IF Upper( cFormat ) == "A4"
      IF cpl == NIL .OR. Upper( cPL ) = "P" // portrait
         ?? "\pgwsxn11907\pghsxn16840"
      ELSE
         ?? "\pgwsxn16840\pghsxn11907"
      ENDIF

   ELSEIF Upper( cFormat ) == "A3"
      IF cpl == NIL .OR. Upper( cPL ) = "P" // portrait
         ?? "\pgwsxn16839\pghsxn23814"
      ELSE
         ?? "\pgwsxn23814\pghsxn16839"
      ENDIF
   ENDIF

   RETURN NIL


FUNCTION WWInsPict( cIme, cPath )

   IF cpath = NIL
      cPath := "c:/sigma/"
   ELSE
      cPath := StrTran( cpath, "\", "/" )  // rtf to trazi
   ENDIF
   ?? "{\field{\*\fldinst { INCLUDEPICTURE " + cpath + cime + "\\d  \\* MERGEFORMAT }}\par}"

   RETURN
