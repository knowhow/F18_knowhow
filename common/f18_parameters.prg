/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


// parametri aplikacije
FUNCTION set_parametre_f18_aplikacije( just_set )

   LOCAL _x := 1
   LOCAL _pos_x
   LOCAL _pos_y
   LOCAL _left := 20
   LOCAL _fin, _kalk, _fakt, _epdv, _virm, _ld, _os, _rnal, _mat, _reports, _kadev
   LOCAL _pos
   LOCAL _email_server, _email_port, _email_username, _email_userpass, _email_from
   LOCAL _email_to, _email_cc
   LOCAL _proper_name, _params
   LOCAL _log_delete_interval
   LOCAL _backup_company, _backup_server
   LOCAL _backup_removable, _backup_ping_time
   LOCAL _rpt_page_len, _bug_report
   LOCAL _log_level

   info_bar( "init", "set_parametre_f18_aplikacije - start" )

   _fin := fetch_metric( "main_menu_fin", my_user(), "D" )
   _kalk := fetch_metric( "main_menu_kalk", my_user(), "D" )
   _fakt := fetch_metric( "main_menu_fakt", my_user(), "D" )
   _ld := fetch_metric( "main_menu_ld", my_user(), "N" )
   _epdv := fetch_metric( "main_menu_epdv", my_user(), "N" )
   _virm := fetch_metric( "main_menu_virm", my_user(), "N" )
   _os := fetch_metric( "main_menu_os", my_user(), "N" )
   _rnal := fetch_metric( "main_menu_rnal", my_user(), "N" )
   _mat := fetch_metric( "main_menu_mat", my_user(), "N" )
   _pos := fetch_metric( "main_menu_pos", my_user(), "N" )
   _reports := fetch_metric( "main_menu_reports", my_user(), "N" )
   _kadev := fetch_metric( "main_menu_kadev", my_user(), "N" )

   _email_server := PadR( fetch_metric( "email_server", my_user(), "" ), 100 )
   _email_port := fetch_metric( "email_port", my_user(), 25 )
   _email_username := PadR( fetch_metric( "email_user_name", my_user(), "" ), 100 )
   _email_userpass := PadR( fetch_metric( "email_user_pass", my_user(), "" ), 50 )
   _email_from := PadR( fetch_metric( "email_from", my_user(), "" ), 100 )
   _email_to := PadR( fetch_metric( "email_to_default", my_user(), "" ), 500 )
   _email_cc := PadR( fetch_metric( "email_cc_default", my_user(), "" ), 500 )

   _proper_name := PadR( fetch_metric( "my_proper_name", my_user(), "" ), 50 )

   _log_delete_interval := fetch_metric( "log_delete_level", NIL, 30 )

   _backup_company := fetch_metric( "backup_company_interval", my_user(), 0 )
   _backup_server := fetch_metric( "backup_server_interval", my_user(), 0 )
   _backup_removable := PadR( fetch_metric( "backup_removable_drive", my_user(), "" ), 300 )

#ifdef __PLATFORM__WINDOWS
   _backup_ping_time := fetch_metric( "backup_windows_ping_time", my_user(), 0 )
#else
   _backup_ping_time := 0
#endif

   _rpt_page_len := fetch_metric( "rpt_duzina_stranice", my_user(), RPT_PAGE_LEN )
   _bug_report := fetch_metric( "bug_report_email", my_user(), "A" )
   _log_level := fetch_metric( "log_level", NIL, 3 )

   IF just_set == nil
      just_set := .F.
   ENDIF

   IF !just_set

      CLEAR SCREEN
      ?
      _pos_x := 2
      _pos_y := 3

      @ _pos_x, _pos_y SAY "Odabir modula za glavni meni ***" COLOR "I"

      @ _pos_x + _x, _pos_y SAY Space( 2 ) + "FIN:" GET _fin PICT "@!"
      @ _pos_x + _x, Col() + 1 SAY "KALK:" GET _kalk PICT "@!"
      @ _pos_x + _x, Col() + 1 SAY "FAKT:" GET _fakt PICT "@!"
      @ _pos_x + _x, Col() + 1 SAY "ePDV:" GET _epdv PICT "@!"
      @ _pos_x + _x, Col() + 1 SAY "LD:" GET _ld PICT "@!"
      @ _pos_x + _x, Col() + 1 SAY "VIRM:" GET _virm PICT "@!"

      ++ _x
      @ _pos_x + _x, _pos_y SAY Space( 2 ) + "OS/SII:" GET _os PICT "@!"
      @ _pos_x + _x, Col() + 1 SAY "POS:" GET _pos PICT "@!"
      @ _pos_x + _x, Col() + 1 SAY "MAT:" GET _mat PICT "@!"
      @ _pos_x + _x, Col() + 1 SAY "RNAL:" GET _rnal PICT "@!"
      @ _pos_x + _x, Col() + 1 SAY "KADEV:" GET _kadev PICT "@!"
      @ _pos_x + _x, Col() + 1 SAY "REPORTS:" GET _reports PICT "@!"

      ++ _x
      ++ _x
      @ _pos_x + _x, _pos_y SAY "Maticni podaci korisnika ***" COLOR "I"

      ++ _x
      ++ _x
      @ _pos_x + _x, _pos_y SAY PadL( "Puno ime i prezime:", _left ) GET _proper_name PICT "@S30"

      ++ _x
      ++ _x
      @ _pos_x + _x, _pos_y SAY "Email parametri ***" COLOR "I"

      ++ _x
      @ _pos_x + _x, _pos_y SAY PadL( "email server:", _left ) GET _email_server PICT "@S30"
      @ _pos_x + _x, Col() + 1 SAY "port:" GET _email_port PICT "9999"
      ++ _x
      @ _pos_x + _x, _pos_y SAY PadL( "username:", _left ) GET _email_username PICT "@S30"
      @ _pos_x + _x, Col() + 1 SAY "password:" GET _email_userpass PICT "@S30" COLOR "BG/BG"
      ++ _x
      @ _pos_x + _x, _pos_y SAY PadL( "moja email adresa:", _left ) GET _email_from PICT "@S40"
      ++ _x
      @ _pos_x + _x, _pos_y SAY PadL( "slati postu na adrese:", _left ) GET _email_to PICT "@S70"

      ++ _x
      @ _pos_x + _x, _pos_y SAY PadL( "cc adrese:", _left ) GET _email_cc PICT "@S70"

      ++ _x
      ++ _x
      @ _pos_x + _x, _pos_y SAY "Parametri log-a ***" COLOR "I"

      ++ _x
      @ _pos_x + _x, _pos_y SAY "Brisi stavke log tabele starije od broja dana (def. 30):" GET _log_delete_interval PICT "9999"

      ++ _x
      ++ _x
      @ _pos_x + _x, _pos_y SAY "Backup parametri ***" COLOR "I"

      ++ _x
      @ _pos_x + _x, _pos_y SAY "Automatski backup podataka preduzeca (interval dana 0 - ne radi nista):" GET _backup_company PICT "999"

      ++ _x
      @ _pos_x + _x, _pos_y SAY "Automatski backup podataka servera (interval 0 - ne radi nista):" GET _backup_server PICT "999"

      ++ _x
      @ _pos_x + _x, _pos_y SAY "Remote backup lokacija:" GET _backup_removable PICT "@S60"

#ifdef __PLATFORM__WINDOWS

      ++ _x
      @ _pos_x + _x, _pos_y SAY "Ping time kod backup komande:" GET _backup_ping_time PICT "99"

#endif

      ++ _x
      ++ _x
      @ _pos_x + _x, _pos_y SAY "Ostali parametri ***" COLOR "I"

      ++ _x
      @ _pos_x + _x, _pos_y SAY "Duzina stranice za izvjestaje ( def: 60 ):" GET _rpt_page_len PICT "999"

      ++ _x

      @ _pos_x + _x, _pos_y SAY "BUG report na email (D/N/A/0):" GET _bug_report PICT "!@" VALID _bug_report $ "DNA0"

      @ _pos_x + _x, Col() + 2 SAY "Nivo logiranja (0..9)" GET _log_level PICT "9" VALID _log_level >= 0 .AND. _log_level < 10

      READ

      IF LastKey() == K_ESC
         RETURN .F.
      ENDIF

      set_metric( "main_menu_fin", my_user(), _fin )
      set_metric( "main_menu_kalk", my_user(), _kalk )
      set_metric( "main_menu_fakt", my_user(), _fakt )
      set_metric( "main_menu_ld", my_user(), _ld )
      set_metric( "main_menu_virm", my_user(), _virm )
      set_metric( "main_menu_os", my_user(), _os )
      set_metric( "main_menu_epdv", my_user(), _epdv )
      set_metric( "main_menu_rnal", my_user(), _rnal )
      set_metric( "main_menu_mat", my_user(), _mat )
      set_metric( "main_menu_pos", my_user(), _pos )
      set_metric( "main_menu_kadev", my_user(), _kadev )
      set_metric( "main_menu_reports", my_user(), _reports )
      set_metric( "email_server", my_user(), AllTrim( _email_server ) )
      set_metric( "email_port", my_user(), _email_port )
      set_metric( "email_user_name", my_user(), AllTrim( _email_username ) )
      set_metric( "email_user_pass", my_user(), AllTrim( _email_userpass ) )
      set_metric( "email_from", my_user(), AllTrim( _email_from ) )
      set_metric( "email_to_default", my_user(), AllTrim( _email_to ) )
      set_metric( "email_cc_default", my_user(), AllTrim( _email_cc ) )
      set_metric( "my_proper_name", my_user(), AllTrim( _proper_name ) )
      set_metric( "log_delete_level", NIL, _log_delete_interval )
      set_metric( "backup_company_interval", my_user(), _backup_company )
      set_metric( "backup_server_interval", my_user(), _backup_server )
      set_metric( "backup_removable_drive", my_user(), AllTrim( _backup_removable ) )
      set_metric( "rpt_duzina_stranice", my_user(), _rpt_page_len )
      set_metric( "bug_report_email", my_user(), _bug_report )

      set_metric( "log_level", NIL, _log_level )
      log_level( _log_level )

#ifdef __PLATFORM__WINDOWS
      set_metric( "backup_windows_ping_time", my_user(), _backup_ping_time )
#endif

      info_bar( "init", "set_parametre_f18_aplikacije - end" )

   ENDIF

   RETURN .T.



/*
   Opis: ispituje da li je modul aktivan za tekućeg korisnika

   Usage: f18_use_module( 'kalk' ) => .T. ili .F.

   Params:
      module_name - naziv modula 'kalk', 'fin'
*/

FUNCTION f18_use_module( module_name )

   LOCAL _ret := .F.
   LOCAL _default := "N"

   IF module_name == "tops"
      module_name := "pos"
   ENDIF

   IF module_name $ "fin#kalk#fakt"
      _default := "D"
   ENDIF

   IF fetch_metric( "main_menu_" + module_name, my_user(), _default ) == "D"
      _ret := .T.
   ENDIF

   RETURN _ret



/*
   Opis: setuje modul kao aktivan ili ne za tekućeg korisnika

   Usage: f18_set_use_module( 'kalk', .T. ) => modul KALK za korisnika je aktivan

   Params:
       module_name - naziv modula 'kalk', 'fin'
       lset - .T. aktivan, .F. neaktivan
*/
FUNCTION f18_set_use_module( module_name, lset )

   LOCAL _ret := .F.
   LOCAL _set := "N"

   IF module_name == "tops"
      module_name := "pos"
   ENDIF

   IF lset == NIL
      lset := .T.
   ENDIF

   IF lset
      _set := "D"
   ENDIF

   set_metric( "main_menu_" + module_name, my_user(), _set )

   RETURN _ret



// ------------------------------------------------------------------------
// podesenje aktivnih modula kod startanja aplikacije po prvi put
// ------------------------------------------------------------------------
FUNCTION f18_set_active_modules()

   LOCAL _ok := .F.
   LOCAL _fin, _kalk, _fakt, _ld, _epdv, _virm, _os, _rnal, _pos, _mat, _reports, _kadev
   LOCAL _pos_x, _pos_y
   LOCAL _x := 1
   LOCAL _len := 8
   LOCAL _corr := "D"
   PRIVATE GetList := {}

   // parametri modula koristenih na glavnom meniju...
   _fin := fetch_metric( "main_menu_fin", my_user(), "D" )
   _kalk := fetch_metric( "main_menu_kalk", my_user(), "D" )
   _fakt := fetch_metric( "main_menu_fakt", my_user(), "D" )
   _ld := fetch_metric( "main_menu_ld", my_user(), "N" )
   _epdv := fetch_metric( "main_menu_epdv", my_user(), "N" )
   _virm := fetch_metric( "main_menu_virm", my_user(), "N" )
   _os := fetch_metric( "main_menu_os", my_user(), "N" )
   _rnal := fetch_metric( "main_menu_rnal", my_user(), "N" )
   _mat := fetch_metric( "main_menu_mat", my_user(), "N" )
   _pos := fetch_metric( "main_menu_pos", my_user(), "N" )
   _kadev := fetch_metric( "main_menu_kadev", my_user(), "N" )
   _reports := fetch_metric( "main_menu_reports", my_user(), "N" )

   Box(, 10, 70 )

   // 1
   @ m_x + _x, m_y + 2 SAY "*** Odabir modula za glavni meni ***" COLOR "I"

   ++ _x
   ++ _x

   // 3
   @ m_x + _x, m_y + 2 SAY hb_UTF8ToStr( "Prvi put pokrećete aplikaciju, potrebno odabrati module" )

   ++ _x

   // 4
   @ m_x + _x, m_y + 2 SAY hb_UTF8ToStr( "koji će se nakon sinhronizacije pojaviti na meniju" )

   ++ _x
   ++ _x

   // 6
   @ m_x + _x, m_y + 2 SAY PadL( "FIN:", _len ) GET _fin PICT "@!"
   @ m_x + _x, Col() + 1 SAY PadL( "KALK:", _len ) GET _kalk PICT "@!"
   @ m_x + _x, Col() + 1 SAY PadL( "FAKT:", _len ) GET _fakt PICT "@!"
   @ m_x + _x, Col() + 1 SAY PadL( "ePDV:", _len ) GET _epdv PICT "@!"
   @ m_x + _x, Col() + 1 SAY PadL( "LD:", _len ) GET _ld PICT "@!"
   @ m_x + _x, Col() + 1 SAY PadL( "VIRM:", _len ) GET _virm PICT "@!"

   ++ _x
   ++ _x

   // 8
   @ m_x + _x, m_y + 2 SAY PadL( "OS/SII:", _len ) GET _os PICT "@!"
   @ m_x + _x, Col() + 1 SAY PadL( "POS:", _len ) GET _pos PICT "@!"
   @ m_x + _x, Col() + 1 SAY PadL( "MAT:", _len ) GET _mat PICT "@!"
   @ m_x + _x, Col() + 1 SAY PadL( "RNAL:", _len ) GET _rnal PICT "@!"
   @ m_x + _x, Col() + 1 SAY PadL( "KADEV:", _len ) GET _kadev PICT "@!"
   @ m_x + _x, Col() + 1 SAY PadL( "REPORTS:", _len ) GET _reports PICT "@!"

   // 10

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Odabir korektan (D/N) ?" GET _corr VALID _corr $ "DN" PICT "@!"

   READ

   BoxC()

   IF LastKey() == K_ESC .OR. _corr == "N"
      RETURN _ok
   ENDIF

   // snimi parametre...
   set_metric( "main_menu_fin", my_user(), _fin )
   set_metric( "main_menu_kalk", my_user(), _kalk )
   set_metric( "main_menu_fakt", my_user(), _fakt )
   set_metric( "main_menu_ld", my_user(), _ld )
   set_metric( "main_menu_virm", my_user(), _virm )
   set_metric( "main_menu_os", my_user(), _os )
   set_metric( "main_menu_epdv", my_user(), _epdv )
   set_metric( "main_menu_rnal", my_user(), _rnal )
   set_metric( "main_menu_mat", my_user(), _mat )
   set_metric( "main_menu_pos", my_user(), _pos )
   set_metric( "main_menu_kadev", my_user(), _kadev )
   set_metric( "main_menu_reports", my_user(), _reports )

   RETURN _ok
