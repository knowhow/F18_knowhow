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


#include "fin.ch"


function kamate_unos()
local _i
local _x := MAXROWS() - 15
local _y := MAXCOLS() - 5
private ImeKol := {}
private Kol := {}

O_Edit()

ImeKol:={ ;
          {"KONTO",         {|| IdKonto  }, "Idkonto"   }, ;
          {"Partner",       {|| IdPartner}, "IdPartner" }, ;
          {"Brdok",         {|| Brdok    }, "Brdok"     }, ;
          {"DatOd",         {|| DatOd    }, "DatOd"     }, ;
          {"DatDo",         {|| DatDo    }, "DatDo"     }, ;
          {"Osnovica",      {|| Osnovica }, "Osnovica"  }, ;
          {"M1",            {|| M1       }, "M1"        }  ;
        }

for _i := 1 to LEN( imekol )
	AADD( Kol, _i )
next

Box(, _x, _y )
	@ m_x + (_x-2), m_y + 2 SAY " <c-N>  Nove Stavke      ณ <ENT> Ispravi stavku   ณ <c-T> Brisi Stavku"
	@ m_x + (_x-1), m_y + 2 SAY " <c-A>  Ispravka Dokum.  ณ <c-P> Stampa svi KL    ณ <a-A> Az. <a-V> Po"
	@ m_x + _x, m_y + 2 SAY " <c-F9> Bris.p <a-F9> B.kณ <a-P> Stampa pojedinac.ณ <SPACE> KS 1/2    "
	ObjDbedit( "PNal", _x , _y ,{|| _key_handler() },"","KAMATE Priprema.....อออออ<c-U> Lista uk.dug+kamata", , , , ,3)
BoxC()

close all
return



static function O_Edit()
O_KS
O_PARTN
O_KONTO
O_KAM_PRIPR
O_KAM_KAMAT
select kam_pripr
set order to tag "1"
go top
return



static function ispravka_unosa( fNovi )
if fnovi
	_IdKonto:=padr("1200",7)
endif

set cursor on

@ m_x+1,m_y+2  SAY "Partner  :" get _IdPartner pict "@!" valid P_Firma(@_idpartner)
@ m_x+3,m_y+2  SAY "Broj Veze:" get _BrDok
@ m_x+5,m_y+2  SAY "Datum od  " GET _datOd VALID PostojiLi(_idPartner,_brDok,_datOd,fNovi)
@ m_x+5,col()+2 SAY "do" GET _datDo
@ m_x+7,m_y+2  SAY "Osnovica  " get _Osnovica pict "999999999.99"

read
ESC_RETURN 0
return 1



/*! \fn PostojiLi(idp, brd, dod, fNovi)
 *  \brief ???
 *  \param idp
 *  \param brd
 *  \param dod
 *  \param fNovi
 */
static function PostojiLi(idp, brd, dod, fNovi)
local lVrati:=.t.
local nRec

PushWA()
SELECT kam_pripr
nRec:=RECNO()
GO TOP

DO WHILE !EOF()
	IF idpartner==idp .and. brdok==brd .and. DTOC(datod)==DTOC(dod) .and. ( RECNO()!=nRec .or. fNovi )
      	lVrati:=.f.
      	Msg("Greska! Vec ste unijeli ovaj podatak!",3)
      	EXIT
    ENDIF
    SKIP 1
ENDDO
GO (nRec)
PopWA()
RETURN lVrati


// -----------------------------------------------
// obrada dogadjaja tastature
// -----------------------------------------------
static function _key_handler()
local nTr2

if (Ch == K_CTRL_T .or. Ch == K_ENTER) .and. reccount2() == 0
    return DE_CONT
endif

select kam_pripr

do case

    case Ch == K_CTRL_T
        if Pitanje("p01","Zelite izbrisati ovu stavku ?","D")=="D"
            delete
            __dbPack()
            return DE_REFRESH
        endif
        return DE_CONT

    case Ch==K_ALT_A
        azuriranje()
        return DE_REFRESH

    case Ch==K_ALT_V
        povrat()
        return DE_REFRESH

    case Ch==ASC(" ")
        cSeek:=EVAL( (TB:getColumn(2)):Block )+EVAL( (TB:getColumn(3)):Block )
        seek cseek
        do while !eof() .and. cseek=idpartner+brdok
            if empty(m1)
                replace m1 with "2"
            else
                replace m1 with " "
            endif
            skip
        enddo

        return DE_REFRESH

    case Ch==K_ENTER
        
        Box("ist",20,75,.f.)
        Scatter()
            
        if ispravka_unosa(.f.)==0
            BoxC()
            return DE_CONT
        else
            Gather()
            BoxC()
            return DE_REFRESH
        endif

    case Ch==K_CTRL_K
   	    fin_kamate_generisi_mj_uplate()
	    RETURN DE_CONT

    case Ch==K_CTRL_A
        PushWA()
        select kam_pripr
        go top
        Box("anal",13,75,.f.,"Ispravka stavki dokumenta")
        nDug:=0; nPot:=0
        do while !eof()
           skip
	   nTR2:=RECNO()
	   skip-1
           Scatter()
           @ m_x+1,m_y+1 CLEAR to m_x+12,m_y+74
           if ispravka_unosa(.f.)==0
             exit
           endif
           select kam_pripr
           Gather()
           go nTR2
         enddo
         PopWA()
         BoxC()
         return DE_REFRESH

     case Ch==K_CTRL_N  // nove stavke
        nDug:=nPot:=nPrvi:=0
        go bottom
        Box("knjn",13,77,.f.,"Unos novih stavki")
        do while .t.
           Scatter()
           @ m_x+1,m_y+1 CLEAR to m_x+12,m_y+76
           if ispravka_unosa(.t.)==0
             exit
           endif
           inkey(10)
           select kam_pripr
           APPEND BLANK
           Gather()
        enddo

        BoxC()
        return DE_REFRESH

    case Ch=K_CTRL_F9

        if Pitanje(,"Zelite li izbrisati pripremu !!????","N")=="D"
            zap
            __dbPack()
        endif
        return DE_REFRESH

    case Ch=K_ALT_F9
        //BrisiKum()
        //return DE_REFRESH
    
    case Ch==K_CTRL_P
     
        if pitanje(,"Rekalkulisati osnovni dug ?","N") == "D"
            
            gDatObr := DATE()
            
            box(, 1, 50 )
                @ m_x + 1, m_y + 2 SAY "Ukucaj tacan datum:" GET gDatObr
                read
            boxc()
            
            select kam_pripr
            go top
      
            do while !eof()
                cIdPartner:=idpartner
                select kam_pripr
                nTTTrec:=recno()
                nOsnDug:=0
                do while !eof() .and. cidpartner==idpartner
                    cBrdok:=brdok
                    nRacun:=0
                    nPredhodni:=0
                    fPrvi:=.f.
                    do while !eof() .and. cidpartner==idpartner .and. brdok==cbrdok
                        if fprvi
                            nRacun:=osnovica
                            fprvi:=.f.
                        else
                            nRacun:=nRacun - (nPredhodni-osnovica)
                        endif
                        nRacun:=iznosnadan(nRacun,gDatObr,datod)
                        nPredhodni:=osnovica
                        skip
                    enddo
                    nOsnDug+=nRacun
                enddo
                go nTTTrec
                do while !eof() .and. cidpartner==idpartner
                    replace osndug with nosndug
                    skip
                enddo

            enddo
        endif
        aDbf := {}
        AADD ( aDbf , {"IDPARTNER" , "C",  6, 0} )
        AADD ( aDbf , {"OSNDUG"    , "N", 12, 2} )
        AADD ( aDbf , {"KAMATE"    , "N", 12, 2} )
        AADD ( aDbf , {"PDV"       , "N", 12, 2} )
        DBCREATE( my_home() + "pom", aDbf)
        my_use_temp( "POM", my_home() + "pom", .f., .t. )
        // INDEX ON IDPARTNER  TAG "1"
        GO TOP

        select kam_pripr
        go top
     nKamMala:=15
     private cVarObrac:="Z"
     Box(,3,70)
       @ m_x+1,m_y+2 SAY "Ne ispisuj kam.listove za iznos kamata ispod" GET nKamMala pict "999999.99"
       @ m_x+2,m_y+2 SAY "Varijanta (Z-zatezna kamata,P-prosti kamatni racun)" GET cVarObrac valid cVarObrac$"ZP" pict "@!"
       read
     BoxC()
     start print cret
     ?
     do while !eof()
      cIdPartner:=idpartner
      private nOsnDug:=0
      private nKamate:=0
      private nSOsnSD:=0
      private nPdv:=0
      private nPdvTotal:=0
      private nKamTotal:=0
      if ObracV(cidpartner,.f.)>nKamMala
        SELECT POM
        APPEND BLANK
        REPLACE IDPARTNER WITH cIdPartner ,;
                OSNDUG    WITH nOsnDug    ,;
                KAMATE    WITH nKamate    ,;
		PDV       WITH nPdvTotal
        SELECT PRIPR
        ObracV(cidpartner,.t.)
      endif
      select kam_pripr
      seek cidpartner+chr(250)
     enddo
     end print
     select pom; use
     select kam_pripr
     go top
     return DE_REFRESH

   case Ch==K_CTRL_U
     nArr:=SELECT()
     nUD1:=0
     nUD2:=0
     nUD3:=0
     IF FILE(PRIVPATH+"POM.DBF")
     my_use_temp( "POM", my_home() + "pom", .f., .t. )
     SELECT POM
     GO TOP
     StartPrint()
     ? "PREGLED UKUPNIH DUGOVANJA PO KUPCIMA"
     ? "------------------------------------"
     ?
     ? "      SIFRA I NAZIV KUPCA            DUG         KAMATA       UKUPNO   "
     ? "-------------------------------- ------------ ------------ ------------"
     DO WHILE !EOF()
       ? IDPARTNER, PADR( Ocitaj(F_PARTN,IDPARTNER,"naz"), 25 ),;
         STR(OSNDUG,12,2), STR(KAMATE,12,2), STR(OSNDUG+KAMATE,12,2)
       nUd1 += osndug
       nUd2 += kamate
       nUd3 += (osndug+kamate)
       SKIP 1
     ENDDO
     ? "-------------------------------- ------------ ------------ ------------"
     ? "UKUPNO SVI KUPCI................",;
       STR(nUd1,12,2), STR(nUd2,12,2), STR(nUd3,12,2)
     END PRINT
     USE
     ENDIF
     SELECT (nArr)
     return DE_REFRESH
	
   case Ch==K_ALT_P
     	select pripr
     	private nKamMala:=0
     	private nOsnDug:=0
     	private nSOsnSD:=0
     	private nKamate:=0
     	private cVarObrac:="Z"
     	cIdpartner:=EVAL( (TB:getColumn(2)):Block )
	Box(,2,70)
       		@ m_x+1,m_y+2 SAY "Varijanta (Z-zatezna kamata,P-prosti kamatni racun)" GET cVarObrac valid cVarObrac$"ZP" pict "@!"
       		read
     	BoxC()
        START PRINT CRET
        
	if ObracV(cIdPartner, .f.) > nKamMala
      		ObracV(cIdPartner)
     	endif
     
     	END PRINT
        select kam_pripr
     	go top
	return DE_REFRESH

   case Ch==K_ALT_A
     return DE_REFRESH

endcase

return DE_CONT



//*******************************
static function ObracV(cIdPartner,fprint)
//*
//* ova fja se poziva u dva kruga
//* u prvom krugu se obracunava
//* nOsnDug, nKamate
//*******************************
local nKumKamSD:=0   
// nKumKamSD - ( kumulativ kamate sa denominacijom )
// nKumKamBD - ( kumulativ kamate bez denominacije )
local cTxtPdv
local cTxtUkupno

if fprint==NIL                            
	fprint:=.t.
endif

nGlavn:=2892359.28
dDatOd:=ctod("01.02.92")
dDatDo:=ctod("30.09.96")

select ks
O_KS
set order to 2

private picDem:="9999999999.99"
nStr:=0
IF FPRINT
        
	nPdvTotal := nKamate * (17 / 100)
	
	if gPdvObr == "D"
		
		cTxtPdv := "PDV (17%)"
		cTxtPdv += " "
		cTxtPdv += REPLICATE(".", 44)
		cTxtPdv += str(nPdvTotal, 12, 2)
		cTxtPdv += " KM"
		
		cTxtUkupno := "Ukupno sa PDV"
		cTxtUkupno += " "
		cTxtUkupno += REPLICATE(".", 40)
		cTxtUkupno += str(nKamate + nPdvTotal, 12, 2)
		cTxtUkupno += " KM"
		
	else
		cTxtPdv := ""
		cTxtUkupno := ""
	endif
	
	?
	P_10CPI
	?? padc("- Strana "+str(++nStr,4)+"-",80)
	?
	select partn
	hseek cIdPartner
	cPom:=trim(partn->adresa)
	if !empty(partn->telefon)
		cPom+=", TEL:"+partn->telefon
	endif
	cPom:=padr(cPom,42)
	dDatPom:=gDatObr

	Stzaglavlje(gVlZagl,PRIVPATH, ;
             dtoc(gDatObr), ;
             padr(cIdPartner+"-"+partn->naz,42),;
             padr(mjesto+" - "+ptt,42),;
             cPom,;
             str(nOsnDug,12,2) ,; //nOsnDug
             str(nKamate,12,2) ,;
	     cTxtPdv , ;
	     cTxtUkupno )
	
	// resetuj varijablu
	//nSOsnSD:=0
	
ENDIF 

select kam_pripr
seek cIdPartner

if fPrint
	if prow()>40
   		FF
   		? 
		P_10CPI
   		?? padc("- Strana "+str(++nStr,4)+"-",80)
   		?
	endif
	P_10CPI
	B_ON
	? space(20),padc("K A M A T N I    L I S T",30)
	B_OFF
	IF gKumKam=="N"
  		P_12CPI
	ELSE
  		P_COND
	ENDIF
	?
	?
	//B_ON
	//? space(45),"Preduzece:",gNFirma
	//B_OFF
endif // fprint

if fprint
	?
	if cVarObrac=="Z"
		m:=" ---------- -------- -------- --- ------------- ------------- -------- ------- -------------"+IF(gKumKam=="D"," -------------","")
	else
		m:=" ---------- -------- -------- --- ------------- ------------- -------- -------------"+IF(gKumKam=="D"," -------------","")
	endif

	NStrana("1") // samo zaglavlje bez strane

endif // fprint

nSKumKam:=0
select kam_pripr
cIdPartner:=idpartner

if !fprint
	nOsnDug:=osndug
endif

do while !eof() .and. idpartner==cIdPartner

fStampajBr:=.t.
fPrviBD:=.t.
nKumKamBD:=0
nKumKamSD:=0
//nSGlavn:=0
cBrDok:=brdok
cM1:=m1
////************************ broj dokumenta **************************
nOsnovSD:=kam_pripr->osnovica
do while !eof() .and. idpartner==cidpartner .and. brdok==cbrdok
	dDatOd:=kam_pripr->datod
	dDatdo:=kam_pripr->datdo
	nOsnovSD:=kam_pripr->osnovica
	if fprviBD
  		nGlavnBD:=kam_pripr->osnovica
  		fPrviBD:=.f.
	else
		//  nGlavnBD:=kam_pripr->osnovica+nKumKamBD
  		if cVarObrac=="Z"
	  		nGlavnBD:=kam_pripr->osnovica+nKumKamSD
  		else
	  		nGlavnBD:=kam_pripr->osnovica
  		endif
	endif
	
	nGlavn:=nGlavnBD

 	select ks

	// nKumKamSD:=0

	seek dtos(dDatOd)

	if dDatOd < DatOd .or. eof()
 		skip -1
	endif

	//****************** vrti kroz KS *******************************
	do while .t.
		ddDatDo:=min(DatDO,dDatDo)
		//if dDatOd==ddDatDo
		//  exit                ?????????? da li ovo treba ??????????
		//endif
		if (IzFmkIni("KAM","DodajDan","D",KUMPATH)=="D")
			nPeriod:= ddDatDo-dDatOd+1
		else
			nPeriod:= ddDatDo-dDatOd
		endif
		*nPeriod:= ddDatDo-dDatOd  // zeljezara
		if (cVarObrac=="P")
			if (Prestupna(YEAR(dDatOd)))
				nExp:=366
			else
				nExp:=365
			endif
		else
			if tip=="G"
	 			if duz==0
	  				//if year(dDatOD) % 4 == 0
	 				//  nExp:=366
	  				//else
	   				nExp:=365
	   				//endif
	 			else
	   				nExp:=duz
	 			endif
			elseif tip=="M"
	 			if duz==0
	  				dExp:= "01."
	  				if month(ddDatdo)==12
	   					dExp+="01."+alltrim(str(year(ddDatdo)+1))
	  				else
	   					dExp+=alltrim(str(month(ddDatdo)+1))+"."+alltrim(str(year(ddDatdo)))
	  				endif
	  				// dexp - karakter varijabla
	  				nExp:=day(ctod(dExp)-1)
	  				//nExp:=30
	 			else
	  				nExp:=duz
	 			endif
			elseif tip=="3"
	 			nExp:=duz
			endif
		endif

		if den<>0  .and. dDatOd==datod
 			if fprint
   				? "********* Izvrsena Denominacija osnovice sa koeficijentom:",den,"****"
 			endif
 			nOsnovSD:=round(nOsnovSD*den,2)
 			nGlavn:=round(nGlavn*den,2)
 			nKumKamSD:=round(nKumKamSD*den,2)
		endif

		if (cVarObrac=="Z")
			nKKam  :=((1+stkam/100)^(nPeriod/nExp) - 1.00000)
			nIznKam:=nKKam*(nGlavn)
			nIznKam:=round(nIznKam,2)
		else
			nKStopa:=stkam/100
			cPom777:=IzFmkIni("KAM","FormulaZaProstuKamatu","nGlavn*nKStopa*nPeriod/nExp",KUMPATH)
			nIznKam:=&(cPom777)
			nIznKam:=round(nIznKam,2)
		endif

		if fprint
  			if prow()>55
   				FF
    				Nstrana()
  			endif
  			if fstampajbr
    				? " "+cbrdok+" "
    				fStampajBr:=.f.
  			else
    				? " "+space(10)+" "
  			endif
  			?? dDatOd,ddDatDo
  			@ prow(),pcol()+1 SAY nPeriod pict "999"
  			@ prow(),pcol()+1 SAY nOsnovSD pict picdem
			@ prow(),pcol()+1 SAY nGlavn pict picdem
  			if (cVarObrac=="Z")
	  			@ prow(),pcol()+1 SAY tip
	  			@ prow(),pcol()+1 SAY stkam pict "999.99"
	  			@ prow(),pcol()+1 SAY nKKam*100 pict "9999.99"
  			else
	  			@ prow(),pcol()+1 SAY stkam pict "999.99"
  			endif
  			nCol1:=pcol()+1
  			@ prow(),pcol()+1 SAY nIznKam pict picdem

		endif //fprint

		//nSOsnSD += nOsnovSD
		//nSGlavn += nGlavn
		
if (cVarObrac=="Z")
	nGlavnBD+=nIznKam
endif

nKumKamBD+=nIznKam
nKumKamSD+=nIznKam

if (cVarObrac=="Z")
	nGlavn+=nIznKam
endif

if fprint .and. gKumKam=="D"
   @ prow(),pcol()+1 SAY nKumKamSD pict picdem  // pitanje
endif

if dDatDo<=DatDo // kraj obracuna
 select kam_pripr
 exit
endif

skip

if EOF()
  Msg("PARTNER: "+kam_pripr->idpartner+", BR.DOK.: "+kam_pripr->brdok+;
      "#GRESKA : Fali datumski interval u kam.stopama!",10)
  exit
endif

dDatOd:=DatOd

enddo // .t.
// vrti kroz KS ***************************************************

select kam_pripr
skip
enddo // cbrdok

nKumKamSD:=IznosNaDan(nKumKamSD,gDatObr,IF(EMPTY(cM1),KS->datdo,KS2->datdo),cM1)
if fprint
  if prow()>59
    FF
    Nstrana()
  endif
  ? m
  ? " UKUPNO ZA",cbrdok
//  @ prow(),nCol1 SAY nKumKamBD pict picdem
  @ prow(),nCol1 SAY nKumKamBD pict picdem

  ? " UKUPNO NA DAN",gDatObr,":"
  @ prow(),nCol1 SAY nKumKamSD pict picdem
  ? m
endif

nSKumKam += nKumKamSD

select kam_pripr
enddo // cidpartner

if fprint
	if prow()>54
  		FF
  		NStrana()
	endif

? m
? " SVEUKUPNO KAMATA NA DAN " + DTOC(gDatObr) + ":"
@ prow(),pcol() SAY nOsnDug pict picdem
//@ prow(),pcol()+1 SAY nGlavn pict picdem
@ prow(),ncol1  SAY nSKumKam pict picdem
? m

P_10CPI

if prow()<62+gPStranica
	for i:=1 to 62+gPStranica-prow()
   		?
 	next
endif
?  PADC("     Obradio:                                 Direktor:    ",80)
?
?  PADC("_____________________                    __________________",80)
?

FF
endif // fprint

if !fprint
	nKamate:=nSKumKam
endif

return nSKumKam
*}


//**************************
static function Nstrana(cTip)
//**************************

if ctip==NIL
  cTip:=""
endif

if cTip==""
   ?
   P_10CPI
   ?? padc("- Strana "+str(++nStr,4)+"-",80)
   ?
endif
if ctip=="1" .or. cTip=""
   IF gKumKam=="N"
     P_12CPI
   ELSE
     P_COND
   ENDIF
   ? m
   if cVarObrac=="Z"
   	? "   Broj          Period      dana     ostatak       kamatna   Tip kam  Konform.    Iznos    "+IF(gKumKam=="D","   kumulativ   ","")
   	? "  racuna                              racuna       osnovica   i stopa   koef       kamate   "+IF(gKumKam=="D","    kamate     ","")
   else
   	? "   Broj          Period      dana     ostatak       kamatna    Stopa       Iznos    "+IF(gKumKam=="D","   kumulativ   ","") 
	? "  racuna                              racuna       osnovica                kamate   "+IF(gKumKam=="D","    kamate     ","")
   endif
   ? m
endif
return
*}



//************************************************************
static function IznosNaDan(nIznos,dTrazeni,dProsli,cM1)
//*
//* dtrazeni = 30.06.98
//* dprosli  = 15.05.94
//* znaci: uracunaj sve denominacije od 15.05.94 do 30.06.98
//************************************************************
*{
LOCAL nK:=1
 PushWA()
   SELECT KS
 GO TOP
 DO WHILE !EOF()
   IF DTOS(dTrazeni) < DTOS(DatOd)
     EXIT
   ELSEIF DTOS(dProsli) >= DTOS(DatOd)
     SKIP 1
     LOOP
   ENDIF
   IF den<>0
     nK:=nK*den
   ENDIF
   SKIP 1
 ENDDO
 PopWA()
RETURN nIznos*nK
*}



static function azuriranje()
*{
if pitanje(,"Izvrsiti azuriranje","N")=="D"
   select kam_pripr; go top
   do while !eof()
     scatter()
     select kamat
     append blank
     gather()
     select kam_pripr
     skip
   enddo
   if Pitanje(,"Izbrisati pripremu ?","D")=="D"
     select kam_pripr
     zap
   endif

endif
*}



function Povrat()
*{
Box(,3,60)
 cIdPartner:=space(6)
 @ m_x+1,m_y+2 SAY "Izvrsiti povrat podataka za partnera:" GET cIdPartner  pict "@!" valid P_Firma(@cIdPartner)
 read
BoxC()

if lastkey()<>K_ESC
  select kamat; go top
  do while !eof()
    scatter()
    if _idpartner==cidpartner
       select kam_pripr
       append blank
       gather()
       select kamat
    endif
    select kamat
    skip
  enddo
endif

if pitanje(,"Izbrisati u kumulativu podatke za partnera","D")=="D"
  select kamat; set order to 0; go top
  do while !eof()
    if idpartner==cidpartner
       delete
    endif
    skip
  enddo
endif

select kam_pripr; go top
return
*}



//*********************
function BrisiKum()
//*********************
*{
local nArr:=SELECT()
Box(,3,60)
 cIdPartner:=space(6)
 @ m_x+1,m_y+2 SAY "Izvrsiti brisanje kumulativa za partnera:" GET cIdPartner  pict "@!" valid P_Firma(@cIdPartner)
 read
 IF LASTKEY()==K_ESC
   BoxC()
   SELECT (nArr)
   RETURN
 ENDIF
BoxC()

if pitanje(,"Izbrisati u kumulativu podatke za partnera","N")=="D"
  select kamat; set order to 0; go top
  do while !eof()
    if idpartner==cidpartner
       delete
    endif
    skip
  enddo
endif
select kam_pripr
return




