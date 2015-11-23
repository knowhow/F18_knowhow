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

STATIC _f18_delphi_exe := "f18_delphirb.exe"
STATIC _f18_label_exe := "f18_labeliranje.exe"


// ------------------------------------------------------------
// stampa rtm reporta kroz delphirb
//
// - rtm_file - naziv rtm fajla
// - table_name - naziv tabele koju otvara
// - table_index - naziv indeksa koji otvara tabelu
// - test_mode .t. ili .f., default .f. - testni rezim komande
// ------------------------------------------------------------
FUNCTION f18_rtm_print( rtm_file, table_name, table_index, test_mode, rtm_mode )

   LOCAL _cmd
   LOCAL _ok := .F.
   LOCAL _delphi_exe := "delphirb.exe"
   LOCAL _label_exe := "labeliranje.exe"
   LOCAL _util_path
   LOCAL _error

#ifdef __PLATFORM__UNIX

   _f18_delphi_exe := "delphirb"
   _f18_label_exe := "labeliranje"
#endif

#ifdef __PLATFORM__LINUX
   my_close_all_dbf()
#endif

   // provjera uslova

   IF ( rtm_file == NIL )
      MsgBeep( "Nije zadat rtm fajl !!!" )
      RETURN _ok
   ENDIF

   IF ( table_name == NIL )
      table_name := ""
   ENDIF

   IF ( table_index == NIL )
      table_index := ""
   ENDIF

   IF ( test_mode == NIL )
      test_mode := .F.
   ENDIF

   IF ( rtm_mode == NIL )
      rtm_mode := "drb"
   ENDIF

   // provjeri treba li kopirati delphirb.exe ?
   IF !copy_delphirb_exe( rtm_mode )
      // sigurno ima neka greska... pa izadji
      RETURN _ok
   ENDIF

   // provjeri treba li kopirati template fajl
   IF !copy_rtm_template( rtm_file )
      // sigurno postoji opet neka greska...
      RETURN _ok
   ENDIF

   // ovdje treba kod za filovanje datoteke IZLAZ.DBF
   IF Pitanje(, "Stampati delphirb report ?", "D" ) == "N"
      // ne zelimo stampati report...
      RETURN _ok
   ENDIF

   // idemo na slaganje komande za report

   _cmd := ""

#ifdef __PLATFORM__UNIX
   _cmd += SLASH + "opt" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
#endif

   IF rtm_mode == "drb"
      _cmd += _f18_delphi_exe
   ELSE
      _cmd += _f18_label_exe
   ENDIF

   _cmd += " "
   _cmd += rtm_file
   _cmd += " "

#ifdef __PLATFORM__WINDOWS
   _cmd += "." + SLASH
#else
   _cmd += my_home()
#endif

   IF !Empty( table_name )

      // dodaj i naziv tabele i index na komandu
      _cmd += " "
      _cmd += table_name
      _cmd += " "
      _cmd += table_index

   ENDIF

#ifdef __PLATFORM__UNIX
   _cmd += " "
   _cmd += "&"
#endif

#ifdef __PLATFORM__WINDOWS
   IF test_mode
      _cmd += " & pause"
   ENDIF
#endif

   // pozicioniraj se na home direktorij tokom izvrsenja
   DirChange( my_home() )

   log_write( "delphirb/label print, cmd: " + _cmd, 7 )

   _error := f18_run( _cmd )

   IF _error <> 0
      MsgBeep( "Postoji problem sa stampom#Greska: " + AllTrim( Str( _error ) ) )
      RETURN _ok
   ENDIF

   // sve je ok
   _ok := .T.

   RETURN _ok



// --------------------------------------------------
// kopira delphirb.exe u home/f18_delphirb.exe
// --------------------------------------------------
STATIC FUNCTION copy_delphirb_exe( mode )

   LOCAL _ok := .T.
   LOCAL _util_path
   LOCAL _drb := "delphirb.exe"
   LOCAL _lab := "labeliranje.exe"
   LOCAL _exe, _tmp

   IF mode == NIL
      mode := "drb"
   ENDIF

   IF mode == "drb"
      _exe := _f18_delphi_exe
      _tmp := _drb
   ELSE
      _exe := _f18_label_exe
      _tmp := _lab
   ENDIF

   // util path...
#ifdef __PLATFORM__WINDOWS
   _util_path := "c:" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
#else
   _util_path := SLASH + "opt" + SLASH + "knowhowERP" + SLASH + "util" + SLASH

   RETURN _ok
#endif

// kopiraj delphirb u home path
IF !File( my_home() + _exe )
IF !File( _util_path + _tmp )
MsgBeep( "Fajl " + _util_path + _tmp + " ne postoji !????" )
_ok := .F.
RETURN _ok
ELSE
FileCopy( _util_path + _tmp, my_home() + _exe )
ENDIF
ENDIF

   RETURN _ok


// ---------------------------------------------------------
// kopiranje template fajla u home direktorij
//
// napomena: template = "nalplac", bez ekstenzije
// ---------------------------------------------------------
STATIC FUNCTION copy_rtm_template( template )

   LOCAL _ret := .F.
   LOCAL _rtm_ext := ".rtm"
   LOCAL _a_source, _a_template
   LOCAL _src_size, _src_date, _src_time
   LOCAL _temp_size, _temp_date, _temp_time
   LOCAL _copy := .F.

   IF !File( my_home() + template + _rtm_ext )
      _copy := .T.
   ELSE

      // fajl postoji na lokaciji
      // ispitaj velicinu, datum vrijeme...
      _a_source := Directory( my_home() + template + _rtm_ext )
      _a_template := Directory( F18_TEMPLATE_LOCATION + template + _rtm_ext )

      // datum, vrijeme, velicina
      _src_size := AllTrim( Str( _a_source[ 1, 2 ] ) )
      _src_date := DToS( _a_source[ 1, 3 ] )
      _src_time := _a_source[ 1, 4 ]

      _temp_size := AllTrim( Str( _a_template[ 1, 2 ] ) )
      _temp_date := DToS( _a_template[ 1, 3 ] )
      _temp_time := _a_template[ 1, 4 ]

      // treba ga kopirati
      IF _temp_date + _temp_time > _src_date + _src_time
         _copy := .T.
      ENDIF

   ENDIF

   // treba ga kopirati
   IF _copy

      IF !File( F18_TEMPLATE_LOCATION + template + _rtm_ext )
         MsgBeep( "Fajl " + F18_TEMPLATE_LOCATION + template + _rtm_ext + " ne postoji !????" )
         RETURN _ret
      ELSE
         FileCopy( F18_TEMPLATE_LOCATION + template + _rtm_ext, my_home() + template + _rtm_ext )
      ENDIF

   ENDIF

   _ret := .T.

   RETURN _ret
