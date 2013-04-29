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


#include "ld.ch"


// ------------------------------------------
// da li ce se racunati min.bruto
// ------------------------------------------
function calc_mbruto()
local lRet := .t.

if ld->I01 = 0
	lRet := .f.
endif

return lRet 


// -----------------------------------------------
// preracunava postojeci iznos na bruto iznos
// -----------------------------------------------
function _calc_tpr( nIzn, lCalculate )
local nRet := nIzn
local cTR

if lCalculate == nil
	lCalculate := .f.
endif

cTR := g_tip_rada( ld->idradn, ld->idrj )

if gPrBruto == "X" .and. ( tippr->uneto == "D" .or. lCalculate == .t. )
	nRet := bruto_osn( nIzn, cTR, ld->ulicodb )
endif

return nRet


// -------------------------------------------------------------------
// lista tipova rada koji se mogu prikazivati pod jednim izvjestajem 
// ili koji ce koristiti iste doprinose
// -------------------------------------------------------------------
function tr_list()
return "I#N"


// -----------------------------------------------------------
// vraca tip rada za radnika i gleda i radnu jedinicu
// ld_rj->TIPRADA = " " - gledaj sif.radnika
// ld_rj->TIPRADA $ "IAUP.." - uzmi za radnu jedinicu vrijednost
//                          tipa rada 
// -----------------------------------------------------------
function g_tip_rada( cRadn, cRj )
local cTipRada := " "
local nTArea := SELECT()

select ld_rj
go top
seek cRJ

if ld_rj->(fieldpos("tiprada")) <> 0
	cTipRada := ld_rj->tiprada
endif

// ako je prazno tip rada, gledaj sifrarnik radnika
if EMPTY( cTipRada )
	select radn
	go top
	seek cRadn
	cTipRada := radn->tiprada
endif

select (nTArea)
return cTipRada


// -----------------------------------------------------------
// vraca oporezivost za radnika i gleda i radnu jedinicu
// ld_rj->OPOR = " " - gledaj sif.ranika
//            "D" - oporeziva kompletna radna jedinica
//            "N" - nije oporeziva radna jedinica
// -----------------------------------------------------------
function g_oporeziv( cRadn, cRj )
local cOpor := " "
local nTArea := SELECT()

select ld_rj
go top
seek cRJ

if ld_rj->(fieldpos("opor")) <> 0
	cOpor := ld_rj->opor
endif

// ako je prazno oporeziv, gledaj sifrarnik radnika
if EMPTY( cOpor )
	select radn
	go top
	seek cRadn
	cOpor := radn->opor
endif

select (nTArea)
return cOpor



// -------------------------------------------------------
// poruka - informacije o dostupnim tipovima rada
// -------------------------------------------------------
function MsgTipRada()
local x := 1
Box(,10,66)
 @ m_x+x,m_y+2 SAY Lokal("Vazece sifre su: ' ' - zateceni neto (bez promjene ugovora o radu)")
 ++x
 @ m_x+x,m_y+2 SAY Lokal("                 'N' - neto placa (neto + porez)")
 ++x
 @ m_x+x,m_y+2 SAY Lokal("                 'I' - neto-neto placa (zagarantovana)")
 ++x
 @ m_x+x,m_y+2 SAY Lokal("                 -------------------------------------------------")
 ++x
 @ m_x+x,m_y+2 SAY Lokal("                 'S' - samostalni poslodavci")
 ++x
 @ m_x+x,m_y+2 SAY Lokal("                 'U' - ugovor o djelu")
 ++x
 @ m_x+x,m_y+2 SAY Lokal("                 'A' - autorski honorar")
 ++x
 @ m_x+x,m_y+2 SAY Lokal("                 'P' - clan.predsj., upr.odbor, itd...")
 ++x
 @ m_x+x,m_y+2 SAY Lokal("                 -------------------------------------------------")
 ++x
 @ m_x+x,m_y+2 SAY Lokal("                 'R' - obracun za rs")

 inkey(0)
BoxC()

return .f.


// ------------------------------------------
// vraca iznos doprinosa po tipu rada
// ------------------------------------------
function get_dopr(cDopr, cTipRada)
local nTArea := SELECT()
local nIzn := 0

if cTipRada == nil
	cTipRada := " "
endif

O_DOPR
go top
seek cDopr
do while !EOF() .and. dopr->id == cDopr
	
	// provjeri tip rada
	if EMPTY( dopr->tiprada ) .and. cTipRada $ tr_list() 
		// ovo je u redu...
	elseif ( cTipRada <> dopr->tiprada )
		skip 
		loop
	endif
	
	nIzn := dopr->iznos
	
	exit

enddo

select (nTArea)
return nIzn



// --------------------------------------------
// da li je radnik oporeziv ?
// --------------------------------------------
function radn_oporeziv( cRadn, cRj )
local lRet := .t.
local nTArea := SELECT()
local cOpor

// izvuci vrijednost da li je radnik oporeziv ?
cOpor := g_oporeziv( cRadn, cRj )

if cOpor == "N"
	lRet := .f.
endif

select (nTArea)

return lRet 



// ---------------------------------------------------------
// vraca bruto osnovu
// nIzn - ugovoreni neto iznos
// cTipRada - vrsta/tip rada
// nLOdb - iznos licnog odbitka
// nSKoef - koeficijent kod samostalnih poslodavaca
// cTrosk - ugovori o djelu i ahon, korsiti troskove ?
// ---------------------------------------------------------
function bruto_osn( nIzn, cTipRada, nLOdb, nSKoef, cTrosk )
local nBrt := 0

if nIzn <= 0
	return nBrt
endif

if nLOdb = nil
	nLOdb := 0
endif

if nSKoef = nil
	nSKoef := 0
endif

if cTrosk == nil
	cTrosk := ""
endif

// stari obracun
if gVarObracun <> "2"
	nBrt := ROUND2( nIzn * ( parobr->k3 / 100 ), gZaok2 )
	return nBrt
endif

do case
	// nesamostalni rad
	case EMPTY(cTipRada)
		nBrt := ROUND2( nIzn * parobr->k5 ,gZaok2 )

	// neto placa (neto + porez )
	case cTipRada == "N"
		nBrt := ROUND2( nIzn * parobr->k6 , gZaok2 )

	// nesamostalni rad, isti neto
	case cTipRada == "I"
		// ako je ugovoreni iznos manji od odbitka
		if (nIzn < nLOdb ) 
			nBrt := ROUND2( nIzn * parobr->k6, gZaok2 )
		else
			nBrt := ROUND2( ( (nIzn - nLOdb) / 0.9 + nLOdb ) ;
				/ 0.69  ,gZaok2)
		endif
		
	// samostalni poslodavci
	case cTipRada == "S"
		nBrt := ROUND2( nIzn * nSKoef ,gZaok2 )
	
	// predsjednicki clanovi
	case cTipRada == "P"
		nBrt := ROUND2( (nIzn * 1.11111) / 0.96 , gZaok2)
	
	// republika srpska
	case cTipRada == "R"
		nTmp := ROUND( ( nLOdb * parobr->k5 ), 2 )
		nBrt := ROUND2( (nIzn - nTmp) / parobr->k6 , gZaok2)
	
	// ugovor o djelu i autorski honorar
	case cTipRada $ "A#U"

		if cTipRada == "U"
			nTr := gUgTrosk
		else
			nTr := gAHTrosk
		endif

		if cTrosk == "N"
			nTr := 0
		endif
		
		nBrt := ROUND2( nIzn / ( ((100 - nTr) * 0.96 * 0.90 + nTr )/100 ) , gZaok2 )
		
		// ako je u RS-u, nema troskova, i drugi koeficijent
		if in_rs( radn->idopsst, radn->idopsrad )
			
			nBrt := ROUND2( nIzn * 1.111112, gZaok2 )
		endif

endcase

return nBrt


// ----------------------------------------
// ispisuje bruto obracun
// ----------------------------------------
function bruto_isp( nNeto, cTipRada, nLOdb, nSKoef, cTrosk )
local cPrn := ""

if nLOdb = nil
	nLOdb := 0
endif

if nSKoef = nil
	nSKoef := 0
endif

if cTrosk == nil
	cTrosk := ""
endif

do case
	// nesamostalni rad
	case EMPTY(cTipRada)
		cPrn := ALLTRIM(STR(nNeto)) + " * " + ;
			ALLTRIM(STR(parobr->k5)) + " ="
	
	// nerezidenti
	case cTipRada == "N"
		cPrn := ALLTRIM(STR(nNeto)) + " * " + ;
			ALLTRIM(STR(parobr->k6)) + " ="

	// nesamostalni rad - isti neto
	case cTipRada == "I"
		cPrn := "((( " + ALLTRIM(STR(nNeto)) + " - " + ;
			ALLTRIM(STR(nLOdb)) + ")" + ;
			" / 0.9 ) + " + ALLTRIM(STR(nLOdb)) + " ) / 0.69 ="
		if ( nNeto < nLOdb ) 
			cPrn := ALLTRIM(STR(nNeto)) + " * " + ;
				ALLTRIM(STR(parobr->k6)) + " ="

		endif
	// samostalni poslodavci
	case cTipRada == "S"
		cPrn := ALLTRIM(STR(nNeto)) + " * " + ;
			ALLTRIM(STR(nSKoef)) + " ="
	
	// clanovi predsjednistva
	case cTipRada == "P"
		cPrn := ALLTRIM(STR(nNeto)) + " * 1.11111 / 0.96 =" 
	
	// republika srpska
	case cTipRada == "R"
		
		nTmp := ROUND( ( nLOdb * parobr->k5 ), 2 )

		cPrn := "( " + ALLTRIM(STR(nNeto)) + " - " + ;
			ALLTRIM(STR( nTmp )) + " ) / " + ;
			ALLTRIM(STR( parobr->k6 )) + " =" 
	
	// ugovor o djelu
	case cTipRada $ "A#U"
	
		if cTipRada == "U"
			nTr := gUgTrosk
		else
			nTr := gAHTrosk
		endif

		if cTrosk == "N"
			nTr := 0
		endif
		
		nProc := ( ((100 - nTr) * 0.96 * 0.90 + nTr ) / 100 ) 
	
		cPrn := ALLTRIM(STR(nNeto)) + " / " + ALLTRIM(STR(nProc,12,6)) + " ="
		// ako je u RS-u, nema troskova, i drugi koeficijent
		if in_rs( radn->idopsst, radn->idopsrad )
			
			cPrn := ALLTRIM(STR(nNeto)) + " * 1.111112 ="
		endif

endcase

return cPrn


// --------------------------------------------
// minimalni bruto
// --------------------------------------------
function min_bruto( nBruto, nSati )
local nRet
local nMBO
local nParSati
local nTmpSati

if nBruto <= 0
	return nBruto
endif

// sati iz parametara obracuna
nParSati := parobr->k1

// puno radno vrijeme ili rad na 4 sata
if (nSati = nParSati) .or. (nParSati/2 = nSati) .or. (radn->k1 $ "M#P")
	
	nTmpSati := nSati
	
	if radn->k1 == "P" 
		nTmpSati := nSati * 2
	endif

	nMBO := ROUND2( nTmpSati * parobr->m_br_sat, gZaok2 )
	nRet := MAX( nBruto, nMBO )
else
	nRet := nBruto
endif

return nRet



// --------------------------------------------
// minimalni neto
// --------------------------------------------
function min_neto( nNeto, nSati )
local nRet
local nMNO
local nParSati
local nTmpSati

if nNeto <= 0
	return nNeto
endif

// sati iz parametara obracuna
nParSati := parobr->k1

// ako je rad puni ili rad na 4 sata
if (nParSati = nSati) .or. (nParSati/2 = nSati) .or. (radn->k1 $ "M#P")

	nTmpSati := nSati

	if radn->k1 == "P" 
		nTmpSati := nSati * 2
	endif

	nMNO := ROUND2( nTmpSati * parobr->m_net_sat, gZaok2 )
	nRet := MAX( nNeto, nMNO )
else
	nRet := nNeto
endif

return nRet



// ---------------------------------------------------
// validacija tipa rada na uslovima izvjestaja
// ---------------------------------------------------
function val_tiprada( cTR )
if cTR $ " #I#S#P#U#N#A#R"
	return .t.
else
	return .f.
endif

return


// --------------------------------
// ispisuje potpis
// --------------------------------
function p_potpis()
private cP1 := gPotp1
private cP2 := gPotp2

if gPotpRpt == "N"
	return ""
endif

if !EMPTY(gPotp1)
	?
	QQOUT(&cP1)	
endif

if !EMPTY(gPotp2)
	? 
	QQOUT(&cP2)
endif

return ""


// -----------------------------------------------------
// vraca koeficijent licnog odbitka
// -----------------------------------------------------
function g_klo( nUOdbitak )
local nKLO := 0
if nUOdbitak <> 0
	nKLO := nUOdbitak / gOsnLOdb
endif
return nKLO



// ------------------------------------------------
// vraca ukupnu vrijednost licnog odbitka
// ------------------------------------------------
function g_licni_odb( cIdRadn )
local nTArea := SELECT()
local nIzn := 0

select radn
seek cIdRadn

if field->klo <> 0
	nIzn := round2( gOsnLOdb * field->klo, gZaok2)
else
	nIzn := 0
endif

select (nTArea)
return nIzn


// ----------------------------------------------------------
// setuj obracun na tip u skladu sa zak.promjenama
// ----------------------------------------------------------
function set_obr_2009()

if YEAR(DATE()) >= 2009 .and. goModul:oDataBase:cRadimUSezona == "RADP" .and. ;
	gVarObracun <> "2"

	MsgBeep("Nova je godina. Obracun je podesen u skladu sa#novim zakonskim promjenama !")
	gVarObracun := "2"

else
	gVarObracun := " "
endif

return


// -----------------------------------------------
// vraca varijantu obracuna iz tabele ld
// -----------------------------------------------
function get_varobr()
return ld->varobr


// -----------------------------------------------------
// promjena varijante obracuna za tekuci obracun
// -----------------------------------------------------
function ld_promjeni_varijantu_obracuna()
local nLjudi, _rec

if Logirati(goModul:oDataBase:cName,"DOK","CHVAROBRACUNA")
	lLogChVarObr:=.t.
else
	lLogChVarObr:=.f.
endif

Box(,4,60)
	@ m_x+1,m_y+2 SAY "Ova opcija vrsi zamjenu identifikatora varijante"
  	@ m_x+2,m_y+2 SAY "obracuna za tekuci obracun."
  	@ m_x+4,m_y+2 SAY "               <ESC> Izlaz"
  	inkey(0)
BoxC()

if (LastKey() == K_ESC)
	closeret
	return
endif

cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun
cVarijanta := SPACE(1)

O_RADN
O_LD

Box(,5,50)
	@ m_x+1,m_y+2 SAY "Radna jedinica: "  GET cIdRJ
	@ m_x+2,m_y+2 SAY "Mjesec: "  GET  cMjesec  pict "99"
	@ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
	@ m_x+4,m_y+2 SAY "Obracun:"  GET  cObracun WHEN HelpObr(.f.,cObracun) VALID ValObr(.f.,cObracun)
	@ m_x+5,m_y+2 SAY "Postavi na varijantu:" GET  cVarijanta

	READ

	ClvBox()
	ESC_BCR
BoxC()

select ld
seek STR( cGodina, 4 ) + cIdRj + STR( cMjesec, 2 ) + BrojObracuna()

EOF CRET

nLjudi := 0

Box(,1,12)
  
   do while !eof() .and. cGodina==godina .and. cIdRj==idrj .and. cMjesec=mjesec .and. if(lViseObr,cObracun==obr,.t.)

	_rec := dbf_get_rec()
    _rec["varobr"] := cVarijanta
    update_rec_server_and_dbf( ALIAS(), _rec )

 	@ m_x+1,m_y+2 SAY ++nLjudi pict "99999"
 	
	skip

   enddo
 
   if lLogChVarObracun
	EventLog(nUser,goModul:oDataBase:cName,"DOK","CHVAROBRACUN",nLjudi,nil,nil,nil,cIdRj,STR(cMjesec,2),STR(cGodina,4),Date(),Date(),"","Promjena varijante obracuna za tekuci obracun")
   endif

   Beep(1)
   inkey(1)

BoxC()

close all

return



function TagVO( cT, cI )

if cI == NIL
    cI := ""
endif

if lViseObr .and. cT $ "12"
    if cI == "I" .or. EMPTY( cObracun )
        cT := cT + "U"
    endif
endif

return cT



function tipprn_use()

// zatvori tippr, tippr2
select (F_TIPPR)
if USED()
    use
endif

select (F_TIPPR2)
if USED()
    use
endif

// otvori sta vec treba
O_TIPPRN

return



function NaDiskete()

cIdRj    := gRj
cMjesec  := gMjesec
cGodina  := gGodina
cObracun := gObracun

O_LD
copy structure extended to struct
use
create (PRIVPATH+"_LD") from struct
close all
O_RADN
copy structure extended to struct
use
create (PRIVPATH+"_RADN") from struct
close all
O_KRED
copy structure extended to struct
ferase(PRIVPATH+"_KRED.CDX")
use
create (PRIVPATH+"_KRED") from struct
#ifdef C50
 index on id to (PRIVPATH+"_kredi1")
#else
 index on id tag ("ID") to (PRIVPATH+"_kred")
#endif
close all
*
O_RADKR
copy structure extended to struct
ferase(PRIVPATH+"_RADKR.CDX")
use
create (PRIVPATH+"_RADKR") from struct
close all

O_KBENEF
O_VPOSLA
O_LD_RJ
O_RADKR
O_KRED
O_RADN
O_LD
O__LD 
SET ORDER TO
 GO TOP
O__RADN
O__RADKR
O__KRED

private cKBenef:=" ",cVPosla:=" ",cDisk:="A:\"

Box(,6,50)
@ m_x+1,m_y+2 SAY "Radna jedinica : "  GET cIdRJ
@ m_x+2,m_y+2 SAY "Mjesec: "  GET  cMjesec  pict "99"
@ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
@ m_x+4,m_y+2 SAY "Disketa:"  GET  cDisk
read; ESC_BCR

select ld
set order to 1
hseek str(cGodina,4)+cidrj+str(cMjesec,2)

do while !eof() .and.  cgodina==godina .and. idrj=cidrj .and. cmjesec=mjesec

 Scatter()  // ld

 select radn; hseek _idradn
 Scatter("r")        // radn
 select _radn
 append blank
 Gather("r")

 SELECT RadKr   // str(godina)+str(mjesec)+idradn+idkred+naosnovu

 HSEEK Str (cGodina,4)+Str (cMjesec)+_IdRadn
 IF Found()
   While !Eof() .and. RADKR->Godina==cGodina .and. RADKR->Mjesec==cMjesec;
         .and. RADKR->IdRadn==_IdRadn
     cIdKred := RADKR->IdKred
     While ! Eof() .and. RADKR->Godina==cGodina .and. RADKR->Mjesec==cMjesec;
           .and. RADKR->(IdRadn+IdKred)==(_IdRadn+cIdKred)
       Scatter ("w")
       SELECT _RADKR
       Append Blank
       Gather ("w")
       SELECT RADKR
       SKIP
     EndDO
     *
     SELECT KRED
     HSEEK cIdKred
     Scatter ("x")
     SELECT _KRED
     HSEEK cIdKred
     IF ! Found()
       Append Blank
       Gather ("x")
     EndIF
     *
     SELECT RADKR
   EndDO
 EndIF

 select _ld
 append blank
 Gather()

 select ld
 skip
enddo

close all

@ m_x+6,m_y+2 SAY "stavi praznu disketu.."
inkey(0)
copy file (PRIVPATH+"_LD.DBF") to (cDisk+"_LD.DBF")
copy file (PRIVPATH+"_RADN.DBF") to (cDisk+"_RADN.DBF")
copy file (PRIVPATH+"_RADKR.DBF") to (cDisk+"_RADKR.DBF")
copy file (PRIVPATH+"_KRED.DBF") to (cDisk+"_KRED.DBF")
#ifdef C50
 copy file (PRIVPATH+"_KREDi1.NTX") to (cDisk+"_KREDi1.NTX")
#else
 copy file (PRIVPATH+"_KRED.CDX") to (cDisk+"_KRED.CDX")
#endif
BoxC()

Beep(1)
Msg("Podaci kopirani na "+cDisk)

closeret



function SaDisketa()

local cOdgov:="N"

private cDisk:="A:\"

Box(,1,50)
 @ m_x+1,m_y+2 SAY "Disketa:"  GET  cDisk
 read; ESC_BCR
Boxc()

copy file (cDisk+"_LD.DBF") to (PRIVPATH+"_LD.DBF")
copy file (cDisk+"_RADN.DBF") to (PRIVPATH+"_RADN.DBF")
copy file (cDisk+"_RADKR.DBF") to (PRIVPATH+"_RADKR.DBF")
copy file (cDisk+"_KRED.DBF") to (PRIVPATH+"_KRED.DBF")
#ifdef C50
 copy file (cDisk+"_KREDi1.NTX") to (PRIVPATH+"_KREDi1.NTX")
#else
 copy file (cDisk+"_KRED.CDX") to (PRIVPATH+"_KRED.CDX")
#endif

O__KRED; GO TOP
O__RADKR; GO TOP
O__RADN; GO TOP
O__LD
SET ORDER TO
GO TOP

cidrj   := idrj
cmjesec := mjesec
cgodina := godina

O_KRED
O_RADKR
O_RADN
O_LD

hseek str(cGodina,4)+cidrj+str(cMjesec,2)
if found()
 Beep(2)
 Msg("Podaci za "+str(cMjesec,2)+"/"+str(cGodina,4)+" rj "+cidrj+" vec postoje")
 closeret
endif

SELECT _LD
GO TOP
Box(,6,40)
nRbr:=0
do while !eof() .and.  cgodina==godina .and. idrj=cidrj .and. cmjesec=mjesec

 Scatter()  // _ld
 @ m_x+1,m_y+2 SAY "LD ..."
 @ row(),col()+1 SAY ++nrbr pict "9999"
 SELECT LD
 append blank
 Gather()

 SELECT _LD
 SKIP 1
enddo


nRbr := 0
SELECT _RADN
GO TOP
do while !eof()

 Scatter()  // _radn
 @ m_x+2,m_y+2 SAY "RADNICI ..."
 @ row(),col()+1 SAY ++nrbr pict "9999"

 select radn
 hseek _id
 if !found()
  append blank
  Gather()
 elseif cOdgov!="O"
   if cOdgov=="A".or.(cOdgov:=Pitanje2("",'RADNIK:'+_id+'. Zelite li da zamijenite podatke?','N'))$'DA'
     Gather()
   endif
 endif
 select _radn
 skip 1
enddo

nRbr := 0
SELECT _RADKR
GO TOP
While ! Eof()
  Scatter()
  @ m_x+3,m_y+2 SAY "KREDITI ..."
  @ row(),col()+1 SAY ++nrbr pict "9999"
  SELECT RADKR  // str(godina)+str(mjesec)+idradn+idkred+naosnovu
  HSEEK STR (_Godina)+Str (_Mjesec)+_IdRadn+_IdKred+_NaOsnovu
  IF ! Found ()
    Append Blank
  EndIF
  Gather ()
  SELECT _RADKR
  SKIP 1
EndDO

nRbr := 0
SELECT _KRED
GO TOP
While ! Eof()
  Scatter()
  @ m_x+4,m_y+2 SAY "KREDITORI ..."
  @ row(),col()+1 SAY ++nrbr pict "9999"
  SELECT KRED
  HSEEK _Id
  IF ! Found ()
    Append Blank
  EndIF
  Gather ()
  SELECT _KRED
  SKIP 1
EndDO

Beep(3)
@m_x+6,m_y+2 SAY "Prenos je zavrsen !!!"
inkey(0)
BoxC()
closeret


// ------------------------------------------------
// preuzimanje podataka iz drugog obracuna
// ------------------------------------------------
function ld_preuzmi_obracun()
local i, lSveRJ

O_LD

cIdRj    := gRj
cMjesec  := gMjesec
cGodina  := gGodina
cObracun := " "
cDodati  := "N"

Box(,4,75)
 @ m_x+0,  m_y+2 SAY "PREUZETI PODATKE IZ OBRACUNA:"
 @ m_x+1,  m_y+2 SAY "Mjesec:  "  GET cMjesec pict "99"
 @ m_x+1,col()+2 SAY "Godina:  "  GET cGodina pict "9999"
 @ m_x+2,  m_y+2 SAY "RJ (prazno-sve):"  GET cIdRJ
 @ m_x+3,  m_y+2 SAY "Obracun: "  GET cObracun VALID cObracun<>gObracun .and. !EMPTY(cObracun)
 @ m_x+4,  m_y+2 SAY "Dodati (iznose) na postojeci obracun: "  GET cDodati pict "@!" valid cDodati $ "DN"
 read; ESC_BCR
BoxC()

lSveRJ:=.f.
if EMPTY(cIDRJ) .and. pitanje(,"Zelite li preuzeti podatke ZA SVE RJ za ovaj mjesec ?","D")=="D"
  lSveRJ:=.t.
endif

select ld
if lSveRJ
  SET ORDER TO TAG "2"
// "str(godina)+str(mjesec)+obr+idradn+idrj"
  seek str(cGodina,4)+str(cMjesec,2)+cObracun
else
// "str(godina)+idrj+str(mjesec)+obr+idradn"
  seek str(cGodina,4)+cIdRj+str(cMjesec,2)+cObracun
endif
if !found()
  Beep(1)
  Msg("Ovaj obracun ne postoji!",4)
  closeret
endif

IF lSveRJ
  do while !eof() .and. STR(godina,4)+str(Mjesec,2)+Obr==str(cGodina,4)+str(cMjesec,2)+cObracun
    nRec:=RECNO()
    Scatter()
    _godina := gGodina
    _mjesec := gMjesec
    _obr    := gObracun
    seek str(gGodina,4)+str(gMjesec,2)+gObracun+_idradn+_idrj
    IF FOUND()
      IF cDodati=="N"
        gather()
      ELSE
        private cpom:=""
        Scatter("w") // stanje u datoteci ld
        for i:=1 to cLDPolja
          cPom:=padl(alltrim(str(i)),2,"0")
          wi&cPom+=_i&cPom
        next
        wuneto+=_uneto
        wuodbici+=_uodbici
        wuiznos+=_uiznos
        Gather("w")
      ENDIF
    ELSE
      append blank
      gather()
    ENDIF
    GO (nRec); skip 1
  enddo
  MsgBeep("Preuzimanje podataka iz obracuna "+cObracun+" za "+STR(cMjesec,2)+"/"+STR(cGodina,4)+",#"+;
          " za sve RJ zavrseno. Novi obracun:"+gObracun+" za "+STR(gMjesec,2)+"/"+STR(gGodina,4))
ELSE
  do while !eof() .and. STR(godina,4)+IdRj+str(Mjesec,2)+Obr==str(cGodina,4)+cIdRj+str(cMjesec,2)+cObracun
    nRec:=RECNO()
    Scatter()
    _godina := gGodina
    _mjesec := gMjesec
    _idrj   := gRJ
    _obr    := gObracun
    seek str(gGodina,4)+gRj+str(gMjesec,2)+gObracun+_idradn
    IF FOUND()
      IF cDodati=="N"
        gather()
      ELSE
        private cpom:=""
        Scatter("w") // stanje u datoteci ld
        for i:=1 to cLDPolja
         cPom:=padl(alltrim(str(i)),2,"0")
         wi&cPom+=_i&cPom
        next
        wuneto+=_uneto
        wuodbici+=_uodbici
        wuiznos+=_uiznos
        Gather("w")
      ENDIF
    ELSE
       append blank
       gather()
    ENDIF
    GO (nRec); skip 1
  enddo
  MsgBeep("Preuzimanje podataka iz obracuna "+cObracun+" za "+STR(cMjesec,2)+"/"+STR(cGodina,4)+",#"+;
          " za RJ:"+cIdRJ+". Novi obracun:"+gObracun+" za "+STR(gMjesec,2)+"/"+STR(gGodina,4)+" za RJ:"+gRJ+".")
ENDIF

CLOSERET





function ld_obracun_napravljen_vise_puta()
local cMjesec := gMjesec
local cGodina := gGodina
local cObracun := gObracun
local _data := {}
local cIdRadn, nProlaz, _count
local _i

Box(,3,50)

    @ m_x+1, m_y+2 SAY " Mjesec: " GET cMjesec pict "99"
    @ m_x+2, m_y+2 SAY " Godina: " GET cGodina pict "9999"
    @ m_x+3, m_y+2 SAY "Obracun: " GET cObracun

    read

    ESC_BCR

BoxC()

O_RADN
O_LD

set order to tag "2"
go top
seek STR( cGodina, 4 ) + STR( cMjesec, 2 ) + cObracun

Box(, 1, 60)

_count := 0

do while !EOF() .and. STR( cGodina, 4 ) + STR( cMjesec, 2 ) + cObracun == STR( field->godina, 4 ) + STR( field->mjesec, 2 ) + obr
  
    cIdRadn := idradn
    nProlaz := 0

    ++ _count
    @ m_x + 1, m_y + 2 SAY "Radnik: " + cIdRadn

    do while !EOF() .and. STR( cGodina, 4 ) + STR( cMjesec, 2 ) + cObracun == STR( field->godina, 4 ) + STR( field->mjesec, 2 ) + field->obr .and. field->idradn == cIdradn
        ++ nProlaz
        skip
    enddo

    if nProlaz > 1

        select radn
        hseek cIdRadn

        select ld
    
        seek STR( cGodina, 4 ) + STR( cMjesec,2) + cObracun + cIdRadn

        do while !EOF() .and. STR( field->godina, 4 ) + STR( field->mjesec, 2 ) + field->obr == STR( cGodina, 4 ) + STR( cMjesec, 2 ) + cObracun .and. field->idradn == cIdRadn
            AADD( _data, { field->obr, field->idradn, PADR( ALLTRIM( radn->naz ) + " " + ALLTRIM( radn->ime ), 20 ), field->idrj, field->uneto, field->usati } )
            skip
        enddo

    endif

enddo

BoxC()

// nemam sta prikazati
if LEN( _data ) == 0
    close all
    return
endif


START PRINT CRET

? Lokal("Radnici obradjeni vise puta za isti mjesec -"), cGodina, "/", cMjesec
?
? Lokal("OBR RADNIK                      RJ     neto        sati")
? "--- ------ -------------------- -- ------------- ----------"

for _i := 1 to LEN( _data )

    ? PADR( _data[ _i, 1 ], 3 ), _data[ _i, 2 ], _data[ _i, 3 ], _data[ _i, 4 ], _data[ _i, 5 ], _data[ _i, 6 ]

next

FF
END PRINT

close all
return

// -------------------------------------------
// generisanje virman iz modula LD
// -------------------------------------------
function ld_gen_virm()

O_VIRM_PRIPR
zapp(.t.)

MsgBeep( "Opcija podrazumjeva da ste prozvali rekapitulaciju plate" )

virm_set_global_vars()
virm_prenos_ld( .t. )
// otvori pripremu virmana...
unos_virmana()
    
close all

return







