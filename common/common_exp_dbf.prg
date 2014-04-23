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


#include "fmk.ch"

STATIC __table := "r_export"
STATIC cij_decimala := 3
STATIC izn_decimala := 2
STATIC kol_decimala := 3
STATIC lZaokruziti := .T.
STATIC cLauncher1 := '"C:\Program Files\LibreOffice 3.4\program\scalc.exe"'
// zamjeniti tarabu sa brojem
STATIC cLauncher2 := ""
STATIC cLauncher := "oo"
// 4 : 852 => US ASCII
STATIC cKonverzija := "4"



// kreiraj tabelu u home direktoriju
FUNCTION t_exp_create( field_list )

   my_close_all_dbf()

   FErase( my_home() + __table + ".dbf" )

   // kreiraj tabelu
   dbcreate2( my_home() + __table, field_list )

   RETURN


// export tabele
FUNCTION tbl_export( launch )

   LOCAL _cmd

   my_close_all_dbf()

   _cmd := AllTrim( launch )
   _cmd += " "
   _cmd += __table + ".dbf"

   log_write( "Export " + __table + " cmd: " + _cmd, 9 )

   MsgBeep( "Tabela " + my_home() + __table + ".dbf" + "je formirana##" + ;
      "Sa opcijom Open file se ova tabela ubacuje u excel #" + ;
      "Nakon importa uradite Save as, i odaberite format fajla XLS ! ##" + ;
      "Tako dobijeni xls fajl mozete mijenjati #" + ;
      "prema svojim potrebama ..." )

   IF Pitanje(, "Odmah pokrenuti spreadsheet aplikaciju ?", "D" ) == "D"
      DirChange( my_home() )
      IF f18_run( _cmd ) <> 0
         MsgBeep( "Problem sa pokretanjem ?!!!" )
      ENDIF
   ENDIF

   RETURN


// -----------------------------------------------------
// setovanje pokretaca za dbf tabelu
// -----------------------------------------------------
FUNCTION set_launcher( launch )

   LOCAL _tmp

   _tmp = Upper( AllTrim( launch ) )

   IF ( _tmp == "OO" ) .OR.  ( _tmp == "OOO" ) .OR.  ( _tmp == "OPENOFFICE" )
      launch := cLauncher1
      RETURN .F.

   ELSEIF ( Left( _tmp, 6 ) == "OFFICE" )
      // OFFICEXP, OFFICE97, OFFICE2003
      launch := msoff_start( SubStr( _tmp, 7 ) )
      RETURN .F.
   ELSEIF ( Left( _tmp, 5 ) == "EXCEL" )
      // EXCELXP, EXCEL97
      launch := msoff_start( SubStr( _tmp, 6 ) )
      RETURN .F.
   ENDIF

   RETURN .T.




STATIC FUNCTION msoff_start( ver )

   LOCAL _tmp :=  '"C:\Program Files\Microsoft Office\Office#\excel.exe"'

   IF ( ver == "XP" )
      // office XP
      RETURN StrTran( _tmp,  "#", "10" )
   ELSEIF ( ver == "2000" )
      // office 2000
      RETURN StrTran( _tmp, "#", "9" )
   ELSEIF ( Empty( ver ) )
      // instalacija office u /office/ direktoriju
      RETURN StrTran( _tmp, "#", "" )
   ELSEIF ( ver == "2003" )
      // office 2003
      RETURN StrTran( _tmp, "#", "11" )
   ELSEIF ( ver == "97" )
      // office 97
      RETURN StrTran( _tmp, "#", "8" )
   ELSE
      // office najnoviji 2005?2006
      RETURN StrTran( _tmp, "#", "12" )
   ENDIF

   RETURN




// export funkcija
FUNCTION exp_report()

   LOCAL nTArea := Select()

   cKonverzija := fetch_metric( "export_dbf_konverzija", my_user(), cKonverzija )
   cLauncher := fetch_metric( "export_dbf_launcher", my_user(), cLauncher )
   cLauncher := PadR( cLauncher, 70 )

   Box(, 10, 70 )
   @ m_x + 1, m_y + 2 SAY "Parametri exporta:" COLOR "I"

   @ m_x + 2, m_y + 2  SAY "Konverzija slova (0-8) " GET cKonverzija PICT "9"

   @ m_x + 3, m_y + 2 SAY "Pokreni oo/office97/officexp/office2003 ?" GET cLauncher PICT "@S26" VALID set_launcher( @cLauncher )

   READ
   BoxC()

   IF LastKey() == K_ESC
      SELECT ( nTArea )
      closeret
   ENDIF

   // snimi parametre
   set_metric( "export_dbf_konverzija", my_user(), cKonverzija )
   set_metric( "export_dbf_launcher", my_user(), cLauncher )

   SELECT ( nTArea )

   RETURN cLauncher
