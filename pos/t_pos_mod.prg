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
    method initdb
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
method mMenu()
local Fx
local Fy

gPrevPos:=gIdPos

Fx:=4
Fy:=8

if gSamoProdaja == "N"
    cre_doksrc()
endif

// predradnje
pos_init_dbfs()

close all

set_hot_keys()

do while (.t.)

    m_x:=Fx
    m_y:=Fy

    KLevel := PosPrijava( Fx, Fy )

    if (self:lTerminate)
        return
    endif

    SETPOS (Fx, Fy)

    if gVsmjene=="N"
        gSmjena:="1"
        OdrediSmjenu(.f.)
    else
        OdrediSmjenu(.t.) 
    endif

    exit

enddo

pos_status_traka()

SETPOS(Fx, Fy)
fPrviPut:=.t.

do while (.t.)

    m_x := Fx
    m_y := Fy
    
    // unesi prijavu korisnika
    if fPRviPut .and. gVSmjene=="N" // ne vodi vise smjena
        fPrviPut:=.f.
    else
        KLevel := PosPrijava(Fx, Fy)
        pos_status_traka()
    endif

    SETPOS( Fx, Fy )

    pos_main_menu_level( KLevel, Fx, Fy )

    if self:lTerminate
        // zavrsi run!
        exit
    endif

enddo

close all

return


function pos_main_menu_level( KLevel, Fx, Fy )

do case

    case ( ( KLevel == L_ADMIN ) .or. ( KLevel == L_SYSTEM ) )
        pos_main_menu_admin()
    case ( KLevel == L_UPRAVN )
        SETPOS( Fx, Fy )
        pos_main_menu_upravnik()
    case ( KLevel == L_PRODAVAC )
        SETPOS( Fx, Fy )
        pos_main_menu_prodavac()

endcase

return



// -------------------------------------------
// -------------------------------------------
method setScreen()

SetNaslov(self)
NaslEkran(.t.)

return


// ---------------------------------------------
// ---------------------------------------------
method setGVars()

set_global_vars()
set_roba_global_vars()

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
public gSetMPCijena := "1"
public gIdCijena:="1"   
public gPopust:=0
public gPopDec:=2
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

public gLocPort := "LPT1" // lokalni port za stampanje racuna

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

public gDuzSifre := 13

// postavljanje globalnih varijabli
public gLocPort:="LPT1"
public gIdCijena:="1"
public gDiskFree:="N"
public grbCjen:=2
public grbStId:="D"
public grbReduk:=0
public gRnInfo:="N"
public aRabat

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

gDatum := DATE()

public gPopVar:= "P"
public gPopZcj:= "N"
public gZadCij:= "N"
public gPopProc:= "N"
public gIsPopust:=.f.
public gKolDec := 2
public gCijDec := 2
public gStariObrPor := .f.
public gClanPopust := .f.
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
public gSifPath := my_home()
public LocSIFPATH := my_home()
public gServerPath := PADR("i:" + SLASH + "sigma", 40 )
public gKalkDEST := PADR( "a:" + SLASH, 300 )
public gMultiPM:="D"
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
gVodiTreb:="N"
gVodiOdj:="N"
gBrojSto:="0"
gRnSpecOpc:="N"
gRadniRac:="N"
gDirZaklj:="D"
gDupliArt:="D"
gDupliUpoz:="N"
gDisplay:="N"

// citaj parametre iz metric tabele
gFirNaziv := fetch_metric("pos_header_org_naziv", nil, gFirNaziv)
gFirAdres := fetch_metric("pos_header_org_adresa", nil, gFirAdres)
gFirIdBroj := fetch_metric("pos_header_org_id_broj", nil, gFirIdBroj)
gFirPM := fetch_metric("pos_header_pm", nil, gFirPM)
gRnMjesto := fetch_metric("pos_header_mjesto", nil, gRnMjesto)
gFirTel := fetch_metric("pos_header_telefon", nil, gFirTel)
gRnPTxt1 := fetch_metric("pos_header_txt_1", nil, gRnPTxt1)
gRnPTxt2 := fetch_metric("pos_header_txt_2", nil, gRnPTxt2)
gRnPTxt3 := fetch_metric("pos_header_txt_3", nil, gRnPTxt3)
gPorFakt := fetch_metric("StampatiPoreskeFakture", nil, gPorFakt)
gVrstaRS := fetch_metric("VrstaRadneStanice", nil, gVrstaRS)
gIdPos := fetch_metric("IDPos", my_user(), gIdPos)
gPostDO := fetch_metric("ZasebneCjelineObjekta", nil, gPostDO)
gIdDio := fetch_metric("OznakaDijelaObjekta", nil, gIdDio)
gServerPath := fetch_metric("PutanjaServera", nil, gServerPath)
gKalkDest := fetch_metric("KalkDestinacija", my_user(), gKalkDest)
gMultiPM := fetch_metric("kalk_tops_prenos_vise_prodajnih_mjesta", my_user(), gMultiPM )
gUseChkDir := fetch_metric("KoristitiDirektorijProvjere", my_user(), gUseChkDir)
gStrValuta := fetch_metric("StranaValuta", nil, gStrValuta)
gLocPort := fetch_metric("OznakaLokalnogPorta", my_user(), gLocPort)
gGotPlac := fetch_metric("OznakaGotovinskogPlacanja", nil, gGotPlac)
gDugPlac := fetch_metric("OznakaDugPlacanja", nil, gDugPlac)
gRnInfo := fetch_metric("RacunInfo", nil, gRnInfo)

gServerPath := ALLTRIM( gServerPath )
if (RIGHT(gServerPath,1) <> SLASH)
    gServerPath += SLASH
endif

// principi rada kase
cPrevPSS := gPocStaSmjene

gVodiTreb := fetch_metric("VodiTrebovanja", nil, gVodiTreb)
gZadCij := fetch_metric("AzuriranjeCijena", nil, gZadCij)
gVodiOdj := fetch_metric("VodiOdjeljenja", nil, gVodiOdj)
gStolovi := fetch_metric("Stolovi", nil, gStolovi)
gRadniRac := fetch_metric("RadniRacuni", nil, gRadniRac)
gDirZaklj := fetch_metric("DirektnoZakljucivanjeRacuna", nil, gDirZaklj)
gRnSpecOpc := fetch_metric("RacunSpecifOpcije", nil, gRnSpecOpc)
gBrojSto := fetch_metric("BrojStolova", nil, gBrojSto)
gDupliArt := fetch_metric("DupliArtikli", nil, gDupliArt)
gDupliUpoz := fetch_metric("DupliUnosUpozorenje", nil, gDupliUpoz)
gPratiStanje := fetch_metric("PratiStanjeRobe", nil, gPratiStanje)
gPocStaSmjene := fetch_metric("PratiPocetnoStanjeSmjene", nil, gPocStaSmjene)
gStamPazSmj := fetch_metric("StampanjePazara", nil, gStamPazSmj)
gStamStaPun := fetch_metric("StampanjePunktova", nil, gStamStaPun)
gVSmjene := fetch_metric("VoditiPoSmjenama", nil, gVsmjene)
gSezonaTip := fetch_metric("TipSezone", nil, gSezonaTip)
gSifUpravn := fetch_metric("UpravnikIspravljaCijene", nil, gSifUpravn)
gDisplay := fetch_metric("DisplejOpcije", nil, gDisplay)
gEntBarCod := fetch_metric("BarkodEnter", my_user(), gEntBarCod)
gEvidPl := fetch_metric("EvidentiranjeVrstaPlacanja", nil, gEvidPl)
gSifUvPoNaz := fetch_metric("PretragaArtiklaPoNazivu", nil, gSifUvPoNaz)
gDiskFree := fetch_metric("SlobodniProstorDiska", nil, gDiskFree)

// izgled racuna
gSjecistr := padr( GETPStr( gSjeciStr ), 20 )
gOtvorstr := padr( GETPStr( gOtvorStr ), 20 )

gPoreziRaster := fetch_metric("PorezniRaster", nil, gPoreziRaster)
nFeedLines := fetch_metric("BrojLinijaZaKrajRacuna", nil, nFeedLines)
gSjeciStr := fetch_metric("SekvencaSjeciTraku", nil, gSjeciStr)
gOtvorStr := fetch_metric("SekvencaOtvoriLadicu", nil, gOtvorStr)

gSjeciStr := Odsj( @gSjeciStr )
gOtvorStr := Odsj( @gOtvorStr )

gZagIz := fetch_metric("IzgledZaglavlja", nil, gZagIz)
gRnHeader := fetch_metric("RacunHeader", nil, gRnHeder)
gRnFuter := fetch_metric("RacunFooter", nil, gRnFuter)

// izgled racuna
grbCjen := fetch_metric("RacunCijenaSaPDV", nil, grbCjen)
grbStId := fetch_metric("RacunStampaIDArtikla", nil, grbStId)
grbReduk := fetch_metric("RacunRedukcijaTrake", nil, grbReduk)

// cijene
gSetMPCijena := fetch_metric("pos_set_cijena", nil, gSetMPCijena )
gIdCijena := fetch_metric("SetCijena", nil, gIdCijena)
gPopust := fetch_metric("Popust", nil, gPopust)
gPopDec := fetch_metric("PopustDecimale", nil, gPopDec)
gPopVar := fetch_metric("PopustVarijanta", nil, gPopVar)
gPopZCj := fetch_metric("PopustZadavanjemCijene", nil, gPopZCj)
gPopProc := fetch_metric("PopustProcenat", nil, gPopProc)
gPopIzn := fetch_metric("PopustIznos", nil, gPopIzn)
gPopIznP := fetch_metric("PopustVrijednostProcenta", nil, gPopIznP)

gColleg := fetch_metric("PodesenjeNonsense", nil, gColleg )
gDuplo := fetch_metric("AzurirajUPomocnuBazu", nil, gDuplo)
gDuploKum := fetch_metric("KumulativPomocneBaze", nil, gDuploKum)
gDuploSif := fetch_metric("SifrarnikPomocneBaze", nil, gDuploSif)
gFMKSif := fetch_metric("FMKSifrarnik", nil, gFmkSif)
gRNALSif := fetch_metric("RNALSifrarnik", nil, gRNALSif)
gRNALKum := fetch_metric("RNALKumulativ", nil, gRNALKum)

gDuzSifre := fetch_metric("DuzinaSifre", my_user(), gDuzSifre)

gUpitNp := fetch_metric("UpitZaNacinPlacanja", nil, gUpitNp)

public gStela := CryptSC("STELA")
public gPVrsteP := .f.
gPVrsteP := fetch_metric("AzuriranjePrometaPoVP", nil, gPVrsteP)

if (gVrstaRS=="S")
    gIdPos := Space(LEN(gIdPos))
endif

public gSQLKom
gSQL := IzFmkIni("Svi","SQLLog","N",KUMPATH)
gSQLLogBase := IzFmkIni("SQL","SQLLogBase","c:\sigma",EXEPATH)

gSamoProdaja := fetch_metric("SamoProdaja", nil, gSamoProdaja)

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
// set valuta
SetNazDVal()

SetBoje( gVrstaRS )

// setuj parametar tezinski_barkod
param_tezinski_barkod(.t.)

// maksimalna kolicina kod unosa racuna
max_kolicina_kod_unosa(.t.)

// kalk konto za stanje pos artikla
kalk_konto_za_stanje_pos( .t. )

// koristenje fiskalnih opcija
fiscal_opt_active()

gRobaBlock := { |Ch| pos_roba_block( Ch ) }

return


