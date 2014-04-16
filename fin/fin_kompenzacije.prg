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


#include "fin.ch"

static picBHD
static picDEM

// ------------------------------------
// otvori tabele
// ------------------------------------
static function _o_tables()
O_KONTO
O_PARTN
return


// -----------------------------------------------------------------------
// vraca uslove generisanja kompenzacije
// -----------------------------------------------------------------------
static function _get_vars( vars )
local _id_firma := gFirma
local _dat_od := CTOD("")
local _dat_do := CTOD("")
local _usl_kto := PADR("", 7)
local _usl_kto2 := PADR("", 7)
local _usl_partn := PADR("", 6)
local _sa_datumom := "D"
local _po_vezi := "D"
local _prelom := "N"
local _x := 1
local _ret := .t.

// citaj parametre
_usl_kto := fetch_metric("fin_komen_konto", my_user(), _usl_kto )
_usl_kto2 := fetch_metric("fin_komen_konto_2", my_user(), _usl_kto2 )
_usl_partn := fetch_metric("fin_komen_partn", my_user(), _usl_partn )
_dat_od := fetch_metric("fin_komen_datum_od", my_user(), _dat_od )
_dat_do := fetch_metric("fin_komen_datum_do", my_user(), _dat_do )
_po_vezi := fetch_metric("fin_komen_po_vezi", my_user(), _po_vezi )
_prelom := fetch_metric("fin_komen_prelomljeno", my_user(), _prelom )
_sa_datumom := fetch_metric("fin_komen_br_racuna_sa_datumom", my_user(), _sa_datumom )

Box( "", 18, 65 )

    set cursor on
        
    @ m_x + _x, m_y + 2 SAY 'KREIRANJE OBRASCA "IZJAVA O KOMPENZACIJI"'

    _x := _x + 4

    do while .t.

        if gNW=="D"
            @ m_x + _x, m_y + 2 SAY "Firma "
            ?? gFirma, "-", PADR( gNFirma, 30 )
        else
            @ m_x + _x, m_y + 2 SAY "Firma: " GET _id_firma valid {|| P_Firma(@_id_firma),_id_firma:=left(_id_firma,2),.t.}
        endif

        ++ _x
        @ m_x + _x, m_y + 2 SAY "Konto duguje   " GET _usl_kto  valid P_KontoFin(@_usl_kto)
        ++ _x
        @ m_x + _x, m_y + 2 SAY "Konto potrazuje" GET _usl_kto2  valid P_KontoFin(@_usl_kto2) .and. _usl_kto2 > _usl_kto
        ++ _x
        @ m_x + _x, m_y + 2 SAY "Partner-duznik " GET _usl_partn valid P_Firma(@_usl_partn)  pict "@!"
        ++ _x
        @ m_x + _x, m_y + 2 SAY "Datum dokumenta od:" GET _dat_od
        @ m_x + _x, col() + 2 SAY "do" GET _dat_do   valid _dat_od <= _dat_do

        ++ _x
        ++ _x
        
        @ m_x + _x, m_y + 2 SAY "Sabrati po brojevima veze D/N ?"  GET _po_vezi valid _po_vezi $ "DN" pict "@!"
        @ m_x + _x, col() + 2 SAY "Prikaz prebijenog stanja " GET _prelom valid _prelom $ "DN" pict "@!"

        ++ _x

        @ m_x + _x, m_y + 2 SAY "Prikaz datuma sa brojem racuna (D/N) ?"  GET _sa_datumom valid _sa_datumom $ "DN" pict "@!"

        read
        ESC_BCR

        exit

    enddo

BoxC()

if LastKey() == K_ESC
    _ret := .f.
    return _ret
endif

// snimi parametre
set_metric("fin_komen_konto", my_user(), _usl_kto )
set_metric("fin_komen_konto_2", my_user(), _usl_kto2 )
set_metric("fin_komen_partn", my_user(), _usl_partn )
set_metric("fin_komen_datum_od", my_user(), _dat_od )
set_metric("fin_komen_datum_do", my_user(), _dat_do )
set_metric("fin_komen_po_vezi", my_user(), _po_vezi )
set_metric("fin_komen_prelomljeno", my_user(), _prelom )
set_metric("fin_komen_br_racuna_sa_datumom", my_user(), _sa_datumom )

vars["konto"] := _usl_kto
vars["konto2"] := _usl_kto2
vars["partn"] := _usl_partn
vars["dat_od"] := _dat_od
vars["dat_do"] := _dat_do
vars["po_vezi"] := _po_vezi
vars["prelom"] := _prelom
vars["firma"] := _id_firma
vars["sa_datumom"] := _sa_datumom

return _ret


// ---------------------------------------------------------
// kreiranje tmp tabela
// ---------------------------------------------------------
static function _cre_tmp_tables( force )
local _dbf
local _tmp1, _tmp2

// struktura tabele
_dbf := {}
AADD( _dbf , { "BRDOK"    , "C" , 50 , 0 } )
AADD( _dbf , { "IZNOSBHD" , "N" , 17 , 2 } )
AADD( _dbf , { "MARKER"   , "C" ,  1 , 0 } )
 
_tmp1 := my_home() + "temp12.dbf"
_tmp2 := my_home() + "temp60.dbf"

if force .or. !FILE( _tmp1 )
    DbCreate( _tmp1, _dbf )
ENDIF

if force .or. !FILE( _tmp2 )
    DbCreate( _tmp2, _dbf )
ENDIF

// otvori tabele
select ( F_TMP_1 )
if used()
    use
endif
my_use_temp( "TEMP12", _tmp1, .f., .t. )

select ( F_TMP_2 )
if used()
    use
endif
my_use_temp( "TEMP60", _tmp2, .f., .t. )

return



// ---------------------------------------------------------------
// komenzacije
// ---------------------------------------------------------------
function kompenzacija()
local _is_gen := .f.
local _vars := hb_hash()
local _i, _n
local _row := MAXROWS() - 10
local _col := MAXCOLS() - 6
local _usl_kto, _usl_kto2

picBHD := FormPicL(gPicBHD,16)
picDEM := FormPicL(gPicDEM,12)

// otvori tabele
_o_tables()

// inicijalizuj hash matricu
_vars["konto"] := ""
_vars["konto2"] := ""
_vars["partn"] := ""
_vars["dat_od"] := DATE()
_vars["dat_do"] := DATE()
_vars["po_vezi"] := "D"
_vars["prelom"] := "N"
_vars["firma"] := gFirma

if Pitanje(, "Izgenerisati stavke za kompenzaciju?", "N" ) == "D"

    _is_gen := .t.
    
    // daj mi parametre...
    if !_get_vars( @_vars )
        return    
    endif

    _usl_kto := _vars["konto"]
    _usl_kto2 := _vars["konto2"]

else

    _usl_kto := PADR( "", 7 )
    _usl_kto2 := _usl_kto

endif

// kreiraj temp tabele za kompenzacije
_cre_tmp_tables( _is_gen )

// generisi stavke za kompenzaciju
if _is_gen 
    _gen_kompen( _vars )
endif

// browsanje
ImeKol := { ;
            {"Br.racuna", {|| PADR( brdok, 10 )    }, "brdok"    } ,;
            {"Iznos",     {|| iznosbhd }, "iznosbhd" } ,;
            {"Marker",    {|| marker }, "marker" } ;
          }

Kol := {}
for _i := 1 to LEN( ImeKol )
    AADD( Kol, _i )  
next

Box(, _row, _col )

    @ m_x, m_y + 30 SAY ' KREIRANJE OBRASCA "IZJAVA O KOMPENZACIJI" '

    @ m_x + _row - 4, m_y + 1 SAY REPLICATE( "=", _col )
    @ m_x + _row - 3, m_y + 1 SAY "  <K> izaberi/ukini racun za kompenzaciju"
    @ m_x + _row - 2, m_y + 1 SAY "<c+P> stampanje kompenzacije                  <T> promijeni tabelu"
    @ m_x + _row - 1, m_y + 1 SAY "<c+N> nova stavka                           <c+T> brisanje                 <ENTER> ispravka stavke "

    for _n := 1 to ( _row - 4 )
        @ m_x + _n, m_y + ( _col / 2 ) SAY "|"
    next

    select temp60
    go top
    select temp12
    go top

    m_y += ( _col / 2 ) + 1

    do while .t.

        if ALIAS() == "TEMP12"
            m_y -= ( _col / 2 ) + 1
        elseif ALIAS() == "TEMP60"
            m_y += ( _col / 2 ) + 1
        endif

        ObjDbedit( "komp1", _row - 7, ( _col / 2 ) - 1 , {|| key_handler( _vars ) }, "", if( ALIAS() == "TEMP12", "DUGUJE " + _usl_kto, "POTRAZUJE " + _usl_kto2 ), , , , ,1)

        if LASTKEY() == K_ESC
            exit
        endif

    enddo

BoxC()

my_close_all_dbf()
return



// ----------------------------------------------------------------
// izgenerisi stavke za kompenzaciju
// ----------------------------------------------------------------
static function _gen_kompen( vars )
local _usl_kto := vars["konto"]
local _usl_kto2 := vars["konto2"]
local _usl_partn := vars["partn"]
local _dat_od := vars["dat_od"]
local _dat_do := vars["dat_do"]
local _po_vezi := vars["po_vezi"]
local _sa_datumom := vars["sa_datumom"]
local _prelom := vars["prelom"]
local _id_firma := vars["firma"]
local _filter, __opis_br_dok
local _id_konto, _id_partner, _prolaz, _prosao
local _otv_st, _t_id_konto
local _br_dok
local _d_bhd, _p_bhd, _d_dem, _p_dem
local _pr_d_bhd, _pr_p_bhd, _pr_d_dem, _pr_p_dem
local _dug_bhd, _pot_bhd, _dug_dem, _pot_dem
local _kon_d, _kon_p, _kon_d2, _kon_p2 
local _svi_d, _svi_p, _svi_d2, _svi_p2 

O_SUBAN
O_TDOK

select SUBAN
    
if _po_vezi == "D"
    set order to tag "3"
endif

// postavi filter
_filter := ".t." 

if !EMPTY( _dat_od )
    _filter += " .and. DATDOK >= " + cm2str( _dat_od )
endif

if !EMPTY( _dat_do )
    _filter += " .and. DATDOK <= " + cm2str( _dat_do )
endif    

msgo( "setujem filter... " )
if _filter == ".t."
    set filter to
else
    set filter to &(_filter)
endif
msgc()

seek _id_firma + _usl_kto + _usl_partn 
   
// pretrazi na drugom kontu 
if !FOUND() 
    seek _id_firma + _usl_kto2 + _usl_partn 
endif

NFOUND CRET

_svi_d := 0
_svi_p := 0
_svi_d2 := 0
_svi_p2 := 0
_kon_d := 0
_kon_p := 0
_kon_d2 := 0
_kon_p2 := 0

_id_konto := field->idkonto

_prolaz := 0
if EMPTY( _usl_partn )  
    // prodji tri puta
    _prolaz := 1
    HSEEK _id_firma + _usl_kto 
    if EOF()
        _prolaz := 2
        HSEEK _id_firma + _usl_kto2 
    endif
endif

Box(, 2, 50 )

_cnt := 0

do while .t.

    if !EOF() .and. field->idfirma == _id_firma .and. ;
            ( ( _prolaz == 0 .and. ( field->idkonto == _usl_kto .or. field->idkonto == _usl_kto2 ) ) .or. ;
            ( _prolaz == 1 .and. field->idkonto = _usl_kto ) .or. ;
            ( _prolaz == 2 .and. field->idkonto = _usl_kto2 ) )
    else
        exit
    endif

    _d_bhd := 0
    _p_bhd := 0
    _d_dem := 0
    _p_dem := 0          
    _pr_d_bhd := 0
    _pr_p_bhd := 0
    _pr_d_dem := 0
    _pr_p_dem := 0          
    _dug_bhd := 0
    _pot_bhd := 0
    _dug_dem := 0
    _pot_dem := 0          

    _id_partner := field->idpartner
    _prosao := .f.
        
    do while !EOF() .and. field->IdFirma == _id_firma .and. field->idpartner == _id_partner ;
                        .and. ( field->idkonto == _usl_kto .or. field->idkonto == _usl_kto2 )

        _id_konto := field->idkonto
        _otv_st := field->otvst

        if !( _otv_st == "9" )

            _prosao := .t.

            select suban
            if _id_konto == _usl_kto 
                select TEMP12
            else
                select TEMP60
            endif
              
            append blank

            __opis_br_dok := ALLTRIM( suban->brdok )
            
            if EMPTY( __opis_br_dok )
                __opis_br_dok := "??????"
            endif

            if _sa_datumom == "D"
                __opis_br_dok += " od " + DTOC( suban->datdok )
            endif

            replace field->brdok with __opis_br_dok

            _t_id_konto := _id_konto 
            select suban

        endif 

        @ m_x + 1, m_y + 2 SAY "konto: " + PADR( _id_konto, 7 ) + " partner: " + _id_partner

        _d_bhd := 0
        _p_bhd := 0
        _d_dem := 0
        _p_dem := 0          

        if _po_vezi == "D"

            _br_dok := field->brdok

            do while !EOF() .and. field->IdFirma == _id_firma .and. field->idpartner == _id_partner ;
                                .and. ( field->idkonto == _usl_kto .or. field->idkonto == _usl_kto2 ) .and. field->brdok == _br_dok
                if field->d_p == "1"
                    _d_bhd += field->iznosbhd
                    _d_dem += field->iznosdem
                else
                    _p_bhd += field->iznosbhd
                    _p_dem += field->iznosdem
                endif

                skip

            enddo

            if _prelom == "D"
                Prelomi( @_d_bhd, @_p_bhd )
                Prelomi( @_d_dem, @_p_dem )
            endif
        
        else

             if field->d_p == "1"
                _d_bhd += field->iznosbhd
                _d_dem += field->iznosdem
             else
                _p_bhd += field->iznosbhd
                _p_dem += field->iznosdem
             endif

        endif
           
        @ m_x + 2, m_y + 2 SAY "cnt:" + ALLTRIM( STR( ++ _cnt ) ) + " suban cnt: " + ALLTRIM( STR( RECNO() ) )
        
        if _otv_st == "9"
             _dug_bhd += _d_bhd
             _pot_bhd += _p_bhd
        else 
             
            // otvorena stavka
            if _t_id_konto == _usl_kto 
                select TEMP12
                if _d_bhd > 0
                    replace field->iznosbhd with _d_bhd
                    if _p_bhd > 0
                        _rec := dbf_get_rec()
                        append blank
                        dbf_update_rec( _rec )
                        replace field->iznosbhd with -_p_bhd
                    endif
                else
                    replace field->iznosbhd with -_p_bhd
                endif
            else
               
                select TEMP60
                if _p_bhd > 0
                    replace field->iznosbhd with _p_bhd
                    if _d_bhd > 0
                        _rec := dbf_get_rec()
                        append blank
                        dbf_update_rec( _rec )
                        replace field->iznosbhd with -_d_bhd
                    endif
                else
                    replace field->iznosbhd with -_d_bhd
                endif
            endif
    
            SELECT SUBAN
           
            _dug_bhd += _d_bhd
            _pot_bhd += _p_bhd 
           
        endif

        if _po_vezi <> "D"
            skip
        endif
          
        if _prolaz == 0 .or. _prolaz == 1
            if ( field->idkonto <> _id_konto .or. field->idpartner <> _id_partner ) .and. _id_konto == _usl_kto
                hseek _id_firma + _usl_kto2 + _id_partner 
            endif
        endif

    enddo 

    _kon_d += _dug_bhd
    _kon_p += _pot_bhd
    _kon_d2 += _dug_dem
    _kon_p2 += _pot_dem

    if _prolaz == 0
        exit
    elseif _prolaz == 1
        seek _id_firma + _usl_kto + _id_partner + CHR(255)
        if _usl_kto <> field->idkonto 
            // nema vise
            _prolaz := 2
            seek _id_firma + _usl_kto2 
            _id_partner := REPLICATE( "", LEN( field->idpartner ) )
            if !found()
                exit
            endif
        endif
    endif

    if nprolaz==2
        do while .t.
            seek _id_firma + _usl_kto2 + _id_partner + CHR(255)
            _t_rec := RECNO()
            if field->idkonto == _usl_kto2
                _id_partner := field->idpartner
                hseek _id_firma + _usl_kto + _id_partner
                if !found() 
                    // ove kartice nije bilo
                    go ( _t_rec )
                    exit
                else
                    loop  
                    // vrati se traziti
                endif
            endif
            exit
        enddo
    endif

enddo

BoxC()

return


// ---------------------------------------------------------------
// obrada dogadjaja tastature
// ---------------------------------------------------------------
static function key_handler( vars )
local nTr2
local GetList:={}
local nRec:=RECNO()
local nX:=m_x
local nY:=m_y
local nVrati:=DE_CONT

if ! ( (Ch==K_CTRL_T .or. Ch==K_ENTER) .and. reccount2()==0 )
    
    do case

        case Ch == ASC("K") .or. Ch==ASC("k")    

            replace field->marker with if( field->marker == "K" , " " , "K" )
            nVrati := DE_REFRESH

        case Ch == K_CTRL_P   
            print_kompen( vars )
            nVrati := DE_CONT

        case Ch == K_CTRL_N 
            
            GO BOTTOM
            SKIP 1
            Scatter()
            Box(, 5, 70)
                @ m_x+2, m_y+2 SAY "Br.racuna " GET _brdok
                @ m_x+3, m_y+2 SAY "Iznos     " GET _iznosbhd
                READ
            BoxC()
            IF LASTKEY() == K_ESC
                GO (nRec)
            ELSE
                APPEND BLANK
                Gather()
                nVrati := DE_REFRESH
            ENDIF

        case Ch==K_CTRL_T                
           
            nVrati := browse_brisi_stavku() 
         
        case Ch == K_ENTER                        
            
            Scatter()

            Box(,5,70)
                @ m_x+2, m_y+2 SAY "Br.racuna " GET _brdok
                @ m_x+3, m_y+2 SAY "Iznos     " GET _iznosbhd
                READ
            BoxC()

            IF LASTKEY() == K_ESC
                GO (nRec)
            ELSE
                my_rlock()
                Gather()
                my_unlock()
                nVrati := DE_REFRESH
            ENDIF

        case Ch == ASC("T") .or. Ch == ASC("t")      

            // prebacivanje na drugu tabelu
            IF ALIAS()=="TEMP12"
                SELECT TEMP60
                GO TOP
            ELSEIF ALIAS()=="TEMP60"
                SELECT TEMP12
                GO TOP
            ENDIF

            nVrati := DE_ABORT

    endcase

endif

m_x := nX
m_y := nY

return nVrati


// stampa kompenzacije
static function print_kompen( vars )
local _id_pov := SPACE(6)
local _id_partn := SPACE(6)
local _br_komp := SPACE(10)
local _x := 1
local _dat_komp := DATE()
local _rok_pl := 7
local _valuta := "D"
local _saldo
local _ret := .t.
local _filter := "komp*.odt"
local _template := ""
local _templates_path := F18_TEMPLATE_LOCATION
local _xml_file := my_home() + "data.xml"

// uzmi partnera 
if !EMPTY( vars["partn"] )
    _id_partn := vars["partn"]
endif

_id_pov := fetch_metric("fin_kompen_id_povjerioca", my_home(), _id_pov )
_br_komp := fetch_metric("fin_kompen_broj", my_home(), _br_komp )
_rok_pl := fetch_metric("fin_kompen_rok_placanja", my_home(), _rok_pl )
_valuta := fetch_metric("fin_kompen_valuta", my_home(), _valuta )

Box(, 10, 50 )
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Datum kompenzacije: " GET _dat_komp
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Rok placanja (dana): " GET _rok_pl VALID _rok_pl >= 0 PICT "999"
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Valuta kompenzacije (D/P): " GET _valuta  valid _valuta $ "DP"  pict "!@"
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Broj kompenzacije: " GET _br_komp
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Sifra (ID) povjerioca: " GET _id_pov VALID P_Firma(@_id_pov) PICT "@!"
    ++ _x
    @ m_x + _x, m_y + 2 SAY "   Sifra (ID) duznika: " GET _id_partn VALID P_Firma(@_id_partn) PICT "@!"
    READ
BoxC()

if LastKey() == K_ESC
    _ret := .f.
    return _ret
endif

// snimi parametre
set_metric("fin_kompen_id_povjerioca", my_home(), _id_pov )
set_metric("fin_kompen_broj", my_home(), _br_komp )
set_metric("fin_kompen_rok_placanja", my_home(), _rok_pl )
set_metric("fin_kompen_valuta", my_home(), _valuta )

// dodaj u vars hash matricu jos stavki
vars["id_pov"] := _id_pov
vars["komp_broj"] := _br_komp
vars["rok_pl"] := _rok_pl
vars["valuta"] := _valuta
vars["datum"] := _dat_komp

// ako nema partnera u matrici, setuj ga !
if EMPTY( vars["partn"] )
    vars["partn"] := _id_partn
endif

// generisi xml fajl
if !_gen_xml( vars, _xml_file )
    _ret := .f.
    return _ret
endif

// generisi report i prikazi kompenzaciju
// -------------------
// daj mi listu template-a
if get_file_list_array( _templates_path, _filter, @_template, .t. ) == 0
    return
endif

// generisi i prikazi report
if f18_odt_generate( _template, _xml_file )
    f18_odt_print()
endif
     
return _ret


// --------------------------------------------------
// generise xml fajl kompenzacije
// --------------------------------------------------
static function _gen_xml( vars, xml_file )
local _ret := .t.
local _id_pov, _br_komp, _rok_pl, _valuta
local _dat_od, _dat_do, _partner
local _temp_duz := .t.
local _temp_pov := .t.
local _br_st := 0
local _ukupno_duz := 0
local _ukupno_pov := 0
local _broj_dok_duz, _broj_dok_pov
local _iznos_duz, _iznos_pov
local _dat_komp

_id_pov := vars["id_pov"]
_br_komp := vars["komp_broj"]
_rok_pl := vars["rok_pl"]
_valuta := vars["valuta"]
_partner := vars["partn"]
_dat_od := vars["dat_od"]
_dat_do := vars["dat_do"]
_dat_komp := vars["datum"]

// generisanje xml fajla
// --------------------------------------------
open_xml( xml_file )

xml_head()

xml_subnode("kompen", .f.)

// povjerioc
// ---------------------------------------------
if !_fill_partn( _id_pov, "pov" )
    return .f.
endif

// duznik
// ---------------------------------------------
if !_fill_partn( _partner, "duz" )
    return .f.
endif

select temp12
go top
select temp60
go top

_skip_t_marker( @_temp_duz, @_temp_pov )

xml_subnode("tabela", .f.)

select temp60

do while _temp_duz .or. _temp_pov

    ++ _br_st 

    xml_subnode( "item", .f. )
    
    _broj_stavke := ALLTRIM( STR( _br_st ) )
         
    _iznos_pov := 0
    _iznos_duz := 0

    _broj_dok_duz := ""
    _broj_dok_pov := ""
    
    if _temp_pov
        _broj_dok_pov := ALLTRIM( field->brdok )
        _iznos_pov := field->iznosbhd
    endif
    
    xml_node("rbr", _broj_stavke )
    xml_node("dok_pov", to_xml_encoding( _broj_dok_pov ) )
    xml_node("izn_pov", ALLTRIM( STR( _iznos_pov, 17, 2 ) ) )

    select temp12

    if _temp_duz
        _broj_dok_duz := ALLTRIM( field->brdok )
        _iznos_duz := field->iznosbhd
    endif

    xml_node("dok_duz", to_xml_encoding( _broj_dok_duz  ) )
    xml_node("izn_duz", ALLTRIM( STR( _iznos_duz, 17, 2 ) ) )

    xml_subnode( "item", .t. )

    // totali
    _ukupno_duz += _iznos_duz
    _ukupno_pov += _iznos_pov

    skip 1
    
    select temp60
    skip 1

    _skip_t_marker( @_temp_duz, @_temp_pov )

enddo
 
xml_subnode("tabela", .t.)

// ispisi jos totale i ostale podatke
// ---------------------------------------------------------------------
// totali
xml_node("total_duz", ALLTRIM( STR( _ukupno_duz, 17, 2 ) ) )
xml_node("total_pov", ALLTRIM( STR( _ukupno_pov, 17, 2 ) ) )
xml_node("total_komp", ALLTRIM( STR( MIN( ABS( _ukupno_duz ), ABS( _ukupno_pov ) ), 17, 2 ) ) )
xml_node("saldo", ALLTRIM( STR( ABS( _ukupno_duz - _ukupno_pov ), 17, 2 ) ) )

// generalni podaci kompenzacije
xml_node("broj", to_xml_encoding( ALLTRIM( _br_komp ) ) )
xml_node("rok_pl", to_xml_encoding( ALLTRIM( STR( _rok_pl ) ) ) )
xml_node("valuta", ALLTRIM( _valuta ) )
xml_node("per_od", DTOC( _dat_od ) )
xml_node("per_do", DTOC( _dat_do ) )
xml_node("datum", DTOC( _dat_komp ) )

xml_subnode( "kompen", .t. )

close_xml()

return _ret


// -------------------------------------------------------
// filuje partnera u xml fajl
// -------------------------------------------------------
static function _fill_partn( part_id, node_name )
local _ret := .t.

if node_name == NIL
    node_name := "pov"
endif

select partn
go top
hseek part_id

if !FOUND()
    MsgBeep( "Partner " + part_id + " ne postoji u sifrarniku !")
    return .f.
endif

xml_subnode( node_name, .f. )

    // podaci povjerioca
    // 
    // <pov>
    //   <id>-</id>
    //   <....
    // </pov>

    xml_node("id", to_xml_encoding( ALLTRIM( field->id ) ) )
    xml_node("naz", to_xml_encoding( ALLTRIM( field->naz ) ) )
    xml_node("naz2", to_xml_encoding( ALLTRIM( field->naz2 ) ) )
    xml_node("mjesto", to_xml_encoding( ALLTRIM( field->mjesto ) ) )
    xml_node("d_ziror", to_xml_encoding( ALLTRIM( field->ziror ) ) )
    xml_node("s_ziror", to_xml_encoding( ALLTRIM( field->dziror ) ) )
    xml_node("tel", ALLTRIM( field->telefon ) )
    xml_node("fax", ALLTRIM( field->fax ) )
    xml_node("adr", to_xml_encoding ( ALLTRIM( field->adresa ) ) )
    xml_node("ptt", ALLTRIM( field->ptt ) )

    // iz sifk nesto ...
    xml_node("id_broj", ALLTRIM( IzsifkPartn( "REGB", part_id, .f. ) ) ) 
    xml_node("por_broj", ALLTRIM( IzsifkPartn( "PORB", part_id, .f. ) ) ) 
  
xml_subnode( node_name, .t. )

return _ret


// --------------------------------------
// preskakanje markera
// --------------------------------------
static function _skip_t_marker( _mark_12, _mark_60 )
local _t_arr := SELECT()

select temp12
do while field->marker != "K" .and. !EOF()
    skip 1
enddo
if EOF()
    _mark_12 := .f.
endif

select temp60
do while field->marker != "K" .and. !EOF()
    skip 1
enddo
if EOF()
    _mark_60 := .f.
endif

select ( _t_arr )

return nil



