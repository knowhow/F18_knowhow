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

#include "kalk.ch"
#include "common.ch"

// ------------------------------
// koristi azur_sql
// ------------------------------
function kalk_kalk_from_sql_server(algoritam)
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
local _order := "idfirma, idvd, brdok, rbr, mkonto, pkonto"
local _key_block

_tbl := "fmk.kalk_kalk"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
	algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update kalk_kalk: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

for _offset := 0 to _count STEP _step 

_qry :=  "SELECT " + ;
		"idfirma, idvd, brdok, rbr, datdok, brfaktp, datfaktp, idroba, idkonto, idkonto2, idzaduz, " + ;
		"idzaduz2, idpartner, datkurs, kolicina, gkolicina, gkolicin2, fcj, " + ;
		"fcj2, fcj3, trabat, rabat, tprevoz, prevoz, tprevoz2, prevoz2, tbanktr, banktr, " + ;
		"tspedtr, spedtr, tcardaz, cardaz, tzavtr, zavtr, nc, tmarza, marza, vpc, rabatv, " + ;
		"vpcsap, tmarza2, marza2, mpc, idtarifa, mpcsapp, mkonto, pkonto, roktr, mu_i, pu_i, " + ;
		"error, podbr " + ;
		"FROM " +	_tbl 
  
if algoritam == "DATE"
    _dat := get_dat_from_semaphore("kalk_kalk")
	_qry += " WHERE datdok >= " + _sql_quote(_dat)
    _key_block := {|| field->dat_dok }
endif

if algoritam == "IDS"
		_ids := get_ids_from_semaphore("kalk_kalk")
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
        	_qry += " (idfirma || idvd || brdok) IN " + _sql_ids
     	endif

        _key_block := {|| field->idfirma + field->idvd + field->brdok } 
endif

_qry += " ORDER BY " + _order
_qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 


// sredimo dbf - pobrisimo sto ne treba
SELECT F_KALK
my_use ("kalk", "kalk_kalk", .f., "SEMAPHORE")

DO CASE

	CASE algoritam == "FULL" .and. _offset==0
    	// "full" algoritam
    	log_write("dat_dok = nil full algoritam") 
    	ZAP

	CASE algoritam == "DATE"

    	log_write("dat_dok <> nil date algoritam") 
    	// "date" algoritam  - brisi sve vece od zadanog datuma
    	SET ORDER TO TAG "DAT"
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

		// CREATE_INDEX("1", "idFirma+IdVd+BrDok+Rbr", "KALK")
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

/*
???? otkud ovdje dva x query ?!
_qry_obj := _server:Query( _qry )
if _qry_obj:NetErr()
	Msgbeep("ajoj :" + _qry_obj:ErrorMsg())
	QUIT
endif
*/

_qry_obj := run_sql_query(_server, _qry, _retry)

@ _x + 4, _y + 2 SAY SECONDS() - _seconds 

_counter := 1

DO WHILE !_qry_obj:Eof()
    append blank

	/*
	"idfirma, idvd, brdok, rbr, datdok, brfaktp, datfaktp, idroba, idkonto, idkonto2, idzaduz, "
	"idzaduz2, idpartner, datkurs, kolicina, gkolicina, gkolicin2, fcj, " 
	"fcj2, fcj3, trabat, rabat, tprevoz, prevoz, tprevoz2, prevoz2, tbanktr, banktr, " 
	"tspedtr, spedtr, tcardaz, cardaz, tzavtr, zavtr, nc, tmarza, marza, vpc, rabatv, "
	"vpcsap, tmarza2, marza2, mpc, idtarifa, mpcsapp, mkonto, pkonto, roktr, mu_i, pu_i, "
	"error, podbr " + ;
	*/

    replace idfirma with _qry_obj:FieldGet(1), ;
    		idvd with _qry_obj:FieldGet(2), ;
    		brdok with _qry_obj:FieldGet(3), ;
    		rbr with _qry_obj:FieldGet(4), ;
    		datdok with _qry_obj:FieldGet(5), ;
    		brfaktp with _qry_obj:FieldGet(6), ;
    		datfaktp with _qry_obj:FieldGet(7), ;
    		idroba with _qry_obj:FieldGet(8), ;
    		idkonto with _qry_obj:FieldGet(9), ;
    		idkonto2 with _qry_obj:FieldGet(10), ;
    		idzaduz with _qry_obj:FieldGet(11), ;
    		idzaduz2 with _qry_obj:FieldGet(12), ;
    		idpartner with _qry_obj:FieldGet(13), ;
    		datkurs with _qry_obj:FieldGet(14), ;
    		kolicina with _qry_obj:FieldGet(15), ;
    		gkolicina with _qry_obj:FieldGet(16), ;
    		gkolicin2 with _qry_obj:FieldGet(17), ;
    		fcj with _qry_obj:FieldGet(18), ;
    		fcj2 with _qry_obj:FieldGet(19), ;
    		fcj3 with _qry_obj:FieldGet(20), ;
    		trabat with _qry_obj:FieldGet(21), ;
    		rabat with _qry_obj:FieldGet(22), ;
    		tprevoz with _qry_obj:FieldGet(23), ;
    		prevoz with _qry_obj:FieldGet(24), ;
    		tprevoz2 with _qry_obj:FieldGet(25), ;
    		prevoz2 with _qry_obj:FieldGet(26), ;
    		tbanktr with _qry_obj:FieldGet(27), ;
    		banktr with _qry_obj:FieldGet(28), ;
    		tspedtr with _qry_obj:FieldGet(29), ;
    		spedtr with _qry_obj:FieldGet(30), ;
    		tcardaz with _qry_obj:FieldGet(31), ;
    		cardaz with _qry_obj:FieldGet(32), ;
    		tzavtr with _qry_obj:FieldGet(33), ;
    		zavtr with _qry_obj:FieldGet(34), ;
    		nc with _qry_obj:FieldGet(35), ;
    		tmarza with _qry_obj:FieldGet(36), ;
    		marza with _qry_obj:FieldGet(37), ;
    		vpc with _qry_obj:FieldGet(38), ;
    		rabatv with _qry_obj:FieldGet(39), ;
    		vpcsap with _qry_obj:FieldGet(40), ;
    		tmarza2 with _qry_obj:FieldGet(41), ;
    		marza2 with _qry_obj:FieldGet(42), ;
    		mpc with _qry_obj:FieldGet(43), ;
    		idtarifa with _qry_obj:FieldGet(44), ;
    		mpcsapp with _qry_obj:FieldGet(45), ;
    		mkonto with _qry_obj:FieldGet(46), ;
    		pkonto with _qry_obj:FieldGet(47), ;
    		roktr with _qry_obj:FieldGet(48), ;
    		mu_i with _qry_obj:FieldGet(49), ;
    		pu_i with _qry_obj:FieldGet(50), ;
    		error with _qry_obj:FieldGet(51), ;
    		podbr with _qry_obj:FieldGet(52)

    _qry_obj:Skip()

    _counter++

    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
ENDDO

USE
_qry_obj:Close()

// limit, offset
next


if (gDebug > 5)
    log_write("kalk_kalk synchro cache:" + STR(SECONDS() - _seconds))
endif

close all
 
return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_kalk_kalk_update( op, record )

LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.kalk_kalk"

if record <> nil
	_where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idvd=" + _sql_quote( record["id_vd"]) +;
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
			" ( idfirma, idvd, brdok, rbr, datdok, brfaktp, datfaktp, idroba, idkonto, idkonto2, idzaduz, " + ;
			"idzaduz2, idpartner, datkurs, kolicina, gkolicina, gkolicin2, fcj, " + ;
			"fcj2, fcj3, trabat, rabat, tprevoz, prevoz, tprevoz2, prevoz2, tbanktr, banktr, " + ; 
			"tspedtr, spedtr, tcardaz, cardaz, tzavtr, zavtr, nc, tmarza, marza, vpc, rabatv, " + ;
			"vpcsap, tmarza2, marza2, mpc, idtarifa, mpcsapp, mkonto, pkonto, roktr, mu_i, pu_i, " + ;
			"error, podbr ) " + ;
                "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_vd"] ) + "," +; 
                            + _sql_quote( record["br_dok"] ) + "," +; 
                            + _sql_quote(STR( record["r_br"] , 3)) + "," +; 
                            + _sql_quote( record["dat_dok"] ) + "," +;
                            + _sql_quote( record["br_fakt_p"] ) + "," +;
                            + _sql_quote( record["dat_fakt_p"] ) + "," +;
                            + _sql_quote( record["id_roba"] ) + "," +;
                            + _sql_quote( record["id_konto"] ) + "," +;
                            + _sql_quote( record["id_konto2"] ) + "," +;
                            + _sql_quote( record["id_zaduz"] ) + "," +;
                            + _sql_quote( record["id_zaduz2"] ) + "," +;
                            + _sql_quote( record["id_partner"] ) + "," +;
                            + _sql_quote( record["dat_kurs"] ) + "," +;
                            + _sql_quote( STR( record["kolicina"], 12, 3 ) ) + "," +;
                            + _sql_quote( STR( record["g_kolicina"], 12, 3 ) ) + "," +;
                            + _sql_quote( STR( record["g_kolicina_2"], 12, 3 ) ) + "," +;
                            + _sql_quote( STR( record["f_cj"], 18, 8 ) ) + "," +;
                            + _sql_quote( STR( record["f_cj2"], 18, 8 ) ) + "," +;
                            + _sql_quote( STR( record["f_cj3"], 18, 8 ) ) + "," +;
                            + _sql_quote( record["t_rabat"] ) + "," +;
                            + _sql_quote( STR( record["rabat"], 18, 8 )) + "," +;
                            + _sql_quote( record["t_prevoz"] ) + "," +;
                            + _sql_quote( STR( record["prevoz"], 18, 8 )) + "," +;
                            + _sql_quote( record["t_prevoz2"] ) + "," +;
                            + _sql_quote( STR( record["prevoz2"], 18, 8 )) + "," +;
                            + _sql_quote( record["t_banktr"] ) + "," +;
                            + _sql_quote( STR( record["banktr"], 18, 8 )) + "," +;
                            + _sql_quote( record["t_spedtr"] ) + "," +;
                            + _sql_quote( STR( record["spedtr"], 18, 8 )) + "," +;
                            + _sql_quote( record["t_cardaz"] ) + "," +;
                            + _sql_quote( STR( record["cardaz"], 18, 8 )) + "," +;
                            + _sql_quote( record["t_zavtr"] ) + "," +;
                            + _sql_quote( STR( record["zavtr"], 18, 8 )) + "," +;
                            + _sql_quote( STR( record["nc"], 18, 8 )) + "," +;
                            + _sql_quote( record["t_marza"] ) + "," +;
                            + _sql_quote( STR( record["marza"], 18, 8 )) + "," +;
                            + _sql_quote( STR( record["vpc"], 18, 8 )) + "," +;
                            + _sql_quote( STR( record["rabatv"], 18, 8 )) + "," +;
                            + _sql_quote( STR( record["vpc_sa_p"], 18, 8 )) + "," +;
                            + _sql_quote( record["t_marza2"] ) + "," +;
                            + _sql_quote( STR( record["marza2"], 18, 8 )) + "," +;
                            + _sql_quote( STR( record["mpc"], 18, 8 )) + "," +;
                            + _sql_quote( record["id_tarifa"] ) + "," +;
                            + _sql_quote( STR( record["mpc_sa_pp"], 18, 8 )) + "," +;
                            + _sql_quote( record["m_konto"] ) + "," +;
                            + _sql_quote( record["p_konto"] ) + "," +;
                            + _sql_quote( record["rok_tr"] ) + "," +;
                            + _sql_quote( record["mu_i"] ) + "," +;
                            + _sql_quote( record["pu_i"] ) + "," +;
                            + _sql_quote( record["error"] ) + "," +;
                            + _sql_quote( record["pod_br"] ) + " )"
                          
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
function kalk_doks_from_sql_server(algoritam)
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _x, _y
local _dat, _ids
local _fnd, _tmp_id

if algoritam == NIL
  algoritam := "FULL"
endif

_x := maxrows() - 15
_y := maxcols() - 20

@ _x + 1, _y + 2 SAY "update kalk_doks: " + algoritam

_seconds := SECONDS()

_qry :=  "SELECT " + ;
		"idfirma, idvd, brdok, datdok, brfaktp, idpartner, idzaduz, idzaduz2, " + ;
		"pkonto, mkonto, nv, vpv, rabat, mpv, podbr, sifra " + ;
		"FROM " + ;
		"fmk.kalk_doks"  

if algoritam == "DATE"
    _dat = get_dat_from_semaphore("kalk_kalk")
    _qry += " WHERE datdok >= " + _sql_quote(_dat)
endif

_qry_obj := _server:Query(_qry) 
if _qry_obj:NetErr()
   MsgBeep("ajoj :" + _qry_obj:ErrorMsg())
   QUIT
endif

SELECT F_KALK_DOKS
my_use ("kalk_doks", "kalk_doks", .f., "SEMAPHORE")

DO CASE

	CASE algoritam == "FULL"
    	
		// "full" algoritam
    	log_write("dat_dok = nil full algoritam") 
	    ZAP
	
	CASE algoritam == "DATE"

    	log_write("dat_dok <> nil date algoritam") 
    	// "date" algoritam  - brisi sve vece od zadanog datuma
    	SET ORDER TO TAG "DAT"
    	// tag je "DatDok" nije DTOS(DatDok)
    	seek _dat
    	do while !eof() .and. (field->datDok >= _dat) 
        	// otidji korak naprijed
        	SKIP
        	_rec := RECNO()
        	SKIP -1
        	DELETE
        	GO _rec  
    	enddo

	CASE algoritam == "IDS"
    	
		_ids := get_ids_from_semaphore("kalk_doks")
    	
		SET ORDER TO TAG "1"

		// CREATE_INDEX("1", "idFirma+IdVd+BrDok", "KALK_DOKS")
    	// pobrisimo sve id-ove koji su drugi izmijenili
    	do while .t.
       		_fnd := .f.
       		for each _tmp_id in _ids
          		
          		HSEEK _tmp_id
          		
				do while !EOF() .and. (field->idfirma + field->idvd + field->brdok) == _tmp_id
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
        	_qry += " (idfirma || idvd || brdok) IN " + _sql_ids
     	endif

END CASE

_qry_obj := _server:Query( _qry )
if _qry_obj:NetErr()
	Msgbeep("ajoj :" + _qry_obj:ErrorMsg())
	QUIT
endif

@ _x + 4, _y + 2 SAY SECONDS() - _seconds 

_counter := 1

DO WHILE !_qry_obj:Eof()
    append blank

	/*
	"idfirma, idvd, brdok, datdok, brfaktp, idpartner, idzaduz, idzaduz2" + ;
	"pkonto, mkonto, nv, vpv, rabat, mpv, podbr, sifra ) " + ;
    */
    
	replace idfirma with _qry_obj:FieldGet(1), ;
    		idvd with _qry_obj:FieldGet(2), ;
    		brdok with _qry_obj:FieldGet(3), ;
    		datdok with _qry_obj:FieldGet(4), ;
    		brfaktp with _qry_obj:FieldGet(5), ;
    		idpartner with _qry_obj:FieldGet(6), ;
    		idzaduz with _qry_obj:FieldGet(7), ;
    		idzaduz2 with _qry_obj:FieldGet(8), ;
    		pkonto with _qry_obj:FieldGet(9), ;
    		mkonto with _qry_obj:FieldGet(10), ;
    		nv with _qry_obj:FieldGet(11), ;
    		vpv with _qry_obj:FieldGet(12), ;
    		rabat with _qry_obj:FieldGet(13), ;
    		mpv with _qry_obj:FieldGet(14), ;
    		podbr with _qry_obj:FieldGet(15)
    		//sifra with _qry_obj:FieldGet(16)

    _qry_obj:Skip()

    _counter++

    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
ENDDO

USE
_qry_obj:Close()

if (gDebug > 5)
    log_write("kalk_kalk synchro cache:" + STR(SECONDS() - _seconds))
endif

close all
 
return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_kalk_doks_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()


_tbl := "fmk.kalk_doks"

if record <> nil
	_where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idvd=" + _sql_quote( record["id_vd"]) +;
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
			" ( idfirma, idvd, brdok, datdok, brfaktp, idpartner, idzaduz, idzaduz2, " + ;
			"pkonto, mkonto, nv, vpv, rabat, mpv, podbr ) " + ;
                "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_vd"] ) + "," +; 
                            + _sql_quote( record["br_dok"] ) + "," +; 
                            + _sql_quote( record["dat_dok"] ) + "," +;
                            + _sql_quote( record["br_fakt_p"] ) + "," +;
                            + _sql_quote( record["id_partner"] ) + "," +;
                            + _sql_quote( record["id_zaduz"] ) + "," +;
                            + _sql_quote( record["id_zaduz2"] ) + "," +;
                            + _sql_quote( record["p_konto"] ) + "," +;
                            + _sql_quote( record["m_konto"] ) + "," +;
							+ _sql_quote( STR( record["nv"], 18, 8 )) + "," +;
                            + _sql_quote( STR( record["vpv"], 18, 8 )) + "," +;
                            + _sql_quote( STR( record["rabat"], 18, 8 )) + "," +;
                            + _sql_quote( STR( record["mpv"], 18, 8 )) + "," +;
                            + _sql_quote( record["pod_br"] ) + " )"
                            //+ _sql_quote( record["sifra"] ) + " )"
                          
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
 


