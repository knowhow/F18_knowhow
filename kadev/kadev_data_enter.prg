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


#include "kadev.ch"
#include "f18_separator.ch"


// ----------------------------------------------
// unos podataka
// ----------------------------------------------
FUNCTION kadev_data()

   LOCAL _i, _header, _footer
   LOCAL _x, _y
   LOCAL _w1 := 30
   PRIVATE ImeKol := {}
   PRIVATE Kol := {}
   PRIVATE fNovi

   _x := MAXROWS() - 4
   _y := MAXCOLS() - 3

   SET EPOCH TO 1910

   // otvori tabele
   kadev_o_tables()

   // setuj kolone pregleda
   set_kols( @ImeKol, @Kol )

   SELECT kadev_0
   SET ORDER TO TAG "2"
   GO TOP

   _header := ""
   _footer := ""

   cTrPrezime := kadev_0->prezime
   cTrIme     := kadev_0->ime
   cTrID      := kadev_0->id

   Box(, _x, _y )

   @ m_x + _x - 4, m_y + 2 SAY PadR( " < c+N > Novi", _w1 ) + ;
      BROWSE_COL_SEP + PadR( " < T > Trazi (pr+ime)", _w1 )
   @ m_x + _x - 3, m_y + 2 SAY PadR( " < ENT > Ispravka", _w1 ) + ;
      BROWSE_COL_SEP + PadR( " < S > Trazi (id)", _w1 )
   @ m_x + _x - 2, m_y + 2 SAY PadR( " < R > Rjesenje", _w1 ) + ;
      BROWSE_COL_SEP + PadR( " < c + T > brisanje ", _w1 )
   @ m_x + _x - 1, m_y + 2 SAY PadR( " < P > Pregl.promjene", _w1 ) + ;
      BROWSE_COL_SEP + PadR( " < I > info staz ", _w1 )

   my_db_edit( 'bpod', _x - 3, _y, {|| data_handler() }, _header, _footer, , , , , 2 )

   BoxC()

   my_close_all_dbf()

   RETURN


// -----------------------------------------------------------
// setovanje kolone za tabelu pregleda
// -----------------------------------------------------------
STATIC FUNCTION set_kols( _imekol, _kol )

   LOCAL _i

   AAdd( _imekol, { 'Prezime', {|| Prezime } } )
   AAdd( _imekol, { 'Ime oca', {|| ImeRod } } )
   AAdd( _imekol, { 'Ime', {|| Ime } } )
   AAdd( _imekol, { 'RJ', {|| IdRJ } } )
   AAdd( _imekol, { 'RMJ', {|| IdRMJ } } )
   AAdd( _imekol, { 'ID-Mat.br', {|| Id } } )
   AAdd( _imekol, { 'Status', {|| status } } )
   AAdd( _imekol, { 'StrSpr', {|| idstrspr } } )
   AAdd( _imekol, { 'RRASP', {|| idrrasp } } )

   FOR _i := 1 TO Len( _imekol )
      AAdd( _kol, _i )
   NEXT

   RETURN



// -------------------------------------------------------------
// ispisuje informacije po parametrima zadatim
// -------------------------------------------------------------
STATIC FUNCTION kadev_radnik_info_by_params( jmbg )

   LOCAL _params := hb_Hash()
   LOCAL _status, _radni_staz
   LOCAL _datum_od := CToD( "" )
   LOCAL _datum_do := Date()
   LOCAL oDATA
   LOCAL _ok := .T.
   PRIVATE GetList := {}

   Box(, 1, 60 )
   @ m_x + 1, m_y + 2 SAY "Za datum od:" GET _datum_od
   @ m_x + 1, Col() + 1 SAY "do:" GET _datum_do
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   _params[ "jmbg" ] := jmbg
   _params[ "datum_od" ] := _datum_od
   _params[ "datum_do" ] := _datum_do

   oDATA := KADEV_DATA_CALC():new()
   oDATA:params := _params

   // izvuci podatke
   oDATA:data_selection()

   // vrati mi podatke statusa
   oDATA:get_status()
   // vrati mi podatke o stazu
   oDATA:get_radni_staz()

   _status := oDATA:status
   _staz := oDATA:radni_staz

   IF _status == NIL
      MsgBeep( "Nemamo statusa za ovog radnika !" )
      RETURN _ok
   ENDIF

   Box(, 12, 70 )

   @ m_x + 1, m_y + 2 SAY "Radnik: " + jmbg COLOR F18_COLOR_I
   @ m_x + 3, m_y + 2 SAY "Podaci od " + DToC( _datum_od ) + " do " + DToC( _datum_do )
   @ m_x + 5, m_y + 2 SAY "STATUS = [" + _status[ "status" ] + "]" COLOR F18_COLOR_I
   @ m_x + 7, m_y + 2 SAY "Podaci radnog staza:" COLOR F18_COLOR_I
   @ m_x + 8, m_y + 2 SAY Replicate( "-", 60 )
   @ m_x + 9, m_y + 2 SAY  "(1)    efektivni:" + _staz[ "rst_ef_info" ]
   @ m_x + 10, m_y + 2 SAY "(2) beneficirani:" + _staz[ "rst_ben_info" ]
   @ m_x + 11, m_y + 2 SAY "(3)       ukupno:" + _staz[ "rst_uk_info" ]

   WHILE Inkey( 0.1 ) != K_ESC
   END

   BoxC()

   RETURN _ok



// ispisuje status radnika na dnu
STATIC FUNCTION kadev_status_radnika( jmbg )

   LOCAL _params := hb_Hash()
   LOCAL _status, _radni_staz
   LOCAL oDATA
   LOCAL _pos_x := MAXROWS() - 8
   LOCAL _pos_y := ( MAXCOLS() / 3 ) * 2

   _params[ "jmbg" ] := jmbg
   _params[ "datum_od" ] := CToD( "" )
   _params[ "datum_do" ] := Date()

   oDATA := KADEV_DATA_CALC():new()
   oDATA:params := _params

   // izvuci podatke
   oDATA:data_selection()

   // vrati mi podatke statusa
   oDATA:get_status()

   // vrati mi podatke o stazu
   oDATA:get_radni_staz()

   _status := oDATA:status
   _staz := oDATA:radni_staz

   IF _status == NIL
      RETURN
   ENDIF

   @ m_x + _pos_x, m_y + _pos_y SAY "STATUS: [" + _status[ "status" ] + "] / Radni staz:" COLOR F18_COLOR_I
   @ m_x + _pos_x + 1, m_y + _pos_y SAY "(1)  efekt.: " + _staz[ "rst_ef_info" ]
   @ m_x + _pos_x + 2, m_y + _pos_y SAY "(2)  benef.: " + _staz[ "rst_ben_info" ]
   @ m_x + _pos_x + 3, m_y + _pos_y SAY "(3) ef/ben.: " + _staz[ "rst_uk_info" ]

   RETURN




// ---------------------------------------------
// key handler
// ---------------------------------------------
STATIC FUNCTION data_handler()

   LOCAL _order := 0
   LOCAL _vars := {}
   LOCAL _tmp := {}
   LOCAL _strana := 0
   LOCAL _tek_strana := 1
   LOCAL oDATA
   LOCAL _tmp_2 := {}
   PRIVATE fNovi := .F.

   // broj podataka
   @ m_x + 1, m_y + 2 SAY "Broj promjena:" COLOR "GR+/B"
   @ m_x + 1, Col() + 2 SAY PadL( AllTrim( Str( kadev_broj_podataka( field->id ), 5, 0 ) ), 8 ) COLOR "W/R+"

   // ispisi status radnika
   kadev_status_radnika( field->id )

   DO CASE

   CASE Ch == K_CTRL_N .OR. Ch == K_ENTER

      IF ( Deleted() .OR. Eof() .OR. Bof() ) .AND. Ch == K_ENTER
         RETURN DE_CONT
      ENDIF

      IF Ch == K_CTRL_N
         fNovi := .T.
      ENDIF

      IF fNovi
         APPEND BLANK
      ENDIF

      // scatter
      set_global_vars_from_dbf()

      IF ent_K_0()
         _rec := get_dbf_global_memvars()
         update_rec_server_and_dbf( "kadev_0", _rec, 1, "FULL" )

         // if Ch == K_CTRL_N
         oDATA := KADEV_DATA_CALC():new()
         oDATA:params := hb_Hash()
         oDATA:params[ "datum_od" ] := CToD( "" )
         oDATA:params[ "datum_do" ] := Date()
         oDATA:params[ "jmbg" ] := field->id
         oDATA:update_status()
         // endif

         fNovi := .F.
         RETURN DE_REFRESH
      ELSE
         IF fNovi
            brisi_kadrovski_karton( .T. )
         endif
         fnovi := .F.
         RETURN DE_REFRESH
      ENDIF

   CASE Ch == K_CTRL_T

      IF !( Deleted() .OR. Eof() .OR. Bof() )
         brisi_kadrovski_karton()
         RETURN DE_REFRESH
      ENDIF

   CASE CH == Asc( "I" ) .OR. CH == Asc( "i" )

      kadev_radnik_info_by_params( field->id )
      RETURN DE_CONT

   CASE Ch == Asc( "T" ) .OR. Ch == Asc( "t" )

      IF VarEdit( { { "Prezime", "cTrPrezime", "", "", "" }, ;
            { "Ime", "cTrIme", "", "", "" } }, ;
            11, 1, 16, 78, "TRAZENJE RADNIKA", "B1" )

         DO WHILE TB:rowPos > 1
            TB:up()
            DO WHILE !TB:stable
               Tb:stabilize()
            ENDDO
         ENDDO
         _order := IndexOrd()
         SET ORDER TO TAG "2"
         SEEK BToE( cTrPrezime + cTrIme )
         dbSetOrder( _order )
         RETURN DE_REFRESH
      ENDIF

   CASE Ch == Asc( "S" ) .OR. Ch == Asc( "s" )

      IF VarEdit( { { "ID", "cTrID", "", "", "" } }, ;
            11, 1, 15, 78, "TRAZENJE RADNIKA", "B1" )
         DO WHILE TB:rowPos > 1
            TB:up()
            DO WHILE !TB:stable
               Tb:stabilize()
            ENDDO
         ENDDO
         _order := IndexOrd()
         SET ORDER TO TAG "1"
         SEEK cTrID
         dbSetOrder( _order )
         RETURN DE_REFRESH
      ENDIF

   CASE Ch == Asc( "P" ) .OR. Ch == Asc( "p" )

      _t_area := Select()

      Box( "uk0_1", MAXROWS() - 12, MAXCOLS() - 5, .F. )

      @ m_x + ( MAXROWS() - 13 ), m_y + 2 SAY "RADNIK: " + AllTrim( kadev_0->prezime ) + " " + ;
         AllTrim( kadev_0->ime ) + ", ID: " + ;
         AllTrim( kadev_0->id )

      SET CURSOR ON

      set_global_vars_from_dbf()

      // daj mi promjene...
      get_4( NIL, .F. )

      _rec := get_dbf_global_memvars()
      update_rec_server_and_dbf( "kadev_0", _rec, 1, "FULL" )

      BoxC()

      SELECT ( _t_area )

   CASE Ch == Asc( "R" ) .OR. Ch == Asc( "r" )

      // rjesenje...
      IF !rjesenje_za_radnika()
         RETURN DE_CONT
      ELSE
         RETURN DE_REFRESH
      ENDIF

   ENDCASE

   RETURN DE_CONT



// -------------------------------------------------------
// rjesenje za radnika...
// -------------------------------------------------------
STATIC FUNCTION rjesenje_za_radnika()

   LOCAL _t_area
   LOCAL _ret := .F.
   LOCAL _niz_0, _niz, _tmp, _izbaceni, _strana, _tek_strana, _i, _n, _y
   LOCAL _postoji

   PRIVATE cTempVar := ""
   PRIVATE cTempIzraz := ""
   PRIVATE nGetP0 := 0
   PRIVATE nGetP1 := 0

   _t_area := Select()

   // otvori rjesenja...
   P_Rjes()

   IF LastKey() == K_ESC
      SELECT ( _t_area )
      RETURN _ret
   ENDIF

   _niz_0 := {}
   _niz := {}
   _tmp := {}
   _strana := 0
   _tek_strana := 1

   SELECT kdv_defrjes
   SET ORDER TO TAG "3"
   SEEK kdv_rjes->id

   DO WHILE !Eof() .AND. field->idrjes == kdv_rjes->id

      IF Empty( field->id )
         SKIP 1
         LOOP
      ENDIF

      cTempVar := AllTrim( field->id )
      cTempIzraz := AllTrim( field->izraz )

      ID&cTempVar := &cTempIzraz

      IF field->priun == "0"
         AAdd( _niz_0, { RTrim( field->upit ), "ID" + cTempVar, RTrim( field->uvalid ), ;
            RTrim( field->upict ), IF( field->obrada == "D", ".t.", ".f." ) } )
         ++ nGetP0
      ELSE
         AAdd( _niz, { RTrim( field->upit ), "ID" + cTempVar, RTrim( field->uvalid ), ;
            RTrim( field->upict ), IF( field->obrada == "D", ".t.", ".f." ) } )
         ++ nGetP1
      ENDIF

      SKIP 1

   ENDDO

   SET ORDER TO TAG "1"

   // unos prioritetnih podataka
   IF nGetP0 > 0

      _strana := Int( nGetP0 / 20 ) + IF( nGetP0 % 20 > 0, 1, 0 )

      DO WHILE .T.

         _tmp := {}

         FOR _i := 1 TO 20
            IF _i + ( _tek_strana - 1 ) * 20 > Len( _niz_0 )
               EXIT
            ELSE
               AAdd( _tmp, _niz_0[ _i + ( _tek_strana - 1 ) * 20 ] )
            ENDIF
         NEXT

         VarEdit( _tmp, 1, 1, 4 + Len( _tmp ), 79, ;
            AllTrim( kdv_rjes->naz ) + "," + ;
            kadev_0->( Trim( prezime ) + " " + Trim( ime ) ) + ;
            ", STR." + AllTrim( Str( _tek_strana ) ) + "/" + AllTrim( Str( _strana ) ), "B1" )

         IF LastKey() == K_PGUP
            -- _tek_strana
         ELSE
            ++ _tek_strana
         ENDIF

         IF _tek_strana < 1
            _tek_strana := 1
         ENDIF

         IF _tek_strana > _strana
            EXIT
         ENDIF

      ENDDO

      IF LastKey() == K_ESC
         SELECT ( _t_area )
         RETURN _ret
      ENDIF

   ENDIF

   // ispitivanje unosa i eventualne modifikacije unosa preostalih podataka
   _postoji := 0

   IF kdv_rjes->idpromj == "G1"

      // godisnji odmor
      SELECT ( F_KADEV_1 )
      PushWA()
      SET ORDER TO TAG "3"
      SEEK kadev_0->id + "G1"

      PRIVATE nImaDana := 0
      PRIVATE nIskorDana := 0

      DO WHILE !Eof() .AND. field->id == kadev_0->id .AND. field->idpromj == "G1"
         IF field->natr1 == ID06
            // ID06 je sad za sad godina prava, kao i nAtr1
            IF field->natr2 > 0
               nImaDana := field->natr2
               IF FieldPos( "natr3" ) > 0
                  nGOKrit1 := nAtr3
                  nGOKrit2 := nAtr4
                  nGOKrit3 := nAtr5
                  nGOKrit4 := nAtr6
                  nGOKrit5 := nAtr7
                  nGOKrit6 := nAtr8
                  nGOKrit7 := nAtr9
               ENDIF
            ENDIF
            nIskorDana += ImaRDana( field->DatumOd, field->DatumDo )
            _postoji ++
         ENDIF

         SKIP 1

      ENDDO

      PRIVATE preostd := AllTrim( Str( nImaDana - nIskorDana ) )

      PopWA()

   ENDIF

   IF _postoji > 1
      MsgBeep( "Vec postoje " + Str( _postoji, 2 ) + " rjesenja!#Za istu godinu moguce je napraviti max.2 rjesenja!#Provjeriti promjene tipa G1!" )
      SELECT ( _t_area )
      RETURN _ret
   ELSEIF _postoji > 0
      MsgBeep( "Vec postoji jedno rjesenje koje definise pravo na godisnji odmor!#Mozete napraviti rjesenje samo za drugi dio godisnjeg odmora.#Ako zelite ponovo definisati pravo, provjerite promjene tipa G1!" )
   ENDIF

   IF _postoji > 0

      // izbacimo nezeljene stavke iz niza
      _izbaceni := { "ID07", "ID08", "ID09", "ID10", "ID11", "ID12", "ID13", "ID14", "ID15", "ID16", "ID17", "ID18" }

      FOR _n := 1 TO Len( _izbaceni )
         _tmp := _izbaceni[ _n ]
         // ispraznimo nezeljene
         &_tmp := Blank( &_tmp )
         // varijable
         _scan := AScan( _niz, {| x| x[ 2 ] == _izbaceni[ _n ] } )
         IF _scan > 0
            ADel( _niz, _scan )
            ASize( _niz, Len( _niz ) - 1 )
            nGetP1 --
         ENDIF
      NEXT

      PRIVATE samo2 := ".t."

      // kad vec znam da je ID20 br.dana za 2.dio god.odmora
      IF !( "U" $ Type( "nGOKrit1" ) )
         ID07 := Int( nGOKrit1 )
         ID08 := Int( nGOKrit2 )
         ID09 := Int( nGOKrit3 )
         ID10 := Int( nGOKrit4 )
         ID11 := Int( nGOKrit5 )
         ID12 := Int( nGOKrit6 )
         ID13 := Int( nGOKrit7 )
         ID14 := Int( nImaDana )
      ENDIF

      ID20 := Int( nImaDana - nIskorDana )

   ELSE
      PRIVATE samo2 := ".f."
   ENDIF

   // unos ostalih podataka
   IF nGetP1 > 0
      _strana := Int( nGetP1 / 20 ) + IF( nGetP1 % 20 > 0, 1, 0 )
      _tek_strana := 1
      DO WHILE .T.
         _tmp_3 := {}
         FOR _y := 1 TO 20
            IF _y + ( _tek_strana - 1 ) * 20 > Len( _niz )
               EXIT
            ELSE
               AAdd( _tmp_3, _niz[ _y + ( _tek_strana - 1 ) * 20 ] )
            ENDIF
         NEXT

         VarEdit( _tmp_3, 1, 1, 4 + Len( _tmp_3 ), 79, ;
            AllTrim( kdv_rjes->naz ) + "," + kadev_0->( Trim( prezime ) + " " + Trim( ime ) ) + ;
            ", STR." + AllTrim( Str( _tek_strana ) ) + "/" + AllTrim( Str( _strana ) ), "B1" )

         IF LastKey() == K_PGUP
            -- _tek_strana
         ELSE
            ++ _tek_strana
         ENDIF

         IF _tek_strana < 1
            _tek_strana := 1
         ENDIF

         IF _tek_strana > _strana
            EXIT
         ENDIF

      ENDDO

      IF LastKey() == K_ESC
         SELECT ( _t_area )
         RETURN _ret
      ENDIF

   ENDIF

   rpt_rjes()

   IF !Empty( kdv_rjes->idpromj ) .AND. ;
         Pitanje(, "¿elite li da se efekat ovog rjesenja evidentira u promjenama? (D/N)", "D" ) == "D"

      ERUP( _izbaceni )
   ENDIF

   SELECT ( _t_area )
   _ret := .T.

   RETURN _ret





// -----------------------------------------
// stampa rjesenja
// -----------------------------------------
FUNCTION rpt_rjes()

   LOCAL aPom := {}
   LOCAL i
   LOCAL nLin
   LOCAL nPocetak
   LOCAL nPreskociRedova
   LOCAL cLin
   LOCAL cPom

   START PRINT CRET

   IF Empty( kdv_rjes->fajl )
      FOR i := 1 TO gnTMarg
         QOut()
      NEXT
   ELSE

      nLin := BrLinFajla( my_home() + AllTrim( KDV_RJES->fajl ) )
      nPocetak := 0
      nPreskociRedova := 0

      FOR i := 1 TO nLin
         aPom := SljedLin( my_home() + AllTrim( KDV_RJES->fajl ), nPocetak )
         nPocetak := aPom[ 2 ]
         cLin := aPom[ 1 ]

         IF nPreskociRedova > 0
            --nPreskociRedova
            LOOP
         ENDIF

         IF i > 1
            ?
         ENDIF

         DO WHILE .T.
            nPom := At( "#", cLin )
            IF nPom > 0
               cPom := SubStr( cLin, nPom, 4 )
               aPom := UzmiVar( SubStr( cPom, 2, 2 ) )
               ?? Left( cLin, nPom - 1 )
               cLin := SubStr( cLin, nPom + 4 )

               IF !Empty( aPom[ 1 ] )
                  PrnKod_ON( aPom[ 1 ] )
               ENDIF

               IF aPom[ 1 ] == "K"
                  // ako evaluacija vrsi i stampu npr.
                  cPom := &( aPom[ 2 ] )
                  // ako je aPom[2]="gPU_ON()"
               ELSE
                  cPom := &( aPom[ 2 ] )
                  ?? cPom
               ENDIF

               IF !Empty( aPom[ 1 ] )
                  PrnKod_OFF( aPom[ 1 ] )
               ENDIF
            ELSE
               ?? cLin
               EXIT
            ENDIF
         ENDDO
      NEXT
   ENDIF

   FF
   ENDPRINT

   RETURN



FUNCTION UzmiVar( cVar )

   LOCAL cVrati := { "", "''" }

   SELECT KDV_DEFRJES
   SEEK KDV_RJES->id + cVar
   IF Found()
      cVrati := { tipslova, iizraz }
   ENDIF

   RETURN cVrati






STATIC FUNCTION erup( arr )

   LOCAL _t_area := Select()
   LOCAL _dok := ""
   LOCAL _rec, _ima_podataka, _t_id_promj
   PRIVATE cPP := ""
   PRIVATE cPR := ""

   SELECT kadev_1
   APPEND BLANK

   set_global_vars_from_dbf()

   _id := kadev_0->id
   _idpromj := kdv_rjes->idpromj

   SELECT kdv_defrjes
   SET ORDER TO TAG "2"
   SEEK kdv_rjes->id

   _t_id_promj := field->ipromj

   _ima_podataka := .F.

   DO WHILE !Eof() .AND. field->idrjes == kdv_rjes->id

      IF AScan( arr, {| x| Right( x, 2 ) == kdv_defrjes->id } ) > 0
         SKIP
         LOOP
      ENDIF

      IF field->ipromj <> _t_id_promj .AND. Len( arr ) == 0

         _t_id_promj := field->ipromj

         SELECT kadev_1

         // gather()
         _rec := get_dbf_global_memvars()
         update_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" )

         // scatter
         set_global_vars_from_dbf()

         IF !_ima_podataka
            _rec := dbf_get_rec()
            delete_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" )
         ENDIF

         _ima_podataka := .F.

         APPEND BLANK

         SELECT kdv_defrjes

      ENDIF

      IF !Empty( field->ppromj )

         cPP := AllTrim( field->ppromj )
         cPR := "ID" + AllTrim( field->id )
         _&cPP := &cPR

         IF !Empty( &cPR )
            _ima_podataka := .T.
            IF AllTrim( field->ppromj ) == "DOKUMENT"
               _dok := _dokument
            ENDIF
         ENDIF

      ENDIF

      SKIP 1

   ENDDO

   SET ORDER TO TAG "1"
   SELECT kadev_1

   _rec := get_dbf_global_memvars()
   update_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" )

   IF !_ima_podataka
      _rec := dbf_get_rec()
      delete_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" )
   ENDIF

   IF !Empty( _dok )
      SELECT kdv_rjes
      _rec := dbf_get_rec()
      _rec[ "zadbrdok" ] := _dok
      update_rec_server_and_dbf( "kadev_rjes", _rec, 1, "FULL" )
   ENDIF

   SELECT ( _t_area )

   RETURN



// ----------------------------------------------------------
// unos "kadev_0" podataka
// ----------------------------------------------------------
FUNCTION ent_K_0()

   LOCAL _max_x := MAXROWS() - 10
   LOCAL _max_y := MAXCOLS() - 5
   LOCAL _strana
   LOCAL _ret

   Box( "uk0_1", _max_x, _max_y, .F. )

   SET CURSOR ON

   _strana := 1

   DO WHILE .T.

      @ m_x + ( _max_x + 1 ), m_y + 2 SAY "RADNIK: " + ;
         Trim( kadev_0->prezime ) + " " + Trim( kadev_0->ime ) + ", ID: " + Trim( kadev_0->id )

      @ m_x + 1, m_y + 1 CLEAR TO m_x + _max_x, m_y + ( _max_y + 1 )

      IF _strana == 1
         _ret := GET_1( _strana )
      ELSEIF _strana == 2
         _ret := GET_2( _strana )
      ELSEIF _strana == 3
         _ret := GET_3( _strana )
      ELSEIF _strana == 4
         _ret := GET_4( _strana, NIL )
      ENDIF

      IF _ret == K_ESC
         EXIT
      ELSEIF _ret == K_PGUP
         -- _strana
      ELSEIF _ret == K_PGDN .OR. _ret == K_ENTER
         ++ _strana
      ENDIF

      IF _strana == 0
         _strana ++
      ELSEIF _strana == 5
         EXIT
      ENDIF

   ENDDO

   BoxC()

   IF LastKey() <> K_ESC
      RETURN .T.
   ELSE
      RETURN .F.
   ENDIF

   RETURN


// --------------------------------------
// unos prve stranice
// --------------------------------------
STATIC FUNCTION get_1( strana )

   LOCAL _left := 30

   @ m_x + 1, m_y + 2 SAY PadR( " 1. Prezime", _left ) GET _prezime PICT "@!"

   @ m_x + 3, m_y + 2 SAY PadR( " 2. Ime jednog roditelja", _left ) GET _imerod PICT "@!"

   @ m_x + 5, m_y + 2 SAY PadR( " 3. Ime", _left ) GET _ime PICT "@!"
   @ m_x + 5, Col() + 2 SAY " Pol (M/Z) " GET _pol VALID _pol $ "MZ" PICT "@!"

   @ m_x + 7, m_y + 2 SAY PadR( " 4. Nacija", _left ) GET _idnac ;
      VALID {|| P_Nac( @_idnac, 7, 40 ) } PICT "@!"

   @ m_x + 9, m_y + 2 SAY PadR( " 5. Jedinstveni mat.broj", _left ) GET _id ;
      VALID _dobar_id( @_id ) PICT "@!"
   @ m_x + 9, Col() + 2 SAY " b) ID broj/2  " GET _id2 VALID _dobar_id2( @_id2 ) PICT "@!"

   @ m_x + 11, m_y + 2 SAY PadR( " 7. Mjesto rodjenja", _left ) GET _mjrodj PICT "@!"

   @ m_x + 13, m_y + 2 SAY PadR( " 8. Datum. rodj ", _left ) GET _datrodj
   @ m_x + 13, Col() + 2 SAY "  9. Broj LK " GET _brlk PICT "@!"

   @ m_x + 15, m_y + 2 SAY " 10. Adresa stanovanja *****"
   @ m_x + 16, m_y + 2 SAY PadR( "  a) mjesto", _left ) GET _mjst PICT "@!"
   @ m_x + 17, m_y + 2 SAY PadR( "  b) mjesna zajednica", _left ) GET _idmzst ;
      VALID P_MZ( @_idmzst, 17, 40 ) PICT "@!"
   @ m_x + 18, m_y + 2 SAY PadR( "  c) ulica", _left ) GET _ulst PICT "@!"
   @ m_x + 19, m_y + 2 SAY PadR( "  d) broj kucnog telefona", _left ) GET _brtel1 PICT "@!"

   READ

   IF !_dobar_id( _id )
      -- strana
   ENDIF

   RETURN LastKey()




// --------------------------------------------
// unos druge stranice
// --------------------------------------------
STATIC FUNCTION get_2( strana )

   LOCAL aRstE
   LOCAL aRstB
   LOCAL aRstU
   LOCAL _left := 30

   @ m_x + 1, m_y + 2 SAY " 11. Strucna sprema " + _idstrspr + "-" + P_STRSPR( @_idstrspr, -2 )

   @ m_x + 3, m_y + 2 SAY " 12. Vrsta str.spr. " + _idzanim + "-" + P_Zanim( @_idzanim, -2 )

   @ m_x + 5, m_y + 2 SAY " 13. R.jedinica RJ " + _idrj + "-" + P_Kadev_Rj( _idrj, -2 )

   @ m_x + 7, m_y + 2 SAY " 14. R.mjesto RMJ " + _idrmj + "-" + P_RMJ( _idrmj, -2 )
   @ m_x + 8, m_y + 2 SAY "    Broj bodova   " + Str( Ocitaj( F_KDV_RJRMJ, _idrj + _idrmj, "BODOVA", .T. ), 7, 2 )
   @ m_x + 9, m_y + 2 SAY " 15. Na radnom mjestu od: " + DToC( _daturmj )
   @ m_x + 9, m_y + 40 SAY "U Firmi od: " + DToC( _datuf )

   @ m_x + 11, m_y + 2 SAY " 16. Van firme od: " + DToC( _datvrmj )

   aRstE := GMJD( _radste )
   aRstB := GMJD( _radstb )

   aRStU := ADDGMJD( aRStE, aRStB )

   @ m_x + 13, m_y + 2 SAY " 17. Radni staz:      Efekt  " + ;
      Str( aRstE[ 1 ], 2 ) + "g." + Str( aRstE[ 2 ], 2 ) + ;
      "m." + Str( aRstE[ 3 ], 2 ) + "d."

   @ m_x + 14, m_y + 2 SAY "                     Benef  " + ;
      Str( aRstB[ 1 ], 2 ) + "g." + Str( aRstB[ 2 ], 2 ) + "m." + Str( aRstB[ 3 ], 2 ) + "d."

   @ m_x + 15, m_y + 2 SAY "                         ä  " + ;
      Str( aRstU[ 1 ], 2 ) + "g." + Str( aRstU[ 2 ], 2 ) + "m." + Str( aRstU[ 3 ], 2 ) + "d."

   @ m_x + 16, m_y + 2 SAY PadR( " 18. Status ...............", _left ) + _status

   @ m_x + 18, m_y + 2 SAY PadR( " 19. broj telefona /2", _left ) GET _brtel2 PICT "@!"
   @ m_x + 19, m_y + 2 SAY PadR( " 20. broj telefona /3", _left ) GET _brtel3 PICT "@!"

   READ

   RETURN LastKey()




// --------------------------------------------
// unos treæe stranice
// --------------------------------------------
STATIC FUNCTION get_3( strana )

   LOCAL _left := 30

   aVr := GMJD( _vrslvr )

   @ m_x + 1, m_y + 2 SAY " 21.PORODICA, OPSTI PODACI"

   @ m_x + 3, m_y + 2 SAY PadR( "  a) Bracno stanje ", _left ) GET _bracst PICT "@!"
   @ m_x + 4, m_y + 2 SAY PadR( "  b) Broj djece ", _left ) GET _brdjece PICT "@!"
   @ m_x + 5, m_y + 2 SAY PadR( "  c) Stambene prilike ", _left ) GET _stan PICT "@!"
   @ m_x + 6, m_y + 2 SAY PadR( "  d) Krvna grupa ", _left ) GET _krv VALID _krv $ "   #A+ #A- #B+ #B- #AB+#AB-#0+ #0- #A  #B  #AB #0  "  PICT "@!"
   @ m_x + 7, m_y + 2 SAY PadR( "  e) " + gDodKar1, _left ) GET _idk1 ;
      VALID P_Kadev_K1( @_idk1, 7, 40 ) PICT "@!"
   @ m_x + 8, m_y + 2 SAY PadR( "  f) " + gDodKar2, _left ) GET _idk2 ;
      VALID P_Kadev_K2( @_idk2, 8, 40 ) PICT "@!"

   @ m_x + 9, m_y + 2 SAY PadR( "  g) Karakt. (opisno)..... 1", _left ) GET _kop1 PICT "@!"
   @ m_x + 10, m_y + 2 SAY PadR( "  h) Karakt. (opisno)..... 2", _left ) GET _kop2 PICT "@!"

   @ m_x + 12, m_y + 2 SAY " 22. ODBRANA"

   @ m_x + 14, m_y + 2 SAY "  a) Ratni raspored        " + _idrrasp + "-" + P_RRASP( _idrrasp, -2 )
   @ m_x + 15, m_y + 2 SAY "  b) Sluzio vojni rok      " + _slvr

   IF _slvr == "D"
      @ m_x + 15, Col() + 2 SAY ", u trajanju: " + Str( aVr[ 1 ], 2 ) + "g." + ;
         Str( aVr[ 2 ], 2 ) + "m." + Str( aVr[ 3 ], 2 ) + "d."
   ENDIF

   @ m_x + 16, m_y + 2 SAY "  c) " + IF( glBezVoj, "Pozn.rada na racunaru", "Sposobnost za voj.sl." ) GET _sposvsl PICT "@!"
   @ m_x + 17, m_y + 2 SAY "  d) Cin       " GET _idcin VALID P_Cin( @_idcin, 17, 30 ) PICT "@!"

   @ m_x + 18, m_y + 2 SAY "  e) " + IF( glBezVoj, "Str.jezici ", "VES       " ) GET _idves ;
      VALID P_Ves( @_idves, 18, 30 ) PICT "@!"

   @ m_x + 19, m_y + 2 SAY "  f) " + IF( glBezVoj, "Otisli bi iz firme?  ", "Sekretarijat odbrane " ) GET _nazsekr PICT "@!S40"

   READ

   RETURN LastKey()



// ---------------------------------------
// unos cetvrte stranice
// ---------------------------------------
STATIC FUNCTION get_4( strana, brzi_unos )

   PRIVATE ImeKol

   IF brzi_unos == NIL
      brzi_unos := .F.
   ENDIF

   IF brzi_unos

      ImeKol := { { "Datum ", {|| datumOd } }, ;
         { "Do    ", {|| datumDo } }, ;
         { "Kar.",  {|| IdK }      }, ;
         { "Opis", {|| opis }    },;
         { "Dokument",  {|| Dokument }      }, ;
         { "Nadlezan",  {|| Nadlezan }      }, ;
         { "RJ", {|| IdRJ }    },;
         { "RMj", {|| IdRMJ }    },;
         { "nAtr1", {|| natr1 }    }, ;
         { "nAtr2", {|| natr2 }    }, ;
         { "cAtr1", {|| catr1 }    }, ;
         { "cAtr2", {|| catr2 }    } ;
         }

      @ m_x, m_y + 2 SAY PadC( " TIP PROMJENE: " + gTrPromjena + "-" + ;
         Trim( Ocitaj( F_KADEV_PROMJ, gTrPromjena, "naz" ) ) + " ", 70, "Í" )

   ELSE

      ImeKol := { { "Datum ", {|| datumOd } }, ;
         { "Do    ", {|| datumDo } }, ;
         { "Promjena", {|| IdPromj + "-" + P_Promj( IdPromj, -2 ) }      }, ;
         { "Kar.",  {|| IdK }      }, ;
         { "Dokument",  {|| Dokument }      }, ;
         { "Nadlezan",  {|| Nadlezan }      }, ;
         { "Opis", {|| opis }    },;
         { "RJ", {|| IdRJ }    },;
         { "RMj", {|| IdRMJ }    },;
         { "nAtr1", {|| natr1 }    }, ;
         { "nAtr2", {|| natr2 }    }, ;
         { "cAtr1", {|| catr1 }    }, ;
         { "cAtr2", {|| catr2 }    } ;
         }
   ENDIF

   cID := kadev_0->id

   SELECT kadev_1

   IF brzi_unos
      SET ORDER TO TAG "3"
   ELSE
      SET ORDER TO TAG "1"
   ENDIF

   cOldH := h[ 1 ]

   h[ 1 ] := "Lista promjena "

   // bilo 24
   // CentrTxt( h[1], MAXROWS()-10 )

   @ m_x + 1, m_y + 2 SAY " 23. Promjene - <Ctrl-End> Kraj pregleda, <Strelice> setanje kroz listu"
   @ m_x + 2, m_y + 2 SAY "                <Ctrl-N> Novi zapis, <Ctrl-T> brisanje, <ENTER> edit"
   @ m_x + 3, m_y + 2 SAY "                <Alt-K> Zatvaranje intervalne promjene"

   BrowseKey( m_x + 5, ;
      m_y + 2, ;
      m_x + ( MAXROWS() - 22 ), ;
      m_y + ( MAXCOLS() - 5 ), ;
      ImeKol, ;
      {| Ch| EdPromj( Ch ) }, ;
      IF( brzi_unos, "id + idpromj == cID + gTrPromjena", "id == cID" ), ;
      cId, 2, 4, 60 )

   h[ 1 ] := cOldH

   @ m_x + 19, m_y + 2 SAY "24. Operater " GET _operater PICT "@!"

   READ

   IF !brzi_unos
      @ m_x + 20, m_y + 2 SAY "  ----  <PgUp> Prethodna strana, <PgDn> snimi, <ESC> otkazi promjene --- "
      Inkey( 0 )
   ENDIF

   SET RELATION TO
   SELECT kadev_0

   RETURN LastKey()




// --------------------------------------
// edit promjena
// --------------------------------------
FUNCTION EdPromj( ch )

   LOCAL lPom := .F.
   LOCAL _t_area := Select()

   DO CASE

   CASE Ch == K_ENTER .OR. Ch == K_CTRL_N

      IF Eof() .AND. Ch == K_ENTER
         SELECT ( _t_area )
         RETURN DE_CONT
      ENDIF

      IF Ch == K_CTRL_N
         APPEND BLANK
      ENDIF

      set_global_vars_from_dbf( "q" )

      IF Ch == K_CTRL_N
         qId := cId
      endif

      Box( "btxt", 12 + IF( ! ( "U" $ Type( "qnAtr3" ) ), 7, 0 ), 60, .F., "<ESC> otkazi operaciju" )

      SET CURSOR ON

      @ m_x + 1, m_y + 2 SAY "Datum         " GET qdatumod
      @ m_x + 3, m_y + 2 SAY "Tip promjene  " GET qidpromj;
         VALID P_Promj( @qidpromj, 3, 40 ) PICTURE "@!"
      @ m_x + 4, m_y + 2 SAY "Karakteristika" GET qidk PICT "@!"

      READ

      IF qIdPromj == "G1"
         // godisnji odmor
         @ m_x + 6, m_y + 2 SAY "Koristi pravo na godisnji odmor za godinu   :"  GET qnAtr1 PICT "9999"
         @ m_x + 7, m_y + 2 SAY "Broj dana godisnjeg odmora na koji ima pravo:"  GET qnAtr2  PICT "9999"

         IF !( "U" $ Type( "qnAtr3" ) )
            @ m_x + 8, m_y + 2 SAY "Zakonski minimum                         :"  GET qnAtr3  PICTURE "999"
            @ m_x + 9, m_y + 2 SAY "Po osnovu vrste poslova i zadataka       :"  GET qnAtr4  PICTURE "999"
            @ m_x + 10, m_y + 2 SAY "Po osnovu slozenosti poslova i zadataka  :"  GET qnAtr5  PICTURE "999"
            @ m_x + 11, m_y + 2 SAY "Po osnovu duzine radnog staza            :"  GET qnAtr6  PICTURE "999"
            @ m_x + 12, m_y + 2 SAY "Po osnovu uslova pod kojim radnik zivi   :"  GET qnAtr7  PICTURE "999"
            @ m_x + 13, m_y + 2 SAY "Po osnovu zdravstvenog stanja radnika    :"  GET qnAtr8  PICTURE "999"
            @ m_x + 14, m_y + 2 SAY "Umanjenje preko 30 dana                  :"  GET qnAtr9  PICTURE "999"
         ENDIF
      ENDIF

      IF qdatumod >= _daturmj
         // ako se ubacuje stara promjena ovaj uslov
         qIdRJ := _idrj
         // nije zadovoljen
         qIdRMJ := _idrmj
      ENDIF

      IF P_Promj( qIdPromj, -6 ) == "1"
         // srj = "1" ako se mijenja promjenom radno mjesto
         @ m_x + 6, m_y + 2 SAY "RJ" GET qIdRj PICT "@!"
         @ m_x + 6, Col() + 2 SAY "RMJ" GET qIdRmj VALID Eval( {|| lPom := P_RJRMJ( @qIdRj, @qIdRmj ), SetPos( m_x + 7, m_y + 3 ), QQOut( Ocitaj( F_KDV_RJ, qIdRj, 1 ) ), SetPos( m_x + 8, m_y + 3 ), QQOut( Ocitaj( F_KDV_RMJ, qIdRmj, 1 ) ), lPom } ) PICTURE "@!"
      ENDIF

      IF ( cTipPromj := P_PROMJ( qIdPromj, -4 ) ) == "X" ;
            .AND. P_Promj( qIdPromj, -7 ) $ "+-*A="
         // -7 = URst
         // znaci da se setuje Radni staz
         aRe := GMJD( nAtr1 )
         aRb := GMJD( nAtr2 )
         nGE := aRe[ 1 ]
         nME := aRe[ 2 ]
         nDe := aRe[ 3 ]
         nGB := aRb[ 1 ]
         nMb := aRb[ 2 ]
         nDb := aRb[ 3 ]
         @ m_x + 6, m_y + 2  SAY "Radni staz '" + cTipPromj + "'"
         @ m_x + 7, m_y + 2  SAY "Efektivan G." GET nGE PICTURE "99"
         @ m_x + 7, Col() SAY " Mj." GET nME  PICTURE "99"
         @ m_x + 7, Col() SAY " D." GET nDE  PICTURE "99"
         @ m_x + 7, Col() SAY "    Benef. G." GET nGB  PICTURE "99"
         @ m_x + 7, Col() SAY " Mj." GET nMB PICTURE "99"
         @ m_x + 7, Col() SAY " D." GET nDB PICTURE "99"
         READ
         qnAtr1 := nGE * 365.125 + nME * 30.41 + nDE
         qnAtr2 := nGB * 365.125 + nMB * 30.41 + nDB
      ENDIF

      IF P_PROMJ( qIdPromj, -8 ) == "1"
         // u Ratni raspored
         cRRasp := Left( qcAtr1, 4 )
         @ m_x + 6, m_y + 2 SAY "Ratni raspored "  GET cRRasp VALID P_RRasp( @cRRasp, 7, 2 )  PICTURE "@!"
         READ
         qcAtr1 := cRRasp
      ENDIF

      IF P_PROMJ( qIdPromj, -9 ) == "1"
         // u strucnu spremu
         cStrSpr := Left( qcAtr1, 3 )
         cVStrSpr := Left( qcAtr2, 4 )
         @ m_x + 6, m_y + 2 SAY "Stepen str.spr"  GET cStrSpr VALID  P_StrSpr( @cStrSpr )  PICTURE "@!"
         @ m_x + 7, m_y + 2 SAY " Vrsta str.spr"  GET cVStrSpr VALID P_Zanim( @cVStrSpr )  PICTURE "@!"
         READ
         qcAtr1 := cStrSpr
         qcAtr2 := cVstrSpr
      ENDIF

      @ m_x + 9 + IF( !( "U" $ Type( "qnAtr3" ) ), 7, 0 ), m_y + 2 SAY "Dokument  " GET qDokument PICTURE "@!"
      @ m_x + 10 + IF( !( "U" $ Type( "qnAtr3" ) ), 7, 0 ), m_y + 2 SAY "Opis      " GET qOpis     PICTURE "@!"
      @ m_x + 12 + IF( !( "U" $ Type( "qnAtr3" ) ), 7, 0 ), m_y + 2 SAY "Nadlezan  " GET qNadlezan PICTURE "@!"

      READ

      BoxC()

      IF LastKey() <> K_ESC

         SELECT kadev_1
         _rec := get_dbf_global_memvars( "q", .F. )
         update_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" )

         IF ( Ch == K_CTRL_N .AND. Pitanje( "p09", "Zelite li azurirati ovu promjenu ?", "D" ) == "D" ) ;
               .OR. ( Ch == K_ENTER .AND. Pitanje( "p10", "Zelite li ponovo azurirati ovu promjenu ?", "N" ) == "D" )

            IF P_PROMJ( qIDPromj, -4 ) <> "X"
               // Tip X - samo postavlja odre|ene parametre
               _status := P_PROMJ( qIdPromj, -5 )
            ENDIF

            IF P_PROMJ( qIdPromj, -6 ) == "1"  // SRMJ=="1" - promjena radnog mjesta
               _idRj := qIdRj
               _idRMJ := qIdRMJ
               _DatURMJ := qDatumOd
               IF Empty( _datuf )
                  _DatUF := qDatumOd
               ENDIF
               _DatVRmj := CToD( "" )
            ENDIF

            IF P_PROMJ( qIdPromj, -4 ) == "I"
               // intervalna promjena
               _DatVRMJ := qDatumOd

               _rec := dbf_get_rec()
               _rec[ "datumdo" ] := CToD( "" )
               update_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" )
               // "otvori promjenu !"
            ENDIF

            IF P_PROMJ( qIDPromj, -8 ) == "1"
               // uRRasp = 1
               _IdRRasp := qcAtr1
            ENDIF

            IF P_PROMJ( qIDPromj, -9 ) == "1"    // uStrSpr = 1
               _IdStrSpr := qcAtr1
               _IdZanim := qcAtr2
            ENDIF

         ENDIF

         RETURN DE_REFRESH

      ELSE
         IF Ch == K_CTRL_N
            // brisemo samo append blank u dbf-u, nema nista na serveru
            delete_with_rlock()
            SKIP -1
         ENDIF

         RETURN DE_REFRESH

      ENDIF

   CASE Ch == K_CTRL_T
      IF Pitanje( "p08", "Sigurno zelite izbrisati ovu promjenu ???", "N" ) == "D"
         _rec := dbf_get_rec()
         delete_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" )
         SKIP -1
         RETURN DE_REFRESH
      ELSE
         RETURN DE_CONT
      ENDIF

   CASE Ch == K_CTRL_END
      RETURN DE_ABORT
   CASE Ch == K_ALT_K

      IF P_PROMJ( IdPromj, -4 ) = "I" .AND. Empty( DatumDo )

         // intervalna promjena
         dPom := Date()

         Box( "bzatv", 3, 40, .F. )
         SET CURSOR ON
         @ m_x + 1, m_y + 1 SAY "Datum zatvaranja:" GET dPom VALID dPom >= DatumOd
         READ
         BoxC()

         IF LastKey() <> K_ESC
            _status := "A"
            // zatvaranje promjene
            _datVRMJ := CToD( "" )
            _rec := dbf_get_rec()
            _rec[ "datumdo" ] := dPom
            update_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" )

            IF P_PROMJ( IDPromj, -8 ) == "1"
               _IdRRasp := ""
            ENDIF

            IF P_PROMJ( IdPromj, -5 ) = "M" .AND. ;
                  P_RRASP( Left( cAtr1, 4 ), -4 ) = "V"
               // sluzenje vojnog roka
               _SlVr := "D"
               _VrSlVr += DatumDo - DatumOd
               _IdRRasp := ""
            ENDIF
         ENDIF
      ELSE
         Msg( "Promjena mora biti nezatvorena, intervalnog tipa", 5 )
      ENDIF
      RETURN DE_REFRESH

   OTHERWISE
      RETURN DE_CONT

   ENDCASE

   RETURN



FUNCTION _dobar_id( noviId )

   LOCAL _t_rec
   LOCAL _t_order

   IF Empty( noviId )
      MsgO( "ID broj ne moze biti prazan!" )
      Inkey( 0 )
      MsgC()
      RETURN .F.
   ENDIF

   _t_rec := RecNo()
   _t_order := IndexOrd()

   SET ORDER TO TAG "1"
   GO TOP
   SEEK ( noviId )

   IF Found() .AND. RecNo() <> _t_rec
      MsgO( "Vec postoji zapis sa ovim ID brojem. Ispravite to !" )
      Inkey( 0 )
      MsgC()
      dbSetOrder( _t_order )
      GO ( _t_rec )
      noviId := kadev_0->id
      RETURN .F.
   ENDIF

   dbSetOrder( _t_order )
   GO ( _t_rec )

   IF noviId <> kadev_0->id

      IF Empty( kadev_0->id ) .OR. Pitanje( "p01", "Promijenili ste ID broj. Želite li ovo snimiti (D/N) ?", " " ) == "D"

         IF !f18_lock_tables( { "kadev_1", "kadev_0" } )
            RETURN .T.
         ENDIF

         run_sql_query( "BEGIN" )

         SELECT kadev_1
         SET ORDER TO TAG "1"
         SEEK kadev_0->id

         DO WHILE kadev_0->id == field->id .AND. !Eof()

            SKIP
            nSRec := RecNo()
            SKIP -1

            _rec := dbf_get_rec()
            _rec[ "id" ] := noviId

            update_rec_server_and_dbf( "kadev_1", _rec, 1, "CONT" )
            GO nSRec

         ENDDO

         SELECT kadev_0

         _rec := dbf_get_rec()
         _rec[ "id" ] := noviID

         update_rec_server_and_dbf( "kadev_0", _rec, 1, "CONT" )

         f18_unlock_tables( { "kadev_1", "kadev_0" } )
         run_sql_query( "COMMIT" )

      ELSE
         noviId := kadev_0->id
      ENDIF

   ENDIF

   RETURN .T.



FUNCTION _dobar_id2( noviId2 )

   LOCAL _t_rec, _t_order

   IF !Empty( noviId2 )

      // dozvoljeno je da je noviId2 prazan
      _t_rec := RecNo()
      _t_order := IndexOrd()
      SET ORDER TO TAG "3"
      SEEK ( noviId2 )

      IF Found() .AND. RecNo() <> _t_rec
         MsgO( "Vec postoji zapis sa ovim ID2 brojem. Ispravite to !" )
         Inkey( 0 )
         MsgC()
         dbSetOrder( _t_order )
         GO ( _t_rec )
         noviId2 := kadev_0->id2
         RETURN .F.
      ENDIF

      dbSetOrder( _t_order )
      GO ( _t_rec )

   ENDIF

   RETURN .T.


// ----------------------------------------------------------------------
// provjerava da li radnik postoji u evidenciji vec po mat.broju
// ----------------------------------------------------------------------
FUNCTION kadev_radnik_postoji( id_broj )

   LOCAL _ok := .F.
   LOCAL _qry, _ret

   _qry := "SELECT id FROM " + F18_PSQL_SCHEMA_DOT + "kadev_0 WHERE id = " + sql_quote( id_broj )

   _ret := run_sql_query( _qry )
   IF ValType( _ret ) <> "L" .AND. _ret:LastRec() <> 0
      _ok := .T.
   ENDIF

   IF !_ok
      MsgBeep( "Radnik sa ovim maticnim brojem ne postoji u evidenciji !" )
   ENDIF

   RETURN _ok


// ---------------------------------------------------------
// brisanje osnovnog i njemu pridruzenih slogova
// ---------------------------------------------------------
FUNCTION brisi_kadrovski_karton( erase )

   IF erase == NIL
      erase := .F.
   ENDIF

   IF ERASE .OR. Pitanje( "p02", "Izbrisati karton: " + id + " (D/N) ?", "N" ) == "D"

      MsgO( "Brisem pridruzene zapise" )

      IF !f18_lock_tables( { "kadev_0", "kadev_1" } )
         RETURN
      ENDIF

      run_sql_query( "BEGIN" )

      SELECT kadev_1
      SET ORDER TO TAG "1"
      SEEK kadev_0->id

      IF Found()
         _rec := dbf_get_rec()
         delete_rec_server_and_dbf( "kadev_1", _rec, 2, "CONT" )
      ENDIF

      SELECT kadev_0
      _rec := dbf_get_rec()
      delete_rec_server_and_dbf( "kadev_0", _rec, 1, "CONT" )

      SKIP -1

      f18_unlock_tables( { "kadev_0", "kadev_1" } )
      run_sql_query( "COMMIT" )

      MsgC()

   ENDIF

   RETURN
