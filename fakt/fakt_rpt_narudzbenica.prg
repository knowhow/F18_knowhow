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
  * \var *string FmkIni_ExePath_FAKT_NarudzbaSaCijenama
  * \brief Odredjuje da li ce se na narudzbenici prikazivati cijene
  * \param N - bez cijena, default vrijednost
  * \param D - prikazi i cijene
  */
*string FmkIni_ExePath_FAKT_NarudzbaSaCijenama;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_NARUDZBENICA_DobAdresa
  * \brief Odredjuje adresu dobavljaca
  * \param _ - default vrijednost
  */
*string FmkIni_KumPath_NARUDZBENICA_DobAdresa;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_NARUDZBENICA_DobTelefon
  * \brief Odredjuje telefon dobavljaca
  * \param _ - default vrijednost
  */
*string FmkIni_KumPath_NARUDZBENICA_DobTelefon;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_NARUDZBENICA_DobDomZR
  * \brief Odredjuje ziro racun dobavljaca
  * \param _ - default vrijednost
  */
*string FmkIni_KumPath_NARUDZBENICA_DobDomZR;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_NARUDZBENICA_DobRegBr
  * \brief Odredjuje registarski broj dobavljaca
  * \param _ - default vrijednost
  */
*string FmkIni_KumPath_NARUDZBENICA_DobRegBr;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_NARUDZBENICA_DobPorBr
  * \brief Odredjuje poreski broj dobavljaca
  * \param _ - default vrijednost
  */
*string FmkIni_KumPath_NARUDZBENICA_DobPorBr;



/*! \fn StNarKup()
 *  \brief Stampa narudzbenice 
 *  \todo Prebaciti u /RPT
 */
 
function StNarKup()
*{

//if Pitanje(,"Fmk.NET narudzba (D/N)?","D")=="D"
//	Mnu_Narudzbenica()
// return
//endif

if (IzFmkIni("FAKT","NarudzbaSaCijenama","N")=="D") .or. (Pitanje(,"Prikaz cijena ?", "N") == "D" )
	lCijene := .t.
else
	lCijene := .f.
endif

START PRINT RET
?
gp12cpi()
gRPL_Gusto()

if empty(gFNar)
	for i:=1 to gnTMarg
		QOUT()
	next
else

	cyAdresa:=IzFmkIni("NARUDZBENICA","DobAdresa" ,"_",KUMPATH)
    	cyTelefon:=IzFmkIni("NARUDZBENICA","DobTelefon","_",KUMPATH)
    	cyDomZR:=IzFmkIni("NARUDZBENICA","DobDomZR"  ,"_",KUMPATH)
    	cyRegBr:=IzFmkIni("NARUDZBENICA","DobRegBr"  ,"_",KUMPATH)
    	cyPorBr:=IzFmkIni("NARUDZBENICA","DobPorBr"  ,"_",KUMPATH)
    	cyBrSudRj:=IzFmkIni("NARUDZBENICA","DobBrSudRj","_",KUMPATH)
    	cyUstanova:=IzFmkIni("NARUDZBENICA","DobUstanova","_",KUMPATH)
    	cyBrUpisa:=IzFmkIni("NARUDZBENICA","DobBrUpisa","_",KUMPATH)
    	cyPNazOrg:=IzFmkIni("NARUDZBENICA","DobPNazOrg","_",KUMPATH)

	if !empty(idpartner)
      		select partn
		HSEEK fakt_pripr->idpartner
      		cxFirma   := naz
      		cxMjesto  := mjesto
      		cxAdresa  := adresa
      		cxTelefon := telefon
      		//cxDomZR   := IzborBanke( IzSifK( "PARTN" , "BANK" , id , .f. ) )
      		cxDomZR   := IspisBankeNar(IzSifK("PARTN","BANK",id,.f.))
      		cxRegBr   := IzSifK( "PARTN" , "REGB" , id , .f. )
      		cxPorBr   := IzSifK( "PARTN" , "PORB" , id , .f. )
      		cxBrSudRj := IzSifK( "PARTN" , "BRJS" , id , .f. )
      		cxBrUpisa := IzSifK( "PARTN" , "BRUP" , id , .f. )
      		cxUstanova := IzSifK( "PARTN" , "USTN" , id , .f. )
      		cxPNazOrg := IzSifK( "PARTN" , "PNZO" , id , .f. )
		select fakt_pripr
    	else
      		cTxt3a:=cTxt3b:=cTxt3c:=""
      		if val(podbr)=0  .and. val(rbr)==1
        		aMemo:=ParsMemo(txt)
        		if len(aMemo)>0
         			cTxt1:=padr(aMemo[1],40)
        		endif
        		if len(aMemo)>=5
          			cTxt2:=aMemo[2]
          			cTxt3a:=aMemo[3]
          			cTxt3b:=aMemo[4]
          			cTxt3c:=aMemo[5]
        		endif
      		endif
      		cxFirma  := cTxt3a
      		cxMjesto := cTxt3c
      		cxRegBr  := cxPorBr := cxAdresa := cxTelefon := cxDomZR := cxDevZR := ""
		cxBrSudRj := " - "
		cxBrUpisa := " - "
		cxUstanova := " - "
		cxPNazOrg := " - "
    	endif
    	dNarudzbe:=datdok
    	nLin:=BrLinFajla(PRIVPATH+TRIM(gFNar))
    	nPocetak:=0
	nPreskociRedova:=0
    	for i:=1 to nLin
      		aPom:=SljedLin(PRIVPATH+TRIM(gFNar),nPocetak)
      		nPocetak:=aPom[2]
      		cLin:=aPom[1]
      		if nPreskociRedova>0
        		--nPreskociRedova
        		loop
      		endif
      		if RIGHT(cLin,4)=="#NA#"
        		if lCijene
          			gpCOND()
        		endif
        		nLM:=LEN(cLin)-4
        		nBrSt:=0
        		nUkIznos:=0
        		nZaokr:=ZAOKRUZENJE
        		cDinDEM:=dindem
        		? "ÚÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄ"+IF(lCijene,"ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","")+"¿"
        		? "³R.BR.³               N A Z I V   R O B E                  ³  KOLICINA  ³J.MJ."+IF(lCijene,"³    CIJENA     ³     IZNOS      ","")+"³"
        		? "ÃÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄ"+IF(lCijene,"ÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","")+"´"
        		do while !eof()
				NSRNPIdRoba()
          			if alltrim(podbr)=="."
            				aMemo:=ParsMemo(txt)
            				cTxt1:=padr(aMemo[1],52)
          			else
            				aMemo:=ParsMemo(txt)
            				if roba->tip="U"
              					aTxtR:=SjeciStr(aMemo[1],iif(gVarF=="1".and.!idtipdok$"11#15#27",51,40))   // duzina naziva + serijski broj
            				else
              					cK1:=cK2:=""
              					if fakt_pripr->(fieldpos("k1"))<>0
							ck1:=k1
							ck2:=k2
						endif
              					aTxtR:=SjeciStr(trim(roba->naz)+iif(!empty(ck1+ck2)," "+ck1+" "+ck2,"")+Katbr(),40)
            				endif
            				cTxt1:=padr(aTxtR[1],52)
          			endif
          			++nBrSt
          			? "³"+STR(nBrSt,4)+".³"+cTxt1+"³"+PADL(TRANSFORM(kolicina,PicKol),12)+"³"+PADC(ALLTRIM(ROBA->jmj),5)
          			IF lCijene
            				?? "³"+PADL(TRANSFORM(cijena,PicDEM),15)
            				?? "³"+PADL(TRANSFORM(kolicina*cijena*Koef(cDinDem),PicDEM),16)
            				nUkIznos += round(kolicina*cijena*Koef(cDinDem),nzaokr)
          			ENDIF
          			?? "³"
          			SKIP 1
        		ENDDO
        		IF lCijene
          			nUkIznos := round(nUkIznos, nZaokr)
          			? "ÃÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´"
          			? "³ U K U P N O ................................................................................³"+PADL(TRANSFORM(nUkIznos,PicDEM),16)+"³"
          			? "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"
          			gp12cpi()
        		ELSE
          			? "ÀÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÙ"
        		ENDIF
      		ELSE
        		?
        		DO WHILE .t.
          			nPom:=AT("#",cLin)
          			IF nPom>0
            				cPom:=SUBSTR(cLin,nPom,4)
            				aPom:=UzmiVar( SUBSTR(cPom,2,2) )
					?? LEFT(cLin,nPom-1)
            				IF SUBSTR(cPom,2,1)=="Y"
						nPom7:=LEN(&(aPom[2]))
						if (nPom7==0)
							cLin:=SUBSTR(cLin,nPom+4)
						else
							cLin:=SUBSTR(cLin,nPom+nPom7)
						endif
					ELSE
              					cLin:=SUBSTR(cLin,nPom+4)
            				ENDIF
					lSjeciStr:=.f.
					if cPom=="#Y5#"
						lSjeciStr:=.t.
					endif
						
            				IF !EMPTY(aPom[1]) 
              					if !lSjeciStr
							PrnKod_ON(aPom[1])
						endif
            				ENDIF
            				IF aPom[1]=="K"
              					cPom:=&(aPom[2])
            				ELSE
              					cPom:=&(aPom[2])
              					
						if !lSjeciStr
							?? cPom
            					else
							aRez:=SjeciStr(cPom, 80)
							?? aRez[1]
							for i:=2 to LEN(aRez)
								? aRez[i] 
							next	
						endif
					ENDIF
					IF !EMPTY(aPom[1])
              					if !lSjeciStr
							PrnKod_OFF(aPom[1])
        					endif
	    				ENDIF
          			ELSE
            				?? cLin
            				EXIT
          			ENDIF
        		ENDDO
      		ENDIF
    	NEXT
endif


FF

gRPL_Normal()

END PRINT
return
*}


/*! \fn UzmiVar(cVar)
 *  \brief Uzima varijable 
 *  \param cVar
 *  \return cVrati
 */

static function UzmiVar(cVar)
*{
local cVrati:=""
local cFS:="UIB"
IF gPrinter=="R"
	cFS:="UI"
ENDIF
DO CASE
   CASE cVar=="Y1"
       cVrati := { cFS, "PADC(ALLTRIM(cxFirma),31)" }
   CASE cVar=="Y2"
       cVrati := { cFS, "PADC(ALLTRIM(cxMjesto),29)" }
   CASE cVar=="Y3"
       cVrati := { cFS, "PADC(ALLTRIM(cxAdresa),24)" }
   CASE cVar=="Y4"
       cVrati := { cFS, "PADC(ALLTRIM(cxTelefon),27)" }
   CASE cVar=="Y5"
	cVrati := { cFS, "ALLTRIM(cxDomZR)" }
   CASE cVar=="Y6"
       cVrati := { cFS, "PADC(ALLTRIM(cxDevZR),22)" }
   CASE cVar=="Y7"
       cVrati := { cFS, "PADC(ALLTRIM(gnFirma),31)" }
   CASE cVar=="Y8"
       cVrati := { cFS, "PADC(ALLTRIM(gMjStr),29)" }
   CASE cVar=="Y9"
       cVrati := { cFS, "PADC(ALLTRIM(cxRegBr),20)" }
   CASE cVar=="YA"
       cVrati := { cFS, "PADC(ALLTRIM(cxPorBr),20)" }
   CASE cVar=="YB"
       cVrati := { cFS, "PADC(ALLTRIM(cyAdresa),24)" }
   CASE cVar=="YC"
       cVrati := { cFS, "PADC(ALLTRIM(cyTelefon),27)" }
   CASE cVar=="YD"
       cVrati := { cFS, "PADC(ALLTRIM(cyDomZR),25)" }
   CASE cVar=="YE"
       cVrati := { cFS, "PADC(ALLTRIM(cyRegBr),20)" }
   CASE cVar=="YF"
       cVrati := { cFS, "PADC(ALLTRIM(cyPorBr),20)" }
   CASE cVar=="YG"
       cVrati := { cFS, "PADC(ALLTRIM(cxBrSudRj),20)" }
   CASE cVar=="YH"
       cVrati := { cFS, "PADC(ALLTRIM(cyBrSudRj),20)" }
   CASE cVar=="YI"
       cVrati := { cFS, "PADC(ALLTRIM(cxUstanova),20)" }
   CASE cVar=="YJ"
       cVrati := { cFS, "PADC(ALLTRIM(cyUstanova),20)" }
   CASE cVar=="YK"
       cVrati := { cFS, "PADC(ALLTRIM(cxBrUpisa),20)" }
   CASE cVar=="YL"
       cVrati := { cFS, "PADC(ALLTRIM(cyBrUpisa),20)" }
   CASE cVar=="YM"
       cVrati := { cFS, "PADC(ALLTRIM(cyPNazOrg),20)" }
   CASE cVar=="YN"
       cVrati := { cFS, "PADC(ALLTRIM(cxPNazOrg),20)" }
   CASE cVar=="01"
       cVrati := { "", "SrediDat(dNarudzbe)" }
   CASE cVar=="B1"
       cVrati := { "K", "gPB_ON()" }
   CASE cVar=="B0"
       cVrati := { "K", "gPB_OFF()" }
   CASE cVar=="U1"
       cVrati := { "K", "gPU_ON()" }
   CASE cVar=="U0"
       cVrati := { "K", "gPU_OFF()" }
   CASE cVar=="I1"
       cVrati := { "K", "gPI_ON()" }
   CASE cVar=="I0"
       cVrati := { "K", "gPI_OFF()" }
 ENDCASE
return cVrati
*}



