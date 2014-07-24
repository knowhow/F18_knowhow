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


STATIC __nvar
STATIC __doc_no


FUNCTION rnal_specifikacija_poslovodja( nVar )

   LOCAL _params

   IF nVar == nil
      nVar := 0
   ENDIF

   __nVar := nVar

   IF _g_vars( @_params ) == 0
      RETURN
   ENDIF

   _cre_spec( _params )

   _p_rpt_spec( _params )

   RETURN



STATIC FUNCTION _g_vars( params )

   LOCAL _ret := 1
   LOCAL _box_x := 18
   LOCAL _box_y := 70
   LOCAL _x := 1
   LOCAL _statusi, _tip_datuma
   LOCAL _dat_od, _dat_do, _group, _operater

   PRIVATE GetList := {}

   _statusi := fetch_metric( "rnal_spec_posl_status", NIL, "N" )
   _tip_datuma := fetch_metric( "rnal_spec_posl_tip_datuma", my_user(), 2 )

   _dat_od := danasnji_datum()
   _dat_do := _dat_od
   _group := 0
   _operater := 0

   Box(, _box_x, _box_y )

   @ m_x + _x, m_y + 2 SAY8 "*** Specifikacija radnih naloga za poslovođe"
	
   ++ _x
   ++ _x
	
   @ m_x + _x, m_y + 2 SAY "Datum od:" GET _dat_od
   @ m_x + _x, Col() + 1 SAY "do:" GET _dat_do

   ++ _x
   ++ _x
	
   @ m_x + _x, m_y + 2 SAY "Operater (0 - svi op.):" GET _operater VALID {|| _operater == 0  } PICT "9999999999"
	
   ++ _x
   ++ _x
	
   @ m_x + _x, m_y + 2 SAY "*** Selekcija grupe artikala "

   ++ _x

   @ m_x + _x, m_y + 2 SAY "(1) - rezano          (4) - IZO"
	
   ++ _x
	
   @ m_x + _x, m_y + 2 SAY "(2) - kaljeno         (5) - LAMI"
	
   ++ _x
	
   @ m_x + _x, m_y + 2 SAY8 "(3) - brušeno         (6) - emajlirano"
	
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Grupa artikala (0 - sve grupe):" GET _group VALID _group >= 0 .AND. _group < 7 PICT "9"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Gledati statuse 'realizovano' (D/N) ?" GET _statusi VALID _statusi $ "DN" PICT "@!"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Gledati datum naloga ili datum isporuke (1/2) ?" GET _tip_datuma PICT "9"
	
   READ

   BoxC()

   IF LastKey() == K_ESC
      _ret := 0
      RETURN _ret
   ENDIF

   // snimi parametre
   set_metric( "rnal_spec_posl_status", NIL, _statusi )
   set_metric( "rnal_spec_posl_tip_datuma", my_user(), _tip_datuma )

   params := hb_Hash()
   params[ "datum_od" ] := _dat_od
   params[ "datum_do" ] := _dat_do
   params[ "tip_datuma" ] := _tip_datuma
   params[ "group" ] := _group
   params[ "operater" ] := _operater
   params[ "gledaj_statuse" ] := _statusi

   params[ "idx" ] := "D1"

   IF _tip_datuma == 2
      params[ "idx" ] := "D2"
   ENDIF

   RETURN _ret



// ----------------------------------------------
// kreiraj specifikaciju
// izvjestaj se primarno puni u _tmp0 tabelu
// ----------------------------------------------
STATIC FUNCTION _cre_spec( params )

   LOCAL nDoc_no
   LOCAL nArt_id
   LOCAL aArtArr := {}
   LOCAL nCount := 0
   LOCAL cCust_desc
   LOCAL aField
   LOCAL nScan
   LOCAL ii
   LOCAL cAop
   LOCAL cAopDesc
   LOCAL aGrCount := {}
   LOCAL nGr1
   LOCAL nGr2
   LOCAL _glass_count := 0

   aField := _spec_fields()

   cre_tmp1( aField )
   o_tmp1()

   rnal_o_tables( .F. )

   _main_filter( params )

   Box(, 1, 50 )

   DO WHILE !Eof()

      nDoc_no := field->doc_no
      __doc_no := nDoc_no

      cCust_desc := AllTrim( g_cust_desc( docs->cust_id ) )
	
      IF "NN" $ cCust_desc
         cCust_desc := cCust_Desc + "/" + ;
            AllTrim( g_cont_desc( docs->cont_id ) )
      ENDIF
	
      cDoc_stat := get_status_dokumenta( docs->doc_status )
	
      cDoc_oper := getusername( docs->operater_i )

      cDoc_prior := s_priority( docs->doc_priori )

      use_sql_doc_log( nDoc_no )	

      SEEK docno_str( nDoc_no )

      cLog := ""
	
      DO WHILE !Eof() .AND. field->doc_no == nDoc_no
		
         cLog := DToC( field->doc_log_da )
         cLog += " / "
         cLog += AllTrim( field->doc_log_ti )
         cLog += " : "
         cLog += AllTrim( field->doc_log_de )
		
         SKIP
      ENDDO
	
      // samo za log, koji nije inicijalni....
      IF "Inicij" $ cLog
         cLog := ""
      ELSE
         cLog := hb_Utf8ToStr( cLog )
      ENDIF
	
      SELECT doc_it
      SET ORDER TO TAG "1"
      GO TOP
      SEEK docno_str( nDoc_no )

      DO WHILE !Eof() .AND. field->doc_no == nDoc_no
		
         nArt_id := field->art_id
         nDoc_it_no := field->doc_it_no
         nQtty := field->doc_it_qtt
		
         aArtDesc := {}

         rnal_matrica_artikla( nArt_id, @aArtDesc )

         _glass_count := broj_stakala( aArtDesc, nQtty )

         // check group of item
         // "0156" itd...
         cIt_group := set_art_docgr( nArt_id, nDoc_no, nDoc_it_no, .F. )
		
         cDiv := AllTrim( Str( Len( cIt_group ) ) )
		
         cDoc_div := "(" + cDiv + "/" + cDiv + ")"
	
         cAop := " "
		
         SELECT doc_ops
         SET ORDER TO TAG "1"
         GO TOP
         SEEK docno_str( nDoc_no ) + docit_str( nDoc_it_no )
		
         aAop := {}

         DO WHILE !Eof() .AND. field->doc_no == nDoc_no ;
               .AND. field->doc_it_no == nDoc_it_no

            cAopDesc := AllTrim( g_aop_desc( field->aop_id ) )

            nScan := AScan( aAop, {| xVal| xVal[ 1 ] == cAopDesc } )
			
            IF nScan == 0
				
               AAdd( aAop, { cAopDesc } )
				
            ENDIF
			
            SKIP
		
         ENDDO

         cAop := ""
		
         IF Len( aAop ) > 0
		
            FOR ii := 1 TO Len( aAop )
				
               IF ii <> 1
                  cAop += "#"
               ENDIF
				
               cAop += aAop[ ii, 1 ]
            NEXT
		
         ENDIF

         lIsLami := is_lami( aArtDesc )

         IF lIsLami == .T.
            IF !Empty( cAop )
               cAop += "#"
            ENDIF
            cAop += "lami-rg"
         ENDIF

         SELECT doc_it

         cItem := AllTrim( g_art_desc( nArt_id ) )
         cItemAop := cAop
		
         nGr1 := Val( SubStr( cIt_group, 1, 1 ) )
	
         _ins_tmp1( nDoc_no, ;
            cCust_desc, ;
            docs->doc_date, ;
            docs->doc_dvr_da, ;
            docs->doc_dvr_ti, ;
            cDoc_stat, ;
            cDoc_prior, ;
            cDoc_div, ;
            docs->doc_desc, ;
            docs->doc_sh_des, ;
            cDoc_oper, ;
            nQtty, ;
            _glass_count, ;
            cItem, ;
            cItemAop, ;
            nGr1, ;
            cLog )

         IF Len( cIt_group ) > 1

            FOR xx := 1 TO Len( cIt_group )

               IF Val( SubStr( cIt_group, xx, 1 ) ) == nGr1
                  LOOP
               ENDIF

               _ins_tmp1( nDoc_no, ;
                  cCust_desc, ;
                  docs->doc_date, ;
                  docs->doc_dvr_da, ;
                  docs->doc_dvr_ti, ;
                  cDoc_stat, ;
                  cDoc_prior, ;
                  cDoc_div, ;
                  docs->doc_desc, ;
                  docs->doc_sh_des, ;
                  cDoc_oper, ;
                  nQtty, ;
                  _glass_count, ;
                  cItem, ;
                  cItemAop, ;
                  Val( SubStr( cIt_group, xx, 1 ) ), ;
                  cLog )
		
            NEXT
		
         ENDIF

         ++ nCount
		
         @ m_x + 1, m_y + 2 SAY "datum isp./nalog broj: " + DToC( docs->doc_dvr_da ) + " / " + AllTrim( Str( nDoc_no ) )
	
         SKIP
		
      ENDDO
	
      SELECT docs
      SKIP
	
   ENDDO

   BoxC()

   RETURN


STATIC FUNCTION _main_filter( params )

   LOCAL _filter := ""
   LOCAL _date := "doc_date"
   LOCAL _dat_od := params[ "datum_od" ]
   LOCAL _dat_do := params[ "datum_do" ]
   LOCAL _tip_datuma := params[ "tip_datuma" ]
   LOCAL _group := params[ "group" ]
   LOCAL _oper := params[ "operater" ]
   LOCAL _idx := params[ "idx" ]
   LOCAL _statusi := params[ "gledaj_statuse" ]

   IF _tip_datuma == 2
      _date := "doc_dvr_da"
   ELSE
      _date := "doc_date"
   ENDIF

   IF _statusi == "N"
      _filter += "( doc_status == 0 .or. doc_status > 2 )"
   ELSE
      _filter += "( doc_status == 0 .or. doc_status == 4 ) "
   ENDIF

   _filter += " .and. DTOS( " + _date + " ) >= " + _filter_quote( DToS( _dat_od ) )
   _filter += " .and. DTOS( " + _date + " ) <= " + _filter_quote( DToS( _dat_do ) )

   IF _oper <> 0
      _filter += " .and. ALLTRIM( STR( operater_i ) ) == " + cm2str( AllTrim( Str( _oper ) ) )
   ENDIF

   SELECT docs
   SET ORDER TO tag &_idx
   SET FILTER to &_filter
   GO TOP
	
   RETURN



// ------------------------------------------
// stampa specifikacije
// stampa se iz _tmp0 tabele
// ------------------------------------------
STATIC FUNCTION _p_rpt_spec( params )

   LOCAL i
   LOCAL ii
   LOCAL nScan
   LOCAL aItemAop
   LOCAL cPom
   LOCAL _group := params[ "group" ]

   START PRINT CRET

   ?
   P_COND2

   _rpt_descr()
   __rpt_info()
   _rpt_head()

   SELECT _tmp1
   GO TOP

   DO WHILE !Eof()
	
      IF _group <> 0
         IF field->it_group <> _group
            SKIP
            loop
         ENDIF
      ENDIF

      IF _nstr() == .T.
         FF
      ENDIF
	
      nDoc_no := field->doc_no
	
      cCustDesc := field->cust_desc
	
      cDate := DToC( field->doc_date ) + "/" + ;
         DToC( field->doc_dvr_d )
	
      cDescr := AllTrim( field->doc_prior ) + " - " + ;
         AllTrim( field->doc_stat ) + " - " + ;
         AllTrim( field->doc_oper ) + " - (" + ;
         AllTrim( field->doc_sdesc ) + " )"


      nCount := 0
	
      nTotQtty := 0
      nTotGlQtty := 0
      cItemAop := ""

      aItemAop := {}
      nScan := 0
	
      DO WHILE !Eof() .AND. field->doc_no == nDoc_no
		
         ++ nCount
		
         nTotQtty += field->qtty
         nTotGlQtty += field->glass_qtty

         cItemAop := AllTrim( field->doc_aop )
		
         IF !Empty( cItemAop )
			
            // razbij string "brusenje#poliranje#kaljenje#"
            // -> u matricu
            aPom := TokToNiz( cItemAop, "#" )
			
            FOR ii := 1 TO Len( aPom )
			
               nScan := AScan( aItemAop, ;
                  {| xVar| aPom[ ii ] == xVar[ 1 ] } )
		
               IF nScan = 0
                  AAdd( aItemAop, { aPom[ ii ] } )
               ENDIF
            NEXT
         ENDIF
		
         cDiv := AllTrim( field->doc_div )
         cLog := AllTrim( field->doc_log )
		
         SKIP
      ENDDO
	
      cDescr := cDiv + " - " + cDescr

      ? docno_str( nDoc_no )
      @ PRow(), PCol() + 1 SAY PadR( cCustDesc, 30 )
      @ PRow(), PCol() + 1 SAY PadR( cDate, 17 )
      @ PRow(), PCol() + 1 SAY " " + PadR( cDescr, 100 )
      ? Space( 10 )
      @ PRow(), PCol() + 1 SAY "kom.na nalogu: " + AllTrim( Str( nTotQtty, 12 ) ) + ;
         " broj stakala: " + AllTrim( Str( nTotGlQtty, 12 ) )
	
      IF Len( aItemAop ) > 0
		
         cPom := ""
		
         FOR i := 1 TO Len( aItemAop )
            IF i <> 1
               cPom += ", "
            ENDIF
            cPom += aItemAop[ i, 1 ]
         NEXT
	
         @ PRow(), PCol() + 1 SAY ", op.: " + cPom
	
      ENDIF
	
      IF !Empty( cLog )
		
         ? Space( 10 )
		
         @ PRow(), PCol() + 2 SAY "zadnja promjena: "
		
         @ PRow(), PCol() + 1 SAY cLog
		
      ENDIF

      ?

   ENDDO

   my_close_all_dbf()

   FF
   END PRINT

   RETURN


// -----------------------------------
// provjerava za novu stranu
// -----------------------------------
STATIC FUNCTION _nstr()

   LOCAL lRet := .F.

   IF PRow() > 62
      lRet := .T.
   ENDIF

   RETURN lRet



// ------------------------------------------------
// ispisi naziv izvjestaja po varijanti
// ------------------------------------------------
STATIC FUNCTION _rpt_descr()

   LOCAL cTmp := "rpt: "

   DO CASE
   CASE __nvar == 1
      cTmp += "SPECIFIKACIJA NALOGA ZA POSLOVOĐE"
   ENDCASE

   ?U cTmp

   RETURN



// -------------------------------------------------
// header izvjestaja
// -------------------------------------------------
STATIC FUNCTION _rpt_head()

   cLine := Replicate( "-", 10 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 30 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 17 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 100 )

   cTxt := PadR( "Nalog br.", 10 )
   cTxt += Space( 1 )
   cTxt += PadR( "Partner", 30 )
   cTxt += Space( 1 )
   cTxt += PadR( "Termini", 17 )
   cTxt += Space( 1 )
   cTxt += PadR( "Ostale info (divizor - prioritet - status - operater - opis)", 100 )

   ? cLine
   ? cTxt
   ? cLine

   RETURN



// -----------------------------------------------
// vraca strukturu polja tabele _tmp1
// -----------------------------------------------
STATIC FUNCTION _spec_fields()

   LOCAL aDbf := {}

   AAdd( aDbf, { "doc_no", "N", 10, 0 } )
   AAdd( aDbf, { "cust_desc", "C", 50, 0 } )
   AAdd( aDbf, { "doc_date", "D", 8, 0 } )
   AAdd( aDbf, { "doc_dvr_d", "D", 8, 0 } )
   AAdd( aDbf, { "doc_dvr_t", "C", 10, 0 } )
   AAdd( aDbf, { "doc_stat", "C", 30, 0 } )
   AAdd( aDbf, { "doc_prior", "C", 30, 0 } )
   AAdd( aDbf, { "doc_oper", "C", 30, 0 } )
   AAdd( aDbf, { "doc_div", "C", 20, 0 } )
   AAdd( aDbf, { "doc_desc", "C", 100, 0 } )
   AAdd( aDbf, { "doc_sdesc", "C", 100, 0 } )
   AAdd( aDbf, { "doc_item", "C", 250, 0 } )
   AAdd( aDbf, { "doc_aop", "C", 250, 0 } )
   AAdd( aDbf, { "qtty", "N", 15, 5 } )
   AAdd( aDbf, { "glass_qtty", "N", 15, 5 } )
   AAdd( aDbf, { "it_group", "N", 5, 0 } )
   AAdd( aDbf, { "doc_log", "C", 200, 0 } )

   RETURN aDbf


// -----------------------------------------------------
// insert into _tmp1
// -----------------------------------------------------
STATIC FUNCTION _ins_tmp1( nDoc_no, cCust_desc, dDoc_date, dDoc_dvr_d, ;
      cDoc_dvr_t, ;
      cDoc_stat, cDoc_prior, ;
      cDoc_div, cDoc_desc, cDoc_sDesc, cDoc_oper, ;
      nQtty, nGl_qtty, cDoc_item, cDoc_aop,nIt_group, cDoc_log )

   LOCAL nTArea := Select()

   SELECT _tmp1
   APPEND BLANK

   REPLACE field->doc_no WITH nDoc_no
   REPLACE field->cust_desc WITH cCust_desc
   REPLACE field->doc_date WITH dDoc_date
   REPLACE field->doc_dvr_d WITH dDoc_dvr_d
   REPLACE field->doc_dvr_t WITH cDoc_dvr_t
   REPLACE field->doc_stat WITH cDoc_stat
   REPLACE field->doc_prior WITH cDoc_prior
   REPLACE field->doc_oper WITH cDoc_oper
   REPLACE field->doc_div WITH cDoc_div
   REPLACE field->doc_desc WITH cDoc_desc
   REPLACE field->doc_sdesc WITH cDoc_sdesc
   REPLACE field->doc_item WITH cDoc_item
   REPLACE field->doc_aop WITH cDoc_aop
   REPLACE field->qtty WITH nQtty
   REPLACE field->glass_qtty WITH nGl_qtty
   REPLACE field->it_group WITH nIt_group
   REPLACE field->doc_log WITH cDoc_log

   SELECT ( nTArea )

   RETURN
