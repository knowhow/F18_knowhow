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

FUNCTION lab_print( temp )

   IF temp == nil
      temp := .F.
   ENDIF

   t_rpt_open()

   SELECT t_docit
   GO TOP

   _lab_print( temp )

   RETURN


STATIC FUNCTION _lab_print( temp, direct_print )

   LOCAL lCheckErr := .F.
   LOCAL cL_pos_def := "Unutra"
   LOCAL cLe_pos_def := "Inside"
   LOCAL cF_desc
   LOCAL cS_desc
   LOCAL cL_desc
   LOCAL cDim
   LOCAL cPosition
   LOCAL cOdtName
   LOCAL cC_desc
   LOCAL cC_tel
   LOCAL cC_addr
   LOCAL cCn_desc
   LOCAL cCn_tel
   LOCAL cCn_addr
   LOCAL cCity
   LOCAL _template
   LOCAL _data_xml := my_home() + "data.xml"
   LOCAL _t_path := F18_TEMPLATE_LOCATION

   IF direct_print == nil
      direct_print := .F.
   ENDIF

   cC_desc := to_xml_encoding( g_t_pars_opis( "P02" ) )
   cC_tel := g_t_pars_opis( "P04" )
   cC_addr := to_xml_encoding( g_t_pars_opis( "P03" ) )
   cCn_desc := to_xml_encoding( g_t_pars_opis( "P11" ) )
   cCn_tel := g_t_pars_opis( "P12" )
   cCn_addr := to_xml_encoding( g_t_pars_opis( "P13" ) )

   IF AllTrim( cC_desc ) == "NN"
      cC_desc := cCn_desc
      cC_tel := cCn_tel
      cC_addr := cCn_addr
   ENDIF

   cObject := to_xml_encoding( g_t_pars_opis( "P21" ) )

   open_xml( _data_xml )
   xml_head()
   xml_subnode( "label", .F. )

   xml_node( "c_desc", AllTrim( cC_desc ) )
   xml_node( "c_tel", AllTrim( cC_tel ) )
   xml_node( "c_addr", AllTrim( cC_addr ) )
   xml_node( "cn_desc", AllTrim( cCn_desc ) )
   xml_node( "cn_tel", AllTrim( cCn_desc ) )
   xml_node( "cn_addr", AllTrim( cCn_desc ) )
   xml_node( "obj", AllTrim( cObject ) )

   SELECT t_docit
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      nDoc_no := field->doc_no
      nDoc_it_no := field->doc_it_no
      nArt_id := field->art_id

      SELECT articles
      GO TOP
      SEEK artid_str( nArt_id )

      cL_desc := to_xml_encoding( AllTrim( field->art_lab_de ) )
      cF_desc := to_xml_encoding( AllTrim( field->art_full_d ) )
      cS_desc := to_xml_encoding( AllTrim( field->art_desc ) )

      IF Empty( cL_desc )
         cL_desc := cS_desc
      ENDIF

      SELECT t_docit

      nHeight := field->doc_it_hei
      nWidth := field->doc_it_wid

      nIHeight := to_inch( nHeight )
      nIWidth := to_inch( nWidth )

      nQty := field->doc_it_qtt

      cPosition := to_xml_encoding( AllTrim( field->doc_it_pos ) )
      cCity := to_xml_encoding( AllTrim( field->doc_acity ) )
      cAltt := to_xml_encoding( AllTrim( Str( field->doc_it_alt, 12 ) ) )

      cArt_type := "-"

      IF is_ramaterm( AllTrim( field->art_desc ) )
         cArt_type := "RAMA-TERM"
      ENDIF

      FOR lab_cnt := 1 TO nQty

         xml_subnode( "glass", .F. )

         xml_node( "id", AllTrim( Str( nArt_id ) ) )

         xml_node( "ldesc", cL_desc )

         xml_node( "sdesc", cS_desc )

         xml_node( "fdesc", cF_desc )

         xml_node( "city", cCity )

         xml_node( "altt", cAltt )

         xml_node( "qtty", AllTrim( Str( 1, 12 ) ) )

         xml_node( "tqt", AllTrim( Str( nQty, 12 ) ) )

         xml_node( "type", cArt_type )

         cTmp_h := AllTrim( Str( nHeight, 12, 2 ) )
         cTmp_w := AllTrim( Str( nWidth, 12, 2 ) )

         xml_node( "full_he", cTmp_h )
         xml_node( "full_wi", cTmp_w )

         xml_node( "dim", cTmp_w + " x " + cTmp_h )

         cTmp_h := AllTrim( Str( nIHeight, 12, 2 ) )
         cTmp_w := AllTrim( Str( nIWidth, 12, 2 ) )

         xml_node( "dim_in", cTmp_w + " x " + cTmp_h )

         cTmp_h := AllTrim( Str( nHeight, 12 ) )
         cTmp_w := AllTrim( Str( nWidth, 12 ) )

         xml_node( "sh_he", cTmp_h )
         xml_node( "sh_wi", cTmp_w )

         xml_node( "l_pos", cL_pos_def )

         xml_node( "l_epos", cLe_pos_def )

         xml_node( "pos", cPosition )

         xml_subnode( "glass", .T. )

      NEXT

      SELECT t_docit
      SKIP

   ENDDO

   xml_subnode( "label", .T. )

   close_xml()

   _template := ""

   IF get_file_list_array( _t_path, "_rg*.odt", @_template ) = 0
      RETURN
   ENDIF

   IF f18_odt_generate( _template, _data_xml )
      f18_odt_print()
   ENDIF

   RETURN
