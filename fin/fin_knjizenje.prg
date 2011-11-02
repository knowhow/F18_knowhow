/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"


#define DABLAGAS lBlagAsis.and._IDVN==cBlagIDVN

static cTekucaRj:=""
static __par_len

// FmkIni_KumPath_TekucaRj - Tekuca radna jedinica
// Koristi se u slucaju da u Db unosimo podatke za odredjenu radnu jedinicu
// da ne bi svaki puta ukucavali tu Rj ovaj parametar nam je nudi kao tekucu vrijednost.

// ---------------------------------------------
// Unos fin naloga
// ---------------------------------------------
function Knjiz()
local izbor
private opc[4]

cSecur:= SecurR(KLevel, "Priprema")
if ImaSlovo("X",cSecur)
   MsgBeep("Opcija nedostupna !")
   closeret
endif
cSecur:=SecurR(KLevel, "SGLEDAJ")
if ImaSlovo("D",cSecur)
   MsgBeep("Opcija nedostupna !")
   closeret
endif

cTekucaRj:=GetTekucaRJ()

lBlagAsis := (IzFMKINI("BLAGAJNA","Asistent","N",PRIVPATH) == "D" )
cBlagIDVN := IzFMKINI("BLAGAJNA","SifraNaloga","66",PRIVPATH)
lAutoPomUDom := ( IzFMKINI("AutomatskoPretvaranjeIznosa","PomocnaUDomacu","N",PRIVPATH)=="D" )

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

 h[1]:=h[2]:=h[3]:=h[4]:=""
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

else   // gNW=="D"
  KnjNal()
endif
closeret
return
*}

/*! \fn KnjNal()
 *  \brief Otvara pripremu za knjizenje naloga
 */
 
function KnjNal()
O_Edit()
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
          {ValDomaca(),     {|| transform(IznosBHD,FormPicL(gPicBHD,15)) }, "iznos "+ALLTRIM(ValDomaca()) } ,;
          {ValPomocna(),    {|| transform(IznosDEM,FormPicL(gPicDEM,10)) }, "iznos "+ALLTRIM(ValPomocna()) } ,;
          {"Opis",          {|| Opis      }, "OPIS" }, ;
          {"K1",            {|| k1      }, "k1" },;
          {"K2",            {|| k2      }, "k2" },;
          {"K3",            {|| K3Iz256(k3)      }, "k3" },;
          {"K4",            {|| k4      }, "k4" } ;
        }


Kol:={}
for i:=1 to 16
	AADD(Kol,i)
next

if gRj=="D" .and. pripr->(FIELDPOS("IDRJ")) <> 0
	AADD(ImeKol, { "RJ", {|| IdRj}, "IdRj" }  )
	AADD(Kol, 17)
ENDIF


//Alert(MAXROWS())
Box( , MAXROWS() - 4, MAXCOLS() - 3)

@ m_x + MAXROWS() - 4-2, m_y+2 SAY "<c-N>  Nove Stavke    � <ENT> Ispravi stavku   � <c-T> Brisi Stavku         "
@ m_x + MAXROWS() - 4-1, m_y+2 SAY "<c-A>  Ispravka Naloga� <c-P> Stampa Naloga    � <a-A> Azuriranje           "
@ m_x + MAXROWS() - 4,   m_y+2 SAY "<c-F9> Brisi pripremu � <F5>  KZB, <a-F5> PrDat� <a-B> Blagajna,<F10> Ostalo"


ObjDbedit("PN2", MaxRows() - 4, MaxCols() - 3,  {|| EdPRIPR()}, "", "Priprema...", , , , ,3)
BoxC()
closeret
return


/*! \fn WRbr()
 *  \brief Sredjivaje rednog broja u pripremi 
 */
function WRbr()
scatter()
if val(_rbr)<2
  @ m_x+1,m_y+2 SAY "Dokument:" GET _idvn
  @ m_x+1,col()+2  GET _brnal
  read
endif

set order to 0
go top
do while !eof()
 replace idvn with _idvn, brnal with _brnal
 skip
enddo
set order to tag "1"
go top
return .t.
*}


/*! \fn VRbr()
 *  \brief 
 */
 
function vrbr()
*{
return .t.
*}



/*! \fn O_Edit()
 *  \brief Otvara unos nove stavke u pripremi
 */
 
function O_Edit()
*{
IF IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
	O_VRSTEP
ENDIF

IF IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
	O_ULIMIT
ENDIF

O_PSUBAN
O_PANAL
O_PSINT
O_PNALOG

O_PAREK
O_KONTO
O_PARTN
O_TNAL
O_TDOK

O_PRIPR


O_NALOG

if (IsRamaGlas())
	O_RNAL
endif

if gRj=="D"
	O_RJ
endif

if gTroskovi=="D"
	O_FOND
	O_FUNK
endif

select PRIPR
set order to tag "1"
go top

// ulaz _IdFirma, _IdKonto, ...., nRBr (val(_RBr))
return
*}



/*! \fn EditPripr()
 *  \brief Ispravka stavke u pripremi
 *  \param fNovi .t. - Nova stavka, .f. - Ispravka postojece
 */
 
function EditPripr()
*{
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
	@  m_x+1,m_y+2 SAY "Firma:" GET _idfirma VALID {|| P_Firma(@_IdFirma,1,20),_idfirma:=left(_idfirma,2),.t.}
    	@  m_x+3,m_y+2 SAY "NALOG: "
    	@  m_x+3,m_y+14 SAY "Vrsta:" GET _idvn VALID P_VN(@_IdVN,3,26)
endif
read

ESC_RETURN 0

if fNovi .and. (_idfirma<>idfirma .or. _idvn<>idvn)
	_brnal := nextnal( _idfirma, _idvn )
     	select  pripr
endif

set key K_ALT_K to DinDem()
set key K_ALT_O to KonsultOS()

@  m_x+3,m_y+55  SAY "Broj:"   get _BrNal   valid Dupli(_IdFirma,_IdVN,_BrNal) .and. !empty(_BrNal)
@  m_x+5,m_y+2  SAY "Redni broj stavke naloga:" get nRbr picture "9999"
@  m_x+7,m_y+2   SAY "DOKUMENT: "

if gNW<>"D"
	@  m_x+7,m_y+14  SAY "Tip:" get _IdTipDok valid P_TipDok(@_IdTipDok,7,26)
endif

if (IsRamaGlas())
	@  m_x+8,m_y+2   SAY "Vezni broj (racun/r.nalog):"  get _BrDok valid BrDokOK()
else
	@  m_x+8,m_y+2   SAY "Vezni broj:" GET _BrDok
endif

@  m_x+8,m_y+COL()+2  SAY "Datum:" GET _DatDok VALID chk_sezona() 

if cDatVal=="D"
	@  m_x+8,col()+2 SAY "Valuta" GET _DatVal
endif

@ m_x+11, m_y+2  SAY "Opis :" GET _Opis WHEN {|| USTipke(),.t.} VALID {|| BosTipke(),.t.} PICT "@S20"

if fk1=="D"
	@  m_x+11,col()+2 SAY "K1" GET _k1 pict "@!" 
endif

if fk2=="D"
	@  m_x+11,col()+2 SAY "K2" GET _k2 pict "@!"
endif

if fk3=="D"
	if IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
       		_k3:=K3Iz256(_k3)
       		@  m_x+11,col()+2 SAY "K3" GET _k3 VALID EMPTY(_k3).or.P_ULIMIT(@_k3) pict "999"
     	else
       		@  m_x+11,col()+2 SAY "K3" GET _k3 pict "@!"
     	endif
endif

if fk4=="D"
	if IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
       		@  m_x+11,col()+2 SAY "K4" GET _k4 VALID EMPTY(_k4).or.P_VRSTEP(@_k4) pict "@!"
     	else
       		@  m_x+11,col()+2 SAY "K4" GET _k4 pict "@!"
     	endif
endif

if gRj=="D" .and. pripr->(FIELDPOS("IDRJ")) <> 0
	@  m_x+11,col()+2 SAY "RJ" GET _idrj valid empty(_idrj) .or. P_Rj(@_idrj) PICT "@!"
	
endif

if gTroskovi=="D"
	@ m_x+12,m_y+22 SAY "      Funk." GET _Funk valid empty(_Funk) .or. P_Funk(@_Funk) pict "@!"
       	@  m_x+12,m_y+44 SAY "      Fond." GET _Fond valid empty(_Fond) .or. P_Fond(@_Fond) pict "@!"
endif



if DABLAGAS
	@ m_x+13,m_y+2   SAY "Konto  :" get _IdKonto    pict "@!" valid  Partija(@_IdKonto) .and. P_Konto(@_IdKonto,13,20,.t.) .and. BrDokOK() .and. MinKtoLen(_IdKonto) .and. _rule_kto_()

else
    	@  m_x+13,m_y+2  SAY "Konto  :" get _IdKonto    pict "@!" valid  Partija(@_IdKonto) .and. P_Konto(@_IdKonto,13,20) .and. BrDokOK() .and. MinKtoLen(_IdKonto) .and. _rule_kto_()

endif

@ m_x+14,m_y+2 SAY "Partner:" get _IdPartner pict "@!" valid ;
	{|| if( empty(_idpartner), Reci(14,20,SPACE(25)), ), ;
	( EMPTY(_IdPartner) .or. P_Firma(@_IdPartner,14,20) ) .and. _rule_partn_() } when ;
	{|| iif(ChkKtoMark(_idkonto),.t.,.f.)}

@ m_x+16,m_y+2  SAY "Duguje/Potrazuje (1/2):" get _D_P valid V_DP() .and. _rule_d_p_() .and. _rule_veza_()

@ m_x+16,m_y+46  GET _IznosBHD  PICTURE "999999999999.99"
@ m_x+17,m_y+46  GET _IznosDEM  WHEN {|| DinDEM(,,"_IZNOSBHD"),.t.} VALID {|oGet| V_IznosDEM(,,"_IZNOSDEM",oGet)} PICTURE '9999999999.99'
@ m_x,m_y+50 SAY " <a-O> Otvorene stavke "
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
set key K_ALT_O to

_k3:=K3U256(_k3)
_Rbr:=STR(nRbr,4)

return 1
*}

// provjeri datum dokumenta na osnovu tek.sezona i upozori
static function chk_sezona()
local nYearDok
local nYearSez
local cCurrSez
local cTmp := ""

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
	
	altd()
	
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
*{
    if (ChkKtoMark(_idkonto))
        cIdPartner := cNewPartner
    else
        cIdPartner := space(6)
    endif

return .t.
*}

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
   	select pripr
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

/*! \fn EdPRIPR()
 *  \brief Ostale operacije u ispravki stavke
 */

function EdPRIPR()
*{
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

select pripr
do case

case Ch==K_ALT_F5
     if pitanje(,"Za konto u nalogu postaviti datum val. DATDOK->DATVAL","N")=="D"
        cIdKonto:=space(7)
        dDatDok:=date()
        nDana:=15
        Box(,5,60)
          @ m_x+1,m_Y+2 SAY "Promjena za konto  " GET cIdKonto
          @ m_x+3,m_Y+2 SAY "Novi datum dok " GET dDatDok
          @ m_x+5,m_Y+2 SAY "uvecati stari datdok za (dana) " GET nDana pict "99"
          read
        BoxC()
        if lastkey()<>K_ESC
          select pripr
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
  	SrediRbr()
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
    Box("ist",20,75,.f.)
    Scatter()
    nRbr:=VAL(_Rbr)
    if EditPRIPR(.f.)==0
     BoxC()
     return DE_CONT
    else
     Gather()
     BrisiPBaze()
     BoxC()
     return DE_REFRESH
    endif

   case Ch==K_CTRL_A
        PushWA()
        select PRIPR
        //go top
        Box("anal", MAXROWS() - 4, MAXCOLS() - 5,.f.,"Ispravka naloga")
        nDug:=0
	nPot:=0
        do while !eof()
           skip
	   nTR2:=RECNO()
	   skip-1
           Scatter()
           nRbr:=VAL(_Rbr)
           @ m_x+1,m_y+1 CLEAR to m_x+19,m_y+74
           if EditPRIPR(.f.)==0
           	exit
           else
             	BrisiPBaze()
           endif
           if _D_P='1'
	   	nDug+=_IznosBHD
	   else
	        nPot+=_IznosBHD
	   endif
           @ m_x+19,m_y+1 SAY "ZBIR NALOGA:"
           @ m_x+19,m_y+14 SAY nDug PICTURE '9 999 999 999.99'
           @ m_x+19,m_y+35 SAY nPot PICTURE '9 999 999 999.99'
           @ m_x+19,m_y+56 SAY nDug-nPot PICTURE '9 999 999 999.99'
           inkey(10)
           select PRIPR
           Gather()
           go nTR2
         enddo
         PopWA()
         BoxC()
         return DE_REFRESH

     case Ch==K_CTRL_N  // nove stavke
	select pripr
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
           Scatter()
	   
	   if (IsRamaGlas())
	   	_idKonto:=SPACE(LEN(_idKonto))
		_idPartner:=SPACE(LEN(_idPartner))
		_brDok:=SPACE(LEN(_brDok))
	   endif
	   
           nRbr:=VAL(_Rbr)+1
           @ m_x+1, m_y+1 CLEAR to m_x+19,m_y + 76
           if EditPRIPR(.t.)==0
             exit
           else
             BrisiPBaze()
           endif
           if _D_P='1'
	   	nDug+=_IznosBHD
	   else
	   	nPot+=_IznosBHD
	   endif
           @ m_x+19, m_y+1 SAY "ZBIR NALOGA:"
           @ m_x+19, m_y+14 SAY nDug PICTURE '9 999 999 999.99'
           @ m_x+19, m_y+35 SAY nPot PICTURE '9 999 999 999.99'
           @ m_x+19, m_y+56 SAY nDug-nPot PICTURE '9 999 999 999.99'
           inkey(10)
	   select PRIPR
	   //SrediRbr(.t.)
           APPEND BLANK
           Gather()
           
	   if lLogUnos

	   	  cOpis := pripr->idfirma + "-" + ;
		  	pripr->idvn + "-" + ;
			pripr->brnal

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
   case Ch=K_CTRL_F9
        if Pitanje(,"Zelite li izbrisati pripremu !!????","N")=="D"
             if lLogBrisanje

	        cOpis := pripr->idfirma + "-" + ;
			pripr->idvn + "-" + ;
			pripr->brnal

	     	EventLog(nUser, goModul:oDataBase:cName, ;
			"DOK", "BRISANJE", ;
			nil, nil, nil, nil, ;
			cOpis, "", "", pripr->datdok, Date(), ;
			"", "Brisanje kompletne pripreme !")
	     endif
	     zap
             BrisiPBaze()
	endif
        return DE_REFRESH

   case Ch==K_CTRL_P
     close all
     StNal()
     O_Edit()
     return DE_REFRESH


   case Ch==K_ALT_F10

     if !SigmaSif("SIGMAXXX")
       return DE_CONT
     endif

     close all
     StNal(.t.)

     // pa azuriraj
     close all
     fin_azur(.t.)
     O_Edit()
     return DE_REFRESH


   case Ch==K_ALT_A
     fin_azur()
     O_Edit()
     return DE_REFRESH

   case Ch==K_ALT_B
     close all
     Blagajna()
     O_Edit()
     return DE_REFRESH

   case Ch==K_ALT_I
     OiNIsplate()
     return DE_CONT

   case Ch==K_F10 
     OstaleOpcije()
     return DE_REFRESH

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


/*! \fn Preduzece()
 *  \brief Vraca naziv firme
 */
 
function Preduzece()
local nArr:=select()
F10CPI
B_ON
? gTS+": "
if gNW=="D"
 ?? gFirma,"-",gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ?? cIdFirma,partn->naz,partn->naz2
endif
B_OFF
?
select (nArr)
return


/*! \fn BrisiPBaze()
 *  \brief Brisi pomocne baze
 */
 
function BrisiPBaze()
*{
  PushWA()
  SELECT F_PSUBAN; ZAP
  SELECT F_PANAL; ZAP
  SELECT F_PSINT; ZAP
  SELECT F_PNALOG; ZAP
  PopWA()
RETURN (NIL)
*}


/*! \fn PreuzSezSPK(cSif)
 *  \brief Preuzimanje sifre iz sezone
 *  \param cSif
 */
 
function PreuzSezSPK(cSif)
*{
*static string
static cSezNS:="1998"
*;
 LOCAL nObl:=SELECT()
 Box(,3,70)
  cSezNS:=PADR(cSezNS,4)
  @ m_x+1,m_y+2 SAY "Sezona:" GET cSezNS PICT "9999"
  READ
  cSezNS:=ALLTRIM(cSezNS)
 BoxC()
 IF cSif=="P"
   USE (TRIM(cDirSif)+"\"+cSezNS+"\PARTN") ALIAS PARTN2 NEW
   SELECT PARTN2
   SET ORDER TO TAG "ID"
   GO TOP
   HSEEK PSUBAN->idpartner
   IF FOUND()
     SELECT PARTN
     APPEND BLANK
     REPLACE id WITH PARTN2->id,;
            naz WITH PARTN2->naz,;
         mjesto WITH PARTN2->mjesto
   ELSE
     SELECT PARTN
     APPEND BLANK
     REPLACE id WITH PSUBAN->idpartner
   ENDIF
   SELECT PARTN2; USE
 ELSE
   USE (TRIM(cDirSif)+"\"+cSezNS+"\KONTO") ALIAS KONTO2 NEW
   SELECT KONTO2
   SET ORDER TO TAG "ID"
   GO TOP
   HSEEK PSUBAN->idkonto
   IF FOUND()
     SELECT KONTO
     APPEND BLANK
     REPLACE id WITH KONTO2->id, naz WITH KONTO2->naz
   ELSE
     SELECT KONTO
     APPEND BLANK
     REPLACE id WITH PSUBAN->idkonto
   ENDIF
   SELECT KONTO2; USE
 ENDIF
 SELECT (nObl)
RETURN



/*! \fn SintFilt(lSint,cFilter)
 *  \brief Iz filterisane SUBAN.DBF tabele generise POM.DBF
 *  \brief Ova funkcija ne podrzava varijantu gDatNal:="D"
 *  \param lSint   - .t.-POM.DBF je analitika, .f.-POM.DBF
 *  \param cFilter
 */
 
function SintFilt(lSint,cFilter)
*{
IF lSint==NIL; lSint:=.f.; ENDIF
  // napravimo pomocnu bazu
  aDbf := {}
  AADD(aDBf,{ 'IDFIRMA'   , 'C' ,   2 ,  0 })
  AADD(aDBf,{ 'IDKONTO'   , 'C' , IF(lSint,3,7) ,  0 })
  AADD(aDBf,{ 'IDVN'      , 'C' ,   2 ,  0 })
  AADD(aDBf,{ 'BRNAL'     , 'C' ,   8 ,  0 })
  AADD(aDBf,{ 'RBR'       , 'C' ,   3 ,  0 })
  AADD(aDBf,{ 'DATNAL'    , 'D' ,   8 ,  0 })
  AADD(aDBf,{ 'DUGBHD'    , 'N' ,  17 ,  2 })
  AADD(aDBf,{ 'POTBHD'    , 'N' ,  17 ,  2 })
  AADD(aDBf,{ 'DUGDEM'    , 'N' ,  15 ,  2 })
  AADD(aDBf,{ 'POTDEM'    , 'N' ,  15 ,  2 })

  DBCREATE2 (PRIVPATH+"POM", aDbf)
  IF !lSint
    USEX (PRIVPATH+"POM", "ANAL", .t.)
  ELSE
    USEX (PRIVPATH+"POM", "SINT", .f.)
  ENDIF
  INDEX ON idFirma+IdVN+BrNal+IdKonto TAG "0"
  IF lSint
    INDEX ON IdFirma+IdKonto+dtos(DatNal) TAG "1"
    INDEX ON idFirma+IdVN+BrNal+Rbr       TAG "2"
  ELSE
    INDEX ON IdFirma+IdKonto+dtos(DatNal) TAG "1"
    INDEX ON idFirma+IdVN+BrNal+Rbr       TAG "2"
    INDEX ON idFirma+dtos(DatNal)         TAG "3"
    INDEX ON Idkonto                      TAG "4"
    INDEX ON DatNal                       TAG "5"
  ENDIF
  SET ORDER TO TAG "0"
  GO TOP

  O_SUBAN
  Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cFilt:=cFilter
  cSort1:="idFirma+IdVN+BrNal+IdKonto"
  INDEX ON &cSort1 TO "SUBTMP" FOR &cFilt EVAL(TekRec2()) EVERY 1
  GO TOP
  nArr:=SELECT()
  BoxC()

  DO WHILE !eof()   // svi nalozi

    nD1:=nD2:=nP1:=nP2:=0
    cIdFirma:=IdFirma; cIDVn=IdVN; cBrNal:=BrNal

    DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog

        cIdkonto:=idkonto

        nDugBHD:=nDugDEM:=0
        nPotBHD:=nPotDEM:=0
        IF D_P="1"
          nDugBHD:=IznosBHD; nDugDEM:=IznosDEM
        ELSE
          nPotBHD:=IznosBHD; nPotDEM:=IznosDEM
        ENDIF

        IF !lSint
          SELECT ANAL     // analitika
          seek cidfirma+cidvn+cbrnal+cidkonto
          fNasao:=.f.
          DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal ;
                     .and. IdKonto==cIdKonto
            if month((nArr)->datdok)==month(datnal)
              fNasao:=.t.
              exit
            endif
            skip 1
          enddo
          if !fNasao
             append blank
          endif

          REPLACE IdFirma WITH cIdFirma,IdKonto WITH cIdKonto,IdVN WITH cIdVN,;
                  BrNal with cBrNal,;
                  DatNal WITH max((nArr)->datdok,datnal),;
                  DugBHD WITH DugBHD+nDugBHD,PotBHD WITH PotBHD+nPotBHD,;
                  DugDEM WITH DugDEM+nDugDEM, PotDEM WITH PotDEM+nPotDEM

        ELSE             // sintetika
  
          SELECT SINT
          seek cidfirma+cidvn+cbrnal+left(cidkonto,3)
          fNasao:=.f.
          DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal ;
                    .and. left(cidkonto,3)==idkonto
            if  month((nArr)->datdok)==month(datnal)
              fNasao:=.t.
              exit
            endif
            skip 1
          enddo
          if !fNasao
              append blank
          endif

          REPLACE IdFirma WITH cIdFirma,IdKonto WITH left(cIdKonto,3),IdVN WITH cIdVN,;
               BrNal WITH cBrNal,;
               DatNal WITH max((nArr)->datdok,datnal),;
               DugBHD WITH DugBHD+nDugBHD,PotBHD WITH PotBHD+nPotBHD,;
               DugDEM WITH DugDEM+nDugDEM,PotDEM WITH PotDEM+nPotDEM
        ENDIF
        SELECT (nArr)
        skip 1
    ENDDO  // nalog

    SELECT (nArr)

  ENDDO  // svi nalozi
  SELECT (nArr); USE

  IF !lSint
    SELECT ANAL
  ELSE
    SELECT SINT
  ENDIF
  go top
  do while !eof()
    nRbr:=0
    cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
    do while !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog
      replace rbr with str(++nRbr,3)
      skip 1
    enddo
  enddo
  SET ORDER TO TAG "1"
  GO TOP

RETURN
*}


/*! \fn TekRec2()
 *  \brief Tekuci zapis
 */
 
function TekRec2()
*{
 nSlog++
 @ m_x+1, m_y+2 SAY PADC(ALLTRIM(STR(nSlog))+"/"+ALLTRIM(STR(nUkupno)),20)
 @ m_x+2, m_y+2 SAY "Obuhvaceno: "+STR(0)
RETURN (NIL)


/*! \fn OstaleOpcije()
 *  \brief Ostale opcije koje se pozivaju sa <F10>
 */
 
function OstaleOpcije()
*{
private opc[4]
  opc[1]:="1. novi datum->datum, stari datum->dat.valute "
  opc[2]:="2. podijeli nalog na vise dijelova"
  if IzFMKINI("FIN","IzvodBanke","N")=="D"
    opc[3]:="3. preuzmi izvod iz banke"
  else
    opc[3]:="3. -------------------------------"
  endif
  opc[4]:="4. konverzija partnera"
  h[1]:=h[2]:=h[3]:=h[4]:=""
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
	  O_PRIPR
          mod_f_val("idpartner", "1", "0", 4, 2, .t. )
	  go top
	  msgc()
     endcase
  enddo
  m_x:=am_x; m_y:=am_y
  O_Edit()
RETURN


/*! \fn PodijeliN()
 *  \brief
 */
 
function PodijeliN()
*{
if !SigmaSif("PVNAPVN")
 return
endif

cPomKTO:="9999999"

O_PRIPR

nRbr1:=nRbr2:=nRbr3:=nRbr4:=0
cBRnal1:=cBrnal2:=cBrnal3:=cBrnal4:=cBrnal5:=pripr->brnal
dDatDok:=pripr->datdok

Box(,10,60)
 @ m_x+1,m_y+2 SAY "Redni broj / 1 " get nRbr1
 @ m_x+1,col()+2 SAY "novi broj naloga" GET cBRNAL1
 @ m_x+2,m_y+2 SAY "Redni broj / 2 " get nRbr2
 @ m_x+2,col()+2 SAY "novi broj naloga" GET cBRNAL2
 @ m_x+3,m_y+2 SAY "Redni broj / 3 " get nRbr3
 @ m_x+3,col()+2 SAY "novi broj naloga" GET cBRNAL3
 @ m_x+4,m_y+2 SAY "Redni broj / 4 " get nRbr4
 @ m_x+4,col()+2 SAY "novi broj naloga" GET cBRNAL4

 @ m_x+6,m_y+6 SAY "Zadnji dio, broj naloga  " get cBrnal5
 @ m_x+8,m_y+6 SAY "Pomocni konto  " get cPomKTO
 @ m_x+9,m_y+6 SAY "Datum dokumenta" get dDatDok

 read
Boxc()
if lastkey()==K_ESC
     close all
     RETURN DE_CONT
endif


nDug:=nPot:=0

cIdfirma:=idfirma
cIdVN:=IDVN
cBrnal:=BRNAL

go top
MsgO("Prvi krug...")
do while !eof()
 if d_p=="1"
    nDug+=iznosbhd
 else
    nPot+=iznosbhd
 endif

 if nRbr1<>0 .and. nRbr1==val(pripr->Rbr)
    nRbr:=nRbr1
 elseif nRbr2<>0 .and. nRbr2==val(pripr->Rbr)
    nRbr:=nRbr2
 elseif nRbr3<>0 .and.nRbr3==val(pripr->Rbr)
    nRbr:=nRbr3
 elseif nRbr4<>0 .and.nRbr4==val(pripr->Rbr)
    nRbr:=nRbr4
 else
    nRbr:=0  // nista
 endif

 if nRbr<>0
    append blank
    replace idvn with cidvn,idfirma with cidfirma, brnal with cbrnal,;
            idkonto with cPomKTO, datdok with dDatDok

    if ndug>nPot // dugovni saldo
       replace d_p with "2"
       replace iznosbhd with (nDug-nPot)
    else
       replace d_p with "1"
       replace iznosbhd with (nPot-nDug)
    endif
    replace rbr with str(nRbr,4)

    // protustavka
    Scatter()
    append blank
    _iznosbhd:=-_iznosbhd
    _opis:=">prenos iz p.n.<"  // prenos iz predhodnog naloga
    Gather()

    if _d_p=="2"  // inicijalizuj ndug,npot
      nPot:=iznosbhd; nDug:=0
    else
      nDug:=iznosbhd; nPot:=0
    endif

 endif


 skip
enddo
MsgC()

MsgO("Drugi krug...")
set order to
go top
do while !eof()
   if nRbr1<>0 .and. val(pripr->Rbr)<=nRbr1
      altd()
      if opis=">prenos iz p.n.<"   .and. idkonto=cPomKTO
       if nRbr2=0
         replace brnal with cBrnal5
       else
        replace brnal with cBrnal2
       endif
      else
       replace brnal with cBrnal1
      endif
   elseif nRbr2<>0 .and. val(pripr->Rbr)<=nRbr2
      if opis=">prenos iz p.n.<"     .and. idkonto=cPomKTO
       if nRbr3=0
         replace brnal with cBrnal5
       else
        replace brnal with cBrnal3
       endif
      else
       replace brnal with cBrnal2
      endif
   elseif nRbr3<>0 .and. val(pripr->Rbr)<=nRbr3
      if opis=">prenos iz p.n.<"      .and. idkonto=cPomKTO
       if nRbr4=0
         replace brnal with cBrnal5
       else
        replace brnal with cBrnal4
       endif
      else
       replace brnal with cBrnal3
      endif
   elseif nRbr4<>0 .and. val(pripr->Rbr)<=nRbr4
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


/*! \fn SetDatUPripr()
 *  \brief Postavi datum u pripremi
 */
 
function SetDatUPripr()
*{
  PRIVATE cTDok:="00"
  PRIVATE dDatum:=CTOD("01.01."+STR(YEAR(DATE()),4))
  IF !VarEdit({ {"Postaviti datum dokumenta","dDatum",,,},;
                {"Promjenu izvrsiti u nalozima vrste","cTDok",,,} }, 10,0,15,79,;
              'SETOVANJE NOVOG DATUMA DOKUMENTA I PREBACIVANJE STAROG U DATUM VALUTE',;
              "B1")
    CLOSERET
  ENDIF
  O_PRIPR
  GO TOP
  DO WHILE !EOF()
    IF IDVN<>cTDok; SKIP 1; LOOP; ENDIF
    Scatter()
    IF EMPTY(_datval)
      _datval:=_datdok
    ENDIF
    _datdok:=dDatum
    Gather()
    SKIP 1
  ENDDO
CLOSERET
return
*}


/*! \fn StSubNal(cInd,lAuto)
 *  \brief Stapmanje subanalitickog naloga
 *  \param cInd  - "1"-stampa pripreme, "2"-stampa azuriranog, "3"-stampa dnevnika
 *  \param lAuto
 */
 
function StSubNal(cInd,lAuto)
LOCAL nArr:=SELECT(), aRez:={}, aOpis:={}

IF lAuto = NIL
	lAuto := .f.
ENDIF
O_PARTN
__par_len := LEN(partn->id)
select (nArr)

lJerry := ( IzFMKIni("FIN","JednovalutniNalogJerry","N",KUMPATH) == "D" )

PicBHD:="@Z "+FormPicL(gPicBHD,15)
PicDEM:="@Z "+FormPicL(gPicDEM,10)

IF gNW=="N"
     M:=IF(cInd=="3","------ ---------- --- ","")+"---- ------- " + REPL("-", __par_len) + " ----------------------------"+IF(gVar1=="1".and.lJerry,"-- "+REPL("-",20),"")+" -- ------------- ----------- -------- -------- --------------- ---------------"+IF(gVar1=="1","-"," ---------- ----------")
ELSE
     M:=IF(cInd=="3","------ ---------- --- ","")+"---- ------- " + REPL("-", __par_len) + " ----------------------------"+IF(gVar1=="1".and.lJerry,"-- "+REPL("-",20),"")+" ----------- -------- -------- --------------- ---------------"+IF(gVar1=="1","-"," ---------- ----------")
ENDIF

IF cInd $ "1#2"
     nUkDugBHD:=nUkPotBHD:=nUkDugDEM:=nUkPotDEM:=0
     nStr:=0
//     nUkDug:=nUkPot:=0
ENDIF

   b2:={|| cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal}
   // cVN:=VN; cFirma:=Firma1+Firma2
   cIdFirma:=IdFirma; cIdVN:=IdVN; cBrNal:=BrNal

IF cInd $ "1#2" .and. !lAuto
     Zagl11()
ENDIF

DO WHILE !eof() .and. eval(b2)
      if !lAuto
       if prow()>61+IF(cInd=="3",-7,0)+gPStranica
         if cInd=="3"
           PrenosDNal()
         else
           FF
         endif
         Zagl11()
       endif
       P_NRED
       IF cInd=="3"
         @ prow(),0 SAY STR(++nRBrDN,6)
         @ prow(),pcol()+1 SAY cIdFirma+"-"+cIdVN+"-"+cBrNal
         @ prow(),pcol()+1 SAY " "+LEFT(DTOC(dDatNal),2)
         @ prow(),pcol()+1 SAY RBr
       ELSE
         @ prow(),0 SAY RBr
       ENDIF
       @ prow(),pcol()+1 SAY IdKonto

       if !empty(IdPartner)
         if gVSubOp=="D"
           select KONTO; hseek (nArr)->idkonto
           select PARTN; hseek (nArr)->idpartner
           cStr:=TRIM(KONTO->naz)+" ("+TRIM(trim(naz)+" "+trim(naz2))+")"
         else
           select PARTN; hseek (nArr)->idpartner
           cStr:=trim(naz)+" "+trim(naz2)
         endif
       else
         select KONTO;  hseek (nArr)->idkonto
         cStr:=naz
       endif
       select (nArr)

       IF gVar1=="1" .and. lJerry
         aRez:={PADR(cStr,30)}
         cStr:=opis
         aOpis:=SjeciStr(cStr,20)
       ELSE
         aRez:=SjeciStr(cStr,28)
         cStr:=opis
         aOpis:=SjeciStr(cStr,20)
       ENDIF

       @ prow(),pcol()+1 SAY Idpartner(idpartner)

       nColStr:=PCOL()+1

       @  prow(),pcol()+1 SAY padr(aRez[1],28+IF(gVar1=="1".and.lJerry,2,0))
       //-DifIdP(idpartner)) // dole cu nastaviti

       nColDok:=PCOL()+1

       IF gVar1=="1" .and. lJerry
         @ prow(),pcol()+1 SAY aOpis[1]
       ENDIF

       if gNW=="N"
         @ prow(),pcol()+1 SAY IdTipDok
         select TDOK;  hseek (nArr)->idtipdok
         @ prow(),pcol()+1 SAY naz
         select (nArr)
         @ prow(),pcol()+1 SAY padr(BrDok,11)
       else
         @ prow(),pcol()+1 SAY padr(BrDok,11)
       endif
       @ prow(),pcol()+1 SAY DatDok
       if cDatVal=="D"
         @ prow(),pcol()+1 SAY DatVal
       else
         @ prow(),pcol()+1 SAY space(8)
       endif
       nColIzn:=pcol()+1
      endif

      IF D_P=="1"
         if !lAuto
           @ prow(),pcol()+1 SAY IznosBHD PICTURE PicBHD
           @ prow(),pcol()+1 SAY 0 PICTURE PicBHD
         endif
         nUkDugBHD+=IznosBHD
         IF cInd=="3"
           nTSDugBHD+=IznosBHD
         ENDIF
      ELSE
         if !lAuto
           @ prow(),pcol()+1 SAY 0 PICTURE PicBHD
           @ prow(),pcol()+1 SAY IznosBHD PICTURE PicBHD
         endif
         nUkPotBHD+=IznosBHD
         IF cInd=="3"
           nTSPotBHD+=IznosBHD
         ENDIF
      ENDIF

      IF gVar1!="1"
        if D_P=="1"
           if !lAuto
             @ prow(),pcol()+1 SAY IznosDEM PICTURE PicDEM
             @ prow(),pcol()+1 SAY 0 PICTURE PicDEM
           endif
           nUkDugDEM+=IznosDEM
           IF cInd=="3"
             nTSDugDEM+=IznosDEM
           ENDIF
        else
           if !lAuto
             @ prow(),pcol()+1 SAY 0 PICTURE PicDEM
             @ prow(),pcol()+1 SAY IznosDEM PICTURE PicDEM
           endif
           nUkPotDEM+=IznosDEM
           IF cInd=="3"
             nTSPotDEM+=IznosDEM
           ENDIF
        endif
      ENDIF

      if !lAuto
        Pok:=0
        for i:=2 to max(len(aRez),len(aOpis)+IF(gVar1=="1".and.lJerry,0,1))
          if i<=len(aRez)
            @ prow()+1,nColStr say aRez[i]
          else
            pok:=1
          endif
          IF gVar1=="1" .and. lJerry
            @ prow()+pok,nColDok say IF( i<=len(aOpis) , aOpis[i] , SPACE(20) )
          ELSE
            @ prow()+pok,nColDok say IF( i-1<=len(aOpis) , aOpis[i-1] , SPACE(20) )
          ENDIF
          if i==2 .and. ( !Empty(k1+k2+k3+k4) .or. grj=="D" .or. gtroskovi=="D" )
            ?? " "+k1+"-"+k2+"-"+K3Iz256(k3)+"-"+k4
            if IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
              ?? "("+Ocitaj(F_VRSTEP,k4,"naz")+")"
            endif
            if gRj=="D"
	    	?? " RJ:",idrj
	    endif
            if gTroskovi=="D"
              ?? "    Funk:",Funk
              ?? "    Fond:",Fond
            endif
          endif
        next
      endif

      IF cInd=="1" .and. ASCAN(aNalozi,cIdFirma+cIdVN+cBrNal)==0  // samo ako se ne nalazi u psuban
        select PSUBAN; Scatter(); select (nArr); Scatter()
        SELECT PSUBAN; APPEND BLANK
        Gather()  // stavi sve vrijednosti iz PRIPR u PSUBAN
      ENDIF
      select (nArr)
      SKIP 1
   ENDDO

   IF cInd $ "1#2" .and. !lAuto
     IF prow()>58+gPStranica; FF; Zagl11();  endif
     P_NRED
     ?? M
     P_NRED
     ?? "Z B I R   N A L O G A:"
     @ prow(),nColIzn  SAY nUkDugBHD PICTURE picBHD
     @ prow(),pcol()+1 SAY nUkPotBHD PICTURE picBHD
     IF gVar1!="1"
       @ prow(),pcol()+1 SAY nUkDugDEM PICTURE picDEM
       @ prow(),pcol()+1 SAY nUkPotDEM PICTURE picDEM
     ENDIF
     P_NRED
     ?? M
     nUkDugBHD:=nUKPotBHD:=nUkDugDEM:=nUKPotDEM:=0

     if gPotpis=="D"
       IF prow()>58+gPStranica; FF; Zagl11();  endif
       P_NRED
       P_NRED; F12CPI
       P_NRED
       @ prow(),55 SAY "Obrada AOP "; ?? replicate("_",20)
       P_NRED
       @ prow(),55 SAY "Kontirao   "; ?? replicate("_",20)
     endif
     FF
   ELSEIF cInd=="3"
      if prow()>54+gPStranica
        PrenosDNal()
      endif
   ENDIF
RETURN
*}


/*! \fn PrenosDNal()
 *  \brief Ispis prenos na sljedecu stranicu
 */
 
function PrenosDNal()
*{
? m
  ? PADR("UKUPNO NA STRANI "+ALLTRIM(STR(nStr)),30)+":"
   @ prow(),nColIzn  SAY nTSDugBHD PICTURE picBHD
   @ prow(),pcol()+1 SAY nTSPotBHD PICTURE picBHD
   IF gVar1!="1"
     @ prow(),pcol()+1 SAY nTSDugDEM PICTURE picDEM
     @ prow(),pcol()+1 SAY nTSPotDEM PICTURE picDEM
   ENDIF
  ? m
  ? PADR("DONOS SA PRETHODNE STRANE",30)+":"
   @ prow(),nColIzn  SAY nUkDugBHD-nTSDugBHD PICTURE picBHD
   @ prow(),pcol()+1 SAY nUkPotBHD-nTSPotBHD PICTURE picBHD
   IF gVar1!="1"
     @ prow(),pcol()+1 SAY nUkDugDEM-nTSDugDEM PICTURE picDEM
     @ prow(),pcol()+1 SAY nUkPotDEM-nTSPotDEM PICTURE picDEM
   ENDIF
  ? m
  ? PADR("PRENOS NA NAREDNU STRANU",30)+":"
   @ prow(),nColIzn  SAY nUkDugBHD PICTURE picBHD
   @ prow(),pcol()+1 SAY nUkPotBHD PICTURE picBHD
   IF gVar1!="1"
     @ prow(),pcol()+1 SAY nUkDugDEM PICTURE picDEM
     @ prow(),pcol()+1 SAY nUkPotDEM PICTURE picDEM
   ENDIF
  ? m
  FF
  nTSDugBHD:=nTSPotBHD:=nTSDugDEM:=nTSPotDEM:=0   // tekuca strana
RETURN
*}


/*! \fn IzvodBanke()
 *  \brief Formira nalog u pripremi na osnovu txt-izvoda iz banke
 */
 
function IzvodBanke()
*{
 LOCAL nIF:=1, cBrNal:=""
 PRIVATE cLFSpec := "A:\ZEN*.", cIdVn:="99"

 O_NALOG
 O_PRIPR
 if reccount2()<>0
   Msg("Priprema mora biti prazna !")
   closeret
 endif

 Box(,20,75); old_m_x := m_x; old_m_y := m_y

  O_PARAMS
   PRIVATE cSection:="7",cHistory:=" ",aHistory:={}
    RPar("f1",@cLFSpec)
     RPar("f2",@cIdVn)
      SELECT PARAMS; USE

  cLFSpec:=PADR(cLFSpec,50)
  @ m_x+2, m_y+2 SAY "Lokacija i specifikacija fajla-izvoda banke" GET cLFSpec PICT "@!S30"
  @ m_x+3, m_y+2 SAY "Vrsta naloga koji se formira (prazno-ne formiraj nalog):" GET cIdVn
  READ; ESC_BCR
  cLFSpec:=TRIM(cLFSpec)

  O_PARAMS
   PRIVATE cSection:="7",cHistory:=" "; aHistory:={}
    WPar("f1",cLFSpec)
     WPar("f2",cIdVn)
      SELECT PARAMS; USE

  aFajlovi := DIRECTORY(cLFSpec)
  IF LEN(aFajlovi)<1
    MsgBeep("Na izabranoj lokaciji ne postoji nijedan specificirani fajl!")
    BoxC(); CLOSERET
  ENDIF

  FOR i:=1 TO LEN(aFajlovi); aFajlovi[i]:=PADR(aFajlovi[i,1],20); NEXT
  nIF := Menu("IBan",aFajlovi,nIF,.f.)
  IF nIF<1
    BoxC(); CLOSERET
  ELSE
    // zatvaranje prozora menija
    // -------------------------
    Menu("IBan",aFajlovi,0,.f.)
  ENDIF
  cIme := LEFT(cLFSpec,2)+"\"+TRIM(aFajlovi[nIF])
  m_x := old_m_x; m_y := old_m_y
  @ m_x+4, m_y+2 SAY "Izabran fajl:"
  @ m_x+4, col()+2 SAY cIme COLOR INVERT

  nH   := fopen(cIme)
  nRBr := 0
  cBrNal := nextnal( gFirma, cIdvn )
  
  StartPrint(.t.)

  P_COND2
  ? "旼컴컫컴컴컴컴쩡컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커"
  ? "쿝.BR� DATUM  쿩IRO-RACUN      쿛OSILJAOC: NAZIV, ADRESA I MJESTO                                                         쿛OZIV NA BROJ                     �"
  ? "쳐컴컨컴컴컴컴좔컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컫컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴쩡컴컴컴좌컴컴컴컴쩡컴쩡컴컴컴컴컫컴컴컴컴캑"
  ? "쿞IFRA I OPIS SVRHE DOZNAKE                                     �     IZNOS    쿏/P쿘AT.BROJ     쿣R.UPL.쿣R.PRIH.� DAT.OD � DAT.DO 쿚P뤂 P.NA BR. 쿍UDZ.ORG.�"
  ? "읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컴컴컴컴컨컴컨컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴좔컴컴컴컨컴컴컴컴좔컴좔컴컴컴컴컨컴컴컴컴켸"

  DO WHILE .T.

    cString := Freadln(nH,1,268)
    cString := STRTRAN( cString , CHR(0) , " " )

    IF LEN(TRIM(cString)) < 2
      EXIT
    ENDIF

    w_DatDok := CTOD( SUBSTR( cString , 1 , 2 ) + "." +;
                      SUBSTR( cString , 3 , 2 ) + "." +;
                      SUBSTR( cString , 5 , 2 ) )

    w_ZiroR  := SUBSTR( cString ,   7 , 16 )
    w_SaljeN := SUBSTR( cString ,  23 , 30 )
    w_SaljeA := SUBSTR( cString ,  53 , 30 )
    w_SaljeM := SUBSTR( cString ,  83 , 30 )
    w_PNABR  := SUBSTR( cString , 113 , 26 )
    w_SifDoz := SUBSTR( cString , 139 ,  3 )
    w_SvrDoz := SUBSTR( cString , 142 , 60 )

    w_Iznos  := VAL( SUBSTR( cString , 202 , 10 )+"."+;
                     SUBSTR( cString , 212 ,  2 ) )

    w_DugPot := SUBSTR( cString , 214 ,  1 )
    w_MatBr  := SUBSTR( cString , 215 , 13 )
    w_VrUpl  := SUBSTR( cString , 228 ,  1 )
    w_VrPrih := SUBSTR( cString , 229 ,  6 )

    w_DatOd  := CTOD( SUBSTR( cString , 235 , 2 ) + "." +;
                      SUBSTR( cString , 237 , 2 ) + "." +;
                      SUBSTR( cString , 239 , 2 ) )

    w_DatDo  := CTOD( SUBSTR( cString , 241 , 2 ) + "." +;
                      SUBSTR( cString , 243 , 2 ) + "." +;
                      SUBSTR( cString , 245 , 2 ) )

    w_Opcina := SUBSTR( cString , 247 ,  3 )
    w_PNABR2 := SUBSTR( cString , 250 , 10 )
    w_BudOrg := SUBSTR( cString , 260 ,  7 )

    ++nRBr

    // TEST:
    // ? nRBr, w_datdok, w_ziror, w_opcina, w_pnabr2, w_budorg

    IF prow()>60
      FF
      ? "旼컴컫컴컴컴컴쩡컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커"
      ? "쿝.BR� DATUM  쿩IRO-RACUN      쿛OSILJAOC: NAZIV, ADRESA I MJESTO                                                         쿛OZIV NA BROJ                     �"
      ? "쳐컴컨컴컴컴컴좔컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컫컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴쩡컴컴컴좌컴컴컴컴쩡컴쩡컴컴컴컴컫컴컴컴컴캑"
      ? "쿞IFRA I OPIS SVRHE DOZNAKE                                     �     IZNOS    쿏/P쿘AT.BROJ     쿣R.UPL.쿣R.PRIH.� DAT.OD � DAT.DO 쿚P뤂 P.NA BR. 쿍UDZ.ORG.�"
      ? "읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컴컴컴컴컨컴컨컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴좔컴컴컴컨컴컴컴컴좔컴좔컴컴컴컴컨컴컴컴컴켸"
    ENDIF


    ? " "+STR(nRBR,4), w_DatDok, w_ZiroR, PADR(TRIM(w_SaljeN)+", "+TRIM(w_SaljeA)+", "+TRIM(w_SaljeM),90), w_PNABR
    ? " "+w_SifDoz, w_SvrDoz, w_Iznos, IF(w_DugPot=="1","dug","pot"), w_MatBr
    ?? " "+PADR(w_VrUpl,7), PADR(w_VrPrih,8), w_DatOd, w_DatDo, w_Opcina, w_PNABR2, w_BudOrg
    ? REPL("-",160)

    IF !EMPTY(cIdVn)
      SELECT PRIPR
      APPEND BLANK
      REPLACE idfirma   with  gFirma      ,;
              idvn      with  cIdVn       ,;
              brnal     with  cBrNal      ,;
              datdok    with  w_datdok    ,;
              d_p       with  w_DugPot    ,;
              iznosbhd  with  w_iznos     ,;
              rbr       with  str(nRBr,4) ,;
              idkonto   with  w_VrPrih    ,;
              opis      with  w_SvrDoz
    ENDIF

  ENDDO

  FClose(nH)

  FF
  EndPrint()

  IF !EMPTY(cIdVn)
    MsgBeep("Preuzimanje izvoda zavrseno. Vratite se u pripremu tipkom <Esc>!")
  ELSE
    MsgBeep("Pregled izvoda zavrsen. Vratite se u pripremu tipkom <Esc>!")
  ENDIF

 BoxC()
CLOSERET
return
*}



/*! \fn K3Iz256(cK3)
 *  \brief 
 *  \param cK3
 */
 
function K3Iz256(cK3)
*{
 LOCAL i,c,o,d:=0,aC:={" ","0","1","2","3","4","5","6","7","8","9"}
  IF IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
    IF !EMPTY(cK3)
      FOR i:=LEN(cK3) TO 1 STEP -1
        d += ASC(SUBSTR(cK3,i,1)) * 256^(LEN(cK3)-i)
      NEXT
      cK3:=""
      DO WHILE .t.
        c := INT(d/11)
        o := d%11
        cK3 := aC[o+1] + cK3
        IF c=0; EXIT; ENDIF
        d := c
      ENDDO
    ENDIF
    cK3:=PADL(cK3,3)
  ENDIF
RETURN cK3
*}


/*! \fn K3U256(cK3)
 *  \brief
 *  \cK3
 */
 
function K3U256(cK3)
*{
LOCAL i,c,o,d:=0,aC:={" ","0","1","2","3","4","5","6","7","8","9"}
  IF !EMPTY(cK3) .and. IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
    FOR i:=1 TO LEN(cK3)
      p := ASCAN( aC , SUBSTR(cK3,i,1) ) - 1
      d += p * 11^(LEN(cK3)-i)
    NEXT
    cK3:=""
    DO WHILE .t.
      c := INT(d/256)
      o := d%256
      cK3 := CHR(o) + cK3
      IF c=0; EXIT; ENDIF
      d := c
    ENDDO
    cK3:=PADL(cK3,2,CHR(0))
  ENDIF
RETURN cK3



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

O_PRIPR
if gRJ == "D" .and. pripr->(FIELDPOS("IDRJ")) <> 0
	nLen := LEN( pripr->idrj )
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



