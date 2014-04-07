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


static __PIC_KOL := "9999999999.999"
static __PIC_DEM := "99999.999"
static __PIC_IZN := "999999999.99"


static function _o_tables()
O_FAKT_DOKS
O_TARIFA
O_PARTN
O_SIFK
O_SIFV
O_ROBA
O_RJ
O_FAKT
set order to tag "3" 
return




// -------------------------------------------------------
// izvjestaj stanje robe
// -------------------------------------------------------
function fakt_stanje_robe()
local fSaberiKol, nKU, nKI
local cDDokOtpr 
private cIdFirma
private qqroba,ddatod,ddatdo,nRezerv,nRevers
private nUl, nIzl, nRbr, cRR, nCol1 := 0, nCol0 := 50
private m := ""
private nStr := 0
private cProred := "N"
private qqTipdok := "  "

lBezUlaza := .f. 

_o_tables()

cIdfirma := gFirma
qqRoba := ""
dDatOd := CTOD("")
dDatDo := DATE()
cSaldo0 := "N"
cDDokOtpr := "D"
qqPartn := SPACE(20)

Box(, 13, 66 )

O_PARAMS
private cSection:="5",cHistory:=" "; aHistory:={}
Params1()
RPar("c1",@cIdFirma)
RPar("c2",@qqRoba)
RPar("d1",@dDatOd)
RPar("d2",@dDatDo)
RPar("d3",@cDDokOtpr)

fSaberikol := .f. 
qqRoba:=padr(qqRoba,60)
qqPartn:=padr(qqPartn,20)
qqTipDok:=padr(qqTipDok,2)

cRR:="N"

private cTipVPC:="1"

cK1:=cK2:=space(4)

private cMink:="N"

do while .t.
 if gNW$"DR"
   @ m_x+1,m_y+2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| empty(cIdFirma) .or. cidfirma==gFirma .or. P_RJ(@cIdFirma), cIdFirma := LEFT( cIdFirma, 2 ), .t. }
 else
  @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif

   @ m_x+2,m_y+2 SAY "Roba   "  GET qqRoba   pict "@!S40"
   @ m_x+3,m_y+2 SAY "Od datuma "  get dDatOd
   @ m_x+3,col()+1 SAY "do"  get dDatDo
   @ m_x+4,m_y+2 SAY "gledati datum (D)dok. (O)otpr. (V)value:" get cDDokOtpr ;
   	VALID cDDokOtpr $ "DOV" PICT "@!"
   
   cRR := "N"
   xPos := 5
@ m_x+xPos,m_y+2 SAY "Prikaz stavki sa stanjem 0 (D/N)    "  get cSaldo0 pict "@!" valid cSaldo0 $ "DN"
if gVarC $ "12"
   @ m_x+xPos+1,m_y+2 SAY "Stanje prikazati sa Cijenom 1/2 (1/2) "  get cTipVpc pict "@!" valid cTipVPC $ "12"
endif

if fakt->(fieldpos("K1"))<>0 .and. gDK1=="D"
   @ m_x+xPos+3,m_y+2 SAY "K1" GET  cK1 pict "@!"
   @ m_x+xPos+4,m_y+2 SAY "K2" GET  cK2 pict "@!"
endif

@ m_x+xPos+5,m_y+2 SAY "Prikaz samo kriticnih zaliha (D/N/O) ?" GET cMinK pict "@!" valid cMink$"DNO"
@ m_x+xPos+7,m_y+2 SAY "Napraviti prored (D/N)    "  get cProred pict "@!" valid cProred $ "DN"

read

 ESC_BCR

 aUsl1:=Parsiraj(qqRoba,"IdRoba")
 
 if lPoNarudzbi
   aUslN := Parsiraj(qqIdNar,"idnar")
 endif

 if aUsl1<>NIL 
   exit
 endif

enddo

if cMink=="O"
   cSaldo0:="D" 
endif

if lBezUlaza
   m := "---- ---------- ----------------------------------------"+IF(lPoNarudzbi.and.cPKN=="D"," ------","")+" ----------- ---"
else
   m := "---- ---------- ----------------------------------------"+IF(lPoNarudzbi.and.cPKN=="D"," ------","") + " " + ;
        REPLICATE( "-", LEN(__PIC_KOL) ) + " --- " + REPLICATE( "-", LEN( __PIC_DEM ) ) + " " + REPLICATE("-", LEN( __PIC_IZN ))
endif
// endif

SELECT PARAMS
Params2()
qqRoba:=trim(qqRoba)
WPar("c1",cIdFirma)
WPar("c2",qqRoba)
WPar("c7",qqPartn)
WPar("c8",qqTipDok)
WPar("d1",dDatOd)
WPar("d2",dDatDo)
WPar("d3",cDDokOtpr)
select params; use

BoxC()

fSMark:=.f.
if (right(qqRoba,1)=="*")
  // izvrsena je markacija robe ..
  fSMark:=.t.
endif

// ako ne postoji polje datuma isporuke
// uvijek gledaj dokumente
if fakt_doks->(FIELDPOS("DAT_ISP")) = 0
	cDDokOtpr := "D"
endif

select FAKT

if lPoNarudzbi .and. cPKN=="D"
    SET ORDER TO TAG "3N"
endif

private cFilt:=".t."


if aUsl1 <> ".t."
    cFilt += ".and." + aUsl1
endif

if !empty(dDatOd) .or. !empty(dDatDo)
 
 // sort po datumu dokumenta
 if cDDokOtpr == "D"
	cFilt+= ".and. DatDok>=" + _filter_quote(dDatOd)+;
		".and. DatDok<=" + _filter_quote(dDatDo)
 endif

endif

if lPoNarudzbi .and. aUslN<>".t."
  cFilt+=".and."+aUslN
endif

cTMPFAKT:=""

if cFilt==".t."
   set filter to
else
   set filter to &cFilt
endif

go top
EOF CRET

cSintetika:="N"

nKU := nKI := 0

START PRINT CRET

ZaglSrobe()

_cijena:=0

nRbr:=0
nIzn:=0
nRezerv:=nRevers:=0
qqPartn:=trim(qqPartn)
cidfirma:=trim(cidfirma)

nH:=0

do while !EOF()
    
    // provjeri datumski valutu, otpremnicu
    if cDDokOtpr == "O"
    	select fakt_doks
	    seek fakt->idfirma + fakt->idtipdok + fakt->brdok
	    if fakt_doks->dat_otpr < dDatOd .or. fakt_doks->dat_otpr > dDatDo
		    select fakt
		    skip
		    loop
	    endif
	    select fakt
    endif
    
    if cDDokOtpr == "V"
    	select fakt_doks
	    seek fakt->idfirma + fakt->idtipdok + fakt->brdok
	    if fakt_doks->dat_val < dDatOd .or. fakt_doks->dat_val > dDatDo
	    	select fakt
		    skip
		    loop
	    endif
	    select fakt
    endif

    // skip & loop gdje je roba->_M1_ != "*"
    if fSMark .and. SkLoNMark("ROBA",SiSiRo()) 
        skip
        loop
    endif

    cIdRoba := IdRoba

    if lPoNarudzbi .and. cPKN=="D"
        cIdNar:=idnar
    endif

    nStanjeCR := nUl := nIzl := 0
    nRezerv := nRevers := 0

    do while !eof()  .and. cIdRoba==IdRoba 

        // provjeri datumski valutu, otpremnicu
        if cDDokOtpr == "O"
    	    select fakt_doks
	        seek fakt->idfirma + fakt->idtipdok + fakt->brdok
	        if fakt_doks->dat_otpr < dDatOd .or. fakt_doks->dat_otpr > dDatDo
		        select fakt
		        skip
	        	loop
	        endif
	        select fakt
        endif
    
        if cDDokOtpr == "V"
    	    select fakt_doks
	        seek fakt->idfirma + fakt->idtipdok + fakt->brdok
	        if fakt_doks->dat_val < dDatOd .or. fakt_doks->dat_val > dDatDo
		        select fakt
		        skip
		        loop
	        endif
	        select fakt
        endif

        // skip & loop gdje je roba->_M1_ != "*"
        if fSMark .and. SkLoNMark("ROBA",SiSiRo()) 
            skip; loop
        endif

        if !empty(qqTipDok)
            if idtipdok<>qqTipDok
                skip; loop
            endif
        endif

        if !empty(cidfirma)
            if idfirma<>cidfirma; skip; loop; endif
        endif

        if !empty(qqPartn)
            select fakt_doks
            hseek fakt->(IdFirma+idtipdok+brdok)
            select fakt
            if !(fakt_doks->partner=qqPartn)
                skip
	            loop
            endif
        endif

        // atributi!!!!!!!!!!!!!
        if !empty(cK1)
            if ck1<>K1
                skip
                loop
            endif
        endif
        if !empty(cK2)
            if ck2<>K2
                skip    
                loop
            endif
        endif

        if !empty(cIdRoba)
            if cRR<>"F"
                if idtipdok="0"  
                    // ulaz
                    nUl+=kolicina
                    if fSaberikol .and. !( roba->K2 = 'X')
                        nKU+=kolicina
                    endif
                elseif idtipdok="1"   
                    // izlaz faktura
                    // za fakture na osnovu optpremince ne ra~unaj izlaz
                    if !(serbr="*" .and. idtipdok=="10") 
                        nIzl+=kolicina
                        if fSaberikol .and. !( roba->K2 = 'X')
                            nKI+=kolicina
                        endif
                    endif
                elseif idtipdok $ "20#27"
                    if serbr="*"
                        nRezerv+=kolicina
                        if fSaberikol .and. !( roba->K2 = 'X')
                            nKI+=kolicina
                        endif
                    endif
                elseif idtipdok=="21"
                    nRevers+=kolicina
                    if fSaberikol .and. !( roba->K2 = 'X')
                        nKI+=kolicina
                    endif
                endif
            else
                // za fakture na osnovu otpremince ne ra~unaj izlaz
                if (serbr="*" .and. idtipdok=="10") 
                    nIzl+=kolicina
                    if fSaberikol .and. !( roba->K2 = 'X')
                        nKI+=kolicina
                    endif
            endif
        endif // crr=="F"
    endif  // empty(
    skip
enddo

if !EMPTY(cIdRoba)
    
    NSRNPIdRoba(cIdRoba, cSintetika=="D" )
    
    SELECT ROBA
    
    if (fieldpos("MINK"))<>0
        nMink:=roba->mink
    else
        nMink:=0
    endif
    
    SELECT FAKT
    
    if prow() > 61 - iif(cProred="D",1,0)
        ZaglSRobe()
    endif

    if (cMink<>"D" .and. (cSaldo0=="D" .or. round(nUl-nIzl,4)<>0)) .or. ; //ne prikazuj stavke 0
        (cMink=="D" .and. nMink<>0 .and. (nUl-nIzl-nMink)<0)

        if cMink=="O" .and. nMink==0 .and. round(nUl-nIzl,4)==0
            loop
        endif

        if cProred=="D"
            ? space(gnLMarg)
            ?? m
        endif
     
        if cMink=="O" .and. nMink<>0 .and. (nUl-nIzl-nMink)<0
            B_ON
        endif  
    
        //
        // pocetak reda...
        // 
        ? space(gnLMarg); ?? str(++nRbr,4),cidroba,PADR(ROBA->naz,40)

        if lPoNarudzbi .and. cPKN=="D"
            ?? "", cIdNar
        endif

        nCol0:=pcol()-11

        if fSaberiKol .and. lBezUlaza
            nCol1:=pcol()+1
        endif
     
        @ prow(),pcol() + 1 SAY nUl-nIzl pict __PIC_KOL
        @ prow(),pcol() + 1 SAY roba->jmj
     
        if cTipVPC=="2" .and.  roba->(fieldpos("vpc2")<>0)
            _cijena:=roba->vpc2
        else
            _cijena := if ( !EMPTY(cIdFirma) , fakt_mpc_iz_sifrarnika(), roba->vpc )
        endif

        if !lBezUlaza
            @ prow(), pcol()+1 SAY _cijena PICT __PIC_DEM
            nCol1 := pcol()+1
            @ prow(), nCol1 SAY ( nUl - nIzl ) * _cijena PICT __PIC_IZN
        endif

        nIzn += (nUl-nIzl) * _cijena

        if cMink<>"N" .and. nMink>0
            ?
            @ prow(),ncol0    SAY padr("min.kolic:",len(pickol))
            @ prow(),pcol()+1 SAY nMink  pict __PIC_KOL
        endif

        if cMink=="O" .and. nMink<>0 .and. (nUl-nIzl-nMink)<0
            B_OFF
        endif
    endif

 endif

enddo

if prow()>59; ZaglSRobe(); endif

if !lBezUlaza
  ? space(gnLMarg); ?? m
  ? space(gnLMarg); ?? " Ukupno:"
  @ prow(),nCol1 SAY nIzn  pict picdem
endif

? space(gnLMarg); ?? m

if fSaberikol
? space(gnLMarg); ?? " Ukupno (kolicine):"
 @ prow(),nCol1    SAY nKU-nKI   picture pickol
endif
? space(gnLMarg); ?? m
FF

END PRINT
my_close_all_dbf()
MyFERASE(cTMPFAKT)


my_close_all_dbf()
return


function ZaglSRobe()
local _rj_tip := ""

if rj->(fieldpos("tip")) <> 0
    _rj_tip := rj->tip
endif

if nstr > 0
  FF
endif
?
P_COND
? space(4), "FAKT: "
?? "Stanje"
?? " robe na dan", date(), "      za period od", dDatOd, "-", dDatDo,space(6),"Strana:",str(++nStr,3)

?
if cRR=="D"
  P_COND2
else
  P_COND
endif

? space(gnLMarg); IspisFirme(cidfirma)
if !empty(qqRoba)
  ? space(gnLMarg)
  ?? "Roba:",qqRoba
endif

if !empty(cK1)
  ?
  ? space(gnlmarg), "- Roba sa osobinom K1:",ck1
endif
if !empty(cK2)
  ?
  ? space(gnlmarg), "- Roba sa osobinom K2:",ck2
endif

if glDistrib .and. !empty(cIdDist)
  ?
  ? space(gnlmarg), "- kontrola distributera:",cIdDist
endif

if lPoNarudzbi .and. !EMPTY(qqIdNar)
  ?
  ? "Prikaz za sljedece narucioce:",TRIM(qqIdNar)
endif

?
if cTipVPC=="2" .and.  roba->(fieldpos("vpc2")<>0)
  ? space(gnlmarg)
  ?? "U CJENOVNIKU SU PRIKAZANE CIJENE: "+cTipVPC
endif
?
? space(gnLMarg)
?? m
? space(gnLMarg)
if lBezUlaza
   ?? "R.br  Sifra       Naziv                                 "+IF(lPoNarudzbi.and.cPKN=="D","Naruc. ","")+"   Stanje      jmj     "
else
   ?? "R.br  Sifra       Naziv                                 "+IF(lPoNarudzbi.and.cPKN=="D","Naruc. ","")+"   Stanje      jmj     "+IF(_rj_tip$"M1#M2".and.!EMPTY(cIdFirma),"Cij.",if(IsPDV()," PC ","VPC "))+"      Iznos"
endif
// endif

? space(gnLMarg)
?? m
return



