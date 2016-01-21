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


function SpecDPK()
local nCol1

picBHD:=FormPicL("9 "+gPicBHD,17)

cF:=cDD:="2" 
// format izvjestaja
cPG := "D"   
// prikazi grad partnera
cIdFirma:=gFirma
nIznos:=nIznos2:=0
cDP:="1"
qqKonto:=qqPartner:=SPACE(100)

O_PARTN

__par_len := LEN(partn->id)

Box("skpoi",10,70,.f.)
@ m_x+1,m_y+2 SAY "SPECIFIKACIJA PARTNERA NA KONTU"
if gNW=="D"
   @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif
@ m_x+4,m_y+2 SAY "Konto  " GET qqKonto PICTURE "@!S50"
@ m_x+5,m_y+2 SAY "Partner" GET qqPartner PICTURE "@!S50"
@ m_x+6,m_y+2 SAY "Duguje/Potrazuje (1/2) ?" GET cDP PICTURE "@!" VALID cDP $ "12"
@ m_x+7,m_y+2 SAY "IZNOS "+ValDomaca() GET nIznos  PICTURE '999999999999.99'
if gVar1<>"1"
 @ m_x+8,m_y+2 SAY "IZNOS "+ValPomocna() GET nIznos2 PICTURE '9999999999.99'
endif
@ m_x+9,m_y+2 SAY "Format izvjestaja A3/A4 (1/2) :" GET cF valid cF $ "12"
@ m_x+10,m_y+2 SAY "Prikazi grad partnera (D/N) :" GET cPG pict "@!" valid cPG $ "DN"
read
if cF=="2"
  IF gVar1=="0"
   @ m_x+10, m_y+40 SAY ALLTRIM(ValDomaca())+"/"+ALLTRIM(ValPomocna())+" (1/2):" GET cDD valid cDD $ "12"
   read
  ELSE
   cDD:="1"
  ENDIF
endif

do while .t.
READ; ESC_BCR
aUsl1:=Parsiraj(qqKonto,"IdKonto","C")
aUsl2:=Parsiraj(qqPartner,"IdPartner","C")
if aUsl1<>NIL .and. aUsl2<>NIL;  exit; endif
enddo

BoxC()

B:=0

cIdFirma:=left(cIdFirma,2)

if cF=="1"
   M:="----- " + REPLICATE("-", __par_len) + " ------------------------------------ ----------------------- ------------------ ----------------- ----------------- ----------------- ----------------- ----------------- ----------------- -----------------"
elseif cPG=="D"
   M:="---- " + REPLICATE("-", __par_len) + " ------------------------- ---------------- ----------------- ----------------- ----------------- -----------------"
else
   M:="---- " + REPLICATE("-", __par_len) + " ------------------------- ----------------- ----------------- ----------------- -----------------"
endif
O_SUBAN
select SUBAN
private cFilt1:="IdFirma=='"+cIdFirma+"'.and."+aUsl1+".and."+aUsl2
set filter to &cFilt1


go top
EOF CRET

nStr:=0
START PRINT CRET
do whileSC !eof()
      nSD1DEM:=nSP1DEM:=nSD1BHD:=nSP1BHD:=0

      cIdKonto:=IdKonto
      If prow()<>0; FF; ZaglDPK(); endif

      nUkDugBHD:=nUkPotBHD:=nUkDugDEM:=nUkPotDEM:=0
      do WHILESC !EOF() .AND. cIdKonto=IdKonto // konto

           cIdPartner:=IdPartner

           nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0
           DO WHILESC  !EOF() .AND. cIdKonto=IdKonto .and. cIdPartner==IdPartner
              IF D_P="1"
                 nDugBHD+=IznosBHD; nDugDEM+=IznosDEM
              ELSE
                 nPotBHD+=IznosBHD; nPotDEM+=IznosDEM
              ENDIF
              SKIP
           ENDDO  // partner

           nRazl:=nDugBHD-nPotBHD
           nRazl2:=nDugDEM-nPotDEM
           If cDP=="2"
             nRazl:=-nRazl; nRazl2:=-nRazl2
           endif

           IF (nIznos==0 .or. (nRazl > nIznos))  .and. (nIznos2==0 .or. (nRazl2 > nIznos2))
              
	      // ako je nRazl=0 uzeti sve partnere
              	IF prow()==0
	      		ZaglDPK()
		ENDIF
              
	      	IF prow()>60 + gPStranica
			FF
			ZaglDPK()
		ENDIF
              	
		@ prow()+1,0 SAY ++B PICTURE '9999'
              	@ prow(),5 SAY cIdPartner

              	SELECT PARTN
		HSEEK cIdPartner
              	
		@ prow(),pcol()+1 SAY PADR(naz, 25)
              	
		if cF=="1" // a3 format
                	
			@ prow(),pcol()+1 SAY PADR(naz2, 25) PICT 'XXXXXXXXXXXX'
                	@ prow(),pcol()+1 SAY PTT
			@ prow(),pcol()+1 SAY PADR(Mjesto, 16) PICT 'XXXXXXXXXXXXXXXX'
			
              	elseif cPG=="D"
                	
			@ prow(),pcol()+1 SAY PADR(Mjesto, 16) PICT 'XXXXXXXXXXXXXXXX'
              	endif
              
	      	nCol1 := pcol()
              	
		if cF=="1" .or. cDD="1"
               		@ prow(),pcol()+1 SAY nDugBHD PICTURE picBHD
               		@ prow(),pcol()+1 SAY nPotBHD PICTURE picBHD
              	endif
              if cF=="1" .or. cDD="2"
               @ prow(),pcol()+1 SAY nDugDEM PICTURE picbhd
               @ prow(),pcol()+1 SAY nPotDEM PICTURE picbhd
              endif
              nUkDugBHD+=nDugBHD
              nUkDugDEM+=nDugDEM
              nUkPotBHD+=nPotBHD
              nUkPotDEM+=nPotDEM

              nSDBHD:=nDugBHD-nPotBHD
              nSDDEM:=nDugDEM-nPotDEM

              IF nSDBHD>=0
                 nSPBHD:=0; nSPDEM:=0
              ELSE
                 nSPBHD:=-nSDBHD; nSPDEM:=-nSDDEM
                 nSDBHD:=nSDDEM:=0
              ENDIF

              if cF=="1" .or. cDD="1"
               @ prow(),pcol()+1 SAY nSDBHD PICTURE picBHD
               @ prow(),pcol()+1 SAY nSPBHD PICTURE picBHD
              endif
              if cF=="1" .or. cDD="2"
               @ prow(),pcol()+1 say nSDDEM PICTURE picbhd
               @ prow(),pcol()+1 say nSPDEM PICTURE picbhd
              endif

              nSD1DEM+=nSDDEM; nSP1DEM+=nSPDEM
              nSD1BHD+=nSDBHD; nSP1BHD+=nSPBHD
              SELECT SUBAN

           ENDIF


      ENDDO // konto

      IF prow()>60+gPStranica; FF; ZaglDPK(); ENDIF
      ?  M
      ? "UKUPNO ZA KONTO:"
     @ prow(),nCol1 SAY ""
     if cF=="1" .or. cDD=="1"
      @ prow(),pcol()+1      SAY nUkDugBHD PICTURE picBHD
      @ prow(),pcol()+1 SAY nUkPotBHD PICTURE picBHD
     endif
     if cF=="1" .or. cDD=="2"
      @ prow(),pcol()+1 SAY nUkDugDEM PICTURE picbhd
      @ prow(),pcol()+1 SAY nUkPotDEM PICTURE picbhd
     endif

     nCol2:=pcol()

     if cF=="1" .or. cDD="1"
      @ prow(),pcol()+1 SAY nSD1BHD PICTURE picBHD // dug bhd ukupno
      @ prow(),pcol()+1 SAY nSP1BHD PICTURE picBHD // pot bhd ukupno
     endif

     if cF=="1" .or. cDD="2"
      @ prow(),pcol()+1 SAY nSD1DEM PICTURE picbhd // dug dem ukupno
      @ prow(),pcol()+1 SAY nSP1DEM PICTURE picbhd // pot dem ukupno
     endif
     ? M
     @ prow()+1,nCol2 SAY ""

     if cF=="1" .or. cDD="1"
      nSaldo:=nUkDugBHD-nUkPotBHD
      @ prow(),pcol()+1 SAY iif( nSaldo>=0,nSaldo,0) PICTURE picBHD // dug bhd
      nSaldo:=nUkPotBHD-nUkDugBHD
      @ prow(),pcol()+1 SAY iif( nSaldo>=0,nSaldo,0) PICTURE picBHD // pot bhd
     endif

     if cF=="1" .or. cDD="2"
      nSaldo:=nUkDugDEM-nUkPotDEM
      @ prow(),pcol()+1 SAY iif( nSaldo>=0,nSaldo,0) PICTURE picbhd // dug dem
      nSaldo:=nUkPotDEM-nUkDugDEM
      @ prow(),pcol()+1 SAY iif( nSaldo>=0,nSaldo,0) PICTURE picbhd // pot dem
     endif
     ? M


enddo // eof()

FF
END PRINT

closeret
return




/*! \fn ZaglDPK()
 *  \brief Zaglavlje specifikacije partnera po kontu
 */

function ZaglDPK()
?
P_COND
?? "FIN.P: SPECIFIKACIJA "
@ prow(),pcol()+2 SAY ""
if !empty(qqPartner)
  ?? " PARTNERA:",trim(qqpartner),"  "
else
  ?? " SVIH PARTNERA  "
endif
if nIznos<>0
  if cDP=="1"
    ?? "KOJI DUGUJU PREKO",nIznos,ALLTRIM(ValDomaca())
  else
    ?? "KOJI POTRA�UJU PREKO",nIznos,ALLTRIM(ValDomaca())
  endif
elseif nIznos2<>0
  if cDP=="1"
    ?? "KOJI DUGUJU PREKO",nIznos2,ALLTRIM(ValPomocna())
  else
    ?? "KOJI POTRA�UJU PREKO",nIznos2,ALLTRIM(ValPomocna())
  endif
endif
?? "  NA DAN :",DATE()
if cF=="1"
  @ prow(),200 SAY "Str:"+str(++nStr,3)
else
  @ prow(),100 SAY "Str:"+str(++nStr,3)
  if cDD=="1"
       @ prow()+1,4 SAY "*** OBRA�UN ZA "+ValDomaca()+"****"
  else
       @ prow()+1,4 SAY "*** OBRA�UN ZA "+ValPomocna()+"****"
  endif
endif
@ prow()+1,0 SAY " FIRMA:"
@ prow(),pcol()+2 SAY cIdFirma
SELECT PARTN; HSEEK cIdFirma
@ prow(),pcol()+1 SAY ALLTRIM(PADR(naz, 25)); @ prow(),pcol()+1 SAY naz2

@ prow(),pcol()+2 SAY "KONTO:"; @ prow(),pcol()+2 SAY cIdKonto
if cF=="1"
 ? "----- " + REPLICATE("-", __par_len) + " ------------------------------------ ----- ----------------- ----------------------------------------------------------------------- -----------------------------------------------------------------------"
 ? "*RED.*" + PADC("�IFRA", __par_len) + "*     NAZIV POSLOVNOG PARTNERA      * PTT *      MJESTO     *       K  U  M  U  L  A  T  I  V  N  I       P  R  O  M  E  T           *                 S      A      L      D       O                       *"
 ? "      " + REPL(" ", __par_len) + "                                                              ----------------------------------------------------------------------- -----------------------------------------------------------------------"
 ? "*BROJ*" + REPLICATE(" ", __par_len) + "*                                   * BROJ*                 *   DUGUJE   "+ValDomaca()+"  *  POTRA�UJE "+ValDomaca()+" *   DUGUJE  "+ValPomocna()+"  *   POTRA�. "+ValPomocna()+"  *    DUGUJE "+ValDomaca()+"  *  POTRA�UJE "+ValDomaca()+" *   DUGUJE  "+ValPomocna()+"  *   POTRA�."+ValPomocna()+"  *"
 ? m
elseif cPG=="D"
 ? "----- " + REPLICATE("-", __par_len) + " ------------------------ ---------------- ----------------------------------- -----------------------------------"
 ? "*RED.*" + PADC("�IFRA", __par_len) + "*     NAZIV POSLOVNOG    *     MJESTO     *         KUMULATIVNI  PROMET       *               SALDO              *"
 ? "                                                       ----------------------------------- -----------------------------------"
 ? "*BROJ*" + REPLICATE(" ", __par_len)  + "*     PARTNERA           *                *    DUGUJE       *   POTRA�UJE     *    DUGUJE       *   POTRA�UJE    *"
 ? m
else
 ? "----- " + REPLICATE("-", __par_len) + " ------------------------ ----------------------------------- -----------------------------------"
 ? "*RED.*" + PADC("SIFRA", __par_len) + "*      NAZIV POSLOVNOG    *         KUMULATIVNI  PROMET       *               SALDO              *"
 ? "      " + REPL(" ", __par_len)+ "                        ----------------------------------- -----------------------------------"
 ? "*BROJ*" + REPLICATE(" ", __par_len) + "*      PARTNERA           *    DUGUJE       *   POTRA�UJE     *    DUGUJE       *   POTRA�UJE    *"
 ? m
endif


SELECT SUBAN
RETURN



/*! \fn SpecBrDan()
 *  \brief Otvorene stavke preko odredjenog broja dana
 */

function SpecBrDan()

local nCol1:=0
picBHD:=FormPicL("9 "+gPicBHD,16)
picDEM:=FormPicL("9 "+gPicDEM,16)



cIdFirma:=gFirma; nIznosBHD:=0; nDana:=30; cIdKonto:=space(7)

O_KONTO
O_PARTN
dDatumOd:=ctod("")
dDatum:=date()
cUkupnoPartner:="D"
cPojed:="D"
cD_P:="1"
__par_len := LEN( partn->id )
qqBrDok:=Space(40)

M:="----- " + REPLICATE("-", __par_len ) + " ----------------------------------- ------ ---------------- -------- -------- --------- -----------------"
if gVar1=="0"
  M+=" ----------------"
endif


// Markeri otvorenih stavki
// D - uzeti u obzir markere
// N - izvjestaj saldirati bez obzira na markere, sabirajuci prema broju veze
cMarkeri:="N"
if IzFmkIni("FIN","Ostav_Markeri","N",KUMPATH)=="D"
  cMarkeri:="D"
endif

// uzeti u obzir datum valutiranja
private cObzirDatVal:="D"
if IzFmkIni("FIN","Ostav_DatVal","D",KUMPATH)=="N"
  cObzirDatVal:="N"
endif


Box("skpoi",14,70,.f.)
@ m_x+1,m_y+2 SAY "OTVORENE STAVKE PREKO/DO ODREDJENOG BROJA DANA"
if gNW=="D"
   @ m_x+3,m_y+2 SAY "Firma "
   ?? gFirma,"-",gNFirma
else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif
private cViseManje:=">"
@ m_x+4,m_y+2 SAY "KONTO  " GET cIdKonto valid P_KontoFin(@cIdKonto)
@ m_x+5,m_y+2 SAY "Broj dana ?" GET cViseManje valid cViseManje$"><"
@ m_x+5,col()+2 GET nDana PICTURE "9999"

@ m_x+6,m_y+2 SAY "obracun od " GET dDatumOd
@ m_x+6,col()+2 SAY  "do datuma:" GET dDatum
@ m_x+8,m_y+2 SAY "duguje/potrazuje (1/2):" GET cD_P
@ m_x+9,m_y+2 SAY "Uzeti u obzir datum valutiranja :" GET cObzirDatVal pict "@!" valid cObzirDatVal $ "DN" when {|| cObzirDatVal:=iif(cViseManje=">","D","N") , .t. }
@ m_x+10,m_y+2 SAY "Uzeti u obzir markere           :" GET cMarkeri     pict "@!" valid cObzirDatVal $ "DN"

@ m_x+12,m_y+2 SAY "prikaz pojedinacnog racuna:" GET cPojed valid cPojed$"DN" pict "@!"
@ m_x+13,m_y+2 SAY "prikaz ukupno za partnera :" GET cUkupnoPartner valid cUkupnoPartner $"DN" pict "@!"
@ m_x+14,m_y+2 SAY "Uslov za broj veze (prazno-svi)" GET qqBrDok pict "@S20"
READ
ESC_BCR

BoxC()

B:=0

cIdFirma:=left(cIdFirma,2)

nStr:=0

IF IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
  O_VRSTEP
ENDIF

O_SUBAN ; set order to tag "3"
//"IdFirma+IdKonto+IdPartner+BrDok+dtos(DatDok)"
hseek cIdFirma+cIdKonto

EOF CRET

START PRINT CRET

cIdKonto:=IdKonto

if prow()<>0
	FF
	ZaglSpBrDana()
endif

if !empty(qqBrDok)
	aUslBrDok := {}
	aUslBrDok := TOKuNIZ(ALLTRIM(qqBrDok), ";")
endif


KDIN:=KDEM:=0   // ukupno za konto BHD,DEM
do whileSC !eof() .and. cIdKonto==IdKonto

  cIdPartner:=Idpartner
  nDinP:=nDemP:=0
  do whileSC !eof() .and. cIdKonto==IdKonto .and. idpartner==cidpartner

     dDatDok:=ctod("")
     cBrdok:=field->brdok
     
     if !empty(qqBrDok) .and. len(aUslBrDok) <> 0
     	lFound := .f.
     	for i:=1 to len(aUslBrDok)
		nOdsjeci := len(aUslBrDok[i,1])
		if right(ALLTRIM(cBrdok), nOdsjeci) == aUslBrDok[i,1]
			lFound := .t.
			exit
		endif
     	next
     	if !lFound
     		skip
		loop
     	endif
     endif

     
     nDin:=nDEM:=0
     do while !eof() .and. idkonto==cidkonto .and. idpartner==cidpartner .and. ;
                           brdok==cBrdok

        IF (cMarkeri=="N" .or. OtvSt=" ")

           if  DatDok<=dDatum  .and. ;// stavke samo do zadanog datuma !!
               (empty(dDatumOd) .or. DatDok>=dDatumOd)
                  if cD_P=="1" //kupci
                    if d_P=="1"
                     nDin+=IznosBHD  ; nDEM+=IznosDEM
                    else
                     nDin-=IznosBHD  ; nDEM-=IznosDEM
                    endif
                  else  // dobalja�i
                     if d_P=="2"
                      nDin+=IznosBHD  ; nDEM+=IznosDEM
                     else
                      nDin-=IznosBHD  ; nDEM-=IznosDEM
                     endif
                  endif

          endif

          if (cD_P=="1" .and. D_P=="1"  .and. iznosbhd>0) .or. ;
             (cD_P=="2" .and. D_P=="2"  .and. iznosbhd>0)
           // dDatDok:=datdok
           if cObzirDatVal=="D"
              // uzima se u obzir datum valutiranja
              dDatDok:=IIF(EMPTY(DATVAL),DATDOK,DATVAL)
           else
              dDatDok:=DatDok
           endif

          endif

        endif // otvst =" "

        skip
      enddo

      IF !empty(dDatDok) .and. iif(cViseManje=">",dDatum-dDatDok>nDana, (dDatum-dDatDok>0 .and. dDatum-dDatDok<=nDana) ) .and. ;
         abs(round(nDin,4))>0

         KDIN+=nDin; KDEM+=nDEM
         nDINP+=nDin; nDEMP+=nDEM
         if cPojed=="D"
            
	    IF prow()==0
	    	ZaglSpBrDana()
	    ENDIF
            IF prow()>60+gPStranica
	    	FF
		ZaglSpBrDana()
	    ENDIF

            @ prow()+1,1 SAY ++B PICTURE '9999'
            @ prow(),pcol()+1 SAY cIdPartner
            SELECT PARTN
	    HSEEK cIdPartner
            @ prow(),pcol()+1 SAY PADR(naz, 25)
	    @ prow(),pcol()+1 SAY naz2 PICTURE 'XXXXXXXXXX'
            @ prow(),pcol()+1 SAY PTT
	    @ prow(),pcol()+1 SAY Mjesto
            
	    SELECT SUBAN

            @ prow(),pcol()+1 SAY cBrDok
            @ prow(),pcol()+1 SAY dDatDok
            @ prow(),pcol()+1 SAY k1+"-"+k2+"-"+k3iz256(k3)+k4
            nCol1:=pcol()+1
            @ prow(),pcol()+1 SAY nDin PICTURE picBHD
            if gVar1="0"
             @ prow(),pcol()+1 SAY nDEM PICTURE picDEM
            endif
         endif // cpojed=="D"

      ENDIF  //dana

  enddo // partner

  if cUkupnoPartner=="D"  .and. abs(round(nDinP,4))>0

     if cpojed=="D"
        ? m
     endif

     IF prow()==0; ZaglSpBrDana(); ENDIF
     IF prow()>60+gPStranica; FF; ZaglSpBrDana(); ENDIF

     if cPojed=="N"
       @ prow()+1,1 SAY ++B PICTURE '9999'
     else
       @ prow()+1,1 SAY space(4)
     endif
     @ prow(),pcol()+1 SAY cIdPartner
     SELECT PARTN
     HSEEK cIdPartner
     @ prow(),pcol()+1 SAY PADR(naz, 25)
     @ prow(),pcol()+1 SAY naz2 PICT 'XXXXXXXXXX'
     @ prow(),pcol()+1 SAY PTT
     @ prow(),pcol()+1 SAY Mjesto
     SELECT SUBAN

     @ prow(),pcol()+1 SAY space(len(cBrDok))
     @ prow(),pcol()+1 SAY space(8)  //dDatDok
     @ prow(),pcol()+1 SAY k1+"-"+k2+"-"+k3iz256(k3)+k4
     nCol1:=pcol()+1
     @ prow(),pcol()+1 SAY nDinP PICTURE picBHD
     if gVar1="0"
      @ prow(),pcol()+1 SAY nDEMP PICTURE picDEM
     endif

     if cpojed=="D"
        ? m
     endif
  endif

ENDDO  // konto
IF prow()>60+gPStranica; FF; ZaglSpBrDana(); ENDIF
? M
? "UKUPNO ZA KONTO:"
@ prow(),nCol1    SAY KDIN PICTURE picBHD
if gVar1="0"
  @ prow(),pcol()+1 SAY KDEM PICTURE picDEM
endif
? M


FF
END PRINT

closeret
return



/*! \fn ZaglSpBrDana()
 *  \brief Zaglavlje za otvorene stavke preko odredjenog broja dana
 */
 
function ZaglSpBrDana()
local cPom
?
P_COND
?? "FIN: SPECIFIKACIJA PARTNERA SA NEPLA�ENIM RA�UNIMA "+iif(cViseManje=">","PREKO ","DO ")+STR(nDana,3)+" DANA  NA DAN "; ?? dDatum
if !empty(dDatumOd)
? "     obuhva�en je period:",dDatumOd,"-",dDatum
endif

if !empty(qqBrDok)
	? "Izvjestaj pravljen po uslovu za broj veze/racuna: '" + ALLTRIM(qqBrDok) + "'"
endif

@ prow(),123 SAY "Str:"+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ? "Firma:",cidfirma,PADR(partn->naz, 25),partn->naz2
endif

? "KONTO:",cIdkonto

SELECT SUBAN

? "----- " + REPLICATE("-", __par_len) + " ----------------------------------- ------ ---------------- -------- -------- -------- "
?? replicate("-",17)
if gVar1=="0" // dvovalutno
 ?? " "+replicate("-",17)
endif
? "*RED *" + PADC("PART-", __par_len) + "*      NAZIV POSLOVNOG PARTNERA      PTT     MJESTO         *  BROJ  * DATUM  * K1-K4  *"
if gVar1=="0"
  ?? PADC("NEPLA�ENO",35)
ELSE
  ?? PADC("NEPLA�ENO",17)
ENDIF

? " BR. " + PADC("NER", __par_len) + "                                                                                         "

?? replicate("-",17)
if gVar1=="0" // dvovalutno
 ?? " "+replicate("-",17)
endif

? "*    *" + REPLICATE(" ", __par_len) + "*                                                           * RA�UNA *"+iif(cObzirDatVal=="D"," VALUTE "," RA�UNA ")+"*        *"

cPom:=""
if cD_P="1"
  cPom+="    DUGUJE "
else
  cPom+="   POTRA�. "
endif
cPom+=ValDomaca()+ "  * "

if gVar1="0" // dvovalutno
 if cD_P="1"
   cPom+="  DUGUJE "
 else
   cPom+=" POTRA�. "
 endif
 cPom+=ValPomocna()+"  *"
endif
?? cPom

? m
RETURN


/*! \fn SpecPoK()
 *  \brief Specifikacija po kontima
 */
 
function SpecPoK()

local cSK:="N"
PRIVATE nC:=66

cIdFirma:=gFirma
picBHD:=FormPicL("9 "+gPicBHD,20)

O_PARTN

__par_len := LEN(partn->id)
dDatOd:=dDatDo:=ctod("")

qqKonto:=space(100)

cTip:="1"
Box("",10,65)
set cursor on

cNula:="N"
do while .t.
 @ m_x+1,m_y+6 SAY "SPECIFIKACIJA ANALITICKIH KONTA"
 if gNW=="D"
   @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+4,m_y+2 SAY "Konto " GET qqKonto  pict "@!S50"
 @ m_x+5,m_y+2 SAY "Datum od" GET dDatOd
 @ m_x+5,col()+2 SAY "do" GET dDatDo
 IF gVar1=="0"
  @ m_x+6,m_y+2 SAY "Obracun za "+ALLTRIM(ValDomaca())+"/"+ALLTRIM(ValPomocna())+" (1/2):" GET cTip valid ctip $ "12"
 ENDIF
 @ m_x+7,m_y+2 SAY "Prikaz sintetickih konta (D/N):" GET cSK pict "@!" valid cSK $ "DN"
 @ m_x+9,m_y+2 SAY "Prikaz stavki sa saldom 0 D/N" GET cNula pict "@!" valid cNula  $ "DN"
 cIdRJ:=""
 IF gRJ=="D" .and. gSAKrIz=="D"
   cIdRJ:="999999"
   @ m_x+10,m_y+2 SAY "Radna jedinica (999999-sve): " GET cIdRj
 ENDIF
 READ; ESC_BCR
 aUsl1:=Parsiraj(qqKonto,"IdKonto")
 if ausl1<>NIL; exit; endif
enddo
BoxC()

if cIdRj=="999999"; cidrj:=""; endif
if gRJ=="D" .and. gSAKrIz=="D" .and. "." $ cidrj
  cidrj:=trim(strtran(cidrj,".",""))
  // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
endif

cIdFirma:=left(cIdFirma,2)

O_KONTO
IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  otvori_sint_anal_kroz_temp(.f.,"IDRJ='"+cIdRJ+"'")
ELSE
  O_ANAL
ENDIF

select ANAL; set order to tag "1"

//cFilt1:="IdFirma=='"+cIdFirma+"'"
cFilt1:="IdFirma=="+cm2str(cIdFirma)
if !(empty(dDatOd) .and. empty(dDatDo))
  cFilt1 += ( ".and.DatNal>="+cm2str(dDatOd) +".and.DatNal<="+cm2str(dDatDo) )
endif
if aUsl1<>".t."
 cFilt1 += ( ".and."+aUsl1 )
endif


set filter to &cFilt1

#ifdef C52
#ifdef PROBA
MsgBeep("Filt pogodaka:"+str(rlOptLevel()))
#endif
#endif
go top

EOF CRET

Pic:=PicBhd

START PRINT CRET

m:="------ --------------------------------------------------------- --------------------- -------------------- --------------------"
nStr:=0

nud:=nup:=0
do whileSC !eof()
 cSin:=left(idkonto,3)
 nkd:=nkp:=0
 do whileSC !eof() .and.  cSin==left(idkonto,3)
     cIdKonto:=IdKonto
     nd:=np:=0
     if prow()==0; zagl5(); endif
     do whileSC !eof() .and. cIdKonto==IdKonto
       if cTip == "1"
         nd+=dugbhd; np+=potbhd
       else
         nd+=dugdem; np+=potdem
       endif
       skip
     enddo
   if prow()>60+gPStranica; FF; zagl5(); endif
   select KONTO; hseek cidkonto; select ANAL
   if cNula=="D" .or. round(nd-np,3)<>0
    ? cidkonto,KONTO->naz
    nC:=pcol()+1
    @ prow(),pcol()+1 SAY nd pict pic
    @ prow(),pcol()+1 SAY np pict pic
    @ prow(),pcol()+1 SAY nd-np pict pic
    nkd+=nd; nkp+=np  // ukupno  za klasu
   endif  // cnula
 enddo  // sintetika
 if prow()>60+gPStranica; FF; zagl5(); endif
 if cSK=="D".and.(nkd!=0.or.nkp!=0)
  ? m
  ?  "SINT.K.",cSin,":"
  @ prow(),nC       SAY nKd pict pic
  @ prow(),pcol()+1 SAY nKp pict pic
  @ prow(),pcol()+1 SAY nKd-nKp pict pic
  ? m
 endif
 nUd+=nKd; nUp+=nKp   // ukupno za sve
enddo
if prow()>60+gPStranica; FF; zagl5(); endif
? m
? " UKUPNO:"
@ prow(),nC       SAY nUd pict pic
@ prow(),pcol()+1 SAY nUp pict pic
@ prow(),pcol()+1 SAY nUd-nUp pict pic
? m
FF
END PRINT
closeret
return



/*! \fn Zagl5()
 *  \brief Zaglavlje specifikacije po kontima
 */
 
static function Zagl5()
?
P_COND
?? "FIN.P:SPECIFIKACIJA ANALITI�KIH KONTA  ZA",ALLTRIM(iif(cTip=="1",ValDomaca(),ValPomocna()))
if !(empty(dDatOd) .and. empty(dDatDo))
  ?? "  ZA NALOGE U PERIODU ",dDatOd,"-",dDatDo
endif
?? " NA DAN: "; ?? DATE()

@ prow(),125 SAY "Str:"+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ? "Firma:",cidfirma,PADR(partn->naz,25),partn->naz2
endif

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  ? "Radna jedinica ='"+cIdRj+"'"
ENDIF

select ANAL
? m
? "KONTO      N A Z I V                                                           duguje            potra�uje                saldo"
? m
return



static function fill_ss_tbl(cKonto, cPartner, cNaziv, nFDug, nFPot, nFSaldo, cRj, cRjNaz)
local nArr
nArr:=SELECT()

O_R_EXP
append blank
replace field->konto with cKonto
replace field->partner with cPartner
replace field->naziv with cNaziv
replace field->duguje with nFDug
replace field->potrazuje with nFPot
replace field->saldo with nFSaldo

if cRj <> nil
	replace field->rj with cRj
	replace field->rjnaziv with cRjNaz
endif

select (nArr)

return


// vraca matricu sa sub.bb poljima
static function get_ss_fields( cRj, nPartLen )

if cRj == nil
	cRj := "N"
endif
if nPartLen == nil
	nPartLen := 6
endif

aFields := {}
AADD(aFields, {"konto", "C", 7, 0})
AADD(aFields, {"partner", "C", nPartLen, 0})
AADD(aFields, {"naziv", "C", 40, 0})

if cRj == "D"
	AADD(aFields, {"rj", "C", 10, 0})
	AADD(aFields, {"rjnaziv", "C", 40, 0})
endif

AADD(aFields, {"duguje", "N", 15, 2})
AADD(aFields, {"potrazuje", "N", 15, 2})
AADD(aFields, {"saldo", "N", 15, 2})

return aFields



// ---------------------------------------------------
// Specifikacija subanalitickih konta 
// ---------------------------------------------------
function SpecPoKP()
local cSK:="N"
local cLDrugi:=""
local cPom:=""
local nCOpis:=0
local cLTreci:=""
local cIzr1
local cIzr2
local cExpRptDN:="N"
local cOpcine := SPACE(20)
local cVN := SPACE(20)
private cSkVar:="N"
private fK1:=fk2:=fk3:=fk4:="N"
private cRasclaniti:="N"
private cRascFunkFond:="N"


cN2Fin:=IzFMkIni('FIN','PartnerNaziv2','N')

nC:=50
O_PARAMS
private cSection:="1"
private cHistory:=" "
private aHistory:={}

RPar("k1",@fk1)
RPar("k2",@fk2)
RPar("k3",@fk3)
RPar("k4",@fk4)
select params
use

cIdFirma:=gFirma
picBHD:=FormPicL("9 "+gPicBHD,20)

qqKonto:=qqPartner:=space(100)
dDatOd:=dDatDo:=CToD("")
O_PARAMS

private cSection:="S"
private cHistory:=" "
private aHistory:={}

RPar("qK",@qqKonto)
RPar("qP",@qqPartner)
RPar("d1",@dDatoD)
RPar("d2",@dDatDo)

qqkonto:=padr(qqKonto,100)
qqPartner:=padr(qqPartner,100)
qqBrDok:=SPACE(40)

select params
use

O_PARTN

__par_len := LEN(partn->id)

cTip:="1"
Box("",20,65)
	set cursor on
	private cK1:=cK2:="9"
	private cK3:=cK4:="99"
	IF IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
  		cK3:="999"
	endif
	IF gDUFRJ=="D"
  		cIdRj:=SPACE(60)
	ELSE
  		cIdRj:="999999"
	ENDIF
	cFunk:="99999"
	cFond:="9999"
	cNula:="N"
	do while .t.
 		@ m_x+1,m_y+6 SAY "SPECIFIKACIJA SUBANALITICKIH KONTA"
 		IF gDUFRJ=="D"
    			cIdFirma:=PADR(gFirma+";",30)
    			@ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma PICT "@!S20"
 		ELSE
   			if gNW=="D"
     				@ m_x+3,m_y+2 SAY "Firma "
				?? gFirma,"-",gNFirma
   			else
    				@ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| IF(!EMPTY(cIdFirma),P_Firma(@cIdFirma),),cidfirma:=left(cidfirma,2),.t.}
   			endif
 		ENDIF
 		@ m_x+4,m_y+2 SAY "Konto   " GET qqKonto  pict "@!S50"
 		@ m_x+5,m_y+2 SAY "Partner " GET qqPartner pict "@!S50"
 		@ m_x+6,m_y+2 SAY "Datum dokumenta od" GET dDatOd
 		@ m_x+6,col()+2 SAY "do" GET dDatDo
 		IF gVar1=="0"
  			@ m_x+7,m_y+2 SAY "Obracun za "+ALLTRIM(ValDomaca())+"/"+ALLTRIM(ValPomocna())+"/"+ALLTRIM(ValDomaca())+"-"+ALLTRIM(ValPomocna())+" (1/2/3):" GET cTip valid ctip $ "123"
 		ELSE
  			cTip:="1"
 		ENDIF

 		@ m_x+ 8,m_y+2 SAY "Prikaz sintetickih konta (D/N) ?" GET cSK  pict "@!" valid csk $ "DN"
 		@ m_x+ 9,m_y+2 SAY "Prikaz stavki sa saldom 0 D/N" GET cNula pict "@!" valid cNula  $ "DN"
 		@ m_x+10,m_y+2 SAY "Skracena varijanta (D/N) ?" GET cSkVar pict "@!" valid cSkVar $ "DN"
 		@ m_x+11,m_y+2 SAY "Uslov za broj veze (prazno-svi) " GET qqBrDok PICT "@!S20"
 		@ m_x+12,m_y+2 SAY "Uslov za vrstu naloga (prazno-svi) " GET cVN PICT "@!S20"

 		cRasclaniti:="N"

 		if gRJ=="D"
  			@ m_x+13,m_y+2 SAY "Rasclaniti po RJ (D/N) "  GET cRasclaniti pict "@!" valid cRasclaniti $ "DN"
 			@ m_x+14,m_y+2 SAY "Rasclaniti po RJ/FUNK/FOND? (D/N) "  GET cRascFunkFond pict "@!" valid cRascFunkFond $ "DN"
		endif

		@ m_x + 15, m_y + 2 SAY "Opcina (prazno-sve):" GET cOpcine

		UpitK1k4(16)

 		@ m_x + 19, m_y + 2 SAY "Export izvjestaja u dbf (D/N) ?" GET cExpRptDN pict "@!" valid cExpRptDN $ "DN"
		
		READ
		ESC_BCR
 		O_PARAMS
 		private cSection:="S"
		private cHistory:=" "
		private aHistory:={}
 		WPar("qK",qqKonto)
 		WPar("qP",qqPartner)
 		WPar("d1",dDatoD)
 		WPar("d2",dDatDo)
 		select params
		use
 		//aUsl1:=Parsiraj(qqKonto,"IdKonto",NIL,@cIzr1)  ??
 		//aUsl2:=Parsiraj(qqPartner,"IdPartner",NIL,@cIzr2) ??
 		aUsl1:=Parsiraj(qqKonto,"IdKonto")
 		aUsl2:=Parsiraj(qqPartner,"IdPartner")
 		IF gDUFRJ=="D"
   			aUsl3:=Parsiraj(cIdFirma,"IdFirma")
   			aUsl4:=Parsiraj(cIdRJ,"IdRj")
 		ENDIF
 		aBV:=Parsiraj(qqBrDok,"UPPER(BRDOK)","C")
		aVN:=Parsiraj(cVN,"IDVN","C")
 		if aBV<>NIL .and. aVN<>NIL .and. ausl1<>NIL .and. aUsl2<>NIL .and. IF(gDUFRJ=="D",aUsl3<>NIL.and.aUsl4<>NIL,.t.)
			exit
		endif
	enddo
BoxC()

lExpRpt := (cExpRptDN == "D")

if lExpRpt
	aSSFields := get_ss_fields( gRj, __par_len )
	t_exp_create(aSSFields)
endif

IF gDUFRJ!="D"
	cIdFirma:=left(cIdFirma,2)
ENDIF

IF cRasclaniti=="D"
  	O_RJ
ENDIF

O_PARTN
O_KONTO
O_SUBAN

CistiK1k4()

select SUBAN
IF !EMPTY(cIdFirma) .and. gDUFRJ!="D"
	IF cRasclaniti=="D"
   		index on idfirma+idkonto+idpartner+idrj+dtos(datdok) to SUBSUB
   		SET ORDER TO TAG "SUBSUB"
 	ELSEIF cRascFunkFond=="D"
   		index on idfirma+idkonto+idpartner+idrj+funk+fond+dtos(datdok) to SUBSUB
   		SET ORDER TO TAG "SUBSUB"

 	ELSE
   		// IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr
   		SET ORDER TO tag "1"
 	ENDIF
ELSE
	IF cRasclaniti=="D"
   		index on idkonto+idpartner+idrj+dtos(datdok) to SUBSUB
  		SET ORDER TO TAG "SUBSUB"
 	ELSEIF cRascFunkFond=="D"
   		index on idkonto+idpartner+idrj+funk+fond+dtos(datdok) to SUBSUB
   		SET ORDER TO TAG "SUBSUB"
 	ELSE
   		cIdFirma:=""
   		INDEX ON IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr TO SVESUB
   		SET ORDER TO TAG "SVESUB"
 	ENDIF
ENDIF

IF gDUFRJ=="D"
	cFilter := aUsl3
ELSE
  	cFilter := "IdFirma="+cm2str(cidfirma)
ENDIF

IF !EMPTY(cVN)
	cFilter += ( ".and. " + aVN )
endif

IF !EMPTY(qqBrDok)
  	cFilter += ( ".and." + aBV )
ENDIF

if aUsl1<>".t."
 	cFilter += ( ".and."+aUsl1 )
endif

if aUsl2<>".t."
 	cFilter += ( ".and."+aUsl2 )
endif

if !empty(dDatOd) .or. !empty(dDatDo)
   	cFilter += ( ".and. DATDOK>="+cm2str(dDatOd)+".and. DATDOK<="+cm2str(dDatDo) )
endif

if fk1=="D" .and. len(ck1)<>0
  	cFilter += ( ".and. k1='"+ck1+"'" )
endif

if fk2=="D" .and. len(ck2)<>0
  	cFilter += ( ".and. k2='"+ck2+"'" )
endif

if fk3=="D" .and. len(ck3)<>0
  	cFilter += ( ".and. k3='"+ck3+"'" )
endif

if fk4=="D" .and. len(ck4)<>0
  	cFilter += ( ".and. k4='"+ck4+"'" )
endif

if gRj=="D" .and. len(cIdrj)<>0
  	IF gDUFRJ=="D"
    		cFilter += ( ".and."+aUsl4 )
  	ELSE
    		cFilter += ( ".and. idrj='"+cidrj+"'" )
  	ENDIF
endif

if gTroskovi=="D" .and. len(cFunk)<>0
  	cFilter += ( ".and. Funk='"+cFunk+"'" )
endif

if gTroskovi=="D" .and. len(cFond)<>0
  	cFilter += ( ".and. Fond='"+cFond+"'" )
endif

set filter to &cFilter

go top
EOF CRET

Pic:=PicBhd

START PRINT CRET

IF cSkVar=="D"
  	nDOpis:=25
	if __par_len > 6
	  //nDOpis += 2
	endif
	nDIznos:=12
  	pic:=RIGHT(picbhd,nDIznos)
ELSE
  	nDOpis:=50
	if __par_len > 6
	   //nDOpis += 2
	endif
	nDIznos:=20
ENDIF

if cTip=="3"
   	m:="------- " + REPLICATE("-", __par_len) + " "+REPL("-",nDOpis)+" "+REPL("-",nDIznos)+" "+REPL("-",nDIznos)
else
   	m:="------- " + REPLICATE("-", __par_len) + " "+REPL("-",nDOpis)+" "+REPL("-",nDIznos)+" "+REPL("-",nDIznos)+" "+REPL("-",nDIznos)
endif

nStr:=0

nud:=0
nup:=0      // DIN
nud2:=0
nup2:=0    // DEM
do whileSC !eof()
	
	cSin:=left(idkonto,3)
 	nKd:=0
	nKp:=0
 	nKd2:=0
	nKp2:=0

 	do whileSC !EOF() .and.  cSin==left(idkonto,3)
   		
		nTArea := SELECT()

		cIdKonto:=IdKonto
   		cIdPartner:=IdPartner

		if !EMPTY(cOpcine)
			select partn
			seek cIdPartner
			if ALLTRIM(field->idops) $ cOpcine
				// to je taj partner...
			else
				// posto nije to taj preskoci...
				select (nTArea)
				skip
				loop
			endif
		endif
		
		select (nTArea)

   		nD:=0
		nP:=0
   		nD2:=0
		nP2:=0

   		if cRasclaniti=="D"
      			cRasclan:=idrj
   		else
      			cRasclan:=""
   		endif
   		if prow()==0
			zagl6(cSkVar)
		endif
		if cRascFunkFond=="D"
			aRasclan:={}
			nDugujeBHD:=0
			nPotrazujeBHD:=0
		endif
   		do whileSC !eof() .and. cIdKonto==IdKonto .and. IdPartner==cIdPartner .and. RasclanRJ()
			if cRascFunkFond=="D"
				cGetFunkFond:=idrj+funk+fond
				cGetIdRj:=idrj
				cGetFunk:=funk
				cGetFond:=fond
			endif
			// racuna duguje/potrazuje
			if d_P=="1"
       				nD+=iznosbhd
       				nD2+=iznosdem
     				if cRascFunkFond=="D"
					nDugujeBHD:=iznosbhd
				endif
			else
       				nP+=iznosbhd
       				nP2+=iznosdem
     				if cRascFunkFond=="D"
					nPotrazujeBHD:=iznosbhd
				endif
			endif
     			
			skip 1

			if cRascFunkFond=="D" .and. cGetFunkFond<>idrj+funk+fond
				AADD(aRasclan, {cGetIdRj, cGetFunk, cGetFond, nDugujeBHD, nPotrazujeBHD})
				nDugujeBHD:=0
				nPotrazujeBHD:=0
			endif
   		enddo
   		if prow()>60+gPStranica
			FF
			zagl6(cSkVar)
		endif
   		if cNula=="D" .or. round(nd-np,3)<>0.and.cTip$"13" .or. round(nd2-np2,3)<>0.and.cTip$"23"
     			? cIdKonto, IdPartner(cIdPartner), ""
     			IF cRasclaniti=="D"
       				SELECT RJ
       				SEEK LEFT(cRasclan,LEN(SUBAN->idrj))
       				SELECT SUBAN
       				IF !EMPTY( LEFT(cRasclan,LEN(SUBAN->idrj)) )
         				cLTreci := "RJ:"+LEFT(cRasclan,LEN(SUBAN->idrj))+"-"+TRIM(RJ->naz)
       				ENDIF
				
     			ENDIF
     			nCOpis:=PCOL()
			// ispis partnera
     			if !empty(cIdPartner)
       				select PARTN
       				hseek cIdPartner
       				select SUBAN
       				if gVSubOp=="D"
         				select KONTO
					hseek cIdKonto
					select SUBAN
         				cPom:=ALLTRIM(KONTO->naz)+" ("+ALLTRIM(ALLTRIM(PARTN->naz)+PN2())+")"
         				?? PADR(cPom,nDOpis-DifIdP(cidpartner))
         				IF LEN(cPom)>nDOpis-DifIdP(cidpartner)
           					cLDrugi:=SUBSTR(cPom,nDOpis+1)
         				ENDIF
       				else
         				cPom:=ALLTRIM(PARTN->naz)+PN2()
         				IF !empty(partn->mjesto)
            					if right(trim(upper(partn->naz)),len(trim(partn->mjesto))) != TRIM(UPPER(partn->mjesto))
                					cPom:=trim(ALLTRIM(partn->naz)+PN2())+" "+trim(partn->mjesto)
                					aTxt:=Sjecistr(cPom,nDOpis)
                					cPom:=aTxt[1]
                					if len(aTxt)>1
                  						cLDrugi:=aTxt[2]
                					endif
            					endif
         				endif
         				?? padr(cPom,nDOpis)
       				endif
     			else
       				select KONTO
				hseek cIdKonto
				select SUBAN
       				?? padr(KONTO->naz,nDOpis)
     			endif
     			nC:=pcol()+1
     			// ispis duguje/potrazuje/saldo
			if cTip=="1"
      				@ prow(),pcol()+1 SAY nD pict pic
      				@ prow(),pcol()+1 SAY nP pict pic
      				@ prow(),pcol()+1 SAY nD-nP pict pic
     			elseif cTip=="2"
      				@ prow(),pcol()+1 SAY nD2 pict pic
      				@ prow(),pcol()+1 SAY nP2 pict pic
      				@ prow(),pcol()+1 SAY nD2-nP2 pict pic
     			else
      				@ prow(),pcol()+1 SAY nD-nP pict pic
      				@ prow(),pcol()+1 SAY nD2-nP2 pict pic
     			endif
     			
			if lExpRpt
				if gRj == "D" .and. cRasclaniti == "D"
					
					cRj_id := cRasclan
					
					if !EMPTY(cRj_id)
						cRj_naz := rj->naz
					else
						cRj_naz := ""
					endif
					
				else
					cRj_id := nil
					cRj_naz := nil
				endif
				
				fill_ss_tbl(cIdKonto, cIdPartner, IF(EMPTY(cIdPartner), konto->naz, ALLTRIM(partn->naz)), nD, nP, nD-nP, cRj_id, cRj_naz)
			endif
			
			nKd+=nD
			nKp+=nP  // ukupno  za klasu
     			nKd2+=nD2
			nKp2+=nP2  // ukupno  za klasu
   		endif // cnula
   		if LEN(cLDrugi)>0
     			@ prow()+1, nCOpis SAY cLDrugi
     			cLDrugi:=""
   		endif
   		if LEN(cLTreci)>0
     			@ prow()+1, nCOpis SAY cLTreci
     			cLTreci:=""
   		endif
		
		if cRascFunkFond=="D" .and. LEN(aRasclan)>0
			@ prow()+1, nCOpis SAY REPLICATE("-", 113)
			for i:=1 to LEN(aRasclan)
				@ prow()+1, nCOpis SAY "RJ: " + aRasclan[i, 1] + ", FUNK: " + aRasclan[i, 2] + ", FOND: " + aRasclan[i, 3] + ": " 
				@ prow(), pcol()+15 SAY aRasclan[i, 4] PICT pic
				@ prow(), pcol()+1 SAY aRasclan[i, 5] PICT pic
				@ prow(), pcol()+1 SAY aRasclan[i, 4] - aRasclan[i, 5] PICT pic  
			next
			@ prow()+1, nCOpis SAY REPLICATE("-", 113)
		endif
		
 	enddo  // sintetika
 	if prow()>60+gPStranica
		FF
		zagl6(cSkVar)
	endif
 	if cSK=="D"
   		? m
   		?  "SINT.K.",cSin,":"
   		if cTip=="1"
     			@ prow(),nC SAY nKd pict pic
     			@ prow(),pcol()+1 SAY nKp pict pic
     			@ prow(),pcol()+1 SAY nKd-nKp pict pic
   		elseif cTip=="2"
     			@ prow(),nC SAY nKd2 pict pic
     			@ prow(),pcol()+1 SAY nKp2 pict pic
     			@ prow(),pcol()+1 SAY nKd2-nKp2 pict pic
   		else
     			@ prow(),nC SAY nKd-nKP pict pic
     			@ prow(),pcol()+1 SAY nKd2-nKP2 pict pic
   		endif
   		? m
 	endif
 	nUd+=nKd
	nUp+=nKp   // ukupno za sve
 	nUd2+=nKd2
	nUp2+=nKp2   // ukupno za sve
enddo

if prow()>60+gPStranica
	FF
	zagl6(cSkVar)
endif

? m
? " UKUPNO:"
if cTip=="1"
	@ prow(),nC       SAY nUd pict pic
  	@ prow(),pcol()+1 SAY nUp pict pic
  	@ prow(),pcol()+1 SAY nUd-nUp pict pic
elseif cTip=="2"
  	@ prow(),nC       SAY nUd2 pict pic
  	@ prow(),pcol()+1 SAY nUp2 pict pic
  	@ prow(),pcol()+1 SAY nUd2-nUp2 pict pic
else
  	@ prow(),nC       SAY nUd-nUP pict pic
  	@ prow(),pcol()+1 SAY nUd2-nUP2 pict pic
endif

if lExpRpt
	fill_ss_tbl("UKUPNO", "", "", nUD, nUP, nUD-nUP )
endif

? m
FF
END PRINT

if lExpRpt
	tbl_export()
endif

closeret
return



/*! \fn SpecSubPro()
 *  \brief Specifikacija subanalitike po proizvoljnom sortiranju, verzija C52
 */
 
function SpecSubPro()
local _fin_params := fin_params()
local _fakt_params := fakt_params()

private fK1 := _fin_params["fin_k1"]
private fK2 := _fin_params["fin_k2"]
private fK3 := _fin_params["fin_k3"]
private fK4 := _fin_params["fin_k4"]

private cSk := "N"
private cSkVar := "N"

cIdFirma := gFirma
picBHD := FormPicL("9 "+gPicBHD,20)

O_KONTO
O_PARTN
__par_len := LEN(partn->id)

dDatOd := dDatDo := CTOD("")
qqkonto := space(7)
qqPartner := space(60)
qqTel := space(60)
cTip := "1"
qqBrDok := ""

Box( "", 20, 65 )

set cursor on

private cSort := "1"

cK1:=cK2:="9"
cK3:=cK4:="99"
cIdRj:="999999"
cFunk:="99999"
cFond:="9999"

private nC:=65

do while .t.
    @ m_x+1,m_y+6 SAY "SPECIFIKACIJA SUBANALITIKA - PROIZV.SORT."
    if gNW=="D"
        @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
    else
        @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
    endif
    @ m_x+4,m_y+2 SAY "Konto   " GET qqkonto  pict "@!" valid P_KontoFin(@qqkonto)
    @ m_x+5,m_y+2 SAY "Partner " GET qqPartner pict "@!S50"
    @ m_x+6,m_y+2 SAY "Datum dokumenta od" GET dDatOd
    @ m_x+6,col()+2 SAY "do" GET dDatDo
    IF gVar1=="0"
        @ m_x+7,m_y+2 SAY "Obracun za "+ALLTRIM(ValDomaca())+"/"+ALLTRIM(ValPomocna())+"/"+ALLTRIM(ValDomaca())+"-"+ALLTRIM(ValPomocna())+" (1/2/3):" GET cTip valid ctip $ "123"
    ENDIF

    @ m_x+9,m_y+2 SAY "Kriterij za telefon" get qqTel pict "@!S30"
    @ m_x+11,m_y+2 SAY "Sortirati po: konto+telefon+partn (1)" get cSort valid csort $ "12"

    @ m_x+15,m_y+2 SAY ""

    if fk1
        @ m_x+15,m_y+2 SAY "K1 (9 svi) :" GET cK1
    endif
    if fk2
        @ m_x+15,col()+2 SAY "K2 (9 svi) :" GET cK2
    endif
    if fk3
        @ m_x+15,col()+2 SAY "K3 ("+cK3+" svi):" GET cK3
    endif
    if fk4 
        @ m_x+15,col()+2 SAY "K4 (99 svi):" GET cK4
    endif
    
    READ
    ESC_BCR
 
    aUsl2 := Parsiraj( qqPartner, "IdPartner" )
    aUsl5 := Parsiraj( qqTel, "partn->telefon" ) 

    if aUsl5 <> NIL .and. aUsl2 <> NIL
        exit
    endif

enddo

BoxC()

cIdFirma := LEFT( cIdFirma, 2 )

nTmpArr := 0
nArr := 0
cImeTmp := ""

O_SUBAN
SET RELATION TO suban->idpartner INTO partn

if cK1 == "9"
    cK1 := ""
endif
if cK2 == "9"
    cK2 := ""
endif
if cK3 == REPL("9",LEN(cK3))
    cK3 := ""
else
    cK3 := k3u256(cK3)
endif
if cK4 == "99"
    cK4 := ""
endif

select SUBAN
set order to tag "1"

if cSort == "1"
    cSort1 := "idfirma + idkonto + partn->telefon + idpartner"
endif

private cFilt1 := "idfirma == " + _filter_quote( cIdFirma ) + " .and. idkonto == '" + qqkonto + "'"

if !(empty(dDatOd) .and. empty(dDatDo))
    cFilt1 += iif(empty(cFilt1),"",".and.")+ ;
            "dDatOd<=DatDok  .and. dDatDo>=DatDok"
endif

if ( fk1 .and. fk2 .and. fk3 .and. fk4 )
    cFilt1+= if( empty(cFilt1), "", ".and." ) + ;
           "(k1=ck1 .and. k2=ck2 .and. k3=ck3 .and. k4=ck4)"
endif

if aUsl2 <> ".t."
    cFilt1 += ".and.(" + aUsl2 +")"
endif
if aUsl5<>".t."
    cFilt1+= ".and.(" + aUsl5 +")"
endif

Box(,1,30)

INDEX ON &cSort1 to "TMPSP2" FOR &cFilt1 

BoxC()

Pic:=PicBhd

START PRINT CRET

if cTip=="3"
   m:="------  " + REPLICATE("-", __par_len) + " ------------------------------------------------- --------------------- --------------------"
else
   m:="------  " + REPLICATE("-", __par_len) + " ------------------------------------------------- --------------------- -------------------- --------------------"
endif
nStr:=0

nud:=nup:=0      // DIN
nud2:=nup2:=0    // DEM

do whileSC !eof()
 select suban
 nkd:=nkp:=0
 nkd2:=nkp2:=0
 cIdkonto:=idkonto
 if cSort=="1"
     cBrTel:=partn->telefon
     bUslov:={|| cbrtel==partn->telefon}
     cNaslov:=partn->telefon+"-"+partn->mjesto
 endif
 do whilesc !eof() .and. idfirma==cidfirma .and. idkonto==cidkonto .and. eval(bUslov)
     nd:=np:=0;nd2:=np2:=0
     if prow()==0; zagl6(cSkVar); endif
     cIdPartner:=IdPartner
     cNazPartn:=PADR(partn->naz, 25)
     do whileSC !eof() .and. idfirma==cidfirma .and. idkonto==cidkonto .and. eval(bUslov) .and. IdPartner==cIdPartner
         if d_P=="1"
           nd+=iznosbhd; nd2+=iznosdem
         else
           np+=iznosbhd; np2+=iznosdem
         endif
       select suban
       SKIP
     enddo
   if prow()>60+gPStranica; FF; zagl6(cSkVar); endif
   ? cidkonto,cIdPartner,""
   if !empty(cIdPartner)
     //select PARTN; hseek cidpartner; select SUBAN
     ?? padr(cNazPARTN,50-DifIdp(cIdPartner))
   else
     select KONTO; hseek cidkonto; select SUBAN
     ?? padr(KONTO->naz,50)
   endif
   nC:=pcol()+1
   if cTip=="1"
    @ prow(),pcol()+1 SAY nd pict pic
    @ prow(),pcol()+1 SAY np pict pic
    @ prow(),pcol()+1 SAY nd-np pict pic
   elseif cTip=="2"
    @ prow(),pcol()+1 SAY nd2 pict pic
    @ prow(),pcol()+1 SAY np2 pict pic
    @ prow(),pcol()+1 SAY nd2-np2 pict pic
   else
    @ prow(),pcol()+1 SAY nd-np pict pic
    @ prow(),pcol()+1 SAY nd2-np2 pict pic
   endif
   nkd+=nd; nkp+=np  // ukupno  za klasu
   nkd2+=nd2; nkp2+=np2  // ukupno  za klasu
 enddo  // csort
 if prow()>60+gPStranica; FF; zagl6(cSkVar); endif
  ? m
  if cSort=="1"
   ?  "Ukupno za:",cNaslov,":"
  endif
  if cTip=="1"
   @ prow(),nC       SAY nKd pict pic
   @ prow(),pcol()+1 SAY nKp pict pic
   @ prow(),pcol()+1 SAY nKd-nKp pict pic
  elseif cTip=="2"
   @ prow(),nC       SAY nKd2 pict pic
   @ prow(),pcol()+1 SAY nKp2 pict pic
   @ prow(),pcol()+1 SAY nKd2-nKp2 pict pic
  else
   @ prow(),nC       SAY nKd-nKP pict pic
   @ prow(),pcol()+1 SAY nKd2-nKP2 pict pic
  endif
  ? m
 nUd+=nKd; nUp+=nKp   // ukupno za sve
 nUd2+=nKd2; nUp2+=nKp2   // ukupno za sve
enddo
if prow()>60+gPStranica; FF; zagl6(cSkVar); endif
? m
? " UKUPNO:"
if cTip=="1"
  @ prow(),nC       SAY nUd pict pic
  @ prow(),pcol()+1 SAY nUp pict pic
  @ prow(),pcol()+1 SAY nUd-nUp pict pic
elseif cTip=="2"
  @ prow(),nC       SAY nUd2 pict pic
  @ prow(),pcol()+1 SAY nUp2 pict pic
  @ prow(),pcol()+1 SAY nUd2-nUp2 pict pic
else
  @ prow(),nC       SAY nUd-nUP pict pic
  @ prow(),pcol()+1 SAY nUd2-nUP2 pict pic
endif
? m
FF
END PRINT
closeret
return



/*! \fn TekRec()
 *  \brief Vraca tekuci zapis
 */
static function TekRec()
@ m_x+1,m_y+2 SAY RecNo()
return nil


/*! \fn Zagl6(cSkVar)
 *  \brief Zaglavlje specifikacije
 *  \param cSkVar
 */
 
static function Zagl6(cSkVar)
?
B_ON
P_COND
?? "FIN: SPECIFIKACIJA SUBANALITICKIH KONTA  ZA "
if cTip=="1"
  ?? ValDomaca()
elseif cTip=="2"
  ?? ValPomocna()
else
  ?? ALLTRIM(ValDomaca())+"-"+ALLTRIM(ValPomocna())
endif
if !(empty(dDatOd) .and. empty(dDatDo))
  ?? "  ZA DOKUMENTE U PERIODU ",dDatOd,"-",dDatDo
endif
?? " NA DAN: "; ?? DATE()
IF !EMPTY(qqBrDok)
  ? "Izvjestaj pravljen po uslovu za broj veze/racuna: '"+TRIM(qqBrDok)+"'"
ENDIF
@ prow(),125 SAY "Str:"+str(++nStr,3)
B_OFF

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 IF EMPTY(cIdFirma)
  ? "Firma:",gNFirma,"(SVE RJ)"
 ELSE
  SELECT PARTN; HSEEK cIdFirma
  ? "Firma:",cidfirma,PADR(partn->naz, 25),partn->naz2
 ENDIF
endif
?
PrikK1k4()

select SUBAN

IF cSkVar=="D"
  F12CPI
  ? m
ELSE
  P_COND
  ? m
ENDIF
if cTip $ "12"
  IF cSkVar!="D"
    ? "KONTO  " + PADC("PARTN.", __par_len) + "  NAZIV KONTA / PARTNERA                                          duguje            potra�uje                saldo"
  ELSE
    ? "KONTO  " + PADC("PARTN", __par_len) + "  " +  PADR("NAZIV KONTA / PARTNERA",nDOpis)+" "+PADC("duguje",nDIznos)+" "+PADC("potra�uje",nDIznos)+" "+PADC("saldo",nDIznos)
  ENDIF
else
  IF cSkVar!="D"
    ? "KONTO  " + PADC("PARTN.", __par_len) + "  NAZIV KONTA / PARTNERA                                       saldo "+ValDomaca()+"           saldo "+ALLTRIM(ValPomocna())
  ELSE
    ? "KONTO  " + PADC("PARTN.", __par_len) + "  "+PADR("NAZIV KONTA / PARTNERA",nDOpis)+" "+PADC("saldo "+ValDomaca(),nDIznos)+" "+PADC("saldo "+ALLTRIM(ValPomocna()),nDIznos)
  ENDIF
endif
? m
return

/*! \fn SpecKK2(lOtvSt)
 *  \brief Specifikacija konto/konto2 partner
 *  \param lOtvSt
 */
 
function SpecKK2(lOtvSt)

local fK1:=fk2:=fk3:=fk4:="N",nC1:=35
cIdFirma:=gFirma

private picBHD:=FormPicL("9 "+gPicBHD,16)
private picDEM:=FormPicL("9 "+gPicDEM,14), cPG := "D"
private fOtvSt:=lOtvSt

O_KONTO
O_PARTN

__par_len := LEN(partn->id)

cDinDem:="1"
dDatOd:=dDatDo:=ctod("")
cKumul:=cPredh:="1"
private qqKonto:=qqKonto2:=qqPartner:=""

if gNW=="D";cIdFirma:=gFirma; endif
cK1:=cK2:="9"; cK3:=cK4:="99"

IF IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
  ck3:="999"
endif

cNula:="D"

qqPartner:=padr(qqPartner,60)
Box("",17,65)
set cursor on
 @ m_x+1,m_y+2 SAY "SPECIFIKACIJA SUBANALITIKE KONTO/KONTO2"
 read
do while .t.

 if gNW=="D"
   @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif

 qqKonto:=padr(qqKonto,7)
 qqKonto2:=padr(qqKonto2,7)
 @ m_x+5,m_y+2 SAY "Konto   " GET qqKonto  valid P_KontoFin(@qqKonto)
 @ m_x+6,m_y+2 SAY "Konto 2 " GET qqKonto2  valid P_KontoFin(@qqKonto2) .and. qqKonto2>qqkonto
 @ m_x+7,m_y+2 SAY "Partner " GET qqPartner pict "@!S50"
 @ m_x+8,m_y+2 SAY "Datum dokumenta od:" GET dDatod
 @ m_x+8,col()+2 SAY "do" GET dDatDo   valid dDatOd<=dDatDo
 @ m_x+9,m_y+2 SAY "Prikazi mjesto partnera (D/N)" GET cPG pict "@!" VALID cPG $ "DN"
 IF gVar1=="0"
  @ m_x+10,m_y+2 SAY "Prikaz "+ALLTRIM(ValDomaca())+"/"+ALLTRIM(ValPomocna())+" (1/2)" GET cDinDem pict "@!" valid cDinDem $ "12"
 ENDIF
 @ m_x+11,m_y+2 SAY "Prikaz stavki sa saldom 0 D/N/2/4" GET cNula pict "@!" valid cNula  $ "DN24"

 if fk1=="D"; @ m_x+14,m_y+2 SAY "K1 (9 svi) :" GET cK1; endif
 if fk2=="D"; @ m_x+15,m_y+2 SAY "K2 (9 svi) :" GET cK2; endif
 if fk3=="D"; @ m_x+16,m_y+2 SAY "K3 ("+ck3+" svi):" GET cK3; endif
 if fk4=="D"; @ m_x+17,m_y+2 SAY "K4 (99 svi):" GET cK4; endif

 read; ESC_BCR

 aUsl1:=Parsiraj(qqPartner,"IdPartner","C")

 if aUsl1<>NIL; exit; endif // ako je NIL - sintaksna greska

enddo

BoxC()

IF cPG=="N"
private m:=REPLICATE("-", __par_len) + " ------------------------- ---------------- ---------------- ----------------"
Else
private m:=REPLICATE("-", __par_len) + " ------------------------- ---------------- ---------------- ---------------- ----------------"
EndIF

O_SUBAN

cIdRj:="999999"  // samo da program ne ispada u f-ji CistiK1K4()
cFunk:="99999"
cFond:="9999"
CistiK1K4()

select SUBAN
//2: "IdFirma+IdPartner+IdKonto"
set order to tag "2"

cFilt1:=".t."

if  fk1=="N" .and. fk2=="N" .and. fk3=="N" .and. fk4=="N"

 if empty(dDatOd) .and. empty(dDatDo)
   if len(aUsl1)==0
    cFilt1:=".t."
   else
    cFilt1:=aUsl1
   endif
 else
   cFilt1:="DATDOK>="+cm2str(dDatOd)+".and.DATDOK<="+cm2str(dDatDo)+".and."+aUsl1
 endif

else  // odigraj sa ck4
 if empty(dDatOd) .and. empty(dDatDo)
   cFilt1:=aUsl1+".and.k1="+cm2str(ck1)+".and.k2="+cm2str(ck2)+;
                 ".and.k3=ck3.and.k4="+cm2str(ck4)
 else
   cFilt1:="DATDOK>="+cm2str(dDatOd)+".and.DATDOK<="+cm2str(dDatDo)+".and."+;
           aUsl1+".and.k1="+cm2str(ck1)+".and.k2="+cm2str(ck2)+;
                 ".and.k3=ck3.and.k4="+cm2str(ck4)
 endif
endif

cFilt1:=STRTRAN(cFilt1,".t..and.","")

IF !(cFilt1==".t.")
  SET FILTER TO &cFilt1
ENDIF

HSEEK cidfirma

EOF CRET

nStr:=0
START PRINT CRET



if nStr==0; Zagl7(); endif


nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0
do whilesc !eof() .and. IdFirma==cIdFirma



    cIdPartner:=IdPartner

    nDBHD:=nPBHD:=nDDEM:=nPDEM:=0
    seek cidfirma+cidpartner+qqkonto
    if !found()
     seek cidfirma+cidpartner+qqkonto2
     if !found()
       seek cidfirma+cidpartner+"!"
     endif
    endif

    do whilesc !eof() .and. IdFirma==cIdFirma .and. cIdpartner==idpartner
           if idkonto==qqkonto
                IF D_P=="1"
                  nDBHD+=iznosbhd
                  nDDEM+=iznosdem
                ELSE
                  nDBHD-=iznosbhd
                  nDDEM-=iznosdem
                endif
           elseif idkonto==qqkonto2
                IF D_P=="1"
                  nPBHD-=iznosbhd
                  nPDEM-=iznosdem
                ELSE
                  nPBHD+=iznosbhd
                  nPDEM+=iznosdem
                endif
           endif
           skip
     enddo

     fuslov:=.f.
     if  cNula=="D"
        if ( ndbhd<>0 .or. npbhd<>0 )
           fuslov:=.t.
        endif
     elseif cnula=="N"
        if ROUND(nDBHD-nPBHD,3)<>0
           fuslov:=.t.
        endif
     elseif cnula=="2"
        if ROUND(nDBHD-nPBHD,3)<>0   .and.  round(ndbhd,3)<>0  .and. round(npbhd,3)<>0
           fuslov:=.t.
           // i saldo 1 i saldo2 su zivi ,   i ukupan saldo <>0
        endif

     elseif cnula=="4"
        if round(ndbhd,3)<>0  .and. round(npbhd,3)<>0
           fuslov:=.t.
           // bitno je sa su saldo 1 i saldo2 su zivi
        endif
     endif

     if fUslov
      IF prow()>56+gPStranica
      	FF
	Zagl7()
      ENDIF
      
      @ prow()+1,0 SAY cidpartner
      
      select partn
      hseek cIdPartner
      select suban
      
      @ prow(),pcol()+1 SAY PADR(partn->naz, 25)
      
      IF cPG=="D"
      	@ prow(),pcol()+1 SAY PARTN->Mjesto
      EndIF
      
      nC1:=pcol()+1
      
      if cDinDem=="1"
         @ prow(),pcol()+1 SAY nDBHD PICTURE picBHD
         @ prow(),pcol()+1 SAY nPBHD PICTURE picBHD
         @ prow(),pcol()+1 SAY nDBHD-nPBHD PICTURE picBHD
         nDugBHD+=nDBHD
         nPotBHD+=nPBHD
      elseif cDinDem=="2"   // devize
         @ prow(),pcol()+1 SAY nDDEM PICTURE picbhd
         @ prow(),pcol()+1 SAY nPDEM PICTURE picbhd
         @ prow(),pcol()+1 SAY nDDEM-nPDEM PICTURE picbhd
         nDugDEM+=nDDEM
         nPotDEM+=nPDEM
      endif
     endif


enddo
? M
? "UKUPNO:"

if cDinDem=="1"
    @ prow(),nC1      SAY nDugBHD PICTURE picBHD
    @ prow(),pcol()+1 SAY nPotBHD PICTURE picBHD
    @ prow(),pcol()+1 SAY nDugBHD-nPotBHD pict picbhd
elseif cDinDem=="2"
    @ prow(),nC1      SAY nDugDEM PICTURE picBHD
    @ prow(),pcol()+1 SAY nPotDEM PICTURE picBHD
    @ prow(),pcol()+1 SAY nDugDEM-nPotDEM pict picbhd
endif
? m

FF
END PRINT
closeret
return



/*! \fn Zagl7()
 *  \brief Zaglavlje specifikacije konto/konto2
 */
static function Zagl7()
?
P_COND
?? "FIN: SPECIFIKACIJA SUBANALITIKE ",qqkonto,"-",qqkonto2," ZA "
if cDinDem=="1"
  ?? ValDomaca()
elseif cDinDem=="2"
  ?? ValPomocna()
endif
if !(empty(dDatOd) .and. empty(dDatDo))
  ?? "  ZA DOKUMENTE U PERIODU ",dDatOd,"-",dDatDo
endif
?? " NA DAN: "; ?? DATE()
@ prow(),125 SAY "Str:"+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ? "Firma:",cidfirma,PADR(partn->naz,25),partn->naz2
endif

select SUBAN

? m
IF cPG="D"
? PADR("PARTN.", __par_len) + " PARTNER                       MJESTO           saldo1         saldo2           saldo"
Else
? PADR("PARTN.", __par_len) + "  PARTNER                       saldo1           saldo2           saldo"
EndIF
? m
return



/*! \fn SpecPop()
 *  \brief Specifikacija konta za odredjene partnere
 */
function SpecPop()

local nCol1:=nCol2:=0

M:="----- ------- ----------------------------- ----------------- ---------------- ------------ ------------ ---------------- ------------"

cIdFirma:=gFirma
qqPartner:=qqKonto:=space(70)
picBHD:=FormPicL("9 "+gPicBHD,16)
picDEM:=FormPicL("9 "+gPicDEM,12)

O_PARTN

__par_len := LEN(partn->id)


Box("SSK",6,60,.f.)

do while .t.
 @ m_x+1,m_y+6 SAY "SPECIFIKACIJA KONTA ZA ODREDJENE PARTNERE"
 if gNW=="D"
   @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+5,m_y+2 SAY "Partner:" GET qqPartner pict "@!S50"
 @ m_x+6,m_y+2 SAY "Konta  :" GET  qqKonto pict "@!S50"
 READ; ESC_BCR
 aUsl1:=parsiraj(qqPartner,"idpartner")
 aUsl2:=parsiraj(qqKonto,"idkonto")
 if aUsl1<>NIL .and. aUsl2<>NIL; exit; endif
enddo

BoxC()

nDugBHD:=nPotBHD:=nUkDugBHD:=nUkPotBHD:=0
nDugDEM:=nPotDEM:=nUKDugDEM:=nUkPotDEM:=0

O_KONTO
O_SUBAN

SELECT SUBAN; set order to tag "2"  // idfirma+idpartner+idkonto
cIdFirma:=left(cIdFirma,2)

if ausl1<>".t." .or. ausl2<>".t."
  cFilt1 := aUsl1+".and."+aUsl2
  set filter to  &cFilt1
else
  set filter to
endif
hseek cIdFirma
EOF CRET


nStr:=0
START PRINT CRET


B:=0
do while cIdFirma==IdFirma .and. !eof()

   cIdKonto:=IdKonto
   cIdPartner:=IdPartner
   B:=0
   nUkDugBHD:=nUkPotBHD:=0
   nUKDugDEM:=nUkPotDEM:=0
   DO WHILESC cIdFirma==IdFirma .and. !EOF() .and. cIdPartner=IdPartner
      cIdKonto:=IdKonto
      if prow()==0; ZglSpSifK(); endif
      nDugBHD:=nPotBHD:=0
      nDugDEM:=nPotDEM:=0
      DO WHILESC cIdFirma==IdFirma .and.  !EOF() .and. cIdPartner==IdPartner .and. cIdKonto==IdKonto
         IF D_P="1"
            nDugBHD+=IznosBHD; nUkDugBHD+=IznosBHD
            nDugDEM+=IznosDEM; nUkDugDEM+=IznosDEM
         ELSE
            nPotBHD+=IznosBHD; nUkPotBHD+=IznosBHD
            nPotDEM+=IznosDEM; nUkPotDEM+=IznosDEM
         ENDIF
         SKIP
      ENDDO
      ? m
      @ prow()+1,1 SAY ++B PICTURE '9999'
      @ prow(),6 SAY cIdKonto
      SELECT KONTO; HSEEK cIdKonto
      aRez:=SjeciStr(naz,30)
      nCol2:=pcol()+1
      @ prow(),pcol()+1 SAY padr(aRez[1],30)
      nCol1:=pcol()+1
      @ prow(),pcol()+1 SAY nDugBHD PICTURE picBHD
      @ prow(),pcol()+1 SAY nPotBHD PICTURE picBHD
      @ prow(),pcol()+1 SAY nDugDEM PICTURE picDEM
      @ prow(),pcol()+1 SAY nPotDEM PICTURE picDEM

      nSaldo:=nDugBHD-nPotBHD
      nSaldo2:=nDugDEM-nPotDEM
      @ prow(),pcol()+1 SAY nSaldo  PICTURE picBHD
      @ prow(),pcol()+1 SAY nSaldo2 PICTURE picDEM

      for i:=2 to len(aRez)
         @ prow()+1,nCol2 say aRez[i]
      next

      SELECT SUBAN
      nDugBHD:=nPotBHD:=0; nDugDEM:=nPotDEM:=0

      IF prow()>60+gPStranica; FF; ENDIF
   ENDDO   // partner

   ? M
   ? "Uk:"
   @ prow(),PCOL()+1 SAY cIdPartner
   select PARTN; hseek cIdPartner
   @ prow(),pcol()+1 SAY left(naz,28)
   select SUBAN
   @ prow(),nCol1    SAY nUkDugBHD PICT picBHD
   @ prow(),pcol()+1 SAY nUkPotBHD PICT picBHD
   @ prow(),pcol()+1 SAY nUkDugDEM PICT picDEM
   @ prow(),pcol()+1 SAY nUkPotDEM PICT picDEM
   @ prow(),pcol()+1 SAY nUkDugBHD-nUkPotBHD  PICT picBHD
   @ prow(),pcol()+1 SAY nUkDugDEM-nUkPotDEM  PICT picDEM
   ? M

   ?
   ?

enddo

FF

END PRINT
CLOSERET
return



/*! \fn ZglSpSifK()
 *  \brief Zaglavlje specifikacije po kontima
 */
function ZglSpSifK()
?
P_COND
?? "FIN: SPECIFIKACIJA PARTNERA :"
@ prow(),pcol()+2 SAY "PO KONTIMA NA DAN :"
@ prow(),pcol()+2 SAY DATE()
@ prow(),125 SAY "Str:"+STR(++nStr,3)


if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ? "Firma:",cidfirma,PADR(partn->naz,25),partn->naz2
endif

? "----- ------- ----------------------------- ------------------------------------------------------------ -----------------------------"
? "*RED.* KONTO *       N A Z I V             *     K U M U L A T I V N I    P R O M E T                   *      S A L D O              "
? "                                            ------------------------------------------------------------ -----------------------------"
? "*BROJ*       *       K O N T A             *  DUGUJE   "+ValDomaca()+"  *  POTRA�UJE "+ValDomaca()+"* DUGUJE "+ValPomocna()+"* POTRA� "+ValPomocna()+"*    "+ValDomaca()+"        *    "+ValPomocna()+"   *"
? M

SELECT SUBAN
RETURN



/*! \fn SpecOstPop()
 *  \brief Specifikacija otvorenih stavki po kontima za partnera 
 */
function SpecOstPop()
*
local nCol1:=nCol2:=0

M:="----- ------- ----------------------------- ----------------- ---------------- ------------ ------------ ---------------- ------------"

cIdFirma:=gFirma
qqPartner:=qqKonto:=space(70)
picBHD:=FormPicL("9 "+gPicBHD,13)
picDEM:=FormPicL("9 "+gPicDEM,10)

O_PARTN

__par_len := LEN(partn->id)

Box("SSK",6,60,.f.)

do while .t.
 @ m_x+1,m_y+6 SAY "SPECIFIKACIJA KONTA ZA ODREDJENE PARTNERE"
 if gNW=="D"
   @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+5,m_y+2 SAY "Partner:" GET qqPartner pict "@!S50"
 @ m_x+6,m_y+2 SAY "Konta  :" GET  qqKonto pict "@!S50"
 READ; ESC_BCR
 aUsl:=parsiraj(qqPartner,"idpartner")
 aUsl2:=parsiraj(qqKonto,"idkonto")
 if aUsl<>NIL; exit; endif
enddo

BoxC()

nDugBHD:=nPotBHD:=nUkDugBHD:=nUkPotBHD:=0
nDugDEM:=nPotDEM:=nUKDugDEM:=nUkPotDEM:=0

O_KONTO
O_SUBAN

SELECT SUBAN; set order to tag "2"  // idfirma+idpartner+idkonto
cIdFirma:=left(cIdFirma,2)

cFilt1:=aUsl+".and."+aUsl2

cFilt1:=STRTRAN(cFilt1,".t..and.","")

IF !(cFilt1==".t.")
  set filter to &cFilt1
ENDIF

hseek cIdFirma
EOF CRET


nStr:=0
START PRINT CRET


B:=0
do while cIdFirma==IdFirma .and. !eof()

   cIdKonto:=IdKonto
   cIdPartner:=IdPartner
   B:=0
   nUkDugBHD:=nUkPotBHD:=0
   nUKDugDEM:=nUkPotDEM:=0
   DO WHILESC cIdFirma==IdFirma .and. !EOF() .and. cIdPartner=IdPartner
      cIdKonto:=IdKonto
      if prow()==0; ZglSpOstP(); endif
      nDugBHD:=nPotBHD:=0
      nDugDEM:=nPotDEM:=0
      DO WHILESC cIdFirma==IdFirma .and.  !EOF() .and. cIdPartner==IdPartner .and. cIdKonto==IdKonto
         IF D_P="1"
            nDugBHD+=IznosBHD; nUkDugBHD+=IznosBHD
            nDugDEM+=IznosDEM; nUkDugDEM+=IznosDEM
         ELSE
            nPotBHD+=IznosBHD; nUkPotBHD+=IznosBHD
            nPotDEM+=IznosDEM; nUkPotDEM+=IznosDEM
         ENDIF
         SKIP
      ENDDO
      ? m
      @ prow()+1,1 SAY ++B PICTURE '9999'
      @ prow(),6 SAY cIdKonto
      SELECT KONTO; HSEEK cIdKonto
      aRez:=SjeciStr(naz,30)
      nCol2:=pcol()+1
      @ prow(),pcol()+1 SAY padr(aRez[1],30)
      nCol1:=pcol()+1
      @ prow(),pcol()+1 SAY nDugBHD PICTURE picBHD
      @ prow(),pcol()+1 SAY nPotBHD PICTURE picBHD
      @ prow(),pcol()+1 SAY nDugDEM PICTURE picDEM
      @ prow(),pcol()+1 SAY nPotDEM PICTURE picDEM

      nSaldo:=nDugBHD-nPotBHD
      nSaldo2:=nDugDEM-nPotDEM
      @ prow(),pcol()+1 SAY nSaldo  PICTURE picBHD
      @ prow(),pcol()+1 SAY nSaldo2 PICTURE picDEM

      for i:=2 to len(aRez)
         @ prow()+1,nCol2 say aRez[i]
      next

      SELECT SUBAN
      nDugBHD:=nPotBHD:=0; nDugDEM:=nPotDEM:=0

      IF prow()>60+gPStranica; FF; ENDIF
   ENDDO   // partner

   ? M
   ? "Uk:"
   @ prow(),PCOL()+1 SAY cIdPartner
   select PARTN; hseek cIdPartner
   @ prow(),pcol()+1 SAY left(naz,28)
   select SUBAN
   @ prow(),nCol1    SAY nUkDugBHD PICT picBHD
   @ prow(),pcol()+1 SAY nUkPotBHD PICT picBHD
   @ prow(),pcol()+1 SAY nUkDugDEM PICT picDEM
   @ prow(),pcol()+1 SAY nUkPotDEM PICT picDEM
   @ prow(),pcol()+1 SAY nUkDugBHD-nUkPotBHD  PICT picBHD
   @ prow(),pcol()+1 SAY nUkDugDEM-nUkPotDEM  PICT picDEM
   ? M

   ?
   ?

enddo

FF

END PRINT
CLOSERET
return



/*! \fn ZglSpOstP()
 *  \brief Zaglavlje specifikacije otvorenih stavki partnera po kontima
 */
function ZglSpOstP()
?
P_COND
?? "FIN: SPECIFIKACIJA OTVORENIH STAVKI PARTNERA :"
@ prow(),pcol()+2 SAY "PO KONTIMA NA DAN :"
@ prow(),pcol()+2 SAY DATE()
@ prow(),125 SAY "Str:"+STR(++nStr,3)


if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ? "Firma:",cidfirma,PADR(partn->naz, 25),partn->naz2
endif

? "----- ------- ----------------------------- ------------------------------------------------------------ -----------------------------"
? "*RED.* KONTO *       N A Z I V             *     K U M U L A T I V N I    P R O M E T                   *      S A L D O              "
? "                                            ------------------------------------------------------------ -----------------------------"
? "*BROJ*       *       K O N T A             *  DUGUJE   "+ValDomaca()+"  *  POTRA�UJE "+ValDomaca()+"* DUGUJE "+ValPomocna()+"* POTRA� "+ValPomocna()+"*    "+ValDomaca()+"        *    "+ValPomocna()+"   *"
? M

SELECT SUBAN
RETURN




/*! \fn PregNDP()
 *  \brief Pregled novih dugovanja i potrazivanja
 */
function PregNDP()
picBHD := FormPicL("9 " + gPicBHD, 17)
private cDP:="1"
private cSortPar:="S"
private cMjestoPar:=SPACE(80)

O_PARTN
__par_len := LEN( partn->id )

O_KONTO

Box("#PREGLED NOVIH DUGOVANJA/POTRAZIVANJA",15,72)

	if gNW=="D"
		cIdFirma:=gfirma
		@ m_x+1,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
	else
		cidfirma:="10"
		@ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
	endif
	@ m_x+2,m_y+2 SAY "Dugovanja/Potrazivanja (1/2):" get cDP valid cDP $ "12"
	read
	ESC_BCR

	if cDP=="2"
		cIdkonto := padr("5410",7)
	else
		cIdkonto := padr("2110",7)
	endif
	
	dDatOd := DATE() - 7
	dDatDo := DATE()
	
	private cPrik:="2"
	private cDinDem:="1"
	private cPG:="D"
	private cPoRP:="2"
	
	@ m_x+3,m_y+2 SAY "Konto:" GET cIdkonto valid p_kontoFin(@cidkonto)
	@ m_x+5,m_y+2 SAY "Period:" GET dDatOd
	@ m_x+5,col()+2 SAY "do" GET dDatDo valid dDatDo>=dDatOd
	if gVar1=="0"
		@ m_x+6,m_y+2 sAY "Prikaz "+ALLTRIM(ValDomaca())+"/"+ALLTRIM(ValPomocna())+" (1/2)"  GET cDinDEM valid cdindem $ "12"
	endif
	@ m_x+ 8,m_y+2 SAY "Prikaz: (1) stavki kod kojih nije bilo promjena u toku tekuce godine"
	@ m_x+ 9,m_y+2 SAY "        (2) stavki kod kojih nije bilo promjena u zadanom periodu"
	@ m_x+10,m_y+2 SAY "        (3) samo stavki kod kojih je bilo promjena u zadanom periodu" GET cPrik valid cprik $ "123"
	@ m_x+12,m_y+2 SAY "Prikazi mjesto partnera (D/N)" GET cPG valid cPG $ "DN"

	if gRj=="D"
		@ m_x+13,m_y+2 SAY "1-po RJ  ili  2-po partnerima (1/2)" GET cPoRP valid cPoRP $ "12"
	endif

	if (cPoRP=="2") // po partnerima
		@ m_x+14, m_y+2 SAY "Sortiranje partnera (S-po sifri,N-po nazivu)" GET cSortPar VALID cSortPar$"SN" PICT "@!"
		@ m_x+15, m_y+2 SAY "Uslov za mjesto partnera (prazno-sva)" GET cMjestoPar PICT "@S25"
	endif

	do while .t.
		read
		ESC_BCR
		aUslMP:=Parsiraj(cMjestoPar,"partn->mjesto")
		if aUslMP<>nil
			exit
		endif
	enddo

BoxC()

O_SUBAN

if cPoRP=="1"
	O_RJ
	select suban
	index on idfirma+idkonto+idrj+dtos(datdok) to SUBSUB
	set order to tag "SUBSUB"
else
	if cSortPar=="N" .or. !empty(cMjestoPar)
		set relation to suban->idpartner into partn
	endif
	if cSortPar=="N"
		index on idfirma+idkonto+PADR(partn->naz, 25)+idpartner+dtos(datdok) to SUBSUB
		set order to tag "SUBSUB"
	endif
	if !empty(cMjestoPar)
		set filter to &aUslMP
	endif
endif

hseek cidfirma+cidkonto
EOF CRET

if cPG=="D"
	m := REPLICATE("-", __par_len)
	m += " "
	m += REPLICATE("-", 25)
	m += " --------------- ------------------ ----------------- ----------------- ----------------- ---------------"
else
	m := REPLICATE("-", __par_len)
	m += " "
	m += REPLICATE("-", 25)
	m += " ------------------ ----------------- ----------------- ----------------- -------------------"
endif

START PRINT CRET
zagl9()
private nTPS1:=nTPS2:=nTS1:=nTS2:=nTT1:=nTT2:=0
nCol1:=60

do while cidfirma==idfirma .and. !eof() .and. cidkonto==idkonto

	if cPoRP=="1"
		cIdPartner:=idrj
	else
		cIdPartner:=idpartner
	endif
	
	nPS1:=0
	nPS2:=0
	
	fYear:=.f.

	do while cidfirma==idfirma .and. !eof() .and. cidkonto==idkonto .and. IF(cPoRP=="1",idrj,idpartner)==cidpartner .and. datdok<dDatOd

		if d_p=="1"
			nPS1+=iznosbhd
			nPS2+=iznosdem
		else
			nPS1-=iznosbhd
			nPS2-=iznosdem
		endif

		if YEAR(datdok) == YEAR(DATE())  
			// bilo je prometa u toku godine
			fYear:=.t.
		endif

		skip 1
	enddo

	nS1:=nS2:=0
	nT1:=nT2:=0

	do while cidfirma==idfirma .and. !eof() .and. cidkonto==idkonto .and. IF(cPoRP=="1",idrj,idpartner)==cidpartner .and. datdok<=dDatDo
		if cDP=="1" // duznici
			if d_p=="1"
				nS1+=iznosbhd
				nS2+=iznosdem
			else
				nT1+=iznosbhd
				nT2+=iznosdem
			endif
		else // dobavljaci
			if d_p=="1"
				nT1+=iznosbhd
				nT2+=iznosdem
			else
				nS1+=iznosbhd
				nS2+=iznosdem
			endif
		endif

		if year(datdok)==year(date())  // bilo je prometa u toku godine
			fYear:=.t.
		endif

		skip 1
	enddo

	do while cidfirma==idfirma .and. !eof() .and. cidkonto==idkonto .and. IF(cPoRP=="1",idrj,idpartner)==cidpartner
		skip 1
	enddo

	if cDP=="2"  // potrazivanja
		nPS1:=-nPs1
		nPS2:=-nPs2
	endif

	if (cPrik=="1") .or. (cPrik=="2" .and. fyear) .or. (cPrik=="3" .and. (ns1<>0 .or. ns2<>0 .or. nt1<>0 .or. nt2<>0))

		if cPoRP=="1"
			select rj
			hseek cidpartner
			select suban
		else
			select partn
			hseek cidpartner
			select suban
		endif

		if prow()>60+gPStranica
			FF
			zagl9()
		endif

		? cIdPartner+" "
		
		if cPoRP=="1"
			?? PADR( RJ->naz, 36)
		else
		
			if cPG=="N"
				?? PADR(partn->naz, 25)
			else
				?? Left (PARTN->Naz, 25), LEFT (PARTN->Mjesto, 15)
			endif
		
		endif

		nCol1:=pcol()+1
		if cDinDEM=="1"
			@ prow(),pcol()+1 SAY nPS1 pict picbhd
			@ prow(),pcol()+1 SAY nS1 pict picbhd
			@ prow(),pcol()+1 SAY nT1 pict picbhd
			@ prow(),pcol()+1 SAY nPS1+nS1-nT1 pict picbhd
		else
			@ prow(),pcol()+1 SAY nPS2 pict picbhd
			@ prow(),pcol()+1 SAY nS2 pict picbhd
			@ prow(),pcol()+1 SAY nT2 pict picbhd
			@ prow(),pcol()+1 SAY nPS2+nS2-nT2 pict picbhd
		endif

		@ prow(),pcol()+2 SAY IIF (cPG="N", "__________________", "______________")
		nTPS1+=nPS1
		nTPS2+=nPS2
		nTS1+=nS1
		nTS2+=nS2
		nTT1+=nT1
		nTT2+=nT2
	endif

enddo

? m
? "  UKUPNO:"
if cDinDEM=="1"
	@ prow(),nCol1 SAY nTPS1 pict picbhd
	@ prow(),pcol()+1 SAY nTS1 pict picbhd
	@ prow(),pcol()+1 SAY nTT1 pict picbhd
	@ prow(),pcol()+1 SAY nTPS1+nTS1-nTT1 pict picbhd
else
	@ prow(),ncol1 SAY nTPS2 pict picbhd
	@ prow(),pcol()+1 SAY nTS2 pict picbhd
	@ prow(),pcol()+1 SAY nTT2 pict picbhd
	@ prow(),pcol()+1 SAY nTPS2+nTS2-nTT2 pict picbhd
endif
? m
FF
END PRINT
return




/*! \fn Zagl9()
 *  \brief Zaglavlje pregleda novih dugovanja i potrazivanja
 *  \param
 */
function Zagl9()
local nTArea := SELECT()

?
P_COND
?? space(35)

B_ON

?? "PREGLED ", iif(cDP=="1", "DUGOVANJA", "POTRA�IVANJA" )
?? ", ZA PERIOD ", dDatOd, "-", dDatDo

// uzmi konto
select konto
hseek cIdKonto
select (nTArea)

? SPACE(2)
?? ALLTRIM(cIdKonto), ":", ALLTRIM( konto->naz ) 

if cPoRP == "1"
	? SPACE(2)
	?? "PO RADNIM JEDINICAMA"
endif

B_OFF

if !empty(cMjestoPar)
	? "Zadan je uslov za mjesto partnera:'"+TRIM(cMjestoPar)+"'"
endif

if cDP=="1"
	
	? m
	
	if cPoRP=="1"
		
		? SPACE(__par_len) + "  Naziv                                 Prethodno           Novo             Napla�eno         Sada�nje          Napomena"
		? SPACE(__par_len) + "                                          stanje          potra�ivanje                           stanje"
	
	elseif cPG=="N"
		
		? SPACE(__par_len) + "    Naziv                     Prethodno           Novo             Napla�eno         Sadasnje          Napomena"
		? SPACE(__par_len) + "                               stanje          potra�ivanje                           stanje"
	
	else
		
		? SPACE(__par_len) + "  Naziv                  Mjesto         Prethodno           Novo             Napla�eno         Sada�nje          Napomena"
		? SPACE(__par_len) + "                                          stanje          potra�ivanje                           stanje"
	
	endif
	
	? m
else
	? m
	if cPoRP=="1"
		? SPACE(__par_len) + "  Naziv                                 Prethodno           Prispjelo         Placeno          Sada�nje          Napomena"
		? SPACE(__par_len) + "                                          stanje                                                 stanje"
	elseif cPG=="N"
		? SPACE(__par_len) + "  Naziv                       Prethodno         Prispjelo          Placeno          Sada�nje          Napomena"
		? SPACE(__par_len) + "                                stanje                                               stanje"
	else
		? SPACE(__par_len) + "  Naziv                  Mjesto         Prethodno           Prispjelo         Placeno          Sada�nje          Napomena"
		? SPACE(__par_len) + "                                          stanje                                                 stanje"
	endif
	? m
endif

return



/*! \fn UpitK1K4(mxplus,lK)
 *  \brief Pita za polja od K1 do K4
 *  \param mxplus
 *  \param lK
 */
function UpitK1K4( mxplus, lK )
local _k1, _k2, _k3, _k4
local _params := fin_params()

_k1 := _params["fin_k1"]
_k2 := _params["fin_k2"]
_k3 := _params["fin_k3"]
_k4 := _params["fin_k4"]

if lK == NIL
    lK := .t.
endif

if lK
    if _k1
        @ m_x + mxplus, m_y + 2 SAY "K1 (9 svi) :" GET cK1
    endif
    if _k2
        @ m_x + mxplus, col() + 2 SAY "K2 (9 svi) :" GET cK2
    endif
    if _k3
        @ m_x + mxplus + 1, m_y + 2 SAY "K3 ("+cK3+" svi):" GET cK3
    endif
    if _k4
        @ m_x + mxplus + 1, col() + 1 SAY "K4 (99 svi):" GET cK4
    endif
endif

if gRj == "D"
    if gDUFRJ == "D" .and. ( PROCNAME(1) == "SPECPOKP" .or. PROCNAME(1) == "SUBKART" )
        @ m_x + mxplus + 2, m_y + 2 SAY "RJ:" GET cIdRj PICT "@!S20"
    else
        @ m_x + mxplus + 2, m_y + 2 SAY "RJ:" GET cIdRj
    endif
endif

if gTroskovi=="D"
    @ m_x + mxplus + 3, m_y + 2 SAY "Funk    :" GET cFunk
    @ m_x + mxplus + 4, m_y + 2 SAY "Fond    :" GET cFond
endif

return



/*! \fn CistiK1K4(lK)
 *  \brief Cisti polja od K1 do K4
 *  \param lK
 */
 
function CistiK1K4(lK)
IF lK==NIL; lK:=.t.; ENDIF
IF lK
  if ck1=="9"; ck1:=""; endif
  if ck2=="9"; ck2:=""; endif
  if ck3==REPL("9",LEN(ck3))
    ck3:=""
  else
    ck3:=k3u256(ck3)
  endif
  if ck4=="99"; ck4:=""; endif
ENDIF
IF gDUFRJ=="D" .and. ( PROCNAME(1)=="SPECPOKP" .or. PROCNAME(1)=="SUBKART" )
  cIdRj:=TRIM(cIdRj)
ELSE
  if cIdRj=="999999"; cidrj:=""; endif
  if "." $ cidrj
    cidrj:=trim(strtran(cidrj,".",""))
    // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
  endif
ENDIF
if cFunk=="99999"; cFunk:=""; endif
if "." $ cfunk
  cfunk:=trim(strtran(cfunk,".",""))
endif
if cFond=="9999"; cFond:=""; endif
if "." $ cfond
  cfond:=trim(strtran(cfond,".",""))
endif
return



/*! \fn PrikK1K4(lK)
 *  \brief Prikazi polja od K1 do K4
 *  \param lK
 */
 
function PrikK1K4(lK)

local fProso:=.f.
local nArr:=SELECT()
local _fakt_params := fakt_params()
local _fin_params := fin_params()

local lVrsteP := _fakt_params["fakt_vrste_placanja"]

IF lK==NIL
	lK:=.t.
ENDIF

IF lVrsteP
  	SELECT (F_VRSTEP)
  	IF !USED()
    		O_VRSTEP
  	ENDIF
  	SELECT (nArr)
ENDIF

cM:=replicate("-",55)

cStr:="Pregled odabranih kriterija :"

if gRJ=="D" .and. len(cIdRJ)<>0
  cRjNaz := ""
  nArr := SELECT()
  O_RJ
  select rj
  hseek cIdRj
  
  if PADR( rj->id, 6 ) == PADR( cIdRj, 6 )
  	cRjNaz:=rj->naz
  endif
  
  select (nArr)
  if !fproso
   ? cM
   ? cStr
   fProso:=.t.
  endif
  ? "Radna jedinica: " + cIdRj + " - " + cRjNaz  
endif
IF lK
  if _fin_params["fin_k1"] .and. !len(ck1)==0
    if !fproso
     ? cM
     ? cStr
     fProso:=.t.
    endif
    ? "K1 =",ck1
  endif
  if _fin_params["fin_k2"] .and. !len(ck2)=0
    if !fproso
     ? cM
     ? cStr
     fProso:=.t.
    endif
    ? "K2 =",ck2
  endif
  if _fin_params["fin_k3"] .and. !len(ck3)=0
    if !fproso
     ? cM
     ? cStr
     fProso:=.t.
    endif
    ? "K3 =",k3iz256(ck3)
  endif
  if _fin_params["fin_k4"] .and. !len(ck4)=0
    if !fproso
     ? cM
     ? cStr
     fProso:=.t.
    endif
    ? "K4 =",ck4
    IF lVrsteP .and. len(ck4)>1
      ?? "-"+Ocitaj(F_VRSTEP,ck4,"naz")
    ENDIF
  endif
ENDIF
if gTroskovi=="D" .and. len(cFunk)<>0
  if !fproso
   ? cM
   ? cStr
   fProso:=.t.
  endif
  ? "Funkcionalna klasif. ='"+cFunk+"'"
endif
if gTroskovi=="D" .and. len(cFond)<>0
  if !fproso
   ? cM
   ? cStr
   fProso:=.t.
  endif
  ? "                Fond ='"+cFond+"'"
endif

if fproso
 ? cM
 ?
endif
return



/*! \fn PartVanProm()
 *  \brief Partneri van prometa
 */
 
function PartVanProm()

LOCAL   dDatOd := CTOD (""), dDatDo := DATE ()
private picBHD:=FormPicL(gPicBHD,16)
private picDEM:=FormPicL(gPicDEM,12)
private cIdKonto := SPACE (7), cIdFirma := SPACE (LEN (gFirma)), ;
        cKrit := SPACE (60), aUsl
  O_KONTO
  O_PARTN
  O_SUBAN
  __par_len := LEN(partn->id)
  *
  Box (, 11, 60)
  @ m_x,m_y+15 SAY "PREGLED PARTNERA BEZ PROMETA"
  if gNW=="D"
    cIdFirma:=gFirma
    @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
  else
    @ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
  endif
  @ m_x+4,m_y+2 SAY " Konto (prazno-svi)" GET cIdKonto ;
                    VALID Empty (cIdKonto) .or. P_KontoFin (@cIdKonto)
  @ m_x+6,m_y+2 SAY "Kriterij za telefon" GET cKrit PICT "@S30@!";
                    VALID {|| aUsl := Parsiraj (cKrit, "Telefon"), ;
                              IIF (aUsl==NIL, .F., .T.)}
  @ m_x+8,m_y+2 SAY "         Pocevsi od" GET dDatOd ;
                    VALID dDatOd <= dDatDo
  @ m_x+10,m_y+2 SAY "       Zakljucno sa" GET dDatDo ;
                    VALID dDatOd <= dDatDo
  READ
  ESC_BCR
  BoxC()

  START PRINT CRET

  INI
  ?
  F10CPI
  ?? SPACE (5) + "Firma:", gNFirma
  ? PADC ("PARTNERI BEZ PROMETA", 80)
  ? PADC ("na dan "+DTOC (DATE())+".", 80)
  ?
  ? SPACE (5)+"    Konto:", ;
    IIF (Empty (cIdKonto), "SVI", cIdKonto+Ocitaj (F_KONTO, cIdKonto, "Naz"))
  ? SPACE (5)+" Kriterij:", cKrit
  ? SPACE (5)+"Za period:", IF (Empty (dDatOd), "", DTOC (dDatOd)+" ")+;
    "do", DTOC (dDatDo)
  ?
  ? SPACE (5)+PADR("Sifra", __par_len), PADR("NAZIV", 25), ;
    PADR ("MJESTO", LEN (PARTN->Mjesto)), PADR ("ADRESA", LEN (PARTN->Adresa))
  ? SPACE (5) + REPL("-", __par_len), REPL ("-", 25 ), ;
    REPL ("-", LEN (PARTN->Mjesto)), REPL ("-", LEN (PARTN->Adresa))

  nBrPartn := 0
  SELECT SUBAN
  set order to tag "2"

  SELECT PARTN
  IF !Empty (aUsl)
    Set filter to &aUsl
  ENDIF
  GO TOP
  WHILE ! EOF()
    fNema := .T.
    SELECT SUBAN
    Seek cIdFirma+PARTN->Id
    While ! Eof() .and. SUBAN->(IdFirma+IdPartner)==(cIdFirma+PARTN->Id)
      IF (Empty (cIdKonto) .or. SUBAN->IdKonto==cIdKonto) .and.;
         dDatOd <= DatDok .and. DatDok <= dDatDo
        fNema := .F.
        EXIT
      ENDIF
      SKIP
    End
    IF fNema
      ? SPACE (5) + PARTN->Id, PADR(PARTN->Naz, 25), PARTN->Mjesto, PARTN->Adresa
      nBrPartn ++
    ENDIF
    SELECT PARTN
    SKIP
  END
  ? SPACE (5) + REPL("-", __par_len), REPL ("-", 25 ), ;
    REPL ("-", LEN (PARTN->Mjesto)), REPL ("-", LEN (PARTN->Adresa))
  ?
  ? SPACE (5)+ "Ukupno izlistano", Alltrim (Str (nBrPartn)), ;
    "partnera bez prometa"
  EJECT
  END PRINT
CLOSERET
return





/*! \fn SpecPoDosp(lKartica)
 *  \brief Otvorene stavke grupisano po brojevima veze
 *  \param lKartica
 */
 
function SpecPoDosp(lKartica)
local nCol1:=72
local cSvi:="N"
local lPrikSldNula:=.f.
local lExpRpt := .f.
local cExpRpt := "N"
local aExpFld 
local cStart
local cP_naz := ""
private cIdPartner

IF lKartica==NIL
	lKartica:=.f.
ENDIF

IF lKartica
	cPoRN:="D"
ELSE
	cPoRN:="N"
ENDIF

cDokument:=SPACE(8)

picBHD := FormPicL(gPicBHD, 14)
picDEM := FormPicL(gPicDEM, 10)

IF gVar1 == "0"
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
cIdkonto:=SPACE(7)
cIdPartner:=PADR("", __par_len)
dNaDan:=DATE()
cOpcine:=SPACE(20)
cValuta:="1"
cPrikNule:="N"

cSaRokom:="N"
nDoDana1 :=  8
nDoDana2 := 15
nDoDana3 := 30
nDoDana4 := 60

PICPIC := PADR( fetch_metric( "fin_spec_po_dosp_picture", NIL, "99999999.99" ), 15 )

Box(,18,60)

if gNW=="D"
      	@ m_x+1,m_y+2 SAY "Firma "
	?? gFirma,"-",gNFirma
else
	@ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma ;
		VALID {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif

@ m_x+ 2,m_y+2 SAY "Konto:               " GET cIdkonto   pict "@!"  valid P_kontoFin(@cIdkonto)
IF cPoRN=="D"
	@ m_x+ 3,m_y+2 SAY "Partner (prazno svi):" GET cIdpartner pict "@!"  valid empty(cIdpartner)  .or. ("." $ cidpartner) .or. (">" $ cidpartner) .or. P_Firma(@cIdPartner)
ENDIF
//    @ m_x+ 5,m_y+2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno valid cPrelomljeno $ "DN" pict "@!"
@ m_x+ 6,m_y+2 SAY "Izvjestaj se pravi na dan:" GET dNaDan
@ m_x+ 7,m_y+2 SAY "Prikazati rocne intervale (D/N) ?" GET cSaRokom VALID cSaRokom$"DN" PICT "@!"
@ m_x+ 8,m_y+2 SAY "Interval 1: do (dana)" GET nDoDana1 WHEN cSaRokom=="D" PICT "999"
@ m_x+ 9,m_y+2 SAY "Interval 2: do (dana)" GET nDoDana2 WHEN cSaRokom=="D" PICT "999"
@ m_x+10,m_y+2 SAY "Interval 3: do (dana)" GET nDoDana3 WHEN cSaRokom=="D" PICT "999"
@ m_x+11,m_y+2 SAY "Interval 4: do (dana)" GET nDoDana4 WHEN cSaRokom=="D" PICT "999"
@ m_x+13,m_y+2 SAY "Prikaz iznosa (format)" GET PICPIC PICT "@!"
@ m_x+14,m_y+2 SAY "Uslov po opcini (prazno - nista)" GET cOpcine
@ m_x+15,m_y+2 SAY "Prikaz stavki kojima je saldo 0 (D/N)?" GET cPrikNule VALID cPrikNule $ "DN" PICT "@!"

if cPoRN=="N"
	@ m_x+16,m_y+2 SAY "Prikaz izvjestaja u (1)KM (2)EURO" GET cValuta VALID cValuta$"12"
endif
@ m_x+18,m_y+2 SAY "Export izvjestaja u DBF ?" GET cExpRpt VALID cExpRpt$"DN" PICT "@!"
read
ESC_BCR
Boxc()

PICPIC := ALLTRIM(PICPIC)
set_metric( "fin_spec_po_dosp_picture", NIL, PICPIC )  

lExpRpt := (cExpRpt == "D")

if cPrikNule == "D"
	lPrikSldNula := .t.
endif

if "." $ cIdPartner
	cIdPartner:=StrTran(cIdPartner,".","")
    	cIdPartner:=Trim(cIdPartner)
endif
if ">" $ cIdPartner
	cIdPartner:=strtran(cIdPartner,">","")
     	cIdPartner:=trim(cIdPartner)
     	fVeci:=.t.
endif
if empty(cIdpartner)
	cIdPartner:=""
endif

cSvi := cIdpartner

if lExpRpt == .t.
	aExpFld := get_ost_fields( cSaRokom, __par_len )
	t_exp_create( aExpFld )
endif

select (F_TRFP2)
if !used()
	O_TRFP2
endif

hseek "99 " + LEFT(cIdKonto, 1)
do while !EOF() .and. IDVD=="99" .and. TRIM(idkonto)!=LEFT(cIdKonto,LEN(TRIM(idkonto)))
	skip 1
enddo

if idvd=="99" .and. TRIM(idkonto)==LEFT(cIdKonto,LEN(TRIM(idkonto)))
	cDugPot:=D_P
else
	cDugPot:="1"
    	Box(,3,60)
      	@ m_x+2,m_y+2 SAY "Konto "+cIdKonto+" duguje / potrazuje (1/2)" get cdugpot  VALID cdugpot$"12" PICT "9"
      	READ
    	Boxc()
endif

fin_create_pom_table( nil, __par_len)  
// kreiraj pomocnu bazu

O_TRFP2
O_SUBAN
O_PARTN
O_KONTO

IF cPoRN=="D"
	gaZagFix:={5,3}
ELSE
  	IF cSaRokom=="N"
   		gaZagFix:={4,4}
  	ELSE
    		gaZagFix:={4,5}
  	ENDIF
ENDIF

START PRINT CRET

nUkDugBHD:=0
nUkPotBHD:=0

select suban
set order to tag "3"

if cSvi=="D"
	seek cIdFirma + cIdKonto
else
 	seek cIdFirma + cIdKonto + cIdPartner
endif

DO WHILESC !EOF() .and. idfirma==cIdfirma .AND. cIdKonto==IdKonto
	
	cIdPartner:=idpartner
	nUDug2:=0
	nUPot2:=0
    	nUDug:=0
	nUPot:=0
    	
	fPrviprolaz:=.t.
    	
	DO WHILESC !EOF() .and. idfirma==cIdfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner
		
		cBrDok:=BrDok
		cOtvSt:=otvst
          	nDug2:=nPot2:=0
          	nDug:=nPot:=0
          	aFaktura:={CTOD(""),CTOD(""),CTOD("")}
          	
		DO WHILESC !EOF() .and. idfirma==cIdfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner .and. brdok==cBrDok
             		
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

          	if round(ndug-npot,2) == 0
             		// nista
          	else
             		fPrviProlaz:=.f.
             		if cPrelomljeno=="D"
                		if (ndug-npot)>0
                   			nDug:=nDug-nPot
                   			nPot:=0
                		else
                   			nPot:=nPot-nDug
                   			nDug:=0
                		endif
                		if (ndug2-npot2)>0
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
		ZSpecPoDosp( nil, nil, PICPIC )
	ENDIF
	
	if (!fveci .and. idpartner=cSvi) .or. fVeci
    	
	else
      		exit
    	endif
enddo

SELECT POM
IF cSaRokom=="D"
	INDEX ON IDPARTNER+OTVST+Rocnost()+DTOS(DATDOK)+DTOS(IIF(EMPTY(DATVAL),DATDOK,DATVAL))+BRDOK TAG "2"
ELSE
	INDEX ON IDPARTNER+OTVST+DTOS(DATDOK)+DTOS(IIF(EMPTY(DATVAL),DATDOK,DATVAL))+BRDOK TAG "2"
ENDIF
SET ORDER TO TAG "2" 
GO TOP

nTUDug:=nTUPot:=nTUDug2:=nTUPot2:=0
nTUkUVD:=nTUkUVP:=nTUkUVD2:=nTUkUVP2:=0
nTUkVVD:=nTUkVVP:=nTUkVVD2:=nTUkVVP2:=0

IF cSaRokom=="D"
          //  D,TD    P,TP   D2,TD2  P2,TP2
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
ENDIF

cLastIdPartner:=""
IF cPoRN=="N"
	fPrviProlaz:=.t.
ENDIF

DO WHILE !EOF()
	
	IF cPoRN=="D"
    		fPrviProlaz:=.t.
  	ENDIF
  	
	cIdPartner:=IDPARTNER
	
	// provjeri saldo partnera
	if !lPrikSldNula .and. saldo_nula(cIdPartner)
		skip
		loop
	endif
	
	// provjeri opcine
	if !EMPTY(cOpcine)
		select partn
		seek cIdPartner
		if AT(partn->idops, cOpcine)<>0
			select pom
			skip
			loop
		endif
  		select pom
	endif
	
	nUDug:=nUPot:=nUDug2:=nUPot2:=0
  	nUkUVD:=nUkUVP:=nUkUVD2:=nUkUVP2:=0
  	nUkVVD:=nUkVVP:=nUkVVD2:=nUkVVP2:=0
	
	cFaza:=otvst
	
	IF cSaRokom=="D"
   		FOR i:=1 TO LEN(anInterUV)
     			FOR j:=1 TO LEN(anInterUV[i])
       				anInterUV[i,j,1]:=0
       				anInterVV[i,j,1]:=0
     			NEXT
   		NEXT
   		nFaza:=RRocnost()
  	ENDIF

	IF prow() > 52 + gPStranica
		FF
		ZSpecPoDosp(.t., nil, PICPIC )
		fPrviProlaz:=.f.
	ENDIF
    		
	if fPrviProlaz
       		ZSpecPoDosp(nil, nil, PICPIC )
       		fPrviProlaz:=.f.
    	endif

    	select pom
    
	DO WHILESC !EOF() .and. cIdPartner==IdPartner
    		
		IF cPoRn=="D"
            ? datdok, datval, PADR(brdok,10)
      		nCol1:=pcol()+1
      		?? " "
      		?? TRANSFORM(dug, picbhd), TRANSFORM(pot, picbhd), TRANSFORM(dug-pot, picbhd)
      		IF gVar1=="0"
        		?? " "+TRANSFORM(dug2,picdem), TRANSFORM(pot2,picdem), TRANSFORM(dug2-pot2,picdem)
      		ENDIF
    	ELSEIF cLastIdPartner!=cIdPartner .or. LEN(cLastIdPartner)<1
     		Pljuc(cIdPartner)
      		cP_naz := PADR(Ocitaj(F_PARTN,cIdPartner,"naz"), 25)
      		PPljuc( cP_naz )
			cLastIdPartner:=cIdPartner
    	ENDIF
    		
        IF otvst==" "
      		IF cPoRn=="D"
        		?? "   U VALUTI"+IF(cSaRokom=="D",IspisRocnosti(),"")
      		ENDIF
      		nUkUVD  += Dug 
			nUkUVP  += Pot
			nUkUVD2 += Dug2
			nUkUVP2 += Pot2
      		IF cSaRokom=="D"
       			anInterUV[nFaza,1,1] += dug
       			anInterUV[nFaza,2,1] += pot
       			anInterUV[nFaza,3,1] += dug2
       			anInterUV[nFaza,4,1] += pot2
      		ENDIF
    	ELSE
      		IF cPoRn=="D"
        		?? " VAN VALUTE"+IF(cSaRokom=="D",IspisRocnosti(),"")
      		ENDIF
      		nUkVVD  += Dug 
			nUkVVP  += Pot
			nUkVVD2 += Dug2
			nUkVVP2 += Pot2
      		IF cSaRokom=="D"
       			anInterVV[nFaza,1,1] += dug
       			anInterVV[nFaza,2,1] += pot
       			anInterVV[nFaza,3,1] += dug2
       			anInterVV[nFaza,4,1] += pot2
      		ENDIF
    	ENDIF
    	nUDug+=Dug
		nUPot+=Pot
    	nUDug2+=Dug2
		nUPot2+=Pot2
    		
        SKIP 1
        //  znaci da treba
    	IF cFaza!=otvst .or. EOF() .or. cIdPartner!=idpartner //<-� prikazati
      		IF cPoRn=="D"
				? m
			ENDIF                           //  � subtotal
      		IF cFaza==" "
        		IF cSaRokom=="D"
         			SKIP -1
         			IF cPoRn=="D"
           				? "UK.U VALUTI"+IspisRocnosti()+":"
						@ prow(),nCol1 SAY anInterUV[nFaza,1,1] PICTURE picBHD
           				@ prow(),pcol()+1 SAY anInterUV[nFaza,2,1] PICTURE picBHD
           				@ prow(),pcol()+1 SAY anInterUV[nFaza,1,1]-anInterUV[nFaza,2,1] PICTURE picBHD
           					
						if gVar1=="0"
             						@ prow(),pcol()+1 SAY anInterUV[nFaza,3,1] PICTURE picdem
             						@ prow(),pcol()+1 SAY anInterUV[nFaza,4,1] PICTURE picdem
             						@ prow(),pcol()+1 SAY anInterUV[nFaza,3,1]-anInterUV[nFaza,4,1] PICTURE picdem
           				endif
         			endif
         			anInterUV[nFaza,1,2] += anInterUV[nFaza,1,1]
         			anInterUV[nFaza,2,2] += anInterUV[nFaza,2,1]
         			anInterUV[nFaza,3,2] += anInterUV[nFaza,3,1]
         			anInterUV[nFaza,4,2] += anInterUV[nFaza,4,1]
         			IF cPoRn=="D"
						? m
					ENDIF
         			SKIP 1
        		ENDIF
        		IF cPoRn=="D"
          			? "UKUPNO U VALUTI:"
				    @ prow(),nCol1 SAY nUkUVD PICTURE picBHD
          			@ prow(),pcol()+1 SAY nUkUVP PICTURE picBHD
          			@ prow(),pcol()+1 SAY nUkUVD-nUkUVP PICTURE picBHD
				    if gVar1=="0"
            				@ prow(),pcol()+1 SAY nUkUVD2 PICTURE picdem
            				@ prow(),pcol()+1 SAY nUkUVP2 PICTURE picdem
            				@ prow(),pcol()+1 SAY nUkUVD2-nUkUVP2 PICTURE picdem
          			endif
        		ENDIF
        		nTUkUVD  += nUkUVD 
			    nTUkUVP  += nUkUVP
        		nTUkUVD2 += nUkUVD2
			    nTUkUVP2 += nUkUVP2
      		ELSE
        		IF cSaRokom=="D"
         			SKIP -1
         			IF cPoRn=="D"
           				? "UK.VAN VALUTE"+IspisRocnosti()+":"
					@ prow(),nCol1 SAY anInterVV[nFaza,1,1] PICTURE picBHD
           				@ prow(),pcol()+1 SAY anInterVV[nFaza,2,1] PICTURE picBHD
           				@ prow(),pcol()+1 SAY anInterVV[nFaza,1,1]-anInterVV[nFaza,2,1] PICTURE picBHD
           				if gVar1=="0"
             					@ prow(),pcol()+1 SAY anInterVV[nFaza,3,1] PICTURE picdem
             					@ prow(),pcol()+1 SAY anInterVV[nFaza,4,1] PICTURE picdem
             					@ prow(),pcol()+1 SAY 44 PICTURE picdem
             					@ prow(),pcol()+1 SAY anInterVV[nFaza,3,1]-anInterVV[nFaza,4,1] PICTURE picdem
           				endif
         			ENDIF
         			anInterVV[nFaza,1,2] += anInterVV[nFaza,1,1]
         			anInterVV[nFaza,2,2] += anInterVV[nFaza,2,1]
         			anInterVV[nFaza,3,2] += anInterVV[nFaza,3,1]
         			anInterVV[nFaza,4,2] += anInterVV[nFaza,4,1]
         			IF cPoRn=="D"
					? m
				ENDIF
         			SKIP 1
        		ENDIF
        		IF cPoRn=="D"
          			? "UKUPNO VAN VALUTE:"
				@ prow(),nCol1 SAY nUkVVD PICTURE picBHD
          			@ prow(),pcol()+1 SAY nUkVVP PICTURE picBHD
          			@ prow(),pcol()+1 SAY nUkVVD-nUkVVP PICTURE picBHD
          			if gVar1=="0"
            				@ prow(),pcol()+1 SAY nUkVVD2 PICTURE picdem
            				@ prow(),pcol()+1 SAY nUkVVP2 PICTURE picdem
            				@ prow(),pcol()+1 SAY nUkVVD2-nUkVVP2 PICTURE picdem
          			endif
        		ENDIF
        		nTUkVVD  += nUkVVD 
			nTUkVVP  += nUkVVP
        		nTUkVVD2 += nUkVVD2
			nTUkVVP2 += nUkVVP2
      		ENDIF
      		IF cPoRn=="D"
			? m
		ENDIF
      		cFaza:=otvst
      		IF cSaRokom=="D"
        		nFaza:=RRocnost()
      		ENDIF
    	ELSEIF cSaRokom=="D" .and. nFaza!=RRocnost()
      		SKIP -1
      		IF cPoRn=="D"
			? m
		ENDIF
      		IF cFaza==" "
        		IF cPoRn=="D"
          			? "UK.U VALUTI"+IspisRocnosti()+":"
				@ prow(),nCol1 SAY anInterUV[nFaza,1,1] PICTURE picBHD
          			@ prow(),pcol()+1 SAY anInterUV[nFaza,2,1] PICTURE picBHD
          			@ prow(),pcol()+1 SAY anInterUV[nFaza,1,1]-anInterUV[nFaza,2,1] PICTURE picBHD
          			if gVar1=="0"
            				@ prow(),pcol()+1 SAY anInterUV[nFaza,3,1] PICTURE picdem
            				@ prow(),pcol()+1 SAY anInterUV[nFaza,4,1] PICTURE picdem
            				@ prow(),pcol()+1 SAY anInterUV[nFaza,3,1]-anInterUV[nFaza,4,1] PICTURE picdem
          			endif
        		ENDIF
        		anInterUV[nFaza,1,2] += anInterUV[nFaza,1,1]
        		anInterUV[nFaza,2,2] += anInterUV[nFaza,2,1]
        		anInterUV[nFaza,3,2] += anInterUV[nFaza,3,1]
        		anInterUV[nFaza,4,2] += anInterUV[nFaza,4,1]
      		ELSE
        		IF cPoRn=="D"
          			? "UK.VAN VALUTE"+IspisRocnosti()+":"
				@ prow(),nCol1 SAY anInterVV[nFaza,1,1] PICTURE picBHD
          			@ prow(),pcol()+1 SAY anInterVV[nFaza,2,1] PICTURE picBHD
          			@ prow(),pcol()+1 SAY anInterVV[nFaza,1,1]-anInterVV[nFaza,2,1] PICTURE picBHD
          			if gVar1=="0"
            				@ prow(),pcol()+1 SAY anInterVV[nFaza,3,1] PICTURE picdem
            				@ prow(),pcol()+1 SAY anInterVV[nFaza,4,1] PICTURE picdem
            				@ prow(),pcol()+1 SAY anInterVV[nFaza,3,1]-anInterVV[nFaza,4,1] PICTURE picdem
          			endif
        		ENDIF
        		anInterVV[nFaza,1,2] += anInterVV[nFaza,1,1]
        		anInterVV[nFaza,2,2] += anInterVV[nFaza,2,1]
        		anInterVV[nFaza,3,2] += anInterVV[nFaza,3,1]
        		anInterVV[nFaza,4,2] += anInterVV[nFaza,4,1]
      		ENDIF
      		IF cPoRn=="D"
			? m
		ENDIF
      	SKIP 1
      	nFaza:=RRocnost()
ENDIF

ENDDO

IF prow()>58+gPStranica
	FF
	ZSpecPoDosp(.t., nil, PICPIC)
ENDIF

SELECT POM
if !fPrviProlaz  // bilo je stavki
	IF cPoRn=="D"
      		? M
      		? "UKUPNO:"
      		@ prow(),nCol1 SAY nUDug PICTURE picBHD
      		@ prow(),pcol()+1 SAY nUPot PICTURE picBHD
      		@ prow(),pcol()+1 SAY nUDug-nUPot PICTURE picBHD
      		if gVar1=="0"
        		@ prow(),pcol()+1 SAY nUDug2 PICTURE picdem
        		@ prow(),pcol()+1 SAY nUPot2 PICTURE picdem
        		@ prow(),pcol()+1 SAY nUDug2-nUPot2 PICTURE picdem
      		endif
      		? m
    	ELSE
      		IF cSaRokom=="D"
        		FOR i:=1 TO LEN(anInterUV)
          			if ( cValuta == "1" )
					PPljuc(TRANSFORM(anInterUV[i,1,1]-anInterUV[i,2,1],PICPIC))
				else
					PPljuc(TRANSFORM(anInterUV[i,3,1]-anInterUV[i,4,1],PICPIC))
        			endif
			NEXT

			if ( cValuta == "1" )
        			PPljuc(TRANSFORM(nUkUVD-nUkUVP,PICPIC))
        		else
        			PPljuc(TRANSFORM(nUkUVD2-nUkUVP2,PICPIC))
			endif
			
			FOR i:=1 TO LEN(anInterVV)
				if ( cValuta == "1" )
          				PPljuc(TRANSFORM(anInterVV[i,1,1]-anInterVV[i,2,1],PICPIC))
        			else
          				PPljuc(TRANSFORM(anInterVV[i,3,1]-anInterVV[i,4,1],PICPIC))
				endif
			NEXT
			if ( cValuta == "1" )
        			PPljuc(TRANSFORM(nUkVVD-nUkVVP,PICPIC))
        			PPljuc(TRANSFORM(nUDug-nUPot,PICPIC))
			else
				PPljuc(TRANSFORM(nUkVVD2-nUkVVP2,PICPIC))
        			PPljuc(TRANSFORM(nUDug2-nUPot2,PICPIC))
			endif
			
			if lExpRpt == .t.
			   if cValuta == "1"	
				fill_ost_tbl( cSaRokom, cIdPartner, cP_naz, nUkUVD - nUkUVP, nUkVVD - nUkVVP, nUDug - nUPot, anInterUV[1,1,1] - anInterUV[1,2,1], anInterUV[2,1,1] - anInterUV[2,2,1], anInterUV[3,1,1] - anInterUV[3,2,1], anInterUV[4,1,1] - anInterUV[4,2,1], anInterUV[5,1,1] - anInterUV[5,2,1], anInterVV[1,1,1] - anInterVV[1,2,1], anInterVV[2,1,1] - anInterVV[2,2,1], anInterVV[3,1,1] - anInterVV[3,2,1], anInterVV[4,1,1] - anInterVV[4,2,1], anInterVV[5,1,1] - anInterVV[5,2,1] )
			   else
			   	fill_ost_tbl( cSaRokom, cIdPartner, cP_naz, nUkUVD2 - nUkUVP2, nUkVVD2 - nUkVVP2, nUDug2 - nUPot2, anInterUV[1,3,1] - anInterUV[1,4,1], anInterUV[2,3,1] - anInterUV[2,4,1], anInterUV[3,3,1] - anInterUV[3,4,1], anInterUV[4,3,1] - anInterUV[4,4,1], anInterUV[5,3,1] - anInterUV[5,4,1], anInterVV[1,3,1] - anInterVV[1,4,1], anInterVV[2,3,1] - anInterVV[2,4,1], anInterVV[3,3,1] - anInterVV[3,4,1], anInterVV[4,3,1] - anInterVV[4,4,1], anInterVV[5,3,1] - anInterVV[5,4,1] )		
			   endif
			endif
      		ELSE
			if ( cValuta == "1" )
        			PPljuc(TRANSFORM(nUkUVD-nUkUVP,PICPIC))
        			PPljuc(TRANSFORM(nUkVVD-nUkVVP,PICPIC))
        			PPljuc(TRANSFORM(nUDug-nUPot  ,PICPIC))
			else
				PPljuc(TRANSFORM(nUkUVD2-nUkUVP2,PICPIC))
        			PPljuc(TRANSFORM(nUkVVD2-nUkVVP2,PICPIC))
        			PPljuc(TRANSFORM(nUDug2-nUPot2  ,PICPIC))
			endif

			if lExpRpt == .t.
			   if cValuta == "1"
				fill_ost_tbl( cSaRokom, cIdPartner, cP_naz, nUkUVD - nUkUVP, nUkVVD - nUkVVP, nUDug - nUPot )
						
			   else
				fill_ost_tbl( cSaRokom, cIdPartner, cP_naz, nUkUVD2 - nUkUVP2, nUkVVD2 - nUkVVP2, nUDug2 - nUPot2 )
				
			   endif
			endif
					
	
      		ENDIF
    	ENDIF
endif

IF cPoRn=="D"
	? 
	? 
	?
ENDIF

nTUDug += nUDug
nTUDug2 += nUDug2
nTUPot += nUPot
nTUPot2 += nUPot2
ENDDO

IF cPoRn=="D" .and. LEN(cSvi)<LEN(idpartner) .and.;
    ( ROUND(nTUDug ,2)!=0 .or. ROUND(nTUPot ,2)!=0 .or.;
      ROUND(nTUkUVD,2)!=0 .or. ROUND(nTUkUVP,2)!=0 .or.;
      ROUND(nTUkVVD,2)!=0 .or. ROUND(nTUkVVP,2)!=0 )

  // prikazimo total
  FF
  ZSpecPoDosp(.t.,.t., PICPIC)
  ? m2:=STRTRAN(M,"-","=")
  IF cSaRokom=="D"
    FOR i:=1 TO LEN(anInterUV)
      ? "PARTN.U VAL."+IspisRoc2(i)+":"
       @ prow(),nCol1 SAY anInterUV[i,1,2] PICTURE picBHD
       @ prow(),pcol()+1 SAY anInterUV[i,2,2] PICTURE picBHD
       @ prow(),pcol()+1 SAY anInterUV[i,1,2]-anInterUV[i,2,2] PICTURE picBHD
       IF gVar1=="0"
         @ prow(),pcol()+1 SAY anInterUV[i,3,2] PICTURE picdem
         @ prow(),pcol()+1 SAY anInterUV[i,4,2] PICTURE picdem
         @ prow(),pcol()+1 SAY anInterUV[i,3,2]-anInterUV[i,4,2] PICTURE picdem
       ENDIF
    NEXT
    ? m
  ENDIF
  ? "PARTNERI UKUPNO U VALUTI  :"
   @ prow(),nCol1 SAY nTUkUVD PICTURE picBHD
   @ prow(),pcol()+1 SAY nTUkUVP PICTURE picBHD
   @ prow(),pcol()+1 SAY nTUkUVD-nTUkUVP PICTURE picBHD
   IF gVar1=="0"
     @ prow(),pcol()+1 SAY nTUkUVD2 PICTURE picdem
     @ prow(),pcol()+1 SAY nTUkUVP2 PICTURE picdem
     @ prow(),pcol()+1 SAY nTUkUVD2-nTUkUVP2 PICTURE picdem
   ENDIF
  ? m2
  IF cSaRokom=="D"
    FOR i:=1 TO LEN(anInterVV)
      ? "PARTN.VAN VAL."+IspisRoc2(i)+":"
       @ prow(),nCol1 SAY anInterVV[i,1,2] PICTURE picBHD
       @ prow(),pcol()+1 SAY anInterVV[i,2,2] PICTURE picBHD
       @ prow(),pcol()+1 SAY anInterVV[i,1,2]-anInterVV[i,2,2] PICTURE picBHD
       IF gVar1=="0"
         @ prow(),pcol()+1 SAY anInterVV[i,3,2] PICTURE picdem
         @ prow(),pcol()+1 SAY anInterVV[i,4,2] PICTURE picdem
         @ prow(),pcol()+1 SAY anInterVV[i,3,2]-anInterVV[i,4,2] PICTURE picdem
       ENDIF
    NEXT
    ? m
  ENDIF

  ? "PARTNERI UKUPNO VAN VALUTE:"
   @ prow(),nCol1 SAY nTUkVVD PICTURE picBHD
   @ prow(),pcol()+1 SAY nTUkVVP PICTURE picBHD
   @ prow(),pcol()+1 SAY nTUkVVD-nTUkVVP PICTURE picBHD
   IF gVar1=="0"
     @ prow(),pcol()+1 SAY nTUkVVD2 PICTURE picdem
     @ prow(),pcol()+1 SAY nTUkVVP2 PICTURE picdem
     @ prow(),pcol()+1 SAY nTUkVVD2-nTUkVVP2 PICTURE picdem
   ENDIF
  ? m2
  ? "PARTNERI UKUPNO           :"
   @ prow(),nCol1 SAY nTUDug PICTURE picBHD
   @ prow(),pcol()+1 SAY nTUPot PICTURE picBHD
   @ prow(),pcol()+1 SAY nTUDug-nTUPot PICTURE picBHD
   IF gVar1=="0"
     @ prow(),pcol()+1 SAY nTUDug2 PICTURE picdem
     @ prow(),pcol()+1 SAY nTUPot2 PICTURE picdem
     @ prow(),pcol()+1 SAY nTUDug2-nTUPot2 PICTURE picdem
   ENDIF
  ? m2

ENDIF // total

IF cPoRn=="N"
	
	cTmpL := ""
	
	// uzmi liniju
	_get_line1( @cTmpL, cSaRokom, PICPIC )
	
	? cTmpL
	
  	Pljuc( PADR( "UKUPNO" , LEN( POM->IDPARTNER + PADR(PARTN->naz, 25)) + 1 ) )
  	
	_get_line2( @cTmpL, cSaRokom, PICPIC)
	
	IF cSaRokom=="D"
    		FOR i:=1 TO LEN(anInterUV)
      			if ( cValuta == "1" )
      				PPljuc(TRANSFORM(anInterUV[i,1,2]-anInterUV[i,2,2],PICPIC))
    			else
      				PPljuc(TRANSFORM(anInterUV[i,3,2]-anInterUV[i,4,2],PICPIC))
			endif
    		NEXT
    		if ( cValuta == "1" )
			PPljuc(TRANSFORM(nTUkUVD-nTUkUVP,PICPIC))
    		else
			PPljuc(TRANSFORM(nTUkUVD2-nTUkUVP2,PICPIC))
		endif
		
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
		
		if lExpRpt == .t.
		  
		  if cValuta == "1"
		    fill_ost_tbl(cSaRokom, "UKUPNO", "", nTUkUVD - nTUkUVP, nTUkVVD - nTUkVVP, nTUDug - nTUPot, anInterUV[1,1,2] - anInterUV[1,2,2], anInterUV[2,1,2] - anInterUV[2,2,2], anInterUV[3,1,2] - anInterUV[3,2,2], anInterUV[4,1,2] - anInterUV[4,2,2], anInterUV[5,1,2] - anInterUV[5,2,2], anInterVV[1,1,2] - anInterVV[1,2,2], anInterVV[2,1,2] - anInterVV[2,2,2], anInterVV[3,1,2] - anInterVV[3,2,2], anInterVV[4,1,2] - anInterVV[4,2,2], anInterVV[5,1,2] - anInterVV[5,2,2] )
		  else
		     fill_ost_tbl(cSaRokom, "UKUPNO", "", nTUkUVD2 - nTUkUVP2, nTUkVVD2 - nTUkVVP2, nTUDug2 - nTUPot2, anInterUV[1,3,2] - anInterUV[1,4,2], anInterUV[2,3,2] - anInterUV[2,4,2], anInterUV[3,3,2] - anInterUV[3,4,2], anInterUV[4,3,2] - anInterUV[4,4,2], anInterUV[5,3,2] - anInterUV[5,4,2], anInterVV[1,3,2] - anInterVV[1,4,2], anInterVV[2,3,2] - anInterVV[2,4,2], anInterVV[3,3,2] - anInterVV[3,4,2], anInterVV[4,3,2] - anInterVV[4,4,2], anInterVV[5,3,2] - anInterVV[5,4,2] )
		  endif
		  
		endif

  	ELSE
		if ( cValuta == "1" )
    			PPljuc(TRANSFORM(nTUkUVD-nTUkUVP,PICPIC))
    			PPljuc(TRANSFORM(nTUkVVD-nTUkVVP,PICPIC))
    			PPljuc(TRANSFORM(nTUDug-nTUPot,PICPIC))
    		else
			PPljuc(TRANSFORM(nTUkUVD2-nTUkUVP2,PICPIC))
    			PPljuc(TRANSFORM(nTUkVVD2-nTUkVVP2,PICPIC))
    			PPljuc(TRANSFORM(nTUDug2-nTUPot2,PICPIC))
		endif
		
		if lExpRpt == .t.
		  
		  if cValuta == "1"
		  	fill_ost_tbl(cSaRokom, "UKUPNO", "", nTUkUVD - nTUkUVP, nTUkVVD - nTUkVVP, nTUDug - nTUPot )
		  else
		  	fill_ost_tbl(cSaRokom, "UKUPNO", "", nTUkUVD2 - nTUkUVP2, nTUkVVD2 - nTUkVVP2, nTUDug2 - nTUPot2 )
		  endif
				
		endif
	
  	ENDIF

	? cTmpL
	
ENDIF

FF

END PRINT

if lExpRpt == .t.
	tbl_export()
endif

select (F_POM)
use

CLOSERET
return


// -----------------------------------------------------
// vraca liniju za report varijanta 1
// -----------------------------------------------------
static function _get_line1(cTmpL, cSaRokom, cPicForm )
local cStart := "�"
local cMidd := "�"
local cLine := "�"
local cEnd := "�"
local cFill := "�"
local nFor := 3

if cSaRokom == "D"
	nFor := 13
endif

cTmpL := cStart
cTmpL += REPLICATE(cFill, __par_len) 
cTmpL += cMidd
cTmpL += REPLICATE(cFill, 25)
	
for i := 1 to nFor
	cTmpL += cLine
	cTmpL += REPLICATE(cFill, LEN(cPicForm))
next
		
cTmpL += cEnd

return

// ------------------------------------------------------
// vraca liniju varijantu 2
// ------------------------------------------------------
static function _get_line2( cTmpL, cSaRokom, cPicForm )
local cStart := "�" 
local cLine := "�"
local cEnd := "�"
local cFill := "�"
local nFor := 3

if cSaRokom == "D"
	nFor := 13
endif

cTmpL := cStart
cTmpL += REPLICATE(cFill, __par_len) 
cTmpL += cLine
cTmpL += REPLICATE(cFill, 25)
	
for i := 1 to nFor
	cTmpL += cLine
	cTmpL += REPLICATE(cFill, LEN(cPicForm))
next
		
cTmpL += cEnd

return



// --------------------------------------------------------
// provjeri da li je saldo partnera 0, vraca .t. ili .f.
// --------------------------------------------------------
function saldo_nula(cIdPartn)
local nPRecNo
local nLRecNo
local nDug:=0
local nPot:=0

nPRecNo := RecNo()

do while !EOF() .and. idpartner == cIdPartn
	nDug += dug
	nPot += pot
	skip
enddo

skip -1

nLRecNo := RecNo()

if (ROUND(nDug, 2) - ROUND(nPot, 2) == 0)
	go (nLRecNo)	
	return .t.
endif

go (nPRecNo)

return .f.


/*! \fn ZSpecPoDosp(fStrana,lSvi)
 *  \brief Zaglavlje izvjestaja specifikacije po dospjecu
 *  \param fStrana
 *  \param lSvi
 */
 
function ZSpecPoDosp( fStrana, lSvi, PICPIC )
local nII
local cTmp

?

if cSaRokom == "D" .and. ((LEN(ALLTRIM(PICPIC)) * 13) + 46 ) > 170
	?? "#%LANDS#"
endif

IF cPoRn=="D"
	IF gVar1=="0"
    		P_COND2
  	ELSE
    		P_COND
  	ENDIF
ELSE
  	IF cSaRokom=="D"
    		P_COND2
  	ELSE
    		P_10CPI
  	ENDIF
ENDIF

if lSvi == NIL
	lSvi:=.f.
endif

if fStrana == NIL
	fStrana:=.f.
endif

if nStr = 0
  	fStrana:=.t.
endif

IF cPoRn == "D"
	?? "FIN.P:  SPECIFIKACIJA OTVORENIH STAVKI PO DOSPIJECU NA DAN "; ?? dNaDan
 	if fStrana
  		@ prow(),110 SAY "Str:"+str(++nStr,3)
 	endif
	
	SELECT PARTN
	HSEEK cIdFirma
 	
	? "FIRMA:",cIdFirma,"-",gNFirma
	
	SELECT KONTO
	HSEEK cIdKonto
	
	? "KONTO  :", cIdKonto, naz
	
	if lSvi
  		? "PARTNER: SVI"
 	else
  		SELECT PARTN
		HSEEK cIdPartner
  		? "PARTNER:", cIdPartner,TRIM(PADR(naz, 25))," ",TRIM(naz2)," ",TRIM(mjesto)
 	endif
	
	? m
 	?
 	
	?? "Dat.dok.*Dat.val.* "
 	
	IF gVar1=="0"
  		?? "  BrDok   *   dug "+ValDomaca()+"  *   pot "+ValDomaca()+"   *  saldo  "+ValDomaca()+" * dug "+ValPomocna()+" * pot "+ValPomocna()+" *saldo "+ValPomocna()+"*      U/VAN VALUTE      *"
 	ELSE
  		?? "  BrDok   *   dug "+ValDomaca()+"  *   pot "+ValDomaca()+"   *  saldo  "+ValDomaca()+" *      U/VAN VALUTE      *"
 	ENDIF
 	
	? m

ELSE
	?? "FIN.P:  SPECIFIKACIJA OTVORENIH STAVKI PO DOSPIJECU NA DAN "; ?? dNaDan
	SELECT PARTN
	HSEEK cIdFirma
 	? "FIRMA:",cIdFirma,"-",gNFirma
	SELECT KONTO
	HSEEK cIdKonto
	
	? "KONTO  :", cIdKonto, naz
	
	IF cSaRokom=="D"
   		
		// prvi red
		cTmp := "�"
		cTmp += REPLICATE("�", __par_len)
		cTmp += "�"
		cTmp += REPLICATE("�", 25)
		cTmp += "�"
		cTmp += REPLICATE("�", (LEN(PICPIC) * 5) + 4 )
		cTmp += "�"
		cTmp += REPLICATE("�", LEN(PICPIC))
		cTmp += "�"
		cTmp += REPLICATE("�", (LEN(PICPIC) * 5) + 4 )
		cTmp += "�"
		cTmp += REPLICATE("�", LEN(PICPIC))
		cTmp += "�"
		cTmp += REPLICATE("�", LEN(PICPIC))
		cTmp += "�"
		
		? cTmp

		// drugi red
   		cTmp := "�"
		cTmp += REPLICATE(" ", __par_len)
		cTmp += "�"
		cTmp += REPLICATE(" ", 25) 
		cTmp += "�"
		cTmp += _f_text("U      V  A  L  U  T  I", (LEN(PICPIC) * 5) + 4 )
		
		cTmp += "�"
		cTmp += REPLICATE(" ", LEN(PICPIC))
		
		cTmp += "�"
		cTmp += _f_text("V  A  N      V  A  L  U  T  E", (LEN(PICPIC) * 5) + 4 )
		cTmp += "�"
		cTmp += REPLICATE(" ", LEN(PICPIC))
		cTmp += "�"
		cTmp += REPLICATE(" ", LEN(PICPIC))
		cTmp += "�"
	
		? cTmp
	
   		
		// treci red
		cTmp := "�"
		cTmp += PADC("SIFRA", __par_len) 
		cTmp += "�"
		cTmp += _f_text("NAZIV  PARTNERA", 25)
		cTmp += "�"
		
		for nII := 1 to 5
			cTmp += REPLICATE("�", LEN(PICPIC) )
			
			if nII == 5
				cTmp += "�"
			else
				cTmp += "�"
			endif
			
		next
		
		cTmp += _f_text( " ", LEN(PICPIC) )
		cTmp += "�"
		
		for nII := 1 to 5
			cTmp += REPLICATE("�", LEN(PICPIC) )
			
			if nII == 5
				cTmp += "�"
			else
				cTmp += "�"
			endif
		next
		
		cTmp += _f_text( " ", LEN(PICPIC) )
		cTmp += "�"
		cTmp += _f_text( "UKUPNO", LEN(PICPIC) )
		cTmp += "�"

		? cTmp
		
   		cTmp := "�"
		cTmp += PADC("PARTN.", __par_len)
		cTmp += "�"
		cTmp += _f_text(" ", 25) 
		
		cTmp += "�"
		cTmp += _f_text( "DO" + STR(nDoDana1, 3) + " D.", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text( "DO" + STR(nDoDana2, 3) + " D.", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text( "DO" + STR(nDoDana3, 3) + " D.", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text( "DO" + STR(nDoDana4, 3) + " D.", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text( "PR." + STR(nDoDana4, 2) + " D.", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text( "UKUPNO", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text( "DO" + STR(nDoDana1, 3) + " D.", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text( "DO" + STR(nDoDana2, 3) + " D.", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text( "DO" + STR(nDoDana3, 3) + " D.", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text( "DO" + STR(nDoDana4, 3) + " D.", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text( "PR." + STR(nDoDana4, 2) + " D.", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text( "UKUPNO", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text( " ", LEN(PICPIC))
		cTmp +=	"�"
   		
		? cTmp 
		
		cTmp := "�"
		cTmp += REPLICATE("�", __par_len)
		cTmp += "�"
		cTmp += REPLICATE("�", 25)
		
		for nII := 1 to 13
			cTmp += "�"
			cTmp += REPLICATE("�", LEN(PICPIC))
		next
		
		cTmp += "�"

		? cTmp
 	
	ELSE
   		
		// 1 red
		cTmp := "�"
		cTmp += REPLICATE("�", __par_len)
		cTmp += "�"
		cTmp += REPLICATE("�", 25)
		
		for nII := 1 to 3
			cTmp += "�"
			cTmp += REPLICATE("�", LEN(PICPIC) )
		next
		
		cTmp += "�"

		? cTmp


		// 2 red
   		
		cTmp := "�"
		cTmp += PADC("SIFRA", __par_len)
		cTmp += "�"
		cTmp += _f_text(" ", 25) 
		cTmp += "�"
		cTmp += _f_text("UKUPNO", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text("UKUPNO", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text(" ", LEN(PICPIC))
		cTmp += "�"
   		
		? cTmp
		
		// 3 red
  	 	
		cTmp := "�"
		cTmp += PADC("PARTN.", __par_len)
		cTmp += "�"
		cTmp += _f_text("NAZIV PARTNERA", 25) 
		cTmp += "�"
		cTmp += _f_text("U VALUTI", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text("VAN VAL.", LEN(PICPIC))
		cTmp += "�"
		cTmp += _f_text("UKUPNO", LEN(PICPIC))
		cTmp += "�"
		
		? cTmp
		
		// 4 red
		cTmp := "�"
		cTmp += REPL("�", __par_len)
		cTmp += "�"
		cTmp += REPLICATE("�", 25)
		
		for nII := 1 to 3
			cTmp += "�"
			cTmp += REPLICATE("�", LEN(PICPIC) )
		next
		
		cTmp += "�"

		? cTmp
 	ENDIF
ENDIF

return


// ---------------------------------------------
// formatiraj tekst ... na nLen
// ---------------------------------------------
static function _f_text( cTxt, nLen )
return PADC(cTxt, nLen)




/*! \fn getmjesto(cMjesto)
 *  \brief 
 *  \param cMjesto
 */
 
function getmjesto(cMjesto)

local fRet
local nSel := select()

select partn
seek (nsel)->idpartner
fRet:=.f.
if mjesto=cMjesto
  fRet:=.t.
endif
select (nSel)
return fRet




/*! \fn P_VKSG(cId,dx,dy)
 *  \brief
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_VKSG(cId,dx,dy)

PRIVATE ImeKol,Kol
ImeKol:={ { "Konto"   , {|| id    },     "id"       },;
          { "Godina"  , {|| godina},     "godina"   },;
          { "St.konto", {|| ids   },     "ids"      };
        }
Kol:={1,2,3}
return PostojiSifra(F_VKSG,1,10,60,"Veze konta sa prethodnim godinama",@cId,dx,dy)




/*! \fn FFor1()
 *  \brief Funkcija koju koristi StampaTabele()
 */
 
static function FFor1()

cIdP:=IDPARTNER

  ukPartner:=0
  FOR i:=1 TO LEN(aGod)
    cPom7777:="ukGOD"+aGod[i,1]
     &cPom7777:=0
  NEXT
  cPom7777:="ukGOD"+STR(VAL(aGod[i-1,1])-1,4)
   &cPom7777:=0
  cPom7777:="ukGOD"+STR(VAL(aGod[i-1,1])-2,4)
   &cPom7777:=0

  DO WHILE !EOF() .and. IDPARTNER==cIdP
    FOR i:=1 TO LEN(aGod)
      cPom7777:="ukGOD"+aGod[i,1]
       cPom7778:=SUBSTR(cPom7777,3)
        &cPom7777 += &cPom7778
         ukPartner += &cPom7778
    NEXT
    cPom7777:="ukGOD"+STR(VAL(aGod[i-1,1])-1,4)
     cPom7778:=SUBSTR(cPom7777,3)
      &cPom7777 += &cPom7778
       ukPartner += &cPom7778
    cPom7777:="ukGOD"+STR(VAL(aGod[i-1,1])-2,4)
     cPom7778:=SUBSTR(cPom7777,3)
      &cPom7777 += &cPom7778
       ukPartner += &cPom7778
    SKIP 1
  ENDDO
  SKIP -1
RETURN .t.


/*! \fn FSvaki1()
 *  \brief 
 */

static function FSvaki1()

++nRbr
cNPartnera:=PADR(Ocitaj(F_PARTN,IDPARTNER,"naz"), 25)
RETURN




