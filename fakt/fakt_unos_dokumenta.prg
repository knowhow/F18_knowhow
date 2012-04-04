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

#include "fakt.ch"
#include "f18_separator.ch"

static lDoks2 := .t.
static lDirty := .t.


// -----------------------------------------------------------------
// Glavna funkcija za poziv pripreme i knjizenje fakture
// -----------------------------------------------------------------
function fakt_unos_dokumenta()
local i, _x_pos, _y_pos, _x, _y

// da li je ocitan barkod
private ImeKol, Kol
private gOcitBarkod:=.f.
private fID_J:=.f.
private lOpcine := ( IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D" )

o_fakt_edit()

select fakt_pripr

if idTipDok=="IM"
    close all
    FaUnosInv()
    return
endif

if IzFMKINI('SifRoba','ID_J','N', SIFPATH)=="D"
    fId_J:=.t.
endif

private ImeKol:={ ;
          {"Red.br"      ,  {|| Rbr()                   } } ,;
          {"Partner/Roba",  {|| Part1Stavka() + Roba()  } } ,;
          {"Kolicina"    ,  {|| kolicina                } } ,;
          {"Cijena"      ,  {|| Cijena                  } , "cijena"    } ,;
          {"Rabat"       ,  {|| Rabat                   } , "Rabat"     } ,;
          {"Porez"       ,  {|| Porez                   } , "porez"     } ,;
          {"RJ"          ,  {|| idfirma                 } , "idfirma"   }, ;
          {"Serbr",         {|| SerBr                   } , "serbr"     }, ;
          {"Partn",         {|| IdPartner               } , "IdPartner" }, ;
          {"IdTipDok",      {|| IdTipDok                } , "Idtipdok"  }, ;
          {"Brdok",         {|| Brdok                   } , "Brdok"     }, ;
          {"DatDok",        {|| DATDOK                  } , "DATDOK"    } ;
        }

if glRadNal
    AADD(ImeKol, { "Rad.nalog", {|| idrnal}, "idrnal" })
endif

if fakt_pripr->(fieldpos("k1"))<>0 .and. gDK1=="D"
  AADD(ImeKol,{ "K1",{|| k1}, "k1" })
  AADD(ImeKol,{ "K2",{|| k2}, "k2" })
endif

if fakt_pripr->(fieldpos("idrelac")) <> 0
    AADD( ImeKol , { "ID relac.", {|| idrelac  }, "IDRELAC"  } )
endif

Kol:={}

for i := 1 to len(ImeKol)
    AADD(Kol, i)
next

private cTipVPC := "1"

if gVarC $ "123"
    cTipVPC := IzFmkIni("FAKT","TekVPC","1", SIFPATH)
endif

lFisMark := .f.
cFFirma  := field->idfirma
cFTipDok := field->idtipdok
cFBrDok  := field->brdok

_x := MAXROWS() - 4
_y := MAXCOLS() - 3
Box( , _x, _y)

@ m_x + _x - 4, m_y + 2 SAY " <c-N> Nove Stavke        " + BROWSE_COL_SEP + " <ENT> Ispravi stavku      " + BROWSE_COL_SEP + " <c-T> Brisi Stavku "
@ m_x + _x - 3, m_y + 2 SAY " <c-A> Ispravka Dokumenta " + BROWSE_COL_SEP + hb_Utf8ToStr(" <c-P> Štampa (TXT)        ") + BROWSE_COL_SEP + " <a-F10> Asistent  "
@ m_x + _x - 2, m_y + 2 SAY hb_Utf8ToStr(" <a-A> Ažuriranje dok.    ") + BROWSE_COL_SEP + hb_Utf8ToStr(" <c-F9> Briši pripremu     ") + BROWSE_COL_SEP + " <F5>  Kontrola zbira  "
@ m_x + _x - 1, m_y + 2 SAY " <R> Rezerv  <X> Prekid R " + BROWSE_COL_SEP + " <F10>  Ostale opcije      " + BROWSE_COL_SEP + " <F9> 20,12->10; 27->11"

ObjDbedit( "PNal", MAXROWS() - 4, MAXCOLS() - 3 , {|| fakt_pripr_keyhandler()}, "", "Priprema...", , , , , 4)

BoxC()

close all
return



/*! \fn EdPripr
 *  \brief Sprema pripremu za unos/ispravku dokumenta
 *  \brief Priprema ekran i definise tipke (c+N,a+A...)
 *  \todo Ovu funkciju definitivno treba srediti....
 */
 
function fakt_pripr_keyhandler()
local _rec
local _ret
local nTr2
local cPom
local cENTER := chr(K_ENTER) + chr(K_ENTER) + chr(K_ENTER)
local aFakt_dok := {}
    
if (Ch==K_ENTER  .and. Empty(BrDok) .and. EMPTY(rbr))
    return DE_CONT
endif


select fakt_pripr

do case

    case lFisMark == .t.
    
        lFisMark := .f.

        if fakt_pripr->(reccount()) <> 0
            // priprema nije prazna, nema stampanja racuna
            msgbeep("Priprema nije prazna, stampa fisk.racuna nije moguca!")
            return DE_CONT
        endif

        if gFC_Pitanje == "D" .and. Pitanje(,"Odstampati racun na fiskalni printer ?", "D") == "N"
            return DE_CONT
        endif

        msgo("stampa na fiskalni printer u toku...")

        // posalji na fiskalni uredjaj
        fakt_fisc_rn( cFFirma, cFTipDok, cFBrDok )

        MsgC()

        select fakt_pripr
    
        if gFC_faktura $ "D#G#X"
            
            if gFC_faktura $ "D#X" .and. Pitanje(,"Stampati fakturu ?", "N") == "D"
            
                // stampaj dokument odmah nakon fiskalnog racuna
                StampTXT( cFFirma, cFTipDok, cFBrDok )
                close all
                o_fakt_edit()
                select fakt_pripr
    
            endif
        
            if gFC_faktura $ "G#X" .and. ;
                Pitanje(,"Stampati graficku fakturu ?", "N") == "D"
            
                stdokodt( cFFirma, cFTipDok, cFBrDok )
           
                close all 
                o_fakt_edit()

                select fakt_pripr
            
            endif

            return DE_REFRESH
        
        endif
    
    return DE_CONT
    
    case (Ch==K_CTRL_T)

        if BrisiStavku() == 1
                return DE_REFRESH
        else
            return DE_CONT
        endif

    case Ch==K_ENTER 

        Box("ist", MAXROWS()-10, MAXCOLS()-10, .f.)

        set_global_vars_from_dbf("_")


        nRbr := RbrUnum(_Rbr)

        if edit_fakt_priprema(.f.) == 0
                _ret := DE_CONT
        else
                _rec := get_dbf_global_memvars("_")
                dbf_update_rec(_rec, .f.)
                PrCijSif()  
                lDirty:=.t.
                _ret :=DE_REFRESH
        endif

        BoxC()
        return _ret

    case Ch==K_CTRL_A

        ProdjiKrozStavke()
        lDirty:=.t.
        return DE_REFRESH

    case Ch==K_CTRL_N
   
        NoveStavke()
        lDirty:=.t.
        return DE_REFRESH

    case Ch=K_CTRL_P
       
        // prvo setuj broj dokumenta
        fakt_set_broj_dokumenta()

        // printaj dokument
        PrintDok()

        lDirty:=.f.

        return DE_REFRESH

    case Ch==K_ALT_L
  
          close all
          label_bkod()
          o_fakt_edit()

    case Ch==K_ALT_P
        
        // setuj broj dokumenta u pripremi ako vec nije
        fakt_set_broj_dokumenta()
    
        if !CijeneOK("Stampanje")
            return DE_REFRESH
        endif
            
        if field->idtipdok == "13"
            FaktStOLPP()
        else
            StDokOdt( nil, nil, nil )
        endif
            
        o_fakt_edit()
            
        return DE_REFRESH

    case Ch = K_ALT_A

        // setuj prvo broj dokumenta u pripremi...
        fakt_set_broj_dokumenta()

        // setuj podatke za fiskalni racun
        cFFirma  := field->idfirma
        cFTipDok := field->idtipdok
        cFBrDok  := field->brdok

        if !CijeneOK("Azuriranje")
            return DE_REFRESH
        endif
            
        CLOSE ALL
            
        // funkcija azuriranja vraca matricu sa podacima dokumenta
        aFakt_dok := azur_fakt()
        
        lDirty:=.t.
            
        o_fakt_edit() 
        
        if gFc_use == "D" .and. cFTipDok $ "10#11"
            
            if aFakt_dok <> nil .and. LEN( aFakt_dok ) > 0
                cFirma := aFakt_dok[ 1, 1 ] 
                cFTipDok := aFakt_dok[ 1, 2 ] 
                cFBrDok := aFakt_dok[ 1, 3 ] 
            endif
            
            lFisMark := .t.         
        
        endif
        
        return DE_REFRESH

    case Ch==K_CTRL_F9
        
        BrisiPripr()
        lDirty:=.t.
        return DE_REFRESH
        
    case Ch == K_F5
            // kontrola zbira
            nRec:=RecNo()
            Box(,12,72)
                nDug2:=nRab2:=nPor2:=0
                cDinDem:=dindem
                nC:=1
                KonZbira()
                if nC>9
                        InkeySc(0)
                        @ m_x+1,m_y+2 CLEAR to m_x+12,m_y+70
                        nC:=1
                @ m_x,m_y+2 SAY ""
                endif
            @ m_x+nC,m_y+2 SAY Replicate("-",65)
                    @ m_x+nC+1,m_y+2   SAY "Ukupno   "
                    @ m_x+nC+1,col()+1 SAY nDug2      pict "9999999.99"
                    @ m_x+nC+1,col()+1 SAY nRab2      pict "9999999.99"
                    @ m_x+nC+1,col()+1 SAY nDug2-nRab2 pict "9999999.99"
                    @ m_x+nC+1,col()+1 SAY nPor2 pict          "9999999.99"
                    @ m_x+nC+1,col()+1 SAY nDug2-nRab2+nPor2 pict "9999999.99"
                    @ m_x+nC+1,col()+1 SAY "("+cDinDem+")"
                InkeySc(0)
            BoxC()
            go nRec
            return DE_CONT
        
    case UPPER(Chr(Ch))  $ "RX"
            go top
            if idtipdok $ "20#27"
                do while !eof()
                    if UPPER(Chr(Ch))=="R"
                            replace serbr with "*"
                    elseif UPPER(Chr(Ch))=="X"
                            replace serbr with ""
                    endif
                    skip
                enddo
            endif
            Beep(1)
            go top
            return DE_REFRESH
        
    case UPPER(Chr(Ch))=="R"
        return DE_REFRESH
       
#ifdef __PLATFORM__DARWIN 
    case Ch==ASC("9")
#else
    case Ch==K_F9
#endif

        Iz20u10() 
        lDirty:=.t.
        return DE_REFRESH
     
#ifdef __PLATFORM__DARWIN 
    case UPPER(CHR(Ch)) == "O"
#else
    case Ch==K_ALT_F10
#endif

        private nEntera:=30
        for iSekv:=1 to INT(RecCount2()/15)+1
            cSekv:=chr(K_CTRL_A)
            for nKekk:=1 to MIN(RecCount2(),15)*20
                cSekv+=cEnter
            next
            keyboard cSekv
        next
        lDirty:=.t.
        return DE_REFRESH
         
#ifdef __PLATFORM__DARWIN 
     case Ch==ASC("0")
#else
    case Ch==K_F10
#endif

        Popupfakt_unos_dokumenta()
        SETLASTKEY(K_CTRL_PGDN)
        return DE_REFRESH
    
    case Ch==K_F11
        // pregled smeca
        Pripr9View()
        
        select fakt_pripr
        go top
        
        return DE_REFRESH

    case Ch=K_ALT_I
        RekZadMpO()
        o_fakt_edit()
        return DE_REFRESH
        
    case Ch==K_ALT_N
        if lDirty
            MsgBeep("Podaci su mjenjani nakon posljednje stampe##"+;
            "Molimo ponovite stampu dokumenta da bi podaci#" +;
            "na narudzbenici bili azurni")
            return DE_CONT
        endif
        select fakt_pripr
        nRec:=RECNO()
        GO TOP
        nar_print(.t.)
        o_fakt_edit()
        select fakt_pripr
        GO (nRec)
        return DE_CONT

    case Ch==K_CTRL_R
        if lDirty
            MsgBeep("Podaci su mjenjani nakon posljednje stampe##"+;
            "Molimo ponovite stampu dokumenta da bi podaci#" +;
            "na radnom nalogu bili azurni.")
            return DE_CONT
        endif
            select fakt_pripr
        nRec:=RECNO()
            GO TOP
        rnal_print(.t.)
        o_fakt_edit()
        select fakt_pripr
            GO (nRec)
            return DE_CONT

    case Ch==K_ALT_E
        
        if Pitanje(,"Exportovati dokument u xls ?", "D" ) == "D"
            
            exp_dok2dbf()
            o_fakt_edit()   
            select fakt_pripr
            go top

        endif
        
        return DE_CONT

endcase

return DE_CONT


// -------------------------------------------
// brisanje stavke
// -------------------------------------------
function BrisiStavku()
local _secur_code
local _log_opis
local _log_stavka
local _log_artikal, _log_kolicina, _log_cijena
local _log_datum
local _t_area
local _rec

if !(ImaPravoPristupa(goModul:oDataBase:cName,"DOK","BRISANJE" ))
    MsgBeep(cZabrana)
    return 0
endif
    
if Pitanje(, "Zelite izbrisati ovu stavku ?","D") == "D"

    if ( RecCount2() == 1 ) .or. JedinaStavka()
        // potreba za resetom brojaca na prethodnu vrijednost ?
        fakt_reset_broj_dokumenta( field->idfirma, field->idtipdok, field->brdok )
    endif
    
    // uzmi opis dokumenta za logiranje
    _log_opis := "dokument: " + field->idfirma + "-" + field->idtipdok + "-" + field->brdok
    _log_stavka := field->rbr
    _log_artikal := "artikal: " + field->idroba
    _log_kolicina := field->kolicina
    _log_cijena := field->cijena
    _log_datum := field->datdok

    delete
    __dbPack()

    _t_area := SELECT()

    if Logirati(goModul:oDataBase:cName,"DOK","BRISANJE")
        EventLog(nUser, goModul:oDataBase:cName, "DOK", "BRISANJE", ;
            _log_kolicina, _log_cijena, nil, nil, ;
            _log_artikal, "", _log_opis, _log_datum, DATE(), "", ;
            "Brisanje stavke " + _log_stavka + " iz pripreme")
    endif

    select ( _t_area )

    return 1

endif

return 0


function ProdjiKrozStavke()
    
PushWA()

select fakt_pripr
// go top
Box(, 22, 75, .f., "")
nDug:=0
do while !eof()
    skip
    nTR2:=RECNO()
    skip - 1

    Scatter()
    _podbr := SPACE(2)

    nRbr:=RbrUnum(_Rbr)

    BoxCLS()

    if edit_fakt_priprema(.f.)==0
            exit
    endif

    nDug += round( _Cijena * _kolicina * PrerCij() * ( 1 - _Rabat / 100) * ( 1 + _Porez / 100) , ZAOKRUZENJE)

    @ m_x+23, m_y+2 SAY "ZBIR DOKUMENTA:"
    @ m_x+23, col()+1 SAY nDug PICTURE '9 999 999 999.99'
    InkeySc(10)

    select fakt_pripr
    Gather()

     // ako treba, promijeni cijenu u sifrarniku
    PrCijSif() 
    go nTR2
enddo
PopWA()
BoxC()

return

// ---------------------
// ---------------------
function NoveStavke()

nDug:=0
nPrvi:=0

go top
do while .not. EOF() 
    // kompletan nalog sumiram
    nDug += Round( Cijena*Kolicina*PrerCij()*(1-Rabat/100)*(1+Porez/100) , ZAOKRUZENJE)
    skip
enddo

go bottom

Box("knjn", MAXROWS() - 10, MAXCOLS() - 10, .f., "Unos novih stavki")

do while .t.

    Scatter()
    // podbr treba skroz ugasiti
    _PodBr := SPACE(2)

    if AllTrim(_podbr) == "." .and. empty(_idroba)
            nRbr := RbrUnum(_Rbr)
            _PodBr :=" 1"
    elseif _podbr >= " 1"
            nRbr   := RbrUnum(_Rbr)
            _podbr := STR(val(_podbr) + 1, 2, 0)
    else
            nRbr := RbrUnum(_Rbr) + 1
            _PodBr := "  "
    endif

    BoxCLS()

    _c1 := _c2 := _c3 := SPACE(20)

    _opis := space(120)

    _n1:= 0
    _n2 := 0
    if edit_fakt_priprema(.t.) == 0
            exit
    endif

    nDug += Round(_Cijena*_Kolicina*PrerCij()*(1-_Rabat/100)*(1+_Porez/100) , ZAOKRUZENJE)
    @ m_x + 23, m_y + 2 SAY "ZBIR DOKUMENTA:"
    @ m_x + 23, col() + 2 SAY nDug PICTURE '9 999 999 999.99'

    InkeySc(10)

    select fakt_pripr
    APPEND BLANK

    Gather()

    // ako treba, promijeni cijenu u sifrarniku
    PrCijSif()      
enddo
BoxC()

return


function PrintDok()
local cPom
local lJos

SpojiDuple()  

o_fakt_edit() 

if !CijeneOK("Stampanje")
    return DE_REFRESH
endif

if IzFMKIni("FAKT", "StampajSveIzPripreme", "N", PRIVPATH) == "D"
    lSSIP99:=.t.
else
    lSSIP99:=.f.
endif

lJos:=.t.

do while lJos
    
    if (IzFMKINI('FAKT','StampaViseDokumenata','N')=="D")
            lJos := StViseDokMenu()
    else
            lJos := .f.
    endif

    cPom := idtipdok
    
    gPtxtC50 := .f.

    StampTXT( nil, cPom, nil )

    o_fakt_edit()

enddo

lSSIP99:=.f.

return


function RekZadMpO()

select fakt_pripr
GO TOP
cSort1:="IzSifK('PARTN','LINI',idpartner,.f.)+idroba"
cFilt1:="idtipdok=='13'.and.idfirma==" + cm2str(fakt_pripr->idfirma)
INDEX ON &cSort1 to "TMPPRIPR" for &cFilt1
GO TOP
StartPrint()
? "FAKT,",date(),", REKAPITULACIJA ZADUZENJA MALOPRODAJNIH OBJEKATA"
? 
IspisFirme(fakt_pripr->idfirma)
?
do while !EOF()
  cLinija:=IzSifK('PARTN','LINI',idpartner,.f.)
  ? "LINIJA:",cLinija
  ? "---------- ---------------------------------------- ----------"
  ? "  SIFRA                NAZIV ARTIKLA                 KOLICINA "
  ? "---------- ---------------------------------------- ----------"
  do while !EOF() .and. cLinija==IzSifK('PARTN','LINI',idpartner,.f.)
    cIdRoba:=idroba; nKol:=0
    SELECT ROBA; SEEK LEFT(cIdRoba,gnDS); select fakt_pripr
    do while !EOF() .and.;
         cLinija==IzSifK('PARTN','LINI',idpartner,.f.) .and.;
         idroba==cIdRoba
      nKol += kolicina
      SKIP 1
    enddo
    ? cIdRoba, LEFT(ROBA->naz,40),  STR(nKol, 10, 0)
  enddo
  ? "---------- ---------------------------------------- ----------"
  ?
  if !EOF()
    FF
  endif
enddo
FF
close all 
EndPrint()
CLOSE ALL
return     



// --------------------------------------------------------
// hendliranje unosa novih stavki u pripremi
// --------------------------------------------------------
function edit_fakt_priprema(fNovi)
local nXpom
local nYpom
local nRec
local aMemo
local cPretvori := "N"
local nPom:= IIF(VAL(gIMenu)<1,ASC(gIMenu)-55,VAL(gIMenu))
local lTxtNaKraju := .f.
local cAvRacun
local cListaTxt := ""
local _vrste_placanja := fetch_metric("fakt_unos_vrste_placanja", nil, "N" )

lDoks2:=(IzFmkIni("FAKT","Doks2","D", KUMPATH)=="D")

private aPom:={}

AADD(aPom, "00 - Pocetno stanje                ")
AADD(aPom, "01 - Ulaz / Radni nalog ")

AADD(aPom, "10 - Porezna faktura")

AADD(aPom, "11 - Porezna faktura gotovina")
AADD(aPom, "12 - Otpremnica" )

AADD(aPom, "13 - Otpremnica u maloprodaju")

AADD(aPom, "19 - " + Naziv19ke() )

AADD(aPom, "20 - Ponuda/Avansna faktura") 

AADD(aPom, "21 - Revers")


AADD(aPom, "22 - Realizovane otpremnice   ")
AADD(aPom, "23 - Realizovane otpremnice MP")

AADD(aPom, "25 - Knjizna obavijest ")

AADD(aPom, "26 - Narudzbenica ")

AADD(aPom, "27 - Ponuda/Avansna faktura gotovina") 

h:= {}
ASIZE(h, LEN(aPom))
AFILL(h, "")

private nRokPl:=0
private cOldKeyDok:=_idfirma+_idtipdok+_brdok

_txt1:=_txt2:=_txt3a:=_txt3b:=_txt3c:=""   // txt1  -  naziv robe,usluge

if IzFmkIni('FAKT','ProsiriPoljeOtpremniceNa50','N',KUMPATH)=='D'
    _BrOtp:=SPACE(50)
else
    _BrOtp:=SPACE(8)
endif

_DatOtp:=CToD("")
_BrNar:=SPACE(8)
_DatPl:=CToD("")
_VezOtpr:=""
_Dest:=""
_m_dveza := ""

if lDoks2
    d2k1:=SPACE(15)
    d2k2:=SPACE(15)
    d2k3:=SPACE(15)
    d2k4:=SPACE(20)
    d2k5:=SPACE(20)
    d2n1:=SPACE(12)
    d2n2:=SPACE(12)
endif

set cursor on

if !fnovi
    aMemo:=ParsMemo(_txt)
    if (LEN(aMemo)>0)
            _txt1:=aMemo[1]
    endif
    if (LEN(aMemo)>=2)
            _txt2:=aMemo[2]
    endif
    if (LEN(aMemo)>=5)
            _txt3a:=aMemo[3]
        _txt3b:=aMemo[4]
        _txt3c:=aMemo[5]
    endif
    if (LEN(aMemo)>=9)
            _BrOtp:=aMemo[6]
        _DatOtp:=CToD(aMemo[7])
        _BrNar:=aMemo[8]
        _DatPl:=CToD(aMemo[9])
    endif
    if (LEN(aMemo)>=10 .and. !EMPTY(aMemo[10]))
            _VezOtpr:=aMemo[10]
    endif
    if lDoks2
            if (LEN(aMemo)>=11)
                d2k1:=aMemo[11]
            endif
            if (LEN(aMemo)>=12)
                d2k2:=aMemo[12]
            endif
            if (LEN(aMemo)>=13)
                d2k3:=aMemo[13]
            endif
            if (LEN(aMemo)>=14)
                d2k4:=aMemo[14]
            endif
            if (LEN(aMemo)>=15)
                d2k5:=aMemo[15]
            endif
            if (LEN(aMemo)>=16)
                d2n1:=aMemo[16]
            endif
            if (LEN(aMemo)>=17)
                d2n2:=aMemo[17]
            endif
    endif
    
    if LEN(aMemo)>=18
        // destinacija
        public _DEST := aMemo[18]
    endif
    
    if LEN(aMemo)>=19
        // dokumenti veza
        public _m_dveza := aMemo[19]
    endif

else
    
    cPretvori := "D"
    
    _serbr:=SPACE(LEN(serbr))
    public _DEST := ""
    public _m_dveza := ""

    if glDistrib
        _ambp:=0
        _ambk:=0
    endif
    
    _cijena:=0
    
    // ako je ovaj parametar ukljucen ponisti polje roba
    if gResetRoba == "D"
        _idRoba:=SPACE(LEN(_idRoba))
    endif
    
    _kolicina:=0

endif

_podbr := SPACE(2)

// prva stavka
if (fNovi .and. (nRbr == 1 )) 
    nPom:= IIF(VAL(gIMenu)<1,ASC(gIMenu)-55,VAL(gIMenu))
    _IdFirma := gFirma
    _IdTipDok := "10"
    _datdok   := date()
    _zaokr    := 2
    _dindem   :=LEFT(VAlBazna(),3)
else
    nPom:=ASCAN(aPom,{|x| _IdTipdok==LEFT(x,2)})
endif

if (nRbr==1 .and. VAL(_podbr) < 1)

    if gNW $ "DR"
        @ m_x+1,m_y+2 SAY PADR( gNFirma, 20 )
        if RecCount2()==0
                _idFirma:=gFirma
        endif
        @ m_x+1, col()+2 SAY " RJ:" GET _idFirma PICT "@!" VALID {|| EMPTY(_idFirma) .or. _idFirma==gFirma .or. P_RJ(@_idFirma) .and. V_Rj()}

        read
    else
        @  m_x+1,m_y+2 SAY "Firma:" GET _IdFirma VALID P_Firma(@_IdFirma,1,20) .and. LEN(TRIM(_idFirma))<=2
    endif
    if gNW=="N"
        read
    endif
    
    __mx := m_x
    __my := m_y
    
    nPom:= Menu2 (5, 30, aPom, nPom)
    
    m_x := __mx
    m_y := __my
        
    ESC_Return 0
        
    _IdTipdok:=LEFT(aPom[nPom],2)

    if !(ImaPravoPristupa(goModul:oDataBase:cName,"DOK","UNOSDOK" + ALLTRIM(_IdTipDok)))
        MsgBeep(cZabrana)
        return 0
    endif
    
    @  m_x+ 2, m_y + 2 SAY PADR(aPom[ASCAN(aPom,{|x|_IdTipdok==LEFT(x,2)})],40)
    
    if (_idTipDok == "13" .and. gVarNum=="2" .and. gVar13=="2")
            
        @ m_x+1, 57 SAY "Prodavn.konto" GET _idPartner VALID P_Konto(@_idPartner)
        read

        _idPartner:=LEFT(_idPartner,6)
            
        if (EMPTY(ALLTRIM(_txt3a+_txt3b+_txt3c)).or._idpartner!=idpartner)
            _txt3a:=MEMOLINE(ALLTRIM(KONTO->naz)+" ("+ALLTRIM(_idpartner)+")",30,1)
            _txt3b:=MEMOLINE(ALLTRIM(KONTO->naz)+" ("+ALLTRIM(_idpartner)+")",30,2)
            _txt3c:=MEMOLINE(ALLTRIM(KONTO->naz)+" ("+ALLTRIM(_idpartner)+")",30,3)
        endif
    
    elseif (_idtipdok=="13" .and. gVarNum=="1" .and. gVar13=="2")
        
        _idPartner:=if(EMPTY(_idPartner), "P1",RJIzKonta(_idPartner+" "))
            
        @ m_x+1, 57 SAY "RJ - objekat:" GET _idPartner valid P_RJ(@_idPartner) pict "@!"
        read
            
        _idpartner:=PADR(KontoIzRJ(_idpartner),6)
            
        if EMPTY(ALLTRIM(_txt3a+_txt3b+_txt3c)).or._idpartner!=idpartner
            _txt3a:=MEMOLINE(RJ->id+" - "+ALLTRIM(RJ->naz)+" (ZADU@ENJE)",30,1)
            _txt3b:=MEMOLINE(RJ->id+" - "+ALLTRIM(RJ->naz)+" (ZADU@ENJE)",30,2)
            _txt3c:=MEMOLINE(RJ->id+" - "+ALLTRIM(RJ->naz)+" (ZADU@ENJE)",30,3)
        endif
    endif

    if ( fNovi .and. ( nRbr == 1 .and. podbr < "0" ) )

        _M1 := " "  
        // marker generacije nuliraj
        gOcitBarkod:=.f.

        // broj dokumenta u pripremi ce biti uvijek 00000
        _brdok := PADR( REPLICATE( "0", gNumDio ), 8 )

    endif
    
    do while .t.    
        
        @  m_x + 2, m_y + 45 SAY "Datum:" GET _datDok
        @  m_x + 2, col() + 1 SAY "Broj:" GET _BrDok VALID !EMPTY(_BrDok) 
        
        if lSpecifZips = .t.
            _txt3a := PADR(_txt3a, 60)
        else
            if IzFMKINI("PoljeZaNazivPartneraUDokumentu","Prosiriti","N",KUMPATH)=="D"
                _txt3a:=padr(_txt3a,60)
            else
                _txt3a:=padr(_txt3a,30)
            endif
        endif

        _txt3b:=padr(_txt3b,30)
        _txt3c:=padr(_txt3c,30)

        lUSTipke:=.f.

        @ nPX := m_x + 4, nPY := m_y + 2 SAY "Partner:" GET _idpartner ;
            PICT "@!" ;
            VALID { || P_Firma( @_idpartner ), ;
                _Txt3a := padr( _idpartner + ".", 30), ;
                IzSifre(), ;
                _isp_partn( _idpartner, nPX, nPY + 18 ) }
            
        // prodajno mjesto - polje
        if fakt_pripr->(FIELDPOS("IDPM")) <> 0
                @ m_x + 5, m_y + 2 SAY "P.M.:" GET _idpm ;
                VALID {|| P_IDPM(@_idpm,_idpartner) }
        endif
    
        // veza dokumenti
        _m_dveza := PADR( ALLTRIM(_m_dveza), 500 )

        @ m_x + 6, m_y + 2 SAY "Veza:" GET _m_dveza ;
                PICT "@S25"
    
        // destinacija
        _dest := PADR( ALLTRIM(_dest), 80 )
        
        if ( gDest .and. !glDistrib )
            @ m_x + 7, m_y + 2 SAY "Dest:" GET _dest PICT "@S25"
        endif

        // radni nalog
        if glRadNal .and. _idtipdok $ "12"
            @ m_x + 8, col()+2 SAY "R.nal:" GET _idrnal ;
                VALID P_RNal(@_idRNal) PICT "@!"
        endif

        if _idtipdok=="10"

            if gDodPar=="1"
                    
                @ m_x + 4, m_y + 51 SAY "Otpremnica broj:" ;
                    GET _brotp ;
                    PICT "@S8" ;
                    WHEN W_BrOtp(fnovi)
                
                @ m_x + 5, m_y + 51 SAY "          datum:" ;
                    GET _Datotp
                    
                @ m_x + 6, m_y + 51 SAY "Ugovor/narudzba:" ;
                    GET _brNar
                
            endif

            if (gDodPar=="1" .or. gDatVal=="D")
                    
                @ m_x + 7, m_y + 51 SAY "Rok plac.(dana):" ;
                    GET nRokPl ;
                    PICT "999" ;
                    WHEN FRokPl("0",fnovi) ;
                    VALID FRokPl("1",fnovi)

                @ m_x + 8, m_y + 51 SAY "Datum placanja :" ;
                    GET _DatPl ;
                    VALID FRokPl("2",fnovi)
                
            endif
            
            if _vrste_placanja == "D"
                @ m_x + 9, m_y + 2  SAY "Nacin placanja" ;
                    GET _idvrstep ;
                    PICT "@!" ;
                    VALID P_VRSTEP( @_idvrstep, 9, 20 )
            endif
        
        elseif (_idtipdok=="06")
                
            @ m_x + 5, m_y + 51 SAY "Po ul.fakt.broj:" ;
                GET _brotp ;
                PICT "@S8" ;
                WHEN W_BrOtp(fnovi)

            @ m_x + 6, m_y + 51 SAY "       i UCD-u :" ;
                GET _brNar
        
        else
            
            // dodaj i za ostale dokumente
            if IsPDV()
                _DatOtp := _datdok
                    @ m_x + 5 ,m_y + 51 SAY " datum isporuke:" ;
                    GET _datotp
            endif
        
        endif
        
        if (fakt_pripr->(FIELDPOS("idrelac")) <> 0 .and. _idtipdok $ "#11#")
            @ m_x + 9, m_y + 50  SAY "Relacija   :" GET _idrelac PICT "@S10"
        endif

        if _idTipDok $ "10#11#19#20#25#26#27"
            @ m_x + 10, m_y + 2 SAY "Valuta ?" GET _dindem PICT "@!" 
        else
            @ m_x + 10, m_y + 1 SAY " "
        endif
        
        if _idTipDok $ "10"
        
            cAvRacun := "N"
            if _idvrstep == "AV"
                cAvRacun := "D"
            endif
            
            @ m_x + 10, col() + 4 SAY "Avansni racun (D/N)?:" ;
                GET cAvRacun ;
                PICT "@!" ;
                VALID cAvRacun $ "DN"
        
        endif
            
        // ako nije ukljucena opcija ispravke partnera 
        // pri unosu dokumenta
        if ( gIspPart == "N" )
            READ
        endif
        
        if (lDoks2 .and. _idtipdok=="10")
                edit_fakt_doks2()
        endif
        
        if (gIspPart == "N")
            _txt3a:=trim(_txt3a)
            _txt3b:=trim(_txt3b)
            _txt3c:=trim(_txt3c)
        endif
        
        ESC_RETURN 0

        select fakt_pripr
        exit
   
    enddo
    
    ChSveStavke( fNovi )

else

    @ m_x + 1, m_y+ 2 SAY PADR( gNFirma, 20 )
    ?? "  RJ:", _IdFirma
    @ m_x+3,m_y+2 SAY PADR(aPom[ASCAN(aPom,{|x|_IdTipdok==LEFT(x,2)})],35)
    @ m_x+3,m_y+45 SAY "Datum: "
    ?? _datDok
    @ m_x + 3, col()+1 SAY "Broj: "
    ?? _BrDok
    _txt2:=""

endif

// unos stavki dokumenta

@ m_x + 13, m_y + 2 SAY "R.br: " GET nRbr  PICT "9999"


//@ m_x + 13, col() + 2 SAY "Podbr.:"  GET _PodBr VALID V_Podbr()

cDSFINI := IzFMKINI('SifRoba','DuzSifra','10', SIFPATH)

@ m_x + 15, m_y + 2  SAY "Artikal: " ;
    GET _IdRoba ;
    PICT "@!S10" ;
    WHEN {|| _idroba:=padr(_idroba, VAL(cDSFINI)), W_Roba()} ;
    VALID {|| _idroba:= iif(len(trim(_idroba))<10, left(_idroba,10), _idroba), V_Roba(), GetUsl(fnovi), NijeDupla(fNovi) }

RKOR2:=0

RKOR2+=GetKarC3N2(row()+1)

if (fakt_pripr->(fieldpos("K1"))<>0 .and. gDK1=="D")
    @ m_x+15+RKOR2,m_y+66 SAY "K1" GET _K1 pict "@!"
endif

if (fakt_pripr->(fieldpos("K2"))<>0 .and. gDK2=="D")
    @ m_x+16+RKOR2,m_y+66 SAY "K2" GET _K2 pict "@!"
endif

if (gSamokol!="D" .and. !glDistrib)
            @ m_x + 16 + RKOR2, m_y+2  SAY JokSBr()+" "  get _serbr pict "@s15"  when _podbr <> " ."
endif

if (gVarC $ "123" .and. _idtipdok $ "10#12#20#21#25")
    @  m_x + 16 + RKOR2, m_y + 59  SAY "Cijena (1/2/3):" GET cTipVPC
endif

RKOR:=0

lGenStavke:=.f.

if ( _m1=="X" .and.  !fnovi )
    
    // ako je racun, onda ne moze biti cijena 0 !
    
    @ m_x+18 + RKOR2, m_y + 2  SAY "Kolicina "
    @ row(),col()+1 SAY _kolicina pict pickol
    
    if _Cijena=0
            V_Kolicina()
    endif
else
    
    if (glDistrib .or. lPoNarudzbi)
            read
            ESC_return 0
    endif
    
    cPako:="(PAKET)"  
    // naziv jedinice mjere veceg pakovanja
    
    @ m_x+18 + RKOR2, m_y + 2 SAY "Kolicina " ;
        GET _kolicina ;
        PICT pickol ;
        VALID V_Kolicina()
    
endif

private trabat:="%"

if (gSamokol != "D")

    // samo kolicine
    if (_idtipdok=="19" .and. IzFMKIni("FAKT","19KaoRacunParticipacije","N",KUMPATH)=="D")
            
        _trabat:="I"
        _rabat:=_kolicina*_cijena*(1-_rabat/100)
            
        @ m_x+18+RKOR+RKOR2, col() + 2  SAY "Cij." GET _Cijena PICT piccdem WHEN _podbr<>" ."  VALID _cijena>0

        @ m_x+18+RKOR+RKOR2,col()+2 SAY "Participacija" GET _Rabat PICT "9999.999" when _podbr<>" ."

    else
        
        @ m_x+18 + RKOR + RKOR2, col() + 2  SAY IF( _idtipdok $ "13#23".and.( gVar13=="2" .or. glCij13Mpc), "MPC.s.PDV", "Cijena ("+ALLTRIM(ValDomaca())+")") GET _Cijena ;
             PICT piccdem ;
             WHEN  _podbr<>" ." .and. SKCKalk(.t.) ;
             VALID SKCKalk(.f.) .and. c_cijena(_cijena, _idtipdok, fNovi)

        if ( PADR(_dindem, 3) <> PADR(ValDomaca(), 3) ) 
            @ m_x+18+ RKOR + RKOR2, col() + 2 SAY "Pr"  GET cPretvori ;
                PICT "@!" ;
                VALID v_pretvori(@cPretvori, _DinDem, _DatDok, @_Cijena )
        endif

             
        if !(_idtipdok $ "12#13").or.(_idtipdok=="12".and.gV12Por=="D")
            @  m_x+18+RKOR+RKOR2, col() + 2  SAY "Rabat" get _Rabat ;
                 pict PicCDem ;
                 when _podbr<>" ." .and. !_idtipdok$"15#27"
            
            @ m_x+18+RKOR+RKOR2,col()+1  GET TRabat ;
                 when {||  trabat:="%",!_idtipdok$"11#15#27" .and. _podbr<>" ."} ;
                 valid trabat $ "% AUCI" .and. V_Rabat() ;
                 pict "@!"
        
        if !IsPdv()
            // nista porez kada je PDV rezim
                @ m_x+18+RKOR+RKOR2,col()+2 SAY "Porez" GET _Porez ;
                 pict "99.99" ;
                 when {|| if( fNovi .and. _idtipdok=="10" .and. IzFMKIni("FAKT","PPPNuditi","N",KUMPATH)=="D".and.ROBA->tip!="U" , _porez := TARIFA->opp , ), _podbr<>" ." .and. !(roba->tip $ "KV") .and. !_idtipdok$"11#15#27"} ;
                 valid V_Porez()
        endif
        
    endif
        
    endif

    private cId:="  "


endif //gSamokol=="D"  // samo kolicine

read

if cAvRacun == "D"
    _idvrstep := "AV"
endif

ESC_return 0

if (_idtipdok=="19" .and. IzFMKIni("FAKT","19KaoRacunParticipacije","N",KUMPATH)=="D")
    _trabat:="%"
    _rabat:=(_kolicina*_cijena-_rabat)/(_kolicina*_cijena)*100
endif

lTxtNaKraju := .t.

if _IdTipDok $ "13" .or. gSamoKol == "D"
    lTxtNaKraju:=.f.
endif

if (_IdTipDok == "12") 
    if  IsKomision(_IdPartner)
        lTxtNaKraju := .t.
    else
        lTxtNaKraju := .f.
    endif
endif

nTArea := SELECT()

if Logirati(goModul:oDataBase:cName,"DOK","UNOS")
    EventLog(nUser, goModul:oDataBase:cName, "DOK", "UNOS", ;
        _kolicina, _cijena, nil, nil, ;
        "artikal: " + _idroba,"", "dokument: " + _idfirma + "-" + _idtipdok + "-" + _brdok, ;
        _datdok, DATE(), "", ;
        "Unos stavke " + _rbr + " novog dokumenta")
endif

select (nTArea)


if lTxtNaKraju
    // uzmi odgovarajucu listu
    cListaTxt := g_txt_tipdok( _idtipdok )
    // unesi tekst
    UzorTxt2( cListaTxt )
endif

if (_podbr==" ." .or.  roba->tip="U" .or. (nrbr==1 .and. val(_podbr)<1))
    
    // odsjeci na kraju prazne linije
    _txt2:=OdsjPLK(_txt2)           
        if !"Racun formiran na osnovu" $ _txt2
            _txt2 += CHR(13)+Chr(10) + _VezOtpr
        endif
    
    _txt := Chr(16)+trim(_txt1)+Chr(17) 
    _txt += Chr(16)+_txt2+Chr(17)
    _txt += Chr(16)+trim(_txt3a)+Chr(17) 
    _txt += Chr(16)+_txt3b+Chr(17)
    _txt += Chr(16)+trim(_txt3c)+Chr(17)
    
    // 6 - br otpr
    _txt += Chr(16)+_BrOtp+Chr(17)
    // 7 - dat otpr
    _txt += Chr(16)+dtoc(_DatOtp)+Chr(17)
    // 8 - br nar
    _txt += Chr(16)+_BrNar+Chr(17)
    // 9 - dat nar
    _txt += Chr(16)+dtoc(_DatPl)+Chr(17)
    
    // 10
    cPom:=_VezOtpr
    _txt += Chr(16)+ cPom + Chr(17) 
    
    // 11
    if lDoks2
        cPom:= d2k1
    else
        cPom:= ""
    endif
    _txt += Chr(16)+ cPom + Chr(17) 

    // 12
    if lDoks2
        cPom:= d2k2
    else
        cPom:= ""
    endif
    _txt += Chr(16)+ cPom + Chr(17) 

    // 13
    if lDoks2
        cPom:= d2k3
    else
        cPom:= ""
    endif
    _txt += Chr(16)+ cPom + Chr(17) 

    // 14
    if lDoks2
        cPom:= d2k4
    else
        cPom:= ""
    endif
    _txt += Chr(16)+ cPom + Chr(17) 

    // 15
    if lDoks2
        cPom:= d2k5
    else
        cPom:= ""
    endif
    _txt += Chr(16)+ cPom + Chr(17) 

    // 16
    if lDoks2
        cPom:= d2n1
    else
        cPom:= ""
    endif
    _txt += Chr(16)+ cPom + Chr(17) 

    // 17
    if lDoks2
        cPom:= d2n2
    else
        cPom:= ""
    endif
    _txt += Chr(16)+ cPom + Chr(17) 

    // 18 - Destinacija
    cPom := ALLTRIM(_Dest)
    _txt += Chr(16)+ cPom + Chr(17) 

    // 19 - vezni dokumenti
    cPom := ALLTRIM(_m_dveza)
    _txt += CHR(16) + cPom + CHR(17)

else
    _txt:=""
endif

_Rbr:=RedniBroj(nRbr)

if lPoNarudzbi
    if lGenStavke
            pIzgSt:=.t.
            // vise od jedne stavke
            for i:=1 to LEN(aNabavke)-1
                // generisi sve izuzev posljednje
                APPEND BLANK
                _rbr:=RedniBroj(nRBr)
                _kolicina:=aNabavke[i,3]
                _idnar:=aNabavke[i,4]
                _brojnar:=aNabavke[i,5]
                if nRBr<>1
                    _txt:=""
                endif
                Gather()
                ++nRBr
            next
            // posljednja je tekuca
            _rbr:=RedniBroj(nRbr)
            _kolicina:=aNabavke[i,3]
            _idnar:=aNabavke[i,4]
            _brojnar:=aNabavke[i,5]
    else
            // jedna ili nijedna
            if LEN(aNabavke)>0
                // jedna
                _kolicina:=aNabavke[1,3]
                _idnar:=aNabavke[1,4]
                _brojnar:=aNabavke[1,5]
            elseif _kolicina==0
                // nije izabrana kolicina -> kao da je prekinut unos tipkom Esc
                return 0
            endif
    endif
endif

return 1


// ------------------------------------------
// ispisi partnera 
// ------------------------------------------
static function _isp_partn( cPartn, nX, nY )
local nTArea := SELECT()
local cDesc := "..."
select partn
seek cPartn

if FOUND()
    cDesc := ALLTRIM( field->naz )
    if LEN( cDesc ) > 13
        cDesc := PADR( cDesc, 12 ) + "..."
    endif
endif

@ nX, nY SAY PADR( cDesc, 15 )

select (nTArea)
return .t.



static function _f_idpm( cIdPm )

cIdPM := UPPER(cIdPM)  

return .t.


// ---------------------------------------------
// vraca listu za odredjeni tip dok
// ---------------------------------------------
function g_txt_tipdok( cIdTd )
local cList := ""
local cVal
private cTmptxt

if !EMPTY( cIdTd ) .and. cIdTD $ "10#11#12#13#15#16#20#21#22#23#25#26#27"
    
    cTmptxt := "g" + cIdTd + "ftxt"
    cVal := &cTmptxt

    if !EMPTY( cVal )
        cList := ALLTRIM( cVal )
    endif

endif

return cList





/*! \fn FRokPl(cVar, fNovi)
 *  \brief Validacija roka placanja
 *  \param cVar
 *  \param fNovi
 */
function FRokPl(cVar, fNovi)
local fOtp:=.f.
local lRP0:=.t.

if IzFMKINI('FAKT','DatumRokPlacanja','F') == "O"
    // F  - faktura, O -  otpremnica
    fOtp := .t.
endif
// ako je dozvoljen rok.placanja samo > 0
if gVFRP0 == "D"
    lRP0:=.f.
endif

if cVar=="0"   // when
    if nRokPl<0
            return .t.   // ne diraj nista
    endif
    if !fNovi
        if EMPTY(_datpl)
                nRokPl:=0
        else
                if fOtp
                    nRokPl:=_datpl-_datotp
                else
                    nRokPl:=_datpl-_datdok
                endif
        endif
  

      else  // ako je novi, a koristi se rok placanja iz Partn/ROKP
        // i ne koriste se Rabatne skale - odnosno ili jedno ili drugo
        if IzFmkIni("Svi", "RokPlIzSifPartn", "N", SIFPATH) = "D" .and. !IsRabati()
            nRokPl:=IzSifk("PARTN", "ROKP", _IdPartner, .f.)
        endif
      endif

elseif cVar=="1"  // valid
    // ako je rama-glas
    if !lRP0
        if nRokPl < 1
            MsgBeep("Obavezno unjeti broj dana !")
            return .f.
        endif
    endif
    if nRokPl<0  // moras unijeti pozitivnu vrijednost ili 0
            MsgBeep("Unijeti broj dana !")
            return .f.
    endif
    if nRokPl=0 .and. gRokPl<0
            // exclusiv, ako je 0 ne postavljaj rok placanja !
            _datPl:=ctod("")
    else
            if fOtp
                _datPl:=_datotp+nRokPl
            else
                _datPl:=_datdok+nRokPl
            endif
    endif
else  // cVar=="2" - postavi datum placanja
    if EMPTY(_datpl)
            nRokPl:=0
    else
            if fotp
                nRokPl:=_datpl-_datotp
            else
                nRokPl:=_datpl-_datdok
            endif
    endif
endif

ShowGets()
return .t.
*}


/* \fn ArgToStr()
 * Argument To String
 */
function ArgToStr(xArg)
*{
if (xArg==NIL)
    return "NIL"
else
    return "'"+xArg+"'"
endif
*}


/*! \fn PrerCij()
 *  \brief Prerada cijene
 *  \brief Ako je u polje SERBR unesen podatak KJ/KG iznos se dobija kao KOLICINA*CIJENA*PrerCij()  - varijanta R - Rudnik
 *  \return nVrati
 */
 
function PrerCij()
local cSBr := ALLTRIM(_field->serbr)
local nVrati:=1

if !EMPTY(cSbr) .and. cSbr != "*" .and. is_fakt_ugalj()
    nVrati := VAL(cSBr)/1000
endif

return nVrati

/*! \fn StUgRabKup()
 *  \brief Stampa dokumenta ugovor o rabatu
 *  \todo Treba prebaciti u /RPT
 */

function StUgRabKup()
lUgRab:=.t.
lSSIP99:=.f.
//StDok2()
lUgRab:=.f.
return


/*! \fn Naziv19ke()
 *  \brief Vraca naziv za tip dokumenta 19
 *  \return cVrati
 */
 
function Naziv19ke()
*{
local cVrati:=""
cVrati:="Izlaz po ostalim osnovama"
return cVrati
*}


/*! \fn IzborBanke(cToken)
 *  \brief Izbor banke
 *  \param cToken
 *  \return cVrati
 */
 
function IzborBanke(cToken)
*{
local aOpc
local cVrati:=""
local nIzb:=1
local nMax:=0

aOpc := TokToNiz(cToken,",")

for i:=1 to LEN(aOpc)
    aOpc[i]:=TRIM(aOpc[i])
        nMax:=MAX(LEN(aOpc[i]), nMax)
next

if LEN(aOpc)<1
    cVrati := ""
elseif LEN(aOpc)<2
    cVrati:=aOpc[1]
else
    aOpc[1]:=PADR(aOpc[1],nMax+1)
        // meni
        MsgO("Izaberite banku narucioca (Enter-izbor / Esc-bez banke)")
        nIzb := Menu2(16,30,aOpc,nIzb)
        MsgC()
        if nIzb>0
            cVrati:=aOpc[nIzb]
        else
            cVrati:=""
        endif
endif
return cVrati
*}

// ----------------------------------
// ----------------------------------
function IspisBankeNar(cBanke)
*{
local aOpc
O_BANKE
aOpc:=TokToNiz(cBanke,",")
cVrati:=""

select banke
set order to tag "ID"
for i:=1 to LEN(aOpc)
    hseek SUBSTR(aOpc[i], 1, 3)
    if Found()
        cVrati += ALLTRIM(banke->naz) + ", " + ALLTRIM(banke->adresa) + ", " + ALLTRIM(banke->mjesto) + ", " + ALLTRIM(aOpc[i]) + "; "
    else
        cVrati += ""
    endif
next
select partn

return cVrati
*}



/*! \fn KonZbira(lVidi)
 *  \brief 
 *  \param lVidi - ako je .t. ili nil mora da postoji i privatna varijabla nC:=1
 */

function KonZbira(lVidi)
*{
if lVidi==nil
    lVidi:=.t.
endif
 go top
 if lVidi
   @ m_x+nC++,m_y+15 SAY "  Uk     Rabat     Uk-Rabat   Por.na Pr  Ukupno"
   ++nC
 endif
 do while !eof()
   cRbr:=rbr
   nDug:=0; nRab:=0; nPor:=0
   do while rbr==cRbr
     nDug+=round( cijena*kolicina*PrerCij() , ZAOKRUZENJE)
     nRab+=round((cijena*kolicina*PrerCij())*Rabat/100 , ZAOKRUZENJE)
     nPor+=round((cijena*kolicina*PrerCij())*(1-Rabat/100)*Porez/100, ZAOKRUZENJE)
     skip
   enddo
   nDug2+=nDug; nRab2+=nRab; nPor2+=nPor
   if lVidi
     @ m_x+nC,m_y+2 SAY  "R.br:"
     @ m_x+nC,col()+1 SAY cRbr
     @ m_x+nC,col()+1 SAY nDug      pict "9999999.99"
     @ m_x+nC,col()+1 SAY nRab      pict "9999999.99"
     @ m_x+nC,col()+1 SAY nDug-nRab pict "9999999.99"
     @ m_x+nC,col()+1 SAY nPor pict          "9999999.99"
     @ m_x+nC,col()+1 SAY nDug-nRab+nPor pict "9999999.99"
     ++nC
     if nC>10
        InkeySc(0)
        @ m_x+1,m_y+2 CLEAR to m_x+12,m_y+70
        nC:=1
    @ m_x,m_y+2 SAY ""
     endif
   endif
 enddo
return
*}


/*! \fn JeStorno10()
 *  \brief True je distribucija i TipDokumenta=10  i krajnji desni dio broja dokumenta="S"
 */
 
function JeStorno10()
*{
return glDistrib .and. _idtipdok=="10" .and. UPPER(RIGHT(TRIM(_BrDok),1))=="S"
*}


/*! \fn RabPor10()
 *  \brief
 */
 
function RabPor10()

local nArr:=SELECT()
SELECT FAKT
SET ORDER to TAG "1"
SEEK _idfirma+"10"+left(_brdok,gNumDio)

do while !EOF() .and.;
    _idfirma+"10"+left(_brdok,gNumDio)==idfirma+idtipdok+left(brdok,gNumDio).and.;
    _idroba<>idroba
    SKIP 1
enddo

if _idfirma+"10"+left(_brdok,gNumDio)==idfirma+idtipdok+left(brdok,gNumDio)
    _rabat    := rabat
    _porez    := porez
    // i cijenu, sto da ne?
    _cijena   := cijena
else
    MsgBeep("Izabrana roba ne postoji u fakturi za storniranje!")
endif
SELECT (nArr)
return


function Popupfakt_unos_dokumenta()

private opc[8]
opc[1]:="1. generacija faktura na osnovu ugovora            "
opc[2]:="2. sredjivanje rednih br.stavki dokumenta"
opc[3]:="3. ispravka teksta na kraju fakture"
opc[4]:="4. svedi protustavkom vrijednost dokumenta na 0"
opc[5]:="5. priprema => smece"
opc[6]:="6. smece    => priprema"
opc[7]:="7. FAKT  <->  diskete"
opc[8]:="8. brisanje dokumenta iz pripreme"

lKonsig := ( IzFMKINI("FAKT","Konsignacija","N",KUMPATH)=="D" )

if lKonsig
 AADD(opc,"9. generisi konsignacioni racun")
else
 AADD(opc,"-----------------------------------------------")
endif

AADD(opc,"A. kompletiranje iznosa fakture pomocu usluga")
AADD(opc,"-----------------------------------------------")
AADD(opc, "C. import txt-a")
AADD(opc, "U. stampa ugovora od do ")

h[1]:=h[2]:=""
close all
private am_x:=m_x,am_y:=m_y
private Izbor:=1
do while .t.
  Izbor:=menu("prip",opc,Izbor,.f.)
  do case
    case Izbor==0
    exit
    case izbor == 1
    m_gen_ug()
    case izbor == 2
       SrediRbrFakt()
    case izbor == 3
      O_FAKT_S_PRIPR
      O_FTXT
      select fakt_pripr
      go top
      lDoks2 := ( IzFMKINI("FAKT","Doks2","N",KUMPATH)=="D" )
      if val(rbr)<>1
    MsgBeep("U pripremi se ne nalazi dokument")
      else
    IsprUzorTxt()
      endif
      close all
    case izbor == 4
       O_ROBA
       O_TARIFA
       O_FAKT_S_PRIPR
       go top
       nDug:=0
       do while !eof()
          scatter()
          nDug+=round( _Cijena*_kolicina*(1-_Rabat/100) , ZAOKRUZENJE)
          skip
       enddo

       _idroba:=space(10)
       _kolicina:=1
       _rbr := STR(RbrUnum(_Rbr) + 1, 3, 0)
       _rabat := 0

       cDN := "D"
       Box(,4,60)
      @ m_x+1 ,m_y+2 SAY "Artikal koji se stvara:" GET _idroba  pict "@!" valid P_Roba(@_idroba)
      @ m_x+2 ,m_y+2 SAY "Kolicina" GET _kolicina valid {|| _kolicina<>0 } pict pickol
      read
      if lastkey()==K_ESC
        boxc()
        close all
        return DE_CONT
      endif
      _cijena:=nDug/_kolicina
      if _cijena<0
        _Cijena:=-_cijena
      else
        _kolicina:=-_kolicina
      endif
      @ m_x+3 ,m_y+2 SAY "Cijena" GET _cijena  pict piccdem
      cDN:="D"
      @ m_x+4 ,m_y+2 SAY "Staviti cijenu u sifrarnik ?" GET cDN valid cDN $ "DN" pict "@!"
      read
      if cDN=="D"
         select roba; replace vpc with _cijena; select fakt_pripr
      endif
      if lastkey()=K_ESC
        boxc()
        close all
         return DE_CONT
      endif
      append blank
      Gather()
      BoxC()
    case izbor == 5
          
        azuriraj_smece()

    case izbor == 6

        povrat_smece()

    case izbor == 7

          faktprenosdiskete()

    case izbor == 8
       O_FAKT_S_PRIPR
       lJos:=.t.
       do while lJos
     lJos:=StViseDokMenu("BRISI")
     if LEN(gFiltNov)==0
       GO TOP
       exit
     endif
     cPom:=""
     do while !EOF() .and. idfirma+idtipdok+brdok==gFiltNov
       SKIP 1
       nnextRec:=RECNO()
       SKIP -1
       cPom:=idfirma+"-"+idtipdok+"-"+brdok
       DELETE
       GO (nnextRec)
     enddo
     if !EMPTY(cPom)
       MsgBeep("Dokument "+cPom+" izbrisan iz pripreme!")
     endif
       enddo
       CLOSE ALL

    case izbor == 9 .and. lKonsig
       GKRacun()

    case izbor == 10
       KomIznosFakt()

    case izbor == 12
        ImportTxt()

    case izbor == 13
        ug_za_period()
  endcase
enddo
m_x:=am_x
m_y:=am_y

o_fakt_edit()

select fakt_pripr
go bottom

return



