/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fakt.ch"
#include "f18_separator.ch"

static lKonsignacija := .f.
static lDoks2 := .t.
static lDirty := .t.


// -----------------------------------------------------------------
// Glavna funkcija za poziv pripreme i knjizenje fakture
// -----------------------------------------------------------------
function fakt_unos_dokumenta()
// da li je ocitan barkod
private gOcitBarkod:=.f.
private fID_J:=.f.
private lVrsteP := ( IzFmkIni("FAKT","VrstePlacanja","N",SIFPATH)=="D" )
private lOpcine := ( IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D" )
private gTBDir:="N"

o_fakt_edit()

select fakt_pripr

if idTipDok=="IM"
	close all
	FaUnosInv()
	return
endif

if IzFMKINI('SifRoba','ID_J','N', SIFPATH)=="D"
	fId_J:=.t.
endif

private ImeKol:={ ;
          {"Red.br",        {|| Rbr() } } ,;
          {"Partner/Roba",  {|| Part1Stavka() + Roba()  } } ,;
          {"Kolicina",      {|| kolicina } } ,;
          {"Cijena",        {|| Cijena } , "cijena" } ,;
          {"Rabat",         {|| Rabat  } ,"Rabat"} ,;
          {"Porez",         {|| Porez  } ,"porez"} ,;
          {"RJ",            {|| idfirma   }, "idfirma" }, ;
          {"Serbr",         {|| SerBr   }, "serbr" }, ;
          {"Partn",         {|| IdPartner   }, "IdPartner" }, ;
          {"IdTipDok",         {|| IdTipDok  }, "Idtipdok" }, ;
          {"Brdok",         {|| Brdok  }, "Brdok" }, ;
          {"DatDok",         {|| DATDOK  }, "DATDOK" } ;
        }

if glRadNal
	AADD(ImeKol, { "Rad.nalog", {|| idrnal}, "idrnal" })
endif

if fakt_pripr->(fieldpos("k1"))<>0 .and. gDK1=="D"
  AADD(ImeKol,{ "K1",{|| k1}, "k1" })
  AADD(ImeKol,{ "K2",{|| k2}, "k2" })
endif

if fakt_pripr->(fieldpos("idrelac")) <> 0
	AADD( ImeKol , { "ID relac.", {|| idrelac  }, "IDRELAC"  } )
endif

Kol:={}
for i:=1 to len(ImeKol)
	AADD(Kol,i)
next

private cTipVPC:="1"

if gVarC $ "123"
	cTipVPC:=IzFmkIni("FAKT","TekVPC","1", SIFPATH)
endif

lFisMark := .f.
cFFirma := field->idfirma
cFTipDok := field->idtipdok
cFBrDok := field->brdok

Box( , MAXROWS() - 4, MAXCOLS() - 3 )

@ m_x + MAXROWS() - 4 - 3, m_y + 2 SAY " <c-N> Nove Stavke        " + BROWSE_COL_SEP + " <ENT> Ispravi stavku      " + BROWSE_COL_SEP + " <c-T> Brisi Stavku "
@ m_x + MAXROWS() - 4 - 2, m_y + 2 SAY " <c-A> Ispravka Dokumenta " + BROWSE_COL_SEP + " <c-P> Stampa (TXT)        " + BROWSE_COL_SEP + " <a-F10> Asistent  "
@ m_x + MAXROWS() - 4 - 1, m_y + 2 SAY " <a-A> Azuriranje dok.    " + BROWSE_COL_SEP + " <c-F9> Brisi pripremu     " + BROWSE_COL_SEP + " <F5>  Kontrola zbira  "
@ m_x + MAXROWS() - 4, m_y + 2 SAY     " <R> Rezerv  <X> Prekid R " + BROWSE_COL_SEP + " <F10>  Ostale opcije      " + BROWSE_COL_SEP + " <F9> 20,12->10; 27->11"

ObjDbedit( "PNal", MAXROWS() - 4, MAXCOLS() - 3 , {|| fakt_pripr_keyhandler()}, "", "Priprema...", , , , , 4)

BoxC()

close all
return


// ----------------------------------------------------------------------
// ispisuje informaciju o tekucem dokumentu na vrhu prozora 
// ----------------------------------------------------------------------
function TekDokument()
local nRec
local aMemo
local cTxt

cTxt := padr( "-", 60 )

if RecCount2() <> 0
	nRec := recno()
  	go top
  	aMemo := ParsMemo(txt)
  	if len(aMemo)>=5
    		cTxt := trim(amemo[3]) + " " + trim(amemo[4]) + "," + trim(amemo[5])
  	else
    		cTxt:=""
  	endif
  	cTxt:=padr(cTxt,30)
  	cTxt:=" "+alltrim(cTxt)+", Broj: "+idfirma+"-"+idtipdok+"-"+brdok+", od "+dtoc(datdok)+" "
  	go nRec
endif

@ m_x+0,m_y+2 SAY cTxt
return



/*! \fn Rbr()
 *  \brief Redni broj
 */
 
function Rbr()
*{
local cRet

if EOF()
	cRet:=""
elseif VAL(fakt_pripr->podbr)==0
   	cRet:=fakt_pripr->rbr+")"
else
   	cRet:=fakt_pripr->rbr+"."+alltrim(fakt_pripr->podbr)
endif

return padr(cRet,6)
*}


// ---------------------------------
// prikaz partnera u prvoj stavki
// ---------------------------------
static function Part1Stavka()
local cRet:=""

if alltrim(rbr) == "1"
  cRet += trim(IdPartner) + ": " 
endif

return cRet

// ------------------------------------------
// Roba() - prikazi robu 
// ------------------------------------------
function Roba()
local cRet := ""


cRet += trim(StIdROBA())+" "
do case
   case EOF()
  	cRet := ""
   case  alltrim(podbr)=="."
  	aMemo:=ParsMemo(txt)
  	cRet += aMemo[1]
   otherwise
	select F_ROBA
	if !used()
		O_ROBA
	endif
	select roba
   	seek fakt_pripr->IdRoba
 	select fakt_pripr
 	cRet += LEFT(ROBA->naz,40)
endcase

return padr( cRet, 30)


/*! \fn JedinaStavka()
 *  \brief U dokumentu postoji samo jedna stavka
 */
 
function JedinaStavka()
*{
nTekRec := RECNO()
nBrStavki := 0
cIdFirma := IdFirma
cIdTipDok := IdTipDok
cBrDok    := BrDok

go top
HSEEK cIdFirma+cIdTipDok+cBrDok
do while ! eof () .and. (IdFirma==cIdFirma) .and. (IdTipDok==cIdTipDok) ;
      .AND. (BrDok==cBrDok)
	nBrStavki++
   	SKIP
enddo
GO nTekRec
return IIF(nBrStavki==1, .t., .f.)
*}


/*! \fn EdPripr
 *  \brief Sprema pripremu za unos/ispravku dokumenta
 *  \brief Priprema ekran i definise tipke (c+N,a+A...)
 *  \todo Ovu funkciju definitivno treba srediti....
 */
 
function fakt_pripr_keyhandler()
*{
// poziva je ObjDbedit u KnjNal
local nTr2
local cPom
local cENTER:=chr(K_ENTER)+chr(K_ENTER)+chr(K_ENTER)
local aFakt_dok := {}
	
if (Ch==K_ENTER  .and. Empty(BrDok) .and. EMPTY(rbr))
	return DE_CONT
endif

//TekDokument()

select fakt_pripr
do case
	case lFisMark == .t.
	
		lFisMark := .f.

		if fakt_pripr->(reccount()) <> 0
			// priprema nije prazna, nema stampanja racuna
			msgbeep("Priprema nije prazna, stampa fisk.racuna nije moguca!")
			return DE_CONT
		endif

		if gFC_Pitanje == "D" .and. ;
			Pitanje(,"Odstampati racun na fiskalni printer ?", "D") == "N"
			return DE_CONT
		endif

		msgo("stampa na fiskalni printer u toku...")

		// posalji na fiskalni uredjaj
		fakt_fisc_rn( cFFirma, cFTipDok, cFBrDok )

		msgc()

		select fakt_pripr
	
		if gFC_faktura $ "D#G#X"
			
		    if gFC_faktura $ "D#X" .and. ; 
				Pitanje(,"Stampati fakturu ?", "N") == "D"
			
				// stampaj dokument odmah nakon fiskalnog racuna

				StampTXT( cFFirma, cFTipDok, cFBrDok )
		    	
				o_fakt_edit()

				select fakt_pripr
	
		    endif
		
		    if gFC_faktura $ "G#X" .and. ;
				Pitanje(,"Stampati graficku fakturu ?", "N") == "D"
			
				stdokodt( cFFirma, cFTipDok, cFBrDok )
			
				o_fakt_edit()

				select fakt_pripr
			
		    endif

		    return DE_REFRESH
		
		endif
	
	return DE_CONT
	
	case (Ch==K_CTRL_T .or. (Ch=K_DEL .and. gTBDir=="D"))
     		if BrisiStavku()==1
     			return DE_REFRESH
		else
			return DE_CONT
		endif
	case Ch==K_ENTER .and. gTBDir="N"
    		Box("ist", 22, 75, .f.)
   		Scatter()
    		nRbr:=RbrUnum(_Rbr)
    		if edit_fakt_priprema(.f.)==0
     			BoxC()
     			return DE_CONT
    		else
     			Gather()
			// ako treba, promijeni cijenu u sifrarniku
			PrCijSif()  
			BoxC()
			lDirty:=.t.
     			return DE_REFRESH
    		endif
	case Ch==K_CTRL_A  .and. gTBDir="N"
        	ProdjiKrozStavke()
		lDirty:=.t.
        	return DE_REFRESH
	case Ch==K_CTRL_N  .and. gTBDir="N"
        	NoveStavke()
		lDirty:=.t.
        	return DE_REFRESH
	case Ch=K_CTRL_P
		PrintDok()
		lDirty:=.f.
        return DE_REFRESH
	case Ch==K_ALT_L
        	close all
         	label_bkod()
         	o_fakt_edit()
	case Ch==K_ALT_P
        	
		if !CijeneOK("Stampanje")
           		return DE_REFRESH
        	endif
        	
		if EMPTY(fakt_naredni_dokument())
           		return DE_REFRESH
        	endif
		
		cPom:=idtipdok
        	
		if cPom=="13"
			close all
          		FaktStOLPP()
        	else
			StDokOdt( nil, nil, nil )
        	endif
        	
		close all
        	
		o_fakt_edit()
        	
		return DE_REFRESH

	case Ch=K_ALT_A

		// setuj podatke za fiskalni racun
		cFFirma := field->idfirma
		cFTipDok := field->idtipdok
		cFBrDok := field->brdok

		if !CijeneOK("Azuriranje")
           		return DE_REFRESH
        	endif
        	
		CLOSE ALL
        	
		// funkcija azuriranja vraca matricu sa podacima dokumenta
		aFakt_dok := azur_fakt()
		
		lDirty:=.t.
        	
		o_fakt_edit()
	
		if gFc_use == "D" .and. cFTipDok $ "10#11"
			
			if aFakt_dok <> nil .and. LEN( aFakt_dok ) > 0
				cFirma := aFakt_dok[ 1, 1 ] 
				cFTipDok := aFakt_dok[ 1, 2 ] 
				cFBrDok := aFakt_dok[ 1, 3 ] 
			endif
			
			lFisMark := .t.			
		endif
		
		return DE_REFRESH

	case Ch==K_CTRL_F9
		
		BrisiPripr()
		lDirty:=.t.
        	return DE_REFRESH
		
	case Ch==K_F5
        	// kontrola zbira
        	nRec:=RecNo()
        	Box(,12,72)
          		nDug2:=nRab2:=nPor2:=0
          		cDinDem:=dindem
          		nC:=1
          		KonZbira()
          		if nC>9
            			InkeySc(0)
            			@ m_x+1,m_y+2 CLEAR to m_x+12,m_y+70
            			nC:=1
				@ m_x,m_y+2 SAY ""
          		endif
			@ m_x+nC,m_y+2 SAY Replicate("-",65)
            		@ m_x+nC+1,m_y+2   SAY "Ukupno   "
            		@ m_x+nC+1,col()+1 SAY nDug2      pict "9999999.99"
            		@ m_x+nC+1,col()+1 SAY nRab2      pict "9999999.99"
            		@ m_x+nC+1,col()+1 SAY nDug2-nRab2 pict "9999999.99"
            		@ m_x+nC+1,col()+1 SAY nPor2 pict          "9999999.99"
            		@ m_x+nC+1,col()+1 SAY nDug2-nRab2+nPor2 pict "9999999.99"
            		@ m_x+nC+1,col()+1 SAY "("+cDinDem+")"
           		InkeySc(0)
        	BoxC()
        	go nRec
        	return DE_CONT
		
	case UPPER(Chr(Ch))  $ "RX"
        	go top
        	if idtipdok $ "20#27"
         		do while !eof()
           			if UPPER(Chr(Ch))=="R"
            				replace serbr with "*"
           			elseif UPPER(Chr(Ch))=="X"
            				replace serbr with ""
           			endif
           			skip
         		enddo
        	endif
        	Beep(1)
        	go top
        	return DE_REFRESH
		
	case UPPER(Chr(Ch))=="R"
        	return DE_REFRESH
		
	case Ch==K_F9
        	Iz20u10() 
		lDirty:=.t.
        	return DE_REFRESH
		
	case Ch==K_ALT_F10
      		private nEntera:=30
      		for iSekv:=1 to INT(RecCount2()/15)+1
       			cSekv:=chr(K_CTRL_A)
       			for nKekk:=1 to MIN(RecCount2(),15)*20
        			cSekv+=cEnter
       			next
       			keyboard cSekv
      		next
		lDirty:=.t.
      		return DE_REFRESH
		
	case Ch==K_F10
       		Popupfakt_unos_dokumenta()
       		SETLASTKEY(K_CTRL_PGDN)
       		return DE_REFRESH
	
	case Ch==K_F11
		// pregled smeca
		Pripr9View()
		
		select fakt_pripr
		go top
		
		return DE_REFRESH

	case Ch=K_ALT_I
       		RekZadMpO()
       		o_fakt_edit()
       		return DE_REFRESH
		
	case Ch==K_ALT_N
		if lDirty
			MsgBeep("Podaci su mjenjani nakon posljednje stampe##"+;
			"Molimo ponovite stampu dokumenta da bi podaci#" +;
			"na narudzbenici bili azurni")
			return DE_CONT
		endif
       		select fakt_pripr
		nRec:=RECNO()
       		GO TOP
		nar_print(.t.)
		o_fakt_edit()
		select fakt_pripr
       		GO (nRec)
       		return DE_CONT
	case Ch==K_CTRL_R
		if lDirty
			MsgBeep("Podaci su mjenjani nakon posljednje stampe##"+;
			"Molimo ponovite stampu dokumenta da bi podaci#" +;
			"na radnom nalogu bili azurni.")
			return DE_CONT
		endif
       		select fakt_pripr
		nRec:=RECNO()
       		GO TOP
		rnal_print(.t.)
		o_fakt_edit()
		select fakt_pripr
       		GO (nRec)
       		return DE_CONT

	case Ch==K_ALT_U
       		select fakt_pripr
		nRec:=RECNO()
       		GO TOP
       		StUgRabKup()
       		o_fakt_edit()
       		select fakt_pripr
       		GO (nRec)
       		return DE_CONT

	case Ch==K_ALT_E
		
		if Pitanje(,"Exportovati dokument u xls ?", "D" ) == "D"
			
			// export fakture u dbf
			exp_dok2dbf()
			
			o_fakt_edit()	
			select fakt_pripr
			go top

		endif
		
		return DE_CONT

endcase

return DE_CONT





// -------------------------------------------
// brisanje stavke
// -------------------------------------------
function BrisiStavku()
cSecur:=SecurR(KLevel,"BRISIGENDOK")
if m1="X" .and. ImaSlovo ("X", cSecur)   // fakt_pripr->m1
       Beep(1)
       Msg("Dokument izgenerisan, ne smije se brisati !!",0)
       return 0
endif

if !(ImaPravoPristupa(goModul:oDataBase:cName,"DOK","BRISANJE" ))
	MsgBeep(cZabrana)
	return 0
endif
	
if Pitanje(,"Zelite izbrisati ovu stavku ?","D")=="D"
	if (RecCount2 () == 1) .OR. JedinaStavka ()
        	select fakt_doks
           	HSEEK fakt_pripr->IdFirma+fakt_pripr->IdTipDok+fakt_pripr->BrDok
           	if FOUND () .AND. fakt_doks->M1 == "Z"
              		// dokument zapisan samo u DOKS-u
              		DELETE
           	endif
           	select fakt_pripr
        endif
	
	// uzmi opis dokumenta za logiranje
	cOpis := "dokument: " + field->idfirma + "-" + field->idtipdok + "-" + field->brdok
	cStavka := field->rbr
	cArtikal := "artikal: " + field->idroba
	nKolicina := field->kolicina
	nCijena := field->cijena
	dDatumDok := field->datdok

	delete

	nTArea := SELECT()

	// logiraj promjenu brisanja stavke !

	if Logirati(goModul:oDataBase:cName,"DOK","BRISANJE")
		EventLog(nUser, goModul:oDataBase:cName, "DOK", "BRISANJE", ;
			nKolicina, nCijena, nil, nil, ;
			cArtikal,"", cOpis, dDatumDok, DATE(), "", ;
			"Brisanje stavke " + cStavka + " iz pripreme")
	endif

	select (nTArea)

        return 1
endif
return 0



function ProdjiKrozStavke()
	
PushWA()

select fakt_pripr
// go top
Box(,22,75,.f.,"")
nDug:=0
do while !eof()
	skip
	nTR2:=RECNO()
	skip-1
   	Scatter()
   	nRbr:=RbrUnum(_Rbr)
   	BoxCLS()
   	if edit_fakt_priprema(.f.)==0
     		exit
   	endif
   	nDug+=round( _Cijena*_kolicina*PrerCij()*(1-_Rabat/100)*(1+_Porez/100) , ZAOKRUZENJE)
   	@ m_x+23,m_y+2 SAY "ZBIR DOKUMENTA:"
   	@ m_x+23,col()+1 SAY nDug PICTURE '9 999 999 999.99'
   	InkeySc(10)
   	select fakt_pripr
   	Gather()
   	PrCijSif()      // ako treba, promijeni cijenu u sifrarniku
   	go nTR2
enddo
PopWA()
BoxC()

return



function NoveStavke()

nDug:=0
nPrvi:=0

go top
do while .not. EOF() 
    	// kompletan nalog sumiram
	nDug += Round( Cijena*Kolicina*PrerCij()*(1-Rabat/100)*(1+Porez/100) , ZAOKRUZENJE)
   	skip
enddo

go bottom

Box("knjn", 22, 77, .f., "Unos novih stavki")

do while .t.
	Scatter()
   	if AllTrim(_podbr)=="." .and. empty(_idroba)
    		nRbr:=RbrUnum(_Rbr)
    		_PodBr:=" 1"
   	elseif _podbr>=" 1"
    		nRbr:=RbrUnum(_Rbr)
    		_podbr:= str(val(_podbr)+1,2)
   	else
    		nRbr:=RbrUnum(_Rbr)+1
    		_PodBr:="  "
   	endif
   	BoxCLS()
   	_c1:=_c2:=_c3:=SPACE(20)
   	_opis:=space(120)
   	_n1:=_n2:=0
   	if edit_fakt_priprema(.t.) == 0
     		exit
   	endif
   	nDug += Round(_Cijena*_Kolicina*PrerCij()*(1-_Rabat/100)*(1+_Porez/100) , ZAOKRUZENJE)
   	@ m_x+23,m_y+2 SAY "ZBIR DOKUMENTA:"
   	@ m_x+23,col()+2 SAY nDug PICTURE '9 999 999 999.99'
   	InkeySc(10)
   	select fakt_pripr
   	APPEND BLANK
   	Gather()
   	PrCijSif()      // ako treba, promijeni cijenu u sifrarniku
enddo
BoxC()

return
*}


function PrintDok()
local cPom
local lJos

SpojiDuple()  // odradi ovo prije stampanja !
SrediRbrFakt()

o_fakt_edit() // sredirbr zatvori pripremu !!

if gTBDir=="D"
	if eof()
     		skip -1
   	endif
endif

if !CijeneOK("Stampanje")
   	return DE_REFRESH
endif

if EMPTY( fakt_naredni_dokument() )
   	return DE_REFRESH
endif

if IzFMKIni("FAKT","StampajSveIzPripreme","N",PRIVPATH)=="D"
  	lSSIP99:=.t.
else
  	lSSIP99:=.f.
endif

lJos:=.t.

do while lJos
	
	if (IzFMKINI('FAKT','StampaViseDokumenata','N')=="D")
    		lJos := StViseDokMenu()
  	else
    		lJos := .f.
  	endif

  	cPom := idtipdok
	
	gPtxtC50 := .f.

  	StampTXT( nil, cPom, nil )

  	o_fakt_edit()

enddo

lSSIP99:=.f.

return


function RekZadMpO()
*{

select fakt_pripr
GO TOP
cSort1:="IzSifK('PARTN','LINI',idpartner,.f.)+idroba"
cFilt1:="idtipdok=='13'.and.idfirma=="+cm2str(fakt_pripr->idfirma)
INDEX ON &cSort1 to "TMPPRIPR" for &cFilt1
GO TOP
StartPrint()
? "FAKT,",date(),", REKAPITULACIJA ZADUZENJA MALOPRODAJNIH OBJEKATA"
? 
IspisFirme(fakt_pripr->idfirma)
?
do while !EOF()
  cLinija:=IzSifK('PARTN','LINI',idpartner,.f.)
  ? "LINIJA:",cLinija
  ? "---------- ---------------------------------------- ----------"
  ? "  SIFRA                NAZIV ARTIKLA                 KOLICINA "
  ? "---------- ---------------------------------------- ----------"
  do while !EOF() .and. cLinija==IzSifK('PARTN','LINI',idpartner,.f.)
    cIdRoba:=idroba; nKol:=0
    SELECT ROBA; SEEK LEFT(cIdRoba,gnDS); select fakt_pripr
    do while !EOF() .and.;
	     cLinija==IzSifK('PARTN','LINI',idpartner,.f.) .and.;
	     idroba==cIdRoba
      nKol += kolicina
      SKIP 1
    enddo
    ? cIdRoba, LEFT(ROBA->naz,40), STR(nKol,10,0)
  enddo
  ? "---------- ---------------------------------------- ----------"
  ?
  if !EOF()
    FF
  endif
enddo
FF
EndPrint()
CLOSE ALL
return     
*}



/*! \fn CijeneOK(cStr)
 *  \brief
 *  \param cStr
 */
 
function CijeneOK(cStr)
local fMyFlag := .F., lRetFlag := .T., nTekRec
  select fakt_pripr
  nTekRec := RECNO ()
  if fakt_pripr->IdTipDok $ "10#11#15#20#25#27"
     // PROVJERI IMA LI NEODREDJENIH CIJENA ako se radi o fakturi
     Scatter()
     SET ORDER to tag "1"
     Seek2 (_IdFirma + _IdTipDok + _BrDok)
     do while ! EOF() .AND. IdFirma == _IdFirma .AND. ;
           IdTipDok == _IdTipDok .AND. BrDok == _BrDok
        if Cijena == 0 .and. EMPTY (PodBr)
           Beep (3)
           Msg ("Utvrdjena greska na stavci broj " + ;
                ALLTRIM (rbr) + "!#" + ;
                "CIJENA NIJE ODREDJENA!!!", 30)
           fMyFlag := .T.
        endif
        SKIP
     END
     if fMyFlag
        Msg (cStr+" nije dozvoljeno!#Vracate se na pripremu!", 30)
        lRetFlag := .F.
     endif
  endif
  GO nTekRec
return (lRetFlag)
*}



/*! \fn EdOtpr(Ch)
 *  \brief Ispravka otpremnica
 *  \param Ch
 */

function EdOtpr(Ch)
*{
local cDn:="N",nRet:=DE_CONT
do case
	case Ch==ASC(" ") .or. Ch==K_ENTER
   		Beep(1)
   		if m1=" "    // iz DOKS
     			replace m1 with "*"
     			nSuma+=Iznos
   		else
     			replace m1 with " "
     			nSuma-=Iznos
   		endif
   		@ m_x+1,m_Y+55 SAY nSuma pict picdem
   		nRet:=DE_REFRESH
endcase

return nRet
*}


/*! \fn renumeracija_fakt_pripr(cVezOtpr,dNajnoviji)
 *  \brief
 *  \param cVezOtpr
 *  \param dNajnoviji - datum posljednje radjene otpremnice
 */
 
function renumeracija_fakt_pripr(cVezOtpr,dNajnoviji)
*{
//poziva se samo pri generaciji otpremnica u fakturu
local dDatDok
local lSetujDatum:=.f.
private nRokPl:=0
private cSetPor:="N"

select fakt_pripr
set order to tag "1"
go top
if RecCount2 () == 0
	return
endif

nRbr:=999
go bottom
do while !bof()
  	replace rbr with str(--nRbr,3)
  	skip -1
enddo

nRbr:=0
do while !eof()
  	skip
	nTrec:=recno()
	skip -1
  	if Empty(podbr)
   		replace rbr with str(++nRbr,3)
  	else
    		if nRbr==0
			nRbr:=1
		endif
    		replace rbr with str(nRbr,3)
  	endif
  	go nTrec
enddo

go top

Scatter()
_txt1:=_txt2:=_txt3a:=_txt3b:=_txt3c:=""
_dest := SPACE(150)
_m_dveza := SPACE(500)

if IzFmkIni('FAKT','ProsiriPoljeOtpremniceNa50','N',KUMPATH)=='D'
	_BrOtp:=space(50)
else
  	_BrOtp:=space(8)
endif
_DatOtp:=ctod(""); _BrNar:=space(8); _DatPl:=ctod("")
if cVezOtpr==nil
  	cVezOtpr:= ""
endif
aMemo:=ParsMemo(_txt)
if len(aMemo)>0
  	_txt1:=aMemo[1]
endif
if len(aMemo)>=2
  	_txt2:=aMemo[2]
endif
if len(aMemo)>=5
  	_txt3a:=aMemo[3]
	_txt3b:=aMemo[4]
	_txt3c:=aMemo[5]
endif
if len(aMemo)>=9
 	_BrOtp:=aMemo[6]
	_DatOtp:=ctod(aMemo[7])
	_BrNar:=amemo[8]
	_DatPl:=ctod(aMemo[9])
endif
if len(aMemo)>=10 .and. !EMPTY(aMemo[10])
  	cVezOtpr := aMemo[10]
endif

// destinacija
if LEN( aMemo) >= 18
	_dest := PADR( aMemo[18], 150 )
endif

if LEN( aMemo ) >= 19
	_m_dveza := PADR( aMemo[19], 500 )
endif

nRbr:=1

Box("#PARAMETRI DOKUMENTA:",10,75)

  if gDodPar=="1"
    if IzFmkIni('FAKT','ProsiriPoljeOtpremniceNa50','N',KUMPATH)=='D'
      @  m_x+1,m_y+2 SAY "Otpremnica broj:" GET _brotp PICT "@S8"
    else
      @  m_x+1,m_y+2 SAY "Otpremnica broj:" GET _brotp
    endif
   @  m_x+2,m_y+2 SAY "          datum:" GET _Datotp
   @  m_x+3,m_y+2 SAY "Ugovor/narudzba:" GET _brNar
   @  m_x+4,m_y+2 SAY "    Destinacija:" GET _dest PICT "@S45"
   @  m_x+5,m_y+2 SAY "Vezni dokumenti:" GET _m_dveza PICT "@S45"
  endif

  if gDodPar=="1" .or. gDatVal=="D"
   nRokPl:=gRokPl
   @  m_x+6,m_y+2 SAY "Datum fakture  :" GET _DatDok
   if dNajnoviji<>NIL
   	@  m_x+6,m_y+35 SAY "Datum posljednje otpremnice:" GET dNajnoviji WHEN .f. COLOR "GR+/B"
   endif
   @ m_x+7,m_y+2 SAY "Rok plac.(dana):" GET nRokPl PICT "999" WHEN FRokPl("0",.t.) VALID FRokPl("1",.t.)
   @ m_x+8,m_y+2 SAY "Datum placanja :" GET _DatPl VALID FRokPl("2",.t.)
   read
  endif

  // ovo ukidam, ovo je porez na promet proizvoda...
  // to se vise ne koristi !

  //@ m_x+10, m_y+2 SAY "Obracunati PDV ?" GET cSetPor pict "@!" valid cSetPor $ "DN"
  
  read

BoxC()

dDatDok:=_Datdok

UzorTxt()

if !Empty (cVezOtpr)
  _txt2 += Chr(13)+Chr(10)+cVezOtpr
endif

_txt:=Chr(16)+trim(_txt1)+Chr(17) + Chr(16)+_txt2+Chr(17)+;
      Chr(16)+trim(_txt3a)+Chr(17) + Chr(16)+_txt3b+Chr(17)+;
      Chr(16)+trim(_txt3c)+Chr(17) +;
      Chr(16)+_BrOtp+Chr(17) +;
      Chr(16)+dtoc(_DatOtp)+Chr(17) +;
      Chr(16)+_BrNar+Chr(17) +;
      Chr(16)+dtoc(_DatPl)+Chr(17)+;
      IIF(Empty (cVezOtpr), "", Chr(16)+cVezOtpr+Chr(17))+;
      Chr(16)+Chr(17)+;
      Chr(16)+Chr(17)+;
      Chr(16)+Chr(17)+;
      Chr(16)+Chr(17)+;
      Chr(16)+Chr(17)+;
      Chr(16)+Chr(17)+;
      Chr(16)+Chr(17)+;
      Chr(16)+TRIM(_dest)+Chr(17)+;
      Chr(16)+TRIM(_m_dveza)+Chr(17)

if datDok<>dDatDok
	lSetujDatum:=.t.
endif

Gather()

if lSetujDatum .or. cSetPor=="D"    
      // obracunaj porez na promet proizvoda na sve stavke!!
      ObracunajPP(cSetPor,dDatDok)
endif

return


// --------------------------------------------------------
// hendliranje unosa novih stavki u pripremi
// --------------------------------------------------------
function edit_fakt_priprema(fNovi)
local nXpom
local nYpom
local nRec
local aMemo
local cPretvori := "N"
local nPom:=IF(VAL(gIMenu)<1,ASC(gIMenu)-55,VAL(gIMenu))
local lTxtNaKraju := .f.
local cAvRacun
local cListaTxt := ""

lKonsignacija := IzFmkIni("FAKT","Konsignacija","N",KUMPATH) == "D"
lDoks2:=(IzFmkIni("FAKT","Doks2","D", KUMPATH)=="D")

private aPom:={}

AADD(aPom, "00 - Pocetno stanje                ")
AADD(aPom, "01 - Ulaz / Radni nalog ")
if lKonsignacija
	AADD(aPom, "06 - Ulaz u konsig.skladiste")
endif

AADD(aPom, "10 - Porezna faktura")

AADD(aPom, "11 - Porezna faktura gotovina")
AADD(aPom, "12 - Otpremnica" )

AADD(aPom, "13 - Otpremnica u maloprodaju")

if lKonsignacija
AADD(aPom, "16 - Konsignacioni racun")
endif

AADD(aPom, "19 - "+Naziv19ke())

AADD(aPom, "20 - Ponuda/Avansna faktura") 

AADD(aPom, "21 - Revers")


AADD(aPom, "22 - Realizovane otpremnice   ")
AADD(aPom, "23 - Realizovane otpremnice MP")

AADD(aPom, "25 - Knjizna obavijest ")

AADD(aPom, "26 - Narudzbenica ")

AADD(aPom, "27 - Ponuda/Avansna faktura gotovina") 

h:= {}
ASIZE(h, LEN(aPom))
AFILL(h, "")

private nRokPl:=0
private cOldKeyDok:=_idfirma+_idtipdok+_brdok

_txt1:=_txt2:=_txt3a:=_txt3b:=_txt3c:=""   // txt1  -  naziv robe,usluge

if IzFmkIni('FAKT','ProsiriPoljeOtpremniceNa50','N',KUMPATH)=='D'
	_BrOtp:=SPACE(50)
else
  	_BrOtp:=SPACE(8)
endif

_DatOtp:=CToD("")
_BrNar:=SPACE(8)
_DatPl:=CToD("")
_VezOtpr:=""
_Dest:=""
_m_dveza := ""

if lDoks2
	d2k1:=SPACE(15)
  	d2k2:=SPACE(15)
  	d2k3:=SPACE(15)
  	d2k4:=SPACE(20)
  	d2k5:=SPACE(20)
  	d2n1:=SPACE(12)
  	d2n2:=SPACE(12)
endif

set cursor on

if !fnovi
	aMemo:=ParsMemo(_txt)
   	if (LEN(aMemo)>0)
     		_txt1:=aMemo[1]
   	endif
   	if (LEN(aMemo)>=2)
     		_txt2:=aMemo[2]
   	endif
   	if (LEN(aMemo)>=5)
     		_txt3a:=aMemo[3]
		_txt3b:=aMemo[4]
		_txt3c:=aMemo[5]
   	endif
   	if (LEN(aMemo)>=9)
    		_BrOtp:=aMemo[6]
		_DatOtp:=CToD(aMemo[7])
		_BrNar:=aMemo[8]
		_DatPl:=CToD(aMemo[9])
   	endif
   	if (LEN(aMemo)>=10 .and. !EMPTY(aMemo[10]))
     		_VezOtpr:=aMemo[10]
   	endif
   	if lDoks2
     		if (LEN(aMemo)>=11)
      			d2k1:=aMemo[11]
     		endif
     		if (LEN(aMemo)>=12)
       			d2k2:=aMemo[12]
     		endif
     		if (LEN(aMemo)>=13)
       			d2k3:=aMemo[13]
     		endif
     		if (LEN(aMemo)>=14)
       			d2k4:=aMemo[14]
     		endif
     		if (LEN(aMemo)>=15)
       			d2k5:=aMemo[15]
     		endif
     		if (LEN(aMemo)>=16)
       			d2n1:=aMemo[16]
     		endif
     		if (LEN(aMemo)>=17)
       			d2n2:=aMemo[17]
     		endif
   	endif
	
	if LEN(aMemo)>=18
		// destinacija
		public _DEST := aMemo[18]
	endif
	
	if LEN(aMemo)>=19
		// dokumenti veza
		public _m_dveza := aMemo[19]
	endif

else
	
	cPretvori := "D"
	
	_serbr:=SPACE(LEN(serbr))
	public _DEST := ""
	public _m_dveza := ""

   	if glDistrib
     		_ambp:=0
		_ambk:=0
   	endif
	
	_cijena:=0
	
	// ako je ovaj parametar ukljucen ponisti polje roba
	if gResetRoba == "D"
		_idRoba:=SPACE(LEN(_idRoba))
	endif
	
	_kolicina:=0
endif

if (fNovi .and. (nRbr==1 .and. VAL(_podbr)<1)) // prva stavka
	nPom:=if(VAL(gIMenu)<1,ASC(gIMenu)-55,VAL(gIMenu))
   	_IdFirma:=gFirma
	_IdTipDok:="10"
   	_datdok:=date()
   	_zaokr:=2
   	_dindem:=LEFT(VAlBazna(),3)
else
	nPom:=ASCAN(aPom,{|x| _IdTipdok==LEFT(x,2)})
endif

if (nRbr==1 .and. VAL(_podbr) < 1)
	if gNW$"DR"
   		@ m_x+1,m_y+2 SAY gNFirma
   		if RecCount2()==0
     			_idFirma:=gFirma
   		endif
   		@ m_x+1,col()+2 SAY " RJ:" GET _idFirma PICT "@!" VALID {|| EMPTY(_idFirma) .or. _idFirma==gFirma .or. P_RJ(@_idFirma) .and. V_Rj()}

   		read
  	else
   		@  m_x+1,m_y+2 SAY "Firma:" GET _IdFirma VALID P_Firma(@_IdFirma,1,20) .and. LEN(TRIM(_idFirma))<=2
  	endif
    	if gNW=="N"
		read
	endif
    
    __mx := m_x
    __my := m_y
 	
	nPom:= Menu2 (5, 30, aPom, nPom)
    
    m_x := __mx
    m_y := __my
    	
	ESC_Return 0
    	
	_IdTipdok:=LEFT(aPom[nPom],2)

	if !(ImaPravoPristupa(goModul:oDataBase:cName,"DOK","UNOSDOK" + ALLTRIM(_IdTipDok)))
		MsgBeep(cZabrana)
		return 0
	endif
	
    @  m_x+ 2, m_y + 2 SAY PADR(aPom[ASCAN(aPom,{|x|_IdTipdok==LEFT(x,2)})],40)
   	
	if (_idTipDok=="13" .and. gVarNum=="2" .and. gVar13=="2")
     		
		@ m_x+1, 57 SAY "Prodavn.konto" GET _idPartner VALID P_Konto(@_idPartner)
     		read

     		_idPartner:=LEFT(_idPartner,6)
     		
		if (EMPTY(ALLTRIM(_txt3a+_txt3b+_txt3c)).or._idpartner!=idpartner)
      			_txt3a:=MEMOLINE(ALLTRIM(KONTO->naz)+" ("+ALLTRIM(_idpartner)+")",30,1)
      			_txt3b:=MEMOLINE(ALLTRIM(KONTO->naz)+" ("+ALLTRIM(_idpartner)+")",30,2)
      			_txt3c:=MEMOLINE(ALLTRIM(KONTO->naz)+" ("+ALLTRIM(_idpartner)+")",30,3)
     		endif
   	
	elseif (_idtipdok=="13" .and. gVarNum=="1" .and. gVar13=="2")
     		_idPartner:=if(EMPTY(_idPartner),"P1",RJIzKonta(_idPartner+" "))
     		
		@ m_x+1, 57 SAY "RJ - objekat:" GET _idPartner valid P_RJ(@_idPartner) pict "@!"
     		read
     		
		_idpartner:=PADR(KontoIzRJ(_idpartner),6)
     		
		if EMPTY(ALLTRIM(_txt3a+_txt3b+_txt3c)).or._idpartner!=idpartner
      			_txt3a:=MEMOLINE(RJ->id+" - "+ALLTRIM(RJ->naz)+" (ZADU@ENJE)",30,1)
      			_txt3b:=MEMOLINE(RJ->id+" - "+ALLTRIM(RJ->naz)+" (ZADU@ENJE)",30,2)
      			_txt3c:=MEMOLINE(RJ->id+" - "+ALLTRIM(RJ->naz)+" (ZADU@ENJE)",30,3)
     		endif
   	endif

   	if (fNovi .and. (nRbr==1 .and. podbr<"0"))
     		_M1:=" "  // marker generacije nuliraj
     		gOcitBarkod:=.f.
     		if (gMreznoNum=="N")
        		cBroj1:=OdrediNBroj(_idfirma,_idtipdok)   //_brdok
        		if ( _idTipDok $ "12#13" )
				
				cTmpTip := "12"
				cTmpTip2 := "22"
           			
				if _idtipdok == "13"
					cTmpTip := "13"
					cTmpTip2 := "23"
				endif

				cBroj2 := OdrediNBroj( _idfirma, cTmpTip2 )
           			if VAL(LEFT(cBroj1,gNumDio))>=val(left(cBroj2,gNumDio))
              			// maximum izmedju broja 22 i 12
              				_Brdok:=cBroj1
           			else
              				_BrDok:=cBroj2
          			endif
        		else
           			_BrDok:=cBroj1
        		endif
			
			select fakt_pripr
     		else
        		_BrDok := SPACE (LEN (_BrDok))
     		endif
   	endif
  	
	do while .t.	
		
		@  m_x + 2, m_y + 45 SAY "Datum:" GET _datDok

   		@  m_x + 2, col() + 1 SAY "Broj:" GET _BrDok ;
			WHEN gMreznoNum=="N" ;
			VALID !EMPTY(_BrDok) .and. ;
			(!glDistrib .or. !JeStorno10() .or. PuniDVRiz10())
   		
		if lSpecifZips = .t.
     			_txt3a := PADR(_txt3a, 60)
		else
			if IzFMKINI("PoljeZaNazivPartneraUDokumentu","Prosiriti","N",KUMPATH)=="D"
      				_txt3a:=padr(_txt3a,60)
     			else
      				_txt3a:=padr(_txt3a,30)
     			endif
   		endif

   		_txt3b:=padr(_txt3b,30)
   		_txt3c:=padr(_txt3c,30)

   		lUSTipke:=.f.

     		@ nPX := m_x + 4, nPY := m_y + 2 SAY "Partner:" GET _idpartner ;
			PICT "@!" ;
			VALID { || P_Firma( @_idpartner ), ;
				_Txt3a := padr( _idpartner + ".", 30), ;
				IzSifre(), ;
				_isp_partn( _idpartner, nPX, nPY + 18 ) }
     		
		// prodajno mjesto - polje
		if fakt_pripr->(FIELDPOS("IDPM")) <> 0
       			@ m_x + 5, m_y + 2 SAY "P.M.:" GET _idpm ;
				VALID {|| P_IDPM(@_idpm,_idpartner) }
     		endif
   	
		// veza dokumenti
		_m_dveza := PADR( ALLTRIM(_m_dveza), 500 )

		@ m_x + 6, m_y + 2 SAY "Veza:" GET _m_dveza ;
				PICT "@S25"
	
		// destinacija
		_dest := PADR( ALLTRIM(_dest), 80 )
   		
		if ( gDest .and. !glDistrib )
     		      	@ m_x + 7, m_y + 2 SAY "Dest:" GET _dest ;
		      		PICT "@S25"
   		endif

		// radni nalog
		if glRadNal .and. _idtipdok $ "12"
			@ m_x + 8, col()+2 SAY "R.nal:" GET _idrnal ;
				VALID P_RNal(@_idRNal) PICT "@!"
		endif

   		if _idtipdok=="10"

     			if gDodPar=="1"
       				
          			@ m_x + 4, m_y + 51 SAY "Otpremnica broj:" ;
					GET _brotp ;
					PICT "@S8" ;
					WHEN W_BrOtp(fnovi)
      			
				@ m_x + 5, m_y + 51 SAY "          datum:" ;
					GET _Datotp
      				
				@ m_x + 6, m_y + 51 SAY "Ugovor/narudzba:" ;
					GET _brNar
     			
			endif

     			if (gDodPar=="1" .or. gDatVal=="D")
      				
				@ m_x + 7, m_y + 51 SAY "Rok plac.(dana):" ;
					GET nRokPl ;
					PICT "999" ;
					WHEN FRokPl("0",fnovi) ;
					VALID FRokPl("1",fnovi)

				@ m_x + 8, m_y + 51 SAY "Datum placanja :" ;
					GET _DatPl ;
					VALID FRokPl("2",fnovi)
     			
			endif
			
     			if lVrsteP
      				@ m_x + 9, m_y + 38  SAY "Nacin placanja" ;
					GET _idvrstep ;
					PICT "@!" ;
					VALID P_VRSTEP( @_idvrstep, 9, 60 )
     			endif
   		
		elseif (_idtipdok=="06")
      			
        		@ m_x + 5, m_y + 51 SAY "Po ul.fakt.broj:" ;
				GET _brotp ;
				PICT "@S8" ;
				WHEN W_BrOtp(fnovi)

      			@ m_x + 6, m_y + 51 SAY "       i UCD-u :" ;
				GET _brNar
   		
		else
			
			// dodaj i za ostale dokumente
			if IsPDV()
				_DatOtp := _datdok
      				@ m_x + 5 ,m_y + 51 SAY " datum isporuke:" ;
					GET _datotp
			endif
		
		endif
   		
		if (fakt_pripr->(FIELDPOS("idrelac")) <> 0 .and. _idtipdok $ "#11#")
     			@ m_x + 9, m_y + 2  SAY "Relacija   :" ;
				GET _idrelac
   		endif

		if _idTipDok $ "10#11#19#20#25#26#27"
		      @ m_x + 10, m_y + 2 SAY "Valuta ?" ;
		      	GET _dindem ;
			PICT "@!" 
		else
		      @ m_x + 10, m_y + 1 SAY " "
		endif
		
		if _idTipDok $ "10"
		
			cAvRacun := "N"
			if _idvrstep == "AV"
				cAvRacun := "D"
			endif
			
			@ m_x + 10, col() + 4 SAY "Avansni racun (D/N)?:" ;
				GET cAvRacun ;
				PICT "@!" ;
				VALID cAvRacun $ "DN"
		
		endif
			
		// ako nije ukljucena opcija ispravke partnera 
		// pri unosu dokumenta
		if ( gIspPart == "N" )
			READ
   		endif
		
		if (lDoks2 .and. _idtipdok=="10")
      			edit_fakt_doks2()
    		endif
   		
		if (gIspPart == "N")
			_txt3a:=trim(_txt3a)
   			_txt3b:=trim(_txt3b)
   			_txt3c:=trim(_txt3c)
   		endif
		
		ESC_Return 0

   		if (gMreznoNum=="D")
     			exit
   		endif

   		select fakt_doks
   		set order to tag "1"
   		hseek _idfirma+_idtipdok+_brDok
   		if !Found()
      			select fakt_pripr
      			exit
   		else
      			Beep(4)
      			Msg("Vec postoji dokument "+_idtipdok+"-"+_brdok,6)
      			select fakt_pripr
   		endif
  	enddo
  	
	ChSveStavke(fNovi)
else

	@ m_x + 1, m_y+ 2 SAY gNFirma 
	?? "  RJ:", _IdFirma
   	@ m_x+3,m_y+2 SAY PADR(aPom[ASCAN(aPom,{|x|_IdTipdok==LEFT(x,2)})],35)
   	@ m_x+3,m_y+45 SAY "Datum: "
   	?? _datDok
   	@ m_x+3,col()+1 SAY "Broj: "
	?? _BrDok
   	_txt2:=""

endif

// unos stavki dokumenta

if ( gNovine == "D" .and. fNovi )
	@ m_x + 13, m_y + 2 SAY "R.br: " + STR(nRbr,4,0)
else
	@ m_x + 13, m_y + 2 SAY "R.br: " ;
		GET nRbr ;
		PICT "9999"
endif

@ m_x + 13, col() + 2 SAY "Podbr.:" ;
	GET _PodBr ;
	VALID V_Podbr()

cDSFINI := IzFMKINI('SifRoba','DuzSifra','10', SIFPATH)

@ m_x + 15, m_y + 2  SAY "Artikal: " ;
	GET _IdRoba ;
	PICT "@!S10" ;
	WHEN {|| _idroba:=padr(_idroba, VAL(cDSFINI)), W_Roba()} ;
	VALID {|| _idroba:= iif(len(trim(_idroba))<10, left(_idroba,10), _idroba), V_Roba(), GetUsl(fnovi), NijeDupla(fNovi) }

RKOR2:=0

RKOR2+=GetKarC3N2(row()+1)

if (fakt_pripr->(fieldpos("K1"))<>0 .and. gDK1=="D")
	@ m_x+15+RKOR2,m_y+66 SAY "K1" GET _K1 pict "@!"
endif

if (fakt_pripr->(fieldpos("K2"))<>0 .and. gDK2=="D")
	@ m_x+16+RKOR2,m_y+66 SAY "K2" GET _K2 pict "@!"
endif

if (gSamokol!="D" .and. !glDistrib)
    		@ m_x+16+RKOR2,m_y+2  SAY JokSBr()+" "  get _serbr pict "@s15"  when _podbr<>" ."
endif

if (gVarC $ "123" .and. _idtipdok $ "10#12#20#21#25")
	@  m_x + 16 + RKOR2, m_y + 59  SAY "Cijena (1/2/3):" GET cTipVPC
endif

RKOR:=0

lGenStavke:=.f.

if ( _m1=="X" .and.  !fnovi )
	
	// ako je racun, onda ne moze biti cijena 0 !
   	
	@ m_x+18 + RKOR2, m_y + 2  SAY "Kolicina "
	@ row(),col()+1 SAY _kolicina pict pickol
   	
	if _Cijena=0
     		V_Kolicina()
   	endif
else
	
	if (glDistrib .or. lPoNarudzbi)
     		read
     		ESC_return 0
   	endif
   	
	cPako:="(PAKET)"  
	// naziv jedinice mjere veceg pakovanja
   	
	@ m_x+18 + RKOR2, m_y + 2 SAY "Kolicina " ;
		GET _kolicina ;
		PICT pickol ;
		VALID V_Kolicina()
	
endif

private trabat:="%"

if (gSamokol != "D")

	// samo kolicine
	if (_idtipdok=="19" .and. IzFMKIni("FAKT","19KaoRacunParticipacije","N",KUMPATH)=="D")
    		
		_trabat:="I"
    	_rabat:=_kolicina*_cijena*(1-_rabat/100)
    		
		@ m_x+18+RKOR+RKOR2, col() + 2  SAY "Cij." GET _Cijena PICT piccdem WHEN _podbr<>" ."  VALID _cijena>0

    	@ m_x+18+RKOR+RKOR2,col()+2 SAY "Participacija" GET _Rabat PICT "9999.999" when _podbr<>" ."

	else
		
    	@ m_x+18 + RKOR + RKOR2, col() + 2  SAY IF( _idtipdok $ "13#23".and.( gVar13=="2" .or. glCij13Mpc), "MPC.s.PDV", "Cijena ("+ALLTRIM(ValDomaca())+")") GET _Cijena ;
		     PICT piccdem ;
		     WHEN  _podbr<>" ." .and. SKCKalk(.t.) ;
		     VALID SKCKalk(.f.) .and. c_cijena(_cijena, _idtipdok, fNovi)

		if ( PADR(_dindem, 3) <> PADR(ValDomaca(), 3) ) 
			@ m_x+18+ RKOR + RKOR2, col() + 2 SAY "Pr"  GET cPretvori ;
				PICT "@!" ;
				VALID v_pretvori(@cPretvori, _DinDem, _DatDok, @_Cijena )
		endif

		     
   		if !(_idtipdok $ "12#13").or.(_idtipdok=="12".and.gV12Por=="D")
			@  m_x+18+RKOR+RKOR2, col() + 2  SAY "Rabat" get _Rabat ;
			     pict PicCDem ;
			     when _podbr<>" ." .and. !_idtipdok$"15#27"
			
      		@ m_x+18+RKOR+RKOR2,col()+1  GET TRabat ;
			     when {||  trabat:="%",!_idtipdok$"11#15#27" .and. _podbr<>" ."} ;
			     valid trabat $ "% AUCI" .and. V_Rabat() ;
			     pict "@!"
		
		if !IsPdv()
			// nista porez kada je PDV rezim
    			@ m_x+18+RKOR+RKOR2,col()+2 SAY "Porez" GET _Porez ;
			     pict "99.99" ;
			     when {|| if( fNovi .and. _idtipdok=="10" .and. IzFMKIni("FAKT","PPPNuditi","N",KUMPATH)=="D".and.ROBA->tip!="U" , _porez := TARIFA->opp , ), _podbr<>" ." .and. !(roba->tip $ "KV") .and. !_idtipdok$"11#15#27"} ;
			     valid V_Porez()
		endif
		
   	endif
		
	endif

	private cId:="  "


endif //gSamokol=="D"  // samo kolicine

read


_idvrstep := SPACE(2)

if cAvRacun == "D"
	_idvrstep := "AV"
endif

ESC_return 0

if (_idtipdok=="19" .and. IzFMKIni("FAKT","19KaoRacunParticipacije","N",KUMPATH)=="D")
	_trabat:="%"
   	_rabat:=(_kolicina*_cijena-_rabat)/(_kolicina*_cijena)*100
endif

lTxtNaKraju := .t.

if _IdTipDok $ "13" .or. gSamoKol == "D"
	lTxtNaKraju:=.f.
endif

if (_IdTipDok == "12") 
	if  IsKomision(_IdPartner)
		lTxtNaKraju := .t.
	else
		lTxtNaKraju := .f.
	endif
endif

nTArea := SELECT()

if Logirati(goModul:oDataBase:cName,"DOK","UNOS")
	EventLog(nUser, goModul:oDataBase:cName, "DOK", "UNOS", ;
		_kolicina, _cijena, nil, nil, ;
		"artikal: " + _idroba,"", "dokument: " + _idfirma + "-" + _idtipdok + "-" + _brdok, ;
		_datdok, DATE(), "", ;
		"Unos stavke " + _rbr + " novog dokumenta")
endif

select (nTArea)


if lTxtNaKraju
	// uzmi odgovarajucu listu
	cListaTxt := g_txt_tipdok( _idtipdok )
	// unesi tekst
	UzorTxt2( cListaTxt )
endif

if (_podbr==" ." .or.  roba->tip="U" .or. (nrbr==1 .and. val(_podbr)<1))
	
	// odsjeci na kraju prazne linije
	_txt2:=OdsjPLK(_txt2)           
     	if !"Faktura formirana na osnovu" $ _txt2
        	_txt2 += CHR(13)+Chr(10) + _VezOtpr
     	endif
	
	_txt := Chr(16)+trim(_txt1)+Chr(17) 
	_txt += Chr(16)+_txt2+Chr(17)
	_txt += Chr(16)+trim(_txt3a)+Chr(17) 
	_txt += Chr(16)+_txt3b+Chr(17)
	_txt += Chr(16)+trim(_txt3c)+Chr(17)
	
	// 6 - br otpr
	_txt += Chr(16)+_BrOtp+Chr(17)
	// 7 - dat otpr
	_txt += Chr(16)+dtoc(_DatOtp)+Chr(17)
	// 8 - br nar
	_txt += Chr(16)+_BrNar+Chr(17)
	// 9 - dat nar
	_txt += Chr(16)+dtoc(_DatPl)+Chr(17)
	
	// 10
	cPom:=_VezOtpr
	_txt += Chr(16)+ cPom + Chr(17) 
	
	// 11
 	if lDoks2
		cPom:= d2k1
	else
		cPom:= ""
	endif
	_txt += Chr(16)+ cPom + Chr(17) 

	// 12
 	if lDoks2
		cPom:= d2k2
	else
		cPom:= ""
	endif
	_txt += Chr(16)+ cPom + Chr(17) 

	// 13
	if lDoks2
		cPom:= d2k3
	else
		cPom:= ""
	endif
	_txt += Chr(16)+ cPom + Chr(17) 

	// 14
 	if lDoks2
		cPom:= d2k4
	else
		cPom:= ""
	endif
	_txt += Chr(16)+ cPom + Chr(17) 

	// 15
 	if lDoks2
		cPom:= d2k5
	else
		cPom:= ""
	endif
	_txt += Chr(16)+ cPom + Chr(17) 

	// 16
	if lDoks2
		cPom:= d2n1
	else
		cPom:= ""
	endif
	_txt += Chr(16)+ cPom + Chr(17) 

	// 17
	if lDoks2
		cPom:= d2n2
	else
		cPom:= ""
	endif
	_txt += Chr(16)+ cPom + Chr(17) 

	// 18 - Destinacija
	cPom := ALLTRIM(_Dest)
	_txt += Chr(16)+ cPom + Chr(17) 

	// 19 - vezni dokumenti
	cPom := ALLTRIM(_m_dveza)
	_txt += CHR(16) + cPom + CHR(17)

else
	_txt:=""
endif

_Rbr:=RedniBroj(nRbr)

if lPoNarudzbi
	if lGenStavke
     		pIzgSt:=.t.
     		// vise od jedne stavke
     		for i:=1 to LEN(aNabavke)-1
       			// generisi sve izuzev posljednje
       			APPEND BLANK
       			_rbr:=RedniBroj(nRBr)
       			_kolicina:=aNabavke[i,3]
       			_idnar:=aNabavke[i,4]
       			_brojnar:=aNabavke[i,5]
       			if nRBr<>1
         			_txt:=""
       			endif
       			Gather()
       			++nRBr
     		next
     		// posljednja je tekuca
     		_rbr:=RedniBroj(nRbr)
     		_kolicina:=aNabavke[i,3]
     		_idnar:=aNabavke[i,4]
     		_brojnar:=aNabavke[i,5]
   	else
     		// jedna ili nijedna
     		if LEN(aNabavke)>0
       			// jedna
       			_kolicina:=aNabavke[1,3]
       			_idnar:=aNabavke[1,4]
       			_brojnar:=aNabavke[1,5]
     		elseif _kolicina==0
       			// nije izabrana kolicina -> kao da je prekinut unos tipkom Esc
      			return 0
     		endif
   	endif
endif

return 1


// ------------------------------------------
// ispisi partnera 
// ------------------------------------------
static function _isp_partn( cPartn, nX, nY )
local nTArea := SELECT()
local cDesc := "..."
select partn
seek cPartn

if FOUND()
	cDesc := ALLTRIM( field->naz )
	if LEN( cDesc ) > 13
		cDesc := PADR( cDesc, 12 ) + "..."
	endif
endif

@ nX, nY SAY PADR( cDesc, 15 )

select (nTArea)
return .t.



static function _f_idpm( cIdPm )

cIdPM := UPPER(cIdPM)  

return .t.


// ---------------------------------------------
// vraca listu za odredjeni tip dok
// ---------------------------------------------
function g_txt_tipdok( cIdTd )
local cList := ""
local cVal
private cTmptxt

if !EMPTY( cIdTd ) .and. cIdTD $ "10#11#12#13#15#16#20#21#22#23#25#26#27"
	
	cTmptxt := "g" + cIdTd + "ftxt"
	cVal := &cTmptxt

	if !EMPTY( cVal )
		cList := ALLTRIM( cVal )
	endif

endif

return cList





/*! \fn FRokPl(cVar, fNovi)
 *  \brief Validacija roka placanja
 *  \param cVar
 *  \param fNovi
 */
function FRokPl(cVar, fNovi)
local fOtp:=.f.
local lRP0:=.t.

if IzFMKINI('FAKT','DatumRokPlacanja','F') == "O"
	// F  - faktura, O -  otpremnica
 	fOtp := .t.
endif
// ako je dozvoljen rok.placanja samo > 0
if gVFRP0 == "D"
	lRP0:=.f.
endif

if cVar=="0"   // when
	if nRokPl<0
     		return .t.   // ne diraj nista
  	endif
  	if !fNovi
   		if EMPTY(_datpl)
      			nRokPl:=0
   		else
     			if fOtp
       				nRokPl:=_datpl-_datotp
     			else
       				nRokPl:=_datpl-_datdok
     			endif
   		endif
  

      else  // ako je novi, a koristi se rok placanja iz Partn/ROKP
		// i ne koriste se Rabatne skale - odnosno ili jedno ili drugo
		if IzFmkIni("Svi", "RokPlIzSifPartn", "N", SIFPATH) = "D" .and. !IsRabati()
			nRokPl:=IzSifk("PARTN", "ROKP", _IdPartner, .f.)
   		endif
      endif

elseif cVar=="1"  // valid
	// ako je rama-glas
	if !lRP0
		if nRokPl < 1
			MsgBeep("Obavezno unjeti broj dana !")
			return .f.
		endif
	endif
	if nRokPl<0  // moras unijeti pozitivnu vrijednost ili 0
        	MsgBeep("Unijeti broj dana !")
        	return .f.
  	endif
	if nRokPl=0 .and. gRokPl<0
     		// exclusiv, ako je 0 ne postavljaj rok placanja !
    		_datPl:=ctod("")
  	else
    		if fOtp
      			_datPl:=_datotp+nRokPl
    		else
      			_datPl:=_datdok+nRokPl
    		endif
  	endif
else  // cVar=="2" - postavi datum placanja
	if EMPTY(_datpl)
    		nRokPl:=0
  	else
    		if fotp
      			nRokPl:=_datpl-_datotp
    		else
      			nRokPl:=_datpl-_datdok
    		endif
	endif
endif

ShowGets()
return .t.
*}



/*! \fn SljBrDok13(cBrD,nBrM,cKon)
 *  \brief
 *  \param cBrD
 *  \param nBrM
 *  \param cKon
 */
 
function SljBrDok13(cBrD,nBrM,cKon)
*{
local nPom
local cPom:=""
local cPom2

cPom2:=PADL(ALLTRIM(STR(VAL(ALLTRIM(SUBSTR(cKon,4))))),2,"0")
nPom:=AT("/",cBrD)
if VAL(SUBSTR(cBrD,nPom+1,2))!=nBrM
	cPom:="01"
else
	cPom:=NovaSifra(SUBSTR(cBrD,nPom-2,2))
endif
return cPom2+cPom+"/"+PADL(ALLTRIM(STR(nBrM)),2,"0")
*}



/*! \fn PrCijSif()
 *  \brief Promjena cijene u sifrarniku
 */
 
function PrCijSif()
NSRNPIdRoba()
select fakt_pripr
return


/*! \fn RJIzKonta(cKonto)
 *  \brief Vraca radnu jedinicu iz sif->konto na osnovu zadatog konta
 *  \param cKonto   - konto
 *  \return cVrati
 */
 
function RJIzKonta(cKonto)
*{
local cVrati:="  ", nArr:=SELECT(), nRec
  SELECT (F_RJ)
  nRec:=RECNO()
   GO TOP
   do while !EOF()
     if cKonto==RJ->konto
       cVrati:=RJ->id
       exit
     endif
     SKIP 1
   enddo
  GO (nRec)
  SELECT (nArr)
return cVrati
*{


/*! \fn KontoIzRJ(cRJ)
 *  \brief Vraca konto na osnovu radne jedinice
 *  \param cRJ  - radna jedinica
 *  \return cVrati
 */
 
function KontoIzRJ(cRJ)
*{
local cVrati:=SPACE(7)
 PushWA()
   SELECT (F_RJ)
     HSEEK cRJ
     if FOUND()
       cVrati:=RJ->konto
     endif
 PopWA()
return cVrati
*}



/*! \fn fakt_naredni_dokument(fNovi)
 *  \brief Postavlja u pripremi broj dokumenta - puni pripremu
 *  \brief fakt_naredni_dokument(fNovi)->cBroj  - Generise naredni broj dokumenta
 *  \param fNovi
 *  \return _brdok
 */
 
function fakt_naredni_dokument(fNovi)
*{
local nPrev:=SELECT()

if !EMPTY (fakt_pripr->BrDok) .or. eof()  // nema dokumenata
   // ovaj vec ima odredjen broj
   return fakt_pripr->BrDok
endif


if gMreznoNum == "D"
  select fakt_pripr
  nTrecPripr:=recno()
  go top
  _idtipdok:=fakt_pripr->idtipdok
  _idfirma:=fakt_pripr->idfirma
  _datdok:=fakt_pripr->datdok
  _dindem:=fakt_pripr->dindem
  _rezerv:=""
  _idpartner:=""
  _partner:=""
  _iznos:=0
  _rabat:=0
  _m1 := " "
  _idvrstep:=""
  if fakt_doks->(FIELDPOS("DATPL")>0)
    _datpl := CTOD("")
  endif
  if fakt_doks->(FIELDPOS("IDPM")>0)
    _idpm  := SPACE(15)
  endif
  go nTrecPripr
endif


// novi dokument, koji nema svog broja, u pripremi
select fakt_doks
//Scatter ()

if gMreznoNum == "D"
   if !FAKT_DOKS->(FLOCK())
      nOkr := 80     // daj mu 10 sekundi max
      do while nOkr > 0
         InkeySc (.125)
         nOkr --
         if fakt_doks->(FLOCK())
            exit
         endif
      enddo
      if nOkr == 0 .AND. ! fakt_doks->(FLOCK())
         Beep (4)
         Msg ("Nemoguce odrediti broj dokumenta - ne mogu pristupiti bazi!")
         return SPACE (LEN (_BrDok))
      endif
   endif
endif

cBroj1:=OdrediNBroj(_idfirma,_idtipdok)   //_brdok

if _idtipdok $ "12#13"

	if _idtipdok == "12"
		cTmpTip := "12"
		cTmpTip2 := "22"
	endif
	
	if _idtipdok == "13"
		cTmpTip := "13"
		cTmpTip2 := "23"
	endif
	
	cBroj2 := OdrediNBroj( _idfirma, cTmpTip2 )
	if VAL( LEFT( cBroj1, gNumDio )) >= VAL( LEFT(cBroj2, gNumDio))
		_Brdok := cBroj1
	else
      		_BrDok := cBroj2
   	endif
else
	_BrDok := cBroj1
endif

if gMreznoNum == "D"
  // pravi se fizicki append u bazi dokumenata da bi se sacuvalo mjesto
  // za ovaj dokument
  //
  select fakt_doks
  // dbappend()   // append blank skine LOCK sa baze
  appblank2 (.F., .F.)   // ne cisti, ne otkljucavaj
  _M1 := "Z"
  if fieldpos("SIFRA")<>0
    _sifra := sifrakorisn
  endif
  Gather2 ()
  DBUNLOCK()

  // popuni broj dokumenta u svakoj stavki pripreme
  select fakt_pripr
  nTekRec := RECNO ()
  nPrevOrd := INDEXORD()
  set order to
  go top

  LOCATE for IdFirma == _IdFirma .AND. IdTipDok == _IdTipDok ;
             .AND. EMPTY (BrDok)
  do while FOUND ()
    REPLACE BrDok WITH _BrDok
    CONTINUE
  END

  GO nTekRec
  DBSETORDER(nPrevOrd)
endif

return _BrDok
*}



/*! \fn StampTXT(cIdFirma,cIdTipDok,cBrDok)
 *  \brief Stampa dokumenta
 *  \todo Ovo bi trebalo prebaciti u /RPT
 *  \param cIdFirma
 *  \param cIdTipDok
 *  \param cBrDok
 */
 
function StampTXT(cIdFirma, cIdTipDok, cBrDok, lJFill)
private InPicDEM:=PicDEM  // picture iznosa
private InPicCDEM:=PicCDEM  // picture iznosa

if IsPDV()

	if lJFill == nil
		lJFill := .f.
	endif

	if gPdvDrb == "D"
		
		if cIdFirma == nil
			Stdok2p_rb()
		else
			// poziv iz stame liste dokumenata, pitaj
			if Pitanje(, "Stampa graficka faktura ? ", "N") == "D"
					
				Stdok2p_rb(cIdFirma, cIdTipDok, cBrDok)
			else
				StdokPdv(cIdFirma, cIdTipDok, cBrDok, lJFill)
			endif
		endif
	
	else	

		if cIdFirma == nil
			StDokPDV()
		else
			StDokPDV(cIdFirma, cIdTipDok, cBrDok, lJFill)
		endif
	
	endif
	
	PicDEM:=InPicDEM
	PicCDEM:=InPicCDEM
	
	return

endif

cIniName:=PRIVPATH+'fmk.ini'
UzmiIzIni(cIniName,'UpitFax','Slati','N','WRITE')
UzmiIzIni(EXEPATH+'fmk.ini','FAKT','KrozDelphi','N','WRITE')


if IzFmkIni('Fakt','DelphiRB','N',EXEPATH)=='P'
   if Pitanje(,'Zelite li stampu kroz DelphiRB D/N ?','N')=='D'
      UzmiIzIni(EXEPATH+'fmk.ini','FAKT','KrozDelphi','D','WRITE')
   endif
endif
if IzFmkIni('UpitFax','PitatiZaFax','N',PRIVPATH)=='D'
  if Pitanje(,'Zelite li dokument za slanje faks-om D/N ?','N')=='D'
     UzmiIzIni(cIniName,'UpitFax','Slati','D','WRITE')
  endif
endif

if "U" $ TYPE("lSSIP99") .or. !VALTYPE(lSSIP99)=="L"; lSSIP99:=.f.; endif


if !(cIdTipdok $ "10#11#13#15#25#27") .and.;
   !(cIdTipDok $ "20" .and. IzFMKIni("FAKT","PredracuniUvijekSaIznosima","N",PRIVPATH)=="D") .and.;
   (gSamokol=="D" .or. glDistrib.and.cIdTipDok$"26#21" .or.;
    Pitanje(,"Prikaz iznosa na dokumentu ?","D")=="N")
   Picdem:=space(len(picdem))
   PicCdem:=space(len(piccdem))
endif

lPartic := ( IzFMKIni("FAKT","19KaoRacunParticipacije","N",KUMPATH)=="D" )

if gNW=="T"
  if cIdFirma==nil
   StDokM()
  else
   StDokM(cIdFirma,cIdTipdok,cbrdok)
  endif
else
  if cidtipdok=="13"
    if cIdFirma==nil
     if IzFMKINI("STAMPA","Opresa","N",KUMPATH)=="D"
       StDok13s()
     else
       StDok13()
     endif
    else
     if IzFMKINI("STAMPA","Opresa","N",KUMPATH)=="D"
       StDok13s(cIdFirma,cIdTipdok,cbrdok)
     else
       StDok13(cIdFirma,cIdTipdok,cbrdok)
     endif
    endif
  elseif cidtipdok=="19" .and. lPartic
    if cIdFirma==nil
      //StDok2()
    else
      //StDok2(cIdFirma,cIdTipdok,cbrdok)
    endif
  else
   if gTipF=="1"
     if cIdFirma==nil
        StDok()
     else
        Stdok(cIdFirma,cIdTipdok,cbrdok)
     endif
   elseif gTipF=="2"
    if gVarF=="3"
      if cIdFirma==nil
         Stdok23()
      else
         Stdok23(cIdFirma,cIdTipdok,cbrdok)
      endif
    elseif gVarF=="9".or.gVarF=="B"
      if cidtipdok $ "12#10#20#25"
        if cIdFirma==nil
           StDok29()
        else
           StDok29(cIdFirma,cIdTipdok,cbrdok)
        endif
      else
        gVarF:="2"
        if cIdFirma==nil
           //StDok2()
        else
           //StDok2(cIdFirma,cIdTipdok,cbrdok)
        endif
        gVarF:="9"
      endif
    elseif gVarF=="A"
      if cidtipdok $ "12#10#20#25#26"
        if cIdFirma==nil
         StDok2a()
        else
         StDok2a(cIdFirma,cIdTipdok,cbrdok)
        endif
      else
        gVarF:="2"
        if cIdFirma==nil
          //StDok2()
        else
          //StDok2(cIdFirma,cIdTipdok,cbrdok)
        endif
        gVarF:="A"
      endif
    else
      if cIdFirma==nil
        //StDok2()
      else
        //StDok2(cIdFirma,cIdTipdok,cbrdok)
      endif
    endif
   else
    if cIdFirma==nil
      StDok3()
    else
      StDok3(cIdFirma,cIdTipdok,cbrdok)
    endif
   endif
  endif
endif

PicDEM:=InPicDEM
PicCDEM:=InPicCDEM

return
*}


/* \fn ArgToStr()
 * Argument To String
 */
function ArgToStr(xArg)
*{
if (xArg==NIL)
	return "NIL"
else
	return "'"+xArg+"'"
endif
*}



/*! \fn IsprUzorTxt(fSilent,bFunc)
 *  \brief Ispravka teksta ispod fakture
 *  \param fSilent
 *  \param bFunc
 */
 
function IsprUzorTxt(fSilent,bFunc)
local cListaTxt := ""

if fSilent==nil
	fSilent:=.f.
endif
lDoks2 := ( IzFMKINI("FAKT","Doks2","N",KUMPATH)=="D" )
if !fSilent
  Scatter()
endif

if IzFmkIni('FAKT','ProsiriPoljeOtpremniceNa50','N',KUMPATH)=='D'
  _BrOtp:=space(50)
else
  _BrOtp:=space(8)
endif
_DatOtp:=ctod(""); _BrNar:=space(8); _DatPl:=ctod("")
_VezOtpr := ""
_txt1:=_txt2:=_txt3a:=_txt3b:=_txt3c:=""        // txt1  -  naziv robe,usluge
nRbr:=RbrUNum(RBr)

if lDoks2
  d2k1 := SPACE(15)
  d2k2 := SPACE(15)
  d2k3 := SPACE(15)
  d2k4 := SPACE(20)
  d2k5 := SPACE(20)
  d2n1 := SPACE(12)
  d2n2 := SPACE(12)
endif

aMemo:=ParsMemo(_txt)
if len(aMemo)>0
  _txt1:=aMemo[1]
endif
if len(aMemo)>=2
  _txt2:=aMemo[2]
endif
if len(aMemo)>=5
  _txt3a:=aMemo[3]; _txt3b:=aMemo[4]; _txt3c:=aMemo[5]
endif

if len(aMemo)>=9
 _BrOtp:=aMemo[6]; _DatOtp:=ctod(aMemo[7]); _BrNar:=amemo[8]; _DatPl:=ctod(aMemo[9])
endif
if len (aMemo)>=10 .and. !EMPTY(aMemo[10])
  _VezOtpr := aMemo [10]
endif

if lDoks2
  if len (aMemo)>=11
    d2k1 := aMemo[11]
  endif
  if len (aMemo)>=12
    d2k2 := aMemo[12]
  endif
  if len (aMemo)>=13
    d2k3 := aMemo[13]
  endif
  if len (aMemo)>=14
    d2k4 := aMemo[14]
  endif
  if len (aMemo)>=15
    d2k5 := aMemo[15]
  endif
  if len (aMemo)>=16
    d2n1 := aMemo[16]
  endif
  if len (aMemo)>=17
    d2n2 := aMemo[17]
  endif
endif

if !fSilent
	cListaTxt := g_txt_tipdok( _idtipdok )
	UzorTxt2( cListaTxt )
endif

if bFunc<>nil; EVAL(bFunc); endif

_txt:=Chr(16)+trim(_txt1)+Chr(17) + Chr(16)+_txt2+Chr(17)+;
      Chr(16)+trim(_txt3a)+Chr(17) + Chr(16)+_txt3b+Chr(17)+;
      Chr(16)+trim(_txt3c)+Chr(17) +;
      Chr(16)+_BrOtp+Chr(17) +;
      Chr(16)+dtoc(_DatOtp)+Chr(17) +;
      Chr(16)+_BrNar+Chr(17) +;
      Chr(16)+dtoc(_DatPl)+Chr(17) +;
      Iif (Empty (_VezOtpr),Chr(16)+ ""+Chr(17), Chr(16)+_VezOtpr+Chr(17))+;
      IF( lDoks2 , Chr(16)+d2k1+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2k2+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2k3+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2k4+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2k5+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2n1+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2n2+Chr(17) , "" )
if !fSilent
  Gather()
endif
return



/*! \fn PrerCij()
 *  \brief Prerada cijene
 *  \brief Ako je u polje SERBR unesen podatak KJ/KG iznos se dobija kao KOLICINA*CIJENA*PrerCij()  - varijanta R - Rudnik
 *  \return nVrati
 */
 
function PrerCij()
*{
local cSBr:=ALLTRIM(_field->serbr), nVrati:=1
 if !EMPTY(cSbr) .and. cSbr!="*" .and. gNW=="R"
   nVrati := VAL(cSBr)/1000
 endif
return nVrati
*}



/*! \fn TestMainIndex()
 *  \brief
 *  \return lVrati
 */
 
function TestMainIndex()
*{
local lVrati:=.t., lUsedFAKT:=.t., lUsedDOKS:=.t., nOblast:=SELECT()

 local cProblemDok:=""
 SELECT (F_FAKT_DOKS)
 if !USED()
   lUsedDOKS:=.f.
   O_FAKT_DOKS
 else
   PushWA()
   SET ORDER to TAG "1"
 endif
 nDoksRec:=RECCOUNT2()
 SELECT (F_FAKT)
 if !USED()
   lUsedFAKT:=.f.
   O_FAKT
 else
   PushWA()
   SET ORDER to TAG "1"
 endif
 nFaktRec:=RECCOUNT2()
 if !(nDoksRec==0 .and. nFaktRec==0)
   select fakt_doks; GO TOP; Scatter()
   SELECT FAKT; SEEK _IdFirma+_idtipdok+_brdok
   if !FOUND()
     cProblemDok:=_IdFirma+_idtipdok+_brdok
     lVrati:=.f.
   else
     SELECT FAKT; GO TOP; Scatter()
     select fakt_doks; GO TOP; SEEK _IdFirma+_idtipdok+_brdok
     if !FOUND()
       lVrati:=.f.
       cProblemDok:=_IdFirma+"-"+_idtipdok+"-"+_brdok
     endif
   endif
   if !lVrati
     MsgBeep("Problem sa indeksnim bazama ili nepovezanost u FAKT.DBF i DOKS.DBF!#1) Izvrsiti reindeksiranje u modulu install FAKT!#2) Ako 1) ne pomaze, provjerite postojanje DOKUMENTA "+cProblemDok)
   endif
 endif
 SELECT (F_FAKT)
 if lUsedFAKT
   SELECT (F_FAKT)
   PopWA()
 else
   USE
 endif
 SELECT (F_FAKT_DOKS)
 if lUsedDOKS
   SELECT (F_FAKT_DOKS)
   PopWA()
 else
   USE
 endif
 SELECT (nOblast)
return lVrati
*}



// fakt_zagl_firma()
// Ispis zaglavlja na izvjestajima
function fakt_zagl_firma()
?
P_12CPI
U_OFF
B_OFF
I_OFF
?? "Subjekt:"; U_ON; ?? PADC(TRIM(gTS)+" "+TRIM(gNFirma),39); U_OFF
? "Prodajni objekat:"; U_ON; ?? PADC(ALLTRIM(NazProdObj()),30); U_OFF
? "(poslovnica-poslovna jedinica)"
? "Datum:"; U_ON; ?? PADC(SrediDat(DATDOK),18); U_OFF
?
?
return




/*! \fn edit_fakt_doks2()
 *  \brief Editovanje DOKS2.DBF pri unosu fakture
 */
 
function edit_fakt_doks2()
*{

local cPom:="", nArr:=SELECT(), GetList:={}

cPom := IzFMKINI("FAKT","Doks2Edit","N", KUMPATH) 
if cPom == "N"
	return
endif
 
cPom := IzFMKINI("FAKT","Doks2opis","dodatnih podataka",KUMPATH)

if Pitanje(,"Zelite li unos/ispravku "+cPom+"? (D/N)","N")=="N"
    SELECT(nArr)
    return
endif

// ucitajmo dodatne podatke iz FMK.INI u aDodPar
// ---------------------------------------------
aDodPar := {}

 AADD( aDodPar , IzFMKINI( "Doks2" , "ZK1" , "K1" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZK2" , "K2" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZK3" , "K3" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZK4" , "K4" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZK5" , "K5" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZN1" , "N1" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZN2" , "N2" , KUMPATH )  )

 nd2n1 := VAL(d2n1)
 nd2n2 := VAL(d2n2)

 Box(,9,75)
   @ m_x+0, m_y+2 SAY "Unos/ispravka "+cPom COLOR "GR+/B"
   @ m_x+2, m_y+2 SAY PADL(aDodPar[1],30) GET d2k1
   @ m_x+3, m_y+2 SAY PADL(aDodPar[2],30) GET d2k2
   @ m_x+4, m_y+2 SAY PADL(aDodPar[3],30) GET d2k3
   @ m_x+5, m_y+2 SAY PADL(aDodPar[4],30) GET d2k4
   @ m_x+6, m_y+2 SAY PADL(aDodPar[5],30) GET d2k5
   @ m_x+7, m_y+2 SAY PADL(aDodPar[6],30) GET nd2n1 PICT "999999999.99"
   @ m_x+8, m_y+2 SAY PADL(aDodPar[7],30) GET nd2n2 PICT "999999999.99"
   READ
 BoxC()

 if LASTKEY()<>K_ESC
   d2n1 := IF( nd2n1<>0 , ALLTRIM(STR(nd2n1)) , "" )
   d2n2 := IF( nd2n2<>0 , ALLTRIM(STR(nd2n2)) , "" )
 endif

 SELECT (nArr)
return
*}


// -------------------------------------------------
// provjeri cijenu sa cijenom iz sifrarnika
// -------------------------------------------------
static function c_cijena( nCijena, cTipDok, lNovidok )
local lRet := .t.
local nRCijena := nil

// provjeru radi samo kod novog dokumenta
if !lNoviDok
	return lRet
endif

if cTipDok $ "11#15#27"
  
  if gMP == "1"
    nRCijena := roba->mpc
  elseif gMP == "3"
    nRCijena := roba->mpc2
  elseif gMP == "4"
    nRCijena := roba->mpc3
  elseif gMP == "5"
    nRCijena := roba->mpc4
  elseif gMP == "6"
    nRCijena := roba->mpc5
  elseif gMP == "7"
    nRCijena := roba->mpc6
  endif

elseif cTipDok $ "10#"
  // veleprodaja...
  nRCijena := roba->vpc
endif

if gPratiC == "D" .and. nRCijena <> nil .and. nCijena <> nRCijena
	msgbeep("Unesena cijena razlicita od cijene u sifrarniku !" + ; 
		"#Trenutna: " + ALLTRIM(STR(nCijena,12,2)) + ;
		", sifrarnik: " + ALLTRIM(STR(nRCijena,12,2)) )
	if Pitanje(,"Koristiti ipak ovu cijenu ?", "D") == "N"
		lRet := .f.
	endif
endif

return lRet



/*! \fn SKCKalk(lSet)
 *  \brief Set Key za Cijenu iz Kalk
 *  \param lSet
 */
 
function SKCKalk(lSet)
*{
// knjizna obavijest obavezno, a mo§e se podesiti i za ostale dokumente
if _idtipdok=="25" .or.;
     IzFMKIni("FAKT","TipDok"+_idtipdok+"_OmoguciUzimanjeFCJizKALK", "N", KUMPATH)=="D"
    if lSet
      SET KEY K_ALT_K to UCKalk()
      @ row()+1, 27 SAY REPLICATE("-", 26)
      @ row()+1, 27 SAY BROWSE_COL_SEP+" <a-K> uzmi FCJ iz KALK "+BROWSE_COL_SEP
      @ row()+1, 27 SAY REPLICATE("-", 26)
    else
      SET KEY K_ALT_K TO
      @ row()+1, 27 SAY "                          "
      @ row()+1, 27 SAY "                          "
      @ row()+1, 27 SAY "                          "
    endif
  endif
return .t.
*}


/*! \fn StUgRabKup()
 *  \brief Stampa dokumenta ugovor o rabatu
 *  \todo Treba prebaciti u /RPT
 */

function StUgRabKup()
*{
lUgRab:=.t.
lSSIP99:=.f.
//StDok2()
lUgRab:=.f.
return
*}


/*! \fn Naziv19ke()
 *  \brief Vraca naziv za tip dokumenta 19
 *  \return cVrati
 */
 
function Naziv19ke()
*{
local cVrati:=""
cVrati:="Izlaz po ostalim osnovama"
return cVrati
*}


/*! \fn IzborBanke(cToken)
 *  \brief Izbor banke
 *  \param cToken
 *  \return cVrati
 */
 
function IzborBanke(cToken)
*{
local aOpc
local cVrati:=""
local nIzb:=1
local nMax:=0

aOpc := TokToNiz(cToken,",")

for i:=1 to LEN(aOpc)
	aOpc[i]:=TRIM(aOpc[i])
    	nMax:=MAX(LEN(aOpc[i]), nMax)
next

if LEN(aOpc)<1
	cVrati := ""
elseif LEN(aOpc)<2
	cVrati:=aOpc[1]
else
	aOpc[1]:=PADR(aOpc[1],nMax+1)
    	// meni
    	MsgO("Izaberite banku narucioca (Enter-izbor / Esc-bez banke)")
    	nIzb := Menu2(16,30,aOpc,nIzb)
    	MsgC()
    	if nIzb>0
      		cVrati:=aOpc[nIzb]
    	else
      		cVrati:=""
    	endif
endif
return cVrati
*}

// ----------------------------------
// ----------------------------------
function IspisBankeNar(cBanke)
*{
local aOpc
O_BANKE
aOpc:=TokToNiz(cBanke,",")
cVrati:=""

select banke
set order to tag "ID"
for i:=1 to LEN(aOpc)
	hseek SUBSTR(aOpc[i],1,3)
	if Found()
		cVrati += ALLTRIM(banke->naz) + ", " + ALLTRIM(banke->adresa) + ", " + ALLTRIM(banke->mjesto) + ", " + ALLTRIM(aOpc[i]) + "; "
	else
		cVrati += ""
	endif
next
select partn

return cVrati
*}



/*! \fn KonZbira(lVidi)
 *  \brief 
 *  \param lVidi - ako je .t. ili nil mora da postoji i privatna varijabla nC:=1
 */

function KonZbira(lVidi)
*{
if lVidi==nil
	lVidi:=.t.
endif
 go top
 if lVidi
   @ m_x+nC++,m_y+15 SAY "  Uk     Rabat     Uk-Rabat   Por.na Pr  Ukupno"
   ++nC
 endif
 do while !eof()
   cRbr:=rbr
   nDug:=0; nRab:=0; nPor:=0
   do while rbr==cRbr
     nDug+=round( cijena*kolicina*PrerCij() , ZAOKRUZENJE)
     nRab+=round((cijena*kolicina*PrerCij())*Rabat/100 , ZAOKRUZENJE)
     nPor+=round((cijena*kolicina*PrerCij())*(1-Rabat/100)*Porez/100, ZAOKRUZENJE)
     skip
   enddo
   nDug2+=nDug; nRab2+=nRab; nPor2+=nPor
   if lVidi
     @ m_x+nC,m_y+2 SAY  "R.br:"
     @ m_x+nC,col()+1 SAY cRbr
     @ m_x+nC,col()+1 SAY nDug      pict "9999999.99"
     @ m_x+nC,col()+1 SAY nRab      pict "9999999.99"
     @ m_x+nC,col()+1 SAY nDug-nRab pict "9999999.99"
     @ m_x+nC,col()+1 SAY nPor pict          "9999999.99"
     @ m_x+nC,col()+1 SAY nDug-nRab+nPor pict "9999999.99"
     ++nC
     if nC>10
        InkeySc(0)
        @ m_x+1,m_y+2 CLEAR to m_x+12,m_y+70
        nC:=1
	@ m_x,m_y+2 SAY ""
     endif
   endif
 enddo
return
*}


/*! \fn JeStorno10()
 *  \brief True je distribucija i TipDokumenta=10  i krajnji desni dio broja dokumenta="S"
 */
 
function JeStorno10()
*{
return glDistrib .and. _idtipdok=="10" .and. UPPER(RIGHT(TRIM(_BrDok),1))=="S"
*}


/*! \fn RabPor10()
 *  \brief
 */
 
function RabPor10()
*{
local nArr:=SELECT()
SELECT FAKT
SET ORDER to TAG "1"
SEEK _idfirma+"10"+left(_brdok,gNumDio)

do while !EOF() .and.;
    _idfirma+"10"+left(_brdok,gNumDio)==idfirma+idtipdok+left(brdok,gNumDio).and.;
    _idroba<>idroba
    SKIP 1
enddo

if _idfirma+"10"+left(_brdok,gNumDio)==idfirma+idtipdok+left(brdok,gNumDio)
    _rabat    := rabat
    _porez    := porez
    // i cijenu, sto da ne?
    _cijena   := cijena
else
    MsgBeep("Izabrana roba ne postoji u fakturi za storniranje!")
endif
SELECT (nArr)
return
*}


function Popupfakt_unos_dokumenta()
private opc[8]
opc[1]:="1. generacija faktura na osnovu ugovora            "
opc[2]:="2. sredjivanje rednih br.stavki dokumenta"
opc[3]:="3. ispravka teksta na kraju fakture"
opc[4]:="4. svedi protustavkom vrijednost dokumenta na 0"
opc[5]:="5. priprema => smece"
opc[6]:="6. smece    => priprema"
opc[7]:="7. FAKT  <->  diskete"
opc[8]:="8. brisanje dokumenta iz pripreme"
lKonsig := ( IzFMKINI("FAKT","Konsignacija","N",KUMPATH)=="D" )
if lKonsig
 AADD(opc,"9. generisi konsignacioni racun")
else
 AADD(opc,"-----------------------------------------------")
endif
AADD(opc,"A. kompletiranje iznosa fakture pomocu usluga")
AADD(opc,"-----------------------------------------------")
AADD(opc, "C. import txt-a")
AADD(opc, "U. stampa ugovora od do ")

h[1]:=h[2]:=""
close all
private am_x:=m_x,am_y:=m_y
private Izbor:=1
do while .t.
  Izbor:=menu("prip",opc,Izbor,.f.)
  do case
    case Izbor==0
	exit
    case izbor == 1
	m_gen_ug()
    case izbor == 2
	SrediRbrFakt()
    case izbor == 3
      O_FAKT_S_PRIPR
      O_FTXT
      select fakt_pripr
      go top
      lDoks2 := ( IzFMKINI("FAKT","Doks2","N",KUMPATH)=="D" )
      if val(rbr)<>1
	MsgBeep("U pripremi se ne nalazi dokument")
      else
	IsprUzorTxt()
      endif
      close all
    case izbor == 4
       O_ROBA
       O_TARIFA
       O_FAKT_S_PRIPR
       go top
       nDug:=0
       do while !eof()
	  scatter()
	  nDug+=round( _Cijena*_kolicina*(1-_Rabat/100) , ZAOKRUZENJE)
	  skip
       enddo
       _idroba:=space(10)
       _kolicina:=1
       _rbr:=str(RbrUnum(_Rbr)+1,3)
       _rabat:=0
       cDN:="D"
       Box(,4,60)
	  @ m_x+1 ,m_y+2 SAY "Artikal koji se stvara:" GET _idroba  pict "@!" valid P_Roba(@_idroba)
	  @ m_x+2 ,m_y+2 SAY "Kolicina" GET _kolicina valid {|| _kolicina<>0 } pict pickol
	  read
	  if lastkey()==K_ESC
	    boxc()
	    close all
	    return DE_CONT
	  endif
	  _cijena:=nDug/_kolicina
	  if _cijena<0
	    _Cijena:=-_cijena
	  else
	    _kolicina:=-_kolicina
	  endif
	  @ m_x+3 ,m_y+2 SAY "Cijena" GET _cijena  pict piccdem
	  cDN:="D"
	  @ m_x+4 ,m_y+2 SAY "Staviti cijenu u sifrarnik ?" GET cDN valid cDN $ "DN" pict "@!"
	  read
	  if cDN=="D"
	     select roba; replace vpc with _cijena; select fakt_pripr
	  endif
	  if lastkey()=K_ESC
	    boxc(); close all; return DE_CONT
	  endif
	  append blank
	  Gather()
       BoxC()
    case izbor == 5
    	// stara funkcija
       	// ObracunajPP()

	// priprema -> smece
	azuriraj_smece()

    case izbor == 6
    	// smece -> priprema
	povrat_smece()

    case izbor == 7
       faktprenosdiskete()
    case izbor == 8
       O_FAKT_S_PRIPR
       lJos:=.t.
       do while lJos
	 lJos:=StViseDokMenu("BRISI")
	 if LEN(gFiltNov)==0
	   GO TOP
	   exit
	 endif
	 cPom:=""
	 do while !EOF() .and. idfirma+idtipdok+brdok==gFiltNov
	   SKIP 1
	   nnextRec:=RECNO()
	   SKIP -1
	   cPom:=idfirma+"-"+idtipdok+"-"+brdok
	   DELETE
	   GO (nnextRec)
	 enddo
	 if !EMPTY(cPom)
	   MsgBeep("Dokument "+cPom+" izbrisan iz pripreme!")
	 endif
       enddo
       CLOSE ALL
    case izbor == 9 .and. lKonsig
       GKRacun()
    case izbor == 10
       KomIznosFakt()
    case izbor == 12
    	ImportTxt()
    case izbor == 13
    	ug_za_period()
  endcase
enddo
m_x:=am_x
m_y:=am_y

o_fakt_edit()

select fakt_pripr
go bottom

return
*}


function ImportTxt()
*{
CLOSE ALL
cKom :="fmk.exe --batch --exe:ImportTxt --db:"+STRTRAN(TRIM(gNFirma), " ", "_") 
RUN &cKom

o_fakt_edit()
return
*}



function GetKarC3N2(mx)
*{
local nKor:=0
local nDod:=0
local x:=0
local y:=0

if (fakt_pripr->(fieldpos("C1"))<>0 .and. gKarC1=="D")
	@ mx+(++nKor),m_y+2 SAY "C1" GET _C1 pict "@!"
	nDod++
endif

if (fakt_pripr->(fieldpos("C2"))<>0 .and. gKarC2=="D")
	SljPozGet(@x,@y,@nKor,mx,nDod)
	@ x,y SAY "C2" GET _C2 pict "@!"
	nDod++
endif

if (fakt_pripr->(fieldpos("C3"))<>0 .and. gKarC3=="D")
	SljPozGet(@x,@y,@nKor,mx,nDod)
	@ x,y SAY "C3" GET _C3 pict "@!"
	nDod++
endif

if (fakt_pripr->(fieldpos("N1"))<>0 .and. gKarN1=="D")
	SljPozGet(@x,@y,@nKor,mx,nDod)
	@ x,y SAY "N1" GET _N1 pict "999999.999"
	nDod++
endif

if (fakt_pripr->(fieldpos("N2"))<>0 .and. gKarN2=="D")
	SljPozGet(@x,@y,@nKor,mx,nDod)
	@ x,y SAY "N2" GET _N2 pict "999999.999"
	nDod++
endif

if (fakt_pripr->(fieldpos("opis"))<>0)
	SljPozGet(@x,@y,@nKor,mx,nDod)
	@x,y SAY "Opis" GET _opis pict "@S40"
	nDod++
endif

if nDod>0
	++nKor
endif

return nKor
*}


static function SljPozGet(x,y,nKor,mx,nDod)
*{
if nDod>0
	if nDod%3==0
		x:=mx+(++nKor)
		y:=m_y+2
	else
		x:=mx+nKor
		y:=col()+2
	endif
else
	x:=mx+(++nKor)
	y:=m_y+2
endif
return
*}

