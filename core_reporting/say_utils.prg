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


FUNCTION say_kolicina( nVar, cPic )

   hb_default( @cPic, prosiri_pic_kolicina_za_2() )

   RETURN say_pict( nVar, cPic, .T. )


FUNCTION say_iznos( nVar, cPic )

   hb_default( @cPic, prosiri_pic_iznos_za_2() )

   RETURN say_pict( nVar, cPic )


FUNCTION say_cijena( nVar, cPic )

   hb_default( @cPic, prosiri_pic_cjena_za_2() )

   RETURN say_pict( nVar, cPic )


FUNCTION say_pict( nVar, cPicture, lZero )

   LOCAL nLen := Len( cPicture ), cPic2, cVar, nI

   hb_default( @lZero, .F. )


   nVar := Round( nVar, 4 )
   FOR nI := 0 TO 3
      IF nI == 0
         cPic2 := Replicate( "9", nLen )
      ELSE
         cPic2 := Replicate( "9", nLen - nI - 1 ) + "." + Replicate( "9", nI )
      ENDIF

      IF lZero
         cPic2 := "@Z " + cPic2
      ENDIF
      cVar := Transform( nVar, cPic2 ) // 5.2 "999999" => "    5"

      IF Val( cVar ) == nVar
         RETURN cVar
      ENDIF

   NEXT

   RETURN Transform( nVar, cPicture ) // ako nista ne odgovara



/*
      sredjivanje formata ispisa
*/
FUNCTION pic_format( cPicture, nNum )

   LOCAL cPictureOut

   IF "*" $ Transform( nNum, cPicture )
      cPictureOut := StrTran( cPicture, ".", "9" ) // jednostavno ukini decimalno mjesto kod ispisa
   ELSE
      cPictureOut := cPicture
   ENDIF

   RETURN cPictureOut
