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



/*

*/
FUNCTION rnal_stampa_naljepnica_odt( temp )

   IF temp == nil
      temp := .F.
   ENDIF

   t_rpt_open()

   SELECT t_docit
   GO TOP

   generisi_xml()

   RETURN



STATIC FUNCTION generisi_xml()

   LOCAL _data_xml := my_home() + "data.xml"
   LOCAL _h_stavke, _h_header, _uk_kolicina

   open_xml( _data_xml )
   xml_head()
   xml_subnode( "label", .F. )

   _h_header := hash_header_naljepnice()
   upisi_header_xml( _h_header )

   SELECT t_docit
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      _uk_kolicina := field->doc_it_qtt

	  _h_stavke := hash_podaci_naljepnice()

      FOR lab_cnt := 1 TO _uk_kolicina
         upisi_stavke_xml( _h_stavke, _uk_kolicina )
      NEXT

      SELECT t_docit
      SKIP

   ENDDO

   xml_subnode( "label", .T. )

   close_xml()

   stampaj_odt( _data_xml )

   RETURN




STATIC FUNCTION upisi_header_xml( hash )

   xml_node( "c_desc", hash["cust_desc"] )
   xml_node( "c_tel", hash["cust_tel"] )
   xml_node( "c_addr", hash["cust_adr"] )
   xml_node( "cn_desc", hash["cont_desc"] )
   xml_node( "cn_tel", hash["cont_tel"] )
   xml_node( "cn_addr", hash["cont_adr"] )
   xml_node( "obj", hash["cust_object"] )

   RETURN



STATIC FUNCTION upisi_stavke_xml( hash, ukupna_kolicina )

   LOCAL cTmp_h, cTmp_w

   xml_subnode( "glass", .F. )

   xml_node( "id", AllTrim( Str( hash["art_id"] ) ) )
   xml_node( "ldesc", AllTrim( hash["ldesc"] ) )
   xml_node( "sdesc", AllTrim( hash["sdesc"] ) )
   xml_node( "fdesc", AllTrim( hash["fdesc"] ) )
   xml_node( "city", hash["city"] )
   xml_node( "altt", hash["altitude"] )
   xml_node( "qtty", AllTrim( Str( 1, 12 ) ) )
   xml_node( "tqt", AllTrim( Str( ukupna_kolicina, 12 ) ) )
   xml_node( "type", hash["article_type"] )

   cTmp_h := AllTrim( Str( hash["height"], 12, 2 ) )
   cTmp_w := AllTrim( Str( hash["width"], 12, 2 ) )

   xml_node( "full_he", cTmp_h )
   xml_node( "full_wi", cTmp_w )
   xml_node( "dim", cTmp_w + " x " + cTmp_h )

   cTmp_h := AllTrim( Str( hash["height_inch"], 12, 2 ) )
   cTmp_w := AllTrim( Str( hash["width_inch"], 12, 2 ) )

   xml_node( "dim_in", cTmp_w + " x " + cTmp_h )

   cTmp_h := AllTrim( Str( hash["height"], 12 ) )
   cTmp_w := AllTrim( Str( hash["width"], 12 ) )

   xml_node( "sh_he", cTmp_h )
   xml_node( "sh_wi", cTmp_w )

   xml_node( "l_pos", hash["def_position"] )
   xml_node( "l_epos", hash["def_position_en"] )
   xml_node( "pos", hash["position"] )

   xml_subnode( "glass", .T. )


   RETURN



STATIC FUNCTION hash_header_naljepnice()

   LOCAL hash := hb_hash()

   hash["cust_desc"] := ALLTRIM( to_xml_encoding( g_t_pars_opis( "P02" ) ) )
   hash["cust_tel"] := ALLTRIM( g_t_pars_opis( "P04" ) )
   hash["cust_adr"] := ALLTRIM( to_xml_encoding( g_t_pars_opis( "P03" ) ) )
   hash["cont_desc"] := ALLTRIM( to_xml_encoding( g_t_pars_opis( "P11" ) ) )
   hash["cont_tel"] := ALLTRIM( g_t_pars_opis( "P12" ) )
   hash["cont_adr"] := ALLTRIM( to_xml_encoding( g_t_pars_opis( "P13" ) ) )

   IF hash["cust_desc"] == "NN"
      hash["cust_desc"] := hash["cont_desc"]
      hash["cust_tel"] := hash["cont_tel"]
      hash["cust_adr"] := hash["cont_adr"]
   ENDIF

   hash["cust_object"] := ALLTRIM( to_xml_encoding( g_t_pars_opis( "P21" ) ) )

   RETURN hash



STATIC FUNCTION hash_podaci_naljepnice()

   LOCAL hash := hb_hash()

   SELECT t_docit

   hash["def_position"] := "Unutra"
   hash["def_position_en"] := "Inside"
 
   hash["doc_no"] := field->doc_no
   hash["doc_it_no"] := field->doc_it_no
   hash["art_id"] := field->art_id

   SELECT articles
   GO TOP
   SEEK artid_str( hash["art_id"] )

   hash["ldesc"] := to_xml_encoding( AllTrim( field->art_lab_de ) )
   hash["fdesc"] := to_xml_encoding( AllTrim( field->art_full_d ) )
   hash["sdesc"] := to_xml_encoding( AllTrim( field->art_desc ) )

   IF Empty( hash["ldesc"] )
      hash["ldesc"] := hash["sdesc"]
   ENDIF

   SELECT t_docit

   hash["height"] := field->doc_it_hei
   hash["width"] := field->doc_it_wid

   hash["height_inch"] := to_inch( field->doc_it_hei )
   hash["width_inch"] := to_inch( field->doc_it_wid )

   hash["qtty"] := field->doc_it_qtt

   hash["position"] := AllTrim( to_xml_encoding( AllTrim( field->doc_it_pos ) ) )
   hash["city"] := AllTrim( to_xml_encoding( AllTrim( field->doc_acity ) ) )
   hash["altitude"] := to_xml_encoding( AllTrim( Str( field->doc_it_alt, 12 ) ) )

   hash["article_type"] := "-"

   IF is_ramaterm( AllTrim( field->art_desc ) )
       hash["article_type"] := "RAMA-TERM"
   ENDIF

   RETURN hash




STATIC FUNCTION stampaj_odt( xml_file )

   LOCAL _template := ""
   LOCAL _t_path := F18_TEMPLATE_LOCATION

   IF get_file_list_array( _t_path, "_rg*.odt", @_template ) = 0
      RETURN
   ENDIF

   IF f18_odt_generate( _template, xml_file )
      f18_odt_print()
   ENDIF

   RETURN


