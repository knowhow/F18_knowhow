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


#include "fmk.ch"


FUNCTION P_Roba( cId, dx, dy, cSeek )

   LOCAL lRet
   LOCAL bRoba
   LOCAL lArtGroup := .F.
   LOCAL _naz_len := 40
   PRIVATE ImeKol
   PRIVATE Kol

   // pretraga po dobavljacu
   IF cSeek == NIL
      cSeek := ""
   ENDIF

   ImeKol := {}

   PushWa()
   O_ROBA_NOT_USED

   AAdd( ImeKol, { PadC( "ID", 10 ),  {|| id }, "id", {|| .T. }, {|| sifra_postoji( wId ) } } )

   AAdd( ImeKol, { PadC( "PLU kod", 8 ),  {|| PadR( fisc_plu, 10 ) }, "fisc_plu", {|| gen_plu( @wfisc_plu ), .F. }, {|| .T. } } )

   IF roba->( FieldPos( "SIFRADOB" ) ) <> 0
      AAdd( ImeKol, { PadC( "S.dobav.", 13 ), {|| PadR( sifraDob, 13 ) }, "sifradob"   } )
   ENDIF

   AAdd( ImeKol, { PadC( "Naziv", _naz_len ), {|| Left( naz, _naz_len ) }, "naz", {|| .T. }, {|| .T. } } )

   // jedinica mjere
   AAdd( ImeKol, { PadC( "JMJ", 3 ), {|| jmj },       "jmj"    } )

   // DEBLJINA i TIP
   IF roba->( FieldPos( "DEBLJINA" ) ) <> 0
      AAdd( ImeKol, { PadC( "Debljina", 10 ), {|| Transform( debljina, "999999.99" ) }, "debljina", nil, nil, "999999.99" } )

      AAdd( ImeKol, { PadC( "Roba tip", 10 ), {|| roba_tip }, "roba_tip", {|| .T. }, {|| .T. } } )
   ENDIF

   // STRINGS
   // IF roba->( FieldPos( "STRINGS" ) ) <> 0
   // AAdd( ImeKol, { PadC( "Strings", 10 ), {|| strings }, "strings", {|| .T. }, {|| .T. } } )
   // ENDIF

   AAdd( ImeKol, { PadC( "VPC", 10 ), {|| Transform( VPC, "999999.999" ) }, "vpc", nil, nil, nil, gPicCDEM  } )

   // VPC2
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "SIF", "SHOWVPC2" ) )
      AAdd( ImeKol, { PadC( "VPC2", 10 ), {|| Transform( VPC2, "999999.999" ) }, "vpc2", NIL, NIL, NIL, gPicCDEM   } )
   ENDIF

   IF roba->( FieldPos( "PLC" ) ) <> 0  .AND. IzFMkIni( "SifRoba", "PlanC", "N", SIFPATH ) == "D"
      AAdd( ImeKol, { PadC( "Plan.C", 10 ), {|| Transform( PLC, "999999.999" ) }, "PLC", NIL, NIL, NIL, gPicCDEM    } )
   ENDIF

   AAdd( ImeKol, { PadC( "MPC1", 10 ), {|| Transform( MPC, "999999.999" ) }, "mpc", NIL, NIL, NIL, gPicCDEM  } )

   FOR i := 2 TO 4

      cPom := "mpc" + AllTrim( Str( i ) )
      cPom2 := '{|| transform(' + cPom + ',"999999.999")}'

      IF roba->( FieldPos( cPom ) )  <>  0

         cPrikazi := fetch_metric( "roba_prikaz_" + cPom, nil, "D" )

         IF cPrikazi == "D"
            AAdd( ImeKol, { PadC( Upper( cPom ), 10 ), &( cPom2 ), cPom, nil, nil, nil, gPicCDEM } )
         ENDIF

      ENDIF

   NEXT

   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "SIF", "SHOWNC" ) )
      AAdd( ImeKol, { PadC( "NC", 10 ), {|| Transform( NC, gPicCDEM ) }, "NC", NIL, NIL, NIL, gPicCDEM  } )
   ENDIF

   AAdd( ImeKol, { "Tarifa", {|| IdTarifa }, "IdTarifa", {|| .T. }, {|| P_Tarifa( @wIdTarifa ), roba_opis_edit()  }   } )
   AAdd( ImeKol, { "Tip", {|| " " + Tip + " " }, "Tip", {|| .T. }, {|| wTip $ " TUCKVPSXY" }, NIL, NIL, NIL, NIL, 27 } )

   AAdd ( ImeKol, { PadC( "BARKOD", 14 ), {|| BARKOD }, "BarKod", {|| .T. }, {|| DodajBK( @wBarkod ), sifra_postoji( wbarkod, "BARKOD" ) }  } )

   AAdd ( ImeKol, { PadC( "MINK", 10 ), {|| Transform( MINK, "999999.99" ) }, "MINK"   } )

   AAdd ( ImeKol, { PadC( "K1", 4 ), {|| k1 }, "k1"   } )
   AAdd ( ImeKol, { PadC( "K2", 4 ), {|| k2 }, "k2", ;
      {|| .T. }, {|| .T. }, nil, nil, nil, nil, 35   } )
   AAdd ( ImeKol, { PadC( "N1", 12 ), {|| N1 }, "N1"   } )
   AAdd ( ImeKol, { PadC( "N2", 12 ), {|| N2 }, "N2", ;
      {|| .T. }, {|| .T. }, nil, nil, nil, nil, 35   } )

/*
   AAdd ( ImeKol, { PadC( "K7", 2 ), {|| k7 }, "k7"   } )
   AAdd ( ImeKol, { PadC( "K8", 2 ), {|| k8 }, "k8"  } )
   AAdd ( ImeKol, { PadC( "K9", 3 ), {|| k9 }, "k9" } )
*/

   // AUTOMATSKI TROSKOVI ROBE, samo za KALK
   IF goModul:oDataBase:cName == "KALK" .AND. roba->( FieldPos( "TROSK1" ) ) <> 0
      AAdd ( ImeKol, { PadR( c10T1, 8 ), {|| trosk1 }, "trosk1", {|| .T. }, {|| .T. } } )
      AAdd ( ImeKol, { PadR( c10T2, 8 ), {|| trosk2 }, "trosk2", ;
         {|| .T. }, {|| .T. }, nil, nil, nil, nil, 30 } )
      AAdd ( ImeKol, { PadR( c10T3, 8 ), {|| trosk3 }, "trosk3", {|| .T. }, {|| .T. } } )
      AAdd ( ImeKol, { PadR( c10T4, 8 ), {|| trosk4 }, "trosk4", ;
         {|| .T. }, {|| .T. }, nil, nil, nil, nil, 30 } )
      AAdd ( ImeKol, { PadR( c10T5, 8 ), {|| trosk5 }, "trosk5"   } )
   ENDIF

   IF goModul:oDataBase:cName == "KALK"
      IF roba->( FieldPos( "ZANIVEL" ) ) <> 0
         AAdd ( ImeKol, { PadC( "Nova cijena", 20 ), {|| Transform( zanivel, "999999.999" ) }, "zanivel", NIL, NIL, NIL, gPicCDEM  } )
      ENDIF
      IF roba->( FieldPos( "ZANIV2" ) ) <> 0
         AAdd ( ImeKol, { PadC( "Nova cijena/2", 20 ), {|| Transform( zaniv2, "999999.999" ) }, "zaniv2", NIL, NIL, NIL, gPicCDEM  } )
      ENDIF
   ENDIF

   IF roba->( FieldPos( "IDKONTO" ) ) <> 0
      AAdd ( ImeKol, { "Id konto", {|| idkonto }, "idkonto", {|| .T. }, {|| Empty( widkonto ) .OR. P_Konto( @widkonto ) }   } )
   ENDIF

   IF roba->( FieldPos( "IDTARIFA2" ) ) <> 0
      AAdd ( ImeKol, { "Tarifa R2", {|| IdTarifa2 }, "IdTarifa2", {|| .T. }, {|| set_tar_rs( @wIdTarifa2, wIdTarifa ) .OR. P_Tarifa( @wIdTarifa2 ) }   } )
      AAdd ( ImeKol, { "Tarifa R3", {|| IdTarifa3 }, "IdTarifa3", {|| .T. }, {|| set_tar_rs( @wIdTarifa3, wIdTarifa ) .OR. P_Tarifa( @wIdTarifa3 ) }   } )
   ENDIF

   Kol := {}

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   SELECT ROBA
   sif_sifk_fill_kol( "ROBA", @ImeKol, @Kol )

   bRoba := gRobaBlock

   IF !Empty( cSeek )
      cPomTag := cSeek
   ELSE
      cPomTag := "ID"
   ENDIF

   lRet := PostojiSifra( F_ROBA, ( cPomTag ), 15, MAXCOLS() - 5, "Lista artikala - robe", @cId, dx, dy, bRoba,,,,, { "ID" } )

   PopWa()

   RETURN lRet


// ---------------------------------------------------
// definisanje opisa artikla u sifrarniku
// ---------------------------------------------------
FUNCTION roba_opis_edit( view )

   LOCAL _op := "N"
   PRIVATE getList := {}

   IF view == NIL
      view := .F.
   ENDIF

   IF !view

      @ m_x + 7, m_y + 43 SAY "Definisati opis artikla (D/N) ?" GET _op PICT "@!" VALID _op $ "DN"

      READ

      IF _op == "N"
         RETURN .T.
      ENDIF

   ENDIF

   Box(, 14, 55 )

   @ m_x + 1, m_y + 2 SAY "OPIS ARTIKLA # " + if( !view, "<c-W> za kraj unosa...", "" )

   // otvori memo edit
   wopis := MemoEdit( field->opis, m_x + 3, m_y + 1, m_x + 14, m_y + 55 )

   BoxC()

   RETURN .T.



// ------------------------------------
// formiranje MPC na osnovu VPC
// ------------------------------------
FUNCTION MpcIzVpc()

   IF pitanje(, "Formirati MPC na osnovu VPC ? (D/N)", "N" ) == "N"
      RETURN DE_CONT
   ENDIF

   PRIVATE GetList := {}
   PRIVATE nZaokNa := 1
   PRIVATE cMPC := " "
   PRIVATE cVPC := " "

   Scatter()
   SELECT tarifa
   hseek _idtarifa
   SELECT roba

   Box(, 4, 70 )
   @ m_x + 2, m_y + 2 SAY "Set cijena VPC ( /2)  :" GET cVPC VALID cVPC $ " 2"
   @ m_x + 3, m_y + 2 SAY "Set cijena MPC ( /2/3):" GET cMPC VALID cMPC $ " 23"
   READ
   IF Empty( cVPC )
      cVPC := ""
   ENDIF
   IF Empty( cMPC )
      cMPC := ""
   ENDIF
   BoxC()

   Box(, 6, 70 )
   @ m_X + 1, m_y + 2 SAY Trim( roba->id ) + "-" + Trim( Left( roba->naz, 40 ) )
   @ m_X + 2, m_y + 2 SAY "TARIFA"
   @ m_X + 2, Col() + 2 SAY _idtarifa
   @ m_X + 3, m_y + 2 SAY "VPC" + cVPC
   @ m_X + 3, Col() + 1 SAY _VPC&cVPC PICT gPicDem
   @ m_X + 4, m_y + 2 SAY "Postojeca MPC" + cMPC
   @ m_X + 4, Col() + 1 SAY roba->MPC&cMPC PICT gPicDem
   @ m_X + 5, m_y + 2 SAY "Zaokruziti cijenu na (broj decimala):" GET nZaokNa VALID {|| _MPC&cMPC := Round( _VPC&cVPC * ( 1 + tarifa->opp / 100 ) * ( 1 + tarifa->ppp / 100 + tarifa->zpp / 100 ), nZaokNa ), .T. } PICT "9"
   @ m_X + 6, m_y + 2 SAY "MPC" + cMPC GET _MPC&cMPC WHEN {|| _MPC&cMPC := Round( _VPC&cVPC * ( 1 + tarifa->opp / 100 ) * ( 1 + tarifa->ppp / 100 + tarifa->zpp / 100 ), nZaokNa ), .T. } PICT gPicDem
   READ
   BoxC()
   IF LastKey() <> K_ESC
      Gather()
      IF Pitanje(, "Želite li isto uraditi za sve artikle kod kojih je MPC" + cMPC + "=0 ? (D/N)", "N" ) == "D"
         nRecAM := RecNo()
         Postotak( 1, RECCOUNT2(), "Formiranje cijena" )
         nStigaoDo := 0
         GO TOP
         DO WHILE !Eof()
            IF ROBA->MPC&cMPC == 0
               Scatter()
               SELECT tarifa
               hseek _idtarifa
               SELECT roba
               _MPC&cMPC := Round( _VPC&cVPC * ( 1 + tarifa->opp / 100 ) * ( 1 + tarifa->ppp / 100 + tarifa->zpp / 100 ), nZaokNa )
               Gather()
            ENDIF
            Postotak( 2, ++nStigaoDo )
            SKIP 1
         ENDDO
         Postotak( 0 )
         GO ( nRecAM )
      ENDIF
      RETURN DE_REFRESH
   ENDIF

   RETURN DE_CONT


// -------------------------------------------------------
// setovanje tarife 2 i 3 u sifrarniku na osnovu idtarifa
// -------------------------------------------------------
FUNCTION set_tar_rs( cId1, cId2 )

   IF Empty( cId1 )
      cId1 := cId2
   ENDIF

   RETURN .T.


FUNCTION WhenBK()

   IF Empty( wBarKod )
      wBarKod := PadR( wId, Len( wBarKod ) )
      AEval( GetList, {| o| o:display() } )
   ENDIF

   RETURN .T.



// roba ima zasticenu cijenu
// sto znaci da krajnji kupac uvijek placa fixan iznos pdv-a
// bez obzira po koliko se roba prodaje
FUNCTION RobaZastCijena( cIdTarifa )

   lZasticena := .F.
   lZasticena := lZasticena .OR.  ( PadR( cIdTarifa, 6 ) == PadR( "PDVZ", 6 ) )
   lZasticena := lZasticena .OR.  ( PadR( cIdTarifa, 6 ) == PadR( "PDV17Z", 6 ) )
   lZasticena := lZasticena .OR.  ( PadR( cIdTarifa, 6 ) == PadR( "CIGA05", 6 ) )

   RETURN lZasticena


FUNCTION OFmkRoba()

   O_SIFK
   O_SIFV
   O_KONTO
   O_KONCIJ
   O_TRFP
   O_TARIFA
   O_ROBA
   O_SAST

   RETURN



// ----------------------------------------------------
// provjera cijena u sifrarniku artikala
// ----------------------------------------------------
FUNCTION sifre_artikli_provjera_mp_cijena()

   LOCAL _check := {}
   LOCAL _i, _n, _x, _mpc
   LOCAL _line
   LOCAL _decimal := 2

   SELECT ( F_ROBA )
   IF !Used()
      O_ROBA
   ENDIF

   MsgO( "Provjera šifarnika artikala u toku ..." )
   GO TOP
   DO WHILE !Eof()

      // prodji kroz MPC setove
      FOR _n := 1 TO 9

         // MPC, MPC2, MPC3...

         _tmp := "mpc"

         IF _n > 1
            _tmp += AllTrim( Str( _n ) )
         ENDIF

         _mpc := field->&_tmp

         IF Abs( _mpc ) - Abs( Val( Str( _mpc, 12, _decimal ) ) ) <> 0

            _n_scan := AScan( _check, {| val | val[ 1 ] == field->id  } )

            IF _n_scan == 0
               // dodaj u matricu...
               AAdd( _check, { field->id, field->barkod, field->naz, ;
                  IF( _n == 1, _mpc, 0 ), ;
                  IF( _n == 2, _mpc, 0 ), ;
                  IF( _n == 3, _mpc, 0 ), ;
                  IF( _n == 4, _mpc, 0 ), ;
                  IF( _n == 5, _mpc, 0 ), ;
                  IF( _n == 6, _mpc, 0 ), ;
                  IF( _n == 7, _mpc, 0 ), ;
                  IF( _n == 8, _mpc, 0 ), ;
                  IF( _n == 9, _mpc, 0 ) } )
            ELSE
               // dodaj u postojecu matricu
               _check[ _n_scan, 2 + _n ] := _mpc
            ENDIF

         ENDIF

      NEXT

      SKIP

   ENDDO

   MsgC()

   // nema gresaka
   IF Len( _check ) == 0
      my_close_all_dbf()
      RETURN
   ENDIF

   START PRINT CRET

   ?

   P_COND2

   _count := 0
   _line := _get_check_line()

   ? _line

   ? "Lista artikala sa nepravilnom MPC"

   ? _line

   ? PadR( "R.br.", 6 ), PadR( "Artikal ID", 10 ), PadR( "Barkod", 13 ), ;
      PadR( "Naziv artikla", 30 ), ;
      PadC( "MPC1", 15 ), ;
      PadC( "MPC2", 15 ), ;
      PadC( "MPC3", 15 ), ;
      PadC( "MPC4", 15 )
   // PadC( "MPC5", 15 ), ;
   // PadC( "MPC6", 15 ), ;
   // PadC( "MPC7", 15 ), ;
   // PadC( "MPC8", 15 ), ;
   // PadC( "MPC9", 15 )

   ? _line

   FOR _i := 1 TO Len( _check )

      ? PadL( AllTrim( Str( ++_count ) ) + ".", 6 )
      // id
      @ PRow(), PCol() + 1 SAY _check[ _i, 1 ]
      // barkod
      @ PRow(), PCol() + 1 SAY _check[ _i, 2 ]
      // naziv
      @ PRow(), PCol() + 1 SAY PadR( _check[ _i, 3 ], 30 )

      // setovi cijena...
      FOR _x := 1 TO 9

         // mpc, mpc2, mpc3...
         _cijena := _check[ _i, 3 + _x ]

         IF Round( _cijena, 4 ) == 0
            _tmp := PadR( "", 15 )
         ELSE
            _tmp := Str( _cijena, 15, 4 )
         ENDIF

         @ PRow(), PCol() + 1 SAY _tmp

      NEXT
   NEXT

   ? _line

   FF

   my_close_all_dbf()

   ENDPRINT

   RETURN


STATIC FUNCTION _get_check_line()

   LOCAL _line := ""

   _line += Replicate( "-", 6 )
   _line += Space( 1 )
   _line += Replicate( "-", 10 )
   _line += Space( 1 )
   _line += Replicate( "-", 13 )
   _line += Space( 1 )
   _line += Replicate( "-", 30 )
   _line += Space( 1 )
   _line += Replicate( "-", 15 )
   _line += Space( 1 )
   _line += Replicate( "-", 15 )
   _line += Space( 1 )
   _line += Replicate( "-", 15 )
   _line += Space( 1 )
   _line += Replicate( "-", 15 )
   _line += Space( 1 )
   _line += Replicate( "-", 15 )
   _line += Space( 1 )
   _line += Replicate( "-", 15 )
   _line += Space( 1 )
   _line += Replicate( "-", 15 )
   _line += Space( 1 )
   _line += Replicate( "-", 15 )
   _line += Space( 1 )
   _line += Replicate( "-", 15 )

   RETURN _line





// --------------------------------------------------
// prikaz izvjestaja duplih barkodova
// --------------------------------------------------
FUNCTION rpt_dupli_barkod()

   LOCAL _data

   MsgO( "Formiram sql upit ..." )
   _data := __dupli_bk_sql()
   MsgC()

   __dupli_bk_rpt( _data )

   RETURN


// -----------------------------------------------
// sql upit
// -----------------------------------------------
STATIC FUNCTION __dupli_bk_sql()

   LOCAL _qry, _table
   LOCAL _server := pg_server()

   _qry := "SELECT id, naz, barkod " + ;
      "FROM fmk.roba r1 " + ;
      "WHERE barkod <> '' AND barkod IN ( " + ;
      "SELECT barkod " + ;
      "FROM fmk.roba r2 " + ;
      "GROUP BY barkod " + ;
      "HAVING COUNT(*) > 1 " + ;
      ") " + ;
      "ORDER BY barkod"

   _table := _sql_query( _server, _qry )

   IF _table == NIL
      RETURN NIL
   ENDIF

   RETURN _table



// -----------------------------------------------
// prikaz duplih barkodova iz sifrarnika
// -----------------------------------------------
STATIC FUNCTION __dupli_bk_rpt( data )

   LOCAL _i

   IF ValType( data ) == "L" .OR. Len( data ) == 0
      MsgBeep( "Nema podataka za prikaz !!!" )
      RETURN
   ENDIF

   START PRINT CRET

   ?

   ? "Dupli barkodovi unutar sifrarnika artikala:"
   ? "----------------------------------------------------------------------------------"
   ? "ID             NAZIV                                    BARKOD"
   ? "----------------------------------------------------------------------------------"

   DO WHILE !data:Eof()

      _row := data:GetRow()

      ? _row:FieldGet( _row:FieldPos( "id" ) ), ;
         PadR( hb_UTF8ToStr( _row:FieldGet( _row:FieldPos( "naz" ) ) ), 40 ), ;
         _row:FieldGet( _row:FieldPos( "barkod" ) )

      data:Skip()

   ENDDO

   FF
   ENDPRINT

   RETURN


// --------------------------------------------------------
// setovanje mpc cijene iz vpc
// --------------------------------------------------------
FUNCTION roba_setuj_mpc_iz_vpc()

   LOCAL _params := hb_Hash()
   LOCAL _rec
   LOCAL _mpc_set
   LOCAL _tarifa
   LOCAL _count := 0
   LOCAL lOk := .T.

   IF !_get_params( @_params )
      RETURN
   ENDIF

   sql_table_update( NIL, "BEGIN" )
   IF !f18_lock_tables( { "roba" }, .T. )
      sql_table_update( NIL, "END" )
      RETURN
   ENDIF

   O_TARIFA
   O_ROBA
   GO TOP

   // koji cu set mpc gledati...
   IF _params[ "mpc_set" ] == 1
      _mpc_set := "mpc"
   ELSE
      _mpc_set := "mpc" + AllTrim( Str( _params[ "mpc_set" ] ) )
   ENDIF

   Box(, 2, 70 )

   DO WHILE !Eof()

      _rec := dbf_get_rec()

      IF !Empty( _params[ "filter_id" ] )
         _filt_id := Parsiraj( _params[ "filter_id" ], "id" )
         IF !( &_filt_id )
            SKIP
            LOOP
         ENDIF
      ENDIF

      // vpc je 0, preskoci...
      IF Round( _rec[ "vpc" ], 3 ) == 0
         SKIP
         LOOP
      ENDIF

      // konverzija samo tamo gdje je mpc = 0
      IF Round( _rec[ _mpc_set ], 3 ) <> 0 .AND. _params[ "mpc_nula" ] == "D"
         SKIP
         LOOP
      ENDIF

      _tarifa := _rec[ "idtarifa" ]

      IF Empty( _tarifa )
         SKIP
         LOOP
      ENDIF

      SELECT tarifa
      hseek _tarifa

      IF !Found()
         SELECT roba
         SKIP
         LOOP
      ENDIF

      SELECT roba

      IF tarifa->opp > 0

         // napravi kalkulaciju...
         _rec[ _mpc_set ] := Round( _rec[ "vpc" ] * ( 1 + ( tarifa->opp / 100 ) ), 2 )

         // zaokruzi na 5 pf
         IF _params[ "zaok_5pf" ] == "D"
            _rec[ _mpc_set ] := _rec[ _mpc_set ] - zaokr_5pf( _rec[ _mpc_set ] )
         ENDIF

         @ m_x + 1, m_y + 2 SAY PadR( "Artikal: " + _rec[ "id" ] + "-" + PadR( _rec[ "naz" ], 20 ) + "...", 50 )
         @ m_x + 2, m_y + 2 SAY PadR( " VPC: " + AllTrim( Str( _rec[ "vpc" ], 12, 3 ) ) + ;
            " -> " + Upper( _mpc_set ) + ": " + AllTrim( Str( _rec[ _mpc_set ], 12, 3 ) ), 50 )

         lOk := update_rec_server_and_dbf( "roba", _rec, 1, "CONT" )

         ++ _count

      ENDIF

      IF !lOk
         EXIT
      ENDIF

      SKIP

   ENDDO

   BoxC()

   IF lOk
      f18_free_tables( { "roba" } )
      sql_table_update( NIL, "END" )
   ELSE
      sql_table_update( NIL, "ROLLBACK" )
   ENDIF

   RETURN



STATIC FUNCTION _get_params( params )

   LOCAL _ok := .F.
   LOCAL _x := 1
   LOCAL _mpc_no := 1
   LOCAL _zaok_5pf := "D"
   LOCAL _mpc_nula := "D"
   LOCAL _filter_id := Space( 200 )

   Box(, 10, 65 )

   @ m_x + _x, m_y + 2 SAY "VPC -> MPC..."

   _x += 2
   @ m_x + _x, m_y + 2 SAY "Setovati MPC (1/2/.../9)" GET _mpc_no VALID _mpc_no >= 1 .AND. _mpc_no < 10 PICT "9"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Zaokruženje 0.5pf (D/N) ?" GET _zaok_5pf VALID _zaok_5pf $ "DN" PICT "@!"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Setovati samo gdje je MPC = 0 (D/N) ?" GET _mpc_nula VALID _mpc_nula $ "DN" PICT "@!"
   _x += 2
   @ m_x + _x, m_y + 2 SAY "Filter po polju ID:" GET _filter_id PICT "@S40"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   params := hb_Hash()
   params[ "mpc_set" ] := _mpc_no
   params[ "zaok_5pf" ] := _zaok_5pf
   params[ "mpc_nula" ] := _mpc_nula
   params[ "filter_id" ] := AllTrim( _filter_id )

   _ok := .T.

   RETURN _ok