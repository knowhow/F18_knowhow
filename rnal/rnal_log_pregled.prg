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


STATIC __doc_no



FUNCTION rnal_pregled_loga_za_nalog( nDoc_no )

   LOCAL nTArea

   nTArea := Select()

   __doc_no := nDoc_no

   rnal_o_tables( .F. )

   tbl_list()

   SELECT ( nTArea )

   RETURN



// -------------------------------------------------
// otvori tabelu pregleda
// -------------------------------------------------
STATIC FUNCTION tbl_list()

   LOCAL cFooter
   LOCAL cHeader

   PRIVATE ImeKol
   PRIVATE Kol

   cHeader := " Nalog broj: " + docno_str( __doc_no ) + " "
   cFooter := " Pregled promjena na nalogu... "

   Box(, 20, 77 )

   _set_box()

   SELECT doc_log
   SET ORDER TO TAG "1"

   set_f_kol()
   set_a_kol( @ImeKol, @Kol )

   Beep( 2 )

   ObjDbedit( "lstlog", 20, 77, {|| k_handler() }, cHeader, cFooter,,,,, 5 )

   BoxC()

   RETURN


// ------------------------------------------
// setovanje dna boxa
// ------------------------------------------
STATIC FUNCTION _set_box()

   LOCAL cLine1 := ""
   LOCAL cLine2 := ""
   LOCAL nOptLen := 24
   LOCAL cOptSep := "|"

   cLine1 := PadR( "<ESC> Izlaz", nOptLen )
   cLine1 += cOptSep + " "
   cLine1 += PadR( "<c-P> Stampa liste", nOptLen )

   @ m_x + 20, m_y + 2 SAY cLine1

   RETURN


// ------------------------------------------------
// setovanje filtera
// ------------------------------------------------
STATIC FUNCTION set_f_kol()

   LOCAL cFilter

   cFilter := "doc_no == " + docno_str( __doc_no )
   SELECT doc_log
   SET FILTER to &cFilter
   GO TOP

   RETURN



// ---------------------------------------------
// pregled - key handler
// ---------------------------------------------
STATIC FUNCTION k_handler()

   LOCAL nTblFilt
   LOCAL cLogDesc := ""
   LOCAL cPom

   // napravi string iz rnlog/rnlog_it
   cLogDesc := g_log_desc( doc_log->doc_no, ;
      doc_log->doc_log_no, ;
      doc_log_ty )

   cPom := StrTran( cLogDesc, "#", "," )

   // prikaz stringa u browse - box-u
   s_log_desc_on_form( cPom )

   DO CASE
	
      // refresh na browse
      // radi prikaza s_log_opis...()
   CASE ( Ch == K_UP ) .OR. ;
         ( Ch == K_PGUP ) .OR. ;
         ( Ch == K_DOWN ) .OR. ;
         ( Ch == K_PGDN )
		
      RETURN DE_REFRESH
		
      // detaljni prikaz box-a sa promjenama
   CASE ( Ch == K_ENTER )
	
      // ima li pravo pristupa
      IF !ImaPravoPristupa( goModul:oDataBase:cName, "DOK", "LOGDETAIL" )
         msgbeep( cZabrana )
         SELECT docs
         RETURN DE_CONT
      ENDIF
		
      sh_log_box( cLogDesc )
      RETURN DE_CONT
	
      // stampa liste log-a
   CASE ( Ch == K_CTRL_P )
      IF Pitanje(, "Stampati liste promjena (D/N) ?", "D" ) == "D"
         // stampa liste
         RETURN DE_CONT
      ENDIF
      SELECT doc_log
      RETURN DE_CONT
	
   ENDCASE

   RETURN DE_CONT



// -------------------------------------------------------
// setovanje kolona tabele za pregled log-a
// -------------------------------------------------------
STATIC FUNCTION set_a_kol( aImeKol, aKol )

   aImeKol := {}

   AAdd( aImeKol, { "dat./vr./oper.", {|| DToC( doc_log_da ) + " / " + PadR( doc_log_ti, 5 ) + " " + PadR( getusername( operater_i ), 10 ) + ".." }, "datum", {|| .T. }, {|| .T. } } )

   AAdd( aImeKol, { "prom.tip", {|| PadR( s_log_type( doc_log_ty ), 12 ) }, "tip", {|| .T. }, {|| .T. } } )

   AAdd( aImeKol, { "kratki opis", {|| PadR( doc_log_de, 30 ) + ".." }, "opis", {|| .T. }, {|| .T. } } )

   aKol := {}

   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN


// --------------------------------------------
// vraca opis tipa promjene
// --------------------------------------------
STATIC FUNCTION s_log_type( cType )

   LOCAL xRet := ""

   cType := AllTrim( cType )

   DO CASE
   CASE cType == "01"
      xRet := "otvoren"
   CASE cType == "99"
      xRet := "realizovan"
   CASE cType == "98"
      xRet := "real.dio"
   CASE cType == "97"
      xRet := "ponisten"
   CASE cType == "96"
      xRet := "nije ispor."
   CASE cType == "10"
      xRet := "osn.podaci"
   CASE cType == "11"
      xRet := "pod.isporuka"
   CASE cType == "12"
      xRet := "kontakti"
   CASE cType == "13"
      xRet := "placanje"
   CASE cType == "20"
      xRet := "artikli"
   CASE cType == "21"
      xRet := "lom"
   CASE cType == "30"
      xRet := "d.operacije"
   ENDCASE

   RETURN xRet


// -------------------------------------------
// prikaz opisa log-a na formi
// cLogText se lomi na 3 reda...
// -------------------------------------------
STATIC FUNCTION s_log_desc_on_form( cLogText )

   LOCAL aLogArr := {}
   LOCAL cRow1
   LOCAL cRow2
   LOCAL cRow3
   LOCAL nLenText := 76
   LOCAL cOpis

   cRow1 := Space( nLenText )
   cRow2 := Space( nLenText )
   cRow3 := Space( nLenText )

   aLogArr := SjeciStr( cLogText, nLenText )

   IF Len( aLogArr ) > 0
	
      cRow1 := aLogArr[ 1 ]
	
      IF Len( aLogArr ) > 1
         cRow2 := aLogArr[ 2 ]
      ENDIF
	
      IF Len( aLogArr ) > 2
         cRow3 := aLogArr[ 3 ]
      ENDIF
   ENDIF

   // separator
   @ m_x + 16, m_y + 2 SAY Space( nLenText )
   @ m_x + 16, m_y + 2 SAY PadR( cRow1, nLenText ) COLOR "I"
   // prvi red
   @ m_x + 17, m_y + 2 SAY Space( nLenText )
   @ m_x + 17, m_y + 2 SAY PadR( cRow2, nLenText ) COLOR "I"
   // drugi red
   @ m_x + 18, m_y + 2 SAY Space( nLenText )
   @ m_x + 18, m_y + 2 SAY PadR( cRow3, nLenText ) COLOR "I"

   RETURN


// -------------------------------------------------------
// formira i vraca string na osnovu tabela DOC_LOG/DOC_LIT
// -------------------------------------------------------
STATIC FUNCTION g_log_desc( nDoc_no, nDoc_log_no, cDoc_log_type )

   LOCAL cRet := ""
   LOCAL nTArea := Select()
   LOCAL nTRec := RecNo()
   LOCAL cTBFilter := dbFilter()

   SELECT doc_log
   SET ORDER TO TAG "1"

   cDoc_log_type := AllTrim( cDoc_log_type )

   DO CASE
   CASE cDoc_log_type == "01"
      cRet := _lit_01_get( nDoc_no, nDoc_log_no )
   CASE cDoc_log_type == "99"
      cRet := _lit_99_get( nDoc_no, nDoc_log_no )
   CASE cDoc_log_type == "98"
      cRet := _lit_99_get( nDoc_no, nDoc_log_no )
   CASE cDoc_log_type == "97"
      cRet := _lit_99_get( nDoc_no, nDoc_log_no )
   CASE cDoc_log_type == "96"
      cRet := _lit_99_get( nDoc_no, nDoc_log_no )
   CASE cDoc_log_type == "10"
      cRet := _lit_10_get( nDoc_no, nDoc_log_no )
   CASE cDoc_log_type == "11"
      cRet := _lit_11_get( nDoc_no, nDoc_log_no )
   CASE cDoc_log_type == "12"
      cRet := _lit_12_get( nDoc_no, nDoc_log_no )
   CASE cDoc_log_type == "13"
      cRet := _lit_13_get( nDoc_no, nDoc_log_no )
   CASE cDoc_log_type == "20"
      cRet := _lit_20_get( nDoc_no, nDoc_log_no )
   CASE cDoc_log_type == "21"
      cRet := _lit_21_get( nDoc_no, nDoc_log_no )
   CASE cDoc_log_type == "30"
      cRet := _lit_30_get( nDoc_no, nDoc_log_no )
   ENDCASE

   SELECT ( nTArea )
   SET FILTER to &cTBFILTER
   GO ( nTRec )

   RETURN cRet



// -------------------------------------------------
// vraca opis akcije prema oznaci cAkcija
// -------------------------------------------------
STATIC FUNCTION g_action_info( cAction )

   LOCAL xRet := ""

   DO CASE
   CASE cAction == "E"
      xRet := "update"
   CASE cAction == "+"
      xRet := "insert"
   CASE cAction == "-"
      xRet := "delete"
   ENDCASE

   RETURN xRet


// ------------------------------------------
// prikaz box-a sa informacijama loga
// ------------------------------------------
STATIC FUNCTION sh_log_box( cLogTxt )

   LOCAL aBoxTxt := {}
   LOCAL cPom
   LOCAL cResp := "OK"
   PRIVATE GetList := {}

   aBoxTxt := toktoniz( cLogTxt, "#" )

   IF Len( aBoxTxt ) == 0
      RETURN
   ENDIF

   Box(, Len( aBoxTxt ) + 2, 70 )
	
   @ m_x + 1, m_y + 2 SAY "Detaljni prikaz promjene: " COLOR "I"
	
   FOR i := 1 TO Len( aBoxTxt )

      @ m_x + ( i + 1 ), m_y + 2 SAY PadR( aBoxTxt[ i ], 65 )
   NEXT

   @ m_x + Len( aBoxTxt ) + 2, m_y + 2 GET cResp
	
   READ
   BoxC()

   IF LastKey() == K_ESC .OR. cResp == "OK"
      RETURN
   ENDIF

   RETURN
