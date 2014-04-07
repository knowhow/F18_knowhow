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


#include "kalk.ch"


// stampanje fin naloga iz FIN-a
function P_Fin( lAuto )
private gDatNal:="N"
private gRavnot:="D"
private cDatVal:="D"

if (lAuto == nil)
	lAuto := .f.
endif

if gafin == "D"
	
	// kontrola zbira - uravnotezenje
 	KZbira( lAuto )
	
	if lAuto == .f. .or. (lAuto == .t. .and. gAImpPrint == "D" ) 
		// stampa fin naloga
 		StNal( lAuto )
	else
		fill_psuban()
		sintstav()
	endif
	
	// azuriranje fin naloga
 	fin_azur( lAuto )

endif

return



// stampa fin naloga
static function StNal( lAuto )
private dDatNal := date()

if lAuto == nil
	lAuto := .f.
endif

StAnalNal( lAuto )
SintStav()

return



// ---------------------------------------------
// filovanje potrebnih tabela kod auto importa
// ---------------------------------------------
static function fill_psuban()

my_close_all_dbf()

O_FIN_PRIPR
O_KONTO
O_PARTN
O_TNAL
O_TDOK
O_PSUBAN

select PSUBAN
my_dbf_zap()

SELECT fin_pripr
set order to tag "1"
go top

if EOF()
	my_close_all_dbf()
	return
endif

DO WHILE !EOF()
	
	cIdFirma := IdFirma
	cIdVN := IdVN
	cBrNal := BrNal

	b2:={|| cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal}

   	DO WHILE !eof() .and. eval(b2)

        select PSUBAN
		Scatter()
		select fin_pripr
		Scatter()

        SELECT PSUBAN
        APPEND BLANK
        Gather()  

		select fin_pripr         
	    SKIP
      
      ENDDO

ENDDO   

my_close_all_dbf()
return


// ----------------------------------------
// stampa analitickog naloga
// ----------------------------------------
static function StAnalNal(lAuto)

O_FIN_PRIPR
O_KONTO
O_PARTN
O_TNAL
O_TDOK
O_PSUBAN

PicBHD := "@Z 999999999999.99"
PicDEM := "@Z 9999999.99"

// fin nalog jednovalutno ili dvovalutno
gVar1 := VAL( fetch_metric("fin_izvjestaji_jednovalutno", nil, "1" ) )

M := "---- ------- ------ ---------------------------- ----------- -------- -------- --------------- ---------------" + IF( gVar1 == 1, "-", " ---------- ----------")

if lAuto == nil
	lAuto := .f.
endif

select PSUBAN
my_dbf_zap()

SELECT fin_pripr
set order to tag "1"
go top

if EOF()
	closeret2
endif

nUkDugBHD:=nUkPotBHD:=nUkDugDEM:=nUkPotDEM:=0
DO WHILE !EOF()

	cIdFirma := IdFirma
	cIdVN := IdVN
	cBrNal := BrNal

   	if !lAuto
    	Box("",2,50)
     		set cursor on
    		@ m_x+1,m_y+2 SAY "Finansijski nalog broj:" GET cIdFirma
     		@ m_x+1,col()+1 SAY "-" GET cIdVn
     		@ m_x+1,col()+1 SAY "-" GET cBrNal
     		if gDatNal=="D"
      			@ m_x+2,m_y+2 SAY "Datum naloga:" GET dDatNal
     		endif
    		read
     		ESC_BCR
    	BoxC()
   	endif	

   	HSEEK cIdFirma+cIdVN+cBrNal
   	if eof()
   		closeret2
   	endif

   	START PRINT CRET

   	?

   	nStr:=0
   	nUkDug:=0
	nUkPot:=0

   	b2:={|| cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal }

   	cIdFirma := IdFirma
	cIdVN := IdVN
	cBrNal := BrNal
   	
	kalk_zagl_11()
   	
	DO WHILE !eof() .and. eval(b2)

    	if prow() > ( RPT_PAGE_LEN + gPStranica )
	 		FF
	 		kalk_zagl_11()
	 	endif

        P_NRED
 
        @ prow(),0 SAY RBr
        @ prow(),pcol()+1 SAY IdKonto

        if !empty(IdPartner)
        	select PARTN
			hseek fin_pripr->idpartner
           	cStr:=trim(naz)+" "+trim(naz2)
      	else
       		select KONTO
			hseek fin_pripr->idkonto
           	cStr:=naz
      	endif
        select fin_pripr

        aRez:=SjeciStr(cStr,28)

        @ prow(),pcol()+1 SAY IdPartner

        nColStr:=PCOL()+1
        @  prow(),pcol()+1 SAY padr(aRez[1],28) // dole cu nastaviti

      	nColDok:=PCOL()+1
 
     	@ prow(),pcol()+1 SAY padr(BrDok,11)
      	@ prow(),pcol()+1 SAY DatDok

      	if cDatVal=="D"
       		@ prow(),pcol()+1 SAY DatVal
      	else
      		@ prow(),pcol()+1 SAY space(8)
      	endif

      	nColIzn:=pcol()+1

      	IF D_P=="1"
        	@ prow(),pcol()+1 SAY IznosBHD PICTURE PicBHD
         	@ prow(),pcol()+1 SAY 0 PICTURE PicBHD
         	nUkDugBHD+=IznosBHD
      	ELSE
        	@ prow(),pcol()+1 SAY 0 PICTURE PicBHD
         	@ prow(),pcol()+1 SAY IznosBHD PICTURE PicBHD
         	nUkPotBHD+=IznosBHD
      	ENDIF

      	IF gVar1 != 1
      		if D_P=="1"
          		@ prow(),pcol()+1 SAY IznosDEM PICTURE PicDEM
          		@ prow(),pcol()+1 SAY 0 PICTURE PicDEM
          		nUkDugDEM+=IznosDEM
       		else
          		@ prow(),pcol()+1 SAY 0 PICTURE PicDEM
          		@ prow(),pcol()+1 SAY IznosDEM PICTURE PicDEM
          		nUkPotDEM+=IznosDEM
       		endif
      	ENDIF

      	Pok := 0
      	
		for i:=2 to LEN( aRez )
        	
			P_NRED
        	@ prow(), nColStr SAY aRez[i]
        	
			If i = 2

           		@ prow(), nColDok say PADR( opis, 40 )

           		if !Empty(k1+k2+k3+k4)
             		?? " " + k1 + "-" + k2 + "-" + k3 + "-" + k4
           		endif

           		Pok := 1

        	endif

      	next

      	If Pok=0 .and. !Empty(opis+k1+k2+k3+k4)
        	P_NRED
         	@ prow(), nColDok SAY PADR( opis, 40 ) + " " + k1 + "-" + k2 + "-" + k3 + "-" + k4
     	endif

        select PSUBAN
		Scatter()

		select fin_pripr
		Scatter()

        SELECT PSUBAN
        APPEND BLANK
        Gather()  
		 
		// stavi sve vrijednosti iz pripr u PSUBAN
        select fin_pripr
        SKIP
      
	ENDDO

    IF prow() > ( RPT_PAGE_LEN + gPStranica )
		FF
		kalk_zagl_11()
	endif

    ? M
    ? "Z B I R   N A L O G A:"
    @ prow(),nColIzn SAY nUkDugBHD PICTURE picBHD
    @ prow(),pcol()+1 SAY nUkPotBHD PICTURE picBHD
    @ prow(),pcol()+1 SAY nUkDugDEM PICTURE picDEM
    @ prow(),pcol()+1 SAY nUkPotDEM PICTURE picDEM
      
	? M

    nUkDugBHD:=nUKPotBHD:=nUkDugDEM:=nUKPotDEM:=0

    if gPotpis=="D"
    	IF prow() > ( RPT_PAGE_LEN + gPStranica )
			FF
			kalk_zagl_11()
		endif
      	?
      	?
		P_12CPI
      	@ prow()+1,55 SAY "Obrada AOP "
		?? replicate("_",20)
      	@ prow()+1,55 SAY "Kontirao   "
		?? replicate("_",20)
  	endif
    FF
    END PRINT

ENDDO   

my_close_all_dbf()

return



function kalk_zagl_11()
local nArr
local _val := VAL( fetch_metric("fin_izvjestaji_jednovalutno", nil, "1" ) )

P_COND
B_ON

?? UPPER( ALLTRIM( gTS )) + ":", ALLTRIM( gNFirma )
?

nArr := SELECT()

if gNW == "N"
	select partn
	hseek cIdFirma
	select (nArr)
   	? cIdFirma, "-", PADR( partn->naz, 40 )
endif

?
? "FIN.P: NALOG ZA KNJIZENJE BROJ :"

@ prow(), PCOL() + 2 SAY cIdFirma + " - " + cIdVn + " - " + cBrNal

B_OFF

if gDatNal == "D"
	@ prow(),pcol()+4 SAY "DATUM: "
 	?? dDatNal
endif

select TNAL
hseek cIdVn

@ prow(),pcol()+4 SAY naz
@ prow(),pcol()+15 SAY "Str:"+str(++nStr,3)

P_NRED
?? M

P_NRED
?? "*R. * KONTO * PART *    NAZIV PARTNERA ILI      *   D  O  K  U  M  E  N  T    *         IZNOS U  "+ValDomaca()+"         *" + if( _val != 1, "    IZNOS U "+ValPomocna()+"    *", "" )

P_NRED
?? "              NER                                ----------------------------- ------------------------------- " + if( _val != 1, "---------------------", "" )

P_NRED
?? "*BR *       *      *    NAZIV KONTA             * BROJ VEZE * DATUM  * VALUTA *  DUGUJE "+ValDomaca()+"  * POTRAZUJE "+ValDomaca()+"*" + if( _val != 1, " DUG. "+ValPomocna()+"* POT."+ValPomocna()+"*", "" )

P_NRED
?? M

select(nArr)
return





/*! \fn SintStav()
 *  \brief Formiranje sintetickih stavki
 */

static function SintStav( lAuto )

O_PANAL
O_PSINT
O_PNALOG
O_PSUBAN
O_KONTO
O_TNAL

if lAuto == NIL
	lAuto := .f.
endif

select PANAL
my_dbf_zap()

select PSINT
my_dbf_zap()

select PNALOG
my_dbf_zap()

select PSUBAN
set order to tag "2"
go top

if empty(BrNal)
	if lAuto == .t.
		closeret
	else
		closeret2
	endif
endif

A:=0

DO WHILE !eof()   
   // svi nalozi

   nStr := 0
   nD1 := 0
   nD2 := 0
   nP1 := 0
   nP2 := 0
   
   cIdFirma := IdFirma
   cIDVn := IdVN
   cBrNal := BrNal

   DO WHILE !EOF() .and. cIdFirma == IdFirma ;
   		.and. cIdVN == IdVN ;
		.and. cBrNal == BrNal

         cIdkonto := idkonto

         nDugBHD:=0
	 nDugDEM:=0
         nPotBHD:=0
	 nPotDEM:=0
         
	 if D_P="1"
               nDugBHD:=IznosBHD
	       nDugDEM:=IznosDEM
         else
               nPotBHD:=IznosBHD
	       nPotDEM:=IznosDEM
         endif

         SELECT PANAL     
	 // analitika
         seek cIdFirma + cIdVn + cBrNal + cIdKonto
	 
         fNasao:=.f.
         
	 DO WHILE !EOF() .and. cIdFirma == IdFirma ;
	 	.and. cIdVN == IdVN .and. cBrNal==BrNal ;
                .and. IdKonto == cIdKonto
		
           if gDatNal=="N"
              if month(psuban->datdok) == month(datnal)
                fNasao:=.t.
                exit
              endif
           else  
	      // sintetika se generise na osnovu datuma naloga
              if month(dDatNal)==month(datnal)
                fNasao:=.t.
                exit
              endif
           endif
           skip
         enddo

         if !fNasao
            append blank
         endif

         my_rlock()

         replace IdFirma WITH cIdFirma
	 replace IdKonto WITH cIdKonto
	 replace IdVN WITH cIdVN
         replace BrNal with cBrNal
         replace DatNal with iif(gDatNal=="D", dDatNal, max(psuban->datdok,datnal))
         replace DugBHD WITH DugBHD + nDugBHD
	 replace PotBHD WITH PotBHD + nPotBHD
         replace DugDEM WITH DugDEM + nDugDEM
	 replace PotDEM WITH PotDEM + nPotDEM
         my_unlock()


         SELECT PSINT
         seek cidfirma+cidvn+cbrnal+left(cidkonto,3)
         fNasao:=.f.
         
	 DO WHILE !eof() .and. cIdFirma==IdFirma ;
	 	.AND. cIdVN==IdVN .AND. cBrNal==BrNal ;
                   .and. left(cidkonto,3)==idkonto
           if gDatNal=="N"
            if  month(psuban->datdok)==month(datnal)
              fNasao:=.t.
              exit
            endif
           else // sintetika se generise na osnovu dDatNal
              if month(dDatNal)==month(datnal)
                fNasao:=.t.
                exit
              endif
           endif

           skip
         ENDDO
         
	 if !fNasao
             append blank
         endif

         my_rlock()
         REPLACE IdFirma WITH cIdFirma,IdKonto WITH left(cIdKonto,3),IdVN WITH cIdVN,;
              BrNal WITH cBrNal,;
              DatNal WITH iif(gDatNal=="D", dDatNal,  max(psuban->datdok,datnal) ),;
              DugBHD WITH DugBHD+nDugBHD,PotBHD WITH PotBHD+nPotBHD,;
              DugDEM WITH DugDEM+nDugDEM,PotDEM WITH PotDEM+nPotDEM

         my_unlock()

         nD1+=nDugBHD; nD2+=nDugDEM; nP1+=nPotBHD; nP2+=nPotDEM

        SELECT PSUBAN
        skip
	
   ENDDO  
   // nalog

   SELECT PNALOG    // datoteka naloga
   APPEND BLANK

   my_rlock()

   REPLACE IdFirma WITH cIdFirma,IdVN WITH cIdVN,BrNal WITH cBrNal,;
           DatNal WITH iif(gDatNal=="D",dDatNal,date()),;
           DugBHD WITH nD1,PotBHD WITH nP1,;
           DugDEM WITH nD2,PotDEM WITH nP2

   my_unlock()

   private cDN:="N"

   SELECT PSUBAN

ENDDO  
// svi nalozi

select PANAL
go top
my_flock()
do while !eof()
   nRbr:=0
   cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
   do while !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog
     replace rbr with str(++nRbr,3)
     skip
   enddo
enddo
my_unlock()

select PSINT
go top
my_flock()
do while !eof()
   nRbr:=0
   cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
   do while !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog
     replace rbr with str(++nRbr,3)
     skip
   enddo
enddo
my_unlock()

my_close_all_dbf()

return


// ------------------------------------------
// stampa sintetickog naloga
// ------------------------------------------
static function StOSNal( fkum )

if fkum == NIL
	fkum := .t.
endif

PicBHD:='@Z 99999999999999.99'
PicDEM:='@Z 999999999.99'
M:="---- -------- ------- --------------------------------------------- ----------------- ----------------- ------------ ------------"

if fkum  
	
	// stampa starog naloga - naloga iz kumulativa - datoteka anal
	select ( F_ANAL )
	if used()
		use
	endif

 	my_use_temp( "PANAL", my_home() + "fin_anal", .f., .f. )
	set order to tag "2"
 
 	O_KONTO
 	O_PARTN
 	O_TNAL
 	O_NALOG

 	cIdFirma := cIdVN := space(2)
 	cBrNal := space(8)

 	Box("",1,35)
  		@ m_x+1,m_y+2 SAY "Nalog:" GET cIdFirma
  		@ m_x+1,col()+1 SAY "-" GET cIdVN
  		@ m_x+1,col()+1 SAY "-" GET cBrNal
  		read
		ESC_BCR
 	BoxC()

	select nalog
 	seek cidfirma+cidvn+cbrnal
 	NFOUND CRET  // ako ne postoji
 	dDatNal:=datnal

 	select PANAL
 	seek cidfirma+cidvn+cbrNal
 	
	START PRINT CRET

else
 	cIdFirma:=idfirma
	cIdvn:=idvn
	cBrNal:=brnal
 	seek cidfirma+cidvn+cbrNal
 	START PRINT RET
endif

nStr:=0
b1:={|| !eof()}

nCol1:=70

 cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
 b2:={|| cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal}
 b3:={|| cIdSinKon==LEFT(IdKonto,3)}
 b4:={|| cIdKonto==IdKonto}
 nDug3:=nPot3:=0
 nRbr2:=0 // brojac sint stavki
 nRbr:=0
 nUkUkDugBHD:=nUkUkPotBHD:=nUkUkDugDEM:=nUkUkPotDEM:=0
 Zagl12()
 DO WHILE eval(b1) .and. eval(b2)     // jedan nalog

    IF prow()-gPStranica>63; FF; Zagl12(); ENDIF
    cIdSinKon:=LEFT(IdKonto,3)
    nUkDugBHD:=nUkPotBHD:=nUkDugDEM:=nUkPotDEM:=0
    DO WHILE  eval(b1) .and. eval(b2) .and. eval(b3)  // sinteticki konto

       cIdKonto:=IdKonto
       nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0
       IF prow()-gPStranica>63; FF; Zagl12(); ENDIF
       DO WHILE  eval(b1) .and. eval(b2) .and. eval(b4)  // analiticki konto
          select KONTO; hseek cidkonto
          select PANAL
          @ prow()+1,0 SAY  ++nRBr PICTURE '9999'
          @ prow(),pcol()+1 SAY datnal
          @ prow(),pcol()+1 SAY cIdKonto
          @ prow(),pcol()+1 SAY left(KONTO->naz,45)
          nCol1:=pcol()+1
          @ prow(),nCol1 SAY DugBHD PICTURE PicBHD
          @ prow(),pcol()+1 SAY PotBHD PICTURE PicBHD
          @ prow(),pcol()+1 SAY DugDEM PICTURE PicDEM
          @ prow(),pcol()+1 SAY PotDEM PICTURE PicDEM
          nDugBHD+=DugBHD; nDugDEM+=DUGDEM
          nPotBHD+=PotBHD; nPotDEM+=POTDEM
          SKIP
       enddo

       nUkDugBHD+=nDugBHD; nUkPotBHD+=nPotBHD
       nUkDugDEM+=nDugDEM; nUkPotDEM+=nPotDEM
    ENDDO  // siteticki konto

    IF prow()-gPStranica>62; FF; Zagl12(); ENDIF
    ? M
    @ prow()+1,1 SAY ++nRBr2 PICTURE '999'
    @ prow(),pcol()+1 SAY PADR(cIdSinKon,6)
    SELECT KONTO; HSEEK cIdSinKon
    @ prow(),pcol()+1 SAY LEFT(Naz,45)
    SELECT PANAL
    @ prow(),nCol1 SAY nUkDugBHD PICTURE PicBHD
    @ prow(),pcol()+1 SAY nUkPotBHD PICTURE PicBHD
    @ prow(),pcol()+1 SAY nUkDugDEM PICTURE PicDEM
    @ prow(),pcol()+1 SAY nUkPotDEM PICTURE PicDEM
    ? M

    nUkUkDugBHD+=nUkDugBHD
    nUKUkPotBHD+=nUkPotBHD
    nUkUkDugDEM+=nUkDugDEM
    nUkUkPotDEM+=nUkPotDEM

 ENDDO  // nalog

 IF prow()-gPStranica>61; FF; Zagl12(); ENDIF

 ? M
 ? "ZBIR NALOGA:"
 @ prow(),nCol1 SAY nUkUkDugBHD PICTURE PicBHD
 @ prow(),pcol()+1 SAY nUkUkPotBHD PICTURE PicBHD
 @ prow(),pcol()+1 SAY nUkUkDugDEM PICTURE PicDEM
 @ prow(),pcol()+1 SAY nUkUkPotDEM PICTURE PicDEM
 ? M

FF
END PRINT

if fkum
	closeret2
endif

return


static function Zagl12()
local nArr
P_COND
?? "FIN.P: ANALITIKA/SINTETIKA -  NALOG ZA KNJIZENJE BROJ : "
@ prow(),PCOL()+2 SAY cIdFirma+" - "+cIdVn+" - "+cBrNal
if gDatNal=="D"
 @ prow(),pcol()+4 SAY "DATUM: "
 ?? dDatNal
endif

SELECT TNAL; HSEEK cIdVN; select PANAL
@ prow(),pcol()+4 SAY tnal->naz
@ prow(),120 SAY "Str:"+str(++nStr,3)

gVar1:="1"
P_NRED; ?? m
P_NRED; ?? "*RED*"+PADC(if(.t.,"","DATUM"),8)+"*           NAZIV KONTA                               *            IZNOS U "+ValDomaca()+"           *"+IF(gVar1=="1","","     IZNOS U "+ValPomocna()+"       *")
P_NRED; ?? "    *        *                                                      ----------------------------------- "+IF(gVar1=="1","","-------------------------")
P_NRED; ?? "*BR *        *                                                     * DUGUJE  "+ValDomaca()+"    * POTRAZUJE  "+ValDomaca()+" *"+IF(gVar1=="1",""," DUG. "+ValPomocna()+"  * POT. "+ValPomocna()+" *")
P_NRED; ?? m

return


// -----------------------------------------------
// kontrola zbira naloga prije azuriranja
// -----------------------------------------------
function KZbira( lAuto )

O_KONTO
O_VALUTE
O_FIN_PRIPR

if lAuto == nil
	lAuto := .f.
endif

Box("kzb",12,70,.f.,"Kontrola zbira FIN naloga")
	
	set cursor on
 	
	cIdFirma:=IdFirma
	cIdVN:=IdVN
	cBrNal:=BrNal

 	@ m_x+1,m_y+2 SAY "Nalog broj: "+cidfirma+"-"+cidvn+"-"+cBrNal

 	set order to tag "1"
 	seek cIdFirma+cIdVn+cBrNal

 	private dug:=0
	private dug2:=0
	private Pot:=0
	private Pot2:=0


 	do while  !eof() .and. (IdFirma+IdVn+BrNal==cIdFirma+cIdVn+cBrNal)
   		
		if D_P == "1"
			dug += IznosBHD
			dug2 += iznosdem
		else
			pot += IznosBHD
			pot2 += iznosdem
		endif
   		
		skip
 	enddo
 	
	SKIP -1
 	
	Scatter()

 	cPic:="999 999 999 999.99"
 	
	@ m_x+5,m_y+2 SAY "Zbir naloga:"
 	@ m_x+6,m_y+2 SAY "     Duguje:"
 	@ m_x+6,COL()+2 SAY Dug PICTURE cPic
 	@ m_x+6,COL()+2 SAY Dug2 PICTURE cPic
 	@ m_x+7,m_y+2 SAY "  Potrazuje:"
 	@ m_x+7,COL()+2 SAY Pot  PICTURE cPic
 	@ m_x+7,COL()+2 SAY Pot2  PICTURE cPic
 	@ m_x+8,m_y+2 SAY "      Saldo:"
 	@ m_x+8,COL()+2 SAY Dug-Pot  PICTURE cPic
 	@ m_x+8,COL()+2 SAY Dug2-Pot2  PICTURE cPic

 	IF Round(Dug-Pot, 2 ) <> 0
   		
		private cDN:="D"
   		
		if lAuto == .f.
			
		  set cursor on
			
		  @ m_x+10,m_y+2 SAY "Zelite li uravnoteziti nalog (D/N) ?" GET cDN valid (cDN $ "DN") pict "@!"
   		  
		  read
		  
   		else
			// uravnoteziti nalog ako je auto import
			cDN := "D"
		endif
		
   		if cDN == "D"
     	
			_Opis:="GRESKA ZAOKRUZ."
     			_BrDok:=""
     			_D_P:="2"
			_IdKonto:=SPACE(7)
     			
			if lAuto == .f.
			  
			  @ m_x+11,m_y+2 SAY "Staviti na konto ?" ;
				GET _IdKonto valid P_Konto(@_IdKonto)
     			  @ m_x+11,col()+1 SAY "Datum dokumenta:" GET _DatDok
     			  
			  read
			
			else
			
			  _idkonto := gAImpRKonto
			  
			  if EMPTY(_idkonto)
			  	_idkonto := "1370   "
			  endif
			  
			endif
			
     			if lAuto == .t. .or. lastkey() <> K_ESC
			       				
				_Rbr:=str(val(_Rbr)+1,4)
      				_IdPartner:=""
       				_IznosBHD:=Dug-Pot
       			
				nTArea := SELECT()
				
				DinDem(NIL,NIL,"_IZNOSBHD")
       			
				select (nTArea)
			
				append blank
       				
				Gather()
				
     			endif
   		endif
 	endif
BoxC()

my_close_all_dbf()

return



