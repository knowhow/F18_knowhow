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


FUNCTION tekuci_modul()
   RETURN gModul

FUNCTION tekuca_sezona()
   RETURN my_server_params()[ "database" ]


FUNCTION start_f18_program_module( oApp, lSezone )

   LOCAL cImeDbf
   LOCAL _i

   gModul   := oApp:cName
   goModul  := oApp


   post_login()

   IF oApp:lTerminate
      RETURN .T.
   ENDIF


   //info_bar( oApp:cName, oApp:cName + " : start_program_module set global vars - start " )
   oApp:set_module_gvars()
   //info_bar( oApp:cName, oApp:cName + " : start_program_module set global vars - end" )

   pripremi_naslovni_ekran( oApp )
   crtaj_naslovni_ekran( .T. )
   show_insert_over_stanje()

   RETURN .T.



FUNCTION mpar37( x, oApp )

   // proslijedjeni su parametri
   lp3 := oApp:cP3
   lp4 := oApp:cP4
   lp5 := oApp:cP5
   lp6 := oApp:cP6
   lp7 := oApp:cP7

   RETURN ( ( lp3 <> NIL .AND. Upper( lp3 ) == x ) .OR. ( lp4 <> NIL .AND. Upper( lp4 ) == x ) .OR. ;
      ( lp5 <> NIL .AND. Upper( lp5 ) == x ) .OR. ( lp6 <> NIL .AND. Upper( lp6 ) == x ) .OR. ;
      ( lp7 <> NIL .AND. Upper( lp7 ) == x ) )



FUNCTION mpar37cnt( oApp )

   LOCAL nCnt := 0

   IF oApp:cP3 <> nil
      ++nCnt
   ENDIF
   IF oApp:cP4 <> nil
      ++nCnt
   ENDIF
   IF oApp:cP5 <> nil
      ++nCnt
   ENDIF
   IF oApp:cP6 <> nil
      ++nCnt
   ENDIF
   IF oApp:cP7 <> nil
      ++nCnt
   ENDIF

   RETURN nCnt


FUNCTION mparstring( oApp )

   LOCAL cPars

   cPars := ""

   IF oApp:cP3 <> NIL
      cPars += "'" + oApp:cP3 + "'"
   ENDIF
   IF oApp:cP4 <> NIL
      IF !Empty( cPars ); cPars += ", ";ENDIF
      cPars += "'" + oApp:cP4 + "'"
   ENDIF
   IF oApp:cP5 <> NIL
      IF !Empty( cPars ); cPars += ", ";ENDIF
      cPars += "'" + oApp:cP5 + "'"
   ENDIF
   IF oApp:cP6 <> NIL
      IF !Empty( cPars ); cPars += ", ";ENDIF
      cPars += "'" + oApp:cP6 + "'"
   ENDIF
   IF oApp:cP7 <> NIL
      IF !Empty( cPars ); cPars += ", ";ENDIF
      cPars += "'" + oApp:cP7 + "'"
   ENDIF

   RETURN cPars
