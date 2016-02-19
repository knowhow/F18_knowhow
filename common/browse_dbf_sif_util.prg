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

MEMVAR ImeKol
MEMVAR Ch, fPoNaz, fID_J

THREAD STATIC __PSIF_NIVO__ := 0
THREAD STATIC __A_SIFV__ := { { NIL, NIL, NIL }, { NIL, NIL, NIL }, { NIL, NIL, NIL }, { NIL, NIL, NIL } }


/*
    ImeKol{   {"ID" ... }, { "Naz" ...} }
    p_sifra( F_TIPDOK, cIdVD, -2 ) => vrijednost polja "Naz" za ID == cIdVd
*/

FUNCTION p_sifra( nDbf, xIndex, nVisina, nSirina, cNaslov, cID, dx, dy,  bBlok, aPoredak, bPodvuci, aZabrane, lInvert, aZabIsp )

   LOCAL cRet, cIdBK
   LOCAL _i
   LOCAL _komande := { "<c-N> Novi", "<F2>  Ispravka", "<ENT> Odabir", _to_str( "<c-T> Briši" ), "<c-P> Print", ;
      "<F4>  Dupliciraj", _to_str( "<c-F9> Briši SVE" ), _to_str( "<c-F> Traži" ), "<a-S> Popuni kol.", ;
      "<a-R> Zamjena vrij.", "<c-A> Cirk.ispravka" }
   LOCAL cUslovSrch :=  ""
   LOCAL cNazSrch
   LOCAL cOrderTag

   PRIVATE fPoNaz := .F.
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
   IF !Used()
      MsgBeep( "Tabela nije otvorena u radnom području !#Prekidam operaciju." )
      RETURN .F.
   ENDIF

   cOrderTag := ordName( 1 )

   sif_set_order( xIndex, cOrderTag, @fID_j )
   sif_sql_seek( @cId, @cIdBK, @cUslovSrch, @cNazSrch, fId_j, cOrderTag )


   IF ValType( dx ) == "N" .AND. dx < 0

      IF !Found()
         GO BOTTOM
         SKIP
         cRet := Eval( ImeKol[ - dx, 2 ] )
         SKIP -1
      ELSE
         cRet := Eval( ImeKol[ - dx, 2 ] )
      ENDIF

      PopSifV()
      PopWa( nDbf )

      RETURN cRet

   ENDIF

   IF ( fPonaz .AND. ( cNazSrch == "" .OR. !Trim( cNazSrch ) == Trim( field->naz ) ) ) ;
         .OR. cId == NIL ;
         .OR. ( !Found() .AND. cNaslov <> NIL ) ;
         .OR. ( cNaslov <> NIL .AND. Left( cNaslov, 1 ) = "#" )

      lPrviPoziv := .T.

      IF Eof()
         SKIP -1
      ENDIF

      IF cId == NIL
         // idemo bez parametara
         GO TOP
      ENDIF

      my_db_edit_sql(, nVisina, nSirina,  {|| ed_sql_sif( nDbf, cNaslov, bBlok, aZabrane, aZabIsp ) }, ToStrU( cNaslov ), "", lInvert, _komande, 1, bPodvuci, , , aPoredak )

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
   ordSetFocus( cOrderTag )

   SET FILTER TO

   PopSifV()
   PopWa( nDbf )

   RETURN .T.





STATIC FUNCTION sif_set_order( xIndex, cOrderTag, fID_j )

   LOCAL nPos

   DO CASE
   CASE ValType( xIndex ) == "N"

      IF xIndex == 1
         ordSetFocus( cOrderTag )
      ELSE

         IF Empty( cOrderTag )
            SET ORDER TO TAG "2"
         ENDIF
      ENDIF

   CASE ValType( xIndex ) == "C" .AND. Right( Upper( Trim( xIndex ) ), 2 ) == "_J"

      SET ORDER TO tag ( xIndex )
      fID_J := .T.

   OTHERWISE

      nPos := At( "_", xIndex )
      IF nPos <> 0
         IF Empty( Left( xIndex, nPos - 1 ) )
            dbSetIndex( SubStr( xIndex, nPos + 1 ) )
         ELSE
            SET ORDER TO tag ( Left( xIndex, nPos - 1 ) ) IN ( SubStr( xIndex, nPos + 1 ) )
         ENDIF
      ELSE
         SET ORDER TO tag ( xIndex )
      ENDIF

   END CASE

   RETURN .T.



STATIC FUNCTION sif_sql_seek( cId, cIdBK, cUslovSrch, cNazSrch, fId_j, cOrderTag )

   LOCAL _bk := ""
   LOCAL _order := ordName()
   LOCAL _tezina := 0

   IF cId == NIL
      RETURN
   ENDIF

   IF ValType( cId ) == "N"
      SEEK Str( cId )
      RETURN
   ENDIF

   IF Right( Trim( cId ), 1 ) == "*"
      sif_katbr_zvjezdica( @cId, @cIdBK, fId_j )
      RETURN
   ENDIF

   IF Right( Trim( cId ), 1 ) $ ".$"
      sif_point_or_slash( @cId, @fPoNaz, @cOrderTag, @cUslovSrch, @cNazSrch )
      RETURN
   ENDIF

   SEEK cId

   IF Found()
      cId := &( FieldName( 1 ) )
      RETURN
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

   RETURN



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

      cIdBK := Left( cId, Len( Trim( cId ) ) -1 )
      cId   := ""

      ImauSifV( "ROBA", "KATB", cIdBK, @cId )

      IF !Empty( cId )

         SELECT roba
         SET ORDER TO TAG "ID"

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



FUNCTION sif_point_or_slash( cId, fPoNaz, cOrderTag, cUslovSrch, cNazSrch )

   LOCAL _filter

   cId := PadR( cId, 10 )

   IF !Empty( cOrderTag )
      ordSetFocus( "NAZ" )
   ELSE
      ordSetFocus( "2" )
   ENDIF

   fPoNaz := .T.

   cNazSrch := ""
   cUslovSrch := ""

   IF Left( Trim( cId ), 1 ) == "."

      PRIVATE GetList := {}

      Box(, 1, 60 )

      cNazSrch := Space( Len( naz ) )
      Beep( 1 )

      @ m_x + 1, m_y + 2 SAY "Unesi naziv:" GET cNazSrch PICT "@!S40"
      READ

      BoxC()

      SEEK Trim( cNazSrch )

      cId := field->id

   ELSEIF Right( Trim( cId ), 1 ) == "$"

      _filter := _filter_quote( Left( Upper( cId ), Len( Trim( cId ) ) - 1 ) ) + " $ UPPER(naz)"
      SET FILTER TO
      SET FILTER to &( _filter )
      GO TOP

   ELSE

      SEEK Left( cId, Len( Trim( cId ) ) - 1 )

   ENDIF

   RETURN .T.



STATIC FUNCTION ed_sql_sif( nDbf, cNaslov, bBlok, aZabrane, aZabIsp )

   LOCAL i
   LOCAL j
   LOCAL imin
   LOCAL imax
   LOCAL nGet
   LOCAL nRet
   LOCAL cOrderTag
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

   cOrderTag := ordName()
   nRet := -1
   lZabIsp := .F.

   IF bBlok <> NIL

      nRet := Eval( bBlok, Ch )
      IF nRet > 4
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

      IF edit_sql_sif_item( Ch, cOrderTag, aZabIsp, .T. ) == 1
         RETURN DE_REFRESH
      ENDIF

      RETURN DE_CONT

   CASE ( Ch == K_F2 .OR. Ch == K_CTRL_A )

      Tb:RefreshCurrent()

      IF edit_sql_sif_item( Ch, cOrderTag, aZabIsp, .F. ) == 1
         RETURN DE_REFRESH
      ENDIF

      RETURN DE_CONT

   CASE Ch == K_CTRL_P

      PushWA()
      IzborP2( Kol, PRIVPATH + Alias() )
      IF LastKey() == K_ESC
         RETURN DE_CONT
      ENDIF

      Izlaz( "Pregled: " + AllTrim( cNaslov ) + " na dan " + DToC( Date() ) + " g.", "sifarnik" )
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
      Popup( cOrderTag )
      RETURN DE_CONT

   OTHERWISE
      IF nRet >- 1
         RETURN nRet
      ELSE
         RETURN DE_CONT
      ENDIF

   ENDCASE

   RETURN



STATIC FUNCTION edit_sql_sif_item( Ch, cOrderTag, aZabIsp, lNovi )

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
      ordSetFocus( cOrderTag )
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

      set_sif_vars()

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
      FOR _jg := 1 TO 3

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
               sif_sql_getlist( cPom, @GetList,  lZabIsp, aZabIsp, lShowPGroup, Ch, @nGet, @i, @nTekRed )
               nGet++
            ELSE
               nRed := 1
               nKolona := 1
               IF Len( ImeKol[ i ] ) >= 10 .AND. Imekol[ i, 10 ] <> NIL
                  nKolona := imekol[ i, 10 ]
                  nRed := 0
               ENDIF

               IF nKolona == 1
                  ++nTekRed
               ENDIF
               @ m_x + nTekRed, m_y + nKolona SAY8 PadL( AllTrim( ImeKol[ i, 1 ] ), 15 )
               @ m_x + nTekRed, Col() + 1 SAY Eval( ImeKol[ i, 2 ] )

            ENDIF

            i++

            IF ( Len( ImeKol ) < i ) .OR. ( nTekRed > Min( MAXROWS() -7, nTrebaRedova ) .AND. !( Len( ImeKol[ i ] ) >= 10 .AND. imekol[ i, 10 ] <> NIL )  )
               EXIT
            ENDIF

         ENDDO

         SET KEY K_F8 TO NNSifru()
         SET KEY K_F9 TO n_num_sif()
         SET KEY K_F5 TO NNSifru2()

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
      ordSetFocus( cOrderTag )
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

   ordSetFocus( cOrderTag )

   RETURN 1



FUNCTION snimi_promjene_sifarnika( lNovi, cTekuciZapis )

   LOCAL lRet := .F.
   LOCAL lOk := .T.
   LOCAL _rec
   LOCAL cAlias := Lower( Alias() )
   LOCAL cEditovaniZapis
   LOCAL lSqlTable
   LOCAL lAppended := .F.

   lSqlTable := is_sql_table( cAlias )

   _rec := get_dbf_global_memvars( "w", NIL, lSqlTable )

   sql_table_update( nil, "BEGIN" )

   IF !f18_lock_tables( { cAlias }, .T. )
      sql_table_update( nil, "END" )
      Msgbeep( "Ne mogu zaključati tabelu " + cAlias + "!#Prekidam operaciju." )
      RETURN lRet
   ENDIF

   IF lNovi .AND. is_sifra_postoji_u_sifarniku( _rec )
      sql_table_update( nil, "END" )
      Msgbeep( "Šifra koju želite dodati već postoji u šifrarniku !" )
      RETURN lRet
   ENDIF

   IF lNovi
      lAppended := .T.
      APPEND BLANK
   ENDIF

   lOk := update_rec_server_and_dbf( cAlias, _rec, 1, "CONT" )

   IF lOk
      lOk := update_sifk_na_osnovu_ime_kol_from_global_var( ImeKol, "w", lNovi, "CONT" )
   ENDIF

   IF lOk

      lRet := .T.
      f18_free_tables( { cAlias } )
      sql_table_update( nil, "END" )
      log_write( "F18_DOK_OPER: dodavanje/ispravka zapisa u šifrarnik " + cAlias, 2 )

   ELSE

      sql_table_update( nil, "ROLLBACK" )

      IF lNovi .AND. lAppended
         // brisi DBF zapis koji smo prvobitno dodali
         delete_with_rlock()
      ENDIF

      log_write( "F18_DOK_OPER: greška kod dodavanja/ispravke zapisa u šifrarnik " + cAlias, 2 )
      MsgBeep( "Greška kod dodavanja/ispravke šifre !#Operacija prekinuta." )

   ENDIF

   set_global_vars_from_dbf( "w" )

   IF lRet
      cEditovaniZapis := vrati_vrijednosti_polja_sifarnika_u_string( "w" )
      IF cEditovaniZapis <> cTekuciZapis
         log_write( "F18_DOK_OPER: " + ;
            iif( lNovi, "dodan novi", "ispravljen" ) + " zapis tabele " + cAlias + ;
            iif( !lNovi, " postojeći zapis: " + cTekuciZapis, "" ) + " novi zapis: " + cEditovaniZapis, 2 )
      ENDIF
   ENDIF

   RETURN lRet



FUNCTION snimi_promjene_cirkularne_ispravke_sifarnika()

   LOCAL _vars, _alias
   LOCAL lRet := .F.
   LOCAL lOk := .T.
   LOCAL lSqlTable

   lSqlTable := is_sql_table( Alias() )

   _vars := get_dbf_global_memvars( "w", NIL, lSqlTable )
   _alias := Lower( Alias() )

   sql_table_update( nil, "BEGIN" )
   IF !f18_lock_tables( { _alias  }, .T. )
      sql_table_update( nil, "END" )
      MsgBeep( "Ne mogu zaključati tabelu " + _alias + " !#Prekidam operaciju." )
      RETURN lRet
   ENDIF

   lOk := update_rec_server_and_dbf( _alias, _vars, 1, "CONT" )
   IF lOk
      lOk := update_sifk_na_osnovu_ime_kol_from_global_var( ImeKol, "w", Ch == K_CTRL_N, "CONT" )
   ENDIF

   IF lOk
      lRet := .T.
      f18_free_tables( { _alias } )
      sql_table_update( nil, "END" )
      log_write( "F18_DOK_OPER: cirkularna ispravka šifrarnika " + _alias, 2 )
   ELSE
      sql_table_update( nil, "ROLLBACK" )
      log_write( "F18_DOK_OPER: greška sa cirkularnom ispravkom šifrarnika " + _alias, 2 )
      MsgBeep( "Greška sa operacijom cirkularne ispravke !#Operacija prekinuta." )
   ENDIF

   set_global_vars_from_dbf( "w" )

   RETURN lRet




STATIC FUNCTION set_w_var( ImeKol, _i, show_grup )

   LOCAL _tmp, _var_name

   IF Left( ImeKol[ _i, 3 ], 6 ) != "SIFK->"

      _var_name := "w" + ImeKol[ _i, 3 ]

   ELSE
      IF Alias() == "PARTN" .AND. Right( ImeKol[ _i, 3 ], 4 ) == "GRUP"
         show_grup := .T.
      ENDIF

      _var_name := "wSifk_" + SubStr( ImeKol[ _i, 3 ], 7 )

      _tmp := IzSifk( Alias(), SubStr( ImeKol[ _i, 3 ], 7 ) )

      IF _tmp == NIL
         _var_name := ""
      ELSE
         __mvPublic( _var_name )
         Eval( MemVarBlock( _var_name ), _tmp )
      ENDIF

   ENDIF

   RETURN _var_name



FUNCTION sif_sql_getlist( var_name, GetList, lZabIsp, aZabIsp, lShowGrup, Ch, nGet, i, nTekRed )

   LOCAL bWhen, bValid, cPic
   LOCAL nRed, nKolona
   LOCAL cWhenSifk, cValidSifk
   LOCAL _when_block, _valid_block
   LOCAL _m_block := MemVarBlock( var_name )
   LOCAL tmpRec

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

   if &var_name == NIL
      tmpRec = RecNo()
      GO BOTTOM
      SKIP
      &var_name := Eval( ImeKol[ i, 2 ] )
      GO tmpRec
   ENDIF

   IF ValType( &var_name ) == "C"
      &var_name = hb_UTF8ToStr( &var_name )
   ENDIF

   AAdd( GetList, _GET_( &var_name, var_name,  cPic, _valid_block, _when_block ) ) ;;
      ATail( GetList ):display()

   RETURN .T.




STATIC FUNCTION add_match_code( ImeKol, Kol )

   LOCAL  _pos, cMCField := Alias()

   IF ( cMCField )->( FieldPos( "MATCH_CODE" ) ) <> 0

      _pos := AScan( ImeKol, {| xImeKol| Upper( xImeKol[ 3 ] ) == "MATCH_CODE" } )

      IF _pos == 0
         AAdd( ImeKol, { "MATCH_CODE", {|| match_code }, "match_code" } )
         AAdd( Kol, Len( ImeKol ) )
      ENDIF

   ENDIF

   RETURN .T.

/*
   vraca naziv polja + vrijednost za tekuci alias
   cMarker = "w" ako je Scatter("w")
*/

FUNCTION vrati_vrijednosti_polja_sifarnika_u_string( cMarker )

   LOCAL cRet := ""
   LOCAL i
   LOCAL cFName
   LOCAL xFVal
   LOCAL cFVal
   LOCAL cType

   FOR i := 1 TO FCount()

      cFName := AllTrim( FIELD( i ) )

      xFVal := FieldGet( i )

      cType := ValType( xFVal )

      IF cType == "C"
         cFVal := AllTrim( xFVal )
      ELSEIF cType == "N"
         cFVal := AllTrim( Str( xFVal, 12, 2 ) )
      ELSEIF cType == "D"
         cFVal := DToC( xFVal )
      ENDIF

      cRet += cFName + "=" + cFVal + "#"
   NEXT

   RETURN cRet




STATIC FUNCTION set_sif_vars()

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


FUNCTION sifarnik_set_roba_defaults()

   IF Alias() <> "ROBA"
      RETURN
   ENDIF

   widtarifa := PadR( "PDV17", 6 )

   RETURN .T.



STATIC FUNCTION Popup( cOrderTag )

   LOCAL opc := {}
   LOCAL opcexe := {}
   LOCAL Izbor

   AAdd( Opc, "1. novi                  " )
   AAdd( opcexe, {|| edit_sql_sif_item( K_CTRL_N, cOrderTag, NIL, .T. ) } )
   AAdd( Opc, "2. edit  " )
   AAdd( opcexe, {|| edit_sql_sif_item( K_F2, cOrderTag, NIL, .F. ) } )
   AAdd( Opc, "3. dupliciraj  " )
   AAdd( opcexe, {|| edit_sql_sif_item( K_F4, cOrderTag, NIL, .T. ) } )
   AAdd( Opc, "4. <a+R> za sifk polja  " )
   AAdd( opcexe, {|| repl_sifk_item() } )
   AAdd( Opc, "5. copy polje -> sifk polje  " )
   AAdd( opcexe, {|| copy_to_sifk() } )

   Izbor := 1
   f18_menu( "bsif", .F., izbor, opc, opcexe )

   RETURN 0


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




FUNCTION sifarnik_brisi_stavku()

   LOCAL _rec_dbf, _rec, cAlias
   LOCAL lOk
   LOCAL hRec

   IF Pitanje( , "Želite li izbrisati ovu stavku (D/N) ?", "D" ) == "N"
      RETURN DE_CONT
   ENDIF

   cAlias := Lower( Alias() )

   PushWA()

   sql_table_update( nil, "BEGIN" )
   IF !f18_lock_tables( { cAlias }, .T. )
      sql_table_update( nil, "END" )
      MsgBeep( "Ne mogu zaključati tabelu " + cAlias + "!#Prekidam operaciju." )
      RETURN DE_CONT
   ENDIF

   _rec_dbf := dbf_get_rec()

   hRec := _rec_dbf

   lOk := delete_rec_server_and_dbf( cAlias, _rec_dbf, 1, "CONT" )

   IF lOk .AND. Alias() != "SIFK" .AND. hb_HHasKey( _rec_dbf, "id" )
      O_SIFK
      O_SIFV
      _rec := hb_Hash()
      _rec[ "id" ]    := PadR( cAlias, 8 )
      _rec[ "idsif" ] := PadR( _rec_dbf[ "id" ], 15 )
      lOk := delete_rec_server_and_dbf( "sifv", _rec, 3, "CONT" )

   ENDIF

   IF lOk
      sql_table_update( nil, "END" )
#ifdef F18_DEBUG
      MsgBeep( "table " + cAlias  + " updated and locked" )
#endif
      f18_free_tables( { cAlias } )
      log_write( "F18_DOK_OPER: brisanje stavke iz šifrarnika, stavka " + pp( hRec ), 2 )
   ELSE
      sql_table_update( nil, "ROLLBACK" )
      log_write( "F18_DOK_OPER: greška sa brisanjem stavke iz šifrarnika", 2 )
      MsgBeep( "Greška sa brisanjem zapisa iz šifrarnika !#Operacija prekinuta." )
   ENDIF

   PopWa()

   IF lOk
      RETURN DE_REFRESH
   ENDIF

   RETURN DE_CONT


FUNCTION sifarnik_brisi_sve()

   PushWA()

   IF Pitanje( , "Želite li sigurno izbrisati SVE zapise (D/N) ?", "N" ) == "N"
      RETURN DE_CONT
   ENDIF

   Beep( 6 )

   IF Pitanje( , "Ponavljam : izbrisati BESPOVRATNO kompletan šifrarnik (D/N) ?", "N" ) == "D"

      IF delete_all_dbf_and_server( Alias() )
         log_write( "F18_DOK_OPER: brisanje kompletnog šifrarnika " + Alias(), 2 )
      ENDIF

      PopWa()

   ENDIF

   RETURN DE_REFRESH



STATIC FUNCTION PushSifV()

   __PSIF_NIVO__ ++
   IF __PSIF_NIVO__ > Len( __A_SIFV__ )
      AAdd( __A_SIFV__, { "", 0, 0 } )
   ENDIF

   RETURN .T.



STATIC FUNCTION PopSifV()

   --__PSIF_NIVO__

   RETURN .T.




FUNCTION sifra_postoji( wId, cTag )

   LOCAL nRec := RecNo()
   LOCAL nRet := .T.
   LOCAL cUpozorenje

   IF cTag == NIL
      cTag := "ID"
   ENDIF

   IF index_tag_num( cTag ) == 0
      _msg := "alias: " + Alias() + ", tag ne postoji :" + cTag
      log_write( _msg )
      MsgBeep( _msg )
      RETURN nRet
   ENDIF

   IF cTag <> "ID" .AND. Empty( wId )
      RETURN nRet
   ENDIF

   cUpozorenje := "Vrijednost polja " + cTag + " već postoji !"

   PushWA()

   SET ORDER TO TAG ( cTag )
   SEEK wId

   IF ( Found() .AND. ( Ch == K_CTRL_N .OR. Ch == K_F4 ) )

      MsgBeep( cUpozorenje )
      nRet := .F.

   ELSEIF ( gSKSif == "D" .AND. Found() )
      IF nRec <> RecNo()
         MsgBeep( cUpozorenje )
         nRet := .F.
      ELSE
         SKIP 1
         IF ( !Eof() .AND. wId == id )
            MsgBeep( cUpozorenje )
            nRet := .F.
         ENDIF
      ENDIF
   ENDIF

   PopWa()

   RETURN nRet



/*
   Opis: funkcija ispituje da li šifra postoji na serveru
 */

FUNCTION is_sifra_postoji_u_sifarniku( hTekuciRec )

   LOCAL lRet := .F.
   LOCAL cAlias := Alias()
   LOCAL hTblRec := get_a_dbf_rec( cAlias, .T. )
   LOCAL cTable, cWhere

   IF ValType( hTblRec ) <> "H"
      RETURN lRet
   ENDIF

   IF hTblRec[ "temp" ]
      RETURN lRet
   ENDIF

   cTable := hTblRec[ "table" ]
   IF Left( cTable, 4 ) <> "fmk."
      cTable := "fmk." + cTable
   ENDIF

   cWhere := napravi_where_uslov_na_osnovu_hash_matrica( hTblRec, hTekuciRec )

   IF Empty( cWhere )
      RETURN lRet
   ENDIF

   IF table_count( cTable, cWhere ) > 0
      lRet := .T.
   ENDIF

   RETURN lRet



STATIC FUNCTION napravi_where_uslov_na_osnovu_hash_matrica( hTblRec, hRec )

   LOCAL cSqlFields, aDbfFields, i, aTmp
   LOCAL cWhere := ""
   LOCAL cTmp := ""

   cSqlFields := hTblRec[ "algoritam" ][ 1 ][ "sql_in" ]
   aDbfFields := hTblRec[ "algoritam" ][ 1 ][ "dbf_key_fields" ]

   IF cSqlFields == NIL .OR. Empty( cSqlFields )
      RETURN cWhere
   ENDIF

   IF aDbfFields == NIL .OR. Len( aDbfFields ) == 0
      RETURN cWhere
   ENDIF

   FOR i := 1 TO Len( aDbfFields )
      IF ValType( aDbfFields[ i ] ) == "A"
         aTmp := aDbfFields[ i ]
         cTmp += Str( hRec[ aTmp[ 1 ] ], aTmp[ 2 ], 0 )
      ELSE
         cTmp += hRec[ aDbfFields[ i ] ]
      ENDIF
   NEXT

   IF Empty( cTmp )
      RETURN cWhere
   ENDIF

   cWhere := cSqlFields
   cWhere += " = "
   cWhere += sql_quote( cTmp )

   RETURN cWhere
