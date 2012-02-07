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

O_KONTO

private Opc:={}
private opcexe:={}


AADD(Opc,"1. osnovni podaci o firmi                                 ")
AADD(opcexe, {|| org_params() })

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

close all
return




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

if lastkey() <> K_ESC

	set_metric("kalk_magacin_po_nc", nil, gMagacin)

  	if IsPDV()
  		set_metric("kalk_magacin_po_nc_pdv", nil, gPDVMagNab)
  	endif

  	set_metric("kalk_kolicina_kalo", nil, gKalo)
  	set_metric("kalk_voditi_kalo", nil, gVodiKalo)
  	set_metric("kalk_dokument_10_prikaz_ukalk_poreza", nil, g10Porez)
  	set_metric("kalk_dokument_14_varijanta_poreza", nil, gVarVP)
  	set_metric("kalk_dokument_10_varijanta", nil, c10Var)
  	set_metric("kalk_dokument_11_bez_nc", nil, g11bezNC)
  	set_metric("kalk_dokument_80_rekap_po_tar", nil, g80VRT)
  	set_metric("kalk_tip_nivelacije_14", nil, gNiv14)
  	set_metric("kalk_varijanta_fakt_13_kalk_11_cijena", nil, gVar13u11)
  	set_metric("kalk_pomoc_sa_mpc", nil, gMPCPomoc)
  	set_metric("kalk_kolicina_kod_nivelacije_fakt", nil, gKolicFakt)
  	set_metric("kalk_preuzimanje_troskova_iz_sif_roba", nil, gRobaTrosk)
  	set_metric("kalk_varijanta_popusta_na_dokumentima", nil, gRCRP )
  	set_metric("kalk_kontiranje_automatska_ravnoteza_naloga", nil, gAutoRavn)
  	set_metric("kalk_automatsko_azuriranje_cijena", nil, gAutoCjen)
  	set_metric("kalk_trosak_1_tip", nil, gRobaTr1Tip)
  	set_metric("kalk_trosak_2_tip", nil, gRobaTr2Tip)
  	set_metric("kalk_trosak_3_tip", nil, gRobaTr3Tip)
  	set_metric("kalk_trosak_4_tip", nil, gRobaTr4Tip)
  	set_metric("kalk_trosak_5_tip", nil, gRobaTr5Tip)
  	set_metric("kalk_konverzija_valute_na_unosu", nil, gDokKVal)

endif

return nil


// kalk :: parametri razno
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
	set_metric("kalk_brojac_kalkulacija", nil, gBrojac)
  	set_metric("kalk_rok_trajanja", nil, gRokTr)
  	set_metric("kalk_potpis_na_kraju_naloga", nil, gPotpis)
  	set_metric("kalk_tip_tabele", nil, gTabela)
  	set_metric("kalk_novi_korisnicki_interfejs", nil, gNW)
  	set_metric("kalk_varijanta_evidencije", nil, gVarEv)
  	set_metric("kalk_zabrana_promjene_tarifa", nil, gPromTar)
  	set_metric("kalk_djoker_f1_kod_kontiranja", nil, gFunKon1)
  	set_metric("kalk_djoker_f2_kod_kontiranja", nil, gFunKon2)
  	set_metric("kalk_timeout_kod_azuriranja", nil, gAzurTimeout)
  	set_metric("kalk_cache_tabela", f18_user(), gCache)
  	set_metric("kalk_kontrola_odstupanja_nc", f18_user(), gNC_ctrl)
  	set_metric("kalk_limit_za_otvorene_stavke", f18_user(), gnLOst)
  	set_metric("kalk_duzina_brojaca_dokumenta", nil, gLenBrKalk)
  	set_metric("kalk_index_za_pretragu_artikala", f18_user(), gArtCDX)
endif

return .t.





/*! \fn kalk_par_metoda_nc()
 *  \brief Ispravka parametara "METODA NC, ISPRAVKA DOKUMENATA"
 */

function kalk_par_metoda_nc()
private  GetList:={}

Box(,4,75,.f.,"METODA NC, ISPRAVKA DOKUMENATA")
  	@ m_x+1,m_y+2 SAY "Metoda nabavne cijene: bez kalk./zadnja/prosjecna/prva ( /1/2/3)" GET gMetodaNC ;
 		valid gMetodaNC $ " 123" .and. metodanc_info()
  	@ m_x+2,m_y+2 SAY "Program omogucava /ne omogucava azuriranje sumnjivih dokumenata (1/2)" GET gCijene ;
		when {|| gCijene:=iif(empty(gmetodanc),"1","2"),.t.} valid  gCijene $ "12"
  	@ m_x+4,m_y+2 SAY "Tekuci odgovor na pitanje o promjeni cijena ?" GET gDefNiv ;
		valid  gDefNiv $ "DN" pict "@!"
	read
BoxC()

if lastkey() <> K_ESC

  set_metric("kalk_metoda_nc", nil, gMetodaNC)
  set_metric("kalk_promjena_cijena_odgovor", nil, gDefNiv)
  set_metric("kalk_azuriranje_sumnjivih_dokumenata", nil, gCijene)
  set_metric("kalk_broj_decimala_za_kolicinu", nil, gDecKol)

endif

return .f.



function metodanc_info()
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



function kalk_par_cijene()
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

if lastkey() <> K_ESC
	set_metric("kalk_format_prikaza_cijene", nil, gPicCDEM)
  	set_metric("kalk_format_prikaza_procenta", nil, gPicProc)
  	set_metric("kalk_format_prikaza_iznosa", nil, gPicDEM)
  	set_metric("kalk_format_prikaza_kolicine", nil, gPicKol)
  	set_metric("kalk_format_prikaza_nabavne_cijene", nil, gPicNC )
  	set_metric("kalk_format_prikaza_cijene_prosirenje", nil, gFPicCDem )
  	set_metric("kalk_format_prikaza_iznosa_prosirenje", nil, gFPicDem )
  	set_metric("kalk_format_prikaza_kolicine_prosirenje", nil, gFPicKol )
  	set_metric("kalk_broj_decimala_za_kolicinu", nil, gDecKol)
endif

return .t.



function SetKomis()
private  GetList:={}

Box(,6,76,.f.,"PARAMETRI KOMISIONE PRODAJE")
  @ m_x+1,m_y+2 SAY "Komision: -konto" GET gKomKonto valid P_Konto(@gKomKonto)
  @ m_x+2,m_y+2 SAY "Oznaka RJ u FAKT" GET gKomFakt
  read
BoxC()

if lastkey() <> K_ESC
	set_metric("kalk_oznaka_rj_u_fakt", nil, gKomFakt)
  	set_metric("kalk_komision_konto", nil, gKomKonto)
endif

return nil



function kalk_par_zavisni_dokumenti()
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

if lastkey() <> K_ESC
	set_metric("kalk_kontiranje_fin", f18_user(), gAFin)
  	set_metric("kalk_kontiranje_mat", f18_user(), gAMat)
  	set_metric("kalk_kontiranje_fakt", f18_user(), gAFakt)
  	set_metric("kalk_generisi_16_nakon_96", f18_user(), gGen16)
  	set_metric("kalk_prenos_pos", f18_user(), gTops)
  	set_metric("kalk_prenos_fakt", f18_user(), gFakt)
  	set_metric("kalk_destinacija_topska", f18_user(), gTopsDest)
  	set_metric("kalk_modemska_veza", f18_user(), gModemVeza)
endif

return nil




function SetODirs()
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
  //set_metric("df",gDirFIN)
  //set_metric("d3",gDirFIK)
  //set_metric("d4",gDirMaK)
  //set_metric("dm",gDirMat)

  //set_metric("dx",@gDirFakt)
  //set_metric("d5",@gDirFakK)
 endif

return nil



function kalk_troskovi_10ka()
private  GetList:={}

Box(,5,76,.T.,"Troskovi 10-ka")
  @ m_x+1,m_y+2  SAY "T1:" GET c10T1
  @ m_x+1,m_y+40 SAY "T2:" GET c10T2
  @ m_x+2,m_y+2  SAY "T3:" GET c10T3
  @ m_x+2,m_y+40 SAY "T4:" GET c10T4
  @ m_x+3,m_y+2  SAY "T5:" GET c10T5
  read
BoxC()

if lastkey() <> K_ESC
  
	set_metric("kalk_dokument_10_trosak_1", nil, c10T1)
	set_metric("kalk_dokument_10_trosak_2", nil, c10T2)
	set_metric("kalk_dokument_10_trosak_3", nil, c10T3)
	set_metric("kalk_dokument_10_trosak_4", nil, c10T4)
	set_metric("kalk_dokument_10_trosak_5", nil, c10T5)

endif

return nil


function kalk_par_troskovi_rn()
private  GetList:={}

Box(,5,76,.t.,"RADNI NALOG")
  @ m_x+1,m_y+2  SAY "T 1:" GET cRNT1
  @ m_x+1,m_y+40 SAY "T 2:" GET cRNT2
  @ m_x+2,m_y+2  SAY "T 3:" GET cRNT3
  @ m_x+2,m_y+40 SAY "T 4:" GET cRNT4
  @ m_x+3,m_y+2  SAY "T 5:" GET cRNT5
  read
BoxC()

if lastkey() <> K_ESC
  set_metric("kalk_dokument_rn_trosak_1", nil, cRNT1)
  set_metric("kalk_dokument_rn_trosak_2", nil, cRNT2)
  set_metric("kalk_dokument_rn_trosak_3", nil, cRNT3)
  set_metric("kalk_dokument_rn_trosak_4", nil, cRNT4)
  set_metric("kalk_dokument_rn_trosak_5", nil, cRNT5)
endif

cIspravka := "N"

return nil



function kalk_par_troskovi_24()
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

if lastkey() <> K_ESC
	set_metric("kalk_dokument_24_trosak_1", nil, c24T1)
  	set_metric("kalk_dokument_24_trosak_2", nil, c24T2)
  	set_metric("kalk_dokument_24_trosak_3", nil, c24T3)
  	set_metric("kalk_dokument_24_trosak_4", nil, c24T4)
  	set_metric("kalk_dokument_24_trosak_5", nil, c24T5)
  	set_metric("kalk_dokument_24_trosak_6", nil, c24T6)
  	set_metric("kalk_dokument_24_trosak_7", nil, c24T7)
  	set_metric("kalk_dokument_24_trosak_8", nil, c24T8)
endif

return nil



