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

static __par_len

// ------------------------------------------------------
// specifikacija dugovanja partnera po r.intervalima
// ------------------------------------------------------
function SpecDugPartnera()
local nCol1:=72
local cSvi:="N"
local _partner := fetch_metric( "fin_spec_po_dobav_partner", NIL, SPACE(6) )
private cIdPartner

cDokument:=SPACE(8)
picBHD:=FormPicL(gPicBHD,14)
picDEM:=FormPicL(gPicDEM,10)

IF gVar1=="0"
    m:="----------- ------------- -------------- -------------- ---------- ---------- ---------- -------------------------"
ELSE
    m:="----------- ------------- -------------- -------------- -------------------------"
ENDIF

m := "-------- -------- " + m

nStr:=0
fVeci:=.f.
cPrelomljeno:="N"

O_SUBAN
O_PARTN
O_KONTO

__par_len := LEN(partn->id)

cIdFirma:=gFirma
cIdkonto:=space(7)
cIdPartner:=PADR("", __par_len)
dNaDan:=DATE()
cOpcine:=SPACE(20)
cSaRokom:="D"
cValuta:="1"

nDoDana1 :=  8
nDoDana2 := 15
nDoDana3 := 30
nDoDana4 := 60

PICPIC:="9999999999.99"

Box(, 13, 60)
if gNW=="D"
        @ m_x+1,m_y+2 SAY "Firma "
    ?? gFirma,"-",gNFirma
else
    @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif

@ m_x+2,m_y+2 SAY "Konto:               " GET cIdkonto   pict "@!"  valid P_konto(@cIdkonto)
@ m_x+3,m_y+2 SAY "Izvjestaj se pravi na dan:" GET dNaDan
@ m_x+4,m_y+2 SAY "Interval 1: do (dana)" GET nDoDana1 PICT "999"
@ m_x+5,m_y+2 SAY "Interval 2: do (dana)" GET nDoDana2 PICT "999"
@ m_x+6,m_y+2 SAY "Interval 3: do (dana)" GET nDoDana3 PICT "999"
@ m_x+7,m_y+2 SAY "Interval 4: do (dana)" GET nDoDana4 PICT "999"
@ m_x+10,m_y+2 SAY "Prikaz iznosa (format)" GET PICPIC PICT "@!"
@ m_x+11,m_y+2 SAY "Uslov po opcini (prazno - nista)" GET cOpcine
@ m_x+12,m_y+2 SAY "Partner (prazno-svi):" GET _partner VALID EMPTY( _partner ) .or. P_Firma( @_partner )
@ m_x+13,m_y+2 SAY "Izvjestaj za (1)KM (2)EURO" GET cValuta VALID cValuta$"12"

read
ESC_BCR
BoxC()

set_metric( "fin_spec_po_dobav_partner", NIL, _partner )

if EMPTY(cIdPartner)
    cIdPartner:=""
endif

cSvi:=cIdPartner

// odredjivanje prirode zadanog konta (dug. ili pot.)
// --------------------------------------------------
select (F_TRFP2)
if !used()
    O_TRFP2
endif
HSEEK "99 "+LEFT(cIdKonto,1)
DO WHILE !EOF() .and. IDVD=="99" .and. TRIM(idkonto)!=LEFT(cIdKonto,LEN(TRIM(idkonto)))
    SKIP 1
ENDDO
IF IDVD=="99" .and. TRIM(idkonto)==LEFT(cIdKonto,LEN(TRIM(idkonto)))
    cDugPot:=D_P
ELSE
    cDugPot:="1"
        Box(,3,60)
        @ m_x+2,m_y+2 SAY "Konto "+cIdKonto+" duguje / potrazuje (1/2)" get cdugpot  VALID cdugpot$"12" PICT "9"
        READ
        Boxc()
ENDIF

fin_create_pom_table(, __par_len)  // kreiraj pomocnu bazu

gaZagFix:={4,5}

START PRINT RET

nUkDugBHD:=0
nUkPotBHD:=0

select suban
set order to tag "3"

seek cIdFirma+cIdKonto+cIdPartner

DO WHILESC !EOF() .and. idfirma==cIdfirma .AND. cIdKonto==IdKonto
        
    cIdPartner:=idpartner
    nUDug2:=0
    nUPot2:=0
    nUDug:=0
    nUPot:=0
        
    fPrviProlaz:=.t.
    
    DO WHILESC !EOF() .and. idfirma==cIdfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner

           
        cBrDok:=BrDok
        cOtvSt:=otvst
        nDug2:=0
        nPot2:=0
        nDug:=0
        nPot:=0
            
        aFaktura:={CTOD(""),CTOD(""),CTOD("")}
            
        DO WHILESC !EOF() .and. idfirma==cIdfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner .and. brdok==cBrDok
 
            if !EMPTY( _partner )
                if _partner <> idpartner
                    skip
                    loop
                endif
            endif
                    
            IF D_P=="1"
                nDug+=IznosBHD
                nDug2+=IznosDEM
            ELSE
                nPot+=IznosBHD
                nPot2+=IznosDEM
            ENDIF
                    
            IF D_P==cDugPot
                aFaktura[1]:=DATDOK
                aFaktura[2]:=DATVAL
            ENDIF
                    
            if aFaktura[3]<DatDok  // datum zadnje promjene
                aFaktura[3]:=DatDok
            endif

            SKIP 1
        ENDDO

        if round(nDug-nPot,2)==0
            // nista
        else
            fPrviProlaz:=.f.
            if cPrelomljeno=="D"
                if (nDug-nPot)>0
                    nDug:=nDug-nPot
                    nPot:=0
                else
                    nPot:=nPot-nDug
                    nDug:=0
                endif
                if (nDug2-nPot2)>0
                    nDug2:=nDug2-nPot2
                    nPot2:=0
                else
                    nPot2:=nPot2-nDug2
                    nDug2:=0
                endif
            endif
                    
            SELECT POM
            APPEND BLANK
                    
            Scatter()
            _idpartner := cIdPartner
            _datdok    := aFaktura[1]
            _datval    := aFaktura[2]
            _datzpr    := aFaktura[3]
            _brdok     := cBrDok
            _dug       := nDug
            _pot       := nPot
            _dug2      := nDug2
            _pot2      := nPot2
            _otvst     := IF(IF(EMPTY(_datval),_datdok>dNaDan,_datval>dNaDan)," ","1")
            Gather()
            SELECT SUBAN
        endif
    enddo // partner
    
    IF prow()>58+gPStranica
        FF
        ZaglDuznici()
    ENDIF
    
    if (!fVeci .and. idpartner=cSvi) .or. fVeci
    else
        exit
    endif

enddo

SELECT POM
INDEX ON IDPARTNER+OTVST+Rocnost()+DTOS(DATDOK)+DTOS(IIF(EMPTY(DATVAL),DATDOK,DATVAL))+BRDOK TAG "2"
SET ORDER TO TAG "2" 
GO TOP

nTUDug := nTUPot := nTUDug2 := nTUPot2 := 0
nTUkUVD := nTUkUVP := nTUkUVD2 := nTUkUVP2 := 0
nTUkVVD := nTUkVVP := nTUkVVD2 := nTUkVVP2 := 0

anInterUV:={ { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 1
             { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 2
             { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 3
             { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 4
             { {0,0} , {0,0} , {0,0} , {0,0} } }        // preko intervala 4

//  D,TD    P,TP   D2,TD2  P2,TP2
anInterVV:={ { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 1
             { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 2
             { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 3
             { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 4
             { {0,0} , {0,0} , {0,0} , {0,0} } }        // preko intervala 4

cLastIdPartner:=""
fPrviProlaz:=.t.

do while !EOF()

    cIdPartner := idpartner

    // a sada provjeri opcine
    // nadji partnera
    if !EMPTY(cOpcine)
        select partn
        hseek cIdPartner
        if AT(ALLTRIM(partn->idops), cOpcine)==0
            select pom
            skip
            loop
        endif
        select pom
    endif
    
    nUDug := nUPot := nUDug2 := nUPot2:=0
    nUkUVD := nUkUVP := nUkUVD2 := nUkUVP2 := 0
    nUkVVD := nUkVVP := nUkVVD2 := nUkVVP2 := 0
    
    FOR i:=1 TO LEN(anInterVV)
        FOR j:=1 TO LEN(anInterVV[i])
            anInterVV[i,j,1]:=0
        NEXT
    NEXT
          
    cFaza := otvst
    nFaza := RRocnost()

    do while !EOF() .and. cIdPartner == IdPartner
    		        
        if fPrviProlaz
            ZaglDuznici()
            fPrviProlaz:=.f.
        endif
            
        select pom
        
        IF cLastIdPartner!=cIdPartner .or. LEN(cLastIdPartner)<1
            Pljuc(cIdPartner)
            PPljuc( PADR( Ocitaj(F_PARTN,cIdPartner,"naz"), 25) )
            cLastIdPartner:=cIdPartner
        ENDIF
 
        if otvst <> " "
      	    nUkVVD  += Dug 
		    nUkVVP  += Pot
		    nUkVVD2 += Dug2
		    nUkVVP2 += Pot2
       	    anInterVV[nFaza,1,1] += dug
       	    anInterVV[nFaza,2,1] += pot
       	    anInterVV[nFaza,3,1] += dug2
       	    anInterVV[nFaza,4,1] += pot2
        endif
    	
        nUDug+=Dug
	    nUPot+=Pot
        nUDug2+=Dug2
	    nUPot2+=Pot2
    	
        skip 1
	
        //  znaci da treba
    	if cFaza != otvst .or. EOF() .or. cIdPartner != idpartner

      		if cFaza <> " "
        		anInterVV[nFaza,1,2] += anInterVV[nFaza,1,1]
         		anInterVV[nFaza,2,2] += anInterVV[nFaza,2,1]
         		anInterVV[nFaza,3,2] += anInterVV[nFaza,3,1]
         		anInterVV[nFaza,4,2] += anInterVV[nFaza,4,1]
       		    nTUkVVD  += nUkVVD 
			    nTUkVVP  += nUkVVP
        		nTUkVVD2 += nUkVVD2
			    nTUkVVP2 += nUkVVP2
      		endif

    	elseif nFaza != RRocnost()

      		if cFaza <> " "
        		anInterVV[nFaza,1,2] += anInterVV[nFaza,1,1]
        		anInterVV[nFaza,2,2] += anInterVV[nFaza,2,1]
        		anInterVV[nFaza,3,2] += anInterVV[nFaza,3,1]
        		anInterVV[nFaza,4,2] += anInterVV[nFaza,4,1]
      		endif

        endif
    
        cFaza := otvst
        nFaza := RRocnost()

    enddo
   
    SELECT POM

    if !fPrviProlaz  // bilo je stavki
        nIznosRok:=0
        nSaldo:=nUDug-nUPot
        nSldDem:=nUDug2-nUPot2
        FOR i:=1 TO LEN(anInterVV)
            if ( cValuta == "1" )
                nIznosRok += anInterVV[ i, 1, 1 ] - anInterVV[ i, 2, 1 ]
                nIznosStavke := nSaldo - nIznosRok
                PPljuc(TRANSFORM(nIznosStavke,PICPIC))
            else
                nIznosRok += anInterVV[ i, 3, 1 ] - anInterVV[ i, 4, 1 ]
                nIznosStavke:=nSldDem-nIznosRok
                PPljuc(TRANSFORM(nIznosStavke,PICPIC))
        
            endif
        NEXT
        if ( cValuta == "1" )
            PPljuc(TRANSFORM(nUkVVD-nUkVVP,PICPIC))
            PPljuc(TRANSFORM(nSaldo,PICPIC))
        else
            PPljuc(TRANSFORM(nUkVVD2-nUkVVP2,PICPIC))
            PPljuc(TRANSFORM(nSldDem,PICPIC))
        endif
        
        IF prow()>52+gPStranica
            FF
            ZaglDuznici()
            fPrviProlaz:=.f.
        ENDIF
        
    endif

    nTUDug += nUDug
    nTUDug2 += nUDug2
    nTUPot += nUPot
    nTUPot2 += nUPot2
    
    IF prow()>58+gPStranica
        FF
        ZaglDuznici(.t.)
    ENDIF

ENDDO

? "�" + REPL("�", __par_len) + "���������������������������������������������������������������������������������������������������������������������������Ĵ"

Pljuc( PADR( "UKUPNO" , LEN(POM->IDPARTNER+PADR(PARTN->naz, 25))+1 ) )

FOR i:=1 TO LEN(anInterVV)
    if ( cValuta == "1" )
        PPljuc(TRANSFORM(anInterVV[i,1,2]-anInterVV[i,2,2],PICPIC))
    else
        PPljuc(TRANSFORM(anInterVV[i,3,2]-anInterVV[i,4,2],PICPIC))
    endif
NEXT

if ( cValuta == "1" )
    PPljuc(TRANSFORM(nTUkVVD-nTUkVVP,PICPIC))
    PPljuc(TRANSFORM(nTUDug-nTUPot,PICPIC))
else
    PPljuc(TRANSFORM(nTUkVVD2-nTUkVVP2,PICPIC))
    PPljuc(TRANSFORM(nTUDug2-nTUPot2,PICPIC))
endif

? "�" + REPL("�", __par_len) + "�����������������������������������������������������������������������������������������������������������������������������"

FF
END PRINT

select (F_POM)
use

CLOSERET
return

/////////////////////
	










/////////////////////

/*! \fn ZaglDuznici(fStrana, lSvi)
 *  \brief Zaglavlje izvjestaja duznika
 *  \param fStrana
 *  \param lSvi
 */

function ZaglDuznici(fStrana, lSvi)

local nArr
nArr:=SELECT()
?
P_COND2

IF lSvi==NIL
    lSvi:=.f.
ENDIF

if fStrana==NIL
    fStrana:=.f.
endif

if nStr=0
  fStrana:=.t.
endif

?? "FIN.P:  Specifikacija Dugovanja partnera po rocnim intervalima "; ?? dNaDan

SELECT PARTN
HSEEK cIdFirma

? "FIRMA:",cIdFirma,"-",gNFirma

SELECT KONTO
HSEEK cIdKonto

? "KONTO  :",cIdKonto,naz
? "�" + REPL("�", __par_len) + "���������������������������������������������������������������������������������������������������������������������������Ŀ"
? "�" + REPL(" ", __par_len) + "�                         �                     V  A  N      V  A  L  U  T  E                                 �             �"
? "�" + PADR("SIFRA", __par_len) + "�     NAZIV  PARTNERA     �����������������������������������������������������������������������������������Ĵ  UKUPNO     �"
? "�" + PADR("PARTN.", __par_len) + "�                         �DO"+STR(nDoDana1,3)+" D.     �DO"+STR(nDoDana2,3)+" D.     �DO"+STR(nDoDana3,3)+" D.     �DO"+STR(nDoDana4,3)+" D.     �PR."+STR(nDoDana4,2)+" D.     � UKUPNO      �             �"
? "�" + REPL("�", __par_len) + "���������������������������������������������������������������������������������������������������������������������������Ĵ"

select (nArr)
return


