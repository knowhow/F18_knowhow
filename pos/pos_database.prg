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


#include "pos.ch"


FUNCTION o_pos_tables( lOtvoriKumulativ )

   my_close_all_dbf()

   IF lOtvoriKumulativ == NIL
      lOtvoriKumulativ := .T.
   ENDIF

   IF lOtvoriKumulativ
      o_pos_kumulativne_tabele()
   ENDIF

   O_ODJ
   O_OSOB
   SET ORDER TO TAG "NAZ"

   O_VRSTEP
   O_PARTN
   O_DIO
   O_K2C
   O_MJTRUR
   O_KASE
   O_SAST
   O_ROBA
   O_TARIFA
   O_SIFK
   O_SIFV
   O_PRIPRZ
   O_PRIPRG
   O__POS
   O__POS_PRIPR

   IF lOtvoriKumulativ
      SELECT pos_doks
   ELSE
      SELECT _pos
   ENDIF

   RETURN


STATIC FUNCTION o_pos_kumulativne_tabele()

   O_POS
   O_POS_DOKS
   O_DOKSPF
 
   RETURN



FUNCTION o_pos_sifre()

   O_KASE
   O_UREDJ
   O_ODJ
   O_ROBA
   O_TARIFA
   O_VRSTEP
   O_VALUTE
   O_PARTN
   O_OSOB
   O_STRAD
   O_SIFK
   O_SIFV

   RETURN



FUNCTION pos_iznos_racuna( cIdPos, cIdVD, dDatum, cBrDok )

   LOCAL cSql, oData, oRow
   LOCAL nTotal := 0

   IF PCount() == 0
      cIdPos := pos_doks->IdPos
      cIdVD := pos_doks->IdVD
      dDatum := pos_doks->Datum
      cBrDok := pos_doks->BrDok
   ENDIF

   cSql := "SELECT "
   cSql += " SUM( ( kolicina * cijena ) - ( kolicina * ncijena ) ) AS total "
   cSql += "FROM fmk.pos_pos "
   cSql += "WHERE "
   cSql += " idpos = " + _sql_quote( cIdPos )
   cSql += " AND idvd = " + _sql_quote( cIdVd )
   cSql += " AND brdok = " + _sql_quote( cBrDok )
   cSql += " AND datum = " + _sql_quote( dDatum )  

   oData := _sql_query( my_server(), cSql )

   IF !is_var_objekat_tpquery( oData )
      RETURN nTotal
   ENDIF 

   nTotal := oData:FieldGet(1) 

   RETURN nTotal




// ----------------------------------------
// pos, stanje robe
// ----------------------------------------
FUNCTION pos_vrati_broj_racuna_iz_fiskalnog( fisc_rn, broj_racuna, datum_racuna )

   LOCAL _qry, _qry_ret, _table
   LOCAL _server := pg_server()
   LOCAL _i, oRow
   LOCAL _id_pos := gIdPos
   LOCAL _rn_broj := ""
   LOCAL _ok := .F.

   _qry := " SELECT pd.datum, pd.brdok, pd.fisc_rn, " + ;
      " SUM( pp.kolicina * pp.cijena ) as iznos, " + ;
      " SUM( pp.kolicina * pp.ncijena ) as popust " + ;
      " FROM fmk.pos_pos pp " + ;
      " LEFT JOIN fmk.pos_doks pd " + ;
      " ON pd.idpos = pp.idpos AND pd.idvd = pp.idvd AND pd.brdok = pp.brdok AND pd.datum = pp.datum " + ;
      " WHERE pd.idpos = " + _sql_quote( _id_pos ) + ;
      " AND pd.idvd = '42' AND pd.fisc_rn = " + AllTrim( Str( fisc_rn ) ) + ;
      " GROUP BY pd.datum, pd.brdok, pd.fisc_rn " + ;
      " ORDER BY pd.datum, pd.brdok, pd.fisc_rn "

   _table := _sql_query( _server, _qry )
   _table:Refresh()
   _table:GoTo( 1 )

   IF _table:LastRec() > 1

      _arr := {}

      DO WHILE !_table:Eof()
         oRow := _table:GetRow()
         AAdd( _arr, { oRow:FieldGet( 1 ), oRow:FieldGet( 2 ), oRow:FieldGet( 3 ), oRow:FieldGet( 4 ), oRow:FieldGet( 5 ) } )
         _table:Skip()
      ENDDO

      // imamo vise racuna
      _browse_rn_choice( _arr, @broj_racuna, @datum_racuna )

      _ok := .T.

   ELSE

      // jedan ili nijedan...

      IF _table:LastRec() == 0
         RETURN _ok
      ENDIF

      _ok := .T.
      oRow := _table:GetRow()
      broj_racuna := oRow:FieldGet( oRow:FieldPos( "brdok" ) )
      datum_racuna := oRow:FieldGet( oRow:FieldPos( "datum" ) )

   ENDIF

   RETURN _ok




STATIC FUNCTION _browse_rn_choice( arr, broj_racuna, datum_racuna )

   LOCAL _ret := 0
   LOCAL _i, _n
   LOCAL _tmp
   LOCAL _izbor := 1
   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _m_x := m_x
   LOCAL _m_y := m_y

   FOR _i := 1 TO Len( arr )

      _tmp := ""
      _tmp += DToC( arr[ _i, 1 ] )
      _tmp += " racun: "
      _tmp += PadR( PadL( AllTrim( gIdPos ), 2 ) + "-" + AllTrim( arr[ _i, 2 ]  ), 10 )
      _tmp += PadL( AllTrim( Str( arr[ _i, 4 ] - arr[ _i, 5 ], 12, 2 ) ), 10 )

      AAdd( _opc, _tmp )
      AAdd( _opcexe, {|| "" } )

   NEXT

   DO WHILE .T. .AND. LastKey() != K_ESC
      _izbor := Menu( "choice", _opc, _izbor, .F. )
      IF _izbor == 0
         EXIT
      ELSE
         broj_racuna := arr[ _izbor, 2 ]
         datum_racuna := arr[ _izbor, 1 ]
         _izbor := 0
      ENDIF
   ENDDO

   m_x := _m_x
   m_y := _m_y

   RETURN _ret



// ----------------------------------------
// pos, stanje robe
// ----------------------------------------
FUNCTION pos_stanje_artikla( id_pos, id_roba )

   LOCAL _qry, _qry_ret, _table
   LOCAL _server := pg_server()
   LOCAL _data := {}
   LOCAL _i, oRow
   LOCAL _stanje := 0

   _qry := "SELECT SUM( CASE WHEN idvd IN ('16') THEN kolicina WHEN idvd IN ('42') THEN -kolicina WHEN idvd IN ('IN') THEN -(kolicina - kol2) ELSE 0 END ) AS stanje FROM fmk.pos_pos " + ;
      " WHERE idpos = " + _sql_quote( id_pos ) + ;
      " AND idroba = " + _sql_quote( id_roba )

   _table := _sql_query( _server, _qry )
   _table:Refresh()

   oRow := _table:GetRow( 1 )

   _stanje := oRow:FieldGet( oRow:FieldPos( "stanje" ) )

   IF ValType( _stanje ) == "L"
      _stanje := 0
   ENDIF

   RETURN _stanje



FUNCTION pos_iznos_dokumenta( lUI )

   LOCAL cRet := Space( 13 )
   LOCAL l_u_i
   LOCAL nIznos := 0
   LOCAL cIdPos, cIdVd, cBrDok
   LOCAL dDatum

   SELECT pos_doks

   cIdPos := pos_doks->idPos
   cIdVd := pos_doks->idVd
   cBrDok := pos_doks->brDok
   dDatum := pos_doks->datum

   IF ( ( lUI == NIL ) .OR. lUI )
      // ovo su ulazi ...
      IF pos_doks->IdVd $ VD_ZAD + "#" + VD_PCS + "#" + VD_REK
         SELECT pos
         SET ORDER TO TAG "1"
         GO TOP
         SEEK cIdPos + cIdVd + DToS( dDatum ) + cBrDok
         DO WHILE !Eof() .AND. pos->( IdPos + IdVd + DToS( datum ) + BrDok ) == cIdPos + cIdVd + DToS( dDatum ) + cBrDok
            nIznos += pos->kolicina * pos->cijena
            SKIP
         ENDDO
         IF pos_doks->idvd == VD_REK
            nIznos := -nIznos
         ENDIF
      ENDIF
   ENDIF

   IF ( ( lUI == NIL ) .OR. !lUI )
      // ovo su, pak, izlazi ...
      IF pos_doks->idvd $ VD_RN + "#" + VD_OTP + "#" + VD_RZS + "#" + VD_PRR + "#" + "IN" + "#" + VD_NIV
         SELECT pos
         SET ORDER TO TAG "1"
         GO TOP
         SEEK cIdPos + cIdVd + DToS( dDatum ) + cBrDok
         DO WHILE !Eof() .AND. pos->( IdPos + IdVd + DToS( datum ) + BrDok ) == cIdPos + cIdVd + DToS( dDatum ) + cBrDok
            DO CASE
            CASE pos_doks->idvd == "IN"
               // samo ako je razlicit iznos od 0
               // ako je 0 onda ne treba mnoziti sa cijenom
               IF pos->kol2 <> 0
                  nIznos += pos->kol2 * pos->cijena
               ENDIF
            CASE pos_doks->IdVd == VD_NIV
               nIznos += pos->kolicina * ( pos->ncijena - pos->cijena )
            OTHERWISE
               nIznos += pos->kolicina * pos->cijena
            ENDCASE
            SKIP
         ENDDO
      ENDIF
   ENDIF

   SELECT pos_doks
   cRet := Str( nIznos, 13, 2 )

   RETURN ( cRet )




// ------------------------------------------------------------------
// pos, uzimanje novog broja za tops dokument
// ------------------------------------------------------------------
FUNCTION pos_novi_broj_dokumenta( id_pos, tip_dokumenta, dat_dok )

   LOCAL _broj := 0
   LOCAL _broj_doks := 0
   LOCAL _param
   LOCAL _tmp, _rest
   LOCAL _ret := ""
   LOCAL _t_area := Select()

   IF dat_dok == NIL
      dat_dok := gDatum
   ENDIF

   // param: pos/10/10
   _param := "pos" + "/" + id_pos + "/" + tip_dokumenta
   _broj := fetch_metric( _param, nil, _broj )

   // konsultuj i doks uporedo
   O_POS_DOKS
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_pos + tip_dokumenta + DToS( dat_dok ) + "Ž"
   SKIP -1

   IF field->idpos == id_pos .AND. field->idvd == tip_dokumenta .AND. DToS( field->datum ) == DToS( dat_dok )
      _broj_doks := Val( field->brdok )
   ELSE
      _broj_doks := 0
   ENDIF

   // uzmi sta je vece, doks broj ili globalni brojac
   _broj := Max( _broj, _broj_doks )

   // uvecaj broj
   ++ _broj

   // ovo ce napraviti string prave duzine...
   _ret := PadL( AllTrim( Str( _broj ) ), 6  )

   // upisi ga u globalni parametar
   set_metric( _param, nil, _broj )

   SELECT ( _t_area )

   RETURN _ret


// ------------------------------------------------------------
// setovanje parametra brojaca na admin meniju
// ------------------------------------------------------------
FUNCTION pos_set_param_broj_dokumenta()

   LOCAL _param
   LOCAL _broj := 0
   LOCAL _broj_old
   LOCAL _id_pos := gIdPos
   LOCAL _tip_dok := "42"

   Box(, 2, 60 )

   @ m_x + 1, m_y + 2 SAY "Dokument:" GET _id_pos
   @ m_x + 1, Col() + 1 SAY "-" GET _tip_dok

   READ

   IF LastKey() == K_ESC
      BoxC()
      RETURN
   ENDIF

   // param: pos/10/10
   _param := "pos" + "/" + _id_pos + "/" + _tip_dok
   _broj := fetch_metric( _param, nil, _broj )
   _broj_old := _broj

   @ m_x + 2, m_y + 2 SAY "Zadnji broj dokumenta:" GET _broj PICT "999999"

   READ

   BoxC()

   IF LastKey() != K_ESC
      // snimi broj u globalni brojac
      IF _broj <> _broj_old
         set_metric( _param, nil, _broj )
      ENDIF
   ENDIF

   RETURN



// ------------------------------------------------------------
// resetuje brojač dokumenta ako smo pobrisali dokument
// ------------------------------------------------------------
FUNCTION pos_reset_broj_dokumenta( id_pos, tip_dok, broj_dok )

   LOCAL _param
   LOCAL _broj := 0

   // param: fakt/10/10
   _param := "pos" + "/" + id_pos + "/" + tip_dok
   _broj := fetch_metric( _param, nil, _broj )

   IF Val( AllTrim( broj_dok ) ) == _broj
      -- _broj
      // smanji globalni brojac za 1
      set_metric( _param, nil, _broj )
   ENDIF

   RETURN



FUNCTION Del_Skip()

   LOCAL nNextRec

   nNextRec := 0
   SKIP
   nNextRec := RecNo()
   SKIP -1
   my_delete()
   GO nNextRec

   RETURN



FUNCTION GoTop2()

   GO TOP
   IF Deleted()
      SKIP
   ENDIF

   RETURN



/*! \fn SR_ImaRobu(cPom,cIdRoba)
 *  \brief Funkcija koja daje .t. ako se cIdRoba nalazi na posmatranom racunu
 *  \param cPom
 *  \param cIdRoba
 */

FUNCTION SR_ImaRobu( cPom, cIdRoba )

   LOCAL lVrati := .F.
   LOCAL nArr := Select()

   SELECT POS
   Seek2( cPom + cIdRoba )

   IF POS->( IdPos + IdVd + DToS( datum ) + BrDok + idroba ) == cPom + cIdRoba
      lVrati := .T.
   ENDIF

   SELECT ( nArr )

   RETURN ( lVrati )



/*! \fn Priprz2Pos()
 *  \brief prebaci iz priprz -> pos,doks
 *  \note azuriranje dokumenata zaduzenja, nivelacija
 *
 */

FUNCTION Priprz2Pos()

   LOCAL lNivel
   LOCAL _rec
   LOCAL _cnt := 0
   LOCAL _tbl_pos := "pos_pos"
   LOCAL _tbl_doks := "pos_doks"
   LOCAL _ok := .T.
   LOCAL _t_rec
   LOCAL _cnt_no
   LOCAL _id_tip_dok
   LOCAL _dok_count

   lNivel := .F.

   SELECT ( cRsDbf )
   SET ORDER TO TAG "ID"

   _dok_count := priprz->( RecCount() )

   log_write( "F18_DOK_OPER: azuriranje stavki iz priprz u pos/doks, br.zapisa: " + AllTrim( Str( _dok_count ) ), 2 )

   Box(, 3, 60 )

   // lockuj semafore
   IF !f18_free_tables( { "pos_pos", "pos_doks" } )
      MsgC()
      RETURN .F.
   ENDIF

   sql_table_update( nil, "BEGIN" )

   SELECT PRIPRZ
   GO TOP

   SELECT pos_doks
   APPEND BLANK

   _rec := dbf_get_rec()
   _rec[ "idpos" ] := priprz->idpos
   _rec[ "idvd" ] := priprz->idvd
   _rec[ "datum" ] := priprz->datum
   _rec[ "brdok" ] := priprz->brdok
   _rec[ "vrijeme" ] := priprz->vrijeme
   _rec[ "idvrstep" ] := priprz->idvrstep
   _rec[ "idgost" ] := priprz->idgost
   _rec[ "idradnik" ] := priprz->idradnik
   _rec[ "m1" ] := priprz->m1
   _rec[ "prebacen" ] := priprz->prebacen
   _rec[ "smjena" ] := priprz->smjena

   // tip dokumenta
   _id_tip_dok := _rec[ "idvd" ]

   @ m_x + 1, m_y + 2 SAY "    AZURIRANJE DOKUMENTA U TOKU ..."
   @ m_x + 2, m_y + 2 SAY "Formiran dokument: " + AllTrim( _rec[ "idvd" ] ) + "-" + _rec[ "brdok" ] + " / zap: " + ;
      AllTrim( Str( _dok_count ) )

   update_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )

   // upis inventure/nivelacije
   SELECT PRIPRZ

   DO WHILE !Eof()

      _t_rec := RecNo()

      // dodaj stavku u pos
      SELECT POS
      APPEND BLANK

      _rec := dbf_get_rec()
      _rec[ "idpos" ] := priprz->idpos
      _rec[ "idvd" ] := priprz->idvd
      _rec[ "datum" ] := priprz->datum
      _rec[ "brdok" ] := priprz->brdok
      _rec[ "m1" ] := priprz->m1
      _rec[ "prebacen" ] := priprz->prebacen
      _rec[ "iddio" ] := priprz->iddio
      _rec[ "idodj" ] := priprz->idodj
      _rec[ "idcijena" ] := priprz->idcijena
      _rec[ "idradnik" ] := priprz->idradnik
      _rec[ "idroba" ] := priprz->idroba
      _rec[ "idtarifa" ] := priprz->idtarifa
      _rec[ "kolicina" ] := priprz->kolicina
      _rec[ "kol2" ] := priprz->kol2
      _rec[ "mu_i" ] := priprz->mu_i
      _rec[ "ncijena" ] := priprz->ncijena
      _rec[ "cijena" ] := priprz->cijena
      _rec[ "smjena" ] := priprz->smjena
      _rec[ "c_1" ] := priprz->c_1
      _rec[ "c_2" ] := priprz->c_2
      _rec[ "c_3" ] := priprz->c_3
      _rec[ "rbr" ] := PadL( AllTrim( Str( ++_cnt ) ), 5 )

      @ m_x + 3, m_y + 2 SAY "Stavka " + AllTrim( Str( _cnt ) ) + " roba: " + _rec[ "idroba" ]

      update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT" )

      SELECT PRIPRZ

      // ako je inventura ne treba nista dirati u sifrarniku...
      IF _id_tip_dok <> "IN"
         // azur sifrarnik robe na osnovu priprz
         azur_sif_roba_row()
      ENDIF

      SELECT PRIPRZ
      GO ( _t_rec )
      SKIP

   ENDDO

   BoxC()

   f18_free_tables( { "pos_pos", "pos_doks" } )
   sql_table_update( nil, "END" )

   MsgO( "brisem pripremu...." )

   // ostalo je jos da izbrisemo stavke iz pomocne baze
   SELECT PRIPRZ

   my_dbf_zap()

   MsgC()

   RETURN



// ------------------------------------------
// azuriraj sifrarnik robe
// priprz -> roba
// ------------------------------------------
STATIC FUNCTION azur_sif_roba_row()

   LOCAL _rec
   LOCAL _field_mpc
   LOCAL _update := .F.

   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   IF gSetMPCijena == "1"
      _field_mpc := "mpc"
   ELSE
      _field_mpc := "mpc" + AllTrim( gSetMPCijena )
   ENDIF

   // pozicioniran sam na robi
   SEEK priprz->idroba

   lNovi := .F.

   IF !Found()

      // novi artikal
      // roba (ili sirov)
      APPEND BLANK

      _rec := dbf_get_rec()
      _rec[ "id" ] := priprz->idroba
      _update := .T.

   ELSE

      _rec := dbf_get_rec()

   ENDIF

   _rec[ "naz" ] := priprz->robanaz
   _rec[ "jmj" ] := priprz->jmj

   IF !IsPDV()
      // u ne-pdv rezimu je bilo bitno da preknjizenje na pdv ne pokvari
      // star cijene
      IF katops->idtarifa <> "PDV17"
         _rec[ _field_mpc ] := Round( priprz->cijena, 3 )
      ENDIF
   ELSE

      IF cIdVd == "NI"
         // nivelacija - u sifrarnik stavi novu cijenu
         _rec[ _field_mpc ] := Round( priprz->ncijena, 3 )
      ELSE
         _rec[ _field_mpc ] := Round( priprz->cijena, 3 )
      ENDIF

   ENDIF

   _rec[ "idtarifa" ] := priprz->idtarifa
   _rec[ "k1" ] := priprz->k1
   _rec[ "k2" ] := priprz->k2
   _rec[ "k7" ] := priprz->k7
   _rec[ "k8" ] := priprz->k8
   _rec[ "k9" ] := priprz->k9
   _rec[ "n1" ] := priprz->n1
   _rec[ "n2" ] := priprz->n2
   _rec[ "barkod" ] := priprz->barkod

   update_rec_server_and_dbf( "roba", _rec, 1, "CONT" )

   RETURN


// ---------------------------------------------------------------
// koriguje broj racuna
// ---------------------------------------------------------------
STATIC FUNCTION _fix_rn_no( racun )

   LOCAL _a_rn := {}

   IF !Empty( racun ) .AND. ( "-" $ racun )

      _a_rn := TokToNiz( racun, "-" )

      IF !Empty( _a_rn[ 2 ] )
         racun := PadR( AllTrim( _a_rn[ 2 ] ), 6 )
      ENDIF

   ENDIF

   RETURN .T.



// ---------------------------------------------------------------
// storniranje racuna po fiskalnom isjecku
// ---------------------------------------------------------------
FUNCTION pos_storno_fisc_no()

   LOCAL nTArea := Select()
   LOCAL _rec
   LOCAL _datum, _broj_rn
   LOCAL _fisc_broj := 0
   PRIVATE GetList := {}
   PRIVATE aVezani := {}

   Box(, 1, 55 )
   @ m_x + 1, m_y + 2 SAY "broj fiskalnog isjecka:" GET _fisc_broj ;
      VALID pos_vrati_broj_racuna_iz_fiskalnog( _fisc_broj, @_broj_rn, @_datum ) ;
      PICT "9999999999"
   READ
   BoxC()

   IF LastKey() == K_ESC
      SELECT ( nTArea )
      RETURN
   ENDIF

   // filuj stavke storno racuna
   __fill_storno( _datum, _broj_rn, Str( _fisc_broj, 10 ) )

   SELECT ( nTArea )

   // ovo refreshira pripremu
   oBrowse:goBottom()
   oBrowse:refreshAll()
   oBrowse:dehilite()

   DO WHILE !oBrowse:Stabilize() .AND. ( ( Ch := Inkey() ) == 0 )
   ENDDO

   RETURN


// -------------------------------------
// storniranje racuna
// -------------------------------------
FUNCTION pos_storno_rn( lSilent, cSt_rn, dSt_date, cSt_fisc )

   LOCAL nTArea := Select()
   LOCAL _rec
   LOCAL _datum := gDatum
   LOCAL _danasnji := "D"
   PRIVATE GetList := {}
   PRIVATE aVezani := {}

   IF lSilent == nil
      lSilent := .F.
   ENDIF

   IF cSt_rn == nil
      cSt_rn := Space( 6 )
   ENDIF

   IF dSt_date == nil
      dSt_date := Date()
   ENDIF

   IF cSt_fisc == nil
      cSt_fisc := Space( 10 )
   ENDIF

   SELECT ( F_POS )
   IF !Used()
      O_POS
   ENDIF

   SELECT ( F_POS_DOKS )
   IF !Used()
      O_POS_DOKS
   ENDIF

   Box(, 4, 55 )

   @ m_x + 1, m_y + 2 SAY "Racun je danasnji ?" GET _danasnji VALID _danasnji $ "DN" PICT "@!"

   READ

   IF _danasnji == "N"
      _datum := NIL
   ENDIF

   @ m_x + 2, m_y + 2 SAY "stornirati pos racun broj:" GET cSt_rn VALID {|| PRacuni( @_datum, @cSt_rn, .T. ), _fix_rn_no( @cSt_rn ), dSt_date := _datum,  .T. }
   @ m_x + 3, m_y + 2 SAY "od datuma:" GET dSt_date

   READ

   cSt_rn := PadL( AllTrim( cSt_rn ), 6 )

   IF Empty( cSt_fisc )
      SELECT pos_doks
      SEEK gIdPos + "42" + DToS( dSt_date ) + cSt_rn
      cSt_fisc := PadR( AllTrim( Str( pos_doks->fisc_rn ) ), 10 )
   ENDIF

   @ m_x + 4, m_y + 2 SAY "broj fiskalnog isjecka:" GET cSt_fisc

   READ

   BoxC()

   IF LastKey() == K_ESC
      SELECT ( nTArea )
      RETURN
   ENDIF

   IF Empty( cSt_rn )
      SELECT ( nTArea )
      RETURN
   ENDIF

   SELECT ( nTArea )

   // filuj stavke storno racuna
   __fill_storno( dSt_date, cSt_rn, cSt_fisc )

   SELECT ( F_POS )
   USE
   SELECT ( F_POS_DOKS )
   USE

   SELECT ( nTArea )

   IF lSilent == .F.

      // ovo refreshira pripremu
      oBrowse:goBottom()
      oBrowse:refreshAll()
      oBrowse:dehilite()

      DO WHILE !oBrowse:Stabilize() .AND. ( ( Ch := Inkey() ) == 0 )
      ENDDO

   ENDIF

   RETURN


// --------------------------------------------------
// filuje pripremu sa storno stavkama
// --------------------------------------------------
STATIC FUNCTION __fill_storno( rn_datum, storno_rn, broj_fiscal )

   LOCAL _t_area := Select()
   LOCAL _t_roba, _rec

   // napuni pripremu sa stavkama racuna za storno
   SELECT ( F_POS )
   IF !Used()
      O_POS
   ENDIF
   SELECT pos
   SEEK gIdPos + "42" + DToS( rn_datum ) + storno_rn

   DO WHILE !Eof() .AND. field->idpos == gIdPos ;
         .AND. field->brdok == storno_rn ;
         .AND. field->idvd == "42"

      _t_roba := field->idroba

      SELECT roba
      SEEK _t_roba

      SELECT pos

      _rec := dbf_get_rec()
      hb_HDel( _rec, "rbr" )

      SELECT _pos_pripr
      APPEND BLANK

      _rec[ "brdok" ] :=  "PRIPRE"
      _rec[ "kolicina" ] := ( _rec[ "kolicina" ] * -1 )
      _rec[ "robanaz" ] := roba->naz
      _rec[ "datum" ] := gDatum
      // placanje uvijek resetovati kod storna na gotovinu
      _rec[ "idvrstep" ] := "01"

      IF Empty( broj_fiscal )
         _rec[ "c_1" ] := AllTrim( storno_rn )
      ELSE
         _rec[ "c_1" ] := AllTrim( broj_fiscal )
      ENDIF

      dbf_update_rec( _rec )

      SELECT pos
      SKIP

   ENDDO

   SELECT pos
   USE

   SELECT ( _t_area )

   RETURN



// ---------------------------------------------------------------------
// pos brisanje dokumenta
// ---------------------------------------------------------------------
FUNCTION pos_brisi_dokument( id_pos, id_vd, dat_dok, br_dok )

   LOCAL _ok := .T.
   LOCAL _t_area := Select()
   LOCAL _ret := .F.
   LOCAL _rec

   SELECT pos
   SET FILTER TO
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_pos + id_vd + DToS( dat_dok ) + br_dok

   IF !Found()

      // potrazi i u doks
      SELECT pos_doks
      SET FILTER TO
      SET ORDER TO TAG "1"
      GO TOP
      SEEK id_pos + id_vd + DToS( dat_dok ) + br_dok

      // nema ga stvarno !!!
      IF !Found()
         SELECT ( _t_area )
         RETURN _ret
      ENDIF

   ENDIF

   log_write( "F18_DOK_OPER: pos, brisanje racuna broj: " + br_dok + " od " + DToC( dat_dok ), 2 )
	           	
   IF !f18_lock_tables( { "pos_pos", "pos_doks" } )
      SELECT ( _t_area )
      RETURN _ret
   ENDIF

   sql_table_update( nil, "BEGIN" )

   _ret := .T.

   MsgO( "Brisanje dokumenta iz glavne tabele u toku ..." )

   SELECT pos
   GO TOP
   SEEK id_pos + id_vd + DToS( dat_dok ) + br_dok

   IF Found()
      _rec := dbf_get_rec()
      delete_rec_server_and_dbf( "pos_pos", _rec, 2, "CONT" )
   ENDIF

   SELECT pos_doks
   GO TOP
   SEEK id_pos + id_vd + DToS( dat_dok ) + br_dok

   IF Found()
      _rec := dbf_get_rec()
      delete_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )
   ENDIF

   f18_free_tables( { "pos_pos", "pos_doks" } )
   sql_table_update( nil, "END" )

   MsgC()

   SELECT ( _t_area )

   RETURN _ret



// -------------------------------------
// povrat racuna u pripremu
// -------------------------------------
FUNCTION pos_povrat_rn( cSt_rn, dSt_date )

   LOCAL nTArea := Select()
   LOCAL _rec
   PRIVATE GetList := {}

   IF Empty( cSt_rn )
      SELECT ( nTArea )
      RETURN
   ENDIF

   cSt_rn := PadL( AllTrim( cSt_rn ), 6 )

   // napuni pripremu sa stavkama racuna za storno
   SELECT pos
   SEEK gIdPos + "42" + DToS( dSt_date ) + cSt_rn

   msgo( "Povrat dokumenta u pripremu ... " )

   DO WHILE !Eof() .AND. field->idpos == gIdPos ;
         .AND. field->brdok == cSt_rn ;
         .AND. field->idvd == "42"

      cT_roba := field->idroba
      SELECT roba
      SEEK cT_roba

      SELECT pos

      _rec := dbf_get_rec()
      hb_HDel( _rec, "rbr" )

      SELECT _pos_pripr
      APPEND BLANK

      _rec[ "robanaz" ] := roba->naz

      dbf_update_rec( _rec )

      SELECT pos

      SKIP

   ENDDO

   msgC()

   // pos brisi dokument iz baze...
   pos_brisi_dokument( gIdPos, VD_RN, dSt_date, cSt_rn )

   SELECT ( nTArea )

   RETURN


// ---------------------------------------------
// import sifrarnika iz fmk
// ---------------------------------------------
FUNCTION pos_import_fmk_roba()

   LOCAL _location := fetch_metric( "pos_import_fmk_roba_path", my_user(), PadR( "", 300 ) )
   LOCAL _cnt := 0
   LOCAL _rec

   O_ROBA

   _location := PadR( AllTrim( _location ), 300 )

   Box(, 1, 60 )
   @ m_x + 1, m_y + 2 SAY "lokacija:" GET _location PICT "@S50"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   // snimi parametar
   set_metric( "pos_import_fmk_roba_path", my_user(), _location )

   SELECT ( F_TMP_1 )
   IF Used()
      USE
   ENDIF

   my_use_temp( "TOPS_ROBA", AllTrim( _location ), .F., .T. )
   INDEX on ( "id" ) TAG "ID"

   // ----------
   // predji na tops_roba

   SELECT tops_roba
   SET ORDER TO TAG "ID"
   GO TOP

   f18_lock_tables( { "roba" } )
   sql_table_update( nil, "BEGIN" )

   Box(, 1, 60 )

   DO WHILE !Eof()

      _id_roba := field->id

      SELECT roba
      GO TOP
      SEEK _id_roba

      IF !Found()
         APPEND BLANK
      ENDIF

      _rec := dbf_get_rec()

      _rec[ "id" ] := tops_roba->id

      _rec[ "naz" ] := tops_roba->naz
      _rec[ "jmj" ] := tops_roba->jmj
      _rec[ "idtarifa" ] := tops_roba->idtarifa
      _rec[ "barkod" ] := tops_roba->barkod
      _rec[ "tip" ] := tops_roba->tip
      _rec[ "mpc" ] := tops_roba->cijena1
      _rec[ "mpc2" ] := tops_roba->cijena2

      IF tops_roba->( FieldPos( "fisc_plu" ) ) <> 0
         _rec[ "fisc_plu" ] := tops_roba->fisc_plu
      ENDIF

      ++ _cnt
      @ m_x + 1, m_y + 2 SAY "import roba: " + _rec[ "id" ] + ":" + PadR( _rec[ "naz" ], 20 ) + "..."
      update_rec_server_and_dbf( "roba", _rec, 1, "CONT" )

      SELECT tops_roba
      SKIP

   ENDDO

   BoxC()

   f18_free_tables( { "roba" } )
   sql_table_update( nil, "END" )

   SELECT ( F_TMP_1 )
   USE

   IF _cnt > 0
      msgbeep( "Update " + AllTrim( Str( _cnt ) ) + " zapisa !" )
   ENDIF

   CLOSE ALL

   RETURN
