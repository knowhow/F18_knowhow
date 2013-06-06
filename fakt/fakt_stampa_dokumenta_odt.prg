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


#include "fakt.ch"

static LEN_KOLICINA := 12
static LEN_CIJENA := 10
static LEN_VRIJEDNOST := 12
static PIC_KOLICINA := ""
static PIC_VRIJEDNOST := ""
static PIC_CIJENA := ""
static __default_odt_vp_template := ""
static __default_odt_mp_template := ""
static __default_odt_kol_template := ""
static _temporary := .f.
static __auto_odt := ""


// ------------------------------------------------------
// setuje defaultni odt template
// ------------------------------------------------------
function __default_odt_template()
__default_odt_vp_template := fetch_metric( "fakt_default_odt_template", my_user(), "" )
__default_odt_mp_template := fetch_metric( "fakt_default_odt_mp_template", my_user(), "" )
__default_odt_kol_template := fetch_metric( "fakt_default_odt_kol_template", my_user(), "" )
return


function __auto_odt_template()
__auto_odt := fetch_metric( "fakt_odt_template_auto", NIL, "D" )
return


// ------------------------------------------------
// stampa dokumenta u odt formatu
// ------------------------------------------------
function stdokodt( cIdf, cIdVd, cBrDok )
local _template := ""
local _jod_templates_path := F18_TEMPLATE_LOCATION
local _xml_file := my_home() + "data.xml"
local _file_pdf := ""
local _ext_pdf := fetch_metric( "fakt_dokument_pdf_lokacija", my_user(), "" )
local _ext_path
local _gen_pdf := .f.
local _racuni := {}
local __tip_dok

// setuj static var...
__auto_odt_template()

if ( cIdF <> NIL )
    _file_pdf := "fakt_" + cIdF + "_" + cIdVd + "_" + ALLTRIM(cBrDok) + ".pdf"
    __tip_dok := cIdVd
else

    _file_pdf := "fakt_priprema.pdf"

    // ali moramo znati koji je dokument u pitanju !
    select fakt_pripr 
    set order to tag "1"
    go top

    __tip_dok := field->idtipdok

endif

IF !EMPTY( _jod_templates_path )
    _t_path := ALLTRIM( _jod_templates_path )
ENDIF

// treba li generisati pdf fajl
if !EMPTY( ALLTRIM( _ext_pdf ) )
	if Pitanje(, "Generisati PDF dokument ?", "N" ) == "D"
		_gen_pdf := .t.
	endif
endif

MsgO( "formiram stavke racuna..." )

AADD( _racuni, { cIdF, cIdVd, cBrDok  } )

// generisi xml fajl
_gen_xml( _xml_file, _racuni )

MsgC()

// odaberi template za stampu...
fakt_odaberi_template( @_template, __tip_dok )

close all

if f18_odt_generate( _template, _xml_file )

	// konvertuj odt u pdf
	if _gen_pdf .and. !EMPTY( _file_pdf )

		_ext_path := ALLTRIM( _ext_pdf )

		if LEFT( ALLTRIM( _ext_pdf ), 4 ) == "HOME"
			// bacaj u HOME path
			_ext_path := my_home() 
		endif 

		f18_convert_odt_to_pdf( NIL, _ext_path + _file_pdf )

	endif

	// printaj odt
    f18_odt_print()

endif

return



static function fakt_odaberi_template( template, tip_dok )
local _ok := .t.
local _mp_template := "f-stdm.odt"
local _vp_template := "f-std.odt"
local _kol_template := "f-stdk.odt"
local _auto_odabir := __auto_odt == "D"
local _f_path := my_home()
local _f_filter := "f-*.odt"

// imamo i gpsamokol parametar koji je bitan... valjda !

template := ""

// odabir template fajla na osnovu tipa dokumenta
do case

    case tip_dok $ "12#13"

        // tipovi dokumenata gdje trebaju samo kolicine 

        if !EMPTY( __default_odt_kol_template )
            template := __default_odt_kol_template
        endif

        if EMPTY( template ) .and. _auto_odabir
            template := _kol_template
        endif
                
    case  tip_dok $ "11#"

        // maloprodajni racuni i ostalo...

        if !EMPTY( __default_odt_mp_template )
            template := __default_odt_mp_template
        endif
            
        if EMPTY( template ) .and. _auto_odabir
            template := _mp_template
        endif

    otherwise

        // ostalo cemo smatrati veleprodajom

        if !EMPTY( __default_odt_vp_template )
            template := __default_odt_vp_template
        endif

        if EMPTY( template ) .and. _auto_odabir
            template := _vp_template
        endif

endcase

if EMPTY( template ) 
    _ok := get_file_list_array( _f_path, _f_filter, @template, .t. ) == 1
endif

return _ok





static function _grupno_params( params )
local _ok := .f.
local _box_x := 15
local _box_y := 70
local _x := 1
local _id_firma, _id_tip_dok, _brojevi
local _datum_od, _datum_do
local _partneri, _roba, _na_lokaciju
local _tip_gen := "1"
local _gen_pdf := "N"

_id_firma := fetch_metric( "export_odt_grupno_firma", my_user(), gFirma )
_id_tip_dok := fetch_metric( "export_odt_grupno_tip_dok", my_user(), "10" )
_datum_od := fetch_metric( "export_odt_grupno_datum_od", my_user(), DATE() )
_datum_do := fetch_metric( "export_odt_grupno_datum_do", my_user(), DATE() )
_brojevi := PADR( fetch_metric( "export_odt_grupno_brojevi", my_user(), "" ) , 500 )
_partneri := PADR( fetch_metric( "export_odt_grupno_partneri", my_user(), "" ) , 500 )
_roba := PADR( fetch_metric( "export_odt_grupno_roba", my_user(), "" ) , 500 )
_na_lokaciju := PADR( fetch_metric( "export_odt_grupno_exp_lokacija", my_user(), "" ) , 500 )

// uslov za stampanje 
Box(, _box_x, _box_y )
    
    @ m_x + _x, m_y + 2 SAY "*** Stampa ODT dokumenata po zadanom uslovu:"

    ++ _x
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "Radna jedinica / vrsta:" GET _id_firma VALID !EMPTY( _id_firma ) 
    @ m_x + _x, col() + 1 SAY "-" GET _id_tip_dok VALID !EMPTY( _id_tip_dok )  
    
    ++ _x
 
    @ m_x + _x, m_y + 2 SAY "Za datum od:" GET _datum_od
    @ m_x + _x, col() + 1 SAY "do:" GET _datum_do
  
    ++ _x
    ++ _x
  
    @ m_x + _x, m_y + 2 SAY "Brojevi dokumenata:" GET _brojevi PICT "@S45"
    
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "Obuhvati artikle:" GET _roba PICT "@S45"
    
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Obuhvati partnere:" GET _partneri PICT "@S45"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Generisati grupno/jedan po jedan (1/2) ?" GET _tip_gen VALID _tip_gen $ "12"

    ++ _x 

    @ m_x + _x, m_y + 2 SAY "Formirati PDF dokument (D/N) ?" GET _gen_pdf VALID _gen_pdf $ "DN" 
   
    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Prebaci na lokaciju:" GET _na_lokaciju PICT "@S40"
    
    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

// sql params
set_metric( "export_odt_grupno_firma", my_user(), _id_firma )
set_metric( "export_odt_grupno_tip_dok", my_user(), _id_tip_dok )
set_metric( "export_odt_grupno_datum_od", my_user(), _datum_od )
set_metric( "export_odt_grupno_datum_do", my_user(), _datum_do )
set_metric( "export_odt_grupno_brojevi", my_user(), ALLTRIM( _brojevi ) )
set_metric( "export_odt_grupno_partneri", my_user(), ALLTRIM( _partneri ) )
set_metric( "export_odt_grupno_roba", my_user(), ALLTRIM( _roba ) ) 
set_metric( "export_odt_grupno_exp_lokacija", my_user(), ALLTRIM( _na_lokaciju ) ) 

// params
params := hb_hash()
params["datum_od"] := _datum_od
params["datum_do"] := _datum_do
params["id_firma"] := _id_firma
params["id_tip_dok"] := _id_tip_dok
params["brojevi"] := _brojevi
params["roba"] := _roba
params["partneri"] := _partneri
params["tip_gen"] := _tip_gen
params["gen_pdf"] := _gen_pdf
params["na_lokaciju"] := _na_lokaciju

_ok := .t.
return _ok




// ----------------------------------------------------------
// generisanje upita za matricu racuna za export
// ----------------------------------------------------------
static function _grupno_sql_gen( racuni, params )
local _ok := .f.
local _qry, _table, _where
local _server := pg_server()
local oRow
local _scan

// idfirma
_where := "WHERE f.idfirma = " + _sql_quote( params["id_firma"] )
// idtipdok
_where += " AND f.idtipdok = " + _sql_quote( params["id_tip_dok"] )
// datdok
if params["datum_od"] <> CTOD("")
    _where += " AND " + _sql_date_parse( "f.datdok", params["datum_od"], params["datum_do"] )
endif
// roba
if !EMPTY( params["roba"] )
    _where += " AND " + _sql_cond_parse( "f.idroba", ALLTRIM( params["roba"] ) + " " )
endif
// brojevi
if !EMPTY( params["brojevi"] )
    _where += " AND " + _sql_cond_parse( "f.brdok", ALLTRIM( params["brojevi"] ) )
endif
// partneri
if !EMPTY( params["partneri"] )
    _where += " AND " + _sql_cond_parse( "f.idpartner", ALLTRIM( params["partneri"] ) + " " )
endif

// glavni upit !
_qry := "SELECT f.idfirma, f.idtipdok, f.brdok, MAX( f.rbr ) " + ;
        "FROM fmk.fakt_fakt f "

_qry += _where

_qry += " GROUP BY f.idfirma, f.idtipdok, f.brdok "
_qry += " ORDER BY f.idfirma, f.idtipdok, f.brdok "

MsgO( "formiranje sql upita u toku ..." )

_table := _sql_query( _server, _qry )

MsgC()

if _table == NIL
    return NIL
endif

_table:Refresh()

// sada mi formiraj matricu na osnovu ovoga...
_table:GoTo(1)

racuni := {}

do while !_table:EOF()
    
    oRow := _table:GetRow()
    
    _scan := ASCAN( racuni, { |val| val[1] + val[2] + val[3] == oRow:FieldGet(1) + oRow:FieldGet(2) + oRow:FieldGet(3) } )
    
    if _scan == 0
        AADD( racuni, { oRow:FieldGet(1), oRow:FieldGet(2), oRow:FieldGet(3) } )
    endif
    
    _table:Skip()

enddo

_ok := .t.
return _ok 




// ------------------------------------------------
// stampa dokumenta u odt formatu, grupne fakture
// ------------------------------------------------
function stdokodt_grupno()
local _t_path := my_home()
local _filter := "f-*.odt"
local _template := ""
local _ext_pdf := fetch_metric( "fakt_dokument_pdf_lokacija", my_user(), "" )
local _file_out := ""
local _jod_templates_path := F18_TEMPLATE_LOCATION
local _xml_file := my_home() + "data.xml"
local _ext_path
local _racuni := {}
local _params := hb_hash()
local _ctrl_data := {}
local _tip_gen
local _gen_pdf, _i
local _gen_jedan := {}
local _na_lokaciju

// setuj static var...
__auto_odt_template()

// init ctrl
AADD( _ctrl_data, { 0, 0, 0, 0, 0, 0, 0, 0, 0 } )

// parametri generisanja...
if !_grupno_params( @_params )
    return
endif

// generisi mi listu racuna za eksport
if !_grupno_sql_gen( @_racuni, _params )
    return 
endif

if LEN( _racuni ) == 0
    MsgBeep( "Nema podataka za export !!!" )
    return 
endif

// tip generisanja i pdf varijanta !
// 1 - grupno
// 2 - jedna po jedna...
_tip_gen := _params["tip_gen"]
// generisi PDF dokument ?
_gen_pdf := _params["gen_pdf"]
// prebaci na lokaciju
_na_lokaciju := _params["na_lokaciju"]

do case
    
    case _tip_gen == "1"

        // generise se zbirno...
        // ===================================================================
        _gen_xml( _xml_file, _racuni, @_ctrl_data )

        if !EMPTY( _jod_templates_path )
            _t_path := ALLTRIM( _jod_templates_path )
        endif
        
        // uzmi template koji ces koristiti
        if get_file_list_array( _t_path, _filter, @_template, .t. ) == 0
            return
        endif

        close all

        // generisi i printaj dokument...
        if f18_odt_generate( _template, _xml_file )

            _file_out := "fakt_" + DTOS( _params["datum_od"] ) + "_" + DTOS( _params["datum_do"] )
            
            if !EMPTY( _na_lokaciju )
                f18_odt_copy( NIL, ALLTRIM( _na_lokaciju ) + _file_out + ".odt" )
            endif

            if _params["gen_pdf"] == "D"
                f18_convert_odt_to_pdf( NIL, ALLTRIM( _ext_pdf ) + _file_out + ".pdf" )
            endif

            f18_odt_print()

        endif

    case _tip_gen == "2"

        // generise se jedan po jedan dokument...
        // ====================================================================

        for _i := 1 to LEN( _racuni )

            // napravi mi samo jedan zapis...

            _gen_jedan := {}
            AADD( _gen_jedan, { _racuni[ _i, 1 ], _racuni[ _i, 2 ], _racuni[ _i, 3 ] } )

            _gen_xml( _xml_file, _gen_jedan, @_ctrl_data )

            if !EMPTY( _jod_templates_path )
                _t_path := ALLTRIM( _jod_templates_path )
            endif
            
            if __auto_odt == "D"
                if _racuni[ _i, 2 ] $ "12#13"
                    _template := "f-stdk.odt"
                else
                    _template := "f-std.odt"
                endif
            else
                // ako je template prazan, pronadji ga !
                if EMPTY( _template )
                    // uzmi template koji ces koristiti
                    if get_file_list_array( _t_path, _filter, @_template, .t. ) == 0
                        return
                    endif
                endif
            endif

            close all

            // u ovoj varijanti mi ne printarj dokument samo generisi
            if f18_odt_generate( _template, _xml_file )
                    
                _file_out := "fakt_" + _racuni[ _i, 1 ] + "_" + _racuni[ _i, 2 ] + "_" + ;
                                ALLTRIM( _racuni[ _i, 3 ] )
 
                // mozes nesto raditi sa njim...
                if !EMPTY( _na_lokaciju )
                    f18_odt_copy( NIL, ALLTRIM( _na_lokaciju ) + _file_out + ".odt" )
                endif

                if _params["gen_pdf"] == "D"
                    f18_convert_odt_to_pdf( NIL, ALLTRIM( _ext_pdf ) + _file_out + ".pdf" )
                endif

            endif

        next

endcase

// kontrolni podaci....
//ctrl_data, { field->ukbezpdv, field->ukpopust, field->ukpoptp, field->ukbpdvpop, ;
//                    field->ukpdv, field->ukkol, field->ukupno, field->zaokr, ;
//                    ( field->ukupno - field->ukpoptp ) } )

// ovdje bi trebalo izbaciti na kraju rekapitulaciju podataka...

return


// ------------------------------------------------
// upisi zaglavlje u xml fajl
// ------------------------------------------------
static function __upisi_zaglavlje()
local _id_broj, cTmp

// podaci zaglavlja
cTmp := ALLTRIM(get_dtxt_opis("I01"))
xml_node("fnaz", to_xml_encoding(cTmp))

cTmp := ALLTRIM(get_dtxt_opis("I02"))
xml_node("fadr", to_xml_encoding(cTmp))

_id_broj := ALLTRIM( get_dtxt_opis("I03") )
xml_node("fid", _id_broj )

if LEN( _id_broj ) == 12
    _id_broj := "4" + _id_broj
	xml_node("fidp", _id_broj )
else
    xml_node("fidp", _id_broj )
endif 

xml_node("ftel", to_xml_encoding( ALLTRIM( get_dtxt_opis("I10") ) ) )
xml_node("feml", to_xml_encoding( ALLTRIM( get_dtxt_opis("I11") ) ) )
xml_node("fbnk", to_xml_encoding( ALLTRIM( get_dtxt_opis("I09") ) ) )

cTmp := ALLTRIM( get_dtxt_opis("I12") )
xml_node("fdt1", to_xml_encoding(cTmp) )

cTmp := ALLTRIM( get_dtxt_opis("I13") )
xml_node("fdt2", to_xml_encoding(cTmp) )

cTmp := ALLTRIM( get_dtxt_opis("I14") )
xml_node("fdt3", to_xml_encoding(cTmp) )

return


// -------------------------------------------------------
// generisi xml sa podacima
// a_racuni - lista racuna koji treba da se generisu
// -------------------------------------------------------
static function _gen_xml( xml_file, a_racuni, ctrl_data )
local i
local cTmpTxt := ""
local _id_broj 
local _n
local _din_dem

if ctrl_data == NIL
    ctrl_data := {}
    AADD( ctrl_data, { 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
endif

PIC_KOLICINA := PADL(ALLTRIM(RIGHT(PicKol, LEN_KOLICINA)), LEN_KOLICINA, "9")
PIC_VRIJEDNOST := PADL(ALLTRIM(RIGHT(PicDem, LEN_VRIJEDNOST)), LEN_VRIJEDNOST, "9")
PIC_CIJENA := PADL(ALLTRIM(RIGHT(PicCDem, LEN_CIJENA)), LEN_CIJENA, "9")

// DRN tabela
// brdok, datdok, datval, datisp, vrijeme, zaokr, ukbezpdv, ukpopust
// ukpoptp, ukbpdvpop, ukpdv, ukupno, ukkol, csumrn

open_xml( xml_file )

xml_head()

xml_subnode("invoice", .f.)

for _n := 1 to LEN( a_racuni )
   
    // napuni pomocnu tabelu na osnovu fakture
    // posljednji parametar .t. odredjuje da se samo napune rn i drn tabele
    StdokPdv( a_racuni[ _n, 1 ], a_racuni[ _n, 2 ], a_racuni[ _n, 3 ], .t. )

    // zaglavlje ide samo jednom
    if _n == 1
        __upisi_zaglavlje()
    endif

    // invoice_no
    xml_subnode( "invoice_no", .f. )
 
    _din_dem := ALLTRIM( get_dtxt_opis( "D07" ) )
    
    select drn
    go top

    // neki totali...
    xml_node("u_zaokr", show_number( field->zaokr, PIC_VRIJEDNOST ) )
    xml_node("u_kol", show_number( field->ukkol, PIC_KOLICINA ) )
 
    // TOTALI:
    // ------------------------------------
    xml_subnode( "total", .f. )

    // ukupno bez pdv
    xml_subnode( "item", .f. )
        xml_node( "bold", "0" )
        xml_node( "naz", to_xml_encoding( "Ukupno bez PDV" ) )
        xml_node( "iznos", show_number( field->ukbezpdv, PIC_VRIJEDNOST ) )
    xml_subnode( "item", .t. )

    if ROUND( field->ukpopust, 2 ) <> 0 
        // ukupno popust
        xml_subnode( "item", .f. )
            xml_node( "bold", "0" )
            xml_node( "naz", to_xml_encoding( "Ukupno popust" ) )
            xml_node( "iznos", show_number( field->ukpopust, PIC_VRIJEDNOST ) )
        xml_subnode( "item", .t. )
       
        // ukupno bez pdv - popust
        xml_subnode( "item", .f. )
            xml_node( "bold", "0" )
            xml_node( "naz", to_xml_encoding( "Ukupno bez PDV - popust" ) )
            xml_node( "iznos", show_number( field->ukbpdvpop, PIC_VRIJEDNOST ) )
        xml_subnode( "item", .t. )
    endif
    
    // pdv
    xml_subnode( "item", .f. )
        xml_node( "bold", "0" )
        xml_node( "naz", to_xml_encoding( "PDV" ) )
        xml_node( "iznos", show_number( field->ukpdv, PIC_VRIJEDNOST ) )
    xml_subnode( "item", .t. )
   
    // ukupno sa pdv
    xml_subnode( "item", .f. )
        xml_node( "bold", "1" )
        xml_node( "naz", to_xml_encoding( "Ukupno sa PDV (" + ALLTRIM( _din_dem ) + ")" ) )
        xml_node( "iznos", show_number( field->ukupno, PIC_VRIJEDNOST ) )
    xml_subnode( "item", .t. )
    
    // popust na teret prodavca, ako ga ima !

    if ROUND( field->ukpoptp, 2 ) <> 0

        // Popust na teret prodavca
        xml_subnode( "item", .f. )
            xml_node( "bold", "0" )
            xml_node( "naz", to_xml_encoding( "Popust na t.p." ) )
            xml_node( "iznos", show_number( field->ukpoptp, PIC_VRIJEDNOST ) )
        xml_subnode( "item", .t. )
 
        // Ukupno - pop.na teret prodavca
        xml_subnode( "item", .f. )
            xml_node( "bold", "1" )
            xml_node( "naz", to_xml_encoding( "UKUPNO - popust na t.p." ) )
            xml_node( "iznos", show_number( field->ukupno - field->ukpoptp, PIC_VRIJEDNOST ) )
        xml_subnode( "item", .t. )

    endif

    xml_subnode( "total", .t. )

    // da li je faktura sa popustom na teret prodavaca ili nije !
    if ROUND( field->ukpoptp, 2 ) <> 0
        xml_node( "poptp", "1" )
    else
        xml_node( "poptp", "0" )
    endif

    // dodaj u kontrolnu matricu podatke
    ctrl_data[ 1, 1 ] := ctrl_data[ 1, 1 ] + field->ukbezpdv
    ctrl_data[ 1, 2 ] := ctrl_data[ 1, 2 ] + field->ukpopust
    ctrl_data[ 1, 3 ] := ctrl_data[ 1, 3 ] + field->ukpoptp
    ctrl_data[ 1, 4 ] := ctrl_data[ 1, 4 ] + field->ukbpdvpop
    ctrl_data[ 1, 5 ] := ctrl_data[ 1, 5 ] + field->ukpdv
    ctrl_data[ 1, 6 ] := ctrl_data[ 1, 6 ] + field->ukkol
    ctrl_data[ 1, 7 ] := ctrl_data[ 1, 7 ] + field->ukupno
    ctrl_data[ 1, 8 ] := ctrl_data[ 1, 8 ] + field->zaokr
    ctrl_data[ 1, 9 ] := ctrl_data[ 1, 9 ] + ( field->ukupno - field->ukpoptp ) 
    
    // dokument iz tabele
    xml_node("dbr", to_xml_encoding( ALLTRIM( field->brdok ) ) )
    xml_node("ddat", if( DTOC( field->datdok ) != DTOC( CTOD( "" ) ), DTOC( field->datdok ), "" ) )
    xml_node("ddval", if( DTOC( field->datval ) != DTOC( CTOD( "" ) ), DTOC( field->datval ), "" ) )
    xml_node("ddisp", if( DTOC( field->datisp ) != DTOC( CTOD( "" ) ), DTOC( field->datisp ), "" ) )
    xml_node("dvr", ALLTRIM( field->vrijeme ) )

    // dokument iz teksta
    cTmp := ALLTRIM(get_dtxt_opis("D01"))
    xml_node("dmj", to_xml_encoding(cTmp))

    cTmp := ALLTRIM(get_dtxt_opis("D02"))
    xml_node("ddok", to_xml_encoding(cTmp))

    cTmp := ALLTRIM(get_dtxt_opis("D04"))
    xml_node("dslovo", to_xml_encoding(cTmp))

    xml_node("dotpr", to_xml_encoding( ALLTRIM(get_dtxt_opis("D05")) ) )
    xml_node("dnar", to_xml_encoding( ALLTRIM(get_dtxt_opis("D06")) ) )
    xml_node("ddin", to_xml_encoding( _din_dem ) )

    // destinacija na fakturi
    cTmp := ALLTRIM(get_dtxt_opis("D08"))
    if EMPTY(cTmp)
        // ako je prazno, uzmi adresu partnera
        cTmp := get_dtxt_opis("K02")
    endif

    xml_node("ddest", to_xml_encoding(cTmp))
    xml_node("dtdok", to_xml_encoding( ALLTRIM(get_dtxt_opis("D09")) ) )
    xml_node("drj", to_xml_encoding( ALLTRIM(get_dtxt_opis("D10")) ) )
    xml_node("didpm", to_xml_encoding( ALLTRIM(get_dtxt_opis("D11")) ) )

    // objekat i naziv
    xml_node("obj_id", ALLTRIM( to_xml_encoding( get_dtxt_opis("O01") ) ) )
    xml_node("obj_naz", ALLTRIM( to_xml_encoding( get_dtxt_opis("O02") ) ) )

    // broj fiskalnog racuna
    xml_node("fisc", ALLTRIM(get_dtxt_opis("O10")) )

    cTmp := ALLTRIM(get_dtxt_opis("F10"))
    xml_node("dsign", to_xml_encoding(cTmp))

    // broj veze
    nLines := VAL( get_dtxt_opis("D30") )
    cTmp := ""
    nTmp := 30
    for i:=1 to nLines
        cTmp += get_dtxt_opis("D" + ALLTRIM(STR( nTmp + i )))
    next
    xml_node("dveza", to_xml_encoding(cTmp))

    // partner
    xml_node("knaz", to_xml_encoding(ALLTRIM(get_dtxt_opis("K01"))) )
    xml_node("kadr", to_xml_encoding(ALLTRIM(get_dtxt_opis("K02"))) )
    xml_node("kid", to_xml_encoding(ALLTRIM(get_dtxt_opis("K03"))) )
    xml_node("kpbr", ALLTRIM(get_dtxt_opis("K05")) )
    xml_node("kmj", to_xml_encoding(ALLTRIM(get_dtxt_opis("K10"))) )
    xml_node("kptt", ALLTRIM(get_dtxt_opis("K11")) )
    xml_node("ktel", to_xml_encoding( ALLTRIM(get_dtxt_opis("K13")) ) )
    xml_node("kfax", to_xml_encoding( ALLTRIM(get_dtxt_opis("K14")) ) )

    // dodatni tekst na fakturi....
    // koliko ima redova ?
    nTxtR := VAL( get_dtxt_opis("P02") )

    for i := 20 to ( 20 + nTxtR )
    
        cTmp := "F" + ALLTRIM( STR(i) )
        cTmpTxt := ALLTRIM( get_dtxt_opis(cTmp) )

        xml_subnode("text", .f.)
        xml_node("row", to_xml_encoding(cTmpTxt) )
        xml_subnode("text", .t.)

    next

    // RN
    // brdok, rbr, podbr, idroba, robanaz, jmj, kolicina, cjenpdv, cjenbpdv
    // cjen2pdv, cjen2bpdv, popust, ppdv, vpdv, ukupno, poptp, vpoptp
    // c1, c2, c3, opis

    // predji sada na stavke fakture
    select rn
    go top

    do while !EOF()
    
        xml_subnode( "item", .f. )
    
        xml_node( "rbr", ALLTRIM( field->rbr ) )
        xml_node( "pbr", ALLTRIM( field->podbr ) )
        xml_node( "id", to_xml_encoding(ALLTRIM( field->idroba )) )
        xml_node( "naz", to_xml_encoding(ALLTRIM( field->robanaz )))
        xml_node( "jmj", to_xml_encoding(ALLTRIM( field->jmj )) )
        xml_node( "kol", show_number( field->kolicina, PIC_KOLICINA ) )
        xml_node( "cpdv", show_number( field->cjenpdv, PIC_CIJENA ) )
        xml_node( "cbpdv", show_number( field->cjenbpdv, PIC_CIJENA ) )
        xml_node( "c2pdv", show_number( field->cjen2pdv, PIC_CIJENA ) )
        xml_node( "c2bpdv", show_number( field->cjen2bpdv, PIC_CIJENA ) )
        xml_node( "pop", show_number( field->popust, PIC_VRIJEDNOST ) )
        xml_node( "ppdv", show_number( field->ppdv, PIC_VRIJEDNOST ) )
        xml_node( "vpdv", show_number( field->vpdv, PIC_VRIJEDNOST ) )
        // ukupno bez pdv
        xml_node( "ukbpdv", show_number( field->cjenbpdv * field->kolicina, ;
            PIC_VRIJEDNOST ) )
        // ukupno sa pdv
        xml_node( "ukpdv", show_number( field->ukupno, PIC_VRIJEDNOST ) )
        // ukupno bez pdv-a sa popustom
        xml_node( "uk2bpdv", show_number( field->cjen2bpdv * field->kolicina, ;
            PIC_VRIJEDNOST ) )
        // ukupno sa pdv-om sa popustom
        xml_node( "uk2pdv", show_number( field->cjen2pdv * field->kolicina, ;
            PIC_VRIJEDNOST ) )
        xml_node( "ptp", show_number( field->poptp, PIC_VRIJEDNOST ) )
        xml_node( "vtp", show_number( field->vpoptp, PIC_VRIJEDNOST ) )

        xml_node( "opis", to_xml_encoding( field->opis ) )

        xml_subnode( "item", .t. )
    
        skip

    enddo

    xml_subnode("invoice_no", .t.)

next

xml_subnode("invoice", .t.)

close_xml()

return


