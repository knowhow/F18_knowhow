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

static PIC_VRIJEDNOST := ""
static LEN_VRIJEDNOST := 12

// -----------------------------------------------------
// stampa naloga za proizvodnju u odt formatu...
// -----------------------------------------------------
function rnal_nalog_za_proizvodnju_odt()
local _groups := {}
local _params
local _cnt := 0
local _doc_no, _doc_gr
local _ok := .f.
local _template := "nalprg.odt"
local _po_grupama := .t.

t_rpt_open()

select t_docit
set order to tag "2"
go top
_doc_no := field->doc_no

// izvuci sve grupe....
do while !EOF() .and. field->doc_no == _doc_no
	
	// grupa dokumenta
	_doc_gr := field->doc_gr_no
	
	do while !EOF() .and. field->doc_no == _doc_no .and. ;
			field->doc_gr_no == _doc_gr
		
		skip		
	enddo
	
	++ _cnt
	
	AADD( _groups, { _doc_gr, _cnt })
	
enddo

select t_docit
go top

// uzmi mi sve parametre za nalog
// header, footer itd...
_get_t_pars( @_params, LEN( _groups ) )

// kreiraj xml
if !_cre_xml( _groups, _params ) 
    return _ok
endif

// zatvori nepotrebne tabele
select t_docit
use
select t_docop
use
select t_pars
use

if LEN( _groups ) == 1 .and. _groups[ 1, 1 ] == 0
    _po_grupama := .f.
endif

// lansiraj odt
if f18_odt_generate( _template )
    f18_odt_print()
endif

_ok := .t.
return _ok



// ------------------------------------------------------
// citanje vrijednosti iz tabele tpars u hash matricu
// ------------------------------------------------------
static function _get_t_pars( params, groups_total )
local _tmp

params := hb_hash()

// ttotal
_tmp := VAL( g_t_pars_opis("N10") )
params["ttotal"] := _tmp
// rekapitulacija materijala
params["rekap_materijala"] := ( ALLTRIM( g_t_pars_opis("N20") ) == "D" )


// operater
_tmp := g_t_pars_opis("N13")
params["nalog_operater"] := _tmp
// operater koji printa
_tmp := getfullusername( getUserid( f18_user() ) )
params["nalog_print_operater"] := _tmp
// vrijeme printanja
_tmp := PADR( TIME(), 5 )
params["nalog_print_vrijeme"] := _tmp

// podaci header-a
// ==============================================
// broj dokumenta
params["nalog_broj"] := g_t_pars_opis("N01")
// naziv naloga
params["nalog_naziv"] := "NALOG ZA PROIZVODNJU br."
// koliko je ukupno grupa na nalogu
params["nalog_grupa_total"] := ALLTRIM( STR( groups_total ) )
// tekuca grupa
params["nalog_grupa"] := ALLTRIM( STR( 1 ) )
// datum naloga
params["nalog_datum"] := g_t_pars_opis("N02")
// vrijeme naloga
params["nalog_vrijeme"] := g_t_pars_opis("N12")
// datum isporuke
params["nalog_isp_datum"] := g_t_pars_opis("N03")
// vrijeme isporuke
params["nalog_isp_vrijeme"] := g_t_pars_opis("N04")
// prioritet naloga
params["nalog_prioritet"] := g_t_pars_opis("N05")
// mjesto isporuke
params["nalog_isp_mjesto"] := g_t_pars_opis("N07")
// dodatni opis naloga
params["nalog_dod_opis"] := g_t_pars_opis("N08")
// objekat id
params["nalog_objekat_id"] := g_t_pars_opis("P20")
// naziv objekta
params["nalog_objekat_naziv"] := g_t_pars_opis("P21")
// vrsta placanja
params["nalog_vrsta_placanja"] := g_t_pars_opis("N06")
// placeno
params["nalog_placeno"] := g_t_pars_opis("N10")
// placanje dodatni opis
params["nalog_placanje_opis"] := g_t_pars_opis("N11")


// podaci kupca
// ===============================================
// firma
params["firma_naziv"] := ALLTRIM( gFNaziv )
// kupac
params["kupac_id"] := g_t_pars_opis("P01")
params["kupac_naziv"] := g_t_pars_opis("P02")
params["kupac_adresa"] := g_t_pars_opis("P03")
params["kupac_telefon"] := g_t_pars_opis("P04")
// kontakt
params["kontakt_id"] := g_t_pars_opis("P10")
params["kontakt_naziv"] := g_t_pars_opis("P11")
params["kontakt_telefon"] := g_t_pars_opis("P12")
params["kontakt_opis"] := g_t_pars_opis("P13")
params["kontakt_opis_2"] := g_t_pars_opis("N09")


return .t.



// -------------------------------------------------------
// kreiranje xml fajla na osnovu podataka...
// -------------------------------------------------------
static function _cre_xml( groups, params )
local _ok := .f.
local _i, _group_id
local _groups_count, _groups_total
local _doc_rbr
local _doc_it_type
local _rekap := .f.
local _qtty_total := 0
local _count
local _t_total
local _xml := my_home() + "data.xml"
local _picdem := "999999999.99"

PIC_VRIJEDNOST := PADL( ALLTRIM( RIGHT( _picdem, LEN_VRIJEDNOST ) ), LEN_VRIJEDNOST, "9" )

// otvori xml za upis...
open_xml( _xml )

xml_subnode( "nalozi", .f. )

// upisi osvnovne podatke naloga
xml_node( "fdesc", to_xml_encoding( params["firma_naziv"] ) )
xml_node( "no", params["nalog_broj"] )
xml_node( "desc", to_xml_encoding( params["nalog_naziv"] ) )
xml_node( "gr_total", params["nalog_grupa_total"] )
xml_node( "date", params["nalog_datum"] )
xml_node( "time", params["nalog_vrijeme"] )
xml_node( "d_date", params["nalog_isp_datum"] )
xml_node( "d_time", params["nalog_isp_vrijeme"] )
xml_node( "d_place", to_xml_encoding( params["nalog_isp_mjesto"] ) )
xml_node( "prior", to_xml_encoding( params["nalog_prioritet"] ) )
xml_node( "desc_2", to_xml_encoding( params["nalog_dod_opis"] ) )
xml_node( "ob_id", to_xml_encoding( params["nalog_objekat_id"] ) )
xml_node( "ob_desc", to_xml_encoding( params["nalog_objekat_naziv"] ) )
xml_node( "oper", to_xml_encoding( params["nalog_operater"] ) )
xml_node( "oper_print", to_xml_encoding( params["nalog_print_operater"] ) )
xml_node( "pr_time", params["nalog_print_vrijeme"] )
xml_node( "vrpl", params["nalog_vrsta_placanja"] )

// kupac/kontakt podaci...
xml_node( "cust_id", to_xml_encoding( params["kupac_id"] ) )
xml_node( "cust_desc", to_xml_encoding( params["kupac_naziv"] ) )
xml_node( "cust_adr", to_xml_encoding( params["kupac_adresa"] ) )
xml_node( "cust_tel", to_xml_encoding( params["kupac_telefon"] ) )
xml_node( "cont_id", to_xml_encoding( params["kontakt_id"] ) )
xml_node( "cont_desc", to_xml_encoding( params["kontakt_naziv"] ) )
xml_node( "cont_tel", to_xml_encoding( params["kontakt_telefon"] ) )
xml_node( "cont_desc_2", to_xml_encoding( params["kontakt_opis"] ) )
xml_node( "cont_desc_3", to_xml_encoding( params["kontakt_opis_2"] ) )

for _i := 1 to LEN( groups )

    // subnode
    xml_subnode( "nalog", .f. )
    
    // uzmi broj grupe
    _group_id := groups[ _i, 1 ]

    // grupa naloga, naziv grupe
    params["nalog_grupa"] := ALLTRIM( STR( _group_id ) )
    params["nalog_grupa_naziv"] := get_art_docgr( _group_id )
    xml_node( "gr_no", params["nalog_grupa"] )
    xml_node( "gr_desc", to_xml_encoding( params["nalog_grupa_naziv"] ) )

    // broj stranice, ukupni broj stranica
    xml_node( "pg_no", ALLTRIM(STR( _i )) )
    xml_node( "pg_total", ALLTRIM(STR( LEN( groups ) )) )
    
    select t_docit
    set order to tag "2"
    go top
    
    _doc_no := field->doc_no

    seek docno_str( _doc_no ) + STR( _group_id, 2 )

    _art_id := 0
    _art_tmp := 0

    _l_opis_artikla := .f.
    _l_opis_stavke := .f.

    _opis_stavke := ""
    _opis_stavke_tmp := ""

    _doc_rbr := 0
    _qtty_total := 0
    _count := 0

    do while !EOF() .and. field->doc_no == _doc_no .and. field->doc_gr_no == _group_id
	
        xml_subnode( "item", .f. )
	    
	    _art_id := field->art_id
	    _item_type := field->doc_it_typ
	
        // redni broj
        xml_node( "no", ALLTRIM( STR( ++_doc_rbr ) ) )

        // naziv artikla
        if !EMPTY( field->art_desc )
            xml_node( "desc", to_xml_encoding( ALLTRIM( field->art_desc ) ) )	
        else
            xml_node( "desc", to_xml_encoding( ALLTRIM( "-||-" ) ) )	
        endif

        // operacije i obrade
	    select t_docop
	    set order to tag "1"
	    go top
	    seek docno_str( t_docit->doc_no ) + docit_str( t_docit->doc_it_no )

	    do while !EOF() .and. field->doc_no == t_docit->doc_no ;
			            .and. field->doc_it_no == t_docit->doc_it_no

	        // uzmi element
	        _el_no := field->doc_el_no
	        _el_desc := 1
	        _el_count := 0
        
            xml_subnode( "element", .f. )		
	
            xml_node( "no", ALLTRIM( STR( field->doc_el_no ) ) )
	    	xml_node( "desc", to_xml_encoding( ALLTRIM(field->doc_el_des) ) )
			
	        do while !EOF() .and. field->doc_no == t_docit->doc_no ;
	    		            .and. field->doc_it_no == t_docit->doc_it_no ;
			                .and. field->doc_el_no == _el_no
		
                xml_subnode( "oper", .f. )
           
			    // iskljuci ga do daljnjeg
			    _el_desc := 0
	
		        if !EMPTY( field->aop_desc ) .and. ALLTRIM(field->aop_desc) <> "?????"
                    xml_node( "cnt", ALLTRIM(STR( ++_el_count ) ) )
                    xml_node( "op_desc", to_xml_encoding( field->aop_desc ) )
		        else
                    xml_node( "cnt", ALLTRIM(STR(0)) )
                    xml_node( "op_desc", "" )
                endif

		        if !EMPTY(field->aop_att_de) .and. ALLTRIM(field->aop_att_de) <> "?????"
                    xml_node( "att_desc", to_xml_encoding( ALLTRIM( field->aop_att_de ) ) )
                    xml_node( "att_val", to_xml_encoding( ALLTRIM( field->aop_value ) ) )
		        else
                    xml_node( "att_desc", "" )
                    xml_node( "att_val", "" )
                endif
		
		        if !EMPTY( field->doc_op_des )  
			        xml_node( "notes", to_xml_encoding( ALLTRIM( field->doc_op_des ) ) )
		        endif
	
		        xml_subnode( "oper", .t. )

                select t_docop		
		        skip
	   
	        enddo

            xml_subnode( "element", .t. )

	    enddo

	    select t_docit
	
	    if _item_type == "R"
            
            // tip
            xml_node( "type", "fi" )	  

	        // prikazi fi
            if ROUND( field->doc_it_wid + field->doc_it_hei, 2 ) == 0
                // nema podataka
                xml_node( "w", "" )
	            xml_node( "h", "" )
            else
	            xml_node( "h", "" )
                if ROUND( field->doc_it_wid, 2 ) == ROUND( field->doc_it_hei, 2 ) 
	                xml_node( "w", show_number( field->doc_it_wid, PIC_VRIJEDNOST ) )
                else
	                xml_node( "w", show_number( field->doc_it_wid, PIC_VRIJEDNOST ) + ", " + show_number( field->doc_it_hei, PIC_VRIJEDNOST ) )
                endif
            endif

	    elseif _item_type == "S"

	        // tip	
            xml_node( "type", "shp" )	  
            // sirina kod shape
	        xml_node( "w", show_number( field->doc_it_wid, PIC_VRIJEDNOST ) + "/" + show_number( field->doc_it_w2, PIC_VRIJEDNOST ) )
            // visina kod shape
	        xml_node( "h", show_number( field->doc_it_hei, PIC_VRIJEDNOST ) + "/" + show_number( field->doc_it_h2, PIC_VRIJEDNOST ) )
  
	    else

            // tip	
            xml_node( "type", "std" )
            // sirina
	        xml_node( "w", show_number( field->doc_it_wid, PIC_VRIJEDNOST ) )
            // visina
	        xml_node( "h", show_number( field->doc_it_hei, PIC_VRIJEDNOST ) )

	    endif
	
        // kolicina
        xml_node( "kol", show_number( field->doc_it_qtt, PIC_VRIJEDNOST ) )
        _qtty_total += field->doc_it_qtt
	
	    // napomene za item:
	    // - napomene
	    // - shema u prilogu

        _tmp := ""
        _opis_stavke := ""
        _l_opis_stavke := .f.

	    if !EMPTY( field->doc_it_des ) ;
		        .or. field->doc_it_alt <> 0 ;
		        .or. ( field->doc_it_sch == "D" )
	
		    _tmp := "Napomene: " + ALLTRIM( field->doc_it_des )
		
		    if field->doc_it_sch == "D"
			    _tmp += " "
			    _tmp += "(SHEMA U PRILOGU)"
		    endif	

		    // nadmorska visina
		    if field->doc_it_alt <> 0
			
			    if !EMPTY( field->doc_acity )
                    _tmp += " "
				    _tmp += "Montaza: "
				    _tmp += ALLTRIM(field->doc_acity)
			    endif
			
			    _tmp += ", "
			    _tmp += "nadmorska visina = " + ALLTRIM(STR(field->doc_it_alt, 12, 2)) + " m"
		    
            endif
	
		    _opis_stavke := _tmp
            _tmp := ""
		    
            if ( ALLTRIM( _opis_stavke_tmp ) <> ALLTRIM( _opis_stavke ) ) .or. ( _art_tmp <> _art_id )
			    _l_opis_stavke := .t.
		    endif

        endif

        if _l_opis_stavke
            xml_node( "note", to_xml_encoding( _opis_stavke )  )	
        else
            xml_node( "note", "" )	
        endif

        xml_subnode( "item", .t. )

	    select t_docit
	    skip

	    _opis_stavke_tmp := _opis_stavke
        _art_tmp := _art_id
	
	    ++ _count
	
    enddo

    xml_node( "qtty", show_number( _qtty_total, PIC_VRIJEDNOST ) )

    xml_subnode( "nalog", .t. )

// --------------------------- vsasa, stampa
next

// rekapitulacija materijala treba
xml_subnode( "rekap", .f. )

select t_docit2
go top

if RECCOUNT2() <> 0 .and. params["rekap_materijala"]
	
    seek docno_str( _doc_no )

    do while !EOF() 

	    if _doc_no > 0
		    if field->doc_no <> _doc_no
			    skip
			    loop
		    endif
	    endif

	    _r_doc := field->doc_no
	    _r_doc_it_no := field->doc_it_no

	    // da li se treba stampati ?
	    select t_docit
	    seek docno_str( _r_doc ) + docit_str( _r_doc_it_no )
	
	    if field->print == "N"
		    select t_docit2
		    skip
		    loop
	    endif
	
	    // vrati se
	    select t_docit2

	    do while !EOF() .and. field->doc_no == _r_doc ;
		                .and. field->doc_it_no == _r_doc_it_no
		
            xml_subnode( "item", .f. )

            xml_node( "no", ALLTRIM(STR( field->it_no )) )
            xml_node( "id", to_xml_encoding( ALLTRIM( field->art_id ) ) )
            xml_node( "desc", to_xml_encoding( ALLTRIM( field->art_desc ) ) )
            xml_node( "notes", to_xml_encoding( ALLTRIM( field->descr ) ) )
            xml_node( "qtty", ALLTRIM( STR( field->doc_it_qtt, 12, 2 ) ) )

            xml_subnode( "item", .t. )

		    skip
	    enddo

    enddo

endif

xml_subnode( "rekap", .t. )

xml_subnode( "nalozi", .t. )

// zatvori xml za upis
close_xml()

_ok := .t.

return _ok






