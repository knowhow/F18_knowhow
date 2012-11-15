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
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc,"1. podaci kase                    ")
AADD(_opcexe,{|| pos_param_podaci_kase()})
AADD(_opc,"2. principi rada")
AADD(_opcexe,{|| pos_param_principi_rada()})
AADD(_opc,"3. izgled racuna")
AADD(_opcexe,{|| pos_param_izgled_racuna()})
AADD(_opc,"4. cijene")
AADD(_opcexe,{|| pos_param_cijene()})
AADD(_opc,"5. postavi vrijeme i datum kase")
AADD(_opcexe,{|| pos_postavi_datum()})
AADD(_opc,"6. podaci firme")
AADD(_opcexe,{|| pos_param_firma()})
AADD(_opc,"7. fiskalni parametri")
AADD(_opcexe,{|| f18_fiscal_params_menu()})
AADD(_opc,"8. podesenja organizacije")
AADD(_opcexe,{|| org_params()})
AADD(_opc,"9. podesenja barkod-a")
AADD(_opcexe,{|| label_params()})

f18_menu("par", .f., _izbor, _opc, _opcexe )

return .f.



function pos_param_podaci_kase()
local aNiz:={}
local cPom:=""
private cIdPosOld:=gIdPos
private cHistory:=" "
private aHistory:={}
private cSection:="1"

gServerPath := padr(gServerPath,40)
gKalkDest := padr(gKalkDest,300)
gDuploKum := padr(gDuploKum,30)
gDuploSif := padr(gDuploSif,30)
gFMKSif := padr(gFmkSif,30)
gRNALSif := padr(gRNALSif,100)
gRNALKum := padr(gRNALKum,100)

set cursor on

AADD(aNiz,{"Vrsta radne stanice (K-kasa, A-samostalna kasa, S-server)" , "gVrstaRS", "gVrstaRS$'KSA'", "@!", })
AADD(aNiz,{"Oznaka/ID prodajnog mjesta" , "gIdPos",, "@!", })

if gModul=="HOPS" 
    AADD(aNiz,{"Ima li objekat zasebne cjeline (dijelove) D/N", "gPostDO","gPostDO$'DN'", "@!", })
    AADD(aNiz,{"Oznaka/ID dijela objekta", "gIdDio",, "@!", })
endif

AADD(aNiz,{"Putanja korijenskog direktorija modula na serveru" , "gServerPath", , , })
AADD(aNiz,{"Destinacija datoteke TOPSKA" , "gKALKDEST", , "@S40", })
AADD(aNiz,{"Razmjena podataka, vise prodajnih jedinica (D/N)", "gMultiPM","gMultiPM $ 'DN'", "@!", })
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
    set_metric("VrstaRadneStanice", nil, gVrstaRS )
    set_metric("IDPos", nil, gIdPos )
    set_metric("ZasebneCjelineObjekta", nil, gPostDO )
    set_metric("OznakaDijelaObjekta", nil, gIdDio )
    set_metric("PutanjaServera", nil, gServerPath )     // pathove ne diraj
    set_metric("KalkDestinacija", nil, gKalkDest )       // pathove ne diraj
    set_metric("kalk_tops_prenos_vise_prodajnih_mjesta", my_user(), gMultiPM )
    set_metric("KoristitiDirektorijProvjere", nil, gUseChkDir ) // koristi chk direktorij
    set_metric("OznakaLokalnogPorta", nil, gLocPort )
    set_metric("OznakaGotovinskogPlacanja", nil, gGotPlac )
    set_metric("OznakaDugPlacanja", nil, gDugPlac )
    set_metric("StranaValuta", nil, gStrValuta )
    set_metric("PodesenjaNonsens", nil, gColleg )
    set_metric("AzurirajUPomocnuBazu", nil, gDuplo )
    set_metric("KumulativPomocneBaze", nil, trim(gDuploKum) ) // pathove ne diraj
    set_metric("SifrarnikPomocneBaze", nil, trim(gDuploSif) ) // pathove ne diraj
    set_metric("FMKSifrarnik", nil, trim(gFmkSif) )   // pathove ne diraj
    set_metric("RNALSifrarnik", nil, trim(gRNALSif) )   // pathove ne diraj
    set_metric("RNALKumulativ", nil, trim(gRNALKum) )   // pathove ne diraj
    set_metric("DuzinaSifre", nil, gDuzSifre )
    set_metric("OperativniSistem", nil, gOperSys )
    MsgC()
endif

gServerPath := ALLTRIM(gServerPath)

if (RIGHT(gServerPath,1) <> SLASH)
    gServerPath += SLASH
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
    set_metric("pos_header_org_naziv", nil, gFirNaziv)
    set_metric("pos_header_org_adresa", nil, gFirAdres)
    set_metric("pos_header_org_id_broj", nil, gFirIdBroj)
    set_metric("pos_header_pm", nil, gFirPM)
    set_metric("pos_header_mjesto", nil, gRnMjesto)
    set_metric("pos_header_telefon", nil, gFirTel)
    set_metric("pos_header_txt_1", nil, gRnPTxt1)
    set_metric("pos_header_txt_2", nil, gRnPTxt2)
    set_metric("pos_header_txt_3", nil, gRnPTxt3)

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
    set_metric("VodiTrebovanja", nil, gVodiTreb )
    set_metric("DirektnoZakljucivanjeRacuna", nil, gDirZaklj )
    set_metric("RacunSpecifOpcije", nil, gRnSpecOpc )
    set_metric("RadniRacuni", nil, gRadniRac )
    set_metric("BrojStolova", nil, gBrojSto )
    set_metric("StampanjePunktova", nil, gStamStaPun )
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

private _konstantni_unos := fetch_metric( "pos_konstantni_unos_racuna", my_user(), "N" )
private _max_qtty := fetch_metric( "pos_maksimalna_kolicina_na_unosu", nil, 0 )
private cIdPosOld := gIdPos

cPrevPSS := gPocStaSmjene

set cursor on

aNiz:={}
AADD (aNiz, {"Da li se racun zakljucuje direktno (D/N)" , "gDirZaklj", "gDirZaklj$'DN'", "@!", })
AADD (aNiz, {"Dopustiti dupli unos artikala na racunu (D/N)" , "gDupliArt", "gDupliArt$'DN'", "@!", })
AADD (aNiz, {"Ako se dopusta dupli unos, da li se radnik upozorava(D/N)" , "gDupliUpoz", "gDupliUpoz$'DN'", "@!", })
AADD (aNiz, {"Da li se prati pocetno stanje smjene (D/N/!)" , "gPocStaSmjene", "gPocStaSmjene$'DN!'", "@!", })

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

if IsPDV()
    AADD (aNiz, {"Stampati poreske fakture (D/N)? " , "gPorFakt", "gPorFakt$'DN'", "@!", })
endif

AADD (aNiz, {"Voditi po stolovima (D/N)? " , "gStolovi", "gStolovi$'DN'", "@!", })
AADD (aNiz, {"Kod unosa racuna uvijek pretraga art.po nazivu (D/N)? " , "gSifUvPoNaz", "gSifUvPoNaz$'DN'", "@!", })
AADD (aNiz, {"Nakon stampe ispis informacija o racunu (D/N)? " , "gRnInfo", "gRnInfo$'DN'", "@!", })
AADD (aNiz, {"Maksimalna kolicina pri unosu racuna (0 - bez provjere) " , "_max_qtty", "_max_qtty >= 0", "999999", })
AADD (aNiz, {"Unos racuna bez izlaska iz pripreme (D/N) " , "_konstantni_unos", "_konstantni_unos$'DN'", "@!", })

VarEdit( aNiz, 2, 2, MAXROWS(), MAXCOLS(),"PARAMETRI RADA PROGRAMA - PRINCIPI RADA", "B1" )

if LASTKEY() <> K_ESC

    MsgO("Azuriram parametre")

    set_metric( "VodiTrebovanja", nil, gVodiTreb )

    if (!IsPlanika())
        set_metric("AzuriranjeCijena", nil, gZadCij )
    endif

    set_metric("VodiOdjeljenja", nil, gVodiOdj)
    set_metric("Stolovi", nil, gStolovi)
    set_metric("DirektnoZakljucivanjeRacuna", nil, gDirZaklj)
    set_metric("RacunSpecifOpcije", nil, gRnSpecOpc)
    set_metric("RadniRacuni", nil, gRadniRac)
    set_metric("BrojStolova", nil, gBrojSto)
    set_metric("DupliArtikli", nil, gDupliArt)
    set_metric("DupliUnosUpozorenje", nil, gDupliUpoz)
    set_metric("PratiStanjeRobe", nil, gPratiStanje )
    set_metric("PratiPocetnoStanjeSmjene", nil, gPocStaSmjene )
    set_metric("StampanjePazara", nil, gStamPazSmj )
    set_metric("StampanjePunktova", nil, gStamStaPun )
    set_metric("VoditiPoSmjenama", nil, gVsmjene )
    set_metric("TipSezone", nil, gSezonaTip )
    set_metric("UpravnikIspravljaCijene", nil, gSifUpravn )
    set_metric("DisplejOpcije", nil, gDisplay )
    set_metric("BarkodEnter", nil, gEntBarCod )
    set_metric("UpitZaNacinPlacanja", nil, gUpitNP )
    set_metric("EvidentiranjeVrstaPlacanja", nil, gEvidPl )
    set_metric("SlobodniProstorDiska", nil, gDiskFree )
    set_metric("PretragaArtiklaPoNazivu", nil, gSifUvPoNaz )
    set_metric("RacunInfo", nil, gRnInfo )

    set_metric( "pos_maksimalna_kolicina_na_unosu", nil, _max_qtty )
	max_kolicina_kod_unosa(.t.)

    set_metric( "pos_konstantni_unos_racuna", my_user(), _konstantni_unos )

    if IsPDV()
        set_metric("StampatiPoreskeFakture", nil, gPorFakt )
    endif

    MsgC()

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
    set_metric("PorezniRaster", nil, gPoreziRaster )
    set_metric("BrojLinijaZaKrajRacuna", nil, nFeedLines )
    set_metric("SekvencaSjeciTraku", nil, gSjeciStr )
    set_metric("SekvencaOtvoriLadicu", nil, gOtvorStr )
    set_metric("RacunCijenaSaPDV", nil, grbCjen )
    set_metric("RacunStampaIDArtikla", nil, grbStId )
    set_metric("RacunRedukcijaTrake", nil, grbReduk )
    set_metric("RacunHeader", nil, gRnHeder )
    set_metric("IzgledZaglavlja", nil, gZagIz )
    set_metric("RacunFooter", nil, gRnFuter )
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
AADD (aNiz, {"Koristiti set cijena                  :" , "gSetMPCijena",,"9" , })
VarEdit(aNiz,9,2,20,78,"PARAMETRI RADA PROGRAMA - CIJENE","B1")

O_PARAMS

if LASTKEY()<>K_ESC
    MsgO("Azuriram parametre")
    set_metric("Popust", nil, gPopust )
    set_metric("PopustZadavanjemCijene", nil, gPopZCj )
    set_metric("PopustDecimale", nil, gPopDec )
    set_metric("PopustVarijanta", nil, gPopVar )
    set_metric("PopustProcenat", nil, gPopProc )
    set_metric("PopustIznos", nil, gPopIzn )
    set_metric("PopustVrijednostProcenta", nil, gPopIznP )
    set_metric("pos_set_cijena", nil, gSetMPCijena )
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


