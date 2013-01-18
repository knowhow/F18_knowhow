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


#include "fakt.ch"

// staticke varijable
static __generisati := .f.



function GDokInv(cIdRj)
local cIdRoba
local cBrDok
local nUl
local nIzl
local nRezerv
local nRevers
local nRbr
local lFoundUPripremi

O_FAKT_DOKS
O_ROBA
O_TARIFA
O_FAKT_PRIPR
SET ORDER TO TAG "3"

O_FAKT
MsgO("scaniram tabelu fakt")
nRbr:=0

GO TOP
cBrDok := PADR( REPLICATE( "0", gNumDio ), 8 )

do while !EOF()
    if (field->idFirma<>cIdRj)
        SKIP
        loop
    endif
    select fakt_pripr
    cIdRoba:=fakt->idRoba
    // vidi imali ovo u pripremi; ako ima stavka je obradjena
    SEEK cIdRj+cIdRoba
    lFoundUPripremi:=FOUND()
    SELECT fakt
    PushWa()
    if !(lFoundUPripremi)
        FaStanje(cIdRj, cIdroba, @nUl, @nIzl, @nRezerv, @nRevers, .t.)
        if (nUl-nIzl-nRevers)<>0
            select fakt_pripr
            nRbr++
            ShowKorner(nRbr, 10)
            cRbr:=RedniBroj(nRbr)
            ApndInvItem(cIdRj, cIdRoba, cBrDok, nUl-nIzl-nRevers, cRbr)
        endif
    endif
    PopWa()
    SKIP
enddo
MsgC()

CLOSE ALL
return




static function ApndInvItem(cIdRj, cIdRoba, cBrDok, nKolicina, cRbr)
APPEND BLANK
REPLACE idFirma WITH cIdRj
REPLACE idRoba  WITH cIdRoba
REPLACE datDok  WITH DATE()
REPLACE idTipDok WITH "IM"
REPLACE serBr   WITH STR(nKolicina, 15, 4)
REPLACE kolicina WITH nKolicina
REPLACE rBr WITH cRbr

if VAL(cRbr)==1
    cTxt:=""
    AddTxt(@cTxt, "")
    AddTxt(@cTxt, "")
    AddTxt(@cTxt, gNFirma)
    AddTxt(@cTxt, "RJ:"+cIdRj)
    AddTxt(@cTxt, gMjStr)
    REPLACE txt WITH cTxt
endif

REPLACE brDok WITH cBrDok
REPLACE dinDem WITH ValDomaca()

SELECT roba
SEEK cIdRoba

select fakt_pripr
REPLACE cijena WITH roba->vpc

return


static function AddTxt(cTxt, cStr)
cTxt:=cTxt+Chr(16)+cStr+Chr(17)
return nil





/*! \fn GDokInvManjak(cIdRj, cBrDok)
 *  \param cIdRj - oznaka firme dokumenta IM na osnovu kojeg se generise dok.19
 *  \param cBrDok - broj dokumenta IM na osnovu kojeg se generise dok.19
 *  \brief Generacija dokumenta 19 tj. otpreme iz mag na osnovu dok. IM
 */
function GDokInvManjak(cIdRj, cBrDok)
local nRBr
local nRazlikaKol
local cRBr
local cNoviBrDok

nRBr := 0

O_FAKT
O_FAKT_PRIPR
O_ROBA

cNoviBrDok := PADR( REPLICATE("0", gNumDio), 8 )

SELECT fakt
SET ORDER TO TAG "1"
HSEEK cIdRj+"IM"+cBrDok

do while (!eof() .and. cIdRj+"IM"+cBrDok==fakt->(idFirma+idTipDok+brDok))
    nRazlikaKol:=VAL(fakt->serBr)-fakt->kolicina
    if (ROUND(nRazlikaKol,5)>0)
            SELECT roba
        HSEEK fakt->idRoba
        select fakt_pripr
        nRBr++
        cRBr:=RedniBroj(nRBr)
        ApndInvMItem(cIdRj, fakt->idRoba, cNoviBrDok, nRazlikaKol, cRBr)
    endif
    SELECT fakt
    skip 1
enddo

if (nRBr>0)
    MsgBeep("U pripremu je izgenerisan dokument otpreme manjka "+cIdRj+"-19-"+cNoviBrDok)
else
    MsgBeep("Inventurom nije evidentiran manjak pa nije generisan nikakav dokument!")
endif

CLOSE ALL

return




/*! \fn ApndInvMItem(cIdRj, cIdRoba, cBrDok, nKolicina, cRbr)
 *  \param cIdRj - oznaka firme dokumenta
 *  \param cIdRoba - sifra robe
 *  \param cBrDok - broj dokumenta
 *  \param nKolicina - kolicina tj.manjak
 *  \param cRbr - redni broj stavke
 *  \brief Dodavanje stavke dokumenta 19 za evidentiranje manjka po osnovu inventure
 */
 
static function ApndInvMItem(cIdRj, cIdRoba, cBrDok, nKolicina, cRbr)
APPEND BLANK
REPLACE idFirma WITH cIdRj
REPLACE idRoba  WITH cIdRoba
REPLACE datDok  WITH DATE()
REPLACE idTipDok WITH "19"
REPLACE serBr   WITH ""
REPLACE kolicina WITH nKolicina
REPLACE rBr WITH cRbr

if (VAL(cRbr)==1)
    cTxt:=""
    AddTxt(@cTxt, "")
    AddTxt(@cTxt, "")
    AddTxt(@cTxt, gNFirma)
    AddTxt(@cTxt, "RJ:"+cIdRj)
    AddTxt(@cTxt, gMjStr)
    REPLACE txt WITH cTxt
endif

REPLACE brDok WITH cBrDok
REPLACE dinDem WITH ValDomaca()
REPLACE cijena WITH roba->vpc
return





/*! \fn GDokInvVisak(cIdRj, cBrDok)
 *  \param cIdRj - oznaka firme dokumenta IM na osnovu kojeg se generise dok.19
 *  \param cBrDok - broj dokumenta IM na osnovu kojeg se generise dok.19
 *  \brief Generacija dokumenta 01 tj.primke u magacin na osnovu dok. IM
 */
function GDokInvVisak(cIdRj, cBrDok)
local nRBr
local nRazlikaKol
local cRBr
local cNoviBrDok

nRBr := 0

O_FAKT
O_FAKT_PRIPR
O_ROBA

cNoviBrDok := PADR( REPLICATE( "0", gNumDio ), 8 )

SELECT fakt
SET ORDER TO TAG "1"
HSEEK cIdRj+"IM"+cBrDok
do while (!eof() .and. cIdRj+"IM"+cBrDok==fakt->(idFirma+idTipDok+brDok))
    nRazlikaKol:=VAL(fakt->serBr)-fakt->kolicina
    if (ROUND(nRazlikaKol,5)<0)
            SELECT roba
        HSEEK fakt->idRoba
        select fakt_pripr
        nRBr++
        cRBr:=RedniBroj(nRBr)
        ApndInvVItem(cIdRj, fakt->idRoba, cNoviBrDok, -nRazlikaKol, cRBr)
    endif
    SELECT fakt
    skip 1
enddo

if (nRBr>0)
    MsgBeep("U pripremu je izgenerisan dokument dopreme viska "+cIdRj+"-01-"+cNoviBrDok)
else
    MsgBeep("Inventurom nije evidentiran visak pa nije generisan nikakav dokument!")
endif

CLOSE ALL
return





/*! \fn ApndInvVItem(cIdRj, cIdRoba, cBrDok, nKolicina, cRbr)
 *  \param cIdRj - oznaka firme dokumenta
 *  \param cIdRoba - sifra robe
 *  \param cBrDok - broj dokumenta
 *  \param nKolicina - kolicina tj.visak
 *  \param cRbr - redni broj stavke
 *  \brief Dodavanje stavke dokumenta 01 za evidentiranje viska po osnovu inventure
 */

static function ApndInvVItem(cIdRj, cIdRoba, cBrDok, nKolicina, cRbr)
APPEND BLANK
REPLACE idFirma WITH cIdRj
REPLACE idRoba  WITH cIdRoba
REPLACE datDok  WITH DATE()
REPLACE idTipDok WITH "01"
REPLACE serBr   WITH ""
REPLACE kolicina WITH nKolicina
REPLACE rBr WITH cRbr

if (VAL(cRbr)==1)
    cTxt:=""
    AddTxt(@cTxt, "")
    AddTxt(@cTxt, "")
    AddTxt(@cTxt, gNFirma)
    AddTxt(@cTxt, "RJ:"+cIdRj)
    AddTxt(@cTxt, gMjStr)
    REPLACE txt WITH cTxt
endif

REPLACE brDok WITH cBrDok
REPLACE dinDem WITH ValDomaca()
REPLACE cijena WITH roba->vpc
return





// ----------------------------------------------
// pretvaranje otpremnice u fakturu
// ----------------------------------------------
function fakt_generisi_racun_iz_otpremnice()
local _id_partner
local _suma := 0
local _veza_otpr := ""
local _datum_max := DATE()
local _ok
local _lock_user := ""
local _lock_param := "fakt_otpremnice_lock_user"

select fakt_pripr
use

O_FAKT_PRIPR
go top

// ako je priprema prazna
if RecCount2() <> 0
    _generisi_racun_iz_pripreme()
    select fakt_pripr
    return .t.
endif

// mogu li koristiti opciju ?
// radi problema u mrežnom radu... #29996 problem
_lock_user := ALLTRIM( fetch_metric( _lock_param, NIL, "" ) )

if !EMPTY( _lock_user )
    MsgBeep( "Opciju pretvaranja koristi (" + _lock_user + "), pokusajte ponovo !!!" )
    select fakt_pripr
    return .t.
endif

// setuj parametar da se opcija koristi
set_metric( _lock_param, NIL, f18_user() )

select fakt_doks
set order to tag "2"  
// idfirma+idtipdok+partner

ImeKol := {}
// browsuj tip dokumenta
AADD( ImeKol, { "TD",     {|| idtipdok }   })
AADD( ImeKol, { "Broj",   {|| brdok }  })
AADD( ImeKol, { "Datdok",  {|| datdok  }  })
AADD( ImeKol, { "Partner", {|| LEFT( partner, 20 )}  })
AADD( ImeKol, { "Iznos",   {|| STR( iznos, 11, 2 )}  })
AADD( ImeKol, { "Marker",  {|| m1 }  })
   
Kol:={}
   
for i := 1 to LEN( ImeKol )
    AADD( Kol, i )
next

_otpr_tip := "12"
_firma := gFirma
_suma := 0
_partn_naz := SPACE(20)
   
Box(, 20, 75 )

    @ m_x + 1, m_y + 2 SAY "PREGLED OTPREMNICA:"
    @ m_x + 3, m_y + 2 SAY "Radna jedinica" GET  _firma pict "@!"
    @ m_x + 3, col() + 2 SAY "Naziv partnera - kljucni dio:" GET _partn_naz pict "@!"

    read

    _partn_naz := TRIM( _partn_naz )

    seek _firma + _otpr_tip

    if !f18_lock_tables( {"fakt_doks"}, .f. )

        // ukini lock opcije
        set_metric( _lock_param, NIL, "" )
        
        close all
        o_fakt_edit()
        select fakt_pripr
        BoxC()

        MsgBeep( "Neuspjesno lokovanje tabele !!!" )

        return .t.

    endif

    sql_table_update( nil, "BEGIN" )
    
    do while !EOF() .and. field->idfirma + field->idtipdok = _firma + _otpr_tip
        if field->m1 <> "Z"

            _rec := dbf_get_rec()
            _rec["m1"] := " "

            if !update_rec_server_and_dbf( "fakt_doks", _rec, 1, "CONT" )
                
                f18_free_tables( { "fakt_doks" } )
                sql_table_update( nil, "ROLLBACK" )
                
                set_metric( _lock_param, NIL, "" )

                close all
                o_fakt_edit()
                select fakt_pripr

                BoxC()    

                MsgBeep( "Ne mogu setovati markere za otpremnice !!!" )

                return .t.

            endif

        endif
        skip

    enddo

    f18_free_tables({ "fakt_doks" })
    sql_table_update( nil, "END" )

    seek _firma + _otpr_tip

    BrowseKey( m_x + 5, m_y + 1, m_x + 19, m_y+ 73, ImeKol, ;
                {|ch| EdOtpr( ch, @_suma) }, "idfirma+idtipdok = _firma + _otpr_tip",;
                _firma + _otpr_tip, 2, , , {|| partner = _partn_naz } )

BoxC()

if __generisati .and. Pitanje(, "Formirati fakturu na osnovu gornjih otpremnica ?", "N" ) == "D"
     
    _ok := _formiraj_racun( _firma, _otpr_tip, _partn_naz, @_veza_otpr, @_datum_max )
 
    // ovdje vec smijem ukinuti lock opciju... racun je formiran i nalazi se u priremi
    set_metric( _lock_param, NIL, "" )
   
    if _ok
        // ovdje ce se setovati jos i parametri dokumenta...
        // datum otpremnice, datum valute... destinacija itd...
        select fakt_pripr
        renumeracija_fakt_pripr( _veza_otpr, _datum_max )
    endif

    select fakt_doks
    set order to tag "1"

else
    // ukini lock opcije
    // korisnik je odabrao da nece koristi opcije pretvaranja
    set_metric( _lock_param, NIL, "" )
endif 

close all
o_fakt_edit()
select fakt_pripr

return .t.




// -----------------------------------------------------------
// generise racun na osnovu podataka iz pripreme
// -----------------------------------------------------------
static function _generisi_racun_iz_pripreme()
local _novi_tip, _tip_dok, _br_dok 
local _t_rec

if !( field->idtipdok $ "12#20#13#01#27" )
	Msg( "Ova opcija je za promjenu 20,12,13 -> 10 i 27 -> 11 ")
    return .f.
endif

if field->idtipdok = "27"
	_novi_tip := "11"
elseif field->idtipdok = "01"
	_novi_tip := "19"
else
    _novi_tip := "10"
endif

if Pitanje(, "Zelite li dokument pretvoriti u " + _novi_tip + " ? (D/N)", "D" ) == "N"
	return .f.
endif
         
Box(, 5, 60 )
            
	_tip_dok := field->idtipdok
    _br_dok := PADR( REPLICATE("0", 5 ), 8 )
            
    select fakt_pripr
	PushWa()

   	go top
    _t_rec := 0
            
	do while !EOF()

    	skip
		_t_rec := RECNO()
		skip -1

       	replace field->brdok with _br_dok
		replace field->idtipdok with _novi_tip
		replace field->datdok with DATE()

      	if _tip_dok == "12"  
			// otpremnica u racun ???
            replace serbr with "*"
      	endif
                
		if _tip_dok == "13"  
        	replace kolicina with -kolicina
        endif
                
		go ( _t_rec )
   	
	enddo
            
	PopWa()
                    
BoxC()

IsprUzorTxt()

return .t.




function EdOtpr( ch, suma )
local cDn := "N"
local nRet := DE_CONT

do case

    case Ch==ASC(" ") .or. Ch==K_ENTER

        if !f18_lock_tables( { "fakt_doks" }, .f. )
            MsgBeep( "Ne mogu postaviti lock, neko drugi koristi opciju..." )
            return DE_CONT
        endif

        sql_table_update( nil, "BEGIN" )

        Beep(1)

        _rec := dbf_get_rec()

        if field->m1 = " "    

            __generisati := .t.
            
            _rec["m1"] := "*"
            
            if !update_rec_server_and_dbf( "fakt_doks", _rec, 1, "CONT" )
                f18_free_tables( { "fakt_doks" } )
                sql_table_update( nil, "ROLLBACK" )
                MsgBeep( "Nisam uspio setovati marker, neko vec koristi opciju..." )
                return DE_CONT
            endif

            suma += field->iznos

        else

            _rec["m1"] := " "

            if !update_rec_server_and_dbf( "fakt_doks", _rec, 1, "CONT" )
                f18_free_tables( { "fakt_doks" } )
                sql_table_update( nil, "ROLLBACK" )
                MsgBeep( "Nisam uspio setovati marker, neko vec koristi opciju..." )
                return DE_CONT
            endif

            suma -= field->iznos

        endif

        @ m_x+1, m_Y + 55 SAY suma pict picdem

        nRet := DE_REFRESH

        f18_free_tables( { "fakt_doks" } )
        sql_table_update( nil, "END" )

endcase

return nRet



// ------------------------------------------------------
// generacija podataka, forma parametara
// ------------------------------------------------------
static function gen_vars( params )
local _ok := .t.
local _sumiraj := "N"
local _tip_rn := 1

params := hb_hash()

Box(, 6, 65 )

    @ m_x + 1, m_y + 2 SAY "Sumirati stavke otpremnica (D/N) ?" GET _sumiraj ;
                    VALID _sumiraj $ "DN" ;
                    PICT "@!"

    @ m_x + 3, m_y + 2 SAY "Formirati tip racuna: 1 (veleprodaja)" 
    @ m_x + 4, m_y + 2 SAY "                      2 (veleprodaja)" GET _tip_rn ;
                    VALID ( _tip_rn > 0 .and. _tip_rn < 3 ) ;
                    PICT "9"

    read

BoxC()

if LastKey() == K_ESC
    _ok := .f.
    return _ok
endif

// snimi mi u matricu parametre
params["tip_racuna"] := _tip_rn
params["sumiraj"] := _sumiraj

return _ok


// --------------------------------------------------------------
// formiranje racuna
// --------------------------------------------------------------
static function _formiraj_racun( firma, otpr_tip, partn_naz, veza_otpr, datum_max )
local _sumirati := .f.
local _vp_mp := 1
local _n_tip_dok, _dat_max, _t_rec, _t_fakt_rec
local _veza_otpremnice, _broj_dokumenta
local _id_partner, _rec
local _ok := .t.
local _gen_params  

_broj_dokumenta := fakt_prazan_broj_dokumenta()

// parametri generisanja...
if !gen_vars( @_gen_params )
    return .f.
endif
         
// uzmi parametre matrice...
_sumirati := _gen_params["sumiraj"] == "D"
_vp_mp := _gen_params["tip_racuna"]

if _vp_mp == 1
    _n_tip_dok := "10"
else
    _n_tip_dok := "11"
endif

_veza_otpremnice := ""
      
select fakt_doks  
seek firma + otpr_tip + partn_naz
      
_dat_max := CTOD("")

if !f18_lock_tables( {"fakt_doks", "fakt_fakt" }, .f. )
    MsgBeep("Neuspjesno lokovanje tabela !!!!")
    return .f.
endif

sql_table_update( nil, "BEGIN" )
      
do while !EOF() .and. field->idfirma + field->idtipdok = firma + otpr_tip ;
               .and. fakt_doks->partner = partn_naz
         
    skip
    _t_rec := RECNO()
    skip -1
         
    if field->m1 = "*"

        _id_partner := fakt_doks->idpartner
        
        if _dat_max < fakt_doks->datdok
            _dat_max := fakt_doks->datdok
        endif
            
        _postojeci_iznos := fakt_doks->iznos               
        _veza_otpremnice += ALLTRIM( fakt_doks->brdok ) + ", "
            
        // promijeni naslov
        // skini zvjezdicu iz browsa
        _rec := dbf_get_rec()

        // postojeci podaci dokumenta
        __post_tip_dok := _rec["idtipdok"]
        __post_id_firma := _rec["idfirma"]
        __post_broj := _rec["brdok"]  
        __novi_broj := __post_broj

        // mjenjamo ih u realizovanu otpremnicu
        _rec["idtipdok"] := "22"
        _rec["m1"] := " "

        // novi tip dokumenta
        __novi_tip_dok := _rec["idtipdok"]

        __t_rec := RECNO()

        _postoji := .t.

        do while _postoji
            // vidi za broj dokumenta da li je ok ?
            if fakt_doks_exist( __post_id_firma, __novi_tip_dok, __novi_broj )
                __novi_broj := fakt_novi_broj_dokumenta( __post_id_firma, __novi_tip_dok, "" )
            else
                _postoji := .f.
                exit
            endif
        enddo

        _rec["brdok"] := __novi_broj

        select fakt_doks
        set order to tag "2"  
        go ( __t_rec )

        if !update_rec_server_and_dbf( "fakt_doks", _rec, 1, "CONT" )
            f18_free_tables({"fakt_doks", "fakt_fakt"})
            sql_table_update( nil, "ROLLBACK" )
            MsgBeep( "Nisam uspio zavrsiti promjenu na tabeli fakt_doks !!!" )
            return .f. 
        endif
        
        // ovo je novi broj dokumenta
        dxIdFirma := fakt_doks->idfirma    
        dxBrDok   := fakt_doks->brdok
            
        select fakt_doks 
        set order to tag "1"
 
        _params := hb_hash()
        _params["old_firma"] := dxIdFirma
        _params["old_tipdok"] := "12"
        _params["old_brdok"] := __post_broj
        _params["new_firma"] := dxIdFirma
        _params["new_tipdok"] := "22"
        _params["new_brdok"] := __novi_broj

        if !update_fakt_atributi_from_server( _params )
            f18_free_tables({"fakt_doks", "fakt_fakt"})
            sql_table_update( nil, "ROLLBACK" )
            MsgBeep( "Nisam uspio napraviti promjene na tabeli fakt_fakt_atributi !!!" )
            return .f. 
        endif

        select fakt
        seek dxIdFirma + "12" + __post_broj
            
        do while !EOF() .and. ( dxIdFirma + "12" + __post_broj ) == ;
                ( field->idfirma + field->idtipdok + field->brdok )
               
            skip
            _t_fakt_rec := recno()
            skip -1
              
            _fakt_rec := dbf_get_rec()
            _fakt_rec["idtipdok"] := "22"
            _fakt_rec["brdok"] := dxBrDok

            if !update_rec_server_and_dbf( "fakt_fakt", _fakt_rec, 1, "CONT" )
                f18_free_tables({"fakt_doks", "fakt_fakt"})
                sql_table_update( nil, "ROLLBACK" )
                MsgBeep( "Nisam uspio zavrsiti promjenu na tabeli fakt_fakt !!!" )
                return .f.
            endif

            _fakt_rec := dbf_get_rec()
            _fakt_rec["brdok"] := _broj_dokumenta
            _fakt_rec["datdok"] := DATE()
            _fakt_rec["m1"] := "X"
            _fakt_rec["idtipdok"] := _n_tip_dok
               
            if _vp_mp == 2
                // radi se o mp racunu, izracunaj cijenu sa pdv
                _fakt_rec["cijena"] := ROUND( _uk_sa_pdv( field->idtipdok, field->idpartner, field->cijena ), 2 )
            endif

            select fakt_pripr
            locate for idroba == fakt->idroba

            if FOUND() .and. _sumirati == .t. .and. ROUND( fakt_pripr->cijena, 2 ) = ROUND( fakt->cijena, 2 )
                _fakt_rec["kolicina"] := fakt_pripr->kolicina + fakt->kolicina
            else
                append blank
            endif
               
            dbf_update_rec( _fakt_rec )

            select fakt

            go ( _t_fakt_rec )
            
        enddo

    endif
        
    select fakt_doks
    set order to tag "2"
        
    go ( _t_rec )

enddo   
    
f18_free_tables({"fakt_doks", "fakt_fakt"})
sql_table_update( nil, "END" )

// obradi i atribute...
//fakt_atributi_server_to_dbf( _params["new_firma"], _params["new_tipdok"], _params["new_brdok"] )

if !EMPTY( _veza_otpremnice )

    _veza_otpremnice := "Racun formiran na osnovu otpremnica: " + ;
                     LEFT ( _veza_otpremnice, LEN ( _veza_otpremnice ) - 2 ) + "."

    veza_otpr := _veza_otpremnice
    datum_max := _dat_max

endif
    
return _ok





function Iz22u10()
local cIdFirma:=gFirma
local cVDok:="22"
local cBrojDokumenta:=SPACE(8)
local cPFirma
local cPVDok
local cPBrDok
local nRbr
local cEditYN:="N"

Box(,5,60)
    @ m_x+1, m_y+2 SAY "Prebaci iz 22 u 10:"
    @ m_x+2, m_y+2 SAY "----------------------------"
    @ m_x+3, m_y+2 SAY "Dokument:" GET cIdFirma 
    @ m_x+3, m_y+14 SAY "-" GET cVDok
    @ m_x+3, m_y+19 SAY "-" GET cBrojDokumenta
    @ m_x+5, m_y+2 SAY "Pitaj prije ispravke stavke (D/N)" GET cEditYN VALID cEditYN$"DN" PICT "@!"
    read
BoxC()


if LastKey()==K_ESC
    return .t.
endif

if (Empty(cIdFirma) .or. Empty(cVDok) .or. Empty(cBrojDokumenta))
    MsgBeep("Nisu popunjena sva polja !!!")
    return .t.
endif

select fakt_pripr
go bottom
nRbr:=VAL(field->rbr)+1

cPFirma:=field->idfirma
cPVDok:=field->idtipdok
cPBrDok:=field->brdok
dDatDok:=field->datdok
cIdPartn:=field->idpartner

O_FAKT
// prvo pogledaj da li dokument postoji u FAKT
select fakt
set order to tag "1"
seek cIdFirma+cVDok+cBrojDokumenta

if !Found()
    MsgBeep("Dokument: " + TRIM(cIdFirma)+"-"+TRIM(cPVDok)+"-"+TRIM(cPBrDok)+" ne postoji!!!")
    select fakt_pripr
    return .t.
else
    Box(,4,70)
    //brojaci dodatih i editovanih stavki
    nEdit:=0
    nAdd:=0
    // pocni popunjavati !!!
    do while !EOF() .and. field->idfirma=cIdFirma .and. field->idtipdok=cVDok .and. field->brdok=cBrojDokumenta
        cIdRoba:=field->idroba
        nKolicina:=field->kolicina
        @ m_x+1, m_y+2 SAY "Trazim artikal: " + TRIM(cIdRoba)
        select fakt_pripr
        go top
        set order to tag "3"
        seek cIdFirma+cIdRoba
        if Found()
            if (cEditYN=="D" .and. Pitanje("Ispraviti kolicinu za artikal " + TRIM(cIdRoba), "D")=="N")
                select fakt
                skip
                loop
            endif
            @ m_x+2, m_y+2 SAY "Status: Ispravljam stavku  "
            Scatter()
            _kolicina+=nKolicina
            Gather()
            nEdit++
            select fakt
            skip
        else
            @ m_x+2, m_y+2 SAY "Status: Dodajem novu stavku"
            append blank
            replace idfirma with cPFirma
            replace idtipdok with cPVDok
            replace brdok with cPBrDok
            replace rbr with RIGHT(STR(nRbr),3)
            replace idroba with fakt->idroba
            replace dindem with fakt->dindem
            replace zaokr with fakt->zaokr
            replace kolicina with fakt->kolicina
            replace cijena with fakt->cijena
            replace rabat with fakt->rabat
            replace porez with fakt->porez
            replace serbr with fakt->serbr
            replace idpartner with cIdPartn
            replace datdok with dDatdok
            nAdd++
            select fakt
            skip
        endif
        @ m_x+3, m_y+2 SAY "Ispravio stavki  :" + STR(nEdit)
        @ m_x+4, m_y+2 SAY "Dodao novi stavki:" + STR(nAdd)
    enddo
    BoxC()
endif

MsgBeep("Dodao: " + STR(nAdd) + ", ispravio: " + STR(nEdit) + " stavki")

select fakt_pripr
return .t.



