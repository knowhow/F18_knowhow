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


function PrenosFin()
local cStranaBitna
local lStranaBitna

private fK1:=fk2:=fk3:=fk4:="N"
O_PARAMS
Private cSection:="1"
private cHistory:=" "
private aHistory:={}


RPar("k1",@fk1)
RPar("k2",@fk2)
RPar("k3",@fk3)
RPar("k4",@fk4)
select params 
use

private cK1:=cK2:="9"
private cK3:=cK4:="99"

IF IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
  ck3:="999"
ENDIF

O_PKONTO
P_PKonto()

cStranaBitna:= "N"
cKlDuguje := "2"
cKlPotraz := "5"

Box(, 12, 60)
  nMjesta:=3
  ddatDo:=date()
  
  @ m_x+1,m_y+2 SAY "Navedite koje grupacije konta se isto ponasaju:"
  @ m_x+3,m_y+2 SAY "Grupisem konte na (broj mjesta)" GET nMjesta pict "9"
  @ m_x+5,m_y+2 SAY "Datum do kojeg se promet prenosi" GET dDatDo

if fk1=="D"; @ m_x+7,m_y+2   SAY "K1 (9 svi) :" GET cK1; endif
if fk2=="D"; @ m_x+7,col()+2 SAY "K2 (9 svi) :" GET cK2; endif
if fk3=="D"; @ m_x+8,m_y+2   SAY "K3 ("+ck3+" svi):" GET cK3; endif
if fk4=="D"; @ m_x+8,col()+1 SAY "K4 (99 svi):" GET cK4; endif

  @ m_x+9, m_y+2 SAY "Klasa konta duguje " GET cKlDuguje PICT "9"
  @ m_x+10, m_y+2 SAY "Klasa konta potraz " GET cKlPotraz PICT "9"
  
  @ m_x+12, m_y+2 SAY "Saldo strane valute je bitan ?" GET cStranaBitna ;
  	PICT "@!" ;
	VALID cStranaBitna $ "DN"
  
  read
  ESC_BCR
  
BoxC()

lStranaBitna := (cStranaBitna == "D")

if ck1=="9"; ck1:=""; endif
if ck2=="9"; ck2:=""; endif
if ck3==REPL("9",LEN(ck3))
  ck3:=""
else
  ck3:=k3u256(ck3)
endif
if ck4=="99"; ck4:=""; endif

//select F_SUBAN
//usex (cDirRad+"\suban") index  (cDirRad+"\subani3")

//select F_PKONTO
//usex (cDirSif+"\pkonto") index (cDirSif+"\pkontoi1")

lPrenos4:=lPrenos5:=lPrenos6:=.f.
SELECT (F_PKONTO)
GO TOP
DO WHILE !EOF()
  IF tip=="4"; lPrenos4:=.t.; ENDIF
  IF tip=="5"; lPrenos5:=.t.; ENDIF
  IF tip=="6"; lPrenos6:=.t.; ENDIF
  SKIP 1
ENDDO


cFilter := ".t."
if fk1=="D" .and. len(ck1)<>0
  cFilter+=" .and. k1='"+ck1+"'"
endif
if fk2=="D" .and. len(ck2)<>0
  cFilter+=" .and. k2='"+ck2+"'"
endif
if fk3=="D" .and. len(ck3)<>0
  cFilter+=" .and. k3='"+ck3+"'"
endif
if fk4=="D" .and. len(ck4)<>0
  cFilter+=" .and. k4='"+ck4+"'"
endif

IF lPrenos4 .or. lPrenos5 .or. lPrenos6
  select (F_SUBAN)
  usex ("suban")
  if lPrenos4
    index on idfirma+idkonto+idpartner+idrj+funk+fond to SUBSUB
  endif
  if lPrenos5
    index on idfirma+idkonto+idpartner+idrj+fond to SUBSUB5
  endif
  if lPrenos6
    index on idfirma+idkonto+idpartner+idrj to SUBSUB6
  endif
  use
  select (F_SUBAN)
  usex ("suban")
  if lPrenos4
    SET INDEX TO SUBSUB
    SET ORDER TO TAG "SUBSUB"
  endif
  if lPrenos5
    SET INDEX TO SUBSUB5
    SET ORDER TO TAG "SUBSUB5"
  endif
  if lPrenos6
    SET INDEX TO SUBSUB6
    SET ORDER TO TAG "SUBSUB6"
  endif
ELSE
  select (F_SUBAN)
  usex ("suban"); set order to tag "3"
  //IdFirma+IdKonto+IdPartner+BrDok+dtos(DatDok)"
ENDIF

IF !(cFilter==".t.")
  SELECT (F_SUBAN)
  SET FILTER TO &(cFilter)
ENDIF

select (F_PKONTO)
usex ("pkonto"); set order to tag "ID"

O_FIN_PRIPR
if reccount2()<>0
  MsgBeep("Priprema mora biti prazna")
  closeret
endif
zap; set order to 0

start print cret
?
? "Prolazim kroz bazu...."
select suban
go top

lVodeSeRJ := FIELDPOS("IDRJ") > 0


Postotak(1,RECCOUNT2(),"Generacija pocetnog stanja")
nProslo:=0

GO TOP
// idfirma, idkonto, idpartner, datdok

dDatVal := CTOD("")

// ----------------------------------- petlja 1
do while !eof()

  nRbr:=ZadnjiRBR()
  cIdFirma:=idfirma

  // ----------------------------------- petlja 2
  do while !eof() .and. cIdFirma==IdFirma

      cIdKonto:=IdKonto
      cTipPr:="0" // tip prenosa
      select pkonto; seek left(cIdKonto,nMjesta)
      if found()        // 1 - otvorene stavke, 2 - saldo partnera,
        cTipPr:=tip     // 3 - otv.st.bez sabiranja,
      endif             // 4 - salda po konto+partner+rj+funkcija+fond
                        // 5 - salda po konto+partner+rj+fond
                        // 6 - salda po konto+partner+rj
      select suban

      if cTipPr=="4"    // mijenjam sort za ovu varijantu
        SET ORDER TO TAG "SUBSUB"
        SEEK cIdFirma+cIdKonto
      elseif cTipPr=="5"    // mijenjam sort za ovu varijantu
        SET ORDER TO TAG "SUBSUB5"
        SEEK cIdFirma+cIdKonto
      elseif cTipPr=="6"    // mijenjam sort za ovu varijantu
        SET ORDER TO TAG "SUBSUB6"
        SEEK cIdFirma+cIdKonto
      elseif lPrenos4 .or. lPrenos5 .or. lPrenos6   // standardni sort
        SET ORDER TO TAG "3"
        SEEK cIdFirma+cIdKonto
      endif

      nDin:=nDem:=0
      //KONTO....pocinje

      // ----------------------------------- petlja 3
      do while !eof() .and. cIdFirma==IdFirma .and. cIdKonto==IdKonto

        cIdPartner:=IdPartner
        ? "Konto:",cidkonto,"    Partner:",cidpartner
        if cTipPr $ "2"    // sabirem po konto+partner
          nDin:=0; nDem:=0
        endif

        if ctippr=="3"
            cSUBk1:=k1
	    cSUBk2:=k2
	    cSUBk3:=k3
	    cSUBk4:=k4

            if Otvst==" "
              Scatter()
              select fin_pripr
              append blank
              Gather()
              replace rbr with str(++nRbr,4),;
                      idvn with "00",;
                      brnal with "00000001"

              select suban
            endif
            Postotak(2,++nProslo)
            skip 1
        else // tipppr=="3#

          cSUBk1:=k1; cSUBk2:=k2; cSUBk3:=k3; cSUBk4:=k4

          // ----------------------------------- petlja 4
          do while !eof() .and. cIdFirma==IdFirma .and. cIdKonto==IdKonto .and. IdPartner==cIdPartner

           cSUBk1:=k1; cSUBk2:=k2; cSUBk3:=k3; cSUBk4:=k4

           if cTipPr=="1"
             cBrDok:=Brdok
	     nDin:=0
	     nDem:=0
             cOtvSt:=otvSt // pretpostavlja se da sve stavke jednog
                           // dokumenta imaju isti znak - otvoren ili zatvoren
             cTekucaRJ:=""
             // ----------------------------------- petlja 5
	     dDatVal:=CTOD("")
             do while !eof() .and. cIdFirma==IdFirma .and. cIdKonto==IdKonto .and. IdPartner==cIdPartner .and. BrDok==cBrDok

              if EMPTY(dDatVal)

		// konto kupaca
		if ( LEFT(IdKonto, 1) == cKlDuguje ) .and. (d_p=="1") 
			if IsVindija()
				if EMPTY(DatVal) .and. !(IsVindija() .and. idvn == "09") 
					dDatVal:=datdok
				else
					dDatVal:=datval
				endif
			else
				if EMPTY(DatVal) 
					dDatVal:=datdok
				else
					dDatVal:=datval
				endif
			endif
		endif

		// konto dobavljaca
		if ( LEFT(IdKonto, 1) == cKlPotraz ) .and. (d_p=="2") 
			if EMPTY(DatVal)
				dDatVal:=datdok
			else
				dDatVal:=datval
			endif
		endif

	       		
	      endif
	       
	       nDin+=iif(d_p=="1", iznosbhd, -iznosbhd)
               nDem+=iif(d_p=="1", iznosdem, -iznosdem)
	       
               IF lVodeSeRJ .and. EMPTY(cTekucaRJ)
                 cTekucaRJ:=IDRJ
               ENDIF
               Postotak(2,++nProslo)
               skip 1

             enddo // brdok
             // ----------------------------------- petlja 5

             //if cOtvSt=="9"
              if round(nDin, 3) <> 0  // ako saldo nije 0
               select fin_pripr
               append blank
               replace  idfirma with cidfirma,;
                        idvn with "00",;
                        brnal with "00000001",;
                        rbr with str(++nRbr,4),;
                        idkonto with cIdkonto,;
                        idpartner with cidpartner,;
                        brdok  with cBrDok,;
                        datdok with dDatDo+1 ,;
			datval with dDatVal
			
               if !(cFilter==".t.")
                 REPLACE  k1 WITH cSUBk1,;
                          k2 WITH cSUBk2,;
                          k3 WITH cSUBk3,;
                          k4 WITH cSUBk4
               endif

	       if cTipPr == "1"
                 if LEFT(IdKonto, 1) == cKlPotraz 
		    // konto dobavljaca
                    replace d_p with "2", iznosbhd with -nDin,iznosdem with -nDem
		 else
		    // konto kupca
                    replace d_p with "1", iznosbhd with nDin,iznosdem with nDem
		 endif
		 
	       else
	         // cTipPr <> "1" 
                 if ndin >= 0
                    replace d_p with "1",iznosbhd with nDin,iznosdem with nDem
                 else
                    replace d_p with "2",iznosbhd with -nDin, iznosdem with -nDem
                 endif 
	       endif
	       
               IF lVodeSeRj
                 REPLACE IDRJ WITH cTekucaRJ
               ENDIF
               select suban
              endif  // limit
             //endif // cotvst=="9"

           endif  // cTipPr=="1"

           if cTipPr=="4"
             cIDRJ := IDRJ; cFunk := FUNK; cFond := FOND
             nDin:=0; nDem:=0

             // ----------------------------------- petlja 6
             do while !eof() .and. cIdFirma==IdFirma .and. cIdKonto==IdKonto .and. IdPartner==cIdPartner ;
                      .and. cIDRJ==IDRJ .and. cFunk==FUNK .and. cFond==FOND

               nDin+=iif(d_p=="1",iznosbhd, -iznosbhd)
               nDem+=iif(d_p=="1",iznosdem, -iznosdem)
               Postotak(2,++nProslo)
               skip 1

             enddo // brdok
             // ----------------------------------- petlja 6

              if round(nDin, 3) <> 0  // ako saldo nije 0
               select fin_pripr
               append blank
               replace  idfirma with cidfirma,;
                        idvn with "00",;
                        brnal with "00000001",;
                        rbr with str(++nRbr,4),;
                        idkonto with cIdkonto,;
                        idpartner with cidpartner,;
                        idrj with cIDRJ,;
                        funk with cFunk,;
                        fond with cFond,;
                        datdok with dDatDo+1
			
               if !(cFilter==".t.")
                 REPLACE  k1 WITH cSUBk1,;
                          k2 WITH cSUBk2,;
                          k3 WITH cSUBk3,;
                          k4 WITH cSUBk4
               endif
               if ndin>=0
                  replace d_p with "1",iznosbhd with nDin,iznosdem with nDem
               else
                 replace d_p with "2",iznosbhd with -nDin, iznosdem with -nDem
               endif // ndin
               select suban
              endif  // limit

           endif  // cTipPr=="4"

           if cTipPr=="5"
             cIDRJ := IDRJ; cFond := FOND
             nDin:=0; nDem:=0

             // ----------------------------------- petlja 6
             do while !eof() .and. cIdFirma==IdFirma .and. cIdKonto==IdKonto .and. IdPartner==cIdPartner ;
                      .and. cIDRJ==IDRJ .and. cFond==FOND

               nDin+=iif(d_p=="1",iznosbhd,-iznosbhd)
               nDem+=iif(d_p=="1",iznosdem,-iznosdem)
               Postotak(2,++nProslo)
               skip 1

             enddo // brdok
             // ----------------------------------- petlja 6

              if round(nDin,3)<>0  // ako saldo nije 0
               select fin_pripr
               append blank
               replace  idfirma with cidfirma,;
                        idvn with "00",;
                        brnal with "00000001",;
                        rbr with str(++nRbr,4),;
                        idkonto with cIdkonto,;
                        idpartner with cidpartner,;
                        idrj with cIDRJ,;
                        fond with cFond,;
                        datdok with dDatDo+1
               if !(cFilter==".t.")
                 REPLACE  k1 WITH cSUBk1,;
                          k2 WITH cSUBk2,;
                          k3 WITH cSUBk3,;
                          k4 WITH cSUBk4
               endif
               if ndin>=0
                  replace d_p with "1",iznosbhd with nDin,iznosdem with nDem
               else
                 replace d_p with "2",iznosbhd with -nDin, iznosdem with -nDem
               endif // ndin
               select suban
              endif  // limit

           endif  // cTipPr=="5"

           if cTipPr=="6"
             cIDRJ := IDRJ
             nDin:=0; nDem:=0

             // ----------------------------------- petlja 6
             do while !eof() .and. cIdFirma==IdFirma .and. cIdKonto==IdKonto .and. IdPartner==cIdPartner ;
                      .and. cIDRJ==IDRJ

               nDin+=iif(d_p=="1",iznosbhd,-iznosbhd)
               nDem+=iif(d_p=="1",iznosdem,-iznosdem)
               Postotak(2,++nProslo)
               skip 1

             enddo // brdok
             // ----------------------------------- petlja 6

              if round(nDin,3)<>0  // ako saldo nije 0
               select fin_pripr
               append blank
               replace  idfirma with cidfirma,;
                        idvn with "00",;
                        brnal with "00000001",;
                        rbr with str(++nRbr,4),;
                        idkonto with cIdkonto,;
                        idpartner with cidpartner,;
                        idrj with cIDRJ,;
                        datdok with dDatDo+1
               if !(cFilter==".t.")
                 REPLACE  k1 WITH cSUBk1,;
                          k2 WITH cSUBk2,;
                          k3 WITH cSUBk3,;
                          k4 WITH cSUBk4
               endif
               if ndin>=0
                 replace d_p with "1",iznosbhd with nDin,iznosdem with nDem
               else
                 replace d_p with "2",iznosbhd with -nDin, iznosdem with -nDem
               endif // ndin
               select suban
              endif  // limit

           endif  // cTipPr=="6"

           if cTipPr $ "02"
             if d_p=="1"; nDin+=iznosbhd; nDem+=IznosDEM; endif
             if d_p=="2"; nDin-=iznosbhd; nDem-=IznosDEM; endif
             skip 1
             Postotak(2,++nProslo)
           endif

          enddo // konto, partner
          // ----------------------------------- petlja 4

        endif    // tippr=="3"

        if cTipPr=="2"  // sabirem po konto+partner
          if (round(nDin,2) <> 0) .or. ((round(nDem, 2) <> 0 ) .and. lStranaBitna)
            select fin_pripr
            append blank
            replace rbr with  str(++nRbr,4),;
                    idkonto with cIdkonto,;
                    idpartner with cidpartner,;
                    datdok with dDatDo+1,;
                    idfirma with cidfirma,;
                    idvn with "00", idtipdok with "00",;
                    brnal with "00000001"
            if !(cFilter==".t.")
              REPLACE  k1 WITH cSUBk1,;
                       k2 WITH cSUBk2,;
                       k3 WITH cSUBk3,;
                       k4 WITH cSUBk4
            endif
	    
            if nDin >= 0
               replace d_p with "1",;
                       iznosbhd with nDin,;
                       iznosdem with nDem
            else
               replace d_p with "2",;
                       iznosbhd with -nDin,;
                       iznosdem with -nDem
            endif // ndin
	    
            select suban
          endif // <> 0
        endif

      enddo // konto
      // ----------------------------------- petlja 3

      if cTipPr=="0"  // sabirem po konto bez obzira na partnera
       if (round(nDin,2) <> 0) .or. (round( nDem, 2 ) <> 0  .and. lStranaBitna)
        select fin_pripr
        append blank
        replace rbr with  str(++nRbr,4),;
                idkonto with cIdkonto,;
                datdok with dDatDo+1,;
                idfirma with cidfirma,;
                idvn with "00", idtipdok with "00",;
                brnal with "00000001"
         if !(cFilter==".t.")
           REPLACE  k1 WITH cSUBk1,;
                    k2 WITH cSUBk2,;
                    k3 WITH cSUBk3,;
                    k4 WITH cSUBk4
         endif
         if ndin>=0
            replace d_p with "1",;
                    iznosbhd with nDin,;
                    iznosdem with nDem
         else
            replace d_p with "2",;
                    iznosbhd with -nDin,;
                    iznosdem with -nDem
         endif // ndin
         select suban
       endif // <> 0
      endif

  enddo // firma
  // ----------------------------------- petlja 2

enddo // eof
// ----------------------------------- petlja 1

Postotak(0)

end print
close all

// ovo nam u ovom momentu ne treba uopste !!!
/*
if !empty(goModul:oDataBase:cSezona) .and. Pitanje(,"Prebaciti dokument u radno podrucje","D")=="D"
  O_FIN_PRIPRRP
  O_FIN_PRIPR
  select fin_priprrp
  append from fin_pripr
  select fin_pripr; zap
  close all
  if Pitanje(,"Prebaciti se na rad sa radnim podrucjem ?","D")=="D"
      URadPodr()
  endif
endif
*/

return




/*! \fn fin_prekart()
 *  \brief Prebacivanje subanalitickih konta... 
 */
 
function fin_prekart()

LOCAL aNiz:={}
 PRIVATE cKonto:=SPACE(60), cPartn:=SPACE(60)
 PRIVATE dDat0:=CTOD(""), dDat1:=CTOD(""), cFirma:=gFirma

MsgBeep("http://redmine.bring.out.ba/issues/26730")

return

Msg("Ova opcija omogucava prebacivanje svih ili dijela stavki sa#"+;
     "postojeceg na drugi konto. Zeljeni konto je u tabeli prikazan#"+;
     "u koloni sa zaglavljem 'Novi konto'. POSLJEDICA OVIH PROMJENA#"+;
     "JE DA CE NALOZI KOJI SADRZE IZMIJENJENE STAVKE BITI RAZLICITI#"+;
     "OD ODSTAMPANIH, PA SE PREPORUCUJE PONOVNA STAMPA TIH NALOGA.")

 AADD (aNiz, {"Firma (prazno-sve)","cFirma",,,})
 AADD (aNiz, {"Konto (prazno-sva)","cKonto",,"@!S30",})
 AADD (aNiz, {"Partner (prazno-svi)","cPartn",,"@!S30",})
 AADD (aNiz, {"Za period od datuma","dDat0",,,})
 AADD (aNiz, {"          do datuma","dDat1",,,})

 DO WHILE .t.
   IF !VarEdit(aNiz, 9,5,17,74,;
               'POSTAVLJANJE USLOVA ZA IZDVAJANJE SUBANALITICKIH STAVKI',;
               "B1")
     CLOSERET
   ENDIF
   aUsl1:=Parsiraj(cKonto,"idkonto")
   aUsl2:=Parsiraj(cPartn,"idpartner")
   if aUsl1<>NIL.and.aUsl2<>NIL
     exit
   elseif aUsl1<>NIL
     MsgBeep ("Kriterij za partnera nije korektno postavljen!")
   elseif aUsl2<>NIL
     MsgBeep ("Kriterij za konto nije korektno postavljen!")
   else
     MsgBeep ("Kriteriji za konto i partnera nisu korektno postavljeni!")
   endif
 ENDDO // .t.

 // otvaranje potrebnih baza
 ///////////////////////////

 O_KONTO
 O_PARTN
 O_SINT; SET ORDER TO tag "2"
 O_ANAL; SET ORDER TO tag "2"
 O_SUBAN

 IF !FILE("TEMP77.DBF")
   aTmp:=DBSTRUCT()
   AADD(aTmp,{"KONTO2","C",7,0})
   AADD(aTmp,{"PART2", "C",6,0})
   AADD(aTmp,{"NSLOG","N",10,0})
   DBCREATE2("TEMP77.DBF",aTmp)
 ENDIF
 USEX(TEMP77, TEMP77, .t.)
 ZAP

 SELECT F_SUBAN

 cFilt1 := ".t." + IF(!EMPTY(cFirma),".and.IDFIRMA=="+cm2str(cFirma),"")+ IIF(!EMPTY(dDat0),".and.DATDOK>="+cm2str(dDat0),"")+;
           IF(!EMPTY(dDat1), ".and.DATDOK<=" + cm2str(dDat1),"") + ".and."+aUsl1+".and."+aUsl2

 cFilt1 := STRTRAN( cFilt1 , ".t..and." , "" )
 IF !(cFilt1==".t.")
   SET FILTER TO &cFilt1
 ENDIF

 GO TOP
 DO WHILE !EOF()
   Scatter()
   _konto2:=_idkonto
   _part2:=_idpartner
   _nslog:=RECNO()
   SELECT TEMP77
   APPEND BLANK
   Gather()
   SELECT F_SUBAN
   SKIP 1
 ENDDO

SELECT TEMP77
GO TOP

ImeKol:={ ;
          {"F.",            {|| IdFirma }, "IdFirma" } ,;
          {"VN",            {|| IdVN    }, "IdVN" } ,;
          {"Br.",           {|| BrNal   }, "BrNal" },;
          {"R.br",          {|| RBr     }, "rbr" , {|| wrbr()}, {|| vrbr()} } ,;
          {"Konto",         {|| IdKonto }, "IdKonto", {|| .t.}, {|| P_Konto(@_IdKonto),.t. } } ,;
          {"Novi konto",    {|| konto2  }, "konto2", {|| .t.}, {|| P_Konto(@_konto2),.t. } } ,;
          {"Partner",       {|| IdPartner }, "IdPartner", {|| .t.}, {|| P_Firma(@_idpartner), .t. } } ,;
          {"Novi partner",  {|| part2  }, "part2", {|| .t.}, {|| P_Firma(@_part2),.t. } } ,;
	  {"Br.veze ",      {|| BrDok   }, "BrDok" } ,;
          {"Datum",         {|| DatDok  }, "DatDok" } ,;
          {"D/P",           {|| D_P     }, "D_P" } ,;
          {ValDomaca(),     {|| transform(IznosBHD,FormPicL(gPicBHD,15)) }, "iznos "+ALLTRIM(ValDomaca()) } ,;
          {ValPomocna(),    {|| transform(IznosDEM,FormPicL(gPicDEM,10)) }, "iznos "+ALLTRIM(ValPomocna()) } ,;
          {"Opis",          {|| Opis      }, "OPIS" }, ;
          {"K1",            {|| k1      }, "k1" },;
          {"K2",            {|| k2      }, "k2" },;
          {"K3",            {|| k3iz256(k3)      }, "k3" },;
          {"K4",            {|| k4      }, "k4" } ;
        }

Kol:={}; for i:=1 to LEN(ImeKol); AADD(Kol,i); next

DO WHILE .t.
 Box(,20,77)
 @ m_x+19,m_y+2 SAY "                         ³                        ³                   "
 @ m_x+20,m_y+2 SAY " <c-T>  Brisi stavku     ³ <ENTER>  Ispravi konto ³ <a-A> Azuriraj    "
 ObjDbedit("PPK",20,77,{|| EPPK()},"","Priprema za prebacivanje stavki", , , , ,2)
 BoxC()
 IF RECCOUNT2()>0
  i:=KudaDalje("ZAVRSAVATE SA PRIPREMOM PODATAKA. STA RADITI SA URADJENIM?",;
            { "AZURIRATI PODATKE",;
              "IZBRISATI PODATKE",;
              "VRATIMO SE U PRIPREMU" })
  DO CASE
    CASE i==1
      AzurPPK()
      EXIT
    CASE i==2
      EXIT
    CASE i==3
      GO TOP
  ENDCASE
 ELSE
  EXIT
 ENDIF
ENDDO

CLOSERET
return NIL



/*! \fn EPPK()
 *  \brief Ispravka konta, promjena konta 
 */
 
function EPPK()

local nTr2

if (Ch==K_CTRL_T .or. Ch==K_ENTER) .and. reccount2()==0
  return DE_CONT
endif

select temp77
do case

  case Ch==K_CTRL_T
     if Pitanje("p01","Zelite izbrisati ovu stavku ?","D")=="D"
      MY_DELETE
      return DE_REFRESH
     endif
     return DE_CONT

   case Ch==K_ENTER
    Scatter()
    IF !VarEdit({{"Konto","_konto2","P_Konto(@_konto2)",,}}, 9,5,17,74,;
               'POSTAVLJANJE NOVOG KONTA',;
               "B1")
     return DE_CONT
    ELSE
     Gather()
     return DE_REFRESH
    ENDIF

   case Ch==K_ALT_A
       AzurPPK()
     return DE_REFRESH

endcase

return DE_CONT



/*! \fn AzurPPK()
 *  \brief Azuriranje promjena konta 
 */
 
function AzurPPK()

 LOCAL lIndik1:=.f., lIndik2:=.f., nZapisa:=0, nSlog:=0, cStavka:="   "
  SELECT SUBAN
  SET FILTER TO
  GO TOP
  SELECT TEMP77
  Postotak(1,RECCOUNT2(),"Azuriranje promjena na subanalitici",,,.t.)
  GO TOP
  DO WHILE !EOF()

    // azuriraj subanalitiku
  //////////////////////////////////////////////////
    if (TEMP77->idkonto != TEMP77->konto2)  
      SELECT SUBAN
      GO TEMP77->NSLOG
      Scatter()
        _idkonto:=TEMP77->konto2
      Gather()
    endif

    if (TEMP77->idpartner != TEMP77->part2)  
      SELECT SUBAN
      GO TEMP77->NSLOG
      Scatter()
        _idpartner:=TEMP77->part2
      Gather()
    endif

    // azuriraj analitiku
  //////////////////////////////////////////////////
    if TEMP77->idkonto!=TEMP77->konto2
      SELECT ANAL; GO TOP
      SEEK TEMP77->(idfirma+idvn+brnal)
      lIndik1:=.f.; lIndik2:=.f.
      DO WHILE !EOF() .and. idfirma+idvn+brnal==TEMP77->(idfirma+idvn+brnal)
        IF idkonto==TEMP77->idkonto .and. !lIndik1
           lIndik1:=.t.
           Scatter()
             IF TEMP77->d_p=="1"
               _dugbhd := _dugbhd - TEMP77->iznosbhd
               _dugdem := _dugdem - TEMP77->iznosdem
             ELSE
               _potbhd := _potbhd - TEMP77->iznosbhd
               _potdem := _potdem - TEMP77->iznosdem
             ENDIF
           Gather()
        ELSEIF idkonto==TEMP77->konto2 .and. !lIndik2
           lIndik2:=.t.
           Scatter()
             IF TEMP77->d_p=="1"
               _dugbhd := _dugbhd + TEMP77->iznosbhd
               _dugdem := _dugdem + TEMP77->iznosdem
             ELSE
               _potbhd := _potbhd + TEMP77->iznosbhd
               _potdem := _potdem + TEMP77->iznosdem
             ENDIF
           Gather()
        ENDIF
        SKIP 1
      ENDDO
      SKIP -1
      IF !lIndik2
        Scatter()
         _idkonto:=TEMP77->konto2
         _rbr:=NovaSifra(_rbr)
         IF gDatNal=="N"; _datnal:=TEMP77->datdok; ENDIF
         _dugbhd:=IF(TEMP77->d_p=="1",TEMP77->iznosbhd,0)
         _potbhd:=IF(TEMP77->d_p=="2",TEMP77->iznosbhd,0)
         _dugdem:=IF(TEMP77->d_p=="1",TEMP77->iznosdem,0)
         _potdem:=IF(TEMP77->d_p=="2",TEMP77->iznosdem,0)
         APPEND BLANK
        Gather()
      ENDIF
    endif

    // azuriraj sintetiku
  //////////////////////////////////////////////////
    if LEFT(TEMP77->idkonto,3)!=LEFT(TEMP77->konto2,3)
      SELECT SINT; GO TOP
      SEEK TEMP77->(idfirma+idvn+brnal)
      lIndik1:=.f.; lIndik2:=.f.
      DO WHILE !EOF() .and. idfirma+idvn+brnal==TEMP77->(idfirma+idvn+brnal)
        IF idkonto==LEFT(TEMP77->idkonto,3) .and. !lIndik1
           lIndik1:=.t.
           Scatter()
             IF TEMP77->d_p=="1"
               _dugbhd := _dugbhd - TEMP77->iznosbhd
               _dugdem := _dugdem - TEMP77->iznosdem
             ELSE
               _potbhd := _potbhd - TEMP77->iznosbhd
               _potdem := _potdem - TEMP77->iznosdem
             ENDIF
           Gather()
        ELSEIF idkonto==LEFT(TEMP77->konto2,3) .and. !lIndik2
           lIndik2:=.t.
           Scatter()
             IF TEMP77->d_p=="1"
               _dugbhd := _dugbhd + TEMP77->iznosbhd
               _dugdem := _dugdem + TEMP77->iznosdem
             ELSE
               _potbhd := _potbhd + TEMP77->iznosbhd
               _potdem := _potdem + TEMP77->iznosdem
             ENDIF
           Gather()
        ENDIF
        SKIP 1
      ENDDO
      SKIP -1
      IF !lIndik2
        Scatter()
         _idkonto:=LEFT(TEMP77->konto2,3)
         _rbr:=NovaSifra(_rbr)
         IF gDatNal=="N"; _datnal:=TEMP77->datdok; ENDIF
         _dugbhd:=IF(TEMP77->d_p=="1",TEMP77->iznosbhd,0)
         _potbhd:=IF(TEMP77->d_p=="2",TEMP77->iznosbhd,0)
         _dugdem:=IF(TEMP77->d_p=="1",TEMP77->iznosdem,0)
         _potdem:=IF(TEMP77->d_p=="2",TEMP77->iznosdem,0)
         APPEND BLANK
        Gather()
      ENDIF
    endif

    SELECT TEMP77
    SKIP 1
    Postotak(2,++nZapisa,,,,.f.)
  ENDDO
  Postotak(-1,,,,,.f.)
  ZAP

  SELECT ANAL
  nZapisa:=0
  Postotak(1,RECCOUNT2(),"Azuriranje promjena na analitici",,,.f.)
  GO TOP
  DO WHILE !EOF()
    IF dugbhd==0 .and. potbhd==0 .and. dugdem==0 .and. potdem==0
      SKIP 1
      nSlog:=RECNO()
      SKIP -1
      MY_DELETE
      GO nSlog
    ELSE
      SKIP 1
    ENDIF
    Postotak(2,++nZapisa,,,,.f.)
  ENDDO
  Postotak(-1,,,,,.f.)

  SELECT SINT
  nZapisa:=0
  Postotak(1,RECCOUNT2(),"Azuriranje promjena na sintetici",,,.f.)
  GO TOP
  DO WHILE !EOF()
    IF dugbhd==0 .and. potbhd==0 .and. dugdem==0 .and. potdem==0
      SKIP 1
      nSlog:=RECNO()
      SKIP -1
      MY_DELETE
      GO nSlog
    ELSE
      SKIP 1
    ENDIF
    Postotak(2,++nZapisa,,,,.f.)
  ENDDO
  Postotak(-1,,,,,.t.)

  SELECT TEMP77
RETURN



/*! \fn ZadnjiRbr()
 *  \brief Vraca zadnji redni broj 
 */
 
function ZadnjiRBR()

local nZRBR:=0
local nObl:=SELECT()

O_FIN_PRIPR
go bottom
nZRBR:=VAL(rbr)
select (nObl)
return (nZRBR)


