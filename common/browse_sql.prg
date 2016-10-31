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
#include "f18_color.ch"

MEMVAR TB, Ch, GetList, goModul
MEMVAR m_x, m_y
MEMVAR bGoreREd, bDoleRed, bDodajRed, fTBNoviRed, TBCanClose, TBAppend, bZaglavlje, TBScatter, nTBLine, nTBLastLine, TBPomjerise
MEMVAR TBSkipBlock

MEMVAR  ImeKol, Kol
MEMVAR  azImeKol, azKol  // snimaju stanje ImeKol, Kol

MEMVAR cKolona

/*

 * brief Glavna funkcija tabelarnog prikaza podataka
 * param cImeBoxa - ime box-a
 * param xw - duzina
 * param yw - sirina
 * param bUserF - kodni blok, user funkcija
 * param cMessTop - poruka na vrhu
 * return NIL
 *

 brief Privatna Varijabla koja se inicijalizira prije "ulaska" u ObjDBedit
 param - [ 1] Zalavlje kolone
 param - [ 2] kodni blok za prikaz kolone {|| id}
 param - [ 3] izraz koji se edituje (string), obradjuje sa & operatorom
 param - [ 4] kodni blok When
 param - [ 5] kodni blok Valid
 param - [ 6] -
 param - [ 7] picture
 param - [ 8] - ima jos getova
 param - [ 9] -
 param - [10] NIL - prikazi u sljedecem redu,  15 - prikazi u koloni my+15  broj kolone pri editu sa <F2>
*/

FUNCTION my_db_edit_sql( cImeBoxa, xw, yw, bUserF, cMessTop, cMessBot, lInvert, aMessage, nFreeze, bPodvuci, nPrazno, nGPrazno, aPoredak, skipblock )

   LOCAL _params := hb_Hash()
   LOCAL nBroji2
   LOCAL cSmj, nRez, i, K, aUF, cPomDB, nTTrec
   LOCAL cLoc := Space( 40 )
   LOCAL cStVr, cNovVr, nRec, nOrder, nPored, xcpos, ycpos

   PRIVATE  bGoreRed := NIL
   PRIVATE  bDoleRed := NIL
   PRIVATE  bDodajRed := NIL


   PRIVATE  fTBNoviRed := .F.  // trenutno smo u novom redu ?
   PRIVATE  TBCanClose := .T. // da li se moze zavrsiti unos podataka ?

   PRIVATE  TBAppend := "N"
   PRIVATE  bZaglavlje := NIL // zaglavlje se edituje kada je kursor u prvoj koloni prvog reda

   PRIVATE  TBScatter := "N"  // uzmi samo tekuce polje
   PRIVATE  nTBLine   := 1      // tekuca linija-kod viselinijskog browsa
   PRIVATE  nTBLastLine := 1  // broj linija kod viselinijskog browsa
   PRIVATE  TBPomjerise := "" // ako je ">2" pomjeri se lijevo dva
   // ovo se moze setovati u when/valid fjama

   PRIVATE  TBSkipBlock := {| nSkip| SkipDB( nSkip, @nTBLine ) }


   IF skipblock <> NIL
      // ovo je zadavanje skip bloka kroz parametar
      TBSkipBlock := skipblock
   ELSE
      TBSkipBlock := NIL
   ENDIF

   PRIVATE bTekCol
   PRIVATE Ch := 0

   PRIVATE azImeKol := ImeKol
   PRIVATE azKol := Kol

   IF nPrazno == NIL
      nPrazno := 0
   ENDIF

   IF nGPrazno == NIL
      nGPrazno := 0
   ENDIF

   IF aPoredak == NIL
      aPoredak := {}
   ENDIF

   IF ( nPored := Len( aPoredak ) ) > 1
      AAdd( aMessage, "<c+U> - Uredi" )
   ENDIF

   PRIVATE TB

   IF lInvert == NIL
      lInvert := .F.
   ENDIF

   _params[ "ime" ]           := cImeBoxa
   _params[ "xw" ]            := xw
   _params[ "yw" ]            := yw
   _params[ "invert" ]        := lInvert
   _params[ "msgs" ]          := aMessage
   _params[ "freeze" ]        := nFreeze
   _params[ "msg_bott" ]      := cMessBot
   _params[ "msg_top" ]       := cMessTop
   _params[ "prazno" ]        := nPrazno
   _params[ "gprazno" ]       := nGPrazno
   _params[ "podvuci_b" ]     := bPodvuci

   browse_only( _params, .T. )

   DO WHILE .T.

      Ch := Inkey()

      IF Deleted()
         // nalazim se na brisanom record-u
         SKIP
         IF Eof()
            Tb:Down()
         ELSE
            Tb:Up()
         ENDIF
         Tb:RefreshCurrent()
      ENDIF


      DO WHILE !TB:stable .AND. ( Ch := Inkey() ) == 0
         Tb:stabilize()
      ENDDO

      IF TB:stable .AND. ( Ch := Inkey() ) == 0

         IF bUserF <> NIL
            xcpos := Row()
            ycpos := Col()
            Eval( bUserF )
            @ xcpos, ycpos SAY ""
         ENDIF

         Ch := Inkey( 0 )
      ENDIF

      IF bUserF <> NIL

         DO WHILE !TB:stabilize()
         END

         nRez := Eval( bUserF )

      ELSE
         nRez := DE_CONT
      ENDIF

      DO CASE

      CASE Ch == K_UP
         TB:up()

      CASE Ch == K_DOWN
         TB:down()

      CASE Ch == K_LEFT
         TB:Left()

      CASE Ch == K_RIGHT
         TB:Right()

      CASE Ch == K_PGUP
         TB:PageUp()

      CASE Ch == K_CTRL_PGUP
         Tb:GoTop()
         Tb:Refreshall()

      CASE Ch == K_CTRL_PGDN
         Tb:GoBottom()

      CASE Ch == K_PGDN
         TB:PageDown()

      OTHERWISE
         standardne_browse_komande( Tb, Ch, @nRez, nPored, aPoredak )

      ENDCASE

      DO CASE

      CASE nRez == DE_REFRESH
         TB:RefreshAll()
         @ m_x + 1, m_y + yw - 6 SAY Str( RecCount(), 5 )

      CASE Ch == K_ESC

         IF nPrazno == 0
            BoxC()
         ENDIF
         EXIT

      CASE nRez == DE_ABORT .OR. Ch == K_CTRL_END .OR. Ch == K_ESC

         IF nPrazno == 0
            BoxC()
         ENDIF

         EXIT


      ENDCASE

   ENDDO

   RETURN


STATIC FUNCTION browse_only( params, lIzOBJDB )

   LOCAL i, j, k
   LOCAL _rows, _width

   IF lIzOBJDB == NIL
      lIzOBJDB := .F.
   ENDIF

   _rows        :=  params[ "xw" ]
   _rows_poruke :=  params[ "prazno" ] + iif( params[ "prazno" ] <> 0, 1, 0 )
   _width       :=  params[ "yw" ]

   IF params[ "prazno" ] == 0

      IF !lIzOBJDB
         BoxC()
      ENDIF
      Box( params[ "ime" ], _rows, _width, params[ "invert" ], params[ "msgs" ] )
   ELSE
      @ m_x + params[ "xw" ] - params[ "prazno" ], m_y + 1 SAY Replicate( BROWSE_PODVUCI, params[ "yw" ] )

   ENDIF

   IF !lIzOBJDB
      ImeKol := azImeKol
      Kol := azKol
   ENDIF

   @ m_x, m_y + 2                         SAY params[ "msg_top" ] + iif( !lIzOBJDB, REPL( BROWSE_PODVUCI_2,  42 ), "" )
   @ m_x + params[ "xw" ] + 1,  m_y + 2   SAY params[ "msg_bott" ] COLOR F18_COLOR_MSG_BOTTOM


   @ m_x + params[ "xw" ] + 1,  Col() + 1 SAY iif( !lIzOBJDB, REPL( BROWSE_PODVUCI_2, 42 ), "" )
   @ m_x + 1, m_y + params[ "yw" ] - 6    SAY Str( RecCount(), 5 )


   TB := TBrowseDB( m_x + 2 + params[ "prazno" ], m_y + 1, m_x + _rows - _rows_poruke, m_y + _width )

   IF TBSkipBlock <> NIL
      Tb:skipBlock := TBSkipBlock
   ENDIF

   // Dodavanje kolona  za stampanje
   FOR k := 1 TO Len( Kol )

      i := AScan( Kol, k )
      IF i <> 0
         // TODO: SQL vraca nil .and. (ImeKol[i,2] <> NIL)
         TCol := TBColumnNew( ImeKol[ i, 1 ], ImeKol[ i, 2 ] )

         IF params[ "podvuci_b" ] <> NIL
            TCol:colorBlock := {|| iif( Eval( params[ "podvuci_b" ] ), { 5, 2 }, { 1, 2 } ) }
         ENDIF

         TB:addColumn( TCol )
      END IF

   NEXT

   TB:headSep := BROWSE_HEAD_SEP
   TB:colsep :=  BROWSE_COL_SEP

   IF params[ "freeze" ] == NIL
      TB:Freeze := 1
   ELSE
      Tb:Freeze := params[ "freeze" ]
   ENDIF

   RETURN


STATIC FUNCTION ForceStable()

   DO WHILE ! TB:stabilize()
   ENDDO

   RETURN .T.



STATIC FUNCTION standardne_browse_komande( TB, Ch, nRez, nPored, aPoredak )

   LOCAL _tr := hb_UTF8ToStr( "Traži:" ), _zam := "Zamijeni sa:"
   LOCAL _last_srch := "N"
   LOCAL cSmj, i, K, aUF
   LOCAL cLoc := Space( 40 )
   LOCAL cStVr, cNovVr, nRec, nOrder, xcpos, ycpos
   LOCAL _trazi_val, _zamijeni_val, _trazi_usl
   LOCAL _sect, _pict
   LOCAL _rec, _saved

   DO CASE


   CASE Ch == K_CTRL_F

      bTekCol := ( TB:getColumn( TB:colPos ) ):Block

      IF ValType( Eval( bTekCol ) ) == "C"

         Box( "bFind", 2, 50, .F. )
         PRIVATE GetList := {}
         SET CURSOR ON
         cLoc := PadR( cLoc, 40 )
         cSmj := "+"
         @ m_x + 1, m_y + 2 SAY _tr GET cLoc PICT "@!"
         @ m_x + 2, m_y + 2 SAY "Prema dolje (+), gore (-)" GET cSmj VALID cSmj $ "+-"
         READ
         BoxC()

         IF LastKey() <> K_ESC

            cLoc := Trim( cLoc )
            aUf := nil
            IF Right( cLoc, 1 ) == ";"
               Beep( 1 )
               aUF := Parsiraj( cLoc, "EVAL(bTekCol)" )
            ENDIF
            Tb:hitTop := TB:hitBottom := .F.
            DO WHILE !( Tb:hitTop .OR. TB:hitBottom )
               IF aUF <> NIL
                  IF Tacno( aUF )
                     EXIT
                  ENDIF
               ELSE
                  IF Upper( Left( Eval( bTekCol ), Len( cLoc ) ) ) == cLoc
                     EXIT
                  ENDIF
               ENDIF
               IF cSmj = "+"
                  Tb:down()
                  Tb:Stabilize()
               ELSE
                  Tb:Up()
                  Tb:Stabilize()
               ENDIF

            ENDDO
            Tb:hitTop := TB:hitBottom := .F.
         ENDIF
      ENDIF

   CASE Ch == K_ALT_R // trazi-zamjeni opcija nad string, datum poljima


      PRIVATE cKolona
      cKolona := ImeKol[ TB:ColPos, 3 ]

      IF Len( Imekol[ TB:colPos ] ) > 2 .AND. !Empty( cKolona ) .AND. ValType( &cKolona ) $ "CD"

         Box(, 3, 60, .F. )

         PRIVATE GetList := {}
         SET CURSOR ON

         @ m_x + 1, m_y + 2 SAY "Uzmi podatke posljednje pretrage ?" GET _last_srch VALID _last_srch $ "DN" PICT "@!"

         READ

         // svako polje ima svoj parametar
         _sect := "_brow_fld_find_" + AllTrim( Lower( cKolona ) )
         _trazi_val := &cKolona

         IF _last_srch == "D"
            _trazi_val := fetch_metric( _sect, "<>", _trazi_val )
         ENDIF

         _zamijeni_val := _trazi_val
         _sect := "_brow_fld_repl_" + AllTrim( Lower( cKolona ) )

         IF _last_srch == "D"
            _zamijeni_val := fetch_metric( _sect, "<>", _zamijeni_val )
         ENDIF

         _pict := ""

         IF ValType( _trazi_val ) == "C" .AND. Len( _trazi_val ) > 45
            _pict := "@S45"
         ENDIF

         @ m_x + 2, m_y + 2 SAY PadR( _tr, 12 ) GET _trazi_val PICT _pict
         @ m_x + 3, m_y + 2 SAY PadR( _zam, 12 ) GET _zamijeni_val PICT _pict

         READ

         BoxC()

         IF LastKey() == K_ESC
            RETURN DE_CONT
         ENDIF

         IF replace_kolona_in_table( cKolona, _trazi_val, _zamijeni_val, _last_srch )
            TB:RefreshAll()
         ELSE
            RETURN DE_CONT
         ENDIF

      ENDIF



   CASE Ch == K_ALT_S

      PRIVATE cKolona


      cKolona := ImeKol[ TB:ColPos, 3 ]

      IF Len( Imekol[ TB:colPos ] ) > 2 .AND. !Empty( cKolona ) .AND. ValType( &cKolona ) == "N"

         Box(, 3, 66, .F. )

         PRIVATE GetList := {}
         SET CURSOR ON

         _trazi_val := &cKolona
         _trazi_usl := Space( 80 )

         @ m_x + 1, m_y + 2 SAY "Postavi na:" GET _trazi_val
         @ m_x + 2, m_y + 2 SAY "Uslov za obuhvatanje stavki (prazno-sve):" GET _trazi_usl ;
            PICT "@S20" ;
            VALID Empty( _trazi_usl ) .OR. alt_s_provjeri_tip_uslova( _trazi_usl, "Greska! Neispravno postavljen uslov!" )

         READ

         BoxC()

         IF LastKey() == K_ESC
            RETURN DE_CONT
         ENDIF

         IF zamjeni_numericka_polja_u_tabeli( cKolona, _trazi_val, _trazi_usl )
            TB:RefreshAll()
         ELSE
            RETURN DE_CONT
         ENDIF

      ENDIF



   CASE Ch == K_CTRL_U .AND. nPored > 1

      PRIVATE GetList := {}
      nRez := IndexOrd()
      Prozor1( 12, 20, 17 + nPored, 59, "UTVRĐIVANJE PORETKA", F18_COLOR_NASLOV, F18_COLOR_OKVIR, F18_COLOR_TEKST, 2 )
      FOR i := 1 TO nPored
         @ 13 + i, 23 SAY PadR( "poredak po " + aPoredak[ i ], 33, "ú" ) + Str( i, 1 )
      NEXT
      @ 18, 27 SAY "UREDITI TABELU PO BROJU:" GET nRez VALID nRez > 0 .AND. nRez < nPored + 1 PICT "9"
      READ
      Prozor0()

      IF LastKey() != K_ESC
         dbSetOrder( nRez + 1 )
         nRez := DE_REFRESH
      ELSE
         nRez := DE_CONT
      ENDIF

   OTHERWISE
      IF ValType( goModul ) == "O"
         goModul:gProc( Ch )
      ENDIF
   ENDCASE

   RETURN .T.



STATIC FUNCTION StandTBTipke()

   IF Ch == K_ESC .OR. Ch == K_CTRL_T .OR. Ch = K_CTRL_P .OR. Ch = K_CTRL_N .OR. ;
         Ch == K_ALT_A .OR. Ch == K_ALT_P .OR. Ch = K_ALT_S .OR. Ch = K_ALT_R .OR. ;
         Ch == K_DEL .OR. Ch = K_F2 .OR. Ch = K_F4 .OR. Ch = K_CTRL_F9 .OR. Ch = 0
      RETURN .T.
   ENDIF

   RETURN .F.





STATIC FUNCTION EditPolja( nX, nY, xIni, cNazPolja, bWhen, bValid, cBoje )

   LOCAL i
   LOCAL cPict
   LOCAL bGetSet
   LOCAL nSirina

   IF TBScatter == "N"
      cPom77I := cNazpolja
      cPom77U := "w" + cNazpolja
      &cPom77U := xIni
   ELSE
      Scatter()
      IF FieldPos( cNazPolja ) <> 0 // field varijabla
         cPom77I := cNazpolja
         cPom77U := "_" + cNazpolja
      ELSE
         cPom77I := cNazpolja
         cPom77U := cNazPolja
      ENDIF
   ENDIF

   cpict := NIL
   IF Len( ImeKol[ TB:Colpos ] ) >= 7  // ima picture
      cPict := ImeKol[ TB:Colpos, 7 ]
   ENDIF


   // provjeriti kolika je sirina get-a!!

   aTBGets := {}
   get := GetNew( nX, nY, MemVarBlock( cPom77U ), ;
      cPom77U, cPict, "W+/BG,W+/B" )
   get:PreBlock := bWhen
   get:PostBlock := bValid
   AAdd( aTBGets, Get )
   nSirina := 8
   IF cPict <> NIL
      nSirina := Len( Transform( &cPom77U, cPict ) )
   ENDIF

   IF Len( ImeKol[ TB:Colpos ] ) >= 8  // ima jos getova
      aPom := ImeKol[ TB:Colpos, 8 ]  // matrica
      FOR i := 1 TO Len( aPom )
         nY := nY + nSirina + 1
         get := GetNew( nX, nY, MemVarBlock( aPom[ i, 1 ] ), ;
            aPom[ i, 1 ], aPom[ i, 4 ], "W+/BG,W+/B" )
         nSirina := Len( Transform( &( aPom[ i, 1 ] ), aPom[ i, 4 ] ) )
         get:PreBlock := aPom[ i, 2 ]
         get:PostBlock := aPom[ i, 3 ]
         AAdd( aTBGets, Get )
      NEXT

      IF nY + nSirina > MAXCOLS() -2

         FOR i := 1 TO Len( aTBGets )
            aTBGets[ i ]:Col := aTBGets[ i ]:Col  - ( nY + nSirina - 78 ) // smanji col koordinate

         NEXT
      ENDIF

   ENDIF

   ReadModal( aTBGets )

   IF TBScatter = "N"
      // azuriraj samo ako nije zadan when blok !
      REPLACE &cPom77I WITH &cPom77U
      sql_azur( .T. )
      // REPLSQL &cPom77I WITH &cPom77U
   ELSE
      IF LastKey() != K_ESC .AND. cPom77I <> cPom77U  // field varijabla
         Gather()
         sql_azur( .T. )
         GathSQL()
      ENDIF
   ENDIF

   RETURN .T.


/* function TBPomjeranje(TB, cPomjeranje)
 *     Opcije pomjeranja tbrowsea u direkt rezimu
 *   param: TB          -  TBrowseObjekt
 *   param: cPomjeranje - ">", ">2", "V0"
 */

STATIC FUNCTION TBPomjeranje( TB, cPomjeranje )

   LOCAL cPomTB

   IF ( cPomjeranje ) = ">"
      cPomTb := SubStr( cPomjeranje, 2, 1 )
      TB:Right()
      IF !Empty( cPomTB )
         FOR i := 1 TO Val( cPomTB )
            TB:Right()
         NEXT
      ENDIF

   ELSEIF ( cPomjeranje ) = "V"
      TB:Down()
      cPomTb := SubStr( cPomjeranje, 2, 1 )
      IF !Empty( cPomTB )
         TB:PanHome()
         FOR i := 1 TO Val( cPomTB )
            TB:Right()
         NEXT
      ENDIF
      IF bDoleRed = NIL .OR. Eval( bDoleRed )
         fTBNoviRed := .F.
      ENDIF
   ELSEIF ( cPomjeranje ) = "<"
      TB:Left()
   ELSEIF ( cPomjeranje ) = "0"
      TB:PanHome()
   ENDIF



FUNCTION browse_brisi_stavku( lPack )

   IF lPack == NIL
      lPack := .T.
   ENDIF

   IF Pitanje( , "Želite izbrisati ovu stavku ?", "D" ) == "D"

      my_rlock()
      DELETE
      my_unlock()

      IF lPack
         my_dbf_pack()
      ENDIF

      RETURN DE_REFRESH
   ENDIF

   RETURN DE_CONT


FUNCTION browse_brisi_pripremu()

   IF Pitanje(, D_ZELITE_LI_IZBRISATI_PRIPREMU, "N" ) == "D"
      my_dbf_zap()
      RETURN DE_REFRESH
   ENDIF

   RETURN DE_CONT
