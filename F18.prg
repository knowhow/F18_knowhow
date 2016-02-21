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


STATIC __relogin_opt := .F.

#ifndef TEST

FUNCTION Main( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11 )

   LOCAL _arg_v := hb_Hash()
   PUBLIC gDebug := 9

   cre_arg_v_hash( @_arg_v, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11 )
   set_f18_params( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11 )
   f18_init_app( _arg_v )

   RETURN .T.

#endif


// vraca hash matricu sa parametrima
STATIC FUNCTION cre_arg_v_hash( hash )

   LOCAL _i := 2
   LOCAL _param
   LOCAL _count := 0

   hash := hb_Hash()
   hash[ "p1" ] := NIL
   hash[ "p2" ] := NIL
   hash[ "p3" ] := NIL
   hash[ "p4" ] := NIL
   hash[ "p5" ] := NIL
   hash[ "p6" ] := NIL
   hash[ "p7" ] := NIL
   hash[ "p8" ] := NIL
   hash[ "p9" ] := NIL
   hash[ "p10" ] := NIL
   hash[ "p11" ] := NIL

   DO WHILE _i <= PCount()
      // ucitaj parametar
      _param := hb_PValue( _i++ )
      // p1, p2, p3...
      hash[ "p" + AllTrim( Str( ++_count ) ) ] := _param
   ENDDO

   RETURN .T.




FUNCTION program_module_menu( arg_v )

   LOCAL menuop := {}
   LOCAL menuexec := {}
   LOCAL mnu_choice
   LOCAL mnu_left := 2
   LOCAL mnu_top := 5
   LOCAL mnu_bottom := 23
   LOCAL mnu_right := 65
   LOCAL _x := 1
   LOCAL _db_params
   LOCAL _count := 0
   LOCAL oBackup := F18Backup():New()
   LOCAL _user_roles := f18_user_roles_info()
   LOCAL _server_db_version := get_version_str( server_db_version() )
   LOCAL _tmp
   LOCAL _color := "BG+/B"

   info_bar( "init", "gen program_module_menu start" )
   IF arg_v == NIL
      // napravi NIL parametre
      cre_arg_v_hash( @arg_v )
   ENDIF

   DO WHILE .T.

      ++ _count

      CLEAR SCREEN
      _db_params := my_server_params()

      _x := 1
      @ _x, mnu_left + 1 SAY8 "Tekuća baza: " + AllTrim( _db_params[ "database" ] ) + " / db ver: " + _server_db_version + " / nivo logiranja: " + AllTrim( Str( log_level() ) )

      ++ _x
      @ _x, mnu_left + 1 SAY "   Korisnik: " + AllTrim( _db_params[ "user" ] ) + "   u grupama " + _user_roles

      ++ _x
      @ _x, mnu_left SAY Replicate( "-", 55 )

      // backup okidamo samo na prvom ulasku
      // ili na opciji relogina
      IF _count == 1 .OR. __relogin_opt

         // provjera da li je backup locked ?
         IF oBackup:locked( .F. )
            oBackup:unlock()
         ENDIF

         // automatski backup podataka preduzeca
         f18_auto_backup_data( 1 )
         __relogin_opt := .F.

      ENDIF

      // resetuj...
      menuop := {}
      menuexec := {}


      set_program_module_menu( @menuop, @menuexec, arg_v[ "p3" ], arg_v[ "p4" ], arg_v[ "p5" ], arg_v[ "p6" ], arg_v[ "p7" ] )

      info_bar( "init", "gen program_module_menu end" )

      mnu_choice := ACHOICE2( mnu_top, mnu_left, mnu_bottom, mnu_right, menuop, .T., "MenuFunc", 1 )

      DO CASE
      CASE mnu_choice == 0

         IF !oBackup:locked
            EXIT
         ELSE
            MsgBeep( oBackup:backup_in_progress_info() )
         ENDIF

      CASE mnu_choice > 0
         IF mnu_choice <= Len( menuexec )
            Eval( menuexec[ mnu_choice ] )
         ENDIF
      ENDCASE

      LOOP

   ENDDO

   info_bar( _db_params[ "database" ], "program_module_menu end" )

   RETURN .T.



STATIC FUNCTION set_program_module_menu( menuop, menuexec, p3, p4, p5, p6, p7 )

   LOCAL _count := 0
   LOCAL cMenuBrojac

   IF f18_use_module( "fin" )
      cMenuBrojac := PadL( AllTrim( Str( ++_count ) ), 2 )
      AAdd( menuop, cMenuBrojac + ". FIN   # finansijsko poslovanje                 " )
      AAdd( menuexec, {|| MainFin( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
   ENDIF

   IF f18_use_module( "kalk" )
      cMenuBrojac := PadL( AllTrim( Str( ++_count ) ), 2 )
      AAdd( menuop, cMenuBrojac + ". KALK  # robno-materijalno poslovanje" )
      AAdd( menuexec, {|| MainKalk( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
   ENDIF

   IF f18_use_module( "fakt" )
      cMenuBrojac := PadL( AllTrim( Str( ++_count ) ), 2 )
      AAdd( menuop, cMenuBrojac + ". FAKT  # fakturisanje" )
      AAdd( menuexec, {|| MainFakt( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
   ENDIF

   IF f18_use_module( "epdv" )
      cMenuBrojac := PadL( AllTrim( Str( ++_count ) ), 2 )
      AAdd( menuop, cMenuBrojac + ". ePDV  # elektronska evidencija PDV-a" )
      AAdd( menuexec, {|| MainEpdv( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
   ENDIF

   IF f18_use_module( "ld" )
      cMenuBrojac := PadL( AllTrim( Str( ++_count ) ), 2 )
      AAdd( menuop, cMenuBrojac + ". LD    # obračun plata" )
      AAdd( menuexec, {|| MainLd( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
   ENDIF


   IF f18_use_module( "os" )
      cMenuBrojac := PadL( AllTrim( Str( ++_count ) ), 2 )
      AAdd( menuop, cMenuBrojac + ". OS/SII# osnovna sredstva i sitan inventar" )
      AAdd( menuexec, {|| MainOs( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
   ENDIF

   IF f18_use_module( "virm" )
      cMenuBrojac := PadL( AllTrim( Str( ++_count ) ), 2 )
      AAdd( menuop, cMenuBrojac + ". VIRM  # virmani" )
      AAdd( menuexec, {|| MainVirm( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
   ENDIF

#ifdef F18_RNAL
   IF f18_use_module( "rnal" )
      cMenuBrojac := PadL( AllTrim( Str( ++_count ) ), 2 )
      AAdd( menuop, cMenuBrojac + ". RNAL  # radni nalozi" )
      AAdd( menuexec, {|| MainRnal( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
   ENDIF
#endif

#ifdef F18_POS
   IF f18_use_module( "pos" )
      cMenuBrojac := PadL( AllTrim( Str( ++_count ) ), 2 )
      AAdd( menuop, cMenuBrojac + ". POS   # maloprodajna kasa" )
      AAdd( menuexec, {|| MainPos( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
   ENDIF
#endif


#ifdef F18_MAT
   IF f18_use_module( "mat" )
      cMenuBrojac := PadL( AllTrim( Str( ++_count ) ), 2 )
      AAdd( menuop, cMenuBrojac + ". MAT   # materijalno" )
      AAdd( menuexec, {|| MainMat( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
   ENDIF
#endif

#ifdef F18_KADEV
   IF f18_use_module( "kadev" )
      cMenuBrojac := PadL( AllTrim( Str( ++_count ) ), 2 )
      AAdd( menuop, cMenuBrojac + ". KADEV  # kadrovska evidencija" )
      AAdd( menuexec, {|| MainKadev( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
   ENDIF
#endif

   IF f18_use_module( "reports" )
      cMenuBrojac := PadL( AllTrim( Str( ++_count ) ), 2 )
      AAdd( menuop, cMenuBrojac + ". REPORTS  # izvještajni modul" )
      AAdd( menuexec, {|| MainReports( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
   ENDIF


   AAdd( menuop, "---------------------------------------------" )
   AAdd( menuexec, {|| NIL } )


   AAdd( menuop, " S. promjena sezone" )
   AAdd( menuexec, {|| f18_promjena_sezone() } )
   AAdd( menuop, " B. backup podataka" )
   AAdd( menuexec, {|| f18_backup_data() } )

  /* TODO: izbaciti
   AAdd( menuop, " F. forsirana sinhronizacija podataka" )
   AAdd( menuexec, {|| F18AdminOpts():New():force_synchro_db() } )
   */

   AAdd( menuop, " P. parametri aplikacije" )
   AAdd( menuexec, {|| set_parametre_f18_aplikacije() } )
   AAdd( menuop, " W. pregled log-a" )
   AAdd( menuexec, {|| f18_view_log() } )

   AAdd( menuop, " V. vpn podrška" )
   AAdd( menuexec, {|| vpn_support() } )

   RETURN .T.


FUNCTION hb_SendMail( ... )
   RETURN tip_MailSend( ... )
