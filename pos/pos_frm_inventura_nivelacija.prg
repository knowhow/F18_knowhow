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

static _saldo_izn := 0
static _saldo_kol := 0


function InventNivel()
parameters fInvent, fIzZad, fSadAz, dDatRada, stanje_dn

local i:=0
local j:=0
local fPocInv:=.f.
local fPreuzeo:=.f.
local cNazDok

private bPrevZv
private bPrevKroz
private bPrevUp
private bPrevDn

private cRSdbf
private cRSblok
private cUI_U
private cUI_I
private cIdVd
private cZaduzuje:="R"

if gSamoProdaja == "D"
    MsgBeep( "Ne mozete vrsiti zaduzenja !" )
    return
endif

if dDatRada == nil
    dDatRada := gDatum
endif

if stanje_dn == nil
    stanje_dn := "N"
endif

if (fInvent == nil)
    fInvent := .t.
else
    fInvent := fInvent
endif

if fInvent
    cIdVd := VD_INV
else
    cIdVd := VD_NIV
endif

if fInvent
    cNazDok := "INVENTUR"
else
    cNazDok := "NIVELACIJ"
endif

if fIzZad == nil
    fIzZad := .f.  
    // fja pozvana iz zaduzenja
endif

if fSadAz == nil
    fSadAz := .f.  
    // fja pozvana iz zaduzenja
endif

if fIzZad
    // ne diraj ove varijable
else
    private cIdOdj := SPACE(2)
    private cIdDio := SPACE(2)
endif

O_InvNiv()

set cursor on

if !fIzZad
    
    aNiz := {}
    
    if gVodiOdj == "D"
        AADD( aNiz,{ "Sifra odjeljenja","cIdOdj","P_Odj(@cIdOdj)",,} )
    endif
    
    if gPostDO == "D" .and. fInvent
        AADD( aNiz,{"Sifra dijela objekta","cIdDio","P_Dio(@cIdDio)",,} )
    endif

    AADD( aNiz, { "Datum rada", "dDatRada", "dDatRada <= DATE()",, } )
    AADD( aNiz, { "Inventura sa gen.stanja (D/N) ?", "stanje_dn", "stanje_dn $ 'DN'", "@!", } )

    if !VarEdit( aNiz, 9, 15, 15, 64, cNazDok + "A", "B1" )
        close all
        return
    endif

endif

SELECT ODJ

cZaduzuje := "R"
cRSdbf := "ROBA"
//cRSblok := "P_Roba( @_IdRoba, 1, 31 )"
cUI_U := R_U
cUI_I := R_I

if !pos_vrati_dokument_iz_pripr( cIdVd, gIdRadnik, cIdOdj, cIdDio )
    close all
    return
endif

// datum trebam setovati na osnovu dokumenta koji je vracen u priprz
// ako postoji

select priprz

// pocetak inventure
if RecCount2() == 0
    fPocInv := .t.
else
    fPocInv := .f.
    dDatRada := priprz->datum
endif

// 1) formiranje pomocne baze sa knjiznim stanjima artikala

if fPocInv    

    cBrDok := pos_novi_broj_dokumenta( gIdPos, cIdVd )  

    fPreuzeo := .f.

    if !fPreuzeo
        O_InvNiv()
    endif

    if stanje_dn == "N" .and. cIdVd == VD_INV
        // iskljucujem generisanje stavki sa stanjem
        fPocInv := .f.
    endif

    if fPocInv .and. !fPreuzeo .and. cIdVd == VD_INV
        
        // generisi stavke SAMO ZA INVENTURU (nemoj za NIVELACIJU)
        MsgO( "GENERISEM DATOTEKU " + cNazDok + "E" )
        
        select priprz 

        Scatter()

        select pos
        set order to tag "2"
        // "2", "IdOdj + idroba + DTOS(Datum)
        seek cIdOdj
    
        do while !EOF() .and. field->idodj == cIdOdj
            
            if pos->datum > dDatRada
                skip
                loop
            endif

            _kolicina := 0
            _idroba := pos->idroba

            do while !EOF() .and. pos->( idodj + idroba ) == ( cIdOdj + _idroba ) .and. pos->datum <= dDatRada

                if !EMPTY( cIdDio ) .and. pos->iddio <> cIdDio
                    skip
                    loop
                endif
                    
                if cZaduzuje == "S" .and. pos->idvd $ "42#01"
                    skip
                    loop  
                    // racuni za sirovine - zdravo
                endif
                    
                if cZaduzuje == "R" .and. pos->idvd == "96"
                    skip
                    loop   
                    // otpremnice za robu - zdravo
                endif
                    
                if pos->idvd $ "16#00"
                    // na ulazu imam samo VD_ZAD i VD_PCS
                    _kolicina += pos->kolicina
                    
                elseif pos->idvd $ "42#96#01#IN#NI"
                    // na izlazu imam i VD_INV i VD_NIV
                    do case
                        case pos->idvd == VD_INV
                            _kolicina -= pos->kolicina - pos->kol2
                        case pos->idvd == VD_NIV
                            // ne mijenja kolicinu
                        otherwise
                            _kolicina -= pos->kolicina
                    endcase
                endif
                skip
            enddo

            if Round( _kolicina, 3 ) <> 0
                    
                select (cRSdbf)
                HSEEK _idroba

                _cijena := _field->mpc     
                // postavi tekucu cijenu
                _ncijena := _field->mpc
                _robanaz := _field->naz 
                _jmj := _field->jmj
                _idtarifa := _field->idtarifa

                select priprz

                _IdOdj := cIdOdj 
                _IdDio := cIdDio
                _BrDok := cBrDok 
                _IdVd := cIdVd
                _Prebacen := OBR_NIJE
                _IdCijena := "1"
                _IdRadnik := gIdRadnik 
                _IdPos := gIdPos
                _datum := dDatRada 
                _Smjena := gSmjena
                _Kol2 := _Kolicina
                _MU_I := cUI_I
                
                append blank  
                Gather()

                select pos

            endif

        enddo  
        
        MsgC()

    else
        select priprz
        Zapp() 
        __dbPack()  
    endif

else
        
    select priprz
    go top
    cBrDok := priprz->brdok

endif

// 2) prikaz formirane baze u browse-sistemu sa mogucnoscu:
//    - unosa stvarnog stanja (ispravka stavke)
//    - unosa novih stavki
//    - brisanja stavki
//    - stampanja dokumenta inventure
//    - stampanja popisne liste

if !fSadAz  

    ImeKol := {}

    AADD( ImeKol, { "Sifra i naziv", {|| idroba + "-" + LEFT( robanaz, 25 ) }})
    AADD( ImeKol, { "BARKOD", {|| barkod } })

    if cIdVd == VD_INV
        AADD( ImeKol, { "Knj.kol." , {|| STR( kolicina, 9, 3 ) } })
        AADD( ImeKol, { "Pop.kol." , {|| STR( kol2, 9, 3 ) }, "kol2" })
    else
        AADD( ImeKol, { "Kolicina" , {|| STR( kolicina, 9, 3 ) } })
    endif

    AADD(ImeKol, { "Cijena "    , {|| STR( cijena, 7, 2 ) }})

    if cIdVd == VD_NIV
        AADD(ImeKol, { "Nova C.",     {|| STR( ncijena, 7, 2 ) } })
    endif
        
    AADD(ImeKol, { "Tarifa "    , {|| idtarifa }})

    Kol := {}
        
    for nCnt := 1 TO LEN( ImeKol )
        AADD( Kol, nCnt )
    next

    select priprz 
    set order to tag "1"

    do while .t.

        select priprz
        go top

        @ 12, 0 SAY ""

        SET CURSOR ON

        ObjDBedit( "PripInv", MAXROWS() - 15, MAXCOLS() - 3, {|| EditInvNiv( dDatRada ) }, ;
                "Broj dokumenta: " + cBrDok , ;
                "PRIPREMA " + cNazDok + "E", nil, ;
                { "<c-N>   Dodaj stavku", "<Enter> Ispravi stavku", "<a-P>   Popisna lista", "<c-P>   Stampanje", "<c-A> cirk ispravka" }, 2, , , )

        // 3) nakon prekida rada na inventuri (<Esc>) utvrdjuje se da li je inventura zavrsena

        // ako je priprema prazna, nemam sta raditi...
        if priprz->( RECCOUNT() ) == 0
            pos_reset_broj_dokumenta( gIdPos, cIdVd, cBrDok )
            close all
            return
        endif
 
        i := KudaDalje( "ZAVRSAVATE SA PRIPREMOM " + cNazDok + "E. STA RADITI S NJOM?", { ;
                    "NASTAVICU S NJOM KASNIJE", ;
                    "AZURIRATI (ZAVRSENA JE)", ;
                    "TREBA JE IZBRISATI", ;
                    "VRATI PRIPREMU " + cNazDok + "E" })

        if i == 1     

            // ostavi je za kasnije
            SELECT _POS
            AppFrom( "PRIPRZ", .f. )
            SELECT PRIPRZ
            Zapp()
            __dbPack()
            close all
            return

        elseif i == 3 

            if Pitanje(, "Sigurno zelite izbrisati pripremu dokumenta (D/N) ?", "N" ) == "D"

                // obrisati pripremu
                SELECT PRIPRZ
                Zapp()
                __dbPack()
                // reset brojaca dokumenta...
                pos_reset_broj_dokumenta( gIdPos, cIdVd, cBrDok )
                close all
                return

            else

                // ostavi je za kasnije
                SELECT _POS
                AppFrom( "PRIPRZ", .f. )
                SELECT PRIPRZ
                Zapp()
                __dbPack()
                close all
                return

            endif

        elseif i == 4     

            // vracamo se na pripremu
            SELECT PRIPRZ
            GO TOP
            LOOP

        endif

        if i == 2 
            // izvsiti azuriranje
            // izadji iz petlje, izvrsi azuriranje
            exit 
        endif

    enddo  
endif 

// azuriraj pripremu u POS
Priprz2Pos()

close all

return


// ---------------------------------------------
// Ispravka nivelacije ili inventure
// ---------------------------------------------
function EditInvNiv( dat_inv_niv )
local nRec := RECNO()
local i := 0
local lVrati := DE_CONT

do case

    case Ch == K_CTRL_P

        StampaInv()
        
        o_invniv()
        select priprz
        go nRec
        
        lVrati := DE_REFRESH

    case Ch == K_ALT_P

        if cIdVd == VD_INV
            StampaInv( .t. )
            o_invniv()
            select priprz
            go nRec
            lVrati:=DE_REFRESH
        endif

    case Ch == K_ENTER
        
        // kalkulisi stavke u pripremi
        _calc_priprz()
        // otvori unos
        if !( EdPrInv(1) == 0 )
            lVrati := DE_REFRESH
        endif

    case Ch == K_CTRL_O

        // update razlika na inventuri
        if update_ip_razlika() == 1
            lVrati := DE_REFRESH
        endif

    case Ch == K_CTRL_U

        // update knj.kolicina
        update_knj_kol()
        lVrati := DE_REFRESH

    case Ch == K_CTRL_A

        do while !eof()
            if EdPrInv(1) == 0
                exit
            endif
            skip
        enddo

        if EOF()
            skip -1
        endif

        lVrati := DE_REFRESH

    case Ch == K_CTRL_N  

        // kalkulisi stavke iz pripreme
        _calc_priprz()

        // otvori unos
        EdPrInv( 0, dat_inv_niv )
        
        lVrati := DE_REFRESH
        
    case Ch == K_CTRL_T
        
        lVrati := DE_CONT

        // brisi stavku u pripremi...
        if Pitanje(, "Stavku " + ALLTRIM( priprz->idroba ) + " izbrisati ?", "N" ) == "D"
            
            delete
            __dbPack()
            lVrati := DE_REFRESH        
            
        endif

endcase

return lVrati



// ----------------------------------------
// kalkulisi priprz stavke
// napuni staticke varijable
// _saldo_kol, _saldo_izn
// ----------------------------------------
static function _calc_priprz()
local _t_area := SELECT()

select priprz
go top

_saldo_kol := 0
_saldo_izn := 0

do while !EOF()

    // inventura treba da gleda kol2
    if field->idvd == "IN"
        _saldo_kol += field->kol2
        _saldo_izn += ( field->kol2 * field->cijena )
    else
        _saldo_kol += field->kolicina
        _saldo_kol += ( field->kolicina * field->cijena )
    endif

    skip

enddo

select (_t_area)
return




// ---------------------------------------------------------
// ispravka ili unos nove stavke u pipremi
// ---------------------------------------------------------
function edprinv( nInd, datum )
local nVrati := 0
local aNiz := {}
local nRec := RECNO()
local _r_tar, _r_barkod, _r_jmj, _r_naz
local _duz_sif := "10"
local _pict := "9999999.99"
local _last_read_var

// slijedi ispravka stavke ( nInd == 1 ) 
// ili petlja unosa stavki ( nInd == 0 )

if gDuzSifre <> nil .and. gDuzSifre > 0
	_duz_sif := ALLTRIM( STR( gDuzSifre ) )
endif

SET CURSOR ON

select priprz

do while .t.
   
    set confirm on
 
    Box(, 7, maxcols()-5 , .t. )

    @ m_x + 0, m_y + 1 SAY " " + IF( nInd == 0, "NOVA STAVKA", "ISPRAVKA STAVKE" ) + " "

    Scatter()

    @ m_x + 1, m_y + 31 SAY PADR( "", 35 ) 
    @ m_x + 6, m_y + 2 SAY "... zadnji artikal: " + ALLTRIM( _idroba ) + " - " + PADR( _robanaz, 25 ) + "..." 
    @ m_x + 7, m_y + 2 SAY "stanje unosa - kol: " + ALLTRIM( STR( _saldo_kol, 12, 2)) + ;
                                                    " total: " + ALLTRIM( STR( _saldo_izn, 12, 2 ) )
 
    select ( cRSdbf )
    hseek _idroba

    if nInd == 1
        @ m_x + 0, m_y + 1 SAY _idroba + " : " + ALLTRIM(naz) + " (" + ALLTRIM(idtarifa) + ")"
    endif

    select priprz

    if nInd == 0  

        // unosenje novih stavki
        _idodj := cIdOdj
        _iddio := cIdDio
        _idroba := SPACE(10)
        _kolicina := 0  
        _kol2 := 0
        _brdok := cBrDok
        _idvd := cIdVd
        _prebacen := OBR_NIJE
        _idcijena := "1"
        _idradnik := gIdRadnik 
        _idpos := gIdPos
        _cijena := 0
        _ncijena := 0
        _datum := datum
        _smjena := gSmjena
        _mu_i := cUI_I

    endif

    nLX := m_x + 1
	
    @ nLX, m_y + 3 SAY "      Artikal:" GET _idroba ;
            PICT PICT_POS_ARTIKAL ;
            WHEN {|| _idroba := PADR( _idroba, VAL( _duz_sif )), .t. } ;
            VALID valid_pos_inv_niv( cIdVd, nInd )

                   
    nLX ++
        
    if cIdVd == VD_INV
            // ovo mi treba samo informativno kod inventure...
            @ nLX, m_y + 3 SAY "Knj. kolicina:" GET _kolicina PICT _pict ;
               WHEN { || .f. }
    else
            @ nLX, m_y + 3 SAY "     Kolicina:" GET _kolicina PICT _pict ;
               WHEN { || .t. }
    endif
            
    nLX ++
    
    if cIdVd == VD_INV

        @ nLX, m_y + 3 SAY "Pop. kolicina:" GET _kol2 PICT _pict ;
              VALID _pop_kol( _kol2 ) ;
              WHEN { || .t.}

        nLX ++

    endif

    @ nLX, m_y + 3 SAY "       Cijena:" GET _cijena PICT _pict ;
         WHEN { || .t.}

    if cIdVd == VD_NIV

        nLX ++

        @ nLX, m_y + 3 SAY "  Nova cijena:" GET _ncijena PICT _pict ;
           WHEN { || .t.}

    endif

    READ

    if LastKey() == K_ESC

        BoxC()

        TB:RefreshAll()
        DO WHILE !TB:stable .AND. ( Ch := INKEY() ) == 0 
            Tb:stabilize()
        ENDDO

        exit

    endif
        
    // priprz
    if nInd == 0
        append blank 
    endif
    
    // pronadji tarifu i barkod za ovaj artikal
    select (cRSdbf)
    set order to tag "ID"
    hseek _idroba

    _r_tar := field->idtarifa
    _r_barkod := field->barkod
    _r_naz := field->naz
    _r_jmj := field->jmj 

    select priprz

    _idtarifa := _r_tar
    _barkod := _r_barkod
    _robanaz := _r_naz
    _jmj := _r_jmj

    Gather()
 
    _saldo_kol += priprz->kol2
    _saldo_izn += ( priprz->kol2 * priprz->cijena )
 
    if nInd == 0
        
        TB:RefreshAll()

        DO WHILE !TB:stable .AND. ( Ch := INKEY() ) == 0 
            Tb:stabilize()
        ENDDO

    endif


    if nInd == 1
        nVrati := 1
        BoxC()
        exit
    endif

    BoxC()

enddo

go nRec

return nVrati


// -----------------------------------------------------
// update razlika artikala na postojecoj inventuri
// -----------------------------------------------------
static function update_ip_razlika()
local _id_odj := SPACE(2)
local ip_kol, ip_roba
local _rec2, _rec

if Pitanje(,"Generisati razliku artikala sa stanja ?", "N" ) == "N"
    return 0
endif
        
MsgO( "GENERISEM RAZLIKU NA OSNOVU STANJA" )
       
select priprz
go top
_rec2 := dbf_get_rec()
 
select pos
set order to tag "2"
// "2", "IdOdj + idroba + DTOS(Datum)
seek _id_odj
    
do while !EOF() .and. field->idodj == _id_odj
            
    if pos->datum > dDatRada
        skip
        loop
    endif

    ip_kol := 0
    ip_roba := pos->idroba

    select priprz
    set order to tag "1"
    go top
    seek PADR( ip_roba, 10 )

    if FOUND() .and. field->idroba == PADR( ip_roba, 10 )
        select pos
        skip
        loop
    endif

    select pos

    do while !EOF() .and. pos->( idodj + idroba ) == ( _id_odj + ip_roba ) .and. pos->datum <= dDatRada

        if !EMPTY( cIdDio ) .and. pos->iddio <> cIdDio
            skip
            loop
        endif
                    
        if pos->idvd $ "16#00"
            // na ulazu imam samo VD_ZAD i VD_PCS
            ip_kol += pos->kolicina
                    
        elseif pos->idvd $ "42#96#01#IN#NI"
            // na izlazu imam i VD_INV i VD_NIV
            do case
                case pos->idvd == VD_INV
                    ip_kol -= pos->kolicina - pos->kol2
                case pos->idvd == VD_NIV
                    // ne mijenja kolicinu
                otherwise
                    ip_kol -= pos->kolicina
            endcase
        endif
                
        skip

    enddo

    if ROUND( ip_kol, 3 ) <> 0
                    
        select roba
        set order to tag "ID"
        go top
        seek ip_roba

        select priprz
        append blank

        _rec := dbf_get_rec()
        _rec["cijena"] := roba->mpc     
        _rec["ncijena"] := 0 
        _rec["idroba"] := ip_roba
        _rec["barkod"] := roba->barkod
        _rec["robanaz"] := roba->naz 
        _rec["jmj"] := roba->jmj
        _rec["idtarifa"] := roba->idtarifa
        _rec["kol2"] := 0
        _rec["kolicina"] := ip_kol
        _rec["brdok"] := _rec2["brdok"]
        _rec["datum"] := _rec2["datum"]
        _rec["idcijena"] := _rec2["idcijena"]
        _rec["idpos"] := _rec2["idpos"]
        _rec["idradnik"] := _rec2["idradnik"]
        _rec["idvd"] := _rec2["idvd"]
        _rec["mu_i"] := _rec2["mu_i"]
        _rec["prebacen"] := _rec2["prebacen"]
        _rec["smjena"] := _rec2["smjena"]
                
        dbf_update_rec( _rec )
                
    endif

    select pos

enddo  
 
select priprz
go top

TB:RefreshAll()

DO WHILE !TB:stable .AND. ( Ch := INKEY() ) == 0 
    Tb:stabilize()
ENDDO

return 1


// -------------------------------------------------
// update knjiznih kolicina na dokumentu
// -------------------------------------------------
static function update_knj_kol()

select priprz
go top

do while !EOF()

    Scatter()
    RacKol( _idodj, _idroba, @_kolicina )

    select priprz
    Gather()

    skip
enddo
    
TB:RefreshAll()

DO WHILE !TB:stable .AND. ( Ch := INKEY() ) == 0 
    Tb:stabilize()
ENDDO

select priprz
go top

return .t.


// ------------------------------------------------------------------
// ------------------------------------------------------------------
static function valid_pos_inv_niv( cIdVd, ind )
local _area := SELECT()

pos_postoji_roba( @_IdRoba, 1, 31) 

RacKol( _idodj, _idroba, @_kolicina )
_set_cijena_artikla( cIdVd, _idroba )

if ind == 0 .and. !_postoji_artikal_u_pripremi( _idroba )
    select ( _area )
    return .f.
endif

if cIdVD == VD_INV
   get_field_set_focus("_kol2")
else
   get_field_set_focus("_cijena")
endif

select ( _area )
return .t.

 


// ----------------------------------------------
// provjera popisane kolicine 
// ----------------------------------------------
function _pop_kol( kol )
local _ok := .t.

if kol > 200
    if Pitanje(, "Da li je kolicina " + ALLTRIM( STR( kol, 12, 2) ) + " ispravna kolicina ?", "N" ) == "N"
        _ok := .f.    
    endif
endif

return _ok



// -----------------------------------------------
// setovanje cijene iz sifrarnika
// -----------------------------------------------
function _set_cijena_artikla( id_vd, id_roba )
local _t_area := SELECT()

if id_vd == VD_INV
    
    select roba
    hseek id_roba        
    // setuj cijene
    _cijena := roba->mpc

endif

select ( _t_area )
return .t.



// -------------------------------------------------------
// provjeri da li postoji ovaj zapis vec u pripremi...
// -------------------------------------------------------
function _postoji_artikal_u_pripremi( id_roba )
local _ok := .t.
local _t_area := SELECT()
local _t_rec := RECNO()

select priprz
set order to tag "1"
go top
seek id_roba

if FOUND()
    _ok := .f.
    MsgBeep( "Artikal " + id_roba + " se vec nalazi u pripremi !")
endif

select ( _t_area )
go ( _t_rec )

return _ok



/*! \fn RacKol(cIdOdj,cIdRoba,nKol)
 *  \brief Racuna kolicinu robe
 *  \param cIdOdj
 *  \param cIdRoba
 *  \param nKol
 *  \return
 */
 
function RacKol( cIdOdj, cIdRoba, nKol )

MsgO( "Racunam kolicinu ..." )

select pos
set order to tag "2"
nKol := 0

seek cIdOdj + cIdRoba

while !EOF() .and. pos->(IdOdj+IdRoba) == (cIdOdj+cIdRoba) .and. pos->Datum <= dDatRada

    if ALLTRIM(POS->IdPos) == "X"
        SKIP
        LOOP
    endif

    // ovdje ne gledam DIO objekta, jer nivelaciju uvijek radim za
    // cijeli objekat

    if pos->idvd $ "16#00"   
        nKol += pos->Kolicina     
    elseif POS->idvd $ "42#01#IN#NI"
        do case
            case POS->IdVd == VD_INV
                nKol := pos->kol2
            case POS->idvd == VD_NIV
                // ne utice na kolicinu
            otherwise
                nKol -= pos->kolicina
        endcase
    endif
    skip
enddo

MsgC()

select priprz

return (.t.)


