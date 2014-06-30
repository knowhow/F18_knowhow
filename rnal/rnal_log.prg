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


#include "rnal.ch"


STATIC __doc_no



/*
   Opis: logiranje stavki novog naloga prilikom ažuriranja
         podaci naloga, podaci stavki naloga, podaci operacija
*/
FUNCTION rnal_logiraj_novi_nalog()

   LOCAL cDesc := ""
   LOCAL aArr

   SELECT _docs
   GO TOP

   __doc_no := field->doc_no

   cDesc := "Inicijalni osnovni podaci"

   aArr := podaci_naloga_za_log_osnovni( field->cust_id, field->doc_priori )

   logiraj_osnovne_podatke_naloga( __doc_no, cDesc, nil, aArr )

   SELECT _docs
   GO TOP

   cDesc := "Inicijalni podaci isporuke"
   aArr := podaci_naloga_za_log_isporuka( field->obj_id, ;
      field->doc_dvr_da, ;
      field->doc_dvr_ti, ;
      field->doc_ship_p )
		
   logiraj_podatke_isporuke_za_nalog( __doc_no, cDesc, nil, aArr )

   SELECT _docs
   GO TOP

   cDesc := "Inicijalni podaci kontakta"
   aArr := podaci_naloga_za_log_kontakti( field->cont_id, field->cont_add_d )

   logiraj_podatke_kontakta_naloga( __doc_no, cDesc, nil, aArr )

   SELECT _docs
   GO TOP

   cDesc := "Inicijalni podaci placanja"
   aArr := podaci_naloga_za_log_placanje( field->doc_pay_id, field->doc_paid, field->doc_pay_de )

   logiraj_podatke_placanja_za_nalog( __doc_no, cDesc, nil, aArr )

   SELECT _doc_it
   GO TOP

   cDesc := "Inicijalni podaci stavki"
   logiraj_stavke_naloga( __doc_no, cDesc )

   cDesc := "Inicijalni podaci dodatnih operacija"
   logiraj_dodatne_operacije_naloga( __doc_no, cDesc )

   RETURN



// -------------------------------------------------
// puni matricu sa osnovnim podacima dokumenta
// aArr = { customer_id, doc_priority }
// -------------------------------------------------
FUNCTION podaci_naloga_za_log_osnovni( nCustId, nPriority )

   LOCAL aArr := {}

   AAdd( aArr, { nCustId, nPriority } )

   RETURN aArr


// -------------------------------------------------
// puni matricu sa podacima placanja
// aArr = { doc_pay_id, doc_paid, doc_pay_desc }
// -------------------------------------------------
FUNCTION podaci_naloga_za_log_placanje( nPayId, cDocPaid, cDocPayDesc )

   LOCAL aArr := {}

   AAdd( aArr, { nPayId, cDocPaid, cDocPayDesc } )

   RETURN aArr


// -------------------------------------------------
// puni matricu sa podacima isporuke
// aArr = { doc_dvr_date, doc_dvr_time, doc_ship_place }
// -------------------------------------------------
FUNCTION podaci_naloga_za_log_isporuka( nObj_id, dDate, cTime, cPlace )

   LOCAL aArr := {}

   AAdd( aArr, { nObj_id, dDate, cTime, cPlace } )

   RETURN aArr


// -------------------------------------------------
// puni matricu sa podacima kontakta
// aArr = { cont_id, cont_add_desc }
// -------------------------------------------------
FUNCTION podaci_naloga_za_log_kontakti( nCont_id, cCont_desc )

   LOCAL aArr := {}

   AAdd( aArr, { nCont_id, cCont_desc } )

   RETURN aArr



// ----------------------------------------------------
// logiranje osnovnih podataka
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija
// aMain - matrica sa osnovnim podacima
// ----------------------------------------------------
FUNCTION logiraj_osnovne_podatke_naloga( nDoc_no, cDesc, cAction, aArr )

   LOCAL nDoc_log_no
   LOCAL cDoc_log_type

   IF ( cAction == nil )
      cAction := "+"
   ENDIF

   cDoc_log_type := "10"
   nDoc_log_no := _inc_log_no( nDoc_no )

   _d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
   _lit_10_insert( cAction, nDoc_no, nDoc_log_no, aArr )

   RETURN


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



// ----------------------------------------------------
// logiranje podataka isporuke
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija
// aArr - matrica sa podacima
// ----------------------------------------------------
FUNCTION logiraj_podatke_isporuke_za_nalog( nDoc_no, cDesc, cAction, aArr )

   LOCAL nDoc_log_no
   LOCAL cDoc_log_type

   IF ( cAction == nil )
      cAction := "+"
   ENDIF

   cDoc_log_type := "11"
   nDoc_log_no := _inc_log_no( nDoc_no )

   _d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
   _lit_11_insert( cAction, nDoc_no, nDoc_log_no, aArr )

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


// ----------------------------------------------------
// logiranje podataka kontakata
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija
// aArr - matrica sa podacima
// ----------------------------------------------------
FUNCTION logiraj_podatke_kontakta_naloga( nDoc_no, cDesc, cAction, aArr )

   LOCAL nDoc_log_no
   LOCAL cDoc_log_type

   IF ( cAction == nil )
      cAction := "+"
   ENDIF

   cDoc_log_type := "12"
   nDoc_log_no := _inc_log_no( nDoc_no )

   _d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
   _lit_12_insert( cAction, nDoc_no, nDoc_log_no, aArr )

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


// ----------------------------------------------------
// logiranje podataka placanja
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija
// aArr - matrica sa osnovnim podacima
// ----------------------------------------------------
FUNCTION logiraj_podatke_placanja_za_nalog( nDoc_no, cDesc, cAction, aArr )

   LOCAL nDoc_log_no
   LOCAL cDoc_log_type

   IF ( cAction == nil )
      cAction := "+"
   ENDIF

   cDoc_log_type := "13"
   nDoc_log_no := _inc_log_no( nDoc_no )

   _d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
   _lit_13_insert( cAction, nDoc_no, nDoc_log_no, aArr )

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



// ----------------------------------------------------
// logiranje podataka o lomu...
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija
// ----------------------------------------------------
FUNCTION log_damage( nDoc_no, cDesc, cAction )

   LOCAL nDoc_log_no
   LOCAL cDoc_log_type

   SELECT _tmp1

   IF RecCount() == 0
      RETURN
   ENDIF

   IF ( cAction == nil )
      cAction := "+"
   ENDIF

   IF !f18_lock_tables( { "doc_log", "doc_lit" } )
      RETURN
   ENDIF

   sql_table_update( nil, "BEGIN" )


   cDoc_log_type := "21"
   nDoc_log_no := _inc_log_no( nDoc_no )

   _d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )

   SELECT _tmp1
   GO TOP

   DO WHILE !Eof()

      IF field->art_marker <> "*"
         SKIP
         LOOP
      ENDIF
	
      _lit_21_insert( cAction, nDoc_no, nDoc_log_no, ;
         field->art_id,  ;
         field->art_desc, ;
         field->glass_no, ;
         field->doc_it_no, ;
         field->doc_it_qtt, ;
         field->damage )
	
      SELECT _tmp1
      SKIP
	
   ENDDO


   f18_free_tables( { "doc_log", "doc_lit" } )
   sql_table_update( nil, "END" )

   RETURN



// ----------------------------------------------------
// logiranje podataka stavki naloga
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija
// ----------------------------------------------------
FUNCTION logiraj_stavke_naloga( nDoc_no, cDesc, cAction )

   LOCAL nDoc_log_no
   LOCAL cDoc_log_type

   SELECT _doc_it
   IF RecCount() == 0
      RETURN
   ENDIF

   IF ( cAction == nil )
      cAction := "+"
   ENDIF

   cDoc_log_type := "20"
   nDoc_log_no := _inc_log_no( nDoc_no )

   _d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )

   SELECT _doc_it
   GO TOP
   SEEK docno_str( nDoc_no )

   DO WHILE !Eof() .AND. field->doc_no == nDoc_no

      _lit_20_insert( cAction, nDoc_no, nDoc_log_no, ;
         field->art_id,  ;
         field->doc_it_des, ;
         field->doc_it_sch, ;
         field->doc_it_qtt,  ;
         field->doc_it_hei, ;
         field->doc_it_wid )
	
      SELECT _doc_it
      SKIP
	
   ENDDO

   RETURN


// ----------------------------------------------------
// logiranje podataka dodatnih operacija
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija
// ----------------------------------------------------
FUNCTION logiraj_dodatne_operacije_naloga( nDoc_no, cDesc, cAction )

   LOCAL nDoc_log_no
   LOCAL cDoc_log_type

   SELECT _doc_ops
   IF RecCount() == 0
      RETURN
   ENDIF

   IF ( cAction == nil )
      cAction := "+"
   ENDIF

   cDoc_log_type := "30"
   nDoc_log_no := _inc_log_no( nDoc_no )

   _d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )

   SELECT _doc_ops
   GO TOP
   SEEK docno_str( nDoc_no )

   DO WHILE !Eof() .AND. field->doc_no == nDoc_no

      _lit_30_insert( cAction, nDoc_no, nDoc_log_no, ;
         field->aop_id,  ;
         field->aop_att_id,  ;
         field->doc_op_des )
	
      SELECT _doc_ops
      SKIP
	
   ENDDO

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


// ----------------------------------------------------
// logiranje zatvaranje
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija
// ----------------------------------------------------
FUNCTION log_closed( nDoc_no, cDesc, nDoc_status )

   LOCAL nDoc_log_no
   LOCAL cDoc_log_type
   LOCAL cAction := "+"

   DO CASE

   CASE nDoc_status == 1
      // closed
      cDoc_log_type := "99"
   CASE nDoc_status == 2
      // rejected
      cDoc_log_type := "97"
   CASE nDoc_status == 4
      // partialy done
      cDoc_log_type := "98"
   CASE nDoc_status == 5
      // closed but not delivered
      cDoc_log_type := "96"

   ENDCASE

   IF !f18_lock_tables( { "doc_log", "doc_lit" } )
      MsgBeep( "Problem sa logiranjem tabela !!!" )
      RETURN
   ENDIF

   sql_table_update( nil, "BEGIN" )

   nDoc_log_no := _inc_log_no( nDoc_no )

   _d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
   _lit_99_insert( cAction, nDoc_no, nDoc_log_no, nDoc_status )

   f18_free_tables( { "doc_log", "doc_lit" } )
   sql_table_update( nil, "END" )

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



FUNCTION rnal_logiraj_promjenu_naloga( nDoc_no, cDesc )

   LOCAL nTArea := Select()

   IF cDesc == nil
      cDesc := ""
   ENDIF

   SELECT _docs
   SET FILTER TO
   SELECT _doc_it
   SET FILTER TO
   SELECT _doc_ops
   SET FILTER TO
   SELECT docs
   SET FILTER TO
   SELECT doc_ops
   SET FILTER TO
   SELECT doc_it
   SET FILTER TO

   // delta stavki dokumenta
   _doc_it_delta( nDoc_no, cDesc )

   // delta dodatnih operacija dokumenta
   _doc_op_delta( nDoc_no, cDesc )

   SELECT ( nTArea )

   RETURN 0


// -------------------------------------------------
// function _doc_it_delta() - delta stavki dokumenta
// nDoc_no - broj naloga
// funkcija gleda _doc_it na osnovu doc_it i trazi
// 1. stavke koje nisu iste
// 2. stavke koje su izbrisane
// -------------------------------------------------
STATIC FUNCTION _doc_it_delta( nDoc_no, cDesc )

   LOCAL nDoc_log_no
   LOCAL cDoc_log_type := "20"
   LOCAL cAction
   LOCAL lLogAppend := .F.

   // uzmi sljedeci broj DOC_LOG
   nDoc_log_no := _inc_log_no( nDoc_no )

   // pozicioniraj se na trazeni dokument
   SELECT doc_it
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDoc_no )

   DO WHILE !Eof() .AND. field->doc_no == nDoc_no

      nDoc_it_no := field->doc_it_no
      nArt_id := field->art_id
      nDoc_it_qtty := field->doc_it_qtt
      nDoc_it_heigh := field->doc_it_hei
      nDoc_it_width := field->doc_it_wid
      cDoc_it_desc := field->doc_it_des
      cDoc_it_sch := field->doc_it_sch
	
      // DOC_IT -> _DOC_IT - provjeri da li je sta brisano
      // akcija "-"
	
      IF !item_exist( nDoc_no, nDoc_it_no, nArt_id, .F. )
		
         cAction := "-"
		
         _lit_20_insert( cAction, nDoc_no, nDoc_log_no, ;
            nArt_id, ;
            cDoc_it_desc, ;
            cDoc_it_sch, ;
            nDoc_it_qtty, ;
            nDoc_it_heigh, ;
            nDoc_it_width )
			
         lLogAppend := .T.
		
         SELECT doc_it
		
         SKIP
         LOOP
		
      ENDIF

      // DOC_IT -> _DOC_IT - da li je sta mjenjano od podataka
      // akcija "E"
	
      IF !item_value( nDoc_no, nDoc_it_no, nArt_id, ;
            nDoc_it_qtty, ;
            nDoc_it_heigh, ;
            nDoc_it_width, .F. )
		
         cAction := "E"
		
         _lit_20_insert( cAction, nDoc_no, nDoc_log_no, ;
            _doc_it->art_id, ;
            _doc_it->doc_it_des, ;
            _doc_it->doc_it_sch, ;
            _doc_it->doc_it_qtt, ;
            _doc_it->doc_it_hei, ;
            _doc_it->doc_it_wid )
	
         lLogAppend := .T.
      ENDIF
	
      SELECT doc_it
	
      SKIP
   ENDDO

   // pozicioniraj se na _DOC_IT
   SELECT _doc_it
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDoc_no )

   DO WHILE !Eof() .AND. field->doc_no == nDoc_no

      nDoc_it_no := field->doc_it_no
      nArt_id := field->art_id
      nDoc_it_qtty := field->doc_it_qtt
      nDoc_it_heigh := field->doc_it_hei
      nDoc_it_width := field->doc_it_wid
      cDoc_it_desc := field->doc_it_des
      cDoc_it_sch := field->doc_it_sch
	
      // _DOC_IT -> DOC_IT, da li stavka postoji u kumulativu
      // akcija "+"
	
      IF !item_exist( nDoc_no, nDoc_it_no, nArt_id, .T. )
		
         cAction := "+"
		
         _lit_20_insert( cAction, nDoc_no, nDoc_log_no, ;
            nArt_id, ;
            cDoc_it_desc, ;
            cDoc_it_sch, ;
            nDoc_it_qtty, ;
            nDoc_it_heigh, ;
            nDoc_it_width )

         lLogAppend := .T.
	
      ENDIF
	
      SELECT _doc_it
	
      SKIP
   ENDDO

   // bilo je promjena dodaj novi log zapis
   IF lLogAppend
      _d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
   ELSE
      // cDesc := "Nije bilo nikakvih promjena..."
      // _d_log_insert(nDoc_no, nDoc_log_no, cDoc_log_type, cDesc)
   ENDIF

   RETURN



// -------------------------------------------------
// function _doc_op_delta() - delta d.operacija
// nDoc_no - broj naloga
// funkcija gleda _doc_ops na osnovu doc_ops i trazi
// 1. stavke koje nisu iste
// 2. stavke koje su izbrisane
// -------------------------------------------------
STATIC FUNCTION _doc_op_delta( nDoc_no, cDesc )

   LOCAL nDoc_log_no
   LOCAL cDoc_log_type := "30"
   LOCAL cAction
   LOCAL lLogAppend := .F.

   // uzmi sljedeci broj DOC_LOG
   nDoc_log_no := _inc_log_no( nDoc_no )

   // pozicioniraj se na trazeni dokument
   SELECT doc_ops
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDoc_no )

   DO WHILE !Eof() .AND. field->doc_no == nDoc_no

      nDoc_it_no := field->doc_it_no
      nDoc_op_no := field->doc_op_no
	
      nAop_id := field->aop_id
      nAop_att_id := field->aop_att_id
      cDoc_op_desc := field->doc_op_des
	
      // DOC_OPS -> _DOC_OPS - provjeri da li je sta brisano
      // akcija "-"
	
      IF !aop_exist( nDoc_no, nDoc_it_no, nDoc_op_no, nAop_id, nAop_att_id, .F. )
		
         cAction := "-"
		
         _lit_30_insert( cAction, nDoc_no, nDoc_log_no, ;
            nAop_id, ;
            nAop_att_id, ;
            cDoc_op_desc )
			
         lLogAppend := .T.
		
         SELECT doc_ops
		
         SKIP
         LOOP
		
      ENDIF

      // DOC_OPS -> _DOC_OPS - da li je sta mjenjano od podataka
      // akcija "E"
	
      IF !aop_value( nDoc_no, nDoc_it_no, nDoc_op_no, nAop_id, ;
            nAop_att_id, ;
            cDoc_op_desc, .F. )
		
         cAction := "E"
		
         _lit_30_insert( cAction, nDoc_no, nDoc_log_no, ;
            _doc_ops->aop_id, ;
            _doc_ops->aop_att_id, ;
            _doc_ops->doc_op_des )
	
         lLogAppend := .T.
      ENDIF
	
      SELECT doc_ops
	
      SKIP
   ENDDO

   // pozicioniraj se na _DOC_IT
   SELECT _doc_ops
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDoc_no )

   DO WHILE !Eof() .AND. field->doc_no == nDoc_no

      nDoc_it_no := field->doc_it_no
      nDoc_op_no := field->doc_op_no
      nAop_id := field->aop_id
      nAop_att_id := field->aop_att_id
      cDoc_op_desc := field->doc_op_des
	
      // _DOC_OPS -> DOC_OPS, da li stavka postoji u kumulativu
      // akcija "+"
	
      IF !aop_exist( nDoc_no, nDoc_it_no, nDoc_op_no, nAop_id, nAop_att_id, .T. )
		
         cAction := "+"
		
         _lit_30_insert( cAction, nDoc_no, nDoc_log_no, ;
            nAop_id, ;
            nAop_att_id, ;
            cDoc_op_desc )

         lLogAppend := .T.
	
      ENDIF
	
      SELECT _doc_ops
	
      SKIP
   ENDDO

   // bilo je promjena dodaj novi log zapis
   IF lLogAppend

      _d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
	
   ELSE

      // cDesc := "Nije bilo promjena ..."
      // _d_log_insert(nDoc_no, nDoc_log_no, cDoc_log_type, cDesc)
	
   ENDIF

   RETURN



// --------------------------------------
// da li postoji item u tabelama
// _DOC_IT, DOC_IT
// --------------------------------------
STATIC FUNCTION item_exist( nDoc_no, nDoc_it_no, nArt_id, lKumul )

   LOCAL nF_DOC_IT := F__DOC_IT
   LOCAL nTArea := Select()
   LOCAL nTRec := RecNo()
   LOCAL lRet := .F.

   IF ( lKumul == nil )
      lKumul := .F.
   ENDIF

   IF ( lKumul == .T. )
      nF_DOC_IT := F_DOC_IT
   ENDIF

   SELECT ( nF_DOC_IT )
   SET ORDER TO TAG "1"
   GO TOP

   SEEK docno_str( nDoc_no ) + docit_str( nDoc_it_no ) + artid_str( nArt_id )

   IF Found()
      lRet := .T.
   ENDIF

   SELECT ( nTArea )
   GO ( nTRec )

   RETURN lRet



// --------------------------------------
// da li je stavka sirovina ista....
// --------------------------------------
STATIC FUNCTION item_value( nDoc_no, nDoc_it_no, nArt_id, ;
      nDoc_it_qtty, nDoc_it_heigh, nDoc_it_width, lKumul )

   LOCAL nF_DOC_IT := F__DOC_IT
   LOCAL nTArea := Select()
   LOCAL nTRec := RecNo()
   LOCAL lRet := .F.

   IF ( lKumul == nil )
      lKumul := .F.
   ENDIF

   IF ( lKumul == .T. )
      nF_DOC_IT := F_DOC_IT
   ENDIF

   SELECT ( nF_DOC_IT )
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDoc_no ) + docit_str( nDoc_it_no ) + artid_str( nArt_id )

   IF ( field->doc_it_qtt == nDoc_it_qtty ) .AND. ;
         ( field->doc_it_hei == nDoc_it_heigh ) .AND. ;
         ( field->doc_it_wid == nDoc_it_width )
      lRet := .T.
   ENDIF

   SELECT ( nTArea )
   GO ( nTRec )

   RETURN lRet



// --------------------------------------
// da li postoji item u tabelama
// _DOC_OPS, DOC_OPS
// --------------------------------------
STATIC FUNCTION aop_exist( nDoc_no, nDoc_it_no, nDoc_op_no, ;
      nAop_id, nAop_att_id, lKumul )

   LOCAL nF_DOC_OPS := F__DOC_OPS
   LOCAL nTArea := Select()
   LOCAL nTRec := RecNo()
   LOCAL lRet := .F.

   IF ( lKumul == nil )
      lKumul := .F.
   ENDIF

   IF ( lKumul == .T. )
      nF_DOC_OPS := F_DOC_OPS
   ENDIF

   SELECT ( nF_DOC_OPS )
   SET ORDER TO TAG "1"
   GO TOP

   SEEK docno_str( nDoc_no ) + ;
      docit_str( nDoc_it_no ) + ;
      docop_str( nDoc_op_no ) + ;
      aopid_str( nAop_id ) + ;
      aopid_str( nAop_att_id )

   IF Found()
      lRet := .T.
   ENDIF

   SELECT ( nTArea )
   GO ( nTRec )

   RETURN lRet



// --------------------------------------
// da li je stavka operacije ista....
// --------------------------------------
STATIC FUNCTION aop_value( nDoc_no, nDoc_it_no, nDoc_op_no, nAop_id, ;
      nAop_att_id, nDoc_op_desc, lKumul )

   LOCAL nF_DOC_OPS := F__DOC_OPS
   LOCAL nTArea := Select()
   LOCAL nTRec := RecNo()
   LOCAL lRet := .F.

   IF ( lKumul == nil )
      lKumul := .F.
   ENDIF

   IF ( lKumul == .T. )
      nF_DOC_OPS := F_DOC_OPS
   ENDIF

   SELECT ( nF_DOC_OPS )
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDoc_no ) + ;
      docit_str( nDoc_it_no ) + ;
      docop_str( nDoc_op_no )

   IF ( field->aop_id == nAop_id ) .AND. ;
         ( field->aop_att_id == nAop_att_id ) .AND. ;
         ( field->doc_op_des == nDoc_op_desc )
      lRet := .T.
   ENDIF

   SELECT ( nTArea )
   GO ( nTRec )

   RETURN lRet





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
