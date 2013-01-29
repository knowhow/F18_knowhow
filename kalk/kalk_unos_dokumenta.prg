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

#include "kalk.ch"
#include "f18_separator.ch"

static cENTER := CHR(K_ENTER) + CHR(K_ENTER) + CHR(K_ENTER)
static __box_x
static __box_y


function kalk_unos_dokumenta()
private PicCDEM:=gPicCDEM
private PicProc:=gPicProc
private PicDEM:= gPICDEM
private Pickol:= gPICKOL
private lAsistRadi:=.f.

__box_x := MAXROWS() - 8
__box_y := MAXCOLS() - 6

kalk_unos_stavki_dokumenta()

close all
return



// ----------------------------------------------------------------
// unos stavki kalkulacije
// ----------------------------------------------------------------
function kalk_unos_stavki_dokumenta(lAObrada)
local nMaxCol := MAXCOLS() - 3
local nMaxRow := MAXROWS() - 4
local _opt_row, _opt_d
local _sep := BROWSE_COL_SEP

O_PARAMS

private lAutoObr := .f.
private lAAsist := .f.
private lAAzur := .f.

if lAObrada == nil
    lAutoObr := .f.
else
    lAutoObr := lAObrada
    lAAsist := .t.
    lAAzur := .t.
endif

private cSection:="K"
private cHistory:=" "
private aHistory:={}

select 99
use

o_kalk_edit()

private gVarijanta := "2"
private PicV := "99999999.9"

private ImeKol := {}
private Kol := {}

// definisi strukturu pripreme
AADD( ImeKol, { "F." , {|| idfirma   }, "idfirma"   } )
AADD( ImeKol, { "VD"        , {|| IdVD                     }, "IdVD"        } )
AADD( ImeKol, { "BrDok"     , {|| BrDok                    }, "BrDok"       } )
AADD( ImeKol, { "R.Br"      , {|| Rbr                      }, "Rbr"         } )
AADD( ImeKol, { "Dat.Kalk"  , {|| DatDok                   }, "DatDok"      } )
AADD( ImeKol, { "Dat.Fakt"  , {|| DatFaktP                 }, "DatFaktP"    } )
AADD( ImeKol, { "K.zad. "   , {|| IdKonto                  }, "IdKonto"     } )
AADD( ImeKol, { "K.razd."   , {|| IdKonto2                 }, "IdKonto2"    } )
AADD( ImeKol, { "IdRoba"    , {|| IdRoba                   }, "IdRoba"      } )

if lKoristitiBK
    AADD( ImeKol, { "Barkod"    , {|| roba_ocitaj_barkod( idroba ) }, "IdRoba" } )
endif

AADD( ImeKol, { "Kolicina"  , {|| transform(Kolicina,picv) }, "kolicina"    } )
AADD( ImeKol, { "IdTarifa"  , {|| idtarifa                 }, "idtarifa"    } )
AADD( ImeKol, { "F.Cj."     , {|| transform(FCJ,picv)      }, "fcj"         } )
AADD( ImeKol, { "F.Cj2."    , {|| transform(FCJ2,picv)     }, "fcj2"        } )
AADD( ImeKol, { "Nab.Cj."   , {|| transform(NC,picv)       }, "nc"          } )
AADD( ImeKol, { "VPC"       , {|| transform(VPC,picv)      }, "vpc"         } )
AADD( ImeKol, { "VPCj.sa P.", {|| transform(VPCsaP,picv)   }, "vpcsap"      } )
AADD( ImeKol, { "MPC"       , {|| transform(MPC,picv)      }, "mpc"         } )
AADD( ImeKol, { "MPC sa PP" , {|| transform(MPCSaPP,picv)  }, "mpcsapp"     } )
AADD( ImeKol, { "RN"        , {|| idzaduz2                 }, "idzaduz2"    } )
AADD( ImeKol, { "Br.Fakt"   , {|| brfaktp                  }, "brfaktp"     } )
AADD( ImeKol, { "Partner"   , {|| idpartner                }, "idpartner"   } )
AADD( ImeKol, { "E"         , {|| error                    }, "error"       } )

if lPoNarudzbi
    AADD( ImeKol , { "Br.nar." , {|| brojnar   }, "brojnar"   } )
    AADD( ImeKol , { "Narucioc" , {|| idnar   }, "idnar"   } )
endif

for i := 1 to LEN( ImeKol )
    AADD( Kol, i )
next

Box(, nMaxRow, nMaxCol )

    _opt_d := ( nMaxCol / 4 )
    
    _opt_row := PADR( "<c+N> Nova stavka", _opt_d ) + _sep
    _opt_row += PADR( "<ENT> Ispravka", _opt_d ) + _sep
    _opt_row += PADR( hb_utf8tostr("<c+T> Brisi stavku"), _opt_d ) + _sep
    _opt_row += "<K> Kalk.cijena"

    @ m_x + nMaxRow - 3, m_y + 2 SAY _opt_row
    
    _opt_row := PADR( "<c+A> Ispravka", _opt_d ) + _sep
    _opt_row += PADR( hb_utf8tostr("<c+P> Stampa dok."), _opt_d ) + _sep
    _opt_row += PADR( hb_utf8tostr("<a+A> Azuriranje"), _opt_d ) + _sep
    _opt_row += "<Q> Etikete"

    @ m_x + nMaxRow - 2, m_y + 2 SAY _opt_row
 
    _opt_row := PADR( "<a+K> Kontiranje", _opt_d ) + _sep
    _opt_row += PADR( hb_utf8tostr("<c+F9> Brisi sve"), _opt_d ) + _sep
    _opt_row += PADR( hb_utf8tostr("<a+P> Stampa pripreme"), _opt_d ) + _sep
   
    @ m_x + nMaxRow - 1, m_y + 2 SAY _opt_row
 
    _opt_row := PADR( hb_utf8tostr("<c+F8> Rasp.troskova"), _opt_d ) + _sep
    _opt_row += PADR( "<A> Asistent", _opt_d ) + _sep
    _opt_row += PADR( "<F10> Dodatne opc.", _opt_d ) + _sep
    _opt_row += "<F11> Dodatne opc./2"
   
    @ m_x + nMaxRow, m_y + 2 SAY _opt_row

    if gCijene == "1" .and. gMetodaNC == " "
        Soboslikar({{ nMaxRow - 3, m_y + 1, nMaxRow, m_y + 77 }}, 23, 14 )
    endif

    private lAutoAsist:=.f.

    ObjDbedit("PNal", nMaxRow, nMaxCol, {|| kalk_pripr_key_handler(lAutoObr)},"<F5>-kartica magacin, <F6>-kartica prodavnica","Priprema...", , , , ,4)

BoxC()

close all
return




function o_kalk_edit()

select F_KALK_DOKS
if !used()
    O_KALK_DOKS
endif

select F_KALK_PRIPR
if !used()
    O_KALK_PRIPR
endif

select F_DOKSRC
if !used()
    O_DOKSRC
endif

select F_P_DOKSRC
if !used()
    O_P_DOKSRC
endif

select F_SIFK
if !used()
    O_SIFK
endif

select F_SIFV
if !used()
    O_SIFV
endif

select F_ROBA
if !used()
    O_ROBA
endif

select F_KALK
if !used()
    O_KALK
endif

select F_KONTO
if !used()
    O_KONTO
endif

select F_PARTN
if !used()
    O_PARTN
endif

select F_TDOK
if !used()
    O_TDOK
endif

select F_VALUTE
if !used()
    O_VALUTE
endif

select F_TARIFA
if !used()
    O_TARIFA 
endif

select F_KONCIJ
if !used()
    O_KONCIJ
endif

select kalk_pripr
set order to tag "1"
go top

return


// -------------------------------------------------------
// provjeri i ispisi duple stavke iz pripreme
// -------------------------------------------------------
static function _kalk_pripr_duple_stavke()
local _data := {}
local _dup := {}
local _scan

O_ROBA
O_KALK_PRIPR

select kalk_pripr
go top

do while !EOF()

    select roba
    hseek kalk_pripr->idroba

    select kalk_pripr

    _scan := ASCAN( _data, {|var| var[1] == kalk_pripr->idroba } )

    if _scan == 0
        AADD( _data, { kalk_pripr->idroba } )    
    else
        AADD( _dup, { kalk_pripr->idroba, roba->naz, roba->barkod, kalk_pripr->rbr } )    
    endif

    skip

enddo

go top

if LEN( _dup ) > 0

    START PRINT CRET
    
    ? "Sljedeci artikli u pripremi su dupli:"
    ? REPLICATE( "-", 80 )
    ? PADR("R.br", 5 ) + " " + PADR( "Rb.st", 5 ) + " " + PADR( "ID", 10 ) + " " + PADR( "NAZIV", 40 ) + " " + PADR( "BARKOD", 13 )
    ? REPLICATE( "-", 80 )
    
    for _i := 1 to LEN( _dup )
        ? PADL( ALLTRIM( STR( _i, 5 ) ) + ".", 5 )
        @ prow(), pcol() + 1 SAY PADR( _dup[ _i, 4 ], 5 )
        @ prow(), pcol() + 1 SAY _dup[ _i, 1 ]
        @ prow(), pcol() + 1 SAY PADR( _dup[ _i, 2 ], 40 )
        @ prow(), pcol() + 1 SAY _dup[ _i, 3 ]
    next

    END PRINT

endif

return



// -------------------------------------------------------------
// obrada dogadjaja tastature u pripremi kalkulacija
// -------------------------------------------------------------
function kalk_pripr_key_handler()
local nTr2
local cSekv
local nKekk
local iSekv
local _rec

if ( Ch == K_CTRL_T .or. Ch == K_ENTER ) .and. EOF()
    return DE_CONT
endif

PRIVATE PicCDEM := gPicCDEM
PRIVATE PicProc := gPicProc
PRIVATE PicDEM := gPicDEM
PRIVATE Pickol := gPicKol

select kalk_pripr

do case

    case Ch == K_ALT_H
        Savjetnik()

    case Ch == K_ALT_K
        close all
        RekapK()
        if Pitanje(,"Zelite li izvrsiti kontiranje ?","D")=="D"
            kalk_kontiranje_naloga()
        endif
        o_kalk_edit()
        return DE_REFRESH

    case Ch == K_SH_F9

        renumeracija_kalk_pripr( nil, nil, .f. )
        return DE_REFRESH

    case Ch == K_SH_F8
        
        if kalk_pripr_brisi_od_do()
            return DE_REFRESH
        endif

    case Ch==K_ALT_P

        close all
        IzbDokOLPP()
        // StPripr()
        o_kalk_edit()

        return DE_REFRESH

    case Ch==K_ALT_L

        close all

        label_bkod()
        o_kalk_edit()

        return DE_REFRESH

    case UPPER(CHR(Ch)) == "Q"

        if Pitanje(,"Stampa naljepnica(labela) za robu ?","D")=="D"

            CLOSE ALL

            RLabele()
            o_kalk_edit()       

            return DE_REFRESH

        endif

        return DE_CONT

    case Ch == K_ALT_A

        if IsJerry()
            JerryMP()
        endif

        close all

        azur_kalk()
        o_kalk_edit()

        if kalk_pripr->(RECCOUNT())==0 
            O__KALK

            select _kalk
            do while !EOF()
                _rec := dbf_get_rec()
                select kalk_pripr
                append blank
                dbf_update_rec( _rec )
                select _kalk
                skip            
            enddo
            
            SELECT kalk_pripr
            
            UzmiIzINI(PRIVPATH+"FMK.INI","Indikatori","ImaU_KALK","N","WRITE")
            close all

            o_kalk_edit()
            MsgBeep("Stavke koje su bile privremeno sklonjene sada su vracene! Obradite ih!")

        endif

        return DE_REFRESH

    case Ch == K_CTRL_P

        close all
        kalk_centr_stampa_dokumenta()

        close all
        o_kalk_edit()

        return DE_REFRESH

    case Ch == K_CTRL_T
        
        if Pitanje(, "Zelite izbrisati ovu stavku ?", "D" ) == "D"
                
            cStavka := kalk_pripr->rbr
            cArtikal := kalk_pripr->idroba
            nKolicina := kalk_pripr->kolicina
            nNc := kalk_pripr->nc
            nVpc := kalk_pripr->vpc

            _rec := dbf_get_rec()
            delete

            _t_rec := RECNO()
            __dbPack()

            if (reccount() == 0) .and. !empty(_rec["idfirma"])
                kalk_rewind(_rec["idfirma"], _rec["idvd"], _rec["datdok"], _rec["brdok"])
            endif
            go ( _t_rec )

            return DE_REFRESH

        endif

        return DE_CONT

    case IsDigit(Chr(Ch))
        Msg("Ako zelite zapoceti unos novog dokumenta: <Ctrl-N>")
        return DE_CONT
    case Ch==K_ENTER
        return EditStavka()
    case Ch==K_CTRL_A .or. lAsistRadi
        return EditAll() 
    case Ch==K_CTRL_N  // nove stavke
        return NovaStavka()
    case Ch==K_CTRL_F8
        RaspTrosk()
        return DE_REFRESH
    case Ch==K_CTRL_F9
        if Pitanje( , "Zelite Izbrisati cijelu pripremu ??","N")=="D"
            select kalk_pripr
            go top            
            _rec := dbf_get_rec()
            if !empty(_rec["idfirma"])
                kalk_rewind(_rec["idfirma"], _rec["idvd"], _rec["datdok"], _rec["brdok"])
            endif
            zapp()
            select p_doksrc
            zapp()
            select kalk_pripr
            return DE_REFRESH
        endif
        return DE_CONT
    case UPPER( CHR(Ch) ) == "A" .or. lAutoAsist
        return KnjizAsistent()
    case UPPER( CHR(Ch) ) == "K"
        // kalkulacija cijena
        kalkulacija_cijena( .f. )
        select kalk_pripr
        go top
        return DE_CONT
    case Ch==K_F10
        return MeniF10()
    case Ch==K_F11
        return MeniF11()
    case Ch==K_F5
        Kmag()
        return DE_CONT
    case Ch==K_F6
        KPro()
        return DE_CONT
    case lAutoObr .and. lAAsist 
        // automatski obradi dokument
        // asistent
        lAAsist := .f.
        return KnjizAsistent()
    case lAutoObr .and. !lAAsist
        lAutoObr := .f.
        keyboard CHR(K_ESC)
        return DE_REFRESH
endcase

return DE_CONT


// ------------------------------------------------------------
// ispravka stavke
// ------------------------------------------------------------
function EditStavka()

if RecCount() == 0
    Msg("Ako zelite zapoceti unos novog dokumenta: <Ctrl-N>")
    return DE_CONT
endif

Scatter()

if LEFT( _idkonto2, 3 ) = "XXX"
    Beep(2)
    Msg("Ne mozete ispravljati protustavke")
    return DE_CONT
endif

nRbr := RbrUNum( _Rbr )
_ERROR := ""

Box( "ist", __box_x, __box_y, .f. )

if EditPRIPR(.f.)==0
    BoxC()
    return DE_CONT
else

    BoxC()

    if _ERROR<>"1"
        _ERROR:="0"
    endif       // stavka onda postavi ERROR

    if _idvd=="16"
        _oldval:=_vpc*_kolicina  // vrijednost prosle stavke
    else
        _oldval:=_mpcsapp*_kolicina  // vrijednost prosle stavke
    endif

    _oldvaln := _nc * _kolicina

    Gather()
        
    if _idvd $ "16#80" .and. !EMPTY( _idkonto2 )
        
        cIdkont := _idkonto
        cIdkont2 := _idkonto2
        _idkonto := cIdkont2
        _idkonto2 := "XXX"
        _kolicina := -kolicina
          
        nRbr := RbrUNum( _rbr ) + 1
        _rbr := RedniBroj( nRbr )

        Box( "", __box_x, __box_y, .f., "Protustavka" )
            seek _idfirma+_idvd+_brdok+_rbr
            _Tbanktr:="X"
            do while !eof() .and. _idfirma+_idvd+_brdok+_rbr==idfirma+idvd+brdok+rbr
                if LEFT( idkonto2, 3 ) == "XXX"
                    Scatter()
                    _TBankTr := ""
                    exit
                endif
                skip
            enddo
                   
            _idkonto := cIdKont2
            _idkonto2 := "XXX"
                    
            if _idvd=="16"
                if IsPDV()
                    Get1_16bPDV()
                else
                    Get1_16b()
                endif
            else
                Get1_80b()
            endif
                    
            if _TBanktr == "X"
                append ncnl
            endif

            if _ERROR<>"1"
                _ERROR:="0"
            endif       

            Gather()

        BoxC()

    endif

    return DE_REFRESH

endif

return DE_CONT


// --------------------------------------------------
// unos nove stavke
// --------------------------------------------------
function NovaStavka()

// isprazni kontrolnu matricu
aNC_ctrl := {}
    
Box( "knjn", __box_x, __box_y, .f., "Unos novih stavki" )    

    _TMarza := "A"

    // ipak idi na zadnju stavku !
    go bottom

    if LEFT( field->idkonto2, 3 ) = "XXX"
        skip -1
    endif
        
    // TODO: popni se u odnosu na negativne brojeve
    // TODO: VIDJETI ?? negativne su protustavke ????!!! zar to ima

    do while !BOF()
        if VAL( field->rbr ) < 0
           skip -1
        else
           exit
        endif
    enddo

    cIdkont := ""
    cIdkont2 := ""
        
    do while .t.

        Scatter()

        _ERROR := ""
           
        if _idvd $ "16#80" .and. _idkonto2 = "XXX"
            _idkonto := cIdkont
            _idkonto2 := cIdkont2
        endif
        
        if fetch_metric( "kalk_reset_artikla_kod_unosa", my_user(), "N" ) == "D"
            _idroba := SPACE(10)
        endif

        _Kolicina := _GKolicina := _GKolicin2 := 0
        _FCj := _FCJ2 := _Rabat := 0
           
        if !( _idvd $ "10#81" )
            _Prevoz := _Prevoz2 := _Banktr := _SpedTr := _CarDaz := _ZavTr := 0
        endif

        _NC := _VPC := _VPCSaP := _MPC := _MPCSaPP := 0
           
        nRbr := RbrUNum( _Rbr ) + 1

        if EditPRIPR( .t. ) == 0
             exit
        endif
           
        append blank
           
        if _error <> "1"
            _error := "0"
        endif       
           
        if _idvd == "16"
            _oldval := _vpc * _kolicina  
        else
            _oldval := _mpcsapp*_kolicina  
        endif

        _oldvaln := _nc * _kolicina

        Gather()
           
        if _idvd $ "16#80" .and. !EMPTY( _idkonto2 )

            cIdkont := _idkonto
            cIdkont2 := _idkonto2

            _idkonto := cIdKont2
            _idkonto2 := "XXX"
            _kolicina := -kolicina

            // uvecaj redni broj stavke
            nRbr := RbrUNum( _rbr ) + 1
            _Rbr := RedniBroj( nRbr )
            
            Box( "", __box_x, __box_y, .f., "Protustavka" )

                if _idvd == "16"
                    if IsPDV()
                        Get1_16bPDV()
                    else
                        Get1_16b()
                    endif
                else
                    Get1_80b()
                endif

                append blank

                if _ERROR <> "1"
                    _ERROR := "0"
                endif       

                // stavka onda postavi ERROR
                Gather()

            BoxC()

            _idkonto := cIdkont
            _idkonto2 := cIdkont2

        endif

    enddo

BoxC()

return DE_REFRESH



// ---------------------------------------------------------
// ispravka svih stavki
// ---------------------------------------------------------
function EditAll()

// ovu opciju moze pozvati i asistent alt+F10 !
PushWA()
select kalk_pripr

Box( "anal", __box_x, __box_y, .f., "Ispravka naloga" )

    nDug := 0
    nPot := 0

    do while !eof()
        skip
        nTR2:=RECNO()
        skip-1
        Scatter()
        _ERROR:=""
        if left(_idkonto2,3) == "XXX"
            // 80-ka
            skip
            skip
            nTR2 := RECNO()
            skip-1
            Scatter()
            _ERROR:=""
            if left(_idkonto2,3) == "XXX"
                exit
            endif
        endif
            
        nRbr:=RbrUNum(_Rbr)
        IF lAsistRadi
                    
            // pocisti bafer
            CLEAR TYPEAHEAD
            // spucaj mu dovoljno entera za jednu stavku
            cSekv:=""
            for nkekk:=1 to 17
                cSekv+=cEnter
            next
            keyboard cSekv
        ENDIF
            
        if EditPRIPR(.f.)==0
            exit
        endif
            
        select kalk_pripr
        
        if _ERROR<>"1"
            _ERROR:="0"
        endif       
        // stavka onda postavi ERROR
        _oldval:=_mpcsapp*_kolicina  // vrijednost prosle stavke
        _oldvaln:=_nc*_kolicina
        Gather()
        
        if _idvd $ "16#80" .and. !empty(_idkonto2)
            
            cIdkont:=_idkonto
            cIdkont2:=_idkonto2
            _idkonto:=cidkont2
            _idkonto2:="XXX"
            _kolicina:=-kolicina
                         
            // uvecaj redni broj stavke
            nRbr := RbrUNum( _rbr ) + 1
            _Rbr := RedniBroj( nRbr )
  
            Box( "", __box_x, __box_y, .f., "Protustavka" )
                seek _idfirma+_idvd+_brdok+_rbr
                _Tbanktr:="X"
                do while !eof() .and. _idfirma+_idvd+_brdok+_rbr == idfirma+idvd+brdok+rbr
                    if left(idkonto2,3)=="XXX"
                        Scatter()
                        _TBankTr:=""
                        exit
                    endif
                    skip
                enddo
                _idkonto:=cidkont2
                _idkonto2:="XXX"
                if _idvd=="16"
                    Get1_16b()
                else
                    Get1_80b()
                endif
                        
                if _TBanktr=="X"
                    append ncnl
                endif
                if _ERROR<>"1"
                    _ERROR:="0"
                endif       
                // stavka onda postavi ERROR
                Gather()
            BoxC()
        endif
        go nTR2
    enddo
       
    Beep(1)
        
    clear typeahead
    PopWA()

BoxC()

lAsistRadi := .f.

return DE_REFRESH



/*! \fn KnjizAsistent()
 *  \brief Asistent za obradu stavki dokumenta u kalk_pripremi
 */

function KnjizAsistent()
lAutoAsist := .f.
lAsistRadi:=.t.
cSekv := CHR(K_CTRL_A)
keyboard cSekv
return DE_REFRESH



/*! \fn MeniF10()
 *  \brief Meni ostalih opcija koji se poziva tipkom F10 u tabeli kalk_pripreme
 */

function MeniF10()
private opc[9]

opc[1]:="1. prenos dokumenta fakt->kalk                                  "
opc[2]:="2. povrat dokumenta u pripremu"
opc[3]:="3. priprema -> smece"
opc[4]:="4. smece    -> priprema"
opc[5]:="5. najstariji dokument iz smeca u pripremu"
opc[6]:="6. generacija dokumenta inventure magacin "
opc[7]:="7. generacija dokumenta inventure prodavnica"
opc[8]:="8. generacija nivelacije prodavn. na osnovu niv. za drugu prod"
opc[9]:="9. parametri obrade - nc / obrada sumnjivih dokumenata"
h[1]:=h[2]:=""

select kalk_pripr
go top

cIdVDTek := IdVD  
// tekuca vrsta dokumenta

if cIdVdTek=="19"
    AADD(opc,"A. obrazac promjene cijena")
else
    AADD(opc,"--------------------------")
endif

AADD( opc , "B. pretvori 11 -> 41  ili  11 -> 42"        )
AADD( opc , "C. promijeni predznak za kolicine"          )
AADD( opc , "D. preuzmi tarife iz sifrarnika"            )
AADD( opc , "E. storno dokumenta"                        )
AADD( opc , "F. prenesi VPC(sifr)+POREZ -> MPCSAPP(dok)" )
AADD( opc , "G. prenesi MPCSAPP(dok)    -> MPC(sifr)"    )
AADD( opc , "H. prenesi VPC(sif)        -> VPC(dok)"     )
AADD( opc , "I. povrat (12,11) -> u drugo skl.(96,97)"   )
AADD( opc , "J. zaduzenje prodavnice iz magacina (10->11)"   )
AADD( opc , "K. veleprodaja na osnovu dopreme u magacin (16->14)"   )

close all

private am_x:=m_x,am_y:=m_y
private Izbor:=1

do while .t.
          Izbor:=menu("prip",opc,Izbor,.f.)
          do case
            case Izbor==0
                EXIT
            case izbor == 1
               if gVodiSamoTarife=="D"
                  Gen41S()
               else
                  FaktKalk()
               endif
            case izbor == 2
                Povrat_kalk_dokumenta()
            case izbor == 3
                azur_kalk_pripr9()
            case izbor == 4
                Povrat9()
            case izbor == 5
                P9najst()

            case izbor == 6
               im()
            case izbor == 7
               ip()
            case izbor == 8
                GenNivP()
            case izbor == 9
                aRezim:={gCijene,gMetodaNC}
                O_PARAMS
                private cSection:="K",cHistory:=" "; aHistory:={}
                cIspravka:="D"
                kalk_par_metoda_nc()
                select params; use
                IF gCijene<>aRezim[1] .or. gMetodaNC<>aRezim[2]
                  IF gCijene=="1".and.gMetodaNC==" "
                    Soboslikar({{m_x+17,m_y+1,m_x+20,m_y+77}},23,14)
                  ELSEIF aRezim[1]=="1".and.aRezim[2]==" "
                    Soboslikar({{m_x+17,m_y+1,m_x+20,m_y+77}},14,23)
                  ENDIF
                ENDIF

            case izbor == 10 .and. cIdVDTek=="19"
                o_kalk_edit()
                select kalk_pripr
                go top
                cidfirma:=idfirma
                cidvd:=idvd
                cbrdok:=brdok
                Obraz19()
                select kalk_pripr
                go top
                RETURN DE_REFRESH

            case izbor == 11
                Iz11u412()

            case izbor == 12
                PlusMinusKol()

            case izbor == 13
                UzmiTarIzSif()

            case izbor == 14
                storno_kalk_dokument()

            case izbor == 15
                DiskMPCSAPP()

            case izbor == 16
                IF SigmaSif("SIGMAXXX")
                  IF Pitanje(,"Koristiti dokument u kalk_pripremi (D) ili azurirani (N) ?","N")=="D"
                    MPCSAPPuSif()
                  ELSE
                    MPCSAPPiz80uSif()
                  ENDIF
                ENDIF

            case izbor == 17
                VPCSifUDok()

            case izbor == 18
                Iz12u97()     // 11,12 -> 96,97

            case izbor == 19
                Iz10u11()

            case izbor == 20
                Iz16u14()


            endcase
enddo
m_x:=am_x; m_y:=am_y
o_kalk_edit()
return DE_REFRESH




/*! \fn MeniF11()
 *  \brief Meni ostalih opcija koji se poziva tipkom F11 u tabeli kalk_pripreme
 */

function MeniF11()
private opc:={}
private opcexe:={}

AADD(opc, "1. preuzimanje kalkulacije iz druge firme        ")
AADD(opcexe, {|| IzKalk2f()})
AADD(opc, "2. ubacivanje troskova-uvozna kalkulacija")
AADD(opcexe, {|| KalkTrUvoz()})
AADD(opc, "3. pretvori maloprodajni popust u smanjenje MPC")
AADD(opcexe, {|| PopustKaoNivelacijaMP()})
AADD(opc, "4. obracun poreza pri uvozu")
AADD(opcexe, {|| ObracunPorezaUvoz()})
AADD(opc, "5. pregled smeca")
AADD(opcexe, {|| kalk_pripr9View()})
AADD(opc, "6. brisi sve protu-stavke")
AADD(opcexe, {|| ProtStErase()})
AADD(opc, "7. setuj sve NC na 0")
AADD(opcexe, {|| SetNcTo0()})
AADD(opc, "8. renumeracija kalk priprema")
AADD(opcexe, {|| renumeracija_kalk_pripr( nil, nil, .f. )})
AADD(opc, "9. provjeri duple stavke u pripremi")
AADD(opcexe, {|| _kalk_pripr_duple_stavke() })

close all
private am_x:=m_x,am_y:=m_y
private Izbor:=1

Menu_SC("osop2")
m_x := am_x
m_y := am_y

o_kalk_edit()

return DE_REFRESH



/*! \fn ProtStErase()
 *  \brief Brisi sve protustavke
 */
 function ProtStErase()

if Pitanje(,"Pobrisati protustavke dokumenta (D/N)?", "N") == "N"
    return
endif

O_KALK_PRIPR
select kalk_pripr
go top

do while !EOF()
    if "XXX" $ idkonto2
        delete
    endif
    skip
enddo

__dbPack()

go top
return



/*! \fn SetNcTo0()
 *  \brief Setuj sve NC na 0
 */
function SetNcTo0()

if Pitanje(, "Setovati NC na 0 (D/N)?", "N") == "N"
    return
endif

O_KALK_PRIPR
select kalk_pripr
go top
do while !EOF()
    Scatter()
    _nc := 0
    Gather()
    skip
enddo

go top
return




//ulaz _IdFirma, _IdRoba, ...., nRBr (val(_RBr))
function EditPripr(fNovi)
private nMarza := 0
private nMarza2 := 0
private nR
private PicDEM := "9999999.99999999"
private PicKol := gPicKol

nStrana := 1

do while .t.

    @ m_x + 1, m_y + 1 CLEAR TO m_x + __box_x, m_y + __box_y

    SETKEY( K_PGDN, {|| NIL} )
    SETKEY( K_PGUP, {|| NIL} )
    // konvertovanje valute - ukljuci
    SETKEY( K_CTRL_K, {|| a_val_convert() } )

    if nStrana == 1
        nR := GET1( fnovi )
    elseif nStrana==2
        nR := GET2( fnovi )
    endif

    SETKEY( K_PGDN, NIL )
    SETKEY( K_PGUP, NIL )
    // konvertovanje valute - iskljuci
    SETKEY( K_CTRL_K, NIL )

    set escape on

    if nR == K_ESC
        exit
    elseif nR == K_PGUP
        --nStrana
    elseif nR == K_PGDN .or. nR == K_ENTER
        ++nStrana
    endif

    if nStrana==0
        nStrana++
    elseif nStrana>=3
        exit
    endif

enddo

if lastkey() <> K_ESC
    _Rbr := RedniBroj( nRbr )
    _Dokument := P_TipDok( _IdVD, -2 )
    return 1
else
    return 0
endif

return





/*! \fn Get1()
 *  \param fnovi
 *  \brief Prva strana/prozor maske unosa/ispravke stavke dokumenta
 */

function Get1()
parameters fnovi

private pIzgSt := .f.   
private Getlist := {}

if Get1Header() == 0
    return K_ESC
endif

if _idvd=="10"

    if nRbr == 1 .and. !IsPDV()
        if gVarEv=="2" .or. glEkonomat .or. Pitanje(,"Skracena varijanta (bez troskova) D/N ?","D")=="D"
                gVarijanta := "1"
        else
                gVarijanta := "2"
        endif
    endif

    if IsPDV()
        return Get1_10PDV()
    else
        return if( gVarijanta == "1", Get1_10s(), Get1_10() )
    endif

elseif _idvd=="11"
    return GET1_11()
elseif _idvd=="12"
    return GET1_12()
elseif _idvd=="13"
    return GET1_12()
elseif _idvd=="14"  //.or._idvd=="74"
    if IsPDV()
        return Get1_14PDV()
    else
        return GET1_14()
    endif
elseif _idvd=="KO"   // vindija KO
    if IsPDV()
        return GET1_14PDV()
    else
        return GET1_14()
    endif
elseif _idvd=="15"
    if !IsPDV()
        return GET1_15()
    endif
elseif _idvd=="16"
    if IsPDV()
        return GET1_16PDV()
    else
        return GET1_16()
    endif
elseif _idvd=="18"
    return GET1_18()
elseif _idvd=="19"
    return GET1_19()
elseif _idvd $ "41#42#43#47#49"
    return GET1_41()
elseif _idvd == "81"
    return get1_81()
elseif _idvd == "80"
    return GET1_80()
elseif _idvd=="24"
    if IsPDV()
        return GET1_24PDV()
    else
        return GET1_24()
    endif
elseif _idvd $ "95#96#97"
    return GET1_95()

elseif _idvd $  "94#16"    // storno fakture, storno otpreme, doprema

    return GET1_94()
elseif _idvd == "82"
    return GET1_82()
elseif _idvd == "IM"
    return GET1_IM()
elseif _idvd == "IP"
    return GET1_IP()
elseif _idvd == "RN"
    return GET1_RN()
elseif _idvd == "PR"
    return GET1_PR()
else
    return K_ESC
endif
return


// ----------------------------------------------------------
// ispisuje naziv sifre na zeljenoj lokaciji
// ----------------------------------------------------------
function ispisi_naziv_sifre( area, id, x, y, len )
local _naz := ""
local _t_area := SELECT()

if EMPTY( id )
    return .t.
endif

select ( area )
    
if (area)->(fieldpos("naz")) <> 0

    _naz := ALLTRIM( field->naz )

    if (area)->(fieldpos("jmj")) <> 0
        if LEN( _naz ) >= len
            _naz := PADR( _naz, len - 6 )
        endif
        _naz += " (" + ALLTRIM( field->jmj ) + ")"
    endif

endif

@ x, y SAY PADR( _naz, len )

select ( _t_area )
return .t.



/*! \fn Get2()
 *  \param fnovi
 *  \brief Druga strana/prozor maske unosa/ispravke stavke dokumenta
 */

function Get2()
parameters fnovi

if _idvd $ "10"
    if !IsPDV()
        return Get2_10()
    endif
elseif _idvd == "RN"
  return Get2_RN()
elseif _idvd == "PR"
  return Get2_PR()
endif

return K_ESC





static function init_hdok(idfirma, idvd, datdok, h_dok)

h_dok["idfirma"] := idfirma
h_dok["idvd"]    := idvd
h_dok["brdok"]  := ""
h_dok["datdok"] := datdok

return .t.


function Get1Header()
local _konto, _h_dok := hb_hash()

if fnovi
    _idfirma := gFirma
endif

if fnovi .and. _TBankTr=="X"
    _TBankTr := "%"
endif  

// izgenerisani izlazi

if gNW $ "DX"
    @  m_x + 1, m_y + 2 SAY "Firma: " 
    ?? gFirma, "-", gNFirma
else
    @  m_x + 1, m_y + 2 SAY "Firma:" GET _IdFirma VALID P_Firma(@_IdFirma,1,25) .and. len(trim(_idFirma))<=2
endif

@  m_x + 2, m_y + 2 SAY "KALKULACIJA: "
@  m_x + 2, col() SAY "Vrsta:" get _idvd valid P_TipDok( @_idvd, 2, 25 ) PICT "@!"

@ m_x + 2, COL() + 2 SAY "Datum:" GET _DatDok VALID init_hdok(_idfirma, _idvd, _datdok, @_h_dok)
read

ESC_RETURN 0

if fNovi .and. ( _idfirma <> idfirma .or. _idvd <> idvd )


     if glBrojacPoKontima

        Box( "#Glavni konto", 3, 70 )
            if _idvd $ "10#16#18#IM#"
                @ m_x+2, m_y+2 SAY "Magacinski konto zaduzuje" GET _idKonto VALID P_Konto(@_idKonto) PICT "@!"
                read
                _konto := _idKonto
            else
                @ m_x+2, m_y+2 SAY "Magacinski konto razduzuje" GET _idKonto2 VALID P_Konto(@_idKonto2) PICT "@!"
                read
                _konto = _idKonto2
            endif
        BoxC()
        _brDok := kalk_novi_broj_dokumenta(_h_dok, _konto)

    else
        _brDok := kalk_novi_broj_dokumenta(_h_dok)
    endif

    select kalk_pripr

endif

@ m_x + 2, m_y + 42  SAY "Broj:" GET _BrDok valid {|| !P_Kalk(_IdFirma, _IdVD, _BrDok) }


@ m_x + 3, m_y + 2  SAY "Redni broj stavke:" GET nRBr PICT '9999'

read

if fNovi .and. LastKey()==K_ESC
   kalk_rewind(_idfirma, _idvd, _datdok, _brdok)
endif

ESC_RETURN 0

return 1





/*! \fn VpcSaPpp()
 *  \brief Vrsi se preracunavanje veleprodajnih cijena ako je _VPC=0
 */

function VpcSaPpp()
*{
if _VPC==0
  _RabatV:=0
  _VPC:=(_VPCSAPPP+_NC*tarifa->vpp/100)/(1+tarifa->vpp/100+_mpc/100)
  nMarza:=_VPC-_NC
  _VPCSAP:=_VPC+nMarza*TARIFA->VPP/100
  _PNAP:=_VPC*_mpc/100
  _VPCSAPP:=_VPC+_PNAP
endif
ShowGets()
return .t.
*}




/*! \fn RaspTrosk(fSilent)
 *  \brief Rasporedjivanje troskova koji su predvidjeni za raspored. Takodje se koristi za raspored ukupne nabavne vrijednosti na pojedinacne artikle kod npr. unosa pocetnog stanja prodavnice ili magacina
 */

function RaspTrosk(fSilent)
*{
local nStUc:=20

if fsilent==NIL
  fsilent:=.f.
endif
if fsilent .or.  Pitanje(,"Rasporediti troskove ??","N")=="D"
   private qqTar:=""
   private aUslTar:=""
   if idvd $ "16#80"
     Box(,1,55)
      if idvd=="16"
       @ m_x+1,m_y+2 SAY "Stopa marze (vpc - stopa*vpc)=nc:" GET nStUc pict "999.999"
      else
       @ m_x+1,m_y+2 SAY "Stopa marze (mpc-stopa*mpcsapp)=nc:" GET nStUc pict "999.999"
      endif
      read
     BoxC()
   endif
   go top

   select F_KONCIJ
   if !used(); O_KONCIJ; endif
   select koncij
   seek trim(kalk_pripr->mkonto)
   select kalk_pripr

   if IsVindija()
    PushWA()
    if !EMPTY(qqTar)
        aUslTar:=Parsiraj(qqTar,"idTarifa")
        if aUslTar<>nil .and. !aUslTar==".t."
            set filter to &aUslTar
        endif
    endif
   endif

   do while !eof()
      nUKIzF:=0
      nUkProV:=0
      cIdFirma:=idfirma;cIdVD:=idvd;cBrDok:=Brdok
      nRec:=recno()
      do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok
         if cidvd $ "10#16#81#80"    
           // zaduzenje magacina,prodavnice
           nUkIzF+=round(fcj*(1-Rabat/100)*kolicina,gZaokr)
         endif
         if cidvd $ "11#12#13"    
           // magacin-> prodavnica,povrat
           nUkIzF+=round(fcj*kolicina,gZaokr)
         endif
         if cidvd $ "RN"
           if val(Rbr)<900
            nUkProV+=round(vpc*kolicina,gZaokr)
           else
            nUkIzF+=round(nc*kolicina,gZaokr)  // sirovine
           endif
         endif
         skip
      enddo
      if cidvd $ "10#16#81#80#RN"  // zaduzenje magacina,prodavnice
       go nRec
       RTPrevoz:=.f.; RPrevoz:=0
       RTCarDaz:=.f.;RCarDaz:=0
       RTBankTr:=.f.;RBankTr:=0
       RTSpedTr:=.f.;RSpedTr:=0
       RTZavTr:=.f.;RZavTr:=0
       if TPrevoz=="R"; RTPrevoz:=.t.;RPrevoz:=Prevoz; endif
       if TCarDaz=="R"; RTCarDaz:=.t.;RCarDaz:=CarDaz; endif
       if TBankTr=="R"; RTBankTr:=.t.;RBankTr:=BankTr; endif
       if TSpedTr=="R"; RTSpedTr:=.t.;RSpedTr:=SpedTr; endif
       if TZavTr =="R"; RTZavTr :=.t.;RZavTr :=ZavTr ; endif

       UBankTr:=0   // do sada utroçeno na bank tr itd, radi "sitniça"
       UPrevoz:=0
       UZavTr:=0
       USpedTr:=0
       UCarDaz:=0
       do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok
         Scatter()

         if _idvd $ "RN" .and. val(_rbr)<900
            _fcj:=_fcj2:= _vpc/nUKProV*nUkIzF
            // nabavne cijene izmisli proporcionalno prodajnim
         endif

         if RTPrevoz    //troskovi 1
             if round(nUkIzF,4)==0
              _Prevoz:=0
             else
              _Prevoz:=round( _fcj*(1-_Rabat/100)*_kolicina/nUkIzF*RPrevoz ,gZaokr)
              UPrevoz+=_Prevoz
              if abs(RPrevoz-UPrevoz)< 0.1 // sitniç, baci ga na zadnju st.
                   skip
                   if .not. ( !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok )
                     _Prevoz+=(RPrevoz-UPrevoz)
                   endif
                   skip -1
              endif
             endif
             _TPrevoz:="U"
         endif
         if RTCarDaz   //troskovi 2
             if round(nUkIzF,4)==0
              _CarDaz:=0
             else
              _CarDaz:=round( _fcj*(1-_Rabat/100)*_kolicina/nUkIzF*RCarDaz ,gZaokr)
              UCardaz+=_Cardaz
              if abs(RCardaz-UCardaz)< 0.1 // sitniç, baci ga na zadnju st.
                   skip
                   if .not. ( !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok )
                     _Cardaz+=(RCardaz-UCardaz)
                   endif
                   skip -1
              endif
             endif
             _TCarDaz:="U"
         endif
         if RTBankTr  //troskovi 3
             if round(nUkIzF,4)==0
              _BankTr:=0
             else
              _BankTr:=round( _fcj*(1-_Rabat/100)*_kolicina/nUkIzF*RBankTr ,gZaokr)
              UBankTr+=_BankTr
              if abs(RBankTr-UBankTr)< 0.1 // sitniç, baci ga na zadnju st.
                   skip
                   if .not. ( !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok )
                     _BankTr+=(RBankTr-UBankTr)
                   endif
                   skip -1
              endif
             endif
             _TBankTr:="U"
         endif
         if RTSpedTr    //troskovi 4
             if round(nUkIzF,4)==0
              _SpedTr:=0
             else
              _SpedTr:=round(_fcj*(1-_Rabat/100)*_kolicina/nUkIzF*RSpedTr,gZaokr)
              USpedTr+=_SpedTr
              if abs(RSpedTr-USpedTr)< 0.1 // sitniç, baci ga na zadnju st.
                   skip
                   if .not. ( !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok )
                     _SpedTr+=(RSpedTr-USpedTr)
                   endif
                   skip -1
              endif
             endif
             _TSpedTr:="U"
         endif
         if RTZavTr    //troskovi
             if round(nUkIzF,4)==0
              _ZavTr:=0
             else
              _ZavTr:=round( _fcj*(1-_Rabat/100)*_kolicina/nUkIzF*RZavTr ,gZaokr)
              UZavTR+=_ZavTR
              if abs(RZavTR-UZavTR)< 0.1 // sitniç, baci ga na zadnju st.
                   skip
                   if .not. ( !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok )
                     _ZavTR+=(RZavTR-UZavTR)
                   endif
                   skip -1
              endif
             endif
             _TZavTr:="U"
         endif
         select roba; hseek _idroba
         select tarifa; hseek _idtarifa; select kalk_pripr
         if _idvd=="RN"
           if val(_rbr)<900
            NabCj()
           endif
         else
            NabCj()
         endif
         if _idvd=="16"
           _nc:=_vpc*(1-nStUc/100)
         endif
         if _idvd=="80"
           _nc:=_mpc-_mpcsapp*nStUc/100
           _vpc:=_nc
           _TMarza2:="A"
           _Marza2:=_mpc-_nc
         endif
         if koncij->naz=="N1"; _VPC:=_NC; endif
         if _idvd=="RN"
           if val(_rbr)<900
            Marza()
           endif
         else
            Marza()
         endif

         Gather()
         skip
       enddo
      endif //cidvd $ 10
      if cidvd $ "11#12#13"
       go nRec
       RTPrevoz:=.f.;RPrevoz:=0
       if TPrevoz=="R"; RTPrevoz:=.t.;RPrevoz:=Prevoz; endif
       nMarza2:=0
       do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok
         Scatter()
         if RTPrevoz    //troskovi 1
             if round(nUkIzF,4)==0
              _Prevoz:=0
             else
              _Prevoz:=_fcj/nUkIzF*RPrevoz
             endif
             _TPrevoz:="A"
         endif
         _nc:=_fcj+_prevoz
         if koncij->naz=="N1"; _VPC:=_NC; endif
         _marza:=_VPC-_FCJ
         _TMarza:="A"
         select roba
         hseek _idroba
         select tarifa
         hseek _idtarifa
         select kalk_pripr
         Marza2()
         _TMarza2:="A"
         _Marza2:=nMarza2
         Gather()
         skip
       enddo
      endif //cidvd $ "11#12#13"
   enddo  // eof()

   if IsVindija()
    select kalk_pripr
    PopWA()
   endif

endif // pitanje
go top
return
*}




/*! \fn Savjetnik()
 *  \brief Zamisljeno da se koristi kao pomoc u rjesavanju problema pri unosu dokumenta. Nije razradjeno.
 */

function Savjetnik()
 LOCAL nRec:=RECNO(),lGreska:=.f.

 MsgO("Priprema izvjestaja...")
 set console off
 cKom:=PRIVPATH+"savjeti.txt"
 set printer off
 set device to printer
 cDDir:=SET(_SET_DEFAULT)
 set default to
 set printer to (ckom)
 set printer on
 SET(_SET_DEFAULT,cDDir)

SELECT kalk_pripr
GO TOP

DO WHILE !EOF()
 lGreska:=.f.
 DO CASE

  CASE idvd=="11"     // magacin->prodavnica
    IF vpc==0
      OpisStavke(@lGreska)
      ? "PROBLEM: - veleprodajna cijena = 0"
      ? "OPIS:    - niste napravili ulaz u magacin, ili nemate veleprodajnu"
      ? "           cijenu (VPC) u sifrarniku za taj artikal"
    ENDIF

 ENDCASE

 IF EMPTY(datdok)
   OpisStavke(@lGreska)
   ? "DATUM KALKULACIJE NIJE UNESEN!!!"
 ENDIF

 IF EMPTY(error)
   OpisStavke(@lGreska)
   ? "STAVKA PRIPADA AUTOMATSKI FORMIRANOM DOKUMENTU !!!"
   ? "Pokrenite opciju <A> - asistent ako zelite da program sam prodje"
   ? "kroz sve stavke ili udjite sa <Enter> u ispravku samo ove stavke."
   IF idvd=="11"
     ? "Kada pokrenete <A> za ovu kalkulaciju (11), veleprodajna"
     ? "cijena ce biti preuzeta: 1) Ako program omogucava azuriranje"
     ? "sumnjivih dokumenata, VPC ce ostati nepromijenjena; 2) Ako program"
     ? "radi tako da ne omogucava azuriranje sumnjivih dokumenata, VPC ce"
     ? "biti preuzeta iz trenutne kartice artikla. Ako nemate evidentiranih"
     ? "ulaza artikla u magacin, bice preuzeta 0 sto naravno nije korektno."
   ENDIF
 ENDIF

 If lGreska; ?; ENDIF
 SKIP 1
ENDDO

 set printer to
 set printer off
 set console on
 SET DEVICE TO SCREEN
 set printer to
 MsgC()
 save screen to cS
 VidiFajl(cKom)
 restore screen from cS
 SELECT kalk_pripr
 GO (nRec)
return



/*! \fn OpisStavke(lGreska)
 *  \brief Daje informacije o dokumentu i artiklu radi lociranja problema. Koristi je opcija "savjetnik"
 *  \sa Savjetnik()
 */

function OpisStavke(lGreska)
 IF !lGreska
  ? "Dokument:    "+idfirma+"-"+idvd+"-"+brdok+", stavka "+rbr
  ? "Artikal: "+idroba+"-"+LEFT(Ocitaj(F_ROBA,idroba,"naz"), 40)
  lGreska:=.t.
 ENDIF
return




function Soboslikar(aNiz,nIzKodaBoja,nUKodBoja)
 LOCAL i, cEkran
  FOR i:=1 TO LEN(aNiz)
    cEkran:=SAVESCREEN(aNiz[i,1],aNiz[i,2],aNiz[i,3],aNiz[i,4])
    cEkran:=STRTRAN(cEkran,CHR(nIzKodaBoja),CHR(nUKodBoja))
    RESTSCREEN(aNiz[i,1],aNiz[i,2],aNiz[i,3],aNiz[i,4],cEkran)
  NEXT
return


function kalk_zagl_firma()
P_12CPI
U_OFF
B_OFF
I_OFF
? "Subjekt:"
U_ON
?? PADC(TRIM(gTS)+" "+TRIM(gNFirma),39)
U_OFF
? "Prodajni objekat:"
U_ON
?? PADC(ALLTRIM(NazProdObj()),30)
U_OFF
? "(poslovnica-poslovna jedinica)"
? "Datum:"
U_ON
?? PADC(SrediDat(DATDOK),18)
U_OFF
?
?
return


static function NazProdObj()
 LOCAL cVrati:=""
  SELECT KONTO
  SEEK kalk_pripr->pkonto
  cVrati:=naz
  SELECT kalk_pripr
return cVrati




function IzbDokOLPP()

do while .t.

    o_kalk_edit()

    select kalk_pripr
    set order to tag "1"
    go top

    cIdFirma := field->IdFirma
    cBrDok := field->BrDok
    cIdVD := field->IdVD

    if eof()
        exit
    endif

    if empty(cidvd+cbrdok+cidfirma) .or. ! (cIdVd $ "11#19#81#80")
        skip
        loop
    endif

    Box("",2,50)
        set cursor on
        @ m_x+1,m_y+2 SAY "Dokument broj:"
        if gNW $ "DX"
            @ m_x+1,col()+2  SAY cIdFirma
        else
            @ m_x+1,col()+2 GET cIdFirma
        endif
        @ m_x+1,col()+1 SAY "-" GET cIdVD  VALID cIdVd $ "11#19#81#80"  PICT "@!"
        @ m_x+1,col()+1 SAY "-" GET cBrDok
        read; ESC_BCR

    BoxC()

    HSEEK cIdFirma+cIdVD+cBrDok
    EOF CRET

    KalkStOLPP()

enddo

close all
return




/*! \fn PlusMinusKol()
 *  \brief Mijenja predznak kolicini u svim stavkama u kalk_pripremi
 */

function PlusMinusKol()
*{
  o_kalk_edit()
  SELECT kalk_pripr
  GO TOP
  DO WHILE !EOF()
    Scatter()
      _kolicina := -_kolicina
      _ERROR := " "
    Gather()
    SKIP 1
  ENDDO
  // Msg("Automatski pokrecem asistenta (Alt+F10)!",1)
  // lAutoAsist:=.t.
  KEYBOARD CHR(K_ESC)
CLOSERET
return
*}




/*! \fn UzmiTarIzSif()
 *  \brief Filuje tarifu u svim stavkama u kalk_pripremi odgovarajucom sifrom tarife iz sifrarnika robe
 */

function UzmiTarIzSif()
*{
  o_kalk_edit()
  SELECT kalk_pripr
  GO TOP
  DO WHILE !EOF()
    Scatter()
      _idtarifa := Ocitaj(F_ROBA,_idroba,"idtarifa")
      _ERROR := " "
    Gather()
    SKIP 1
  ENDDO
  Msg("Automatski pokrecem asistenta (opcija A)!",1)
  lAutoAsist:=.t.
  KEYBOARD CHR(K_ESC)
CLOSERET
return
*}




/*! \fn DiskMPCSAPP()
 *  \brief Formira diskontnu maloprodajnu cijenu u svim stavkama u kalk_pripremi
 */

function DiskMPCSAPP()
*{
aPorezi:={}
o_kalk_edit()
SELECT kalk_pripr
GO TOP
DO WHILE !EOF()
    SELECT ROBA
    HSEEK kalk_pripr->idroba
    SELECT TARIFA
    HSEEK ROBA->idtarifa
    Tarifa(kalk_pripr->pKonto,kalk_pripr->idRoba,@aPorezi)
    SELECT kalk_pripr
    Scatter()
    
    _mpcSaPP:=MpcSaPor(roba->vpc,aPorezi)
    
    _ERROR := " "
    Gather()
    SKIP 1
ENDDO
Msg("Automatski pokrecem asistenta (opcija A)!",1)
lAutoAsist:=.t.
KEYBOARD CHR(K_ESC)
CLOSERET
return
*}



/*! \fn MPCSAPPuSif()
 *  \brief Maloprodajne cijene svih artikala u kalk_pripremi kopira u sifrarnik robe
 */

function MPCSAPPuSif()
*{
  o_kalk_edit()
  SELECT kalk_pripr
  GO TOP
  DO WHILE !EOF()
    cIdKonto:=kalk_pripr->pkonto
    SELECT KONCIJ; HSEEK cIdKonto
    SELECT kalk_pripr
    DO WHILE !EOF() .and. pkonto==cIdKonto
      SELECT ROBA; HSEEK kalk_pripr->idroba
      IF FOUND()
        StaviMPCSif(kalk_pripr->mpcsapp,.f.)
      ENDIF
      SELECT kalk_pripr
      SKIP 1
    ENDDO
  ENDDO
CLOSERET
return
*}



/*! \fn MPCSAPPiz80uSif()
 *  \brief Maloprodajne cijene svih artikala iz izabranog azuriranog dokumenta tipa 80 kopira u sifrarnik robe
 */

function MPCSAPPiz80uSif()
*{
  o_kalk_edit()

  cIdFirma := gFirma
  cIdVdU   := "80"
  cBrDokU  := SPACE(LEN(kalk_pripr->brdok))

  Box(,4,75)
    @ m_x+0, m_y+5 SAY "FORMIRANJE MPC U SIFRARNIKU OD MPCSAPP DOKUMENTA TIPA 80"
    @ m_x+2, m_y+2 SAY "Dokument: "+cIdFirma+"-"+cIdVdU+"-"
    @ row(),col() GET cBrDokU VALID postoji_kalk_dok(cIdFirma+cIdVdU+cBrDokU)
    READ; ESC_BCR
  BoxC()

  // pocnimo
  SELECT KALK
  SEEK cIdFirma+cIdVDU+cBrDokU
  cIdKonto:=KALK->pkonto
  SELECT KONCIJ; HSEEK cIdKonto
  SELECT KALK
  DO WHILE !EOF() .and. cIdFirma+cIdVDU+cBrDokU == IDFIRMA+IDVD+BRDOK
    SELECT ROBA; HSEEK KALK->idroba
    IF FOUND()
      StaviMPCSif(KALK->mpcsapp,.f.)
    ENDIF
    SELECT KALK
    SKIP 1
  ENDDO

CLOSERET
return
*}




/*! \fn VPCSifUDok()
 *  \brief Filuje VPC u svim stavkama u kalk_pripremi odgovarajucom VPC iz sifrarnika robe
 */

function VPCSifUDok()
*{
  o_kalk_edit()
  SELECT kalk_pripr
  GO TOP
  DO WHILE !EOF()
    SELECT ROBA; HSEEK kalk_pripr->idroba
    SELECT KONCIJ; SEEK TRIM(kalk_pripr->mkonto)
    // SELECT TARIFA; HSEEK ROBA->idtarifa
    SELECT kalk_pripr
    Scatter()
      _vpc := KoncijVPC()
      _ERROR := " "
    Gather()
    SKIP 1
  ENDDO
  Msg("Automatski pokrecem asistenta (opcija A)!",1)
  lAutoAsist:=.t.
  KEYBOARD CHR(K_ESC)
CLOSERET
return
*}



// ------------------------------------------------
// otvara tabele za pregled izvjestaja
// ------------------------------------------------
static function _o_ctrl_tables( azurirana )

O_KONCIJ
O_ROBA
O_TARIFA
O_PARTN
O_KONTO
O_TDOK

if azurirana 
    O_SKALK   
    // alias kalk_pripr
else
    O_KALK_PRIPR
endif

return



// ---------------------------------------------------
// centralna funkcija za stampu dokumenta
// ---------------------------------------------------
function kalk_centr_stampa_dokumenta()
parameters fStara, cSeek, lAuto
local nCol1
local nCol2
local nPom

nCol1:=0
nCol2:=0
nPom:=0

PRIVATE PicCDEM :=gPICCDEM
PRIVATE PicProc :=gPICPROC
PRIVATE PicDEM  := gPICDEM
PRIVATE Pickol  := gPICKOL
private nStr:=0

if (pcount()==0)
    fstara:=.f.
endif

if (fStara == nil)
    fStara := .f.
endif

if (lAuto==nil)
    lAuto := .f.
endif

if (cSeek==nil)
    cSeek := ""
endif

close all

// otvori potrebne tabele
_o_ctrl_tables( fstara )

select kalk_pripr
set order to tag "1"
go top

fTopsD:=.f.
fFaktD:=.f.

do while .t.

    cIdFirma := IdFirma
    cBrDok := BrDok
    cIdVD := IdVD

    if eof()
        exit
    endif

    if empty( cIdvd + cBrdok + cIdfirma )
        skip
        loop
    endif
    
    if !lAuto
    
    if (cSeek == "")
        Box("",1,50)
            set cursor on
            @ m_x+1,m_y+2 SAY "Dokument broj:"
            if (gNW $ "DX")
                @ m_x+1,col()+2  SAY cIdFirma
            else
                @ m_x+1,col()+2 GET cIdFirma
            endif
            @ m_x+1,col()+1 SAY "-" GET cIdVD  pict "@!"
            @ m_x+1,col()+1 SAY "-" GET cBrDok valid kalk_fix_brdok(@cBrDok)
            read
            ESC_BCR
        BoxC()
    endif

    endif
    
    if ( !EMPTY( cSeek ) .and. cSeek != 'IZDOKS' )
        HSEEK cSeek
        cIdfirma:=substr(cSeek,1,2)
        cIdvd:=substr(cSeek,3,2)
        cBrDok:=padr(substr(cSeek,5,8) ,8)
    else
        HSEEK cIdFirma + cIdVD + cBrDok
    endif

    // provjeri da li kalkulacija ima sve cijene ?
    if !kalkulacija_ima_sve_cijene( cIdFirma, cIdVd, cBrDok )
        MsgBeep( "Unutar kalkulacije nedostaju pojedine cijene bitne za obracun!#Stampanje onemoguceno." )
        close all
        return
    endif

    if (cIdvd == "24")
        Msg("Kalkulacija 24 ima samo izvjestaj rekapitulacije !")
        close all
        return
    endif

    if (cSeek != 'IZDOKS')
        EOF CRET
    else
        private nStr:=1
    endif

    START PRINT CRET
    ?

    do while .t.
    
        if (cidvd=="10".and.!((gVarEv=="2").or.(gmagacin=="1")).or.(cidvd $ "11#12#13")).and.(c10Var=="3")
            gPSOld := gPStranica
            gPStranica := VAL(IzFmkIni("KALK","A3_GPSTRANICA","-20",EXEPATH))
            P_PO_L
        endif
    
        if (cSeek=='IZDOKS')  
            // stampaj sve odjednom !!!
            if (prow()>42)
                ++nStr
                FF
            endif
            select kalk_pripr
            cIdfirma:=kalk_doks->idfirma
            cIdvd:=kalk_doks->idvd
            cBrdok:=kalk_doks->brdok
            hseek cIdFirma+cIdVD+cBrDok
        endif

        Preduzece()

        if (cidvd=="10" .or. cidvd=="70") .and. !IsPDV()
            if (gVarEv=="2")
                StKalk10_sk()
            elseif (gMagacin=="1")
                    // samo po nabavnim
                StKalk10_1()
            else
                if (c10Var=="1")
                    StKalk10_2()
                elseif (c10Var=="2")
                    StKalk10_3()
                else
                    StKalk10_4()
                endif
            endif
        elseif cIdVD == "10" .and. IsPDV()
            if (gMagacin == "1")
                    // samo po nabavnim
                StKalk10_1()
            else
                // PDV ulazna kalkulacija
                StKalk10_PDV()
            endif
        elseif cidvd $ "15"
            if !IsPDV()
                StKalk15()
            endif
        elseif (cidvd $ "11#12#13")
            if (c10Var=="3")
                StKalk11_3()
            else
                if (gmagacin=="1")
                    StKalk11_1()
                else
                    StKalk11_2()
                endif
            endif
        elseif (cidvd $ "14#94#74#KO")
            if (c10Var=="3")
                Stkalk14_3()
            else
                if IsPDV()
                    StKalk14PDV()
                else
                    Stkalk14()
                endif
            endif
        elseif (cidvd $ "16#95#96#97") .and. IsPDV()
            if gPDVMagNab == "D"
                StKalk95_1()
            else
                StKalk95_PDV()
            endif
        elseif (cidvd $ "95#96#97#16") .and. !IsPDV()
            if (gVarEv=="2")
                Stkalk95_sk()
            elseif (gmagacin=="1")
                Stkalk95_1()
            else
                Stkalk95()
            endif
        elseif (cidvd $ "41#42#43#47#49")   
            // realizacija prodavnice
            if (IsJerry() .and. cIdVd$"41#42#47")
                StKalk47J()
            else
                StKalk41()
            endif
        elseif (cidvd == "18")
            StKalk18()
        elseif (cidvd == "19")
            if IsJerry()
                StKalk19J()
            else
                StKalk19()
            endif
        elseif (cidvd == "80")
            StKalk80()
        elseif (cidvd == "81")
            if IsJerry()
                StKalk81J()
            else
                if (c10Var=="1")
                    StKalk81()
                else
                    StKalk81_2()
                endif
            endif
        elseif (cidvd == "82")
            StKalk82()
        elseif (cidvd == "IM")
            StKalkIm()
        elseif (cidvd == "IP")
            StKalkIp()
        elseif (cidvd == "RN")
            if !fStara
                RaspTrosk(.t.)
            endif
            StkalkRN()
        elseif (cidvd == "PR")
            StkalkPR()
        endif

        if (cSeek != 'IZDOKS')
            exit

        else

            select kalk_doks
            skip
            if eof()
                exit
            endif
            ?
            ?

        endif
        
        if (cidvd == "10" .and. !((gVarEv=="2").or.(gmagacin=="1")).or.(cidvd $ "11#12#13")).and.(c10Var=="3")
            gPStranica:=gPSOld
            P_PO_P
        endif

    enddo // cSEEK

    if (gPotpis=="D")
        if (prow() > 57 + gPStranica)
            FF
            @ prow(),125 SAY "Str:"+str(++nStr,3)
        endif
        ?
        ?
        P_12CPI
        @ prow()+1,47 SAY "Obrada AOP  "; ?? replicate("_",20)
        @ prow()+1,47 SAY "Komercijala "; ?? replicate("_",20)
        @ prow()+1,47 SAY "Likvidatura "; ?? replicate("_",20)
    endif

    ?
    ?

    FF

    // zapamti tabelu, zapis na kojima si stao
    PushWa()
    close all
    END PRINT

    _o_ctrl_tables( fstara )
    PopWa()

    if (cidvd $ "80#11#81#12#13#IP#19")
        fTopsD:=.t.
    endif
    
    if (cidvd $ "10#11#81")
        fFaktD:=.t.
    endif

    if (!empty(cSeek))
        exit
    endif

enddo  // vrti kroz kalkulacije

if (fTopsD .and. !fstara .and. gTops!="0 ")
    start print cret
    select kalk_pripr
    set order to tag "1"
    go top
    cIdFirma:=IdFirma
    cBrDok:=BrDok
    cIdVD:=IdVD
    if (cIdVd $ "11#12")
        StKalk11_2(.t.)  //maksuzija za tops - bez NC
    elseif (cIdVd == "80")
        Stkalk80(.t.)
    elseif (cIdVd == "81")
        Stkalk81(.t.)
    elseif (cIdVd == "IP")
        StkalkIP(.t.)
    elseif (cIdVd == "19")
        Stkalk19()
    endif
    close all
    FF
    END PRINT

    kalk_generisi_tops_dokumente()

endif

if (fFaktD .and. !fStara .and. gFakt!="0 ")
    start print cret
    o_kalk_edit()
    select kalk_pripr
    set order to tag "1"
    go top
    cIdFirma:=IdFirma
    cBrDok:=BrDok
    cIdVD:=IdVD
    if (cIdVd $ "11#12")
        StKalk11_2(.t.)  //maksuzija za tops - bez NC
    elseif (cIdVd == "10")
        StKalk10_3(.t.)
    elseif (cIdVd == "81")
        StKalk81(.t.)
    endif
    close all
    FF
    END PRINT

endif

close all
return nil



// ---------------------------------------------------------------------
// provjerava da li kalkulacija ima sve potrebne cijene
// ---------------------------------------------------------------------
function kalkulacija_ima_sve_cijene( firma, tip_dok, br_dok )
local _ok := .t.
local _area := SELECT()
local _t_rec := RECNO()

do while !EOF() .and. field->idfirma + field->idvd + field->brdok == firma + tip_dok + br_dok

    if field->idvd $ "11#41#42#RN"
        if field->fcj == 0
            _ok := .f.
            exit
        endif
    elseif field->idvd $ "16#96#94#95#14#80#"
        if field->nc == 0
            _ok := .f.
            exit
        endif
    endif

    skip

enddo

select ( _area )
go ( _t_rec )

return _ok




/*! \fn PopustKaoNivelacijaMP()
 *  \brief Umjesto iskazanog popusta odradjuje smanjenje MPC
 */

function PopustKaoNivelacijaMP()
*{
local lImaPromjena
lImaPromjena:=.f.
o_kalk_edit()
select kalk_pripr
go top
do while !eof()
    if (!idvd="4" .or. rabatv==0)
        skip 1
        loop
    endif
    lImaPromjena:=.t.
    Scatter()
        _mpcsapp:=ROUND(_mpcsapp-_rabatv,2)
        _rabatv:=0
        private aPorezi:={}
        private fNovi:=.f.
        VRoba(.f.)
        WMpc(.t.)
        _error:=" "
        select kalk_pripr
    Gather()
    skip 1
enddo
if lImaPromjena
    Msg("Izvrsio promjene!",1)
    //lAutoAsist:=.t.
    keyboard CHR(K_ESC)
else
    MsgBeep("Nisam nasao nijednu stavku sa maloprodajnim popustom!")
endif
CLOSERET
return
*}



/*! \fn StOLPPAz()
 *  \brief Funkcija za stampu OLPP-a za azurirani KALK dokument
 */

function StOLPPAz()
*{
local nCol1
local nCol2
local nPom

nCol1:=0
nCol2:=0
nPom:=0

PRIVATE PicCDEM:=gPICCDEM
PRIVATE PicProc:=gPICPROC
PRIVATE PicDEM:= gPICDEM
PRIVATE Pickol:= gPICKOL

private nStr:=0

O_KONCIJ
O_ROBA
O_TARIFA
O_PARTN
O_KONTO
O_TDOK
O_SKALK   
// alias kalk_pripr

select kalk_pripr
set order to tag "1"
go top

do while .t.

    cIdFirma:=IdFirma
    cBrDok:=BrDok
    cIdVD:=IdVD

    if eof()
        exit
    endif

    if empty(cIdVd+cBrDok+cIdFirma)
        skip
        loop
    endif

    Box("",2,50)
        set cursor on
        @ m_x+1,m_y+2 SAY "Dokument broj:"
        if (gNW $ "DX")
            @ m_x+1,col()+2  SAY cIdFirma
        else
            @ m_x+1,col()+2 GET cIdFirma
        endif
        @ m_x+1,col()+1 SAY "-" GET cIdVD  valid cIdVd$"11#19#80#81" pict "@!"
        @ m_x+1,col()+1 SAY "-" GET cBrDok
        @ m_x+2, m_y+2 SAY "(moguce vrste KALK dok.su: 11,19,80,81)"
        read
        ESC_BCR
    BoxC()

    HSEEK cIdFirma+cIdVD+cBrDok

    EOF CRET

    KalkStOlpp()
        

enddo  // vrti kroz kalkulacije

close all

return nil



