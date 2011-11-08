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


#include "kalk.ch"


function kalk_params()
*{
O_KONTO
O_PARAMS
private cSection:="K",cHistory:=" "; aHistory:={}

private Opc:={}
private opcexe:={}


AADD(Opc,"1. osnovni podaci o firmi                                 ")
AADD(opcexe, {|| kalk_par_firma('D')})

AADD(Opc,"2. metoda proracuna NC, mogucnosti ispravke dokumenata ")
AADD(opcexe, {|| kalk_par_metoda_nc('D')})

AADD(Opc,"3. varijante obrade i prikaza pojedinih dokumenata ")
AADD(opcexe, {|| kalk_par_varijante_prikaza('D')})

AADD(Opc,"4. nazivi troskova za 10-ku ")
AADD(opcexe, {|| kalk_troskovi_10ka('D')})

AADD(Opc, "5. nazivi troskova za 24-ku")
AADD(opcexe, {|| kalk_par_troskovi_24('D')})

AADD(Opc,"6. nazivi troskova za RN")
AADD(opcexe, {|| kalk_par_troskovi_rn('D')})

AADD(Opc,"7. prikaz cijene,%,iznosa")
AADD(opcexe, {|| kalk_par_cijene('D')})

AADD(Opc,"8. nacin formiranja zavisnih dokumenata")
AADD(opcexe, {|| kalk_par_zavisni_dokumenti('D')})

AADD(Opc,"9. lokacije FIN/MAT/FAKT ..")
AADD(opcexe, {|| SetOdirs('D')})

AADD(Opc, "A. parametri za komisionu prodaju" )
AADD(opcexe, {|| SetKomis('D')})

AADD(Opc, "B. parametri - razno")
AADD(opcexe, {|| kalk_par_razno('D')})

private Izbor:=1
Menu_SC("pars")

select params; use
closeret
return
*}



/*! \fn kalk_par_varijante_prikaza()
 *  \brief Ispravka parametara "varijante obrade i prikaza pojedinih dokumenata"
 */

function kalk_par_varijante_prikaza()
local nX := 1
private  GetList:={}

Box(,23,76,.f.,"Varijante obrade i prikaza pojedinih dokumenata")
	
	@ m_x + nX, m_y+2 SAY "14 -Varijanta poreza na RUC u VP 1/2 (1-naprijed,2-nazad)"  get gVarVP  valid gVarVP $ "12"
  	
	nX += 1
	
	@ m_x + nX, m_y+2 SAY "14 - Nivelaciju izvrsiti na ukupno stanje/na prodanu kolicinu  1/2 ?" GET gNiv14  valid gNiv14 $ "12"

	nX += 2
	
  	@ m_x + nX, m_y+2 SAY "10 - Varijanta izvjestaja (1/2/3)" GET c10Var  valid c10Var $ "123"
  	
	nX += 1
	
	@ m_x + nX,m_y+2 SAY "10 - prikaz ukalkulisanog poreza (D/N)" GET  g10Porez  pict "@!" valid g10Porez $ "DN"
  	
	nX += 1
	
	@ m_x + nX,m_y+2 SAY "10 - ** kolicina = (1) kol-kalo ; (2) kol" GET gKalo valid gKalo $ "12"
  
	nX += 1
  	
	@ m_x + nX,m_y+2 SAY "10 - automatsko preuzimanje troskova iz sifrarnika robe ? (0/D/N)" GET gRobaTrosk valid gRobaTrosk $ "0DN" PICT "@!"

	nX += 1
	
	@ m_x + nX,m_y+2 SAY "   default tip za pojedini trosak:" 
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "   " + c10T1 GET gRobaTr1Tip valid gRobaTr1Tip $ " %URA" PICT "@!"
	
	@ m_x + nX, col() + 1 SAY c10T2 GET gRobaTr2Tip valid gRobaTr2Tip $ " %URA" PICT "@!"
	
	@ m_x + nX, col() + 1 SAY c10T3 GET gRobaTr3Tip valid gRobaTr3Tip $ " %URA" PICT "@!"
	
	@ m_x + nX, col() + 1 SAY c10T4 GET gRobaTr4Tip valid gRobaTr4Tip $ " %URA" PICT "@!"
	
	@ m_x + nX, col() + 1 SAY c10T5 GET gRobaTr5Tip valid gRobaTr5Tip $ " %URA" PICT "@!"
	
	nX += 1

	@ m_x + nX, m_y + 2 SAY "10 - pomoc sa koverzijom valute pri unosu dokumenta (D/N)" GET gDokKVal valid gDokKVal $ "DN" PICT "@!"
	
	nX += 2
	
  	@ m_x + nX, m_y+2 SAY "Voditi kalo pri ulazu " GET gVodiKalo valid gVodiKalo $ "DN" pict "@!"

	nX += 1
  
  	@ m_x + nX,m_y+2 SAY "Program se koristi iskljucivo za vodjenje magacina po NC  Da-1 / Ne-2 " GET gMagacin valid gMagacin $ "12"
  
  	if IsPDV()
	
		nX += 1
  		
		@ m_x + nX,m_y+2 SAY "PDV, evidencija magacina po NC  D/N " GET gPDVMagNab valid gPDVMagNab $ "DN"
  	
	endif
  	
	nX += 1
	
  	@ m_x + nX,m_y+2 SAY "Varijanta FAKT13->KALK11 ( 1-mpc iz sifrarnika, 2-mpc iz FAKT13)" GET  gVar13u11  pict "@!" valid gVar13u11 $ "12"
  
  	nX += 2
	
  	@ m_x + nX,m_y+2 SAY "Varijanta KALK 11 bez prikaza NC i storna RUC-a (D/N)" GET  g11bezNC  pict "@!" valid g11bezNC $ "DN"
  	
	nX += 1
	
	@ m_x + nX,m_y+2 SAY "Pri ulaznoj kalkulaciji pomoc sa C.sa PDV (D/N)" GET  gMPCPomoc pict "@!" valid gMPCPomoc $ "DN"

	nX += 1

	@ m_x + nX, m_y + 2 SAY "Varijanta popusta na dokumentima, default P-%, C-cijena" GET gRCRP

	nX += 1
	
  	@ m_x + nX,m_y+2 SAY "80 - var.rek.po tarifama ( 1 -samo ukupno / 2 -prod.1,prod.2,ukupno)" GET  g80VRT pict "9" valid g80VRT $ "12"
  	
	nX += 2
	
	@ m_x + nX,m_y+2 SAY "Kolicina za nivelaciju iz FAKT-a " GET  gKolicFakt valid gKolicFakt $ "DN"  pict "@!"
  	
	@ m_x + nX,col()+1 SAY "Auto ravnoteza naloga (FIN):" GET gAutoRavn VALID gAutoRavn $ "DN" PICT "@!"
	
	nX += 1

	@ m_x + nX,m_y+2 SAY "Automatsko azuriranje cijena u sifrarnik (D/N)" GET gAutoCjen VALID gAutoCjen $ "DN" PICT "@!"
	
	read

BoxC()

 if lastkey()<>K_ESC
  WPar("c1",gMagacin)
  if IsPDV()
  	WPar("c2",gPDVMagNab)
  endif
  Wpar("ka",gKalo)
  Wpar("vk",gVodiKalo)
  Wpar("up",g10Porez)
  WPar("vp",@gVarVP)
  WPar("v1",c10Var)
  WPar("v2",g11bezNC)
  WPar("v3",g80VRT)
  WPar("n4",gNiv14)
  WPar("vo",gVar13u11)
  WPar("mP",gMPCPomoc)
  WPar("fK",gKolicFakt)
  WPar("rx",gRobaTrosk)
  Wpar("rc",gRCRP )
  WPar("ar",gAutoRavn)
  WPar("ac",gAutoCjen)
  WPar("R1",gRobaTr1Tip)
  WPar("R2",gRobaTr2Tip)
  WPar("R3",gRobaTr3Tip)
  WPar("R4",gRobaTr4Tip)
  WPar("R5",gRobaTr5Tip)
  WPar("KV",gDokKVal)
 endif

return nil




/*! \fn kalk_par_razno()
 *  \brief Ispravka parametara "razno"
 */

function kalk_par_razno()
private  GetList:={}

Box(,15,75,.f.,"RAZNO")
 @ m_x+1,m_y+2 SAY "Brojac kalkulacija D/N         " GET gBrojac pict "@!" valid gbrojac $ "DN"
 @ m_x+1,col()+2 SAY "duzina brojaca:" GET gLenBrKalk pict "9" VALID gLenBrKalk > 0 .and. gLenBrKalk < 10
 @ m_x+2,m_y+2 SAY "Potpis na kraju naloga D/N     " GET gPotpis valid gPotpis $ "DN"
 @ m_x+3,m_Y+2 SAY "Rok trajanja D/N               " GET gRokTr pict "@!" valid gRokTr $ "DN"
 @ m_x+4,m_y+2 SAY "Novi korisnicki interfejs D/N/X" GET gNW valid gNW $ "DNX" pict "@!"
 @ m_x+5,m_y+2 SAY "Varijanta evidencije (1-sa cijenama, 2-iskljucivo kolicinski)" GET gVarEv valid gVarEv $ "12" pict "9"
 @ m_x+6,m_y+2 SAY "Tip tabele (0/1/2)             " GET gTabela VALID gTabela<3 PICT "9"
 @ m_x+7,m_y+2 SAY "Zabraniti promjenu tarife u dokumentima? (D/N)" GET gPromTar VALID gPromTar $ "DN" PICT "@!"
 @ m_x+8,m_y+2 SAY "F-ja za odredjivanje dzokera F1 u kontiranju" GET gFunKon1 PICT "@S28"
 @ m_x+9,m_y+2 SAY "F-ja za odredjivanje dzokera F2 u kontiranju" GET gFunKon2 PICT "@S28"
 @ m_x+10,m_y+2 SAY "Limit za otvorene stavke" GET gnLOst PICT "99999"
 @ m_x+11,m_y+2 SAY "Timeout kod azuriranja dokumenta (sec.)" GET gAzurTimeout PICT "99999"
 @ m_x+12,m_y+2 SAY "Timeout kod azuriranja fin.naloga (sec.)" GET gAzurFinTO PICT "99999"
 @ m_x+13,m_y+2 SAY "Auto obrada dokumenata iz cache tabele (D/N)" GET gCache VALID gCache $ "DN" PICT "@!"

@ m_x+14,m_y+2 SAY "Kontrola odstupanja NC:" GET gNC_ctrl PICT "999.99"
@ m_x+14, col() SAY "%" 

@ m_x+15,m_y+2 SAY "Indeks kod pretrage artikla:" GET gArtCDX PICT "@15"
	
read
BoxC()

if lastkey()<>K_ESC
  Wpar("br",gBrojac)
  Wpar("rt",gRokTr)
  WPar("po",gPotpis)
  Wpar("tt",gTabela)
  Wpar("nw",gNW)
  Wpar("ve",gVarEv)
  WPar("pt",gPromTar)
  WPar("f1",gFunKon1)
  WPar("f2",gFunKon2)
  WPar("aK",gAzurTimeout)
  WPar("aQ",gCache)
  WPar("aR",gNC_ctrl)
  WPar("aY",gnLOst)
  WPar("bK",gLenBrKalk)
  WPar("cd",gArtCDX)
endif

return .t.





/*! \fn kalk_par_metoda_nc()
 *  \brief Ispravka parametara "METODA NC, ISPRAVKA DOKUMENATA"
 */

function kalk_par_metoda_nc()
*{
private  GetList:={}

 Box(,4,75,.f.,"METODA NC, ISPRAVKA DOKUMENATA")
  @ m_x+1,m_y+2 SAY "Metoda nabavne cijene: bez kalk./zadnja/prosjecna/prva ( /1/2/3)" GET gMetodaNC  valid gMetodaNC $ " 123" .and. ReciMu()
  @ m_x+2,m_y+2 SAY "Program omogucava /ne omogucava azuriranje sumnjivih dokumenata (1/2)" GET gCijene  when {|| gCijene:=iif(empty(gmetodanc),"1","2"),.t.} valid  gCijene $ "12"
  @ m_x+4,m_y+2 SAY "Tekuci odgovor na pitanje o promjeni cijena ?" GET gDefNiv valid  gDefNiv $ "DN" pict "@!"
  read
 BoxC()

 if lastkey()<>K_ESC
  Wpar("nc",gMetodaNC)
  Wpar("nI",gDefNiv)
  WPar("ci",@gCijene)
  WPar("dk",@gDecKol)
 endif

return .f.
*}




/*! \fn Recimu()
 *  \brief Poruka koja objasnjava znacenje parametara "METODA NC, ISPRAVKA DOKUMENATA"
 */

function Recimu()
*{
if gMetodanc==" "
  Beep(2)
  Msg("Ova metoda omogucava da izvrsite proizvoljne ispravke#"+;
      "Program ce Vam omoguciti da ispravite bilo koji dokument#"+;
      "bez bilo kakve analize. Zato nakon ispravki dobro provjerite#"+;
      "odgovarajuce kartice.#"+;
      "Ako ste neiskusan korisnik konsultujte uputstvo !",0)

elseif gMetodaNC $ "13"
  Beep(2)
  Msg("Ovu metodu obracuna nabavne cijene ne preporucujemo !#"+;
      "Molimo Vas da usvojite metodu  2 - srednja nabavna cijena !",0)
endif
return .t.
*}




/*! \fn kalk_par_firma()
 *  \brief Ispravka parametara "MATICNA FIRMA, BAZNA VALUTA"
 */

function kalk_par_firma()
*{
private  GetList:={}

 Box(,4,65,.f.,"MATICNA FIRMA, BAZNA VALUTA")
  @ m_x+1,m_y+2 SAY "Firma: " GET gFirma
  @ m_x+1,col()+2 SAY "Naziv: " GET gNFirma
  @ m_x+1,col()+2 SAY "TIP SUBJ.: " GET gTS
  @ m_x+2,m_Y+2 SAY "Bazna valuta (Domaca/Pomocna)" GET gBaznaV  valid gbaznav $ "DP"  pict "!@"
  @ m_x+3,m_Y+2 SAY "Zaokruzenje " GET gZaokr pict "99"
  read
 BoxC()

 if lastkey()<>K_ESC
  Wpar("ff",gFirma)
  Wpar("ts",gTS)
  gNFirma:=padr(gNFirma,20)
  Wpar("fn",gNFirma)
  Wpar("Bv",gBaznaV)
  WPar("za",@gZaokr)
 endif

return .f.
*}




/*! \fn kalk_par_cijene()
 *  \brief Ispravka parametara "PARAMETRI PRIKAZA - PICTURE KODOVI"
 */

function kalk_par_cijene()
*{
private  GetList:={}

Box(,10,60,.f.,"PARAMETRI PRIKAZA - PICTURE KODOVI")
	@ m_x+1,m_y+2 SAY "Prikaz Cijene  " GET gPicCDem
  	@ m_x+2,m_y+2 SAY "Prikaz procenta" GET gPicProc
  	@ m_x+3,m_y+2 SAY "Prikaz iznosa  " GET gPicDem
 	@ m_x+4,m_y+2 SAY "Prikaz kolicine" GET gPicKol
  	@ m_x+5,m_y+2 SAY "Ispravka NC    " GET gPicNC
  	@ m_x+6,m_y+2 SAY "Decimale za kolicine" GET gDecKol pict "9"
  	@ m_x+7,m_y+2 SAY REPLICATE("-", 30) 
  	@ m_x+8,m_y+2 SAY "Dodatno prosirenje cijene" GET gFPicCDem
  	@ m_x+9,m_y+2 SAY "Dodatno prosirenje iznosa" GET gFPicDem
  	@ m_x+10,m_y+2 SAY "Dodatno prosirenje kolicine" GET gFPicKol
  	read
BoxC()

if lastkey()<>K_ESC
	Wpar("p1",gPicCDEM)
  	Wpar("p2",gPicProc)
  	Wpar("p3",gPicDEM)
  	Wpar("p4",gPicKol)
  	Wpar("p5",gPicNC )
  	Wpar("p6",gFPicCDem )
  	Wpar("p7",gFPicDem )
  	Wpar("p8",gFPicKol )
  	Wpar("dk",gDecKol)
endif

return .t.
*}




/*! \fn SetKomis()
 *  \brief Ispravka parametara "PARAMETRI KOMISIONE PRODAJE"
 */

function SetKomis()
*{
private  GetList:={}

 Box(,6,76,.f.,"PARAMETRI KOMISIONE PRODAJE")
  @ m_x+1,m_y+2 SAY "Komision: -konto" GET gKomKonto valid P_Konto(@gKomKonto)
  @ m_x+2,m_y+2 SAY "Oznaka RJ u FAKT" GET gKomFakt
  read
 BoxC()

 if lastkey()<>K_ESC
  Wpar("k1",gKomFakt)
  Wpar("k2",gKomKonto)
 endif

return nil
*}




/*! \fn kalk_par_zavisni_dokumenti()
 *  \brief Ispravka parametara "NACINI FORMIRANJA ZAVISNIH DOKUMENATA"
 */

function kalk_par_zavisni_dokumenti()
*{
private  GetList:={}
 Box(,8,76,.f.,"NACINI FORMIRANJA ZAVISNIH DOKUMENATA")
  @ m_x+1,m_y+2 SAY "Automatika formiranja FIN naloga D/N/0" GET gAFin pict "@!" valid gAFin $ "DN0"
  @ m_x+2,m_y+2 SAY "Automatika formiranja MAT naloga D/N/0" GET gAMAT pict "@!" valid gAMat $ "DN0"
  @ m_x+3,m_y+2 SAY "Automatika formiranja FAKT dokum D/N" GET gAFakt pict "@!" valid gAFakt $ "DN"
  @ m_x+4,m_y+2 SAY "Generisati 16-ku nakon 96  D/N (1/2) ?" GET gGen16  valid gGen16 $ "12"
  @ m_x+5,m_y+2 SAY "Nakon stampe zaduzenja prodavnice prenos u TOPS 0-ne/1 /2 " GET gTops  valid gTops $ "0 /1 /2 /3 /99" pict "@!"
  @ m_x+6,m_y+2 SAY "Nakon stampe zaduzenja prenos u FAKT 0-ne/1 /2 " GET gFakt  valid gFakt $ "0 /1 /2 /3 /99" pict "@!"
  read
  if gTops<>"0 ".or.gFakt<>"0 "
    @ m_x+7,m_y+2 SAY "Mjesto na koje se prenose podaci za TOPS/FAKT " GET gTopsDest   pict "@!"
    @ m_x+9,m_y+2 SAY "Koristi se modemska veza" GET gModemVeza  pict "@!" valid gModemVeza $ "DN"
    read
  endif
 BoxC()

 if lastkey()<>K_ESC
  WPar("af",@gAFin)
  WPar("am",@gAMat)
  WPar("ax",@gAFakt)
  WPar("g6",@gGen16)
  WPar("YT",gTops)
  WPar("YF",gFakt)
  WPar("YW",gTopsDest)
  WPar("Mv",gModemVeza)
 endif

return nil
*}




/*! \fn SetODirs()
 *  \brief Ispravka parametara "DIREKTORIJI"
 */

function SetODirs()
*{
private  GetList:={}

 gDirFin:=padr(gDirFin,30)
 gDirMat:=padr(gDirMat,30)
 gDirFiK:=padr(gDirFiK,30)
 gDirMaK:=padr(gDirMaK,30)
 gDirFakt:=padr(gDirFakt,30)
 gDirFakK:=padr(gDirFakK,30)

 Box(,5,76,.f.,"DIREKTORIJI")
  @ m_x+1,m_y+2 SAY "Priv.dir.FIN" get gDirFin  pict "@S25"
  @ m_x+1,col()+1 SAY "Rad.dir.FIN" get gDirFiK  pict "@S25"
  @ m_x+3,m_y+2 SAY "Priv.dir.MAT" get gDirMat   pict "@S25"
  @ m_x+3,col()+1 SAY "Rad.dir.MAT" get gDirMaK  pict "@S25"
  @ m_x+5,m_y+2 SAY "Pri.dir.FAKT" get gDirFakt  pict "@S25"
  @ m_x+5,col()+1 SAY "Ra.dir.FAKT" get gDirFakk  pict "@S25"
  read
 BoxC()

 gDirFin:=trim(gDirFin)
 gDirMat:=trim(gDirMat)
 gDirFiK:=trim(gDirFiK)
 gDirMaK:=trim(gDirMaK)
 gDirFakt:=trim(gDirFakt)
 gDirFakK:=trim(gDirFakK)

 if lastkey()<>K_ESC
  WPar("df",gDirFIN);   WPar("d3",gDirFIK)
  WPar("d4",gDirMaK);   WPar("dm",gDirMat)

  WPar("dx",@gDirFakt)
  WPar("d5",@gDirFakK)
 endif

return nil
*}




/*! \fn kalk_troskovi_10ka()
 *  \brief Ispravka parametara "Troskovi 10-ka"
 */

function kalk_troskovi_10ka()
*{
private  GetList:={}

 Box(,5,76,.T.,"Troskovi 10-ka")
  @ m_x+1,m_y+2  SAY "T1:" GET c10T1
  @ m_x+1,m_y+40 SAY "T2:" GET c10T2
  @ m_x+2,m_y+2  SAY "T3:" GET c10T3
  @ m_x+2,m_y+40 SAY "T4:" GET c10T4
  @ m_x+3,m_y+2  SAY "T5:" GET c10T5
  read
 BoxC()

 if lastkey()<>K_ESC
  WPar("11",c10T1)
  WPar("12",c10T2)
  WPar("13",c10T3)
  WPar("14",c10T4)
  WPar("15",c10T5)
 endif

return nil
*}




/*! \fn kalk_par_troskovi_rn()
 *  \brief Ispravka parametara "RADNI NALOG"
 */

function kalk_par_troskovi_rn()
*{
private  GetList:={}

 Box(,5,76,.t.,"RADNI NALOG")
  @ m_x+1,m_y+2  SAY "T 1:" GET cRNT1
  @ m_x+1,m_y+40 SAY "T 2:" GET cRNT2
  @ m_x+2,m_y+2  SAY "T 3:" GET cRNT3
  @ m_x+2,m_y+40 SAY "T 4:" GET cRNT4
  @ m_x+3,m_y+2  SAY "T 5:" GET cRNT5
  read
 BoxC()

 if lastkey()<>K_ESC
  WPar("71",@cRNT1)
  WPar("72",@cRNT2)
  WPar("73",@cRNT3)
  WPar("74",@cRNT4)
  WPar("75",@cRNT5)
 endif
 cIspravka:="N"

return nil
*}




/*! \fn kalk_par_troskovi_24()
 *  \brief Ispravka parametara "24 - USLUGE"
 */

function kalk_par_troskovi_24()
*{
private  GetList:={}

 Box(,5,76,.t.,"24 - USLUGE")
  @ m_x+1,m_y+2  SAY "T 1:" GET c24T1
  @ m_x+1,m_y+40 SAY "T 2:" GET c24T2
  @ m_x+2,m_y+2  SAY "T 3:" GET c24T3
  @ m_x+2,m_y+40 SAY "T 4:" GET c24T4
  @ m_x+3,m_y+2  SAY "T 5:" GET c24T5
  @ m_x+3,m_y+40 SAY "T 6:" GET c24T6
  @ m_x+4,m_y+2  SAY "T 7:" GET c24T7
  @ m_x+4,m_y+40 SAY "T 8:" GET c24T8
  read
 BoxC()

 if lastkey()<>K_ESC
  WPar("21",c24T1)
  WPar("22",c24T2)
  WPar("23",c24T3)
  WPar("24",c24T4)
  WPar("25",c24T5)
  WPar("26",c24T6)
  WPar("27",c24T7)
  WPar("28",c24T8)
 endif

return nil
*}


