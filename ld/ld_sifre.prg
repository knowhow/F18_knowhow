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
MEMVAR wId, wNaz, wIdRj, wVr_invalid, wSt_invalid
MEMVAR cFooter, lPInfo


STATIC __filter_radn := .F.


FUNCTION P_Radn( cId, dx, dy )

   LOCAL i, lRet
   LOCAL cPom, nPom, cPom2
   LOCAL aKol

   PRIVATE ImeKol
   PRIVATE kol
   PRIVATE cFooter := ""
   PRIVATE lPInfo := .F.

   IF PCount() = 0
      lPInfo := .T.
   ENDIF

   PushWA()
   O_RADN_NOT_USED


   // filterisanje tabele radnika
   aktivni_radnici_filter( .T. )

   ImeKol := {}
   AAdd( ImeKol, { Lokal( PadR( "Id", 6 ) ), {|| field->id }, "id", {|| .T. }, {|| vpsifra( wId, "1" ) } } )
   AAdd( ImeKol, { Lokal( PadR( "Prezime", 20 ) ), {|| field->naz }, "naz" } )
   AAdd( ImeKol, { Lokal( PadR( "Ime roditelja", 15 ) ), {|| field->imerod }, "imerod" } )
   AAdd( ImeKol, { Lokal( PadR( "Ime", 15 ) ), {|| field->ime }, "ime" } )
   AAdd( ImeKol, { PadR( iif( gBodK == "1", Lokal( "Br.bodova" ), Lokal( "Koeficij." ) ), 10 ), {|| field->brbod }, "brbod" } )
   AAdd( ImeKol, { Lokal( PadR( "MinR%", 5 ) ), {|| field->kminrad }, "kminrad" } )

   IF RADN->( FieldPos( "KLO" ) ) <> 0

      AAdd( ImeKol, { Lokal( PadR( "Koef.l.odb.", 15 ) ), {|| field->klo }, "klo" } )
      AAdd( ImeKol, { Lokal( PadR( "Tip rada", 15 ) ), {|| field->tiprada }, "tiprada", ;
         {|| .T. }, {|| wtiprada $ " #I#A#S#N#P#U#R" .OR. MsgTipRada() } } )

      IF RADN->( FieldPos( "SP_KOEF" ) ) <> 0
         AAdd( ImeKol, { Lokal( PadR( "prop.koef", 15 ) ), {|| field->sp_koef }, "sp_koef" } )
      ENDIF

      IF RADN->( FieldPos( "OPOR" ) ) <> 0
         AAdd( ImeKol, { Lokal( PadR( "oporeziv", 15 ) ), {|| field->opor }, "opor" } )
      ENDIF

      IF RADN->( FieldPos( "TROSK" ) ) <> 0
         AAdd( ImeKol, { Lokal( PadR( "koristi trosk.", 15 ) ), {|| field->trosk }, "trosk" } )
      ENDIF

   ENDIF

   AAdd( ImeKol, { Lokal( PadR( "StrSpr", 6 ) ), {|| PadC( field->Idstrspr, 6 ) }, "idstrspr", ;
      {|| .T. }, {|| P_StrSpr( @wIdStrSpr ) } } )
   AAdd( ImeKol, { Lokal( PadR( "V.Posla", 6 ) ), {|| PadC( field->IdVPosla, 6 ) }, "IdVPosla", ;
      {|| .T. }, {|| Empty( wIdvposla ) .OR. P_VPosla( @wIdVPosla ) } } )
   AAdd( ImeKol, { Lokal( PadR( "Ops.Stan", 8 ) ), {|| PadC( field->IdOpsSt, 8 ) }, "IdOpsSt", ;
      {|| .T. }, {|| P_Ops( @wIdOpsSt ) } } )
   AAdd( ImeKol, { Lokal( PadR( "Ops.Rada", 8 ) ), {|| PadC( field->IdOpsRad, 8 ) }, "IdOpsRad", ;
      {|| .T. }, {|| P_Ops( @wIdOpsRad ) } } )
   AAdd( ImeKol, { Lokal( PadR( "Maticni Br.", 13 ) ), {|| PadC( field->matbr, 13 ) }, "MatBr", ;
      {|| .T. }, {|| .T. } } )
   AAdd( ImeKol, { Lokal( PadR( "Dat.Od", 8 ) ), {|| field->datod }, "datod", {|| .T. }, {|| .T. } } )
   AAdd( ImeKol, { Lokal( PadR( "POL", 3 ) ), {|| PadC( field->pol, 3 ) }, "POL", {|| .T. }, {|| wPol $ "MZ" } } )
   AAdd( ImeKol, { PadR( "K1", 2 ), {|| PadC( field->k1, 2 ) }, "K1", {|| .T. }, {|| .T. } } )
   AAdd( ImeKol, { PadR( "K2", 2 ), {|| PadC( field->k2, 2 ) }, "K2", {|| .T. }, {|| .T. } } )
   AAdd( ImeKol, { PadR( "K3", 2 ), {|| PadC( field->k3, 2 ) }, "K3", {|| .T. }, {|| .T. } } )
   AAdd( ImeKol, { PadR( "K4", 2 ), {|| PadC( field->k4, 2 ) }, "K4", {|| .T. }, {|| .T. } } )
   AAdd( ImeKol, { Lokal( PadR( "PorOl", 6 ) ), {|| field->porol }, "POROL", {|| .T. }, {|| .T. } } )

   AAdd( ImeKol, { Lokal( PadR( "Radno mjesto", 30 ) ), {|| field->rmjesto }, "RMJESTO", {|| .T. }, {|| .T. } } )

   AAdd( ImeKol, { Lokal( PadR( "Br.Knjizice ", 12 ) ), {|| PadC( field->brknjiz, 12 ) }, "brknjiz", {|| .T. }, {|| .T. } } )

   AAdd( ImeKol, { Lokal( PadR( "Br.Tekuceg rac.", 20 ) ), {|| PadC( field->brtekr, 20 ) }, "brtekr", {|| .T. }, {|| .T. } } )

   AAdd( ImeKol, { Lokal( PadR( "Isplata", 7 ) ), {|| PadC( field->isplata, 7 ) }, "isplata", {|| .T. }, {|| wIsplata $ "  #TR#SK#BL" .OR. MsgIspl() } } )
   AAdd( ImeKol, { Lokal( PadR( "Banka", 6 ) ), {|| PadC( field->idbanka, 6 ) }, "idbanka", {|| .T. }, {|| Empty( WIDBANKA ) .OR. P_Kred( @widbanka ) } } )

   AAdd( ImeKol, { Lokal( PadR( "OSN.Bol", 11 ) ), {|| field->osnbol }, "osnbol" } )

   IF radn->( FieldPos( "N1" ) <> 0 )
      AAdd( ImeKol, { PadC( "N1", 12 ), {|| field->n1 }, "n1" } )
      AAdd( ImeKol, { PadC( "N2", 12 ), {|| field->n2 }, "n2" } )
      AAdd( ImeKol, { PadC( "N3", 12 ), {|| field->n3 }, "n3" } )
   ENDIF

   IF radn->( FieldPos( "IDRJ" ) <> 0 )
      AAdd( ImeKol, { "ID RJ", {|| field->idrj }, "idrj", ;
         {|| .T. }, {|| Empty( wIdRj ) .OR. P_LD_Rj( @wIdRj ) } } )
   ENDIF

   // Dodaj specificna polja za popunu obrasca DP
   IF radn->( FieldPos( "STREETNAME" ) <> 0 )
      AAdd( ImeKol, { Lokal( PadC( "Ime ul.", 40 ) ), {|| field->streetname }, "streetname" } )
      AAdd( ImeKol, { Lokal( PadC( "Broj ul.", 10 ) ), {|| field->streetnum }, "streetnum" } )
      AAdd( ImeKol, { Lokal( PadC( "Zaposl.od", 12 ) ), {|| field->hiredfrom }, "hiredfrom", ;
         {|| .T. }, {|| P_HiredFrom( @wHiredfrom ) } } )
      AAdd( ImeKol, { Lokal( PadC( "Zaposl.do", 12 ) ), {|| field->hiredto }, "hiredto" } )
   ENDIF


   IF radn->( FieldPos( "AKTIVAN" ) ) <> 0
      AAdd( ImeKol, { "Aktivan?", {|| field->aktivan }, "aktivan" } )
   ENDIF

   IF radn->( FieldPos( "BEN_SRMJ" ) ) <> 0
      AAdd( ImeKol, { "Benef.sifra", {|| field->ben_srmj }, "ben_srmj" } )
   ENDIF

   Kol := {}

   IF gMinR == "B"
      ImeKol[ 6 ] := { PadR( "MinR", 7 ), {|| Transform( field->kminrad, "9999.99" ) }, "kminrad" }
   ENDIF

   FOR i := 1 TO 9
      cPom := "S" + AllTrim( Str( i ) )
      nPom := Len( ImeKol )
      IF radn->( FieldPos( cPom ) <> 0 )
         cPom2 := IzFmkIni( "LD", "OpisRadn" + cPom, "KOEF_" + cPom, KUMPATH )
         AAdd( ImeKol, { cPom + "(" + cPom2 + ")", {|| &cPom. }, cPom } )
      ENDIF
   NEXT

   aKol := { PadR( "vr.invalid", 10 ), {|| Transform( field->vr_invalid, "9" ) }, "vr_invalid", ;
      {|| .T. }, {|| Wvr_invalid == 0 .OR. valid_vrsta_invaliditeta( Wvr_invalid ) }, NIL,  "9" }

   AAdd( ImeKol,  aKol )

   aKol := { PadR( "st.invalid", 10 ), {|| Transform( field->st_invalid, "999" ) }, "st_invalid", ;
      {|| .T. }, {|| Wst_invalid >= 0 }, NIL, "999"  }
   AAdd( ImeKol,  aKol )


   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, I )
   NEXT

   lRet := PostojiSifra( F_RADN, 1, MAXROWS() - 15, MAXCOLS() - 15, "Lista radnika" + Space( 5 ) + "<S> filter radnika on/off", @cId, dx, dy, {| Ch| RadBl( Ch ) },,,,, { "ID" } )

   PopWa( F_RADN )

   RETURN lRet


// ------------------------------------------
// filterisanje tabele radnika
// ------------------------------------------
STATIC FUNCTION aktivni_radnici_filter( lFiltered )

   LOCAL cFilter := ""


   IF radn->( FieldPos( "aktivan" ) ) == 0
      RETURN .F.
   ENDIF

   IF lFiltered == nil
      lFiltered := .T.
   ENDIF

   cFilter := "aktivan $ ' #D'"

   // pozicioniraj se na radnika
   SELECT RADN

   IF lFiltered == .T. .AND. gRadnFilter == "D"
      SET FILTER to &cFilter
      GO TOP
   ELSE
      SET FILTER TO
      GO TOP
   ENDIF


   RETURN .T.



/*! \fn P_HiredFrom(dHiredFrom)
 *  \brief
 *  \param dHiredFrom
 */
FUNCTION P_HiredFrom( dHiredFrom )

   IF Empty( DToS( dHiredFrom ) ) .AND. !Empty( DToS( field->datod ) ) .AND. Pitanje(, Lokal( "Popuni polje na osnovu polja Datum Od" ), "D" ) == "D"
      dHiredFrom := field->datod
   ENDIF

   RETURN .T.

/*! \fn P_StreetNum(cStreetNum)
 *  \brief
 *  \param cStreetNum - vrijednost polja streetnum
 */
FUNCTION P_StreetNum( cStreetNum )

   IF Empty( field->streetnum )
      cStreetNum := Space( 5 ) + "0"
   ENDIF

   RETURN .T.


// ---------------------------------------------
// ispisuje info o poreskoj kartici
// ---------------------------------------------
STATIC FUNCTION p_pkartica( cIdRadn )

   LOCAL nTA := Select()

   O_PK_RADN
   SELECT pk_radn
   SEEK cIdRadn

   IF Found() .AND. field->idradn == cIdRadn
      @ PRow() + 8, PCol() + 8 SAY "               " COLOR "W+/W"
   ELSE
      @ PRow() + 8, PCol() + 8 SAY "pk: nepopunjena" COLOR "W+/R+"
   ENDIF

   SELECT ( nTA )

   RETURN .T.



// --------------------------------------------
// radn. blok funkcije
// --------------------------------------------
FUNCTION RadBl( Ch )

   LOCAL cMjesec := gMjesec
   LOCAL _rec

   IF lPInfo == .T.
      // ispisi info o poreskoj kartici
      p_pkartica( field->id )
   ENDIF

   __filter_radn := .F.

   IF ( Ch == K_ALT_M )

      Box(, 4, 60 )
      @ m_x + 1, m_y + 2 SAY "Postavljenje koef. minulog rada:"
      @ m_x + 2, m_y + 2 SAY "Pazite da ovu opciju ne izvrsite vise puta za isti mjesec !"
      @ m_x + 4, m_y + 2 SAY "Mjesec:" GET cMjesec PICT "99"
      READ
      BoxC()

      IF ( LastKey() == K_ESC )
         RETURN DE_CONT
      ENDIF

      MsgO( Lokal( "Prolazim kroz tabelu radnika.." ) )

      SELECT radn
      GO TOP

      sql_table_update( nil, "BEGIN" )
      f18_lock_tables( { "ld_radn" }, .T. )


      DO WHILE !Eof()

         _rec := dbf_get_rec()

         IF Month( _rec[ "datod" ] ) == cMjesec

            IF _rec[ "pol" ] == "M"
               _rec[ "kminrad" ] := _rec[ "kminrad" ] + gMRM
            ELSEIF pol == "Z"
               _rec[ "kminrad" ] := _rec[ "kminrad" ] + gMRZ
            ENDIF

         ENDIF

         IF _rec[ "kminrad" ] > 20
            // ogranicenje minulog rada
            _rec[ "kminrad" ] := 20
         ENDIF

         update_rec_server_and_dbf( "ld_radn", _rec, 1, "CONT" )

         SKIP
      ENDDO

      sql_table_update( nil, "END" )
      f18_free_tables( { "ld_radn" } )

      MsgC()

      GO TOP
      RETURN DE_REFRESH

   ELSEIF ( Ch == K_CTRL_T )

      IF ImaURadKr( radn->id, "2" )
         Beep( 1 )
         Msg( Lokal( "Stavka radnika se ne moze brisati jer se vec nalazi u obracunu!" ) )
         RETURN 7
      ENDIF

   ELSEIF ( Ch == K_F2 )

      IF ImaURadKr( radn->id, "2" )
         RETURN 99
      ENDIF

   ELSEIF ( Upper( Chr( Ch ) ) == "P" )

      // poreska kartica, vraca faktor odbitka...
      nFakt := p_kartica( field->id )

      SELECT radn

      IF nFakt >= 0 .AND. nFakt <> radn->klo
         IF Pitanje(, "Postaviti novi faktor licnog odbitka ?", "D" ) == "D"
            _rec := dbf_get_rec()
            _rec[ "klo" ] := nFakt
            update_rec_server_and_dbf( "ld_radn", _rec, 1, "FULL" )
         ENDIF
      ENDIF

      RETURN DE_CONT

   ELSEIF ( Upper( Chr( Ch ) ) == "D" )

      pk_delete( field->id )

      SELECT radn
      RETURN DE_CONT

   ELSEIF Ch == K_CTRL_G

      // setovanje datuma u poreskim karticama
      IF pitanje(, "setovati datum poreskih kartica ?", "N" ) == "D"

         pk_set_date()
         SELECT radn
         RETURN DE_CONT

      ENDIF

   ELSEIF ( Upper( Chr( Ch ) ) == "Q" )

      // filter po ime, prezime itd...
      _filter_radn()
      __filter_radn := .T.
      RETURN DE_REFRESH


   ELSEIF ( Upper( Chr( Ch ) ) == "S" )

      // filter po radnicima
      cTmp := dbFilter()

      IF Empty( cTmp )
         MsgBeep( "prikazuju se samo aktivni radnici ..." )
         aktivni_radnici_filter( .T. )
         RETURN DE_REFRESH
      ELSE
         MsgBeep( "vracam filter na sve radnike ...." )
         aktivni_radnici_filter( .F. )
         RETURN DE_REFRESH
      ENDIF

   ENDIF

   RETURN DE_CONT



// ---------------------------------------------------------------
// filter tabele radnika po pojedinim poljima
// ---------------------------------------------------------------
STATIC FUNCTION _filter_radn()

   LOCAL _ok := .F.
   LOCAL _filter := ""
   LOCAL _ime, _prezime, _imerod
   LOCAL _x := 1
   LOCAL _sort := 2
   PRIVATE GetList := {}

   _ime := Space( 200 )
   _prezime := _ime
   _imerod := _ime

   Box(, 6, 70 )

   @ m_x + _x, m_y + 2 SAY8 "*** FILTER ŠIFARNIKA RADNIKA"

   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "     IME:" GET _ime PICT "@S40"

   ++ _x
   @ m_x + _x, m_y + 2 SAY " PREZIME:" GET _prezime PICT "@S40"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "RODITELJ:" GET _imerod PICT "@S40"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Sortiranje: 1 - sifra, 2 - prezime:" GET _sort PICT "9" VALID _sort >= 1 .AND. _sort <= 2

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   IF !Empty( _prezime )
      IF !Empty( _filter )
         _filter += " .AND. "
      ENDIF
      IF Right( AllTrim( _prezime ), 1 ) <> ";"
         _prezime := AllTrim( _prezime ) + ";"
      ENDIF
      _filter += parsiraj( Upper( _prezime ), "UPPER(naz)" )
   ENDIF

   IF !Empty( _ime )
      IF !Empty( _filter )
         _filter += " .AND. "
      ENDIF
      IF Right( AllTrim( _ime ), 1 ) <> ";"
         _ime := AllTrim( _ime ) + ";"
      ENDIF
      _filter += parsiraj( Upper( _ime ), "UPPER(ime)" )
   ENDIF

   IF !Empty( _imerod )
      IF !Empty( _filter )
         _filter += " .AND. "
      ENDIF
      IF Right( AllTrim( _imerod ), 1 ) <> ";"
         _imerod := AllTrim( _imerod ) + ";"
      ENDIF
      _filter += parsiraj( Upper( _imerod ), "UPPER(imerod)" )
   ENDIF

   IF Empty( _filter )

      // ukidam filter, setujem pravi sort...
      SET FILTER TO
      SET ORDER TO TAG "1"
      GO TOP

      RETURN _ok

   ENDIF

   // postavi filter
   SET FILTER to &( _filter )

   // kako da slozim podatke ?
   IF _sort == 2
      SET ORDER TO TAG "2"
   ELSE
      SET ORDER TO TAG "1"
   ENDIF

   GO TOP
   _ok := .T.

   RETURN _ok




FUNCTION MsgIspl()

   Box(, 3, 50 )
   @ m_x + 1, m_y + 2 SAY8 "Vazeće šifre su: TR - tekući racun   "
   @ m_x + 2, m_y + 2 SAY8 "                 SK - štedna knjizica"
   @ m_x + 3, m_y + 2 SAY8 "                 BL - blagajna"
   Inkey( 0 )
   BoxC()

   RETURN .F.



FUNCTION P_ParObr( cId, dx, dy )

   LOCAL _tmp_id
   PRIVATE imekol := {}
   PRIVATE kol := {}

   AAdd( ImeKol, { PadR( "mjesec", 8 ),  {|| id }, "id", {|| iif( ValType( wId ) == "C", Eval( MemVarBlock( "wId" ), Val( wId ) ), NIL ), .T. } } )
   AAdd( ImeKol, { "godina", {|| godina }, "godina", {|| iif( ValType( wId ) == "N", Eval( MemVarBlock( "wID" ), Str( wId, 2 ) ), NIL ), .T. }  } )
   AAdd( ImeKol, { PadR( "obracun", 10 ), {|| obr }, "obr" } )

   IF IzFMKINI( "LD", "VrBodaPoRJ", "N", KUMPATH ) == "D"
      AAdd( ImeKol, { "rj", {|| IDRJ }, "IDRJ" } )
   ENDIF

   AAdd( ImeKol, { PadR( "opis", 10 ), {|| naz }, "naz" } )
   AAdd( ImeKol, { PadR( iif( gBodK == "1", "vrijednost boda", "vr.koeficijenta" ), 15 ), ;
      {|| vrbod }, "vrbod" } )
   AAdd( ImeKol, { PadR( "n.koef.1", 8 ), {|| k5 }, "k5"  } )
   AAdd( ImeKol, { PadR( "n.koef.2", 8 ), {|| k6 }, "k6"  } )
   AAdd( ImeKol, { PadR( "n.koef.3", 8 ), {|| k7 }, "k7"  } )
   AAdd( ImeKol, { PadR( "n.koef.4", 8 ), {|| k8 }, "k8"  } )
   AAdd( ImeKol, { PadR( "br.sati", 5 ), {|| k1 }, "k1"  } )
   AAdd( ImeKol, { PadR( "prosj.LD", 12 ), {|| Prosld }, "PROSLD"  }  )
   AAdd( ImeKol, { PadR( "mn sat.", 12 ), {|| m_net_sat }, "m_net_sat"  } )
   AAdd( ImeKol, { PadR( "mb sat.", 12 ), {|| m_br_sat }, "m_br_sat"  } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( kol, i )
   NEXT

   RETURN PostojiSifra( F_PAROBR, 1, MAXROWS() -15, MAXCOLS() -20, Lokal( "Parametri obracuna" ), @cId, dx, dy )


FUNCTION g_tp_naz( cId )

   LOCAL nTArea := Select()
   LOCAL xRet := ""

   O_TIPPR
   SELECT tippr
   SEEK cId

   IF Found()
      xRet := AllTrim( tippr->naz )
   ENDIF

   SELECT ( nTArea )

   RETURN xRet





FUNCTION P_TipPr( cId, dx, dy )

   LOCAL i
   PRIVATE imekol := {}
   PRIVATE kol := {}

   AAdd( ImeKol, { PadR( "Id", 2 ), {|| id }, "id", {|| .T. }, {|| vpsifra( wid ) } } )
   AAdd( ImeKol, { PadR( "Naziv", 20 ), {||  naz }, "naz" } )
   AAdd( ImeKol, { "Aktivan", {||  PadC( aktivan, 7 ) }, "aktivan" } )
   AAdd( ImeKol, { "Fiksan", {||  PadC( fiksan, 7 ) }, "fiksan" } )
   AAdd( ImeKol, { PadR( "U fond s.", 10 ), {||  PadC( ufs, 10 ) }, "ufs" } )
   AAdd( ImeKol, { PadR( "U neto", 6 ), {||  PadC( uneto, 6 ) }, "uneto" } )

   IF TIPPR->( FieldPos( "TPR_TIP" ) ) <> 0
      AAdd( ImeKol, { PadR( "tp.tip", 6 ), {||  tpr_tip }, "tpr_tip", {|| .T. }, {|| v_tpr_tip( wtpr_tip ) } } )
   ENDIF

   AAdd( ImeKol, { PadR( "Formula", 200 ), {|| formula }, "formula"  } )
   AAdd( ImeKol, { PadR( "Opis", 8 ), {|| opis }, "opis"  } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   RETURN PostojiSifra( F_TIPPR, 1, MAXROWS() -15, MAXCOLS() -20, Lokal( "Tipovi primanja" ), @cId, dx, dy, {| Ch| TprBl( Ch ) },,,,, { "ID" } )


// -----------------------------------------
// valid tpr_tip
// -----------------------------------------
FUNCTION v_tpr_tip( cTip )

   IF Empty( cTip )
      MsgBeep( "Tip moze biti:##prazno - standardno#N - neto#2 - naknade za rad#X - neoporezive stavke, krediti itd..." )
   ENDIF

   RETURN .T.


// ----------------------------------------
// valid dop_tip
// ----------------------------------------
FUNCTION v_dop_tip( cTip )

   IF Empty( cTip )
      MsgBeep( "Tip moze biti:##prazno - standardno#N - neto#2 - ostale naknade#P - neto + ostale naknade#B - bruto#R - neto na ruke" )
   ENDIF

   RETURN .T.



FUNCTION TprBl( Ch )

   RETURN DE_CONT




FUNCTION P_TipPr2( cId, dx, dy )

   PRIVATE imekol
   PRIVATE kol

   ImeKol := { { PadR( "Id", 2 ), {|| id }, "id", {|| .T. }, {|| vpsifra( wid ) } }, ;
      { PadR( "Naziv", 20 ), {||  naz }, "naz" }, ;
      {      "Aktivan", {||  PadC( aktivan, 7 ) }, "aktivan" }, ;
      {      "Fiksan", {||  PadC( fiksan, 7 ) }, "fiksan" }, ;
      { PadR( "U fond s.", 10 ), {||  PadC( ufs, 10 ) }, "ufs" }, ;
      { PadR( "U neto", 6 ), {||  PadC( uneto, 6 ) }, "uneto" }, ;
      { PadR( "Formula", 200 ), {|| formula }, "formula"  }, ;
      { PadR( "Opis", 8 ), {|| opis }, "opis"  } ;
      }
   Kol := { 1, 2, 3, 4, 5, 6, 7, 8 }

   RETURN PostojiSifra( F_TIPPR2, 1, MAXROWS() -15, MAXCOLS() -20, Lokal( "Tipovi primanja za obracun 2" ),  @cId, dx, dy, ;
      {| Ch| Tpr2Bl( Ch ) },,,,, { "ID" } )



FUNCTION Tpr2Bl( Ch )

   RETURN DE_CONT



FUNCTION P_LD_RJ( cId, dx, dy )

   LOCAL lRet
   PRIVATE imekol := {}
   PRIVATE kol := {}

   PushWA()

   O_LD_RJ_NOT_USED

   AAdd( ImeKol, { PadR( "Id", 2 ),      {|| id }, "id", {|| .T. }, {|| vpsifra( wid ) } } )
   AAdd( ImeKol, { PadR( "Naziv", 35 ), {||  naz }, "naz" } )

   IF ld_rj->( FieldPos( "TIPRADA" ) ) <> 0
      AAdd( ImeKol, { "tip rada", {||  tiprada }, "tiprada", {|| .T. }, {|| wtiprada $ " #I#A#S#N#P#U#R#" .OR. MsgtipRada() }  } )
   ENDIF
   IF ld_rj->( FieldPos( "OPOR" ) ) <> 0
      AAdd( ImeKol, { "oporeziv", {||  opor }, "opor"  } )
   ENDIF

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   lRet := PostojiSifra( F_LD_RJ, 1, MAXROWS() -15, 60, Lokal( "Lista radnih jedinica" ), @cId, dx, dy )

   PopWa( F_LD_RJ )

   RETURN lRet



// vraca PU code opstine
FUNCTION g_ops_code( cId )

   LOCAL nTArea := Select()
   LOCAL cRet := ""

   O_OPS
   SELECT ops
   GO TOP
   SEEK cId
   IF Found()
      cRet := field->idj
   ENDIF

   SELECT ( nTArea )

   RETURN cRet



FUNCTION P_Kred( cId, dx, dy )

   PRIVATE imekol, kol

   ImeKol := { { PadR( "Id", 6 ), {|| id }, "id", {|| .T. }, {|| vpsifra( wid ) } }, ;
      { PadR( "Naziv", 30 ), {||  naz }, "naz" }, ;
      { PadR( "Adresa", 30 ), {||  adresa }, "adresa" }, ;
      { PadR( "Mjesto", 20 ), {||  mjesto }, "mjesto" }, ;
      { PadR( "PTT", 5 ), {||  ptt }, "ptt" }, ;
      { PadR( "Filijala", 30 ), {||  fil }, "fil" }, ;
      { PadR( "Racun", 20 ), {||  ziro }, "ziro" }, ;
      { PadR( "Partija", 20 ), {||  zirod }, "zirod" }                 ;
      }

   // Dorade 2001
   Kol := { 1, 2, 3, 4, 5, 6, 7, 8 }

   RETURN PostojiSifra( F_KRED, 1, MAXROWS() -15, MAXCOLS() -20, Lokal( "Lista kreditora" ), @cId, dx, dy )



FUNCTION KrBlok( Ch )

   IF ( Ch == K_CTRL_T )
      IF ImaURadKr( KRED->id, "3" )
         Beep( 1 )
         Msg( Lokal( "Firma se ne moze brisati jer je vec koristena u obracunu!" ) )
         RETURN 7
      ENDIF
   ELSEIF ( Ch == K_F2 )
      IF ImaURadKr( KRED->id, "3" )
         RETURN 99
      ENDIF
   ENDIF

   RETURN DE_CONT



FUNCTION ImaURadKr( cKljuc, cTag )

   LOCAL lVrati := .F.
   LOCAL lUsed := .T.
   LOCAL nArr := Select()

   SELECT ( F_RADKR )

   IF !Used()
      lUsed := .F.
      O_RADKR
   ELSE
      PushWA()
   ENDIF

   SET ORDER TO tag ( cTag )
   SEEK cKljuc

   lVrati := Found()

   IF !lUsed
      USE
   ELSE
      PopWA()
   ENDIF

   SELECT ( nArr )

   RETURN lVrati


FUNCTION ImaUObrac( cKljuc, cTag )

   LOCAL lVrati := .F.
   LOCAL lUsed := .T.
   LOCAL nArr := Select()

   SELECT ( F_LD )

   IF !Used()
      lUsed := .F.
      O_LD
   ELSE
      PushWA()
   ENDIF

   SET ORDER TO tag ( cTag )
   SEEK cKljuc

   lVrati := Found()

   IF !lUsed
      USE
   ELSE
      PopWA()
   ENDIF

   IF !lVrati  // ako nema u LD, provjerimo ima li u 1.dijelu obracuna (smece)
      SELECT ( F_LDSM )
      IF !Used()
         lUsed := .F.
         O_LDSM
      ELSE
         PushWA()
      ENDIF
      SET ORDER TO tag ( cTag )
      SEEK cKljuc
      lVrati := Found()
      IF !lUsed
         USE
      ELSE
         PopWA()
      ENDIF
   ENDIF
   SELECT ( nArr )

   RETURN lVrati



FUNCTION P_POR( cId, dx, dy )

   LOCAL i
   LOCAL _st_stopa := fetch_metric( "ld_porezi_stepenasta_stopa", NIL, "N" )
   PRIVATE Imekol := {}
   PRIVATE Kol := {}

   AAdd( ImeKol, { PadR( "Id", 2 ), {|| id }, "id", {|| .T. }, {|| vpsifra( wid ) } } )

   IF POR->( FieldPos( "ALGORITAM" ) ) <> 0 .AND. _st_stopa == "D"
      AAdd( ImeKol, { "Algor.", {|| algoritam }, "algoritam" } )
   ENDIF

   AAdd( ImeKol, { PadR( "Naziv", 20 ), {|| naz }, "naz" } )

   AAdd( ImeKol, { PadR( "Iznos", 20 ), {||  iznos }, "iznos", {|| IF( POR->( FieldPos( "ALGORITAM" ) ) <> 0, wh_oldpor( walgoritam ), .T. ) } } )

   AAdd( ImeKol, { PadR( "Donji limit", 12 ), {||  dlimit }, "dlimit" } )

   AAdd( ImeKol, { PadR( "PoOpst", 6 ), {||  poopst }, "poopst" } )

   AAdd( ImeKol, { "p.tip", {|| por_tip }, "por_tip" } )

   // nove stope i iznosi....
   IF POR->( FieldPos( "ALGORITAM" ) ) <> 0 .AND. _st_stopa == "D"

      AAdd( ImeKol, { "St.1", {|| s_sto_1 }, "s_sto_1", {|| wh_por( walgoritam ) } } )
      AAdd( ImeKol, { "Izn.1", {|| s_izn_1 }, "s_izn_1", {|| wh_por( walgoritam ) } } )
      AAdd( ImeKol, { "St.2", {|| s_sto_2 }, "s_sto_2", {|| wh_por( walgoritam ) } } )
      AAdd( ImeKol, { "Izn.2", {|| s_izn_2 }, "s_izn_2", {|| wh_por( walgoritam ) } } )
      AAdd( ImeKol, { "St.3", {|| s_sto_3 }, "s_sto_3", {|| wh_por( walgoritam ) } } )
      AAdd( ImeKol, { "Izn.3", {|| s_izn_3 }, "s_izn_3", {|| wh_por( walgoritam ) } } )
      AAdd( ImeKol, { "St.4", {|| s_sto_4 }, "s_sto_4", {|| wh_por( walgoritam ) } } )
      AAdd( ImeKol, { "Izn.4", {|| s_izn_4 }, "s_izn_4", {|| wh_por( walgoritam ) } } )
      AAdd( ImeKol, { "St.5", {|| s_sto_5 }, "s_sto_5", {|| wh_por( walgoritam ) } } )
      AAdd( ImeKol, { "Izn.5", {|| s_izn_5 }, "s_izn_5", {|| wh_por( walgoritam ) } } )

   ENDIF

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   PushWA()

   O_SIFK
   O_SIFV
   SELECT sifk
   SET ORDER TO TAG "ID"
   SEEK "POR"

   DO WHILE !Eof() .AND. ID = "POR"
      AAdd ( ImeKol, {  IzSifKNaz( "POR", SIFK->Oznaka ) } )
      AAdd ( ImeKol[ Len( ImeKol ) ], &( "{|| ToStr(IzSifk('POR','" + sifk->oznaka + "')) }" ) )
      AAdd ( ImeKol[ Len( ImeKol ) ], "SIFK->" + SIFK->Oznaka )

      IF ( sifk->edkolona > 0 )
         FOR ii := 4 TO 9
            AAdd( ImeKol[ Len( ImeKol ) ], NIL  )
         NEXT
         AAdd( ImeKol[ Len( ImeKol ) ], sifk->edkolona  )
      ELSE
         FOR ii := 4 TO 10
            AAdd( ImeKol[ Len( ImeKol ) ], NIL  )
         NEXT
      ENDIF

      // postavi picture za brojeve
      IF ( sifk->Tip = "N" )
         IF ( f_decimal > 0 )
            ImeKol[ Len( ImeKol ), 7 ] := Replicate( "9", sifk->duzina - sifk->f_decimal - 1 ) + "." + Replicate( "9", sifk->f_decimal )
         ELSE
            ImeKol[ Len( ImeKol ), 7 ] := Replicate( "9", sifk->duzina )
         ENDIF
      ENDIF

      AAdd( Kol, iif( sifk->UBrowsu = '1', ++i, 0 ) )
      SKIP
   ENDDO

   PopWa()

   RETURN PostojiSifra( F_POR, 1, MAXROWS() -15, MAXCOLS() -20, ;
      Lokal( "Lista poreza na platu.....<F5> arhiviranje poreza, <F6> pregled" ), ;
      @cId, dx, dy, {| Ch| PorBl( Ch ) } )



// -------------------------------
// when porez
// -------------------------------
FUNCTION wh_por( cAlg )

   LOCAL lRet := .F.

   IF cAlg == "S"
      lRet := .T.
   ENDIF

   RETURN lRet


// -------------------------------
// when stari porez
// -------------------------------
FUNCTION wh_oldpor( cAlg )

   LOCAL lRet := .F.

   IF Empty( cAlg ) .OR. cAlg <> "S"
      lRet := .T.
   ENDIF

   RETURN lRet



FUNCTION P_DOPR( cId, dx, dy )

   PRIVATE imekol := {}
   PRIVATE kol := {}

   AAdd( ImeKol, { PadR( "Id", 2 ), {|| id }, "id" } )
   AAdd( ImeKol, { PadR( "Naziv", 20 ), {||  naz }, "naz" } )
   AAdd( ImeKol, { PadR( "Iznos", 20 ), {||  iznos }, "iznos" } )
   AAdd( ImeKol, { PadR( "d.tip", 6 ), {||  dop_tip }, "dop_tip", {|| .T. }, {|| v_dop_tip( wdop_tip ) } }  )
   AAdd( ImeKol, { PadR( "tip rada", 10 ), {|| tiprada }, "tiprada", {|| .T. }, {|| wtiprada $ " #I#S#N#P#U#A#R" .OR. MsgTipRada() } }  )
   AAdd( ImeKol, { PadR( "KBenef", 5 ), {|| PadC( idkbenef, 5 ) }, "idkbenef", {|| .T. }, {|| Empty( widkbenef ) .OR. P_KBenef( @widkbenef ) } } )
   AAdd( ImeKol, { PadR( "Donji limit", 12 ), {||  dlimit }, "dlimit" } )
   AAdd( ImeKol, { PadR( "PoOpst", 6 ), {||  poopst }, "poopst" }  )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   PushWA()

   O_SIFK
   O_SIFV

   SELECT sifk
   SET ORDER TO TAG "ID"
   SEEK "DOPR"

   DO WHILE !Eof() .AND. ID = "DOPR"
      AAdd( ImeKol, { IzSifKNaz( "DOPR", SIFK->Oznaka ) } )
      AAdd( ImeKol[ Len( ImeKol ) ], &( "{|| ToStr(IzSifk('DOPR','" + sifk->oznaka + "')) }" ) )
      AAdd( ImeKol[ Len( ImeKol ) ], "SIFK->" + SIFK->Oznaka )
      IF ( sifk->edkolona > 0 )
         FOR ii := 4 TO 9
            AAdd( ImeKol[ Len( ImeKol ) ], NIL  )
         NEXT
         AAdd( ImeKol[ Len( ImeKol ) ], sifk->edkolona  )
      ELSE
         FOR ii := 4 TO 10
            AAdd( ImeKol[ Len( ImeKol ) ], NIL  )
         NEXT
      ENDIF
      // postavi picture za brojeve
      IF ( sifk->tip = "N" )
         IF ( f_decimal > 0 )
            ImeKol[ Len( ImeKol ), 7 ] := Replicate( "9", sifk->duzina - sifk->f_decimal - 1 ) + "." + Replicate( "9", sifk->f_decimal )
         ELSE
            ImeKol[ Len( ImeKol ), 7 ] := Replicate( "9", sifk->duzina )
         ENDIF
      ENDIF
      AAdd  ( Kol, iif( sifk->UBrowsu = '1', ++i, 0 ) )
      SKIP
   ENDDO

   PopWa()

   SELECT dopr

   RETURN PostojiSifra( F_DOPR, 1, MAXROWS() -15, MAXCOLS() -20, ;
      Lokal( "Lista doprinosa na platu......<F5> arhiviranje doprinosa, <F6> pregled" ), ;
      @cId, dx, dy, {| Ch| DoprBl( Ch ) } )



FUNCTION P_KBenef( cId, dx, dy )

   PRIVATE imekol
   PRIVATE kol

   ImeKol := { { PadR( "Id", 3 ), {|| PadC( id, 3 ) }, "id", {|| .T. }, {|| vpsifra( wid ) } }, ;
      { PadR( "Naziv", 8 ), {||  naz }, "naz" }, ;
      { PadR( "Iznos", 5 ), {||  iznos }, "iznos" }                       ;
      }

   Kol := { 1, 2, 3 }

   RETURN PostojiSifra( F_KBENEF, 1, MAXROWS() -15, MAXCOLS() -20, ;
      Lokal( "Lista koef.beneficiranog radnog staza" ), ;
      @cId, dx, dy )




FUNCTION P_StrSpr( cId, dx, dy )

   PRIVATE imekol, kol

   ImeKol := { { PadR( "Id", 3 ), {|| id }, "id", {|| .T. }, {|| vpsifra( wid ) } }, ;
      { PadR( "Naziv", 20 ), {||  naz }, "naz" }, ;
      { PadR( "naz2", 6 ), {|| naz2 }, "naz2" }                     ;
      }
   Kol := { 1, 2, 3 }

   RETURN PostojiSifra( F_STRSPR, 1, MAXROWS() -15, MAXCOLS() -15, ;
      Lokal( "Lista: strucne spreme" ), ;
      @cId, dx, dy )




FUNCTION P_VPosla( cId, dx, dy )

   PRIVATE imekol
   PRIVATE kol

   ImeKol := { { PadR( "Id", 2 ), {|| id }, "id", {|| .T. }, {|| vpsifra( wid ) } }, ;
      { PadR( "Naziv", 20 ), {||  naz }, "naz" }, ;
      { PadR( "KBenef", 5 ), {|| PadC( idkbenef, 5 ) }, "idkbenef", {|| .T. }, {|| P_KBenef( @widkbenef ) }  }  ;
      }
   Kol := { 1, 2, 3 }

   RETURN PostojiSifra( F_VPOSLA, 1, 10, 55, Lokal( "Lista: Vrste posla" ), @cId, dx, dy )


FUNCTION P_NorSiht( cId, dx, dy )

   PRIVATE imekol
   PRIVATE kol

   ImeKol := { { PadR( "Id", 4 ), {|| id }, "id", {|| .T. }, {|| vpsifra( wid ) } }, ;
      { PadR( "Naziv", 20 ), {||  naz }, "naz" }, ;
      { PadR( "JMJ", 3 ), {|| PadC( jmj, 3 ) }, "jmj"  }, ;
      { PadR( "Iznos", 8 ), {|| Iznos }, "Iznos"  }  ;
      }
   Kol := { 1, 2, 3, 4 }

   RETURN PostojiSifra( F_NORSIHT, 1, MAXROWS() -15, MAXCOLS() -20, "Lista: Norme u sihtarici", @cId, dx, dy )




FUNCTION TotBrisRadn()

   LOCAL cSigurno := "N"
   LOCAL nRec
   PRIVATE cIdRadn := Space( 6 )

   IF !spec_funkcije_sifra( "SIGMATB " )
      RETURN
   ENDIF

   O_RADN         // id, "1"
   O_RADKR        // idradn, "2"
   O_LD           // idradn, "RADN"
   O_LDSM         // idradn, "RADN"

   Box(, 7, 75 )
   @ m_x + 0, m_y + 5 SAY Lokal( "TOTALNO BRISANJE RADNIKA IZ EVIDENCIJE" )
   @ m_x + 8, m_y + 20 SAY Lokal( "<F5> - trazenje radnika pomocu sifrarnika" )
   SET KEY K_F5 TO TRUSif()
   DO WHILE .T.
      BoxCLS()
      IF cSigurno == "D"
         cIdRadn := Space( 6 )
         cSigurno := "N"
      ENDIF

      @ m_x + 2, m_y + 2 SAY Lokal( "Radnik" ) GET cIdRadn PICT "@!"
      @ m_x + 6, m_y + 2 SAY "Sigurno ga zelite obrisati (D/N) ?" GET cSigurno WHEN PrTotBR( cIdRadn ) VALID cSigurno $ "DN" PICT "@!"

      READ

      IF ( LastKey() == K_ESC )
         EXIT
      ENDIF

      IF cSigurno != "D"
         LOOP
      ENDIF

sql_table_update( nil, "BEGIN" )
      f18_lock_tables( { "ld_ld", "ld_radn", "ld_radkr" }, .T. )

      // brisem ga iz sifarnika radnika
      // -------------------------------
      SELECT radn
      SET ORDER TO TAG "1"
      GO TOP
      SEEK cIdRadn
      DO WHILE !Eof() .AND. id == cIdRadn
         SKIP 1
         nRec := RecNo()
         SKIP -1
         _rec := dbf_get_rec()
         delete_rec_server_and_dbf( "ld_radn", _rec, 1, "CONT" )
         GO ( nRec )
      ENDDO

      // brisem ga iz baze kredita
      // -------------------------
      SELECT radkr
      SET ORDER TO TAG "2"
      GO TOP
      SEEK cIdRadn
      DO WHILE !Eof() .AND. idradn == cIdRadn
         SKIP 1
         nRec := RecNo()
         SKIP -1
         _rec := dbf_get_rec()
         delete_rec_server_and_dbf( "ld_radkr", _rec, 1, "CONT" )
         GO ( nRec )
      ENDDO

      // brisem ga iz baze obracuna
      // --------------------------
      SELECT ld
      SET ORDER TO TAG "RADN"
      GO TOP
      SEEK cIdRadn
      DO WHILE !Eof() .AND. idradn == cIdRadn
         SKIP 1
         nRec := RecNo()
         SKIP -1
         _rec := dbf_get_rec()
         delete_rec_server_and_dbf( "ld_ld", _rec, 1, "CONT" )
         GO ( nRec )
      ENDDO

   ENDDO

   sql_table_update( nil, "END" )
   f18_free_tables( { "ld_ld", "ld_radn", "ld_radkr" } )

   SET KEY K_F5 TO

   BoxC()

   my_close_all_dbf()

   RETURN .T.


FUNCTION PrTotBr( cIdRadn )

   LOCAL cBI := "W+/G"

   SELECT ( F_RADN )
   SET ORDER TO TAG "1"
   GO TOP
   SEEK cIdRadn

   SELECT ( F_RADKR )
   SET ORDER TO TAG "2"
   GO TOP
   SEEK cIdRadn

   cKljuc := Str( godina, 4 ) + Str( mjesec, 2 )

   DO WHILE !Eof() .AND. idradn == cIdRadn
      IF ( cKljuc < Str( godina, 4 ) + Str( mjesec, 2 ) )
         cKljuc := Str( godina, 4 ) + Str( mjesec, 2 )
      ENDIF
      SKIP 1
   ENDDO
   SKIP -1

   SELECT ( F_LD )
   SET ORDER TO TAG "RADN"
   GO TOP
   SEEK cIdRadn

   cKljuc := Str( godina, 4 ) + Str( mjesec, 2 )

   DO WHILE !Eof() .AND. idradn == cIdRadn
      IF cKljuc < Str( godina, 4 ) + Str( mjesec, 2 )
         cKljuc := Str( godina, 4 ) + Str( mjesec, 2 )
      ENDIF
      SKIP 1
   ENDDO
   SKIP -1

   SELECT ( F_LDSM )
   SET ORDER TO TAG "RADN"
   GO TOP
   SEEK cIdRadn
   cKljuc := Str( godina, 4 ) + Str( mjesec, 2 )
   DO WHILE !Eof() .AND. idradn == cIdRadn
      IF cKljuc < Str( godina, 4 ) + Str( mjesec, 2 )
         cKljuc := Str( godina, 4 ) + Str( mjesec, 2 )
      ENDIF
      SKIP 1
   ENDDO
   SKIP -1

   @ m_x + 3, m_y + 1 CLEAR TO m_x + 5, m_y + 75
   @ m_x + 3, m_y + 2 SAY "PREZIME I IME:"
   @ m_x + 3, m_y + 17 SAY IF( RADN->id == cIdRadn, RADN->( Trim( naz ) + " (" + Trim( imerod ) + ") " + Trim( ime ) ), "nema podatka" ) COLOR cBI
   @ m_x + 4, m_y + 2 SAY "POSLJEDNJI OBRACUN:"
   @ m_x + 4, m_y + 22 SAY IF( LD->idradn == cIdRadn, Str( LD->mjesec, 2 ) + "/" + Str( LD->godina, 4 ), "nema podatka" ) COLOR cBI
   @ m_x + 4, m_y + 35 SAY "RJ:"
   @ m_x + 4, m_y + 39 SAY IF( LD->idradn == cIdRadn, LD->idrj, "nema podatka" ) COLOR cBI
   @ m_x + 5, m_y + 2 SAY "POSLJEDNJA RATA KREDITA:"
   @ m_x + 5, m_y + 27 SAY IF( RADKR->idradn == cIdRadn, Str( RADKR->mjesec, 2 ) + "/" + Str( RADKR->godina, 4 ), "nema podatka" ) COLOR cBI

   RETURN IF( RADN->id == cIdRadn .OR. LD->idradn == cIdRadn .OR. ;
      LDSM->idradn == cIdRadn .OR. RADKR->idradn == cIdRadn, .T., .F. )




FUNCTION TRUSif()

   IF ReadVar() == "CIDRADN"
      P_Radn( @cIdRadn )
      KEYBOARD Chr( K_ENTER ) + Chr( K_UP )
   ENDIF

   RETURN



FUNCTION PorBl( Ch )

   LOCAL nVrati := DE_CONT
   LOCAL nRec := RecNo()
   PRIVATE GetList := {}

   DO CASE
   CASE Ch == K_F5
      // pitati za posljednji mjesec
      cMj := gMjesec
      cGod := gGodina
      Box( "#PROMJENA POREZA U TOKU GODINE", 4, 60 )
      @ m_x + 2, m_y + 2 SAY "Posljednji mjesec po starim porezima:" GET cMj VALID cMj > 0 .AND. cMj < 13
      @ m_x + 3, m_y + 2 SAY "Godina: " + Str( cGod )
      READ
      IF LastKey() == K_ESC
         BoxC()
         RETURN nVrati
      ENDIF
      BoxC()

      // formiraj imena direktorija
      cPodDir := PadL( AllTrim( Str( cMj ) ), 2, "0" ) + Str( cGod, 4 )
      cPath := SIFPATH
      aIme := { "POR.DBF", "POR.CDX" }
      // zatvaram POR.DBF
      SELECT POR
      USE
      // napraviti direktorij i iskopirati POR.* u njega
      DirMake( cPath + cPodDir )
      lKopirano := .F.
      FOR i := 1 TO Len( aIme )
         IF File( cPath + cPodDir + SLASH + aIme[ i ] )
            MsgBeep( "Fajl " + aIme[ i ] + " vec postoji u " + cpath + cPodDir + " !" + "#Ukoliko ga sada zamijenite necete ga moci vratiti!" )
            IF Pitanje(, "Zelite li ga zamijeniti?", "N" ) == "N"
               LOOP
            ENDIF
         ENDIF
         lKopirano := .T.
         FileCopy( cPath + aIme[ i ], cPath + cPodDir + SLASH + aIme[ i ] )
      NEXT
      // otvaram POR.DBF
      O_POR
      GO ( nRec )

      // poruka: mozete definisati nove poreze
      IF lKopirano
         MsgBeep( "Stari porezi su smjesteni u podrucje " + cPodDir + "#Nakon ovoga mozete definisati nove poreze." )
      ENDIF

   CASE Ch == K_F6
      // meni sezona
      cPath := SIFPATH
      cGodina := gGodina
      Box(, 3, 30 )
      @ m_x + 2, m_y + 2 SAY "Godina:" GET cGodina PICT "9999"
      READ
      BoxC()
      IF LastKey() == K_ESC
         RETURN nVrati
      ENDIF
      cGodina := Str( cGodina, 4, 0 )
      aSez := ASezona2( cPath, cGodina, "POR.DBF" )
      IF Empty( aSez )
         MsgBeep( "Ne postoje sezone promjena poreza u " + cGodina + ". godini!" )
         RETURN nVrati
      ELSE
         // meni sezona - aSez
         // ------------------
         FOR i := 1 TO Len( aSez )
            aSez[ i ] := PadR( aSez[ i, 1 ] + " - " + ld_naziv_mjeseca( Val( Left( aSez[ i, 1 ], 2 ) ) ), 73 )
         NEXT
         h := Array( Len( aSez ) ); AFill( h, "" )
         Box( "#SEZONE PRED PROMJENU POREZA U " + cGodina + ".GODINI: ÍÍÍÍÍ <Enter>-izbor ", Min( Len( aSez ), 16 ) + 3, 77 )
         @ m_x + 1, m_y + 2 SAY PadC( "M J E S E C", 75 )
         @ m_x + 2, m_y + 2 SAY REPL( "Ä", 75 )
         nPom := 1
         @ Row() -1, Col() -6 SAY ""
         nPom := Menu( "SPME", aSez, nPom, .F.,,, { m_x + 2, m_y + 1 } )
         IF nPom > 0
            MENU( "SPME", aSez, 0, .F. )
         ENDIF
         BoxC()
         IF nPom > 0
            cPorDir := Left( aSez[ nPom ], 6 )
         ELSE
            RETURN nVrati
         ENDIF
      ENDIF

      // otvaranje sezonske baze
      SELECT ( F_POR )
      USE
      USE ( cPath + cPorDir + SLASH + "POR" )
      SET ORDER TO TAG "ID"
      GO TOP
      @ m_x + 11, m_y + 2 SAY "Porezi koji su vazili zakljucno sa (MMGGGG):" + cPorDir
      KEYBOARD Chr( K_CTRL_PGUP )
      nVrati := DE_REFRESH

   ENDCASE

   RETURN nVrati



// ------------------------------------
// ------------------------------------
FUNCTION DoprBl( Ch )

   LOCAL nVrati := DE_CONT
   LOCAL nRec := RecNo()

   DO CASE
   CASE Ch == K_F5

      // pitati za posljednji mjesec
      // ---------------------------
      cMj  := gMjesec
      cGod := gGodina
      PRIVATE GetList := {}
      Box( Lokal( "#PROMJENA DOPRINOSA U TOKU GODINE" ), 4, 60 )
      @ m_x + 2, m_y + 2 SAY Lokal( "Posljednji mjesec po starim doprinosima:" ) GET cMj VALID cMj > 0 .AND. cMj < 13
      @ m_x + 3, m_y + 2 SAY "Godina: " + Str( cGod )
      READ
      IF LastKey() == K_ESC; BoxC(); RETURN nVrati; ENDIF
      BoxC()

      // formiraj imena direktorija
      // --------------------------
      cPodDir := PadL( AllTrim( Str( cMj ) ), 2, "0" ) + Str( cGod, 4 )
      cPath := SIFPATH
      aIme := { "DOPR.DBF", "DOPR.CDX" }

      // zatvaram DOPR.DBF
      // -----------------
      SELECT DOPR
      USE

      // napraviti direktorij i iskopirati DOPR.* u njega
      // -------------------------------------------------
      DirMake( cPath + cPodDir )
      lKopirano := .F.
      FOR i := 1 TO Len( aIme )
         IF File( cpath + cPodDir + "\" + aIme[ i ] )
            MsgBeep( "Fajl " + aIme[ i ] + " vec postoji u " + cpath + cPodDir + " !" + ;
               "#Ukoliko ga sada zamijenite necete ga moci vratiti!" )
            IF Pitanje(, "Zelite li ga zamijeniti?", "N" ) == "N"
               LOOP
            ENDIF
         ENDIF
         lKopirano := .T.
         FileCopy( cPath + aIme[ i ], cpath + cPodDir + "\" + aIme[ i ] )
      NEXT

      // otvaram DOPR.DBF
      // ----------------
      O_DOPR
      GO ( nRec )

      // poruka: mozete definisati nove doprinose
      // ----------------------------------------
      IF lKopirano
         MsgBeep( "Stari doprinosi su smjesteni u podrucje " + cPodDir + "#Nakon ovoga " + ;
            "mozete definisati nove doprinose." )
      ENDIF

   CASE Ch == K_F6
      // meni sezona
      cPath   := SIFPATH
      cGodina := gGodina
      PRIVATE GetList := {}
      Box(, 3, 30 )
      @ m_x + 2, m_y + 2 SAY "Godina:" GET cGodina PICT "9999"
      READ
      BoxC()
      IF LastKey() == K_ESC; RETURN nVrati; ENDIF
      cGodina := Str( cGodina, 4, 0 )
      aSez := ASezona2( cPath, cGodina, "DOPR.DBF" )
      IF Empty( aSez )
         MsgBeep( "Ne postoje sezone promjena doprinosa u " + cGodina + ". godini!" )
         RETURN nVrati
      ELSE
         // meni sezona - aSez
         // ------------------
         FOR i := 1 TO Len( aSez )
            aSez[ i ] := PadR( aSez[ i, 1 ] + " - " + ld_naziv_mjeseca( Val( Left( aSez[ i, 1 ], 2 ) ) ), 73 )
         NEXT
         h := Array( Len( aSez ) ); AFill( h, "" )
         Box( "#SEZONE PRED PROMJENU DOPRINOSA U " + cGodina + ".GODINI: ||||| <Enter>-izbor ", Min( Len( aSez ), 16 ) + 3, 77 )
         @ m_x + 1, m_y + 2 SAY PadC( "M J E S E C", 75 )
         @ m_x + 2, m_y + 2 SAY REPL( "-", 75 )
         nPom := 1
         @ Row() -1, Col() -6 SAY ""
         nPom := Menu( "SDME", aSez, nPom, .F.,,, { m_x + 2, m_y + 1 } )
         IF nPom > 0
            MENU( "SDME", aSez, 0, .F. )
         ENDIF
         BoxC()
         IF nPom > 0
            cDoprDir := Left( aSez[ nPom ], 6 )
         ELSE
            RETURN nVrati
         ENDIF
      ENDIF

      // otvaranje sezonske baze
      SELECT ( F_DOPR ); USE
      USE ( cPath + cDoprDir + "\DOPR" ) ; SET ORDER TO TAG "ID"
      GO TOP
      @ m_x + 11, m_y + 2 SAY "Doprinosi koji su vazili zakljucno sa (MMGGGG):" + cDoprDir
      KEYBOARD Chr( K_CTRL_PGUP )
      nVrati := DE_REFRESH

   ENDCASE

   RETURN nVrati
