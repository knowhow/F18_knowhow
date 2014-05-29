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
STATIC l_open_dbedit
STATIC par_count
STATIC _art_id
STATIC l_quick_find
STATIC __art_sep
// article separator
STATIC __mc_sep
// match code separator
STATIC __qf_cond
// quick find condition
STATIC __aop_sep
// addops separator



// ------------------------------------------------
// otvara sifrarnik artikala
// cId - artikal id
// ------------------------------------------------
FUNCTION s_articles( cId, lAutoFind, lQuickFind )

   LOCAL nBoxX := maxrows() - 4
   LOCAL nBoxY := maxcols() - 4
   LOCAL nTArea
   LOCAL cHeader
   LOCAL cFooter
   LOCAL cOptions := ""
   LOCAL cTag := "1"
   LOCAL GetList := {}
   PRIVATE ImeKol
   PRIVATE Kol

   par_count := PCount()
   l_open_dbedit := .T.

   __art_sep := "_"
   __aop_sep := "-"
   __mc_sep := "_"
   __qf_cond := Space( 200 )

   IF lAutoFind == nil
      lAutoFind := .F.
   ENDIF

   IF lQuickFind == nil
      lQuickFind := .F.
   ENDIF

   l_quick_find := lQuickFind

   IF ( par_count > 0 )

      IF lAutoFind == .F.

         l_open_dbedit := .F.

      ENDIF

      IF cId <> Val( artid_str( 0 ) ) .AND. lAutoFind == .T.

         l_open_dbedit := .F.

         lAutoFind := .F.

      ENDIF

   ENDIF

   nTArea := Select()

   O_ARTICLES

   cHeader := "Artikli /"
   cFooter := ""

   SELECT articles
   SET RELATION TO
   SET FILTER TO

   // id: sort by art_id
   SET ORDER TO TAG "1"

   GO TOP

   IF !l_open_dbedit

      SEEK artid_str( cId )

      IF !Found()
         l_open_dbedit := .T.
         GO TOP
      ENDIF

   ENDIF

   IF l_open_dbedit

      set_a_kol( @ImeKol, @Kol )

      cOptions += "cN-novi "
      cOptions += "cT-brisi "
      cOptions += "F2-ispr. "
      cOptions += "F3-isp.naz. "
      cOptions += "F4-dupl. "
      cOptions += "Q-br.traz"

      Box(, nBoxX, nBoxY, .T. )

      @ m_x + nBoxX + 1, m_y + 2 SAY cOptions

      ObjDbedit(, nBoxX, nBoxY, {|| key_handler( Ch ) }, cHeader, cFooter, .T.,,,, 7 )

      BoxC()

   ENDIF

   cId := field->art_id

   SELECT ( nTArea )

   RETURN



// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
STATIC FUNCTION set_a_kol( aImeKol, aKol )

   aKol := {}
   aImeKol := {}

   AAdd( aImeKol, { PadC( "ID/MC", 10 ), {|| sif_idmc( art_id ) }, "art_id", {|| rnal_uvecaj_id( @wArt_id, "ART_ID" ), .F. }, {|| .T. } } )
   AAdd( aImeKol, { "sifra :: puni naziv", {|| AllTrim( art_desc ) + " :: " + Upper( art_full_d ) }, "art_desc" } )
   AAdd( aImeKol, { "labela opis", {|| AllTrim( art_lab_de ) }, "art_desc" } )

   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN


STATIC FUNCTION key_handler()

   LOCAL nArt_id := 0
   LOCAL cArt_desc := ""
   LOCAL nArt_type := 0
   LOCAL cSchema := Space( 20 )
   LOCAL nTRec := RecNo()
   LOCAL nRet

   box_preview( maxrows() - 9, 2, maxcols() - 3 )

   DO CASE

   CASE l_quick_find == .T.

      brza_pretraga_artikla()

      l_quick_find := .F.

      Tb:RefreshAll()

      WHILE !TB:stabilize()
      END

      RETURN DE_CONT

   CASE Ch == K_CTRL_N

      SELECT articles
      SET FILTER TO
      SET RELATION TO

      IF setuj_novi_id_tabele( @nArt_id, "ART_ID", NIL, "FULL" ) == 0
         RETURN DE_CONT
      ENDIF

      odaberi_tip_artikla( @nArt_type, @cSchema )

      IF s_elements( nArt_id, .T., nArt_Type, cSchema ) == 1
         SELECT articles
         GO BOTTOM
      ELSE
         SELECT articles
         GO ( nTRec )
      ENDIF

      RETURN DE_REFRESH

   CASE Ch == K_F2

      IF s_elements( field->art_id ) == 1

         SELECT articles
         SET ORDER TO TAG "1"
         GO ( nTRec )

         RETURN DE_REFRESH

      ENDIF

      SELECT articles
      SET ORDER TO TAG "1"
      GO ( nTRec )

      RETURN DE_CONT

   CASE Ch == K_F3

      IF ispravi_opis_artikla( field->art_id ) == 1
         RETURN DE_REFRESH
      ENDIF

   CASE Ch == K_F4

      SELECT articles

      nArt_new := rnal_dupliciraj_artikal( articles->art_id )

      IF nArt_new > 0 .AND. s_elements( nArt_new, .T. ) == 1

         SELECT articles
         SET ORDER TO TAG "1"
         GO ( nTRec )

         RETURN DE_REFRESH

      ENDIF

      SELECT articles
      SET ORDER TO TAG "1"
      GO ( nTRec )
      RETURN DE_REFRESH

   CASE Ch == K_CTRL_T

      IF rnal_brisi_artikal( field->art_id, .T. ) == 1
         RETURN DE_REFRESH
      ENDIF

      RETURN DE_CONT


   CASE Ch == K_ENTER

      IF par_count > 0
         RETURN DE_ABORT
      ENDIF

   CASE Upper( Chr( Ch ) ) == "Q"

      IF brza_pretraga_artikla() == 1
         RETURN DE_REFRESH
      ENDIF

      RETURN DE_CONT

   ENDCASE

   RETURN DE_CONT



STATIC FUNCTION odaberi_tip_artikla( nType, cSchema )

   LOCAL nX := 1
   PRIVATE GetList := {}

   cSchema := Space( 20 )
   nType := 0

   Box(, 10, 50 )

   @ m_x + nX, m_y + 2 SAY "Odabir vrste artikla"

   nX += 2

   @ m_x + nX, m_y + 2 SAY "   (1) jednostruko staklo"

   ++nX

   @ m_x + nX, m_y + 2 SAY "   (2) dvostruko staklo"

   ++nX

   @ m_x + nX, m_y + 2 SAY8 "   (3) trostruko/višestruko staklo"

   nX += 2

   @ m_x + nX, m_y + 2 SAY "   (0) ostalo"

   nX += 2

   @ m_x + nX, m_y + 2 SAY " selekcija:" GET nType VALID nType >= 0 .AND. nType <= 3 PICT "9"

   READ

   IF nType <> 0
      @ m_x + nX, m_y + 18 SAY8 "šema:" GET cSchema VALID odaberi_shemu_artikla( @cSchema, nType )
   ENDIF

   READ

   BoxC()

   RETURN


STATIC FUNCTION odaberi_shemu_artikla( cSchema, nType )

   LOCAL aSch
   LOCAL i
   LOCAL nSelect := 0
   LOCAL opc := {}
   LOCAL opcexe := {}
   LOCAL izbor := 1

   aSch := rnal_shema_artikla_za_tip( nType )

   IF ( aSch == NIL .OR. Len( aSch ) == 0 )

      msgbeep( "Ne postoje definisane šeme, koristim standardnu šemu za tip " + ALLTRIM( STR( nType ) ) )

      IF nType == 1
         cSchema := "G"
      ELSEIF nType == 2
         cSchema := "G-F-G"
      ELSEIF nType == 3
         cSchema := "G-F-G-F-G"
      ENDIF

      RETURN .T.

   ENDIF


   FOR i := 1 TO Len( aSch )

      cPom := PadR( aSch[ i, 1 ], 30 )

      AAdd( opc, cPom )
      AAdd( opcexe, {|| nSelect := izbor, izbor := 0 } )

   NEXT

   f18_menu( "schema", .F., @izbor, opc, opcexe )

   cSchema := AllTrim( aSch[ nSelect, 1 ] )

   RETURN .T.



STATIC FUNCTION brza_pretraga_artikla()

   LOCAL cFilt := ".t."

   IF brza_pretraga_uslov() == 0
      RETURN 0
   ENDIF

   IF brza_pretraga_filter( @cFilt ) == 0
      RETURN 0
   ENDIF

   SELECT articles
   SET FILTER TO
   GO TOP

   IF cFilt == ".t."

      SET FILTER TO
      GO TOP
      nRet := 0

   ELSE

      MsgO( "Vrsim selekciju artikala... sačekajte trenutak...." )

      cFilt := StrTran( cFilt, ".t. .and.", "" )

      SET FILTER to &cFilt
      SET ORDER TO TAG "2"

      GO TOP

      MsgC()
      nRet := 1

   ENDIF

   RETURN nRet



STATIC FUNCTION brza_pretraga_filter( cFilter )

   LOCAL nRet := 0
   LOCAL aTmp := {}
   LOCAL aArtTmp := {}
   LOCAL i
   LOCAL nCnt

   IF Empty( __qf_cond )
      RETURN nRet
   ENDIF

   cCond := AllTrim( __qf_cond )

   // F4*F4;F2*F4; => aTmp[1] = F4*F4
   // => aTmp[2] = F2*F4

   aTmp := TokToNiz( cCond, ";" )

   FOR i := 1 TO Len( aTmp )

      IF ( i == 1 )

         cFilter += " .and. "

      ELSE

         cFilter += " .or. "

      ENDIF


      IF "*" $ aTmp[ i ]

         aCountTmp := TokToNiz( cCond, "*" )
         nCount := Len( aCountTmp )

         // "*F4"

         IF Left( aTmp[ i ], 1 ) == "*" .AND. nCount == 1

            cTmp := Upper( AllTrim( aCountTmp[ 1 ] ) )

            cFilter += cm2str( "_" + cTmp )
            cFilter += " $ "
            cFilter += "ALLTRIM(UPPER(art_desc))"


            // "F4*"

         ELSEIF Right( aTmp[ i ], 1 ) == "*" .AND. nCount == 1

            cTmp := Upper( AllTrim( aCountTmp[ i ] ) )
            nTmp := Len( cTmp )

            cFilter += "LEFT(ALLTRIM(UPPER(art_desc)), " + AllTrim( Str( nTmp ) ) + ")"
            cFilter += " = "
            cFilter += cm2str( cTmp )


         ELSEIF nCount > 1

            aArtTmp := TokToNiz( aTmp[ i ], "*" )

            FOR iii := 1 TO Len( aArtTmp )

               IF iii == 1

                  cTmp := Upper( AllTrim( aArtTmp[ iii ] ) )
                  nTmp := Len( cTmp )

                  cFilter += " ( "
                  cFilter += "LEFT(ALLTRIM(UPPER(art_desc)), " + AllTrim( Str( nTmp ) ) + ")"
                  cFilter += " = "
                  cFilter += cm2str( cTmp )

               ELSEIF iii > 1

                  cTmp := Upper( AllTrim( aArtTmp[ iii ] ) )
                  cFilter += " .and. " + cm2str( "_" + cTmp )
                  cFilter += " $ "
                  cFilter += "ALLTRIM(UPPER(art_desc))"

               ENDIF

               IF iii == Len( aArtTmp )
                  cFilter += " ) "
               ENDIF
            NEXT

         ELSE

         ENDIF

      ELSE

         // cisi unos, gleda se samo LEFT( nnn )

         cTmp := AllTrim( aTmp[ i ] )
         nTmp := Len( cTmp )

         cFilter += "LEFT(ALLTRIM(UPPER(art_desc)), " + AllTrim( Str( nTmp ) ) + ")"
         cFilter += " = "
         cFilter += cm2str( Upper( cTmp ) )

      ENDIF

   NEXT

   IF cFilter == ".t."
      nRet := 0
   ELSE
      nRet := 1
   ENDIF

   RETURN nRet


STATIC FUNCTION brza_pretraga_uslov()

   LOCAL nBoxX := 6
   LOCAL nBoxY := 70
   LOCAL nX := 1
   PRIVATE GetList := {}

   Box(, nBoxX, nBoxY )

   @ m_x + nX, m_y + 2 SAY "===>>> Brza pretraga artikala ===>>>"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "uslov:" GET __qf_cond VALID validacija_uslova( __qf_cond ) PICT "@S60!"

   READ
   BoxC()

   ESC_RETURN 0

   RETURN 1


STATIC FUNCTION validacija_uslova( cCond )

   LOCAL lRet := .T.

   IF Empty( cCond )
      lRet := .F.
   ENDIF

   IF lRet == .F. .AND. Empty( cCond )
      MsgBeep( "Uslov ne može biti prazno !" )
   ENDIF

   RETURN lRet




STATIC FUNCTION ispravi_opis_artikla( nArt_id )

   LOCAL cArt_desc := PadR( field->art_desc, 100 )
   LOCAL cArt_mcode := PadR( field->match_code, 10 )
   LOCAL cArt_full_desc := PadR( field->art_full_d, 250 )
   LOCAL cArt_lab_desc := PadR( field->art_lab_de, 200 )
   LOCAL cDBFilter := dbFilter()
   LOCAL nTRec := RecNo()
   LOCAL nRet := 0
   LOCAL _rec

   IF !f18_lock_tables( { "articles" } )
      MsgBeep( "Ne mogu lockovati tabelu !" )
      RETURN nRet
   ENDIF

   sql_table_update( nil, "BEGIN" )

   IF ispravka_artikla_box( @cArt_desc, @cArt_full_desc, @cArt_lab_desc, ;
         @cArt_mcode ) == 1

      SET FILTER TO
      SET ORDER TO TAG "1"
      GO TOP

      SEEK artid_str( nArt_id )

      _rec := dbf_get_rec()

      _rec[ "art_desc" ] := cArt_desc
      _rec[ "art_full_d" ] := cArt_full_desc
      _rec[ "art_lab_de" ] := cArt_lab_desc
      _rec[ "match_code" ] := cArt_mcode

      update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )

      SET ORDER TO TAG "1"
      SET FILTER to &cDBFilter
      GO ( nTRec )

      nRet := 1
   ENDIF

   f18_free_tables( { "articles" } )
   sql_table_update( nil, "END" )

   RETURN nRet


// ----------------------------------------
// prikazi info artikla u box preview
// ----------------------------------------
STATIC FUNCTION box_preview( nX, nY, nLen )

   LOCAL aDesc := {}
   LOCAL i

   aDesc := TokToNiz( articles->art_full_d, ";" )

   @ nX, nY SAY PadR( "ID: " + artid_str( articles->art_id ) + Space( 3 ) + "MATCH CODE: " + articles->match_code, nLen ) COLOR "GR+/G"

   FOR i := 1 TO 6
      @ nX + i, nY SAY PadR( "", nLen ) COLOR "BG+/B"
   NEXT

   FOR i := 1 TO Len( aDesc )

      @ nX + i, nY SAY PadR( " * " + AllTrim( aDesc[ i ] ), nLen ) COLOR "BG+/B"

   NEXT

   RETURN


// -------------------------------
// convert art_id to string
// -------------------------------
FUNCTION artid_str( nId )
   RETURN Str( nId, 10 )


// -------------------------------
// get art_desc by art_id
// -------------------------------
FUNCTION g_art_desc( nArt_id, lEmpty, lFullDesc )

   LOCAL cArtDesc := "?????"
   LOCAL nTArea := Select()

   IF lEmpty == nil
      lEmpty := .F.
   ENDIF

   IF lEmpty == .T.
      cArtDesc := ""
   ENDIF

   IF lFullDesc == nil
      lFullDesc := .T.
   ENDIF

   O_ARTICLES
   SELECT articles
   SET ORDER TO TAG "1"
   GO TOP
   SEEK artid_str( nArt_id )

   IF Found()
      IF lFullDesc == .T.
         IF !Empty( field->art_full_d )
            cArtDesc := AllTrim( field->art_full_d )
         ENDIF
      ELSE
         IF !Empty( field->art_desc )
            cArtDesc := AllTrim( field->art_desc )
         ENDIF
      ENDIF
   ENDIF

   SELECT ( nTArea )

   RETURN cArtDesc



STATIC FUNCTION rnal_brisi_artikal( nArt_id, lChkKum, lSilent )

   LOCAL nEl_id
   LOCAL _del_rec, _field_ids, _where_bl
   LOCAL _el_tek, _att_tek, _aops_tek

   IF lSilent == nil
      lSilent := .F.
   ENDIF

   IF lChkKum == nil
      lChkKum := .F.
   ENDIF

   IF lChkKum == .T.

      O_DOC_IT
      SELECT doc_it
      SET ORDER TO TAG "2"
      GO TOP

      SEEK artid_str( nArt_id )

      IF Found()
         MsgBeep( "Uočeno je da se artikal koristi u nalogu br: " + AllTrim( Str( doc_it->doc_no ) ) + " #BRISANJE ONEMOGUĆENO !" )
         SELECT articles
         RETURN 0
      ENDIF
   ENDIF

   SELECT articles
   SET ORDER TO TAG "1"
   GO TOP
   SEEK artid_str( nArt_id )

   IF Found()

      IF !lSilent .AND. Pitanje(, "Izbrisati zapis (D/N) ???", "N" ) == "N"
         RETURN 0
      ENDIF

      _del_rec := dbf_get_rec()

      IF !f18_lock_tables( { "articles", "elements", "e_att", "e_aops" } )
         RETURN 0
      ENDIF

      sql_table_update( nil, "BEGIN" )

      delete_rec_server_and_dbf( Alias(), _del_rec, 1, "CONT" )

      SELECT elements
      SET ORDER TO TAG "1"
      GO TOP
      SEEK artid_str( nArt_id )

      DO WHILE !Eof() .AND. field->art_id == nArt_id

         SKIP 1
         _el_tek := RecNo()
         SKIP -1

         nEl_id := field->el_id

         SELECT e_att
         SET ORDER TO TAG "1"
         GO TOP
         SEEK elid_str( nEl_id )

         DO WHILE !Eof() .AND. field->el_id == nEl_id

            SKIP 1
            _att_tek := RecNo()
            SKIP -1

            _del_rec := dbf_get_rec()
            delete_rec_server_and_dbf( Alias(), _del_rec, 1, "CONT" )

            GO ( _att_tek )
         ENDDO

         SELECT e_aops
         SET ORDER TO TAG "1"
         GO TOP
         SEEK elid_str( nEl_id )

         DO WHILE !Eof() .AND. field->el_id == nEl_id
            SKIP 1
            _aops_tek := RecNo()
            SKIP -1
            _del_rec := dbf_get_rec()
            delete_rec_server_and_dbf( Alias(), _del_rec, 1, "CONT" )

            GO ( _aops_tek )
         ENDDO

         SELECT elements

         _del_rec := dbf_get_rec()
         delete_rec_server_and_dbf( Alias(), _del_rec, 1, "CONT" )

         GO ( _el_tek )

      ENDDO

      f18_free_tables( { "articles", "elements", "e_att", "e_aops" } )
      sql_table_update( nil, "END" )

   ENDIF

   SELECT articles

   RETURN 1



STATIC FUNCTION rnal_dupliciraj_artikal( nArt_id )

   LOCAL nArtNewid
   LOCAL nElRecno
   LOCAL nOldEl_id
   LOCAL nElGr_id
   LOCAL nElNewid := 0
   LOCAL _rec

   IF Pitanje(, "Duplicirati artikal (D/N)?", "D" ) == "N"
      RETURN -1
   ENDIF

   SELECT articles
   SET FILTER TO
   SET RELATION TO

   IF !f18_lock_tables( { "articles", "elements", "e_att", "e_aops" } )
      RETURN -1
   ENDIF

   sql_table_update( nil, "BEGIN" )

   IF setuj_novi_id_tabele( @nArtNewid, "ART_ID" ) == 0
      RETURN -1
   ENDIF

   SELECT elements
   SET ORDER TO TAG "1"
   GO TOP
   SEEK artid_str( nArt_id )

   DO WHILE !Eof() .AND. field->art_id == nArt_id

      nElNewId := 0
      nOldEl_id := field->el_id
      nElGr_id := field->e_gr_id

      SKIP 1
      nElRecno := RecNo()
      SKIP -1

      // daj mi novi element
      setuj_novi_id_tabele( @nElNewid, "EL_ID" )

      _rec := dbf_get_rec()

      _rec[ "art_id" ] := nArtNewid
      _rec[ "e_gr_id" ] := nElGr_id

      update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )

      rnal_dupliciraj_atribute_artikla( nOldEl_id, nElNewid )

      rnal_dupliciraj_operacije_artikla( nOldEl_id, nElNewid )

      SELECT elements
      GO ( nElRecno )

   ENDDO

   f18_free_tables( { "articles", "elements", "e_att", "e_aops" } )
   sql_table_update( nil, "END" )

   RETURN nArtNewid


STATIC FUNCTION rnal_dupliciraj_atribute_artikla( nOldEl_id, nNewEl_id )

   LOCAL nElRecno
   LOCAL nNewAttId := 0
   LOCAL _rec

   SELECT e_att
   SET ORDER TO TAG "1"
   GO TOP

   SEEK elid_str( nOldEl_id )

   DO WHILE !Eof() .AND. field->el_id == nOldEl_id

      SKIP 1
      nElRecno := RecNo()
      SKIP -1

      _rec := dbf_get_rec()

      setuj_novi_id_tabele( @nNewAttId, "EL_ATT_ID" )

      _rec := dbf_get_rec()

      _rec[ "el_att_id" ] := nNewAttId
      _rec[ "el_id" ] := nNewEl_id

      update_rec_server_and_dbf( "e_att", _rec, 1, "CONT" )

      SELECT e_att
      GO ( nElRecno )

   ENDDO

   RETURN


STATIC FUNCTION rnal_dupliciraj_operacije_artikla( nOldEl_id, nNewEl_id )

   LOCAL nElRecno
   LOCAL nNewAopId := 0
   LOCAL _rec

   SELECT e_aops
   SET ORDER TO TAG "1"
   GO TOP

   SEEK elid_str( nOldEl_id )

   DO WHILE !Eof() .AND. field->el_id == nOldEl_id

      SKIP 1
      nElRecno := RecNo()
      SKIP -1

      _rec := dbf_get_rec()

      setuj_novi_id_tabele( @nNewAopId, "EL_OP_ID" )

      _rec[ "el_op_id" ] := nNewAopid
      _rec[ "el_id" ] := nNewEl_id

      update_rec_server_and_dbf( "e_aops", _rec, 1, "CONT" )

      SELECT e_aops
      GO ( nElRecno )

   ENDDO

   RETURN




// -----------------------------------------
// filuje matricu aAttr
//
// vars:
// aArr - matrica, proslijedjuje se po ref.
// nElNo - broj elementa artikla
// cGrValCode - kod vrijednosti grupe
// cGrVal - vrijednost grupe (puni opis)
// cAttJoker - joker atributa
// cAttValCode - kod vrijednosti atributa
// cAttVal - vrijednost atributa (puni opis)
// -----------------------------------------
STATIC FUNCTION _f_a_attr( aArr, nElNo, cGrValCode, cGrVal, ;
      cAttJoker, cAttValCode, cAttVal )

   AAdd( aArr, { nElNo, cGrValCode, cGrVal, cAttJoker, cAttValCode, cAttVal } )

   RETURN


// ----------------------------------------------
// setovanje opisa artikla na osnovu tabela
// ELEMENTS, E_AOPS, E_ATT
//
// nArt_id - artikal id
// lNew - novi artikal
// lAuto - auto generacija naziva
// ----------------------------------------------
//
//
// aArr sadrzi:
// { nElNo, cGrValCode, cGrVal, cAttJoker, cAttValCode, cAttVal }

FUNCTION rnal_setuj_naziv_artikla( nArt_id, lNew, lAuto, aAttr, lOnlyArr )

   // artikal kod
   LOCAL cArt_code := ""
   // artikal puni naziv
   LOCAL cArt_desc := ""
   // artikal match kod
   LOCAL cArt_mcode := ""
   // element id
   LOCAL nEl_id
   // grupa id iz elementa
   LOCAL nEl_gr_id
   // grupa kod
   LOCAL cGr_code
   // grupa puni naziv
   LOCAL cGr_desc
   // atribut grupe ID
   LOCAL nE_gr_att
   // vrijednost atributa ID
   LOCAL nE_gr_val
   // vrijednost atributa opis
   LOCAL cAttValCode
   // vrijednost atributa grupe opis
   LOCAL cAttVal
   // joker atributa, operacije
   LOCAL cAttJoker
   LOCAL cAopJoker
   LOCAL cAop
   LOCAL cAopCode
   LOCAL cAopAtt
   LOCAL cAopAttCode

   // ostale pomocne varijable
   LOCAL nRet := 0
   LOCAL nCount := 0
   LOCAL nElCount := 0

   IF lOnlyArr == nil
      lOnlyArr := .F.
   ENDIF

   // matrica sa atributima
   IF aAttr == nil
      aAttr := {}
   ENDIF

   // setovanje statickih varijabli

   // article code separator
   __art_sep := "_"
   // puni naziv separator
   __mc_sep := ";"
   // add ops separator
   __aop_sep := "-"

   IF lAuto == nil
      lAuto := .F.
   ENDIF

   // ukini filtere
   SELECT elements
   SET FILTER TO
   SELECT e_att
   SET FILTER TO
   SELECT e_aops
   SET FILTER TO
   SELECT aops
   SET FILTER TO
   SELECT aops_att
   SET FILTER TO

   // elementi...
   SELECT elements
   SET ORDER TO TAG "1"
   GO TOP
   SEEK artid_str( nArt_id )

   DO WHILE !Eof() .AND. field->art_id == nArt_id

      // brojac elementa, 1, 2, 3
      ++ nElCount

      // ID element
      nEl_id := field->el_id
      // ID grupa na osnovu elementa
      nEl_gr_id := field->e_gr_id

      // grupa kod
      cGr_code := AllTrim( g_e_gr_desc( nEl_gr_id, nil, .F. ) )
      // grupa puni opis
      cGr_desc := AllTrim( g_e_gr_desc( nEl_gr_id ) )

      // .... predji na atribute elemenata .....
      SELECT e_att
      SET ORDER TO TAG "1"
      GO TOP
      SEEK elid_str( nEl_id )

      DO WHILE !Eof() .AND. field->el_id == nEl_id


         // vrijednost atributa
         nE_gr_val := field->e_gr_vl_id
         cAttValCode := AllTrim( g_e_gr_vl_desc( nE_gr_val, nil, .F. ) )
         cAttVal := AllTrim( g_e_gr_vl_desc( nE_gr_val ) )

         // koji je ovo atribut ?????
         nE_gr_att := g_gr_att_val( nE_gr_val )

         // daj njegov opis
         cAtt_desc := AllTrim( g_gr_at_desc( nE_gr_att ) )

         // joker ovog atributa je ???
         cAttJoker := g_gr_att_joker( nE_gr_att )


         _f_a_attr( @aAttr, nElCount, cGr_code, cGr_desc, ;
            cAttJoker, cAttValCode, cAttVal )

         SKIP

      ENDDO

      // predji na dodatne operacije elemenata....
      SELECT e_aops
      SET ORDER TO TAG "1"
      GO TOP
      SEEK elid_str( nEl_id )

      DO WHILE !Eof() .AND. field->el_id == nEl_id

         // dodatna operacija ID ...
         nAop_id := field->aop_id

         cAopCode := AllTrim( g_aop_desc( nAop_id, nil, .F. ) )
         cAop := AllTrim( g_aop_desc( nAop_id ) )

         // koji je djoker ????
         cAopJoker := AllTrim( g_aop_joker( nAop_id ) )

         // atribut...
         nAop_att_id := field->aop_att_id
         cAopAttCode := AllTrim( g_aop_att_desc( nAop_att_id, nil, .F. ) )
         IF Empty( cAopAttCode )
            cAopAttCode := cAopCode
         ENDIF

         cAopAtt := AllTrim( g_aop_att_desc( nAop_att_id ) )

         IF Empty( cAopAtt )
            cAopAtt := cAop
         ENDIF

         // ukini jokere koji se koriste za pozicije pecata i slicno
         rem_jokers( @cAopAtt )

         _f_a_attr( @aAttr, nElCount, cGr_code, cGr_desc, ;
            cAopJoker, cAopAttCode, ;
            cAopAtt )

         SKIP
      ENDDO

      // vrati se na elemente i idi dalje...
      SELECT elements
      SKIP

      ++ nCount

   ENDDO

   IF lOnlyArr == .F.

      rnal_setuj_naziv_artikla_iz_pravila( aAttr, @cArt_code, @cArt_desc, @cArt_mcode )

      IF lAuto == .T.
         nRet := rnal_azuriraj_artikal_auto( nArt_id, cArt_code, cArt_desc, cArt_mcode )
      ELSE
         nRet := rnal_azuriraj_artikal( nArt_id, cArt_code, cArt_desc, cArt_mcode, lNew )
      ENDIF

   ENDIF

   RETURN nRet



// ---------------------------------------------------------
// vraca naziv elementa unutar kompozicije iz ARR
// aArr - matrica sa definicijom artikla
// nEl_count - redni broj trazenog elementa
// ---------------------------------------------------------
FUNCTION g_el_descr( aArr, nEl_count )

   LOCAL nTotElem
   LOCAL cElemCode
   LOCAL i
   LOCAL xRet := ""
   LOCAL cTmp
   LOCAL nTmp
   LOCAL nTmp2
   LOCAL nScan
   LOCAL lInsLExtChar := .F.
   LOCAL cLExtraChar := ""

   // ukupni broj elemenata
   IF Len( aArr ) > 0
      nTotElem := aArr[ Len( aArr ), 1 ]
   ENDIF

   IF nEl_count > nTotElem
      xRet := "unknown"
      RETURN xRet
   ENDIF

   nScan := AScan( aArr, {|xVal| xVal[ 1 ] = nEl_count } )

   IF nScan = 0
      xRet := "unknown"
      RETURN xRet
   ENDIF

   // iscitaj code elementa
   cElemCode := aArr[ nScan, 2 ]

   // uzmi pravilo <GL_TICK>#<GL_TYPE>.....
   cRule := pravilo_grupe_elementa( cElemCode )

   aRule := TokToNiz( cRule, "#" )

   FOR nRule := 1 TO Len( aRule )

      // <GL_TICK>
      cRuleDef := AllTrim( aRule[ nRule ] )

      IF Left( cRuleDef, 1 ) <> "<"

         cLExtraChar := Left( cRuleDef, 1 )
         cRuleDef := StrTran( cRuleDef, cLExtraChar, "" )

         lInsLExtChar := .T.

      ENDIF

      nSeek := AScan( aArr, {| xVal | ;
         xVal[ 1 ] == nEl_count .AND. xVal[ 4 ] == cRuleDef } )

      IF nSeek > 0

         IF lInsLExtChar == .T.
            xRet += cLExtraChar
            lInsLExtChar := .F.
         ENDIF

         xRet += AllTrim( aArr[ nSeek, 5 ] )

      ENDIF

   NEXT

   RETURN xRet


/*
   Opis: setovanje naziva artikla automatski na osnovu pravila definisanih u tabeli pravila (f18_rules)

   Parameters:
     - aArr - matrica definicije artikla
     - cArt_code 
     - cArt_desc
     - cArt_mcode
*/

STATIC FUNCTION rnal_setuj_naziv_artikla_iz_pravila( aArr, cArt_code, cArt_desc, cArt_mcode )

   LOCAL nTotElem := 0
   LOCAL cElemCode
   LOCAL i
   LOCAL cTmp
   LOCAL nTmp
   LOCAL lInsLExtChar := .F.
   LOCAL cLExtraChar := ""

   IF Len( aArr ) > 0
      nTotElem := aArr[ Len( aArr ), 1 ]
   ENDIF

   FOR i := 1 TO nTotElem

      nTmp := AScan( aArr, {| xVar | xVar[ 1 ] == i } )
      cElemCode := aArr[ nTmp, 2 ]

      cRule := pravilo_grupe_elementa( cElemCode )
      aRule := TokToNiz( cRule, "#" )

      FOR nRule := 1 TO Len( aRule )

         cRuleDef := AllTrim( aRule[ nRule ] )

         IF Left( cRuleDef, 1 ) <> "<"

            cLExtraChar := Left( cRuleDef, 1 )
            cRuleDef := StrTran( cRuleDef, cLExtraChar, "" )

            lInsLExtChar := .T.

         ENDIF

         nSeek := AScan( aArr, {| xVal | ;
            xVal[ 1 ] == i .AND. xVal[ 4 ] == cRuleDef } )

         IF nSeek > 0

            IF lInsLExtChar == .T.
               cArt_code += cLExtraChar
               lInsLExtChar := .F.
            ENDIF

            cArt_code += AllTrim( aArr[ nSeek, 5 ] )

            IF !Empty( cArt_desc )
               cArt_desc += " "
            ENDIF

            cArt_desc += AllTrim( aArr[ nSeek, 6 ] )

            cArt_mcode += AllTrim( ;
               PadR( Upper( AllTrim( aArr[ nSeek, 6 ] ) ), 2 ) )

         ENDIF

      NEXT

      IF i <> nTotElem
         cArt_code += "_"
         cArt_desc += ";"
      ENDIF

   NEXT

   RETURN



STATIC FUNCTION pravilo_grupe_elementa( cCode )

   LOCAL cRule := ""

   cRule := rnal_format_naziva_elementa( cCode )

   IF Empty( cRule )
      msgbeep( "Pravilo za formiranje naziva elementa ne postoji !!!" )
   ENDIF

   RETURN cRule




STATIC FUNCTION postoji_li_artikal( nArt_id, cDesc, nId )

   LOCAL nTArea := Select()
   LOCAL lRet := .F.

   SELECT articles
   SET ORDER TO TAG "2"
   GO TOP
   SEEK cDesc

   IF Found() .AND. field->art_id <> nArt_id .AND. AllTrim( cDesc ) == AllTrim( field->art_desc )
      nId := field->art_id
      lRet := .T.
   ENDIF

   SET ORDER TO TAG "1"

   SELECT ( nTArea )

   RETURN lRet


/*
   Opis: ažuriranje artikla u šifranik rnal_articles, otvaranje box-a za nazive

   Parametres:
     - nArt_id - id artikla
     - cArt_desc - skraćeni opis artikla
     - cArt_full_desc - puni opis artikla
     - cArt_mcode - match code artikla
     - lNew - .T. novi artikla, .F. postojeći
*/

STATIC FUNCTION rnal_azuriraj_artikal( nArt_id, cArt_Desc, cArt_full_desc, cArt_mcode, lNew )

   LOCAL lAppend := .F.
   LOCAL lExist := .F.
   LOCAL nExist_id := 0
   LOCAL cArt_lab_desc := ""

   lExist := postoji_li_artikal( nArt_id, cArt_desc, @nExist_id )

   IF lExist == .T.
      msgBeep( "UPOZORENJE: već postoji artikal sa istim opisom !!!#Artikal: " + AllTrim( Str( nExist_id ) ) )
   ENDIF

   SELECT articles
   SET ORDER TO TAG "1"
   GO TOP
   SEEK artid_str( nArt_id )

   IF Found()

      IF !lNew
         IF AllTrim( cArt_desc ) == AllTrim( articles->art_desc ) ;
               .AND. AllTrim( cArt_full_desc ) == AllTrim( articles->art_full_d )
            lAppend := .F.
         ELSE
            lAppend := .T.
         ENDIF
      ELSE
         lAppend := .T.
      ENDIF

      IF !Empty( cArt_desc ) .AND. lAppend == .T. ;
            .AND. ( !lNew .OR. ( lNew .AND. Pitanje(, "Novi artikal, snimiti promjene ?", "D" ) == "D" ) )

         cArt_desc := PadR( cArt_desc, 100 )
         cArt_full_desc := PadR( cArt_full_desc, 250 )
         cArt_lab_desc := PadR( cArt_lab_desc, 200 )
         cArt_mcode := PadR( cArt_mcode, 10 )

         IF ispravka_artikla_box( @cArt_desc, @cArt_full_desc, ;
               @cArt_lab_desc, @cArt_mcode ) == 1

            _rec := dbf_get_rec()

            _rec[ "art_desc" ] := cArt_desc
            _rec[ "match_code" ] := cArt_mcode
            _rec[ "art_full_d" ] := cArt_full_desc
            _rec[ "art_lab_de" ] := cArt_lab_desc

            update_rec_server_and_dbf( "articles", _rec, 1, "FULL" )

            RETURN 1

         ENDIF

      ENDIF

      IF lNew == .T.
         rnal_brisi_artikal( nArt_id, .T., .T. )
      ENDIF

   ENDIF

   RETURN 0



/*
   Opis: automatsko ažuriranje artikla u šifranik rnal_articles

   Parametres:
     - nArt_id - id artikla
     - cArt_desc - skraćeni opis artikla
     - cArt_full_desc - puni opis artikla
     - cArt_mcode - match code artikla
*/
STATIC FUNCTION rnal_azuriraj_artikal_auto( nArt_id, cArt_Desc, cArt_full_desc, cArt_mcode )

   LOCAL lChange := .F.
   LOCAL _rec

   IF Empty( cArt_desc )
      RETURN 0
   ENDIF

   SELECT articles
   SET ORDER TO TAG "1"
   GO TOP
   SEEK artid_str( nArt_id )

   IF Found()

      IF AllTrim( cArt_desc ) == AllTrim( articles->art_desc ) .AND. ;
            AllTrim( cArt_full_desc ) == AllTrim( articles->art_full_d )
         lChange := .F.
      ELSE
         lChange := .T.
      ENDIF

   ENDIF

   IF lChange == .T.

      cArt_desc := PadR( cArt_desc, 100 )
      cArt_full_desc := PadR( cArt_full_desc, 100 )
      cArt_mcode := PadR( cArt_mcode, 10 )

      _rec := dbf_get_rec()

      _rec[ "art_desc" ] := cArt_desc
      _rec[ "match_code" ] := cArt_mcode
      _rec[ "art_full_d" ] := cArt_full_desc

      update_rec_server_and_dbf( "articles", _rec, 1, "FULL" )

      RETURN 1

   ENDIF

   RETURN 0



// ------------------------------------------------
// dodaj na string cStr string cAdd
// cStr - po referenci string na koji se stikla
// cAdd - dodatak za string
// lNoSpace - .t. - nema razmaka
// ------------------------------------------------
STATIC FUNCTION __add_to_str( cStr, cAdd, lNoSpace )

   LOCAL cSpace := Space( 1 )

   IF lNoSpace == nil
      lNoSpace := .F.
   ENDIF

   IF Empty( cStr ) .OR. lNoSpace == .T.
      cSpace := ""
   ENDIF

   cStr += cSpace + cAdd

   RETURN



STATIC FUNCTION ispravka_artikla_box( cArt_desc, cArt_full_desc, ;
      cArt_lab_desc, cArt_mcode )

   PRIVATE GetList := {}

   Box(, 6, 70 )

   @ m_x + 1, m_y + 2 SAY "*** pregled/korekcija podataka artikla"

   @ m_x + 3, m_y + 2 SAY "Puni naziv:" GET cArt_full_desc PICT "@S57" VALID !Empty( cArt_full_desc )
   @ m_x + 4, m_y + 2 SAY "Skr. naziv:" GET cArt_desc PICT "@S57" VALID !Empty( cArt_desc )
   @ m_x + 5, m_y + 2 SAY "Lab. tekst:" GET cArt_lab_desc PICT "@S57"

   @ m_x + 6, m_y + 2 SAY "Match code:" GET cArt_mcode

   READ

   BoxC()

   ESC_RETURN 1

   RETURN 1



// ------------------------------------------------
// napuni matricu aElem sa elementima artikla
// aElem - matrica sa elementima
// nArt_id - id artikla
//
// aElem = { el_id, tip, naz, mc, e_gr_at_id, e_gr_vl_id }
// ------------------------------------------------
FUNCTION _fill_a_articles( aElem, nArt_id )

   LOCAL nTArea := Select()
   LOCAL cArt_desc := ""
   LOCAL cArt_mc := ""

   aElem := {}

   // artikli
   SELECT articles
   SET ORDER TO TAG "1"
   GO TOP
   SEEK artid_str( nArt_id )

   IF Found()
      cArt_desc := AllTrim( field->art_desc )
      cArt_mc := AllTrim( field->match_code )
   ENDIF

   // elementi
   SELECT elements
   SET ORDER TO TAG "1"
   GO TOP
   SEEK artid_str( nArt_id )

   DO WHILE !Eof() .AND. field->art_id == nArt_id

      nEl_id := field->el_id

      // atributi
      SELECT e_att
      SET ORDER TO TAG "1"
      GO TOP
      SEEK artid_str( nEl_id )

      DO WHILE !Eof() .AND. field->el_id == nEl_id

         AAdd( aElem, { field->el_id, "ATT",  cArt_desc, cArt_mc, field->e_gr_at_id, field->e_gr_vl_id } )
         SKIP

      ENDDO

      // operacije
      SELECT e_aops
      SET ORDER TO TAG "1"
      GO TOP
      SEEK artid_str( nEl_id )

      DO WHILE !Eof() .AND. field->el_id == nEl_id
         AAdd( aElem, { field->el_id, "AOP",  cArt_desc, cArt_mc, field->aop_id, field->aop_att_id } )
         SKIP
      ENDDO

      SELECT elements
      SKIP

   ENDDO

   SELECT ( nTArea )

   RETURN



// ------------------------------------------------
// napuni matricu aElem cisto sa elementima artikla
// aElem - matrica sa elementima
// nArt_id - id artikla
//
// aElem = { el_id, grupa }
// ------------------------------------------------
FUNCTION _g_art_elements( aElem, nArt_id )

   LOCAL nTArea := Select()
   LOCAL cPom := ""
   LOCAL nCnt := 0

   aElem := {}

   // elementi
   SELECT elements
   SET ORDER TO TAG "1"
   GO TOP
   SEEK elid_str( nArt_id )

   DO WHILE !Eof() .AND. field->art_id == nArt_id

      ++ nCnt

      cPom := g_e_gr_desc( field->e_gr_id )
      cPom += " "
      cPom += get_el_desc( field->el_id )

      AAdd( aElem, { field->el_id, cPom, nCnt } )

      SKIP

   ENDDO

   SELECT ( nTArea )

   RETURN



// -------------------------------------
// get element description
// -------------------------------------
STATIC FUNCTION get_el_desc( nEl_id )

   LOCAL xRet := ""
   LOCAL nTArea := Select()

   SELECT e_att
   SET ORDER TO TAG "1"
   GO TOP
   SEEK elid_str( nEl_id )

   DO WHILE !Eof() .AND. field->el_id == nEl_id

      xRet += AllTrim(  g_e_gr_vl_desc( field->e_gr_vl_id ) ) + " "

      SKIP
   ENDDO

   SELECT ( nTArea )

   RETURN xRet


// ---------------------------------------
// vraca broj elementa artikla
// ---------------------------------------
FUNCTION _g_elem_no( aElem, nDoc_el_no, nElem_no )

   LOCAL nTmp

   nTmp := AScan( aElem, {| xVal| xVal[ 1 ] == nDoc_el_no } )

   IF nTmp > Len( aElem ) .OR. nTmp == 0
      nElem_no := 0
   ELSE
      nElem_no := aElem[ nTmp, 3 ]
   ENDIF

   RETURN


// ---------------------------------------------------
// provjerava ispravnost artikla
// ---------------------------------------------------
FUNCTION check_article_valid( art_id )

   LOCAL _t_area := Select()
   LOCAL _valid := .T.
   LOCAL _elem := {}

   // razlozi artikal na elemente
   rnal_setuj_naziv_artikla( art_id, nil, nil, @_elem, .T. )

   IF Len( _elem ) == 0
      MsgBeep( "Artikal nema pripadajuce elemente !!!" )
      _valid := .F.
   ENDIF

   SELECT ( _t_area )

   RETURN _valid




// ---------------------------------------------------
// prikaz artikala bez elemenata...
// ---------------------------------------------------
FUNCTION rpt_artikli_bez_elemenata()

   LOCAL _elem, _art_id
   LOCAL _error := {}
   LOCAL _count

   // otvori mi sifrarnike
   rnal_o_sif_tables()

   SELECT articles
   GO TOP

   Box(, 1, 50 )

   DO WHILE !Eof()

      _elem := {}
      _art_id := field->art_id

      @ m_x + 1, m_y + 2 SAY "Artikal: " + AllTrim( Str ( _art_id ) )

      // razlozi artikal na elemente
      rnal_setuj_naziv_artikla( _art_id, nil, nil, @_elem, .T. )

      SELECT articles

      IF Len( _elem ) == 0
         // ovaj nema ...
         AAdd( _error, { field->art_id, field->art_desc } )
      ENDIF

      SKIP

   ENDDO

   BoxC()

   my_close_all_dbf()

   IF Len( _error ) == 0
      RETURN
   ENDIF

   START PRINT CRET

   ?

   ? "Lista artikala bez elemenata..."
   ? Replicate( "-", 70 )
   ? "R.br  Artikal / Opis"
   ? Replicate( "-", 70 )

   _count := 0

   FOR _i := 1 TO Len( _error )
      ? PadL( AllTrim( Str( ++_count ) ), 4 ) + ".", _error[ _i, 1 ], _error[ _i, 2 ]
   NEXT

   FF
   END PRINT

   RETURN
