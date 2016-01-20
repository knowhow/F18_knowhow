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
#include "hbclass.ch"
#include "common.ch"


CLASS LDExportTxt

   METHOD New()
   METHOD params()
   METHOD export()

   METHOD export_setup()
   METHOD export_setup_read_params()
   METHOD export_setup_write_params()

   METHOD export_setup_duplicate()

   DATA export_params
   DATA formula_params

   PROTECTED:

   METHOD create_txt_from_dbf()
   METHOD _dbf_struct()
   METHOD create_export_dbf()
   METHOD fill_data_from_ld()
   METHOD get_export_line_macro()
   METHOD get_export_params()
   METHOD get_export_list()
   METHOD copy_existing_formula()

ENDCLASS



METHOD LDExportTxt:New()

   ::export_params := hb_Hash()
   ::formula_params := hb_Hash()

   RETURN SELF



// -----------------------------------------------------------
// struktura pomocne tabele
// -----------------------------------------------------------
METHOD LDExportTxt:_dbf_struct()

   LOCAL _dbf := {}
   LOCAL _i, _a_tmp
   LOCAL _dodatna_polja := ::export_params[ "dodatna_polja" ]

   // struktura...
   AAdd( _dbf, { "IDRJ", "C", 2, 0 } )
   AAdd( _dbf, { "OBR", "C", 1, 0 } )
   AAdd( _dbf, { "GODINA", "N", 4, 0 } )
   AAdd( _dbf, { "MJESEC", "N", 2, 0 } )
   AAdd( _dbf, { "IDRADN", "C", 6, 0 } )
   AAdd( _dbf, { "PUNOIME", "C", 50, 0 } )
   AAdd( _dbf, { "IME", "C", 30, 0 } )
   AAdd( _dbf, { "IMEROD", "C", 30, 0 } )
   AAdd( _dbf, { "PREZIME", "C", 40, 0 } )
   AAdd( _dbf, { "JMBG", "C", 13, 0 } )
   AAdd( _dbf, { "TEKRN", "C", 50, 0 } )
   AAdd( _dbf, { "KNJIZ", "C", 50, 0 } )
   AAdd( _dbf, { "IZNOS_1", "N", 15, 2 } )
   AAdd( _dbf, { "IZNOS_2", "N", 15, 2 } )
   AAdd( _dbf, { "KREDIT", "N", 15, 2 } )
   AAdd( _dbf, { "PARTIJA", "C", 50, 2 } )
   AAdd( _dbf, { "BANK_PART", "C", 50, 2 } )
   AAdd( _dbf, { "UNETO", "N", 15, 2 } )
   AAdd( _dbf, { "USATI", "N", 15, 2 } )

   IF !Empty( _dodatna_polja )
      _a_tmp := TokToNiz( _dodatna_polja, ";" )
      FOR _i := 1 TO Len( _a_tmp )
         IF !Empty( _a_tmp[ _i ] )
            AAdd( _dbf, { Upper( _a_tmp[ _i ] ), "N", 15, 2 } )
         ENDIF
      NEXT
   ENDIF

   RETURN _dbf


// -----------------------------------------------------------
// kreiranje pomocne tabele
// -----------------------------------------------------------
METHOD LDExportTxt:create_export_dbf()

   LOCAL _dbf
   LOCAL _table_name := "export"

   // struktura dbf-a
   _dbf := ::_dbf_struct()

   SELECT ( F_TMP_1 )
   USE

   FErase( my_home() + _table_name + ".dbf" )
   FErase( my_home() + _table_name + ".cdx" )

   dbCreate( my_home() + _table_name + ".dbf", _dbf )

   SELECT ( F_TMP_1 )
   USE
   my_use_temp( "EXP_BANK", my_home() + _table_name + ".dbf", .F., .F. )

   INDEX on ( punoime ) TAG "1"
   INDEX on ( jmbg ) TAG "2"

   RETURN .T.




// -----------------------------------------------------------
// parametri tekuceg exporta
// -----------------------------------------------------------

METHOD LDExportTxt:params()

   LOCAL _ok := .F.
   LOCAL _mjesec := gMjesec
   LOCAL _godina := gGodina
   LOCAL _rj := Space( 200 )
   LOCAL _name
   LOCAL _export := "D"
   LOCAL _obr := "1"
   LOCAL _file_name := PadR( "export_ld.txt", 50 )
   LOCAL _id_formula := fetch_metric( "ld_export_banke_tek", my_user(), 1 )
   LOCAL _x := 1
   LOCAL _dod_polja := PadR( fetch_metric( "ld_export_banke_dodatna_polja", my_user(), "" ), 500 )

   // citaj parametre
   O_KRED

   Box(, 16, 70 )

   @ m_x + _x, m_y + 2 SAY "Datumski period / mjesec:" GET _mjesec PICT "99"
   @ m_x + _x, Col() + 1 SAY "godina:" GET _godina PICT "9999"
   @ m_x + _x, Col() + 1 SAY "obracun:" GET _obr WHEN HelpObr( .T., _obr ) VALID ValObr( .T., _obr )

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Radna jedinica (prazno-sve):" GET _rj PICT "@S35"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Dodatna eksport polja (Sx, Ix):" GET _dod_polja PICT "@S32"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Tekuca formula eksporta (1 ... n):" GET _id_formula PICT "999" VALID ::get_export_params( @_id_formula )

   READ

   IF LastKey() == K_ESC
      ::export_params := NIL
      BoxC()
      RETURN _ok
   ENDIF

   _file_name := ::formula_params[ "file" ]
   _name := ::formula_params[ "name" ]

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY Replicate( "-", 60 )

   ++ _x

   @ m_x + _x, m_y + 2 SAY "  Odabrana varijanta: " + PadR( _name, 30 )

   ++ _x

   @ m_x + _x, m_y + 2 SAY "         Sifra banke: " + ::formula_params[ "banka" ]

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Naziv izlaznog fajla: " + PadR( _file_name, 20 )

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Eksportuj podatke (D/N)?" GET _export VALID _export $ "DN" PICT "@!"

   READ

   BoxC()

   IF LastKey() == K_ESC .OR. _export == "N"
      ::export_params := NIL
      RETURN _ok
   ENDIF

   // snimi parametre

   set_metric( "ld_export_banke_tek", my_user(), _id_formula )
   set_metric( "ld_export_banke_dodatna_polja", my_user(), AllTrim( _dod_polja ) )

   ::export_params := hb_Hash()
   ::export_params[ "mjesec" ] := _mjesec
   ::export_params[ "godina" ] := _godina
   ::export_params[ "obracun" ] := _obr
   ::export_params[ "rj" ] := _rj
   ::export_params[ "banka" ] := ::formula_params[ "banka" ]
   ::export_params[ "fajl" ] := _file_name
   ::export_params[ "formula" ] := _id_formula
   ::export_params[ "dodatna_polja" ] := _dod_polja
   ::export_params[ "separator" ] := ::formula_params[ "separator" ]
   ::export_params[ "separator_formula" ] := ::formula_params[ "separator_formula" ]
   ::export_params[ "kreditori" ] := ::formula_params[ "kreditori" ]
   ::export_params[ "krediti_export" ] := ( ::formula_params[ "krediti_export" ] == "D" )

   _ok := .T.

   RETURN _ok



// ----------------------------------------------------------
// kopiranje formule iz postojece formule
// ----------------------------------------------------------
METHOD LDExportTxt:copy_existing_formula( id_formula )

   LOCAL oExport := LDExportTxt():New()
   LOCAL _tmp
   PRIVATE GetList := {}

   IF Left( id_formula, 1 ) == "#"
      id_formula := StrTran( AllTrim( id_formula ), "#", "" )
   ELSE
      RETURN .T.
   ENDIF

   // uzmi postojecu formulu...
   IF oExport:get_export_params( Val( id_formula ) )

      _tmp := oExport:get_export_line_macro()

      IF !Empty( _tmp  )
         id_formula := PadR( _tmp, 500 )
      ELSE
         MsgBeep( "Zadata formula ne postoji !!!" )
      ENDIF

   ENDIF

   RETURN .T.




// -----------------------------------------------------------
// generisanje podataka u pomocnu tabelu iz sql-a
// -----------------------------------------------------------

METHOD LDExportTxt:fill_data_from_ld()

   LOCAL _ok := .F.
   LOCAL _qry, _table
   LOCAL _server := pg_server()
   LOCAL _count, _rec
   LOCAL _dod_polja := ::export_params[ "dodatna_polja" ]
   LOCAL _pro_polja, _a_polja, _i

   _pro_polja := ""

   IF !Empty( _dod_polja )

      _a_polja := TokToNiz( AllTrim( _dod_polja ), ";" )

      FOR _i := 1 TO Len( _a_polja )
         IF !Empty( _a_polja[ _i ] )
            _pro_polja += "ld."
            _pro_polja += Lower( _a_polja[ _i ] )
            _pro_polja += ","
         ENDIF
      NEXT

   ENDIF

   _qry := "SELECT " + ;
      " ld.godina, " + ;
      " ld.mjesec, " + ;
      " ld.obr, " + ;
      " ld.idrj, " + ;
      " ld.idradn, " + ;
      " rd.ime, " + ;
      " rd.imerod, " + ;
      " rd.naz, " + ;
      " rd.matbr AS jmbg, " + ;
      " rd.brtekr AS tekrn, " + ;
      " rd.brknjiz AS knjiz, " + ;
      _pro_polja + ;
      " ld.uneto, " + ;
      " ld.usati, " + ;
      " ld.uodbici, " + ;
      " ld.uiznos "

   if ::export_params[ "krediti_export" ]
      _qry += " , kr.placeno AS kredit, "
      _qry += " kr.naosnovu AS partija, "
      _qry += " kred.ziro AS bank_part "
   ENDIF

   _qry += " FROM fmk.ld_ld ld "
   _qry += " LEFT JOIN fmk.ld_radn rd ON ld.idradn = rd.id "

   if ::export_params[ "krediti_export" ]
      _qry += " LEFT JOIN fmk.ld_radkr kr ON ld.idradn = kr.idradn AND "
      _qry += "             ld.mjesec = kr.mjesec AND ld.godina = kr.godina "
      _qry += " LEFT JOIN fmk.kred kred ON kr.idkred = kred.id "
   ENDIF

   _qry += " WHERE ld.godina = " + AllTrim( Str( ::export_params[ "godina" ] ) )
   _qry += " AND ld.mjesec = " + AllTrim( Str( ::export_params[ "mjesec" ] ) )
   _qry += " AND ld.obr = " + _sql_quote( ::export_params[ "obracun" ] )
   _qry += " AND rd.isplata = " + _sql_quote( "TR" )

   IF !::export_params[ "krediti_export" ]
      _qry += " AND rd.idbanka = " + _sql_quote( ::export_params[ "banka" ] )
   ENDIF

   IF !Empty( ::export_params[ "rj" ] )
      _qry += " AND " + _sql_cond_parse( "ld.idrj", AllTrim( ::export_params[ "rj" ] ) )
   ENDIF

   if ::export_params[ "krediti_export" ] .AND. !Empty( ::export_params[ "kreditori" ] )
      _qry += " AND kr.idkred IN ( "
      _a_kreditor := TokToNiz( AllTrim( ::export_params[ "kreditori" ] ), ";" )
      FOR _i := 1 TO Len( _a_kreditor )
         IF _i > 1
            _qry += ", "
         ENDIF
         _qry += _sql_quote( _a_kreditor[ _i ] )
      NEXT
      _qry += " ) "
   ENDIF

   // sortiranje exporta po prezimenu
   _qry += " ORDER BY ld.godina, ld.mjesec, ld.obr, rd.naz "

   MsgO( "formiranje sql upita u toku ..." )

   _table := _sql_query( _server, _qry )

   MsgC()

   IF _table == NIL
      RETURN NIL
   ENDIF

   _table:GoTo(1)
   _count := 0

   // napunit ce iz sql upita tabelu export
   DO WHILE !_table:Eof()

      ++ _count

      oRow := _table:GetRow()

      SELECT exp_bank
      APPEND BLANK

      _rec := dbf_get_rec()
      _rec[ "godina" ] := oRow:FieldGet( oRow:FieldPos( "godina" ) )
      _rec[ "mjesec" ] := oRow:FieldGet( oRow:FieldPos( "mjesec" ) )
      _rec[ "idrj" ] := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "idrj" ) ) )
      _rec[ "obr" ] := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "obr" ) ) )
      _rec[ "idradn" ] := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "idradn" ) ) )
      _rec[ "jmbg" ] := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "jmbg" ) ) )
      _rec[ "tekrn" ] := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "tekrn" ) ) )
      _rec[ "knjiz" ] := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "knjiz" ) ) )

      _rec[ "punoime" ] := ;
         AllTrim( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "ime" ) ) ) ) + " (" + ;
         AllTrim( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "imerod" ) ) ) ) + ") " + ;
         AllTrim( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "naz" ) ) ) )

      _rec[ "ime" ] := AllTrim( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "ime" ) ) ) )
      _rec[ "imerod" ] := AllTrim( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "imerod" ) ) ) )
      _rec[ "prezime" ] := AllTrim( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "naz" ) ) ) )

      _rec[ "iznos_1" ] := oRow:FieldGet( oRow:FieldPos( "uiznos" ) )
      // iznos_2 ostavljam prazno...

      _rec[ "usati" ] := oRow:FieldGet( oRow:FieldPos( "usati" ) )
      _rec[ "uneto" ] := oRow:FieldGet( oRow:FieldPos( "uneto" ) )

      if ::export_params[ "krediti_export" ]
         // kredit
         _rec[ "kredit" ] := oRow:FieldGet( oRow:FieldPos( "kredit" ) )
         _rec[ "partija" ] := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "partija" ) ) )
         _rec[ "bank_part" ] := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "bank_part" ) ) )
      ENDIF

      IF !Empty( _dod_polja )
         FOR _i := 1 TO Len( _a_polja )
            IF !Empty( _a_polja[ _i ] )
               _rec[ Lower( _a_polja[ _i ] ) ] := oRow:FieldGet( oRow:FieldPos( Lower( _a_polja[ _i ] ) ) )
            ENDIF
         NEXT
      ENDIF

      dbf_update_rec( _rec )

      _table:Skip()

   ENDDO

   _ok := .T.

   RETURN _ok





// -----------------------------------------------------------
// vraca liniju koja ce sluziti kao makro za odsjecanje i prikaz
// teksta
// -----------------------------------------------------------

METHOD LDExportTxt:get_export_line_macro()

   LOCAL _struct

   _struct := AllTrim( ::formula_params[ "formula" ] )

   RETURN _struct



// -----------------------------------------------------------
// pravi txt fajl na osnovu dbf tabele i makro linije
// -----------------------------------------------------------

METHOD LDExportTxt:create_txt_from_dbf()

   LOCAL _ok := .F.
   LOCAL _output_filename
   LOCAL _output_dir
   LOCAL _curr_struct
   LOCAL _separator, _separator_formule
   LOCAL _line, _i, _a_struct

   _output_dir := my_home() + "export" + SLASH

   IF DirChange( _output_dir ) != 0
      MakeDir( _output_dir )
   ENDIF

   // fajl ide u my_home/export/
   _output_filename := _output_dir + AllTrim( ::export_params[ "fajl" ] )

   SET PRINTER TO ( _output_filename )
   SET PRINTER ON
   SET CONSOLE OFF

   // kreriraj makro liniju
   _curr_struct := ::get_export_line_macro()
   _separator := ::export_params[ "separator" ]
   _separator_formule := ::export_params[ "separator_formula" ]
   _a_struct := TokToNiz( _curr_struct, _separator_formule )
   _line := ""

   FOR _i := 1 TO Len( _a_struct )

      IF !Empty( _a_struct[ _i ] )

         // plusevi izmedju...
         IF _i > 1
            _line += " + "
         ENDIF

         // makro
         _line += _a_struct[ _i ]

         // ako treba separator
         IF _i < Len( _a_struct ) .AND. !Empty( _separator )
            _line += ' + "' + _separator + '" '
         ENDIF

      ENDIF

   NEXT

   // predji na upis podataka
   SELECT exp_bank
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      ?? to_win1250_encoding( hb_StrToUTF8( &( _line ) ), .T. )
      ?
      SKIP
   ENDDO

   SET PRINTER TO
   SET PRINTER OFF
   SET CONSOLE ON

   IF File( _output_filename )
      open_folder( _output_dir )
      MsgBeep( "Fajl uspjesno kreiran !" )
      _ok := .T.
   ELSE
      MsgBeep( "Postoji problem sa operacijom kreiranja fajla !!!" )
   ENDIF

   // zatvori tabelu...
   SELECT exp_bank
   USE

   DirChange( my_home() )

   RETURN _ok




// -----------------------------------------------------------
// glavna metoda exporta
// -----------------------------------------------------------

METHOD LDExportTxt:export()

   LOCAL _ok := .F.

   if ::export_params == NIL
      MsgBeep( "Prekidam operaciju exporta !" )
      RETURN _ok
   ENDIF

   // kreiraj tabelu exporta
   ::create_export_dbf()

   // napuni je podacima iz obračuna
   IF ! ::fill_data_from_ld()
      MsgBeep( "Za traženi period ne postoje podaci u obracunima !!!" )
      RETURN _ok
   ENDIF

   // kreiraj txt fajl na osnovu dbf tabele
   IF ! ::create_txt_from_dbf()
      RETURN _ok
   ENDIF

   _ok := .T.

   RETURN _ok


// ----------------------------------------------------------
// dupliciranje postavke eksporta
// ----------------------------------------------------------
METHOD LDExportTxt:export_setup_duplicate()

   LOCAL _existing := 1
   LOCAL _new := 0
   LOCAL oExisting := LDExportTxt():New()
   LOCAL oNew := LDExportTxt():New()
   PRIVATE GetList := {}

   Box(, 3, 60 )

   @ m_x + 1, m_y + 2 SAY "*** DUPLICIRANJE POSTAVKI EKSPORTA"
   @ m_x + 2, m_y + 2 SAY "Koristiti postojece podesenje broj:" GET _existing PICT "999"
   @ m_x + 3, m_y + 2 SAY "      Kreirati novo podesenje broj:" GET _new PICT "999"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   IF _new > 0 .AND. _new <> _existing

      oExisting:export_setup_read_params( _existing )

      oNew:formula_params := oExisting:formula_params
      oNew:export_setup_write_params( _new )

   ENDIF

   RETURN




// -----------------------------------------------------------
// podesenje varijanti exporta
// -----------------------------------------------------------

METHOD LDExportTxt:export_setup()

   LOCAL _ok := .F.
   LOCAL _x := 1
   LOCAL _id_formula := fetch_metric( "ld_export_banke_tek", my_user(), 1 )
   LOCAL _active, _formula, _filename, _name, _sep, _sep_formula, _banka, _kreditori, _kred_exp
   LOCAL _write_params

   Box(, 15, 70 )

   @ m_x + _x, m_y + 2 SAY "Varijanta eksporta:" GET _id_formula PICT "999"

   READ

   IF LastKey() == K_ESC
      BoxC()
      RETURN _ok
   ENDIF

   ::export_setup_read_params( _id_formula )

   _formula := ::formula_params[ "formula" ]
   _filename := ::formula_params[ "file" ]
   _name := ::formula_params[ "name" ]
   _sep := ::formula_params[ "separator" ]
   _sep_formula := ::formula_params[ "separator_formula" ]
   _banka := ::formula_params[ "banka" ]
   _kreditori := ::formula_params[ "kreditori" ]
   _kred_exp := ::formula_params[ "krediti_export" ]

   IF _formula == NIL
      // tek se podesavaju parametri za ovu formulu
      _formula := Space( 500 )
      _name := PadR( "XXXXX Banka", 100 )
      _filename := PadR( "", 50 )
      _banka := Space( 6 )
      _kreditori := Space( 300 )
      _kred_exp := "N"
      _sep := ";"
      _sep_formula := ";"
   ELSE
      _formula := PadR( AllTrim( _formula ), 500 )
      _name := PadR( AllTrim( _name ), 100 )
      _filename := PadR( AllTrim( _filename ), 50 )
      _sep := PadR( _sep, 1 )
      _sep_formula := PadR( _sep_formula, 1 )
      _banka := PadR( _banka, 6 )
      _kreditori := PadR( _kreditori, 300 )
      _kred_exp := PadR( _kred_exp, 1 )
   ENDIF

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "(*)   Naziv:" GET _name PICT "@S50" VALID !Empty( _name )

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "(*)   Banka:" GET _banka PICT "@S50" VALID !Empty( _banka ) .AND. P_Kred( @_banka )

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "(*) Formula:" GET _formula PICT "@S50" VALID ;
      {|| !Empty( _formula ) .AND. ::copy_existing_formula( @_formula ) }

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Naziv izlaznog fajla:" GET _filename PICT "@S40"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Separator u izl.fajlu [ ; , . ]:" GET _sep

   ++ _x

   @ m_x + _x, m_y + 2 SAY "    Separator formule [ ; , . ]:" GET _sep_formula

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Eksport kredita (D/N) ?" GET _kred_exp PICT "!@" VALID _kred_exp $ "DN"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Lista kreditora za kredite:" GET _kreditori PICT "@S30"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   // write params

   set_metric( "ld_export_banke_tek", my_user(), _id_formula )

   ::formula_params[ "separator" ] := _sep
   ::formula_params[ "separator_formula" ] := _sep_formula
   ::formula_params[ "formula" ] := _formula
   ::formula_params[ "file" ] := _filename
   ::formula_params[ "name" ] := _name
   ::formula_params[ "banka" ] := _banka
   ::formula_params[ "kreditori" ] := _kreditori
   ::formula_params[ "krediti_export" ] := _kred_exp

   ::export_setup_write_params( _id_formula )

   RETURN _ok





// -----------------------------------------------------------
// citanje podesenja varijanti
// -----------------------------------------------------------


METHOD LDExportTxt:export_setup_read_params( id )

   LOCAL _param_name := "ld_export_" + PadL( AllTrim( Str( id ) ), 2, "0" ) + "_"
   LOCAL _ok := .T.

   ::formula_params := hb_Hash()
   ::formula_params[ "name" ] := fetch_metric( _param_name + "name", NIL, NIL )
   ::formula_params[ "file" ] := fetch_metric( _param_name + "file", NIL, NIL )
   ::formula_params[ "formula" ] := fetch_metric( _param_name + "formula", NIL, NIL )
   ::formula_params[ "separator" ] := fetch_metric( _param_name + "sep", NIL, NIL )
   ::formula_params[ "separator_formula" ] := fetch_metric( _param_name + "sep_formula", NIL, ";" )
   ::formula_params[ "banka" ] := fetch_metric( _param_name + "banka", NIL, NIL )
   ::formula_params[ "kreditori" ] := fetch_metric( _param_name + "kreditori", NIL, NIL )
   ::formula_params[ "krediti_export" ] := fetch_metric( _param_name + "krediti_export", NIL, "N" )

   RETURN _ok





// -----------------------------------------------------------
// snimanje podesenja varijanti
// -----------------------------------------------------------

METHOD LDExportTxt:export_setup_write_params( id )

   LOCAL _param_name := "ld_export_" + PadL( AllTrim( Str( id ) ), 2, "0" ) + "_"

   set_metric( _param_name + "name", NIL, AllTrim( ::formula_params[ "name" ] ) )
   set_metric( _param_name + "file", NIL, AllTrim( ::formula_params[ "file" ] ) )
   set_metric( _param_name + "formula", NIL, AllTrim( ::formula_params[ "formula" ] ) )
   set_metric( _param_name + "sep", NIL, AllTrim( ::formula_params[ "separator" ] ) )
   set_metric( _param_name + "sep_formula", NIL, AllTrim( ::formula_params[ "separator_formula" ] ) )
   set_metric( _param_name + "banka", NIL, ::formula_params[ "banka" ] )
   set_metric( _param_name + "kreditori", NIL, ::formula_params[ "kreditori" ] )
   set_metric( _param_name + "krediti_export", NIL, ::formula_params[ "krediti_export" ] )

   RETURN .T.




METHOD LDExportTxt:get_export_params( id )

   LOCAL _ok := .F.

   IF id == 0
      id := ::get_export_list()
   ENDIF

   IF id == 0
      MsgBeep( "Potrebno izabrati neku od varijanti !" )
      RETURN _ok
   ENDIF

   ::export_setup_read_params( id )

   if ::formula_params[ "name" ] == NIL .OR. Empty( ::formula_params[ "name" ]  )
      MsgBeep( "Za ovu varijantu ne postoji podesenje !!!#Ukucajte 0 da bi odabrali iz liste." )
   ELSE
      _ok := .T.
   ENDIF

   RETURN _ok






METHOD LDExportTxt:get_export_list()

   LOCAL _id := 0
   LOCAL _i
   LOCAL _param_name := "ld_export_"
   LOCAL _opc, _opcexe, _izbor := 1
   LOCAL _m_x := m_x
   LOCAL _m_y := m_y

   _opc := {}
   _opcexe := {}

   FOR _i := 1 TO 20

      ::export_setup_read_params( _i )

      if ::formula_params[ "name" ] <> NIL .AND. !Empty( ::formula_params[ "name" ] )

         _tmp := ""
         _tmp += PadL( AllTrim( Str( _i ) ) + ".", 4 )
         _tmp += PadR( ::formula_params[ "name" ], 40 )

         AAdd( _opc, _tmp )
         AAdd( _opcexe, {|| "" } )

      ENDIF

   NEXT

   DO WHILE .T. .AND. LastKey() != K_ESC
      _izbor := Menu( "choice", _opc, _izbor, .F. )
      IF _izbor == 0
         EXIT
      ELSE
         _id := Val( Left ( _opc[ _izbor ], 3 ) )
         _izbor := 0
      ENDIF
   ENDDO

   m_x := _m_x
   m_y := _m_y

   RETURN _id




FUNCTION ld_export_banke()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. export podataka za banku                " )
   AAdd( _opcexe, {|| ld_export_txt_banka()  } )
   AAdd( _opc, "2. postavke formula exporta   " )
   AAdd( _opcexe, {|| ld_export_txt_setup()  } )
   AAdd( _opc, "3. dupliciranje podešenja eksporta   " )
   AAdd( _opcexe, {|| LDExportTxt():New():export_setup_duplicate()  } )

   f18_menu( "el", .F., _izbor, _opc, _opcexe )

   RETURN





FUNCTION ld_export_txt_banka( params )

   LOCAL oExp

   oExp := LDExportTxt():New()

   // u slucaju da nismo setovali parametre, pozovi ih
   IF params == NIL
      oExp:params()
   ELSE
      // setuj parametre na osnovu proslijedjenih...
      oExp:export_params := hb_Hash()
      oExp:export_params[ "godina" ] := params[ "godina" ]
      oExp:export_params[ "mjesec" ] := params[ "mjesec" ]
   ENDIF

   oExp:export()

   RETURN




FUNCTION ld_export_txt_setup()

   LOCAL oExp

   oExp := LDExportTxt():New()
   oExp:export_setup()

   RETURN
