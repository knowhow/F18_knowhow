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



// --------------------------------
// lista sastavnica
// --------------------------------
FUNCTION g_sast_list()

   LOCAL cMarker
   LOCAL cKto
   LOCAL lExpDbf := .F.
   LOCAL cExpDbf
   LOCAL nVar := 2

   // uslovi exporta
   IF  _get_vars( @cMarker, @cKto, @cExpDbf ) == 0
      RETURN
   ENDIF

   IF cExpDbf == "D"
      lExpDbf := .T.
   ENDIF


   // kreiraj kroz export tabelu ovaj pregled....
   aFields := _g_fields()
   t_exp_create( aFields )

   O_R_EXP

   // kreiraj i privremeni index
   INDEX ON r_export->idsast TAG "1"


   // sada kada imas sve uslove, napravi selekciju
   O_ROBA
   O_SAST

   SELECT sast
   SET ORDER TO TAG "IDRBR"
   GO TOP


   Box(, 3, 60 )

   @ m_x + 1, m_y + 2 SAY "sortiram podatke....."


   DO WHILE !Eof()

      cRoba := field->id

      SELECT roba
      GO TOP
      SEEK cRoba

      IF Found() .AND. field->id == cRoba

         IF !Empty( cMarker ) .AND. field->k1 <> cMarker

            SELECT sast
            SKIP
            LOOP

         ENDIF

      ELSE

         SELECT sast
         SKIP
         LOOP

      ENDIF

      SELECT sast

      DO WHILE !Eof() .AND. field->id == cRoba

         fill_exp_tbl( sast->id2, _art_naz( sast->id2 ), ;
            sast->kolicina, 0 )

         @ m_x + 3, m_y + 2 SAY "sastavnica: " + sast->id2

         SKIP
      ENDDO

   ENDDO

   // sada izracunaj stanja za sve u r_export
   SELECT r_export
   SET ORDER TO TAG "1"

   GO TOP

   my_flock()

   DO WHILE !Eof()

      // izracunaj stanje
      REPLACE field->stanje WITH g_kalk_stanje( field->idsast, cKto )

      IF field->kol > 0 .AND. field->stanje <= field->kol
         REPLACE field->TOTAL WITH field->kol - field->stanje
      ELSE
         REPLACE field->TOTAL WITH 0
      ENDIF

      SKIP

   ENDDO

   my_unlock()

   BoxC()

   // i sada daj report
   // .....

   IF Empty( cKto )
      nVar := 1
   ENDIF


   r_sast_list( cMarker, nVar )


   IF lExpDbf == .T.
      tbl_export()
   ENDIF

   RETURN



// ------------------------------------------
// report sastavnice
// ------------------------------------------
STATIC FUNCTION r_sast_list( cMarker, nVar )

   LOCAL cSpace := Space( 2 )
   LOCAL cLine
   LOCAL i

   START PRINT CRET

   SELECT r_export
   SET ORDER TO TAG "1"
   GO TOP

   i := 0

   ?

   P_COND

   ? cSpace + "Specifikacija sastavnica po oznaci"
   ? cSpace + "Oznaka: " + cMarker
   ?

   cLine := cSpace + Replicate( "-", 5 ) + Space( 1 ) + Replicate( "-", 10 ) + ;
      Space( 1 ) + ;
      Replicate( "-", 40 ) + Space( 1 ) + Replicate( "-", 10 ) + ;
      iif( nVar == 2, Space( 1 ) + Replicate( "-", 10 ) + Space( 1 ) + ;
      Replicate( "-", 10 ), "" )



   ? cLine

   ? cSpace + PadR( "R.br", 5 ), PadR( "Sifra", 10 ), PadR( "Naziv", 40 ), PadR( "Kol.po", 10 ), IF( nVar == 2, PadR( "Stanje", 10 ) + Space( 1 ) + PadR( "Ukupno", 10 ), "" )
   ? cSpace + PadR( "", 5 ), PadR( "", 10 ), PadR( "", 40 ), PadR( "sastav.", 10 ), IF( nVar == 2, PadR( "po kart.", 10 ) + Space( 1 ) + PadR( "", 10 ), "" )
   ? cSpace + PadR( "", 5 ), PadR( "", 10 ), PadR( "", 40 ), PadC( "(1)", 10 ), IF( nVar == 2, PadC( "(2)", 10 ) + Space( 1 ) + PadC( "(1-2)", 10 ), "" )

   ? cLine

   DO WHILE !Eof()

      ? cSpace + Str( ++i, 4 ) + ")"

      @ PRow(), PCol() + 1 SAY field->idsast
      @ PRow(), PCol() + 1 SAY field->naz
      @ PRow(), PCol() + 1 SAY Str( field->kol, 10, 2 )

      IF nVar == 2

         @ PRow(), PCol() + 1 SAY Str( field->stanje, 10, 2 )
         @ PRow(), PCol() + 1 SAY Str( field->total, 10, 2 )

      ENDIF

      SKIP
   ENDDO

   ? cLine

   FF
   ENDPRINT

   RETURN




// vraca naziv robe
STATIC FUNCTION _art_naz( cId )

   LOCAL nTArea := Select()
   LOCAL cRet

   SELECT roba
   SEEK cId
   cRet := naz

   SELECT ( nTArea )

   RETURN cRet


// -----------------------------------------------
// vraca stanje sa lagera za cKto i cIdRoba
// -----------------------------------------------
STATIC FUNCTION g_kalk_stanje( cIdRoba, cKto )

   LOCAL nTArea := Select()
   LOCAL nStanje := 0

   IF !Empty( cKto )

      o_kalk()
      SELECT kalk
      SET ORDER TO TAG "3"
      GO TOP

      SEEK gFirma + cKto + cIdRoba

      DO WHILE !Eof() .AND. idfirma + mkonto + idroba == gFirma + cKto + cIdRoba

         IF mu_i == "1"

            IF idvd $ "12#22#94"
               nStanje += kolicina - gkolicina - gkolicin2
            ELSE
               nStanje += kolicina
            ENDIF

         ELSEIF mu_i == "5"

            nStanje -= kolicina
         ENDIF

         SKIP
      ENDDO

   ENDIF

   SELECT ( nTArea )

   RETURN nStanje



// ----------------------------------------------
// uslovi liste
// ----------------------------------------------
STATIC FUNCTION _get_vars( cMark, cMagKto, cExpDbf )

   LOCAL nX := 1

   cMark := Space( 4 )
   cMagKto := Space( 7 )
   cExpDbf := "D"

   Box(, 10, 60 )

   @ m_x + nX, m_y + 2 SAY "***** Lista sastavnica po oznaci"

   nX += 3

   @ m_x + nX, m_y + 2 SAY "Oznaka koristena u K1 (prazno-sve):" GET cMark

   nX += 2

   @ m_x + nX, m_y + 2 SAY "Gledaj stanje sirovina na kontu:" GET cMagKto VALID Empty( cMagKto ) .OR. p_konto( @cMagKto )

   nX += 2

   @ m_x + nX, m_y + 2 SAY "Export u dbf?" GET cExpDbf VALID cExpDbf $ "DN" PICT "@!"

   READ
   BoxC()


   IF LastKey() == K_ESC
      RETURN 0
   ENDIF

   RETURN 1


// --------------------------------------------
// specifikacija polja tabele exporta
// --------------------------------------------
STATIC FUNCTION _g_fields()

   LOCAL aFields := {}

   AAdd( aFields, { "IDSAST", "C", 10, 0 } )
   AAdd( aFields, { "NAZ", "C", 40, 0 } )
   // kolicina po sastavnicama
   AAdd( aFields, { "KOL", "N", 15, 5 } )
   // kolicina u kalk-u
   AAdd( aFields, { "STANJE", "N", 15, 5 } )
   // razlika
   AAdd( aFields, { "TOTAL", "N", 15, 5 } )

   RETURN aFields



// ---------------------------------------------------------
// filuj tabelu exporta sa vrijednostima....
// ---------------------------------------------------------
STATIC FUNCTION fill_exp_tbl( cSast, cNaz, nKol, nStanje )

   LOCAL nTArea := Select()

   O_R_EXP

   SELECT r_export
   SET ORDER TO TAG "1"

   SEEK cSast

   my_flock()

   IF !Found()

      APPEND BLANK
      REPLACE field->idsast WITH cSast
      REPLACE field->naz WITH cNaz

   ENDIF

   REPLACE field->kol WITH field->kol + nKol

   // stanje je uvijek isto njega ne sabiri
   REPLACE field->stanje WITH nStanje

   IF field->kol > 0 .AND. field->stanje <= field->kol
      REPLACE field->TOTAL WITH field->kol - field->stanje
   ELSE
      REPLACE field->TOTAL WITH 0
   ENDIF

   my_unlock()

   SELECT ( nTArea )

   RETURN
