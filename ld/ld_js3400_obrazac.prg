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


#include "ld.ch"


static __mj_od
static __mj_do
static __god_od
static __god_do
static __por_per
static __datum
static __djl_broj
static __op_jmb
static __op_ime

// ------------------------------------------
// obrazac JS3400
// ------------------------------------------
function r_js3400_obrazac()
local nC1:=20
local i
local cRj := SPACE(60)
local cRJDef := SPACE(2)
local cRadnik := SPACE(_LR_) 
local cPrimDobra := SPACE(100)
local cIdRj
local cMj_od
local cMj_do
local cGod_od
local cGod_do
local cDopr10 := "10"
local cDopr11 := "11"
local cDopr12 := "12"
local cDopr1X := "1X"
local cTipRpt := "1"
local cTP_off := SPACE(100)
local cObracun := gObracun
local cWinPrint := "S"
local _x := 1
local _oper := "O"

// kreiraj pomocnu tabelu
ol_tmp_tbl()

cIdRj := gRj
cMj_od := gMjesec
cMj_do := gMjesec
cGod_od := gGodina
cGod_do := gGodina

cPredNaz := SPACE(50)
cPredAdr := SPACE(50)
cPredJMB := SPACE(13)
cPredOpc := SPACE(30)
cPredTel := SPACE(30)
cPredEml := SPACE(50)
cDjlBroj := SPACE(20)
cOpJmb := SPACE(16)
cOpIme := SPACE(50)

nPorGodina := YEAR(DATE())
dDatUnosa := DATE()
dDatPodnosenja := DATE()

// otvori tabele
ol_o_tbl()

// upisi parametre...
cPredNaz := HB_UTF8TOSTR( fetch_metric( "obracun_plata_preduzece_naziv", NIL, cPredNaz ) )
cPredAdr := HB_UTF8TOSTR( fetch_metric( "obracun_plata_preduzece_adresa", NIL, cPredAdr ) )
cPredJMB := HB_UTF8TOSTR( fetch_metric( "obracun_plata_preduzece_id_broj", NIL, cPredJMB ) )
cPredOpc := HB_UTF8TOSTR( fetch_metric( "obracun_plata_preduzece_opcina", NIL, cPredOpc ) )
cPredTel := HB_UTF8TOSTR( fetch_metric( "obracun_plata_preduzece_telefon", NIL, cPredTel ) )
cPredEml := HB_UTF8TOSTR( fetch_metric( "obracun_plata_preduzece_email", NIL, cPredEml ) )
cDjlBroj := HB_UTF8TOSTR( fetch_metric( "obracun_plata_js_obrazac_djelovodni_broj", NIL, cDjlBroj ) )
cOpJmb := HB_UTF8TOSTR( fetch_metric( "obracun_plata_js_obrazac_op_jmb", NIL, cOpJmb ) )
cOpIme := HB_UTF8TOSTR( fetch_metric( "obracun_plata_js_obrazac_op_ime", NIL, cOpIme ) )

Box("#JS-3400", 22, 75)

    @ m_x + _x, m_y + 2 SAY "Radne jedinice: " GET cRj PICT "@!S25"

    ++ _x
    @ m_x + _x, m_y + 2 SAY "Period od:" GET cMj_od pict "99"
    @ m_x + _x, col() + 1 SAY "/" GET cGod_od pict "9999"
    @ m_x + _x, col() + 1 SAY "do:" GET cMj_do pict "99" 
    @ m_x + _x, col() + 1 SAY "/" GET cGod_do pict "9999"
    @ m_x + _x, col()+2 SAY "Obracun:" GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)

    ++ _x
    ++ _x 
    @ m_x + _x, m_y + 2 SAY "Radnik (prazno-svi radnici): " GET cRadnik ;
        VALID EMPTY(cRadnik) .or. P_RADN(@cRadnik)

    ++ _x
    ++ _x
    @ m_x + _x, m_y + 2 SAY "   Doprinos iz pio: " GET cDopr10 

    ++ _x
    @ m_x + _x, m_y + 2 SAY "   Doprinos iz zdr: " GET cDopr11

    ++ _x
    @ m_x + _x, m_y + 2 SAY "   Doprinos iz nez: " GET cDopr12

    ++ _x
    @ m_x + _x, m_y + 2 SAY "Doprinos iz ukupni: " GET cDopr1X

    ++ _x
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Naziv preduzeca: " GET cPredNaz pict "@S30"
    @ m_x + _x, col() + 1 SAY "JID: " GET cPredJMB

    ++ _x
    @ m_x + _x, m_y + 2 SAY "Adr.: " GET cPredAdr pict "@S30"
    @ m_x + _x, col() + 1 SAY "Sifra opc: " GET cPredOpc pict "@S10"

    ++ _x
    @ m_x + _x, m_y + 2 SAY "Tel.: " GET cPredTel pict "@S20"
    @ m_x + _x, col() + 1 SAY "Email: " GET cPredEml pict "@S30"

    ++ _x
    ++ _x
    @ m_x + _x, m_y + 2 SAY "(1) JS-3400 " GET cTipRpt VALID cTipRpt $ "1" 
    @ m_x + _x, col() + 2 SAY "def.rj" GET cRJDef 
    @ m_x + _x, col() + 2 SAY "st./exp.(S/E)?" GET cWinPrint VALID cWinPrint $ "SE" PICT "@!" 

    ++ _x
    ++ _x
    @ m_x + _x, m_y + 2 SAY "P.godina" GET nPorGodina PICT "9999"
    @ m_x + _x, col() + 2 SAY "Dat.podnos." GET dDatPodnosenja 
    @ m_x + _x, col() + 2 SAY "Dat.unosa" GET dDatUnosa 

    ++ _x
    @ m_x + _x, m_y + 2 SAY "Dj.broj:" GET cDjlBroj PICT "@S10"
    @ m_x + _x, col() + 2 SAY "Podnosi:" GET cOpIme PICT "@S20"
    @ m_x + _x, col() + 2 SAY "JMB:" GET cOpJmb 

    ++ _x
    @ m_x + _x, m_y + 2 SAY "operacija: (O)snovna (P)onovljena " GET _oper VALID _oper $ "OP" PICT "@!"
    
    read

    cOperacija := g_operacija( _oper )

    clvbox()
    
    ESC_BCR

BoxC()

if lastkey() == K_ESC
    return
endif

// staticke
__mj_od := cMj_od
__mj_do := cMj_do
__god_od := cGod_od
__god_do := cGod_do
__por_per := nPorGodina
__datum := dDatPodnosenja
__djl_broj := cDjlBroj
__op_jmb := cOpJmb
__op_ime := cOpIme

// upisi parametre...
set_metric( "obracun_plata_preduzece_naziv", NIL, cPredNaz )
set_metric( "obracun_plata_preduzece_adresa", NIL, cPredAdr )
set_metric( "obracun_plata_preduzece_id_broj", NIL, cPredJMB )
set_metric( "obracun_plata_preduzece_opcina", NIL, cPredOpc ) 
set_metric( "obracun_plata_preduzece_telefon", NIL, cPredTel )
set_metric( "obracun_plata_preduzece_email", NIL, cPredEml ) 
set_metric( "obracun_plata_js_obrazac_djelovodni_broj", NIL, cDjlBroj )
set_metric( "obracun_plata_js_obrazac_op_jmb", NIL, cOpJmb ) 
set_metric( "obracun_plata_js_obrazac_op_ime", NIL, cOpIme ) 

select ld

// sortiraj tabelu i postavi filter
ol_sort( cRj, cGod_od, cGod_do, cMj_od, cMj_do, cRadnik, cTipRpt, cObracun )

// nafiluj podatke obracuna
ol_fill_data( cRj, cRjDef, cGod_od, cGod_do, cMj_od, cMj_do, cRadnik, ;
    cPrimDobra, cTP_off, cDopr10, cDopr11, cDopr12, cDopr1X, cTipRpt, ;
    cObracun )


// stampa izvjestaja xml/oo3
_xml_print( cTipRpt )

return


// ------------------------------------------------------
// vraca vrstu operacije
// ------------------------------------------------------
static function g_operacija( oper )
local _operacija := ""

if oper == "O"
    _operacija := "Osnovna"
elseif oper == "P"
    _operacija := "Ponovljena"
endif

return _operacija


// --------------------------------------
// vraca period osiguranja
// --------------------------------------
static function g_osig( mjesec, od_do )
local _ret := ""
local _tmp
local _day

if EMPTY( ALLTRIM( STR( mjesec ) ) )
    return _ret
endif

if od_do == "1"
    _day := "01"
else
    do case
        case mjesec = 1 .or. mjesec = 3 .or. mjesec = 5 .or. mjesec = 7 .or. mjesec = 8 .or. mjesec = 10 .or. mjesec = 12
            _day := "31"
        case mjesec = 2
            _day := "28"
        case mjesec = 4 .or. mjesec = 6 .or. mjesec = 9 .or. mjesec = 11
            _day := "30"
    endcase
endif

// mjesec/dan
_ret := PADL( ALLTRIM( STR( mjesec  ) ) , 2, "0" )
_ret += "/" + _day

return _ret



// ----------------------------------------
// stampa xml-a
// ----------------------------------------
static function _xml_print( tip )
local _template
local _xml_file := my_home() + "data.xml"

// napuni xml fajl
_fill_xml( tip, _xml_file )

do case
    case tip == "1"
        _template := "ld_js_1.odt"
endcase

// generisi report
if f18_odt_generate( _template, _xml_file )
    f18_odt_print()
endif

return


// --------------------------------------------
// filuje xml fajl sa podacima izvjestaja
// --------------------------------------------
static function _fill_xml( cTip, xml_file )
local nTArea := SELECT()
local nT_bruto := 0
local nT_sati := 0
local nT_dop_u := 0
local nT_d_zdr := 0
local nT_d_pio := 0
local nT_d_nez := 0
local nR_bruto := 0
local nR_sati := 0
local nR_dop_u := 0
local nR_d_zdr := 0
local nR_d_pio := 0
local nR_d_nez := 0
local nOsig_od, nOsig_do

// otvori xml za upis
open_xml( xml_file )
// upisi header
xml_head()

xml_subnode("rpt", .f.)

// naziv firme
xml_node( "p_naz", to_xml_encoding( ALLTRIM(cPredNaz) ) )
xml_node( "p_adr", to_xml_encoding( ALLTRIM(cPredAdr) ) )
xml_node( "p_jmb", ALLTRIM(cPredJmb) )
xml_node( "p_opc", ALLTRIM(cPredOpc) )
xml_node( "p_tel", ALLTRIM(cPredTel) )
xml_node( "p_eml", ALLTRIM(cPredEml) )
xml_node( "p_per", g_por_per() )
xml_node( "datum", DTOC( __datum ) )
xml_node( "pod_ime", to_xml_encoding( ALLTRIM( __op_ime ) ) )
xml_node( "pod_jmb", to_xml_encoding( ALLTRIM( __op_jmb ) ) )
xml_node( "dj_broj", to_xml_encoding( ALLTRIM( __djl_broj ) ) )

select r_export
set order to tag "1"
go top

nCnt := 0

do while !EOF()
    
    // po radniku
    cT_radnik := field->idradn
    
    // pronadji radnika u sifrarniku
    select radn
    seek cT_radnik

    select r_export

    nR_bruto := 0
    nR_sati := 0
    nR_dop_u := 0
    nR_d_zdr := 0
    nR_d_pio := 0
    nR_d_nez := 0
   
    // startna vrijednost osiguranja
    nOsig_od := field->mjesec
     
    // prodji kroz radnike i saberi im vrijednosti...
    do while !EOF() .and. field->idradn == cT_radnik

        // ukupni doprinosi
        replace field->dop_uk with field->dop_pio + ;
            field->dop_nez + field->dop_zdr

        nR_bruto += field->bruto
        nT_bruto += field->bruto

        nR_sati += field->sati
        nT_sati += field->sati

        nR_dop_u += field->dop_uk
        nT_dop_u += field->dop_uk

        nR_d_zdr += field->dop_zdr
        nT_d_zdr += field->dop_zdr

        nR_d_pio += field->dop_pio
        nT_d_pio += field->dop_pio

        nR_d_nez += field->dop_nez
        nT_d_nez += field->dop_nez

        // krajnja vrijednost osiguranja
        nOsig_do := field->mjesec

        skip

    enddo

    // subnode radnik
    xml_subnode("radnik", .f.)

      xml_node("ime", to_xml_encoding( ALLTRIM(radn->ime) + ;
        " (" + ALLTRIM(radn->imerod) + ;
        ") " + ALLTRIM(radn->naz) ) )

      xml_node("os_od", ALLTRIM( g_osig( nOsig_od, "1" ) ) )
      xml_node("os_do", ALLTRIM( g_osig( nOsig_do, "2" ) ) )
      xml_node("mb", ALLTRIM(radn->matbr) )
      xml_node("rbr", STR( ++ nCnt ) )
      xml_node("sati", STR( nR_sati ) )
      xml_node("bruto", STR( nR_bruto, 12, 2 ) )
      xml_node("do_uk", STR( nR_dop_u, 12, 2 ) )
      xml_node("do_pio", STR( nR_d_pio, 12, 2 ) )
      xml_node("do_zdr", STR( nR_d_zdr, 12, 2 ) )
      xml_node("do_nez", STR( nR_d_nez, 12, 2 ) )

    // zatvori radnika
    xml_subnode("radnik", .t.)

enddo

// upisi totale za radnika
xml_subnode("total", .f.)

    xml_node("red", STR( nCnt ) )
    xml_node("sati", STR( nT_sati, 12, 2 ) )
    xml_node("bruto", STR( nT_bruto, 12, 2 ) )
    xml_node("do_uk", STR( nT_dop_u, 12, 2 ) )
    xml_node("do_pio", STR( nT_d_pio, 12, 2 ) )
    xml_node("do_zdr", STR( nT_d_zdr, 12, 2 ) )
    xml_node("do_nez", STR( nT_d_nez, 12, 2 ) )

xml_subnode("total", .t.)
    
// zatvori <rpt>
xml_subnode("rpt", .t.)

select (nTArea)

// zatvori xml fajl za upis
close_xml()

return


// ----------------------------------------------------------
// vraca string poreznog perioda
// ----------------------------------------------------------
static function g_por_per()
local _ret := ""

_ret := ALLTRIM( STR( __por_per ) )

return _ret


