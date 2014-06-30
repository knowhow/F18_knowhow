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
STATIC __oper_id

// ---------------------------------
// promjena, lom na artiklima
// ---------------------------------
FUNCTION _ch_damage( nOperId )

   LOCAL nTRec := RecNo()
   LOCAL cDesc
   LOCAL cDamage
   LOCAL aDbf := {}

   __oper_id := nOperId

   // setuj polja tabele....
   tmp_damage( @aDbf )

   // kreiraj pomocnu tabelu...
   cre_tmp1( aDbf )
   o_tmp1()
   SELECT _tmp1
   my_dbf_zap()


   SELECT docs
   __doc_no := field->doc_no

   // napuni tmp sa stavkama naloga
   _doc_to_tmp()

   // box sa unosom podataka
   IF _box_damage( @cDesc ) == 0
      RETURN
   ENDIF

   beep( 1 )

   logiraj_podatke_loma_na_staklima( __doc_no, cDesc, "+" )

   beep( 2 )

   SELECT docs
   GO ( nTRec )

   RETURN



// --------------------------------------------
// setovanje polja tabele _tmp1
// --------------------------------------------
STATIC FUNCTION tmp_damage( aDbf )

   AAdd( aDbf, { "doc_no", "N", 10, 0 } )
   AAdd( aDbf, { "doc_it_no", "N", 4, 0 } )
   AAdd( aDbf, { "art_id", "N", 10, 0 } )
   AAdd( aDbf, { "glass_no", "N", 3, 0 } )
   AAdd( aDbf, { "doc_it_qtt", "N", 12, 2 } )
   AAdd( aDbf, { "doc_it_h", "N", 12, 2 } )
   AAdd( aDbf, { "doc_it_w", "N", 12, 2 } )
   AAdd( aDbf, { "damage", "N", 12, 2 } )
   AAdd( aDbf, { "art_marker", "C", 1, 0 } )
   AAdd( aDbf, { "art_desc", "C", 150, 0 } )

   RETURN



// ---------------------------------------------
// napuni tmp tabelu sa stavkama naloga
// ---------------------------------------------
STATIC FUNCTION _doc_to_tmp()

   LOCAL nTArea := Select()

   SELECT doc_it
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( __doc_no )

   DO WHILE !Eof() .AND. field->doc_no == __doc_no

      SELECT _tmp1
      APPEND BLANK
	
      Scatter()
	
      _doc_no := doc_it->doc_no
      _doc_it_no := doc_it->doc_it_no
      _art_id := doc_it->art_id
      _doc_it_qtt := doc_it->doc_it_qtt
      _doc_it_h := doc_it->doc_it_hei
      _doc_it_w := doc_it->doc_it_wid
      _damage := 0
      _glass_no := 0
	
      Gather()
	
      SELECT doc_it
      SKIP
	
   ENDDO

   SELECT ( nTArea )

   RETURN


// --------------------------------------
// box sa unosom podataka osnovnih
// --------------------------------------
STATIC FUNCTION _box_damage( cDesc )

   LOCAL nBoxX := 14
   LOCAL nBoxY := 77
   LOCAL cHeader
   LOCAL lLogCh := .F.
   LOCAL cFooter
   LOCAL cOptions
   PRIVATE GetList := {}
   PRIVATE ImeKol
   PRIVATE Kol

   cHeader := " *** Dokument broj: " + docno_str( __doc_no ) + " "
   cFooter := " *** Evidencija loma na stavkama "

   cOptions := "<SPACE> markiranje stavki"
   cOptions += " "
   cOptions += "<ESC> snimanje promjena"

   Box(, nBoxX, nBoxY, .T. )

   SELECT _tmp1
   GO TOP

   set_a_kol( @ImeKol, @Kol )

   @ m_x + ( nBoxX - 1 ), m_y + 1 SAY cOptions

   ObjDbedit( "damage", nBoxX, nBoxY, {|| key_handler() }, cHeader, cFooter,,,,, 2 )

   BoxC()

   IF LastKey() == K_ESC

      // provjeri da li treba logirati ista...
      SELECT _tmp1
      GO TOP

      DO WHILE !Eof()
         IF field->art_marker == "*"
            lLogCh := .T.
            EXIT
         ENDIF
         SKIP
      ENDDO
	
      IF lLogCh == .T. .AND. Pitanje(, "Logirati promjene (D/N) ?", "D" ) == "D"
         // daj opis promjene
         _get_ch_desc( @cDesc )
		
         cDesc := ""
         RETURN 1
		
      ELSE
         cDesc := ""
         RETURN 0
      ENDIF
   ENDIF

   RETURN 0


// ------------------------------------------
// setovanje kolona browse-a
// ------------------------------------------
STATIC FUNCTION set_a_kol( aImeKol, aKol )

   aImeKol := {}
   aKol := {}

   AAdd( aImeKol, { "rbr", {|| docit_str( doc_it_no ) }, ;
      "doc_it_no", {|| .T. }, {|| .T. } } )

   AAdd( aImeKol, { "artikal/kol", {|| sh_article( art_id, doc_it_qtt, ;
      doc_it_w, doc_it_h ) }, ;
      "art_id", {|| .T. }, {|| .T. } } )

   AAdd( aImeKol, { "staklo", {|| glass_no }, ;
      "glass_no", {|| .T. }, {|| .T. } } )

   AAdd( aImeKol, { "steta", {|| damage }, ;
      "damage", {|| .T. }, {|| .T. } } )

   AAdd( aImeKol, { "mark", {|| PadR( art_marker, 4 ) }, ;
      "art_marker", {|| .T. }, {|| .T. } } )

   AAdd( aImeKol, { "opis", {|| PadR( art_desc, 35 ) }, ;
      "art_desc", {|| .T. }, {|| .T. } } )

   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN

// -----------------------------------------
// prikaz artikla u tabeli
// -----------------------------------------
FUNCTION sh_article( nArt_id, nQtty, nWidth, nHeight )

   LOCAL xRet := "???"
   LOCAL cTmp
   LOCAL nTmp

   IF nWidth == 0 .AND. nHeight == 0
      xRet := "("
      xRet += AllTrim( Str( nQtty, 12, 0 ) )
      xRet += ")"
   ELSE
      // dimenzije
      xRet := "("
      xRet += AllTrim( Str( nWidth, 12, 0 ) )
      xRet += "x"
      xRet += AllTrim( Str( nHeight, 12, 0 ) )
      xRet += "x"
      xRet += AllTrim( Str( nQtty, 12, 0 ) )
      xRet += ")"
   ENDIF

   // naziv
   cTmp := AllTrim( g_art_desc( nArt_id, .T., .F. ) )

   xRet := cTmp + " " + xRet

   RETURN PadR( xRet, 35 )


// ---------------------------------------
// obrada key handlera
// ---------------------------------------
STATIC FUNCTION key_handler()

   DO CASE
   CASE Ch == Asc( " " )
      // markiranje loma "*"
      RETURN _mark_item()
	
   ENDCASE

   RETURN DE_CONT


// --------------------------------------
// markiranje stavke...
// --------------------------------------
STATIC FUNCTION _mark_item()

   LOCAL cDesc
   LOCAL nDamage
   LOCAL nGlass_no

   IF field->art_marker == "*"
	
      IF pitanje(, "Ukloniti marker sa ove stavke (D/N) ?", "D" ) == "D"
		
		 RREPLACE field->art_marker with SPACE(1), field->art_desc with SPACE(150), field->damage with 0, field->glass_no with 0

         Beep( 1 )
		
         RETURN DE_REFRESH
      ELSE
         RETURN DE_CONT
      ENDIF
	
   ELSE
	
      IF _get_it_desc( @cDesc, field->doc_it_qtt, ;
            @nDamage, @nGlass_no ) > 0
	
         RREPLACE field->art_marker WITH "*", field->art_desc WITH cDesc, field->damage WITH nDamage, field->glass_no WITH nGlass_no
	
         beep( 2 )

         RETURN DE_REFRESH
      ELSE
         RETURN DE_CONT
      ENDIF
   ENDIF

   RETURN



// ----------------------------------------------------------------
// unesi opis stavke...
// ----------------------------------------------------------------
STATIC FUNCTION _get_it_desc( cDesc, nQty, nDamage, nGlass_no )

   LOCAL nRet := 1
   PRIVATE GetList := {}

   Box(, 6, 70 )
	
   cDesc := Space( 150 )
   nDamage := 0
   nGlass_no := 1
	
   @ m_x + 1, m_y + 2 SAY " *** Unos podataka o ostecenjima " ;
      COLOR "BG+/B"
	
   @ m_x + 3, m_y + 2 SAY "odnosi se na staklo br:" GET nGlass_no ;
      PICT "99"

   @ m_x + 4, m_y + 2 SAY " broj ostecenih komada:" GET nDamage ;
      PICT "999999.99" VALID nDamage <= nQty
	
   @ m_x + 6, m_y + 2 SAY "opis:" GET cDesc PICT "@S60" ;
      VALID !Empty( cDesc )
	
   READ
   BoxC()

   IF LastKey() == K_ESC
      nRet := 0
   ENDIF

   RETURN nRet



// -----------------------------------------
// unesi opis promjene
// -----------------------------------------
STATIC FUNCTION _get_ch_desc( cDesc )

   PRIVATE GetList := {}

   Box(, 5, 70 )
	
   cDesc := Space( 150 )
	
   @ m_x + 1, m_y + 2 SAY " *** Unos opisa promjene " COLOR "BG+/B"
	
   @ m_x + 3, m_y + 2 SAY "opis:" GET cDesc PICT "@S60"
	
   READ
   BoxC()

   RETURN


// ---------------------------------------------------------
// kalkulise ostecenja po odredjenom artiklu sa naloga
//
// params:
// * nDoc_no - broj dokumenta
// * nDoc_it_no - broj stavke dokumenta
// * nArt_id - id artikla
// * nElem_no - broj elementa u artiklu (1 ili 2 ili 3 ...)
// ---------------------------------------------------------
FUNCTION calc_dmg( nDoc_no, nDoc_it_no, nArt_id, nElem_no )

   LOCAL nRet := 0
   LOCAL nTArea := Select()
   LOCAL cLogType := PadR( "21", 3 )

   IF nElem_no == nil
      nElem_no := 0
   ENDIF

   SELECT doc_log
   SET ORDER TO TAG "2"
   SEEK docno_str( nDoc_no ) + cLogType

   IF !Found()
      SELECT ( nTArea )
      RETURN nRet
   ENDIF

   // prodji kroz logove tipa "21" - lom
   DO WHILE !Eof() .AND. field->doc_no == nDoc_no ;
         .AND. field->doc_log_ty == cLogType

      nDoc_log_no := field->doc_log_no

      SELECT doc_lit
      SEEK docno_str( nDoc_no ) + doclog_str( nDoc_log_no )

      DO WHILE !Eof() .AND. field->doc_no == nDoc_no .AND. ;
            field->doc_log_no == nDoc_log_no

         // field->int_1 = stavka naloga
         // field->int_2 = broj elementa artikla
         // field->num_2 = broj komada slomljenih

         IF field->art_id = nArt_id
			
            IF field->int_1 = nDoc_it_no .AND. ;
                  if( nElem_no > 0, ;
                  field->int_2 = nElem_no, .T. )
				
               nRet += field->num_2

            ENDIF

         ENDIF

         SKIP
      ENDDO
	
      SELECT doc_log
      SKIP

   ENDDO

   SELECT ( nTArea )

   RETURN nRet
