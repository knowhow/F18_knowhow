/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "rnal.ch"

function lab_print( temp )

if temp == nil
    temp := .f.
endif

t_rpt_open()

select t_docit
go top

_lab_print( temp )

return


static function _lab_print( temp, direct_print )
local lCheckErr := .f.
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
local _t_path := F18_TEMPLATE_LOCATION

if direct_print == nil
    direct_print := .f.
endif

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

open_xml( _data_xml )
xml_head()
xml_subnode("label", .f.)

xml_node( "c_desc", ALLTRIM(cC_desc) )
xml_node( "c_tel", ALLTRIM(cC_tel) )
xml_node( "c_addr", ALLTRIM(cC_addr) )
xml_node( "cn_desc", ALLTRIM(cCn_desc) )
xml_node( "cn_tel", ALLTRIM(cCn_desc) )
xml_node( "cn_addr", ALLTRIM(cCn_desc) )
xml_node( "obj", ALLTRIM(cObject) )

select t_docit
set order to tag "1"
go top

do while !EOF()

    nDoc_no := field->doc_no
    nDoc_it_no := field->doc_it_no
    nArt_id := field->art_id
    
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
    
    for lab_cnt := 1 to nQty
      
      xml_subnode( "glass", .f. )
    
      xml_node( "id", ALLTRIM(STR(nArt_id)) )
    
      xml_node( "ldesc", cL_desc )
    
      xml_node( "sdesc", cS_desc )
    
      xml_node( "fdesc", cF_desc )
      
      xml_node( "city", cCity )
    
      xml_node( "altt", cAltt )

      xml_node( "qtty", ALLTRIM(STR(1, 12)) )
      
      xml_node( "tqt", ALLTRIM(STR(nQty, 12)) )
      
      xml_node( "type", cArt_type ) 
      
      cTmp_h := ALLTRIM( STR(nHeight, 12, 2) )
      cTmp_w := ALLTRIM( STR(nWidth, 12, 2) )
      
      xml_node( "full_he", cTmp_h )
      xml_node( "full_wi", cTmp_w )
      
      xml_node( "dim", cTmp_w + " x " + cTmp_h )
     
      cTmp_h := ALLTRIM( STR(nIHeight, 12, 2) )
      cTmp_w := ALLTRIM( STR(nIWidth, 12, 2) )
      
      xml_node( "dim_in", cTmp_w + " x " + cTmp_h )
 
      cTmp_h := ALLTRIM( STR(nHeight, 12) )
      cTmp_w := ALLTRIM( STR(nWidth, 12) )
      
      xml_node( "sh_he", cTmp_h )
      xml_node( "sh_wi", cTmp_w )
     
      xml_node( "l_pos", cL_pos_def )
      
      xml_node( "l_epos", cLe_pos_def )
    
      xml_node( "pos", cPosition )

      xml_subnode( "glass", .t. )
    
    next

    select t_docit
    skip

enddo

xml_subnode("label", .t.)

close_xml()

_template := ""

if get_file_list_array( _t_path, "_rg*.odt", @_template ) = 0
    return
endif

if f18_odt_generate( _template, _data_xml )
    f18_odt_print()
endif

return


