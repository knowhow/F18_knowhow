/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"


// -----------------------------------------
// otvaranje tabele sastavnica
// -----------------------------------------
FUNCTION p_sast( cId, dx, dy )

   PRIVATE ImeKol
   PRIVATE Kol

   SELECT roba

   set_a_kol( @ImeKol, @Kol )

   GO TOP

   RETURN PostojiSifra( F_ROBA, "IDP", MAXROWS() -15, MAXCOLS() -3, "Gotovi proizvodi: <ENTER> Unos norme, <Ctrl-F4> Kopiraj normu, <F7>-lista norm.", @cId, dx, dy, {| Ch| key_handler( Ch ) } )


// ---------------------------------
// setovanje kolona tabele
// ---------------------------------
STATIC FUNCTION set_a_kol( aImeKol, aKol )

   LOCAL cPom
   LOCAL cPom2

   aImeKol := {}
   aKol := {}

   AAdd( aImeKol, { PadC( "ID", 10 ), {|| id }, "id", {|| .T. }, {|| sifra_postoji( wId ) } } )
   AAdd( aImeKol, { PadC( "Naziv", 20 ), {|| PadR( naz, 20 ) }, "naz" } )
   AAdd( aImeKol, { PadC( "JMJ", 3 ), {|| jmj }, "jmj" } )
   AAdd( aImeKol, { PadC( "VPC", 10 ), {|| Transform( VPC, "999999.999" ) }, "vpc" } )

   // VPC2
   IF ( roba->( FieldPos( "vpc2" ) ) <> 0 )
      AAdd( aImeKol, { PadC( "VPC2", 10 ), {|| Transform( VPC2, "999999.999" ) }, "vpc2" } )
   ENDIF

   AAdd( aImeKol, { PadC( "MPC", 10 ), {|| Transform( MPC, "999999.999" ) }, "mpc" } )

   FOR i := 2 TO 10
      cPom := "MPC" + AllTrim( Str( i ) )
      cPom2 := '{|| transform(' + cPom + ',"999999.999")}'
      IF roba->( FieldPos( cPom ) )  <>  0
         AAdd ( aImeKol, { PadC( cPom, 10 ), ;
            &( cPom2 ),;
            cPom } )
      ENDIF
   NEXT

   AAdd( aImeKol, { PadC( "NC", 10 ), {|| Transform( NC, "999999.999" ) }, "NC" } )

   AAdd( aImeKol, { "Tarifa", {|| IdTarifa }, "IdTarifa", {|| .T. }, {|| P_Tarifa( @wIdTarifa ), roba_opis_edit() } } )

   AAdd( aImeKol, { "K1", {|| K1 }, "K1", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { "Tip", {|| " " + Tip + " " }, "Tip", {|| .T. }, {|| wTip $ "P" } } )

   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN



// -------------------------------
// obrada tipki
// -------------------------------
STATIC FUNCTION key_handler( Ch )

   LOCAL nUl
   LOCAL nIzl
   LOCAL nRezerv
   LOCAL nRevers
   LOCAL nIOrd
   LOCAL nFRec
   LOCAL aStanje

   nTRec := RecNo()

   nReturn := DE_CONT

   DO CASE

   CASE Ch == K_CTRL_F9
      // brisanje sastavnica i proizvoda
      bris_sast()
      nReturn := 7

   CASE Ch == K_ENTER
      // prikazi sastavnicu
      show_sast()
      nReturn := DE_REFRESH

   CASE Ch == K_CTRL_F4
      // kopiranje sastavnica u drugi proizvod
      copy_sast()
      nReturn := DE_REFRESH

   CASE Ch == K_F7
      // lista sastavnica
      ISast()
      nReturn := DE_REFRESH

   CASE Ch == K_F10
      // ostale opcije
      ost_opc_sast()
      nReturn := DE_CONT

   ENDCASE

   SET ORDER TO TAG "IDP"
   GO ( nTRec )

   RETURN nReturn

// -----------------------------------------
// zamjena sastavnice u svim proizvodima
// -----------------------------------------
STATIC FUNCTION sast_repl_all()

   LOCAL lOk := .T.
   LOCAL cOldS
   LOCAL cNewS
   LOCAL nKolic
   LOCAL _rec

   cOldS := Space( 10 )
   cNewS := Space( 10 )
   nKolic := 0

   Box(, 6, 70 )
   @ m_x + 1, m_y + 2 SAY "'Stara' sirovina :" GET cOldS PICT "@!" VALID P_Roba( @cOldS )
   @ m_x + 2, m_y + 2 SAY "'Nova'  sirovina :" GET cNewS PICT "@!" VALID cNewS <> cOldS .AND. P_Roba( @cNewS )
   @ m_x + 4, m_y + 2 SAY "Kolicina u normama (0 - zamjeni bez obzira na kolicinu)" GET nKolic PICT "999999.99999"
   READ
   BoxC()

   IF ( LastKey() <> K_ESC )

      sql_table_update( nil, "BEGIN" )
      IF !f18_lock_tables( { "sast" }, .T. )
         sql_table_update( nil, "END" )
         MsgBeep( "Greska sa lock-om tabele sast !" )
         RETURN .F.
      ENDIF

      SELECT sast
      SET ORDER TO
      GO TOP

      DO WHILE !Eof()
         IF id2 == cOldS
            IF ( nKolic = 0 .OR. Round( nKolic - kolicina, 5 ) = 0 )
               _rec := dbf_get_rec()
               _rec[ "id2" ] := cNewS
               lOk := update_rec_server_and_dbf( "sast", _rec, 1, "CONT" )
            ENDIF
         ENDIF
         IF !lOk
            EXIT
         ENDIF
         SKIP
      ENDDO

      IF lOk
         f18_free_tables( { "sast" } )
         sql_table_update( nil, "END" )
      ELSE
         sql_table_update( nil, "ROLLBACK" )
      ENDIF

      SET ORDER TO TAG "idrbr"

   ENDIF

   RETURN


// ------------------------
// promjena ucesca
// ------------------------
STATIC FUNCTION pr_uces_sast()

   LOCAL lOk := .T.
   LOCAL cOldS
   LOCAL cNewS
   LOCAL nKolic
   LOCAL nKolic2
   LOCAL _rec

   cOldS := Space( 10 )
   cNewS := Space( 10 )
   nKolic := 0
   nKolic2 := 0

   Box(, 6, 65 )
   @ m_x + 1, m_y + 2 SAY "Sirovina :" GET cOldS PICT "@!" VALID P_Roba( @cOldS )
   @ m_x + 4, m_y + 2 SAY "postojeca kolicina u normama " GET nKolic PICT "999999.99999"
   @ m_x + 5, m_y + 2 SAY "nova kolicina u normama      " GET nKolic2 PICT "999999.99999"   VALID nKolic <> nKolic2
   READ
   BoxC()

   IF ( LastKey() <> K_ESC )

      sql_table_update( nil, "BEGIN" )
      IF !f18_lock_tables( { "sast" }, .T. )
         sql_table_update( nil, "END" )
         MsgBeep( "Greska sa lock-om tabele sast !" )
         RETURN
      ENDIF

      SELECT sast
      SET ORDER TO
      GO TOP

      DO WHILE !Eof()

         IF PadR( field->id2, 10 ) == PadR( cOldS, 10 )
            IF Round( nKolic - field->kolicina, 5 ) = 0
               _rec := dbf_get_rec()
               _rec[ "kolicina" ] := nKolic2
               lOk := update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )
            ENDIF
         ENDIF

         IF !lOk
            EXIT
         ENDIF

         SKIP

      ENDDO

      IF lOk
         f18_free_tables( { "sast" } )
         sql_table_update( nil, "END" )
      ELSE
         sql_table_update( nil, "ROLLBACK" )
      ENDIF

      SET ORDER TO TAG "idrbr"
   ENDIF

   RETURN



// ----------------------------------------
// ostale opcije nad sastavnicama
// ----------------------------------------
STATIC FUNCTION ost_opc_sast()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1
   LOCAL _am_x := m_x
   LOCAL _am_y := m_y

   AAdd( _opc, "1. zamjena sirovine u svim sastavnicama                 " )
   AAdd( _opcexe, {|| sast_repl_all() } )
   AAdd( _opc, "2. promjena ucesca pojedine sirovine u svim sastavnicama" )
   AAdd( _opcexe, {|| pr_uces_sast() } )
   AAdd( _opc, "------------------------------------" )
   AAdd( _opcexe, {|| notimp() } )
   AAdd( _opc, "L. pregled sastavnica sa pretpostavkama sirovina" )
   AAdd( _opcexe, {|| pr_pr_sast() } )
   AAdd( _opc, "M. lista sastavnica koje (ne)sadrze sirovinu x" )
   AAdd( _opcexe, {|| pr_ned_sast() } )
   AAdd( _opc, "D. sifre sa duplim sastavnicama" )
   AAdd( _opcexe, {|| pr_dupl_sast() } )
   AAdd( _opc, "P. pregled brojnog stanja sastavnica" )
   AAdd( _opcexe, {|| pr_br_sast() } )
   AAdd( _opc, "E. export sastavnice -> dbf" )
   AAdd( _opcexe, {|| _exp_sast_dbf() } )
   AAdd( _opc, "F. export roba -> dbf" )
   AAdd( _opcexe, {|| _exp_roba_dbf() } )

   f18_menu( "o_sast", .F., _izbor, _opc, _opcexe )

   m_x := _am_x
   m_y := _am_y

   RETURN


// ---------------------------------
// kopiranje sastavnica
// ---------------------------------
STATIC FUNCTION copy_sast()

   LOCAL lOk := .T.
   LOCAL nTRobaRec
   LOCAL cNoviProizvod
   LOCAL cIdTek
   LOCAL nTRec
   LOCAL nCnt := 0
   LOCAL _rec

   nTRobaRec := RecNo()

   IF Pitanje(, "Kopirati postojeće sastavnice u novi proizvod", "N" ) == "D"

      cNoviProizvod := Space( 10 )
      cIdTek := field->id

      Box(, 2, 60 )
      @ m_x + 1, m_y + 2 SAY "Kopirati u proizvod:" GET cNoviProizvod VALID cNoviProizvod <> cIdTek .AND. p_roba( @cNoviProizvod ) .AND. roba->tip == "P"
      READ
      BoxC()

      IF ( LastKey() <> K_ESC )

         sql_table_update( nil, "BEGIN" )
         IF !f18_lock_tables( { "sast" }, .T. )
            sql_table_update( nil, "END" )
            MsgBeep( "lock sast neuspjesno !" )
            RETURN .F.
         ENDIF

         SELECT sast
         SET ORDER TO TAG "idrbr"
         SEEK cIdTek
         nCnt := 0


         DO WHILE !Eof() .AND. ( id == cIdTek )
            ++ nCnt
            nTRec := RecNo()
            _rec := dbf_get_rec()
            _rec[ "id" ] := cNoviProizvod
            APPEND BLANK

            lOk := update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )

            IF !lOk
               EXIT
            ENDIF

            GO ( nTrec )
            SKIP

         ENDDO

         IF lOk
            f18_free_tables( { "sast" } )
            sql_table_update( nil, "END" )
         ELSE
            sql_table_update( nil, "ROLLBACK" )
         ENDIF

         SELECT roba
         SET ORDER TO TAG "idun"

      ENDIF
   ENDIF

   GO ( nTrobaRec )

   IF ( nCnt > 0 )
      MsgBeep( "Kopirano sastavnica: " + AllTrim( Str( nCnt ) ) )
   ELSE
      MsgBeep( "Ne postoje sastavnice na uzorku za kopiranje!" )
   ENDIF

   RETURN


// --------------------------------
// brisanje sastavnica
// --------------------------------
STATIC FUNCTION bris_sast()

   LOCAL lOk := .T.
   LOCAL _d_n
   LOCAL _t_rec
   LOCAL _rec

   _d_n := "0"

   Box(, 5, 40 )
   @ m_x + 1, m_Y + 2 SAY8 "Odaberite željenu opciju:"
   @ m_x + 3, m_Y + 2 SAY8 "0. Ništa !"
   @ m_x + 4, m_Y + 2 SAY "1. Izbrisati samo sastavnice ?"
   @ m_x + 5, m_Y + 2 SAY "2. Izbrisati i artikle i sastavnice "
   @ m_x + 5, Col() + 2 GET _d_n VALID _d_n $ "012"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN 7
   ENDIF

   sql_table_update( nil, "BEGIN" )
   IF !f18_lock_tables( { "roba", "sast" }, .T. )
      sql_table_update( nil, "END" )
      MsgBeep( "lock roba, sast neuspjeno !" )
      RETURN 7
   ENDIF


   IF _d_n $ "12" .AND. Pitanje(, "Sigurno želite izbrisati definisane sastavnice (D/N) ?", "N" ) == "D"

      SELECT sast
      DO WHILE !Eof()
         SKIP 1
         _t_rec := RecNo()
         SKIP -1
         _rec := dbf_get_rec()
         lOk := delete_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )
         IF !lOk
            EXIT
         ENDIF
         GO ( _t_rec )
      ENDDO

   ENDIF

   IF lOk .AND. _d_n $ "2" .AND. Pitanje(, "Sigurno želite izbrisati proizvode (D/N) ?", "N" ) == "D"

      SELECT roba

      DO WHILE !Eof()
         SKIP
         _t_rec := RecNo()
         SKIP -1

         _rec := dbf_get_rec()
         lOk := delete_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )

         IF !lOk
            EXIT
         ENDIF

         GO ( _t_rec )

      ENDDO

   ENDIF

   IF lOk
      f18_free_tables( { "roba", "sast" } )
      sql_table_update( nil, "END" )
   ELSE
      sql_table_update( nil, "ROLLBACK" )
   ENDIF

   RETURN


// ---------------------------
// prikaz sastavnice
// ---------------------------
STATIC FUNCTION show_sast()

   LOCAL nTRobaRec
   PRIVATE cIdTek
   PRIVATE ImeKol
   PRIVATE Kol

   // roba->id
   cIdTek := field->id
   nTRobaRec := RecNo()

   SELECT sast
   SET ORDER TO TAG "idrbr"
   SET FILTER TO id = cIdTek
   GO TOP

   // setuj kolone sastavnice tabele
   sast_a_kol( @ImeKol, @Kol )

   PostojiSifra( F_SAST, "IDRBR", MAXROWS() - 18, 80, cIdTek + "-" + Left( roba->naz, 40 ),,,, {| Char| EdSastBlok( Char ) },,,, .F. )

   // ukini filter
   SET FILTER TO

   SELECT roba
   SET ORDER TO TAG "idun"

   GO nTrobaRec

   RETURN



// ------------------------------------
// ispravka sastavnice
// ------------------------------------
STATIC FUNCTION EdSastBlok( char )

   DO CASE
   CASE char == K_CTRL_F9
      MsgBeep( "Nedozvoljena opcija !!!" )
      RETURN 7
   ENDCASE

   RETURN DE_CONT


// --------------------------------
// sastavnice setovanje kolona
// --------------------------------
STATIC FUNCTION sast_a_kol( aImeKol, aKol )

   aImeKol := {}
   aKol := {}

   // redni broj
   AAdd( aImeKol, { "R.Br", {|| r_br }, "r_br", {|| .T. }, {|| .T. } } )

   // id roba
   AAdd( aImeKol, { PadC( "Sifra sirovine", 20 ), {|| id2 }, "id2", {|| .T. }, {|| wId := cIdTek, p_roba( @wId2 ) } } )

   // kolicina
   AAdd( aImeKol, { "Kolicina", {|| kolicina }, "kolicina" } )

   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN



// ----------------------------------------------------------
// lista sastavnica sa pretpostavljenim sirovinama
// ----------------------------------------------------------
FUNCTION pr_pr_sast()

   LOCAL cSirovine := Space( 200 )
   LOCAL cArtikli := Space( 200 )
   LOCAL cIdRoba
   LOCAL aSast := {}
   LOCAL i
   LOCAL nScan
   LOCAL aError := {}
   LOCAL aArt := {}

   BOX(, 2, 65 )
   @ m_x + 1, m_y + 2 SAY "pr.sirovine:" GET cSirovine PICT "@S40" ;
      VALID !Empty( cSirovine )
   @ m_x + 2, m_y + 2 SAY "uslov za artikle:" GET cArtikli PICT "@S40"
   READ
   BOXC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   // sastavnice u matricu...
   aSast := TokToNiz( AllTrim( cSirovine ), ";" )

   IF !Empty( cArtikli )
      bUsl := Parsiraj( AllTrim( cArtikli ), "ID" )
   ENDIF

   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   DO WHILE !Eof()

      IF field->tip <> "P"
         SKIP
         LOOP
      ENDIF

      IF !Empty( cArtikli )
         if &bUsl
            // idi dalje...
         ELSE
            SKIP
            LOOP
         ENDIF
      ENDIF

      cIdRoba := field->id
      cRobaNaz := ( field->naz )

      SELECT sast
      SET ORDER TO TAG "ID"
      GO TOP
      SEEK cIdRoba

      IF !Found()

         AAdd( aError, { 1, cIdRoba, cRobaNaz, ;
            "ne postoji sastavnica !!!" } )

         SELECT roba
         SKIP
         LOOP

      ENDIF

      i := 0

      cUzorak := ""
      lPostoji := .F.

      DO WHILE !Eof() .AND. field->id == cIdRoba

         // sirovina za
         cUzorak := AllTrim( field->id2 )

         lPostoji := .F.

         FOR i := 1 TO Len( aSast )

            cPretp := aSast[ i ]

            IF cPretp $ cUzorak
               lPostoji := .T.
               EXIT
            ENDIF

         NEXT

         IF lPostoji == .F.
            AAdd( aError, { 2, cIdRoba, roba->naz, "uzorak " + ;
               "se ne poklapa !"  } )
         ENDIF

         SKIP

      ENDDO

      SELECT roba
      SKIP

   ENDDO

   IF Len( aError ) == 0
      msgbeep( "sve ok :)" )
      RETURN
   ENDIF

   START PRINT CRET

   i := 0

   ?

   cLine := Replicate( "-", 5 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 15 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 50 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 50 )

   cTxt := PadR( "rbr", 5 )
   cTxt += Space( 1 )
   cTxt += PadR( "uzrok", 15 )
   cTxt += Space( 1 )
   cTxt += PadR( "artikal / sirovina", 50 )
   cTxt += Space( 1 )
   cTxt += PadR( "opis", 50 )

   P_COND
   ? cLine
   ? cTxt
   ? cLine

   nCnt := 0

   FOR i := 1 TO Len( aError )

      ? PadL( AllTrim( Str( ++nCnt ) ) + ")", 5 )

      IF aError[ i, 1 ] == 1
         cPom := "nema sastavnice"
      ELSE
         cPom := "  fale sirovine"
      ENDIF

      @ PRow(), PCol() + 1 SAY cPom
      @ PRow(), PCol() + 1 SAY PadR( AllTrim( aError[ i, 2 ] ) + "-" + ;
         AllTrim( aError[ i, 3 ] ), 50 )
      @ PRow(), PCol() + 1 SAY PadR( aError[ i, 4 ], 50 )

   NEXT

   FF
   ENDPRINT

   RETURN


// -----------------------------------------------
// pregled brojnog stanja sastavnica
// -----------------------------------------------
FUNCTION pr_br_sast()

   LOCAL nMin := 5
   LOCAL nMax := 15
   LOCAL cArtikli := Space( 200 )
   LOCAL cIdRoba
   LOCAL i
   LOCAL aError := {}

   box(, 3, 65 )
   @ m_x + 1, m_y + 2 SAY "min.broj sastavnica:" GET nMin PICT "999"
   @ m_x + 2, m_y + 2 SAY "max.broj sastavnica:" GET nMax PICT "999"
   @ m_x + 3, m_y + 2 SAY "uslov za artikle:" GET cArtikli PICT "@S40"
   READ
   boxc()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   IF !Empty( cArtikli )
      bUsl := Parsiraj( AllTrim( cArtikli ), "ID" )
   ENDIF

   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   DO WHILE !Eof()

      IF field->tip <> "P"
         SKIP
         LOOP
      ENDIF

      IF !Empty( cArtikli )
         if &bUsl
            // idi dalje...
         ELSE
            SKIP
            LOOP
         ENDIF
      ENDIF

      cIdRoba := field->id

      SELECT sast
      SET ORDER TO TAG "ID"
      GO TOP
      SEEK cIdRoba

      IF !Found()
         SELECT roba
         SKIP
         LOOP
      ENDIF

      nTmp := 0

      // koliko ima sastavnica ?
      DO WHILE !Eof() .AND. field->id == cIdRoba
         ++ nTmp
         SKIP
      ENDDO

      IF ( nTmp < nMin ) .OR. ( nTmp > nMax )

         AAdd( aError, {  AllTrim( cIdRoba ) + " - " + ;
            AllTrim( roba->naz ), nTmp  } )
      ENDIF

      SELECT roba
      SKIP

   ENDDO

   IF Len( aError ) == 0
      msgbeep( "sve ok :)" )
      RETURN
   ENDIF

   START PRINT CRET

   i := 0

   ?

   cLine := Replicate( "-", 5 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 5 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 50 )

   cTxt := PadR( "rbr", 5 )
   cTxt += Space( 1 )
   cTxt += PadR( "broj", 5 )
   cTxt += Space( 1 )
   cTxt += PadR( "roba", 50 )

   P_COND
   ? cLine
   ? cTxt
   ? cLine

   nCnt := 0

   FOR i := 1 TO Len( aError )

      ? PadL( AllTrim( Str( ++nCnt ) ) + ")", 5 )
      @ PRow(), PCol() + 1 SAY Str( aError[ i, 2 ], 5 )
      @ PRow(), PCol() + 1 SAY PadR( aError[ i, 1 ], 50 )

   NEXT

   FF
   ENDPRINT

   RETURN





// -----------------------------------------------
// pregled sastavnica koje nedostaju
// -----------------------------------------------
FUNCTION pr_ned_sast()

   LOCAL cSirovine := Space( 200 )
   LOCAL cArtikli := Space( 200 )
   LOCAL cPostoji := "P"
   LOCAL cIdRoba
   LOCAL aSast := {}
   LOCAL i
   LOCAL nScan
   LOCAL aError := {}

   box(, 3, 65 )
   @ m_x + 1, m_y + 2 SAY "tr.sirovine:" GET cSirovine PICT "@S40" ;
      VALID !Empty( cSirovine )
   @ m_x + 2, m_y + 2 SAY "[P]ostoji / [N]epostoji" GET cPostoji ;
      PICT "@!" ;
      VALID cPostoji $ "PN"
   @ m_x + 3, m_y + 2 SAY "uslov za artikle:" GET cArtikli PICT "@S40"

   READ
   boxc()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   // sastavnice u matricu...
   aSast := TokToNiz( cSirovine, ";" )

   IF !Empty( cArtikli )
      bUsl := Parsiraj( AllTrim( cArtikli ), "ID" )
   ENDIF

   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   DO WHILE !Eof()

      IF field->tip <> "P"
         SKIP
         LOOP
      ENDIF

      IF !Empty( cArtikli )
         if &bUsl
         ELSE
            SKIP
            LOOP
         ENDIF
      ENDIF

      cIdRoba := field->id

      SELECT sast
      SET ORDER TO TAG "ID"
      GO TOP
      SEEK cIdRoba

      IF !Found()

         SELECT roba
         SKIP
         LOOP

      ENDIF

      i := 0

      lPostoji := .F.

      DO WHILE !Eof() .AND. field->id == cIdRoba

         // sirovina za
         cUzorak := AllTrim( field->id2 )
         nScan := AScan( aSast, {|xVal| xVal $ cUzorak } )

         IF nScan <> 0
            lPostoji := .T.
            EXIT
         ENDIF

         SKIP

      ENDDO

      IF cPostoji == "N" .AND. lPostoji == .F.
         AAdd( aError, {  AllTrim( cIdRoba ) + " - " + ;
            AllTrim( roba->naz )  } )
      ENDIF

      IF cPostoji == "P" .AND. lPostoji == .T.
         AAdd( aError, {  AllTrim( cIdRoba ) + " - " + ;
            AllTrim( roba->naz )  } )
      ENDIF


      SELECT roba
      SKIP

   ENDDO

   IF Len( aError ) == 0
      msgbeep( "sve ok :)" )
      RETURN
   ENDIF

   START PRINT CRET

   i := 0

   ?

   cLine := Replicate( "-", 5 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 50 )

   cTxt := PadR( "rbr", 5 )
   cTxt += Space( 1 )
   cTxt += PadR( "roba", 50 )

   P_COND
   ? cLine
   ? cTxt
   ? cLine

   nCnt := 0

   FOR i := 1 TO Len( aError )

      ? PadL( AllTrim( Str( ++nCnt ) ) + ")", 5 )
      @ PRow(), PCol() + 1 SAY PadR( aError[ i, 1 ], 50 )

   NEXT

   FF
   ENDPRINT

   RETURN


// ---------------------------------------------
// pregled duplih sastavnica
// ---------------------------------------------
FUNCTION pr_dupl_sast()

   LOCAL cIdRoba
   LOCAL cArtikli := Space( 200 )
   LOCAL aSast := {}
   LOCAL i
   LOCAL nScan
   LOCAL aError := {}
   LOCAL aDbf := {}

   box(, 1, 65 )
   @ m_x + 1, m_y + 2 SAY "uslov za artikle:" GET cArtikli PICT "@S40"
   READ
   boxc()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   AAdd( aDbf, { "IDROBA", "C", 10, 0 } )
   AAdd( aDbf, { "ROBANAZ", "C", 200, 0 } )
   AAdd( aDbf, { "SAST", "C", 150, 0 } )
   AAdd( aDbf, { "MARK", "C", 1, 0 } )

   t_exp_create( aDbf )
   O_R_EXP
   INDEX ON sast TAG "1"

   O_SAST
   O_ROBA
   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   IF !Empty( cArtikli )
      bUsl := Parsiraj( AllTrim( cArtikli ), "ID" )
   ENDIF


   box(, 1, 50 )

   // prvo mi daj svu robu u p.tabelu sa sastavnicama
   DO WHILE !Eof()

      IF field->tip <> "P"
         SKIP
         LOOP
      ENDIF

      IF !Empty( cArtikli )
         if &bUsl
         ELSE
            SKIP
            LOOP
         ENDIF
      ENDIF

      cIdRoba := field->id
      cRobaNaz := AllTrim( field->naz )

      @ m_x + 1, m_y + 2 SAY "generisem uzorak: " + cIdRoba

      SELECT sast
      SET ORDER TO TAG "ID"
      GO TOP
      SEEK cIdRoba

      IF !Found()
         SELECT roba
         SKIP
         LOOP
      ENDIF

      cUzorak := ""

      DO WHILE !Eof() .AND. field->id == cIdRoba

         cUzorak += AllTrim( field->id2 )

         SKIP
      ENDDO

      // upisi u pomocnu tabelu
      SELECT r_export
      APPEND BLANK
      REPLACE field->idroba WITH cIdRoba
      REPLACE field->robanaz WITH cRobaNaz
      REPLACE field->sast WITH cUzorak

      SELECT roba
      SKIP

   ENDDO

   // sada provjera na osnovu uzoraka

   SELECT roba
   GO TOP

   DO WHILE !Eof()

      cTmpRoba := field->id
      cTmpNaz := AllTrim( field->naz )

      IF field->tip <> "P"
         SKIP
         LOOP
      ENDIF

      IF !Empty( cArtikli )
         if &bUsl
         ELSE
            SKIP
            LOOP
         ENDIF
      ENDIF

      @ m_x + 1, m_y + 2 SAY "provjeravam uzorke: " + cTmpRoba

      SELECT sast
      SET ORDER TO TAG "ID"
      GO TOP
      SEEK cTmpRoba

      IF !Found()
         SELECT roba
         SKIP
         LOOP
      ENDIF

      cTmp := ""

      DO WHILE !Eof() .AND. field->id == cTmpRoba
         cTmp += AllTrim( field->id2 )
         SKIP
      ENDDO

      SELECT r_export
      SET ORDER TO TAG "1"
      GO TOP
      SEEK PadR( cTmp, 150 )

      DO WHILE !Eof() .AND. field->sast == PadR( cTmp, 150 )

         IF field->mark == "1"
            SKIP
            LOOP
         ENDIF

         IF field->idroba == cTmpRoba
            // ovo je ta sifra, preskoci
            REPLACE field->mark WITH "1"
            SKIP
            LOOP
         ENDIF

         // markiraj da sam ovaj artikal prosao
         REPLACE field->mark WITH "1"

         AAdd( aError, { AllTrim( cTmpRoba ) + " - " + ;
            AllTrim( cTmpNaz ), AllTrim( r_export->idroba ) + ;
            " - " + AllTrim( r_export->robanaz ) } )
         SKIP
      ENDDO


      SELECT roba
      SKIP
   ENDDO

   boxc()

   IF Len( aError ) == 0
      msgbeep( "sve ok :)" )
      RETURN
   ENDIF

   START PRINT CRET

   i := 0

   ?

   cLine := Replicate( "-", 5 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 50 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 50 )

   cTxt := PadR( "rbr", 5 )
   cTxt += Space( 1 )
   cTxt += PadR( "roba uzorak", 50 )
   cTxt += Space( 1 )
   cTxt += PadR( "ima i u", 50 )

   P_COND
   ? cLine
   ? cTxt
   ? cLine

   nCnt := 0

   FOR i := 1 TO Len( aError )

      ? PadL( AllTrim( Str( ++nCnt ) ) + ")", 5 )
      @ PRow(), PCol() + 1 SAY PadR( aError[ i, 1 ], 50 )
      @ PRow(), PCol() + 1 SAY PadR( aError[ i, 2 ], 50 )

   NEXT

   FF
   ENDPRINT

   RETURN

// -----------------------------------------------
// eksport sastavnica u dbf fajl
// -----------------------------------------------
FUNCTION _exp_sast_dbf()

   LOCAL aDbf := {}

   AAdd( aDbf, { "R_ID", "C", 10, 0 } )
   AAdd( aDbf, { "R_NAZ", "C", 200, 0 } )
   AAdd( aDbf, { "R_JMJ", "C", 3, 0 } )
   AAdd( aDbf, { "S_ID", "C", 10, 0 } )
   AAdd( aDbf, { "S_NAZ", "C", 200, 0 } )
   AAdd( aDbf, { "S_JMJ", "C", 3, 0 } )
   AAdd( aDbf, { "KOL", "N", 12, 2 } )
   AAdd( aDbf, { "NC", "N", 12, 2 } )
   AAdd( aDbf, { "VPC", "N", 12, 2 } )
   AAdd( aDbf, { "MPC", "N", 12, 2 } )

   t_exp_create( aDbf )

   O_R_EXP
   O_SAST
   O_ROBA

   SELECT sast
   SET ORDER TO TAG "ID"
   GO TOP

   box(, 1, 50 )
   DO WHILE !Eof()

      cIdRoba := field->id

      IF Empty( cIdROba )
         SKIP
         LOOP
      ENDIF

      SELECT roba
      GO TOP
      SEEK cIdRoba

      cR_naz := field->naz
      cR_jmj := field->jmj

      SELECT sast

      DO WHILE !Eof() .AND. field->id == cIdRoba

         cSast := field->id2
         nKol := field->kolicina

         SELECT roba
         GO TOP
         SEEK cSast

         cNaz := field->naz
         nCjen := field->nc

         SELECT sast

         @ m_x + 1, m_y + 2 SAY "upisujem: " + cIdRoba

         SELECT r_export
         APPEND BLANK

         REPLACE field->r_id WITH cIdRoba
         REPLACE field->r_naz WITH cR_naz
         REPLACE field->r_jmj WITH cR_jmj
         REPLACE field->s_id WITH cSast
         REPLACE field->s_naz WITH cNaz
         REPLACE field->kol WITH nKol
         REPLACE field->nc WITH nCjen

         SELECT sast
         SKIP

      ENDDO

   ENDDO

   boxc()

   msgbeep( "Podaci se nalaze u " + PRIVPATH + "r_export.dbf tabeli !" )

   SELECT r_export
   USE

   RETURN

// -----------------------------------------------
// export robe u dbf
// -----------------------------------------------
FUNCTION _exp_roba_dbf()

   LOCAL aDbf := {}

   AAdd( aDbf, { "ID", "C", 10, 0 } )
   AAdd( aDbf, { "NAZIV", "C", 200, 0 } )
   AAdd( aDbf, { "JMJ", "C", 3, 0 } )
   AAdd( aDbf, { "NC", "N", 12, 2 } )
   AAdd( aDbf, { "VPC", "N", 12, 2 } )
   AAdd( aDbf, { "MPC", "N", 12, 2 } )

   t_exp_create( aDbf )
   O_R_EXP
   O_ROBA
   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   box(, 1, 50 )
   DO WHILE !Eof()

      @ m_x + 1, m_y + 2 SAY "upisujem: " + roba->id

      SELECT r_export
      APPEND BLANK

      REPLACE field->id WITH roba->id
      REPLACE field->naziv WITH roba->naz
      REPLACE field->jmj WITH roba->jmj
      REPLACE field->nc WITH roba->nc
      REPLACE field->vpc WITH roba->vpc
      REPLACE field->mpc WITH roba->mpc

      SELECT roba
      SKIP
   ENDDO

   boxc()

   msgbeep( "Podaci se nalaze u " + PRIVPATH + "r_export.dbf tabeli !" )

   SELECT r_export
   USE

   RETURN
