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


FUNCTION ReklKase( dDOd, dDDo, cVarijanta )

   PRIVATE cIdPos := gIdPos
   PRIVATE dDatum0
   PRIVATE dDatum1
   PRIVATE cFilter := ".t."

   SET CURSOR ON

   IF ( dDOd == nil )
      dDatum0 := gDatum
      dDatum1 := gDatum
   ELSE
      dDatum0 := dDOd
      dDatum1 := dDDo
   ENDIF

   IF ( cVarijanta == nil )
      cVarijanta := "0"
   ENDIF

   o_pos_tables()

   IF ( cVarijanta == "0" )
      cIdPos := gIdPos
   ELSE
      IF FrmRptVars( @cIdPos, @dDatum0, @dDatum1 ) == 0
         RETURN 0
      ENDIF
   ENDIF

   START PRINT CRET
   Zagl( dDatum0, dDatum1, cIdPos )

   SELECT ( F_POS_DOKS )
   IF !Used()
      o_pos_doks()
   ENDIF
   SetFilter( @cFilter, cIdPos, dDatum0, dDatum1 )

   nCnt := 0
   ? "----------------------------------------"
   ? "Rbr  Datum     BrDok           Iznos"
   ? "----------------------------------------"
   GO TOP

   DO WHILE !Eof() .AND. idvd == VD_REK
      ++ nCnt
      ? Str( nCnt, 3 )
      ?? Space( 2 ) + DToC( field->datum )
      ?? Space( 2 ) + PadR( AllTrim( field->idvd ) + "-" +  AllTrim( field->brdok ), 10 )
      ?? Space( 2 ) + pos_iznos_dokumenta( .T., field->idpos, field->idvd, field->datum, field->brdok )
      SKIP
   ENDDO

   ENDPRINT

   my_close_all_dbf()

   RETURN .T.


/* FrmRptVars(cIdPos, dDatum0, dDatum1)
 *     Uzmi varijable potrebne za izvjestaj
 *  \return 0 - nije uzeo, 1 - uzeo uspjesno
 */
STATIC FUNCTION FrmRptVars( cIdPos, dDatum0, dDatum1 )


   LOCAL aNiz

   aNiz := {}
   cIdPos := gIdPos

   IF gVrstaRS <> "K"
      AAdd( aNiz, { "Prod. mjesto (prazno-sve)", "cIdPos", "cidpos='X'.or.EMPTY(cIdPos) .or. p_pos_kase(@cIdPos)", "@!", } )
   ENDIF

   AAdd( aNiz, { "Izvjestaj se pravi od datuma", "dDatum0",,, } )
   AAdd( aNiz, { "                   do datuma", "dDatum1",,, } )

   DO WHILE .T.
      IF cVarijanta <> "1"  // onda nema read-a
         IF !VarEdit( aNiz, 6, 5, 24, 74, "USLOVI ZA IZVJESTAJ PREGLED REKLAMACIJA", "B1" )
            CLOSE ALL
            RETURN 0
         ENDIF
      ENDIF
   ENDDO

   RETURN 1



STATIC FUNCTION Zagl( dDatum0, dDatum1, cIdPos )


   ?? gP12CPI
   IF glRetroakt
      ? PadC( "REKLAMACIJE NA DAN " + FormDat1( dDatum1 ), 40 )
   ELSE
      ? PadC( "REKLAMACIJE NA DAN " + FormDat1( gDatum ), 40 )
   ENDIF
   ? PadC( "-------------------------------------", 40 )

  // o_pos_kase()
   IF Empty( cIdPos )
      ? "PRODAJNO MJESTO: SVA"
   ELSE
      ? "PRODAJNO MJESTO: " + cIdPos + "-" + find_pos_kasa_naz( cIdPos )
   ENDIF

   ? "PERIOD     : " + FormDat1( dDatum0 ) + " - " + FormDat1( dDatum1 )

   RETURN .T.


STATIC FUNCTION SetFilter( cFilter, cIdPos, dDatum0, dDatum1 )

   // {

   SELECT pos_doks
   SET ORDER TO TAG "2"  // "2" - "IdVd+DTOS (Datum)+Smjena"

   cFilter += " .and. idvd == '98' .and. sto <> 'P   ' "
   cFilter += " .and. idpos == '" + cIdPos + "'"
   IF ( dDatum0 <> nil )
      cFilter += " .and. datum >= " + dbf_quote( dDatum0 )
   ENDIF
   IF ( dDatum1 <> nil )
      cFilter += " .and. datum <= " + dbf_quote( dDatum1 )
   ENDIF

   IF !( cFilter == ".t." )
      SET FILTER TO &cFilter
   ENDIF

   RETURN
// }

STATIC FUNCTION TblCrePom()

   LOCAL aDbf := {}

   AAdd( aDbf, { "IdPos","C",  2, 0 } )
   AAdd( aDbf, { "IdRadnik","C",  4, 0 } )
   AAdd( aDbf, { "IdVrsteP","C",  2, 0 } )
   AAdd( aDbf, { "IdOdj","C",  2, 0 } )
   AAdd( aDbf, { "IdRoba","C", 10, 0 } )
   AAdd( aDbf, { "IdCijena","C",  1, 0 } )
   AAdd( aDbf, { "Kolicina","N", 12, 3 } )
   AAdd( aDbf, { "Iznos","N", 20, 5 } )
   AAdd( aDbf, { "Iznos2","N", 20, 5 } )
   AAdd( aDbf, { "Iznos3","N", 20, 5 } )
   AAdd( aDbf, { "K1","C",  4, 0 } )
   AAdd( aDbf, { "K2","C",  4, 0 } )

   pos_cre_pom_dbf( aDbf )

   SELECT ( F_POM )
   IF Used()
      USE
   ENDIF
   my_use_temp( "POM", my_home() + "pom", .F., .T. )

   INDEX on ( IdPos + IdRadnik + IdVrsteP + IdOdj + IdRoba + IdCijena ) TAG "1"
   INDEX on ( IdPos + IdOdj + IdRoba + IdCijena ) TAG "2"
   INDEX on ( IdPos + IdRoba + IdCijena ) TAG "3"
   INDEX on ( IdPos + IdVrsteP ) TAG "4"
   INDEX on ( IdPos + K1 + idroba ) TAG "K1"

   SET ORDER TO TAG "1"

   RETURN
