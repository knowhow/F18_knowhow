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


FUNCTION CjenR()

   PRIVATE cKomLin

   IF Pitanje(, "Formiranje cjenovnika ?", "N" ) == "N"
      RETURN DE_CONT
   ENDIF

   SELECT ROBA
   SELECT ( F_BARKOD )

   IF !Used()
      O_BARKOD
   ENDIF
   SELECT BARKOD
   zapp()

   SELECT roba
   GO TOP
   MsgO( "Priprema barkod.dbf za cjen" )

   cIniName := EXEPATH + 'ProIzvj.ini'

   // Iscita var Linija1 iz FMK.INI/KUMPATH u PROIZVJ.INI
   UzmiIzIni( cIniName, 'Varijable', 'Linija1', IzFmkIni( "Zaglavlje", "Linija1", gNFirma, KUMPATH ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', 'Linija2', IzFmkIni( "Zaglavlje", "Linija2", "-", KUMPATH ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', 'Linija3', IzFmkIni( "Zaglavlje", "Linija3", "-", KUMPATH ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', 'Linija4', IzFmkIni( "Zaglavlje", "Linija4", "-", KUMPATH ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', 'Linija5', IzFmkIni( "Zaglavlje", "Linija5", "-", KUMPATH ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', 'CjenBroj', IzFmkIni( "Zaglavlje", "CjenBroj", "-", KUMPATH ), 'WRITE' )
   cCjenIzbor := IzFmkIni( "Zaglavlje", "CjenIzbor", " ", KUMPATH )

   DO WHILE !Eof()
      SELECT BARKOD
      APPEND BLANK
      REPLACE ID       WITH  roba->id,;
         NAZIV    WITH  Trim( Left( ROBA->naz, 40 ) ) + " (" + Trim( ROBA->jmj ) + ")",;
         VPC      WITH  ROBA->vpc, ;
         MPC      WITH  ROBA->mpc
      SELECT roba
      SKIP
   ENDDO
   MsgC()

   my_close_all_dbf()

   // Izbor cjenovnika  ( /M/V)

   PRIVATE cCjenBroj := Space( 15 )
   PRIVATE cCjenIzbor := " "

   BOX (, 4, 40 )
   @ m_x + 1, m_y + 2 SAY "Cjenovnik broj : " GET cCjenBroj
   @ m_x + 3, m_y + 2 SAY "Cjenovnik ( /M/V) : " GET cCjenIzbor VALID cCjenIzbor $ " MV"
   @ m_x + 4, m_y + 2 SAY "M - sa MPC,V - sa VPC,prazno - sve"
   READ
   boxc()

   UzmiIzIni( cIniName, 'Varijable', 'CjenBroj', cCjenBroj, 'WRITE' )
   UzmiIzIni( KUMPATH + 'FMK.INI', 'Zaglavlje', 'CjenBroj', cCjenBroj, 'WRITE' )
   UzmiIzIni( KUMPATH + 'FMK.INI', 'Zaglavlje', 'CjenIzbor', cCjenIzbor, 'WRITE' )

   IF LastKey() == K_ESC
      RETURN DE_CONT
   ENDIF

   f18_rtm_print( "cjen", "barkod", "id" )

   RETURN DE_CONT


// ------------------------------------------------------
// stampa rekapitulacije stara cijena -> nova cijena
// ------------------------------------------------------
FUNCTION rpt_zanivel()

   LOCAL nTArea := Select()
   LOCAL cZagl
   LOCAL cLine
   LOCAL cRazmak := Space( 1 )
   LOCAL nCnt

   O_ROBA
   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   // ako ne postoji polje u robi, nista...
   IF roba->( FieldPos( "zanivel" ) ) == 0
      RETURN
   ENDIF

   cZagl := PadC( "R.br", 6 )
   cZagl += cRazmak
   cZagl += PadC( "ID", 10 )
   cZagl += cRazmak
   cZagl += PadC( "Naziv", 20 )
   cZagl += cRazmak
   cZagl += PadC( "Stara cijena", 15 )
   cZagl += cRazmak
   cZagl += PadC( "Nova cijena", 15 )

   cLine := Replicate( "-", Len( cZagl ) )

   START PRINT CRET

   ? "Pregled promjene cijena u sifrarniku robe"
   ?
   ? cLine
   ? cZagl
   ? cLine

   nCnt := 0

   DO WHILE !Eof()

      IF field->zanivel == 0
         SKIP
         LOOP
      ENDIF

      ++ nCnt

      ? PadL( Str( nCnt, 5 ) + ".", 6 ), PadR( field->id, 10 ), PadR( field->naz, 20 ), PadL( Str( field->mpc, 12, 2 ), 15 ), PadL( Str( field->zanivel, 12, 2 ), 15 )

      SKIP

   ENDDO

   FF
   ENDPRINT

   SELECT ( nTArea )

   RETURN
