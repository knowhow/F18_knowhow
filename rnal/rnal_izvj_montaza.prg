/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "rnal.ch"


// varijanta izvjestaja
static __rpt_var := NIL
static __server_params
static __redmine_server

static function server_params()
return __server_params

static function my_redmine_server()
return __redmine_server

// --------------------------------------------------
// izvjestaj montaze koji se generise na osnovu
// redmine podataka
// --------------------------------------------------
function rnal_rpt_montaza()
local _params := hb_hash()
local _data := NIL
local _template := "rnal_montaza.odt"
local _my_xml := my_home() + "data.xml"

#ifndef __PLATFORM__LINUX
	MsgBeep("Izvjestaj radi samo na linux oper.sistemu !!!")
	return
#endif

// uslovi izvjestaja
if !get_vars( @_params )
	return
endif

// kreiraj pomocnu tabelu
_cre_tmp_tbl()

// kreiraj izvjestaj u pom.tabelu r_export
cre_rpt( _params )

// kreiraj xml
if cre_xml( _my_xml, _params )

	if f18_odt_generate( _template, _my_xml )
	    // printaj odt
        f18_odt_print()
    endif

endif

return



// --------------------------------------------------
// kreiranje pomocne tabele
// --------------------------------------------------
static function _cre_tmp_tbl()
local _dbf := {}
local _i, _tmp 

AADD( _dbf, { "priority", "N", 5, 0 }  )
AADD( _dbf, { "issue", "N", 10, 0 }  )
AADD( _dbf, { "author", "C", 50, 0 }  )
AADD( _dbf, { "subject", "C", 250, 0 }  )
AADD( _dbf, { "project", "C", 150, 0 }  )
AADD( _dbf, { "status", "C", 50, 0 }  )
AADD( _dbf, { "due_date", "D", 8, 0 }  )
AADD( _dbf, { "created", "D", 8, 0 }  )

// napravi cust_1... cust_15 polja
for _i := 1 to 15
	_tmp := "cust_" + ALLTRIM(STR( _i ))
	AADD( _dbf, { _tmp, "C", 250, 0 }  )
next

// kreiraj r_export tabelu sa strukturom
t_exp_create( _dbf )

return




// --------------------------------------------------
// kreiraj izvjestaj i vrati mi u tabelu
// --------------------------------------------------
static function cre_rpt( params )
local oTable, _rec
local _query, oRow, _i, _value
local _count := 0
local _limit := params["limit"]
local _limit_str := ""

// daj mi parametre konekcije
__server_params := get_redmine_server_params( __rpt_var )

// konektuj se na server
__redmine_server := redmine_server( __server_params )
// da li je server ziv ???
if __redmine_server == NIL
	return NIL
endif

if _limit > 0
	_limit_str := " LIMIT " + ALLTRIM(STR(_limit))
endif

_query := "SELECT " + ;
	" iss.priority_id AS priority, " + ;
	" iss.id AS issue, " + ;
	" CONCAT(usr.firstname, ' ', usr.lastname ) AS author, " + ;
    " iss.subject, " + ;
	" iss.due_date, " + ;
	" iss.created_on, " + ;
	" pr.name AS project, " + ;
	" it.name AS status " + ; 
	" FROM issues AS iss " + ; 
	" LEFT JOIN projects AS pr ON iss.project_id = pr.id " + ; 
	" LEFT JOIN issue_statuses AS it ON iss.status_id = it.id " + ;
	" LEFT JOIN users AS usr ON iss.author_id = usr.id " + ;
	" WHERE " + ;
	" iss.status_id IN (1,2,3,4)" + ;
	" AND iss.project_id = 4" + ;
	" AND iss.tracker_id = 12" + ;
	" GROUP BY iss.priority_id, iss.id" + ; 
	" ORDER BY iss.priority_id DESC" + ;
	_limit_str + ;
	";"

oTable := __redmine_server:Query( _query )

log_write( "RNAL montaza, mysql qry: " + _query , 9 )

if oTable:NetErr()
	log_write( "qry err " + oTable:ErrorMsg(), 3 )
	return NIL
endif

if oTable == NIL
	return NIL
endif

oTable:Refresh()

O_R_EXP

Box(, 1, 50 )

// sada napravi sub-querije... custom polja
for _i := 1 to oTable:LastRec()

    oRow := oTable:GetRow( _i )

	APPEND BLANK

	++ _count

	_rec := dbf_get_rec()

	_rec["priority"] := oRow:FieldGet( oRow:FieldPos( "priority" ) )
	_rec["issue"] := oRow:FieldGet( oRow:FieldPos( "issue" ) )
	_rec["author"] := ALLTRIM( oRow:FieldGet( oRow:FieldPos( "author" ) ) )
	_rec["subject"] := ALLTRIM( oRow:FieldGet( oRow:FieldPos( "subject" ) ) )
	_rec["project"] := ALLTRIM( oRow:FieldGet( oRow:FieldPos( "project" ) ) )
	_rec["status"] := ALLTRIM( oRow:FieldGet( oRow:FieldPos( "status" ) ) )
	if oRow:FieldGet( oRow:FieldPos( "due_date" ) ) <> NIL
		_rec["due_date"] := oRow:FieldGet( oRow:FieldPos( "due_date" ) )
	endif
	_rec["created"] := oRow:FieldGet( oRow:FieldPos( "created" ) )

	update_custom_field_values( @_rec )	
	
	@ m_x + 1, m_y + 2 SAY "punim master tabelu, zapis: " + PADR( ;
			ALLTRIM(STR( _i )) + "/" + ALLTRIM(STR( oTable:LastRec()) ), 20 )

	dbf_update_rec( _rec )

next

BoxC()

oTable:Destroy()

// zatvori tabelu
select r_export
use


return _count


// -------------------------------------------------------------------------
// pushira vrijednost custom_field vrijednosti
// -------------------------------------------------------------------------
static function update_custom_field_values( rec )
local _val
local oTable
local _query, oRow2
local _issue, _i
local _tmp, _row_value

// konektuj se na server
//oServer := redmine_server( server_params() )
// da li je server ziv ???
//if oServer == NIL
//	return NIL
//endif

// uzmi vrijednost issue iz proslijedjene komponenete row
_issue := rec["issue"]

_query := "SELECT " + ;
		" cf.name AS field, " + ;
		" cv.value AS value " + ;
		" FROM custom_values AS cv " + ;
		" LEFT JOIN custom_fields AS cf ON cf.id = cv.custom_field_id " + ;
		" WHERE cv.customized_id = " + ALLTRIM(STR( _issue )) + ;
		" ORDER BY cv.custom_field_id;"

oTable := __redmine_server:Query( _query )
log_write( "RNAL montaza, mysql sub-qry: " + _query , 9 )

if oTable:NetErr()
	log_write( "qry err " + oTable:ErrorMsg(), 3 )
	return NIL
endif

if oTable == NIL
	return NIL
endif

// update tekuceg row zapisa
for _i := 1 to oTable:LastRec()

    oRow2 := oTable:GetRow( _i )

	// naziv polja
	_tmp := "cust_" + ALLTRIM( STR( _i ))

	_row_value := oRow2:FieldGet( oRow2:FieldPos( "value" ) )

	if hb_hhaskey( rec, _tmp )
		rec[ _tmp ] := _row_value
	endif

next

return .t.



// -------------------------------------------------
// generisi xml fajl
// -------------------------------------------------
static function cre_xml( xml_file, params )
local oRow
local _i
local _ret := .f.
local _count := 0

O_R_EXP
if RecCount() == 0
	MsgBeep( "Nema podataka !!!" )
	return _ret
endif

MsgO( "Generisanje xml fajla u toku... ")

open_xml( xml_file )
xml_head()

xml_subnode( "mon", .f. )

xml_node( "date", DTOC( DATE()) )

select r_export
go top

do while !EOF()

	++ _count

	xml_subnode( "item", .f. )

	// issue
    xml_node( "no", ALLTRIM( STR( _count ) ) )

    xml_node( "issue", ;
		ALLTRIM( STR( field->issue ) ) )

    xml_node( "priority", ;
		ALLTRIM( STR( field->priority ) ) )
    
	xml_node( "subject", ;
		to_xml_encoding( ;
			field->subject ) )
 
	xml_node( "author", ;
		to_xml_encoding( ;
			field->author ) )
 
	xml_node( "project", ;
		to_xml_encoding( ;
			field->project ) )
 
	xml_node( "status", ;
		to_xml_encoding( ;
			field->status ) )

	xml_node( "due_date", ;
		DTOC( ;
			field->due_date ) )

	xml_node( "created", ;
		DTOC( ;
			field->created ) )
 
	// custom polja
	xml_node( "cust_1", ;
		to_xml_encoding( ;
			field->cust_1 ) )
 
	xml_node( "cust_2", ;
		to_xml_encoding( ;
			field->cust_2 ) )
 
	xml_node( "cust_3", ;
		to_xml_encoding( ;
			field->cust_3 ) )
 
	xml_node( "cust_4", ;
		to_xml_encoding( ;
			field->cust_4 ) )
 
	xml_node( "cust_5", ;
		to_xml_encoding( ;
			field->cust_5 ) )
 
	xml_node( "cust_6", ;
		to_xml_encoding( ;
			field->cust_6 ) )
 
	xml_node( "cust_7", ;
		to_xml_encoding( ;
			field->cust_7 ) )
 
	xml_node( "cust_8", ;
		to_xml_encoding( ;
			field->cust_8 ) )

 	xml_node( "cust_9", ;
		to_xml_encoding( ;
			field->cust_9 ) )
 
	xml_node( "cust_10", ;
		to_xml_encoding( ;
			field->cust_10 ) )
 
	xml_node( "cust_11", ;
		to_xml_encoding( ;
			field->cust_11 ) )

 	xml_node( "cust_12", ;
		to_xml_encoding( ;
			field->cust_12 ) )

 	xml_node( "cust_13", ;
		to_xml_encoding( ;
			field->cust_13 ) )
 
	xml_node( "cust_14", ;
		to_xml_encoding( ;
			field->cust_14 ) )
 
	xml_node( "cust_15", ;
		to_xml_encoding( ;
			field->cust_15 ) )
 

	xml_subnode( "item", .t. )

	skip

enddo

xml_subnode( "mon", .t. )

close_xml()

MsgC()

select r_export
use

if _count > 0
	_ret := .t.
endif

return _ret





// --------------------------------------------------
// uslovi izvjestaja
// --------------------------------------------------
static function get_vars( params )
local _i := 1
local _conn := "N"
local _limit := 0

Box(, 10, 70 )

	@ m_x + _i, m_y + 2 SAY "Podesiti parametre konekcije (D/N) ?" GET _conn VALID _conn $ "DN" PICT "@!"

	read

	if _conn == "D"
		// setuj parametre konekcije
		redmine_login_form( __rpt_var )
	endif

	++ _i
	++ _i

	@ m_x + _i, m_y + 2 SAY "Limitirati broj zapisa na:" GET _limit PICT "999999"

	read	

BoxC()

if LastKey() == K_ESC
	return .f.
endif

// snimi parametre
params["limit"] := _limit
// params[""] := param2
// params[""] := param3
// params[""] := param4


return .t.






