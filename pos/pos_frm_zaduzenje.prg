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


/*! \fn Zaduzenje(cIdVd)
 *  \brief Dokument zaduzenja
 *
 *  cIdVD -  16 ulaz
 *           95 otpis
 *           IN inventura
 *           NI nivelacija
 *           96 razduzenje sirovina - ako se radi o proizvodnji
 *           PD - predispozicija
 *
 *  Zaduzenje odjeljenje/punktova robama/sirovinama
 *       lForsSir .T. - radi se o forsiranom zaduzenju odjeljenja
 *                           sirovinama
 */

*function Zaduzenje(cIdVd)
*{

function Zaduzenje
parameters cIdVd

local _from_kalk := .f.
local cOdg
local PrevDn
local PrevUp
local nSign

if gSamoProdaja == "D" .and. ( cIdVd <> VD_REK )
    MsgBeep("Ne mozete vrsiti zaduzenja !")
    return
endif

private ImeKol:={}
private Kol:={}
private oBrowse
private cBrojZad
private cIdOdj
private cRsDbf
private bRSblok
private cIdVd
private cRobSir:=" "
private dDatRada:=DATE()
private cBrDok:=nil
private bPrevZv
private bPrevUp
private bPrevDn

// dodatni podaci o reklamaciji
if ( IsPlanika() .and. cIdVd == VD_REK )
    private cRekOp1
    private cRekOp2
    private cRekOp3
    // postavi odmah da je "R" - realizovana radi odustajanja
    private cRekOp4:="R"
endif

// koristim ga kod sirovinskog zaduzenja odjeljenja
// ma kako se ono vodilo

if cIdVd == NIL
    cIdVd := "16"
else
    cIdVd := cIdVd
endif

ImeKol := { { "Sifra",    {|| idroba},      "idroba" }, ;
            { "Naziv",    {|| RobaNaz  },   "RobaNaz" },;
            { "JMJ",      {|| JMJ},         "JMJ"       },;
            { "Kolicina", {|| kolicina   }, "Kolicina"  },;
            { "Cijena",   {|| Cijena},      "Cijena"    } ;
          }
Kol := { 1, 2, 3, 4, 5 }

o_pos_tables()

Box(, 6, 60)

    cIdOdj:=SPACE(2)
    cIdDio:=SPACE(2)
    cRazlog:=SPACE(40)
    cIdOdj2:=SPACE(2)
    cIdPos:=gIdPos

    SET CURSOR ON

    if gVrstaRS == "S"
        @ m_x+1, m_y+3 SAY "Prodajno mjesto:" GET cIdPos pict "@!" valid cIdPos<="X ".and. !EMPTY(cIdPos)
    endif

    if gvodiodj == "D"
        @ m_x+3, m_y + 3 SAY   " Odjeljenje:" GET cIdOdj VALID P_Odj (@cIdOdj, 3, 28)
        if cIdVD=="PD"
            @ m_x+4, m_y + 3 SAY " Prenos na :" GET cIdOdj2 VALID P_Odj (@cIdOdj2, 4, 28)
        endif
    endif

    @ m_x+6,m_y+3 SAY " Datum dok:" GET dDatRada PICT "@D" VALID dDatRada <= DATE()
    
    READ
    ESC_BCR

BoxC()

cRSdbf := "ROBA"
bRSblok := { |x,y| pos_postoji_roba( @_idroba, x, y ), setspeczad() }
cUI_I := R_I
cUI_U := R_U

SELECT PRIPRZ

if RecCount2() > 0
    //ako je sta bilo ostalo, spasi i oslobodi pripremu
    SELECT _POS
    AppFrom( "PRIPRZ", .f. )
endif

SELECT priprz
my_dbf_zap()

// vrati ili pobrisi ono sto je poceo raditi ili prekini s radom
if !pos_vrati_dokument_iz_pripr( cIdVd, gIdRadnik, cIdOdj, cIdDio )
    my_close_all_dbf()
    return
endif

fSadAz := .f.

if ( cIdVd <> VD_REK ) .and. pos_preuzmi_iz_kalk( @cIdVd, @cBrDok, @cRsDBF )

    _from_kalk := .t.

    if priprz->( RecCount2() ) > 0

        if cBrDok <> NIL .and. Pitanje(,"Odstampati prenesni dokument na stampac ?", "N" ) == "D"

            if cIdVd $ "16#96#95#98"
                StampZaduz( cIdVd, cBrDok )
            elseif cIdVd $ "IN#NI"
                StampaInv()
            endif

            // otvori ponovo tabele
            o_pos_tables()

            if Pitanje(,"Ako je sve u redu, zelite li staviti na stanje dokument ?"," ")=="D"
                fSadAz := .t.
            endif

        endif
    endif

endif

if cIdVD == "NI"
    
    my_close_all_dbf()
    InventNivel( .f., .t., fSadaz, dDatRada )   
    return

elseif cIdVd == "IN"

    my_close_all_dbf()
    InventNivel( .t., .t., fSadAz, dDatRada )
    return

endif

select (F_PRIPRZ)

if !used()
    return
endif

if !fSadAz

    // browsanje dokumenta ...........
    SELECT PRIPRZ
    SET ORDER TO
    go  top

    Box (,20,77,,{"<*> - Ispravka stavke ","Storno - negativna kolicina"})
    @ m_x, m_y + 4 SAY PADC( "PRIPREMA " + NaslovDok( cIdVd ) + " NA ODJELJENJE " + ;
                        ALLTRIM( ODJ->Naz ) + IIF( !Empty( cIdDio ), ;
                        "-" + DIO->Naz, "" ), 70 ) COLOR Invert

    oBrowse := FormBrowse( m_x+6, m_y+1, m_x+19, m_y+77, ImeKol, Kol,{ "�", "�", "�"}, 0)
    oBrowse:autolite:=.f.

    PrevDn := SETKEY( K_PGDN, {|| DummyProc() })
    PrevUp := SETKEY( K_PGUP, {|| DummyProc() })

    SetSpecZad()

    SELECT PRIPRZ

    Scatter()

    _IdPos:=cIdPos
    _IdVrsteP:=cIdOdj2
    // vrste placanja su iskoristene za idodj2
    _IdOdj:=cIdOdj
    _IdDio:=cIdDio
    _IdVd:=cIdVd
    _BrDok:=SPACE(LEN(pos_doks->BrDok))
    _Datum:=dDatRada
    _Smjena:=gSmjena
    _IdRadnik:=gIdRadnik
    _IdCijena:="1"
    // ne interesuje me set cijena
    _Prebacen:=OBR_NIJE
    _MU_I:=cUI_U
    // ulaz
    if cIdVd==VD_OTP
        _MU_I:=cUI_I
        // kad je otpis imam izlaz
    endif

    SET CURSOR ON

    do while .t.

        do while !oBrowse:Stabilize() .and. ((Ch:=INKEY())==0)
            //Ol_Yield()
        enddo

        _idroba := SPACE (LEN (_idroba))
        _Kolicina := 0
        _cijena := 0
        _ncijena := 0
        _marza2 := 0
        _TMarza2 := "%"
        fMarza := " "

        @ m_x + 2, m_y + 25 SAY SPACE(40)
        
        if gDuzSifre <> nil .and. gDuzSifre > 0
            cDSFINI := ALLTRIM( STR( gDuzSifre ) )
        else
            cDSFINI := IzFMKIni('SifRoba','DuzSifra','10')
        endif

        @ m_x + 2, m_y + 5 SAY " Artikal:" GET _idroba pict "@!S" + cDSFINI ;
                    WHEN {|| _idroba := PADR( _idroba, VAL(cDSFINI)),.t.} ;
                    VALID EVAL (bRSblok, 2, 25) .and. ( gDupliArt == "D" .or. ZadProvDuple(_idroba))
        @ m_x + 4, m_y + 5 SAY "Kolicina:" GET _Kolicina PICT "999999.999" ;
                    WHEN{|| OsvPrikaz(),ShowGets(),.t.} ;
                    VALID ZadKolOK(_Kolicina)
        
        if gZadCij=="D"
            @ m_x + 3, m_y + 35  SAY "N.cijena:" GET _ncijena PICT "99999.9999"
            @ m_x + 3, m_y + 56  SAY "Marza:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICTURE "@!"
            @ m_x + 3, col() + 2 GET _Marza2 PICTURE "9999.99"
            @ m_x + 3, col() + 1 GET fMarza pict "@!" VALID {|| _marza2:=iif(_cijena<>0 .and. empty(fMarza), 0, _marza2),marza2(fmarza),_cijena:=iif(_cijena==0,_cijena:=_nCijena*(tarifa->zpp/100+(1+TARIFA->Opp/100)*(1+TARIFA->PPP/100)),_cijena),fMarza:=" ",.t.}
            @ m_x + 4, m_y + 35 SAY "MPC SA POREZOM:" GET _cijena  PICT "99999.999" valid {|| _marza2:=0, marza2(), ShowGets(), .t.}
        endif

        READ
        
        if (LASTKEY()==K_ESC)
                EXIT
        else

            // setuj MPC u sifranik robe ako je
            // razlicita !!!
            StUSif()

            select PRIPRZ
            append blank

            // selektuj robu
            select roba

            // setuj varijable za append
            _robanaz := roba->naz
            _jmj := roba->jmj
            _idtarifa := roba->idtarifa
            _cijena := if( EMPTY( _cijena ), pos_get_mpc(), _cijena )
            _barkod := roba->barkod
            _n1 := roba->n1
            _n2 := roba->n2
            _k1 := roba->k1
            _k2 := roba->k2
            _k7 := roba->k7
            _k9 := roba->k9
            
            select priprz

            Gather() 

            oBrowse:goBottom()
            oBrowse:refreshAll()
            oBrowse:dehilite()

        endif

    enddo

    SETKEY(K_PGUP,PrevUp)
    SETKEY(K_PGDN,PrevDn)
    UnSetSpecZad()

    BoxC()
    
endif

SELECT PRIPRZ
      
if RecCount2() > 0 

    select pos_doks
    set order to tag "1"

    if !_from_kalk
        cBrDok := pos_novi_broj_dokumenta( cIdPos, IIF( cIdvd == "PD", "16", cIdVd ) )
    endif

    SELECT PRIPRZ
 
    Beep(4)

    if !fSadAz .and. Pitanje(, "Zelite li odstampati dokument ?", "N" ) == "D"
        StampZaduz( cIdVd, cBrDok )
        o_pos_tables()
    endif

    if fSadAz .or. Pitanje(,"Zelite li staviti dokument na stanje? (D/N)", "D" ) == "D"
        AzurPriprZ( cBrDok, cIdVD )
    else
        SELECT _POS
        AppFrom("PRIPRZ",.f.)
        SELECT PRIPRZ
        my_dbf_zap()
        MsgBeep("Dokument nije stavljen na stanje!#"+"Ostavljen je za doradu!",20)
    endif
endif

my_close_all_dbf()
return




function OsvPrikaz()
if gZadCij=="D"
    nArr:=SELECT()
        SELECT (F_TARIFA)
        if !USED()
        O_TARIFA
    endif
        SEEK ROBA->idtarifa
    SELECT (nArr)
        @ m_x+ 5,  m_y+2 SAY "PPP (%):"
    @ row(),col()+2 SAY TARIFA->OPP PICTURE "99.99"
        @ m_x+ 5,col()+8 SAY "PPU (%):"
    @ row(),col()+2 SAY TARIFA->PPP PICTURE "99.99"
        @ m_x+ 5,col()+8 SAY "PP (%):" 
    @ row(),col()+2 SAY TARIFA->ZPP PICTURE "99.99"
        _cijena:=&("ROBA->cijena"+gIdCijena)
endif
return




// ----------------------------------------------------------
// setuje u sifranik mpc
// ----------------------------------------------------------
function StUSif()
local _t_area := SELECT()
local _rec
local _tmp

if gSetMPCijena == "1"
    _tmp := "mpc"
else
    _tmp := "mpc" + ALLTRIM( gSetMPCijena )
endif

if gZadCij=="D"

    if _cijena <> pos_get_mpc() .and. Pitanje(, "Staviti u sifrarnik novu cijenu? (D/N)", "D" )=="D"

        SELECT (F_ROBA)
        _rec := dbf_get_rec()
        _rec[ _tmp ] := _cijena

        update_rec_server_and_dbf( "roba", _rec, 1, "FULL" )

        select ( _t_area )
    endif

endif

return



function SetSpecZad()
bPrevZv := SETKEY(ASC("*"), {|| IspraviZaduzenje() })
return .t.



function UnSetSpecZad()
SETKEY(ASC("*"),{|| bPrevZv})
return .f.



function ZadKolOK(nKol)

if LASTKEY()=K_UP
    return .t.
endif
if nKol=0
    MsgBeep("Kolicina mora biti razlicita od nule!#Ponovite unos!", 20)
        return (.f.)
endif
return (.t.)



/*! \fn ZadProvDuple(cSif)
 *  \brief Provjera postojanja sifre u zaduzenju
 *  \param cSif
 *  \return
 */
function ZadProvDuple(cSif)
local lFlag:=.t.

SELECT PRIPRZ
SET ORDER TO tag "1"
nPrevRec:=RECNO()
Seek cSif
if FOUND()
    MsgBeep("Na zaduzenju se vec nalazi isti artikal!#"+"U slucaju potrebe ispravite stavku zaduzenja!", 20)
        lFlag:=.f.
endif
SET ORDER TO
GO (nPrevRec)
return (lFlag)



/*! \fn IspraviZaduzenje()
 *  \brief Ispravka zaduzenja od strane korisnika
 */
function IspraviZaduzenje()
local cGetId
local nGetKol
local aConds
local aProcs

UnSetSpecZad()
cGetId:=_idroba
nGetKol:=_Kolicina

OpcTipke({"<Enter>-Ispravi stavku","<B>-Brisi stavku","<Esc>-Zavrsi"})

oBrowse:autolite:=.t.
oBrowse:configure()
aConds:={ {|Ch| Ch == ASC ("b") .OR. Ch == ASC ("B")},{|Ch| Ch == K_ENTER}}
aProcs:={ {|| BrisStavZaduz ()}, {|| EditStavZaduz ()}}
ShowBrowse(oBrowse, aConds, aProcs)
oBrowse:autolite:=.f.
oBrowse:dehilite()
oBrowse:stabilize()

// vrati stari meni
Prozor0()
// vrati sto je bilo u GET-u
_idroba:=cGetId
_Kolicina:=nGetKol
SetSpecZad()
return



/*! \fn BrisStavZaduz()
 *  \brief Brise stavku zaduzenja
 */

function BrisStavZaduz()

SELECT PRIPRZ
if RecCount2()==0
    MsgBeep("Zaduzenje nema nijednu stavku!#Brisanje nije moguce!", 20)
        return (DE_CONT)
endif
Beep(2)
my_delete_with_pack()
oBrowse:refreshAll()
return (DE_CONT)




/*! \fn EditStavZaduz()
 *  \brief Vrsi editovanje stavke zaduzenja i to samo artikla ili samo kolicine
 */
function  EditStavZaduz()
local PrevRoba
local nARTKOL:=2
local nKOLKOL:=4
private GetList:={}
  
if RecCount2()==0
    MsgBeep("Zaduzenje nema nijednu stavku!#Ispravka nije moguca!", 20)
        return (DE_CONT)
endif
// uradi edit samo vrijednosti u tekucoj koloni

PrevRoba:=_IdRoba:=PRIPRZ->idroba
_Kolicina:=PRIPRZ->Kolicina
Box(, 3, 60)
@ m_x+1,m_y+3 SAY "Novi artikal:" GET _idroba PICTURE "@K" VALID EVAL (bRSblok, 1, 27) .AND.(_IdRoba==PrevRoba.or.ZadProvDuple (_idroba))
@ m_x+2,m_y+3 SAY "Nova kolicina:" GET _Kolicina VALID ZadKolOK (_Kolicina)
read

if LASTKEY()<>K_ESC
    if _idroba<>PrevRoba
            // priprz
            REPLACE RobaNaz WITH &cRSdbf.->Naz,Jmj WITH &cRSdbf.->Jmj,Cijena WITH &cRSdbf.->Cijena,IdRoba WITH _IdRoba
        endif
        // priprz
        REPLACE Kolicina WITH _Kolicina
endif

BoxC()
oBrowse:refreshCurrent()
return (DE_CONT)
*}

function NaslovDok(cIdVd)
do case
    case cIdVd=="16"
        return "ZADUZENJE"
    case cIdVd=="PD"
        return "PREDISPOZICIJA"
    case cIdVd=="95"
        return "OTPIS"
    case cIdVd=="98"
        return "REKLAMACIJA"
    otherwise
        return "????"
endcase

return

