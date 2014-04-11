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


#include "fin.ch"
#include "hbclass.ch"
#include "common.ch"

// ----------------------------------------------------
// ----------------------------------------------------
CLASS FinBrutoBilans

    DATA params
    DATA data
    DATA zagl
    DATA klase
    
    VAR pict_iznos
    VAR tip

    // tip: 1 - subanaliticki
    // tip: 2 - analiticki
    // tip: 3 - sinteticki
    // tip: 4 - po grupama

    METHOD New()
    METHOD get_data()    

    METHOD print()
    METHOD print_txt()
    METHOD print_odt()

    METHOD create_temp_table()
    METHOD fill_temp_table()

    PROTECTED:

        VAR broj_stranice
        VAR txt_rpt_len

        METHOD set_bb_params()
        METHOD get_vars()
        METHOD gen_xml()

        METHOD init_params()
        METHOD set_txt_lines()
        METHOD zaglavlje_txt()

        METHOD rekapitulacija_klasa()        

ENDCLASS



// ----------------------------------------------------
// ----------------------------------------------------
METHOD FinBrutoBilans:New( _tip_ )

::tip := 1
::klase := {}
::data := NIL
::broj_stranice := 0
::txt_rpt_len := 60
::init_params()

if _tip_ <> NIL
    ::tip := _tip_
endif

return SELF


// ----------------------------------------------------
// ----------------------------------------------------
METHOD FinBrutoBilans:init_params()

::params := hb_hash()
::params["idfirma"] := gFirma
::params["datum_od"] := CTOD("")
::params["datum_do"] := DATE()
::params["konto"] := ""
::params["valuta"] := 1
::params["id_rj"] := ""
::params["export_dbf"] := .f.
::params["saldo_nula"] := .f.
::params["txt"] := .t.
::params["kolona_tek_prom"] := .t.
::params["naziv"] := ""
::params["odt_template"] := ""

::pict_iznos := ALLTRIM( gPicBHD )

return SELF



// ----------------------------------------------------
// ----------------------------------------------------
METHOD FinBrutoBilans:set_bb_params()

do case 
    case ::tip == 1
        ::params["naziv"] := "SUBANALITIČKI BRUTO BILANS"
        ::params["odt_template"] := "fin_bbl.odt"
    case ::tip == 2
        ::params["naziv"] := "ANALITIČKI BRUTO BILANS"
        ::params["odt_template"] := "fin_bbl.odt"
    case ::tip == 3
        ::params["naziv"] := "SINTETIČKI BRUTO BILANS"
        ::params["odt_template"] := "fin_bbl.odt"
    case ::tip == 4
        ::params["naziv"] := "BRUTO BILANS PO GRUPAMA"
        ::params["odt_template"] := "fin_bbl.odt"
endcase

return SELF



// ------------------------------------------------------
// ------------------------------------------------------
METHOD FinBrutoBilans:get_vars()
local _ok := .f.
local _val := 1
local _x := 1
local _valuta := 1
local _user := my_user()
local _konto := PADR( fetch_metric( "fin_bb_konto", _user, "" ), 200 )
local _dat_od := fetch_metric( "fin_bb_dat_od", _user, CTOD("") )
local _dat_do := fetch_metric( "fin_bb_dat_do", _user, CTOD("") )
local _txt := 1
// izbacujemo za sada ovaj parametar
//fetch_metric( "fin_bb_txt_odt", _user, 1 )
local _tek_prom := fetch_metric( "fin_bb_kol_tek_promet", _user, "D" )
local _saldo_nula := fetch_metric( "fin_bb_saldo_nula", _user, "D" )
local _id_rj := SPACE(6)
local _export_dbf := "N"
local _tip := 1

if ::tip <> NIL
    _tip := ::tip
endif

Box(, 17, 70 )

    @ m_x + _x, m_y + 2 SAY "***** BRUTO BILANS *****"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "ODABERI VRSTU BILANSA:"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "[1] subanaliticki  [2] analiticki  [3] sinteticki  [4] po grupama :" GET _tip PICT "9"

    READ

    if LastKey() == K_ESC
        return _ok
    endif

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "**** USLOVI IZVJESTAJA:"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Firma "
    ?? gFirma, "-", ALLTRIM( gNFirma )

    ++ _x

 	@ m_x + _x, m_y + 2 SAY "Konta (prazno-sva):" GET _konto PICT "@!S40"
        
    ++ _x

 	@ m_x + _x, m_y + 2 SAY "Za period od:" GET _dat_od
 	@ m_x + _x, col() + 1 SAY "do:" GET _dat_do

    ++ _x
    ++ _x

 	@ m_x + _x, m_y + 2 SAY "Varijanta stampe TXT/ODT (1/2):" GET _txt PICT "9" WHEN .f.

    ++ _x

 	@ m_x + _x, m_y + 2 SAY "Prikaz stavki sa saldom 0 (D/N) ?" GET _saldo_nula VALID _saldo_nula $ "DN" PICT "@!"

    ++ _x

 	@ m_x + _x, m_y + 2 SAY "Prikaz kolone tekuci promet (D/N) ?" GET _tek_prom VALID _tek_prom $ "DN" PICT "@!"

 	if _tip == 1 .and. gRJ == "D"
        ++ _x
        _id_rj := "999999"
   		@ m_x + _x, m_y + 2 SAY "Radna jedinica ( 999999-sve ): " GET _id_rj
 	endif
 	
    ++ _x
 	@ m_x + _x, m_y + 2 SAY "Export izvjestaja u DBF (D/N) ?" GET _export_dbf VALID _export_dbf $ "DN" PICT "@!"

    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

// snimi parametre
set_metric( "fin_bb_konto", _user, ALLTRIM( _konto ) )
set_metric( "fin_bb_dat_od", _user, _dat_od )
set_metric( "fin_bb_dat_do", _user, _dat_do )
set_metric( "fin_bb_saldo_nula", _user, _saldo_nula )
set_metric( "fin_bb_txt_odt", _user, _txt )
set_metric( "fin_bb_kol_tek_promet", _user, _tek_prom )

::params["idfirma"] := gFirma
::params["konto"] := ALLTRIM( _konto )
::params["datum_od"] := _dat_od
::params["datum_do"] := _dat_do
::params["valuta"] := _valuta
::params["id_rj"] := _id_rj
::params["export_dbf"] := ( _export_dbf == "D" )
::params["saldo_nula"] := ( _saldo_nula == "D" )
::params["kolona_tek_prom"] := ( _tek_prom == "D" )
// tekstualnu varijantu postavljamo kao defaultnu dok se ne ispravi bug #32651
::params["txt"] := .t. 

::tip := _tip

// setuj dodatne parametre
::set_bb_params()

_ok := .t.

return _ok





// ---------------------------------------------------------------
// ---------------------------------------------------------------
METHOD FinBrutoBilans:get_data()
local _qry, _data
local _server := my_server()
local _konto := ::params["konto"]
local _dat_od := ::params["datum_od"]
local _dat_do := ::params["datum_do"]
local _id_rj := ::params["id_rj"]
local _iznos_dug := "iznosbhd"
local _iznos_pot := "iznosbhd"
local _table := "fmk.fin_suban"
local _date_field := "sub.datdok"

if ::tip == 2

    _table := "fmk.fin_anal"
    _date_field := "sub.datnal"

    _iznos_dug := "dugbhd"
    _iznos_pot := "potbhd"

elseif ::tip > 2

    _table := "fmk.fin_sint"
    _date_field := "sub.datnal"

    _iznos_dug := "dugbhd"
    _iznos_pot := "potbhd"

endif

// valuta 1 = domaca
if ::params["valuta"] == 2

    _iznos_dug := "iznosdem"
    _iznos_pot := "iznosdem"

    if ::tip > 1
        _iznos_dug := "dugdem"
        _iznos_pot := "potdem"
    endif

endif

_where := "WHERE sub.idfirma = " + _filter_quote( gFirma )
_where += " AND " + _sql_date_parse( _date_field, _dat_od, _dat_do )

if !EMPTY( _konto )
    _where += " AND " + _sql_cond_parse( "sub.idkonto", _konto + " " )
endif

if ::tip == 1
    if !EMPTY( _id_rj ) .and. _id_rj <> "999999"
        _where += " AND sub.idrj = " + _sql_quote( _id_rj ) 
    endif
endif

_qry := "SELECT "

if ::tip == 1 .or. ::tip == 2
    _qry += "sub.idkonto, "
elseif ::tip == 3
    _qry += " rpad( sub.idkonto, 3 ) AS idkonto, "
elseif ::tip == 4
    _qry += " rpad( sub.idkonto, 2 ) AS idkonto, "
endif

if ::tip == 1 

    _qry += "sub.idpartner, " 

    _qry += "SUM( CASE WHEN sub.d_p = '1' AND sub.idvn = '00' THEN sub." + _iznos_dug + " END ) as ps_dug, " 
    _qry += "SUM( CASE WHEN sub.d_p = '2' AND sub.idvn = '00' THEN sub." + _iznos_pot + " END ) as ps_pot, "

    if ::params["kolona_tek_prom"]
        _qry += "SUM( CASE WHEN sub.d_p = '1' AND sub.idvn <> '00' THEN sub." + _iznos_dug + " END ) as tek_dug, " 
        _qry += "SUM( CASE WHEN sub.d_p = '2' AND sub.idvn <> '00' THEN sub." + _iznos_pot + " END ) as tek_pot, "
    endif

    _qry += "SUM( CASE WHEN sub.d_p = '1' THEN sub." + _iznos_dug + " END ) as kum_dug, "
    _qry += "SUM( CASE WHEN sub.d_p = '2' THEN sub." + _iznos_pot + " END ) as kum_pot "

elseif ::tip > 1

    _qry += "SUM( CASE WHEN sub.idvn = '00' THEN sub." + _iznos_dug + " END ) as ps_dug, " 
    _qry += "SUM( CASE WHEN sub.idvn = '00' THEN sub." + _iznos_pot + " END ) as ps_pot, "

    if ::params["kolona_tek_prom"]
        _qry += "SUM( CASE WHEN sub.idvn <> '00' THEN sub." + _iznos_dug + " END ) as tek_dug, " 
        _qry += "SUM( CASE WHEN sub.idvn <> '00' THEN sub." + _iznos_pot + " END ) as tek_pot, "
    endif

    _qry += "SUM( sub." + _iznos_dug + " ) as kum_dug, "
    _qry += "SUM( sub." + _iznos_pot + " ) as kum_pot "

endif

_qry += "FROM " + _table + " sub " 

_qry += _where + " " 

if ::tip == 1
    _qry += "GROUP BY sub.idkonto, sub.idpartner " 
    _qry += "ORDER BY sub.idkonto, sub.idpartner "
elseif ::tip == 2
    _qry += "GROUP BY sub.idkonto "
    _qry += "ORDER BY sub.idkonto "
elseif ::tip == 3
    _qry += "GROUP BY rpad( sub.idkonto, 3 ) "
    _qry += "ORDER BY rpad( sub.idkonto, 3 ) "
elseif ::tip == 4
    _qry += "GROUP BY rpad( sub.idkonto, 2 ) "
    _qry += "ORDER BY rpad( sub.idkonto, 2 ) "
endif

MsgO( "formiranje sql upita u toku ..." )
_data := _sql_query( _server, _qry )
MsgC()

if VALTYPE( _data ) == "L" .or. _data:LastRec() == 0
    MsgBeep( "Ne postoje trazeni podaci !!!" )
    return NIL
endif

::data := _data

return SELF




// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
METHOD FinBrutoBilans:set_txt_lines()
local _arr := {}
local _tmp 
local oRPT := ReportCommon():new()

// r.br
_tmp := 4
AADD( _arr, { _tmp, PADC("R.", _tmp ), PADC("br.", _tmp ), PADC("", _tmp ) })

if ::tip == 4
    // grupa konta
    _tmp := 7
    AADD( _arr, { _tmp, PADC("GRUPA", _tmp ), PADC("KONTA", _tmp), PADC("", _tmp ) })
else
    // konto
    _tmp := 7
    AADD( _arr, { _tmp, PADC("KONTO", _tmp ), PADC("", _tmp), PADC("", _tmp ) })
endif

if ::tip == 1
    // partner
    _tmp := 6
    AADD( _arr, { _tmp, PADC("PART-", _tmp ), PADC("NER", _tmp ), PADC("", _tmp) })
    // naziv konto/partner
    _tmp := 40
    AADD( _arr, { _tmp, PADC("NAZIV KONTA ILI PARTNERA", _tmp ), PADC("", _tmp ), PADC("", _tmp) })
elseif ::tip == 2
    // naziv konto/partner
    _tmp := 40
    AADD( _arr, { _tmp, PADC("NAZIV ANALITIČKOG KONTA", _tmp ), PADC("", _tmp ), PADC("", _tmp) })
elseif ::tip == 3
    // naziv konto/partner
    _tmp := 40
    AADD( _arr, { _tmp, PADC("NAZIV SINTETIČKOG KONTA", _tmp ), PADC("", _tmp ), PADC("", _tmp) })
endif

// pocetno stanje
_tmp := ( LEN( ::pict_iznos ) * 2 ) + 1
AADD( _arr, { _tmp, PADC( "POČETNO STANJE", _tmp), PADC( REPL("-", _tmp ), _tmp ), PADC( "DUGUJE     POTRAŽUJE" , _tmp ) })

if ::params["kolona_tek_prom"]
    // tekuci promet
    AADD( _arr, { _tmp, PADC("TEKUĆI PROMET", _tmp), PADC( REPL("-", _tmp ), _tmp), PADC( "DUGUJE     POTRAŽUJE" , _tmp ) })
endif

// kumulativni promet
AADD( _arr, { _tmp, PADC("KUMULATIVNI PROMET", _tmp), PADC( REPL("-", _tmp ), _tmp), PADC( "DUGUJE     POTRAŽUJE" , _tmp ) })

// saldo
AADD( _arr, { _tmp, PADC("SALDO", _tmp), PADC( REPL("-", _tmp ), _tmp ), PADC( "DUGUJE     POTRAŽUJE" , _tmp ) })

oRPT:zagl_arr := _arr

::zagl := hb_hash()
::zagl["line"] := oRPT:get_zaglavlje( 0 )

oRPT:zagl_delimiter := "*"

::zagl["txt1"] := hb_utf8tostr( oRPT:get_zaglavlje( 1, "*" ) )
::zagl["txt2"] := hb_utf8tostr( oRPT:get_zaglavlje( 2, "*" ) )
::zagl["txt3"] := hb_utf8tostr( oRPT:get_zaglavlje( 3, "*" ) )

return SELF




// -----------------------------------------------------
// -----------------------------------------------------
METHOD FinBrutoBilans:zaglavlje_txt()


Preduzece()

P_COND2

?
? "FIN: " + hb_utf8tostr( ::params["naziv"] ) + " U VALUTI " + if( ::params["valuta"] == 1, ValDomaca(), ValPomocna() )
?? " ZA PERIOD OD", ::params["datum_od"], "-", ::params["datum_do"]
?? " NA DAN: "
?? DATE()

@ prow(), 100 SAY "Str:" + STR( ++ ::broj_stranice, 3 )

? ::zagl["line"]
? ::zagl["txt1"]
? ::zagl["txt2"]
? ::zagl["txt3"]
? ::zagl["line"]

return SELF



// ---------------------------------------------------
// ---------------------------------------------------
METHOD FinBrutoBilans:gen_xml()
local _xml := "data.xml"
local _sint_len := 3
local _kl_len := 1
local _a_klase := {}
local _klasa, _i, _count
local _u_ps_dug := _u_ps_pot := _u_kum_dug := _u_kum_pot := _u_tek_dug := _u_tek_pot := _u_sld_dug := _u_sld_pot := 0
local _t_ps_dug := _t_ps_pot := _t_kum_dug := _t_kum_pot := _t_tek_dug := _t_tek_pot := _t_sld_dug := _t_sld_pot := 0
local _tt_ps_dug := _tt_ps_pot := _tt_kum_dug := _tt_kum_pot := _tt_tek_dug := _tt_tek_pot := _tt_sld_dug := _tt_sld_pot := 0
local _ok := .f.

if ::tip == 4
    _sint_len := 2
endif

open_xml( my_home() + _xml )

xml_subnode( "rpt", .f. )

xml_subnode( "bilans", .f. )

// header podaci
xml_node( "firma", to_xml_encoding( gFirma ) )
xml_node( "naz", to_xml_encoding( gNFirma ) )
xml_node( "datum", DTOC( DATE() ) )
xml_node( "datum_od", DTOC( ::params["datum_od"] ) )
xml_node( "datum_do", DTOC( ::params["datum_do"] ) )

if !EMPTY( ::params["konto"] )
    xml_node( "konto", to_xml_encoding( ::params["konto"] ) ) 
else
    xml_node( "konto", to_xml_encoding( "- sva konta -" ) ) 
endif

O_R_EXP
select r_export
set order to tag "1"
go top

_count := 0

do while !EOF()

    __konto := _set_sql_record_to_hash( "fmk.konto", field->idkonto )

    _klasa := LEFT( field->idkonto, _kl_len )

    xml_subnode( "klasa", .f. )

    xml_node( "id", to_xml_encoding( _klasa ) )
    
    xml_node( "naz", to_xml_encoding( ALLTRIM( __konto["naz"] ) ) )

    _t_ps_dug := _t_ps_pot := _t_kum_dug := _t_kum_pot := _t_tek_dug := _t_tek_pot := _t_sld_dug := _t_sld_pot := 0
    
    do while !EOF() .and. LEFT( field->idkonto, _kl_len ) == _klasa

        _sint := LEFT( field->idkonto, _sint_len )
        __konto := _set_sql_record_to_hash( "fmk.konto", _sint )

        if __konto == NIL
            MsgBeep( "Ne postoji sintetički konto " + _sint + " u šifraniku konta" )
            return _ok
        endif

        xml_subnode( "sint", .f. )

        xml_node( "id", to_xml_encoding( _sint ) )
        
        xml_node( "naz", to_xml_encoding( ALLTRIM( __konto["naz"] ) ) )

        _u_ps_dug := _u_ps_pot := _u_kum_dug := _u_kum_pot := _u_tek_dug := _u_tek_pot := _u_sld_dug := _u_sld_pot := 0

        do while !EOF() .and. LEFT( field->idkonto, _sint_len ) == _sint 
            	
			xml_subnode( "item", .f. )
        
            xml_node( "rb", ALLTRIM( STR( ++ _count ) ) )
            xml_node( "kto", to_xml_encoding( field->idkonto ) )
            
            if ::tip == 1

                xml_node( "part", to_xml_encoding( field->idpartner ) )
           
                if !EMPTY( field->partner ) 
                    xml_node( "naz", to_xml_encoding( field->partner ) )
                else
                    xml_node( "naz", to_xml_encoding( field->konto ) )
                endif

            elseif ::tip == 2 .or. ::tip == 3
				
				xml_node( "part", "" )
                xml_node( "naz", to_xml_encoding( field->konto ) )

			else
		
				xml_node( "part", "" )
				xml_node( "naz", "" )

            endif

            // iznosi ...
            xml_node( "ps_dug", ALLTRIM( STR( field->ps_dug, 12, 2 ) ) )
            xml_node( "ps_pot", ALLTRIM( STR( field->ps_pot, 12, 2 ) ) )

            xml_node( "tek_dug", ALLTRIM( STR( field->tek_dug, 12, 2 ) ) )
            xml_node( "tek_pot", ALLTRIM( STR( field->tek_pot, 12, 2 ) ) )

            xml_node( "kum_dug", ALLTRIM( STR( field->kum_dug, 12, 2 ) ) )
            xml_node( "kum_pot", ALLTRIM( STR( field->kum_pot, 12, 2 ) ) )

            xml_node( "sld_dug", ALLTRIM( STR( field->sld_dug, 12, 2 ) ) )
            xml_node( "sld_pot", ALLTRIM( STR( field->sld_pot, 12, 2 ) ) )

            // totali sintetički...
            _u_ps_dug += field->ps_dug
            _u_ps_pot += field->ps_pot
            _u_tek_dug += field->tek_dug
            _u_tek_pot += field->tek_pot
            _u_kum_dug += field->kum_dug
            _u_kum_pot += field->kum_pot
            _u_sld_dug += field->sld_dug
            _u_sld_pot += field->sld_pot

            // totali po klasama
            _t_ps_dug += field->ps_dug
            _t_ps_pot += field->ps_pot
            _t_tek_dug += field->tek_dug
            _t_tek_pot += field->tek_pot
            _t_kum_dug += field->kum_dug
            _t_kum_pot += field->kum_pot
            _t_sld_dug += field->sld_dug
            _t_sld_pot += field->sld_pot

            // total ukupno
            _tt_ps_dug += field->ps_dug
            _tt_ps_pot += field->ps_pot
            _tt_tek_dug += field->tek_dug
            _tt_tek_pot += field->tek_pot
            _tt_kum_dug += field->kum_dug
            _tt_kum_pot += field->kum_pot
            _tt_sld_dug += field->sld_dug
            _tt_sld_pot += field->sld_pot

            // dodaj u matricu sa klasama, takodjer totale...
            _scan := ASCAN( _a_klase, { |var| var[1] == LEFT( _sint, 1 ) } )

            if _scan == 0
                // dodaj novu stavku u matricu...
                AADD( _a_klase, { LEFT( _sint, 1 ), ;
                                    field->ps_dug, ;
                                    field->ps_pot, ;
                                    field->tek_dug, ;
                                    field->tek_pot, ;
                                    field->kum_dug, ;
                                    field->kum_pot, ;
                                    field->sld_dug, ;
                                    field->sld_pot } )
            else

                // dodaj na postojeci iznos...

                _a_klase[ _scan, 2 ] := _a_klase[ _scan, 2 ] + field->ps_dug
                _a_klase[ _scan, 3 ] := _a_klase[ _scan, 3 ] + field->ps_pot
                _a_klase[ _scan, 4 ] := _a_klase[ _scan, 4 ] + field->tek_dug
                _a_klase[ _scan, 5 ] := _a_klase[ _scan, 5 ] + field->tek_pot
                _a_klase[ _scan, 6 ] := _a_klase[ _scan, 6 ] + field->kum_dug
                _a_klase[ _scan, 7 ] := _a_klase[ _scan, 7 ] + field->kum_pot
                _a_klase[ _scan, 8 ] := _a_klase[ _scan, 8 ] + field->sld_dug
                _a_klase[ _scan, 9 ] := _a_klase[ _scan, 9 ] + field->sld_pot

            endif

            xml_subnode( "item", .t. )
            
            skip

        enddo
   
        if ::tip < 3
            // upisi totale sintetike 
            // ....
            xml_node( "ps_dug", ALLTRIM( STR( _u_ps_dug, 12, 2 ) ) ) 
            xml_node( "ps_pot", ALLTRIM( STR( _u_ps_pot, 12, 2 ) ) ) 
            xml_node( "kum_dug", ALLTRIM( STR( _u_kum_dug, 12, 2 ) ) ) 
            xml_node( "kum_pot", ALLTRIM( STR( _u_kum_pot, 12, 2 ) ) ) 
            xml_node( "tek_dug", ALLTRIM( STR( _u_tek_dug, 12, 2 ) ) ) 
            xml_node( "tek_pot", ALLTRIM( STR( _u_tek_pot, 12, 2 ) ) ) 
            xml_node( "sld_dug", ALLTRIM( STR( _u_sld_dug, 12, 2 ) ) ) 
            xml_node( "sld_pot", ALLTRIM( STR( _u_sld_pot, 12, 2 ) ) ) 

        endif

        xml_subnode( "sint", .t. )

    enddo

    // uspisi totale klase
    xml_node( "ps_dug", ALLTRIM( STR( _t_ps_dug, 12, 2 ) ) ) 
    xml_node( "ps_pot", ALLTRIM( STR( _t_ps_pot, 12, 2 ) ) ) 
    xml_node( "kum_dug", ALLTRIM( STR( _t_kum_dug, 12, 2 ) ) ) 
    xml_node( "kum_pot", ALLTRIM( STR( _t_kum_pot, 12, 2 ) ) ) 
    xml_node( "tek_dug", ALLTRIM( STR( _t_tek_dug, 12, 2 ) ) ) 
    xml_node( "tek_pot", ALLTRIM( STR( _t_tek_pot, 12, 2 ) ) ) 
    xml_node( "sld_dug", ALLTRIM( STR( _t_sld_dug, 12, 2 ) ) ) 
    xml_node( "sld_pot", ALLTRIM( STR( _t_sld_pot, 12, 2 ) ) ) 

    xml_subnode( "klasa", .t. )

enddo

// ukupni total
xml_node( "ps_dug", ALLTRIM( STR( _tt_ps_dug, 12, 2 ) ) ) 
xml_node( "ps_pot", ALLTRIM( STR( _tt_ps_pot, 12, 2 ) ) ) 
xml_node( "kum_dug", ALLTRIM( STR( _tt_kum_dug, 12, 2 ) ) ) 
xml_node( "kum_pot", ALLTRIM( STR( _tt_kum_pot, 12, 2 ) ) ) 
xml_node( "tek_dug", ALLTRIM( STR( _tt_tek_dug, 12, 2 ) ) ) 
xml_node( "tek_pot", ALLTRIM( STR( _tt_tek_pot, 12, 2 ) ) ) 
xml_node( "sld_dug", ALLTRIM( STR( _tt_sld_dug, 12, 2 ) ) ) 
xml_node( "sld_pot", ALLTRIM( STR( _tt_sld_pot, 12, 2 ) ) ) 

// totali po klasama...
xml_subnode( "total", .f. )

for _i := 1 to LEN( _a_klase )

    xml_subnode( "item", .f. )

    xml_node( "klasa", to_xml_encoding( _a_klase[ _i, 1 ] ) )
    xml_node( "ps_dug", ALLTRIM( STR( _a_klase[ _i, 2 ], 12, 2 ) ) )
    xml_node( "ps_pot", ALLTRIM( STR( _a_klase[ _i, 3 ], 12, 2 ) ) )
    xml_node( "tek_dug", ALLTRIM( STR( _a_klase[ _i, 4 ], 12, 2 ) ) )
    xml_node( "tek_pot", ALLTRIM( STR( _a_klase[ _i, 5 ], 12, 2 ) ) )
    xml_node( "kum_dug", ALLTRIM( STR( _a_klase[ _i, 6 ], 12, 2 ) ) )
    xml_node( "kum_pot", ALLTRIM( STR( _a_klase[ _i, 7 ], 12, 2 ) ) )
    xml_node( "sld_dug", ALLTRIM( STR( _a_klase[ _i, 8 ], 12, 2 ) ) )
    xml_node( "sld_pot", ALLTRIM( STR( _a_klase[ _i, 9 ], 12, 2 ) ) )

    xml_subnode( "item", .t. )

next

xml_subnode( "total", .t. )

xml_subnode( "bilans", .t. )

xml_subnode( "rpt", .t. )

close_xml()

my_close_all_dbf()

_ok := .t.

return _ok




// ----------------------------------------------------------
// ----------------------------------------------------------
METHOD FinBrutoBilans:print()

// parametri...
if EMPTY( ::params["konto"] )
    if !::get_vars()
        return SELF
    endif
endif

// daj mi podatke 
::get_data()

if ::data == NIL
    return SELF
endif

// napuni pomocnu tabelu izvjestaja...
::create_temp_table()
::fill_temp_table()

if ::params["export_dbf"]
    f18_open_mime_document( my_home() + "r_export.dbf" )
    return SELF
endif

if ::params["txt"]
    ::print_txt()
else
    ::print_odt()
endif

return SELF


// -----------------------------------------------
// -----------------------------------------------
METHOD FinBrutoBilans:print_odt()
local _template := "fin_bbl.odt"

// generisi xml report
if ::gen_xml()
    // printaj odt report
    if f18_odt_generate( _template )
	    // printaj odt
        f18_odt_print()
    endif
endif

return SELF





// -----------------------------------------------------------
// -----------------------------------------------------------
METHOD FinBrutoBilans:print_txt()
local _line, _i_col
local _a_klase := {}
local _klasa, _i, _count, _sint, _id_konto, _id_partner, __partn, __klasa, __sint, __konto
local _u_ps_dug := _u_ps_pot := _u_kum_dug := _u_kum_pot := _u_tek_dug := _u_tek_pot := _u_sld_dug := _u_sld_pot := 0
local _t_ps_dug := _t_ps_pot := _t_kum_dug := _t_kum_pot := _t_tek_dug := _t_tek_pot := _t_sld_dug := _t_sld_pot := 0
local _tt_ps_dug := _tt_ps_pot := _tt_kum_dug := _tt_kum_pot := _tt_tek_dug := _tt_tek_pot := _tt_sld_dug := _tt_sld_pot := 0
local _rbr := 0
local _rbr_2 := 0
local _rbr_3 := 0
local _kl_len := 1
local _sint_len := 3

if ::tip == 4
    // po grupama
    _sint_len := 2
endif

// setuj zaglavlje i linije...
::set_txt_lines()

_line := ::zagl["line"]

START PRINT CRET

::zaglavlje_txt()

O_R_EXP
select r_export
set order to tag "1"
go top

do while !EOF()

    _t_ps_dug := _t_ps_pot := _t_kum_dug := _t_kum_pot := _t_tek_dug := _t_tek_pot := _t_sld_dug := _t_sld_pot := 0
    
    _klasa := LEFT( field->idkonto, _kl_len )
    __klasa := _set_sql_record_to_hash( "fmk.konto", _klasa )
   
    if __klasa == NIL
        MsgBeep( "Ne postoji šifra klase " + _klasa + " u šifrarniku konta !" )
        //return Self
    endif
 
    do while !EOF() .and. LEFT( field->idkonto, _kl_len ) == _klasa

        _u_ps_dug := _u_ps_pot := _u_kum_pot := _u_kum_dug := _u_tek_dug := _u_tek_pot := _u_sld_dug := _u_sld_pot := 0
        
        _sint := LEFT( field->idkonto, _sint_len )
        __sint := _set_sql_record_to_hash( "fmk.konto", _sint )

        if __sint == NIL
            MsgBeep( "Ne postoji šifra sintetike " + _sint + " u šifrarniku konta !" )
            //return Self
        endif

        do while !EOF() .and. LEFT( field->idkonto, _sint_len ) == _sint 

            // da li treba prikazivati ?
            if !::params["saldo_nula"] .and. ROUND( field->kum_dug - field->kum_pot, 2 ) == 0
                SKIP
                LOOP
            endif

            // nova stranica i zaglavlje...
            if prow() > ::txt_rpt_len
                FF
                ::zaglavlje_txt()
            endif

            @ prow() + 1, 0 SAY ++ _rbr PICT "9999"
            @ prow(), pcol() + 1 SAY field->idkonto
            
            if ::tip < 4
            
                __konto := _set_sql_record_to_hash( "fmk.konto", field->idkonto )
                
				if ::tip == 1
                    @ prow(), pcol() + 1 SAY field->idpartner
                    __partn := _set_sql_record_to_hash( "fmk.partn", field->idpartner )
                    // ovdje mogu biti šifre koje nemaju partnera a da u sifrarniku nemamo praznog zapisa
                    // znači __partn može biti NIL 
                endif

                if ::tip == 1 .and. !EMPTY( field->idpartner ) 
					if __partn <> NIL
                    	_opis := __partn["naz"]
					else
						_opis := "Nema partnera " + field->idpartner + " !"
					endif
                else
                    _opis := ""
                endif

                // ako nema partnera kao opis će se koristiti naziv konta
                if EMPTY( _opis )
					if __konto <> NIL
                    	_opis := __konto["naz"]
                	else
						_opis := "Nema konta " + field->idkonto + " !" 
					endif
				endif       

                @ prow(), pcol() + 1 SAY PADR( _opis, 40 )
            
            endif

            _i_col := pcol() + 1

            @ prow(), pcol() + 1 SAY field->ps_dug PICT ::pict_iznos
            @ prow(), pcol() + 1 SAY field->ps_pot PICT ::pict_iznos

            if ::params["kolona_tek_prom"]
                @ prow(), pcol() + 1 SAY field->tek_dug PICT ::pict_iznos
                @ prow(), pcol() + 1 SAY field->tek_pot PICT ::pict_iznos
            endif

            @ prow(), pcol() + 1 SAY field->kum_dug PICT ::pict_iznos
            @ prow(), pcol() + 1 SAY field->kum_pot PICT ::pict_iznos

            @ prow(), pcol() + 1 SAY field->sld_dug PICT ::pict_iznos
            @ prow(), pcol() + 1 SAY field->sld_pot PICT ::pict_iznos

            // totali sintetički...
            _u_ps_dug += field->ps_dug
            _u_ps_pot += field->ps_pot
            _u_kum_dug += field->kum_dug
            _u_kum_pot += field->kum_pot
            _u_tek_dug += field->tek_dug
            _u_tek_pot += field->tek_pot
            _u_sld_dug += field->sld_dug
            _u_sld_pot += field->sld_pot

            // totali po klasama
            _t_ps_dug += field->ps_dug
            _t_ps_pot += field->ps_pot
            _t_kum_dug += field->kum_dug
            _t_kum_pot += field->kum_pot
            _t_tek_dug += field->tek_dug
            _t_tek_pot += field->tek_pot
            _t_sld_dug += field->sld_dug
            _t_sld_pot += field->sld_pot

            // total ukupno
            _tt_ps_dug += field->ps_dug
            _tt_ps_pot += field->ps_pot
            _tt_kum_dug += field->kum_dug
            _tt_kum_pot += field->kum_pot
            _tt_tek_dug += field->tek_dug
            _tt_tek_pot += field->tek_pot
            _tt_sld_dug += field->sld_dug
            _tt_sld_pot += field->sld_pot

            // dodaj u matricu sa klasama, takodjer totale...
            _scan := ASCAN( _a_klase, { |var| var[1] == LEFT( _sint, 1 ) } )

            if _scan == 0
                // dodaj novu stavku u matricu...
                AADD( _a_klase, { LEFT( _sint, 1 ), ;
                                    field->ps_dug, ;
                                    field->ps_pot, ;
                                    field->tek_dug, ;
                                    field->tek_pot, ;
                                    field->kum_dug, ;
                                    field->kum_pot, ;
                                    field->sld_dug, ;
                                    field->sld_pot } )
            else

                // dodaj na postojeci iznos...

                _a_klase[ _scan, 2 ] := _a_klase[ _scan, 2 ] + field->ps_dug
                _a_klase[ _scan, 3 ] := _a_klase[ _scan, 3 ] + field->ps_pot
                _a_klase[ _scan, 4 ] := _a_klase[ _scan, 4 ] + field->tek_dug
                _a_klase[ _scan, 5 ] := _a_klase[ _scan, 5 ] + field->tek_pot
                _a_klase[ _scan, 6 ] := _a_klase[ _scan, 6 ] + field->kum_dug
                _a_klase[ _scan, 7 ] := _a_klase[ _scan, 7 ] + field->kum_pot
                _a_klase[ _scan, 8 ] := _a_klase[ _scan, 8 ] + field->sld_dug
                _a_klase[ _scan, 9 ] := _a_klase[ _scan, 9 ] + field->sld_pot

            endif

            SKIP

        enddo

        if ::tip < 3
 
            // nova stranica i zaglavlje...
            if prow() + 3 > ::txt_rpt_len
                FF
                ::zaglavlje_txt()
            endif

            // ispisi sintetiku....
            ? _line

            @ prow() + 1, 2 SAY ++ _rbr_2 PICT "9999"      
            @ prow(), pcol() + 1 SAY _sint
            
            if __sint == NIL
                @ prow(), pcol() + 1 SAY PADR( "Nema sintetičkog konta " + _sint, 40)    
            else
                @ prow(), pcol() + 1 SAY PADR( __sint["naz"], 40 )
            endif

            @ prow(), _i_col SAY _u_ps_dug PICT ::pict_iznos
            @ prow(), pcol() + 1 SAY _u_ps_pot PICT ::pict_iznos

            if ::params["kolona_tek_prom"]
                @ prow(), pcol() + 1 SAY _u_tek_dug PICT ::pict_iznos
                @ prow(), pcol() + 1 SAY _u_tek_pot PICT ::pict_iznos
            endif

            @ prow(), pcol() + 1 SAY _u_kum_dug PICT ::pict_iznos
            @ prow(), pcol() + 1 SAY _u_kum_pot PICT ::pict_iznos

            @ prow(), pcol() + 1 SAY _u_sld_dug PICT ::pict_iznos
            @ prow(), pcol() + 1 SAY _u_sld_pot PICT ::pict_iznos

            ? _line

        endif

    enddo

    // nova stranica i zaglavlje...
    if prow() + 3 > ::txt_rpt_len
        FF
        ::zaglavlje_txt()
    endif

    // ispisi klasu
    ? _line

    @ prow() + 1, 2 SAY ++ _rbr_3 PICT "9999"      
    @ prow(), pcol() + 1 SAY _klasa

    if ::tip < 3
        if __klasa == NIL
            @ prow(), pcol() + 1 SAY PADR( "Nepostojeća šifra klase " + _klasa, 40 )
        else
            @ prow(), pcol() + 1 SAY PADR( __klasa["naz"], 40 )
        endif
    endif

    @ prow(), _i_col SAY _t_ps_dug PICT ::pict_iznos
    @ prow(), pcol() + 1 SAY _t_ps_pot PICT ::pict_iznos

    if ::params["kolona_tek_prom"]
        @ prow(), pcol() + 1 SAY _t_tek_dug PICT ::pict_iznos
        @ prow(), pcol() + 1 SAY _t_tek_pot PICT ::pict_iznos
    endif

    @ prow(), pcol() + 1 SAY _t_kum_dug PICT ::pict_iznos
    @ prow(), pcol() + 1 SAY _t_kum_pot PICT ::pict_iznos

    @ prow(), pcol() + 1 SAY _t_sld_dug PICT ::pict_iznos
    @ prow(), pcol() + 1 SAY _t_sld_pot PICT ::pict_iznos

    ? _line

enddo

::klase := _a_klase

// nova stranica i zaglavlje...
if prow() + 3 > ::txt_rpt_len
    FF
    ::zaglavlje_txt()
endif

? _line
? "UKUPNO"
@ prow(), _i_col SAY _tt_ps_dug PICT ::pict_iznos
@ prow(), pcol() + 1 SAY _tt_ps_pot PICT ::pict_iznos

if ::params["kolona_tek_prom"]
    @ prow(), pcol() + 1 SAY _tt_tek_dug PICT ::pict_iznos
    @ prow(), pcol() + 1 SAY _tt_tek_pot PICT ::pict_iznos
endif

@ prow(), pcol() + 1 SAY _tt_kum_dug PICT ::pict_iznos
@ prow(), pcol() + 1 SAY _tt_kum_pot PICT ::pict_iznos

@ prow(), pcol() + 1 SAY _tt_sld_dug PICT ::pict_iznos
@ prow(), pcol() + 1 SAY _tt_sld_pot PICT ::pict_iznos
? _line

::rekapitulacija_klasa()

FF
END PRINT

my_close_all_dbf()

return SELF




// -----------------------------------------------------------
// -----------------------------------------------------------
METHOD FinBrutoBilans:rekapitulacija_klasa()
local _line
local _kl_ps_dug := _kl_ps_pot := _kl_tek_dug := _kl_tek_pot := _kl_sld_dug := _kl_sld_pot := 0
local _kl_kum_dug := _kl_kum_pot := 0

// nova stranica i zaglavlje...
if prow() + LEN( ::klase ) + 10 > ::txt_rpt_len
    FF
    ::zaglavlje_txt()
endif

?
? "REKAPITULACIJA PO KLASAMA NA DAN: "
?? DATE()
? _line := "--------- --------------- --------------- --------------- --------------- --------------- ---------------"
? hb_utf8tostr( "*        *          POČETNO STANJE       *        KUMULATIVNI PROMET     *            SALDO             *" )
? "  KLASA   ------------------------------- ------------------------------- -------------------------------"
? hb_utf8tostr( "*        *    DUGUJE     *   POTRAŽUJE   *    DUGUJE     *   POTRAŽUJE   *     DUGUJE    *    POTRAŽUJE *" )
? _line 

for _i := 1 to LEN( ::klase )

    @ prow() + 1, 4 SAY ::klase[ _i, 1 ]

    // ps dug / ps pot
    @ prow(), 10 SAY ::klase[ _i, 2 ] PICT ::pict_iznos
    @ prow(), pcol() + 1 SAY ::klase[ _i, 3 ] PICT ::pict_iznos

    // kum dug / tek pot
    @ prow(), pcol() + 1 SAY ::klase[ _i, 6 ] PICT ::pict_iznos
    @ prow(), pcol() + 1 SAY ::klase[ _i, 7 ] PICT ::pict_iznos

    // sld dug / sld pot 
    @ prow(), pcol() + 1 SAY ::klase[ _i, 8 ] PICT ::pict_iznos
    @ prow(), pcol() + 1 SAY ::klase[ _i, 9 ] PICT ::pict_iznos

    _kl_ps_dug += ::klase[ _i, 2 ]
    _kl_ps_pot += ::klase[ _i, 3 ]
 
    _kl_kum_dug += ::klase[ _i, 6 ]
    _kl_kum_pot += ::klase[ _i, 7 ]
 
    _kl_sld_dug += ::klase[ _i, 8 ]
    _kl_sld_pot += ::klase[ _i, 9 ]
    
next

? _line
? "UKUPNO:"
@ prow(), 10 SAY _kl_ps_dug PICT ::pict_iznos
@ prow(), pcol() + 1 SAY _kl_ps_pot PICT ::pict_iznos
@ prow(), pcol() + 1 SAY _kl_kum_dug PICT ::pict_iznos
@ prow(), pcol() + 1 SAY _kl_kum_pot PICT ::pict_iznos
@ prow(), pcol() + 1 SAY _kl_sld_dug PICT ::pict_iznos
@ prow(), pcol() + 1 SAY _kl_sld_pot PICT ::pict_iznos
? _line

return SELF



// -----------------------------------------------------
// -----------------------------------------------------
METHOD FinBrutoBilans:fill_temp_table()
local _count := 0
local oRow, _rec
local __konto, __partn
local _id_konto, _id_partn

O_R_EXP
set order to tag "1"

::data:refresh()
::data:goTo(1)

MsgO( "Punim pomocnu tabelu izvjestaja ..." )

do while !::data:EOF()

    oRow := ::data:GetRow()

    _id_konto := query_row( oRow, "idkonto" )
    __konto := _set_sql_record_to_hash( "fmk.konto", _id_konto )
    
    if ::tip == 1
        // postoji mogućnost da imamo praznog partnera a u šifrarniku nemamo prazan zapis koji bi se uzeo
        // __partn može u konačnici biti = NIL
        _id_partn := query_row( oRow, "idpartner" )
        __partn := _set_sql_record_to_hash( "fmk.partn", _id_partn )
    endif

    select r_export
    append blank
    _rec := dbf_get_rec()

	if __konto <> NIL .and. !EMPTY( __konto["naz"] )
    	_rec["konto"] := PADR( __konto["naz"], 60 )
	else
		_rec["konto"] := "?????????????"
	endif

    _rec["idkonto"] := _id_konto

    if ::tip == 1
        _rec["idpartner"] := _id_partn
        if !EMPTY( _id_partn ) .and. __partn <> NIL
            _rec["partner"] := PADR( __partn["naz"], 100 )
        else
            _rec["partner"] := ""
        endif
    endif

    _rec["ps_dug"] := query_row( oRow, "ps_dug" )
    _rec["ps_pot"] := query_row( oRow, "ps_pot" )

    if ::params["kolona_tek_prom"]
        _rec["tek_dug"] := query_row( oRow, "tek_dug" )
        _rec["tek_pot"] := query_row( oRow, "tek_pot" )
    else
        _rec["tek_dug"] := 0
        _rec["tek_pot"] := 0
    endif

    _rec["kum_dug"] := query_row( oRow, "kum_dug" )
    _rec["kum_pot"] := query_row( oRow, "kum_pot" )

    // sredi kolonu saldo...
    _rec["sld_dug"] := _rec["kum_dug"] - _rec["kum_pot"]

    if _rec["sld_dug"] >= 0
        _rec["sld_pot"] := 0
    else
        _rec["sld_pot"] := - _rec["sld_dug"]
        _rec["sld_dug"] := 0
    endif

    ++ _count

    dbf_update_rec( _rec )

    ::data:SKIP()

enddo

MsgC()

my_close_all_dbf()

return _count




// ----------------------------------------------
// kreiranje pomocne tabele izvjestaja
// ----------------------------------------------
METHOD FinBrutoBilans:create_temp_table()
local _dbf := {}

AADD( _dbf, { "idkonto", "C", 7, 0 } )
AADD( _dbf, { "konto", "C", 60, 0 } )

if ::tip == 1
    AADD( _dbf, { "idpartner", "C", 6, 0 } )
    AADD( _dbf, { "partner", "C", 100, 0 } )
endif

AADD( _dbf, { "ps_dug", "N", 18, 2 } )
AADD( _dbf, { "ps_pot", "N", 18, 2 } )

AADD( _dbf, { "tek_dug", "N", 18, 2 } )
AADD( _dbf, { "tek_pot", "N", 18, 2 } )

AADD( _dbf, { "kum_dug", "N", 18, 2 } )
AADD( _dbf, { "kum_pot", "N", 18, 2 } )

AADD( _dbf, { "sld_dug", "N", 18, 2 } )
AADD( _dbf, { "sld_pot", "N", 18, 2 } )

t_exp_create( _dbf )

O_R_EXP

if ::tip == 1
    index on ( idkonto + idpartner ) TAG "1"
else
    index on ( idkonto ) TAG "1"
endif

return SELF



