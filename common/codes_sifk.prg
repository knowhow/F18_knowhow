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


FUNCTION SifkFill( cSifk, cSifv, cSifrarnik, cIDSif )

   PushWa()

   USE ( cSifK ) NEW   ALIAS _SIFK
   USE ( cSifV ) NEW   ALIAS _SIFV

   SELECT _SIFK
   IF reccount2() == 0  // nisu upisane karakteristike, ovo se radi samo jednom
      SELECT sifk; SET ORDER TO TAG "ID";  SEEK PadR( cSifrarnik, 8 )
      // uzmi iz sifk sve karakteristike ID="ROBA"

      DO WHILE !Eof() .AND. ID = PadR( cSifrarnik, 8 )
         Scatter()
         SELECT _Sifk; APPEND BLANK
         Gather()
         SELECT sifK
         SKIP
      ENDDO
   ENDIF // reccount()

   // uzmi iz sifv sve one kod kojih je ID=ROBA, idsif=2MON0002

   SELECT sifv
   SET ORDER TO TAG "IDIDSIF"
   SEEK PadR( cSifrarnik, 8 ) + cidsif

   DO WHILE !Eof() .AND. ID == PadR( cSifrarnik, 8 ) .AND. idsif == PadR( cidsif, Len( cIdSif ) )
      Scatter()
      SELECT _SifV
      APPEND BLANK
      Gather()
      SELECT sifv
      SKIP
   ENDDO

   SELECT _sifv
   USE
   SELECT _sifk
   USE

   PopWa()

   RETURN
// }

/*!
 @function   SifkOsv
 @abstract   Osvjezi tabele SIFK, SIFV iz pomocnih tabela (uobicajeno _SIFK, SIFV)
 @discussion -
 @param cSIFK ime sifk tabele (npr PRIVPATH+"_SIFK")
 @param cSifV ime sifv tabele
 @param cSifrarnik sifrarnik (npr "ROBA")
*/

FUNCTION SifkOsv( cSifk, cSifv, cSifrarnik, cIDSif )

   // {
   PushWa()

   USE ( cSifK ) NEW   ALIAS _SIFK
   USE ( cSifV ) NEW   ALIAS _SIFV

   SELECT sifk; SET ORDER TO TAG "ID2" // id + oznaka
   SELECT _sifk
   DO WHILE !Eof()
      scatter()
      SELECT sifk
      SEEK _SIFK->( ID + OZNAKA )
      IF !Found()
         APPEND BLANK
      ENDIF
      Gather()
      SELECT _SIFK
      SKIP
   ENDDO

   SELECT sifv

   // "ID","id+oznaka+IdSif",SIFPATH+"SIFV"
   SET ORDER TO TAG "ID"

   SELECT _SIFV
   DO WHILE !Eof()
      scatter()
      SELECT SIFV
      SEEK _SIFV->( ID + OZNAKA + IDSIF )
      IF !Found()
         APPEND BLANK
      ENDIF
      Gather()
      SELECT _SIFV
      SKIP
   ENDDO

   SELECT _SIFK
   USE
   SELECT _SIFV
   USE

   PopWa()

   RETURN

/*! \fn DaUSifv(cBaza,cIdKar,cId,cVrKar)
 *  \brief
 *  \param cBaza
 *  \param cIdKar
 *  \param cId
 *  \param cVrKar
 */
FUNCTION DaUSifV( cBaza, cIdKar, cId, cVrKar )

   LOCAL nArr := Select(), lVrati := .F.

   SELECT SIFV
   SEEK PadR( cBaza, 8 ) + PadR( cIdKar, 4 ) + PadR( cId, 15 ) + cVrKar
   IF Found()
      lVrati := .T.
   ENDIF
   SELECT ( nArr )

   RETURN lVrati
