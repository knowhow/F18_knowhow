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
function fakt_set_params()

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
AADD(opcexe,{|| fakt_par_firma()})

AADD(opc,"2. postaviti varijante obrade dokumenata       ") 
AADD(opcexe,{|| fakt_par_varijante_prikaza()})

AADD(opc,"3. izgled dokumenata      ")
AADD(opcexe,{|| par_fakt_izgled_dokumenta()})

if IsPDV()
	AADD(opc,"4. izgled dokumenata - zaglavlje ")
	AADD(opcexe,{|| ZaglParams()})
endif

AADD(opc,"5. nazivi dokumenata i teksta na kraju (potpis)")
AADD(opcexe,{|| fakt_par_nazivi_dokumenata()})

AADD(opc,"6. prikaza cijena, iznos ")
AADD(opcexe,{|| fakt_par_cijene()})

AADD(opc,"7. postaviti parametre - razno                 ")
AADD(opcexe,{|| fakt_par_razno()})

if !IsPDV()
	AADD(opc,"W. parametri Win stampe (DelphiRB)             ")
	AADD(opcexe,{|| P_WinFakt()})
endif

AADD(opc,"8. parametri stampaca                          ")
AADD(opcexe,{|| PushWa(), PPrint(), PopWa() })

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
			VALID gFC_faktura $ "DNGX" PICT "@!"
	
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


/*! \fn fakt_par_razno()
 *  \brief Podesenja parametri-razno
 */
function fakt_par_razno()
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

gFNaziv := PADR( gFNaziv, 250 )
gFPNaziv := PADR( gFPNaziv, 250 )
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
	set_metric( "fakt_zagl_firma_naziv", nil, gFNaziv )
	set_metric( "fakt_zagl_firma_naziv_2", nil, gFPNaziv )
   	set_metric( "fakt_zagl_adresa", nil, gFAdresa )
   	set_metric( "fakt_zagl_id_broj", nil, gFIdBroj )
   	set_metric( "fakt_zagl_banka_1", nil, gFBanka1 )
   	set_metric( "fakt_zagl_banka_2", nil, gFBanka2 )
   	set_metric( "fakt_zagl_banka_3", nil, gFBanka3 )
   	set_metric( "fakt_zagl_banka_4", nil, gFBanka4 )
   	set_metric( "fakt_zagl_banka_5", nil, gFBanka5 )
   	set_metric( "fakt_zagl_telefon", nil, gFTelefon )
	set_metric( "fakt_zagl_email", nil, gFEmailWeb )
   	set_metric( "fakt_zagl_dtxt_1", nil, gFText1 )
	set_metric( "fakt_zagl_dtxt_2", nil, gFText2 )
	set_metric( "fakt_zagl_dtxt_3", nil, gFText3 )
	set_metric( "fakt_zagl_koristiti_txt", nil, gStZagl )
	set_metric( "fakt_zagl_pic_header", nil, gFPicHRow )
	set_metric( "fakt_zagl_pic_footer", nil, gFPicFRow )
endif

return 



function fakt_par_firma()
private  GetList:={}

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
    // snimi parametre
	set_metric( "fakt_mjesto", nil, gMjStr )
	set_metric( "fakt_id_firma", nil, gFirma )
	set_metric( "fakt_tip_subjeka", nil, gTS )
	set_metric( "fakt_firma_naziv", nil, gNFirma )
	set_metric( "fakt_bazna_valuta", nil, gBaznaV )
	set_metric( "fakt_modemska_veza", nil, gModemVeza )
	
endif

return


function fakt_par_cijene()
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



function fakt_par_varijante_prikaza()
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

function par_fakt_izgled_dokumenta()
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



 
function fakt_par_nazivi_dokumenata()
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


function V_VZagl()
local _cmd := "gvim " + PRIVPATH + gVlZagl

if Pitanje(,"Zelite li izvrsiti ispravku zaglavlja ?","N")=="D"
	if !EMPTY(gVlZagl)
   		Box(,25,80)
   			run (_cmd)
   		BoxC()
 	endif
endif
return .t.


function V_VNar()
local _cmd := "gvim " + PRIVPATH + gFNar

if Pitanje( , "Zelite li izvrsiti ispravku fajla obrasca narudzbenice ?","N")=="D"
	if !EMPTY(gFNar)
   		Box(,25,80)
   			run (_cmd)
   		BoxC()
 	endif
endif

return .t.




/*! \fn V_VUgRab()
 *  \brief Ispravka fajla ugovora o rabatu
 */
function V_VUgRab()
local _cmd := "gvim " + PRIVPATH + gFUgRab

if Pitanje(,"Zelite li izvrsiti ispravku fajla-teksta ugovora o rabatu ?","N")=="D"
	if !EMPTY(gFUgRab)
   		Box(,25,80)
   			run (_cmd)
   		BoxC()
 	endif
endif
return .t.



function P_WinFakt()

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



// ----------------------------------------------------
// specificne funkcije za fakturisanje uglja
// ----------------------------------------------------
function is_fakt_ugalj()
return .f.




