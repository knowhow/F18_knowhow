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

#include "f18.ch"

static cPrinter := "D" 
static nZagrada:=0 
static cKom:="" 
static nSekundi:=0 
static cTekprinter := "" 
static cFName


function SetgaSDBFs()

PUBLIC gaSDBFs := { ;
 {F_GPARAMS  , "GPARAMS",  P_ROOTPATH },; 
 {F_GPARAMSP , "GPARAMS",  P_PRIVPATH},;
 {F_PARAMS   , "PARAMS"  , P_PRIVPATH},;
 {F_KORISN   , "KORISN"  , P_TEKPATH },;
 {F_MPARAMS  , "MPARAMS" , P_TEKPATH },;
 {F_KPARAMS  , "KPARAMS" , P_KUMPATH },;
 {F_SECUR    , "SECUR"   , P_KUMPATH },;
 {F_ADRES    , "ADRES"   , P_SIFPATH },;
 {F_SIFK     , "SIFK"    , P_SIFPATH },;
 {F_SIFV     , "SIFV"    , P_SIFPATH  },;
 {F_TMP      , "TMP"     , P_PRIVPATH},;
 {F_SQLPAR   , "SQLPAR"  , P_KUMSQLPATH};
}

return



/*! \fn PreuzSezSPK(cSif)
 *  \brief Preuzimanje sifre iz sezone
 *  \param cSif
 */
 
function PreuzSezSPK(cSif)
static cSezNS:="1998"
 LOCAL nObl:=SELECT()
 Box(,3,70)
  cSezNS:=PADR(cSezNS,4)
  @ m_x+1,m_y+2 SAY "Sezona:" GET cSezNS PICT "9999"
  READ
  cSezNS:=ALLTRIM(cSezNS)
 BoxC()
 IF cSif=="P"
   USE (TRIM(cDirSif)+"\"+cSezNS+"\PARTN") ALIAS PARTN2 NEW
   SELECT PARTN2
   SET ORDER TO TAG "ID"
   GO TOP
   HSEEK PSUBAN->idpartner
   IF FOUND()
     SELECT PARTN
     APPEND BLANK
     REPLACE id WITH PARTN2->id,;
            naz WITH PARTN2->naz,;
         mjesto WITH PARTN2->mjesto
   ELSE
     SELECT PARTN
     APPEND BLANK
     REPLACE id WITH PSUBAN->idpartner
   ENDIF
   SELECT PARTN2; USE
 ELSE
   USE (TRIM(cDirSif)+"\"+cSezNS+"\KONTO") ALIAS KONTO2 NEW
   SELECT KONTO2
   SET ORDER TO TAG "ID"
   GO TOP
   HSEEK PSUBAN->idkonto
   IF FOUND()
     SELECT KONTO
     APPEND BLANK
     REPLACE id WITH KONTO2->id, naz WITH KONTO2->naz
   ELSE
     SELECT KONTO
     APPEND BLANK
     REPLACE id WITH PSUBAN->idkonto
   ENDIF
   SELECT KONTO2; USE
 ENDIF
 SELECT (nObl)
RETURN


// -------------------------------------------------------------------
// StartPrint(lUlFajl, cF)
// Pocetna procedura za stampu u OUTF.TXT
//  * lUFajl - True -> cDirekt="V", False - tekuca postavka varijanta 
//  * cF - ime izlaznog fajla, tekuca vrijednost OUTF.TXT
//  * FmkIni/ExePath/Printeri_DirektnoOUTFTXT
// --------------------------------------------------------------
function StartPrint(lUFajl, cF, cDocumentName)
local cDirekt
local cLpt
local cDDir
local cOutfTXT

if lUFajl==nil
	lUFajl:=.f.
endif

cFName := OUTF_FILE

if cF<>nil
	cFName:=cF
endif

if (cDocumentName == nil)
  cDocumentName :=  gModul + '_' + DTOC(DATE()) 
endif

private GetList:={}

setprc(0,0)

cDirekt:=gcDirekt
cLpt:="1"
nZagrada:=0

cTekPrinter:=gPrinter

cOutfTXT:=IzFMKIni('Printeri', 'DirektnoOUTFTXT','N')

if !(lUFajl)

	cDirekt:=print_dialog_box(cDirekt)
	cKom:="LPT"+gPPort

	if cDirekt = "R"
		gPrinter := "R"
	endif

	if gPrinter = "G"
		cDirekt := "G"
	endif
	
	if cDirekt = "G"
		gPrinter := "G"
	endif
	
	if gPrinter=="R"
		PtxtSekvence()
	endif

    // transformisi cKom varijablu za portove > 4
    GPPortTransform(@cKom)

	set confirm on

else
	cDirekt := "V"
endif

cPrinter := cDirekt

if cDirekt=="D" .and. gPrinter <> "R" .and. gPrinter <> "G" .and. cOutfTxt <> "D"
	do while .t.
		if InRange(VAL(gPPort),5,7)  .or. ;
		   (val(gPPort)=8 ) .or. ;
		   (val(gPPort)=9 ) .or. ;
		   (val(gPPort)<4 .and. printready(val(gPPort)) )

		  // 8 - copy lpt1
		  exit           

		else
			Beep(2)
			MsgO("Printer nije ukljucen - ON LINE !")
			nBroji2:=seconds()
			DO WHILE NEXTKEY()==0
				CekaHandler(@nBroji2)
			ENDDO
			INKEY()
			MsgC()
			if lastkey()==K_ESC
				return .f.
			endif
		endif
	enddo

	set console off
else
	if !gAppSrv
		MsgO("Priprema izvjestaja...")
	endif
	set console off
	
    cKom := PRIVPATH + cFName

	if gnDebug>=5
		MsgBeep("Direktno N, cKom=" + AllTrim(cKom))
	endif

endif


set printer off
set device to printer

cDDir:=SET(_SET_DEFAULT)
set default to

if cKom="LPT1" .and. gPPort<>"8"
	set printer to

elseif ckom=="LPT2" .and. gPPort<>"9"
	Set( 24, "lpt2", .F. )
else
        // radi se o fajlu
	if DRVPATH $ cKom  
		bErr:=ERRORBLOCK({|o| MyErrH(o)})
		begin sequence
		set printer to (ckom)
		recover
		bErr:=ERRORBLOCK(bErr)
		cKom:= ToUnix("C" + DRVPATH + "sigma" + SLASH + cFName) 
		if gnDebug>=5
			MsgBeep("Radi se o fajlu !##set printer to (cKom)##var cKom=" + AllTrim(cKom))
		endif
		
		set printer to (cKom)
		END SEQUENCE
		bErr:=ERRORBLOCK(bErr)
	else
		if gnDebug>=5
			MsgBeep("set printer to (cKom)##var cKom=" + AllTrim(cKom))
		endif
		set printer to (ckom)
	endif 

endif

set printer on

nSekundi:=seconds()

SET(_SET_DEFAULT,cDDir)
GpIni(cDocumentName)

return .t.

// --------------------------------------
// za portove > 4 izvrsi transformaciju
//  cKom
// -------------------------------------
static function GPPortTransform(cKom)

if gPPort>"4"
	if gpport=="5"
		cKom:="LPT1"
	elseif gPPort=="6"
		cKom:="LPT2"
	elseif gPPort=="7"
		cKom:="LPT3"
	elseif gPPort $ "89"
			cKom:=PRIVPATH+cFName
			if gnDebug>=5
				MsgBeep("Inicijalizacija var cKom##var cKom=" + AllTrim(cKom))
			endif
	endif
endif

return




// ----------------------------------------
// ----------------------------------------
function EndPrint()
local cS
local i
local nSek2
local cOutfTxt
local _f_path
PRIVATE cPom

#ifdef __PLATFORM__UNIX
// TODO: #27234
//       my_close_all_dbf()
#endif


SET DEVICE TO SCREEN
set printer off
set printer to
set console on

// u test rezimu se ne pokrece editor
#ifdef TEST
  return
#endif

//cOutfTxt:= IzFMKIni('Printeri','DirektnoOUTFTXT','N')
cOutfTxt := ""

nSek2:=seconds()

Tone(440,2)
Tone(440,2)

* ako nije direktno na printer
if cPrinter<>"D" .or. (gPPort $ "89" .and. cPrinter=="D") .or. gPrinter=="R" .or. gPrinter=="G" .or. (cOutftxt=="D" .and. cPrinter=="D")  

if gAppSrv
    return
endif

if cPrinter <> "D" .or. gPrinter == "R" .or. gPrinter == "G" .or. (cOutftxt=="D" .and. cPrinter=="D")
 MsgC()
endif

save screen to cS

if cOutfTXT=="D" .and. cPrinter="D"
	// direktno na printer, ali preko outf.txt
	cKom:=ckom+" LPT"+gPPort
	cPom:=cKom
	!copy &cPom

elseif gPPort $ "89" .and. cPrinter="D"
	cKom:=ckom+" LPT"
	if gPPort=="8"
	cKom+="1"
	else
	cKom+="2"
	endif
	cPom:=cKom
	!copy &cPom
	if gnDebug>=5
		MsgBeep("LPT port 8 ili 9##!copy " + AllTrim(cKom))
	endif
elseif cPrinter=="N"
	cPom:=cKom
	!ll &cPom

elseif cPrinter=="E"
	cPom:=cKom
	!q &cPom

elseif cPrinter=="V"
	
	IF "U" $ TYPE("gaZagFix")
		gaZagFix:=NIL
	ENDIF
	IF "U" $ TYPE("gaKolFix")
		gaKolFix:=NIL
	ENDIF
	
	//VidiFajl(cKom, gaZagFix, gaKolFix)

    /* TODO treba li f18_editor parametrizirati ?! */   
    
    _f_path := "f18_editor " + my_home() + cFName 

        f18_run(_f_path)
	
	gaZagFix:=NIL
	gaKolFix:=NIL

elseif cPrinter=="G"
	// gvim stampa...
	cKom := PRIVPATH + cFName
	gvim_cmd(cKom)
else
	// R - Windowsi
	Beep(1)
    cKom:=PRIVPATH+cFName

	if gPrinter == "R"
		if gPDFprint == "X" .and. goModul:oDataBase:cName == "FAKT" 
			if Pitanje(,"Print u PDF/PTXT (D/N)?", "D") == "D" 
				PDFView(cKom)
			else
				Ptxt(cKom)
			endif
		elseif gPDFprint == "D" .and. ;
			goModul:oDataBase:cName == "FAKT" 
			PDFView(cKom)
		else
			Ptxt(cKom)
		endif
	endif
	
endif
restore screen from cS

// cPrinter
endif 

// nemoj "brze izvjestaje"
if nSek2-nSekundi>10  
	@ 23,75 SAY nSek2-nSekundi pict "9999"
endif

if gPrinter<>cTekPrinter
	gPrinter:=cTekPrinter
	PushWa()
	O_GPARAMS
	private cSection:="P" 
	private cHistory:=gPrinter
	private aHistory:={}
	RPar_Printer()
	select gparams
	use
	PopWa()
endif

return

function SPrint2(cKom)

// cKom je oznaka porta, npr. "3"

 local cddir, nNPort

if gPrinter="R"
  StartPrint()
  return
endif

setprc(0, 0)
nZagrada := 0
cKom := UPPER(cKom)
nNPort := VAL(substr(cKom,4))

do while .t.

     if (SLASH $  cKom) .or. InRange(nNPort,5,7)  .or. ;
        (nNPort=8 ) .or.  ;
        (nNPort=9 ) .or.  ;
        (nNPort<4 .and. printready(val(gPPort)) )
          exit
     else
        Beep(2)
        MsgO("Printer nije ukljucen ili je blokiran! PROVJERITE GA!")
        INKEY()
        MsgC()
        if lastkey()==K_ESC
		return .f.
	endif
     endif
   enddo

  if nNPort>4
    if nNport==5
      cKom:="LPT1"
    elseif nNport==6
      ckom:="LPT2"
    elseif nNport==7
      cKom:="LPT3"
    elseif nNPort>7
        cKom:=PRIVPATH+cFName
        if gnDebug>=5
	    	MsgBeep("SPrint2() var cKom=" + AllTrim(cKom))
	    endif
    endif
  endif

  set console off
  set printer off
  set device to printer
  cDDir:=SET(_SET_DEFAULT)
  set default to
  if cKom=="LPT1"
    if gnDebug>=5
    	MsgBeep("set printer to")
    endif
    set printer to
  elseif cKom=="LPT2"
    Set( 24, "lpt2", .f. )
  else
    if gnDebug>=5
    	MsgBeep("set printer to (cKom) " + AllTrim(cKom))
    endif
    set printer to (cKom)
  endif
  if gnDebug>=5
  	MsgBeep("SPrint2(), set printer to (cKom)##var cKom=" + AllTrim(cKom) + "##var cDDir=" + AllTrim(cDDir))
  endif
  set printer on
  SET(_SET_DEFAULT,cDDir)
  INI
return .t.


function EPrint2(xPos)

private cPom

if gPrinter=="R"
  EndPrint()
  return
endif

RESET
set printer to
set printer off
set console on
SET DEVICE TO SCREEN
set printer to

  if gPPort $ "89"
    cKom:=PRIVPATH+cFName
    if gnDebug>=5
      	MsgBeep("EPrint2(), var cKom=" + AllTrim(cKom))
    endif
    if gPPort $ "89"
       save screen to cS
       cKom:=cKom+" LPT"
       if gPPort=="8"
         cKom+="1"
       else
         cKom+="2"
       endif
       cPom:=cKom
       if gnDebug>=5
       	MsgBeep("before !copy cPom##var cKom=" + AllTrim(cKom) + "##var cPom=" + AllTrim(cPom))
        MsgBeep("Pocni stampu")
       endif
       
       !copy &cPom
       
       if gnDebug>=5
       	MsgBeep("Zavrsio stampu! Vracam screen!")
       endif
       
       restore screen from cS
    
    endif
  endif
  
  // LPT1, LPT2 ...
  if gOpSist $ "W2000WXP"
  	save screen to cS
  	cPom:=EXEPATH+"dummy.txt"
  	!copy &cPom
  	restore screen from cS
  endif

  if gnDebug>=5
	cPom:=EXEPATH+"dummy.txt"
	MsgBeep(Alltrim(cPom))
	!copy &cPom
  endif
   
  Tone(440,2)
  Tone(440,2)
  Msg( "Stampanje zavrseno. Pritisnite bilo koju tipku za nastavak rada!", ;
       15, xPos )
return


// ------------------------------------------
// PPrint()
// Podesenja parametara stampaca
// ------------------------------------------
function PPrint()
local fused:=.f.
local ch
local cSekvence:="N"

PushWa()

set cursor on
IF gPicSif=="8"
  SETKEY(K_CTRL_F2,NIL)
ELSE
  SETKEY(K_SH_F2,NIL)
ENDIF
SETKEY( K_ALT_R , {|| UzmiPPr() , AEVAL(GetList,{|o| o:display()}) } )
private GetList:={}

O_GPARAMS
select 99
if used()
  fUsed:=.t.
else
  O_PARAMS
endif

private cSection:="1",cHistory:=" "; aHistory:={}
RPAR("px",@gPrinter)

Box(,3,65)
 set cursor on
 @ m_x+24,m_y+2  SAY "<a-R> - preuzmi parametre"
 @ m_x+1,m_y+2  SAY "TEKUCI STAMPAC:"
 @ m_x+1,col()+4  GET  gPrinter pict "@!"
 @ m_x+3,m_y+2 SAY "Pregled sekvenci ?"
 @ m_x+3,col()+2 GET cSekvence valid csekvence $ "DN" pict "@!"
 read
Boxc()

if empty(gPPort)
    gPPort:="1"
endif


Box(,23,65)

 if gPrinter=="*"
   select gparams // parametri stampaca
   cSection:="P"
   seek cSection
   do while !eof() .and. cSection==sec
     cH:=h
     do while !eof() .and. cSection==sec .and. ch==h
       skip
     enddo
     AADD(aHistory,{ch})
   enddo
   if len(aHistory)>0
    gPrinter:=(ABrowse(aHistory,10,1,{|ch|  HistUser(ch)}))[1]
   else
    gPrinter:=" "
  endif
  select params
  cSection:="1"
 endif
 WPar("px", gPrinter)

 select gparams

 private cSection:="P"
 private cHistory:=gPrinter
 private aHistory:={}
 Rpar_Printer()
 All_GetPstr()

 set key K_CTRL_P TO  PSeqv()
 @ m_x+3,m_y+2  SAY "INI          " GET gPINI    pict "@S40"
 @ m_x+4,m_y+2  SAY "Kond. -17cpi " GET gPCOND   pict "@S40"
 @ m_x+5,m_y+2  SAY "Kond2.-20cpi " GET gPCond2  pict "@S40"
 @ m_x+6,m_y+2  SAY "CPI 10       " GET gP10cpi pict "@S40"
 @ m_x+7,m_y+2  SAY "CPI 12       " GET gP12CPI pict "@S40"
 @ m_x+8,m_y+2  SAY "Bold on      " GET gPB_ON   pict "@S40"
 @ m_x+9,m_y+2  SAY "Bold off     " GET gPB_OFF  pict "@S40"
 @ m_x+10,m_y+2 SAY "Podvuceno on " GET gPU_ON   pict "@S40"
 @ m_x+11,m_y+2 SAY "Podvuceno off" GET gPU_OFF  pict "@S40"
 @ m_x+12,m_y+2 SAY "Italic on    " GET gPI_ON    pict "@S40"
 @ m_x+13,m_y+2 SAY "Italic off   " GET gPI_OFF   pict "@S40"
 @ m_x+14,m_y+2 SAY "Nova strana  " GET gPFF     pict "@S40"
 @ m_x+15,m_y+2 SAY "Portret      " GET gPO_Port     pict "@S40"
 @ m_x+16,m_y+2 SAY "Lendskejp    " GET gPO_Land     pict "@S40"
 @ m_x+17,m_y+2 SAY "Red.po l./nor" GET gRPL_Normal  pict "@S40"
 @ m_x+18,m_y+2 SAY "Red.po l./gus" GET gRPL_Gusto   pict "@S40"
 @ m_x+19,m_y+2 SAY "Reset (kraj) " GET gPRESET  pict "@S40"
 @ m_x+21,m_y+2 SAY "Dodatnih redova +/- u odnosu na A4 format " GET gPStranica pict "999"
 @ m_x+23,m_y+2 SAY "LPT 1/2/3    " GET gPPort   valid gPPort $ "12356789"
 gPPTK:=padr(gPPTK,2)
 @ m_x+23,col()+2 SAY "Konverzija" GET gPPTK pict "@!" valid subst(gPPTK,2,1)$ " 1"
 if csekvence=="D"
   read
 endif
 set key K_CTRL_P TO
BoxC()


WPAR("01",Odsj(@gPINI))
WPAR("02",Odsj(@gPCOND))
WPAR("03",Odsj(@gPCOND2))
WPAR("04",Odsj(@gP10cpi))
WPAR("05",Odsj(@gP12cpi))
WPAR("06",Odsj(@gPB_ON))
WPAR("07",Odsj(@gPB_OFF))
WPAR("08",Odsj(@gPI_ON))
WPAR("09",Odsj(@gPI_OFF))
WPAR("10",Odsj(@gPRESET))
WPAR("11",Odsj(@gPFF))
WPAR("12",Odsj(@gPU_ON))
WPAR("13",Odsj(@gPU_OFF))

WPAR("14",Odsj(@gPO_Port))
WPAR("15",Odsj(@gPO_Land))
WPAR("16",Odsj(@gRPL_Normal))
WPAR("17",Odsj(@gRPL_Gusto))

if empty(gPPort)
    gPPort:="1"
endif
WPar("PP",gPPort)

WPar("r-",gPStranica)
Wpar("pt",gPPTK)

// upisi u glavne parametre sql/db
set_metric( "print_dodatni_redovi_po_stranici", nil, gPStranica )

select gparams
use

select params
if !fUsed
 select params
 use
endif

IF gPicSif=="8"
  SETKEY(K_CTRL_F2,{|| PPrint()})
ELSE
  SETKEY(K_SH_F2,{|| PPrint()})
ENDIF
SETKEY(K_ALT_R,NIL)
PopWa()

IF !EMPTY(gPPTK)
  SetGParams("1", " ", "pt", "gPTKonv", gPPTK)
ENDIF
return

// ----------------------------------------------
// ----------------------------------------------
static function UzmiPPr(cProc,nline,cVar)
LOCAL cOzn:=" ", GetList:={}
Box(,1,77)
 @ m_x+1,m_y+2 SAY "Ukucajte oznaku stampaca cije parametre zelite preuzeti:" GET cOzn
 READ
 IF LASTKEY()!=K_ESC
   select gparams
   private cSection:="P",cHistory:=cOzn; aHistory:={}
   RPar_Printer()
   All_GetPstr()
 ENDIF
BoxC()
RETURN

// --------------------------------------------
// --------------------------------------------
static function PSeqv(cProc, nLine, cVar)
Box(,1,70)

@ m_x+1,m_y+2 SAY Odsj(&cVar)

INKEY()

BoxC()

return

// ----------------------------------
// ----------------------------------
function GetPStr(cStr, nDuzina)
local i
local cPom:=""
local cNum
local fSl

if nDuzina==NIL
  nDuzina:=60
endif

fSL:=.f.

for i:=1 to len(cStr)
	
	cNum:=substr(cStr,i,1)
  
	// slova
	if asc(cNum)>=33 .and. asc(cNum)<=126        
		if fSl  // proslo je bilo slovo
			cPom:=left(cPom,len(cPom)-1)+cNum+SLASH
		else
			cPom+="'"+cNum+SLASH
		endif
		fSl:=.t.
	else
		cPom+= alltrim(str( asc(cNum),3))+SLASH
		fSl:=.f.
	endif

next

return padr(cPom, nDuzina)

// ----------------------------------------------
// * nZnak  - broj znakova u redu
// * cPapir - "4" za A4, ostalo za A3
// -----------------------------------------------
function GuSt(nZnak, cPapir)
if cPapir=="POS"
	RETURN gP12cpi
ENDIF

nZnak=IF(cPapir=="4",nZnak*2-1,nZnak)
return IIF(nZnak<161, gP10cpi, IIF(nZnak<193, gP12cpi, IIF(nZnak<275,gPCOND,gPCond2)))

/*
* nZnak  - broj znakova u redu
* cPapir - "4" za A4, ostalo za A3
*/

function GuSt2(nZnak,cPapir)


if cPapir=="POS"
	return gP12cpi()
endif

if cPapir=="4"
  nZnak:=nZnak*2-1
else
	if  cPapir=="L4"
		nZnak:=nZnak*1.4545-1
	endif
endif

if nZnak<161
   return gP10cpi()
else
	if nZnak<193
		return gP12cpi()
	else
		if nZnak<275
			gPCOND()
		else
			gPCond2()
		endif
	endif
endif


// -----------------------------------
// -----------------------------------
function Odsj(cStr)
local nPos,cPom,cnum
cPom:=""
do while .t.
 nPos:=at(SLASH,cStr)
if nPos==0
 	exit
endif
 cNum:=left(cStr,nPos-1)
 
 if left(cNum,1)="'"    
  /* 
    oblik '(s<ESC>    => (s
  */
  cPom+=substr(cNum,2)
 else
  /*
   oblik 027<ESC>    => Chr(27)
  */
  cPom+=chr(val(cNum))
 endif
 
 cStr:=substr(cStr,nPos+1)
enddo
cStr:=cPom
return cPom




/*! \fn OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
 */
function OKumul(nArea, cStaza, cIme, nIndexa, cDefault)

select (nArea)
 
my_use (cIme)
return NIL


function Gather(cZn)

local i, aStruct
local _field_b
local _ime_p
local cVar

if cZn==nil
  cZn:="_"
endif
aStruct:=DBSTRUCT()
 
for i:=1 to len(aStruct)
     _field_b := FIELDBLOCK(_ime_p := aStruct[i,1])

     // cImeP - privatna var
     cVar := cZn + _ime_p

     //rlock()
     //IF "U" $ TYPE(cVar)
     //    MsgBeep2("Neuskladj.strukt.baza! F-ja: GATHER(), Alias: " + ALIAS() + ", Polje: " + _ime_p)
     //ELSE
            EVAL(_field_b, EVAL(MEMVARBLOCK(cVar)) )
     //ENDIF
 
     //dbunlock()
next

return nil


