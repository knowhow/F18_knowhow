/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"

MEMVAR m_x, m_y, GetList
MEMVAR gFirma

CLASS FaktDokumenti

   DATA    items
   DATA    COUNT

   METHOD  count_markirani
   METHOD  New()
   METHOD  za_partnera( idfirma, idtipdok, idpartner )
   METHOD  pretvori_otpremnice_u_racun()
   METHOD  change_idtipdok_markirani( new_idtipdok )

   ASSIGN  locked   INLINE ::p_locked
   METHOD  Lock()

   PROTECTED:
   METHOD generisi_fakt_pripr_vars()
   METHOD  generisi_fakt_pripr()
   DATA  _sql_where
   DATA  p_idfirma
   DATA  p_idtipdok
   DATA  p_idpartner
   DATA  p_locked  INIT .F.
   DATA  p_lock_tables INIT { "fakt_fakt", "fakt_doks", "fakt_doks2" }

ENDCLASS


METHOD FaktDokumenti:New()

   ::items := {}
   ::count := 0

   RETURN self


// -------------------------------------------
// lokuj - zabrani promjene drugih
// logika semafora ovo zahtjeva
// -------------------------------------------
METHOD FaktDokumenti:Lock()

   IF f18_lock_tables( ::p_lock_tables, .T. )
      ::p_locked := .T.
   ELSE
      ::p_locked := .F.
   ENDIF

   return ::p_locked





METHOD FaktDokumenti:za_partnera( idfirma, idtipdok, idpartner )

   LOCAL _qry_str
   LOCAL _cnt
   LOCAL _brdok
   LOCAL _qry
   LOCAL _item

   ::p_idfirma := idfirma
   ::p_idtipdok := idtipdok
   ::p_idpartner := idpartner

   _qry_str := "SELECT fakt_doks.idfirma, fakt_doks.idtipdok, fakt_doks.brdok FROM " + F18_PSQL_SCHEMA_DOT + "fakt_doks "
   _qry_str += "WHERE "

   ::_sql_where := "fakt_doks.idfirma=" + sql_quote( ::p_idfirma ) +  " AND fakt_doks.idtipdok=" + sql_quote( ::p_idtipdok ) + " AND fakt_doks.idpartner=" + sql_quote( ::p_idpartner )

   _qry_str += ::_sql_where
   _qry := run_sql_query( _qry_str )

   _cnt := 0
   DO WHILE !_qry:Eof()
      _brdok := _qry:FieldGet( 3 )
      // napunicemo items matricom FaktDokument objekata
      _item := FaktDokument():New( ::p_idfirma, ::p_idtipdok, _brdok )
      _item:refresh_info()
      AAdd( ::items, _item )
      _cnt ++
      _qry:skip()
   ENDDO

   ::count := _cnt

   RETURN _cnt




METHOD FaktDokumenti:pretvori_otpremnice_u_racun()

   LOCAL _idfirma, _idtipdok, _idpartner
   LOCAL _suma := 0
   LOCAL _veza_otpr := ""
   LOCAL _datum_max := Date()
   LOCAL _ok
   LOCAL _lock_user := ""
   LOCAL _fakt_browse

   O_FAKT_PRIPR
   GO TOP

   // ako je priprema prazna
   IF RecCount2() <> 0
      MsgBeep( "FAKT priprema nije prazna" )
      RETURN .F.
   ENDIF

   _idfirma   := gFirma
   _idtipdok  := "12"
   _idpartner := Space( 6 )
   _suma      := 0

   SET CURSOR ON

   Box(, MAXROWS() - 7, MAXCOLS() - 10 )

   @ m_x + 1, m_y + 2 SAY "PREGLED OTPREMNICA:"
   @ m_x + 3, m_y + 2 SAY "Radna jedinica" GET  _idfirma PICT "@!"
   @ m_x + 3, Col() + 1 SAY " - " + _idtipdok + " / " PICT "@!"
   @ m_x + 3, Col() + 1 SAY "Partner ID:" GET _idpartner PICT "@!" ;
      VALID {|| P_Firma( @_idpartner ),  ispisi_partn( _idpartner, m_x + MAXROWS() -12, m_y + 18 ) }

   READ

   @ m_x + MAXROWS() -12, m_y + 2 SAY "Partner:"
   @ m_x + MAXROWS() -10, m_y + 2 SAY "Komande: <SPACE> markiraj otpremnicu"


   ::za_partnera( _idfirma, _idtipdok, _idpartner )

   _fakt_browse := BrowseFaktDokumenti():New( m_x + 5, m_y + 1, m_x + MAXROWS() - 13, MAXCOLS() -11, self )
   _fakt_browse:set_kolone_markiraj_otpremnice()
   _fakt_browse:Browse()


   BoxC()

   if ::count_markirani > 0
      if ::change_idtipdok_markirani( "22" )
         ::generisi_fakt_pripr()
      ENDIF
   ELSE
      MsgBeep( "Nije odabrana nijedna otpremnica !" )
   ENDIF

   RETURN .T.


METHOD FaktDokumenti:generisi_fakt_pripr_vars( params )

   LOCAL _ok := .T.
   LOCAL _sumiraj := "N"
   LOCAL _tip_rn := 1
   LOCAL _valuta := PadR( ValDomaca(), 3 )

   params := hb_Hash()

   Box(, 6, 65 )

   @ m_x + 1, m_y + 2 SAY "Sumirati stavke otpremnica (D/N) ?" GET _sumiraj ;
      VALID _sumiraj $ "DN" PICT "@!"

   @ m_x + 3, m_y + 2 SAY "Formirati tip racuna: 1 (veleprodaja)"
   @ m_x + 4, m_y + 2 SAY "                      2 (maloprodaja)" GET _tip_rn ;
      VALID ( _tip_rn > 0 .AND. _tip_rn < 3 ) PICT "9"

   @ m_x + 6, m_y + 2 SAY "Valuta (KM/EUR):" GET _valuta VALID !Empty( _valuta ) PICT "@!"

   READ

   BoxC()

   IF LastKey() == K_ESC
      _ok := .F.
      RETURN _ok
   ENDIF

   // snimi mi u matricu parametre
   params[ "tip_racuna" ] := _tip_rn
   params[ "sumiraj" ] := _sumiraj
   params[ "valuta" ] := Upper( _valuta )

   RETURN _ok



METHOD FaktDokumenti:count_markirani()

   LOCAL _item, _cnt

   _cnt := 0
   FOR EACH _item IN ::items
      IF _item:mark
         _cnt ++
      ENDIF
   NEXT

   RETURN _cnt


METHOD FaktDokumenti:change_idtipdok_markirani( new_idtipdok )

   LOCAL _err, _item, _broj, _ok := .T.
   LOCAL hParams

   BEGIN SEQUENCE WITH {| err| err:cargo := { ProcName( 1 ), ProcName( 2 ), ProcLine( 1 ), ProcLine( 2 ) }, Break( err ) }

      run_sql_query( "BEGIN; SET TRANSACTION ISOLATION LEVEL SERIALIZABLE" )

      IF !::lock
         run_sql_query( "ROLLBACK" )
         MsgBeep( "Neuspješno zaključavanje tabela, operacija " + ::p_idtipdok + "=>" + new_idtipdok + " otkazana !" )
         _ok := .F.
         BREAK
      ENDIF

      FOR EACH _item IN ::items
         IF _item:mark
            _broj := _item:broj
            IF !_item:change_idtipdok( new_idtipdok )
               run_sql_query( "ROLLBACK" )
               _ok := .F.
               BREAK
            ENDIF
         ENDIF
      NEXT

      hParams := hb_Hash()
      hParams[ "unlock" ] :=  ::p_lock_tables
      run_sql_query( "COMMIT", hParams )
      _ok := .T.

   RECOVER

      MsgBeep( "Neuspješna konverzija " + _broj + " idtpdok => " + new_idtipdok + " !" )
      _ok := .F.

   END SEQUENCE

   close_open_fakt_tabele()

   ::p_idtipdok := new_idtipdok

   RETURN _ok


METHOD FaktDokumenti:generisi_fakt_pripr()

   LOCAL _sumirati := .F.
   LOCAL _vp_mp := 1
   LOCAL _n_tip_dok, _dat_max, _t_rec, _t_fakt_rec
   LOCAL _veza_otpremnice, _broj_dokumenta
   LOCAL _id_partner, _rec
   LOCAL _ok := .T.
   LOCAL _item, _msg
   LOCAL _gen_params, _valuta
   LOCAL _first
   LOCAL _qry
   LOCAL _datum_max

   IF !::generisi_fakt_pripr_vars( @_gen_params ) // parametri generisanja...
      RETURN .F.
   ENDIF

   // uzmi parametre matrice...
   _sumirati := _gen_params[ "sumiraj" ] == "D"
   _vp_mp := _gen_params[ "tip_racuna" ]
   _valuta := _gen_params[ "valuta" ]

   IF _vp_mp == 1
      _n_tip_dok := "10"
   ELSE
      _n_tip_dok := "11"
   ENDIF

   _sql := "SELECT idroba, cijena, COALESCE(substring(txt from '\x10(.*?)\x11\x10.*?\x11' ), '') AS opis_usluga, "
   IF _sumirati
      _sql += "sum(kolicina), max(datdok), max(txt)"
   ELSE
      _sql += "kolicina, datdok, txt"
   ENDIF
   _sql += " FROM " + F18_PSQL_SCHEMA_DOT + "fakt_fakt "
   _sql += " LEFT JOIN " + F18_PSQL_SCHEMA_DOT + "roba "
   _sql += " ON fakt_fakt.idroba=roba.id "
   _sql += " WHERE "
   _sql += "idfirma=" + sql_quote( ::p_idfirma ) + " AND  idtipdok=" + sql_quote( ::p_idtipdok )
   _sql += " AND brdok IN ("

   _veza_otpremnice := ""
   _first := .T.
   FOR EACH _item IN ::items
      IF _item:mark
         IF _first
            _first := .F.
         ELSE
            _sql += ","
            _veza_otpremnice += ","
         ENDIF
         _sql += sql_quote( _item:brdok )
         _veza_otpremnice += Trim( _item:brdok )
      ENDIF
   NEXT

   _sql += ")"

   IF _sumirati
      _sql += " group by idroba,cijena,opis_usluga order by idroba,cijena,opis_usluga"
   ELSE
      _sql += " order by idroba,cijena,opis_usluga"
   ENDIF

   _qry := run_sql_query( _sql )

   SELECT fakt_pripr
   _fakt_rec := dbf_get_rec()

   _fakt_rec[ "idfirma" ]   := ::p_idfirma
   _fakt_rec[ "idpartner" ] := ::p_idpartner
   _fakt_rec[ "brdok" ]     := fakt_prazan_broj_dokumenta()
   _fakt_rec[ "datdok" ]    := Date()
   _fakt_rec[ "idtipdok" ]  := _n_tip_dok
   _fakt_rec[ "dindem" ]    := Left( _valuta, 3 )
   _datum_max := Date()

   DO WHILE !_qry:Eof()

      _fakt_rec[ "idroba" ]   :=  _to_str( _qry:FieldGet( 1 ) )
      _fakt_rec[ "cijena" ]   := _qry:FieldGet( 2 )
      // ovo polje ipak ne trebamo
      // _opis_usluga := _qry:FieldGet(3)
      _fakt_rec[ "kolicina" ] := _qry:FieldGet( 4 )
      _fakt_rec[ "datdok" ]   := _qry:FieldGet( 5 )
      _fakt_rec[ "txt" ]      := _to_str( _qry:FieldGet( 6 ) )

      IF _fakt_rec[ "datdok" ] > _datum_max
         _datum_max := _fakt_rec[ "datdok" ]
      ENDIF

      IF _vp_mp == 2
         // radi se o mp racunu, izracunaj cijenu sa pdv
         _fakt_rec[ "cijena" ] := Round( _uk_sa_pdv( ::p_idtipdok, ::p_idpartner, _fakt_rec[ "cijena" ] ), 2 )
      ENDIF

      APPEND BLANK
      dbf_update_rec( _fakt_rec )

      _qry:skip()

   ENDDO

   _veza_otpremnice := "Racun formiran na osnovu otpremnica: " + _veza_otpremnice

   renumeracija_fakt_pripr( _veza_otpremnice, _datum_max )

   RETURN _ok




/* renumeracija_fakt_pripr(cVezOtpr,dNajnoviji)
  *
  *   param: cVezOtpr
  *   param: dNajnoviji - datum posljednje radjene otpremnice

  // poziva se samo pri generaciji otpremnica u fakturu
*/


FUNCTION renumeracija_fakt_pripr( veza_otpremnica, datum_max )

   LOCAL dDatDok
   LOCAL lSetujDatum := .F.
   PRIVATE nRokPl := 0
   PRIVATE cSetPor := "N"

   SELECT fakt_pripr
   SET ORDER TO TAG "1"
   GO TOP

   IF RecCount2 () == 0
      RETURN
   ENDIF

   nRbr := 999
   GO BOTTOM

   my_flock()

   DO WHILE !Bof()
      REPLACE rbr WITH Str( --nRbr, 3 )
      SKIP -1
   ENDDO

   nRbr := 0
   DO WHILE !Eof()
      SKIP
      nTrec := RecNo()
      SKIP -1
      IF Empty( podbr )
         REPLACE rbr WITH Str( ++nRbr, 3, 0 )
      ELSE
         IF nRbr == 0
            nRbr := 1
         ENDIF
         REPLACE rbr WITH Str( nRbr, 3, 0 )
      ENDIF
      GO nTrec
   ENDDO

   my_unlock()

   GO TOP

   Scatter()

   _txt1 := _txt2 := _txt3a := _txt3b := _txt3c := ""
   _dest := Space( 150 )
   _m_dveza := Space( 500 )

   IF my_get_from_ini( 'FAKT', 'ProsiriPoljeOtpremniceNa50', 'N', KUMPATH ) == 'D'
      _BrOtp := Space( 50 )
   ELSE
      _BrOtp := Space( 8 )
   ENDIF

   _DatOtp := CToD( "" )
   _BrNar := Space( 8 )
   _DatPl := CToD( "" )

   IF veza_otpremnica == nil
      veza_otpremnica := ""
   ENDIF

   aMemo := ParsMemo( _txt )
   IF Len( aMemo ) > 0
      _txt1 := aMemo[ 1 ]
   ENDIF
   IF Len( aMemo ) >= 2
      _txt2 := aMemo[ 2 ]
   ENDIF
   IF Len( aMemo ) >= 5
      _txt3a := aMemo[ 3 ]
      _txt3b := aMemo[ 4 ]
      _txt3c := aMemo[ 5 ]
   ENDIF
   IF Len( aMemo ) >= 9
      _BrOtp := aMemo[ 6 ]
      _DatOtp := CToD( aMemo[ 7 ] )
      _BrNar := amemo[ 8 ]
      _DatPl := CToD( aMemo[ 9 ] )
   ENDIF
   IF Len( aMemo ) >= 10 .AND. !Empty( aMemo[ 10 ] )
      cVezOtpr := aMemo[ 10 ]
   ENDIF

   // destinacija
   IF Len( aMemo ) >= 18
      _dest := PadR( aMemo[ 18 ], 150 )
   ENDIF

   IF Len( aMemo ) >= 19
      _m_dveza := PadR( aMemo[ 19 ], 500 )
   ENDIF

   nRbr := 1

   Box( "#PARAMETRI DOKUMENTA:", 10, 75 )

   IF gDodPar == "1"
      @  m_x + 1, m_y + 2 SAY "Otpremnica broj:" GET _brotp
      @  m_x + 2, m_y + 2 SAY "          datum:" GET _Datotp
      @  m_x + 3, m_y + 2 SAY8 "Ugovor/narudžba:" GET _brNar
      @  m_x + 4, m_y + 2 SAY "    Destinacija:" GET _dest PICT "@S45"
      @  m_x + 5, m_y + 2 SAY "Vezni dokumenti:" GET _m_dveza PICT "@S45"
   ENDIF

   IF gDodPar == "1" .OR. gDatVal == "D"

      nRokPl := gRokPl

      @  m_x + 6, m_y + 2 SAY "Datum fakture  :" GET _DatDok

      IF datum_max <> NIL
         @  m_x + 6, m_y + 35 SAY "Datum posljednje otpremnice:" GET datum_max WHEN .F. COLOR "GR+/B"
      ENDIF

      @ m_x + 7, m_y + 2 SAY8 "Rok plać.(dana):" GET nRokPl PICT "999" WHEN valid_rok_placanja( @nRokPl, "0", .T. ) ;
         VALID valid_rok_placanja( nRokPl, "1", .T. )
      @ m_x + 8, m_y + 2 SAY8 "Datum plaćanja :" GET _DatPl VALID valid_rok_placanja( nRokPl, "2", .T. )

      READ
   ENDIF

   READ

   BoxC()

   dDatDok := _Datdok

   UzorTxt()

   IF !Empty ( veza_otpremnica )
      _txt2 += Chr( 13 ) + Chr( 10 ) + veza_otpremnica
   ENDIF

   _txt := Chr( 16 ) + Trim( _txt1 ) + Chr( 17 ) + Chr( 16 ) + _txt2 + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _txt3a ) + Chr( 17 ) + Chr( 16 ) + _txt3b + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _txt3c ) + Chr( 17 ) + ;
      Chr( 16 ) + _BrOtp + Chr( 17 ) + ;
      Chr( 16 ) + DToC( _DatOtp ) + Chr( 17 ) + ;
      Chr( 16 ) + _BrNar + Chr( 17 ) + ;
      Chr( 16 ) + DToC( _DatPl ) + Chr( 17 ) + ;
      iif( Empty ( veza_otpremnica ), "", Chr( 16 ) + veza_otpremnica + Chr( 17 ) ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _dest ) + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _m_dveza ) + Chr( 17 )

   IF datDok <> dDatDok
      lSetujDatum := .T.
   ENDIF

   my_rlock()
   Gather()
   my_unlock()

   RETURN .T.
