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
return self


// ----------------------------------------------
// ----------------------------------------------
METHOD KADEV_DATA_CALC:get_radni_staz()
local _dat_od := CTOD("")
local _dat_do := DATE()

if ::params["datum_do"] == NIL

    Box(, 1, 60 )
        @ m_x + 1, m_y + 2 SAY "Za datum od:" GET _dat_od
        @ m_x + 1, col() + 1 SAY "do:" GET _dat_do
        read
    BoxC()

    if LastKey() == K_ESC
        return
    endif

    ::params["datum_od"] := _dat_od
    ::params["datum_do"] := _dat_do

endif

::recalc_radni_staz()

return self



// -----------------------------------------------------
// -----------------------------------------------------
METHOD KADEV_DATA_CALC:update_status()
local _rec

::data_selection()
::get_status()
::get_radni_staz()

select kadev_0
_rec := dbf_get_rec()

_rec["radste"] := ::radni_staz["rst_ef"]
_rec["radstb"] := ::radni_staz["rst_ben"]
_rec["status"] := ::status["status"]
_rec["idrj"] := ::status["rj"]
_rec["idrmj"] := ::status["rmj"]
_rec["daturmj"] := ::status["datum_u_rmj"]
_rec["datvrmj"] := ::status["datum_van_rmj"]
_rec["idrrasp"] := ::status["id_ratni_raspored"]
_rec["idstrspr"] := ::status["id_strucna_sprema"]
_rec["idzanim"] := ::status["id_zanimanja"]
_rec["vrslvr"] := ::status["sluzenje_vojnog_roka_dana"]
_rec["slvr"] := ::status["sluzenje_vojnog_roka"]

update_rec_server_and_dbf( "kadev_0", _rec, 1, "FULL" )

return Self




// ----------------------------------------------
// ----------------------------------------------
METHOD KADEV_DATA_CALC:get_status()
local _dat_od := CTOD("")
local _dat_do := DATE()

if ::params["datum_do"] == NIL

    Box(, 1, 60 )
        @ m_x + 1, m_y + 2 SAY "Za datum od:" GET _dat_od
        @ m_x + 1, col() + 1 SAY "do:" GET _dat_do
        read
    BoxC()

    if LastKey() == K_ESC
        return
    endif

    ::params["datum_od"] := _dat_od
    ::params["datum_do"] := _dat_do

endif

// rekalkulisi status...
::recalc_status()

return self





// ---------------------------------------------
// ---------------------------------------------
METHOD KADEV_DATA_CALC:data_selection()
local _datum_od := CTOD("")
local _datum_do := DATE()
local _data, _qry

// setovanje parametara...
if hb_hhaskey( ::params, "jmbg" )
    ::jmbg := ::params["jmbg"]
endif

if hb_hhaskey( ::params, "datum_od" )
    _datum_od := ::params["datum_od"]
endif

if hb_hhaskey( ::params, "datum_do" )
    _datum_do := ::params["datum_do"]
endif

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
_qry += "FROM fmk.kadev_1 pr "
_qry += "LEFT JOIN fmk.kadev_promj prs ON pr.idpromj = prs.id "
_qry += "LEFT JOIN fmk.kadev_0 main ON pr.id = main.id "
_qry += "LEFT JOIN fmk.kadev_rrasp rrsp ON main.idrrasp = rrsp.id "
_qry += "LEFT JOIN fmk.kadev_rjrmj rjrmj ON pr.idrj = rjrmj.idrj AND pr.idrmj = rjrmj.idrmj "
_qry += "LEFT JOIN fmk.kbenef ben ON rjrmj.sbenefrst = ben.id "
_qry += "WHERE pr.id = " + _sql_quote( ::jmbg )

if _datum_od <> NIL .or. _datum_do <> NIL
    _qry += " AND ( " + _sql_date_parse( "pr.datumod", _datum_od, _datum_do ) + " ) " 
endif

_qry += "ORDER BY pr.datumod "

_data := _sql_query( my_server(), _qry )

if VALTYPE( _data ) == "L"
    return NIL
endif

_data:Refresh()
_data:GoTo(1)

::podaci_promjena := _data

return Self



// ----------------------------------------------
// ----------------------------------------------
METHOD KADEV_DATA_CALC:recalc_radni_staz()
local _ok := .f.
local _datum_od := CTOD("")
local _datum_do := DATE()
local _data, oRow
local _rst_ef := 0
local _rst_ben := 0
local _rst_ufe := 0
local _rst_ufb := 0
local _otvoreno := .f.
local _k_bfr := 0
local _a_rst_ef, _a_rst_ben, _a_rst_uk

if hb_hhaskey( ::params, "datum_od" )
    _datum_od := ::params["datum_od"]
endif

if hb_hhaskey( ::params, "datum_do" )
    _datum_do := ::params["datum_do"]
endif

// inicijalizacija matrice status...
::init_radni_staz()

// daj mi podatke promjena
_data := ::podaci_promjena

if _data == NIL
    return _ok
endif

_data:GoTo(1)

do while !_data:EOF() 

    oRow := _data:GetRow()

    _tip_promjene := oRow:FieldGet( oRow:FieldPos( "tip" ) )
    _benef_iznos := oRow:FieldGet( oRow:FieldPos( "benef_iznos" ) )
    _u_radni_staz := oRow:FieldGet( oRow:FieldPos( "uradst" ) )
    _natr_1 := oRow:FieldGet( oRow:FieldPos( "natr1" ) )
    _natr_2 := oRow:FieldGet( oRow:FieldPos( "natr2" ) )
    _d_od := oRow:FieldGet( oRow:FieldPos( "datumod" ) )
    _d_do := oRow:FieldGet( oRow:FieldPos( "datumdo" ) )
 
    if _tip_promjene = "X" 

        if _u_radni_staz == "="
            _rst_ef := _natr_1
            _rst_ben := _natr_2
            _rst_ufe := _natr_1
            _rst_ufb := _natr_2
        endif

        if _u_radni_staz = "+"
            _rst_ef += _natr_1
            _rst_ben += _natr_2
            _rst_ufe += _natr_1
            _rst_ufb += _natr_2
        endif

        if _u_radni_staz = "-"
            _rst_ef -= _natr_1
            _rst_ben -= _natr_2
            _rst_ufe -= _natr_1
            _rst_ufb -= _natr_2
        endif

        if _u_radni_staz = "A"
            _rst_ef := ( _rst_ef + _natr_1 ) / 2
            _rst_ben := ( _rst_ben + _natr_2 ) / 2
        endif

        if _u_radni_staz = "*"
            _rst_ef := ( _rst_ef * _natr_1 )
            _rst_ben := ( _rst_ben * _natr_2 )
        endif
    
    elseif _tip_promjene == "X"
        // ovu promjenu ignorisi !
        _data:Skip()
        LOOP
    endif

    if _otvoreno

        _tmp := ( _d_od - _datum_od )
        _tmp_2 := _tmp * _k_bfr / 100
        
        if _tmp < 0 .and. _tip_promjene == "I"      
            MsgO( "Neispravne promjene kod " + ::jmbg )
                Inkey(0)
            MsgC()
            return _ok
        else
            _rst_ef += _tmp
            _rst_ben += _tmp_2
        endif

    endif

    if _tip_promjene == " " .and. _u_radni_staz $ "12" 
        _datum_od := _d_od
        // otpocinje proces kalkulacije
        if _u_radni_staz == "1"
            _k_bfr := _benef_iznos
        else   
            _k_bfr := 0
        endif
        _otvoreno := .t.     
    else
        _otvoreno := .f.
    endif

    if _tip_promjene == "I" .and. _u_radni_staz == " "
        if EMPTY( _d_do )  
            _otvoreno := .f.   
        else
            _otvoreno := .t.
            _datum_od := IIF( ( _d_do > _datum_do ), _datum_do, _d_do ) 
            _k_bfr := _benef_iznos
        endif
    endif

    if _tip_promjene == "I" .and. _u_radni_staz $ "12"
        _tmp := IIF( EMPTY( _d_do ), _datum_do, IF( _d_do > _datum_do, _datum_do, _d_do ) ) - _d_od
        if _u_radni_staz == "1"
            _tmp_2 := _tmp * _benef_iznos / 100
        else   
            // za URadSt = 2 ne obracunava se beneficirani r.st.
            _tmp_2 := 0
        endif

        if _tmp < 0 
            MsgO("Neispravne intervalne promjene kod " + ::jmbg )
                Inkey(0)
            MsgC()
            return _ok
        else
            _rst_ef += _tmp
            _rst_ben += _tmp_2
            _otvoreno := .t.
            _datum_od := IIF( EMPTY ( _d_do ), _datum_do, IIF( _d_do > _datum_do, _datum_do, _d_do ) )
            _k_bfr := _benef_iznos
        endif

    endif

    _data:Skip()

enddo
  
if _otvoreno

    _tmp := ( _datum_do - _datum_od )
    _tmp_2 := _tmp * _k_bfr / 100

    if _tmp < 0
        MsgO("Neispravne promjene ili dat. kalkul. za " + ::jmbg )
            Inkey(0)
        MsgC()
        return _ok
    else
        _rst_ef += _tmp
        _rst_ben += _tmp_2
    endif

endif

// kalkulacija radnog staza
_a_rst_ef := GMJD( _rst_ef )
_a_rst_ben := GMJD( _rst_ben )
_a_rst_uk := ADDGMJD( _a_rst_ef, _a_rst_ben )

::radni_staz["rst_ef"] := _rst_ef
::radni_staz["rst_ben"] := _rst_ben

// efektini opis
::radni_staz["rst_ef_info"] := STR( _a_rst_ef[1], 2 ) + "g." + ;
                                STR( _a_rst_ef[2], 2 ) + "m." + ;
                                STR( _a_rst_ef[3], 2 ) + "d."

// beneficirani
::radni_staz["rst_ben_info"] := STR( _a_rst_ben[1], 2 ) + "g." + ;
                                STR( _a_rst_ben[2], 2 ) + "m." + ;
                                STR( _a_rst_ben[3], 2 ) + "d."

// ukupno
::radni_staz["rst_uk_info"] := STR( _a_rst_uk[1], 2 ) + "g." + ;
                                STR( _a_rst_uk[2], 2 ) + "m." + ;
                                STR( _a_rst_uk[3], 2 ) + "d."


_ok := .t.

return _ok




// ----------------------------------------------
// inicijalizacija matrice radni staz
// ----------------------------------------------
METHOD KADEV_DATA_CALC:init_radni_staz()

::radni_staz := hb_hash()
::radni_staz["rst_ef"] := 0
::radni_staz["rst_ben"] := 0
::radni_staz["rst_ef_info"] := ""
::radni_staz["rst_ben_info"] := ""
::radni_staz["rst_uk_info"] := ""

return Self



// ----------------------------------------------
// inicijalizacija status varijable
// ----------------------------------------------
METHOD KADEV_DATA_CALC:init_status()

::status := hb_hash()
::status["status"] := ""
::status["rj"] := ""
::status["rmj"] := ""
::status["datum_u_rmj"] := CTOD("")
::status["datum_van_rmj"] := CTOD("")
::status["id_ratni_raspored"] := ""
::status["id_strucna_sprema"] := ""
::status["id_zanimanja"] := ""
::status["sluzenje_vojnog_roka"] := ""
::status["sluzenje_vojnog_roka_dana"] := 0

return Self



// ----------------------------------------------
// ----------------------------------------------
METHOD KADEV_DATA_CALC:recalc_status()
local _datum_od := NIL
local _datum_do := NIL
local _qry, oRow, _data
local _ok := .f.
local _id_promjene, _status_promjene, _tip_promjene, _srmj_promjene
local _id_rj, _id_rmj, _d_od, _d_do, _rrsp_catr, _vrijeme_sluzenja_vr
local _u_radni_staz, _u_ratni_raspored, _u_strucnu_spremu
local _catr_1, _catr_2

if hb_hhaskey( ::params, "datum_od" )
    _datum_od := ::params["datum_od"]
endif

if hb_hhaskey( ::params, "datum_do" )
    _datum_do := ::params["datum_do"]
endif

// inicijalizacija matrice status...
::init_status()

_data := ::podaci_promjena

if _data == NIL
    return _ok
endif

_data:GoTo(1)

do while !_data:EOF() 

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
     
    if _tip_promjene <> "X" 
        ::status["status"] := _status_promjene
    endif

    if _srmj_promjene == "1"  
        // promjena radnog mjesta
        ::status["rj"] := _id_rj 
        ::status["rmj"] := _id_rmj
        ::status["datum_u_rmj"] := _d_od
        ::status["datum_van_rmj"] := CTOD("")
    else
        ::status["rj"] := oRow:FieldGet( oRow:FieldPos( "k0_idrj" ) )
        ::status["rmj"] := oRow:FieldGet( oRow:FieldPos( "k0_idrmj" ) )
    endif

    if _u_ratni_raspored == "1" 
        // setovanje ratnog rasporeda
        ::status["id_ratni_raspored"] := _catr_1
    endif

    if _u_strucnu_spremu == "1" 
        // setovanje strucne spreme
        ::status["id_strucna_sprema"] := _catr_1
        ::status["id_zanimanja"] := _catr_2
    endif

    if _u_radni_staz = " " .and. _tip_promjene = " " 
        // fiksna promjena
        ::status["rmj"] := ""
        ::status["rj"] := ""
        ::status["datum_van_rmj"] := _d_od
    endif

    if _tip_promjene == "I"  
        // intervalna promjena
        
        if !( EMPTY( _d_od ) .or. ( _d_do > _datum_do )) 
            // zatvorena
            if _status_promjene == "M" .and. _rrsp_catr == "V" 
                // catr = "V" -> sluzenje vojnog roka
                ::status["sluzenje_vojnog_roka"] := "D"
                ::status["sluzenje_vojnog_roka_dana"] := _vrijeme_sluzenja_vr + ( _d_do - _d_od )
            endif
        endif

        if EMPTY( _d_do ) .or. ( _d_do > _datum_do )
            ::status["datum_van_rmj"] := _d_od
        else   
            if _u_ratni_raspored = "1"  
                // vrsi se zatvaranje promjene
                // ako je intervalna promjena setovala RRasp
                ::status["id_ratni_raspored"] := ""
            endif
            ::status["status"] := "A"
        endif

    endif

    _data:skip()

enddo

_ok := .t.

return _ok




