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

// variables

STATIC l_new_it
STATIC _doc


// ------------------------------------------
// unos ispravka stavki naloga....
// nDoc_no - dokument broj
// lNew - nova stavka .t. or .f.
// ------------------------------------------
FUNCTION e_doc_item( nDoc_no, lNew )

   LOCAL nX := m_x
   LOCAL nY := m_y
   LOCAL nGetBoxX := 18
   LOCAL nGetBoxY := 70
   LOCAL cBoxNaz := "unos nove stavke"
   LOCAL nRet := 0
   LOCAL nFuncRet := 0
   LOCAL cGetDOper := "N"
   LOCAL lCopyAop
   LOCAL nArt
   LOCAL _rec
   PRIVATE GetList := {}

   _doc := nDoc_no

   IF lNew == nil
      lNew := .T.
   ENDIF

   l_new_it := lNew

   IF l_new_it == .F.
      cBoxNaz := "ispravka stavke"
   ENDIF

   SELECT _doc_it

   Box(, nGetBoxX, nGetBoxY, .F., "Unos stavki naloga" )

   set_opc_box( nGetBoxX, 50 )

   // say top, bottom
   @ m_x + 1, m_y + 2 SAY PadL( "***** " + cBoxNaz, nGetBoxY - 2 )
   @ m_x + nGetBoxX, m_y + 2 SAY PadL( "(*) popuna obavezna", nGetBoxY - 2 ) COLOR "BG+/B"


   DO WHILE .T.

      set_global_memvars_from_dbf()

      nFuncRet := _e_box_item( nGetBoxX, nGetBoxY, @cGetDOper )

      IF nFuncRet == 1

         SELECT _doc_it

         IF l_new_it
            APPEND BLANK
         ENDIF

         _rec := get_dbf_global_memvars( NIL, .F. )
         // update zapisa...
         dbf_update_rec( _rec )

         IF cGetDOper == "D"

            lCopyAop := .F.

            // operacije moguce kopirati samo ako je isti
            // artikal i ako je redni broj <> 1

            IF _doc_it->doc_it_no <> 1

               nArt := _doc_it->art_id

               SKIP -1

               IF nArt == _doc_it->art_id

                  lCopyAop := .T.

               ENDIF

               SKIP 1

            ENDIF

            IF lCopyAop == .T. .AND. pitanje(, "koristi operacije prethodne stavke ?", "N" ) == "D"

               // kopiraj operacije...
               _cp_oper( _doc, ;
                  _doc_it->art_id, ;
                  _doc_it->doc_it_no )

            ELSE

               // manualno unesi operacije

               e_doc_ops( _doc, ;
                  lNew, ;
                  _doc_it->art_id, ;
                  _doc_it->doc_it_no )

            ENDIF

            SELECT _doc_it

         ENDIF

         IF l_new_it
            LOOP
         ENDIF

      ENDIF

      BoxC()
      SELECT _doc_it

      nRet := RECCOUNT2()

      EXIT

   ENDDO

   SELECT _docs

   m_x := nX
   m_y := nY

   RETURN nRet


// -------------------------------------------------
// forma za unos podataka
// cGetDOper , D - unesi dodatne operacije...
// -------------------------------------------------
STATIC FUNCTION _e_box_item( nBoxX, nBoxY, cGetDOper )

   LOCAL nX := 1
   LOCAL aArtArr := {}
   LOCAL nTmpArea
   LOCAL nLeft := 21
   LOCAL _curr_doc_it_no

   cGetDOper := "N"

   IF l_new_it

      _doc_no := _doc
      _doc_it_no := inc_docit( _doc )
      _doc_it_typ := " "
      _it_lab_pos := "I"

      // ako je nova stavka i vrijednost je 0, uzmi default...
      IF _doc_it_alt == 0
         _doc_it_alt := gDefNVM
      ENDIF

      IF Empty( _doc_acity )
         _doc_acity := PadR( gDefCity, 50 )
      ENDIF

      IF _doc_it_sch == " "
         _doc_it_sch := "N"
      ENDIF

   ENDIF

   _curr_doc_it_no := _doc_it_no

   nX += 2

   @ m_x + nX, m_y + 2 SAY PadL( "r.br stavke (*)", nLeft ) GET _doc_it_no WHEN l_new_it ;
      VALID _check_rbr( _doc_no, _doc_it_no )

   nX += 2

   @ m_x + nX, m_y + 2 SAY PadL( "ARTIKAL (*):", nLeft ) GET _art_id ;
      VALID {|| _old_x := m_x, _old_y := m_y, ;
      s_articles( @_art_id, .F., .T. ), ;
      m_x := _old_x, _old_y := m_y, ;
      show_it( g_art_desc( _art_id, nil, .F. ) + "..", 35 ), ;
      check_article_valid( @_art_id ) } ;
      WHEN set_opc_box( nBoxX, 50, "0 - otvori sifrarnik i pretrazi" )

   nX += 1

   @ m_x + nX, m_y + 2 SAY PadL( "Tip artikla (*):", nLeft ) GET _doc_it_typ ;
      VALID {|| _doc_it_typ $ " SR" .AND. show_it( _g_doc_it_type( _doc_it_typ ) ) } ;
      WHEN set_opc_box( nBoxX, 50, "' ' - standardni, 'R' - radius, 'S' - shape" ) PICT "@!"

   READ
   ESC_RETURN 0

   // set opisa na formi
   cDimADesc := "(A) sirina [mm] (*):"
   cDimBDesc := "(B) visina [mm] (*):"
   cDimCDesc := "(C) sirina [mm] (*):"
   cDimDDesc := "(D) visina [mm] (*):"

   IF _doc_it_typ == "R"
      cDimADesc := "(A) fi [mm] (*):"
      cDimBDesc := "(B) fi [mm] (*):"
   ENDIF

   IF _doc_it_typ $ "SR"
      _doc_it_sch := "D"
   ENDIF

   _doc_it_h2 := 0
   _doc_it_w2 := 0

   nX += 1

   @ m_x + nX, m_y + 2 SAY PadL( "shema u prilogu (D/N)? (*):", nLeft + 9 ) GET _doc_it_sch PICT "@!" VALID {|| _doc_it_sch $ "DN" } WHEN {|| _set_arr( _art_id, @aArtArr ), set_opc_box( nBoxX, 50, "da li postoji dodatna shema kao prilog" ) }

   @ m_x + nX, Col() + 2 SAY "pozicija" GET _doc_it_pos ;
      WHEN {|| set_opc_box( nBoxX, 50, "pozicija naljepnice" ) }

   @ m_x + nX, Col() + 2 SAY "I/O" GET _it_lab_pos ;
      WHEN {|| set_opc_box( nBoxX, 50, ;
      "labela, pozicija I - inside O - outside" ) } ;
      VALID {|| _it_lab_pos $ "IO" }

   nX += 1

   @ m_x + nX, m_y + 2 SAY PadL( "dod.nap.stavke:", nLeft ) GET _doc_it_des PICT "@S40" ;
      WHEN set_opc_box( nBoxX, 50, "dodatne napomene vezane za samu stavku" )

   nX += 2

   @ m_x + nX, m_y + 2 SAY PadL( cDimADesc, nLeft + 3 ) GET _doc_it_wid PICT Pic_Dim() ;
      VALID val_width( _doc_it_wid ) .AND. rule_items( "DOC_IT_WIDTH", _doc_it_wid, aArtArr ) ;
      WHEN set_opc_box( nBoxX, 50 )


   nX += 1

   @ m_x + nX, m_y + 2 SAY PadL( cDimBDesc, nLeft + 3 ) GET _doc_it_hei PICT Pic_Dim() ;
      VALID val_heigh( _doc_it_hei ) .AND. rule_items( "DOC_IT_HEIGH", _doc_it_hei, aArtArr ) ;
      WHEN set_opc_box( nBoxX, 50 )

   nX += 1

   @ m_x + nX, m_y + 2 SAY PadL( "kolicina [kom] (*):", nLeft + 3 ) GET _doc_it_qtt PICT Pic_Qtty() VALID val_qtty( _doc_it_qtt ) .AND. rule_items( "DOC_IT_QTTY", _doc_it_qtt, aArtArr ) WHEN set_opc_box( nBoxX, 50 )

   nX += 1

   READ

   ESC_RETURN 0


   IF rule_items( "DOC_IT_ALT", _doc_it_alt, aArtArr ) <> .T.
      @ m_x + nX, m_y + 2 SAY PadL( "nadm. visina [m] (*):", nLeft + 3 ) GET _doc_it_alt PICT "999999" VALID val_altt( _doc_it_alt ) WHEN set_opc_box( nBoxX, 50, "Nadmorska visina izrazena u metrima" )
      @ m_x + nX, Col() + 2 SAY "grad:" GET _doc_acity VALID !Empty( _doc_acity ) PICT "@S20" WHEN set_opc_box( nBoxX, 50, "Grad u kojem se montira proizvod" )
   ELSE
      // pobrisi screen na lokaciji nadmorske visine
      @ m_x + nX, m_y + 2 SAY Space( 70 )

      // ponisti vrijednosti da ne bi ostale zapamcene u bazi
      _doc_it_alt := 0
      _doc_acity := ""

   ENDIF

   // ako je nova stavka obezbjedi unos operacija...
   IF l_new_it
      nX += 2
      @ m_x + nX, m_y + 2 SAY PadL( "unesi dod.oper.stavke (D/N)? (*):", nLeft + 15 ) GET cGetDOper PICT "@!" VALID cGetDOper $ "DN" WHEN set_opc_box( nBoxX, 50, "unos dodatnih operacija za stavku" )
   ENDIF

   READ

   ESC_RETURN 0

   // da li je doslo do promjene rednog broja stavke ?
   IF !l_new_it .AND. ( AllTrim( Str( _curr_doc_it_no ) ) <> AllTrim( Str( _doc_it_no ) ) )
      MsgBeep( "Uslijedila je promjena rednog broja !!!" )
   ENDIF

   RETURN 1


// -------------------------------------------------------
// provjera rednog broja na unosu
// -------------------------------------------------------
STATIC FUNCTION _check_rbr( docno, docitno )

   LOCAL _ok := .T.
   LOCAL _t_rec := RecNo()

   IF docitno == 0
      MsgBeep( "Redni broj ne moze biti 0 !!!" )
      _ok := .F.
      RETURN _ok
   ENDIF

   SELECT _doc_it
   GO TOP
   SEEK docno_str( docno ) + docit_str( docitno )

   IF Found()
      MsgBeep( "Redni broj vec postoji unutar dokumenta !!!" )
      _ok := .F.
   ENDIF

   GO ( _t_rec )

   RETURN _ok



// -----------------------------------
// vraca tip stavke naloga
// -----------------------------------
FUNCTION _g_doc_it_type( cType )

   LOCAL cRet := "standard"

   IF cType == "S"
      cRet := "shape"
   ELSEIF cType == "R"
      cRet := "radius"
   ENDIF

   RETURN cRet


STATIC FUNCTION _set_arr( nArt_id, aArr )

   LOCAL nTArea := Select()

   rnal_matrica_artikla( nArt_id, @aArr )

   SELECT ( nTArea )

   RETURN .T.



FUNCTION inc_docit( nDoc_no )

   LOCAL nTArea := Select()
   LOCAL nTRec := RecNo()
   LOCAL nRet := 0

   SELECT _doc_it
   GO TOP
   SET ORDER TO TAG "1"
   SEEK doc_str( nDoc_no )

   DO WHILE !Eof() .AND. field->doc_no == nDoc_no
      nRet := field->doc_it_no
      SKIP
   ENDDO

   nRet += 1

   SELECT ( nTArea )
   GO ( nTRec )

   RETURN nRet


// --------------------------------------
// vrijednost mora biti <> 0
// --------------------------------------
STATIC FUNCTION razlicito_od_0( nVal, cObjekatValidacije )

   LOCAL lRet := .T.

   IF Round( nVal, 2 ) == 0
      lRet := .F.
   ENDIF

   val_msg( lRet, cObjekatValidacije + " : mora biti <> 0 !" )

   RETURN lRet

// ---------------------------------------------------------------------
// vrijednost mora biti u opsegu
// ---------------------------------------------------------------------
STATIC FUNCTION u_opsegu( nVal, nMin, nMax, cObjekatValidacije, cJMJ )

   LOCAL lRet := .F.

   IF nVal >= nMin .AND. nVal <= nMax
      lRet := .T.
   ENDIF

   val_msg( lRet, "Dozvoljeni opseg za " + cObjekatValidacije + " " + ;
      AllTrim( Str( nMin ) ) + " - " +  AllTrim( Str( max_width() ) ) + " " + cJMJ + " !" )

   RETURN lRet

// -------------------------------------
// poruka pri validaciji
// -------------------------------------
STATIC FUNCTION val_msg( lRet, cMsg )

   IF lRet == .F.
      MsgBeeP( cMsg )
   ENDIF

   RETURN


// ------------------------------------------------------
// validacija precnika (fi), kolicine, nadmorske visine
// -------------------------------------------------------
STATIC FUNCTION val_fi( nVal )
   RETURN razlicito_od_0( nVal, "prečnik" )

// -------------------------------------
// validacija kolicine
// -------------------------------------
STATIC FUNCTION val_qtty( nVal )
   RETURN razlicito_od_0( nVal, "količina" )

// -------------------------------------
// validacija nadmorske visine
// -------------------------------------
STATIC FUNCTION val_altt( nVal )
   RETURN razlicito_od_0( nVal, "nadmorska visina" )

// ----------------------------------
// validacija sirine, visine
// ----------------------------------
STATIC FUNCTION val_width( nVal )
   RETURN u_opsegu( nVal, 1, gMaxWidth, "širina", "mm" )


STATIC FUNCTION val_heigh( nVal )
   RETURN u_opsegu( nVal, 1, gMaxHeigh, "visina", "mm" )


// -----------------------------------------------
// kopiranje stavki sa drugog naloga
// -----------------------------------------------
FUNCTION cp_items()

   LOCAL nDocCopy
   LOCAL cQ_it
   LOCAL cQ_aops
   LOCAL cSeason
   LOCAL nRet := 1
   LOCAL nTArea := Select()

   nRet := _cp_box( @nDocCopy, @cQ_it, @cQ_aops, @cSeason )

   // ako necu nista raditi - izlazim
   IF nRet = 0
      RETURN nRet
   ENDIF

   SELECT _docs

   // imam parametre, idem na kopiranje
   __cp_items( _docs->doc_no, nDocCopy, cQ_it, cQ_aops, cSeason )

   SELECT ( nTArea )

   RETURN nRet


// ----------------------------------------------
// box sa uslovim kopiranja
//
// nDoc - broj dokumenta
// cQ_it - pitanje za kopiranje stavki (d/n)
// cQ_aops - pitanje za kopiranje operac. (d/n)
// ----------------------------------------------
STATIC FUNCTION _cp_box( nDoc, cQ_It, cQ_Aops, cSeason )

   LOCAL nRet := 1
   LOCAL GetList := {}

   nDoc := 0
   cQ_it := "D"
   cQ_Aops := "D"
   cSeason := Space( 4 )

   Box(, 5, 55 )

   @ m_x + 1, m_y + 2 SAY "Nalog iz kojeg kopiramo:" GET nDoc ;
      PICT "9999999999" VALID ( nDoc > 0 )

   @ m_x + 1, Col() + 2 SAY "sezona:" GET cSeason ;

      @ m_x + 3, m_y + 2 SAY "   Kopirati stavke naloga (D/N)" GET cQ_it ;
      PICT "@!" VALID ( cQ_it $ "DN" )

   @ m_x + 4, m_y + 2 SAY "Kopirati operacije naloga (D/N)" GET cQ_Aops ;
      PICT "@!" VALID ( cQ_Aops $ "DN" )

   READ
   BoxC()


   IF LastKey() == K_ESC
      nRet := 0
   ENDIF

   RETURN nRet



// ---------------------------------------------------
// kopiraj stavke naloga
//
// nDoc - originalni dokument
// nDocCopy - dokument s kojeg kopiramo
// ---------------------------------------------------
STATIC FUNCTION __cp_items( nDoc, nDocCopy, cQ_it, cQ_aops, cSeason )

   LOCAL nTArea := Select()
   LOCAL nDocItCopy
   LOCAL nT_Docit := F_DOC_IT
   LOCAL nT_Docops := F_DOC_OPS
   LOCAL lSeason := .F.
   LOCAL _rec

   IF cQ_it == "N"
      RETURN
   ENDIF

   cSeason := AllTrim( cSeason )

   IF !Empty( cSeason ) .AND. Val( cSeason ) <> Year( Date() )

      lSeason := .T.

      // pozicioniraj se na tabele iz sezone

      SELECT ( nT_docit )
      USE
      SELECT ( nT_docit )
      USE ( KUMPATH + cSeason + SLASH + "DOC_IT.DBF" ) ALIAS doc_it

      SELECT ( nT_docops )
      USE
      SELECT ( nT_docops )
      USE ( KUMPATH + cSeason + SLASH + "DOC_OPS.DBF" ) ALIAS doc_ops

   ENDIF

   SELECT ( nT_docit )
   SET ORDER TO TAG "1"
   GO TOP
   SEEK docno_str( nDocCopy )

   // kada sam pronasao nalog sada idemo na kopiranje stavki ...
   SELECT _doc_it
   GO BOTTOM
   // redni broj
   nDoc_it_no := field->doc_it_no

   SELECT ( nT_docit )
   DO WHILE !Eof() .AND. field->doc_no = nDocCopy

      nDocItCopy := field->doc_it_no

      _rec := dbf_get_rec()

      SELECT _doc_it
      APPEND BLANK

      // zamjeni broj dokumenta i redni broj
      _rec[ "doc_no" ] := nDoc
      _rec[ "doc_it_no" ] := ++nDoc_it_no

      dbf_update_rec( _rec )

      // kopiraj i operacije ove stavke, ako je to uredu
      IF cQ_aops == "N"

         SELECT ( nT_docit )
         SKIP
         LOOP

      ENDIF

      SELECT ( nT_docops )
      GO TOP
      SEEK docno_str( nDocCopy ) + docit_str( nDocItCopy )

      DO WHILE !Eof() .AND. field->doc_no = nDocCopy ;
            .AND. field->doc_it_no = nDocItCopy

         _rec := dbf_get_rec()

         SELECT _doc_ops
         APPEND BLANK

         // samo ovo zamjeni sa trenutnim dokumentom
         _rec[ "doc_no" ] := nDoc
         _rec[ "doc_it_no" ] := nDoc_it_no

         dbf_update_rec( _rec )

         SELECT ( nT_docops )
         SKIP

      ENDDO

      SELECT ( nT_docit )
      SKIP

   ENDDO

   IF lSeason == .T.
      // vrati se na stare tabele
      SELECT ( nT_docit )
      USE
      SELECT ( nT_docops )
      USE
      O_DOC_IT
      O_DOC_OPS
   ENDIF

   SELECT ( nTArea )

   RETURN


// --------------------------------------------------------
// --------------------------------------------------------
FUNCTION set_items_article()

   LOCAL _ret := .F.
   LOCAL _art_id, _rec

   _art_id := get_items_article()

   IF _art_id == NIL
      RETURN _ret
   ENDIF

   SELECT _doc_it
   GO TOP
   DO WHILE !Eof()
      _rec := dbf_get_rec()
      _rec[ "art_id" ] := _art_id
      dbf_update_rec( _rec )
      SKIP
   ENDDO
   GO TOP
   _ret := .T.

   RETURN _ret



// --------------------------------------------------------
// --------------------------------------------------------
FUNCTION get_items_article()

   LOCAL _art_id := 0
   LOCAL _box_x := 3
   LOCAL _box_y := 40
   LOCAL _x := m_x
   LOCAL _y := m_y
   PRIVATE GetList := {}

   Box(, _box_x, _box_y )
   @ m_x + 1, m_y + 2 SAY "Odaberi artikal iz liste artikala:"
   @ m_x + 2, m_y + 2 SAY "Artikal:" GET _art_id VALID {|| s_articles( @_art_id, .F., .T. ), .T. }
   READ
   BoxC()

   m_x := _x
   m_y := _y

   IF LastKey() == K_ESC
      RETURN NIL
   ENDIF

   RETURN _art_id
