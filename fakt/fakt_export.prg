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


// ----------------------------------
// export tabele fakt
// ----------------------------------
FUNCTION fakt_export_tbl_fakt()

   LOCAL dD_f
   LOCAL dD_t
   LOCAL cId_f
   LOCAL cId_td

   // daj uslove
   IF get_vars( @dD_f, @dD_t, @cId_f, @cId_td ) == 0
      RETURN
   ENDIF

   // kreiraj export tabelu
   cre_export_table()
   O_R_EXP
   INDEX ON idfirma + idtipdok + brdok TAG "1"

   fill_export_table( dD_f, dD_t, cId_f, cId_td )

   RETURN


// ---------------------------------
// kreiranje tabele
// ---------------------------------
STATIC FUNCTION cre_export_table()

   LOCAL aDbf

   aDbf := get_export_fields()
   t_exp_create( aDbf )

   RETURN



// ----------------------------------
// vraca potrebna polja tabele
// ----------------------------------
STATIC FUNCTION get_export_fields()

   LOCAL aRet := {}

   AAdd( aRet, { "IDFIRMA", "C", 2, 0 } )
   AAdd( aRet, { "IDTIPDOK", "C", 2, 0 } )
   AAdd( aRet, { "BRDOK", "C", 8, 0 } )
   AAdd( aRet, { "DATDOK", "D", 8, 0 } )
   AAdd( aRet, { "IDPARTNER", "C", 6, 0 } )
   AAdd( aRet, { "IDROBA", "C", 10, 0 } )
   AAdd( aRet, { "KOLICINA", "N", 20, 5 } )
   AAdd( aRet, { "CIJENA", "N", 20, 5 } )
   AAdd( aRet, { "RABAT", "N", 20, 5 } )
   AAdd( aRet, { "IDREL", "C", 5, 0 } )

   RETURN aRet


// -----------------------------------
// uslovi povlacenja
// -----------------------------------
STATIC FUNCTION get_vars( dD_f, dD_t, cId_f, cId_td )

   LOCAL nRet := 1
   LOCAL GetList := {}

   dD_f := Date() -60
   dD_t := Date()
   cId_f := PadR( gFirma + ";", 100 )
   cId_td := PadR( "10;", 100 )

   Box(, 5, 65 )
   @ m_x + 1, m_y + 2 SAY "Datum od" GET dD_f
   @ m_x + 1, Col() + 1 SAY "do" GET dD_t
   @ m_x + 2, m_y + 2 SAY "Firma (prazno-sve):" GET cId_f ;
      PICT "@S20"
   @ m_x + 3, m_y + 2 SAY "Tip dokumenta (prazno-svi:)" GET cId_td ;
      PICT "@S20"
   READ
   BoxC()

   IF LastKey() == K_ESC
      nRet := 0
   ENDIF

   RETURN nRet


// ----------------------------------
// napuni export tabelu
// ----------------------------------
STATIC FUNCTION fill_export_table( dD_f, dD_t, cId_f, cId_td )

   LOCAL cFilt := ""
   LOCAL cIdFirma
   LOCAL cIdTipDok
   LOCAL cBrDok
   LOCAL cIdRoba
   LOCAL nCount := 0

   O_R_EXP
   O_ROBA
   O_FAKT_DOKS
   O_FAKT

   IF !Empty( cId_f )
      cFilt += Parsiraj( AllTrim( cId_f ), "idfirma", "C" )
   ENDIF

   IF !Empty( cId_td )
      IF !Empty( cFilt )
         cFilt += " .and. "
      ENDIF
      cFilt += Parsiraj( AllTrim( cId_td ), "idtipdok", "C" )
   ENDIF



   SELECT fakt
   SET ORDER TO TAG "1"

   IF !Empty( cFilt )
      SET FILTER to &cFilt
      GO TOP
   ENDIF

   DO WHILE !Eof()

      // provjeri datum
      IF ( field->datdok < dD_f .OR. field->datdok > dD_t )
         SKIP
         LOOP
      ENDIF

      cIdFirma := field->idfirma
      cIdTipDok := field->idtipdok
      cBrDok := field->brdok
      cIdRoba := field->idroba

      // pozicioniraj se na doks
      SELECT fakt_doks
      SEEK cIdFirma + cIdTipdok + cBrDok

      SELECT r_export
      APPEND BLANK

      ++ nCount

      REPLACE idfirma WITH fakt->idfirma
      REPLACE idtipdok WITH fakt->idtipdok
      REPLACE brdok WITH fakt->brdok
      REPLACE datdok WITH fakt->datdok
      REPLACE idpartner WITH fakt_doks->idpartner
      REPLACE idroba WITH fakt->idroba
      REPLACE kolicina WITH fakt->kolicina
      REPLACE cijena WITH fakt->cijena
      REPLACE rabat WITH fakt->rabat

      IF fakt->( FieldPos( "IDRELAC" ) ) <> 0
         REPLACE idrel WITH fakt->idrelac
      ENDIF

      SELECT fakt
      SKIP
   ENDDO

   IF nCount > 0
      msgbeep( "Exportovao " + AllTrim( Str( nCount ) ) + " zapisa u R_EXP.DBF !" )
   ENDIF

   RETURN


