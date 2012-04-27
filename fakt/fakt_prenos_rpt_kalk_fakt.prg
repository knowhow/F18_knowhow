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



// -----------------------------------------------------
// poredjenje fakt -> kalk
// -----------------------------------------------------
function uporedna_lista_fakt_kalk(lFaktFakt)
local cIdFirma,qqRoba,nRezerv,nRevers
local nul,nizl,nRbr,cRR,nCol1:=0
local m:=""
local cDirFakt, cDirKalk
local cViseKonta
private dDatOd, dDatDo
private gDirKalk := ""
private cOpis1:=PADR("F A K T",12)
private cOpis2:="FAKT 2.FIRMA"

if lFaktFakt==nil
	lFaktFakt:=.f.
endif

O_FAKT_DOKS
O_KALK
O_KONTO
O_TARIFA
O_SIFK
O_SIFV
O_ROBA
O_RJ
O_FAKT

select fakt
set order to tag "3"
// idroba

cKalkFirma := gFirma
cIdfirma := gFirma
qqRoba:=""
dDatOd:=ctod("")
dDatDo:=date()
cRazlKol := "D"
cRazlVr  := "D"
cMP := "M"
cIdKonto := PADR( "1320", 7 )
qqKonto := cIdKonto

cViseKonta := ""
lViseKonta := .f.

qqPartn := space(20)
private qqTipdok:="  "

Box(,16,66)

cIdFirma := fetch_metric("fakt_uporedna_lista_id_firma", my_user(), cIdFirma )
qqRoba := fetch_metric( "fakt_uporedna_lista_roba", my_user(), qqRoba )
dDatOd := fetch_metric( "fakt_uporedna_lista_datum_od", my_user(), dDatOd )
dDatDo := fetch_metric( "fakt_uporedna_lista_datum_do", my_user(), dDatDo )
cRazlKol := fetch_metric( "fakt_uporedna_lista_razlika_kolicina", my_user(), cRazlKol )
cRazlVr := fetch_metric( "fakt_uporedna_lista_razlika_vrijednosti", my_user(), cRazlVr )
cMp := fetch_metric( "fakt_uporedna_lista_mp", my_user(), cMP )
qqKonto := fetch_metric( "fakt_uporedna_lista_konta", my_user(), qqKonto )
cKalk_firma := fetch_metric( "fakt_uporedna_lista_kalk_id_firma", my_user(), cKalkFirma )
cOpis1 := fetch_metric( "fakt_uporedna_lista_opis_1", my_user(), cOpis1 )
cOpis2 := fetch_metric( "fakt_uporedna_lista_opis_2", my_user(), cOpis2 )
cIdKonto := fetch_metric( "fakt_uporedna_lista_konto", my_user(), cIdKonto )

cIdKonto := qqKonto

if lFaktFakt
    if Pitanje(,"Podesiti direktorij FAKT-a druge firme? (D/N)","N")=='D'
        Box(,6,70)
            @ m_x+1, m_y+2 SAY "Kum.dir.drugog FAKT-a:" GET cF2F  PICT "@!"
            @ m_x+2, m_y+2 SAY "Sif.dir.drugog FAKT-a:" GET cF2FS PICT "@!"
            @ m_x+3, m_y+2 SAY "Zaglavlje stanja u FAKT:" GET cOpis1 PICT "@!"
            @ m_x+4, m_y+2 SAY "Zaglav.st.FAKT 2.firme :" GET cOpis2 PICT "@!"
            READ
        BoxC()
    endif
endif

qqRoba:=padr(qqRoba,60)
qqKonto:=padr(qqKonto,IF(lViseKonta,60,7))
qqPartn:=padr(qqPartn,20)
qqTipDok:=padr(qqTipDok,2)

cRR:="N"

private cTipVPC:="1"

cK1:=cK2:=space(4)

do while .t.
    
	cIdFirma := LEFT( cIdFirma, 2 )
    
	if lFaktFakt
        @ m_x+1,m_y+2 SAY "RJ" GET cIdFirma VALID {|| cIdFirma == gFirma .or. P_RJ( @cIdFirma ), cIdFirma := LEFT( cIdFirma, 2 ), .t.  }
        @ m_x+3,m_y+2 SAY "RJ u FAKT druge firme"  GET cKalkFirma pict "@!S40"
        @ m_x+4,m_y+2 SAY "Roba   "  GET qqRoba   pict "@!S40"
        @ m_x+5,m_y+2 SAY "Od datuma"  get dDatOd
        @ m_x+5,col()+1 SAY "do datuma"  get dDatDo
        cRazlKol:="D"
        cRazlVr:="N"
    else
        
		@ m_x+1,m_y+2 SAY "RJ" GET cIdFirma VALID {|| cIdfirma == gFirma .or. P_RJ(@cIdFirma), cIdFirma := LEFT( cIdFirma, 2), .t. }
        
		if lViseKonta
            @ m_x+2,m_y+2 SAY "Konto u KALK"  GET qqKonto ;
                        WHEN  {|| qqKonto:=Iif (!Empty(cIdKonto),cIdKonto+" ;",qqKonto), .T.} PICT "@!S20"
        else
            @ m_x+2,m_y+2 SAY "Konto u KALK"  GET qqKonto ;
                        WHEN  {|| qqKonto:=Iif (!Empty(cIdKonto),cIdKonto,qqKonto), .T.} ;
                        VALID P_Konto (@qqKonto)
        endif
        @ m_x+3,m_y+2 SAY "Oznaka firme u KALK"  GET cKalkFirma pict "@!S40"
        @ m_x+4,m_y+2 SAY "Roba   "  GET qqRoba   pict "@!S40"
        @ m_x+5,m_y+2 SAY "Od datuma"  get dDatOd
        @ m_x+5,col()+1 SAY "do datuma"  get dDatDo
        @ m_x+6,m_y+2 SAY "Prikazi ako se razlikuju kolicine (D/N)" GET cRazlKol pict "@!" VALID cRazlKol $ "DN"
        @ m_x+7,m_y+2 SAY "Prikazi ako se razlikuju vrijednosti (D/N)" GET cRazlVr pict "@!" VALID cRazlVr $ "DN"
        
        if gVarC $ "12"
            @ m_x+9,m_y+2 SAY "Stanje u FAKT prikazati sa Cijenom 1/2 (1/2) "  get cTipVpc pict "@!" valid cTipVPC $ "12"
        endif

        @ m_x+10,m_y+2 SAY "K1" GET  cK1 pict "@!"
        @ m_x+10,col()+1 SAY "K2" GET  cK2 pict "@!"

	endif

  	read

  	ESC_BCR

  	aUsl1:=Parsiraj(qqRoba,"IdRoba")

 	if lViseKonta
    	aUsl2:=Parsiraj(qqKonto,"MKONTO")
    	if aUsl1<>nil .and. (lFaktFakt .or. aUsl2<>nil)
			exit
		endif
	else
    	if aUsl1<>nil
    		exit
    	endif
  	endif
enddo

cSintetika := "N"

qqRoba := TRIM( qqRoba )

// snimi parametre u sql/db
set_metric("fakt_uporedna_lista_id_firma", my_user(), cIdFirma )
set_metric( "fakt_uporedna_lista_roba", my_user(), qqRoba )
set_metric( "fakt_uporedna_lista_datum_od", my_user(), dDatOd )
set_metric( "fakt_uporedna_lista_datum_do", my_user(), dDatDo )
set_metric( "fakt_uporedna_lista_razlika_kolicina", my_user(), cRazlKol )
set_metric( "fakt_uporedna_lista_razlika_vrijednosti", my_user(), cRazlVr )
set_metric( "fakt_uporedna_lista_mp", my_user(), cMP )
set_metric( "fakt_uporedna_lista_konta", my_user(), qqKonto )
set_metric( "fakt_uporedna_lista_kalk_id_firma", my_user(), cKalkFirma )
set_metric( "fakt_uporedna_lista_opis_1", my_user(), cOpis1 )
set_metric( "fakt_uporedna_lista_opis_2", my_user(), cOpis2 )
set_metric( "fakt_uporedna_lista_konto", my_user(), cIdKonto )

if lFaktFakt

  //fakt-fakt uporedi
  cDirFakt:=SezRad(TRIM(cF2F))
  USE (cDirFakt+"FAKT") ALIAS KALK NEW
  SET ORDER to TAG "3"
  if TRIM(cF2FS) != TRIM(goModul:oDataBase:cDirSif)
    USE (SezRad(TRIM(cF2FS))+"ROBA") ALIAS ROBA2 NEW
  endif
  
endif

aDbf := {}
AADD (aDbf, {"IdRoba", "C", 10, 0})
AADD (aDbf, {"FST",    "N", 15, 5})
AADD (aDbf, {"FVR",    "N", 15, 5})
AADD (aDbf, {"KST",    "N", 15, 5})
AADD (aDbf, {"KVR",    "N", 15, 5})
DBCREATE( my_home() + "pom", aDbf )

select ( F_POM )
if used()
	use
endif

my_use_temp( "POM", my_home() + "pom", .f., .t. )
index on IdRoba to (my_home() + "pomi1")

SET INDEX to (my_home() + "pomi1")

BoxC()

select fakt

private cFilt1:=""
cFilt1 := aUsl1+IF(EMPTY(dDatOd),"",".and.DATDOK>="+cm2str(dDatOd))+;
                IF(EMPTY(dDatDo),"",".and.DATDOK<="+cm2str(dDatDo))
cFilt1 := STRTRAN(cFilt1,".t..and.","")

if !(cFilt1==".t.")
  SET FILTER to &cFilt1
else
  SET FILTER TO
endif

SELECT RJ
HSEEK cIdFirma

select KALK

private cFilt2:=""

if !lFaktFakt .and. lViseKonta
  if ! RJ->(Found()) .or. Empty (RJ->Tip) .or. RJ->Tip="V"
    // veleprodajna cijena u FAKT, uzimam MKONTO u KALK
    cTipC := "V"
  else
    // u suprotnom, uzimam PKONTO
    aUsl2:=Parsiraj(qqKonto,"PKONTO")
    cTipC := "M"
  endif
endif

cFilt2 := aUsl1+IF(EMPTY(dDatOd),"",".and.DATDOK>="+cm2str(dDatOd))+;
                IF(EMPTY(dDatDo),"",".and.DATDOK<="+cm2str(dDatDo))
if !lFaktFakt .and. lViseKonta
  cFilt2 += ".and."+aUsl2+".and.IDFIRMA=="+cm2str(cKalkFirma)
  set order to tag "7"
endif

cFilt2 := STRTRAN(cFilt2,".t..and.","")

if !(cFilt2==".t.")
  SET FILTER to &cFilt2
else
  SET FILTER TO
endif

SELECT FAKT
go top
FaktEof := EOF()

SELECT KALK
GO TOP
KalkEof := EOF()

if FaktEof .and. KalkEof
  Beep (3)
  Msg ("Ne postoje trazeni podaci")
  CLOSERET
endif

START PRINT CRET

SELECT FAKT

do while !EOF()
  
	cIdRoba:=IdRoba
  	nSt := 0
	nVr := 0
  	
	while !EOF() .and. cIdRoba == field->IdRoba
    	
		if field->idfirma <> cIdfirma
    		skip
			loop
    	endif
    	
		// atributi!!!!!!!!!!!!!
    	if !empty(ALLTRIM( cK1 ))
      		if ck1 <> K1
      			skip
				loop
      		endif
    	endif
    	
		if !empty( ALLTRIM( cK2 ))
      		if ck2<>K2
      			skip
				loop
      		endif
    	endif

    	if !empty(cIdRoba)
      		if idtipdok = "0"  
				// ulaz
         		nSt += kolicina
         		nVr += Kolicina*Cijena
      		elseif idtipdok = "1"   
				// izlaz faktura
        		if !(serbr="*" .and. idtipdok=="10") 
					// za fakture na osnovu optpremince ne ra~unaj izlaz
           			nSt -= kolicina
           			nVr -= Kolicina*Cijena
        		endif
      		endif
    	endif  
    	skip
  	enddo
  
	if !EMPTY( cIdRoba )
    	NSRNPIdRoba( cIdRoba, cSintetika == "D" )
    	SELECT ROBA
   	 	if cTipVPC == "2" .and.  roba->( fieldpos("vpc2") <> 0 )
        	_cijena:=roba->vpc2
    	else
     		_cijena := if ( !EMPTY(cIdFirma) , fakt_mpc_iz_sifrarnika(), roba->vpc )
    	endif
    	SELECT POM
    	APPEND BLANK
    	REPLACE IdRoba WITH cIdRoba, FST WITH nSt, FVR WITH nSt*_cijena
    	SELECT FAKT
  	endif

enddo

//  zatim prodjem KALK (jer nesto moze biti samo u jednom)
SELECT KALK

if lFaktFakt
	GO TOP
  	While ! Eof()
    cIdRoba:=IdRoba
    nSt := nVr :=0
    While !eof() .and. cIdRoba==IdRoba
      	if idfirma<>cKalkFirma
      		skip
		loop
	endif
      // atributi!!!!!!!!!!!!!
      if !empty(cK1)
        if ck1<>K1; skip; loop; endif
      endif
      if !empty(cK2)
        if ck2<>K2; skip; loop; endif
      endif

      if !empty(cIdRoba)
        if idtipdok="0"  // ulaz
           nSt += kolicina
           ** nVr += Kolicina*Cijena
        elseif idtipdok="1"   // izlaz faktura
          if !(serbr="*" .and. idtipdok=="10") // za fakture na osnovu otpremnice ne racunaj izlaz
             nSt -= kolicina
             ** nVr -= Kolicina*Cijena
          endif
        endif
      endif  // empty(
      skip
    enddo
    if !empty(cIdRoba)
      SELECT POM
      HSEEK cIdRoba
      if ! Found()
        APPEND BLANK
        REPLACE IdRoba WITH cIdRoba
      endif
      REPLACE KST WITH nSt
      SELECT KALK
    endif
  enddo

else

	if !lViseKonta
   		//if ! RJ->(Found())
     		// veleprodajna cijena u FAKT, uzimam MKONTO u KALK
     		cTipC := "V"
     		Set order to tag "3"
   		//else
     		// u suprotnom, uzimam PKONTO
     	//	cTipC := "M"
     	//	SET ORDER TO TAG "4"
  	 	//endif
 	endif

  	GO TOP
  	if !lViseKonta
   		Seek (cKalkFirma+qqKonto)
  	endif
  	do while !EOF() .and. IF(lViseKonta, .t., KALK->(IdFirma+Iif (cTipC=="V",MKonto,PKonto))==cKalkFirma+qqKonto)
    	cIdRoba := KALK->IdRoba
    	nSt := 0
		nVr := 0
    	do while !EOF() .and. KALK->IdRoba==cIdRoba .and. IF(lViseKonta, .t., KALK->(IdFirma+Iif (cTipC=="V",MKonto,PKonto))==cKalkFirma+qqKonto)
      		if cTipC=="V"
        		// magacin
        		if mu_i=="1" .and. !(idvd $ "12#22#94")    // ulaz
          			nSt += kolicina-gkolicina-gkolicin2
          			nVr += vpc*(kolicina-gkolicina-gkolicin2)
        		elseif mu_i=="5"                           // izlaz
          			nSt -= kolicina
          			nVr -= vpc*(kolicina)
        		elseif mu_i=="1" .and. (idvd $ "12#22#94")    // povrat
          			nSt += kolicina
          			nVr += vpc*(kolicina)
        		elseif mu_i=="3"    // nivelacija
         			nVr += vpc*(kolicina)
        		endif
      		else  
				// cTipC=="M"
        		// prodavnica
        		if pu_i=="1"
          			nSt += kolicina-GKolicina-GKolicin2
          			nVr += round(mpcsapp*kolicina,ZAOKRUZENJE)
        		elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
          			nSt -= kolicina
          			nVr -= ROUND(mpcsapp*kolicina,ZAOKRUZENJE)
        		elseif pu_i=="I"
          			nSt += gkolicin2
          			nVr -= mpcsapp*gkolicin2
        		elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
          			nSt -= kolicina
          			nVr -= ROUND( mpcsapp*kolicina ,ZAOKRUZENJE)
        		elseif pu_i=="3"    // nivelacija
          			nVr += round( mpcsapp*kolicina ,ZAOKRUZENJE)
        		endif
      		endif // cTipC=="V"
   			SKIP
    	enddo
    
		SELECT POM
   		HSEEK cIdRoba
   		if ! Found()
    		Append Blank
      		REPLACE IdRoba WITH cIdRoba
    	endif
    	REPLACE KST WITH nSt, KVR WITH nVr
    	SELECT KALK
  	
	enddo

endif


// --------------------------------------------------
// pocetak ispisa
?
P_COND
?? space(gnLMarg); IspisFirme(cidfirma)
if lFaktFakt
  ? space(gnLMarg)
  ?? "FAKT: Uporedna lager lista u FAKT i FAKT druge firme na dan",date(),"   za period od",dDatOd,"-",dDatDo
else
  ? space(gnLMarg); ?? "FAKT: Usporedna lager lista u FAKT i KALK na dan",date(),"   za period od",dDatOd,"-",dDatDo
endif
if !empty(qqRoba)
  ?
  ? space(gnLMarg)
  ?? "Roba:",qqRoba
endif

if !empty(cK1) .and. !lFaktFakt
  ?
  ? space(gnlmarg), "- Roba sa osobinom K1:",ck1
endif
if !empty(cK2) .and. !lFaktFakt
  ?
  ? space(gnlmarg), "- Roba sa osobinom K2:",ck2
endif

?
if cTipVPC=="2" .and.  roba->(fieldpos("vpc2")<>0) .and. !lFaktFakt
  ? space(gnlmarg); ??"U IZVJESTAJU SU PRIKAZANE CIJENE: "+cTipVPC
endif
?
if lFaktFakt
  m:="----------------------------------------- --- ------------ ------------ ------------"

  ? space(gnLMarg); ?? m
  ? space(gnLMarg)
  ?? "                                         *   *"+Padc(ALLTRIM(cOpis1),12)+"*"+Padc(ALLTRIM(cOpis2),12)+"*  RAZLIKA"
  ? space(gnLMarg)
  ?? "Sifra i naziv artikla                    *JMJ*   STANJE   *   STANJE   *  KOLICINA  "
  ? space(gnLMarg); ?? m

  SELECT POM
  GO TOP
  do while !EOF()
    if (cRazlKol=="D" .and. ROUND (FST,4) <> ROUND (KST, 4)) .or. ;
       (cRazlVr=="D" .and. ROUND (FVR,4) <> ROUND (KVR, 4))
      SELECT ROBA
      HSEEK POM->IdRoba
      if !FOUND() .and. TRIM(cF2FS)!=TRIM(goModul:oDataBase:cDirSif)
        SELECT ROBA2
        HSEEK POM->IdRoba
        SELECT POM
        ? SPACE (gnLMarg)
        ?? ROBA2->Id, LEFT (ROBA2->Naz, 30), ROBA2->Jmj, ;
           STR (FST, 12, 3), STR (KST, 12, 3), STR (FST-KST, 12, 3)
      else
        SELECT POM
        ? SPACE (gnLMarg)
        ?? ROBA->Id, LEFT (ROBA->Naz, 30), ROBA->Jmj, ;
           STR (FST, 12, 3), STR (KST, 12, 3), STR (FST-KST, 12, 3)
      endif
    endif
    SKIP
  enddo
  ? space(gnLMarg); ?? m
else
  m:="----------------------------------------- --- ------------ ------------ ------------ ------------ ------------ ------------"

  ? space(gnLMarg); ?? m
  ? space(gnLMarg)
  ?? "                                         *   *      F   A   K   T      *      K   A   L   K      *      R A Z L I K A"
  ? space(gnLMarg)
  ?? "Sifra i naziv artikla                    *JMJ*   STANJE   * VRIJEDNOST *   STANJE   * VRIJEDNOST *  KOLICINA  * VRIJEDNOST"
  ? space(gnLMarg); ?? m

  SELECT POM
  GO TOP
  While !Eof()
    if (cRazlKol=="D" .and. ROUND (FST,4) <> ROUND (KST, 4)) .or. ;
       (cRazlVr=="D" .and. ROUND (FVR,4) <> ROUND (KVR, 4))
      SELECT ROBA
      HSEEK POM->IdRoba
      SELECT POM
      ? SPACE (gnLMarg)
      ?? ROBA->Id, LEFT (ROBA->Naz, 30), ROBA->Jmj, ;
         STR (FST, 12, 3), STR (FVR, 12, 2),;
         STR (KST, 12, 3), STR (KVR, 12, 2),;
         STR (FST-KST, 12, 3), STR (FVR-KVR, 12, 2)
    endif
    SKIP
  enddo
  ? space(gnLMarg); ?? m
endif

close all

FF
END PRINT

return


