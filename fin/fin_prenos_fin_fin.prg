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

#include "fin.ch"


/*! \fn FinDisk()
 *  \brief Menij prenosa fin<->fin (diskete, modem)
 */
 
function FinDisk()
private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc,"1. prenos dokumenata   =>        ")
AADD(opcexe,{|| PrDisk()})
AADD(opc,"2. prijem dokumenata   <= ")
AADD(opcexe,{|| PovDisk()})
AADD(opc,"3. podesavanje prenosa i prijema")
AADD(opcexe,{|| PPPDisk()})
Menu_SC("pfin")
return .f.


/*! \fn PrDisk()
 *  \brief Prenos dokumenata 
 */
 
function PrDisk()
local nRec
PRIVATE cLokPren    := "A:\"
PRIVATE cFZaPredaju := "AFIN"
PRIVATE cFZaPrijem  := "AFIN"
PRIVATE cUslovVDok  := "1;"
PRIVATE cSpecUslov  := ""
PRIVATE cKonvFirma  := ""
PRIVATE cKonvBrDok  := ""

PPPDisk(.t.)

if pitanje(,"Zelite li izvrsiti prenos fin.naloga subanalitike na diskete ?","N")=="N"
  closeret
endif

if Pitanje(,"Nulirati datoteke prenosa prije nastavka ?","D")=="D"
  O_PRIPR
  copy structure extended to (PRIVPATH+"struct")
  use
  create (PRIVPATH+"PSUBAN") from (PRIVPATH+"struct")

  O_KONTO
  copy structure extended to (PRIVPATH+"struct")
  use
  create (PRIVPATH+"_konto") from (PRIVPATH+"struct")

  O_PARTN
  copy structure extended to (PRIVPATH+"struct")
  use
  create (PRIVPATH+"_partn") from (PRIVPATH+"struct")

  O_SIFK
  copy structure extended to (PRIVPATH+"struct")
  use
  create (PRIVPATH+"_SIFK") from (PRIVPATH+"struct")

  O_SIFV
  copy structure extended to (PRIVPATH+"struct")

  use
  create (PRIVPATH+"_SIFV") from (PRIVPATH+"struct")


  close all

  O_PSUBAN  
  // otvara se bez indeksa
  O__KONTO
  O__PARTN

  select PSUBAN; zap
  select _konto; zap
  select _partn; zap

  close all
endif

fSifk:=.t.

O_PSUBAN
O_SUBAN
O_NALOG
select nalog
set order to tag "1" // idFirma+IdVN+BrNal

select suban
set order to tag "4"  // idFirma+IdVN+BrNal+RBr
set relation to idfirma+idvn+brnal into nalog
// -----------
// koristim nalog->datNal tj. datum azuriranja za obuhvatanje naloga po datumu jer nema puno koristi od gledanja datuma stavke (suban->datDok), MS 04.04.2003
// -----------

cidfirma:=gfirma
cIdVN:=space(2)
cBrNal:=space(8)

private qqBrNal:=space(80)
private qqIdVN:=PADR(cUslovVDok,80)
private qqSpecUslov:=PADR(cSpecUslov,80)
private dDatOd:=CTOD("")
private dDatDo:=DATE()

if !empty(cidVN)
 qqIdVN:=padr(cidVN+";",80)
endif

Box(,4,70)
 DO WHILE .T.
  @ m_x+1,  m_y+2  SAY  "Vrste naloga        "  GEt qqIdVN pict "@S40"
  @ m_x+2,  m_y+2  SAY  "Brojevi dok./naloga "  GEt qqBrNal pict "@S40"
  @ m_x+3,  m_y+2  SAY  "Spec.dodatni uslov  "  GEt qqSpecUslov pict "@S40"
  @ m_x+4,  m_y+2  SAY  "Obuvaceni period od:" GET dDatOd
  @ m_x+4,col()+2  SAY  "do:" GET dDatDo
  READ
  PRIVATE aUsl1:=Parsiraj(qqBrNal,"BrNal","C")
  PRIVATE aUsl3:=Parsiraj(qqIdVN,"IdVN","C")
  IF aUsl1<>NIL .and. ausl3<>NIL
    EXIT
  ENDIF
 ENDDO
Boxc()

qqSpecUslov:=TRIM(qqSpecUslov)

if Pitanje(,"Prenijeti u datoteku prenosa suban.naloge sa ovim kriterijem ?","N")=="D"
  select SUBAN
  if !flock(); Msg("SUBAN je zauzeta ",3); closeret; endif

  PRIVATE cFilt1:=""
  cFilt1 := "IDFIRMA=="+cm2str(cIdFirma)+".and."+aUsl1+".and."+aUsl3
  if !empty(dDatOd) .or. !empty(dDatDo)
	// -----------
	// koristim nalog->datNal tj. datum azuriranja za obuhvatanje naloga po datumu jer nema puno koristi od gledanja datuma stavke (suban->datDok), MS 04.04.2003
	// -----------
	cFilt1 += ".and. nalog->datNal>="+cm2str(dDatOd)+".and. nalog->datNal<="+cm2str(dDatDo)
  endif

  IF !EMPTY(qqSpecUslov)
    cFilt1 += ".and.("+qqSpecUslov+")"
  ENDIF

  cFilt1 := STRTRAN(cFilt1,".t..and.","")

  IF !(cFilt1==".t.")
    SET FILTER TO &cFilt1
  ENDIF

  altd()
  go top

  MsgO("Prolaz kroz SUBAN...")
  StartPrint(.t.)
  ? "FIN - U DATOTECI ZA PRENOS SU SLJEDECI DOKUMENTI - NALOZI:"
  ?; ? "FIRMA� TIP 쿍ROJ    �  DATUM "
     ? "-----------------------------"
  do while !eof()
  	select SUBAN
  	Scatter()
  	select PSUBAN
  	append ncnl
  	Gather2()
  	select SUBAN
  	SKIP 1
  		cpFirma:=idfirma
  		cpIDVN:=idvn
  		cpBrNal:=brnal
  	SKIP -1
  	IF cpFirma+cpIdVN+cpBrNal!=idfirma+idvn+brnal
  		? "  "+idfirma+" �  "+idvn+" �"+brnal+"�"+DTOC(nalog->datNal)
  	ENDIF
  	skip 1
  enddo
  EndPrint()

  MsgC()
else
  close all
  return
endif
close all

O_KONTO
O_PARTN
O_SIFK
O_SIFV

O__KONTO

INDEX ON id TO "_KONTTMP"  // index radi trazenja

O__PARTN

INDEX ON id TO "_PARTTMP"  // index radi trazenja

select _konto
//append from konto  !! ? kupi i sto treba i sto ne treba

MsgO("Osvjezavam datoteke _Konto i _Partn ... ")
O_PSUBAN
select PSUBAN
go top
// uzmi samo konta koja su se pojavila u dokumentima !!!!

altd()

do while !eof()

  select _konto
  // nafiluj tabelu _KONTO sa siframa iz dokumenta
  seek PSUBAN->idkonto
  if !found()
    select konto
    seek PSUBAN->idkonto
    if found()
     scatter()
     // dodaj u _konto
     select _konto
     append blank
     Gather()
    endif
    if fsifk
      SifkFill(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","KONTO",PSUBAN->idkonto)
    endif
  endif

  select _partn
  // nafiluj tabelu _PARTN sa siframa iz dokumenta
  seek PSUBAN->idpartner
  if !found()
    select partn
    seek PSUBAN->idpartner
    if found()
     scatter()
     // dodaj u _partn
     select _partn
     append blank
     Gather()
    endif
    if fsifk
      SifkFill(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","PARTN",PSUBAN->idpartner)
    endif
  endif

  select PSUBAN
  skip
enddo

MsgC()

close all

FILECOPY( PRIVPATH+"OUTF.TXT" , PRIVPATH+"_FIN.TXT" )

aFajlovi:={ PRIVPATH+"PSUBAN.*",;
            PRIVPATH+"_KONTO.*",;
            PRIVPATH+"_PARTN.*",;
            PRIVPATH+"_FIN.TXT",;
            PRIVPATH+"_SIF?.*"}
Zipuj(aFajlovi,cFZaPredaju,cLokPren)
return




/*! \fn PovDisk()
 *  \brief Povrat dokumenata
 */
 
function PovDisk()

local nRec
PRIVATE cLokPren    := "A:\"
PRIVATE cFZaPredaju := "AFIN"
PRIVATE cFZaPrijem  := "AFIN"
PRIVATE cUslovVDok  := "1;"
PRIVATE cSpecUslov  := ""
PRIVATE cKonvFirma  := ""
PRIVATE cKonvBrDok  := ""

PPPDisk(.t.)

fSifk:=.t.


IF !Unzipuj(cFZaPrijem,,cLokPren)   // raspakuje u PRIVPATH
  CLOSERET
ENDIF

close all
if lastkey()==K_ESC; return; endif

save screen to cs
VidiFajl(PRIVPATH+"_FIN.TXT")
IF Pitanje(,"Zelite li preuzeti prikazane dokumente? (D/N)"," ")=="N"
  restore screen from cs
  RETURN
ENDIF
restore screen from cs

O_PSUBAN
O_PRIPR

SELECT PSUBAN; set order to 0  // idFirma+IdVN+BrNal+RBr

if !EMPTY(cKonvFirma+cKonvBrDok)
  aKBrDok:=TokUNiz(cKonvBrDok)
  aKFirma:=TokUNiz(cKonvFirma)
  GO TOP
  DO WHILE !EOF()
    nPosKBrDok := ASCAN( aKBrDok , {|x| x[1]==IDVN   } )
    IF nPosKBrDok>0
      cPom777 := aKBrDok[nPosKBrDok,2]
      REPLACE brnal WITH &cPom777
    ENDIF
    nPosKFirma := ASCAN( aKFirma , {|x| x[1]==IDFIRMA} )
    IF nPosKFirma>0
      REPLACE idfirma WITH aKFirma[nPosKFirma,2]
    ENDIF
    SKIP 1
  ENDDO
endif

cidfirma:=gfirma; cIdVN:=space(2); cBrNal:=space(8)

MsgO("Prenos PSUBAN -> PRIPR")
select pripr
append from PSUBAN
MsgC()

cdn1:=Pitanje(,"KONTA - DODATI nepostojece sifre ?","D")
cdn2:=Pitanje(,"KONTA - ZAMIJENITI postojece sifre ?","D")

if cdn1=="D"
close all
O_KONTO
O_SIFK
O_SIFV
O__KONTO

set order to 0
go top
Box(,1,60)

// prolazimo kroz _KONTO
do while !eof()
  @ m_x+1,m_y+2 SAY id; ?? "-",naz
  select KONTO; scatter()
  select _KONTO
  scatter()
  select KONTO; hseek _id
  if !found()
    append blank
    gather()
    SifKOsv(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","KONTO",_id)
  else
    if cdn2=="D"  // zamijeniti postojece sifre
     gather()
     SifKOsv(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","KONTO",_id)
    endif
  endif
  select _KONTO
  skip
enddo
Boxc()
endif // cnd1

if pitanje(,"PARTN - dodati nepostojece sifre ?","D")=="D"
	close all
	O_PARTN
	O_SIFK
	O_SIFV
	O__PARTN
	set order to 0
	go top
	Box(,1,60)
	do while !eof()
		@ m_x+1,m_y+2 SAY id; ?? "-",naz
		select partn ;   scatter()
		select _partn
		scatter()
		select partn; hseek _id
		if !found()
			append blank
			gather()
			if fSifk
				SifKOsv(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","PARTN",_id)
			endif
		endif
		select _partn
		skip
	enddo
	BoxC()
endif

closeret
return



/*! \fn PPPDisk(lIni)
 *  \brief Podesavanje prenosa i prijema dokumenata
 *  \param lIni
 */
 
function PPPDisk(lIni)

LOCAL GetList:={}
  IF lIni==NIL; lIni:=.f.; ENDIF
  O_PARAMS
  private cSection:="3",cHistory:=" "; aHistory:={}

  IF !lIni
    private cLokPren    := "A:\"
    private cFZaPredaju := "AFIN"
    private cFZaPrijem  := "AFIN"
    private cUslovVDok  := ""
    private cSpecUslov  := ""
    private cKonvFirma  := ""
    private cKonvBrDok  := ""
  ENDIF

  RPar("01",@cLokPren    )
  RPar("02",@cFZaPredaju )
  RPar("03",@cFZaPrijem  )
  RPar("04",@cUslovVDok  )
  RPar("05",@cSpecUslov  )
  RPar("06",@cKonvFirma  )
  RPar("07",@cKonvBrDok  )

  IF !lIni

    cLokPren    := PADR( cLokPren    , 80 )
    cFZaPredaju := PADR( cFZaPredaju , 80 )
    cFZaPrijem  := PADR( cFZaPrijem  , 80 )
    cUslovVDok  := PADR( cUslovVDok  , 80 )
    cSpecUslov  := PADR( cSpecUslov  , 80 )
    cKonvFirma  := PADR( cKonvFirma  , 80 )
    cKonvBrDok  := PADR( cKonvBrDok  , 80 )

    Box(,12,75)
     @ m_X+ 0,m_y+ 4 SAY "PODESAVANJE PARAMETARA ZA PRENOS I PRIJEM PODATAKA PUTEM DISKETA"
     @ m_X+ 2,m_y+ 2 SAY "Lokacija za prenos            " GET cLokPren    PICT "@!S30"
     @ m_X+ 3,m_y+ 2 SAY "Naziv fajla za predaju        " GET cFZaPredaju PICT "@!S30"
     @ m_X+ 4,m_y+ 2 SAY "Naziv fajla za prijem         " GET cFZaPrijem  PICT "@!S30"
     @ m_X+ 5,m_y+ 2 SAY "Standardno koristeni uslov za "
     @ m_X+ 6,m_y+ 2 SAY "tip dokumenata koji se prenose" GET cUslovVDok  PICT "@!S30"
     @ m_X+ 7,m_y+ 2 SAY "Specificni dodatni uslov      " GET cSpecUslov  PICT "@!S30"
     @ m_X+ 8,m_y+ 2 SAY "컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴"
     @ m_X+ 9,m_y+ 2 SAY "Konverzije pri prijemu dokumenata:"
     @ m_X+10,m_y+ 2 SAY "Oznaka firme (F1.F2;F3.F4 ...)  " GET cKonvFirma  PICT "@!S30"
     @ m_X+11,m_y+ 2 SAY "Br.dokumenta (VN1.F1;VN2.F2 ...)" GET cKonvBrDok  PICT "@!S30"
     READ
    BoxC()

    cLokPren    := TRIM( cLokPren    )
    cFZaPredaju := TRIM( cFZaPredaju )
    cFZaPrijem  := TRIM( cFZaPrijem  )
    cUslovVDok  := TRIM( cUslovVDok  )
    cSpecUslov  := TRIM( cSpecUslov  )
    cKonvFirma  := TRIM( cKonvFirma  )
    cKonvBrDok  := TRIM( cKonvBrDok  )

    IF LASTKEY()!=K_ESC
      WPar("01",cLokPren    )
      WPar("02",cFZaPredaju )
      WPar("03",cFZaPrijem  )
      WPar("04",cUslovVDok  )
      WPar("05",cSpecUslov  )
      WPar("06",cKonvFirma  )
      WPar("07",cKonvBrDok  )
    ENDIF

  ENDIF
  USE
RETURN




