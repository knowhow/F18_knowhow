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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */


/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_OstraniciKarticu
  * \brief Da li se ostranicava kartica artikla?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_FAKT_OstraniciKarticu;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_Sintet
  * \brief Da li se koriste sinteticke (skracene) sifre robe?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_Sintet;



/*! \fn fakt_kartica()
 *  \brief Izvjestaj - kartica
 */
 
function fakt_kartica()
*{
local cIdfirma, nRezerv, nRevers
local nul, nizl, nRbr, cRR, nCol1:=0, cKolona, cBrza:="D"
local cPredh:="2"

local lpickol:="@Z "+pickol

private m:=""

O_SIFK
O_SIFV
O_PARTN
O_ROBA
O_TARIFA
O_RJ
O_FAKT_DOKS
O_FAKT
if glRadNal
	O_RNAL
endif

select fakt
if fId_J
  set order to tag "3J" // idroba_J+Idroba+dtos(datDok)
else
  set order to 3 // idroba+dtos(datDok)
endif

cIdfirma:=gFirma
PRIVATE qqRoba:=""
PRIVATE dDatOd:=ctod("")
PRIVATE dDatDo:=date()
private cPPartn:="N"

if glRadNal
	cRadniNalog:=SPACE(10)
endif

_c1:=_c2:=_c3:=SPACE(20)
_n1:=_n2:=0

Box("#IZVJESTAJ:KARTICA",17+IF(lPoNarudzbi,2,0),63)

cPPC:="N"

cOstran := IzFMKINI("FAKT","OstraniciKarticu","N",SIFPATH)

O_PARAMS
private cSection:="5",cHistory:=" "; aHistory:={}
Params1()
RPar("c1",@cIdFirma)
RPar("d1",@dDatOd)
RPar("d2",@dDatDo)
RPar("cP",@cPPC)
RPar("Cp",@cPPartn)

cRR:="N"

private cTipVPC:="1"

private ck1:=cK2:=space(4)   // atributi
private qqPartn:=space(20)

qqTarife:=""
qqNRobe:=""
//cSort:="S"

do while .t.
 @ m_x+1,m_y+2 SAY "Brza kartica (D/N)" GET cBrza pict "@!" valid cBrza $ "DN"
 read
 if gNW $ "DR"
   @ m_x+2,m_y+2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| empty(cIdFirma) .or. cidfirma==gFirma .or.P_RJ(@cIdFirma) }
 else
   @ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif

if cBrza=="D"
 RPar("c3",@qqRoba)
 qqRoba:=padr(qqRoba,10)
 if fID_J
   @ m_x+3,m_y+2 SAY "Roba " GET qqRoba pict "@!" valid {|| P_Roba(@qqRoba), qqRoba:=roba->id_j, .t.}
 else
   @ m_x+3,m_y+2 SAY "Roba " GET qqRoba pict "@!" valid P_Roba(@qqRoba)
 endif
else
 RPar("c2",@qqRoba)
 qqRoba:=padr(qqRoba,60)
 @ m_x+3,m_y+2 SAY "Roba " GET qqRoba pict "@!S40"
endif

@ m_x+4,m_y+2 SAY "Od datuma "  get dDatOd
@ m_x+4,col()+1 SAY "do"  get dDatDo
@ m_x+5,m_y+2 SAY "Prikaz rezervacija, reversa (D/N)   "  get cRR   pict "@!" valid cRR $ "DN"
@ m_x+6,m_y+2 SAY "Prethodno stanje (1-BEZ, 2-SA)      "  get cPredh pict"9" valid cPredh $ "12"
if gVarC $ "12"
 @ m_x+7,m_y+2 SAY "Stanje prikazati sa Cijenom 1/2 (1/2) "  get cTipVpc pict "@!" valid cTipVPC $ "12"
endif
IF gNovine=="D"
  @ m_x+8,m_y+2 SAY "Uslov po sifri partnera (prazno - svi)"  GET qqPartn   pict "@!"
ELSE
  @ m_x+8,m_y+2 SAY "Naziv partnera (prazno - svi)"  GET qqPartn   pict "@!"
ENDIF
if fakt->(fieldpos("K1"))<>0 .and. gDK1=="D"
 @ m_x+9,m_y+2 SAY "K1" GET  cK1 pict "@!"
 @ m_x+10,m_y+2 SAY "K2" GET  cK2 pict "@!"
endif

@ m_x+12,m_y+2 SAY "Prikaz kretanja cijena D/N"  get cPPC pict "@!" valid cPPC $ "DN"
@ m_x+13,m_y+2 SAY "Prikazi partnera za svaku stavku"  get cPPartn pict "@!" valid cPPartn $ "DN"

if cBrza=="N"
  @ m_x+15,m_y+2 SAY "Svaka kartica na novu stranicu? (D/N)"  get cOstran VALID cOstran$"DN" PICT "@!"
else
  cOstran:="N"
endif

if glRadNal
  	@ m_x+16,m_y+2 SAY "Uslov po radnom nalogu (prazno-svi)" get cRadniNalog valid EMPTY(cRadniNalog) .or. P_RNal(@cRadniNalog)
endif

IF lPoNarudzbi
  qqIdNar := SPACE(60)
  cPKN    := "N"
  @ row()+1,m_y+2 SAY "Uslov po sifri narucioca:" GET qqIdNar PICT "@!S30"
  @ row()+1,m_y+2 SAY "Prikazati kolone 'narucilac' i 'br.narudzbe' ? (D/N)" GET cPKN VALID cPKN$"DN" pict "@!"
ENDIF

read

ESC_BCR

if fID_J .and. cBrza=="D"
 qqRoba:=roba->(ID_J+ID)
endif

cSintetika:=IzFmkIni("FAKT","Sintet","N")
IF cSintetika=="D" .and.  IF(cBrza=="D",ROBA->tip=="S",.t.)
  @ m_x+17,m_y+2 SAY "Sinteticki prikaz? (D/N) " GET  cSintetika pict "@!" valid cSintetika $ "DN"
ELSE
  cSintetika:="N"
ENDIF
read;ESC_BCR

 if cBrza=="N"
   if fID_J
    aUsl1:=Parsiraj(qqRoba,"IdRoba_J")
   else
    aUsl1:=Parsiraj(qqRoba,"IdRoba")
   endif
 endif
 if gNovine=="D"
   aUsl2:=Parsiraj(qqPartn,"IdPartner")
 endif

 IF lPoNarudzbi
   aUslN := Parsiraj(qqIdNar,"idnar")
 ENDIF

 if IF(cBrza=="N", aUsl1<>NIL, .t.) .and. ;
    (!lPoNarudzbi.or.aUslN<>NIL)
   exit
 endif

enddo
m:="---- ------------------ -------- "
if cPPArtn=="D"
  m+=replicate("-",20)+" "
endif

IF lPoNarudzbi.and.cPKN=="D"
  m+="------ ---------- "
ENDIF

m+="----------- ----------- -----------"
if cPPC=="D"
 m+=" ----------- ----- -----------"
endif

Params2()
WPar("c1",cIdFirma)
WPar("d1",dDatOd)
WPar("d2",dDatDo)  
WPar("cP",cPPC)
WPar("Cp",cPPartn)

IF cBrza=="D"
 WPar("c3",trim(qqRoba))
ELSE
 WPar("c2",trim(qqRoba))
ENDIF
select params; use

BoxC()

if cPPArtn=="D"
  O_FAKT_DOKS 
endif

select FAKT

PRIVATE cFilt1:=""

cFilt1 := IF(cBrza=="N",aUsl1,".t.")+ ;
          IF(EMPTY(dDatOd),"",".and.DATDOK>="+cm2str(dDatOd))+;
	  IF(EMPTY(dDatDo),"",".and.DATDOK<="+cm2str(dDatDo))

if glRadNal .and. !EMPTY(cRadniNalog)
	cFilt1+=".and. idrnal="+Cm2Str(cRadniNalog)
endif

if lPoNarudzbi .and. aUslN<>".t."
  cFilt1+=".and."+aUslN
endif

cFilt1 := STRTRAN(cFilt1,".t..and.","")

cTMPFAKT:=""

if cFilt1==".t."
   set filter to
  else
   set filter to &cFilt1
endif

IF cBrza=="N"
 go top
 EOF CRET
ELSE
 seek qqRoba
ENDIF

START PRINT CRET
?
P_12CPI
?? space(gnLMarg); ?? "FAKT: Kartice artikala na dan",date(),"      za period od",dDatOd,"-",dDatDo
? space(gnLMarg); IspisFirme(cidfirma)
if !empty(qqRoba)
 ? space(gnLMarg)
 if !empty(qqRoba) .and. cBrza="N"
   ?? "Uslov za artikal:",qqRoba
 endif
endif

if glRadNal .and. !EMPTY(cRadniNalog)
	? SPACE(gnLMarg)
	?? "Uslov za radni nalog: ", ALLTRIM(cRadniNalog), GetNameRNal(cRadniNalog)
endif

?
if cTipVPC=="2" .and.  roba->(fieldpos("vpc2")<>0)
  ? space(gnlmarg); ?? "U CJENOVNIKU SU PRIKAZANE CIJENE: "+cTipVPC
endif
if !empty(cK1)
  ?
  ? space(gnlmarg),"- Roba sa osobinom K1:",ck1
endif
if !empty(cK2)
  ?
  ? space(gnlmarg),"- Roba sa osobinom K2:",ck2
endif
if lPoNarudzbi .and. !EMPTY(qqIdNar)
  ?
  ? "Prikaz za sljedece narucioce:",TRIM(qqIdNar)
endif

_cijena:=0
_cijena2:=0
nRezerv:=nRevers:=0

qqPartn:=trim(qqPartn)
if !empty(qqPartn)
  ?
  IF gNovine=="D"
    ? space(gnlmarg),"- Prikaz za partnere obuhvacene uslovom za sifru:"
  ELSE
    ? space(gnlmarg),"- Prikaz za partnere ciji naziv pocinje sa:"
  ENDIF
  ? space(gnlmarg)," ",qqPartn
  ?
endif

IF lPoNarudzbi .and. cPKN=="D" .and. cPPartn=="D" .and. cPPC=="D"
  P_COND2
ELSE
  P_COND
ENDIF

nStrana := 1
lPrviProlaz:=.t.
 
do while !eof()
  if cBrza=="D"
    if qqRoba<>iif(fID_j,IdRoba_J+IdRoba,IdRoba) .and.;
       IF(cSintetika=="D",LEFT(qqRoba,gnDS)!=LEFT(IdRoba,gnDS),.t.)
      // tekuci slog nije zeljena kartica
      exit
    endif
  endif
  if fId_j
   cIdRoba:=IdRoba_J+IdRoba
  else
   cIdRoba:=IdRoba
  endif
  nUl:=nIzl:=0
  nRezerv:=nRevers:=0
  nRbr:=0
  nIzn:=0

  if fId_j
   NSRNPIdRoba(substr(cIdRoba,11), cSintetika=="D")
  else
   NSRNPIdRoba(cIdRoba, cSintetika=="D" )
  endif
  select FAKT

  if cTipVPC=="2" .and.  roba->(fieldpos("vpc2")<>0)
        _cijena:=roba->vpc2
  else
      _cijena := if ( !EMPTY(cIdFirma) , fakt_mpc_iz_sifrarnika(), roba->vpc )
  endif
  if gVarC=="4" // uporedo vidi i mpc
     _cijena2:=roba->mpc
  endif

  if prow()-gPStranica>50; FF; ++nStrana; endif

  ZaglKart(lPrviProlaz)
  lPrviProlaz:=.f.

  IF cPredh=="2"     // dakle sa prethodnim stanjem
     PushWa()
     select fakt
     set filter to
     if fID_J
      //TODO : pogledati
      seek cIdFirma+IF(cSintetika=="D".and.ROBA->tip=="S",RTRIM(ROBA->id),cIdRoba)
     else
      seek cIdFirma+IF(cSintetika=="D".and.ROBA->tip=="S",RTRIM(ROBA->id),cIdRoba)
     endif
     // DO-WHILE za cPredh=2
     DO WHILE !eof() .and. IF(cSintetika=="D".and.ROBA->tip=="S",;
                              LEFT(cIdRoba,gnDS)==LEFT(IdROba,gnDS),;
                              cIdRoba==iif(fID_J,IdRoba_J+Idroba,IdRoba) ) .and. dDatOd>datdok

       if !empty(cK1)
        if ck1<>K2 ; skip; loop; endif
       endif
       if !empty(cK2)
         if ck2<>K2; skip; loop; endif
       endif
       if !empty(cidfirma); if idfirma<>cidfirma; skip; loop; end; end
       if !empty(qqPartn)
         IF gNovine=="D"
           IF !(&aUsl2); SKIP 1; LOOP; ENDIF
         ELSE
           select fakt_doks; hseek fakt->(IdFirma+idtipdok+brdok)
           select fakt; if !(doks->partner=qqPartn); skip; loop; endif
         ENDIF
       endif

       if !empty(cIdRoba)
        if idtipdok="0"  // ulaz
           nUl+=kolicina
        elseif idtipdok="1"   // izlaz faktura
          if !(left(serbr,1)=="*" .and. idtipdok=="10")  // za fakture na osnovu optpremince ne ra~unaj izlaz
           nIzl+=kolicina
          endif
        elseif idtipdok$"20#27".and.cRR=="D"
           if serbr="*"
             nRezerv+=kolicina
           endif
        elseif idtipdok=="21".and.cRR=="D"
           nRevers+=kolicina
        endif
       endif
       SKIP 1
     ENDDO  // za do-while za cPredh="2"
//     if !(nIzl==0.and.nUl==0.and.nRevers==0.and.nRezerv==0)
         ? space(gnLMarg); ?? str(nRbr,3)+".   "+idfirma+PADR("  PRETHODNO STANJE",23)
         if cppartn=="D"
           @ prow(),pcol()+1 SAY space(20)
         endif
         @ prow(),pcol()+1 SAY nUl pict lpickol
         @ prow(),pcol()+1 SAY (nIzl+nRevers+nRezerv) pict lpickol
         @ prow(),pcol()+1 SAY nUl-(nIzl+nRevers+nRezerv) pict lpickol
//     endif
    PopWA()
  ENDIF

  // GLAVNA DO-WHILE
  do while !eof() .and. IF(cSintetika=="D".and.ROBA->tip=="S",;
                           LEFT(cIdRoba,gnDS)==LEFT(IdRoba,gnDS),;
                           cIdRoba==iif(fID_J,IdRoba_J+IdRoba,IdRoba))
    cKolona:="N"

    if !empty(cidfirma); if idfirma<>cidfirma; skip; loop; end; end
    if !empty(cK1); if ck1<>K1 ; skip; loop; end; end // uslov ck1
    if !empty(cK2); if ck2<>K2; skip; loop; end; end // uslov ck2

    if !empty(qqPartn)
      IF gNovine=="D"
        IF !(&aUsl2); SKIP 1; LOOP; ENDIF
      ELSE
        select fakt_doks; hseek fakt->(IdFirma+idtipdok+brdok)
        select fakt; if !(doks->partner=qqPartn); skip; loop; endif
      ENDIF
    endif

    if !empty(cIdRoba)
     if idtipdok="0"  // ulaz
        nUl+=kolicina
        cKolona:="U"
     elseif idtipdok="1"   // izlaz faktura
       if !(left(serbr,1)=="*" .and. idtipdok=="10")  // za fakture na osnovu optpremince ne ra~unaj izlaz
        nIzl+=kolicina
       endif
       cKolona:="I"
     elseif idtipdok$"20#27" .and. cRR=="D"
        if serbr="*"
          nRezerv+=kolicina
          cKolona:="R1"
        endif
     elseif idtipdok=="21".and.cRR=="D"
        nRevers+=kolicina
        cKolona:="R2"
     endif

     if cKolona!="N"

      if prow()-gPStranica>55; FF; ++nStrana; ZaglKart(); endif

      ? space(gnLMarg); ?? str(++nRbr,3)+".   "+idfirma+"-"+idtipdok+"-"+brdok+left(serbr,1)+"  "+DTOC(datdok)

      if cPPartn=="D"
       select fakt_doks; hseek fakt->(IdFirma+idtipdok+brdok); select fakt
       @ prow(),pcol()+1 SAY padr(doks->Partner,20)
      endif

      IF lPoNarudzbi .and. cPKN=="D"
        @ prow(),pcol()+1 SAY idnar
        @ prow(),pcol()+1 SAY brojnar
      ENDIF

      @ prow(),pcol()+1 SAY IF(cKolona=="U",kolicina,0) pict lpickol
      @ prow(),pcol()+1 SAY IF(cKolona!="U",kolicina,0) pict lpickol
      @ prow(),pcol()+1 SAY nUl-(nIzl+nRevers+nRezerv) pict lpickol
      if cPPC=="D"
        @ prow(),pcol()+1 SAY Cijena pict picdem
        @ prow(),pcol()+1 SAY Rabat  pict "99.99"
        @ prow(),pcol()+1 SAY Cijena*(1-Rabat/100) pict picdem
      endif
     endif

     if fieldpos("k1")<>0  .and. gDK1=="D"
       @ prow(),pcol()+1 SAY k1
     endif
     if fieldpos("k2")<>0  .and. gDK2=="D"
       @ prow(),pcol()+1 SAY k2
     endif

     *if cPPartn=="D"
     * select fakt_doks; hseek fakt->(IdFirma+idtipdok+brdok); select fakt
     * ? space(gNLMarg)
     * @ prow(),pcol()+7 SAY doks->Partner
     *endif
     if roba->tip="U"
      aMemo:=ParsMemo(txt)
      aTxtR:=SjeciStr(aMemo[1],60)   // duzina naziva + serijski broj
      for ui=1 to len(aTxtR)
         ? space(gNLMarg)
         @ prow(),pcol()+7 SAY aTxtR[ui]
      next
     endif

    endif

    skip
  enddo
  // GLAVNA DO-WHILE

  if prow()-gPStranica>55; FF; ++nStrana; ZaglKart(); endif

  ? space(gnLMarg); ?? m
  ? space(gnLMarg)+"CIJENA:            "+STR(_cijena,12,3)
  if gVarC=="4" //uporedo i mpc
   ? space(gnLMarg)+"MPC   :            "+STR(_cijena2,12,3)
  endif
  IF cRR=="D"
    ? space(gnLMarg)+"Rezervisano:       "+STR(nRezerv,12,3)
    ? space(gnLMarg)+"Na reversu:        "+STR(nRevers,12,3)
  ENDIF
  ? space(gnLMarg)+PADR("STANJE"+IF(cRR=="D"," (OSTALO):",":"),19)+STR( nUl-(nIzl+nRevers+nRezerv) ,12,3)
  ? space(gnLMarg)+"IZNOS:             "+STR((nUl-(nIzl+nRevers+nRezerv))*_cijena,12,3)
  if gVarC=="4"
    ? space(gnLMarg)+"IZNOS MPV:         "+STR((nUl-(nIzl+nRevers+nRezerv))*_cijena2,12,3)
  endif
  ? space(gnLMarg); ?? m
  ?
  if cOstran=="D"    // kraj kartice => zavrsavam stranicu
    FF; ++nStrana
  endif
enddo

if cOstran!="D"
  FF
endif

END PRINT
CLOSE ALL; MyFERASE(cTMPFAKT)
closeret


STAT PROC ZaglKart(lIniStrana)
  STATIC nZStrana:=0
  IF lIniStrana=NIL; lIniStrana:=.f.; ENDIF
  IF lIniStrana; nZStrana:=0; ENDIF
  B_ON
  IF nStrana>nZStrana
    ?? SPACE(66)+"Strana: "+ALLTRIM(STR(nStrana))
  ENDIF
  ?
  ? space(gnLMarg); ?? m
  ? space(gnLMarg); ?? "SIFRA:"
  if fID_J
   ?? IF(cSintetika=="D".and.ROBA->tip=="S",ROBA->ID_J,left(cidroba,10)),PADR(ROBA->naz,40)," ("+ROBA->jmj+")"
  else
   ?? IF(cSintetika=="D".and.ROBA->tip=="S",ROBA->id,cidroba),PADR(ROBA->naz,40)," ("+ROBA->jmj+")"
  endif
  ? space(gnLMarg); ?? m
  B_OFF
  ? space(gnLMarg)
  ?? "R.br  RJ Br.dokumenta   Dat.dok."
  if cPPartn=="D"
    ?? padc("Partner",21)
  endif
  IF lPoNarudzbi .and. cPKN=="D"
    ?? " Naruc."+" Br.narudz."
  ENDIF
  ?? "     Ulaz       Izlaz      Stanje  "
  if cPPC=="D"
    ?? "     Cijena   Rab%   C-Rab"
  endif

  ? space(gnLMarg); ?? m
  nZStrana=nStrana
return
*}

