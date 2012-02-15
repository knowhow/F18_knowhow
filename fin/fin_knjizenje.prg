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
#include "f18_separator.ch"

#define DABLAGAS lBlagAsis .and. _IDVN==cBlagIDVN

static cTekucaRj:=""
static __par_len

// FmkIni_KumPath_TekucaRj - Tekuca radna jedinica
// Koristi se u slucaju da u Db unosimo podatke za odredjenu radnu jedinicu
// da ne bi svaki puta ukucavali tu Rj ovaj parametar nam je nudi kao tekucu vrijednost.

// ---------------------------------------------
// Unos fin naloga
// ---------------------------------------------
function fin_unos_naloga()
local izbor

private opc[4]

cTekucaRj:=GetTekucaRJ()

lBlagAsis := "N"
cBlagIDVN := "66"
lAutoPomUDom := "N"

private fK1:=fk2:=fk3:=fk4:=cDatVal:="N",gnLOst:=0,gPotpis:="N"

O_PARAMS
Private cSection:="1",cHistory:=" ",aHistory:={}
Params1()
RPar("k1",@fk1)
RPar("k2",@fk2)
RPar("k3",@fk3)
RPar("k4",@fk4)
RPar("dv",@cDatVal)
RPar("li",@gnLOSt)
RPar("po",@gPotpis)
select params
use

private KursLis:="1"

if gNW=="N"
 Opc[1]:="1. knjizenje naloga    "
 Opc[2]:="2. stampa naloga"
 Opc[3]:="3. azuriranje podataka"
 Opc[4]:="4. kurs "+KursLis

 Izbor:=1
 do while .t.

 h[1]:= h[2]:= h[3]:= h[4]:= ""

 Izbor:=menu("knjiz",opc,Izbor,.f.)

   do case
     case Izbor==0
         EXIT
     case izbor == 1
         KnjNal()
     case izbor == 2
         StNal()
     case izbor == 3
         fin_azur()
     case izbor == 4
       // prva vrijednost
       if KursLis=="1"  
         KursLis:="2"
       else
         KursLis:="1"
       endif
       opc[4]:= "4. kurs " + KursLis
   endcase

 enddo

else 
  // gNW=="D"
  KnjNal()
endif
closeret
return

/*! \fn KnjNal()
 *  \brief Otvara pripremu za knjizenje naloga
 */
 
function KnjNal()
local _sep := BROWSE_COL_SEP
local _w := 25

o_fin_edit()
ImeKol:={ ;
          {"F.",            {|| IdFirma }, "IdFirma" } ,;
          {"VN",            {|| IdVN    }, "IdVN" } ,;
          {"Br.",           {|| BrNal   }, "BrNal" },;
          {"R.br",          {|| RBr     }, "rbr" , {|| wrbr()}, {|| vrbr()} } ,;
          {"Konto",         {|| IdKonto }, "IdKonto", {|| .t.}, {|| P_Konto(@_IdKonto),.t. } } ,;
          {"Partner",       {|| IdPartner }, "IdPartner" } ,;
          {"Br.veze ",      {|| BrDok   }, "BrDok" } ,;
          {"Datum",         {|| DatDok  }, "DatDok" } ,;
          {"D/P",           {|| D_P     }, "D_P" } ,;
          {ValDomaca(),     {|| transform(IznosBHD,FormPicL(gPicBHD, 15)) }, "iznos "+ALLTRIM(ValDomaca()) } ,;
          {ValPomocna(),    {|| transform(IznosDEM,FormPicL(gPicDEM, 10)) }, "iznos "+ALLTRIM(ValPomocna()) } ,;
          {"Opis",          {|| PADR(LEFT(Opis, 37) + IIF(LEN(ALLTRIM(Opis))>37, "...", ""), 40)  }, "OPIS" }, ;
          {"K1",            {|| k1      }, "k1" },;
          {"K2",            {|| k2      }, "k2" },;
          {"K3",            {|| K3Iz256(k3)   }, "k3" },;
          {"K4",            {|| k4      }, "k4" } ;
        }


Kol:={}
for i:=1 to 16
    AADD(Kol,i)
next

if gRj=="D" .and. fin_pripr->(FIELDPOS("IDRJ")) <> 0
    AADD(ImeKol, { "RJ", {|| IdRj}, "IdRj" }  )
    AADD(Kol, 17)
ENDIF

Box( , MAXROWS() - 4, MAXCOLS() - 6)

  @ m_x + MAXROWS() - 6, m_y + 2 SAY PADR(" <c-N> Nove Stavke", _w) + _sep + PADR(" <ENT> Ispravi stavku", _w)  + _sep + PADR(hb_Utf8ToStr(" <c-T> Briši Stavku"), _w) + _sep + PADR( " P - povrat naloga", _w) + _sep 

  @ m_x + MAXROWS() - 5, m_y + 2 SAY PADR(" <c-A> ispravi sve stavke", _w) + _sep + PADR(hb_Utf8ToStr(" <c-P> Štampa Naloga"), _w) + _sep + PADR(hb_Utf8ToStr(" <a-A> Ažuriranje"), _w) + _sep + PADR(hb_Utf8ToStr(" X Ažur bez štampe"), _w) + _sep

  @ m_x + MAXROWS() - 4, m_y + 2 SAY PADR(hb_Utf8ToStr(" <c-F9> Briši pripremu"), _w) + _sep + PADR(" <F5>  Kontrola zbira", _w)  + _sep + PADR(" <a-F5> PrDat", _w) + _sep + PADR(" <a-B> Blagajna", _w) + _sep + PADR(" <F10> Ostalo", _w) + _sep

  ObjDbedit("PN2", MaxRows() - 4, MaxCols() - 6,  {|| edit_fin_pripr()}, "", "Priprema...", , , , ,3)

BoxC()

closeret
return


/*! \fn WRbr()
 *  \brief Sredjivaje rednog broja u pripremi 
 */
function WRbr()
local _rec
local _rec_2

_rec := dbf_get_rec()

if val(_rec["rbr"]) < 2
  @ m_x + 1, m_y + 2 SAY "Dokument:" GET _rec["idvn"]
  @ m_x + 1, col() + 2  GET _rec["brnal"]
  READ
endif

set order to 0
go top
do while !eof()
   _rec_2 := dbf_get_rec()
   _rec_2["idvn"]  := _rec["idvn"]
   _rec_2["brnal"] := _rec["brnal"]
   dbf_update_rec(_rec_2)
   skip
enddo

set order to tag "1"
go top
return .t.


function vrbr()
return .t.

function o_fin_edit()
close all

IF IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
    O_VRSTEP
ENDIF

IF IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
    O_ULIMIT
ENDIF

if (IsRamaGlas())
    O_RNAL
endif

if gRj=="D"
    O_FIN_RJ
endif

if gTroskovi=="D"
    O_FOND
    O_FUNK
endif

O_PSUBAN
O_PANAL
O_PSINT
O_PNALOG
O_PAREK
O_KONTO
O_PARTN
O_TNAL
O_TDOK
O_NALOG
O_FIN_PRIPR

select fin_pripr
set order to tag "1"
go top

return

/*! \fn edit_fin_priprema()
 *  \brief Ispravka stavke u pripremi
 *  \param fNovi .t. - Nova stavka, .f. - Ispravka postojece
 */
 
function edit_fin_priprema()
local _ostav := NIL 
local _iznos_unesen := .f.

parameters fNovi

if fNovi .and. nRbr==1
    _IdFirma:=gFirma
endif

if fNovi
    _OtvSt:=" "
endif

if ((gRj=="D") .and. fNovi)
    _idRj:=cTekucaRj
endif
    
set cursor on

if gNW=="D"
    @  m_x+1,m_y+2 SAY "Firma: "
        ?? gFirma,"-",gNFirma
        @  m_x+3,m_y+2 SAY "NALOG: "
        @  m_x+3,m_y+14 SAY "Vrsta:" GET _idvn VALID P_VN(@_IdVN,3,26) PICT "@!"
else
    @  m_x+1,m_y+2 SAY "Firma:" GET _idfirma VALID {|| P_Firma(@_IdFirma,1,20), _idfirma:=left(_idfirma,2),.t.}
        @  m_x+3,m_y+2 SAY "NALOG: "
        @  m_x+3,m_y+14 SAY "Vrsta:" GET _idvn VALID P_VN(@_IdVN,3,26)
endif
read

ESC_RETURN 0

if fNovi .and. (_idfirma<>idfirma .or. _idvn<>idvn)
    _brnal := nextnal( _idfirma, _idvn )
        select  fin_pripr
endif

set key K_ALT_K to DinDem()
set key K_ALT_O to KonsultOS()

@  m_x+3, m_y + 55  SAY "Broj:"   get _BrNal   valid Dupli(_IdFirma,_IdVN,_BrNal) .and. !empty(_BrNal)
@  m_x+5, m_y + 2  SAY "Redni broj stavke naloga:" get nRbr picture "9999"
@  m_x+7, m_y + 2   SAY "DOKUMENT: "

if gNW<>"D"
    @  m_x+7,m_y+14  SAY "Tip:" get _IdTipDok valid P_TipDok(@_IdTipDok,7,26)
endif

if (IsRamaGlas())
    @  m_x+8, m_y+2   SAY "Vezni broj (racun/r.nalog):"  get _BrDok valid BrDokOK()
else
    @  m_x+8, m_y+2   SAY "Vezni broj:" GET _BrDok
endif

@  m_x+8, m_y + COL() + 2  SAY "Datum:" GET _DatDok VALID chk_sezona() 

if cDatVal=="D"
    @  m_x+8,col()+2 SAY "Valuta" GET _DatVal
endif

@ m_x+11, m_y+2  SAY "Opis :" GET _Opis WHEN {|| .t.} VALID {|| .t.} PICT "@S50"

if fk1=="D"
    @  m_x+11,col()+2 SAY "K1" GET _k1 pict "@!" 
endif

if fk2=="D"
    @  m_x+11,col()+2 SAY "K2" GET _k2 pict "@!"
endif

if fk3=="D"
    if IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3", "N", SIFPATH)=="D"
            _k3:=K3Iz256(_k3)
            @  m_x+11, col() + 2 SAY "K3" GET _k3 VALID EMPTY(_k3).or.P_ULIMIT(@_k3) pict "999"
        else
            @  m_x+11, col() + 2 SAY "K3" GET _k3 pict "@!"
        endif
endif

if fk4=="D"

    if IzFMKIni("FAKT", "VrstePlacanja", "N", SIFPATH)=="D"
            @  m_x+11, col()+2 SAY "K4" GET _k4 VALID EMPTY(_k4).or.P_VRSTEP(@_k4) pict "@!"
    else
            @  m_x+11, col()+2 SAY "K4" GET _k4 pict "@!"
    endif
endif

if gRj=="D" .and. fin_pripr->(FIELDPOS("IDRJ")) <> 0
    @  m_x + 11, col() + 2 SAY "RJ" GET _idrj valid empty(_idrj) .or. P_Rj(@_idrj) PICT "@!"
endif

if gTroskovi=="D"
    @ m_x+12,m_y+22 SAY "      Funk." GET _Funk valid empty(_Funk) .or. P_Funk(@_Funk) pict "@!"
    @  m_x+12,m_y+44 SAY "      Fond." GET _Fond valid empty(_Fond) .or. P_Fond(@_Fond) pict "@!"
endif

if DABLAGAS
    @ m_x+13, m_y+2   SAY "Konto  :" get _IdKonto    pict "@!" valid  Partija(@_IdKonto) .and. P_Konto(@_IdKonto, 13, 20, .t.) .and. BrDokOK() .and. MinKtoLen(_IdKonto) .and. _rule_kto_()

else
        @  m_x+13, m_y+2  SAY "Konto  :" get _IdKonto    pict "@!" valid  Partija(@_IdKonto) .and. P_Konto(@_IdKonto, 13, 20) .and. BrDokOK() .and. MinKtoLen(_IdKonto) .and. _rule_kto_()

endif

@ m_x+14, m_y+2 SAY "Partner:" get _IdPartner pict "@!" valid ;
    {|| if( empty(_idpartner), Reci(14, 20, SPACE(25)), ), ;
    ( EMPTY(_IdPartner) .or. P_Firma(@_IdPartner, 14, 20) ) .and. _rule_partn_() } when ;
    {|| iif(ChkKtoMark(_idkonto), .t., .f.)}


@ m_x + 16, m_y+2  SAY "Duguje/Potrazuje (1/2):" get _D_P valid V_DP() .and. _rule_d_p_() .and. _rule_veza_()

@ m_x + 16, m_y + 65 GET _ostav PUSHBUTTON  CAPTION "<Otvorene stavke>" WHEN { || _iznos_unesen } VALID {|| _iznos_unesen := .f., .t.} ;
                         SIZE X 15 Y 2 STATE {|param| KonsultOs(param)}

@ m_x + 16, m_y + 46  GET _IznosBHD  PICTURE "999999999999.99" WHEN {  || _iznos_unesen := .t., .t. }

@ m_x + 17, m_y + 46  GET _IznosDEM  PICTURE '9999999999.99' ;
                      WHEN {|| DinDEM( , , "_IZNOSBHD"), .t.} VALID {|oGet| V_IznosDEM( , , "_IZNOSDEM", oGet)} 



read



// ako su radne jedinice setuj var cTekucaRJ na novu vrijednost
if (gRJ=="D" .and. cTekucaRJ<>_idrj)
    cTekucaRJ:=_idrj
    SetTekucaRJ(cTekucaRJ)
endif

_IznosBHD:=round(_iznosbhd,2)
_IznosDEM:=round(_iznosdem,2)

ESC_RETURN 0
set key K_ALT_K to

_k3:=K3U256(_k3)
_Rbr:=STR(nRbr,4)

return 1

// provjeri datum dokumenta na osnovu tek.sezona i upozori
static function chk_sezona()
local nYearDok
local nYearSez
local cCurrSez
local cTmp := ""

// trenutno ukidam ovu provjeru, jer nemamo sezona
return .t.

cCurrSez := goModul:oDataBase:cRadimUSezona

if cCurrSez == "RADP"
    // ako je radno podrucje, procitaj koja je sezona
    nYearSez := VAL(goModul:oDataBase:cSezona)
    cTmp := goModul:oDataBase:cSezona
else
    // vidi koja je sezona cRadimUSezona
    nYearSez := VAL(cCurrSez)
    cTmp := cCurrSez
endif

nYearDok := YEAR(_datdok)

if nYearSez <> nYearDok
    MsgBeep("Upozorenje!##Datum dokumenta " + DToC(_datDok) + "#Tekuca sezona " + cTmp )
endif

return .t.


/*! \fn MinKtoLen(cIdKonto)
 *  \brief Provjerava minimalnu dozvoljenu duzinu konta pri knjizenju
 *  \param cIdKonto - konto id
 */
function MinKtoLen(cIdKonto)
*{
if gKtoLimit=="N"
    return .t.
endif

if gKtoLimit=="D" .and. gnKtoLimit > 0
    if LEN(ALLTRIM(cIdKonto)) > gnKtoLimit
        return .t.
    else
        MsgBeep("Duzina konta mora biti veca od " + ALLTRIM(STR(gnKtoLimit)))
        return .f.
    endif
endif

return
*}


/*! \fn V_IznosDEM(p1, p2, cVar, oGet)
 *  \brief Sredjivanje iznosa
 *  \param p1
 *  \param p2
 *  \param cVar
 *  \param oGet
 */
 
function V_IznosDEM(p1,p2,cVar,oGet)
*{
if lAutoPomUDom .and. oGet:changed
    
    _iznosdem:=oGet:unTransform()
    DinDem(p1,p2,cVar)
endif

return .t.
*}

/*! \fn CheckMark(cIdKonto)
 *  \brief Provjerava da li je konto markiran, ako nije izbrisi zapamceni _IdPartner
 *  \param cIdKonto - oznaka konta
 *  \param cIdPartner - sifra partnera koja ce se ponuditi
 *  \param cNewPartner - zapamcena sifra partnera
 */
 
function CheckMark(cIdKonto, cIdPartner, cNewPartner)
    if (ChkKtoMark(_idkonto))
        cIdPartner := cNewPartner
    else
        cIdPartner := space(6)
    endif

return .t.

/*! \fn Partija(cIdKonto)
 *  \brief
 *  \param cIdKonto - oznaka konta
 */
 
function Partija(cIdKonto)
*{
if right(trim(cIdkonto),1)=="*"
    select parek
    hseek strtran(cIdkonto,"*","")+" "
    cIdkonto:=idkonto
    select fin_pripr
endif
return .t.
*}


// -----------------------------------------------------
// Ispis duguje/potrazuje u domacoj i pomocnoj valuti 
// -----------------------------------------------------
function V_DP()
SetPos(m_x+16,m_y+30)
if _D_P=="1"
    ?? "   DUGUJE"
else
    ?? "POTRAZUJE"
endif
?? " "+ValDomaca()

SetPos(m_x+17,m_y+30)
if _D_P=="1"
    ?? "   DUGUJE"
else
    ?? "POTRAZUJE"
endif
?? " "+ValPomocna()

return _D_P $ "12"



/*! \fn DinDem(p1,p2,cVar)
 *  \brief
 *  \param p1
 *  \param p2
 *  \param cVar
 */
function DinDem(p1,p2,cVar)
*{
local nNaz

nNaz:=Kurs(_datdok)
if cVar=="_IZNOSDEM"
    _IZNOSBHD:=_IZNOSDEM*nnaz
elseif cVar="_IZNOSBHD"
  if round(nNaz,4)==0
    _IZNOSDEM:=0
  else
    _IZNOSDEM:=_IZNOSBHD/nnaz
  endif
endif
// select(nArr)
AEVAL(GetList,{|o| o:display()})
*}


// poziva je ObjDbedit u KnjNal
// c-T  -  Brisanje stavke,  F5 - kontrola zbira za jedan nalog
// F6 -  Suma naloga, ENTER-edit stavke, c-A - ispravka naloga

/*! \fn edit_fin_pripr()
 *  \brief Ostale operacije u ispravki stavke
 */

function edit_fin_pripr()
local nTr2
local lLogUnos := .f.
local lLogBrisanje := .f.

if Logirati(goModul:oDataBase:cName,"DOK","UNOS")
    lLogUnos:=.t.
endif
if Logirati(goModul:oDataBase:cName,"DOK","BRISANJE")
    lLogBrisanje:=.t.
endif

if (Ch==K_CTRL_T .or. Ch==K_ENTER) .and. reccount2()==0
    return DE_CONT
endif

select fin_pripr
do case

case Ch==K_ALT_F5
     if pitanje(,"Za konto u nalogu postaviti datum val. DATDOK->DATVAL","N")=="D"
        cIdKonto:=space(7)
        dDatDok:=date()
        nDana:=15

        Box(, 5, 60)
          @ m_x+1, m_Y+2 SAY "Promjena za konto  " GET cIdKonto
          @ m_x+3, m_Y+2 SAY "Novi datum dok " GET dDatDok
          @ m_x+5, m_Y+2 SAY "uvecati stari datdok za (dana) " GET nDana pict "99"
          read
        BoxC()

        if lastkey()<>K_ESC
          select fin_pripr
          go top
          do while !eof()
             if idkonto==cidkonto .and. empty(datval)
                replace  datval with datdok+ndana,;
                         datdok with dDatDok
             endif
             skip
          enddo
          go top
          return DE_REFRESH
        endif
     endif
     return DE_CONT

  case Ch==K_F8

    // brisi stavke u pripremi od - do
    if br_oddo() = 1
        return DE_REFRESH
    else
        return DE_CONT
    endif


  case Ch==K_F9
    SrediRbrFin()
    return DE_REFRESH

  case Ch==K_CTRL_T
     if Pitanje(,"Zelite izbrisati ovu stavku ?","D")=="D"

      cBDok :=field->idfirma + "-" + field->idvn + "-" + field->brnal
      cStavka := field->rbr
      cBKonto := field->idkonto
      cBDP := field->d_p
      dBDatnal := field->datdok
      cBIznos := STR(field->iznosbhd)

      delete
      __dbPack()
 
      BrisiPBaze()
      
      if lLogBrisanje
        EventLog(nUser, goModul:oDataBase:cName, "DOK", "BRISANJE",;
        nil,nil,nil,nil,;
        cBDok, "konto: " + cBKonto + " dp=" + cBDP +;
        " iznos=" + cBIznos + " KM", "",;
        dBDatNal,;
        Date(),;
        "", "Obrisana stavka broj " + cStavka + " naloga!")     
      endif
      return DE_REFRESH
     endif
     return DE_CONT

   case Ch==K_F5 

      // kontrola zbira za jedan nalog
      KontrZbNal()
      return DE_REFRESH

   case Ch==K_ENTER

       Box("ist", MAXROWS()- 5, MAXCOLS() - 8,.f.)
          set_global_vars_from_dbf()

          nRbr := VAL(_Rbr)

          if edit_fin_priprema(.f.)==0
              BoxC()
              return DE_CONT
          else
              dbf_update_rec(get_dbf_global_memvars(), .f.)
              BrisiPBaze()
              BoxC()
              return DE_REFRESH
          endif

   case Ch==K_CTRL_A
        PushWA()
        select fin_pripr
        Box("anal", MAXROWS() - 4, MAXCOLS() - 5, .f., "Ispravka naloga")
        nDug:=0
        nPot:=0
        do while !eof()
           skip

           nTR2 := RECNO()
           skip -1
           set_global_vars_from_dbf()
           nRbr:=VAL(_Rbr)
           @ m_x + 1, m_y + 1 CLEAR to m_x + 19, m_y + 74
           if edit_fin_priprema(.f.)==0
                exit
           else
                BrisiPBaze()
           endif
           if _D_P == '1'
               nDug+=_IznosBHD
           else
               nPot+=_IznosBHD
           endif

           @ m_x+19, m_y+1 SAY "ZBIR NALOGA:"
           @ m_x+19, m_y+14 SAY nDug PICTURE '9 999 999 999.99'
           @ m_x+19, m_y+35 SAY nPot PICTURE '9 999 999 999.99'
           @ m_x+19, m_y+56 SAY nDug-nPot PICTURE '9 999 999 999.99'
           inkey(10)

           select fin_pripr
           dbf_update_rec(get_dbf_global_memvars(), .f.)
           go nTR2
         enddo

         PopWA()
         BoxC()
         return DE_REFRESH

     case Ch==K_CTRL_N  // nove stavke
        select fin_pripr
        nDug:=0
        nPot:=0
        nPrvi:=0
        go top
        do while .not. eof() // kompletan nalog sumiram
            if D_P='1'
                nDug+=IznosBHD
            else
                nPot+=IznosBHD
            endif
            skip
        enddo
        go bottom
        
    Box("knjn", MAXROWS() - 4, MAXCOLS() - 3, .f., "Knjizenje naloga - nove stavke")
        do while .t.
           set_global_vars_from_dbf()
            
           if (IsRamaGlas())
                _idKonto:=SPACE(LEN(_idKonto))
                _idPartner:=SPACE(LEN(_idPartner))
                _brDok:=SPACE(LEN(_brDok))
           endif
            
           nRbr:=VAL(_Rbr) + 1
           @ m_x + 1, m_y + 1 CLEAR to m_x+19,m_y + 76
           if edit_fin_priprema(.t.)==0
                    exit
           else
                    BrisiPBaze()
           endif

           if _D_P='1'
                nDug += _IznosBHD
           else
                nPot += _IznosBHD
           endif
           @ m_x+19, m_y+1 SAY "ZBIR NALOGA:"
           @ m_x+19, m_y+14 SAY nDug PICTURE '9 999 999 999.99'
           @ m_x+19, m_y+35 SAY nPot PICTURE '9 999 999 999.99'
           @ m_x+19, m_y+56 SAY nDug-nPot PICTURE '9 999 999 999.99'
           inkey(10)

           select fin_pripr
           APPEND BLANK
           dbf_update_rec(get_dbf_global_memvars(), .f.)
                
            if lLogUnos
                cOpis := fin_pripr->idfirma + "-" + ;
                    fin_pripr->idvn + "-" + ;
                    fin_pripr->brnal

                EventLog(nUser, goModul:oDataBase:cName, ;
                    "DOK", "UNOS", ;
                    nil, nil, nil, nil,;
                    "nalog: " + cOpis, "duguje=" + STR(nDug) +;
                    " potrazuje=" + STR(nPot), "", ;
                    Date(), Date(), ;
                    "", "Unos novih stavki na nalog")
            endif
            
         enddo
         BoxC()
         return DE_REFRESH

   case Ch == K_CTRL_F9

        if Pitanje(,"Zelite li izbrisati pripremu !!????","N")=="D"
             if lLogBrisanje

            cOpis := fin_pripr->idfirma + "-" + ;
            fin_pripr->idvn + "-" + ;
            fin_pripr->brnal

            EventLog(nUser, goModul:oDataBase:cName, ;
            "DOK", "BRISANJE", ;
            nil, nil, nil, nil, ;
            cOpis, "", "", fin_pripr->datdok, Date(), ;
            "", "Brisanje kompletne pripreme !")
         endif
         zap
         BrisiPBaze()
    endif
        return DE_REFRESH

   case Ch==K_CTRL_P

     close all
     StNal()
     o_fin_edit()
     return DE_REFRESH


   case UPPER(Chr(Ch)) == "X" 

     close all
     stampa_fin_document(.t.)

     close all
     fin_azur(.t.)
     o_fin_edit()
     return DE_REFRESH


   case Ch==K_ALT_A
     fin_azur()
     o_fin_edit()
     return DE_REFRESH

   case Ch==K_ALT_B
     close all
     Blagajna()
     o_fin_edit()
     return DE_REFRESH

   case Ch==K_ALT_I
     OiNIsplate()
     return DE_CONT
 
#ifdef __PLATFORM__DARWIN 
    case Ch == ASC("0")
#else
    case Ch==K_F10
#endif
         OstaleOpcije()
         return DE_REFRESH

     case UPPER(Chr(Ch)) == "P"

         if reccount() != 0
             MsgBeep("Povrat nedozvoljen, imate stavke u pripremi")
             RETURN DE_CONT
         endif

         close all
         povrat_fin_naloga()
         o_fin_edit()
         RETURN DE_REFRESH

endcase

return DE_CONT


// ----------------------------------------
// brisi stavke iz pripreme od-do
// ----------------------------------------
static function br_oddo()
local nRet := 1
local GetList := {}
local cOd := SPACE(4)
local cDo := SPACE(4)
local nOd
local nDo

Box(,1, 31)
    @ m_x + 1, m_y + 2 SAY "Brisi stavke od:" GET cOd VALID _rbr_fix(@cOd)
    @ m_x + 1, col()+1 SAY "do:" GET cDo VALID _rbr_fix(@cDo)
    read
BoxC()

if LastKey() == K_ESC .or. ;
    Pitanje(,"Sigurno zelite brisati zapise ?","N") == "N"
    return 0
endif

go top

do while !EOF()
    
    cRbr := field->rbr

    if cRbr >= cOd .and. cRbr <= cDo
        delete
    endif

    skip
enddo

go top

return nRet


// -----------------------------------------
// fiksiranje rednog broja
// -----------------------------------------
static function _rbr_fix( cStr )

cStr := PADL( ALLTRIM(cStr), 4 )

return .t.


 
function IdPartner(cIdPartner)
local cRet

cRet := cIdPartner

return cRet



/*! \fn DifIdP(cIdPartner)
 *  \brief Formatira cIdPartner na 6 mjesta ako mu je duzina 8
 *  \param cIdPartner - id partnera
 */
 
function DifIdP(cIdPartner)
return 0



/*! \fn BrisiPBaze()
 *  \brief Brisi pomocne baze
 */
 
function BrisiPBaze()
  PushWA()
  SELECT F_PSUBAN
  ZAP
  SELECT F_PANAL
  ZAP
  SELECT F_PSINT
  ZAP
  SELECT F_PNALOG
  ZAP
  
  PopWA()

RETURN (NIL)


/*! \fn fin_tek_rec_2()
 *  \brief Tekuci zapis
 */
 
function fin_tek_rec_2()
*{
 nSlog++
 @ m_x+1, m_y+2 SAY PADC(ALLTRIM(STR(nSlog))+"/"+ALLTRIM(STR(nUkupno)),20)
 @ m_x+2, m_y+2 SAY "Obuhvaceno: "+STR(0)
RETURN (NIL)


/*! \fn OstaleOpcije()
 *  \brief Ostale opcije koje se pozivaju sa <F10>
 */
 
function OstaleOpcije()

private opc[4]
  opc[1]:="1. novi datum->datum, stari datum->dat.valute "
  opc[2]:="2. podijeli nalog na vise dijelova"
  if IzFMKINI("FIN","IzvodBanke","N")=="D"
    opc[3]:="3. preuzmi izvod iz banke"
  else
    opc[3]:="3. -------------------------------"
  endif
  opc[4]:="4. konverzija partnera"

  h[1] := h[2] := h[3] := h[4] := ""
  private Izbor:=1
  private am_x:=m_x,am_y:=m_y
  close all
  do while .t.
     Izbor:=menu("prip",opc,Izbor,.f.)
     do case
       case Izbor==0
           EXIT
       case izbor == 1
           SetDatUPripr()
       case izbor == 2
           PodijeliN()
       case izbor == 3
           if IzFMKINI("FIN","IzvodBanke","N")=="D"
             IzvodBanke()
           endif
       case izbor == 4
          msgo("konverzija - polje partnera")
          O_FIN_PRIPR
          mod_f_val("idpartner", "1", "0", 4, 2, .t. )
      go top
      msgc()
     endcase
  enddo
  m_x := am_x
  m_y:=am_y
  o_fin_edit()
RETURN


/*! \fn PodijeliN()
 *  \brief
 */
 
function PodijeliN()
local _rec
local nDug, nPot
local nRbr1 := nRbr2 := nRbr3 := nRbr4 := 0
local cBRnal1, cBrnal2, cBrnal3, cBrnal4, cBrnal5
local dDatDok
local cPomKTO := "9999999"
local cIdFirma, cIdVN, cBrNal

if !SigmaSif("PVNAPVN")
 return
endif


O_FIN_PRIPR

cBRnal1 := cBrnal2 := cBrnal3 := cBrnal4 := cBrnal5 := fin_pripr->brnal
dDatDok := fin_pripr->datdok

Box( , 10, 60)

 @ m_x+1, m_y+2 SAY "Redni broj / 1 " get nRbr1
 @ m_x+1, col()+2 SAY "novi broj naloga" GET cBRNAL1
 @ m_x+2, m_y+2 SAY "Redni broj / 2 " get nRbr2
 @ m_x+2, col()+2 SAY "novi broj naloga" GET cBRNAL2
 @ m_x+3, m_y+2 SAY "Redni broj / 3 " get nRbr3
 @ m_x+3, col()+2 SAY "novi broj naloga" GET cBRNAL3
 @ m_x+4, m_y+2 SAY "Redni broj / 4 " get nRbr4
 @ m_x+4, col()+2 SAY "novi broj naloga" GET cBRNAL4

 @ m_x+6, m_y+6 SAY "Zadnji dio, broj naloga  " get cBrnal5
 @ m_x+8, m_y+6 SAY "Pomocni konto  " get cPomKTO
 @ m_x+9, m_y+6 SAY "Datum dokumenta" get dDatDok

 read
Boxc()

if lastkey()==K_ESC
     close all
     RETURN DE_CONT
endif


nDug := nPot := 0

cIdfirma := idfirma
cIdVN    := IDVN
cBrnal   := BRNAL

go top
MsgO("Prvi krug...")
do while !eof()

 if d_p=="1"
    nDug += iznosbhd
 else
    nPot += iznosbhd
 endif

 if nRbr1<>0 .and. nRbr1==val(fin_pripr->Rbr)
    nRbr:=nRbr1

 elseif nRbr2<>0 .and. nRbr2==val(fin_pripr->Rbr)
    nRbr:=nRbr2

 elseif nRbr3<>0 .and.nRbr3==val(fin_pripr->Rbr)
    nRbr:=nRbr3

 elseif nRbr4<>0 .and.nRbr4==val(fin_pripr->Rbr)
    nRbr:=nRbr4
 else
    nRbr:=0  // nista
 endif

 if nRbr<>0

    APPEND BLANK
    _rec := dbf_get_rec()
    _rec["idvn"]    := cIdvn
    _rec["idfirma"] := cIdfirma
    _rec["brnal"]   := cBrnal
    _rec["idkonto"] := cPomKTO
    _rec["datdok"]  := dDatDok

    
    if nDug > nPot // dugovni saldo
       _rec["d_p"]      := "2"
       _rec["iznosbhd"] :=  nDug - nPot
    else
       _rec["d_p"]      := "1"
       _rec["iznosbhd"] :=  nPot - nDug
    endif

    _rec["rbr"] := STR(nRbr, 4)
    dbf_update_rec(_rec)

    // slijedi dodavanje protustavke
    APPEND BLANK
    _rec["iznosbhd"] :=  -_rec["iznosbhd"]
    _rec["opis"]     := ">prenos iz p.n.<"  
    dbf_update_rec(_rec)

    if _d_p == "2"
      nPot := iznosbhd
      nDug:=0
    else
      nDug := iznosbhd
      nPot:=0
    endif

 endif


 skip
enddo

MsgC()

MsgO("Drugi krug...")
set order to
go top
do while !eof()
   if nRbr1<>0 .and. val(fin_pripr->Rbr)<=nRbr1
      if opis=">prenos iz p.n.<"   .and. idkonto=cPomKTO
       if nRbr2=0
         replace brnal with cBrnal5
       else
        replace brnal with cBrnal2
       endif
      else
       replace brnal with cBrnal1
      endif
   elseif nRbr2<>0 .and. val(fin_pripr->Rbr)<=nRbr2
      if opis=">prenos iz p.n.<"     .and. idkonto=cPomKTO
       if nRbr3=0
         replace brnal with cBrnal5
       else
        replace brnal with cBrnal3
       endif
      else
       replace brnal with cBrnal2
      endif
   elseif nRbr3<>0 .and. val(fin_pripr->Rbr)<=nRbr3
      if opis=">prenos iz p.n.<"      .and. idkonto=cPomKTO
       if nRbr4=0
         replace brnal with cBrnal5
       else
        replace brnal with cBrnal4
       endif
      else
       replace brnal with cBrnal3
      endif
   elseif nRbr4<>0 .and. val(fin_pripr->Rbr)<=nRbr4
      if opis=">prenos iz p.n.<"    .and. idkonto=cPomKTO
       replace brnal with cBrnal5
      else
       replace brnal with cBrnal4
      endif
   else
      replace brnal with cBrnal5
   endif
   skip
enddo
MsgC()

close all
return DE_REFRESH
*}




/*! \fn BrDokOK()
 *  \brief
 */
 
function BrDokOK()
*{
local nArr
local lOK
local nLenBrDok
if (!IsRamaGlas())
    return .t.
endif
nArr:=SELECT()
lOK:=.t.
nLenBrDok:=LEN(_brDok)
select konto
seek _idkonto
if field->oznaka="TD"
    select rnal
    hseek PADR(_brDok,10)
    if !found() .or. empty(_brDok)
        MsgBeep("Unijeli ste nepostojeci broj radnog naloga. Otvaram sifrarnik radnih##naloga da biste mogli izabrati neki od postojecih!")
        P_Rnal(@_brDok,9,2)
        _brDok:=PADR(_brDok,nLenBrDok)
        ShowGets()
    endif
endif
SELECT (nArr)
return lOK
*}



/*! \fn SetTekucaRJ(cRJ)
 *  \brief Setuje tekucu radnu jedinicu 
 *  \param cRJ
 */
 
function SetTekucaRJ(cRJ)
*{
local nArr
local lUsed
nArr:=SELECT()
lUsed:=.t.
select (F_PARAMS)
if !used()
    lUsed:=.f.
    O_PARAMS
endif
Private cSection:="1",cHistory:=" ",aHistory:={}
Params1()
WPar("tj",cRJ)
if !lUsed
    select params
    use
endif
select (nArr)
return



function GetTekucaRJ()

local nArr
local lUsed
local cRJ
local nLen

nArr:=SELECT()
lUsed:=.t.

O_FIN_PRIPR
if gRJ == "D" .and. fin_pripr->(FIELDPOS("IDRJ")) <> 0
    nLen := LEN( fin_pripr->idrj )
    cRJ:=SPACE( nLen )
else
    nLen := 6
    cRj:=SPACE(nLen)
endif
select (F_PARAMS)
if !used()
    lUsed:=.f.
    O_PARAMS
endif

private cSection:="1",cHistory:=" ",aHistory:={}
Params1()
RPar("tj",@cRJ)
if !lUsed
    select params
    use
endif
select (nArr)
return ( PADR( cRJ, nLen ) )



