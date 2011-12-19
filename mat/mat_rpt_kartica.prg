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


#include "mat.ch"


static PicDEM := "99999999.99"
static PicBHD := "9999999999.99"
static PicKol := "9999999.99"


// --------------------------------------
// kartice, glavni menij
// --------------------------------------
function mat_kartica()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. sintetika      " )
AADD( _opcexe, { || KSintKont() } )
AADD( _opc, "2. analitika" )
AADD( _opcexe, { || KAnalK() } )
AADD( _opc, "3. subanalitika " )
AADD( _opcexe, { || KSuban() } )


f18_menu("kca", .f., _izbor, _opc, _opcexe )

close all
return


// --------------------------------------
// sinteticka kartica
// --------------------------------------
function KSintKont()
local nC1:=30

O_PARTN

cIdFirma:=gFirma
qqKonto:=SPACE(100)
Box("KSK",4,60,.f.)
do while .t.
@ m_x+1,m_y+2 SAY "SINTETICKA KARTICA"
if gNW$"DR"
  @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif
@ m_x+4,m_y+2 SAY KonSeks("KONTO")+":  " GET qqKonto picture "@S50"
READ;  ESC_BCR
 aUsl1 := Parsiraj( qqKonto, "IdKonto", "C" )
 if aUsl1<>NIL
     exit
 endif
enddo

BoxC()

cIdFirma:=left(cIdFirma,2)

O_MAT_SINT
O_KONTO

select mat_sint
set filter to Tacno(aUsl1) .and. IdFirma==cIdFirma
go top

EOF CRET

START PRINT CRET

m := "------- ---- ----------- -------------- -------------- -------------- --------------"

do while !eof() 
// firma

nUkDug := 0
nUkPot := 0
nUkDug2 := 0
nUkPot2 := 0
cIdKonto := IdKonto

if prow()<>0
    FF
    ZaglKSintK()
endif

DO WHILE !eof() .AND. cIdFirma=IdFirma .and. cIdKonto=IdKonto
   IF prow()==0; ZaglKSintK(); ENDIF
   IF prow()>65; FF; ZaglKSintK(); ENDIF
   ? IdVN, brnal,rbr,"  ",datnal
   nC1:=pcol()+3
   @ prow(),pcol()+3 SAY Dug PICTURE picDEM
   nUkDug+=Dug
   @ prow(),pcol()+1 SAY Pot PICTURE picDEM
   nUkPot+=Pot
   @ prow(),pcol()+1 SAY Dug2 PICTURE picBHD
   nUkDug2+=Dug2
   @ prow(),pcol()+1 SAY Pot2 PICTURE picBHD
   nUkPot2+=Pot2
   SKIP
ENDDO

IF prow()>61; FF; ZaglKSintK(); ENDIF
? m
? "UKUPNO:"
@ prow(),nC1 SAY nUkDug        PICTURE picDEM
@ prow(),pcol()+1 SAY nUkPot  PICTURE picDEM
@ prow(),pcol()+1 SAY nUkDug2 PICTURE picBHD
@ prow(),pcol()+1 SAY nUkPot2 PICTURE picBHD
?  m
? "SALDO:"
nSaldo:=nUkDug-nUkPot
nSaldo2:=nUkDug2-nUkPot2
IF nSaldo>0
   @ prow(),nC1 SAY nSaldo        PICTURE picDEM
   @ prow(),pcol()+1 SAY 0       PICTURE picDEM
   @ prow(),pcol()+1 SAY nSaldo2 PICTURE picBHD
ELSE 
   nSaldo:=-nSaldo
   @ prow(),pcol()+1 SAY 0       PICTURE picDEM
   @ prow(),pcol()+1 SAY nSaldo  PICTURE picDEM
   @ prow(),pcol()+1 SAY 0       PICTURE picBHD
   @ prow(),pcol()+1 SAY nSaldo2 PICTURE picBHD
ENDIF
? m
nUkDug:=nUkPot:=nUkDug2:=nUkPot2:=0

enddo

FF
END PRINT

close all
return


// ----------------------------------------------
// zaglavlje sinteticke kartice
// ----------------------------------------------
static function ZaglKSintK()
?? "MAT.P: SINTETICKA KARTICA   NA DAN "; @ prow(),PCOL()+1 SAY DATE()
SELECT PARTN; HSEEK cIdFirma
? "FIRMA:",cidfirma,PADR( partn->naz, 25 ), PADR( partn->naz2, 25 )

SELECT KONTO; HSEEK cIdKonto
? KonSeks("KONTO")+":", cIdkonto, konto->naz
? m
? "*NALOG * R. *  DATUM    *   I Z N O S   U   "+ValPomocna()+"      *  I Z N O S    U    "+ValDomaca()+"    *"
? "*      * Br *           ------------------------------ -----------------------------"
? "*      *    *  NALOGA   *    DUGUJE    *  POTRAZUJE   *      DUGUJE   *  POTRAZUJE *"
? m
SELECT mat_sint
RETURN


// -----------------------------------------
// analiticka kartica
// -----------------------------------------
function KAnalK()
local _izbor := 1
local _opc := {}
local _opcexe := {}

AADD( _opc, "1. kartica za pojedinacni konto         " )
AADD( _opcexe, { || KAnKPoj() } )
AADD( _opc, "2. kartica po svim kontima" )
AADD( _opcexe, { || KAnKKonto() } )

f18_menu("ksix", .f., _izbor, _opc, _opcexe )

return



// -----------------------------------------
// -----------------------------------------
function KAnKPoj()
cIdFirma:="  "
qqKonto:=SPACE(100)

O_PARTN

Box("KANP",3,70,.f.)

do while .t.
 @ m_x+1,m_y+6 SAY "ANALITICKA KARTICA"
 if gNW$"DR"
  @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
  cIdFirma:=gFirma
 else
  @ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+3,m_y+2 SAY KonSeks("KONTO  ")+"  : " GET qqKonto  picture "@S50"
 READ;  ESC_BCR

 aUsl1:=Parsiraj(qqKonto,"IdKonto","C")
 if aUsl1<>NIL; exit; endif
enddo

BoxC()

O_MAT_ANAL
O_KONTO

select mat_anal 
set filter to Tacno(aUsl1) .and. IdFirma==cIdFirma
go top
EOF CRET

START PRINT CRET

m:="-- ---- --- -------- ------------- -------------- -------------- ----------------"

*
a:=0
do while !eof()

  cIdKonto:=IdKonto
  if a<>0; EJECTA0; ZaglKAnalK(); endif
  nUkDug:=nUkPot:=nUkDug2:=nUkPot2:=0
  DO WHILE !eof() .and. cIdKonto==IdKonto //konto
     IF A==0; ZaglKAnalK(); ENDIF
     IF A>64; EJECTA0; ZaglKAnalK(); ENDIF
     @ ++A,0      SAY IdVN
     @ A,pcol()+1 SAY BrNal
     @ A,pcol()+1 SAY RBr
     @ A,pcol()+1 SAY DatNal
     @ A,pcol()+1 SAY Dug PICTURE picDEM
     @ A,pcol()+1 SAY Pot PICTURE picDEM
     @ A,pcol()+1 SAY Dug2 PICTURE picBHD
     @ A,pcol()+1 SAY Pot2 PICTURE picBHD
     nUkDug+=Dug; nUkPot+=Pot; nUkDug2+=Dug2; nUkPot2+=Pot2
     SKIP
  ENDDO

  @ ++A,0 SAY m
  @ ++A,0 SAY "UKUPNO:"
  @ A,21       SAY nUkDug  PICTURE picDEM
  @ A,pcol()+1 SAY nUkPot  PICTURE picDEM
  @ A,pcol()+1 SAY nUkDug2 PICTURE picBHD
  @ A,pcol()+1 SAY nUkPot2  PICTURE picBHD
  @ ++A,0 SAY m
  @ ++A,0 SAY "SALDO:"
  nSaldo:=nUkDug-nUkPot
  nSaldo2:=nUkDug2-nUkPot2
  IF nSaldo>=0
     @ A,21 SAY nSaldo PICTURE picDEM
     @ A,pcol()+1 SAY 0 PICTURE picDEM
     @ A,pcol()+1 SAY nSaldo2 PICTURE picBHD
  ELSE
     nSaldo:=-nSaldo
     @ A,21 SAY 0 PICTURE picDEM
     @ A,pcol()+1 SAY nSaldo PICTURE picDEM
     @ A,pcol()+1 SAY 0 PICTURE picBHD
     @ A,pcol()+1 SAY nSaldo2 PICTURE picBHD
  ENDIF
  @ ++A,0 SAY m
  nUkDug:=nUkPot:=nUkDug2:=nUkPot2:=0

enddo // eof

EJECTNA0

END PRINT

set filter to
close all

return


static function ZaglKAnalK()
P_COND
@ a,0  SAY "MAT.P: KARTICA - ANALITICKI "+KonSeks("KONTO")+" - ZA POJEDINACNI "+KonSeks("KONTO")
@ ++A,0 SAY "FIRMA:"; @ A,pcol()+1 SAY cIdFirma
SELECT PARTN; HSEEK cIdFirma
@ A,pcol()+1 SAY naz; @ A,pcol()+1 SAY naz2

@ ++A,0 SAY KonSeks("KONTO")+":"; @ A,pcol()+1 SAY cIdKonto
SELECT KONTO; HSEEK cIdKonto
@ A,pcol()+1 SAY naz

@ ++A,0 SAY "---------------------------------------------------------------------------------"
@ ++A,0 SAY "*V*BR  *R  * DATUM  *  I Z N O S   U   "+ValPomocna()+"     *    I Z N O S    U    "+ValDomaca()+"     *"
@ ++A,0 SAY "                      -------------------------- --------------------------------"
@ ++A,0 SAY "*N*NAL *BR * NALOGA *    DUGUJE   *  POTRAZUJE  *     DUGUJE    *   POTRAZUJE   *"
@ ++A,0 SAY m

SELECT mat_anal
RETURN



function KAnKKonto()

cIdFirma:="  "

O_PARTN
O_MAT_ANAL

Box("kankko",2,60,.f.)
@ m_x+1,m_y+2 SAY "ANALITICKA KARTICA - PO "+KonSeks("KONT")+"IMA"
if gNW$"DR"
  @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
  cIdFirma:=gFirma
else
  @ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif
READ;  ESC_BCR
BoxC()

// cIdFirma:=left(cIdFirma,2)

O_MAT_SUBAN
O_KONTO
O_ROBA
O_SIFK
O_SIFV

SELECT mat_anal
set order to tag "2"
SEEK cIdFirma
NFOUND CRET

START PRINT CRET
A:=0

M:="------- --------------------------------- ------------- ------------- ------------- --------------- --------------- ----------------"

nUkDug:=nUkUkDug:=nUkPot:=nUkUkPot:=0
nUkDug2:=nUkUk2Dug:=nUkPot2:=nUkUk2Pot:=0
DO WHILE !eof() .AND. cIdFirma=IdFirma

   cIdKonto:=IdKonto

   DO WHILE !eof() .AND. cIdFirma=IdFirma .AND. cIdKonto=IdKonto
      nUkDug+=Dug; nUkPot+=Pot
      nUkDug2+=Dug2; nUkPot2+=Pot2
      SKIP
   ENDDO

   if A==0; ZagKKAnalK();endif
   if A>62; EJECTA0; ZagKKAnalK();endif
   nSaldo:=nUkDug-nUkPot
   nSaldo2:=nUkDug2-nUkPot2

   @ ++A,1 SAY cIdKonto
   SELECT KONTO; HSEEK cIdKonto
   @ A,8 SAY Naz picture replicate("X",32)

   @ A,42       SAY nUkDug  PICTURE PicDEM
   @ A,pcol()+1 SAY nUkPot  PICTURE PicDEM
   @ A,pcol()+1 SAY nSaldo  PICTURE PicDEM
   @ A,pcol()+1 SAY nUkDug2 PICTURE PicBHD
   @ A,pcol()+1 SAY nUkPot2 PICTURE PicBHD
   @ A,pcol()+1 SAY nSaldo2 PICTURE PicBHD
   nUkUkDug+=nUkDug; nUkUkPot+=nUkPot
   nUkUk2Dug+=nUkDug2; nUkUk2Pot+=nUkPot2
   nUkDug:=nUkPot:=nUkDug2:=nUkPot2:=0
   SELECT mat_anal
ENDDO

if A>62; EJECTA0; ZagKKAnalK();endif
nUkSaldo:=nUkUkDug-nUkUkPot
nUk2Saldo:=nUkUk2Dug-nUkUk2Pot
@ ++A,0 SAY M
@ ++A,0 SAY "UKUPNO ZA FIRMU:"
@ A,42       SAY nUkUkDug  PICTURE PicDEM
@ A,pcol()+1 SAY nUkUkPot  PICTURE PicDEM
@ A,pcol()+1 SAY nUkSaldo  PICTURE PicDEM
@ A,pcol()+1 SAY nUkUk2Dug PICTURE PicBHD
@ A,pcol()+1 SAY nUkUk2Pot PICTURE PicBHD
@ A,pcol()+1 SAY nUk2Saldo PICTURE PicBHD
@ ++A,0 SAY M
nUkUkDug:=nUkUkPot:=nUkUk2Dug:=nUkUk2Pot:=0

EJECTNA0
END PRINT
close all
return



function ZagKKAnalK()
P_COND
@ a,0  SAY "MAT.P: KARTICA STANJA PO ANALITICKIM "+KonSeks("KONT")+"IMA NA DAN "; @ A,PCOL()+1 SAY DATE()
@ A,0 SAY "FIRMA:"
@ A,10 SAY cIdFirma
SELECT PARTN; HSEEK cIdFirma
@ A,PCOL()+2 SAY naz; @ A,PCOL()+1 SAY naz2

@ ++A,0 SAY "------- --------------------------------- ----------------------------------------- ------------------------------------------------"
@ ++A,0 SAY KonSeks("*KONTO ")+"*      NAZIV "+KonSeks("KONTA  ")+"              *     I  Z  N  O  S     U     "+ValPomocna()+"        *       I  Z  N  O  S     U     "+ValDomaca()+"            *"
@ ++A,0 SAY "                                          ----------------------------------------- --------------- --------------- ----------------"
@ ++A,0 SAY "*      *                                 *    DUGUJE   *  POTRAZUJE  *    SALDO    *     DUGUJE    *  POTRAZUJE    *  SALDO        *"
@ ++A,0 SAY M

SELECT mat_anal
RETURN



// ---------------------------------------------
// mat_subanaliticka kartica
// ---------------------------------------------
function KSuban()
local nCol1
local nCol2
local cBrza := "D"
local cPredh := "1"

cIdFirma:=gFirma

qqRoba:=""
qqPartner:=""
qqKonto:=""

O_PARTN
O_KONTO
O_SIFV
O_SIFK
O_ROBA

Box("",10,70,.f.)

private cFilter

dDatOd:=dDatDo:=ctod("")

O_PARAMS
Private cSection:="4",cHistory:=" ",aHistory:={}
Params1()
RPar("c1",@cBrza)
RPar("c2",@cIdFirma); RPar("c3",@qqKonto); RPar("c4",@qqPartner)
RPar("c5",@qqRoba)
RPar("c6",@cPredh)
RPar("d1",@dDatOd); RPar("d2",@dDatDo)
if gNW$"DR";cIdFirma:=gFirma; endif

@ m_x+1,m_y+2 SAY "SUBANALITICKA KARTICA"

@ m_x+2,m_y+2 SAY "Brza kartica (D/N)" GET cBrza pict "@!" valid cBrza $ "DN"
read

do while .t.
if gNW$"DR"
  @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif
if cBrza=="D"
 qqKonto:=padr(qqkonto,7)
 qqRoba:=padr(qqRoba,10)
 @ m_x+4,m_y+2   SAY KonSeks("Konto  ")+"        " GET qqKonto   pict "@!" valid P_Konto(@qqKonto)
 @ m_x+5,m_y+2   SAY "Sifra artikla  " GET qqRoba    pict "@!" valid P_Roba(@qqRoba)
else
 qqKonto:=padr(qqKonto,60)
 qqPartner:=padr(qqPartner,60)
 qqRoba:=padr(qqRoba,80)
 @ m_x+4,m_y+2   SAY KonSeks("Konto  ")+"        " GET qqKonto   PICTURE "@S50"
 @ m_x+5,m_y+2   SAY "Partner        " GET qqPartner PICTURE "@S50"
 @ m_x+6,m_y+2   SAY "Sifra artikla  " GET qqRoba    PICTURE "@S50"
endif

@ m_x+8,m_y+2   SAY "BEZ/SA predhodnim prometom (1/2):" GET cPredh valid cpredh $ "12"
@ m_x+10,m_y+2   SAY "Datum dokumenta od:" GET dDatOd
@ m_x+10,col()+2 SAY "do" GET dDatDo valid dDatDo>=dDatOd
READ;  ESC_BCR

if cBrza=="N"
 aUsl1:=Parsiraj(qqPartner,"IdPartner","C")
 aUsl2:=Parsiraj(qqRoba,"IdRoba","C")
 aUsl3:=Parsiraj(qqKonto,"IdKonto","C")
 if aUsl1 <> NIL .and. aUsl2 <> NIL .and. aUsl3 <> NIL 
 	exit
 endif
else
 exit
endif

enddo

BoxC()

if Params2()
 WPar("c1",cBrza)
 WPar("c2",padr(cIdFirma,2)); WPar("c3",qqKonto); RPar("c4",qqPartner)
 WPar("c5",qqRoba)
 WPar("c6",cPredh)
 WPar("d1",dDatOd);WPar("d2",@dDatDo)
endif
select params
use

O_MAT_SUBAN
O_TDOK

select mat_suban
set order to tag "3"

if cBrza == "D"
	if cPredh == "1"
         	if !empty(dDatOd) .and. !empty(dDatDo)
          		set filter to  dDatOd<=DatDok .and. dDatDo>=DatDok
         	else
          		set filter to
         	endif
  	else    
  		// sa predhodnim prometom
         	if  !empty(dDatDo)
          		set filter to  dDatDo>=DatDok
         	else
          		set filter to
         	endif
  	endif
  	
	HSEEK cIdFirma + qqKonto + qqRoba

else 
       		
	cFilter := ".t."
		
	if cPredh == "1"

		if !EMPTY( dDatOd ) .and. !EMPTY( dDatDo )
 			cFilter += " .and. (DatDok >= " + ;
				cm2str( dDatOd ) + ;
				" .and. DatDok <= " + ;
				cm2str( dDatDo ) + ")"
		endif
	else
		
		if !EMPTY( dDatDo )
			cFilter += " .and. (DatDok <= " + ;
				cm2str( dDatDo ) + ")"
	
		endif
	endif

	if !EMPTY( qqPartner )
		cFilter += " .and. " + aUsl1
	endif

	if !EMPTY( qqKonto )
		cFilter += " .and. " + aUsl2
	endif

	if !EMPTY( qqRoba )
		cFilter += " .and. " + aUsl3
	endif

	set filter to &(cFilter) 
	HSEEK cIdFirma
       	

endif 

// cBrza

EOF CRET

m:="-- ---- -- -------- -------- ------ ---------- ---------- ---------- ----------- ------------- ------------- --------------- ---------------"
nStr:=0
START PRINT CRET

A:=0
nCol1:=nCol2:=0

do while !eof() .and. IdFirma==cIdFirma

  if cBrza=="D"
    if qqKonto<>IdKonto .or. qqRoba<>IdRoba
    	exit
    endif
  endif

  cIdKonto:=IdKonto
  cIdRoba:=IdRoba

  nUlazK:=nIzlazK:=nDugI:=nPotI:=0
                   nDugI2:=nPotI2:=0

  ZaglKSif()
  
  if cPredh="2"
    
    do while !eof() .and. IdFirma==cIdFirma .AND. IdKonto==cIdKonto .and. IdRoba==cIdRoba .and. datdok<dDatOd
     IF U_I="1"
        nUlazK+=Kolicina
     ELSE
        nIzlazK+=Kolicina
     ENDIF

     IF D_P="1"
        nDugI+=Iznos
        nDugI2+=Iznos2
     ELSE
        nPotI+=Iznos
        nPotI2+=Iznos2
     ENDIF
      skip
    enddo
      ? "Promet do",dDatOd
      @ prow(),36 SAY nUlazK pict pickol
      @ prow(),pcol()+1 SAY nIzlazK pict pickol
      @ prow(),pcol()+1 SAY nUlazK-nIzlazK pict pickol
      if round(nUlazK-nIzlazK,4)<>0
         nCijena=(nDugI-nPotI)/(nUlazK-nIzlazK)
      else
         nCijena:=0
      ENDIF
      @ prow(),pcol()+1 SAY nCijena pict "9999999.999"
      @ prow(),pcol()+1 SAY nDugI pict picdem
      @ prow(),pcol()+1 SAY nPotI pict picdem
      @ prow(),pcol()+1 SAY nDugI2 pict picbhd
      @ prow(),pcol()+1 SAY nPotI2 pict picbhd

  endif
  DO WHILE !eof() .and. IdFirma==cIdFirma .AND. IdKonto==cIdKonto .and. IdRoba==cIdRoba
     SELECT mat_suban

     if prow()>61; FF; ZaglKSif(); endif
     @ prow()+1,0 SAY IdVN
     @ prow(),pcol()+1 SAY BrNal
     @ prow(),pcol()+1 SAY IdTipDok
     @ prow(),pcol()+1 SAY BrDok
     @ prow(),pcol()+1 SAY DatDok
     @ prow(),pcol()+1 SAY IdPartner
     nCol1:=PCOL()+1
     IF U_I="1"
        @ prow(),pcol()+1 SAY Kolicina PICTURE PicKol
        @ prow(),pcol()+1 SAY 0 PICTURE PicKol
        nUlazK+=Kolicina
     ELSE
        @ prow(),pcol()+1 SAY 0 PICTURE PicKol
        @ prow(),pcol()+1 SAY Kolicina PICTURE PicKol
        nIzlazK+=Kolicina
     ENDIF
     @ prow(),pcol()+1 SAY nUlazK-nIzlazK pict pickol
     @ prow(),pcol()+1 SAY iif(round(Kolicina,4)<>0,Iznos/Kolicina,0) picture "9999999.999"

     nCol2:=pcol()+1
     IF D_P="1"
        @ prow(),pcol()+1 SAY Iznos PICTURE PicDem
        @ prow(),pcol()+1 SAY 0 PICTURE PicDem
        @ prow(),pcol()+1 SAY Iznos2 PICTURE PicBHD
        @ prow(),pcol()+1 SAY 0 PICTURE PicBHD
        nDugI+=Iznos
        nDugI2+=Iznos2
     ELSE
        @ prow(),pcol()+1 SAY 0 PICTURE PicDem
        @ prow(),pcol()+1 SAY Iznos PICTURE PicDem
        @ prow(),pcol()+1 SAY 0 PICTURE PicBHD
        @ prow(),pcol()+1 SAY Iznos PICTURE PicBHD
        nPotI+=Iznos
        nPotI2+=Iznos2
     ENDIF
     select mat_suban
     skip
  ENDDO

  if prow()>59; FF; ZaglKSif(); endif
  ? m
  ? "UKUPNO:"
  @ prow(),nCol1 SAY nUlazK PICTURE PicKol
  @ prow(),pcol()+1 SAY nIzlazK PICTURE PicKol
  @ prow(),pcol()+1 SAY nUlazK-nIzlazK PICTURE PicKol
  @ prow(),nCol2    SAY nDugI PICTURE PicDEM
  @ prow(),pcol()+1 SAY nPotI PICTURE PicDEM
  @ prow(),pcol()+1 SAY nDugI2 PICTURE PicBHD
  @ prow(),pcol()+1 SAY nPotI2 PICTURE PicBHD
  ? m
  ? "SALDO:"

  nSaldoI:=nDugI-nPotI
  nSaldoI2:=nDugI2-nPotI2
  nSaldoK:=nUlazK-nIzlazK
  nCijena:=0; nCijena2:=0
  IF round(nSaldoK,4)<>0
     nCijena=nSaldoI/nSaldoK
     nCijena2:=nSaldoI2/nSaldoK
  else
     nCijena:=nCijena2:=0
  ENDIF
  @ prow(),pcol()+2     SAY "CIJENA:"
  @ prow(),pcol()+1 SAY nCijena  picture "999999.999"
  @ prow(),pcol()+1 SAY ValPomocna()

  IF nSaldoK>0
     @ prow(),nCol1 SAY nSaldoK PICTURE PicKol
     @ prow(),pcol()+1 SAY 0   PICTURE PicKol
  ELSE
     nSaldoK:=-nSaldoK
     @ prow(),nCol1     SAY 0       PICTURE PicKol
     @ prow(),pcol()+1 SAY nSaldoK PICTURE PicKol
  ENDIF
  @ prow(),pcol()+1 SAY space(len(pickol))

  IF nSaldoI>0
     @ prow(),nCol2 SAY nSaldoI PICTURE PicDEM
     @ prow(),pcol()+1 SAY 0 PICTURE PicDEM
  ELSE
     nSaldoI:=-nSaldoI
     @ prow(),nCol2  SAY 0         PICTURE PicDEM
     @ prow(),pcol()+1 SAY nSaldoI PICTURE PicDEM
  ENDIF
  IF nSaldoI2>0
     @ prow(),pcol()+1 SAY nSaldoI2 PICTURE PicBHD
     @ prow(),pcol()+1 SAY 0        PICTURE PicBHD
  ELSE
     nSaldoI2:=-nSaldoI2
     @ prow(),pcol()+1 SAY 0         PICTURE PicBHD
     @ prow(),pcol()+1 SAY nSaldoI2  PICTURE PicBHD
  ENDIF

  ? m
  ?
enddo // eof

FF
END PRINT
closeret
return


static function ZaglKSif()

?
P_COND2

?? "MAT.P: SUBANALITICKA KARTICA   NA DAN "; @ prow(),PCOL()+1 SAY DATE()
? "FIRMA:"
@ prow(),pcol()+1 SAY cIdFirma
SELECT PARTN; HSEEK cIdFirma
@  prow(),pcol()+2 SAY naz
@  prow(),pcol()+1 SAY naz2
@  prow(),120 SAY "Str."+str(++nStr,3)

? "ARTIKAL:"
@ prow(),pcol()+1 SAY cIdRoba
select ROBA; HSEEK cIdRoba
@ prow(),pcol()+1 SAY naz
@ prow(),pcol()+2 SAY jmj

? KonSeks("KONTO")+":"
@ prow(),pcol()+1 SAY cIdKonto

SELECT KONTO; HSEEK cIdKonto
@ prow(),pcol()+1 SAY konto->naz

?  "------- --------------------------- --------------------- ---------- ----------- --------------------------- -------------------------------"
?  "*NALOG *   D O K U M E N T         *       KOLICINA      *  STANJE  *  CIJENA   *     I Z N O S   "+ValPomocna()+"      *     I Z N O S    "+ValDomaca()+"        *"
?  "------- --------------------------- ---------------------           *           * -------------------------- -------------------------------"
?  "*V*BROJ*TIP* BROJ  * DATUM  * PART *   ULAZ   *   IZLAZ  *          *   "+ValPomocna()+"    *    DUGUJE   *   POTRAZUJE *    DUGUJE     *   POTRAZUJE  *"
?  "*N*    *  *        *        * NER  *          *          *          *           *             *             *               *              *"
?  m


SELECT mat_suban
return


