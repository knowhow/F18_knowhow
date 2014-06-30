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



// -----------------------------------
// punjenje loga sa stavkama tipa 10
// -----------------------------------
FUNCTION _lit_10_insert( cAction, nDoc_no, nDoc_log_no, aArr )

   LOCAL nDoc_lit_no

   nDoc_lit_no := _inc_lit_no( nDoc_no, nDoc_log_no )

   SELECT doc_lit
   APPEND BLANK

   _rec := dbf_get_rec()

   _rec[ "doc_no" ] := nDoc_no
   _rec[ "doc_log_no" ] := nDoc_log_no
   _rec[ "doc_lit_no" ] := nDoc_lit_no
   _rec[ "int_1" ] := aArr[ 1, 1 ]
   _rec[ "int_2" ] := aArr[ 1, 2 ]
   _rec[ "doc_lit_ac" ] := cAction

   update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )

   RETURN



// -----------------------------------
// punjenje loga sa stavkama tipa 11
// -----------------------------------
FUNCTION _lit_11_insert( cAction, nDoc_no, nDoc_log_no, aArr )

   LOCAL nDoc_lit_no

   nDoc_lit_no := _inc_lit_no( nDoc_no, nDoc_log_no )

   SELECT doc_lit
   APPEND BLANK

   _rec := dbf_get_rec()

   _rec[ "doc_no" ] := nDoc_no
   _rec[ "doc_log_no" ] := nDoc_log_no
   _rec[ "doc_lit_no" ] := nDoc_lit_no
   _rec[ "date_1" ] := aArr[ 1, 2 ]
   _rec[ "int_1" ] := aArr[ 1, 1 ]
   _rec[ "char_1" ] := aArr[ 1, 3 ]
   _rec[ "char_2" ] := aArr[ 1, 4 ]
   _rec[ "doc_lit_ac" ] := cAction

   update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )

   RETURN





// -----------------------------------
// punjenje loga sa stavkama tipa 12
// -----------------------------------
FUNCTION _lit_12_insert( cAction, nDoc_no, nDoc_log_no, aArr )

   LOCAL nDoc_lit_no

   nDoc_lit_no := _inc_lit_no( nDoc_no, nDoc_log_no )

   SELECT doc_lit
   APPEND BLANK

   _rec := dbf_get_rec()

   _rec[ "doc_no" ] := nDoc_no
   _rec[ "doc_log_no" ] := nDoc_log_no
   _rec[ "doc_lit_no" ] := nDoc_lit_no
   _rec[ "int_1" ] := aArr[ 1, 1 ]
   _rec[ "char_1" ] := aArr[ 1, 2 ]
   _rec[ "doc_lit_ac" ] := cAction

   update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )

   RETURN



// -----------------------------------
// punjenje loga sa stavkama tipa 13
// -----------------------------------
FUNCTION _lit_13_insert( cAction, nDoc_no, nDoc_log_no, aArr )

   LOCAL nDoc_lit_no

   nDoc_lit_no := _inc_lit_no( nDoc_no, nDoc_log_no )

   SELECT doc_lit
   APPEND BLANK

   _rec := dbf_get_rec()

   _rec[ "doc_no" ] := nDoc_no
   _rec[ "doc_log_no" ] := nDoc_log_no
   _rec[ "doc_lit_no" ] := nDoc_lit_no
   _rec[ "int_1" ] := aArr[ 1, 1 ]
   _rec[ "char_1" ] := aArr[ 1, 2 ]
   _rec[ "char_2" ] := aArr[ 1, 3 ]
   _rec[ "doc_lit_ac" ] := cAction

   update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )

   RETURN


// -----------------------------------
// punjenje loga sa stavkama tipa 20
// -----------------------------------
FUNCTION _lit_20_insert( cAction, nDoc_no, nDoc_log_no, ;
      nArt_id, cDoc_desc, cDoc_sch, ;
      nArt_qtty, nArt_heigh, nArt_width )

   LOCAL nDoc_lit_no

   nDoc_lit_no := _inc_lit_no( nDoc_no, nDoc_log_no )

   SELECT doc_lit
   APPEND BLANK

   _rec := dbf_get_rec()

   _rec[ "doc_no" ] := nDoc_no
   _rec[ "doc_log_no" ] := nDoc_log_no
   _rec[ "doc_lit_no" ] := nDoc_lit_no
   _rec[ "art_id" ] := nArt_id
   _rec[ "num_1" ] := nArt_qtty
   _rec[ "num_2" ] := nArt_heigh
   _rec[ "num_3" ] := nArt_width
   _rec[ "char_1" ] := cDoc_desc
   _rec[ "char_2" ] := cDoc_sch
   _rec[ "doc_lit_ac" ] := cAction

   update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )

   RETURN


// -----------------------------------
// punjenje loga sa stavkama tipa 21
// -----------------------------------
FUNCTION _lit_21_insert( cAction, nDoc_no, nDoc_log_no, ;
      nArt_id, cArt_desc, nGlass_no, nDoc_it_no, ;
      nQty, nDamage )

   LOCAL nDoc_lit_no

   nDoc_lit_no := _inc_lit_no( nDoc_no, nDoc_log_no )

   SELECT doc_lit
   APPEND BLANK

   _rec := dbf_get_rec()

   _rec[ "doc_no" ] := nDoc_no
   _rec[ "doc_log_no" ] := nDoc_log_no
   _rec[ "doc_lit_no" ] := nDoc_lit_no
   _rec[ "art_id" ] := nArt_id
   _rec[ "num_1" ] := nQty
   _rec[ "num_2" ] := nDamage
   _rec[ "int_1" ] := nDoc_it_no
   _rec[ "int_2" ] := nGlass_no
   _rec[ "char_1" ] := cArt_desc
   _rec[ "doc_lit_ac" ] := cAction

   update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )

   RETURN




// -----------------------------------
// punjenje loga sa stavkama tipa 30
// -----------------------------------
FUNCTION _lit_30_insert( cAction, nDoc_no, nDoc_log_no, ;
      nAop_id, nAop_att_id, cDoc_op_desc )

   LOCAL nDoc_lit_no

   nDoc_lit_no := _inc_lit_no( nDoc_no, nDoc_log_no )

   SELECT doc_lit
   APPEND BLANK

   _rec := dbf_get_rec()

   _rec[ "doc_no" ] := nDoc_no
   _rec[ "doc_log_no" ] := nDoc_log_no
   _rec[ "doc_lit_no" ] := nDoc_lit_no
   _rec[ "int_1" ] := nAop_id
   _rec[ "int_2" ] := nAop_att_id
   _rec[ "char_1" ] := cDoc_op_desc
   _rec[ "doc_lit_ac" ] := cAction

   update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )

   RETURN




// -----------------------------------
// punjenje loga sa stavkama tipa 99
// -----------------------------------
FUNCTION _lit_99_insert( cAction, nDoc_no, nDoc_log_no, nDoc_status )

   LOCAL nDoc_lit_no

   nDoc_lit_no := _inc_lit_no( nDoc_no, nDoc_log_no )

   SELECT doc_lit
   APPEND BLANK

   _rec := dbf_get_rec()

   _rec[ "doc_no" ] := nDoc_no
   _rec[ "doc_log_no" ] := nDoc_log_no
   _rec[ "doc_lit_no" ] := nDoc_lit_no
   _rec[ "int_1" ] := nDoc_status
   _rec[ "doc_lit_ac" ] := cAction

   update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )

   RETURN


// --------------------------------------------
// dodaje zapis u tabelu doc_log
// --------------------------------------------
FUNCTION _d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )

   LOCAL nOperId
   LOCAL nTArea := Select()

   nOperId := GetUserID( f18_user() )

   SELECT doc_log
   APPEND BLANK

   _rec := dbf_get_rec()

   _rec[ "doc_no" ] := nDoc_no
   _rec[ "doc_log_no" ] := nDoc_log_no
   _rec[ "doc_log_da" ] := danasnji_datum()
   _rec[ "doc_log_ti" ] := PadR( Time(), 5 )
   _rec[ "doc_log_ty" ] := cDoc_log_type
   _rec[ "operater_i" ] := nOperId
   _rec[ "doc_log_de" ] := cDesc

   update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )

   SELECT ( nTArea )

   RETURN



// -------------------------------------------------------
// vraca sljedeci redni broj dokumenta u DOC_LOG tabeli
// -------------------------------------------------------
FUNCTION _inc_log_no( nDoc_no )

   LOCAL nLastNo := 0

   PushWa()

   SELECT doc_log
   SET ORDER TO TAG "1"
   GO TOP

   SEEK docno_str( nDoc_no )

   DO WHILE !Eof() .AND. ( field->doc_no == nDoc_no )
      nLastNo := field->doc_log_no
      SKIP
   ENDDO

   PopWa()

   RETURN nLastNo + 1



FUNCTION doclog_str( nId )
   RETURN Str( nId, 10 )



STATIC FUNCTION _inc_lit_no( nDoc_no, nDoc_log_no )

   LOCAL nLastNo := 0

   PushWa()
   SELECT doc_lit
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDoc_no ) + doclog_str( nDoc_log_no )

   DO WHILE !Eof() .AND. ( field->doc_no == nDoc_no ) ;
         .AND. ( field->doc_log_no == nDoc_log_no )
	
      nLastNo := field->doc_lit_no
      SKIP
	
   ENDDO
   PopWa()

   RETURN nLastNo + 1






// ----------------------------------------------
// vraca string napunjen promjenama tipa "20"
// ----------------------------------------------
FUNCTION _lit_20_get( nDoc_no, nDoc_log_no )

   LOCAL cRet := ""
   LOCAL nTArea := Select()

   SELECT doc_lit
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDoc_no ) + doclog_str( nDoc_log_no )

   DO WHILE !Eof() .AND. field->doc_no == nDoc_no ;
         .AND. field->doc_log_no == nDoc_log_no

      cRet += "artikal: " + PadR( g_art_desc( field->art_id ), 10 )
      cRet += "#"
      cRet += "kol.=" + AllTrim( Str( field->num_1, 8, 2 ) )
      cRet += ","
      cRet += "vis.=" + AllTrim( Str( field->num_2, 8, 2 ) )
      cRet += ","
      cRet += "sir.=" + AllTrim( Str( field->num_3, 8, 2 ) )
      cRet += "#"
	
      IF !Empty( field->char_1 )
         cRet += "opis.=" + AllTrim( field->char_1 )
         cRet += "#"
      ENDIF
	
      IF !Empty( field->char_2 )
         cRet += "shema.=" + AllTrim( field->char_2 )
         cRet += "#"
      ENDIF

      SELECT doc_lit
	
      SKIP
   ENDDO

   SELECT ( nTArea )

   RETURN cRet



// ----------------------------------------------
// vraca string napunjen promjenama tipa "21"
// ----------------------------------------------
FUNCTION _lit_21_get( nDoc_no, nDoc_log_no )

   LOCAL cRet := ""
   LOCAL nTArea := Select()

   SELECT doc_lit
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDoc_no ) + doclog_str( nDoc_log_no )

   DO WHILE !Eof() .AND. field->doc_no == nDoc_no ;
         .AND. field->doc_log_no == nDoc_log_no

	
      cRet += "stavka: " + AllTrim( Str( field->int_1 ) )
      cRet += "#"
      cRet += AllTrim( "artikal: " + PadR( g_art_desc( field->art_id ), 30 ) )
      cRet += "#"
      cRet += "staklo br: " + AllTrim( Str( field->int_2 ) )
      cRet += "#"
      cRet += "lom komada: " + AllTrim( Str( field->num_2 ) )
      cRet += "#"
      cRet += "opis: " + AllTrim( field->char_1 )
	
      SELECT doc_lit
	
      SKIP
   ENDDO

   SELECT ( nTArea )

   RETURN cRet


// ----------------------------------------------
// vraca string napunjen promjenama tipa "30"
// ----------------------------------------------
FUNCTION _lit_30_get( nDoc_no, nDoc_log_no )

   LOCAL cRet := ""
   LOCAL nTArea := Select()

   SELECT doc_lit
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDoc_no ) + doclog_str( nDoc_log_no )

   DO WHILE !Eof() .AND. field->doc_no == nDoc_no ;
         .AND. field->doc_log_no == nDoc_log_no

      cRet += "d.oper.: " + g_aop_desc( field->int_1 )
      cRet += "#"
      cRet += "atr.d.oper.:" + g_aop_att_desc( field->int_2 )
      cRet += ","
      cRet += "d.opis:" + AllTrim( field->char_1 )
      cRet += "#"
	
      SELECT doc_lit
	
      SKIP
   ENDDO

   SELECT ( nTArea )

   RETURN cRet




// ----------------------------------------------
// vraca string napunjen promjenama tipa "01"
// ----------------------------------------------
FUNCTION _lit_01_get( nDoc_no, nDoc_log_no )

   LOCAL cRet := ""
   LOCAL nTArea := Select()

   cRet += "Otvaranje naloga...#"
	
   SELECT ( nTArea )

   RETURN cRet


// ----------------------------------------------
// vraca string napunjen promjenama tipa "99"
// ----------------------------------------------
FUNCTION _lit_99_get( nDoc_no, nDoc_log_no )

   LOCAL cRet := ""
   LOCAL nTArea := Select()

   SELECT doc_lit
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDoc_no ) + doclog_str( nDoc_log_no )

   nStat := field->int_1

   DO CASE
   CASE nStat == 1
      cRet := "zatvoren nalog...#"
   CASE nStat == 2
      cRet := "ponisten nalog...#"
   CASE nStat == 4
      cRet := "djelimicno zatvoren nalog...#"
   CASE nStat == 5
      cRet := "zatvoren, ali nije isporucen...#"
   ENDCASE

   SELECT ( nTArea )

   RETURN cRet


// ----------------------------------------------
// vraca string napunjen promjenama tipa "10"
// ----------------------------------------------
FUNCTION _lit_10_get( nDoc_no, nDoc_log_no )

   LOCAL cRet := ""
   LOCAL nTArea := Select()

   SELECT doc_lit
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDoc_no ) + doclog_str( nDoc_log_no )

   DO WHILE !Eof() .AND. field->doc_no == nDoc_no ;
         .AND. field->doc_log_no == nDoc_log_no

      cRet += "narucioc: " + PadR( g_cust_desc( field->int_1 ), 20 )
      cRet += "#"
      cRet += "prioritet: " + AllTrim( Str( field->int_2 ) )
      cRet += "#"
	
      SELECT doc_lit
      SKIP
   ENDDO

   SELECT ( nTArea )

   RETURN cRet


// ----------------------------------------------
// vraca string napunjen promjenama tipa "11"
// ----------------------------------------------
FUNCTION _lit_11_get( nDoc_no, nDoc_log_no )

   LOCAL cRet := ""
   LOCAL nTArea := Select()

   SELECT doc_lit
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDoc_no ) + doclog_str( nDoc_log_no )

   DO WHILE !Eof() .AND. field->doc_no == nDoc_no ;
         .AND. field->doc_log_no == nDoc_log_no

      cRet += "objekat: " + AllTrim( g_obj_desc( field->int_1 ) )
      cRet += "#"
      cRet += "datum isp.: " + DToC( field->date_1 )
      cRet += "#"
      cRet += "vrij.isp.: " + AllTrim( field->char_1 )
      cRet += "#"
      cRet += "mjesto isp.: " + AllTrim( field->char_2 )
      cRet += "#"
	
      SELECT doc_lit
      SKIP
   ENDDO

   SELECT ( nTArea )

   RETURN cRet



// ----------------------------------------------
// vraca string napunjen promjenama tipa "12"
// ----------------------------------------------
FUNCTION _lit_12_get( nDoc_no, nDoc_log_no )

   LOCAL cRet := ""
   LOCAL nTArea := Select()

   SELECT doc_lit
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDoc_no ) + doclog_str( nDoc_log_no )

   DO WHILE !Eof() .AND. field->doc_no == nDoc_no ;
         .AND. field->doc_log_no == nDoc_log_no

      cRet += "kontakt.: " + g_cont_desc( field->int_1 )
      cRet += "#"
      cRet += "kont.d.opis.: " + AllTrim( field->char_1 )
      cRet += "#"
	
      SELECT doc_lit
      SKIP
   ENDDO

   SELECT ( nTArea )

   RETURN cRet



// ----------------------------------------------
// vraca string napunjen promjenama tipa "13"
// ----------------------------------------------
FUNCTION _lit_13_get( nDoc_no, nDoc_log_no )

   LOCAL cRet := ""
   LOCAL nTArea := Select()

   SELECT doc_lit
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDoc_no ) + doclog_str( nDoc_log_no )

   DO WHILE !Eof() .AND. field->doc_no == nDoc_no ;
         .AND. field->doc_log_no == nDoc_log_no

      cRet += "vr.plac: " + s_pay_id( field->int_1 )
      cRet += "#"
      cRet += "placeno: " + AllTrim( field->char_1 )
      cRet += "#"
      cRet += "opis: " + AllTrim( field->char_2 )
      cRet += "#"
	
      SELECT doc_lit
      SKIP
   ENDDO

   SELECT ( nTArea )

   RETURN cRet


