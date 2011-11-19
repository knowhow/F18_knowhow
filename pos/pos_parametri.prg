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


function pos_parametri()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. podaci kase                    ")
AADD(opcexe,{|| pos_param_podaci_kase()})
AADD(opc,"2. principi rada")
AADD(opcexe,{|| pos_param_principi_rada()})
AADD(opc,"3. izgled racuna")
AADD(opcexe,{|| pos_param_izgled_racuna()})
AADD(opc,"4. cijene")
AADD(opcexe,{|| pos_param_cijene()})
AADD(opc,"5. postavi vrijeme i datum kase")
AADD(opcexe,{|| pos_postavi_datum()})
AADD(opc,"6. podaci firme")
AADD(opcexe,{|| pos_param_firma()})
AADD(opc,"7. fiskalni parametri")
AADD(opcexe,{|| pos_param_fiscal()})

Menu_SC("par")
return .f.



/*! \fn pos_param_podaci_kase()
 *  \brief Podesavanje osnovnih podataka o kasi
 */

function pos_param_podaci_kase()
local aNiz:={}
local cPom:=""

private cIdPosOld:=gIdPos
private cHistory:=" "
private aHistory:={}
private cSection:="1"

gServerPath := padr(gServerPath,40)
gKalkDest := padr(gKalkDest,40)
gDuploKum := padr(gDuploKum,30)
gDuploSif := padr(gDuploSif,30)
gFMKSif := padr(gFmkSif,30)
gRNALSif := padr(gRNALSif,100)
gRNALKum := padr(gRNALKum,100)

set cursor on

AADD(aNiz,{"Vrsta radne stanice (K-kasa, A-samostalna kasa, S-server)" , "gVrstaRS", "gVrstaRS$'KSA'", "@!", })
AADD(aNiz,{"Oznaka/ID prodajnog mjesta" , "gIdPos", "NemaPrometa(cIdPosOld,gIdPos)", "@!", })

if gModul=="HOPS" 
	AADD(aNiz,{"Ima li objekat zasebne cjeline (dijelove) D/N", "gPostDO","gPostDO$'DN'", "@!", })
  	AADD(aNiz,{"Oznaka/ID dijela objekta", "gIdDio",, "@!", })
endif

AADD(aNiz,{"Putanja korijenskog direktorija modula na serveru" , "gServerPath", , , })
AADD(aNiz,{"Destinacija datoteke TOPSKA" , "gKALKDEST", , , })
AADD(aNiz,{"Razmjena podataka, koristi se modemska veza D/N", "gModemVeza","gModemVeza$'DN'", "@!", })
AADD(aNiz,{"Razmjena podataka, koristiti 'chk' direktorij D/N", "gUseChkDir","gUseChkDir$'DN'", "@!", })
AADD(aNiz,{"Lokalni port za stampu racuna" , "gLocPort", , , })
AADD(aNiz,{"Oznaka/ID gotovinskog placanja" , "gGotPlac",, "@!", })
AADD(aNiz,{"Oznaka/ID placanja duga       " , "gDugPlac",, "@!", })
AADD(aNiz,{"Oznaka strane valute" , "gStrValuta",, "@!", })
AADD(aNiz,{"Podesenja nonsens D/N" , "gColleg",, "@!", })
AADD(aNiz,{"Azuriraj u pomocnu bazu" , "gDuplo",, "@!", "gDuplo$'DN'"})
AADD(aNiz,{"Direktorij kumulativa za pom bazu","gDuploKum",, "@!",})
AADD(aNiz,{"Direktorij sifrarnika za pom bazu","gDuplosif",, "@!",})
AADD(aNiz, {"Direktorij sifrarnika FMK        ","gFMKSif",, "@!",})
AADD(aNiz, {"Duzina sifre artikla u unosu","gDuzSifre",, "99",})
AADD(aNiz, {"Operativni sistem","gOperSys",, "@!",})

VarEdit(aNiz,2,2,24,78,"PARAMETRI RADA PROGRAMA - PODACI KASE","B1")

// Upisujem nove parametre
if LASTKEY()<>K_ESC
	MsgO("Azuriram parametre PZ")
    	f18_set_metric("VrstaRadneStanice",gVrstaRS )
    	f18_set_metric("IDPos",gIdPos )
    	f18_set_metric("ZasebneCjelineObjekta",gPostDO )
    	f18_set_metric("OznakaDijelaObjekta",gIdDio )
    	f18_set_metric("PutanjaServera",gServerPath )     // pathove ne diraj
    	f18_set_metric("KalkDestinacija",gKalkDest )       // pathove ne diraj
    	f18_set_metric("ModemskaVeza",gModemVeza )
    	f18_set_metric("KoristitiDirektorijProvjere",gUseChkDir ) // koristi chk direktorij
    	f18_set_metric("OznakaLokalnogPorta",gLocPort )
    	f18_set_metric("OznakaGotovinskogPlacanja",gGotPlac )
    	f18_set_metric("OznakaDugPlacanja",gDugPlac )
    	f18_set_metric("StranaValuta",gStrValuta )
    	f18_set_metric("PodesenjaNonsens",gColleg )
    	f18_set_metric("AzurirajUPomocnuBazu",gDuplo )
    	f18_set_metric("KumulativPomocneBaze",trim(gDuploKum) ) // pathove ne diraj
    	f18_set_metric("SifrarnikPomocneBaze",trim(gDuploSif) ) // pathove ne diraj
    	f18_set_metric("FMKSifrarnik",trim(gFmkSif) )   // pathove ne diraj
    	f18_set_metric("RNALSifrarnik",trim(gRNALSif) )   // pathove ne diraj
    	f18_set_metric("RNALKumulativ",trim(gRNALKum) )   // pathove ne diraj
    	f18_set_metric("DuzinaSifre",gDuzSifre )
    	f18_set_metric("OperativniSistem",gOperSys )
    	MsgC()
endif

gServerPath := ALLTRIM(gServerPath)

if (RIGHT(gServerPath,1) <> SLASH)
	gServerPath += SLASH
endif

return



function pos_param_fiscal()
local aNiz:={}
local cPom:=""

set cursor on

AADD(aNiz,{"PDV obveznik", "gFc_pdv", , "@!", })

AADD(aNiz,{"Tip fiskalne kase", "gFc_type", , "@S20", })
AADD(aNiz,{"[K] kasa-printer [P] printer ?", "gFc_device", , "@!", })
AADD(aNiz,{"IOSA broj", "gIOSA", , "@S16", })
AADD(aNiz,{"serijski broj", "gFc_serial", , "@S10", })

AADD(aNiz,{"Putanja izl.fajla", "gFc_path", , "@S50", })
AADD(aNiz,{"Sekundarna putanja", "gFc_path2", , "@S50", })
AADD(aNiz,{"Naziv izl.fajla", "gFc_name", , "@S20", })
AADD(aNiz,{"Naziv odgovora", "gFc_answ", , "@S20", })

AADD(aNiz,{"Provjera greske kod prodaje", "gFc_error", , "@!", })
AADD(aNiz,{"Timeout fiskalnih operacija", "gFc_tout", , "9999", })

AADD(aNiz,{"'kod' artikla je (I)Id, (P/D)Plu, (B)Barkod", "gFc_acd", , "@!", })
AADD(aNiz,{"inicijalni PLU", "gFc_pinit", , "99999", })
AADD(aNiz,{"Duzina naziva artikla", "gFc_alen", , "99", })

AADD(aNiz,{"Konverzija znakova", "gFc_konv", , "@!", })

AADD(aNiz,{"Provjera kolicina, cijena (1/2)", "gFc_chk", ,"@!", })
AADD(aNiz,{"Stampati i pos racun ?", "gFc_txrn", ,"@!", })
AADD(aNiz,{"Stampati broj dokumenta ?", "gFc_nftxt", ,"@!", })
AADD(aNiz,{"Automatski polog", "gFc_pauto", ,"999999.99", })
AADD(aNiz,{"Restart server (D/N)?", "gFc_restart", ,"@!", })

AADD(aNiz,{"Koristiti fiskalne funkcije", "gFc_use", ,"@!", })

VarEdit(aNiz,2,2,24,78,"Fiskalni parametri","B1")

// Upisujem nove parametre
if LASTKEY()<>K_ESC
		
		MsgO("Azuriram parametre PZ")
    	
		f18_set_metric("FiscalTipUredjaja",gFc_type )
    	f18_set_metric("FiscalLokacijaFajla",gFc_path )
    	f18_set_metric("FiscalImeFajla",gFc_name )
    	f18_set_metric("FiscalAktivan",gFc_use )
    	f18_set_metric("FiscalCmd",gFc_cmd )
    	f18_set_metric("FiscalCmdPar1",gFc_cp1 )
    	f18_set_metric("FiscalCmdPar2",gFc_cp2 )
    	f18_set_metric("FiscalCmdPar3",gFc_cp3 )
    	f18_set_metric("FiscalCmdPar4",gFc_cp4 )
    	f18_set_metric("FiscalCmdPar5",gFc_cp5 )
    	f18_set_metric("FiscalProvjeraGreske",gFc_error )
    	f18_set_metric("FiscalIOSABroj",gIOSA )
    	f18_set_metric("FiscalKonverzijaZnakova",gFc_konv )
    	f18_set_metric("FiscalTimeOut",gFc_tout )
    	f18_set_metric("FiscalStampatiRacun",gFc_txrn )
    	f18_set_metric("FiscalPluDinamicki",gFc_acd )
    	f18_set_metric("FiscalPluDuzina",gFc_alen )
    	f18_set_metric("FiscalStampatiBrojDokumenta",gFc_nftxt )
    	f18_set_metric("FiscalPDVObveznik",gFc_pdv )
    	f18_set_metric("FiscalListaUredjaja",gFc_device )
    	f18_set_metric("FiscalInicijalniPlu",gFc_pinit )
    	f18_set_metric("FiscalProvjeraPodataka",gFc_chk )
    	f18_set_metric("FiscalLokacijaFajla2",gFc_path2 )
    	f18_set_metric("FiscalAutomatskiPolog",gFc_pauto )
    	f18_set_metric("FiscalImeFajlaOdgovora",gFc_answ )
    	f18_set_metric("FiscalSerijskiBroj",gFc_serial )
    	f18_set_metric("FiscalRestartServera",gFc_restart )
    	
		MsgC()

endif

return




function pos_param_firma()
local aNiz:={}
local cPom:=""

gFirIdBroj := PADR(gFirIdBroj, 13)

set cursor on

AADD(aNiz,{"Puni naziv firme", "gFirNaziv", , , })
AADD(aNiz,{"Adresa firme", "gFirAdres", , , })
AADD(aNiz,{"Telefoni", "gFirTel", , , })
AADD(aNiz,{"ID broj", "gFirIdBroj", , , })
AADD(aNiz,{"Prodajno mjesto" , "gFirPM", , , })
AADD(aNiz,{"Mjesto nastanka racuna", "gRnMjesto" , , , })
AADD(aNiz,{"Pomocni tekst racuna - linija 1:", "gRnPTxt1", , , })
AADD(aNiz,{"Pomocni tekst racuna - linija 2:", "gRnPTxt2", , , })
AADD(aNiz,{"Pomocni tekst racuna - linija 3:", "gRnPTxt3", , , })

VarEdit(aNiz,7,2,24,78,"PODACI FIRME I RACUNA","B1")

// Upisujem nove parametre
if LASTKEY()<>K_ESC

		MsgO("Azuriram parametre PZ")

    	f18_set_metric("RacunNaziv",gFirNaziv )
    	f18_set_metric("RacunAdresa",gFirAdres )
    	f18_set_metric("RacunIdBroj",gFirIdBroj )
    	f18_set_metric("RacunProdajnoMjesto",gFirPM )
    	f18_set_metric("RacunMjestoNastankaRacuna",gRnMjesto )
    	f18_set_metric("RacunTelefon",gFirTel )
    	f18_set_metric("RacunDodatniTekst1",gRnPTxt1 )
    	f18_set_metric("RacunDodatniTekst2",gRnPTxt2 )
    	f18_set_metric("RacunDodatniTekst3",gRnPTxt3 )
    	
		MsgC()

endif

return


// principi rada kase
function pos_param_principi_rada()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. osnovna podesenja              ")
AADD(opcexe,{|| ParPrBase()})

if gModul=="HOPS"
	AADD(opc,"2. podesenja - ugostiteljstvo   ")
	AADD(opcexe,{|| ParPrUgost()})
endif

Menu_SC("prr")

return .f.



function ParPrUgost()
local aNiz:={}
local cPrevPSS
local cPom:=""
private cIdPosOld:=gIdPos

cPrevPSS:=gPocStaSmjene

set cursor on

aNiz:={{"Da li se vode trebovanja (D/N)" , "gVodiTreb", "gVodiTreb$'DN'", "@!", }}
AADD (aNiz, {"Da li se koriste radni racuni(D/N)" , "gRadniRac", "gRadniRac$'DN'", "@!", })
AADD (aNiz, {"Ako se ne koriste, da li se racun zakljucuje direktno (D/N)" , "gDirZaklj", "gDirZaklj$'DN'", "@!", })
AADD (aNiz, {"Da li je broj stola obavezan (D/N/0)", "gBrojSto", "gBrojSto$'DN0'", "@!", })
AADD (aNiz, {"Dijeljenje racuna, spec.opcije nad racunom (D/N)", "gRnSpecOpc", "gRnSpecOpc$'DN'", "@!", })
AADD (aNiz, {"Da li se po zakljucenju smjene stampa stanje puktova (D/N)" , "gStamStaPun", "gStamStaPun$'DN'", "@!", })

VarEdit(aNiz,2,2,24,79,"PARAMETRI RADA PROGRAMA - UGOSTITELJSTVO","B1")

if LASTKEY() <> K_ESC
		MsgO("Azuriram parametre")
    	f18_set_metric("VodiTrebovanja",gVodiTreb )
    	f18_set_metric("DirektnoZakljucivanjeRacuna",@gDirZaklj )
    	f18_set_metric("RacunSpecifOpcije",@gRnSpecOpc )
		f18_set_metric("RadniRacuni",@gRadniRac )
    	f18_set_metric("BrojStolova",@gBrojSto )
    	f18_set_metric("StampanjePunktova",@gStamStaPun )
    	MsgC()
endif

return



// --------------------------------------------
// osnovni prinicipi rada kase
// --------------------------------------------
function ParPrBase()
local aNiz:={}
local cPrevPSS
local cPom:=""
private cIdPosOld:=gIdPos

cPrevPSS:=gPocStaSmjene

set cursor on

aNiz:={}
AADD (aNiz, {"Da li se racun zakljucuje direktno (D/N)" , "gDirZaklj", "gDirZaklj$'DN'", "@!", })
AADD (aNiz, {"Dopustiti dupli unos artikala na racunu (D/N)" , "gDupliArt", "gDupliArt$'DN'", "@!", })
AADD (aNiz, {"Ako se dopusta dupli unos, da li se radnik upozorava(D/N)" , "gDupliUpoz", "gDupliUpoz$'DN'", "@!", })
AADD (aNiz, {"Da li u u objektu postoje odjeljenja (D/N)" , "gVodiodj", "gVodiOdj(@gVodiOdj)", "@!",})
AADD (aNiz, {"Da li se prati pocetno stanje smjene (D/N)" , "gPocStaSmjene", "gPocStaSmjene$'DN!'", "@!", })
AADD (aNiz, {"Da li se po zakljucenju smjene stampa ukupni pazar (D/N)" , "gStamPazSmj", "gStamPazSmj$'DN'", "@!", })
AADD (aNiz, {"Da li se prati stanje zaliha robe na prodajnim mjestima (D/N/!)" , "gPratiStanje", "gPratiStanje$'DN!'", "@!", })
AADD (aNiz, {"Da li se po zakljucenju smjene stampa stanje odjeljenja (D/N)" , "gStamStaPun", "gStamStaPun$'DN'", "@!", })
AADD (aNiz, {"Voditi po smjenama (D/N)" , "gVSmjene", "gVsmjene$'DN'", "@!", })
AADD (aNiz, {"Tip sezona M-mjesec G-godina" , "gSezonaTip", "gSezonaTip$'MG'", "@!", })
if KLevel=="0"
	AADD (aNiz, {"Upravnik moze ispravljati cijene" , "gSifUpravn", "gSifUpravn$'DN'", "@!", })
endif
AADD (aNiz, {"Ako je Bar Cod generisi <ENTER> " , "gEntBarCod", "gEntBarCod$'DN'", "@!", })
If (!IsPlanika())
	// generisao bug pri unosu reklamacije
	AADD (aNiz, {"Pri unosu zaduzenja azurirati i cijene (D/N)? " , "gZadCij", "gZadCij$'DN'", "@!", })
else
	gZadCij:="N"
endif
AADD (aNiz, {"Pri azuriranju pitati za nacin placanja (D/N)? " , "gUpitNP", "gUpitNP$'DN'", "@!", })
AADD (aNiz, {"Stampa na POS displej (D/N)? " , "gDisplay", "gDisplay$'DN'", "@!", })
AADD (aNiz, {"Evidentiranje podataka o vrstama placanja (D/N)? " , "gEvidPl", "gEvidPl$'DN'", "@!", })
AADD (aNiz, {"Provjera prostora na disku (D/N)? " , "gDiskFree", "gDiskFree$'DN'", "@!", })
if IsPDV()
	AADD (aNiz, {"Stampati poreske fakture (D/N)? " , "gPorFakt", "gPorFakt$'DN'", "@!", })

endif

AADD (aNiz, {"Voditi po stolovima (D/N)? " , "gStolovi", "gStolovi$'DN'", "@!", })
AADD (aNiz, {"Kod unosa racuna uvijek pretraga art.po nazivu (D/N)? " , "gSifUvPoNaz", "gSifUvPoNaz$'DN'", "@!", })
AADD (aNiz, {"Nakon stampe ispis informacija o racunu (D/N)? " , "gRnInfo", "gRnInfo$'DN'", "@!", })

VarEdit(aNiz,2,2,24,79,"PARAMETRI RADA PROGRAMA - PRINCIPI RADA","B1")

if LASTKEY()<>K_ESC
		MsgO("Azuriram parametre")
    	f18_set_metric("VodiTrebovanja",gVodiTreb)
    	if (!IsPlanika())
			f18_set_metric("AzuriranjeCijena",gZadCij)
    	endif
		f18_set_metric("VodiOdjeljenja",gVodiOdj)
		f18_set_metric("Stolovi",@gStolovi)
		f18_set_metric("DirektnoZakljucivanjeRacuna",@gDirZaklj)
    	f18_set_metric("RacunSpecifOpcije",@gRnSpecOpc)
		f18_set_metric("RadniRacuni",@gRadniRac)
    	f18_set_metric("BrojStolova",@gBrojSto)
    	f18_set_metric("DupliArtikli",@gDupliArt)
    	f18_set_metric("DupliUnosUpozorenje",@gDupliUpoz)
    	f18_set_metric("PratiStanjeRobe",@gPratiStanje )
   		f18_set_metric("PratiPocetnoStanjeSmjene",@gPocStaSmjene )
    	f18_set_metric("StampanjePazara",@gStamPazSmj )
    	f18_set_metric("StampanjePunktova",@gStamStaPun )
    	f18_set_metric("VoditiPoSmjenama",@gVsmjene )
    	f18_set_metric("TipSezone",@gSezonaTip )
    	f18_set_metric("UpravnikIspravljaCijene",@gSifUpravn )
    	f18_set_metric("DisplejOpcije",@gDisplay )
    	f18_set_metric("BarkodEnter",@gEntBarCod )
		f18_set_metric("UpitZaNacinPlacanja",@gUpitNP )
    	f18_set_metric("EvidentiranjeVrstaPlacanja",@gEvidPl )
    	f18_set_metric("SlobodniProstorDiska",@gDiskFree )
    	f18_set_metric("PretragaArtiklaPoNazivu",@gSifUvPoNaz )
    	f18_set_metric("RacunInfo",@gRnInfo )
		if IsPDV()
    		f18_set_metric("StampatiPoreskeFakture",@gPorFakt )
		endif
    	MsgC()
endif

return




function gVodiOdj(gVodiOdj)
if gVodiOdj=="0"
	if Pitanje(,"Nulirati sifre odjeljenja ","N")=="D"
    		Pushwa()
    		O_POS
		set order to 0
		go top
    		do while !eof()
      			replace idodj with "", iddio with "0"
      			skip
    		enddo
    		use
    		O_ROBA
		set order to 0
		go top
    		do while !eof()
      			replace idodj with ""
      			skip
    		enddo
    		use
    		PopWa()
	endif
  	gVodiOdj:="N"
endif
if gVodiOdj$"DN"
	return .t.
endif
return



function pos_param_izgled_racuna()
local aNiz:={}
local cPom:=""

private cIdPosOld:=gIdPos

gSjecistr:=PADR(GETPStr(gSjeciStr),20)
gOtvorstr:=PADR(GETPStr(gOtvorStr),20)

set cursor on

gSjeciStr:=PADR(gSjeciStr,30)
gOtvorStr:=PADR(gOtvorStr,30)
gZagIz:=PADR(gZagIz,20)

AADD(aNiz, {"Stampa poreza pojedinacno (D-pojedinacno,N-zbirno)" , "gPoreziRaster", "gPoreziRaster$'DN'", "@!", })
AADD(aNiz, {"Broj redova potrebnih da se racun otcijepi" , "nFeedLines", "nFeedLines>=0", "99", })
AADD(aNiz, {"Sekvenca za cijepanje trake" , "gSjeciStr", , "@S20", })
AADD(aNiz, {"Sekvenca za otvaranje kase " , "gOtvorStr", , "@S20", })
AADD(aNiz, {"Racun, prikaz cijene bez PDV (1) ili sa PDV (2) ?" , "grbCjen", , "9", })
AADD(aNiz, {"Racun, prikaz id artikla na racunu (D/N)" , "grbStId", "grbStId$'DN'", "@!", })
AADD(aNiz, {"Redukcija potrosnje trake kod stampe racuna i izvjestaja (0/1/2)" , "grbReduk", "grbReduk>=0 .and. grbReduk<=2", "9", })

VarEdit(aNiz,9,1,19,78,"PARAMETRI RADA PROGRAMA - IZGLED RACUNA","B1")

if LASTKEY()<>K_ESC
	MsgO("Azuriram parametre")
  	f18_set_metric("PorezniRaster", gPoreziRaster )
  	f18_set_metric("BrojLinijaZaKrajRacuna", nFeedLines )
  	f18_set_metric("SekvencaSjeciTraku", gSjeciStr )
  	f18_set_metric("SekvencaOtvoriLadicu", gOtvorStr )
  	f18_set_metric("RacunCijenaSaPDV", grbCjen )
	f18_set_metric("RacunStampaIDArtikla", grbStId )
	f18_set_metric("RacunRedukcijaTrake", grbReduk )
  	f18_set_metric("RacunHeader", gRnHeder )
  	f18_set_metric("IzgledZaglavlja", gZagIz )
  	f18_set_metric("RacunFooter", gRnFuter )
	MsgC()
endif

gSjeciStr:=Odsj(gSjeciStr)
gOtvorStr:=Odsj(gOtvorStr)
gZagIz:=TRIM(gZagIz)

return


function pos_v_file(cFile,cSta)
private cKom:="q "+PRIVPATH+cFile

if !EMPTY(cFile).and.Pitanje(,"Zelite li izvrsiti ispravku "+cSta+"?","N")=="D"
	Box(,25,80)
  	run &ckom
  	BoxC()
endif
return .t.


function pos_param_cijene()
local aNiz:={}
private cIdPosOld:=gIdPos

set cursor on

AADD (aNiz, {"Generalni popust % (99-gledaj sifranik)" , "gPopust" , , "99", })
AADD (aNiz, {"Zakruziti cijenu na (broj decimala)    " , "gPopDec" , ,  "9", })
AADD (aNiz, {"Varijanta Planika/Apoteka decimala)    " , "gPopVar" ,"gPopVar$' PA'" , , })
AADD (aNiz, {"Popust zadavanjem nove cijene          " , "gPopZCj" ,"gPopZCj$'DN'" , , })
AADD (aNiz, {"Popust zadavanjem procenta             " , "gPopProc","gPopProc$'DN'" , , })
AADD (aNiz, {"Popust preko odredjenog iznosa (iznos):" , "gPopIzn",,"999999.99" , })
AADD (aNiz, {"                  procenat popusta (%):" , "gPopIznP",,"999.99" , })
VarEdit(aNiz,9,2,18,78,"PARAMETRI RADA PROGRAMA - CIJENE","B1")

O_PARAMS

if LASTKEY()<>K_ESC
		MsgO("Azuriram parametre")
    	f18_set_metric("Popust",gPopust )
    	f18_set_metric("PopustZadavanjemCijene",gPopZCj )
    	f18_set_metric("PopustDecimale",gPopDec )
    	f18_set_metric("PopustVarijanta",gPopVar )
    	f18_set_metric("PopustProcenat",gPopProc )
    	f18_set_metric("PopustIznos",gPopIzn )
    	f18_set_metric("PopustVrijednostProcenta",gPopIznP )
    	MsgC()
endif

return


function pos_postavi_datum()
local dSDat:=DATE()
local cVrij:=TIME()

Box(,3,60)
set cursor on
set date format to "DD.MM.YYYY"

@ m_x+1, m_y+2 SAY  "Datum:  " GET dSDat
@ m_x+2, m_y+2 SAY  "Vrijeme:" GET cVrij

read

set date format to "DD.MM.YY"
BoxC()

if Pitanje(,"Postaviti vrijeme i datum racunara ??","N")=="D"
	SetDate(dSDat)
	SetTime(cVrij)
	// setuj i gDatum
	gDatum := dSDat
	return .t.
endif

return .f.


