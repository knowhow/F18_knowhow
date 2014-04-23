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
// ;

STATIC _LOG_PROMJENE := .F.

STATIC __A_SIFV__ := { { NIL, NIL, NIL }, { NIL, NIL, NIL }, { NIL, NIL, NIL }, { NIL, NIL, NIL } }

FUNCTION PostojiSifra( nDbf, nNtx, nVisina, nSirina, cNaslov, cID, dx, dy,  bBlok, aPoredak, bPodvuci, aZabrane, invert, aZabIsp )

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

   PRIVATE nOrdId

   PushWa()
   PushSifV()

   IF invert == NIL
      invert := .T.
   ENDIF

   SELECT ( nDbf )

   IF rddName() ==  "SQLMIX"

      PopSifV()
      PopWa()

      RETURN p_sifra( nDbf, nNtx, nVisina, nSirina, cNaslov, @cID, dx, dy,  bBlok, aPoredak, bPodvuci, aZabrane, invert, aZabIsp )
   ENDIF



   IF !Used()
      my_use( nDbf, nil, .F. )
   ENDIF

   // setuj match_code polje...
   set_mc_imekol( nDbf )

   nOrderSif := IndexOrd()
   nOrdId := index_tag_num( "ID" )

   sif_set_order( nNTX, nOrdId, @fID_j )

   sif_seek( @cId, @cIdBK, @cUslovSrch, @cNazSrch, fId_j, nOrdId )

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

   IF ( fPonaz .AND. ( cNazSrch == "" .OR. !Trim( cNazSrch ) == Trim( naz ) ) ) ;
         .OR. cId == NIL ;
         .OR. ( !Found() .AND. cNaslov <> NIL ) ;
         .OR. ( cNaslov <> NIL .AND. Left( cNaslov, 1 ) = "#" )

      // if cID == nil - pregled sifrarnika

      lPrviPoziv := .T.

      IF Eof()
         SKIP -1
      ENDIF

      IF cId == NIL
         // idemo bez parametara
         GO TOP
      ENDIF

      ObjDbedit(, nVisina, nSirina,  {|| EdSif( nDbf, cNaslov, bBlok, aZabrane, aZabIsp ) }, cNaslov, "", invert, _komande, 1, bPodvuci, , , aPoredak )

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

      // nisam ni ulazio u objdb
      IF fID_J
         cId := ( nDBF )->id
         __A_SIFV__[ __PSIF_NIVO__, 1 ] := ( nDBF )->ID_J
      ENDIF

   ENDIF

   __A_SIFV__[ __PSIF_NIVO__, 2 ] := RecNo()

   // ispisi naziv

   sif_ispisi_naziv( nDbf, dx, dy )

   SELECT ( nDbf )

   // vrati order sifranika !!
   ordSetFocus( nOrderSif )

   SET FILTER TO
   PopSifV()
   PopWa()

   RETURN .T.

// ------------------------------------------------
// ------------------------------------------------
STATIC FUNCTION sif_set_order( nNTX, nOrdId, fID_j )

   LOCAL nPos

   // POSTAVLJANJE ORDERA...
   DO CASE
   CASE ValType( nNTX ) == "N"

      IF nNTX == 1
         IF nOrdid <> 0
            SET ORDER TO TAG "ID"
         ELSE
            SET ORDER TO TAG "1"
         ENDIF
      ELSE

         IF nOrdid == 0
            SET ORDER TO TAG "2"
         ENDIF
      ENDIF

   CASE ValType( nNTX ) == "C" .AND. Right( Upper( Trim( nNTX ) ), 2 ) == "_J"

      // postavi order na ID_J
      SET ORDER TO tag ( nNTX )
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

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
STATIC FUNCTION sif_seek( cId, cIdBK, cUslovSrch, cNazSrch, fId_j, nOrdId )

   LOCAL _bk := ""
   LOCAL _order := IndexOrd()
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
      sif_dbf_point_or_slash( @cId, @fPoNaz, @nOrdId, @cUslovSrch, @cNazSrch )
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



FUNCTION sif_dbf_point_or_slash( cId, fPoNaz, nOrdId, cUslovSrch, cNazSrch )

   LOCAL _filter

   cId := PadR( cId, 10 )

   IF nOrdid <> 0
      SET ORDER TO TAG "NAZ"
   ELSE
      SET ORDER TO TAG "2"
   ENDIF

   fPoNaz := .T.

   cNazSrch := ""
   cUslovSrch := ""

   IF Left( Trim( cId ), 1 ) == "."

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

// --------------------------
// --------------------------
FUNCTION ID_J( nOffSet )

   IF nOffset = NIL
      nOffset := 1
   ENDIF
   IF __PSIF_NIVO__ + nOffset > 0
      RETURN __A_SIFV__[ __PSIF_NIVO__ + nOffset, 1 ]
   ELSE
      RETURN __A_SIFV__[ 1, 1 ]
   ENDIF

   RETURN

// -------------------------------------------
// setuje match_code imekol {}
// -------------------------------------------
FUNCTION set_mc_imekol( nDBF )

   LOCAL nSeek
   LOCAL bPom

   cFldId := "ID"
   cFldMatchCode := "MATCH_CODE"

   IF ( nDBF == F_SIFK ) .OR. ( nDBF == F_SIFV ) .OR. ( nDBF == F_OPS )
      RETURN
   ENDIF

   // ako nema polja match code ... nista...
   IF ( nDBF )->( FieldPos( cFldMatchCode ) ) == 0
      RETURN
   ENDIF

   nSeek := AScan( ImeKol, {| xEditFieldNaz| Upper( xEditFieldNaz[ 3 ] ) == "ID" } )

   // setuj prikaz polja
   IF nSeek > 0

      bPom := {|| ;
         PadR( AllTrim( &cFldID ) +  IIF( !Empty( &cFldMatchCode ), ;
         IIF( Len( AllTrim( &cFldMatchCode ) ) > 4, ;
         "/" + Left( AllTrim( &cFldMatchCode ), 2 ) + "..", ;
         "/" + Left( AllTrim( &cFldMatchCode ), 4 ) ), ;
         "" ), ;
         Len( &cFldID ) + 5 ) ;
         }

      ImeKol[ nSeek, 1 ] := "ID/MC"
      ImeKol[ nSeek, 2 ] := bPom


   ENDIF

   RETURN


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

// ------------------------------------------------------------
// -----------------------------------------------------------
STATIC FUNCTION EdSif( nDbf, cNaslov, bBlok, aZabrane, aZabIsp )

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
   LOCAL oDb_lock := F18_DB_LOCK():New
   LOCAL _db_locked := oDb_lock:is_locked()

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

#ifndef TEST

   // provjeri pristup opcijama koje mjenjaju podatke
   IF ( Ch == K_CTRL_N .OR. Ch == K_CTRL_A .OR. Ch == K_F2 .OR. ;
         Ch == K_CTRL_T .OR. Ch == K_F4 .OR. Ch == K_CTRL_F9 .OR. Ch == K_F10 ) .AND. ;
         ( !ImaPravoPristupa( goModul:oDatabase:cName, "SIF", "EDSIF" ) .OR. _db_locked )

      oDb_lock:warrning()
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

   CASE ( Ch == K_CTRL_N .OR. Ch == K_F2 .OR. Ch == K_F4 .OR. Ch == K_CTRL_A )

      Tb:RefreshCurrent()

      IF EditSifItem( Ch, nOrder, aZabIsp ) == 1
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
      SifPopup( nOrder )
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
FUNCTION EditSifItem( Ch, nOrder, aZabIsp )

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

   nPrevRecNo := RecNo()

   lNovi := .F.

   IF _LOG_PROMJENE == .T.
      // daj stare vrijednosti
      cOldDesc := _g_fld_desc( "w" )
   ENDIF

   add_match_code( @ImeKol, @Kol )

   __A_SIFV__[ __PSIF_NIVO__, 3 ] :=  Ch

   IF Ch == K_CTRL_N .OR. Ch == K_F2

      IF nOrdid <> 0
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

      // setuj varijable za tekuci slog
      SetSifVars()

      IF Ch == K_CTRL_N
         // naštimaj default vrijednosti za sifrarnik robe
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
      FOR _jg := 1 TO 3  // glavna petlja

         // moguca su  tri get ekrana

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

               // ne prikazuj nil vrijednosti
               IF Eval( ImeKol[ i, 2 ] ) <> NIL .AND. ToStr( Eval( ImeKol[ i, 2 ] ) ) <> "_?_"
                  IF nKolona = 1
                     ++nTekRed
                  ENDIF
                  @ m_x + nTekRed, m_y + nKolona SAY PadL( AllTrim( ImeKol[ i, 1 ] ),15 )
                  @ m_x + nTekRed, Col() + 1 SAY Eval( ImeKol[ i, 2 ] )
               ELSE
                  ++nNestampati
               ENDIF

            ENDIF

            i++

            // ! sljedeci slog se stampa u istom redu
            IF ( Len( imeKol ) < i ) .OR. ( nTekRed > Min( MAXROWS() -7, nTrebaRedova ) .AND. !( Len( ImeKol[ i ] ) >= 10 .AND. imekol[ i, 10 ] <> NIL )  )
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

         _vars := get_dbf_global_memvars( "w" )
         _alias := Lower( Alias() )

         IF !f18_lock_tables( { _alias, "sifv", "sifk" } )
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
      ordSetFocus( nOrder )
   ENDIF

   IF LastKey() == K_ESC

      IF lNovi
         GO ( nPrevRecNo )
      ENDIF

      RETURN 0

   ENDIF

   //
   // ako je novi zapis napravi APPEND BLANK
   //

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

   //
   // uzmi mi varijable sa unosne maske
   //

   _vars := get_dbf_global_memvars( "w" )

   //
   // lokuj tabele i napravi update zapisa....
   //

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



STATIC FUNCTION sif_getlist( var_name, GetList, lZabIsp, aZabIsp, lShowGrup, Ch, nGet, i, nTekRed )

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
FUNCTION SifPopup( nOrder )

   PRIVATE Opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor

   AAdd( Opc, "1. novi                  " )
   AAdd( opcexe, {|| EditSifItem( K_CTRL_N, nOrder ) } )
   AAdd( Opc, "2. edit  " )
   AAdd( opcexe, {|| EditSifItem( K_F2, nOrder ) } )
   AAdd( Opc, "3. dupliciraj  " )
   AAdd( opcexe, {|| EditSifItem( K_F4, nOrder ) } )
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
   // ova fja se uvijek poziva nakon Edsif-a
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


// -----------------------------------------
// nadji sifru, v2 funkcije
// -----------------------------------------
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

      // postavi filter na numericke sifre
      SET FILTER to &cFilter

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

      IF nOrdId <> 0
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
FUNCTION NNSifru()

   LOCAL cPom
   LOCAL nDuzSif := 0
   LOCAL lPopuni := .F.
   LOCAL nDuzUn := 0
   LOCAL cLast := Chr( 252 ) + Chr( 253 )
   LOCAL nKor := 0

   IF IzFmkIni( "NovaSifraOpc_F8", "PopunjavaPraznine", "N" ) == "D"
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

      IF nOrdId <> 0
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



// ---------------------------------------------------------------------
// VpSifra(wId)
// Stroga kontrola ID-a sifre pri unosu nove ili ispravci postojece!
// wId - ID koji se provjerava
// --------------------------------------------------------------------
FUNCTION VpSifra( wId, cTag )

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



/*! \fn VpNaziv(wNaziv)
 *  \brief Stroga kontrola naziva sifre pri unosu nove ili ispravci postojece sifre
 *  \param wNaziv - Naziv koji se provjerava
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
         // bio isti zapis, idi na drugi
         SKIP 1
         IF !Eof() .AND. wNaziv == naz
            MsgBeep( cUpozorenje + AllTrim( cId ) + " !!!" )
            nRet := .F.
         ENDIF
      ENDIF
   ENDIF

   SET ORDER TO TAG "ID"
   GO nRec

   RETURN nRet


// ---------------------------------
// ---------------------------------
FUNCTION ImaSlovo( cSlova, cString )

   LOCAL i

   FOR i := 1 TO Len( cSlova )
      IF SubStr( cSlova, i, 1 )  $ cString
         RETURN .T.
      ENDIF
   NEXT

   RETURN .F.

// ------------------------------
// ------------------------------
FUNCTION UslovSif()

   LOCAL aStruct := dbStruct()

   SkratiAZaD( @aStruct )

   Box( "", IF( Len( aStruct ) > 22, 22, Len( aStruct ) ), 67, .F.,"", "Postavi kriterije za pretrazivanje" )

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
      IF Left( cfilter, 8 ) == ".t..and."
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
   ImeKol := { { PadR( "Id", 15 ),      {|| id }, "id"  },;
      { PadR( "Naz", 25 ),     {|| naz }, "naz" },;
      { PadR( "Sort", 4 ),     {|| sort }, "sort" },;
      { PadR( "Oznaka", 4 ),   {|| oznaka }, "oznaka" },;
      { PadR( "Veza", 4 ),     {|| veza }, "veza" },;
      { PadR( "Izvor", 15 ),   {|| izvor }, "izvor" },;
      { PadR( "Uslov", 30 ),   {|| PadR( uslov, 30 ) }, "uslov" },;
      { PadR( "Tip", 3 ),      {|| tip }, "tip" },;
      { PadR( "Unique", 3 ),   {|| f_unique }, "f_unique", NIL, NIL, NIL, NIL, NIL, NIL, 20 },;
      { PadR( "Duz", 3 ),      {|| duzina }, "duzina" },;
      { PadR( "Dec", 3 ),      {|| f_decimal }, "f_decimal" },;
      { PadR( "K Validacija", 50 ), {|| PadR( KValid, 50 ) }, "KValid" },;
      { PadR( "K When", 50 ),  {|| KWhen }, "KWhen" },;
      { PadR( "UBrowsu", 4 ),  {|| UBrowsu }, "UBrowsu" },;
      { PadR( "EdKolona", 4 ), {|| EdKolona }, "EdKolona" },;
      { PadR( "K1", 4 ),       {|| k1 }, "k1" },;
      { PadR( "K2", 4 ),       {|| k2 }, "k2" },;
      { PadR( "K3", 4 ),       {|| k3 }, "k3" },;
      { PadR( "K4", 4 ),       {|| k4 }, "k4" }             ;
      }

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   RETURN PostojiSifra( F_SIFK, 1, MAXROWS() -15, MAXCOLS() -15, "sifk - Karakteristike", @cId, dx, dy )

// nadji novu sifru - radi na pritisak F5 pri unosu
// nove sifre
FUNCTION NNSifru2()

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
   cNumDio := IzFMKINI( "ROBA", "NumDio", "SUBSTR(ID,7,3)", SIFPATH )
   cPom2   := &( cImeVar )
   nDuz    := Len( cPom2 )
   cPom2   := RTrim( cPom2 )
   cPom    := cK1 + Chr( 255 )
   PushWA()

   nOrder := index_tag_num( "BROBA" )
   IF nOrder = 0
      MsgBeep( "Ako ste u mrezi, svi korisnici moraju napustiti FMK. Zatim pritisnite Enter!" )
      MsgO( "Kreiram tag(index) 'BROBA'" )
      cSort := IzFMKINI( "ROBA", "Sort", "K1+SUBSTR(ID,7,3)", SIFPATH )
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

   RETURN

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
