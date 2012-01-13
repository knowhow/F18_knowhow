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


// ------------------------------------------------------
// glavna funkcija za poziv stampe labele
// -----------------------------------------------------
function lab_print( lTemporary )

if lTemporary == nil
    lTemporary := .f.
endif

t_rpt_open()

select t_docit
go top

_lab_print( lTemporary )

return


// -----------------------------------
// stampa labele...
// -----------------------------------
static function _lab_print( lTemporary, lDirectPrint )
local lCheckErr := .f.
// default vrijednost pozicije
local cL_pos_def := "Unutra"
local cLe_pos_def := "Inside"
local cF_desc
local cS_desc
local cL_desc
local cDim
local cPosition
local cOdtName
local cC_desc
local cC_tel
local cC_addr
local cCn_desc
local cCn_tel
local cCn_addr
local cCity
local _template
local _data_xml := my_home() + "data.xml"

if lDirectPrint == nil
    lDirectPrint := .f.
endif

// daj mi osnovne podatke o dokumentu
cC_desc := to_xml_encoding( g_t_pars_opis("P02") )
cC_tel := g_t_pars_opis("P04")
cC_addr := to_xml_encoding( g_t_pars_opis("P03") )
cCn_desc := to_xml_encoding( g_t_pars_opis("P11") )
cCn_tel := g_t_pars_opis("P12")
cCn_addr := to_xml_encoding( g_t_pars_opis("P13") )

if ALLTRIM( cC_desc ) == "NN"
    cC_desc := cCn_desc
    cC_tel := cCn_tel
    cC_addr := cCn_addr
endif

cObject := to_xml_encoding( g_t_pars_opis("P21") )

// otvori xml za upis
open_xml( _data_xml )
// upisi header
xml_head()
// <label>
xml_subnode("label", .f.)

// <c_desc></c_desc>
xml_node( "c_desc", ALLTRIM(cC_desc) )
// <c_tel></c_tel>
xml_node( "c_tel", ALLTRIM(cC_tel) )
// <c_addr></c_addr>
xml_node( "c_addr", ALLTRIM(cC_addr) )
// <cn_desc></cn_desc>
xml_node( "cn_desc", ALLTRIM(cCn_desc) )
// <cn_tel></cn_tel>
xml_node( "cn_tel", ALLTRIM(cCn_desc) )
// <cn_addr></cn_addr>
xml_node( "cn_addr", ALLTRIM(cCn_desc) )

// <obj></obj>
xml_node( "obj", ALLTRIM(cObject) )

// sada prodji po stavkama
select t_docit
set order to tag "1"
go top

// stampaj podatke 
do while !EOF()

    nDoc_no := field->doc_no
    nDoc_it_no := field->doc_it_no

    nArt_id := field->art_id
    
    // nadji aritkal
    select articles
    go top
    seek artid_str(nArt_id)
    
    cL_desc := to_xml_encoding( ALLTRIM( field->art_lab_de ) )
    cF_desc := to_xml_encoding( ALLTRIM( field->art_full_d ) )
    cS_desc := to_xml_encoding( ALLTRIM( field->art_desc ) )

    if EMPTY(cL_desc)
        cL_desc := cS_desc
    endif

    select t_docit

    nHeight := field->doc_it_hei
    nWidth := field->doc_it_wid
    
    // daj i u inche
    nIHeight := to_inch( nHeight )
    nIWidth := to_inch( nWidth )

    nQty := field->doc_it_qtt
    
    cPosition := to_xml_encoding( ALLTRIM(field->doc_it_pos) )
    cCity := to_xml_encoding( ALLTRIM( field->doc_acity ) )
    cAltt := to_xml_encoding( ALLTRIM( STR( field->doc_it_alt, 12 ) ) )
   
    cArt_type := "-"

    if is_ramaterm( ALLTRIM(field->art_desc) )
        cArt_type := "RAMA-TERM"
    endif
    
    // koliko stavki ima, toliko i labela
    for lab_cnt := 1 to nQty
      
      // <glass>
      xml_subnode( "glass", .f. )
    
      // <id>212</id>
      xml_node( "id", ALLTRIM(STR(nArt_id)) )
    
      // <ldesc>4F ...</ldesc>
      xml_node( "ldesc", cL_desc )
    
      // <sdesc>4F_A12...</sdesc>
      xml_node( "sdesc", cS_desc )
    
      // <fdesc>Staklo Float clear 4mm ...</fdesc>
      xml_node( "fdesc", cF_desc )
      
      // <city></city>
      xml_node( "city", cCity )
    
      // <altt></altt>
      xml_node( "altt", cAltt )

      // <qtty>1</qtty>
      xml_node( "qtty", ALLTRIM(STR(1, 12)) )
      
      // <tqtty>17</tqtty>
      xml_node( "tqt", ALLTRIM(STR(nQty, 12)) )
      
      // <type>RAMA-TERM</type>
      xml_node( "type", cArt_type ) 
      
      cTmp_h := ALLTRIM( STR(nHeight, 12, 2) )
      cTmp_w := ALLTRIM( STR(nWidth, 12, 2) )
      
      // <full_he>250</full_he>
      xml_node( "full_he", cTmp_h )
      // <full_wi>300</full_wi>
      xml_node( "full_wi", cTmp_w )
      
      // <dim>300 x 250</dim>
      xml_node( "dim", cTmp_w + " x " + cTmp_h )
     
      cTmp_h := ALLTRIM( STR(nIHeight, 12, 2) )
      cTmp_w := ALLTRIM( STR(nIWidth, 12, 2) )
      
      // <dim_in>300 x 250</dim_in>
      xml_node( "dim_in", cTmp_w + " x " + cTmp_h )
 
      cTmp_h := ALLTRIM( STR(nHeight, 12) )
      cTmp_w := ALLTRIM( STR(nWidth, 12) )
      
      // <sh_he>250</sh_he>
      xml_node( "sh_he", cTmp_h )
      // <sh_wi>300</sh_wi>
      xml_node( "sh_wi", cTmp_w )
     
      // <l_pos>unutra</l_pos>
      xml_node( "l_pos", cL_pos_def )
      
      // <l_epos>unutra</l_epos>
      xml_node( "l_epos", cLe_pos_def )
    
      // <pos>P1</pos>
      xml_node( "pos", cPosition )

      // </glass>
      xml_subnode( "glass", .t. )
    
    next

    select t_docit
    skip

enddo

// </label>
xml_subnode("label", .t.)
// zatvori xml za upis
close_xml()

_template := ""
// izaberi sablon
if g_afile( my_home(), "_rg*.odt", @_template ) = 0
    return
endif

// pokreni generisanje template fajla i pokreni oo3
_run_j_reports( _template )
_run_o_office()

return


// ---------------------------------------------------------
// startanje jod reports
// ---------------------------------------------------------
static function _run_j_reports( template_file )
local _java_start := ALLTRIM( gJavaStart )
local _chk_error := .f.
local _sv_screen
local _jod_report := ALLTRIM( gJODRep )
local _data_xml
local _out_file
local _template

_data_xml := my_home() + "data.xml"
_out_file := my_home() + "rg-lab.odt"
_template := my_home() + template_file

#ifdef __PLATFORM_WINDOWS
    _data_xml := '"' + _data_xml + '"'
    _out_file := '"' + _out_file + '"'
    _template := '"' + _template + '"'
#endif

if Pitanje( , "Provjeriti gresku ? (D/N)", "N" ) == "D"
    _chk_error := .t.
endif

// pokreni generisanje i stampu
save screen to _sv_screen

clear screen

// stampanje labele

// cmdline: java -jar jodreports-cli.jar template.odt data.xml output.odt

// java -jar jodreports-cli.jar
_cmd_line := _java_start + " " + _jod_report + " "
// template file
_cmd_line += _template + " " 
// data.xml
_cmd_line += _data_xml + " " 
// output file
_cmd_line += _out_file 

? _cmd_line
?

run (_cmd_line)

// zaustavi se da vidis o cemu se radi
if _chk_error == .t.
    inkey(0)
endif

restore screen from _sv_screen

return


// ------------------------------------------
// pokreni open office 
// ------------------------------------------
static function _run_o_office()
local _sv_screen
local _oo_start
local _cmd_line
local _out_file

_oo_start := ALLTRIM( gOOPath ) + ALLTRIM( gOOWriter )
_out_file := my_home() + "rg-lab.odt"

#ifdef __PLATFORM__WINDOWS
    _oo_start := '"' + ALLTRIM( gOOPath ) + ALLTRIM( gOOWriter ) + '"'
    _out_file := '"' + my_home() + "rg-lab.odt" + '"'
#endif

save screen to _sv_screen
clear screen

// otvori naljepnicu
_cmd_line := _oo_start + " " + _out_file

run (_cmd_line)

restore screen from _sv_screen

return


// -----------------------------------------
// uzmi labelu za stampu
// -----------------------------------------
static function _g_label( cPath, cLabel )
local cFilter := "_rg*.odt"
local nPx := m_x
local nPy := m_y

cLabel := "rg-1.odt"

OpcF:={}

aFiles := DIRECTORY( cPath + cFilter )

// da li postoje templejti
if LEN( aFiles )==0
    MsgBeep("Ne postoji definisan niti jedan template !")
    return 0
endif

// sortiraj po datumu
ASORT(aFiles,,,{|x,y| x[3]>y[3]})
AEVAL(aFiles,{|elem| AADD(OpcF, PADR(elem[1],15)+" "+dtos(elem[3]))},1)
// sortiraj listu po datumu
ASORT(OpcF,,,{|x,y| RIGHT(x,10)>RIGHT(y,10)})

h:=ARRAY(LEN(OpcF))
for i:=1 to LEN(h)
    h[i]:=""
next

// selekcija fajla
IzbF:=1
lRet := .f.
do while .t. .and. LastKey()!=K_ESC
    IzbF:=Menu("imp", OpcF, IzbF, .f.)
    if IzbF == 0
            exit
        else
            cLabel := Trim(LEFT(OpcF[IzbF],15))
            if Pitanje(,"Koristiti ovaj template ?","D")=="D"
                IzbF:=0
            lRet:=.t.
        endif
        endif
enddo

m_x := nPx
m_y := nPy

if lRet
    return 1
else
    return 0
endif

return 1



