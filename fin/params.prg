#include "fin.ch"

// -----------------------------------
// meni parametara
// -----------------------------------
function mnu_params()
private opc := {}
private opcexe := {}
private izbor := 1

read_params()

AADD(opc, "1. osnovni parametri                        ")
AADD(opcexe, {|| par_osnovni() })
AADD(opc, "2. parametri rada ")
AADD(opcexe, {|| par_obrada() })
AADD(opc, "3. parametri izgleda ")
AADD(opcexe, {|| par_izgled() })

Menu_sc("fin_param")

return


// ---------------------------------------
// osnovni parametri modula
// ---------------------------------------
static function par_osnovni()
local nX := 1

Box(,10,70)
 	
	set cursor on
 	
	@ m_x + nX, m_y + 2 SAY "*********** Osnovni parametri:"
	
	nX := nX + 2
	
	@ m_x + nX, m_y + 2 SAY "Firma" GET gFirma
	
 	@ m_x + nX, col() + 2 SAY "Naziv firme:" get gNFirma
 	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Tip subjekta:" get gTS
	
	nX := nX + 2
	
 	@ m_x + nX, m_y + 2 SAY "Novi korisnicki interfejs? (D/N)" GET gNW valid gNW $ "DN" pict "@!"


	read
	
BoxC()

if LastKey() <> K_ESC
	write_params()
endif

return


// ---------------------------------------
// parametri obrade naloga
// ---------------------------------------
static function par_obrada()
local nX := 1

Box(,23,70)

	set cursor on
 	
 	@ m_x + nX, m_y + 2 SAY "*********************** Unos naloga:"

	nX := nX + 2
	
 	@ m_x + nX, m_y + 2 SAY "Unos datuma naloga? (D/N):" GET gDatNal valid gDatNal $ "DN" pict "@!"

	@ m_x + nX, col() + 2 SAY "Unos datuma valute? (D/N):" GET gDatVal valid gDatVal $ "DN" pict "@!"
	
	++ nX

	@ m_x + nX, m_y + 2 SAY "Unos radnih jedinica? (D/N)" GET gRJ valid gRj $ "DN" pict "@!"

	++ nX
	
 	@ m_x + nX, m_y + 2 SAY "Unos ekonomskih kategorija? (D/N)" GET gTroskovi valid gTroskovi $ "DN" pict "@!"

	++ nX

 	@ m_x + nX, m_y + 2 SAY "Unos polja K1 - K4 ? (D/N)"

 	++ nX
	
	@ m_x + nX, m_y + 2 SAY "K1 (D/N)" GET gK1 ;
				valid gK1 $ "DN" pict "@!"
 	@ m_x + nX, col() + 2 SAY "K2 (D/N)" GET gK2 ;
				valid gK2 $ "DN" pict "@!"
 	@ m_x + nX, col() + 2 SAY "K3 (D/N)" GET gK3 ;
				valid gK3 $ "DN" pict "@!"
 	@ m_x + nX, col() + 2 SAY "K4 (D/N)" GET gK4 ;
				valid gK4 $ "DN" pict "@!"
 	
	nX := nX + 2

	@ m_x + nX, m_y + 2 SAY "Brojac naloga: 1 - (firma,vn,brnal), 2 - (firma,brnal)" GET gBrojac valid gbrojac $ "12"
	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Limit za unos konta? (D/N):" GET gKtoLimit pict "@!" valid gKtoLimit $ "DN"
 	
	@ m_x + nX, col() + 2 SAY "-> vrijednost limita:" GET gnKtoLimit pict "9" WHEN gKtoLimit == "D"
	

	nX := nX + 2
	
	@ m_x + nX, m_y + 2 SAY "********************** Obrada naloga:"

	nX := nX + 2
	
	@ m_x + nX, m_y + 2 SAY "Neophodna ravoteza naloga? (D/N):" GET gRavnot valid gRavnot $ "DN" pict "@!"
	
 	++ nX
	
 	@ m_x + nX, m_y + 2 SAY "Onemoguciti povrat azuriranog naloga u pripremu? (D/N)" GET gBezVracanja VALID gBezVracanja $ "DN" pict "@!"
 		
	++ nX

 	@ m_x + nX, m_y + 2  SAY "Limit za otvorene stavke ("+ValDomaca()+")" GET gnLOst pict "99999.99"
	
	++ nX 
	
	@ m_x + nX, m_y + 2 SAY "Koristiti konta-izuzetke u FIN-BUDZET-u? (D/N)" GET gBuIz VALID gBuIz$"DN" PICT "@!"

	++ nX 
	
	@ m_x + nX, m_y + 2 SAY "Pri pomoci asistenta provjeri i spoji duple uplate za partn.? (D/N)" GET gOAsDuPartn VALID gOAsDuPartn $ "DN" PICT "@!"

	++ nX

	@ m_x + nX, m_y + 2 SAY "Timeout kod azuriranja naloga (sec.):" ;
		GET gAzurTimeout PICT "99999"
  	
	nX := nX + 2

	@ m_x + nX, m_y + 2 SAY "********************** Ostalo:"
	
  	nX := nX + 2
	
 	@ m_x + nX, m_y + 2 SAY "Automatski pozovi kontrolu zbira datoteke svakih" GET gnKZBDana PICT "999" valid (gnKZBDana <= 999 .and. gnKZBDana >= 0)

	@ m_x + nX, col() + 1 SAY "dana"

	read
BoxC()

if LastKey() <> K_ESC
	write_params()
endif

return

// ---------------------------------------
// parametri izgleda dokumenata itd...
// ---------------------------------------
static function par_izgled()
local nX := 1

Box(, 15,70)

	set cursor on

 	@ m_x + nX, m_y + 2 SAY "*************** Varijante izgleda i prikaza:"

	nX := nX + 2
	
 	@ m_x + nX, m_y + 2 SAY "Potpis na kraju naloga? (D/N):" GET gPotpis valid gPotpis $ "DN"  pict "@!"
 	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Varijanta izvjestaja 0-dvovalutno 1-jednovalutno " GET gVar1 VALID gVar1 $ "01"
	
	++ nX

	@ m_x + nX, m_y + 2 SAY "Prikaz iznosa u " + ValPomocna() GET gPicDEM
 	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Prikaz iznosa u " + ValDomaca() GET gPicBHD

	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Sintetika i analitika se kreiraju u izvjestajima? (D/N)" GET gSAKrIz valid gSAKrIz $ "DN" PICT "@!"
	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "U subanalitici prikazati nazive i konta i partnera? (D/N)" GET gVSubOp valid gVSubOp$"DN" PICTURE "@!"
 	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Razmak izmedju kartica - br.redova (99-uvijek nova stranica): " GET gnRazRed PICTURE "99"
	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Dugi uslov za firmu i RJ u suban.specif.? (D/N)" GET gDUFRJ valid gDUFRJ $ "DN" pict "@!"
 	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Fajl obrasca kompenzacije" GET gFKomp valid V_FKomp()
	
	++ nX
	
 	@ m_x + nX, m_y + 2 SAY "Lijeva marg.za obrazac 'Odobr. i nalog za isplatu' (br.znakova)" GET gnLMONI PICTURE "999"
	
	read
BoxC()

if LastKey() <> K_ESC
	write_params()
endif

return


// ----------------------------------
// citanje parametara 
// ----------------------------------
function read_params()
O_PARAMS
private cSection:="1"
private cHistory:=" "
private aHistory:={}

RPar("k1",@gK1)
RPar("k2",@gK2)
RPar("k3",@gK3)
RPar("k4",@gK4)
RPar("dv",@gDatVal)
RPar("br",@gBrojac)
RPar("li",@gnLOst)
RPar("po",@gPotpis)
RPar("ff",@gFirma)
RPar("ts",@gTS)
RPar("du",@gDUFRJ)
Rpar("fk",@gFKomp)
Rpar("fn",@gNFirma)
Rpar("lm",@gnLMONI)
Rpar("nw",@gNW)
Rpar("bv",@gBezVracanja)
Rpar("bi",@gBuIz)
Rpar("p1",@gPicDEM)
Rpar("p2",@gPicBHD)
Rpar("v1",@gVar1)
Rpar("rr",@gnRazRed)
Rpar("so",@gVSubOp)
Rpar("zx",@gKtoLimit)
Rpar("zy",@gnKtoLimit)
Rpar("az",@gnKZBDana)
Rpar("OA",@gOAsDuPartn)

gNFirma:=padr(gNFirma,20)

gK1:=padr(gK1,1)
gK2:=padr(gK2,1)
gK3:=padr(gK3,1)
gK4:=padr(gK4,1)

gVar1:=padr(gVar1,1)

return

// -------------------------------
// snimanje parametara
// -------------------------------
function write_params()
O_PARAMS
private cSection:="1"
private cHistory:=" "
private aHistory:={}

WPar("k1",gK1)
WPar("k2",gK2)
WPar("k3",gK3)
WPar("k4",gK4)
WPar("dv",gDatVal)
WPar("br",gBrojac)
WPar("li",gnLOst)
WPar("po",gPotpis)
WPar("ff",gFirma)
WPar("ts",gTS)
WPar("du",gDUFRJ)
Wpar("fk",gFKomp)
Wpar("fn",gNFirma)
Wpar("lm",gnLMONI)
Wpar("Ra",gRavnot)
Wpar("dn",gDatNal)
Wpar("nw",gNW)
Wpar("bv",gBezVracanja)
Wpar("bi",gBuIz)
Wpar("p1",gPicDEM)
Wpar("p2",gPicBHD)
Wpar("v1",gVar1)
Wpar("tr",gTroskovi)
Wpar("rj",gRj)
Wpar("rr",gnRazRed)
Wpar("so",gVSubOp)
Wpar("si",gSAKrIz)
Wpar("zx",gKtoLimit)
Wpar("zy",gnKtoLimit)
Wpar("az",gnKZBdana)
Wpar("aT",gAzurTimeOut)
Wpar("OA",gOAsDuPartn)

return


// ---------------------------------------------
// Ispravka fajla kompenzacije
// ---------------------------------------------
function v_fkomp()
private cKom := "q "+ PRIVPATH + gFKomp
if Pitanje(,"Zelite li izvrsiti ispravku obrasca kompenzacije ?","N")=="D"
	if !empty(gFKomp)
   		Box(,25,80)
   			run &ckom
   		BoxC()
 	endif
endif
return .t.


