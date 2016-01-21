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


#include "f18.ch"



function GenProd()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc, "1. pocetno stanje                                        ")
AADD(_opcexe, {|| kalk_prod_pocetno_stanje() } )
AADD(_opc, "2. pocetno stanje (stara opcija/legacy)")
AADD(_opcexe, {|| PocStProd() } )
AADD(_opc, "3. inventure    ")
AADD(_opcexe, {|| MnuPInv()})
AADD(_opc, "4. nivelacije")
AADD(_opcexe, {|| MnuPNivel()})
AADD(_opc, "5. setuj mpc po uzoru na postojecu za % ")
AADD(_opcexe, {|| set_mpc_2()})

f18_menu( "gdpr", nil, _izbor, _opc, _opcexe )

return



static function MnuPNivel()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc, "1. nivelacija prema zadatnom %                  ")
AADD(_opcexe, {|| NivPoProc()})
AADD(_opc, "2. vrati na cijene prije posljednje nivelacije")
AADD(_opcexe, {|| VratiZadNiv()})
AADD(_opc, "---------------------------------------------")
AADD(_opcexe, {|| nil})
AADD(_opc, "3. generacija nivelacije za sve prodavnice")
AADD(_opcexe, {|| get_nivel_p() })
AADD(_opc, "4. pregled promjene cijena (roba->zanivel)")
AADD(_opcexe, {|| rpt_zanivel() })
AADD(_opc, "5. pregled efekata nivelacije za sve prodavnice")
AADD(_opcexe, {|| result_nivel_p()})
AADD(_opc, "6. azuriranje nivelacije za sve prodavnice")
AADD(_opcexe, {|| obr_nivel_p()})
AADD(_opc, "7. setovanje mpc nakon obradjenih nivelacija")
AADD(_opcexe, {|| set_mpc_iz_zanivel()})
AADD(_opc, "8. kopiranje podataka n.cijena 2 -> n.cijena 1")
AADD(_opcexe, {|| zaniv2_zaniv()})
AADD(_opc, "9. stampa obrazaca o prom.cijena za sve prod.")
AADD(_opcexe, {|| o_pr_cijena()})
AADD(_opc, "---------------------------------------------")
AADD(_opcexe, {|| nil})
AADD(_opc, "10. PDV nivelacija - zadrzi cijene")
AADD(_opcexe, {|| get_zcnivel()})

f18_menu( "pmn", nil, _izbor, _opc, _opcexe  )

return



static function MnuPInv()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc, "1. dokument inventure                       ")
AADD(_opcexe, {|| IP()})
AADD(_opc, "2. inventura-razlika prema postojecoj IP ")
AADD(_opcexe, {|| gen_ip_razlika()})
AADD(_opc, "3. na osnovu IP generisi 80-ku ")
AADD(_opcexe, {|| gen_ip_80()})

f18_menu( "pmi", nil, _izbor, _opc, _opcexe )

return




function GenNivP()

O_KONTO
O_TARIFA
O_SIFK
O_SIFV
O_ROBA

Box(,4,70)

cIdFirma:=gFirma
cIdVD:="19"
cOldDok:=space(8)
cIdkonto:=padr("1320",7)
dDatDok:=date()

@ m_x+1,m_Y+2 SAY "Prodavnica:" GET  cidkonto valid P_Konto(@cidkonto)
@ m_x+2,m_Y+2 SAY "Datum     :  " GET  dDatDok
@ m_x+4,m_y+2 SAY "Dokument na osnovu koga se vrsi inventura:" GET cIdFirma
@ m_x+4,col()+2 SAY "-" GET cIdVD
@ m_x+4,col()+2 SAY "-" GET cOldDok

read
ESC_BCR

BoxC()

O_KONCIJ
O_KALK_PRIPR
O_KALK
private cBrDok:=SljBroj(cidfirma,"19",8)

nRbr:=0
set order to tag "1"
//"KALKi1","idFirma+IdVD+BrDok+RBr","KALK")

select koncij; seek trim(cidkonto)
select kalk
hseek cidfirma+cidvd+colddok
do while !eof() .and. cidfirma+cidvd+colddok==idfirma+idvd+brdok

nTrec:=recno()    // tekuci slog
cIdRoba:=Idroba
nUlaz:=nIzlaz:=0
nMPVU:=nMPVI:=nNVU:=nNVI:=0
nRabat:=0
select roba; hseek cidroba; select kalk
set order to tag "4"
//"KALKi4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALK")
seek cidfirma+cidkonto+cidroba

do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+pkonto+idroba

  if ddatdok<datdok  // preskoci
      skip; loop
  endif

  if roba->tip $ "UT"
      skip; loop
  endif

  if pu_i=="1"
    nUlaz+=kolicina-GKolicina-GKolicin2
    nMPVU+=mpcsapp*kolicina
    nNVU+=nc*kolicina

  elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
    nIzlaz+=kolicina
    nMPVI+=mpcsapp*kolicina
    nNVI+=nc*kolicina

  elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
    nUlaz-=kolicina
    nMPVU-=mpcsapp*kolicina
    nnvu-=nc*kolicina

  elseif pu_i=="3"    // nivelacija
    nMPVU+=mpcsapp*kolicina

  elseif pu_i=="I"
    nIzlaz+=gkolicin2
    nMPVI+=mpcsapp*gkolicin2
    nNVI+=nc*gkolicin2
  endif

  skip
enddo // po orderu 4

select kalk; set order to tag "1"; go nTrec

 select roba
 hseek cidroba
 select kalk_pripr
 scatter()
 append ncnl
 _idfirma:=cidfirma; _idkonto:=cidkonto; _pkonto:=cidkonto; _pu_i:="3"
 _idroba:=cidroba; _idtarifa:=kalk->idtarifa
 _idvd:="19"; _brdok:=cbrdok
 _rbr:=RedniBroj(++nrbr)
 _kolicina:=nUlaz-nIzlaz
 _datdok:=_DatFaktP:=ddatdok
 _fcj:=kalk->fcj
 _mpc:=kalk->mpc
 _mpcsapp:=kalk->mpcsapp
 if (_kolicina>0 .and.  round((nmpvu-nmpvi)/_kolicina,4)==round(_fcj,4)) .or.;
    ( round(_kolicina,4)=0 .and. round(nmpvu-nmpvi,4)=0)
    _ERROR:="0"
 else
    _ERROR:="1"
 endif

 my_rlock()
 Gather2()
 my_unlock()

 select kalk

 skip
enddo

my_close_all_dbf()
return


// Generisanje dokumenta tipa 19 tj. nivelacije na osnovu zadanog %
function NivPoProc()
local nStopa:=0.0
local nZaokr:=1

O_KONTO
O_TARIFA
O_SIFK
O_SIFV
O_ROBA

cVarijanta:="2"

Box(,7,60)
cIdFirma:=gFirma
cIdkonto:=padr("1320",7)
dDatDok:=date()
@ m_x+1,m_Y+2 SAY "Prodavnica :" GET  cidkonto valid P_Konto(@cidkonto)
@ m_x+2,m_Y+2 SAY "Datum      :" GET  dDatDok
@ m_x+3,m_Y+2 SAY "Cijenu zaokruziti na (br.decimalnih mjesta) :" GET nZaokr PICT "9"
@ m_x+4,m_Y+2 SAY "(1) Popust prema stopama iz polja ROBA->N1"
@ m_x+5,m_Y+2 SAY "(2) popust prema stopama iz polja ROBA->N2"
@ m_x+6,m_Y+2 SAY "(3) popust prema jedinstvenoj stopi      ?"  GET cVarijanta valid cVarijanta$"123"

read
ESC_BCR

if cVarijanta=="3"
    @ m_x+7,m_Y+2 SAY "Stopa promjene cijena (- za smanjenje)      :" GET nStopa PICT "999.99%"
    read
    ESC_BCR
endif

BoxC()

O_KONCIJ
O_KALK_PRIPR
O_KALK
private cBrDok:=SljBroj(cidfirma,"19",8)

nRbr:=0
set order to tag "4"

MsgO("Generacija dokumenta 19 - "+cbrdok)

select koncij
seek trim(cidkonto)
select kalk
hseek cidfirma+cidkonto

do while !eof() .and. cIdFirma+cIdKonto==idFirma+pKonto

    cIdRoba:=idRoba
    nUlaz:=nIzlaz:=0
    nMPVU:=nMPVI:=nNVU:=nNVI:=0
    nRabat:=0
    select roba
    hseek cIdRoba
    select kalk

    do while !eof() .and. cIdFirma+cIdKonto+cIdRoba==idFirma+pKonto+idRoba

        if dDatDok<datDok  // preskoci
            skip
            loop
        endif
        if roba->tip $ "UT"
            skip
            loop
        endif

        if pu_i=="1"
            nUlaz+=kolicina-gKolicina-gKolicin2
            nMPVU+=mpcSaPp*kolicina
            nNVU+=nc*kolicina

        elseif pu_i=="5"  .and. !(idVd $ "12#13#22")
            nIzlaz+=kolicina
            nMPVI+=mpcSaPp*kolicina
            nNVI+=nc*kolicina

        elseif pu_i=="5"  .and. (idVd $ "12#13#22")    // povrat
            nUlaz-=kolicina
            nMPVU-=mpcSaPp*kolicina
            nNVU-=nc*kolicina

        elseif pu_i=="3"    // nivelacija
            nMPVU+=mpcSaPp*kolicina

        elseif pu_i=="I"
            nIzlaz+=gKolicin2
            nMPVI+=mpcSaPp*gKolicin2
            nNVI+=nc*gKolicin2
        endif

        skip
    enddo

    select roba
    hseek cIdRoba

    select kalk

    if (cVarijanta="1" .and. roba->n1=0)
        //skip
        loop
    endif

    if (cVarijanta="2" .and. roba->n2=0)
        //skip
        loop
    endif


    if (round(nUlaz-nIzlaz,4)<>0) .or. (round(nMpvU-nMpvI,4)<>0)
        PushWA()
        select kalk_pripr
        scatter()
        append ncnl
        _idfirma:=cIdFirma
        _pkonto:=_idKonto:=cIdKonto
        _mkonto:=""
        _mu_i:=""
        _pu_i:="3"
        _idroba:=cIdRoba
        _idtarifa:=roba->idtarifa
        _idvd:="19"
        _brdok:=cBrDok
        _rbr:=RedniBroj(++nRbr)
        _kolicina:=nUlaz-nIzlaz
        _datdok:=_DatFaktP:=dDatDok
        _error:="0"
        _fcj:=UzmiMPCSif()

        if cVarijanta=="1"  // roba->n1
            _mpcsapp := ROUND( -_fcj*roba->N1/100 , nZaokr )
        elseif cVarijanta=="2"
            _mpcsapp := ROUND( -_fcj*roba->N2/100 , nZaokr )
        else
            _mpcsapp := ROUND( _fcj*nStopa/100 , nZaokr )
        endif

        private aPorezi:={}
        private fNovi:=.t.
        VRoba(.f.)
        //P_Tarifa(@_idTarifa)
        select kalk_pripr
        my_rlock() 
        Gather2()
        my_unlock()
        select kalk
        PopWA()
    endif

enddo

MsgC()
my_close_all_dbf()
return



// Generise novu 19-ku tj.nivelaciju na osnovu vec azurirane
function VratiZadNiv()
local nSlog:=0,nPom:=0,cStBrDok:=""

O_KONTO
O_TARIFA
O_SIFK
O_SIFV
O_ROBA

Box(,4,60)
cIdFirma:=gFirma
cIdKonto:=padr("1320",7)
dDatDok:=date()
@ m_x+1,m_Y+2 SAY "Prodavnica :" GET  cIdKonto valid P_Konto(@cIdKonto)
@ m_x+2,m_Y+2 SAY "Datum      :" GET  dDatDok
read
ESC_BCR

BoxC()

O_KALK_DOKS
set order to tag "1"
go top
SEEK cIdFirma+"20"
skip -1

do while (!BOF() .and. idvd=="19")
    if (pkonto==cIdKonto .and. datdok<=dDatDok)
        exit
    endif
    skip -1
enddo

if (idvd!="19" .or. pkonto!=cIdKonto)
    Msg("Ne postoji nivelacija za zadanu prodavnicu u periodu do unesenog datuma!",6)
    CLOSERET
else
    cStBrDok:=kalk_doks->brdok
    Box(,4,60)
    @ m_x+1, m_y+2 SAY "Nivel. broj "+cIdFirma+" - 19 -" GET cStBrDok
    read
    ESC_BCR
    BoxC()
endif

O_KALK_PRIPR
O_KALK
private cBrDok:=SljBroj(cIdFirma,"19",8)

nRbr:=0
select KALK
set order to tag "1"
go top
SEEK cIdFirma+"19"+cStBrDok

MsgO("Generacija dokumenta 19 - "+cBrDok)
DO WHILE !EOF().and.idvd=="19".and.brdok==cStBrDok
  SELECT ROBA; HSEEK KALK->idroba
  SELECT KALK; nSlog:=RECNO()
//  nPom := StanjeProd( cIdFirma+cIdKonto+KALK->idroba , ddatdok )
  set order to tag "1"
  GO nSlog
  Scatter()
  SELECT kalk_pripr; APPEND NCNL

  _idkonto:=cidkonto; _pkonto:=cidkonto; _pu_i:=_mu_i:=""
  _idtarifa:=roba->idtarifa
  _idvd:="19"; _brdok:=cbrdok
  _rbr:=RedniBroj(++nrbr)
  _kolicina:=nPom
  _datdok:=_DatFaktP:=ddatdok
  _ERROR:=""
  _fcj:=_fcj+_mpcsapp
  _mpcsapp:=-_mpcsapp

  Gather2()
  SELECT KALK
  SKIP 1
ENDDO
MsgC()

my_close_all_dbf()
return






// Generisanje nivelacije radi korekcije MPC
function KorekMPC()
local dDok := DATE()
local nPom := 0
private cMagac := fetch_metric( "kalk_sredi_karicu_mpc", my_user(), PADR( "1330", 7) )
 
O_KONTO
 
cSravnitiD:="D"
 
private cUvijekSif:="D"
 
Box(,6,50)
	@ m_x+1,m_y+2 SAY "Konto prodavnice: " GEt cMagac pict "@!" valid P_konto(@cMagac)
   	@ m_x+2,m_y+2 SAY "Sravniti do odredjenog datuma:" GET cSravnitiD valid cSravnitiD $ "DN" pict "@!"
   	@ m_x+4,m_y+2 SAY "Uvijek nivelisati na MPC iz sifrarnika:" GET cUvijekSif valid cUvijekSif $ "DN" pict "@!"
   	read
	ESC_BCR
   	@ m_x+6,m_y+2 SAY "Datum do kojeg se sravnjava" GET dDok
   	read
	ESC_BCR
BoxC()

O_KONCIJ
SEEK trim( cMagac )
 
O_ROBA
O_KALK_PRIPR
O_KALK

nTUlaz:=nTIzlaz:=0
nTVPVU:=nTVPVI:=nTNVU:=nTNVI:=0
nTRabat:=0
lGenerisao := .f.
private nRbr:=0

select kalk
cBrNiv := kalk_sljedeci(gfirma,"19")

select kalk
set order to tag "4"
HSEEK gFirma + cMagac

Box(,6,65)

@ 1+m_x, 2+m_y SAY "Generisem nivelaciju... 19-" + cBrNiv

do while !eof() .and. idfirma+pkonto=gFirma+cMagac

	cIdRoba:=Idroba
	nUlaz:=nIzlaz:=0
	nVPVU:=nVPVI:=nNVU:=nNVI:=0
	nRabat:=0

	select roba
	hseek cIdroba
	select kalk

	if roba->tip $ "TU"
		skip
		loop
	endif

	cIdkonto := pkonto

	nUlazVPC  := UzmiMPCSif()
	nStartMPC := nUlazVPC  
	// od ove cijene pocinjemo

	nPosljVPC := nUlazVPC

	@ 2+m_x, 2+m_y SAY "ID roba: " + cIdRoba
	@ 3+m_x, 2+m_y SAY "Cijena u sifrarniku " + ALLTRIM(STR(nUlazVpc))

	do while !eof() .and. gFirma+cidkonto+cidroba==idFirma+pkonto+idroba

  		if roba->tip $ "TU"
    		skip
    		loop
  		endif
  
		if cSravnitiD=="D"
     		if datdok>dDok
          		skip
				loop
     		endif
  		endif

  		if pu_i=="1"
    		nUlaz+=kolicina-gkolicina-gkolicin2
    		nVPVU+=mpcsapp*(kolicina-gkolicina-gkolicin2)
    		nUlazVPC:=mpcsapp
    		if mpcsapp<>0
				nPosljVPC:=mpcsapp
			endif
  		elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
    		nIzlaz+=kolicina
    		nVPVI+=mpcsapp*kolicina
    		if mpcsapp<>0
				nPosljVPC:=mpcsapp
			endif
  		elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
   	 		nUlaz-=kolicina
    		nVPVU-=mpcsapp*kolicina
    		if mpcsapp<>0
				nPosljVPC:=mpcsapp
			endif
  		elseif pu_i=="3"    
			// nivelacija
    		nVPVU+=mpcsapp*kolicina
    		if mpcsapp+fcj<>0
				nPosljVPC:=mpcsapp+fcj
			endif
  		elseif pu_i=="I"
    		nIzlaz+=gkolicin2
    		nVPVI+=mpcsapp*gkolicin2
    		if mpcsapp<>0
				nPosljVPC:=mpcsapp
			endif
  		endif
  		skip
	enddo

  	nRazlika := 0
  	//nStanje := ROUND( nUlaz - nIzlaz, 4 )
  	//nVPV := ROUND( nVPVU - nVPVI, 4 )
  	
	nStanje := ( nUlaz - nIzlaz )
	nVPV := ( nVPVU - nVPVI )

	select kalk_pripr

  	if cUvijekSif == "D"
    	nUlazVPC := nStartMPC
  	endif

  	if ROUND( nStanje, 4 ) <> 0 .or. ROUND( nVPV, 4 ) <> 0
    	if ROUND( nStanje, 4 ) <> 0
       		if cUvijekSif == "D" .and. ROUND( nUlazVPC - nVPV / nStanje, 4 ) <> 0
          		nRazlika := nUlazVPC - nVPV / nStanje
       		else  
				// samo ako kartica nije ok
        		if ROUND( nPosljVPC - nVPV / nStanje, 4 ) = 0  
					// kartica izgleda ok
          			nRazlika := 0
        		else
          			nRazlika := nUlazVPC - nVPV / nStanje
          			// nova - stara cjena
        		endif
       		endif
    	else
        	nRazlika := nVPV
    	endif

    	if ROUND( nRazlika, 4 ) <> 0

      		lGenerisao := .t.

     	 	@ 4 + m_x, 2 + m_y SAY "Generisao stavki: " + ALLTRIM(STR(++nRbr))

      		append blank

      		replace idfirma with gFirma, idroba with cIdRoba, idkonto with cIdKonto,;
              datdok with dDok,;
              idtarifa with roba->idtarifa,;
              datfaktp with dDok,;
              kolicina with nStanje,;
              idvd with "19", brdok with cBrNiv ,;
              rbr with STR(nRbr,3),;
              pkonto with cMagac,;
              pu_i with "3"

      		if nStanje <> 0
           		replace fcj with nVPV/nStanje
                replace mpcsapp with nRazlika
      		else
           		replace kolicina with 1
                replace fcj with nRazlika+nUlazVPC
                replace mpcsapp with -nRazlika
                replace Tbanktr with "X"
      		endif

    	endif

  	endif

  	select kalk

enddo

BoxC()

if lGenerisao
    MsgBeep("Generisana nivelacija u kalk_pripremi - obradite je!")
endif

my_close_all_dbf()
return


// Generisanje dokumenta tipa 11 na osnovu 13-ke
function Iz13u11()

O_KONTO
O_KALK_PRIPR
O_KALK_PRIPR2
O_KALK
O_SIFK
O_SIFV
O_ROBA

select kalk_pripr; go top
private cIdFirma:=idfirma,cIdVD:=idvd,cBrDok:=brdok
if !(cidvd $ "13")   .or. Pitanje(,"Zelite li zaduziti drugu prodavnicu ?","D")=="N"
  closeret
endif

private cProdavn:=space(7)
Box(,3,35)
 @ m_x+2,m_y+2 SAY "Prenos u prodavnicu:" GET cProdavn valid P_Konto(@cProdavn)
 read
BoxC()
private cBrUlaz:="0"
select kalk
seek cidfirma+"11�"
skip -1
if idvd<>"11"
     cBrUlaz:=space(8)
else
     cBrUlaz:=brdok
endif
cBrUlaz:=UBrojDok(val(left(cBrUlaz,5))+1,5,right(cBrUlaz,3))

select kalk_pripr
go top
private nRBr:=0
do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cbrdok==brdok
  scatter()
  select roba; hseek _idroba
  select kalk_pripr2
  append blank

  _idpartner:=""
  _rabat:=prevoz:=prevoz2:=_banktr:=_spedtr:=_zavtr:=_nc:=_marza:=_marza2:=_mpc:=0

   _fcj:=_fcj2:=_nc:=kalk_pripr->nc
   _rbr:=str(++nRbr,3)
   _kolicina:=kalk_pripr->kolicina
   _idkonto:=cProdavn
   _idkonto2:=kalk_pripr->idkonto2
   _brdok:=cBrUlaz
   _idvd:="11"
   _MKonto:=_Idkonto2;_MU_I:="5"     // izlaz iz magacina
   _PKonto:=_Idkonto; _PU_I:="1"     // ulaz  u prodavnicu

   _TBankTr:=""    // izgenerisani dokument
   gather()

  select kalk_pripr
  skip
enddo

my_close_all_dbf()
return



// Generisanje stavki u 42-ki na osnovu storna 41-ica
function Gen41S()

O_KALK_PRIPR
select kalk_pripr
if idvd<>"42"
  MsgBeep("U kalk_pripremi mora da se nalazi dokument 42 !!!")
  close kalk_pripr
  return .f.
endif

if pitanje(,"Generisati storno 41-ca ?"," ")=="N"
  close kalk_pripr
  return .f.
endif

O_TARIFA
O_ROBA
O_KALK

select kalk_pripr
go bottom

cIdFirma:=kalk_pripr->idFirma
cPKonto:=kalk_pripr->pkonto

select kalk; set order to tag "PTARIFA"
//("PTarifa","idFirma+PKonto+IDTarifa+idroba",KUMPATH+"KALK")
seek cidfirma+cPKonto


DO WHILE !EOF() .AND. cIdFirma==IdFirma .and. Pkonto==cPKonto
   cIdTarifa:=IdTarifa
   select roba; hseek kalk->idroba
   select tarifa; hseek cIdTarifa; select kalk
   VtPorezi()
   nOPP:=TARIFA->OPP; nPPP:=TARIFA->PPP
   nZPP:=tarifa->zpp
   nMPV:=nMPVSaPP:=0
   nPopust:=0

   lUPripr:=.t.
   select kalk_pripr; locate for idtarifa==cidtarifa
   if !found(); go top; lUPripr:=.f.; endif
   dGledamDo:=datdok
   select kalk

   // ---------------------------------
   // koliko je avansa na raspolaganju?
   // ---------------------------------
   DO WHILE !EOF() .AND. cIdFirma==IdFirma  .and. PKonto==cPKonto .and.;
            cIdtarifa==IdTarifa
      IF DATDOK>dGledamDo .or. !lUPripr; SKIP 1; LOOP; ENDIF
      SELECT ROBA; HSEEK KALK->IDROBA  // pozicioniraj sifrarnik robe
      SELECT KALK
      IF IDVD = "41" .OR. (IDVD=="42" .AND. KOLICINA*MPC<0)
        // ----------------------------------
        // gledaj samo 41-ce i 42-ke u stornu
        // ----------------------------------
        IF IDVD=="42" .and. kolicina>0
          nMPV     += (-MPC*Kolicina)
          nMPVSaPP += (-MPCSaPP*Kolicina)
        ELSE
          nMPV     += MPC*Kolicina
          nMPVSaPP += MPCSaPP*Kolicina
        ENDIF
      ENDIF
      SKIP 1
   ENDDO // tarifa

   SELECT kalk_pripr

   nMPVSappReal := 0
   nMPVReal     := 0

   if round(nMPVSaPP,4)<>0
     if !lUPripr
       MsgBeep("U kalk_pripremi se ne nalazi unesena stavka za tarifu :"+cIdtarifa+" ?")
       my_close_all_dbf()
       return .f.
     else
       nMPVSappREal := kalk_pripr->mpcsapp * kolicina
       nMPVReal     := kalk_pripr->mpc * kolicina
       cRIdRoba     := kalk_pripr->idroba
       SKIP 1
       DO WHILE !EOF()
         IF idtarifa==cidtarifa
           IF kolicina>0
             nMPVSappREal += kalk_pripr->mpcsapp * kolicina
             nMPVReal     += kalk_pripr->mpc * kolicina
           ELSE
             MsgBeep("Vec postoji storno 41-ca, stavka br."+rbr+" u kalk_pripremi!")
           ENDIF
         ENDIF
         SKIP 1
       ENDDO
     endif
   endif

   if nMPVSAppReal<0  // ako se radi o une�enom stornu obra�unate realizacije
     nMPVSapp:=0      // onda ne mo�e biti storna avansa
     nMPV:=0
   elseif nMPVSAPP>nMPVSAppREal   // akontacije su vece od realizovanog poreza
     nMPVSapp:=nMPVSappReal // poreska uplata ne moze biti negativna
     nMPV:=nMPVReal         // tj realizovano - akontacija >=0
   endif

   if round(nMPVSaPP,4)<>0
     select kalk_pripr ; go bottom
     Scatter()
     append blank
     gather()
     RREPLACE rbr with str(val(rbr)+1,3), kolicina with -1, MPCSAPP with nMPVSapp,;
             mpc with nMPV, nc with nMPV, marza2 with 0, TMarza with "A",;
             idtarifa with cIdTarifa,  idroba with cRIdRoba

   endif
   select kalk

ENDDO // konto

my_close_all_dbf()
return .t.


// Generisanje dokumenta tipa 41 ili 42 na osnovu 11-ke
function Iz11u412()

  o_kalk_edit()
  cIdFirma := gFirma
  cIdVdU   := "11"
  cIdVdI   := "4"
  cBrDokU  := SPACE(LEN(kalk_pripr->brdok))
  cBrDokI  := ""
  dDatDok    := CTOD("")

  cBrFaktP   := SPACE(LEN(kalk_pripr->brfaktp))
  cIdPartner := SPACE(LEN(kalk_pripr->idpartner))
  dDatFaktP  := CTOD("")

  cPoMetodiNC:="N"

  Box(,6,75)
    @ m_x+0, m_y+5 SAY "FORMIRANJE DOKUMENTA 41/42 NA OSNOVU DOKUMENTA 11"
    @ m_x+2, m_y+2 SAY "Dokument: "+cIdFirma+"-"+cIdVdU+"-"
    @ row(),col() GET cBrDokU VALID postoji_kalk_dok(cIdFirma+cIdVdU+cBrDokU)
    @ m_x+3, m_y+2 SAY "Formirati dokument (41 ili 42)  4"
    cPom:="2"
    @ row(),col() GET cPom VALID cPom $ "12" PICT "9"
    @ m_x+4, m_y+2 SAY "Datum dokumenta koji se formira" GET dDatDok VALID !EMPTY(dDatDok)
    @ m_x+5, m_y+2 SAY "Utvrditi NC po metodi iz parametara ? (D/N)" GET cPoMetodiNC VALID cPoMetodiNC $ "DN" PICT "@!"
    READ; ESC_BCR
    cIdVdI += cPom
  BoxC()

  IF cIdVdI=="41"
    Box(,5,75)
      @ m_x+0, m_y+5 SAY "FORMIRANJE DOKUMENTA 41 NA OSNOVU DOKUMENTA 11"
      @ m_x+2, m_y+2 SAY "Broj maloprodajne fakture" GET cBrFaktP
      @ m_x+3, m_y+2 SAY "Datum fakture            " GET dDatFaktP
      @ m_x+4, m_y+2 SAY "Sifra kupca              " GET cIdPartner VALID EMPTY(cIdPartner) .or. P_Firma(@cIdPartner)
      READ
    BoxC()
  ENDIF

  // utvrdimo broj nove kalkulacije
  SELECT KALK_DOKS; SEEK cIdFirma+cIdVdI+CHR(255); SKIP -1
  IF cIdFirma+cIdVdI == IDFIRMA+IDVD
     cBrDokI := brdok
  ELSE
     cBrDokI := space(8)
  ENDIF
  cBrDokI := UBrojDok(val(left(cBrDokI,5))+1,5,right(cBrDokI,3))

  // pocnimo sa generacijom dokumenta
  SELECT KALK
  SEEK cIdFirma+cIdVDU+cBrDokU
  DO WHILE !EOF() .and. cIdFirma+cIdVDU+cBrDokU == IDFIRMA+IDVD+BRDOK
    PushWA()
    SELECT kalk_pripr; APPEND BLANK; Scatter()
      _idfirma   := cIdFirma
      _idroba    := KALK->idroba
      _idkonto   := KALK->idkonto
      _idvd      := cIdVDI
      _brdok     := cBrDokI
      _datdok    := dDatDok
      _brfaktp   := cBrFaktP
      _datfaktp  := IF(!EMPTY(dDatFaktP),dDatFaktP,dDatDok)
      _idpartner := cIdPartner
      _rbr       := KALK->rbr
      _kolicina  := KALK->kolicina
      _fcj       := KALK->nc
      _tprevoz   := "A"
      _tmarza2   := "A"
//      _marza2    := KALK->(marza+marza2)
      _mpc       := KALK->mpc
      _idtarifa  := KALK->idtarifa
      _mpcsapp   := KALK->mpcsapp
      _pkonto    := KALK->pkonto
      _pu_i      := "5"
      _error     := "0"

if !empty(gMetodaNC) .and. cPoMetodiNC=="D"
 nc1:=nc2:=0
// MsgO("Racunam stanje u prodavnici")

  //                                 ? ?           ?
  KalkNabP(_idfirma,_idroba,_idkonto,0,0,@nc1,@nc2,)

// MsgC()
// if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);endif
 if gMetodaNC $ "13"; _fcj:=nc1; elseif gMetodaNC=="2"; _fcj:=nc2; endif
endif

    _nc     := _fcj
    _marza2 := _mpc - _nc

    SELECT kalk_pripr
    my_rlock()
    Gather()
    my_unlock()
    SELECT KALK 
    PopWA()
    SKIP 1
  ENDDO

my_close_all_dbf()
return


// Generisanje dokumenta tipa 11 na osnovu 10-ke
function Iz10u11()

  o_kalk_edit()
  cIdFirma := gFirma
  cIdVdU   := "10"
  cIdVdI   := "11"
  cBrDokU  := SPACE(LEN(kalk_pripr->brdok))
  cIdKonto := SPACE(LEN(kalk_pripr->idkonto))
  cBrDokI  := ""
  dDatDok    := CTOD("")

  cBrFaktP   := ""
  cIdPartner := ""
  dDatFaktP  := CTOD("")

  cPoMetodiNC:="N"

  Box(,6,75)
    @ m_x+0, m_y+5 SAY "FORMIRANJE DOKUMENTA 11 NA OSNOVU DOKUMENTA 10"
    @ m_x+2, m_y+2 SAY "Dokument: "+cIdFirma+"-"+cIdVdU+"-"
    @ row(),col() GET cBrDokU VALID postoji_kalk_dok(cIdFirma+cIdVdU+cBrDokU)
    @ m_x+3, m_y+2 SAY "Prodavn.konto zaduzuje   " GET cIdKonto VALID P_Konto(@cIdKonto)
    @ m_x+4, m_y+2 SAY "Datum dokumenta koji se formira" GET dDatDok VALID !EMPTY(dDatDok)
    @ m_x+5, m_y+2 SAY "Utvrditi NC po metodi iz parametara ? (D/N)" GET cPoMetodiNC VALID cPoMetodiNC $ "DN" PICT "@!"
    READ; ESC_BCR
  BoxC()


  // utvrdimo broj nove kalkulacije
  SELECT KALK_DOKS; SEEK cIdFirma+cIdVdI+CHR(255); SKIP -1
  IF cIdFirma+cIdVdI == IDFIRMA+IDVD
     cBrDokI := brdok
  ELSE
     cBrDokI := space(8)
  ENDIF
  cBrDokI := UBrojDok(val(left(cBrDokI,5))+1,5,right(cBrDokI,3))

  // pocnimo sa generacijom dokumenta
  SELECT KALK
  SEEK cIdFirma+cIdVDU+cBrDokU
  DO WHILE !EOF() .and. cIdFirma+cIdVDU+cBrDokU == IDFIRMA+IDVD+BRDOK
    PushWA()
    SELECT kalk_pripr
    APPEND BLANK
    Scatter()
      _idfirma   := cIdFirma
      _idroba    := KALK->idroba
      _idkonto   := cIdKonto
      _idkonto2  := KALK->idkonto
      _idvd      := cIdVDI
      _brdok     := cBrDokI
      _datdok    := dDatDok
      _brfaktp   := cBrFaktP
      _datfaktp  := IF(!EMPTY(dDatFaktP),dDatFaktP,dDatDok)
      _idpartner := cIdPartner
      _rbr       := KALK->rbr
      _kolicina  := KALK->kolicina
      _fcj       := KALK->nc
      _tprevoz   := "R"
      _tmarza    := "A"
      _tmarza2   := "A"
      _vpc       := KALK->vpc
      // _marza2 := _mpc - _vpc
      // _mpc       := KALK->mpc
      _idtarifa  := KALK->idtarifa
      _mpcsapp   := KALK->mpcsapp
      _pkonto    := _idkonto
      _mkonto    := _idkonto2
      _mu_i      := "5"
      _pu_i      := "1"
      _error     := "0"

if !empty(gMetodaNC) .and. cPoMetodiNC=="D"
 nc1:=nc2:=0
// MsgO("Racunam stanje u prodavnici")

  //                                 ? ?           ?
  KalkNabP(_idfirma,_idroba,_idkonto,0,0,@nc1,@nc2,)

// MsgC()
// if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);endif
 if gMetodaNC $ "13"; _fcj:=nc1; elseif gMetodaNC=="2"; _fcj:=nc2; endif
endif

    _nc     := _fcj
    _marza  := _vpc - _nc

    SELECT kalk_pripr
    my_rlock()
    Gather()
    my_unlock()
    SELECT KALK
    PopWA()
    SKIP 1
  ENDDO

my_close_all_dbf()
return



// generisi 80-ku na osnovu IP-a
function gen_ip_80()
local cIdFirma := gFirma
local cTipDok := "IP"
local cIpBrDok := SPACE(8)
local dDat80 := DATE()
local nCnt:=0
local cNxt80:=SPACE(8)

Box(,5,65)
    @ 1+m_x, 2+m_y SAY "Postojeci dokument IP -> " + cIdFirma + "-" + cTipDok + "-" GET cIpBrDok VALID !Empty(cIpBrDok)
    @ 2+m_x, 2+m_y SAY "Datum dokumenta" GET dDat80 VALID !Empty(dDat80)
    read
BoxC()

if LastKey()==K_ESC
    return
endif

if Pitanje(,"Generisati 80-ku (D/N)?","D") == "N"
    return
endif

// kopiraj dokument u pript
if cp_dok_pript( cIdFirma, cTipDok, cIpBrDok ) == 0
    return
endif

O_KALK_DOKS
O_KALK
O_PRIPT
O_KALK_PRIPR

cNxt80 := GetNextKalkDoc( gFirma, "80" )

// obradi dokument u kalk_pripremu -> konvertuj u 80
select pript
set order to tag "2"
go top

Box(,1,30)

do while !EOF()

    Scatter()

    select kalk_pripr
    append blank
    
    _gkolicina := 0
    _gkolicin2 := 0
    _idvd := "80"
    _error := "0"
    _tmarza2 := "A"
    _datdok := dDat80
    _datfaktp := dDat80
    _brdok := cNxt80
    
    Gather()
    
    ++ nCnt
    @ 1+m_x, 2+m_y SAY ALLTRIM(STR(nCnt))
    
    select pript
    skip
enddo

BoxC()

return



