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



FUNCTION pos_pregled_racuna_tabela()

   LOCAL fScope := .T.
   LOCAL cFil0
   LOCAL cTekIdPos := gIdPos
   PRIVATE aVezani := {}
   PRIVATE dMinDatProm := CToD( "" )

   O_SIFK
   O_SIFV
   O_KASE
   O_ROBA
   O__POS_PRIPR
   o_pos_doks()
   o_pos_pos()

   dDatOd := Date()
   dDatDo := Date()

   qIdRoba := Space( Len( POS->idroba ) )

   SET CURSOR ON

   Box(, 2, 60 )
   @ m_x + 1, m_y + 2 SAY "Datumski period:" GET dDatOd
   @ m_x + 1, Col() + 2 SAY "-" GET dDatDo
   @ m_x + 2, m_y + 2 SAY "Prodajno mjesto:" GET gIdPos VALID P_Kase( @gIdPos )
   READ
   BoxC()

   IF LastKey() == K_ESC
      CLOSE ALL
      RETURN
   ENDIF

   cFil0 := ""

   IF !Empty( dDatOd ) .AND. !Empty( dDatDo )
      cFil0 := "datum >= " + _filter_quote( dDatOD ) + " .and. datum <= " + _filter_quote( dDatDo ) + " .and. "
   ENDIF

   pos_lista_racuna(,,, fScope, cFil0, qIdRoba )

   my_close_all_dbf()

   gIdPos := cTekIdPos

   RETURN
