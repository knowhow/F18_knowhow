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

#include "f18.ch"

MEMVAR ImeKol, Kol

THREAD STATIC __PSIF_NIVO__ := 0
THREAD STATIC __A_SIFV__ := { { NIL, NIL, NIL }, { NIL, NIL, NIL }, { NIL, NIL, NIL }, { NIL, NIL, NIL } }



FUNCTION PostojiSifra( nDbf, nNtx, nVisina, nSirina, cNaslov, cID, dx, dy,  bBlok, aPoredak, bPodvuci, aZabrane, lInvert, aZabIsp )

   LOCAL cRet, cIdBK
   LOCAL hRec
   LOCAL _i
   LOCAL _komande := { "<c-N> Novi", "<F2>  Ispravka", "<ENT> Odabir", _to_str( "<c-T> Briši" ), "<c-P> Print", ;
      "<F4>  Dupliciraj", _to_str( "<c-F9> Briši SVE" ), _to_str( "<c-F> Traži" ), "<a-S> Popuni kol.", ;
      "<a-R> Zamjena vrij.", "<c-A> Cirk.ispravka" }
   LOCAL cUslovSrch :=  ""
   LOCAL cNazSrch
   LOCAL nOrderSif
   LOCAL cSeekRet, lTraziPoNazivu := .F.

   PRIVATE fID_J := .F.

   IF aZabIsp == nil
      aZabIsp := {}
   ENDIF

   FOR _i := 1 TO Len( aZabIsp )
      aZabIsp[ _i ] := Upper( aZabIsp[ _i ] )
   NEXT

   PushWA()
   PushSifV()

   IF lInvert == NIL
      lInvert := .T.
   ENDIF

   SELECT ( nDbf )

   IF Used() .AND. ( rddName() ==  "SQLMIX" )
      PopSifV()
      PopWa( nDbf )
      RETURN p_sifra( nDbf, nNtx, nVisina, nSirina, cNaslov, @cID, dx, dy,  bBlok, aPoredak, bPodvuci, aZabrane, lInvert, aZabIsp )
   ENDIF

   IF !Used()
      AltD()
      hRec := get_a_dbf_rec_by_wa( nDbf )
      IF hRec == NIL
         error_bar( "bug", log_stack( 1 ) )
         RETURN .F.
      ENDIF
      my_use( hRec[ "table" ] )

   ENDIF

   set_mc_imekol( nDbf )

   nOrderSif := IndexOrd()

   sif_set_order( nNTX, index_tag_num( "ID" ), @fID_j )

   cSeekRet := sif_seek( @cId, @cIdBK, @cUslovSrch, @cNazSrch, fId_j, index_tag_num( "ID" ) )
   IF cSeekRet == "naz"
      lTraziPoNazivu := .T.
   ENDIF

   IF dx <> NIL .AND. dx < 0

      IF !Found()
         GO BOTTOM
         SKIP  // id na eof, tamo su prazne vrijednosti
         cRet := &( FieldName( -dx ) )
         SKIP -1
      ELSE
         cRet := &( FieldName( -dx ) )
      ENDIF

      PopSifV()
      PopWa( nDbf )
      RETURN cRet

   ENDIF


   IF ( lTraziPoNazivu .AND. ( cNazSrch == "" .OR. !Trim( cNazSrch ) == Trim( field->naz ) ) ) ;
         .OR. cId == NIL .OR. ( !Found() .AND. cNaslov <> NIL ) .OR. ( cNaslov <> NIL .AND. Left( cNaslov, 1 ) = "#" )

      lPrviPoziv := .T.

      IF Eof()
         SKIP -1
      ENDIF

      IF cId == NIL
         GO TOP
      ENDIF

      my_db_edit(, nVisina, nSirina,  {|| sif_komande( nDbf, cNaslov, bBlok, aZabrane, aZabIsp ) }, cNaslov, "", lInvert, _komande, 1, bPodvuci, , , aPoredak )

      IF Type( "id" ) $ "U#UE"
         cID := ( nDbf )->( FieldGet( 1 ) )
      ELSE

         IF !( nDBf )->( Used() )
            Alert( "not used ?!" )
         ENDIF

         cID := ( nDbf )->id
         IF fID_J
            __A_SIFV__[ __PSIF_NIVO__, 1 ] := ( nDBF )->ID_J
         ENDIF
      ENDIF

   ELSE

      IF fID_J
         cId := ( nDBF )->id
         __A_SIFV__[ __PSIF_NIVO__, 1 ] := ( nDBF )->ID_J
      ENDIF

   ENDIF

   __A_SIFV__[ __PSIF_NIVO__, 2 ] := RecNo()

   sif_ispisi_naziv( nDbf, dx, dy )

   SELECT ( nDbf )

   ordSetFocus( nOrderSif )
   SET FILTER TO

   PopSifV()
   PopWa( nDbf )

   RETURN .T.




STATIC FUNCTION sif_set_order( nNTX, nOrdId, fID_j )

   LOCAL nPos

   DO CASE
   CASE ValType( nNTX ) == "N"

      IF nNTX == 1
         IF index_tag_num( "ID" ) != 0
            SET ORDER TO TAG "ID"
         ELSE
            SET ORDER TO TAG "1"
         ENDIF
      ELSE

         IF index_tag_num( "ID" ) == 0
            SET ORDER TO TAG "2"
         ENDIF
      ENDIF

   CASE ValType( nNTX ) == "C" .AND. Right( Upper( Trim( nNTX ) ), 2 ) == "_J"


      SET ORDER TO tag ( nNTX ) // postavi order na ID_J
      fID_J := .T.

   OTHERWISE

      // IDX varijanta:  TAG_IMEIDXA
      nPos := At( "_", nNTX )
      IF nPos <> 0
         IF Empty( Left( nNtx, nPos - 1 ) )
            dbSetIndex( SubStr( nNTX, nPos + 1 ) )
         ELSE
            SET ORDER TO tag ( Left( nNtx, nPos - 1 ) ) IN ( SubStr( nNTX, nPos + 1 ) )
         ENDIF
      ELSE
         SET ORDER TO tag ( nNtx )
      ENDIF

   END CASE

   RETURN .T.



FUNCTION sif_seek( cId, cIdBK, cUslovSrch, cNazSrch, fId_j )

   LOCAL _bk := ""
   LOCAL _order := IndexOrd()
   LOCAL _tezina := 0

   IF cId == NIL
      RETURN "nil"
   ENDIF

   IF ValType( cId ) == "N"
      SEEK Str( cId )
      RETURN "num"
   ENDIF

   IF Right( Trim( cId ), 1 ) == "*"
      sif_katbr_zvjezdica( @cId, @cIdBK, fId_j )
      RETURN "katbr"
   ENDIF

   IF Right( Trim( cId ), 1 ) $ ".$"
      sifra_na_kraju_ima_tacka_ili_dolar( @cId, @cUslovSrch, @cNazSrch )
      RETURN "naz"
   ENDIF

   SEEK cId

   IF Found()
      cId := &( FieldName( 1 ) )
      RETURN "id"
   ENDIF

   IF Len( cId ) > 10

#ifdef F18_POS
      IF !tezinski_barkod( @cId, @_tezina, .F. )
         barkod( @cId )
      ENDIF
#else
      barkod( @cId )
#endif

      ordSetFocus( _order )

      RETURN "barkod"

   ENDIF

   RETURN "id"


/*

STATIC FUNCTION sif_seek_sql( cId, cIdBK, cUslovSrch, cNazSrch, fId_j, cOrderTag )

   LOCAL _bk := ""
   LOCAL _order := ordName()
   LOCAL _tezina := 0

   IF cId == NIL
      RETURN .F.
   ENDIF

   IF ValType( cId ) == "N"
      SEEK Str( cId )
      RETURN .T.
   ENDIF

   IF Right( Trim( cId ), 1 ) == "*"
      sif_katbr_zvjezdica( @cId, @cIdBK, fId_j )
      RETURN .T.
   ENDIF

   IF Right( Trim( cId ), 1 ) $ ".$"
      RETURN sifra_na_kraju_ima_tacka_ili_dolar( @cId, @cUslovSrch, @cNazSrch )
   ENDIF

   SEEK cId

   IF Found()
      cId := &( FieldName( 1 ) )
      RETURN .T.
   ENDIF

   IF Len( cId ) > 10

#ifdef F18_POS
      IF !tezinski_barkod( @cId, @_tezina, .F. )
         barkod( @cId )
      ENDIF
#else
      barkod( @cId )
#endif

      ordSetFocus( _order )
      RETURN .T.

   ENDIF

   RETURN .T.
*/

STATIC FUNCTION sif_katbr_zvjezdica( cId, cIdBK, fId_j )

   cId := PadR( cId, 10 )

   IF  FieldPos( "KATBR" ) <> 0
      SET ORDER TO TAG "KATBR"
      SEEK Left( cId, Len( Trim( cId ) ) - 1 )
      cId := id
   ELSE
      SEEK Chr( 250 ) + Chr( 250 ) + Chr( 250 )
   ENDIF

   IF !Found()

      // trazi iz sifranika karakteristika
      cIdBK := Left( cId, Len( Trim( cId ) ) -1 )
      cId   := ""

      ImauSifV( "ROBA", "KATB", cIdBK, @cId )

      IF !Empty( cId )

         SELECT roba
         SET ORDER TO TAG "ID"
         // nasao sam sifru !!
         SEEK cId
         cId := Id
         IF fid_j
            cId := ID_J
            SET ORDER TO TAG "ID_J"
            SEEK cId
         ENDIF

      ENDIF
   ENDIF

   RETURN .T.




FUNCTION ID_J( nOffSet )

   IF nOffset = NIL
      nOffset := 1
   ENDIF
   IF __PSIF_NIVO__ + nOffset > 0
      RETURN __A_SIFV__[ __PSIF_NIVO__ + nOffset, 1 ]
   ELSE
      RETURN __A_SIFV__[ 1, 1 ]
   ENDIF

   RETURN .T.


// -------------------------------------------
// setuje match_code imekol {}
// -------------------------------------------
FUNCTION set_mc_imekol( nDBF )

   LOCAL nSeek
   LOCAL bPom

   cFldId := "ID"
   cFldMatchCode := "MATCH_CODE"

   IF ( nDBF == F_SIFK ) .OR. ( nDBF == F_SIFV ) .OR. ( nDBF == F_OPS )
      RETURN .T.
   ENDIF

   // ako nema polja match code ... nista...
   IF ( nDBF )->( FieldPos( cFldMatchCode ) ) == 0
      RETURN
   ENDIF

   nSeek := AScan( ImeKol, {| xEditFieldNaz| Upper( xEditFieldNaz[ 3 ] ) == "ID" } )

   // setuj prikaz polja
   IF nSeek > 0

      bPom := {|| ;
         PadR( AllTrim( &cFldID ) +  iif( !Empty( &cFldMatchCode ), ;
         iif( Len( AllTrim( &cFldMatchCode ) ) > 4, ;
         "/" + Left( AllTrim( &cFldMatchCode ), 2 ) + "..", ;
         "/" + Left( AllTrim( &cFldMatchCode ), 4 ) ), ;
         "" ), ;
         Len( &cFldID ) + 5 ) ;
         }

      ImeKol[ nSeek, 1 ] := "ID/MC"
      ImeKol[ nSeek, 2 ] := bPom


   ENDIF

   RETURN .T.


FUNCTION SIF_TEKREC( cDBF, nOffset )

   LOCAL xVal
   LOCAL nArr

   IF nOffset = NIL
      nOffset := 1
   ENDIF
   IF __PSIF_NIVO__ + nOffset > 0
      xVal := __A_SIFV__[ __PSIF_NIVO__ + nOffset, 2 ]
   ELSE
      xVal := __A_SIFV__[ 1, 2 ]
   ENDIF

   IF cDBF <> NIL
      nArr := Select()
      SELECT ( cDBF )
      GO xVal
      SELECT ( nArr )
   ENDIF

   RETURN xVal



STATIC FUNCTION PushSifV()

   __PSIF_NIVO__ ++
   IF __PSIF_NIVO__ > Len( __A_SIFV__ )
      AAdd( __A_SIFV__, { "", 0, 0 } )
   ENDIF

   RETURN .T.


STATIC FUNCTION PopSifV()

   --__PSIF_NIVO__

   RETURN .T.



STATIC FUNCTION sif_komande( nDbf, cNaslov, bBlok, aZabrane, aZabIsp )

   LOCAL i
   LOCAL j
   LOCAL imin
   LOCAL imax
   LOCAL nGet
   LOCAL nRet
   LOCAL nOrder
   LOCAL nLen
   LOCAL nRed
   LOCAL nKolona
   LOCAL nTekRed
   LOCAL nTrebaRedova
   LOCAL cUslovSrch
   LOCAL lNovi
   PRIVATE cPom
   PRIVATE aQQ
   PRIVATE aUsl
   PRIVATE aStruct

   IF aZabrane = nil
      aZabrane := {}
   ENDIF

   IF aZabIsp = nil
      aZabIsp := {}
   ENDIF

   Ch := LastKey()

   aStruct := dbStruct()
   SkratiAZaD ( @aStruct )
   FOR i := 1 TO Len( aStruct )
      cImeP := aStruct[ i, 1 ]
      cVar := "w" + cImeP
      PRIVATE &cVar := &cImeP
   NEXT

   nOrder := IndexOrd()
   nRet := -1
   lZabIsp := .F.

   IF bBlok <> NIL
      nRet := Eval( bBlok, Ch )
      IF nret > 4
         IF nRet == 5
            RETURN DE_ABORT
         ELSEIF nRet == 6
            RETURN DE_CONT
         ELSEIF nRet == 7
            RETURN DE_REFRESH
         ELSEIF nRet == 99 .AND. Len( aZabIsp ) > 0
            lZabIsp := .T.
            nRet := -1
         ENDIF
      ENDIF
   ENDIF

   IF AScan( aZabrane, Ch ) <> 0
      MsgBeep( "Nivo rada:" + klevel + " : Opcija nedostupna !" )
      RETURN DE_CONT
   ENDIF


   DO CASE

   CASE Ch == K_ENTER

#ifdef F18_DEBUG_BROWSE_SIF
      AltD() // F18_DEBUG_BROWSE_SIF
#endif

      IF gMeniSif
         RETURN DE_CONT
      ELSE
         lPrviPoziv := .F.
         RETURN DE_ABORT
      ENDIF

   CASE Upper( Chr( Ch ) ) == "F"

      IF m_code_src() == 0
         RETURN DE_CONT
      ELSE
         RETURN DE_REFRESH
      ENDIF

   CASE ( Ch == K_CTRL_N .OR. Ch == K_F4 )

      Tb:RefreshCurrent()

      IF browse_edit_stavka( Ch, nOrder, aZabIsp, .T. ) == 1
         RETURN DE_REFRESH
      ENDIF

      RETURN DE_CONT

   CASE ( Ch == K_F2 .OR. Ch == K_CTRL_A )

      Tb:RefreshCurrent()

      IF browse_edit_stavka( Ch, nOrder, aZabIsp, .F. ) == 1
         RETURN DE_REFRESH
      ENDIF

      RETURN DE_CONT

   CASE Ch == K_CTRL_P

      PushWA()
      IzborP2( Kol, PRIVPATH + Alias() )
      IF LastKey() == K_ESC
         RETURN DE_CONT
      ENDIF

      print_lista( "Pregled: " + AllTrim( cNaslov ) + " na dan " + DToC( Date() ) + " g.", "sifarnik" )
      PopWa()

      RETURN DE_CONT

   CASE Ch == K_ALT_F
      uslovsif()
      RETURN DE_REFRESH

   CASE Ch == K_CTRL_F6

      Box( , 1, 30 )
      PUBLIC gIdFilter := Eval( ImeKol[ TB:ColPos, 2 ] )
      @ m_x + 1, m_y + 2 SAY "Filter :" GET gidfilter
      READ
      BoxC()

      IF Empty( gidfilter )
         SET FILTER TO
      ELSE
         SET FILTER TO Eval( ImeKol[ TB:ColPos, 2 ] ) == gidfilter
         GO TOP
      ENDIF
      RETURN DE_REFRESH

   CASE Ch == K_CTRL_T
      RETURN sifarnik_brisi_stavku()

   CASE Ch == K_CTRL_F9
      RETURN sifarnik_brisi_sve()

   CASE Ch == K_F10
      SifPopup( nOrder )
      RETURN DE_CONT

   OTHERWISE
      IF nRet >- 1
         RETURN nRet
      ELSE
         RETURN DE_CONT
      ENDIF

   ENDCASE

   RETURN .T.


FUNCTION browse_edit_stavka( Ch, nOrder, aZabIsp, lNovi )

   LOCAL i
   LOCAL j
   LOCAL _alias
   LOCAL _jg
   LOCAL imin
   LOCAL imax
   LOCAL nGet
   LOCAL nRet
   LOCAL nLen
   LOCAL nRed
   LOCAL nKolona
   LOCAL nTekRed
   LOCAL nTrebaRedova
   LOCAL oTable
   LOCAL nPrevRecNo
   LOCAL cMCField
   LOCAL nMCScan
   LOCAL _vars
   LOCAL cTekuciZapis

   PRIVATE nXP
   PRIVATE nYP
   PRIVATE cPom
   PRIVATE aQQ
   PRIVATE aUsl
   PRIVATE aStruct

   nPrevRecNo := RecNo()

   cTekuciZapis := vrati_vrijednosti_polja_sifarnika_u_string( "w" )

   add_match_code( @ImeKol, @Kol )

   __A_SIFV__[ __PSIF_NIVO__, 3 ] :=  Ch

   IF Ch == K_CTRL_N .OR. Ch == K_F2

      IF index_tag_num( "ID" ) != 0
         SET ORDER TO TAG "ID"
      ELSE
         SET ORDER TO TAG "1"
      ENDIF
      GO ( nPrevRecNo )

   ENDIF

   IF Ch == K_CTRL_N
      lNovi := .T.
      GO BOTTOM
      SKIP 1
   ENDIF

   IF Ch == K_F4
      lNovi := .T.
   ENDIF

   DO WHILE .T.

      SetSifVars()

      IF Ch == K_CTRL_N
         sifarnik_set_roba_defaults()
      ENDIF

      nTrebaredova := Len( ImeKol )

      FOR i := 1 TO Len( ImeKol )
         IF Len( ImeKol[ i ] ) >= 10 .AND. Imekol[ i, 10 ] <> NIL
            nTrebaRedova--
         ENDIF
      NEXT

      i := 1
      FOR _jg := 1 TO 3  // glavna petlja

         IF _jg == 1
            Box( NIL, Min( MAXROWS() -7, nTrebaRedova ) + 1, MAXCOLS() -20, .F. )
         ELSE
            BoxCLS()
         ENDIF

         SET CURSOR ON
         PRIVATE Getlist := {}

         nGet := 1
         nNestampati := 0

         nTekRed := 1

         DO WHILE .T.

            lShowPGroup := .F.

            IF Empty( ImeKol[ i, 3 ] )
               cPom := ""
            ELSE
               cPom := set_w_var( ImeKol, i, @lShowPGroup )
            ENDIF

            cPic := ""

            IF !Empty( cPom )
               sif_dbf_getlist( cPom, @GetList,  lZabIsp, aZabIsp, lShowPGroup, Ch, @nGet, @i, @nTekRed )
               nGet++
            ELSE
               nRed := 1
               nKolona := 1
               IF Len( ImeKol[ i ] ) >= 10 .AND. Imekol[ i, 10 ] <> NIL
                  nKolona := imekol[ i, 10 ]
                  nRed := 0
               ENDIF

               IF Eval( ImeKol[ i, 2 ] ) <> NIL .AND. ToStr( Eval( ImeKol[ i, 2 ] ) ) <> "_?_"
                  IF nKolona = 1
                     ++nTekRed
                  ENDIF
                  @ m_x + nTekRed, m_y + nKolona SAY PadL( AllTrim( ImeKol[ i, 1 ] ), 15 )
                  @ m_x + nTekRed, Col() + 1 SAY Eval( ImeKol[ i, 2 ] )
               ELSE
                  ++nNestampati
               ENDIF

            ENDIF

            i++

            IF ( Len( imeKol ) < i ) .OR. ( nTekRed > Min( MAXROWS() -7, nTrebaRedova ) .AND. !( Len( ImeKol[ i ] ) >= 10 .AND. imekol[ i, 10 ] <> NIL )  )
               EXIT
            ENDIF
         ENDDO

         SET KEY K_F8 TO k_f8_nadji_novu_sifru()
         SET KEY K_F9 TO n_num_sif()
         SET KEY K_F5 TO k_f5_nadji_novu_sifru()

         READ

         SET KEY K_F8 TO
         SET KEY K_F9 TO
         SET KEY K_F5 TO

         IF ( Len( imeKol ) < i )
            EXIT
         ENDIF

      NEXT

      BoxC()

      IF Ch <> K_CTRL_A
         EXIT
      ELSE

         IF LastKey() == K_ESC
            EXIT
         ENDIF

         IF !snimi_promjene_cirkularne_ispravke_sifarnika()
            EXIT
         ENDIF

         IF LastKey() == K_PGUP
            SKIP -1
         ELSE
            SKIP
         ENDIF

         IF Eof()
            SKIP -1
            EXIT
         ENDIF

      ENDIF

   ENDDO

   IF Ch == K_CTRL_N .OR. Ch == K_F2
      ordSetFocus( nOrder )
   ENDIF

   IF LastKey() == K_ESC
      IF lNovi
         GO ( nPrevRecNo )
      ENDIF
      RETURN 0
   ENDIF

   snimi_promjene_sifarnika( lNovi, cTekuciZapis )

   IF Ch == K_F4 .AND. Pitanje( , "Vrati se na predhodni zapis (D/N) ?", "D" ) == "D"
      GO ( nPrevRecNo )
   ENDIF

   RETURN 1



STATIC FUNCTION set_w_var( ImeKol, _i, show_grup )

   LOCAL _tmp, _var_name


   IF Left( ImeKol[ _i, 3 ], 6 ) != "SIFK->"

      _var_name := "w" + ImeKol[ _i, 3 ]
      // npr WVPC2
      // ako provjerimo strukturu, onda mozemo vidjeti da trebamo uzeti
      // varijablu karakteristike("ROBA","V2")

   ELSE
      // ako je SIFK->GRUP, prikazuj status
      IF Alias() == "PARTN" .AND. Right( ImeKol[ _i, 3 ], 4 ) == "GRUP"
         show_grup := .T.
      ENDIF

      _var_name := "wSifk_" + SubStr( ImeKol[ _i, 3 ], 7 )

      _tmp := IzSifk( Alias(), SubStr( ImeKol[ _i, 3 ], 7 ) )

      IF _tmp == NIL
         // ne koristi se !!!
         _var_name := ""
      ELSE
         __mvPublic( _var_name )
         Eval( MemVarBlock( _var_name ), _tmp )
      ENDIF

   ENDIF

   RETURN _var_name



FUNCTION sif_dbf_getlist( var_name, GetList, lZabIsp, aZabIsp, lShowGrup, Ch, nGet, i, nTekRed )

   LOCAL bWhen, bValid, cPic
   LOCAL nRed, nKolona
   LOCAL cWhenSifk, cValidSifk
   LOCAL _when_block, _valid_block
   LOCAL _m_block := MemVarBlock( var_name )

   // uzmi when, valid kodne blokove
   IF ( Ch == K_F2 .AND. lZabIsp .AND. AScan( aZabIsp, Upper( ImeKol[ i, 3 ] ) ) > 0 )
      bWhen := {|| .F. }
   ELSEIF ( Len( ImeKol[ i ] ) < 4 .OR. ImeKol[ i, 4 ] == nil )
      bWhen := {|| .T. }
   ELSE
      bWhen := Imekol[ i, 4 ]
   ENDIF

   IF ( Len( ImeKol[ i ] ) < 5 .OR. ImeKol[ i, 5 ] == nil )
      bValid := {|| .T. }
   ELSE
      bValid := Imekol[ i, 5 ]
   ENDIF

   _m_block := MemVarBlock( var_name )

   IF _m_block == NIL
      MsgBeep( "var_name nedefinisana :" + var_name )
   ENDIF

   IF Len( ToStr( Eval( _m_block ) ) ) > 50
      cPic := "@S50"
      @ m_x + nTekRed + 1, m_y + 67 SAY Chr( 16 )

   ELSEIF Len( ImeKol[ i ] ) >= 7 .AND. ImeKol[ i, 7 ] <> NIL
      cPic := ImeKol[ i, 7 ]
   ELSE
      cPic := ""
   ENDIF

   nRed := 1
   nKolona := 1

   IF Len( ImeKol[ i ] ) >= 10 .AND. Imekol[ i, 10 ] <> NIL
      nKolona := ImeKol[ i, 10 ] + 1
      nRed := 0
   ENDIF

   IF nKolona == 1
      nTekRed ++
   ENDIF

   IF lShowPGroup
      nXP := nTekRed
      nYP := nKolona
   ENDIF

   // stampaj grupu za stavku "GRUP"
   IF lShowPGroup
      p_gr( &var_name, m_x + nXP, m_y + nYP + 1 )
   ENDIF

   IF "wSifk_" $ var_name
      // uzmi when valid iz SIFK

      IzSifKWV( Alias(), SubStr( var_name, 7 ), @cWhenSifk, @cValidSifk )

      IF !Empty( cWhenSifk )
         _when_block := & ( "{|| " + cWhenSifk + "}" )
      ELSE
         _when_block := bWhen
      ENDIF

      IF !Empty( cValidSifk )
         _valid_block := & ( "{|| " + cValidSifk + "}" )
      ELSE
         _valid_block := bValid
      ENDIF
   ELSE
      _when_block := bWhen
      _valid_block := bValid
   ENDIF

   @ m_x + nTekRed, m_y + nKolona SAY  iif( nKolona > 1, "  " + AllTrim( ImeKol[ i, 1 ] ), PadL( AllTrim( ImeKol[ i, 1 ] ), 15 ) )  + " "

   AAdd( GetList, _GET_( &var_name, var_name,  cPic, _valid_block, _when_block ) ) ;;

      ATail( GetList ):display()

   RETURN .T.



STATIC FUNCTION add_match_code( ImeKol, Kol )

   LOCAL  _pos, cMCField := Alias()

   // dodaj u matricu match_code ako ne postoji
   IF ( cMCField )->( FieldPos( "MATCH_CODE" ) ) <> 0

      _pos := AScan( ImeKol, {| xImeKol| Upper( xImeKol[ 3 ] ) == "MATCH_CODE" } )

      // ako ne postoji dodaj ga...
      IF _pos == 0
         // dodaj polje u ImeKol
         AAdd( ImeKol, { "MATCH_CODE", {|| match_code }, "match_code" } )
         // dodaj novu stavku u kol
         AAdd( Kol, Len( ImeKol ) )
      ENDIF

   ENDIF

FUNCTION SetSifVars()

   LOCAL _i, _struct
   PRIVATE cImeP
   PRIVATE cVar

   _struct := dbStruct()

   SkratiAZaD( @_struct )

   FOR _i := 1 TO Len( _struct )
      cImeP := _struct[ _i, 1 ]
      cVar := "w" + cImeP

      &cVar := &cImeP
   NEXT

   RETURN .T.



FUNCTION SifPopup( nOrder )

   PRIVATE Opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor

   AAdd( Opc, "1. novi                  " )
   AAdd( opcexe, {|| browse_edit_stavka( K_CTRL_N, nOrder, NIL, .T. ) } )
   AAdd( Opc, "2. edit  " )
   AAdd( opcexe, {|| browse_edit_stavka( K_F2, nOrder, NIL, .F. ) } )
   AAdd( Opc, "3. dupliciraj  " )
   AAdd( opcexe, {|| browse_edit_stavka( K_F4, nOrder, NIL, .T. ) } )
   AAdd( Opc, "4. <a+R> za sifk polja  " )
   AAdd( opcexe, {|| repl_sifk_item() } )
   AAdd( Opc, "5. copy polje -> sifk polje  " )
   AAdd( opcexe, {|| copy_to_sifk() } )

   Izbor := 1
   Menu_Sc( "bsif" )

   RETURN 0


// -------------------------------------------------------------------
// @function   Fill_IDJ
// @abstract   Koristi se za punjenje sifre ID_J sa zadatim stringom
// @discussion fja koja punjeni polje ID_J tako sto ce se uglavnom definisati
// kao validacioni string u sifrarniku Sifk
// Primjer:
// - Zelim da napunim sifru po prinicpu ( GR1 + GR2 + GR3 + sekvencijalni dio)
// - Zadajem sljedeci kWhenBlok:
// When: FILL_IDJ( WSIFK_GR1 + WSIFK_GR2 + WSIFK_GR3)
// @param      cStr  zadati string
// --------------------------------------------------------------------
FUNCTION Fill_IDJ( cSTR )

   LOCAL nTrec, cPoz

   PushWA()


   nTrec := RecNo()
   SET ORDER TO TAG "ID_J"
   SEEK cStr + Chr( 246 )
   SKIP -1
   // ova fja se uvijek poziva nakon sif_komande
   // ako je __LAST_CH__=f4 onda se radi o dupliciranju

   IF ( __A_SIFV__[ __PSIF_NIVO__, 3 ] == K_F4 ) .OR. ;
         ( RecNo() <> nTrec .AND. ( Left( wId_J, Len( cStr ) ) != cStr ) )
      // ne mjenjam samog sebe
      IF  Right( AllTrim( wNAZ ), 3 ) == "..."
         // naziv je u formi "KATEGORIJA ARTIKALA.........."
         cPoz :=  Replicate ( ".", Len( ID_J ) -Len( cStr ) )
      ELSEIF ( Left( ID_J, Len( cStr ) ) = cStr ) .AND. ( SubStr( ID_J, Len( cstr ) + 1, 1 ) <> "." )
         // GUMEPODA01
         // Len(id_j) - len( cStr )  = 10 - 8 = 2
         cPoz :=  PadL ( AllTrim( Str( Val ( SubStr( ID_J, Len( cstr ) + 1 ) ) + 1 ) ), Len( ID_J ) - Len( cStr ), "0" )
      ELSE
         cPoz :=  PadL ( "1", Len( ID_J ) -Len( cStr ), "0" )
      ENDIF

      GO nTrec
      // replace ID_J with   ( cStr +  cPoz)
      wID_J :=  ( cStr +  cPoz )
   ENDIF
   PopWa()

   RETURN .T.


// prikaz idroba
// nalazim se u tabeli koja sadrzi IDROBA, IDROBA_J
FUNCTION StIdROBA()

   STATIC cPrikIdRoba := ""

   IF cPrikIdroba == ""
      cPrikIdRoba := 'ID'
   ENDIF

   IF cPrikIdRoba = "ID_J"
      RETURN IDROBA_J
   ELSE
      RETURN IDROBA
   ENDIF

FUNCTION aTacno( aUsl )

   LOCAL i

   FOR i = 1 TO Len( aUsl )
      IF !( Tacno( aUsl[ i ] ) )
         RETURN .F.
      ENDIF
   NEXT

   RETURN .T.



FUNCTION n_num_sif()

   LOCAL cFilter := "val(id) <> 0"
   LOCAL i
   LOCAL nLId
   LOCAL lCheck
   LOCAL lLoop

   // ime polja : "wid"
   PRIVATE cImeVar := ReadVar()
   // vrijednost unjeta u polje
   cPom := &( cImeVar )

   IF cImeVar == "WID"

      PushWA()

      nDuzSif := Len( cPom )


      SET FILTER to &cFilter // postavi filter na numericke sifre

      // kreiraj indeks
      INDEX ON Val( id ) TAG "_VAL"

      GO BOTTOM

      // zapis
      nTRec := RecNo()
      nLast := nTRec

      // sifra kao uzorak
      nLId := Val( ID )
      lCheck := .F.

      DO WHILE lCheck = .F.

         lLoop := .F.
         // ispitaj prekid sifri
         FOR i := 1 TO 10

            SKIP -1

            IF nLId = Val( field->id )
               // ako je zadnja sifra ista kao i prethodna
               // idi na sljedecu
               // ili idi na zadnju sifru
               nTRec := nLast
               lLoop := .T.
               EXIT
            ENDIF

            IF nLId - Val( field->id ) <> i
               // ima prekid
               // idi, ponovo...
               nLID := Val( field->id )
               nTRec := RecNo()
               lCheck := .F.
               lLoop := .F.
               EXIT
            ELSE
               lLoop := .T.
            ENDIF

         NEXT

         IF lLoop = .T.
            lCheck := .T.
         ENDIF

      ENDDO

      GO ( nTREC )

      &( cImeVar ) := PadR( NovaSifra( IF( Empty( id ), id, RTrim( id ) ) ), nDuzSif, " " )

      SET FILTER TO

      IF index_tag_num( "ID" ) != 0
         SET ORDER TO TAG "ID"
      ELSE
         SET ORDER TO TAG "1"
      ENDIF

      GO TOP

   ENDIF

   AEval( GetList, {| o| o:display() } )
   PopWA()

   RETURN NIL


// ----------------------------------------------------
// nadji novu sifru - radi na pritisak F8 pri unosu
// nove sifre
// ----------------------------------------------------
FUNCTION k_f8_nadji_novu_sifru()

   LOCAL cPom
   LOCAL nDuzSif := 0
   LOCAL lPopuni := .F.
   LOCAL nDuzUn := 0
   LOCAL cLast := Chr( 252 ) + Chr( 253 )
   LOCAL nKor := 0

   IF my_get_from_ini( "NovaSifraOpc_F8", "PopunjavaPraznine", "N" ) == "D"
      lPopuni := .T.
   ENDIF

   // ime polja
   PRIVATE cImeVar := ReadVar()
   // vrijednost unjeta u polje
   cPom := &( cImeVar )

   IF cImeVar == "WID"

      nDuzSif := Len( cPom )
      nDuzUn := Len( Trim( cPom ) )
      cPom := PadR( RTrim( cPom ), nDuzSif, "Z" )

      PushWA()

      IF index_tag_num( "ID" ) != 0
         SET ORDER TO TAG "ID"
      ELSE
         SET ORDER TO TAG "1"
      ENDIF

      GO TOP
      IF lPopuni
         SEEK Left( cPom, nDuzUn )
         DO WHILE !Eof() .AND. Left( cPom, 2 ) = Left( id, 2 )
            // preskoci stavke opisa grupe artikala
            IF Len( Trim( id ) ) <= nDuzUn .OR. Right( Trim( id ), 1 ) == "."
               SKIP 1
            ENDIF
            IF cLast == "¬¦æÑ" // tj. prva konkretna u nizu
               IF Val( SubStr( id, nDuzUn + 1 ) ) > 1
                  // rupa odmah na poetku
                  nKor := nDuzSif - Len( Trim( id ) )
                  EXIT
               ENDIF
            ELSEIF Val( SubStr( id, nDuzUn + 1 ) ) -Val( cLast ) > 1
               // rupa izmeÐu
               EXIT
            ENDIF
            cLast := SubStr( id, nDuzUn + 1 )
            SKIP 1
         ENDDO
         // na osnovu cLast formiram slijedeu çifru
         cPom := Left( cPom, nDuzUn ) + IF( cLast == "¬¦æÑ", REPL( "0", nDuzSif - nDuzUn - nKor ), cLast )
         &( cImeVar ) := PadR( NovaSifra( IF( Empty( cPom ), cPom, RTrim( cPom ) ) ), nDuzSif, " " )
      ELSE

         SEEK cPom
         SKIP -1
         &( cImeVar ) := PadR( NovaSifra( IF( Empty( id ), id, RTrim( id ) ) ), nDuzSif, " " )

      ENDIF

      AEval( GetList, {| o| o:display() } )
      PopWA()
   ENDIF

   RETURN ( NIL )


/*
   Opis: ovo je wrapper funkcija koja koristi funkciju sifra_postoji()
*/

FUNCTION VpSifra( wId, cTag )
   RETURN sifra_postoji( wId, cTag )




/* VpNaziv(wNaziv)
 *     Stroga kontrola naziva sifre pri unosu nove ili ispravci postojece sifre
 *   param: wNaziv - Naziv koji se provjerava
 */

FUNCTION VpNaziv( wNaziv )

   LOCAL nRec := RecNo()
   LOCAL nRet := .T.
   LOCAL cId
   LOCAL cUpozorenje := "Ovaj naziv se vec nalazi u sifri:   "

   SET ORDER TO TAG "naz"
   HSeek wNaziv
   cId := roba->id

   IF ( Found() .AND. Ch == K_CTRL_N )
      MsgBeep( cUpozorenje + AllTrim( cId ) + " !!!" )
      nRet := .F.
   ELSEIF ( gSKSif == "D" .AND. Found() )
      IF nRec <> RecNo()
         MsgBeep( cUpozorenje + AllTrim( cId ) + " !!!" )
         nRet := .F.
      ELSE

         SKIP 1 // bio isti zapis, idi na drugi
         IF !Eof() .AND. wNaziv == naz
            MsgBeep( cUpozorenje + AllTrim( cId ) + " !!!" )
            nRet := .F.
         ENDIF
      ENDIF
   ENDIF

   SET ORDER TO TAG "ID"
   GO nRec

   RETURN nRet


FUNCTION ImaSlovo( cSlova, cString )

   LOCAL i

   FOR i := 1 TO Len( cSlova )
      IF SubStr( cSlova, i, 1 )  $ cString
         RETURN .T.
      ENDIF
   NEXT

   RETURN .F.



FUNCTION UslovSif()

   LOCAL aStruct := dbStruct()

   SkratiAZaD( @aStruct )

   Box( "", iif( Len( aStruct ) > 22, 22, Len( aStruct ) ), 67, .F., "", "Postavi kriterije za pretrazivanje" )

   PRIVATE Getlist := {}

   //
   // postavljanje uslova
   //
   aQQ := {}
   aUsl := {}

   IF "U" $ Type( "aDefSpremBaz" )
      aDefSpremBaz := NIL
   ENDIF

   IF aDefSpremBaz != NIL .AND. !Empty( aDefSpremBaz )
      FOR i := 1 TO Len( aDefSpremBaz )
         aDefSpremBaz[ i, 4 ] := ""
      NEXT
   ENDIF

   SET CURSOR ON

   FOR i := 1 TO Len( aStruct )
      IF i == 23
         @ m_x + 1, m_y + 1 CLEAR TO m_x + 22, m_y + 67
      ENDIF
      AAdd( aQQ, Space( 100 ) )
      AAdd( aUsl, NIL )
      @ m_x + IF( i > 22, i - 22, i ), m_y + 67 SAY Chr( 16 )
      @ m_x + IF( i > 22, i - 22, i ), m_y + 1 SAY PadL( AllTrim( aStruct[ i, 1 ] ), 15 ) GET aQQ[ i ] PICTURE "@S50" ;
         valid {|| aUsl[ i ] := Parsiraj( aQQ[ i ] := _fix_usl( aQQ[ i ] ), aStruct[ i, 1 ], iif( aStruct[ i, 2 ] == "M", "C", aStruct[ i, 2 ] ) ), aUsl[ i ] <> NIL  }
      READ
      IF LastKey() == K_ESC
         EXIT
      ELSE
         IF aDefSpremBaz != NIL .AND. !Empty( aDefSpremBaz ) .AND. aUsl[ i ] <> NIL .AND. ;
               aUsl[ i ] <> ".t."
            FOR j := 1 TO Len( aDefSpremBaz )
               IF Upper( aDefSpremBaz[ j, 2 ] ) == Upper( aStruct[ i, 1 ] )
                  aDefSpremBaz[ j, 4 ] := aDefSpremBaz[ j, 4 ] + ;
                     IF( !Empty( aDefSpremBaz[ j, 4 ] ), ".and.", "" ) + ;
                     IF( Upper( aDefSpremBaz[ j, 2 ] ) == Upper( aDefSpremBaz[ j, 3 ] ), aUsl[ i ], ;
                     Parsiraj( aQQ[ i ] := _fix_usl( aQQ[ i ] ), aDefSpremBaz[ j, 3 ], iif( aStruct[ i, 2 ] == "M", "C", aStruct[ i, 2 ] ) ) )
               ENDIF
            NEXT
         ENDIF
      ENDIF
   NEXT
   READ
   BoxC()
   IF LastKey() == K_ESC; RETURN DE_CONT; ENDIF
   aOKol := AClone( Kol )

   PRIVATE cFilter := ".t."
   FOR i := 1 TO Len( aUsl )
      IF ausl[ i ] <> NIL .AND. aUsl[ i ] <> ".t."
         cFilter += ".and." + aUsl[ i ]
      ENDIF
   NEXT
   IF cFilter == ".t."
      SET FILTER TO
   ELSE
      IF Left( cFilter, 8 ) == ".t..and."
         cFilter := SubStr( cFilter, 9 )
         SET FILTER to &cFilter
      ENDIF
   ENDIF
   GO TOP

   RETURN NIL

// -------------------------------------------
// sredi uslov ako nije postavljeno ; na kraj
// -------------------------------------------
STATIC FUNCTION _fix_usl( xUsl )

   LOCAL nLenUsl := Len( xUsl )
   LOCAL xRet := Space( nLenUsl )

   IF Empty( xUsl )
      RETURN xUsl
   ENDIF

   IF Right( AllTrim( xUsl ), 1 ) <> ";"
      xRet := PadR( AllTrim( xUsl ) + ";", nLENUSL )
   ELSE
      xRet := xUsl
   ENDIF

   RETURN xRet



FUNCTION P_Sifk( cId, dx, dy )

   LOCAL i
   PRIVATE imekol, kol

   Kol := {}
   O_SIFK
   O_SIFV
   ImeKol := { { PadR( "Id", 15 ),      {|| ToStrU( id ) }, "id"  }, ;
      { PadR( "Naz", 25 ),     {|| ToStrU( naz ) }, "naz" }, ;
      { PadR( "Sort", 4 ),     {|| sort }, "sort" }, ;
      { PadR( "Oznaka", 4 ),   {|| ToStrU( oznaka ) }, "oznaka" }, ;
      { PadR( "Veza", 4 ),     {|| veza }, "veza" }, ;
      { PadR( "Izvor", 15 ),   {|| izvor }, "izvor" }, ;
      { PadR( "Uslov", 30 ),   {|| PadR( uslov, 30 ) }, "uslov" }, ;
      { PadR( "Tip", 3 ),      {|| tip }, "tip" }, ;
      { PadR( "Unique", 3 ),   {|| f_unique }, "f_unique", NIL, NIL, NIL, NIL, NIL, NIL, 20 }, ;
      { PadR( "Duz", 3 ),      {|| duzina }, "duzina" }, ;
      { PadR( "Dec", 3 ),      {|| f_decimal }, "f_decimal" }, ;
      { PadR( "K Validacija", 50 ), {|| PadR( KValid, 50 ) }, "KValid" }, ;
      { PadR( "K When", 50 ),  {|| KWhen }, "KWhen" }, ;
      { PadR( "UBrowsu", 4 ),  {|| UBrowsu }, "UBrowsu" }, ;
      { PadR( "EdKolona", 4 ), {|| EdKolona }, "EdKolona" }, ;
      { PadR( "K1", 4 ),       {|| k1 }, "k1" }, ;
      { PadR( "K2", 4 ),       {|| k2 }, "k2" }, ;
      { PadR( "K3", 4 ),       {|| k3 }, "k3" }, ;
      { PadR( "K4", 4 ),       {|| k4 }, "k4" }             ;
      }

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   RETURN PostojiSifra( F_SIFK, 1, MAXROWS() - 15, MAXCOLS() - 15, "sifk - Karakteristike", @cId, dx, dy )



FUNCTION k_f5_nadji_novu_sifru()

   LOCAL cPom
   LOCAL cPom2
   LOCAL nOrder
   LOCAL nDuz

   PRIVATE cK1 := ""
   PRIVATE cImeVar := ""
   PRIVATE cNumDio := ""

   IF Alias() <> "ROBA" .OR.  FieldPos( "K1" ) == 0 .OR. !( ( cImeVar := ReadVar() ) == "WID" ) .OR. !Empty( cK1 := Space( Len( K1 ) ) ) .OR. !VarEdit( { { "Unesite K1", "cK1",, "@!", } }, 10, 23, 14, 56, "Odredjivanje nove sifre artikla", "B5" )
      RETURN ( NIL )
   ENDIF
   cNumDio := my_get_from_ini( "ROBA", "NumDio", "SUBSTR(ID,7,3)", SIFPATH )
   cPom2   := &( cImeVar )
   nDuz    := Len( cPom2 )
   cPom2   := RTrim( cPom2 )
   cPom    := cK1 + Chr( 255 )
   PushWA()

   nOrder := index_tag_num( "BROBA" )
   IF nOrder = 0
      MsgBeep( "Ako ste u mrezi, svi korisnici moraju napustiti FMK. Zatim pritisnite Enter!" )
      MsgO( "Kreiram tag(index) 'BROBA'" )
      cSort := my_get_from_ini( "ROBA", "Sort", "K1+SUBSTR(ID,7,3)", SIFPATH )
      INDEX ON &cSort TAG BROBA
      MsgC()
   ENDIF
   SET ORDER TO TAG "BROBA"
   GO TOP
   SEEK cPom
   SKIP -1
   cNumDio := &cNumDio
   IF K1 == cK1
      &( cImeVar ) := PadR( cPom2 + PadL( AllTrim( Str( Val( cNumDio ) + 1 ) ), Len( cNumDio ), "0" ), nDuz )
   ELSE
      &( cImeVar ) := PadR( cPom2 + PadL( "1", Len( cNumDio ), "0" ), nDuz )
   ENDIF

   wk1 := cK1
   AEval( GetList, {| o| o:display() } )
   PopWA()
   KEYBOARD Chr( K_END )

   RETURN ( NIL )



FUNCTION SeekBarKod( cId, cIdBk, lNFGR )

   LOCAL nRec

   IF lNFGR == nil
      lNFGR := .F.
   ENDIF
   IF lNFGR
      nRec := RecNo()
   ENDIF

   // trazi glavni barkod
   IF FieldPos( "BARKOD" ) <> 0
      SET ORDER TO TAG "BARKOD"
      SEEK cID
      gOcitBarkod := .T.
      cId := ID
      IF fID_J
         cID := ID_J
         SET ORDER TO TAG "ID_J"
         SEEK cID
      ENDIF
   ELSE
      SEEK "àáâ"
   ENDIF

   // nisam nasao barkod u polju BARKOD
   IF !Found()
      cIdBK := cID
      cId := ""
      ImauSifV( "ROBA", "BARK", cIdBK, @cId )
      IF !Empty( cID )
         Beep( 1 )
         SELECT roba
         SET ORDER TO TAG "ID"
         SEEK cId  // nasao sam sifru !!
         cId := Id
         IF fID_J
            gOcitBarkod := .T.
            cID := ID_J
            SET ORDER TO TAG "ID_J"
            SEEK cID
         ENDIF
      ENDIF
   ENDIF

   IF lNFGR .AND. !Found()
      SET ORDER TO TAG "ID"
      GO ( nRec )
   ENDIF

   RETURN .T.
