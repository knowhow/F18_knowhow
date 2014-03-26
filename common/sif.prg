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

#include "fmk.ch"

#include "dbstruct.ch"

// static integer
STATIC __PSIF_NIVO__ := 0

STATIC _LOG_PROMJENE := .F.

STATIC __A_SIFV__ := { { NIL, NIL, NIL }, { NIL, NIL, NIL }, { NIL, NIL, NIL }, { NIL, NIL, NIL } }

FUNCTION p_sifra( nDbf, xIndex, nVisina, nSirina, cNaslov, cID, dx, dy,  bBlok, aPoredak, bPodvuci, aZabrane, invert, aZabIsp )

   LOCAL cRet, cIdBK
   LOCAL _i
   LOCAL _komande := { "<c-N> Novi", "<F2>  Ispravka", "<ENT> Odabir", _to_str( "<c-T> Briši" ), "<c-P> Print", ;
      "<F4>  Dupliciraj", _to_str( "<c-F9> Briši SVE" ), _to_str( "<c-F> Traži" ), "<a-S> Popuni kol.", ;
      "<a-R> Zamjena vrij.", "<c-A> Cirk.ispravka" }
   LOCAL cUslovSrch :=  ""
   LOCAL cNazSrch

   // trazenje je po nazivu
   PRIVATE fPoNaz := .F.
   PRIVATE fID_J := .F.

   IF aZabIsp == nil
      aZabIsp := {}
   ENDIF

   FOR _i := 1 TO Len( aZabIsp )
      aZabIsp[ _i ] := Upper( aZabIsp[ _i ] )
   NEXT

   // provjeri da li treba logirati promjene
   IF Logirati( "FMK", "SIF", "PROMJENE" )
      _LOG_PROMJENE := .T.
   ENDIF

   PRIVATE cOrderTag

   PushWa()
   PushSifV()

   IF invert == NIL
      invert := .T.
   ENDIF

   SELECT ( nDbf )
   IF !Used()
      MsgBeep( "USED FALSE ?!" )
      RETURN .F.
   ENDIF

   // setuj match_code polje...
   set_mc_imekol( nDbf )

   cOrderTag := ordName( 1 )

   sif_set_order( xIndex, cOrderTag, @fID_j )

   sif_sql_seek( @cId, @cIdBK, @cUslovSrch, @cNazSrch, fId_j, cOrderTag )

   IF dx <> NIL .AND. dx < 0
      // u slucaju negativne vrijednosti vraca se vrijednost polja
      // koje je na poziciji ABS(i)
      IF !Found()
         GO BOTTOM
         SKIP  // id na eof, tamo su prazne vrijednosti
         cRet := &( FieldName( -dx ) )
         SKIP -1
      ELSE
         cRet := &( FieldName( -dx ) )
      ENDIF

      PopSifV()
      PopWa()

      RETURN cRet

   ENDIF

   IF !Empty( cUslovSrch )
      // postavi filter u sifrarniku
      set_sif_filt( cUslovSrch )
   ENDIF

   IF ( fPonaz .AND. ( cNazSrch == "" .OR. !Trim( cNazSrch ) == Trim( naz ) ) ) ;
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

      browse_table_sql(, nVisina, nSirina,  {|| ed_sql_sif( nDbf, cNaslov, bBlok, aZabrane, aZabIsp ) }, ToStrU( cNaslov ) , "", invert, _komande, 1, bPodvuci, , , aPoredak )

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

   // ispisi naziv
   sif_ispisi_naziv( nDbf, dx, dy )

   SELECT ( nDbf )
   ordSetFocus( cOrderTag )

   SET FILTER TO
   PopSifV()
   PopWa()

   RETURN .T.

// ------------------------------------------------
// ------------------------------------------------
STATIC FUNCTION sif_set_order( xIndex, cOrderTag, fID_j )

   LOCAL nPos

   DO CASE
   CASE ValType( xIndex ) == "N"

      IF xIndex == 1
         ordSetFocus( cOrderTag )
      ELSE

         IF EMPTY( cOrderTag )
            SET ORDER TO TAG "2"
         ENDIF
      ENDIF

   CASE ValType( xIndex ) == "C" .AND. Right( Upper( Trim( xIndex ) ), 2 ) == "_J"

      // postavi order na ID_J
      SET ORDER TO tag ( xIndex )
      fID_J := .T.

   OTHERWISE

      // IDX varijanta:  TAG_IMEIDXA
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

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
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

   IF Right( Trim( cId ), 1 ) $ "./$"
      sif_point_or_slash( @cId, @fPoNaz, @cOrderTag, @cUslovSrch, @cNazSrch )
      RETURN
   ENDIF

   // glavni seek
   // id, barkod
   SEEK cId

   IF Found()
      // po id-u
      cId := &( FieldName( 1 ) )
      RETURN
   ENDIF

   // po barkod-u
   IF Len( cId ) > 10

      IF !tezinski_barkod( @cId, @_tezina, .F. )
         barkod( @cId )
      ENDIF

      ordSetFocus( _order )
      RETURN

   ENDIF

   RETURN



// ----------------------------------------------------
// ----------------------------------------------------
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



STATIC FUNCTION sif_point_or_slash( cId, fPoNaz, cOrderTag, cUslovSrch, cNazSrch )

   LOCAL _filter

   cId := PadR( cId, 10 )

   IF !EMPTY( cOrderTag )
      ordSetFocus( "NAZ" )
   ELSE
      ordSetFocus( "2" )
   ENDIF

   fPoNaz := .T.

   cNazSrch := ""
   cUslovSrch := ""

   IF Left( Trim( cId ), 1 ) == "/"

      PRIVATE GetList := {}

      Box(, 1, 60 )

      cUslovSrch := Space( 120 )
      zelim_pronaci( cUslovSrch )
      BoxC()

   ELSEIF Left( Trim( cId ), 1 ) == "."

      // SEEK PO NAZ kada se unese DUGACKI DIO
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

      // pretraga dijela sifre...
      _filter := _filter_quote( Left( Upper( cId ), Len( Trim( cId ) ) - 1 ) ) + " $ UPPER(naz)"
      SET FILTER TO
      SET FILTER to &( _filter )
      GO TOP

   ELSE

      SEEK Left( cId, Len( Trim( cId ) ) - 1 )

   ENDIF

   RETURN .T.

// ------------------------------------------------------------
// -----------------------------------------------------------
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

   // matrica zabrana
   IF aZabrane = nil
      aZabrane := {}
   ENDIF

   // matrica zabrana ispravki polja
   IF aZabIsp = nil
      aZabIsp := {}
   ENDIF

   Ch := LastKey()

   // deklarisi privatne varijable sifrarnika
   // wPrivate
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

#ifndef TEST

   // provjeri pristup opcijama koje mjenjaju podatke
   IF ( Ch == K_CTRL_N .OR. Ch == K_CTRL_A .OR. Ch == K_F2 .OR. ;
         Ch == K_CTRL_T .OR. Ch == K_F4 .OR. Ch == K_CTRL_F9 .OR. Ch == K_F10 ) .AND. ;
         ( !ImaPravoPristupa( goModul:oDatabase:cName, "SIF", "EDSIF" ) )

      RETURN DE_CONT

   ENDIF

#endif

   DO CASE

   CASE Ch == K_ENTER
      // ako sam u sifrarniku a ne u unosu dokumenta
      IF gMeniSif
         RETURN DE_CONT
      ELSE
         // u unosu sam dokumenta
         lPrviPoziv := .F.
         RETURN DE_ABORT
      ENDIF

   CASE Upper( Chr( Ch ) ) == "F"

      // pretraga po MATCH_CODE
      IF m_code_src() == 0
         RETURN DE_CONT
      ELSE
         RETURN DE_REFRESH
      ENDIF

   CASE Ch == Asc( "/" )

      cUslovSrch := ""

      Box( , 1, 60 )
      cUslovSrch := Space( 120 )
      zelim_pronaci( @cUslovSrch )

      BoxC()

      IF !Empty( cUslovSrch )
         // postavi filter u sifrarniku
         set_sif_filt( cUslovSrch )
      ELSE
         SET FILTER TO
      ENDIF
      RETURN DE_REFRESH


   CASE ( Ch == K_CTRL_N .OR. Ch == K_F2 .OR. Ch == K_F4 .OR. Ch == K_CTRL_A )

      Tb:RefreshCurrent()

      IF edit_sql_sif_item( Ch, cOrderTag, aZabIsp ) == 1
         RETURN DE_REFRESH
      ENDIF

      RETURN DE_CONT

   CASE Ch == K_CTRL_P

      PushWa()
      IzborP2( Kol, PRIVPATH + Alias() )
      IF LastKey() == K_ESC
         RETURN DE_CONT
      ENDIF

      Izlaz( "Pregled: " + AllTrim( cNaslov ) + " na dan " + DToC( Date() ) + " g.", "sifrarnik" )
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
      RETURN sif_brisi_stavku()

   CASE Ch == K_CTRL_F9
      RETURN sif_brisi_sve()

   CASE Ch == K_ALT_C
      RETURN SifClipBoard()

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

// ------------------------------------------
// ------------------------------------------
STATIC FUNCTION edit_sql_sif_item( Ch, cOrderTag, aZabIsp )

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

   PRIVATE nXP
   PRIVATE nYP
   PRIVATE cPom
   PRIVATE aQQ
   PRIVATE aUsl
   PRIVATE aStruct

   altd()
   nPrevRecNo := RecNo()

   lNovi := .F.

   IF _LOG_PROMJENE == .T.
      // daj stare vrijednosti
      cOldDesc := _g_fld_desc( "w" )
   ENDIF

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

      // setuj varijable za tekuci slog
      set_sif_vars()

      IF Ch == K_CTRL_N
         // nastimaj default vrijednosti za sifrarnik robe
         set_roba_defaults()
      ENDIF

      nTrebaredova := Len( ImeKol )

      FOR i := 1 TO Len( ImeKol )
         IF Len( ImeKol[ i ] ) >= 10 .AND. Imekol[ i, 10 ] <> NIL
            nTrebaRedova--
         ENDIF
      NEXT

      i := 1
      // tekuci red u matrici imekol
      FOR _jg := 1 TO 3  

         IF _jg == 1
            Box( NIL, Min( MAXROWS() -7, nTrebaRedova ) + 1, MAXCOLS() -20, .F. )
         ELSE
            BoxCLS()
         ENDIF

         SET CURSOR ON
         PRIVATE Getlist := {}

         // brojac get-ova
         nGet := 1

         // broj redova koji se ne prikazuju (_?_)
         nNestampati := 0

         nTekRed := 1

         DO WHILE .T.

            lShowPGroup := .F.

            IF Empty( ImeKol[ i, 3 ] )
               // ovdje se kroji matrica varijabli.......
               // area->nazpolja
               cPom := ""
            ELSE
               cPom := set_w_var( ImeKol, i, @lShowPGroup )
            ENDIF

            cPic := ""

            // samo varijable koje mozes direktno mjenjati
            IF !Empty( cPom )
               sif_getlist( cPom, @GetList,  lZabIsp, aZabIsp, lShowPGroup, Ch, @nGet, @i, @nTekRed )
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

            // ! sljedeci slog se stampa u istom redu
            IF ( Len( ImeKol ) < i ) .OR. ( nTekRed > Min( MAXROWS() -7, nTrebaRedova ) .AND. !( Len( ImeKol[ i ] ) >= 10 .AND. imekol[ i, 10 ] <> NIL )  )
               // izadji dosao sam do zadnjeg reda boxa, ili do kraja imekol
               EXIT
            ENDIF
         ENDDO

         // key handleri F8, F9, F5
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

         // ovo vazi samo za CTRL + A opciju !!!!!
         IF LastKey() == K_ESC
            EXIT
         ENDIF

         _vars := get_dbf_global_memvars( "w", NIL, .T. )

         _alias := Lower( Alias() )

         IF !f18_lock_tables( { _alias, "sifv", "sifk", _alias } )
            log_write( "ERROR: nisam uspio lokovati tabele: " + _alias + ", sifk, sifv", 2 )
            EXIT
         ENDIF

         sql_table_update( nil, "BEGIN" )
         // sifarnik
         update_rec_server_and_dbf( _alias, _vars, 1, "CONT" )
         // sifk/sifv
         update_sifk_na_osnovu_ime_kol_from_global_var( ImeKol, "w", Ch == K_CTRL_N, "CONT" )
         f18_free_tables( { _alias, "sifv", "sifk" } )
         sql_table_update( nil, "END" )

         set_global_vars_from_dbf( "w" )

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

   // ako je novi zapis napravi APPEND BLANK
   IF lNovi

      // provjeri da li vec ovaj id postoji ?
      nNSInfo := _chk_sif( "w" )

      IF nNSInfo = 1
         msgbeep( "Ova sifra vec postoji !" )
         RETURN 0
      ELSEIF nNSInfo = -1
         RETURN 0
      ENDIF

      APPEND BLANK

   ENDIF

   // uzmi varijable sa forme za unos
   _vars := get_dbf_global_memvars( "w", NIL, .T. )

   // lokuj tabele i napravi update zapisa....
   IF f18_lock_tables( { Lower( Alias() ), "sifv", "sifk" } )

      sql_table_update( nil, "BEGIN" )
	
      IF !update_rec_server_and_dbf( Alias(), _vars, 1, "CONT" )

         IF lNovi
            delete_with_rlock()
         ENDIF

         f18_free_tables( { Lower( Alias() ), "sifv", "sifk" } )
         sql_table_update( nil, "ROLLBACK" )

      ELSE

         update_sifk_na_osnovu_ime_kol_from_global_var( ImeKol, "w", lNovi, "CONT" )
         f18_free_tables( { Lower( Alias() ), "sifv", "sifk" } )
         sql_table_update( nil, "END" )

      ENDIF
   ELSE

      IF lNovi
         // izbrisi ovaj append koji si dodao....
         delete_with_rlock()
      ENDIF

      MsgBeep( "ne mogu lockovati " + Lower( Alias() ) + " sifk/sifv ?!" )

   ENDIF

   // ovo je potrebno radi nekih sifrarnika koji nakon ove opcije opet koriste
   // globalne memoriske varijable w....
   set_global_vars_from_dbf( "w" )

   IF Ch == K_F4 .AND. Pitanje( , "Vrati se na predhodni zapis", "D" ) == "D"
      GO ( nPrevRecNo )
   ENDIF

   ordSetFocus( cOrderTag)
   RETURN 1

// ----------------------------------------------------
// ----------------------------------------------------
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



STATIC FUNCTION sif_getlist( var_name, GetList, lZabIsp, aZabIsp, lShowGrup, Ch, nGet, i, nTekRed )

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

   @ m_x + nTekRed, m_y + nKolona SAY  IIF( nKolona > 1, "  " + AllTrim( ImeKol[ i, 1 ] ), PadL( AllTrim( ImeKol[ i, 1 ] ), 15 ) )  + " "

   // SQL moze vratiti nil vrijednosti
   if &var_name == NIL
      tmpRec = RecNo()
      GO BOTTOM
      SKIP
      // EOF record
      &var_name := Eval( ImeKol[ i, 2 ] )
      GO tmpRec
   ENDIF

   IF ValType( &var_name ) == "C"
      &var_name = hb_UTF8ToStr( &var_name )
   ENDIF

   AAdd( GetList, _GET_( &var_name, var_name,  cPic, _valid_block, _when_block ) ) ;;

      ATail( GetList ):display()

   RETURN .T.


// -----------------------------------------
// -----------------------------------------
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


   // --------------------------------------------------
   // kod sifarnika partnera se mora potvrditi ma
   // --------------------------------------------------

STATIC FUNCTION _chk_sif( cMarker )

   LOCAL cFName
   LOCAL xFVal
   LOCAL cFVal
   LOCAL cType
   LOCAL nTArea := Select()
   LOCAL nTREC := RecNo()
   LOCAL nRet := 0
   LOCAL i := 1
   LOCAL cArea := Alias( nTArea )
   PRIVATE cF_Seek
   PRIVATE GetList := {}

   cFName := AllTrim( FIELD( i ) )
   xFVal := FieldGet( i )
   cType := ValType( xFVal )
   cF_Seek := &( cMarker + cFName )

   IF ( cType == "C" ) .AND. ( cArea $ "#PARTN#ROBA#" )

      GO TOP
      SEEK cF_seek

      IF Found()
         nRet := 1
         GO ( nTRec )
      ENDIF

   ENDIF

   SELECT ( nTArea )

   RETURN nRet


// --------------------------------------------------
// vraca naziv polja + vrijednost za tekuci alias
// cMarker = "w" ako je Scatter("w")
// --------------------------------------------------
STATIC FUNCTION _g_fld_desc( cMarker )

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
         // string
         cFVal := AllTrim( xFVal )
      ELSEIF cType == "N"
         // numeric
         cFVal := AllTrim( Str( xFVal, 12, 2 ) )
      ELSEIF cType == "D"
         // date
         cFVal := DToC( xFVal )
      ENDIF

      cRet += cFName + "=" + cFVal + "#"
   NEXT

   RETURN cRet

// ----------------------------------------------------
// uporedjuje liste promjena na sifri u sifrarniku
// ----------------------------------------------------
STATIC FUNCTION _g_fld_changes( cOld, cNew )

   LOCAL cChanges := "nema promjena - samo prolaz sa F2"
   LOCAL aOld
   LOCAL aNew
   LOCAL cTmp := ""

   // stara matrica
   aOld := TokToNiz( cOld, "#" )
   // nova matrica
   aNew := TokToNiz( cNew, "#" )

   // kao osnovnu referencu uzmi novu matricu
   FOR i := 1 TO Len( aNew )

      cVOld := AllTrim( aOld[ i ] )
      cVNew := AllTrim( aNew[ i ] )
      IF cVNew == cVOld
         // do nothing....
      ELSE
         cTmp += "nova " + cVNew + " stara " + cVOld + ","
      ENDIF
   NEXT

   IF !Empty( cTmp )
      cChanges := cTmp
   ENDIF

   RETURN cChanges

// -----------------------
// -----------------------
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

   RETURN


// --------------------------------------------------------
// setuje default vrijednosti tekuceg sloga za sif.roba
// --------------------------------------------------------
STATIC FUNCTION set_roba_defaults()

   IF Alias() <> "ROBA"
      RETURN
   ENDIF

   // set tarifa uvijek PDV17
   widtarifa := PadR( "PDV17", 6 )

   RETURN



// -------------------------------------------------------
// -------------------------------------------------------
STATIC FUNCTION Popup( cOrderTag )

   LOCAL opc := {}
   LOCAL opcexe := {}
   LOCAL Izbor

   AAdd( Opc, "1. novi                  " )
   AAdd( opcexe, {|| edit_sql_sif_item( K_CTRL_N, cOrderTag ) } )
   AAdd( Opc, "2. edit  " )
   AAdd( opcexe, {|| edit_sql_sif_item( K_F2, cOrderTag ) } )
   AAdd( Opc, "3. dupliciraj  " )
   AAdd( opcexe, {|| edit_sql_sif_item( K_F4, cOrderTag ) } )
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


// -------------------------------
// -------------------------------
STATIC FUNCTION sif_brisi_stavku()

   LOCAL _rec_dbf, _rec, _alias

   IF Pitanje( , "Želite li izbrisati ovu stavku ??", "D" ) == "D"

      PushWa()

      _alias := Alias()

      sql_table_update( nil, "BEGIN" )

      _rec_dbf := dbf_get_rec()
      delete_rec_server_and_dbf( Alias(), _rec_dbf, 1, "CONT" )

      // ako postoji id polje, pobriši i sifv
      IF hb_HHasKey( _rec_dbf, "id" )

         SELECT ( F_SIFK )
         IF !Used()
            O_SIFK
         ENDIF

         SELECT ( F_SIFV )
         IF !Used()
            O_SIFV
         ENDIF

         _rec := hb_Hash()
         _rec[ "id" ]    := PadR( _alias, 8 )
         _rec[ "idsif" ] := PadR( _rec_dbf[ "id" ], 15 )
         // id + idsif
         delete_rec_server_and_dbf( "sifv", _rec, 3, "CONT" )
      ENDIF

      sql_table_update( nil, "END" )

      PopWa()
      RETURN DE_REFRESH
   ELSE
      RETURN DE_CONT
   ENDIF

   RETURN DE_REFRESH

// -------------------------------
// -------------------------------
STATIC FUNCTION sif_brisi_sve()

   IF Pitanje( , "Želite li sigurno izbrisati SVE zapise ??", "N" ) == "N"
      RETURN DE_CONT
   ENDIF

   Beep( 6 )

   nTArea := Select()
   // logiraj promjenu brisanja stavke
   IF _LOG_PROMJENE == .T.
      EventLog( nUser, "FMK", "SIF", "PROMJENE", nil, nil, nil, nil, ;
         "", "", "", Date(), Date(), "", ;
         "pokusaj brisanja kompletnog sifrarnika" )
   ENDIF
   SELECT ( nTArea )

   IF Pitanje( , "Ponavljam : izbrisati BESPOVRATNO kompletan sifrarnik ??", "N" ) == "D"

      delete_all_dbf_and_server( Alias() )
      SELECT ( nTArea )

   ENDIF

   RETURN DE_REFRESH


// ---------------------------------------------------
// ---------------------------------------------------
STATIC FUNCTION PushSifV()

   __PSIF_NIVO__ ++
   IF __PSIF_NIVO__ > Len( __A_SIFV__ )
      AAdd( __A_SIFV__, { "", 0, 0 } )
   ENDIF

   RETURN

// ------------------------------
// ------------------------------
STATIC FUNCTION PopSifV()

   --__PSIF_NIVO__

   RETURN


// ---------------------------------------------------------------------
// VpSifra(wId)
// Stroga kontrola ID-a sifre pri unosu nove ili ispravci postojece!
// wId - ID koji se provjerava
// --------------------------------------------------------------------
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
      QUIT_1
   ENDIF

   // ako nije tag = ID, dozvoli i dupli unos, moze biti barkod polje
   IF cTag <> "ID" .AND. Empty( wId )
      RETURN nRet
   ENDIF

   cUpozorenje := "Vrijednost polja " + cTag + " vec postoji !!!"

   PushWa()

   SET ORDER TO TAG ( cTag )
   SEEK wId

   IF ( Found() .AND. ( Ch == K_CTRL_N .OR. Ch == K_F4 ) )

      MsgBeep( cUpozorenje )
      nRet := .F.

   ELSEIF ( gSKSif == "D" .AND. Found() )
      // nasao na ispravci ili dupliciranju
      IF nRec <> RecNo()
         MsgBeep( cUpozorenje )
         nRet := .F.
      ELSE
         // bio isti zapis, idi na drugi
         SKIP 1
         IF ( !Eof() .AND. wId == id )
            MsgBeep( cUpozorenje )
            nRet := .F.
         ENDIF
      ENDIF
   ENDIF

   PopWa()

   RETURN nRet

// ------------------------------------------
// ------------------------------------------
FUNCTION zelim_pronaci( cUslovSrch )

   @ m_x + 1, m_y + 2 SAY8 "Želim pronaći:" GET cUslovSrch PICT "@!S40"
   READ

   cUslovSrch := Trim( cUslovSrch )
   IF Right( cUslovSrch, 1 ) == "*"
      cUslovSrch := Left( cUslovSrch, Len( cUslovSrch ) -1 )
   ENDIF

   RETURN .T.

// --------------------------------------------------------------------------------
// set_sif_filt
// postavlja _M1_ na "*" za polja kod kojih je cSearch .t.;
// takodje parsira ulaz (npr. RAKO, GSLO 10 20 30, GR1>55, GR2 20 $55#66#77#88 )
// formiraj filterski uslov
// --------------------------------------------------------------------------------
FUNCTION set_sif_filt( cSearch )

   LOCAL _i
   LOCAL n1, n2, cVarijabla, cTipVar
   LOCAL fAddNaPost := .F.
   LOCAL fOrNaPost  := .F.
   LOCAL nCount, nCount2
   PRIVATE cFilt := ".t. "

   cSearch := AllTrim( Trim( cSearch ) )
   // zamjeniti "NAZ $ MISHEL"  -> NAZ $MISHEL
   cSearch := StrTran( cSearch, "$ ", "$" )

   n1 := NumToken( cSearch, "," )
   FOR _i := 1 TO n1

      cUslov := Token( cSearch, ",", _i )
      n2 := NumToken( cUslov, " " )

      IF n2 == 1
         IF cUslov == "+"  // dodaj na postojeci uslov
            fAddNaPost := .T.
         ELSEIF Upper( cUslov ) == "*"  // dodaj na postojeci uslov
            fOrNaPost := .T.
         ELSE
            cFilt += ".and." + iif( FieldPos( "ID_J" ) == 0, "Id", "ID_J" ) + "=" + Token( cUslov, " ", 1 )
         ENDIF

      ELSEIF n2 >= 2  // npr ....,GSLO 33 55 77,.......

         IF  FieldPos( Token( cUslov, " ", 1 ) ) <> 0  // radi se o polju unutar baze
            cVarijabla := Token( cUslov, " ", 1 )
         ELSE
            // radi se o polju sifk
            cVarijabla := "IzSifk('" + Alias() + "','" + AllTrim( Token( cUslov, " ", 1 ) ) + ",####',NIL,.f.,.t.)"
         ENDIF


         cOperator := NIL
         cFilt += ".and. ("

         FOR j := 2 TO n2  // sada nastiklaj uslove ...

            DO CASE
            CASE Left( Token( cUslov, " ", j ),1 ) == ">"
               cOperator := ">"
            CASE Left( Token( cUslov, " ", j ),1 ) == "$"
               cOperator := "$"
            CASE Left( Token( cUslov, " ", j ),1 ) == "!"
               cOperator := "!"
            CASE Left( Token( cUslov, " ", j ),2 ) == "<>"
               cOperator := "<>"
            CASE Left( Token( cUslov, " ", j ),1 ) == "<"
               cOperator := "<"
            CASE Left( Token( cUslov, " ", j ),2 ) == ">="
               cOperator := ">="
            CASE Left( Token( cUslov, " ", j ),2 ) == "<="
               cOperator := "<="
            END CASE

            IF cOperator == NIL
               cOperator := "="
               cV2 := SubStr( Token( cUslov, " ", j ),1 )
            ELSE
               IF cOperator == "="
                  cV2 := SubStr( Token( cUslov, " ", j ), Len( cOperator ) )
               ELSE
                  cV2 := SubStr( Token( cUslov, " ", j ), 1 + Len( cOperator ) )
               ENDIF
            ENDIF

            cV2 := StrTran( cV2, "_", " " )  // !!! pretvori "_" u " "


            IF cVarijabla == "IzSifk("
               IF cOperator == "="
                  cVarijabla := StrTran( cVarijabla, "####", cV2 )
               ELSE
                  cVarijabla := StrTran( cVarijabla, ",####", "" )
               ENDIF
            ENDIF

            cTipVar := ValType( &cVarijabla )
            IF j > 2
               cFilt += ".or. "
            ENDIF

            IF cOperator = "$"
               cFilt +=  "'" + cV2 + "'"  + cOperator + cVarijabla
            ELSE
               IF cOperator == "!"
                  cOperator := "!="
               ENDIF

               IF cTipVar == "C"
                  cFilt += cVarijabla + cOperator + "'" + cV2 + "'"
               ELSEIF cTipVar == "N"
                  cFilt += cVarijabla + cOperator + cV2
               ELSEIF cTipVar == "D"
                  cFilt += cVarijabla + "CTOD(" + cOperator + cV2 + ")"
               ENDIF
            ENDIF

         NEXT

         cFilt += ")"

      ENDIF
   NEXT

   IF !fAddNaPost
      SET FILTER TO
   ENDIF

   GO TOP
   // prodji kroz bazu i markiraj
   @ 25, 1 SAY cFilt
   MsgO( "Vršim odabir željenih stavki: ...." )
   nCount := 0
   nCount2 := 0
   DO WHILE !Eof()

      Scatter()
      IF Empty( cFilt ) .OR. &cFilt
         REPLACE _M1_ WITH "*"
         ++nCount2
      ELSE
         IF !fOrNaPost
            REPLACE _M1_ WITH " "
         ENDIF
      ENDIF
      ++nCount
      IF ( nCount % 10 == 0 )
         @ m_x + 6, m_y + 40 SAY nCount
      ENDIF
      SKIP
   ENDDO
   Msgc()

   @ m_x + 1, m_y + 20 SAY  Str( nCount2, 3 ) + "/"

   PRIVATE cFM1 := "_M1_='*'"
   SET FILTER TO  &cFM1
   GO TOP

   RETURN
