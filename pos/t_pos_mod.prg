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


#include "pos.ch"
#include "hbclass.ch"


// -----------------------------------------------
// -----------------------------------------------
CLASS TPosMod FROM TAppMod
	method New
	method setGVars
	method setScreen
	method mMenu
	method gProc
	method initdb
	method srv
END CLASS

// -----------------------------------------------
// -----------------------------------------------
method new(p1, p2, p3, p4, p5, p6, p7, p8, p9)
::super:new(p1, p2, p3, p4, p5, p6, p7, p8, p9)
return self


// -----------------------------------------------
// -----------------------------------------------
method initdb()
::oDatabase:=TDbPos():new()
return nil


// -----------------------------------------------
// -----------------------------------------------
method gProc(Ch)
do case
      CASE Ch==K_SH_F2
        PPrint()
      CASE Ch==K_SH_F10
        self:gParams()
      CASE Ch==K_SH_F1
        Calc()
      CASE Ch==K_SH_F5
        self:oDatabase:vratiSez()
      CASE Ch==K_SH_F6
        IF kLevel <= L_UPRAVN
	  self:oDatabase:logAgain(Godina_2(gDatum)+padl(month(gDatum),2,"0"),.f.,.t.)
	EndIF
      CASE Ch==K_SH_F7
        KorLoz()
end case
clear typeahead
return nil


// -----------------------------------------------
// -----------------------------------------------
method mMenu()
local Fx
local Fy

gPrevPos:=gIdPos

Fx:=4
Fy:=8

if gSql=="D"
	O_Log()
	CreDIntDB()
endif

if gSamoProdaja == "N"
	cre_doksrc()
endif

self:oDatabase:scan()

// brisi sve iz _pos sto je zakljuceno....
self:oDatabase:del_pos_z()

/// fill init db podatke
f_init_db()

close all

if gSql=="D"
	if gSamoProdaja=="D"
		self:oDataBase:integ()
	else
		self:oDataBase:chkinteg()
	endif
endif

SETKEY(K_SH_F1,{|| Calc()})

MsgBeep("Ukoliko je predhodni put u toku rada#bilo problema  (nestanak struje, blokirao racunar...),## kucajte lozinku IB, pa <ENTER> !")

do while (.t.)
	m_x:=Fx
      	m_y:=Fy
      	KLevel:=PosPrijava(Fx, Fy)
      	if (self:lTerminate)
		return
	endif
	if !PPrenosPos()
        	self:lTerminate := .t.
                return
        endif

	SETPOS (Fx, Fy)
      	if (KLevel > L_UPRAVN  .and. gVSmjene=="D")
      		Msg("NIJE ODREDJENA SMJENA!!#"+"POTREBNO JE DA SE PRIJAVI SEF OBJEKTA#ILI NEKO VISEG RANGA!!!", 20)
        	loop
      	endif
      	if gVsmjene=="N"
        	gSmjena:="1"
        	OdrediSmjenu(.f.)
      	else
        	OdrediSmjenu(.t.) 
      	endif
      	exit
enddo

PrikStatus()
SETPOS(Fx, Fy)
fPrviPut:=.t.

do while (.t.)

	m_x:=Fx
	m_y:=Fy
  	
	// unesi prijavu korisnika
  	if fPRviPut .and. gVSmjene=="N" // ne vodi vise smjena
    		fPrviPut:=.f.
  	else
    		KLevel:=PosPrijava(Fx, Fy)
    		PrikStatus()
                if !PPrenosPos()
                    self:lTerminate := .t.
                endif
  	endif
  	SETPOS (Fx, Fy)
  	pos_main_menu_level(KLevel,Fx,Fy)

	if self:lTerminate
		// zavrsi run!
		exit
	endif
enddo

CLOSE ALL

return



 
function pos_main_menu_level(KLevel,Fx,Fy)

do case
	case ((KLevel==L_ADMIN).or.(KLevel==L_SYSTEM))
        	pos_main_menu_admin()
        case (KLevel==L_UPRAVN)
        	if !CRinitDone
          		Msg("NIJE UNIJETO POCETNO STANJE SMJENE!!!", 10)
       		endif
       		SETPOS(Fx, Fy)
       		pos_main_menu_upravnik()
        case (KLevel==L_PRODAVAC)
            if gVrstaRS<>"S"
          		SETPOS(Fx,Fy)
          		pos_main_menu_prodavac()
       		else
          		MsgBeep("Na serveru ne mozete izdavati racune")
       		endif
endcase

return

// ------------------------------------------------------
// ------------------------------------------------------
method srv()

? "Pokrecem POS: Applikacion server"

if (mpar37("/IMPROBA",goModul))
	if LEFT(self:cP5,3)=="/S="
		AzurSifIzFmk(nil, .t., SUBSTR(self:cP5,4))
		goModul:quit()
	endif
endif

if (mpar37("/REAL2KALK", goModul))
	altd()

	if (LEFT(self:cP5,4)=="/D1=" .and. LEFT(self:cP6,4)=="/D2=")
		// automatski prenos real.u KALK
		// (D1, D2)
		AutoReal2Kalk(SUBSTR(self:cP5,5), SUBSTR(self:cP6,5))
		goModul:quit()
	endif
endif

if (mpar37("/REK2KALK", goModul))
	altd()

	if (LEFT(self:cP5,4)=="/D1=" .and. LEFT(self:cP6,4)=="/D2=")
		// automatski prenos rekl.u KALK
		// (D1, D2)
		AutoRek2Kalk(SUBSTR(self:cP5,5), SUBSTR(self:cP6,5))
		goModul:quit()
	endif
endif

return


// -------------------------------------------
// -------------------------------------------
method setScreen()

SetNaslov(self)
NaslEkran(.t.)

return


function pos_pdv_parametri()
O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
RPar("PD",@gPDV)
lSql:=.f.
if gSQL=="D"
	lSql := .t.
	gSQL:="N"
endif
ParPDV()
WPar("PD",gPDV)
if lSql
	gSQL:="D"
endif

if goModul:oDataBase:cRadimUSezona == "RADP"
	SetPDVBoje()
endif

return




// ---------------------------------------------
// ---------------------------------------------
method setGVars()

set_global_vars()
set_roba_global_vars()

//SetFmkRGVars()
//SetFmkSGVars()

pos_pdv_parametri()

// gPrevIdPos - predhodna vrijednost gIdPos
public gPrevIdPos:="  "

public gOcitBarcod:=.f.
public gSmijemRaditi:='D'
public gSamoProdaja:='N'
public gZauzetSam:='N'

// sifra radnika
public gIdRadnik        
// prezime i ime korisnika (iz OSOB)
public gKorIme          

// status radnika
public gSTRAD           

// identifikator seta cijena koji se
public gIdCijena:="1"   
public gPopust:=0
public gPopDec:=1
public gPopZcj:="N"
public gPopVar:="P"
public gPopProc:="N"
public gPopIzn:=0
public gPopIznP:=0
public SC_Opisi[5]      // nazivi (opisi) setova cijena
public gSmjena := " "   // identifikator smjene
public gDatum           // datum
public gStolovi := "N"
public gVodiTreb        // da li se vode trebovanja (ako se vode, onda se i
                        // stampaju)
public gVodiOdj
public gRadniRac        // da li se koristi princip radnih racuna ili se
                        // racuni furaju kao u trgovini
public gDupliArt        // da li dopusta unos duplih artikala na racunu
public gDupliUpoz       // ako se dopusta, da li se radnik upozorava na duple

public gDirZaklj        // ako se ne koristi princip radnih racuna, da li se
                        // racuni zakljucuju odmah po unosu stavki
public gBrojSto         // da li je broj stola obavezan
                        // D-da, N-ne, 0-uopce se ne vodi
public gPoreziRaster    // da li se porezi stampaju pojedinacno ili
                        // zbirno
public gPratiStanje     // da li se prati stanje zaliha robe na
                        // prodajnim mjestima
public gPocStaSmjene    // da li se uvodi pocetno stanje smjene
                        // (da li se radnicima dodjeljuju pocetna sredstva)
public gIdPos           // id prodajnog mjesta

public gIdDio           // id dijela objekta u kome je kasa locirana
                        // (ima smisla samo za HOPS)

public nFeedLines       // broj linija potrebnih da se racun otcijepi
public CRinitDone       // da li je uradjen init kase (na pocetku smjene)

public gDomValuta    
public gGotPlac         // sifra za gotovinsko (default) placanje
public gDugPlac

public gVrstaRS         // vrsta radne stanice
                        // ( K-kasa S-server A-samostalna kasa)
public gEvidPl          // evidentiranje podataka za vrste placanja CEK, SIND.KRED. i GARANTNO PISMO

public gDisplay  // koristiti ispis na COM DISPLAY

public gLocPort:="LPT1" // lokalni port za stampanje racuna

public gStamPazSmj      // da li se automatski stampa pazar smjene
                        // na kasi
public gStamStaPun      // da li se automatski stampa stanje
                        // nedijeljenih punktova koje kasa pokriva

public gRnSpecOpc  // HOPS - rn specificne opcije
public gSjeciStr:=""
public gOtvorStr:=""
public gVSmjene:="N"
public gSezonaTip:="M"
public gSifUpravn:="D"
public gEntBarCod:="D"
public gSifUvPoNaz:="N" // sifra uvijek po nazivu

public gPosNaz
public gDioNaz
public gRnHeder:="RacHeder.TXT"
public gRnFuter:="RacPodn.TXT "
public gZagIz:="1;2;"
public gColleg:="N"
public gDuplo:="N"
public gDuploKum:=""
public gDuploSif:=""
public gFmkSif:=""
public gRNALSif := ""
public gRNALKum := ""

public gOperSys := PADR("XP", 10)
public gDuzSifre := 13

// postavljanje globalnih varijabli
public gLocPort:="LPT1"
public gIdCijena:="1"
public gsOsInfo:="win98"
public gDiskFree:="N"
public grbCjen:=2
public grbStId:="D"
public grbReduk:=0
public gRnInfo:="N"

#ifdef CLIP
	return
#endif

self:cName:=IzFmkIni("POS","MODUL","TOPS",KUMPATH)
gModul:=self:cName

gKorIme:=""
gIdRadnik:=""
gStRad:=""

//SetNaslov(self)
//NaslEkran(.t.)
ToggleIns()
ToggleIns()

SC_Opisi [1] := "1"
SC_Opisi [2] := "2"
SC_Opisi [3] := "3"
SC_Opisi [4] := "4"
SC_Opisi [5] := "5"

gDatum:=DATE()

public gIdCijena:= "1"
public gPopust:= 0
public gPopDec:= 1
public gPopVar:= "P"
public gPopZcj:= "N"
public gZadCij:= "N"
public gPopProc:= "N"
public gIsPopust:=.f.

public gKolDec
gKolDec:=INT(VAL(IzFmkIni("TOPS","KolicinaDecimala","2",KUMPATH)))
public gCijDec
gCijDec:=INT(VAL(IzFmkIni("TOPS","CijenaDecimala","2",KUMPATH)))

public gStariObrPor
if IzFmkIni("POS","StariObrPor","N",EXEPATH)=="D"
	gStariObrPor:=.t.
else
	gStariObrPor:=.f.
endif

public gClanPopust
if IzFmkIni("TOPS","Clanovi","N",PRIVPATH)=="D"
	gClanPopust:=.t.
else
	gClanPopust:=.f.
endif

public gPoreziRaster:="D"
public gPratiStanje:="N"
public gIdPos:="1 "
public gPostDO:="N"
public gIdDio:="  "

public nFeedLines:=6
public gPocStaSmjene:="N"
public gStamPazSmj:="D"
public gStamStaPun:="D"
public CRinitDone:=.t.
public gVrstaRS:="A"
public gEvidPl:="N"

public gGotPlac:="01"
public gDugPlac:="DP"

public gSifPath:=SIFPATH
public LocSIFPATH:=SIFPATH
public gServerPath

gServerPath:=PADR(ToUnix("i:\sigma",40))

public gKalkDEST
gKalkDEST:=PADR(ToUnix("a:\",20))

public gModemVeza:="N"
public gUseChkDir:="N"
public gStrValuta:=space(4)
// upit o nacinu placanja
public gUpitNp := "N"  


// podaci kase - zaglavlje
public gFirNaziv := SPACE(35)
public gFirAdres := SPACE(35)
public gFirIdBroj := SPACE(13)
public gFirPM := SPACE(35)
public gRnMjesto := SPACE(20)
public gPorFakt := "N"
public gRnPTxt1 := SPACE(35)
public gRnPTxt2 := SPACE(35)
public gRnPTxt3 := SPACE(35)
public gFirTel := SPACE(20)

// fiskalni parametri
public gFc_type := SPACE(20)
public gFc_device := "P"
public gFc_path := SPACE(100)
public gFc_path2 := SPACE(100)
public gFc_name := SPACE(11)
public gFc_answ := PADR("ANSWER.TXT", 40)
public gFc_serial := PADR("010001", 15)
public gFc_error := "D"
public gFc_use := "N"
public gFc_cmd := SPACE(100)
public gFc_cp1 := SPACE(100)
public gFc_cp2 := SPACE(100)
public gFc_cp3 := SPACE(100)
public gFc_cp4 := SPACE(100)
public gFc_cp5 := SPACE(100)
public gIOSA := SPACE(16)
public gFc_konv := "5"
public gFc_tout := 300
public gFc_txrn := "N"
public gFc_acd := "D"
public gFc_alen := 32
public gFc_nftxt := "N"
public gFc_pdv := "D"
public gFc_pinit := 10
public gFC_chk := "1"
public gFC_pauto := 0
public gFC_dlist := "N"
public gFc_restart := "N"

if gModul=="HOPS"
	gVodiTreb:="D"
	gVodiOdj:="D"
	gBrojSto:="0"
	gRnSpecOpc:="N"
	gRadniRac:="D"
	gDirZaklj:="N"
	gDupliArt:="N"
	gDupliUpoz:="D"
	gDisplay:="N"
else
	gVodiTreb:="N"
	gVodiOdj:="N"
	gBrojSto:="0"
	gRnSpecOpc:="N"
	gRadniRac:="N"
	gDirZaklj:="D"
	gDupliArt:="D"
	gDupliUpoz:="N"
	gDisplay:="N"
endif

O_PARAMS
private cSection:="F"
private cHistory:=" "
private aHistory:={}

Rpar("f1",@gFc_type)
Rpar("f2",@gFc_path)
Rpar("f3",@gFc_name)
Rpar("f4",@gFc_use)
Rpar("f5",@gFc_cmd)
Rpar("f6",@gFc_cp1)
Rpar("f7",@gFc_cp2)
Rpar("f8",@gFc_cp3)
Rpar("f9",@gFc_cp4)
Rpar("f0",@gFc_cp5)
Rpar("fE",@gFc_error)
Rpar("fI",@gIOSA)
Rpar("fK",@gFc_konv)
Rpar("fT",@gFc_tout)
Rpar("fP",@gFc_txrn)
Rpar("fC",@gFc_acd)
Rpar("fR",@gFc_alen)
Rpar("fN",@gFc_nftxt)
Rpar("fO",@gFc_pdv)
Rpar("fD",@gFc_device)
Rpar("fZ",@gFc_pinit)
Rpar("fX",@gFc_chk)
Rpar("fS",@gFc_path2)
Rpar("fA",@gFc_pauto)
Rpar("fB",@gFc_answ)
Rpar("fY",@gFc_serial)
Rpar("fG",@gFc_restart)

O_PARAMS
private cSection:="1"
private cHistory:=" "
private aHistory:={}

Rpar("F1",@gFirNaziv)
Rpar("F2",@gFirAdres)
Rpar("F3",@gFirIdBroj)
Rpar("F4",@gFirPM)
Rpar("F5",@gRnMjesto)
Rpar("F6",@gFirTel)
Rpar("F7",@gRnPTxt1)
Rpar("F8",@gRnPTxt2)
Rpar("F9",@gRnPTxt3)
Rpar("pF",@gPorFakt)
//

Rpar("n8",@gVrstaRS)
Rpar("na",@gIdPos)
Rpar("PD",@gPostDO)
Rpar("DO",@gIdDio)
Rpar("n9",@gServerPath)
Rpar("kT",@gKalkDest)
Rpar("Mv",@gModemVeza)
Rpar("Mc",@gUseChkDir)
Rpar("sV",@gStrValuta)
Rpar("n0",@gLocPort)
Rpar("n7",@gGotPlac)
Rpar("nX",@gDugPlac)
Rpar("rI",@gRnInfo)

gServerPath := AllTrim(gServerPath)
if (RIGHT(gServerPath,1) <> SLASH)
	gServerPath+=SLASH
endif

// principi rada kase
cPrevPSS := gPocStaSmjene

Rpar("n2",@gVodiTreb)
Rpar("zc",@gZadCij)
Rpar("vO",@gVodiOdj)
Rpar("vS",@gStolovi)
Rpar("RR",@gRadniRac)
Rpar("Dz",@gDirZaklj)
Rpar("sO",@gRnSpecOpc)
Rpar("BS",@gBrojSto)
Rpar("n5",@gDupliArt)
Rpar("Nu",@gDupliUpoz)
Rpar("Ns",@gPratiStanje)
Rpar("nh",@gPocStaSmjene)
Rpar("nj",@gStamPazSmj)
Rpar("nk",@gStamStaPun)
Rpar("vs",@gVsmjene)
Rpar("ST",@gSezonaTip)
Rpar("Si",@gSifUpravn)
Rpar("Sx",@gDisplay)
Rpar("Bc",@gEntBarCod)
Rpar("Ep",@gEvidPl)
Rpar("UN",@gSifUvPoNaz)
Rpar("dF",@gDiskFree)

if IsPlanika()
	gPratiStanje := "D"
endif

// izgled racuna
gSjecistr:=padr(GETPStr(gSjeciStr),20)
gOtvorstr:=padr(GETPStr(gOtvorStr),20)
Rpar("n4",@gPoreziRaster)
Rpar("n6",@nFeedLines)
Rpar("sS",@gSjeciStr)
Rpar("oS",@gOtvorStr)
gSjeciStr:=Odsj(@gSjeciStr)
gOtvorStr:=Odsj(@gOtvorStr)

Rpar("zI",@gZagIz)
Rpar("RH",@gRnHeder)
Rpar("RF",@gRnFuter)

// izgled racuna
Rpar("Ra",@grbCjen)
Rpar("Rb",@grbStId)
Rpar("Rc",@grbReduk)

// cijene
Rpar("nb",@gIdCijena)
Rpar("pP",@gPopust)
Rpar("pd",@gPopDec)
Rpar("pV",@gPopVar)
Rpar("pC",@gPopZCj)
Rpar("pO",@gPopProc)
Rpar("pR",@gPopIzn)
Rpar("pS",@gPopIznP)

Rpar("Co",@gColleg)
Rpar("Du",@gDuplo)
Rpar("D7",@gDuploKum)
Rpar("D8",@gDuploSif)
Rpar("D9",@gFmkSif)
Rpar("gS",@gRNALSif)
Rpar("gK",@gRNALKum)

Rpar("gB",@gDuzSifre)
Rpar("gX",@gOperSys)

cPom:=SC_Opisi[1]
Rpar("nc",@cPom)
SC_Opisi[1]:=cPom

cPom:=SC_Opisi[2]
Rpar("nd",@cPom)
SC_Opisi[2]:=cPom

cPom:=SC_Opisi[3]
Rpar("ne",@cPom)
SC_Opisi[3]:=cPom

cPom:=SC_Opisi[4]
Rpar("nf",@cPom)
SC_Opisi[4]:=cPom

cPom:=SC_Opisi[5]
Rpar("ng",@cPom)
SC_Opisi[5]:=cPom

Rpar("np",@gUpitNp)

SELECT params
USE

RELEASE cSection,cHistory,aHistory

public gStela
gStela:=CryptSC(IzFmkIni("KL","PregledRacuna",CryptSC("STELA"),KUMPATH))
public gPVrsteP
gVrsteP:=IzFMKIni("TOPS","AzuriranjePrometaPoVP","N",KUMPATH)=="D"


if (gVrstaRS=="S")
	gIdPos:=Space(LEN(gIdPos))
endif

public gSQLKom
gSQL:=IzFmkIni("Svi","SQLLog","N",KUMPATH)
gSamoProdaja:=IzFmkIni("TOPS","SamoProdaja","N",PRIVPATH)
gSQLLogBase:=IzFmkIni("SQL","SQLLogBase","c:\sigma",EXEPATH)


public gPosSirovine
public gPosKalk

public gSQLSynchro
public gPosModem

public glRetroakt

glRetroakt:=(IzFmkIni("POS","Retroaktivno","N",KUMPATH)=="D")

// varijable FISSTA
public gFisCTTPath
gFisCTTPath:=(IzFmkIni("FISSTA","FisCTTPath","c:\tops",EXEPATH))
public gFisTimeOut
gFisTimeOut:=VAL((IzFmkIni("FISSTA","FisTimeOut","5",EXEPATH)))
public gFisStorno
gFisStorno:=(IzFmkIni("FISSTA","FisStorno","N",EXEPATH))
public gFissta
gFissta:=(IzFmkIni("FISSTA", "Fissta", "N", EXEPATH))
public gFisRptEvid
gFisRptEvid:=(IzFmkIni("FISSTA", "FisRptEvid", "N", EXEPATH))
public gFisConStr
gFisConStr:=(IzFmkIni("FISSTA", "CmdKonekcija", "0_1", EXEPATH))

gPosSirovine:="D"
gPosKalk:="D"

gSQLSynchro:="D"
gPosModem:="D"



public glPorezNaSvakuStavku

glPorezNaSvakuStavku:=(IzFmkIni("POS","PorezNaSvakuStavku","D",PRIVPATH)=="D")

public glPorNaSvStRKas
glPorNaSvStRKas:=(IzFmkIni("POS","PorezNaSvStRealKase","N",PRIVPATH)=="D")

if (!self:oDatabase:lAdmin .and. gVrstaRS<>"S")
	O_KASE
  	set order to tag "ID"
  	HSEEK gIdPos
  	if FOUND()
		gPosNaz:=AllTrim(KASE->Naz)
  	else
   		gPosNaz:="SERVER"
  	endif
  	O_DIO
  	set order to tag "ID"
  	HSEEK gIdDio
  	if FOUND()
  		gDioNaz := AllTrim (DIO->Naz)
  	else
  		gDioNaz:=""
  	endif
  	close all
endif

//  odredi naziv domace valute
if (!self:oDatabase:lAdmin) 
	SetNazDVal()
	if IsPlanika()	
		chkTblPromVp()
	endif
endif

SetBoje(gVrstaRS)

return



