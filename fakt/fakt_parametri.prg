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


#include "fakt.ch"



// ------------------------------------------
// setuju parametre pri pokretanju modula
// napuni sifrarnike
// ------------------------------------------
function s_params()

// PTXT 01.50 compatibility switch
public gPtxtC50 := .t.

fill_part()

return



/*! \fn mnu_fakt_params()
 *  \brief Otvara glavni menij sa parametrima
 */
function mnu_fakt_params()
private cSection:="1"
private cHistory:=" "
private aHistory:={}
private Izbor:=1
private opc:={}
private opcexe:={}

O_ROBA
O_PARAMS

SELECT params
USE


AADD(opc,"1. postaviti osnovne podatke o firmi           ")
AADD(opcexe,{|| SetFirma()})

AADD(opc,"2. postaviti varijante obrade dokumenata       ") 
AADD(opcexe,{|| SetVarijante()})

AADD(opc,"3. izgled dokumenata      ")
AADD(opcexe,{|| SetT1()})

if IsPDV()
	AADD(opc,"4. izgled dokumenata - zaglavlje ")
	AADD(opcexe,{|| ZaglParams()})
endif

AADD(opc,"5. nazivi dokumenata i teksta na kraju (potpis)")
AADD(opcexe,{|| SetT2()})

AADD(opc,"6. prikaza cijena, iznos ")
AADD(opcexe,{|| SetPICT()})

AADD(opc,"7. postaviti parametre - razno                 ")
AADD(opcexe,{|| SetRazno()})

if !IsPDV()
	AADD(opc,"W. parametri Win stampe (DelphiRB)             ")
	AADD(opcexe,{|| P_WinFakt()})
endif

AADD(opc,"8. parametri stampaca                          ")
AADD(opcexe,{|| PushWa(), PPrint(), PopWa() })


if IsRabati()
	AADD(opc,"9. rabatne skale            ")
	AADD(opcexe,{|| PRabat()})
endif

AADD(opc,"F. parametri fiskalnog uredjaja  ")
AADD(opcexe,{|| fisc_param() })

AADD(opc,"L. lista fiskalnih uredjaja  ")
AADD(opcexe,{|| p_fdevice() })


Menu_SC("parf")

return nil 

// ---------------------------------------------
// parametri fiskalnog stampaca
// ---------------------------------------------

function fisc_param()
private cSection:="F"
private cHistory:=" "
private aHistory:={}
private GetList:={}

O_PARAMS

Box(,21,77,.f.,"PARAMETRI FISKALNOG STMPACA")

	nX := 1
	
	@ m_x+nX, col()+1 SAY "PDV obveznik (D/N):" GET gFC_pdv ;
			VALID gFC_pdv $ "DN" PICT "@!"

	++ nX

	@ m_x+nX, m_y+2 SAY "Tip uredjaja:" GET gFC_type ;
			VALID !EMPTY(gFC_type)
		
	@ m_x+nX, col()+1 SAY "IOSA broj:" GET gIOSA 

	++ nX
	
	@ m_x+nX, m_y+2 SAY "[K] kasa-printer [P] printer ?" GET gFC_device ;
			VALID gFC_device $ "KP" PICT "@!"
	
	@ m_x+nX, col()+2 SAY "serijski broj:" GET gFC_serial PICT "@S10"

	++ nX
	++ nX

	@ m_x+nX, m_y+2 SAY "Izl.dir:" GET gFC_path ;
			VALID !EMPTY(gFC_path) PICT "@S25"
		
	@ m_x+nX, col()+1 SAY "Izl.fajl:" GET gFC_name ;
			VALID !EMPTY(gFC_name) PICT "@S25"
		
	++ nX
	
	@ m_x+nX, m_y+2 SAY "Sek.dir:" GET gFC_path2 ;
			PICT "@S25"

	@ m_x+nX, col()+1 SAY "Fajl odgovora:" GET gFC_answ ;
			PICT "@S25"
	
	++ nX
	
	@ m_x+nX, m_y+2 SAY "Duzina naziva robe:" GET gFC_alen PICT "999"
		
	@ m_x+nX, col()+2 SAY "Provjera gresaka:" GET gFC_error ;
			VALID gFC_error $ "DN" PICT "@!"
	
	++ nX

	@ m_x+nX, m_y+2 SAY "Timeout fiskalnih operacija:" ;
		GET gFC_tout PICT "9999"
	
	++ nX

	@ m_x+nX, m_y+2 SAY "Pitanje prije stampe ?" GET gFC_Pitanje ;
			VALID gFC_pitanje $ "DN" PICT "@!"
		
	@ m_x+nX, col()+2 SAY "Konverzija znakova (0-8)" GET gFC_Konv ;
			VALID gFC_Konv $ "012345678"
		
	++ nX
	++ nX
	
	@ m_x+nX, m_y+2 SAY "Stampanje zbirnog racuna u VP (0/1/...)" ;
			GET gFC_zbir ;
			VALID gFC_zbir >= 0 PICT "999"

	++ nX

	@ m_x+nX, m_y+2 SAY "Stampa broja racuna ?" GET gFC_nftxt ;
			VALID gFC_nftxt $ "DN" PICT "@!"
	
	++ nX
	
	@ m_x+nX, m_y+2 SAY "Stampati racun nakon stampe fiskalnog racuna ?" ;
			GET gFC_faktura ;
			VALID gFC_faktura $ "DN" PICT "@!"
	
	++ nX
	++ nX

	@ m_x+nX, m_y+2 SAY "Provjera kolicine i cijene (1/2)" ;
		GET gFC_chk ;
		VALID gFC_chk $ "12" PICT "@!"
	
	@ m_x+nX, col()+1 SAY "Automatski polog:" ;
		GET gFC_pauto ;
		PICT "999999.99"

	++ nX

	@ m_x+nX, m_y+2 SAY "'kod' artikla [P/D]Plu, [I]Id, [B]Barkod:" ;
			GET gFC_acd VALID gFC_acd $ "PIBD" PICT "@!"

	++ nX
	
	@ m_x+nX, m_y+2 SAY "inicijalni PLU" ;
			GET gFC_pinit PICT "99999"


	++ nX
	
	@ m_x+nX, m_y+2 SAY "Koristiti listu uredjaja ?" GET gFc_dlist ;
		VALID gFc_dlist $ "DN" PICT "@!"

	++ nX

	@ m_x+nX, m_y+2 SAY "Koristiti fiskalne funkcije ?" GET gFc_use ;
		VALID gFc_use $ "DN" PICT "@!"

  	read

BoxC()

if (LASTKEY() <> K_ESC)
	Wpar("f1",gFc_use)
   	Wpar("f2",gFC_path)
   	Wpar("f3",gFC_pitanje)
   	Wpar("f4",gFC_tout)
   	Wpar("f5",gFC_Konv)
	WPar("f6",gFC_type)
	WPar("f7",gFC_name)
	WPar("f8",gFC_error)
	WPar("f9",gFC_cmd)
	WPar("f0",gFC_cp1)
	WPar("fa",gFC_cp2)
	WPar("fb",gFC_cp3)
	WPar("fc",gFC_cp4)
	WPar("fd",gFC_cp5)
	WPar("fe",gFC_addr)
	WPar("ff",gFC_port)
	WPar("fi",giosa)
	WPar("fj",gFC_alen)
	WPar("fn",gFC_nftxt)
	WPar("fC",gFC_acd)
	WPar("fO",gFC_pdv)
	WPar("fD",gFC_device)
	WPar("fT",gFC_pinit)
	WPar("fX",gFC_chk)
	WPar("fZ",gFC_faktura)
	WPar("fk",gFC_zbir)
	WPar("fS",gFC_path2)
	WPar("fK",gFC_dlist)
	WPar("fA",gFC_pauto)
	WPar("fB",gFC_answ)
	WPar("fY",gFC_serial)

endif

return 


/*! \fn SetRazno()
 *  \brief Podesenja parametri-razno
 */
function SetRazno()
private cSection:="1"
private cHistory:=" "
private aHistory:={}
private GetList:={}

O_PARAMS

gKomLin:=PADR(gKomLin,70)

Box(,21,77,.f.,"OSTALI PARAMETRI (RAZNO)")

nX := 2
if !IsPdv()
	@ m_x+nX, m_y+2 SAY "Naziv fajla zaglavlja (prazno bez zaglavlja)" GET gVlZagl VALID V_VZagl()
	nX++
	@ m_x+nX, m_y+2 SAY "Novi korisnicki interfejs D-da/N-ne/R-rudnik/T-test" GET gNW VALID gNW $ "DNRT" PICT "@!"
	nX++
  	@ m_x+nX, m_y+2 SAY "Svaki izlazni fajl ima posebno ime ?" GET gImeF VALID gImeF $ "DN"
	nX++
	
  	@ m_x+nX, m_y+2 SAY "Komandna linija za RTF fajl:" GET gKomLin PICT "@S40"
	nX++
endif

  	@ m_x+nX, m_y+2 SAY "Inicijalna meni-opcija (1/2/.../G)" GET gIMenu VALID gIMenu $ "123456789ABCDEFG" PICT "@!"
	nX := nX+3
	
if !IsPdV()
  	@ m_x+nX,m_y+2 SAY "Prikaz K1" GET gDk1 PICT "@!" VALID gDk1 $ "DN"
  	@ m_x+nX,col()+2 SAY "Prikaz K2" GET gDk2 PICT "@!" VALID gDk2 $ "DN"
	nX++
  	@ m_x+nX,m_y+2 SAY "Mjesto uzimati iz RJ (D/N)" GET gMjRJ PICT "@!" VALID gMjRJ $ "DN"
	nX++
endif
	
  	@ m_x+nX,m_y+2 SAY "Omoguciti poredjenje FAKT sa FAKT druge firme (D/N) ?" GET gFaktFakt VALID gFaktFakt $ "DN" PICT "@!"
	nX++
  	@ m_x+nX,m_y+2 SAY "Koriste li se artikli koji se vode po sintet.sifri, roba tipa 'S' (D/N) ?" GET gNovine VALID gNovine $ "DN" PICT "@!"
	nX++
  	@ m_x+nX, m_y+2 SAY "Duzina sifre artikla sinteticki " GET gnDS VALID gnDS>0 PICT "9"
	nX++

  	@ m_x+nX, m_y+2 SAY "Obrazac narudzbenice " GET gFNar VALID V_VNar()
	nX++
	
  	@ m_x+nX, m_y+2 SAY "Obrazac ugovor rabat " GET gFUgRab VALID V_VUgRab()
	nX++

  	@ m_x+nX, m_y+2 SAY "Voditi samo kolicine " GET gSamoKol PICT "@!" VALID gSamoKol $ "DN"
	nX++
	
  	@ m_x+nX, m_y+2 SAY "Tekuca vrijednost za rok placanja  " GET gRokPl PICT "999"
	nX++
	
	if !IsPDV()
  		@ m_x+nX, m_y+2 SAY "Mogucnost ispravke partnera u novoj stavci (D/N)" GET gIspPart PICT "@!" VALID gIspPart$"DN"
		nX++
	else
		gIspPart := "N"
	endif
	
	@ m_x + nX, m_y+2 SAY "Uvijek resetuj artikal pri unosu dokumenata (D/N)" GET gResetRoba PICT "@!" VALID gResetRoba $ "DN"

	nX ++

	@ m_x + nX, m_y + 2 SAY "Ispis racuna MP na traku (D/N/X)" ;
		GET gMPPrint ;
		PICT "@!" ;
		VALID gMPPrint $ "DNXT"

	read

	if gMPPrint $ "DXT"

		nX ++
		
		@ m_x + nX, m_y + 2 SAY "Oznaka lokalnog porta za stampu: LPT" ;
			GET gMPLocPort ;
			VALID gMPLocPort $ "1234567" PICT "@!"
		
		nX ++
		
		@ m_x + nX, m_y + 2 SAY "Redukcija trake (0/1/2):" ;
			GET gMPRedTraka ;
			VALID gMPRedTraka $ "012"
	
		nX ++
	
		@ m_x + nX, m_y + 2 SAY "Ispis id artikla na racunu (D/N):" ;
			GET gMPArtikal ;
			VALID gMPArtikal $ "DN" PICT "@!"
		
		nX ++
	
		@ m_x + nX, m_y + 2 SAY "Ispis cjene sa pdv (2) ili bez (1):" ;
			GET gMPCjenPDV ;
			VALID gMPCjenPDV $ "12"
	

		read

	endif

BoxC()


gKomLin:=TRIM(gKomLin)

if (LASTKEY()<>K_ESC)
	Wpar("ff",gFaktFakt)
   	Wpar("nw",gNW)
   	Wpar("NF",gFNar)
   	Wpar("UF",gFUgRab)
   	Wpar("sk",gSamoKol)
   	Wpar("rP",gRokPl)
   	Wpar("no",gNovine)
   	Wpar("ds",gnDS)
   	WPar("vz",gVlZagl)
   	WPar("if",gImeF)
   	WPar("95",gKomLin)   
   	WPar("k1",@gDk1)
   	WPar("k2",@gDk2)
   	WPar("im",gIMenu)
   	WPar("mr",gMjRJ)
   	WPar("Fi",@gIspPart)
   	WPar("Fr",@gResetRoba)
   	WPar("mP",gMpPrint)
   	WPar("mL",gMpLocPort)
   	WPar("mT",gMpRedTraka)
	WPar("mA",gMpArtikal)
	WPar("mC",gMpCjenPDV)

endif

return 


// ---------------------------------------------
// ---------------------------------------------
function ZaglParams()
local nSay := 17
local sPict := "@S55"
local nX := 1
private cSection:="1"
private cHistory:=" "
private aHistory:={}
private GetList:={}

O_PARAMS

UsTipke()

gFIdBroj := PADR(gFIdBroj, 13)
gFText1 := PADR(gFText1, 72)
gFText2 := PADR(gFText2, 72)
gFText3 := PADR(gFText3, 72)
gFTelefon := PADR(gFTelefon, 72)
gFEmailWeb := PADR(gFEmailWeb, 72)

Box( , 21, 77, .f., "Izgleda dokumenata - zaglavlje")

	// opci podaci
	@ m_x+nX, m_y+2 SAY PADL("Puni naziv firme:", nSay) GET gFNaziv ;
		PICT sPict
	nX++
	
	@ m_x+nX, m_y+2 SAY PADL("Dodatni opis:", nSay) GET gFPNaziv ;
		PICT sPict
	nX++

	@ m_x+nX, m_y+2 SAY PADL("Adresa firme:", nSay) GET gFAdresa ;
		PICT sPict 
	nX++
	
  	@ m_x+nX, m_y+2 SAY PADL("Ident.broj:", nSay) GET gFIdBroj
	nX++
	
	@ m_x+nX, m_y+2 SAY PADL("Telefoni:", nSay) GET gFTelefon ;
		PICT sPict 
	nX++
	
	@ m_x+nX, m_y+2 SAY PADL("email/web:", nSay) GET gFEmailWeb ;
		PICT sPict 
	nX++
	
  	// banke
	@ m_x+nX,  m_y+2 SAY PADL("Banka 1:", nSay) GET gFBanka1 ;
		PICT sPict
	nX++
	
  	@ m_x+nX,  m_y+2 SAY PADL("Banka 2:", nSay) GET gFBanka2 ;
		PICT sPict
	nX++
	
  	@ m_x+nX, m_y+2 SAY PADL("Banka 3:", nSay) GET gFBanka3 ;
		PICT sPict
	nX++
	
  	@ m_x+nX, m_y+2 SAY PADL("Banka 4:", nSay) GET gFBanka4 ;
		PICT sPict
	nX++
	
  	@ m_x+nX, m_y+2 SAY PADL("Banka 5:", nSay) GET gFBanka5 ;
		PICT sPict
	nX += 2
	
	// dodatni redovi
  	@ m_x+nX, m_y+2 SAY "Proizvoljan sadrzaj na kraju"
	nX++
	
  	@ m_x+nX, m_y+2 SAY PADL("Red 1:", nSay) GET gFText1 ;
		PICT sPict
	nX++
	
	
  	@ m_x+nX, m_y+2 SAY PADL("Red 2:", nSay) GET gFText2 ;
		PICT sPict
	nX++
	
  	@ m_x+nX, m_y+2 SAY PADL("Red 3:", nSay) GET gFText3 ;
		PICT sPict
	nX += 2

	@ m_x+ nX, m_y+2 SAY "Koristiti tekstualno zaglavlje (D/N)?" GET gStZagl ;
		VALID gStZagl $ "DN" PICT "@!"

	nX += 2
	
	@ m_x + nX, m_y+2 SAY PADL("Slika na vrhu fakture (redova):", nSay + 15) GET gFPicHRow PICT "99"
	
	nX += 1
	
	@ m_x + nX, m_y+2 SAY PADL("Slika na dnu fakture (redova):", nSay + 15) GET gFPicFRow PICT "99"
  	read
	
BoxC()

if (LASTKEY() <> K_ESC)
	Wpar("F1",gFNaziv)
	Wpar("f1",gFPNaziv)
   	Wpar("F2",gFAdresa)
   	Wpar("F3",gFIdBroj)
   	Wpar("F9",gFBanka1)
   	Wpar("G1",gFBanka2)
   	Wpar("G2",gFBanka3)
   	Wpar("G3",gFBanka4)
   	Wpar("G4",gFBanka5)
   	Wpar("G5",gFTelefon)
	Wpar("G6",gFEmailWeb)
   	Wpar("G7",gFText1)
	Wpar("G8",gFText2)
	Wpar("G9",gFText3)
	Wpar("Z1",gStZagl)
	Wpar("Z2",gFPicHRow)
	Wpar("Z3",gFPicFRow)
endif

return 




*string Params_s7;
/*! \ingroup params
 *  \var Params_s7
 *  \brief Grad tj.mjesto u kojem je firma
 *  \param Zenica - u Zenici
 *  \note gMjStr
 */


*string Params_fi;
/*! \ingroup params
 *  \var Params_fi
 *  \brief Sifra firme/default radne jedinice
 *  \param 10 - sifra firme ili default radne jedinice je 10
 *  \note gFirma
 */


*string Params_ts;
/*! \ingroup params
 *  \var Params_ts
 *  \brief Tip poslovnog subjekta
 *  \param Preduzece - znaci da se radi o preduzecu
 *  \note gTS
 */


*string Params_fn;
/*! \ingroup params
 *  \var Params_fn
 *  \brief Naziv firme
 *  \param SIGMA-COM - naziv firme je SIGMA-COM
 *  \note gNFirma
 */


*string Params_Bv;
/*! \ingroup params
 *  \var Params_Bv
 *  \brief Bazna valuta
 *  \param D - domaca
 *  \param P - pomocna
 *  \note gBaznaV
 */


*string Params_mV;
/*! \ingroup params
 *  \var Params_mV
 *  \brief Koristiti modemsku vezu?
 *  \param S - da, server
 *  \param K - da, korisnik
 *  \param N - ne koristiti modemsku vezu
 *  \note gModemVeza
 */


/*! \fn SetFirma()
 *  \brief Podesenje osnovnih parametara o firmi
 */
 
function SetFirma()
private  GetList:={}

O_PARAMS

gMjStr:=PADR(gMjStr,20)

Box(, 6, 60, .f.,"Podaci o maticnoj firmi")
	@ m_x+2,m_y+2 SAY "Firma: " GET gFirma
  	@ m_x+3,m_y+2 SAY "Naziv: " GET gNFirma
  	@ m_x+3,col()+2 SAY "TIP SUBJ.: " GET gTS
  	@ m_x+4,m_y+2 SAY "Grad" GET gMjStr
  	//@ m_x+5,m_y+2 SAY "Bazna valuta (Domaca/Pomocna)" GET gBaznaV  VALID gBaznaV $ "DP"  PICT "!@"
  	@ m_x+6,m_y+2 SAY "Koristiti modemsku vezu S-erver/K-orisnik/N" GET gModemVeza VALID gModemVeza $ "SKN"  PICT "!@"
  	READ
BoxC()

gMjStr:=TRIM(gMjStr)

// bazna valuta uvijek domaca
gBaznaV := "D"

if (LASTKEY()<>K_ESC)
	WPar("s7",gMjStr)
  	Wpar("fi",gFirma)
  	Wpar("ts",gTS)
  	Wpar("fn",gNFirma)
  	Wpar("Bv",gBaznaV)
  	WPar("mV",gModemVeza)
endif

return



*string Params_p0;
/*! \ingroup params
 *  \var Params_p0
 *  \brief Format prikaza cijena
 *  \param 99999.999 - 5 mjesta za cijeli i 3 za decimalni dio broja
 *  \note PicCDem
 */


*string Params_p1;
/*! \ingroup params
 *  \var Params_p1
 *  \brief Format prikaza iznosa
 *  \param 99999.999 - 5 mjesta za cijeli i 3 za decimalni dio broja
 *  \note PicDem
 */


*string Params_p2;
/*! \ingroup params
 *  \var Params_p2
 *  \brief Format prikaza kolicina
 *  \param 99999.999 - 5 mjesta za cijeli i 3 za decimalni dio broja
 *  \note PicKol
 */


/*! \fn SetPict()
 *  \brief Podesenje Pict iznosa, kolicine, ...
 */
 
function SetPict()
*{
local nX

private  GetList:={}

O_PARAMS

PicKol:=STRTRAN(PicKol,"@Z ","")

nX:=1
Box(, 6, 60, .f.,"PARAMETRI PRIKAZA")

	@ m_x+nX,m_y+2 SAY "Prikaz cijene   " GET PicCDem
	nX++
	
  	@ m_x+nX, m_y+2 SAY "Prikaz iznosa   " GET PicDem
	nX++
	
  	@ m_x+nX, m_y+2 SAY "Prikaz kolicine " GET PicKol
	nX++

  	@ m_x+nX, m_y+2 SAY "Na kraju fakture izvrsiti zaokruzenje" GET gFZaok PICT "99"
	nX++
  	
	@ m_x+nX, m_y+2 SAY "Zaokruzenje 5 pf (D/N)?" GET gZ_5pf PICT "@!" ;
		VALID gZ_5pf $ "DN"


  	read
BoxC()

if (LASTKEY()<>K_ESC)
   	WPar("p0", PicCDem)
   	WPar("p1", PicDem)
   	WPar("p2", PicKol)
   	WPar("fz", gFZaok)
   	WPar("mZ", gZ_5pf)
endif

return 
*}


*string Params_dp;
/*! \ingroup params
 *  \var Params_dp
 *  \brief Omoguciti unos datuma placanja, broja otpremnice i broja narudzbe?
 *  \param 1 - da
 *  \param 2 - ne
 *  \note gDodPar
 */


*string Params_dv;
/*! \ingroup params
 *  \var Params_dv
 *  \brief Omoguciti unos datuma placanja u svim varijantama izgleda fakture 9?
 *  \param D - da
 *  \param N - ne
 *  \note gDatVal
 */


*string Params_pd;
/*! \ingroup params
 *  \var Params_pd
 *  \brief Generisati ulazni dokument (01) pri azuriranju izlaza (13-ke)?
 *  \param D - da
 *  \param N - ne
 *  \note gProtu13
 */


*string Params_mn;
/*! \ingroup params
 *  \var Params_mn
 *  \brief Ukljuciti mreznu numeraciju dokumenata?
 *  \param D - da
 *  \param N - ne
 *  \note gMreznoNum
 */


*string Params_dc;
/*! \ingroup params
 *  \var Params_dc
 *  \brief Maloprodajna cijena koja se koristi u 13-ki
 *  \param   - uvijek pri stampi pita za cijenu koja se zeli prikazati
 *  \param 1 - MPC
 *  \param 2 - MPC2
 *  \param 6 - MPC6
 *  \note g13dcij
 */


*string Params_vo;
/*! \ingroup params
 *  \var Params_vo
 *  \brief Varijanta dokumenta 13
 *  \param 1 - default varijanta
 *  \param 2 - varijanta radjena za Niagaru i Lagunu
 *  \note gVar13
 */


*string Params_vn;
/*! \ingroup params
 *  \var Params_vn
 *  \brief Varijanta numeracije dokumenta 13 za varijantu 2 dokumenta 13
 *  \param 1 - Laguna: unosi se RJ koja se zaduzuje a na osnovu tog podatka se iz sifrarnika RJ uzme konto i upise u polje IDPARTNER
 *  \param 2 - Niagara: unosi se konto prodavnice koja se zaduzuje, a brojac je u formi KKNN/MM gdje je KK oznaka prodavnice a odredjuje se kao zadnji dio konta pocevsi od 4.mjesta (13201->01,1329->09), NN je redni broj sa nulom ispred ako je manji od 10 (01,02,...,10,11,...), a MM je mjesec u kojem se pravi dokument (01,02,...,12)
 *  \note gVarNum
 */


*string Params_pk;
/*! \ingroup params
 *  \var Params_pk
 *  \brief Da li se prati trenutno stanje artikla pri unosu dokumenta?
 *  \param D - da
 *  \param N - ne
 *  \note gPratiK
 */


*string Params_50;
/*! \ingroup params
 *  \var Params_50
 *  \brief Varijante koristenja cijene
 *  \param   - samo VPC
 *  \param 1 - VPC ili VPC2
 *  \param 2 - VPC ili VPC2 
 *  \param 3 - NC
 *  \param 4 - uporedo se prikazuje MPC
 *  \param X - samo MPC
 *  \note gVarC
 */


*string Params_mp;
/*! \ingroup params
 *  \var Params_mp
 *  \brief Koja se cijena nudi u fakturi maloprodaje (11-ki) ?
 *  \param 1 - MPC
 *  \param 2 - VPC+porezi (diskontna cijena)
 *  \param 3 - MPC2
 *  \param 4 - MPC3
 *  \param 5 - MPC4
 *  \param 6 - MPC5
 *  \param 7 - MPC6
 *  \note gMP
 */


*string Params_nd;
/*! \ingroup params
 *  \var Params_nd
 *  \brief Numericki dio broja dokumenta za automatiku odredjivanja narednog broja dokumenta
 *  \param 5 - prvih 5 znakova
 *  \note gNumDio
 */


*string Params_PR;
/*! \ingroup params
 *  \var Params_PR
 *  \brief Upozorenje na promjenu radne jedinice ?
 *  \param D - da, da se ne bi slucajnom greskom upisala pogresna radna jedinica
 *  \param N - ne upozoravaj
 *  \note gDetPromRj
 */


*string Params_vp;
/*! \ingroup params
 *  \var Params_vp
 *  \brief U otpremnici (12-ki) omoguciti unos poreza ?
 *  \param D - da
 *  \param N - ne
 *  \note gV12Por
 */


*string Params_vu;
/*! \ingroup params
 *  \var Params_vu
 *  \brief Varijanta fakturisanja na osnovu ugovora
 *  \param 1 - ugovori se sortiraju po siframa, tekuce postavke
 *  \param 2 - ugovori se sortiraju po nazivima izuzev kod pregleda sifrarnika kroz meni sifrarnika (tada je sortiranje po siframa)
 *  \note gVFU
 */


/*! \fn SetVarijante()
 *  \brief Podesenje varijante obrade dokumenata
 */
 
function SetVarijante()
*{
private  GetList:={}

O_PARAMS

Box(, 23, 76, .f., "VARIJANTE OBRADE DOKUMENATA")
	@ m_x+1,m_y+2 SAY "Unos Dat.pl, otpr., narudzbe D/N (1/2) ?" GET gDoDPar VALID gDodPar $ "12" PICT "@!"
  	@ m_x+1,m_y+46 SAY "Dat.pl.u svim v.f.9 (D/N)?" GET gDatVal VALID gDatVal $ "DN" PICT "@!"
  	@ m_x+2,m_y+2 SAY "Generacija ulaza prilikom izlaza 13" GET gProtu13 VALID gProtu13 $ "DN" PICT "@!"
  	@ m_x+3,m_y+2 SAY "Mrezna numeracija dokumenata D/N" GET gMreznoNum PICT "@!" VALID gMreznoNum $ "DN"
  	@ m_x+4,m_y+2 SAY "Maloprod.cijena za 13-ku ( /1/2/3/4/5/6)   " GET g13dcij VALID g13dcij$" 123456"
  	@ m_x+5,m_y+2 SAY "Varijanta dokumenta 13 (1/2)   " GET gVar13 VALID gVar13$"12"
  	@ m_x+6,m_y+2 SAY "Varijanta numeracije dokumenta 13 (1/2)   " GET gVarNum VALID gVarNum$"12"
  	@ m_x+7,m_y+2 SAY "Pratiti trenutnu kolicinu D/N ?" GET gPratiK PICT "@!" VALID gPratiK $ "DN"
  	@ m_x+7,col()+1 SAY "Pratiti cijene na unosu D/N ?" GET gPratiC PICT "@!" VALID gPratiC $ "DN"
	@ m_x+8,m_y+2 SAY  "Koristenje VP cijene:"
  	@ m_x+9,m_y+2 SAY  "  ( ) samo VPC   (X) koristiti samo MPC    (1) VPC1/VPC2 "
  	@ m_x+10,m_y+2 SAY "  (2) VPC1/VPC2 putem rabata u odnosu na VPC1   (3) NC "
  	@ m_x+11,m_y+2 SAY "  (4) Uporedo vidi i MPC............" GET gVarC
  	@ m_x+12,m_y+2 SAY "U fakturi maloprodaje koristiti:"
  	@ m_x+13,m_y+2 SAY "  (1) MPC iz sifrarnika  (2) VPC + PPP + PPU   (3) MPC2 "
  	@ m_x+14,m_y+2 SAY "  (4) MPC3  (5) MPC4  (6) MPC5  (7) MPC6 ....." GET gMP VALID gMP $ "1234567"
  	@ m_x+15,m_y+2 SAY "Numericki dio broja dokumenta:" GET gNumDio PICT "99"
  	@ m_x+16,m_y+2 SAY "Upozorenje na promjenu radne jedinice:" GET gDetPromRj PICT "@!" VALID gDetPromRj $ "DN"
  	@ m_x+17,m_y+2 SAY "Var.otpr.-12 sa porezom :" GET gV12Por PICT "@!" VALID gV12Por $ "DN"
  	@ m_x+17,m_y+35 SAY "Var.fakt.po ugovorima (1/2) :" GET gVFU PICT "9" VALID gVFU $ "12"
  	@ m_x+18,m_y+2 SAY "Var.fakt.rok plac. samo vece od 0 :" GET gVFRP0 PICT "@!" VALID gVFRP0 $ "DN"
	@ m_x+19,m_y+2 SAY "Koristiti C1 (D/N)?" GET gKarC1 PICT "@!" VALID gKarC1$"DN"
  	@ m_x+19,col()+2 SAY "C2 (D/N)?" GET gKarC2 PICT "@!" VALID gKarC2$"DN"
  	@ m_x+19,col()+2 SAY "C3 (D/N)?" GET gKarC3 PICT "@!" VALID gKarC3$"DN"
  	@ m_x+19,col()+2 SAY "N1 (D/N)?" GET gKarN1 PICT "@!" VALID gKarN1$"DN"
  	@ m_x+19,col()+2 SAY "N2 (D/N)?" GET gKarN2 PICT "@!" VALID gKarN2$"DN"
  	@ m_x+20,m_y+2 SAY "Prikaz samo kolicina na dokumentima (0/D/N)" GET gPSamoKol PICT "@!" VALID gPSamoKol $ "0DN"
	@ m_x+21,m_y+2 SAY "Pretraga artikla po indexu:" GET gArtCdx PICT "@!"
	@ m_x+22,m_y+2 SAY "Koristiti rabat iz sif.robe (polje N1) ?" GET gRabIzRobe PICT "@!" VALID gRabIzRobe $ "DN"
	@ m_x+23,m_y+2 SAY "Brisi direktno u smece" GET gcF9usmece PICT "@!" VALID gcF9usmece $ "DN"
	@ m_x+23,col()+2 SAY "Timeout kod azuriranja" GET gAzurTimeout PICT "9999" 
	@ m_x+23,col()+2 SAY "Email info" GET gEmailInfo ;
		VALID gEmailInfo $ "DN" PICT "!@" 
	
	read
BoxC()

if (LASTKEY()<>K_ESC)
	WPar("dp",gDodPar)
   	WPar("dv",gDatVal)
   	WPar("pd",gProtu13)
   	WPar("mn",gMreznoNum)
   	WPar("dc",g13dcij)
   	WPar("vo",gVar13)
   	WPar("vn",gVarNum)
   	WPar("pk",gPratik)
   	WPar("pc",gPratiC)
   	WPar("50",gVarC)
   	WPar("mp",gMP)  // varijanta maloprodajne cijene
   	WPar("nd",gNumdio)
   	WPar("PR",gDetPromRj)
   	WPar("vp",gV12Por)
   	WPar("vu",gVFU)
   	WPar("v0",gVFRP0)
   	WPar("g1",gKarC1)
   	WPar("g2",gKarC2)
   	WPar("g3",gKarC3)
   	WPar("g4",gKarN1)
   	WPar("g5",gKarN2)
   	WPar("g6",gPSamoKol)
	WPar("gC",gArtCDX)
	WPar("gE",gEmailInfo)
	WPar("rR",gRabIzRobe)
	WPar("Fx",gcF9usmece)
	WPar("Fz",gAzurTimeout)
  	
endif

return 


*string Params_c1;
/*! \ingroup params
 *  \var Params_c1
 *  \brief Prikaz cijena u podstavkama ili u glavnim stavkama ?
 *  \param 1 - u podstavkama
 *  \param 2 - u glavnim stavkama
 *  \note cIzvj
 */


*string Params_tf;
/*! \ingroup params
 *  \var Params_tf
 *  \brief Varijanta izgleda fakture
 *  \param 1 -
 *  \param 2 -
 *  \param 3 -
 *  \note gTipF
 */


*string Params_vf;
/*! \ingroup params
 *  \var Params_vf
 *  \brief Podvarijanta izgleda fakture
 *  \param 1 -
 *  \param 2 -
 *  \param 3 -
 *  \param 4 -
 *  \param 9 -
 *  \param A -
 *  \param B -
 *  \note gVarF
 */


*string Params_kr;
/*! \ingroup params
 *  \var Params_kr
 *  \brief Broj redova za vertikalno pomjeranje znakova krizanja i broja dokumenta u podvarijanti 9 izgleda fakture na A4 papiru
 *  \param 0 - ne pomjeraj nista
 *  \note gKriz
 */


*string Params_55;
/*! \ingroup params
 *  \var Params_55
 *  \brief Broj redova za vertikalno pomjeranje znakova krizanja i broja dokumenta u podvarijanti 9 izgleda fakture na A5 papiru
 *  \param 0 - ne pomjeraj nista
 *  \note gKrizA5
 */


*string Params_vr;
/*! \ingroup params
 *  \var Params_vr
 *  \brief Podvarijanta izgleda RTF fakture za varijantu 2 izgleda fakture
 *  \param   - (prazno), default varijanta
 *  \param 1 - za Minex
 *  \param 2 - za Likom
 *  \param 3 - za Zenelu
 *  \note gVarRF
 */


*string Params_er;
/*! \ingroup params
 *  \var Params_er
 *  \brief Broj dodatnih redova dokumenta po listu
 *  \param
 *  \note gERedova
 */


*string Params_pr;
/*! \ingroup params
 *  \var Params_pr
 *  \brief Lijeva margina za stampanje dokumenata (broj kolona)
 *  \param 4 - odvoji slijeva 4 kolone
 *  \note gnLMarg
 */


*string Params_56;
/*! \ingroup params
 *  \var Params_56
 *  \brief Lijeva margina za stampanje dokumenata u varijanti 2 podvarijanta 9 za A5 papir (broj kolona)
 *  \param 4 - odvoji slijeva 4 kolone
 *  \note gnLMargA5
 */


*string Params_pt;
/*! \ingroup params
 *  \var Params_pt
 *  \brief Gornja margina pri stampanju dokumenata (broj redova). Koristi se samo ako nije definisan fajl zaglavlja
 *  \param 9 - odmakni 9 redova od pocetka lista
 *  \note gnTMarg
 */


*string Params_a5;
/*! \ingroup params
 *  \var Params_a5
 *  \brief Moze li se koristiti obrazac A5 u podvarijanti 9 ?
 *  \param D - uz upit da, ponudjeni odgovor na upit je uvijek "D"
 *  \param N - uz upit da, ali ponudjeni odgovor na upit je uvijek "N"
 *  \param 0 - ne, nema ni upita
 *  \note gFormatA5
 */


*string Params_fp;
/*! \ingroup params
 *  \var Params_fp
 *  \brief Horizontalno pomjeranje zaglavlja u podvarijanti 9 za A4 papir (broj kolona)
 *  \param 2 - pomjeriti dvije kolone udesno
 *  \note gFPzag
 */


*string Params_51;
/*! \ingroup params
 *  \var Params_51
 *  \brief Horizontalno pomjeranje zaglavlja u podvarijanti 9 za A5 papir (broj kolona)
 *  \param 2 - pomjeriti dvije kolone udesno
 *  \note gFPzagA5
 */


*string Params_52;
/*! \ingroup params
 *  \var Params_52
 *  \brief Vertikalno pomjeranje stavki u podvarijanti 9 za A5 papir (broj redova)
 *  \param 2 - pomjeriti dva reda prema dolje
 *  \note gnTMarg2A5
 */


*string Params_53;
/*! \ingroup params
 *  \var Params_53
 *  \brief Vertikalno pomjeranje totala u podvarijanti 9 za A5 papir (broj redova)
 *  \param 2 - pomjeriti dva reda prema dolje
 *  \note gnTMarg3A5
 */


*string Params_54;
/*! \ingroup params
 *  \var Params_54
 *  \brief Vertikalno pomjeranje donjeg dijela fakture u podvarijanti 9 za A5 papir (broj redova)
 *  \param 2 - pomjeriti dva reda prema dolje
 *  \note gnTMarg4A5
 */


*string Params_d1;
/*! \ingroup params
 *  \var Params_d1
 *  \brief Vertikalno pomjeranje stavki u podvarijanti 9 za A4 papir (broj redova)
 *  \param 2 - pomjeriti dva reda prema dolje
 *  \note gnTMarg2
 */


*string Params_d2;
/*! \ingroup params
 *  \var Params_d2
 *  \brief Vertikalno pomjeranje totala u podvarijanti 9 za A4 papir (broj redova)
 *  \param 2 - pomjeriti dva reda prema dolje
 *  \note gnTMarg3
 */


*string Params_d3;
/*! \ingroup params
 *  \var Params_d3
 *  \brief Vertikalno pomjeranje donjeg dijela fakture u podvarijanti 9 za A4 papir (broj redova)
 *  \param 2 - pomjeriti dva reda prema dolje
 *  \note gnTMarg4
 */


*string Params_cr;
/*! \ingroup params
 *  \var Params_cr
 *  \brief Znak kojim se precrtava dio teksta na obrascu fakture (podvarijanta 9)
 *  \param X - precrtavati znakom X
 *  \note gZnPrec
 */


*string Params_ot;
/*! \ingroup params
 *  \var Params_ot
 *  \brief Broj redova za odvajanje tabele od broja dokumenta
 *  \param 3 - odvojiti 3 reda
 *  \note gOdvT2
 */


*integer Params_tb;
/*! \ingroup params
 *  \var Params_tb
 *  \brief Nacin crtanja tabele koji se koristi pri stampanju sifrarnika i u pojedinim izvjestajima i dokumentima
 *  \param 0 - koristi se samo znak "-" (minus) za iscrtavanje horizontalnih linija, a vertikale se ne iscrtavaju
 *  \param 1 - sve se crta jednostrukom linijom
 *  \param 2 - okvir tabele se crta dvostrukom linijom, a ostalo jednostrukom
 *  \note gTabela
 *  \sa StampaTabele()
 */


*string Params_za;
/*! \ingroup params
 *  \var Params_za
 *  \brief Da li se zaglavlje dokumenta ispisuje na svakoj stranici?
 *  \param D - da
 *  \param N - ne
 *  \note gZagl
 */


*string Params_zb;
/*! \ingroup params
 *  \var Params_zb
 *  \brief Crni tj."masni" ispis dokumenta ?
 *  \param 1 - da
 *  \param 2 - ne
 *  \note gbold
 */


*string Params_RT;
/*! \ingroup params
 *  \var Params_RT
 *  \brief Prikaz rekapitulacije po tarifama u dokumentu 13-ki ?
 *  \param D - da
 *  \param N - ne
 *  \note gRekTar
 */


*string Params_HL;
/*! \ingroup params
 *  \var Params_HL
 *  \brief Ispis horizontalnih linija izmedju stavki dokumenta?
 *  \param D - da
 *  \param N - ne
 *  \note gHLinija
 */


*string Params_rp;
/*! \ingroup params
 *  \var Params_rp
 *  \brief Prikaz rabata u % (procentu) ?
 *  \param D - da
 *  \param N - ne
 *  \note gRabProc
 */


/*! \fn SetT1()
 *  \brief Varijante izgleda dokumenta
 */
 
function SetT1()
*{
local nX

local nDx1 := 0
local nDx2 := 0
local nDx3 := 0

local nSw1 := 72
local nSw2 := 1
local nSw3 := 72
local nSw4 := 31
local nSw5 := 1
local nSw6 := 1
local nSw7 := 0

private GetList:={}
private cIzvj:="1"

O_PARAMS

if ValType(gTabela)<>"N"
	gTabela:=1
endif

RPar("c1",@cIzvj)

cSection := "F"
RPar("x1", @nDx1)
RPar("x2", @nDx2)
RPar("x3", @nDx3)
RPar("x4", @nSw1)
RPar("x5", @nSw2)
RPar("x6", @nSw3)
RPar("x7", @nSw4)
RPar("x8", @nSw5)
RPar("x9", @nSw6)
RPar("y1", @nSw7)

cSection := "1"

nX:=2
Box(,22,76,.f.,"Izgled dokumenata")

       if !IsPdv()
	@ m_x + nX, m_y+2 SAY "Prikaz cijena podstavki/cijena u glavnoj stavci (1/2)" GET cIzvj
	nX++
  	
 	 @ m_x + nX, m_y+2 SAY "Izgled fakture 1/2/3" GET gTipF VALID gTipF $ "123"
	 nX++
  	 @ m_x + nX, m_y+2 SAY "Varijanta 1/2/3/4/9/A/B" GET gVarF VALID gVarF $ "12349AB"
	 nX++
	endif
	
  	@ m_x + nX, m_y+2 SAY "Dodat.redovi po listu " GET gERedova ;
	     PICT "999"
	nX++
  	@ m_x + nX, m_y+2 SAY "Lijeva margina pri stampanju " GET gnLMarg PICT "99"
	nX++
  	
	// legacy
	if !IsPdv()
	 @ m_x+ nX, m_y+35 SAY "L.marg.za v.2/9/A5 " GET gnLMargA5 PICT "99"
	 nX++
	endif
	
  	@ m_x+ nX, m_y+2 SAY "Gornja margina " GET gnTMarg PICT "99"
	nX++

	// legacy
	if !IsPdv()
  	 @ m_x + nX, m_y+2 SAY "Koristiti A5 obrazac u varijanti 9 D/N/0" GET gFormatA5 PICT "@!" VALID gFormatA5 $ "DN0"
	 nX++
	
  	 @ m_x+ nX, m_y+58 SAY "A4   A5"
	 nX++
  	 @ m_x+ nX, m_y+2 SAY "Horizont.pomjeranje zaglavlja u varijanti 9 (br.kolona)" GET gFPzag PICT "99"
  	 @ m_x+ nX, m_y+63 GET gFPzagA5 PICT "99"
	 nX++
  	 @ m_x + nX, m_y+2 SAY "Vertikalno pomjeranje stavki u fakturi var.9(br.redova)" GET gnTmarg2 PICT "99"
  	 @ m_x + nX, m_y+63 GET gnTmarg2A5 PICT "99"
	 nX++
  	 @ m_x + nX, m_y+2 SAY "Vertikalno pomjeranje totala u fakturi var.9(br.redova)" GET gnTmarg3 PICT "99"
  	 @ m_x + nX, m_y+63 GET gnTmarg3A5 PICT "99"
	nX++
  	 @ m_x + nX, m_y+2 SAY "Vertikalno pomj.donjeg dijela fakture  var.9(br.redova)" GET gnTmarg4 PICT "99"
  	 @ m_x + nX, m_y+63 GET gnTmarg4A5 PICT "99"
	 nX++
  	 @ m_x + nX, m_y+2 SAY "Vertik.pomj.znakova krizanja i br.dok.var.9(br.red.>=0)" GET gKriz PICT "99"
  	 @ m_x + nX, m_y+63 GET gKrizA5 PICT "99"
	 nX++
  	 @ m_x + nX, m_y+2 SAY "Znak kojim se precrtava dio teksta na papiru" GET gZnPrec
	 nX++

     	 @ m_x + nX, m_y+2 SAY "Broj linija za odvajanje tabele od broja dokumenta" GET gOdvT2 VALID gOdvT2>=0 PICT "9"
	 nX++

  	  @ m_x + nX, m_y+2 SAY "Nacin crtanja tabele (0/1/2) ?" GET gTabela VALID gTabela<3.and.gTabela>=0 PICT "9"
	nX++
  	  @ m_x + nX, m_y+2 SAY "Zaglavlje na svakoj stranici D/N  (1/2) ? " GET gZagl VALID gZagl $ "12" PICT "@!"
	  nX++
  	  @ m_x + nX, m_y+2 SAY "Crni-masni prikaz fakture D/N  (1/2) ? " GET gBold VALID gBold $ "12" PICT "@!"
	  nX++
    	  @ m_x + nX, m_y+2 SAY "Var.RTF-fakt.,izgled tipa 2 (' '-standardno, 1-MINEX, 2-LIKOM, 3-ZENELA)" GET gVarRF VALID gVarRF $ " 123"
	  nX++
	
   	  @ m_x + nX, m_y+2 SAY "Prikaz rekapitulacije po tarifama na 13-ci:" GET gRekTar VALID gRekTar $ "DN" PICT "@!"
	  nX++
	
  	  @ m_x + nX, m_y+2 SAY "Prikaz horizot. linija:" GET gHLinija VALID gHLinija $ "DN" PICT "@!"
	  nX++
	
  	  @ m_x + nX, m_y+2 SAY "Prikaz rabata u %(procentu)? (D/N):" GET gRabProc VALID gRabProc $ "DN" PICT "@!"
	  nX++
	endif

	if IsPdv()
  	  @ m_x+ nX, m_y+2 SAY "PDV Delphi RB prikaz (D/N)" GET gPDVDrb PICT "@!" VALID gPDVDrb $ "DN"
	  nX++
  	  @ m_x+ nX, m_y+2 SAY "PDV TXT dokument varijanta " GET gPDVDokVar PICT "@!" VALID gPDVDokVar $ "123"
	  nX++
	endif

	if IsPdv()
	 nX += 2
	 @ m_x+nX, m_y+2 SAY "Koordinate iznad kupac/ispod kupac/nar_otp-tabela"
	 nX ++
	
	 @ m_x+nX, m_y+2 SAY "DX-1 :" GET nDx1 ;
	         PICT "99" 
	 @ m_x+nX, col()+2 SAY "DX-2 :" GET nDx2 ;
	         PICT "99" 
	 @ m_x+nX, col()+2 SAY "DX-3 :" GET nDx3 ;
	         PICT "99"
	 nX += 2
	 
	 @ m_x+nX, m_y+2 SAY "SW-1 :" GET nSw1 ;
	         PICT "99" 
	 @ m_x+nX, col()+2 SAY "SW-2 :" GET nSw2 ;
	         PICT "99" 
	 @ m_x+nX, col()+2 SAY "SW-3 :" GET nSw3 ;
	         PICT "99" 
         @ m_x+nX, col()+2 SAY "SW-4 :" GET nSw4 ;
	         PICT "99"
         @ m_x+nX, col()+2 SAY "SW-5 :" GET nSw5 ;
	         PICT "99"
	 nX += 2	 
	
	 @ m_x+nX, m_y+2 SAY "SW-6 :" GET nSw6 ;
	         PICT "9" 
	 @ m_x+nX, col()+2 SAY "SW-7 :" GET nSw7 ;
	         PICT "9" 
	
	 nX += 2

	 // parametri fin.stanje na dod.txt...
	 @ m_x+nX, m_y+2 SAY "Ispis grupacije robe poslije naziva (D/N)" GET glRGrPrn PICT "@!" VALID glRGrPrn $ "DN"
	 
	 nX += 2

	 // parametri fin.stanje na dod.txt...
	 @ m_x+nX, m_y+2 SAY "Prikaz fin.salda kupca/dobavljaca na dodatnom tekstu (D/N)" GET gShSld PICT "@!" VALID gShSld $ "DN"

	 nX += 1
	 
	 @ m_x+nX, m_y+2 SAY PADL("Konto duguje:", 20) GET gFinKtoDug VALID !EMPTY(gFinKtoDug) .and. P_Konto(@gFinKtoDug) WHEN gShSld == "D"

	 nX += 1
	
	 @ m_x+nX, m_y+2 SAY PADL("Konto potrazuje:", 20) GET gFinKtoPot VALID !EMPTY(gFinKtoPot) .and. P_Konto(@gFinKtoPot) WHEN gShSld == "D"
	 
	 nX += 1
	 
	 @ m_x+nX, m_y+2 SAY "Varijanta prikaza podataka (1/2)" GET gShSldVar PICT "9" VALID gShSldVar > 0 .and. gShSldVar < 3 WHEN gShSld == "D"
	
	endif

  	read
BoxC()

if (LASTKEY()<>K_ESC)
	WPar("c1", cIzvj)
   	WPar("tf", @gTipF)
   	WPar("vf", @gVarF)
   	WPar("kr", @gKriz)
   	WPar("55", @gKrizA5)
   	WPar("vr", @gVarRF)
   	WPar("er", gERedova)
   	WPar("pr", gnLMarg)
   	WPar("56", gnLMargA5)
   	WPar("pt", gnTMarg)
   	WPar("a5", gFormatA5)
   	WPar("fp", gFPzag)
   	WPar("51", gFPzagA5)
   	WPar("52", gnTMarg2A5)
   	WPar("53", gnTMarg3A5)
   	WPar("54", gnTMarg4A5)
   	WPar("d1", gnTMarg2)
   	WPar("d2", gnTMarg3)
   	WPar("d3", gnTMarg4)
   	WPar("cr", gZnPrec)
   	WPar("ot", gOdvT2)
   	WPar("tb", gTabela)
   	WPar("za", gZagl)   // zaglavlje na svakoj stranici
   	WPar("zb", gbold)
   	WPar("RT", gRekTar)
   	WPar("HL", gHLinija)
   	WPar("rp", gRabProc)
	WPar("H1", gPDVDrb)
   	WPar("H2", gPDVDokVar)
   	WPar("F5", glRGrPrn)
   	
	cSection := "2"
	WPar("s1", gShSld)
   	WPar("s2", gFinKtoDug)
   	WPar("s3", gFinKtoPot)
   	WPar("s4", gShSldVar)

	cSection := "F"
	WPar("x1", nDx1)
	WPar("x2", nDx2)
	WPar("x3", nDx3)
	WPar("x4", nSw1)
	WPar("x5", nSw2)
	WPar("x6", nSw3)
	WPar("x7", nSw4)
	WPar("x8", nSw5)
	WPar("x9", nSw6)
	WPar("y1", nSw7)

	cSection := "1"
	
endif

return 



*string Params_r3;
/*! \ingroup params
 *  \var Params_r3
 *  \brief Naziv dokumenta tipa 06
 *  \param "ZADUZ.KONS.SKLAD.br." - default vrijednost
 *  \note g06Str
 */


*string Params_r4;
/*! \ingroup params
 *  \var Params_r4
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 06 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g06Str2T
 */


*string Params_r5;
/*! \ingroup params
 *  \var Params_r5
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 06 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g06Str2R
 */


*string Params_s1;
/*! \ingroup params
 *  \var Params_s1
 *  \brief Naziv dokumenta tipa 10
 *  \param "RACUN/OTPREMNICA br." - default vrijednost
 *  \note g10Str
 */


*string Params_s4;
/*! \ingroup params
 *  \var Params_s4
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 10 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g10Str2T
 */


*string Params_r1;
/*! \ingroup params
 *  \var Params_r1
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 10 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g10Str2R
 */


*string Params_s2;
/*! \ingroup params
 *  \var Params_s2
 *  \brief Naziv dokumenta tipa 11
 *  \param "RACUN MP br." - default vrijednost
 *  \note g11Str
 */


*string Params_s5;
/*! \ingroup params
 *  \var Params_s5
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 11 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g11Str2T
 */


*string Params_x1;
/*! \ingroup params
 *  \var Params_x1
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 11 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g11Str2R
 */


*string Params_x3;
/*! \ingroup params
 *  \var Params_x3
 *  \brief Naziv dokumenta tipa 12
 *  \param "OTPREMNICA br." - default vrijednost
 *  \note g12Str
 */


*string Params_x4;
/*! \ingroup params
 *  \var Params_x4
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 12 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g12Str2T
 */


*string Params_x5;
/*! \ingroup params
 *  \var Params_x5
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 12 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g12Str2R
 */


*string Params_x6;
/*! \ingroup params
 *  \var Params_x6
 *  \brief Naziv dokumenta tipa 13
 *  \param "OTPREMNICA U MP br." - default vrijednost
 *  \note g13Str
 */


*string Params_x7;
/*! \ingroup params
 *  \var Params_x7
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 13 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g13Str2T
 */


*string Params_x8;
/*! \ingroup params
 *  \var Params_x8
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 13 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g13Str2R
 */


*string Params_xl;
/*! \ingroup params
 *  \var Params_xl
 *  \brief Naziv dokumenta tipa 15
 *  \param "RACUN br." - default vrijednost
 *  \note g15Str
 */


*string Params_xm;
/*! \ingroup params
 *  \var Params_xm
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 15 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g15Str2T
 */


*string Params_xn;
/*! \ingroup params
 *  \var Params_xn
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 15 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g15Str2R
 */


*string Params_s9;
/*! \ingroup params
 *  \var Params_s9
 *  \brief Naziv dokumenta tipa 16
 *  \param "KONSIGNAC.RACUN br." - default vrijednost
 *  \note g16Str
 */


*string Params_s8;
/*! \ingroup params
 *  \var Params_s8
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 16 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g16Str2T
 */


*string Params_r2;
/*! \ingroup params
 *  \var Params_r2
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 16 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g16Str2R
 */


*string Params_s3;
/*! \ingroup params
 *  \var Params_s3
 *  \brief Naziv dokumenta tipa 20
 *  \param "PREDRACUN br." - default vrijednost
 *  \note g20Str
 */


*string Params_s6;
/*! \ingroup params
 *  \var Params_s6
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 20 (za potpise)
 *  \param "                                                               Direktor" - default vrijednost
 *  \note g20Str2T
 */


*string Params_x2;
/*! \ingroup params
 *  \var Params_x2
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 20 u varijanti RTF fakture (za potpise)
 *  \param "\tab \tab \tab Direktor:" - default vrijednost
 *  \note g20Str2R
 */


*string Params_x9;
/*! \ingroup params
 *  \var Params_x9
 *  \brief Naziv dokumenta tipa 21
 *  \param "REVERS br." - default vrijednost
 *  \note g21Str
 */


*string Params_xa;
/*! \ingroup params
 *  \var Params_xa
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 21 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g21Str2T
 */


*string Params_xb;
/*! \ingroup params
 *  \var Params_xb
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 21 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g21Str2R
 */


*string Params_xc;
/*! \ingroup params
 *  \var Params_xc
 *  \brief Naziv dokumenta tipa 22
 *  \param "ZAKLJ.OTPREMNICA br." - default vrijednost
 *  \note g22Str
 */


*string Params_xd;
/*! \ingroup params
 *  \var Params_xd
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 22 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g22Str2T
 */


*string Params_xe;
/*! \ingroup params
 *  \var Params_xe
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 22 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g22Str2R
 */


*string Params_xf;
/*! \ingroup params
 *  \var Params_xf
 *  \brief Naziv dokumenta tipa 25
 *  \param "KNJIZNA OBAVIJEST br." - default vrijednost
 *  \note g25Str
 */


*string Params_xg;
/*! \ingroup params
 *  \var Params_xg
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 25 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g25Str2T
 */


*string Params_xh;
/*! \ingroup params
 *  \var Params_xh
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 25 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g25Str2R
 */


*string Params_xi;
/*! \ingroup params
 *  \var Params_xi
 *  \brief Naziv dokumenta tipa 26
 *  \param "NARUDZBA SA IZJAVOM br." - default vrijednost
 *  \note g26Str
 */


*string Params_xj;
/*! \ingroup params
 *  \var Params_xj
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 26 (za potpise)
 *  \param "                                      Potpis:" - default vrijednost
 *  \note g26Str2T
 */


*string Params_xk;
/*! \ingroup params
 *  \var Params_xk
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 26 u varijanti RTF fakture (za potpise)
 *  \param "\tab \tab Potpis:" - default vrijednost
 *  \note g26Str2R
 */


*string Params_xo;
/*! \ingroup params
 *  \var Params_xo
 *  \brief Naziv dokumenta tipa 27
 *  \param "PREDRACUN MP br." - default vrijednost
 *  \note g27Str
 */


*string Params_xp;
/*! \ingroup params
 *  \var Params_xp
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 27 (za potpise)
 *  \param "                                                               Direktor" - default vrijednost
 *  \note g27Str2T
 */


*string Params_xr;
/*! \ingroup params
 *  \var Params_xr
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 27 u varijanti RTF fakture (za potpise)
 *  \param "\tab \tab \tab Direktor:" - default vrijednost
 *  \note g27Str2R
 */


/*! \fn SetT2()
 *  \brief Ispis naziva dokumenta i potpisa na kraju fakture
 */
 
function SetT2()
*{
private  GetList:={}

O_PARAMS

g10Str:=PADR(g10Str,20)
g16Str:=PADR(g16Str,20)
g06Str:=PADR(g06Str,20)
g11Str:=PADR(g11Str,20)
g12Str:=PADR(g12Str,20)
g13Str:=PADR(g13Str,20)
g15Str:=PADR(g15Str,20)
g20Str:=PADR(g20Str,20)
g21Str:=PADR(g21Str,20)
g22Str:=PADR(g22Str,20)
g23Str:=PADR(g23Str,20)
g25Str:=PADR(g25Str,20)
g26Str:=PADR(g26Str,24)
g27Str:=PADR(g27Str,20)

g10ftxt:=PADR(g10ftxt,100)
g11ftxt:=PADR(g11ftxt,100)
g12ftxt:=PADR(g12ftxt,100)
g13ftxt:=PADR(g13ftxt,100)
g15ftxt:=PADR(g15ftxt,100)
g16ftxt:=PADR(g16ftxt,100)
g20ftxt:=PADR(g20ftxt,100)
g21ftxt:=PADR(g21ftxt,100)
g22ftxt:=PADR(g22ftxt,100)
g23ftxt:=PADR(g23ftxt,100)
g25ftxt:=PADR(g25ftxt,100)
g26ftxt:=PADR(g26ftxt,100)
g27ftxt:=PADR(g27ftxt,100)

g10Str2T:=PADR(g10Str2T,132)
g10Str2R:=PADR(g10Str2R,132)
g16Str2T:=PADR(g16Str2T,132)
g16Str2R:=PADR(g16Str2R,132)
g06Str2T:=PADR(g06Str2T,132)
g06Str2R:=PADR(g06Str2R,132)
g11Str2T:=PADR(g11Str2T,132)
g15Str2T:=PADR(g15Str2T,132)
g11Str2R:=PADR(g11Str2R,132)
g15Str2R:=PADR(g15Str2R,132)
g12Str2T:=PADR(g12Str2T,132)
g12Str2R:=PADR(g12Str2R,132)
g13Str2T:=PADR(g13Str2T,132)
g13Str2R:=PADR(g13Str2R,132)
g20Str2T:=PADR(g20Str2T,132)
g20Str2R:=PADR(g20Str2R,132)
g21Str2T:=PADR(g21Str2T,132)
g21Str2R:=PADR(g21Str2R,132)
g22Str2T:=PADR(g22Str2T,132)
g22Str2R:=PADR(g22Str2R,132)
g23Str2T:=PADR(g23Str2T,132)
g23Str2R:=PADR(g23Str2R,132)
g25Str2T:=PADR(g25Str2T,132)
g25Str2R:=PADR(g25Str2R,132)
g26Str2T:=PADR(g26Str2T,132)
g26Str2R:=PADR(g26Str2R,132)
g27Str2T:=PADR(g27Str2T,132)
g27Str2R:=PADR(g27Str2R,132)
gNazPotStr:=PADR(gNazPotStr,132)

Box(,22,76,.f.,"Naziv dokumenata, potpis na kraju, str. 1")
	@ m_x+ 1,m_y+2 SAY "06 - Tekst"      GET g06Str
  	@ m_x+ 2,m_y+2 SAY "06 - Potpis TXT" GET g06Str2T PICT"@S50"
  	@ m_x+ 3,m_y+2 SAY "06 - Potpis RTF" GET g06Str2R PICT"@S50"
  	@ m_x+ 4,m_y+2 SAY "10 - Tekst"      GET g10Str
  	@ m_x+ 4,col()+1 SAY "d.txt lista:" GET g10ftxt PICT "@S25"
  	@ m_x+ 5,m_y+2 SAY "10 - Potpis TXT" GET g10Str2T PICT"@S50"
  	@ m_x+ 6,m_y+2 SAY "10 - Potpis RTF" GET g10Str2R PICT"@S50"
  	@ m_x+ 7,m_Y+2 SAY "11 - Tekst"      GET g11Str
  	@ m_x+ 7,col()+1 SAY "d.txt lista:" GET g11ftxt PICT "@S25"
  	@ m_x+ 8,m_y+2 SAY "11 - Potpis TXT" GET g11Str2T PICT "@S50"
  	@ m_x+ 9,m_y+2 SAY "11 - Potpis RTF" GET g11Str2R PICT "@S50"
  	@ m_x+10,m_y+2 SAY "12 - Tekst"      GET g12Str
  	@ m_x+10,col()+1 SAY "d.txt lista:" GET g12ftxt PICT "@S25"
  	@ m_x+11,m_y+2 SAY "12 - Potpis TXT" GET g12Str2T PICT "@S50"
  	@ m_x+12,m_y+2 SAY "12 - Potpis RTF" GET g12Str2R PICT "@S50"
  	@ m_x+13,m_y+2 SAY "13 - Tekst"      GET g13Str
  	@ m_x+13,col()+1 SAY "d.txt lista:" GET g13ftxt PICT "@S25"
  	@ m_x+14,m_y+2 SAY "13 - Potpis TXT" GET g13Str2T PICT "@S50"
  	@ m_x+15,m_y+2 SAY "13 - Potpis RTF" GET g13Str2R PICT "@S50"
  	@ m_x+16,m_y+2 SAY "15 - Tekst"      GET g15Str
  	@ m_x+16,col()+1 SAY "d.txt lista:" GET g15ftxt PICT "@S25"
  	@ m_x+17,m_y+2 SAY "15 - Potpis TXT" GET g15Str2T PICT "@S50"
  	@ m_x+18,m_y+2 SAY "15 - Potpis RTF" GET g15Str2R PICT "@S50"
  	@ m_x+19,m_y+2 SAY "16 - Tekst"      GET g16Str
  	@ m_x+19,col()+1 SAY "d.txt lista:" GET g16ftxt PICT "@S25"
  	@ m_x+20,m_y+2 SAY "16 - Potpis TXT" GET g16Str2T PICT"@S50"
  	@ m_x+21,m_y+2 SAY "16 - Potpis RTF" GET g16Str2R PICT"@S50"
  	read
BoxC()

Box(,19, 76,.f.,"Naziv dokumenata, potpis na kraju, str. 2")
	@ m_x+ 1,m_y+2 SAY "20 - Tekst"      GET g20Str
  	@ m_x+ 1,col()+1 SAY "d.txt lista:" GET g20ftxt PICT "@S25"
  	@ m_x+ 2,m_y+2 SAY "20 - Potpis TXT" GET g20Str2T PICT "@S50"
  	@ m_x+ 3,m_y+2 SAY "20 - Potpis RTF" GET g20Str2R PICT "@S50"
  	@ m_x+ 4,m_y+2 SAY "21 - Tekst"      GET g21Str
  	@ m_x+ 4,col()+1 SAY "d.txt lista:" GET g21ftxt PICT "@S25"
  	@ m_x+ 5,m_y+2 SAY "21 - Potpis TXT" GET g21Str2T PICT "@S50"
  	@ m_x+ 6,m_y+2 SAY "21 - Potpis RTF" GET g21Str2R PICT "@S50"
  	@ m_x+ 7,m_y+2 SAY "22 - Tekst"      GET g22Str
  	@ m_x+ 7,col()+1 SAY "d.txt lista:" GET g22ftxt PICT "@S25"
  	@ m_x+ 8,m_y+2 SAY "22 - Potpis TXT" GET g22Str2T PICT"@S50"
  	@ m_x+ 9,m_y+2 SAY "22 - Potpis RTF" GET g22Str2R PICT"@S50"
  	
	@ m_x+ 10,m_y+2 SAY "23 - Tekst"      GET g23Str
  	@ m_x+ 10,col()+1 SAY "d.txt lista:" GET g23ftxt PICT "@S25"
  	@ m_x+ 11,m_y+2 SAY "23 - Potpis TXT" GET g23Str2T PICT"@S50"
  	@ m_x+ 12,m_y+2 SAY "23 - Potpis RTF" GET g23Str2R PICT"@S50"
  	
	@ m_x+13,m_y+2 SAY "25 - Tekst"      GET g25Str
  	@ m_x+13,col()+1 SAY "d.txt lista:" GET g25ftxt PICT "@S25"
  	@ m_x+14,m_y+2 SAY "25 - Potpis TXT" GET g25Str2T PICT"@S50"
  	@ m_x+15,m_y+2 SAY "25 - Potpis RTF" GET g25Str2R PICT"@S50"
  	@ m_x+16,m_y+2 SAY "26 - Tekst"      GET g26Str
  	@ m_x+16,col()+1 SAY "d.txt lista:" GET g26ftxt PICT "@S25"
  	@ m_x+17,m_y+2 SAY "26 - Potpis TXT" GET g26Str2T PICT"@S50"
 	@ m_x+18,m_y+2 SAY "26 - Potpis RTF" GET g26Str2R PICT"@S50"
  	@ m_x+19,m_y+2 SAY "27 - Tekst"      GET g27Str
  	@ m_x+19,col()+1 SAY "d.txt lista:" GET g27ftxt PICT "@S25"
  	@ m_x+20,m_y+2 SAY "27 - Potpis TXT" GET g27Str2T PICT"@S50"
  	@ m_x+21,m_y+2 SAY "27 - Potpis RTF" GET g27Str2R PICT"@S50"
  	@ m_x+22,m_y+2 SAY "Dodatni red    " GET gNazPotStr PICT"@S50"
	
	read
BoxC()

if gKodnaS=="8"
	g10Str:=KSTo852(TRIM(g10Str)  )
        g10Str2T:=KSTo852(TRIM(g10Str2T))
        g10Str2R:=(TRIM(g10Str2R))
        g16Str:=KSTo852(TRIM(g16Str)  )
        g16Str2T:=KSTo852(TRIM(g16Str2T))
        g16Str2R:=(TRIM(g16Str2R))
        g06Str:=KSTo852(TRIM(g06Str)  )
        g06Str2T:=KSTo852(TRIM(g06Str2T))
        g06Str2R:=(TRIM(g06Str2R))
        g11Str:=KSTo852(TRIM(g11Str)  )
        g11Str2T:=KSTo852(TRIM(g11Str2T))
        g11Str2R:=(TRIM(g11Str2R))
        g12Str:=KSTo852(TRIM(g12Str)  )
        g12Str2T:=KSTo852(TRIM(g12Str2T))
        g12Str2R:=(TRIM(g12Str2R))
        g13Str:=KSTo852(TRIM(g13Str)  )
        g13Str2T:=KSTo852(TRIM(g13Str2T))
        g13Str2R:=(TRIM(g13Str2R))
        g15Str:=KSTo852(TRIM(g15Str)  )
        g15Str2T:=KSTo852(TRIM(g15Str2T))
        g15Str2R:=(TRIM(g15Str2R))
        g20Str:=KSTo852(TRIM(g20Str)  )
        g20Str2T:=KSTo852(TRIM(g20Str2T))
        g20Str2R:=(TRIM(g20Str2R))
        g21Str:=KSTo852(TRIM(g21Str)  )
        g21Str2T:=KSTo852(TRIM(g21Str2T))
        g21Str2R:=(TRIM(g21Str2R))
        g22Str:=KSTo852(TRIM(g22Str)  )
        g22Str2T:=KSTo852(TRIM(g22Str2T))
        g22Str2R:=(TRIM(g22Str2R))
        
	g23Str:=KSTo852(TRIM(g23Str)  )
        g23Str2T:=KSTo852(TRIM(g23Str2T))
        g23Str2R:=(TRIM(g23Str2R))
       
	g25Str:=KSTo852(TRIM(g25Str)  )
        g25Str2T:=KSTo852(TRIM(g25Str2T))
        g25Str2R:=(TRIM(g25Str2R))
        g26Str:=KSTo852(TRIM(g26Str)  )
        g26Str2T:=KSTo852(TRIM(g26Str2T))
        g26Str2R:=(TRIM(g26Str2R))
        g27Str:=KSTo852(TRIM(g27Str)  )
        g27Str2T:=KSTo852(TRIM(g27Str2T))
        g27Str2R:=(TRIM(g27Str2R))
	gNazPotStr:=KSTo852(TRIM(gNazPotStr))
else
        g10Str:=KSTo7(TRIM(g10Str)  )
        g10Str2T:=KSTo7(TRIM(g10Str2T))
        g10Str2R:=(TRIM(g10Str2R))
        g16Str:=KSTo7(TRIM(g16Str)  )
        g16Str2T:=KSTo7(TRIM(g16Str2T))
        g16Str2R:=(TRIM(g16Str2R))
        g06Str:=KSTo7(TRIM(g06Str)  )
        g06Str2T:=KSTo7(TRIM(g06Str2T))
        g06Str2R:=(TRIM(g06Str2R))
        g11Str:=KSTo7(TRIM(g11Str)  )
        g11Str2T:=KSTo7(TRIM(g11Str2T))
        g11Str2R:=(TRIM(g11Str2R))
        g12Str:=KSTo7(TRIM(g12Str)  )
        g12Str2T:=KSTo7(TRIM(g12Str2T))
        g12Str2R:=(TRIM(g12Str2R))
        g13Str:=KSTo7(TRIM(g13Str)  )
        g13Str2T:=KSTo7(TRIM(g13Str2T))
        g13Str2R:=(TRIM(g13Str2R))
        g15Str:=KSTo7(TRIM(g15Str)  )
        g15Str2T:=KSTo7(TRIM(g15Str2T))
        g15Str2R:=(TRIM(g15Str2R))
        g20Str:=KSTo7(TRIM(g20Str)  )
        g20Str2T:=KSTo7(TRIM(g20Str2T))
        g20Str2R:=(TRIM(g20Str2R))
        g21Str:=KSTo7(TRIM(g21Str)  )
        g21Str2T:=KSTo7(TRIM(g21Str2T))
        g21Str2R:=(TRIM(g21Str2R))
        g22Str:=KSTo7(TRIM(g22Str)  )
        g22Str2T:=KSTo7(TRIM(g22Str2T))
        g22Str2R:=(TRIM(g22Str2R))
        
	g23Str:=KSTo7(TRIM(g23Str)  )
        g23Str2T:=KSTo7(TRIM(g23Str2T))
        g23Str2R:=(TRIM(g23Str2R))
       
	g25Str:=KSTo7(TRIM(g25Str)  )
        g25Str2T:=KSTo7(TRIM(g25Str2T))
        g25Str2R:=(TRIM(g25Str2R))
        g26Str:=KSTo7(TRIM(g26Str)  )
        g26Str2T:=KSTo7(TRIM(g26Str2T))
        g26Str2R:=(TRIM(g26Str2R))
        g27Str:=KSTo7(TRIM(g27Str)  )
        g27Str2T:=KSTo7(TRIM(g27Str2T))
        g27Str2R:=(TRIM(g27Str2R))
	gNazPotStr:=KSTo7(TRIM(gNazPotStr))
endif

if (LASTKEY()<>K_ESC)
	WPar("s1",g10Str)
  	WPar("s2",g11Str)
  	WPar("s3",g20Str)
  	WPar("s4",@g10Str2T)
  	WPar("s5",@g11Str2T)
  	WPar("s6",@g20Str2T)
  	WPar("s9",g16Str)
  	WPar("r3",g06Str)
  	WPar("s8",@g16Str2T)
  	WPar("r4",@g06Str2T)
  	WPar("x1",@g11Str2R)
  	WPar("x2",@g20Str2R)
  	WPar("x3",@g12Str)
  	WPar("x4",@g12Str2T)
  	WPar("x5",@g12Str2R)
  	WPar("x6",@g13Str)
  	WPar("x7",@g13Str2T)
  	WPar("x8",@g13Str2R)
  	WPar("xl",@g15Str)
  	WPar("xm",@g15Str2T)
  	WPar("xn",@g15Str2R)
  	WPar("x9",@g21Str)
  	WPar("xa",@g21Str2T)
  	WPar("xb",@g21Str2R)
  	WPar("xc",@g22Str)
 	WPar("xd",@g22Str2T)
  	WPar("xe",@g22Str2R)

  	WPar("xC",@g23Str)
 	WPar("xD",@g23Str2T)
  	WPar("xE",@g23Str2R)
  	
	WPar("xf",@g25Str)
  	WPar("xg",@g25Str2T)
  	WPar("xh",@g25Str2R)
  	WPar("xi",@g26Str)
  	WPar("xj",@g26Str2T)
  	WPar("xk",@g26Str2R)
  	WPar("xo",@g27Str)
	WPar("uc",@gNazPotStr)
  	WPar("xp",@g27Str2T)
  	WPar("xr",@g27Str2R)
  	WPar("r1",@g10Str2R)
  	WPar("r2",@g16Str2R)
  	WPar("r5",@g06Str2R)
  	// liste
	WPar("ya",@g10ftxt)
	WPar("yb",@g11ftxt)
	WPar("yc",@g12ftxt)
	WPar("yd",@g13ftxt)
	WPar("ye",@g15ftxt)
	WPar("yf",@g16ftxt)
	WPar("yg",@g20ftxt)
	WPar("yh",@g21ftxt)
	WPar("yi",@g22ftxt)
	WPar("yI",@g23ftxt)
	WPar("yj",@g25ftxt)
	WPar("yk",@g26ftxt)
	WPar("yl",@g27ftxt)

endif

return 



/*! \fn V_VZagl()
 *  \brief Ispravka zaglavlja
 */
 
function V_VZagl()
*{
private cKom:="q "+PRIVPATH+gVlZagl

if Pitanje(,"Zelite li izvrsiti ispravku zaglavlja ?","N")=="D"
	if !EMPTY(gVlZagl)
   		Box(,25,80)
   			run &ckom
   		BoxC()
 	endif
endif
return .t.
*}


/*! \fn V_VNar()
 *  \brief Ispravka fajla narudzbenice
 */
 
function V_VNar()
*{
private cKom:="q "+PRIVPATH+gFNar

if Pitanje( , "Zelite li izvrsiti ispravku fajla obrasca narudzbenice ?","N")=="D"
	if !EMPTY(gFNar)
   		Box(,25,80)
   			run &ckom
   		BoxC()
 	endif
endif

return .t.
*}



/*! \fn V_VUgRab()
 *  \brief Ispravka fajla ugovora o rabatu
 */
function V_VUgRab()
*{
private cKom:="q "+PRIVPATH+gFUgRab

if Pitanje(,"Zelite li izvrsiti ispravku fajla-teksta ugovora o rabatu ?","N")=="D"
	if !EMPTY(gFUgRab)
   		Box(,25,80)
   			run &ckom
   		BoxC()
 	endif
endif
return .t.
*}


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_Firma
  * \brief Naziv firme
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_Firma;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_Adres
  * \brief Adresa firme
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_Adres;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_Tel
  * \brief Broj telefona firme
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_Tel;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_Fax
  * \brief Broj faksa firme
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_Fax;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_RegBroj
  * \brief Registarski broj firme
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_RegBroj;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_PorBroj
  * \brief Poreski broj firme
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_PorBroj;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_ZRacun1
  * \brief Broj ziro racuna 1
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_ZRacun1;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_ZRacun2
  * \brief Broj ziro racuna 2
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_ZRacun2;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_ZRacun3
  * \brief Broj ziro racuna 3
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_ZRacun3;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_ZRacun4
  * \brief Broj ziro racuna 4
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_ZRacun4;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_ZRacun5
  * \brief Broj ziro racuna 5
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_ZRacun5;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_LokSlika
  * \brief Lokacija slike u koja sadrzi znak (logo) firme
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_LokSlika;


/*! \fn P_WinFakt()
 *  \brief Podesavanje parametara stampe kroz DelphiRB
 */

function P_WinFakt()
*{

cIniName:=EXEPATH+'proizvj.ini'

cFirma:=PADR(UzmiIzIni(cIniName,'Varijable','Firma','--','READ'),30)
cAdresa:=PADR(UzmiIzIni(cIniName,'Varijable','Adres','--','READ'),30)
cTelefoni:=PADR(UzmiIzIni(cIniName,'Varijable','Tel','--','READ'),50)
cFax:=PADR(UzmiIzIni(cIniName,'Varijable','Fax','--','READ'),30)
cRBroj:=PADR(UzmiIzIni(cIniName,'Varijable','RegBroj','--','READ'),13)
cPBroj:=PADR(UzmiIzIni(cIniName,'Varijable','PorBroj','--','READ'),13)
cBrSudRj:=PADR(UzmiIzIni(cIniName,'Varijable','BrSudRj','--','READ'),45)
cBrUpisa:=PADR(UzmiIzIni(cIniName,'Varijable','BrUpisa','--','READ'),45)
cZRac1:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun1','--','READ'),45)
cZRac2:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun2','--','READ'),45)
cZRac3:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun3','--','READ'),45)
cZRac4:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun4','--','READ'),45)
cZRac5:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun5','--','READ'),45)
cZRac6:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun6','--','READ'),45)
cNazivRtm:=PADR(IzFmkIni('Fakt','NazRTM','',EXEPATH),15)
cNazivFRtm:=PADR(IzFmkIni('Fakt','NazRTMFax','',EXEPATH),15)
cPictLoc:=PADR(UzmiIzIni(cIniName,'Varijable','LokSlika','--','READ'),30)
cDN:="D"

Box(,22,63)
	@ m_x+1,m_Y+2 SAY "Podesavanje parametara Win stampe:"
   	@ m_x+3,m_Y+2 SAY "Naziv firme: " GET cFirma
   	@ m_x+4,m_Y+2 SAY "Adresa: " GET cAdresa
   	@ m_x+5,m_Y+2 SAY "Telefon: " GET cTelefoni
   	@ m_x+6,m_Y+2 SAY "Fax: " GET cFax
   	@ m_x+7,m_Y+2 SAY "Ziro racun 1: " GET cZRac1
   	@ m_x+8,m_Y+2 SAY "Ziro racun 2: " GET cZRac2
   	@ m_x+9,m_Y+2 SAY "Ziro racun 3: " GET cZRac3
   	@ m_x+10,m_Y+2 SAY "Ziro racun 4: " GET cZRac4
  	@ m_x+11,m_Y+2 SAY "Ziro racun 5: " GET cZRac5
  	@ m_x+12,m_Y+2 SAY "Ziro racun 6: " GET cZRac6
   	@ m_x+13,m_Y+2 SAY "Identifikac.broj: " GET cRBroj
   	@ m_x+14,m_Y+2 SAY "Porezni dj. broj: " GET cPBroj
   	@ m_x+15,m_Y+2 SAY "Br.sud.rjesenja: " GET cBrSudRj
   	@ m_x+16,m_Y+2 SAY "Reg.broj upisa: " GET cBrUpisa
   	
	@ m_x+17,m_Y+2 SAY "--------------------------------------------"
   	@ m_x+18,m_Y+2 SAY "Lokacija slike: " GET cPictLoc
   	@ m_x+19,m_Y+2 SAY "Naziv RTM fajla za fakture: " GET cNazivRtm
   	@ m_x+20,m_Y+2 SAY "Naziv RTM fajla za slanje dok.faksom: " GET cNazivFRtm
   	@ m_x+21,m_Y+2 SAY "Snimi podatke D/N? " GET cDN valid cDN $ "DN" pict "@!"
   	read
BoxC()

if lastkey()=K_ESC
	return
endif

if cDN=="D"
	UzmiIzIni(cIniName,'Varijable','Firma',cFirma,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','Adres',cAdresa,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','Tel',cTelefoni,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','Fax',cFax,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','RegBroj',cRBroj,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','PorBroj',cPBroj,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','BrSudRj',cBrSudRj,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','BrUpisa',cBrUpisa,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','ZRacun1',cZRac1,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','ZRacun2',cZRac2,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','ZRacun3',cZRac3,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','ZRacun4',cZRac4,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','ZRacun5',cZRac5,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','ZRacun6',cZRac6,'WRITE')
    	UzmiIzIni(EXEPATH+"fmk.ini",'Fakt','NazRTM',cNazivRtm,'WRITE')
    	UzmiIzIni(EXEPATH+"fmk.ini",'Fakt','NazRTMFax',cNazivFRtm,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','LokSlika',cPictLoc,'WRITE')
    	MsgBeep("Podaci snimljeni!")
else
	return
endif

return
*}

*string Params_s7;
/*! \ingroup params
 *  \var Params_s7
 *  \brief Grad tj.mjesto u kojem je firma
 *  \param Zenica - u Zenici
 *  \note gMjStr
 */


*string Params_fi;
/*! \ingroup params
 *  \var Params_fi
 *  \brief Sifra firme/default radne jedinice
 *  \param 10 - sifra firme ili default radne jedinice je 10
 *  \note gFirma
 */


*string Params_ts;
/*! \ingroup params
 *  \var Params_ts
 *  \brief Tip poslovnog subjekta
 *  \param Preduzece - znaci da se radi o preduzecu
 *  \note gTS
 */


*string Params_fn;
/*! \ingroup params
 *  \var Params_fn
 *  \brief Naziv firme
 *  \param SIGMA-COM - naziv firme je SIGMA-COM
 *  \note gNFirma
 */


*string Params_Bv;
/*! \ingroup params
 *  \var Params_Bv
 *  \brief Bazna valuta
 *  \param D - domaca
 *  \param P - pomocna
 *  \note gBaznaV
 */


*string Params_mV;
/*! \ingroup params
 *  \var Params_mV
 *  \brief Koristiti modemsku vezu?
 *  \param S - da, server
 *  \param K - da, korisnik
 *  \param N - ne koristiti modemsku vezu
 *  \note gModemVeza
 */


/*! \fn PRabat()
 *  \brief Podesenje parametara rabatnih skala
 */
 
function PRabat()
*{
private  GetList:={}

O_PARAMS
RPar("rs", gcRabDef)
RPar("is", gcRabIDef)
RPar("id", gcRabDok)

gcRabDef:=PADR(gcRabDef, 10)

Box(,4,60,.f.,"RABATNE SKALE")
  	@ m_x+1,m_y+2 SAY "Tekuca vr. rabat (oznaka)    :" GET gcRabDef VALID !Empty(gcRabDef)
	@ m_x+2,m_y+2 SAY "Tekuci iznos rabata (1-5):" GET gcRabIDef VALID gcRabIDef$"12345" PICT "!@"
	@ m_x+3,m_y+2 SAY "Odnosi se na sljedece tipove dok. (10#12):" 
	@ m_x+4,m_y+2 GET gcRabDok VALID !Empty(gcRabDok) PICT "@S20"
  	READ
BoxC()

if (LASTKEY()<>K_ESC)
	WPar("rs",gcRabDef)
  	Wpar("ir",gcRabIDef)
  	Wpar("id",gcRabDok)
endif

return
*}



