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

// ----------------------------------------------------------
// kopiranje vrijednosti nekog polja u neko SIFK polje
// ----------------------------------------------------------
FUNCTION copy_to_sifk()

   LOCAL cTable := Alias()
   LOCAL cFldFrom := Space( 8 )
   LOCAL cFldTo := Space( 4 )
   LOCAL cEraseFld := "D"
   LOCAL cRepl := "D"
   LOCAL nTekX
   LOCAL nTekY
   LOCAL lSql

   Box(, 6, 65, .F. )
	
   PRIVATE GetList := {}
   SET CURSOR ON
	
   nTekX := m_x
   nTekY := m_y
	
   @ m_x + 1, m_y + 2 SAY PadL( "Polje iz kojeg kopiramo (polje 1)", 40 ) GET cFldFrom VALID !Empty( cFldFrom ) .AND. val_fld( cFldFrom )
   @ m_x + 2, m_y + 2 SAY PadL( "SifK polje u koje kopiramo (polje 2)", 40 ) GET cFldTo VALID g_sk_flist( @cFldTo )
	
   @ m_x + 4, m_y + 2 SAY "Brisati vrijednost (polje 1) nakon kopiranja ?" GET cEraseFld VALID cEraseFld $ "DN" PICT "@!"
	
   @ m_x + 6, m_y + 2 SAY "*** izvrsiti zamjenu ?" GET cRepl VALID cRepl $ "DN" PICT "@!"
   READ

   BoxC()

   lSql := get_a_dbf_rec( Alias() )[ 'sql' ]

   IF cRepl == "N"
      RETURN 0
   ENDIF

   IF LastKey() == K_ESC
      RETURN 0
   ENDIF

   nTRec := RecNo()
   GO TOP

   DO WHILE !Eof()
	
      SKIP
      nRec := RecNo()
      SKIP -1
	
      cCpVal := ( Alias() )->&cFldFrom
      IF !Empty( cCpval )
         USifK( Alias(), cFldTo,  Unicode():New( ( Alias() )->id, lSql ), cCpVal )
      ENDIF
	
      IF cEraseFld == "D"
         REPLACE ( Alias() )->&cFldFrom WITH ""
      ENDIF
	
      GO ( nRec )
   ENDDO

   GO ( nTRec )

   RETURN 0


// --------------------------------------------------
// zamjena vrijednosti sifk polja
// --------------------------------------------------
FUNCTION repl_sifk_item()

   LOCAL cTable := Alias()
   LOCAL cField := Space( 4 )
   LOCAL cOldVal
   LOCAL cNewVal
   LOCAL cCurrVal
   LOCAL cPtnField
   LOCAL lSql := is_sql_table()

   Box(, 3, 60, .F. )
   PRIVATE GetList := {}
   SET CURSOR ON
	
   nTekX := m_x
   nTekY := m_y
	
   @ m_x + 1, m_y + 2 SAY " SifK polje:" GET cField VALID g_sk_flist( @cField )
   READ
	
   cCurrVal := "wSifk_" + cField
   &cCurrVal := IzSifk( Alias(), cField )
   cOldVal := &cCurrVal
   cNewVal := Space( Len( cOldVal ) )
	
   m_x := nTekX
   m_y := nTekY
	
   @ m_x + 2, m_y + 2 SAY8 "      Traži:"  GET cOldVal
   @ m_x + 3, m_y + 2 SAY8 "Zamijeni sa:" GET cNewVal
	
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN 0
   ENDIF

   IF Pitanje( , "Izvršiti zamjenu polja? (D/N)", "D" ) == "N"
      RETURN 0
   ENDIF

   nTRec := RecNo()

   DO WHILE !Eof()
      &cCurrVal := IzSifK( Alias(), cField )
      if &cCurrVal == cOldVal
         USifK( Alias(), cField, Unicode():New( ( Alias() )->id, lSql ), cNewVal )
      ENDIF
      SKIP
   ENDDO

   GO ( nTRec )

   RETURN 0



FUNCTION g_sk_flist( cField )

   LOCAL aFields := {}
   LOCAL cCurrAlias := Alias()
   LOCAL nArr
   LOCAL nField

   nArr := Select()

   SELECT sifk
   SET ORDER TO TAG "ID"
   cCurrAlias := PadR( cCurrAlias, 8 )
   SEEK cCurrAlias

   DO WHILE !Eof() .AND. field->id == cCurrAlias
      AAdd( aFields, { field->oznaka, field->naz } )
      SKIP
   ENDDO

   SELECT ( nArr )

   IF !Empty( cField ) .AND. AScan( aFields, {| xVal| xVal[ 1 ] == cField } ) > 0
      RETURN .T.
   ENDIF

   IF Len( aFields ) > 0
      PRIVATE Izbor := 1
      PRIVATE opc := {}
      PRIVATE opcexe := {}
      PRIVATE GetList := {}
	
      FOR i := 1 TO Len( aFields )
         AAdd( opc, PadR( aFields[ i, 1 ] + " - " + aFields[ i, 2 ], 40 ) )
         AAdd( opcexe, {|| nField := Izbor, Izbor := 0 } )
      NEXT
	
      Izbor := 1
      Menu_SC( "skf" )
   ENDIF

   cField := aFields[ nField, 1 ]

   RETURN .T.



FUNCTION IzSifkPartn( dbf_name, ozna, u_id_sif, return_nil )

   LOCAL xSif

   IF ValType( u_id_sif ) != "O"
        xSif := Unicode():New( u_id_sif, is_partn_sql() )
   ELSE
        xSif := u_id_sif
   ENDIF
   RETURN  IzSifk( "PARTN", dbf_name, ozna, xSif, return_nil )

FUNCTION IzSifkKonto( dbf_name, ozna, u_id_sif, return_nil )

   LOCAL xSif

   IF ValType( u_id_sif ) != "O"
        xSif := Unicode():New( u_id_sif, is_konto_sql() )
   ELSE
        xSif := u_id_sif
   ENDIF
   RETURN  IzSifk( "KONTO", dbf_name, ozna, xSif, return_nil )


FUNCTION IzSifkRoba( dbf_name, ozna, u_id_sif, return_nil )

   LOCAL xSif

   IF ValType( u_id_sif ) != "O"
        xSif := Unicode():New( u_id_sif, is_roba_sql() )
   ELSE
        xSif := u_id_sif
   ENDIF
   RETURN  IzSifk( "ROBA", dbf_name, ozna, xSif, return_nil )


FUNCTION IzSifk( dbf_name, ozna, u_id_sif, return_nil )

   LOCAL _tmp

   PushWA()
   _tmp := get_sifk_value( dbf_name, ozna, u_id_sif, return_nil )
   PopWa()

   RETURN _tmp

// -----------------------------------------------------------
// get_karakter_value
// Izvlaci vrijednost iz tabele SIFK
// param dbf_name ime DBF-a
// param oznaka oznaka BARK , GR1 itd
// param id_sif       sifra u sifrarniku, npr  000000232  ,
// ili "00000232,XXX1233233" pri pretrazivanju

/*
  get_sifk_value( "PARTN", "BANK", "K01", NIL )

  => "0123456789012345,0123456789012349"
  => NIL - ne postoji SIFK PARTN/BANK
  => PADR("", 190) ako postoji SIFV ili je prazan zapis


  - return_nil  = NIL => NIL - NIL za nedefinisanu vrijednost,
                  .T. => ""  - "" za nedefinisanu vrijednost
*/

FUNCTION get_sifk_value ( dbf_name, ozna, u_id_sif, return_nil )

   LOCAL _ret := ""
   LOCAL _sifk_tip, _sifk_duzina, _sifk_veza, uIdSif
   LOCAL lSql := .F.

   // ID default polje
   IF u_id_sif == NIL
      u_id_sif := ( dbf_name )->ID
      IF !Empty( dbf_name )
         lSql := is_sql_table( dbf_name )
      ENDIF
   ENDIF

   u_id_sif := Unicode():New( u_id_sif, lSql )
   dbf_name := PadR( dbf_name, SIFK_LEN_DBF )
   ozna     := PadR( ozna, SIFK_LEN_OZNAKA )
   uIdSif   := u_id_sif:PadR( SIFK_LEN_IDSIF )

   use_sql_sifk( dbf_name, ozna )
   _ret := NIL

   GO TOP
   IF Eof()
      // uopste ne postoji takva karakteristika
      IF return_nil <> NIL
         _ret := get_sifv_value( "X", "" )
      ELSE
         _ret := NIL
      ENDIF
      RETURN _ret
   ENDIF

   _sifk_duzina := sifk->duzina
   _sifk_tip    := sifk->tip
   _sifk_veza   := sifk->veza

   SELECT F_SIFV
   // proslijedi unicode objekat, to je najsigurnije
   use_sql_sifv( dbf_name, ozna, u_id_sif )
   GO TOP
   IF Eof()
      _ret := get_sifv_value( _sifk_tip, _sifk_duzina, "" )
      IF _sifk_veza == "N"
         _ret := PadR( _ret, 190 )
      ENDIF
      RETURN _ret
   ENDIF

   _ret := get_sifv_value( _sifk_tip, _sifk_duzina, sifv->naz )

   IF _sifk_veza == "N"
      _ret := ToStr( _ret )
      SKIP
      DO WHILE !Eof() .AND.  ( ( id + oznaka + idsif ) == ( dbf_name + ozna + uIdSif ) )
         _ret += "," + ToStr( get_sifv_value( _sifk_tip, _sifk_duzina, sifv->naz ) )
         SKIP
      ENDDO
      _ret := PadR( _ret, 190 )
   ENDIF

   RETURN _ret



STATIC FUNCTION get_sifv_value( sifk_tip, sifk_duzina, naz_value )

   LOCAL _ret

   DO CASE
   CASE sifk_tip == "C"
      _ret := PadR( naz_value, sifk_duzina )

   CASE sifk_tip == "N"
      _ret := Val( AllTrim( naz_value ) )

   CASE sifk_tip == "D"
      _ret := SToD( Trim( naz_value ) )
   OTHERWISE
      _ret := "?NEPTIP?"

   END DO

   RETURN _ret

/*

  IzSifkNaz( "ROBA", "GR1" ) => "Grupa 1  "
  IzSifkNaz( "ROBA", "XYZ" ) => "         "

*/
FUNCTION IzSifkNaz( cDBF, cOznaka )

   LOCAL xRet := "", nArea

   PushWA()

   cDBF := PadR( cDBF, SIFK_LEN_DBF )
   cOznaka := PadR( cOznaka, SIFK_LEN_OZNAKA )

   SELECT F_SIFK
   use_sql_sifk( cDBF, cOznaka )
   xRet := field->NAZ

   PopWA()

   RETURN xRet



FUNCTION IzSifkWV( cDBF, cOznaka, cWhen, cValid )

   LOCAL xRet := ""

   PushWA()

   cDBF := PadR( cDBF, SIFK_LEN_DBF )
   cOznaka := PadR( cOznaka, SIFK_LEN_OZNAKA )
   SELECT F_SIFK
   use_sql_sifk( cDBF, cOznaka )

   cWhen  := sifk->KWHEN
   cValid := sifk->KVALID

   PopWa()

   RETURN NIL

// -------------------------------------------------------
// USifk
// Postavlja vrijednost u tabelu SIFK
// cDBF ime DBF-a
// cOznaka oznaka xxxx
// cIdSif  Id u sifrarniku npr. 2MON0001
// xValue  vrijednost (moze biti tipa C,N,D)
//
// veza: 1
// USifK("PARTN", "ROKP", temp->idpartner, temp->rokpl)
// USifK("PARTN", "PORB", temp->idpartner, temp->porbr)

// veza: N
// USifK( "PARTN", "BANK", cPartn, "1400000000001,131111111111112" )
// iz ovoga se vidi da je "," nedozvoljen znak u ID-u
// ------------------------------------------------------------------

FUNCTION USifk( dbf_name, ozna, u_id_sif, val, transaction )

   LOCAL _i
   LOCAL ntrec, numtok
   LOCAL _sifk_rec
   LOCAL _tran
   LOCAL cIdSif

   IF transaction == NIL
      transaction := "FULL"
   ENDIF

   IF val == NIL
      RETURN .F.
   ENDIF

   cIdSif := ( Unicode():New( u_id_sif ) ):getString()
   PushWA()

   dbf_name := PadR( dbf_name, SIFK_LEN_DBF )
   ozna     := PadR( ozna, SIFK_LEN_OZNAKA )
   cIdSif   := PadR( cIdSif, SIFK_LEN_IDSIF )

   SELECT F_SIFK
   use_sql_sifk( dbf_name, ozna )
   GO TOP
   IF Eof() .OR. !( sifk->tip $ "CDN" )
      PopWa()
      RETURN .F.
   ENDIF

   SELECT F_SIFV
   use_sql_sifv( dbf_name, ozna, cIdSif )

   SELECT sifk
   _sifk_rec := dbf_get_rec()

   IF transaction == "FULL"
      _tran := "BEGIN"
      sql_table_update( nil, _tran )
   ENDIF

   IF sifk->veza == "N"
      IF !update_sifv_n_relation( _sifk_rec, cIdSif, val )
         RETURN .F.
      ENDIF
   ELSE
      IF !update_sifv_1_relation( _sifk_rec, cIdSif, val )
         RETURN .F.
      ENDIF
   ENDIF

   IF transaction == "FULL"
      _tran := "END"
      sql_table_update( nil, _tran )
   ENDIF

   PopWa()

   RETURN .T.



STATIC FUNCTION update_sifv_n_relation( sifk_rec, id_sif, vals )

   LOCAL _i, _numtok, _tmp, _naz, _values
   LOCAL _sifv_rec

   _sifv_rec := hb_Hash()
   _sifv_rec[ "id" ] := sifk_rec[ "id" ]
   _sifv_rec[ "oznaka" ] := sifk_rec[ "oznaka" ]
   _sifv_rec[ "idsif" ] := id_sif

   // veza 1->N posebno se tretira !!
   SELECT sifv
   brisi_sifv_item( sifk_rec[ "id" ], sifk_rec[ "oznaka" ], id_sif )

   _numtok := NumToken( vals, "," )

   FOR _i := 1 TO _numtok

      _tmp := Token( vals, ",", _i )
      APPEND BLANK

      _sifv_rec[ "naz" ] := PadR( get_sifv_naz( _tmp, sifk_rec ), 50 )

      update_rec_server_and_dbf( "sifv", _sifv_rec, 1, "CONT" )

   NEXT

   RETURN .T.




STATIC FUNCTION update_sifv_1_relation( sifk_rec, id_sif, value )

   LOCAL _sifv_rec

   _sifv_rec := hb_Hash()
   _sifv_rec[ "id" ] := sifk_rec[ "id" ]
   _sifv_rec[ "oznaka" ] := sifk_rec[ "oznaka" ]
   _sifv_rec[ "idsif" ] := id_sif

   value := PadR( value, sifk_rec[ "duzina" ] )

   // veza 1-1
   SELECT  SIFV
   brisi_sifv_item( sifk_rec[ "id" ], sifk_rec[ "oznaka" ], id_sif )

   APPEND BLANK

   _sifv_rec[ "naz" ] := get_sifv_naz( value, sifk_rec )
   _sifv_rec[ "naz" ] := PadR( _sifv_rec[ "naz" ], 50 )

   // zakljucavanje se desava u nadfunkciji
   update_rec_server_and_dbf( "sifv", _sifv_rec, 1, "CONT" )

   RETURN .T.



STATIC FUNCTION brisi_sifv_item( dbf_name, ozn, id_sif )

   LOCAL _sifv_rec := hb_Hash()

   _sifv_rec[ "id" ]     := dbf_name
   _sifv_rec[ "oznaka" ] := ozn
   _sifv_rec[ "idsif" ]  := id_sif

   RETURN delete_rec_server_and_dbf( "sifv", _sifv_rec, 2, "CONT" )



STATIC FUNCTION get_sifv_naz( val, sifk_rec )

   DO CASE
   CASE sifk_rec[ "tip" ] == "C"
      RETURN PadR( val, sifk_rec[ "duzina" ] )
   CASE sifk_rec[ "tip" ] == "N"
      RETURN val
   CASE sifk_rec[ "tip" ] == "D"
      RETURN DToS( val )
   END CASE



/*
    ImauSifv
    Povjerava ima li u sifv vrijednost ...
    ImaUSifv("ROBA","BARK","BK0002030300303",@cIdSif)

    @param cDBF ime DBF-a
    @param cOznaka oznaka BARK , GR1 itd
    @param cVOznaka oznaka BARK003030301
    @param cIDSif   ROBA01 - idroba
*/

FUNCTION ImaUSifv( cDBF, cOznaka, cVrijednost, cIdSif )

   LOCAL cJedanod := ""
   LOCAL xRet := ""
   LOCAL nTr1, nTr2, xVal
   PRIVATE cPom := ""

   cDBF    := PadR( cDBF, SIFK_LEN_DBF )
   cOznaka := PadR( cOznaka, SIFK_LEN_OZNAKA )

   xVal := NIL

   PushWA()

   SELECT F_SIFV
   use_sql_sifv( cDbf, cOznaka, NIL, cVrijednost )
   GO TOP
   IF !Eof()
      cIdSif := IdSif
   ENDIF
   PopWa()

   RETURN


FUNCTION update_sifk_na_osnovu_ime_kol_from_global_var( ime_kol, var_prefix, novi, transaction )

   LOCAL _i, uId
   LOCAL _alias
   LOCAL _field_b
   LOCAL _a_dbf_rec
   LOCAL lSql := is_sql_table( Alias() )
   LOCAL lOk := .T.
   LOCAL lRet := .F.

   _alias := Alias()

   FOR _i := 1 TO Len( ime_kol )
      IF Left( ime_kol[ _i, 3 ], 6 ) == "SIFK->"
         _field_b :=  MemVarBlock( var_prefix + "SIFK_" + SubStr( ime_kol[ _i, 3 ], 7 ) )
         uId := Unicode():New( ( _alias )->id,  lSql )
         IF IzSifk( _alias, SubStr( ime_kol[ _i, 3 ], 7 ), uId ) <> NIL
            lOk := USifk( _alias, SubStr( ImeKol[ _i, 3 ], 7 ), uId, Eval( _field_b ), transaction )
         ENDIF
         IF !lOk
           EXIT
         ENDIF
      ENDIF
   NEXT

   lRet := lOk

   RETURN lRet


// --------------------------------------------
// validacija da li polje postoji
// --------------------------------------------
STATIC FUNCTION val_fld( cField )

   LOCAL lRet := .T.

   IF ( Alias() )->( FieldPos( cField ) ) == 0
      lRet := .F.
   ENDIF

   IF lRet == .F.
      msgbeep( "Polje ne postoji !!!" )
   ENDIF

   RETURN lRet


// ------------------------------------------------------------------
// formiranje matrice na osnovu podataka iz tabele sifv
// ------------------------------------------------------------------
FUNCTION array_from_sifv( dbf, oznaka, id_sif )

   LOCAL _arr := {}
   LOCAL _t_area := Select()

   dbf := PadR( dbf, 8 )
   oznaka := PadR( oznaka, 4 )

   SELECT F_SIFV
   use_sql_sifv( dbf, oznaka, id_sif )
   SET ORDER TO TAG "ID"
   GO TOP

   DO WHILE !Eof() .AND. field->id + field->oznaka + field->idsif = dbf + oznaka + id_sif
      IF !Empty( naz )
         AAdd( _arr, AllTrim( field->naz ) )
      ENDIF
      SKIP
   ENDDO

   SELECT ( _t_area )

   RETURN _arr
