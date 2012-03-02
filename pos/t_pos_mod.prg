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

	if (LEFT(self:cP5,4)=="/D1=" .and. LEFT(self:cP6,4)=="/D2=")
		// automatski prenos real.u KALK
		// (D1, D2)
		AutoReal2Kalk(SUBSTR(self:cP5,5), SUBSTR(self:cP6,5))
		goModul:quit()
	endif
endif

if (mpar37("/REK2KALK", goModul))

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

f18_get_metric("PDVGlobal", @gPDV )

lSql := .f.
if gSQL == "D"
	lSql := .t.
	gSQL := "N"
endif

ParPDV()

f18_set_metric("PDVGlobal", gPDV )

if lSql
	gSQL := "D"
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

self:cName := "TOPS"
gModul := self:cName

gKorIme:=""
gIdRadnik:=""
gStRad:=""

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

gServerPath := PADR(ToUnix("i:\sigma",40))

public gKalkDEST
gKalkDEST := PADR(ToUnix("a:\",20))

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

// parametri fiskalnog uredjaja
public gFc_type, gFc_device, gFc_use, gFc_path, gFc_path2, gFc_name, gFc_answ, gFc_pitanje, gFc_error
public gFc_fisc_print, gFc_operater, gFc_oper_pwd, gFc_tout, gIosa, gFc_alen, gFc_nftxt, gFc_acd, gFc_pdv
public gFc_pinit, gFc_chk, gFc_faktura, gFc_zbir, gFc_dlist, gFc_pauto, gFc_serial, gFc_restart

// fiskalni parametri
gVodiTreb:="N"
gVodiOdj:="N"
gBrojSto:="0"
gRnSpecOpc:="N"
gRadniRac:="N"
gDirZaklj:="D"
gDupliArt:="D"
gDupliUpoz:="N"
gDisplay:="N"

// procitaj fiskalne parametre
fiscal_params_read()

// citaj parametre iz metric tabele
f18_get_metric("RacunNaziv",@gFirNaziv)
f18_get_metric("RacunAdresa",@gFirAdres)
f18_get_metric("RacunIdBroj",@gFirIdBroj)
f18_get_metric("RacunProdajnoMjesto",@gFirPM)
f18_get_metric("RacunMjestoNastankaRacuna",@gRnMjesto)
f18_get_metric("RacunTelefon",@gFirTel)
f18_get_metric("RacunDodatniTekst1",@gRnPTxt1)
f18_get_metric("RacunDodatniTekst2",@gRnPTxt2)
f18_get_metric("RacunDodatniTekst3",@gRnPTxt3)
f18_get_metric("StampatiPoreskeFakture",@gPorFakt)
f18_get_metric("VrstaRadneStanice",@gVrstaRS)
f18_get_metric("IDPos",@gIdPos)
f18_get_metric("ZasebneCjelineObjekta",@gPostDO)
f18_get_metric("OznakaDijelaObjekta",@gIdDio)
f18_get_metric("PutanjaServera",@gServerPath)
f18_get_metric("KalkDestinacija",@gKalkDest)
f18_get_metric("ModemskaVeza",@gModemVeza)
f18_get_metric("KoristitiDirektorijProvjere",@gUseChkDir)
f18_get_metric("StranaValuta",@gStrValuta)
f18_get_metric("OznakaLokalnogPorta",@gLocPort)
f18_get_metric("OznakaGotovinskogPlacanja",@gGotPlac)
f18_get_metric("OznakaDugPlacanja",@gDugPlac)
f18_get_metric("RacunInfo",@gRnInfo)

gServerPath := AllTrim(gServerPath)
if (RIGHT(gServerPath,1) <> SLASH)
	gServerPath += SLASH
endif

// principi rada kase
cPrevPSS := gPocStaSmjene

f18_get_metric("VodiTrebovanja",@gVodiTreb)
f18_get_metric("AzuriranjeCijena",@gZadCij)
f18_get_metric("VodiOdjeljenja",@gVodiOdj)
f18_get_metric("Stolovi",@gStolovi)
f18_get_metric("RadniRacuni",@gRadniRac)
f18_get_metric("DirektnoZakljucivanjeRacuna",@gDirZaklj)
f18_get_metric("RacunSpecifOpcije",@gRnSpecOpc)
f18_get_metric("BrojStolova",@gBrojSto)
f18_get_metric("DupliArtikli",@gDupliArt)
f18_get_metric("DupliUnosUpozorenje",@gDupliUpoz)
f18_get_metric("PratiStanjeRobe",@gPratiStanje)
f18_get_metric("PratiPocetnoStanjeSmjene",@gPocStaSmjene)
f18_get_metric("StampanjePazara",@gStamPazSmj)
f18_get_metric("StampanjePunktova",@gStamStaPun)
f18_get_metric("VoditiPoSmjenama",@gVsmjene)
f18_get_metric("TipSezone",@gSezonaTip)
f18_get_metric("UpravnikIspravljaCijene",@gSifUpravn)
f18_get_metric("DisplejOpcije",@gDisplay)
f18_get_metric("BarkodEnter",@gEntBarCod)
f18_get_metric("EvidentiranjeVrstaPlacanja",@gEvidPl)
f18_get_metric("PretragaArtiklaPoNazivu",@gSifUvPoNaz)
f18_get_metric("SlobodniProstorDiska",@gDiskFree)

if IsPlanika()
	gPratiStanje := "D"
endif

// izgled racuna
gSjecistr := padr( GETPStr( gSjeciStr ), 20 )
gOtvorstr := padr( GETPStr( gOtvorStr ), 20 )

f18_get_metric("PorezniRaster",@gPoreziRaster)
f18_get_metric("BrojLinijaZaKrajRacuna",@nFeedLines)
f18_get_metric("SekvencaSjeciTraku",@gSjeciStr)
f18_get_metric("SekvencaOtvoriLadicu",@gOtvorStr)

gSjeciStr := Odsj( @gSjeciStr )
gOtvorStr := Odsj( @gOtvorStr )

f18_get_metric("IzgledZaglavlja",@gZagIz)
f18_get_metric("RacunHeader",@gRnHeder)
f18_get_metric("RacunFooter",@gRnFuter)

// izgled racuna
f18_get_metric("RacunCijenaSaPDV",@grbCjen)
f18_get_metric("RacunStampaIDArtikla",@grbStId)
f18_get_metric("RacunRedukcijaTrake",@grbReduk)

// cijene
f18_get_metric("SetCijena",@gIdCijena)
f18_get_metric("Popust",@gPopust)
f18_get_metric("PopustDecimale",@gPopDec)
f18_get_metric("PopustVarijanta",@gPopVar)
f18_get_metric("PopustZadavanjemCijene",@gPopZCj)
f18_get_metric("PopustProcenat",@gPopProc)
f18_get_metric("PopustIznos",@gPopIzn)
f18_get_metric("PopustVrijednostProcenta",@gPopIznP)

f18_get_metric("PodesenjeNonsense",@gColleg)
f18_get_metric("AzurirajUPomocnuBazu",@gDuplo)
f18_get_metric("KumulativPomocneBaze",@gDuploKum)
f18_get_metric("SifrarnikPomocneBaze",@gDuploSif)
f18_get_metric("FMKSifrarnik",@gFmkSif)
f18_get_metric("RNALSifrarnik",@gRNALSif)
f18_get_metric("RNALKumulativ",@gRNALKum)

f18_get_metric("DuzinaSifre",@gDuzSifre)
f18_get_metric("OperativniSistem",@gOperSys)

f18_get_metric("UpitZaNacinPlacanja",@gUpitNp)

public gStela
gStela:=CryptSC(IzFmkIni("KL","PregledRacuna",CryptSC("STELA"),KUMPATH))

public gPVrsteP := .f.
f18_get_metric("AzuriranjePrometaPoVP", @gPVrsteP)

if (gVrstaRS=="S")
	gIdPos := Space(LEN(gIdPos))
endif

public gSQLKom
gSQL := IzFmkIni("Svi","SQLLog","N",KUMPATH)
gSQLLogBase := IzFmkIni("SQL","SQLLogBase","c:\sigma",EXEPATH)

f18_get_metric("SamoProdaja", @gSamoProdaja)

public gPosSirovine
public gPosKalk

public gSQLSynchro
public gPosModem

public glRetroakt

glRetroakt:=(IzFmkIni("POS","Retroaktivno","N",KUMPATH)=="D")

gPosSirovine:="D"
gPosKalk:="D"
gSQLSynchro:="D"
gPosModem:="D"

public glPorezNaSvakuStavku := .f.
public glPorNaSvStRKas := .f.

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
endif

SetBoje(gVrstaRS)

return


