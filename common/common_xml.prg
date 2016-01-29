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


// ------------------------------------
// xml node
// ------------------------------------
FUNCTION xml_node( cName, cData, lWrite )

   LOCAL cTmp

   IF lWrite == nil
      lWrite := .T.
   ENDIF

   // eg.
   // cName = "position"
   // cData = "x26"
   // => <position>x26</position>

   cTmp := _bracket( cName, .F. )
   cTmp += AllTrim( cData )
   cTmp += _bracket( cName, .T. )

   IF lWrite == .T.
      ?? cTmp
      ?
   ENDIF

   RETURN cTmp


// ------------------------------------
// xml single node
// ------------------------------------
FUNCTION xml_snode( cName, cData, lWrite )

   LOCAL cTmp

   IF lWrite == nil
      lWrite := .T.
   ENDIF

   // eg.
   // cName = position
   // cData = bcr="22" vat="33"
   // => <position bcr="22" vat="33" />

   cTmp := _sbracket( cName + " " + cData )

   IF lWrite == .T.
      ?? cTmp
      ?
   ENDIF

   RETURN cTmp



// ----------------------------------------------
// xml subnode
// ----------------------------------------------
FUNCTION xml_subnode( cName, lEscape, lWrite )

   LOCAL cTmp

   IF lWrite == nil
      lWrite := .T.
   ENDIF

   // eg.
   // cName = "position"
   // => <position> (lEscape = .f.)
   // => </position> (lEscape = .t.)

   cTmp := _bracket( cName, lEscape )

   IF lWrite == .T.
      ?? cTmp
      ?
   ENDIF

   RETURN cTmp



// ----------------------------------------------------
// xml header
// ----------------------------------------------------
FUNCTION xml_head( lWrite, cTxt )

   LOCAL cTmp := '<?xml version="1.0" encoding="UTF-8"?>'

   IF cTxt == nil
      cTxt := cTmp
   ENDIF

   IF lWrite == nil
      lWrite := .T.
   ENDIF

   IF lWrite == .T.
      ?? cTxt
      ?
   ENDIF

   RETURN cTxt


// --------------------------------------------
// stavi single string u zagrade (single node)
// --------------------------------------------
STATIC FUNCTION _sbracket( cStr )

   LOCAL cRet

   cRet := "<"

   cRet += cStr
   cRet += " /"
   cRet += ">"

   RETURN cRet


// --------------------------------------------
// stavi string u zagrade
// --------------------------------------------
STATIC FUNCTION _bracket( cStr, lEsc )

   LOCAL cRet

   cRet := "<"
   IF lEsc == .T.
      cRet += "/"
   ENDIF
   cRet += cStr
   cRet += ">"

   RETURN cRet


// --------------------------------
// otvori xml fajl za upis
// --------------------------------
FUNCTION open_xml( cFile )

   IF cFile == nil
      cFile := my_home() + "data.xml"
   ENDIF

   SET PRINTER to ( cFile )
   SET PRINTER ON
   SET CONSOLE OFF

   RETURN


// --------------------------------
// zatvori fajl za upis
// --------------------------------
FUNCTION close_xml()

   SET PRINTER TO
   SET PRINTER OFF
   SET CONSOLE ON

   RETURN


// ----------------------------------------------
// datum za xml dokument
// ----------------------------------------------
FUNCTION xml_date( dDate )

   LOCAL cRet := ""

   cRet := AllTrim( Str( Year( dDate ) ) )
   cRet += "-"
   cRet += PadL( AllTrim( Str( Month( dDate ) ) ), 2, "0" )
   cRet += "-"
   cRet += PadL( AllTrim( Str( Day( dDate ) ) ), 2, "0" )

   RETURN cRet
