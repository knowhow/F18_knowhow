/* 
 * This file is part of the bring.out ERP, a free and open source 
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fakt.ch"
#include "common.ch"

// ------------------------------
// koristi azur_sql
// ------------------------------
function fakt_fakt_from_sql_server(algoritam)
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _x, _y
local _dat, _ids
local _fnd, _tmp_id
local _count
local _tbl
local _offset
local _step := 15000
local _retry := 3
local _order := "idfirma, idtipdok, brdok, rbr"
local _key_block

_tbl := "fmk.fakt_fakt"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
	algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update fakt_fakt: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + ;
		"idfirma, idtipdok, brdok, rbr, datdok, idpartner, dindem, zaokr, podbr, idroba, serbr, kolicina, " + ;
		"cijena, rabat, porez, txt, k1, k2, m1, idvrstep, idpm, c1, c2, c3, n1, n2, opis, dok_veza " + ;
		"FROM " +	_tbl 
  
  if algoritam == "DATE"
    _dat := get_dat_from_semaphore("fakt_fakt")
	_qry += " WHERE datdok >= " + _sql_quote(_dat)
    _key_block := {|| field->datdok }
  endif

  if algoritam == "IDS"
		_ids := get_ids_from_semaphore("fakt_fakt")
    	_qry += " WHERE "
    	if LEN(_ids) < 1
       		// nema id-ova
      		_qry += "false"
    	else
        	_sql_ids := "("
        	for _i := 1 to LEN(_ids)
            	_sql_ids += _sql_quote(_ids[_i])
            	if _i < LEN(_ids)
            		_sql_ids += ","
            	endif
        	next
        	_sql_ids += ")"
        	_qry += " (idfirma || idtipdok || brdok) IN " + _sql_ids
     	endif

        _key_block := {|| field->idfirma + field->idtipdok + field->brdok } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 


  // sredimo dbf - pobrisimo sto ne treba
  SELECT F_FAKT
  my_use ("fakt", "fakt_fakt", .f., "SEMAPHORE")

  DO CASE

	CASE algoritam == "FULL" .and. _offset==0
    	// "full" algoritam
    	log_write("datdok = nil full algoritam") 
    	ZAP

	CASE algoritam == "DATE"

    	log_write("datdok <> nil date algoritam") 
    	// "date" algoritam  - brisi sve vece od zadanog datuma
    	SET ORDER TO TAG "8"
    	// tag je "DatDok" nije DTOS(DatDok)
    	seek _dat
    	do while !eof() .and. eval(_key_block)  >= _dat 
        	// otidji korak naprijed
        	SKIP
        	_rec := RECNO()
        	SKIP -1
        	DELETE
        	GO _rec  
    	enddo

	CASE algoritam == "IDS"
    	
    	SET ORDER TO TAG "1"

		// CREATE_INDEX("1", "idFirma+Idtipdok+BrDok+Rbr", "FAKT")
    	// pobrisimo sve id-ove koji su drugi izmijenili
    	do while .t.
       		_fnd := .f.
       		for each _tmp_id in _ids
          		
          		HSEEK _tmp_id
          		
				do while !EOF() .and. EVAL(_key_block) == _tmp_id
               		skip
               		_rec := RECNO()
               		skip -1 
               		DELETE
               		go _rec 
               		_fnd := .t.
          		enddo
        	next
        	if ! _fnd 
				exit
			endif
    	enddo

  ENDCASE
  // sada je sve izbrisano

  _qry_obj := run_sql_query(_qry, _retry)

  @ _x + 4, _y + 2 SAY SECONDS() - _seconds 

  _counter := 1

  DO WHILE !_qry_obj:Eof()
    append blank
	
	/*
	_qry :=  "SELECT " + ;
		"idfirma, idtipdok, brdok, rbr, datdok, idpartner, dindem, zaokr, podbr, idroba, serbr, kolicina, " + ;
		"cijena, rabat, porez, txt, k1, k2, m1, idvrstep, idpm, c1, c2, c3, n1, n2, opis, dok_veza " + ;
		"FROM " +	_tbl 
 	*/

    replace idfirma with _qry_obj:FieldGet(1), ;
    		idtipdok with _qry_obj:FieldGet(2), ;
    		brdok with _qry_obj:FieldGet(3), ;
    		rbr with _qry_obj:FieldGet(4), ;
    		datdok with _qry_obj:FieldGet(5), ;
    		idpartner with _qry_obj:FieldGet(6), ;
    		dindem with _qry_obj:FieldGet(7), ;
    		zaokr with _qry_obj:FieldGet(8), ;
    		podbr with _qry_obj:FieldGet(9), ;
    		idroba with _qry_obj:FieldGet(10), ;
    		serbr with _qry_obj:FieldGet(11), ;
    		kolicina with _qry_obj:FieldGet(12), ;
    		cijena with _qry_obj:FieldGet(13), ;
    		rabat with _qry_obj:FieldGet(14), ;
    		porez with _qry_obj:FieldGet(15), ;
    		txt with _qry_obj:FieldGet(16), ;
    		k1 with _qry_obj:FieldGet(17), ;
    		k2 with _qry_obj:FieldGet(18), ;
    		m1 with _qry_obj:FieldGet(19), ;
    		idvrstep with _qry_obj:FieldGet(20), ;
    		idpm with _qry_obj:FieldGet(21), ;
    		c1 with _qry_obj:FieldGet(22), ;
    		c2 with _qry_obj:FieldGet(23), ;
    		c3 with _qry_obj:FieldGet(24), ;
    		n1 with _qry_obj:FieldGet(25), ;
    		n2 with _qry_obj:FieldGet(26), ;
    		opis with _qry_obj:FieldGet(27), ;
    		dok_veza with _qry_obj:FieldGet(28)
      
	_qry_obj:Skip()

    _counter++

    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
  ENDDO

  USE

next

if (gDebug > 5)
    log_write("fakt_fakt synchro cache:" + STR(SECONDS() - _seconds))
endif

//close all
 
return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_fakt_fakt_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.fakt_fakt"

if record <> nil
	_where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idtipdok=" + _sql_quote( record["id_tip_dok"]) +;
                        " and brdok=" + _sql_quote(record["br_dok"]) 
endif

DO CASE
 CASE op == "BEGIN"
    _qry := "BEGIN;"
 CASE op == "END"
    _qry := "COMMIT;"
 CASE op == "ROLLBACK"
    _qry := "ROLLBACK;"
 CASE op == "del"
    _qry := "DELETE FROM " + _tbl + ;
             " WHERE " + _where
 CASE op == "ins"
    _qry := "INSERT INTO " + _tbl + ;
				"( idfirma, idtipdok, brdok, rbr, datdok, idpartner, dindem, zaokr, podbr, idroba, serbr, kolicina, " + ;
				"cijena, rabat, porez, txt, k1, k2, m1, idvrstep, idpm, c1, c2, c3, n1, n2, opis, dok_veza ) " + ;
               "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_tip_dok"] ) + "," +; 
                            + _sql_quote( record["br_dok"] ) + "," +; 
                            + _sql_quote(STR( record["r_br"] , 3)) + "," +; 
                            + _sql_quote( record["dat_dok"] ) + "," +;
                            + _sql_quote( record["id_partner"] ) + "," +;
                            + _sql_quote( record["din_dem"] ) + "," +;
                            + _sql_quote( record["zaokr"] ) + "," +;
                            + _sql_quote(STR( record["pod_br"], 2 )) + "," +;
                            + _sql_quote( record["id_roba"] ) + "," +;
                            + _sql_quote( record["ser_br"] ) + "," +;
                            + STR( record["kolicina"], 14, 5 ) + "," +;
                            + STR( record["cijena"], 14, 5 ) + "," +;
                            + STR( record["rabat"], 8, 5 ) + "," +;
                            + STR( record["porez"], 9, 5 ) + "," +;
                            + _sql_quote( record["txt"] ) + "," +;
                            + _sql_quote( record["k1"] ) + "," +;
                            + _sql_quote( record["k2"] ) + "," +;
                            + _sql_quote( record["m1"] ) + "," +;
                            + _sql_quote( record["id_vrste_p"] ) + "," +;
                            + _sql_quote( record["id_pm"] ) + "," +;
                            + _sql_quote( record["c1"] ) + "," +;
                            + _sql_quote( record["c2"] ) + "," +;
                            + _sql_quote( record["c3"] ) + "," +;
                            + STR( record["n1"], 10, 3 ) + "," +;
                            + STR( record["n2"], 10, 3 ) + "," +;
                            + _sql_quote( record["opis"] ) + "," +;
                            + _sql_quote( record["dok_veza"] ) + " )"
                          
ENDCASE
   
_ret := _sql_query( _server, _qry)

if (gDebug > 5)
   log_write(_qry)
   log_write("_sql_query VALTYPE(_ret) = " + VALTYPE(_ret))
endif

if VALTYPE(_ret) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return _ret
else
   return .t.
endif
 

// ------------------------------
// koristi azur_sql
// ------------------------------
function fakt_doks_from_sql_server(algoritam)
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _x, _y
local _dat, _ids
local _fnd, _tmp_id
local _tbl
local _count
local _offset
local _step := 15000
local _retry := 3
local _order := "idfirma, idtipdok, brdok"
local _key_block

if algoritam == NIL
  algoritam := "FULL"
endif

_x := maxrows() - 15
_y := maxcols() - 20

_tbl := "fmk.fakt_doks"

@ _x + 1, _y + 2 SAY "update fakt_doks: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" )

for _offset := 0 to _count STEP _step

  _qry :=  "SELECT " + ;
		"idfirma, idtipdok, brdok, partner, datdok, dindem, iznos, rabat, rezerv, m1, idpartner, " + ;
		"idvrstep, datpl, idpm, dok_veza, oper_id, fisc_rn, dat_isp, dat_otpr, dat_val " + ;
		"FROM " + _tbl

  if algoritam == "DATE"
      _dat = get_dat_from_semaphore( "fakt_doks" )
      _qry += " WHERE datdok >= " + _sql_quote(_dat)
      _key_block := { || field->datdok }
  endif

  if algoritam == "IDS"
		_ids := get_ids_from_semaphore( "fakt_doks" )
    	_qry += " WHERE "
    	if LEN(_ids) < 1
       		// nema id-ova
      		_qry += "false"
    	else
        	_sql_ids := "("
        	for _i := 1 to LEN(_ids)
            	_sql_ids += _sql_quote(_ids[_i])
            	if _i < LEN(_ids)
            		_sql_ids += ","
            	endif
        	next
        	_sql_ids += ")"
        	_qry += " (idfirma || idtipdok || brdok) IN " + _sql_ids
     	endif

        _key_block := {|| field->idfirma + field->idtipdok + field->brdok } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 


  SELECT F_FAKT_DOKS
  my_use ("fakt_doks", "fakt_doks", .f., "SEMAPHORE")

  DO CASE

	CASE algoritam == "FULL"
    	
		// "full" algoritam
    	log_write("dat_dok = nil full algoritam") 
	    ZAP
	
	CASE algoritam == "DATE"

    	log_write("dat_dok <> nil date algoritam") 
    	// "date" algoritam  - brisi sve vece od zadanog datuma
    	SET ORDER TO TAG "5"
    	// tag je "DatDok" nije DTOS(DatDok)
    	seek _dat
    	do while !eof() .and. EVAL( _key_block ) >= _dat 
        	// otidji korak naprijed
        	SKIP
        	_rec := RECNO()
        	SKIP -1
        	DELETE
        	GO _rec  
    	enddo

	CASE algoritam == "IDS"
    	
		SET ORDER TO TAG "1"

		// CREATE_INDEX("1", "idFirma+IdTipDok+BrDok", "FAKT_DOKS")
    	// pobrisimo sve id-ove koji su drugi izmijenili
    	do while .t.
       		_fnd := .f.
       		for each _tmp_id in _ids
          		
          		HSEEK _tmp_id
          		
				do while !EOF() .and. EVAL( _key_block ) == _tmp_id 
               		skip
               		_rec := RECNO()
               		skip -1 
               		DELETE
               		go _rec 
               		_fnd := .t.
          		enddo
        	next
        	if ! _fnd 
				exit
			endif
    	enddo

  ENDCASE

  _qry_obj := run_sql_query( _qry, _retry )

  @ _x + 4, _y + 2 SAY SECONDS() - _seconds 

  _counter := 1

  DO WHILE !_qry_obj:Eof()
    append blank
   
	replace idfirma with _qry_obj:FieldGet(1), ;
    		idtipdok with _qry_obj:FieldGet(2), ;
    		brdok with _qry_obj:FieldGet(3), ;
    		partner with _qry_obj:FieldGet(4), ;
    		datdok with _qry_obj:FieldGet(5), ;
    		dindem with _qry_obj:FieldGet(6), ;
    		iznos with _qry_obj:FieldGet(7), ;
    		rabat with _qry_obj:FieldGet(8), ;
    		rezerv with _qry_obj:FieldGet(9), ;
    		m1 with _qry_obj:FieldGet(10), ;
    		idpartner with _qry_obj:FieldGet(11), ;
    		idvrstep with _qry_obj:FieldGet(12), ;
    		datpl with _qry_obj:FieldGet(13), ;
    		idpm with _qry_obj:FieldGet(14), ;
    		dok_veza with _qry_obj:FieldGet(15), ;
    		oper_id with _qry_obj:FieldGet(16), ;
    		fisc_rn with _qry_obj:FieldGet(17), ;
    		dat_isp with _qry_obj:FieldGet(18), ;
    		dat_otpr with _qry_obj:FieldGet(19), ;
    		dat_val with _qry_obj:FieldGet(20)

    _qry_obj:Skip()

    _counter++

    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
  ENDDO

  USE

next

if (gDebug > 5)
    log_write("fakt_doks synchro cache:" + STR(SECONDS() - _seconds))
endif

//close all
 
return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_fakt_doks_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()


_tbl := "fmk.fakt_doks"

if record <> nil
	_where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idtipdok=" + _sql_quote( record["id_tip_dok"]) +;
                        " and brdok=" + _sql_quote(record["br_dok"]) 
endif

DO CASE
 CASE op == "BEGIN"
    _qry := "BEGIN;"
 CASE op == "END"
    _qry := "COMMIT;"
 CASE op == "ROLLBACK"
    _qry := "ROLLBACK;"
 CASE op == "del"
    _qry := "DELETE FROM " + _tbl + ;
             " WHERE " + _where
 CASE op == "ins"
    _qry := "INSERT INTO " + _tbl + ;
				"( idfirma, idtipdok, brdok, partner, datdok, dindem, iznos, rabat, rezerv, m1, idpartner, " + ;
				"idvrstep, datpl, idpm, dok_veza, oper_id, fisc_rn, dat_isp, dat_otpr, dat_val ) " + ;
                "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_tip_dok"] ) + "," +; 
                            + _sql_quote( record["br_dok"] ) + "," +; 
                            + _sql_quote( record["partner"] ) + "," +;
                            + _sql_quote( record["dat_dok"] ) + "," +;
                            + _sql_quote( record["din_dem"] ) + "," +;
							+ _sql_quote( STR( record["iznos"], 12, 3 )) + "," +;
							+ _sql_quote( STR( record["rabat"], 12, 3 )) + "," +;
                            + _sql_quote( record["rezerv"] ) + "," +;
                            + _sql_quote( record["m1"] ) + "," +;
                            + _sql_quote( record["id_partner"] ) + "," +;
                            + _sql_quote( record["id_vrste_p"] ) + "," +;
                            + _sql_quote( record["dat_pl"] ) + "," +;
                            + _sql_quote( record["id_pm"] ) + "," +;
                            + _sql_quote( record["dok_veza"] ) + "," +;
                            + _sql_quote( STR( record["oper_id"], 10, 0 ) ) + "," +;
                            + _sql_quote( STR( record["fisc_rn"], 10, 0 ) ) + "," +;
                            + _sql_quote( record["dat_isp"] ) + "," +;
                            + _sql_quote( record["dat_otpr"] ) + "," +;
                            + _sql_quote( record["dat_val"] ) + " )"
                          
END CASE
   
_ret := _sql_query( _server, _qry)

if (gDebug > 5)
   log_write(_qry)
   log_write("_sql_query VALTYPE(_ret) = " + VALTYPE(_ret))
endif

if VALTYPE(_ret) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return _ret
else
   return .t.
endif
 


// ------------------------------
// koristi azur_sql
// ------------------------------
function fakt_doks2_from_sql_server(algoritam)
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _x, _y
local _dat, _ids
local _fnd, _tmp_id
local _tbl
local _count
local _offset
local _step := 15000
local _retry := 3
local _order := "idfirma, idtipdok, brdok"
local _key_block

if algoritam == NIL
  algoritam := "FULL"
endif

_x := maxrows() - 15
_y := maxcols() - 20

_tbl := "fmk.fakt_doks2"

@ _x + 1, _y + 2 SAY "update fakt_doks2: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" )

for _offset := 0 to _count STEP _step

  _qry :=  "SELECT " + ;
		"idfirma, idtipdok, brdok, k1, k2, k3, k4, k5, n1, n2 " + ;
		"FROM " + _tbl

  if algoritam == "DATE"
      _dat = get_dat_from_semaphore( "fakt_doks2" )
      _qry += " WHERE datdok >= " + _sql_quote(_dat)
      _key_block := { || field->datdok }
  endif

  if algoritam == "IDS"
		_ids := get_ids_from_semaphore( "fakt_doks2" )
    	_qry += " WHERE "
    	if LEN(_ids) < 1
       		// nema id-ova
      		_qry += "false"
    	else
        	_sql_ids := "("
        	for _i := 1 to LEN(_ids)
            	_sql_ids += _sql_quote(_ids[_i])
            	if _i < LEN(_ids)
            		_sql_ids += ","
            	endif
        	next
        	_sql_ids += ")"
        	_qry += " (idfirma || idtipdok || brdok) IN " + _sql_ids
     	endif

        _key_block := {|| field->idfirma + field->idtipdok + field->brdok } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 


  SELECT F_FAKT_DOKS2
  my_use ("fakt_doks2", "fakt_doks2", .f., "SEMAPHORE")

  DO CASE

	CASE algoritam == "FULL"
    	
		// "full" algoritam
    	log_write("dat_dok = nil full algoritam") 
	    ZAP
	
	CASE algoritam == "DATE"

    	log_write("dat_dok <> nil date algoritam") 
    	// "date" algoritam  - brisi sve vece od zadanog datuma
    	SET ORDER TO TAG "5"
    	// tag je "DatDok" nije DTOS(DatDok)
    	seek _dat
    	do while !eof() .and. EVAL( _key_block ) >= _dat 
        	// otidji korak naprijed
        	SKIP
        	_rec := RECNO()
        	SKIP -1
        	DELETE
        	GO _rec  
    	enddo

	CASE algoritam == "IDS"
    	
		SET ORDER TO TAG "1"

		// CREATE_INDEX("1", "idFirma+IdTipDok+BrDok", "FAKT_DOKS2")
    	// pobrisimo sve id-ove koji su drugi izmijenili
    	do while .t.
       		_fnd := .f.
       		for each _tmp_id in _ids
          		
          		HSEEK _tmp_id
          		
				do while !EOF() .and. EVAL( _key_block ) == _tmp_id 
               		skip
               		_rec := RECNO()
               		skip -1 
               		DELETE
               		go _rec 
               		_fnd := .t.
          		enddo
        	next
        	if ! _fnd 
				exit
			endif
    	enddo

  ENDCASE

  _qry_obj := run_sql_query( _qry, _retry )

  @ _x + 4, _y + 2 SAY SECONDS() - _seconds 

  _counter := 1

  DO WHILE !_qry_obj:Eof()
    append blank
   
	replace idfirma with _qry_obj:FieldGet(1), ;
    		idtipdok with _qry_obj:FieldGet(2), ;
    		brdok with _qry_obj:FieldGet(3), ;
    		k1 with _qry_obj:FieldGet(4), ;
    		k2 with _qry_obj:FieldGet(5), ;
    		k3 with _qry_obj:FieldGet(6), ;
    		k4 with _qry_obj:FieldGet(7), ;
    		k5 with _qry_obj:FieldGet(8), ;
    		n1 with _qry_obj:FieldGet(9), ;
    		n2 with _qry_obj:FieldGet(10)

    _qry_obj:Skip()

    _counter++

    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
  ENDDO

  USE

next

if (gDebug > 5)
    log_write("fakt_doks2 synchro cache:" + STR(SECONDS() - _seconds))
endif

//close all
 
return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_fakt_doks2_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()


_tbl := "fmk.fakt_doks2"

if record <> nil
	_where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idtipdok=" + _sql_quote( record["id_tip_dok"]) +;
                        " and brdok=" + _sql_quote(record["br_dok"]) 
endif

DO CASE
 CASE op == "BEGIN"
    _qry := "BEGIN;"
 CASE op == "END"
    _qry := "COMMIT;"
 CASE op == "ROLLBACK"
    _qry := "ROLLBACK;"
 CASE op == "del"
    _qry := "DELETE FROM " + _tbl + ;
             " WHERE " + _where
 CASE op == "ins"
    _qry := "INSERT INTO " + _tbl + ;
				"( idfirma, idtipdok, brdok, k1, k2, k3, k4, k5, n1, n2 ) " + ;
                "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_tip_dok"] ) + "," +; 
                            + _sql_quote( record["br_dok"] ) + "," +; 
                            + _sql_quote( record["k1"] ) + "," +;
                            + _sql_quote( record["k2"] ) + "," +;
                            + _sql_quote( record["k3"] ) + "," +;
                            + _sql_quote( record["k4"] ) + "," +;
                            + _sql_quote( record["k5"] ) + "," +;
							+ _sql_quote( STR( record["n1"], 15, 2 )) + "," +;
							+ _sql_quote( STR( record["n2"], 15, 2 )) + ")"
                          
END CASE
   
_ret := _sql_query( _server, _qry)

if (gDebug > 5)
   log_write(_qry)
   log_write("_sql_query VALTYPE(_ret) = " + VALTYPE(_ret))
endif

if VALTYPE(_ret) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return _ret
else
   return .t.
endif
 




