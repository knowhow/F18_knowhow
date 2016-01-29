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

// ---------------------------------------
// lokalizira string u skladu sa
// trenutnom postavkom lokalizacije
// ---------------------------------------
FUNCTION lokal( cString, cLokal )

   LOCAL cPrevod
   LOCAL nIdStr

   cString := hb_UTF8ToStr( cString )

   IF ( cLokal == nil )
      cLokal := gLokal
   ENDIF

   IF AllTrim( cLokal ) == "0"
      RETURN cString
   ENDIF

   PushWA()
   SELECT F_LOKAL
   IF !Used()
      O_LOKAL
   ENDIF

   SET ORDER TO TAG "IDNAZ"
   // nadji izvorni string
   SEEK "0 " + cString + "##"

   IF !Found()
      APPEND BLANK
      REPLACE id WITH "0 ", ;
         naz WITH cString + "##", ;
         id_str WITH next_id_str()
   ELSE
      nIdStr := id_str
      // nadji prevod - za tekucu lokalizaciju
      SET ORDER TO TAG "ID"
      SEEK PadR( cLokal, 2 ) + Str( nIdStr, 6, 0 )
      IF Found()
         // postoji prevod

         // "neki tekst##            "
         cString := RTrim( naz )
         // "neki tekst##"
         cString := Left( cString, Len( cString ) - 2 )
         // "neki tekst"
      ENDIF

   ENDIF
   PopWa()

   RETURN cString

// ----------------------
// sljedeci id na redu
// ----------------------
FUNCTION next_id_str()

   LOCAL nNext

   PushWA()
   SET ORDER TO TAG "ID_STR"
   GO BOTTOM
   nNext := id_str + 1
   PopWa()

   RETURN nNext
