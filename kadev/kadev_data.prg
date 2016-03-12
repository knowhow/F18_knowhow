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
#include "hbclass.ch"
#include "common.ch"


CLASS KADEV_DATA_CALC

   VAR jmbg

   DATA radni_staz
   DATA status
   DATA radnik_data
   DATA params
   DATA podaci_promjena

   METHOD new()
   METHOD get_radni_staz()
   METHOD get_status()
   METHOD data_selection()
   METHOD update_status()

   PROTECTED:

   METHOD recalc_radni_staz()
   METHOD recalc_status()
   METHOD init_status()
   METHOD init_radni_staz()

ENDCLASS


// ----------------------------------------------
// ----------------------------------------------
METHOD KADEV_DATA_CALC:New()

   ::params := NIL
   ::podaci_promjena := NIL

   RETURN self


// ----------------------------------------------
// ----------------------------------------------
METHOD KADEV_DATA_CALC:get_radni_staz()

   LOCAL _dat_od := CToD( "" )
   LOCAL _dat_do := Date()

   if ::params[ "datum_do" ] == NIL

      Box(, 1, 60 )
      @ m_x + 1, m_y + 2 SAY "Za datum od:" GET _dat_od
      @ m_x + 1, Col() + 1 SAY "do:" GET _dat_do
      READ
      BoxC()

      IF LastKey() == K_ESC
         RETURN
      ENDIF

      ::params[ "datum_od" ] := _dat_od
      ::params[ "datum_do" ] := _dat_do

   ENDIF

   ::recalc_radni_staz()

   RETURN self



// -----------------------------------------------------
// -----------------------------------------------------
METHOD KADEV_DATA_CALC:update_status()

   LOCAL _rec

   ::data_selection()
   ::get_status()
   ::get_radni_staz()

   SELECT kadev_0
   _rec := dbf_get_rec()

   // samo ako su ove vrijednosti razlicite od praznog
   IF !Empty( ::status[ "rj" ] )
      _rec[ "idrj" ] := ::status[ "rj" ]
   ENDIF

   IF !Empty( ::status[ "rmj" ] )
      _rec[ "idrmj" ] := ::status[ "rmj" ]
   ENDIF

   IF !Empty( ::status[ "id_strucna_sprema" ] )
      _rec[ "idstrspr" ] := ::status[ "id_strucna_sprema" ]
   ENDIF

   _rec[ "radste" ] := ::radni_staz[ "rst_ef" ]
   _rec[ "radstb" ] := ::radni_staz[ "rst_ben" ]
   _rec[ "status" ] := ::status[ "status" ]
   _rec[ "daturmj" ] := ::status[ "datum_u_rmj" ]
   _rec[ "datvrmj" ] := ::status[ "datum_van_rmj" ]
   _rec[ "idrrasp" ] := ::status[ "id_ratni_raspored" ]
   _rec[ "idzanim" ] := ::status[ "id_zanimanja" ]
   _rec[ "vrslvr" ] := ::status[ "sluzenje_vojnog_roka_dana" ]
   _rec[ "slvr" ] := ::status[ "sluzenje_vojnog_roka" ]

   update_rec_server_and_dbf( "kadev_0", _rec, 1, "FULL" )

   RETURN Self




// ----------------------------------------------
// ----------------------------------------------
METHOD KADEV_DATA_CALC:get_status()

   LOCAL _dat_od := CToD( "" )
   LOCAL _dat_do := Date()

   if ::params[ "datum_do" ] == NIL

      Box(, 1, 60 )
      @ m_x + 1, m_y + 2 SAY "Za datum od:" GET _dat_od
      @ m_x + 1, Col() + 1 SAY "do:" GET _dat_do
      READ
      BoxC()

      IF LastKey() == K_ESC
         RETURN
      ENDIF

      ::params[ "datum_od" ] := _dat_od
      ::params[ "datum_do" ] := _dat_do

   ENDIF

   // rekalkulisi status...
   ::recalc_status()

   RETURN self





// ---------------------------------------------
// ---------------------------------------------
METHOD KADEV_DATA_CALC:data_selection()

   LOCAL _datum_od := CToD( "" )
   LOCAL _datum_do := Date()
   LOCAL _data, _qry

   // setovanje parametara...
   IF hb_HHasKey( ::params, "jmbg" )
      ::jmbg := ::params[ "jmbg" ]
   ENDIF

   IF hb_HHasKey( ::params, "datum_od" )
      _datum_od := ::params[ "datum_od" ]
   ENDIF

   IF hb_HHasKey( ::params, "datum_do" )
      _datum_do := ::params[ "datum_do" ]
   ENDIF

   _qry := "SELECT "
   _qry += "  pr.id, "
   _qry += "  pr.datumod, "
   _qry += "  pr.datumdo, "
   _qry += "  pr.idpromj, "
   _qry += "  pr.idrj, "
   _qry += "  pr.idrmj, "
   _qry += "  pr.catr1, "
   _qry += "  pr.catr2, "
   _qry += "  pr.natr1, "
   _qry += "  pr.natr2, "
   _qry += "  prs.naz, "
   _qry += "  prs.tip, "
   _qry += "  prs.status, "
   _qry += "  prs.uradst, "
   _qry += "  prs.srmj, "
   _qry += "  prs.urrasp, "
   _qry += "  prs.ustrspr, "
   _qry += "  rrsp.catr, "
   _qry += "  main.vrslvr, "
   _qry += "  main.idrj AS k0_idrj, "
   _qry += "  main.idrmj AS k0_idrmj, "
   _qry += "  ben.iznos AS benef_iznos "
   _qry += "FROM " + F18_PSQL_SCHEMA_DOT + "kadev_1 pr "
   _qry += "LEFT JOIN " + F18_PSQL_SCHEMA_DOT + "kadev_promj prs ON pr.idpromj = prs.id "
   _qry += "LEFT JOIN " + F18_PSQL_SCHEMA_DOT + "kadev_0 main ON pr.id = main.id "
   _qry += "LEFT JOIN " + F18_PSQL_SCHEMA_DOT + "kadev_rrasp rrsp ON main.idrrasp = rrsp.id "
   _qry += "LEFT JOIN " + F18_PSQL_SCHEMA_DOT + "kadev_rjrmj rjrmj ON pr.idrj = rjrmj.idrj AND pr.idrmj = rjrmj.idrmj "
   _qry += "LEFT JOIN " + F18_PSQL_SCHEMA_DOT + " kbenef ben ON rjrmj.sbenefrst = ben.id "
   _qry += "WHERE pr.id = " + sql_quote( ::jmbg )

   IF _datum_od <> NIL .OR. _datum_do <> NIL
      _qry += " AND ( " + _sql_date_parse( "pr.datumod", _datum_od, _datum_do ) + " ) "
   ENDIF

   _qry += "ORDER BY pr.datumod "

   _data := _sql_query( my_server(), _qry )

   IF sql_query_bez_zapisa( _data )
      RETURN NIL
   ENDIF

   _data:GoTo( 1 )

   ::podaci_promjena := _data

   RETURN Self



// ----------------------------------------------
// ----------------------------------------------
METHOD KADEV_DATA_CALC:recalc_radni_staz()

   LOCAL _ok := .F.
   LOCAL _datum_od := CToD( "" )
   LOCAL _datum_do := Date()
   LOCAL _data, oRow
   LOCAL _rst_ef := 0
   LOCAL _rst_ben := 0
   LOCAL _rst_ufe := 0
   LOCAL _rst_ufb := 0
   LOCAL _otvoreno := .F.
   LOCAL _k_bfr := 0
   LOCAL _a_rst_ef, _a_rst_ben, _a_rst_uk

   IF hb_HHasKey( ::params, "datum_od" )
      _datum_od := ::params[ "datum_od" ]
   ENDIF

   IF hb_HHasKey( ::params, "datum_do" )
      _datum_do := ::params[ "datum_do" ]
   ENDIF

   // inicijalizacija matrice status...
   ::init_radni_staz()

   // daj mi podatke promjena
   _data := ::podaci_promjena

   IF _data == NIL
      RETURN _ok
   ENDIF

   _data:GoTo( 1 )

   DO WHILE !_data:Eof()

      oRow := _data:GetRow()

      _tip_promjene := oRow:FieldGet( oRow:FieldPos( "tip" ) )
      _benef_iznos := oRow:FieldGet( oRow:FieldPos( "benef_iznos" ) )
      _u_radni_staz := oRow:FieldGet( oRow:FieldPos( "uradst" ) )
      _natr_1 := oRow:FieldGet( oRow:FieldPos( "natr1" ) )
      _natr_2 := oRow:FieldGet( oRow:FieldPos( "natr2" ) )
      _d_od := oRow:FieldGet( oRow:FieldPos( "datumod" ) )
      _d_do := oRow:FieldGet( oRow:FieldPos( "datumdo" ) )

      IF _tip_promjene = "X"

         IF _u_radni_staz == "="
            _rst_ef := _natr_1
            _rst_ben := _natr_2
            _rst_ufe := _natr_1
            _rst_ufb := _natr_2
         ENDIF

         IF _u_radni_staz = "+"
            _rst_ef += _natr_1
            _rst_ben += _natr_2
            _rst_ufe += _natr_1
            _rst_ufb += _natr_2
         ENDIF

         IF _u_radni_staz = "-"
            _rst_ef -= _natr_1
            _rst_ben -= _natr_2
            _rst_ufe -= _natr_1
            _rst_ufb -= _natr_2
         ENDIF

         IF _u_radni_staz = "A"
            _rst_ef := ( _rst_ef + _natr_1 ) / 2
            _rst_ben := ( _rst_ben + _natr_2 ) / 2
         ENDIF

         IF _u_radni_staz = "*"
            _rst_ef := ( _rst_ef * _natr_1 )
            _rst_ben := ( _rst_ben * _natr_2 )
         ENDIF

      ELSEIF _tip_promjene == "X"
         // ovu promjenu ignorisi !
         _data:Skip()
         LOOP
      ENDIF

      IF _otvoreno

         _tmp := ( _d_od - _datum_od )
         _tmp_2 := _tmp * _k_bfr / 100

         IF _tmp < 0 .AND. _tip_promjene == "I"
            MsgO( "Neispravne promjene kod " + ::jmbg )
            Inkey( 0 )
            MsgC()
            RETURN _ok
         ELSE
            _rst_ef += _tmp
            _rst_ben += _tmp_2
         ENDIF

      ENDIF

      IF _tip_promjene == " " .AND. _u_radni_staz $ "12"
         _datum_od := _d_od
         // otpocinje proces kalkulacije
         IF _u_radni_staz == "1"
            _k_bfr := _benef_iznos
         ELSE
            _k_bfr := 0
         ENDIF
         _otvoreno := .T.
      ELSE
         _otvoreno := .F.
      ENDIF

      IF _tip_promjene == "I" .AND. _u_radni_staz == " "
         IF Empty( _d_do )
            _otvoreno := .F.
         ELSE
            _otvoreno := .T.
            _datum_od := iif( ( _d_do > _datum_do ), _datum_do, _d_do )
            _k_bfr := _benef_iznos
         ENDIF
      ENDIF

      IF _tip_promjene == "I" .AND. _u_radni_staz $ "12"
         _tmp := iif( Empty( _d_do ), _datum_do, IF( _d_do > _datum_do, _datum_do, _d_do ) ) - _d_od
         IF _u_radni_staz == "1"
            _tmp_2 := _tmp * _benef_iznos / 100
         ELSE
            // za URadSt = 2 ne obracunava se beneficirani r.st.
            _tmp_2 := 0
         ENDIF

         IF _tmp < 0
            MsgO( "Neispravne intervalne promjene kod " + ::jmbg )
            Inkey( 0 )
            MsgC()
            RETURN _ok
         ELSE
            _rst_ef += _tmp
            _rst_ben += _tmp_2
            _otvoreno := .T.
            _datum_od := iif( Empty ( _d_do ), _datum_do, iif( _d_do > _datum_do, _datum_do, _d_do ) )
            _k_bfr := _benef_iznos
         ENDIF

      ENDIF

      _data:Skip()

   ENDDO

   IF _otvoreno

      _tmp := ( _datum_do - _datum_od )
      _tmp_2 := _tmp * _k_bfr / 100

      IF _tmp < 0
         MsgO( "Neispravne promjene ili dat. kalkul. za " + ::jmbg )
         Inkey( 0 )
         MsgC()
         RETURN _ok
      ELSE
         _rst_ef += _tmp
         _rst_ben += _tmp_2
      ENDIF

   ENDIF

   // kalkulacija radnog staza
   _a_rst_ef := GMJD( _rst_ef )
   _a_rst_ben := GMJD( _rst_ben )
   _a_rst_uk := ADDGMJD( _a_rst_ef, _a_rst_ben )

   ::radni_staz[ "rst_ef" ] := _rst_ef
   ::radni_staz[ "rst_ben" ] := _rst_ben

   // efektini opis
   ::radni_staz[ "rst_ef_info" ] := Str( _a_rst_ef[ 1 ], 2 ) + "g." + ;
      Str( _a_rst_ef[ 2 ], 2 ) + "m." + ;
      Str( _a_rst_ef[ 3 ], 2 ) + "d."

   // beneficirani
   ::radni_staz[ "rst_ben_info" ] := Str( _a_rst_ben[ 1 ], 2 ) + "g." + ;
      Str( _a_rst_ben[ 2 ], 2 ) + "m." + ;
      Str( _a_rst_ben[ 3 ], 2 ) + "d."

   // ukupno
   ::radni_staz[ "rst_uk_info" ] := Str( _a_rst_uk[ 1 ], 2 ) + "g." + ;
      Str( _a_rst_uk[ 2 ], 2 ) + "m." + ;
      Str( _a_rst_uk[ 3 ], 2 ) + "d."


   _ok := .T.

   RETURN _ok




// ----------------------------------------------
// inicijalizacija matrice radni staz
// ----------------------------------------------
METHOD KADEV_DATA_CALC:init_radni_staz()

   ::radni_staz := hb_Hash()
   ::radni_staz[ "rst_ef" ] := 0
   ::radni_staz[ "rst_ben" ] := 0
   ::radni_staz[ "rst_ef_info" ] := ""
   ::radni_staz[ "rst_ben_info" ] := ""
   ::radni_staz[ "rst_uk_info" ] := ""

   RETURN Self



// ----------------------------------------------
// inicijalizacija status varijable
// ----------------------------------------------
METHOD KADEV_DATA_CALC:init_status()

   ::status := hb_Hash()
   ::status[ "status" ] := ""
   ::status[ "rj" ] := ""
   ::status[ "rmj" ] := ""
   ::status[ "datum_u_rmj" ] := CToD( "" )
   ::status[ "datum_van_rmj" ] := CToD( "" )
   ::status[ "id_ratni_raspored" ] := ""
   ::status[ "id_strucna_sprema" ] := ""
   ::status[ "id_zanimanja" ] := ""
   ::status[ "sluzenje_vojnog_roka" ] := ""
   ::status[ "sluzenje_vojnog_roka_dana" ] := 0

   RETURN Self



// ----------------------------------------------
// ----------------------------------------------
METHOD KADEV_DATA_CALC:recalc_status()

   LOCAL _datum_od := NIL
   LOCAL _datum_do := NIL
   LOCAL _qry, oRow, _data
   LOCAL _ok := .F.
   LOCAL _id_promjene, _status_promjene, _tip_promjene, _srmj_promjene
   LOCAL _id_rj, _id_rmj, _d_od, _d_do, _rrsp_catr, _vrijeme_sluzenja_vr
   LOCAL _u_radni_staz, _u_ratni_raspored, _u_strucnu_spremu
   LOCAL _catr_1, _catr_2

   IF hb_HHasKey( ::params, "datum_od" )
      _datum_od := ::params[ "datum_od" ]
   ENDIF

   IF hb_HHasKey( ::params, "datum_do" )
      _datum_do := ::params[ "datum_do" ]
   ENDIF

   // inicijalizacija matrice status...
   ::init_status()

   _data := ::podaci_promjena

   IF _data == NIL
      RETURN _ok
   ENDIF

   _data:GoTo( 1 )

   DO WHILE !_data:Eof()

      oRow := _data:GetRow()

      _tip_promjene := oRow:FieldGet( oRow:FieldPos( "tip" ) )
      _status_promjene := oRow:FieldGet( oRow:FieldPos( "status" ) )
      _srmj_promjene := oRow:FieldGet( oRow:FieldPos( "srmj" ) )
      _id_rj := oRow:FieldGet( oRow:FieldPos( "idrj" ) )
      _id_rmj := oRow:FieldGet( oRow:FieldPos( "idrmj" ) )
      _d_od := oRow:FieldGet( oRow:FieldPos( "datumod" ) )
      _d_do := oRow:FieldGet( oRow:FieldPos( "datumdo" ) )
      _rrsp_catr := oRow:FieldGet( oRow:FieldPos( "catr" ) )
      _catr_1 := oRow:FieldGet( oRow:FieldPos( "catr1" ) )
      _catr_2 := oRow:FieldGet( oRow:FieldPos( "catr2" ) )
      _vrijeme_sluzenja_vr := oRow:FieldGet( oRow:FieldPos( "vrslvr" ) )
      _u_radni_staz := oRow:FieldGet( oRow:FieldPos( "uradst" ) )
      _u_ratni_raspored := oRow:FieldGet( oRow:FieldPos( "urrsp" ) )
      _u_strucnu_spremu := oRow:FieldGet( oRow:FieldPos( "ustrspr" ) )

      IF _tip_promjene <> "X"
         ::status[ "status" ] := _status_promjene
      ENDIF

      IF _srmj_promjene == "1"
         // promjena radnog mjesta
         ::status[ "rj" ] := _id_rj
         ::status[ "rmj" ] := _id_rmj
         ::status[ "datum_u_rmj" ] := _d_od
         ::status[ "datum_van_rmj" ] := CToD( "" )
      ELSE
         ::status[ "rj" ] := oRow:FieldGet( oRow:FieldPos( "k0_idrj" ) )
         ::status[ "rmj" ] := oRow:FieldGet( oRow:FieldPos( "k0_idrmj" ) )
      ENDIF

      IF _u_ratni_raspored == "1"
         // setovanje ratnog rasporeda
         ::status[ "id_ratni_raspored" ] := _catr_1
      ENDIF

      IF _u_strucnu_spremu == "1"
         // setovanje strucne spreme
         ::status[ "id_strucna_sprema" ] := _catr_1
         ::status[ "id_zanimanja" ] := _catr_2
      ENDIF

      IF _u_radni_staz = " " .AND. _tip_promjene = " "
         // fiksna promjena
         ::status[ "rmj" ] := ""
         ::status[ "rj" ] := ""
         ::status[ "datum_van_rmj" ] := _d_od
      ENDIF

      IF _tip_promjene == "I"
         // intervalna promjena

         IF !( Empty( _d_od ) .OR. ( _d_do > _datum_do ) )
            // zatvorena
            IF _status_promjene == "M" .AND. _rrsp_catr == "V"
               // catr = "V" -> sluzenje vojnog roka
               ::status[ "sluzenje_vojnog_roka" ] := "D"
               ::status[ "sluzenje_vojnog_roka_dana" ] := _vrijeme_sluzenja_vr + ( _d_do - _d_od )
            ENDIF
         ENDIF

         IF Empty( _d_do ) .OR. ( _d_do > _datum_do )
            ::status[ "datum_van_rmj" ] := _d_od
         ELSE
            IF _u_ratni_raspored = "1"
               // vrsi se zatvaranje promjene
               // ako je intervalna promjena setovala RRasp
               ::status[ "id_ratni_raspored" ] := ""
            ENDIF
            ::status[ "status" ] := "A"
         ENDIF

      ENDIF

      _data:skip()

   ENDDO

   _ok := .T.

   RETURN _ok
