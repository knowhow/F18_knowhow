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


static function server_params()
return __server_params


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

// kreiraj izvjestaj
_data := cre_rpt( _params )

if _data == NIL
	MsgBeep( "Nema podataka !!!" )
endif

// kreiraj xml
if cre_xml( _my_xml, _data, _params )

	//if f18_odt_generate( _template, _my_xml )
	    // printaj odt
        //f18_odt_print()
    //endif

endif

return



// --------------------------------------------------
// kreiraj izvjestaj i vrati mi u tabelu
// --------------------------------------------------
static function cre_rpt( params )
local oServer
local oTable
local _query, oRow, _i, _value

// daj mi parametre konekcije
__server_params := get_redmine_server_params( __rpt_var )

// konektuj se na server
oServer := redmine_server( __server_params )
// da li je server ziv ???
if oServer == NIL
	return NIL
endif

_query := "SELECT " + ;
	" iss.priority_id, " + ;
	" iss.id AS issue, " + ;
	" CONCAT(usr.firstname, ' ', usr.lastname ) AS author, " + ;
    " iss.subject, " + ;
	" pr.name AS project, " + ;
	" it.name AS status, " + ; 
	" 'rnal' AS RNAL, " + ;
	" 'kupac' AS kupac, " + ;
	" 'telefon_1' AS telefon_1, " + ;
	" 'telefon_2' AS telefon_2, " + ;
	" 'adresa' AS adresa, " + ;
	" 'descr' AS stakla_i_radovi, " + ;
	" 'termin' AS termin, " + ;
	" 'ekipa' AS ekipa, " + ;
	" '2012-11-01' AS due_date, " + ;
	" 'parent_task' AS parent_task " + ;
	" FROM issues AS iss " + ; 
	" LEFT JOIN projects AS pr ON iss.project_id = pr.id " + ; 
	" LEFT JOIN issue_statuses AS it ON iss.status_id = it.id " + ;
	" LEFT JOIN users AS usr ON iss.author_id = usr.id " + ;
	" WHERE " + ;
	" iss.status_id IN (1,2,3,4)" + ;
	" AND iss.project_id = 4" + ;
	" AND iss.tracker_id = 12" + ;
	" GROUP BY iss.priority_id, iss.id" + ; 
	" ORDER BY iss.priority_id DESC;"

oTable := oServer:Query( _query )
log_write( "RNAL montaza, mysql qry: " + _query , 9 )

if oTable:NetErr()
	log_write( "qry err " + oTable:ErrorMsg(), 3 )
	return NIL
endif

if oTable == NIL
	return NIL
endif

// sada napravi sub-querije... custom polja
for _i := 1 to oTable:LastRec()

    oRow := oTable:GetRow( _i )

	update_custom_field_values( @oRow )	

	if !oTable:Update( oRow )
		MsgBeep( "Imamo problem sa update oRow !!!" )
		log_write( "update row err: " + oTable:Error(), 3 )
		return NIL
	endif

next


return oTable


// -------------------------------------------------------------------------
// pushira vrijednost custom_field vrijednosti
// -------------------------------------------------------------------------
static function update_custom_field_values( row )
local _val
local oServer
local oTable
local _query, oRow2
local _issue, _i
local _row_field, _row_value

// konektuj se na server
oServer := redmine_server( server_params() )
// da li je server ziv ???
if oServer == NIL
	return NIL
endif

// uzmi vrijednost issue iz proslijedjene komponenete row
_issue := row:Fieldget( row:Fieldpos("issue") )

_query := "SELECT " + ;
		" cf.name AS field, " + ;
		" cv.value AS value " + ;
		" FROM custom_values AS cv " + ;
		" LEFT JOIN custom_fields AS cf ON cf.id = cv.custom_field_id " + ;
		" WHERE cv.customized_id = " + ALLTRIM(STR( _issue )) + ";"

oTable := oServer:Query( _query )
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

	_row_field := ALLTRIM( oRow2:FieldGet( oRow2:FieldPos( "field" ) ) )
	_row_value := oRow2:FieldGet( oRow2:FieldPos( "value" ) )

	if VALTYPE( _row_value ) == "C"
		//_row_value := hb_utf8tostr( _row_value )
	endif 

	if VALTYPE( row:FieldGet( row:FieldPos( _row_field ) ) ) <> "L"
		// appenduj row
		row:FieldPut( row:FieldPos( _row_field ), _row_value )
	endif

next
	
return




// -------------------------------------------------
// generisi xml fajl
// -------------------------------------------------
static function cre_xml( xml_file, table, params )
local oRow
local _i
local _ret := .f.
local _count := 0

if table == NIL .or. table:LastRec() == 0
    return _ret
endif

open_xml( xml_file )
xml_head()

xml_subnode( "mon", .f. )

for _i := 1 to table:LastRec()

	++ _count

    oRow := table:GetRow( _i )

	xml_subnode( "item", .f. )

	// issue
    xml_node( "no", ALLTRIM( STR( _count ) ) )

    xml_node( "issue", ;
		ALLTRIM( STR( oRow:Fieldget( oRow:Fieldpos("issue") ) ) ) )

    xml_node( "priority", ;
		ALLTRIM( STR( oRow:Fieldget( oRow:Fieldpos("priority_id") ) ) ) )
    
	xml_node( "subject", ;
		to_xml_encoding( ;
			oRow:Fieldget( oRow:Fieldpos("subject") ) ) )
 
	xml_node( "author", ;
		to_xml_encoding( ;
			hb_utf8tostr( oRow:Fieldget( oRow:Fieldpos("author") ) ) ) )
 
	xml_node( "project", ;
		to_xml_encoding( ;
			hb_utf8tostr( oRow:Fieldget( oRow:Fieldpos("project") ) ) ) )
 
	xml_node( "status", ;
		to_xml_encoding( ;
			hb_utf8tostr( oRow:Fieldget( oRow:Fieldpos("status") ) ) ) )
 
	// custom polja
	xml_node( "rnal", ;
		to_xml_encoding( ;
			hb_utf8tostr( oRow:Fieldget( oRow:Fieldpos("rnal") ) ) ) )
 
	xml_node( "kupac", ;
		to_xml_encoding( ;
			hb_utf8tostr( oRow:Fieldget( oRow:Fieldpos("kupac") ) ) ) )
 
	xml_node( "telefon", ;
		to_xml_encoding( ;
			hb_utf8tostr( oRow:Fieldget( oRow:Fieldpos("telefon") ) ) ) )
 

	xml_subnode( "item", .t. )

next

xml_subnode( "mon", .t. )

close_xml()

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

Box(, 10, 70 )

	@ m_x + _i, m_y + 2 SAY "Podesiti parametre konekcije (D/N) ?" GET _conn VALID _conn $ "DN" PICT "@!"

	read

	if _conn == "D"
		// setuj parametre konekcije
		redmine_login_form( __rpt_var )
	endif

	++ _i
	++ _i

	@ m_x + _i, m_y + 2 SAY "datum od"

	read	

BoxC()

if LastKey() == K_ESC
	return .f.
endif

// snimi parametre
// _params[""] := param1
// _params[""] := param2
// _params[""] := param3
// _params[""] := param4


return .t.






