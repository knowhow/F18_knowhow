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


#include "f18.ch"

#define DABLAGAS lBlagAsis .and. _IDVN == cBlagIDVN



// -----------------------------------------------------------------------------
// Blagajna dnevni izvjestaj
// -----------------------------------------------------------------------------
function Blagajna()
local nRbr, nCOpis:=0, cOpis := ""
local _idvn
local _rec
local _nCol1
//lSumiraj := ( IzFMKINI("BLAGAJNA","DBISumirajPoBrojuVeze","N", PRIVPATH)=="D" )
lSumiraj := .f.

O_KONTO
O_ANAL
O_FIN_PRIPR

GO TOP

_idvn := field->idvn 

cIdfirma := idfirma
cBrdok := brnal

IF DABLAGAS

	cKontoBlag := PADR(IzFMKINI("BLAGAJNA","Konto","202000",PRIVPATH),7)
  
	SET ORDER TO TAG "2"
  	SEEK cidfirma + _idvn + cBrDok + cKontoBlag
  	IF !FOUND() .or. Pitanje(,"Postoji knjizenje na kontu blagajne! Regenerisati knjizenje? (D/N)","N")=="D"
    	IF FOUND()
      		DO WHILE !EOF() .and. cidfirma+_idvn+cBrDok+cKontoBlag == idFirma+IdVN+BrNal+IdKonto
        		SKIP 1; nRec:=RECNO(); SKIP -1
        		MY_DELETE
       		 	GO (nRec)
      		ENDDO
   	 	ENDIF
    
    	SET ORDER TO TAG "1"
    	GO TOP
    	lEOF:=.f.
    	DO WHILE !EOF() .and. !lEOF .and. cIdfirma + _idvn + cBrDok == idFirma + IdVN + BrNal
        	SKIP 1
        	lEOF:=EOF()
        	nRec:=RECNO()
        	SKIP -1
       
        	_rec := dbf_get_rec()
        	APPEND BLANK

        	// promijeni konto i predznak, te nuliraj partnera, rj, funk i fond
        	_rec["idkonto"]    := cKontoBlag
        	_rec["id_partner"] := SPACE(LEN( _rec["idpartner"]))
        	_rec["d_p"]        := IIF( _rec["d_p"] =="1", "2", "1")

        	if (gRJ == "D")
          		_rec["idrj"] := SPACE(LEN(_rec["idrj"]))
       		endif

        	if gTroskovi=="D"
          		_rec["funk"] := SPACE(LEN( _rec["funk"]))
          		_rec["fond"] := SPACE(LEN( _rec["fond"]))
       	 	endif
     
        	dbf_update_rec(_rec, .t.) 
        	GO (nRec)

    	ENDDO
  	ENDIF
  	SET ORDER TO TAG "1"
  	go top
ENDIF

cDinDem := "1"

Box(, 3, 60 )

	@ m_x+1,m_y+2 SAY ValDomaca() + "/" + ValPomocna() + " blagajnicki izvjestaj (1/2):" GET cDinDem

 	read

 	if cDinDem == "1"
   		cIdKonto := fetch_metric("fin_blagajna_def_konto_km", NIL, PADR( "2050", 7 ))
   		pici := FormPicL("9," + gPicBHD, 12)
 	else
   		cIdKonto := fetch_metric("fin_blagajna_def_konto_dem", NIL, PADR( "2020", 7 ))
 	endif

 	IF DABLAGAS
   		cIdKonto := cKontoBlag
 	ENDIF

 	dDatdok := datdok

 	@ m_x+2,m_Y+2 SAY "Datum:" GET dDatDok
 	@ m_x+3,m_Y+2 SAY "Konto blagajne:" GET cIdKonto PICT "@S7" VALID P_Konto( @cIdKonto )

 	read

BoxC()

if LastKey() == K_ESC
	return
endif

// snimi parametre
if cDinDem == "1"
   	set_metric("fin_blagajna_def_konto_km", NIL, cIdKonto )
else
   	set_metric("fin_blagajna_def_konto_dem", NIL, cIdKonto )
endif

select fin_pripr

START PRINT CRET
?
F12CPI
?? space(12)

if cDinDem=="1"
	?? "("+ValDomaca()+")"
else
  	?? "DEVIZNI ("+ValPomocna()+")"
endif

?? hb_Utf8ToStr(" BLAGAJNIČKI IZVJESTAJ OD "), dDatDok
?? space(8), "Broj:", cBrDok
?
?

nRbr:=0
nDug:=nPot:=0
nCol1:=45

? "    ------- ------------------------- --------------------- -------------- ---------------"
? "    * Redni*       Temeljnica        *        OPIS         *    ULAZ      *    IZLAZ     *"
? "    * broj *                         *                     *              *              *"
? "    *      *            *            *                     *              *              *"
? m:="    ------- ------------ ------------ --------------------- -------------- ---------------"
do while !eof()
  IF PROW() > 49 + gPStranica
    PZagBlag(nDug, nPot, m, cBrDok, pici, cDinDem, dDatDok)
  ENDIF

  IF lSumiraj
    nPomD:=nPomP:=0
    cBrDok2:=brdok
    cOpis:=""
    nStavki:=0
    DO WHILE !EOF() .and. brdok==cBrDok2
      if idkonto<>cidkonto
        skip 1
        loop
      else
        if nPomD<>0 .and. d_p=="2" .or. nPomP<>0 .and. d_p=="1"
          // ovo se moze desiti ako su iste temeljnice za naplatu i isplatu
          exit
        endif
      endif
      if cDinDem=="1"  

        if d_p=="1"
          nPomD+=iznosbhd
        else
          nPomP+=iznosbhd
        endif

      else

        if d_p=="1"
           nPomD+=iznosdem
        else
            nPomP+=iznosdem
        endif

      endif
      IF !EMPTY(opis)
        cOpis += opis
        ++nStavki
      ENDIF
      skip 1
    ENDDO
    IF PROW() > 49 + gPStranica - nStavki
      PZagBlag(nDug, nPot, m, cBrDok, pici, cDinDem, dDatDok)
    ENDIF
    ? "    *",str(++nRbr,3)+". *"
    if nPomD<>0
      ?? " "+cbrdok2+" *"+space(12)+"*"
    else
      ?? space(12)+"* "+padr(cbrdok2,11)+"*"
    endif

    nCOpis:=pcol()+1
    ?? " "+PADR(cOpis, 20)
    nCol1:=pcol()+1

    @ prow(),pcol()+1 SAY PADL(TRANSFORM(nPomD,pici),14)
    @ prow(),pcol()+1 SAY PADL(TRANSFORM(nPomP,pici),14)
    nDug += nPomD
    nPot += nPomP
    OstatakOpisa(cOpis,nCOpis)

  ELSE

    if idkonto<>cidkonto
      skip
      loop
    endif

    ? "    *",str(++nRbr, 3) + ". *"
    if d_p=="1"
      ?? " "+brdok+" *"+space(12)+"*"
    else
      ?? space(12)+"* "+padr(brdok,11)+"*"
    endif

    nCOpis:=pcol()+1
    ?? " "+PADR(cOpis:=ALLTRIM(opis),20)
    nCol1:=pcol()+1

    if cdindem=="1" 

      if d_p=="1"
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosbhd,pici), 14)
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici), 14)
        nDug+=iznosbhd
      else
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici), 14)
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosbhd,pici), 14)
        nPot+=iznosbhd
      endif

    else

      if d_p=="1"
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosdem,pici), 14)
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici), 14)
        nDug+=iznosdem
      else
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici), 14)
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosdem,pici), 14)
        nPot+=iznosdem
      endif

    endif
    OstatakOpisa(cOpis,nCOpis)
    skip 1
  ENDIF
enddo
select anal

//TAG 1 - "IdFirma+IdKonto+dtos(DatNal)", "ANAL"

hseek cIdfirma+cIdkonto
nDugSt:=nPotSt:=0
do while !eof() .and. idfirma==cIdfirma .and. idkonto==cIdkonto .and. datnal<=dDatDok

   if cDindem=="1"
     nDugSt+=dugbhd
     nPotSt+=potbhd
   else
     nDugSt+=dugdem
     nPotSt+=potdem
   endif
   
   skip
enddo
? m
@ prow()+1,10 SAY "Promet blagajne:"
@ prow(), ncol1 SAY PADL(TRANSFORM(ndug,pici), 14)
@ prow(), pcol()+1 SAY PADL(TRANSFORM(npot,pici), 14)
? m
@ prow()+1, 10 SAY "Saldo od "+dtoc(ddatdok-1)+":"
@ prow(), ncol1 SAY PADL(TRANSFORM(ndugst-npotst,pici), 14)
? m
@ prow()+1, 10 SAY "Ukupan primitak:"
@ prow(), ncol1 SAY PADL(TRANSFORM(ndugst-npotst+ndug,pici), 14)

@ prow()+1, 10 SAY "Izdatak:"
@ prow(), ncol1 SAY PADL(TRANSFORM(npot,pici), 14)

? m
@ prow()+1,10 SAY "Saldo na dan:"
@ prow(),ncol1 SAY PADL(TRANSFORM(ndugst-npotst+ndug-npot,pici),14)
? m
@ prow()+1,10 SAY "Slovima:"
@ prow(),pcol()+1 SAY Slovima(round(ndugst-npotst+ndug-npot,2),iif(cdindem=="1",ValDomaca(),ValPomocna()))
? m
?
?
@ prow()+1, 25 SAY "  ___________________            ______________________"
@ prow()+1, 25 SAY "     Blagajna                           Kontrola       "
FF
end print
closeret


function PZagBlag(nDug,nPot,m,cBrDok,pici,cDinDem,dDatDok)

// zavrsetak prethodne stranice:
// -----------------------------
? m
@ prow()+1,10 SAY "Promet blagajne, prenos:"
@ prow(), ncol1 SAY PADL(TRANSFORM(ndug,pici),14)
@ prow(), pcol()+1 SAY PADL(TRANSFORM(npot,pici),14)
? m
FF
// sljedeca stranica:
// ------------------
F12CPI
?? space(12)
if cDinDem=="1"
      ?? "("+ValDomaca()+")"
else
      ?? "DEVIZNI ("+ValPomocna()+")"
endif
?? " BLAGAJNICKI IZVJESTAJ OD ", dDatDok
?? space(8),"Broj:",cBrDok
?
?
? "    ------- ------------------------- --------------------- -------------- ---------------"
? "    * Redni*       Temeljnica        *        OPIS         *    ULAZ      *    IZLAZ     *"
? "    * broj *                         *                     *              *              *"
? "    *      *            *            *                     *              *              *"
? m
@ prow()+1,10 SAY "Promet blagajne, donos:"
@ prow(),ncol1 SAY PADL(TRANSFORM(ndug,pici),14)
@ prow(),pcol()+1 SAY PADL(TRANSFORM(npot,pici),14)
? m

return




// stampa blagajne na osnovu azuriranog dokumenta
function blag_azur()
local nCol1
local nRbr:=0
local nCOpis:=0
local cOpis:=""
local lSumiraj
private pici:=FormPicL("9," + gPicDEM, 12)
private cLine := ""

//lSumiraj := ( IzFMKINI("BLAGAJNA","DBISumirajPoBrojuVeze","N",PRIVPATH)=="D" )
lSumiraj := .f.

O_PARTN
O_KONTO
O_ANAL
O_SUBAN

cDinDem:="1"

Box(, 4, 60)
    @ m_x+1,m_y+2 SAY ValDomaca()+"/"+ValPomocna()+" blagajnicki izvjestaj (1/2):" GET cDinDem
    read
    if cDinDem=="1"
        cIdKonto:=padr("2020",7)
        pici:=FormPicL("9,"+gPicBHD,12)
    else
        cIdKonto:=padr("2050",7)
    endif

    dDatdok:=datdok
    cIdFirma := gFirma
    cTipDok := SPACE(2)
    cBrDok := SPACE(8)
    
    @ m_x+2,m_Y+2 SAY "Dokument:" GET cIdFirma VALID !EMPTY(cIdFirma)
    @ m_x+2,m_Y+15 SAY "-" GET cTipDok VALID !EMPTY(cTipDok)
    @ m_x+2,m_Y+20 SAY "-" GET cBrDok VALID !EMPTY(cBrDok)
    
    read

    // precesljaj dokument radi konta i datuma, pa ponudi
    dat_kto_blag(@dDatDok, @cIdKonto, cIdFirma, cTipDok, cBrDok)
    
    @ m_x+3,m_Y+2 SAY "Datum:" GET dDatDok
    @ m_x+4,m_Y+2 SAY "Konto blagajne:" GET cIdKonto valid P_Konto(@cIdKonto)
    read
BoxC()

if LastKey()==K_ESC
    return
endif

SELECT SUBAN
set order to tag "4"
hseek cIdFirma+cTipDok+cBrDok

// nisam pronasao dokument
if !FOUND()
    MsgBeep("Dokument " + cIdFirma + "-" + cTipDok + "-" + cBrDok + " ne postoji!")
    return
endif

start print cret


nRbr:=0
nDug:=0
nPot:=0
nCol1:=20

// setuj liniju reporta
set_line(@cLine)

// stampaj zaglavlje reporta
st_bl_zagl(cLine, cDinDem, cIdFirma, cTipDok, cBrDok, dDatDok)

do while !eof() .and. field->idfirma == cIdFirma .and. field->idvn == cTipDok .and. field->brnal == cBrDok

    IF PROW() > 49+gPStranica
            PZagBlag(nDug,nPot,cLine,cBrDok,pici,cDinDem,dDatDok)
    ENDIF
    IF lSumiraj
            nPomD:=nPomP:=0
            cBrDok2:=brdok
            cOpis:=""
            nStavki:=0
            DO WHILE !EOF() .and. brdok==cBrDok2
                if idkonto<>cIdKonto
                    skip 1
                    loop
                else
                    if nPomD<>0 .and. d_p=="2" .or. nPomP<>0 .and. d_p=="1"
                        // ovo se moze desiti ako su iste 
                    // temeljnice za naplatu i isplatu
                        exit
                    endif
                endif
                if cDinDem=="1"  // dinari !!!!
                    if d_p=="1"
                        nPomD+=iznosbhd
                    else
                        nPomP+=iznosbhd
                    endif
                else
                    if d_p=="1"
                        nPomD+=iznosdem
                    else
                        nPomP+=iznosdem
                    endif
                endif
                IF !EMPTY(opis)
                    cOpis += opis
                    ++nStavki
                ENDIF
                skip 1
            ENDDO
            IF PROW() > 49+gPStranica-nStavki
                PZagBlag(nDug,nPot,m,cBrDok,pici,cDinDem,dDatDok)
            ENDIF
        
            ? "    *", str(++nRbr, 3) + ". *"
            
        if nPomD<>0
                ?? " " + cBrDok2 + " *" + space(12) + "*"
            else
                ?? space(12) + "* " + padr(cBrDok2, 11) + "*"
            endif
        
            nCOpis:=pcol()+1
            ?? " "+PADR(cOpis, 20)
            nCol1:=pcol()+1
            @ prow(),pcol()+1 SAY PADL(TRANSFORM(nPomD,pici),14)
            @ prow(),pcol()+1 SAY PADL(TRANSFORM(nPomP,pici),14)
            nDug += nPomD
            nPot += nPomP
            OstatakOpisa(cOpis,nCOpis)
    ELSE

        // lSumiraj := .f.

        if idkonto <> cIdkonto
            skip
            loop
        endif
        ? "    *", str(++nRbr,3)+". *"
        if d_p=="1"
            ?? " "+brdok+" *"+space(12)+"*"
        else
            ?? space(12)+"* "+padr(brdok,11)+"*"
        endif
        nCOpis:=pcol()+1
        ?? " "+PADR(cOpis:=ALLTRIM(opis),20)
        nCol1:=pcol()+1
        if cDinDem=="1"  // dinari !!!!
        if d_p=="1"
                @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosbhd,pici),14)
                @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
                nDug+=iznosbhd
            else
                @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
                @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosbhd,pici),14)
                nPot+=iznosbhd
            endif
    else
        if d_p=="1"
                @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosdem,pici),14)
                @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
                nDug+=iznosdem
            else
                @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
                @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosdem,pici),14)
                nPot+=iznosdem
            endif
    endif
        OstatakOpisa(cOpis,nCOpis)
        skip 1
    ENDIF
enddo

// procesljaj staro stanje
select anal
hseek cIdfirma+cIdkonto

nDugSt:=0
nPotSt:=0

do while !eof() .and. idfirma==cIdfirma .and. idkonto==cIdkonto .and. datnal<dDatDok
    if cDinDem=="1"
            nDugSt+=dugbhd
            nPotSt+=potbhd
    else
            nDugSt+=dugdem
            nPotSt+=potdem
    endif
    skip
enddo

? cLine
@ prow()+1,10 SAY "Promet blagajne:"
@ prow(),ncol1 SAY PADL(TRANSFORM(nDug, pici),14)
@ prow(),pcol()+1 SAY PADL(TRANSFORM(nPot, pici),14)
? cLine
@ prow()+1,10 SAY "Saldo od "+dtoc(dDatDok-1)+":"
@ prow(),ncol1 SAY PADL(TRANSFORM(nDugst-nPotst, pici),14)
? cLine
@ prow()+1,10 SAY "Ukupan primitak:"
@ prow(),ncol1 SAY PADL(TRANSFORM(nDugSt-nPotSt+nDug, pici),14)
@ prow()+1,10 SAY "Izdatak:"
@ prow(),ncol1 SAY PADL(TRANSFORM(nPot, pici), 14)
? cLine
@ prow()+1,10 SAY "Saldo na dan:"
@ prow(),ncol1 SAY PADL(TRANSFORM(nDugSt-nPotSt+nDug-nPot, pici),14)
? cLine
@ prow()+1,10 SAY "Slovima:"
@ prow(),pcol()+1 SAY Slovima(round(ndugst-npotst+ndug-npot, 2),iif(cdindem=="1", ValDomaca(), ValPomocna()))
? cLine
?
?

@ prow()+1,25 SAY "  ___________________            ______________________"
@ prow()+1,25 SAY "     Blagajna                           Kontrola       "

FF

end print

closeret
return


// vrati konto naloga
static function dat_kto_blag(dDatum, cKonto, cFirma, cIdVn, cBrNal)
local nLenKto
local cTmpKto
select suban
set order to tag "4"
hseek cFirma+cIdVn+cBrNal

// nisam pronasao dokument
if !FOUND()
    MsgBeep("Dokument " + cFirma + "-" + cIdVn + "-" + cBrNal + " ne postoji!")
    return
endif

do while !EOF() .and. suban->(idfirma + idvn + brnal) == cFirma + cIdVn + cBrNal
    nTmpKto := field->idkonto
    nLenKto := LEN(ALLTRIM(nTmpKto))
    if nLenKto > 4
        if LEFT(nTmpKto, 4) == "2020"
            cKonto := nTmpKto
            dDatum := field->datdok
            exit
        endif
    endif
    skip
enddo

return


// setovanje linije za izvjestaj
static function set_line(cLine)
local cRazmak := SPACE(1)
cLine := ""
cLine += SPACE(4)
cLine += REPLICATE("-", 7)
cLine += cRazmak
cLine += REPLICATE("-", 25)
cLine += cRazmak
cLine += REPLICATE("-", 21)
cLine += cRazmak
cLine += REPLICATE("-", 14)
cLine += cRazmak
cLine += REPLICATE("-", 15)

return


// stampa zaglavlja blagajne
function st_bl_zagl(cLine, cDinDem, cIdFirma, cTipDok, cBrDok, dDatDok )
?
F12CPI

?? space(12)

if cDinDem=="1"
    ?? "("+ValDomaca()+")"
else
    ?? "DEVIZNI ("+ValPomocna()+")"
endif

?? hb_Utf8ToStr(" BLAGAJNIČKI IZVJESTAJ OD "), dDatDok
?? space(8),"Broj:", cBrDok
? SPACE(20)
?? "na osnovu dokumenta: " + cIdFirma + "-" + cTipDok + "-" + cBrDok
?
?
? cLine
? "    * Redni*       Temeljnica        *        OPIS         *    ULAZ      *    IZLAZ     *"
? "    * broj *                         *                     *              *              *"
? "    *      *            *            *                     *              *              *"
? cLine

return
