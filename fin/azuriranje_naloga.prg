/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"

static lIzgenerisi := .f.
static cNal

/*! \fn Azur(lAuto)
 *  \brief Azuriranje knjizenja
 *  \param lAuto - .t. azuriraj automatski, .f. azuriraj sa pitanjem
 */
function fin_azur(lAuto)
// PostgreSQL server object
local oServer

if Logirati(goModul:oDataBase:cName,"DOK","AZUR")
	lLogAzur:=.t.
else
	lLogAzur:=.f.
endif

if (lAuto==NIL)
	lAuto:=.f.
endif

if !lAuto .and. Pitanje("pAz", "Sigurno zelite izvrsiti azuriranje (D/N)?", "N") == "N"
	return
endif

o_fin_za_azuriranje()
if !fin_azur_check(lAuto)
   return .f.
endif

oServer := pg_server()

if oServer == NIL
  CLEAR SCREEN 
  ? "fin_azur oServer nil ?!"
  QUIT
endif

if fin_azur_sql(oServer)

   o_fin_za_azuriranje()
   if !fin_azur_dbf(lAuto)
       MsgBeep("Neuspjesno FIN/DBF azuriranje !?")
       return .f.
   endif
else
  MsgBeep("Neuspjesno FIN/SQL azuriranje !?")
endif

return .t.

// -----------------------------
// -----------------------------
function o_fin_za_azuriranje()
// otvori tabele
close all
O_KONTO
O_PARTN
O_FIN_PRIPR
O_SUBAN
O_ANAL
O_SINT
O_NALOG

O_PSUBAN
O_PANAL
O_PSINT
O_PNALOG
return



// ----------------------
// ----------------------
function fin_azur_sql(oServer)
local lOk

MsgO("sql suban")

SELECT PSUBAN
GO TOP
lOk := .t.
sql_fin_suban_update("BEGIN")
do while !eof()
   //sql_fin_suban_update(oServer, cIdFirma, cIdVn, cBrNal, nRbr, dDatVal, dDatDok, cOpis, cIdPartn, cKonto, cDP, nIznos)
    if !sql_fin_suban_update(field->IdFirma, field->IdVn, field->BrNal, VAL(field->Rbr), ;
           field->DatDok, field->DatVal, field->opis, ;
           field->IdPartner, field->IdKonto, field->D_P, field->IZNOSBHD)
       lOk := .f.
       exit
    endif
   SKIP
enddo

if lOk
  update_semaphore_version("fin_suban")
  sql_fin_suban_update("END")
else
  sql_fin_suban_update("ROLLBACK")
endif

MsgC()
return lOk

// ---------------------------
// provjeri prije azuriranja
// ----------------------------
function fin_azur_check(lAuto)
local lAzur
local nSaldo
local cNal

// provjeri da li se u pripremi nalazi vise dokumenata... razlicitih
if _is_vise_dok() == .t.
	// provjeri za duple stavke prilikom azuriranja...
	if prov_duple_stavke() == 1 
		return .f.
	endif
	// nafiluj sve potrebne tabele
	stnal( .t. )
endif

lAzur:=.t.
select PSUBAN
if reccount2()==0
  lAzur:=.f.
endif

select PANAL
if reccount2()==0
  lAzur:=.f.
endif

select PSINT
if reccount2()==0
  lAzur:=.f.
endif

if !lAzur
  MsgBeep("Niste izvrsili stampanje naloga ...")
  close all
  return .f.
endif

SELECT PSUBAN
GO TOP
do while !eof()

    // prodji kroz PSUBAN i vidi da li je nalog zatvoren
    // samo u tom slucaju proknjizi nalog u odgovarajuce datoteke
    cNal := IDFirma+IdVn+BrNal
    nSaldo:=0
    do while !eof() .and. cNal == IdFirma + IdVn + BrNal

        if !psuban_partner_check()
            close all
            return .f.
        endif

        if !psuban_konto_check()
            close all
            return .f.
        endif

        select psuban
        if D_P=="1"
            nSaldo+=IznosBHD
        else
            nSaldo-=IznosBHD
        endif
        skip

    enddo

    if round(nSaldo,4)<>0 .and. gRavnot=="D"
        Beep(1)
        Msg("Neophodna ravnoteza naloga " + cNal + "##, azuriranje nece biti izvrseno!")
        return .f.
    endif


    if nalog_postoji_u_suban(cNal)
            log_write("nalog postoji u suban " + cNal)
            return .f.
    endif
   
    SELECT PSUBAN

enddo


select PSUBAN
set order to TAG "1"
go top

lIzgenerisi:=.f.
if reccount2() > 9999 .and. !lAuto
  if Pitanje(,"Staviti na stanje bez provjere ?","N")=="D"
    lIzgenerisi:=.t.
  endif
endif


return lAzur

// ------------------------
// azuriraj dbf-ove
// -----------------------
function fin_azur_dbf(lAuto)
local nC
local nTArea := SELECT()
local nSaldo

Box("ad", 10, MAXCOLS()-10)

if lLogAzur
	cOpis := fin_pripr->idfirma + "-" + ;
		fin_pripr->idvn + "-" + ;
		fin_pripr->brnal

	EventLog(nUser, goModul:oDataBase:cName, "DOK", "AZUR", nil, nil, nil, nil, cOpis, "", "", fin_pripr->datdok, Date(), ;
		      "", "Azuriranje dokumenta - poceo !")
endif

select PSUBAN
set order to tag "1"
go top


SELECT PSUBAN
GO TOP
do while !eof()

    // prodji kroz PSUBAN i vidi da li je nalog zatvoren
    // samo u tom slucaju proknjizi nalog u odgovarajuce datoteke
    cNal := IDFirma+IdVn+BrNal
    // ----------------------------------------------------
    // ----------------------------------------------------
    if preskoci_ako_nalog_ima_tacku_u_nazivu(cNal)
           LOOP
    endif

    @ m_x+1,m_y+2 SAY "Azuriram nalog: " + IdFirma + "-" + idvn + "-" + ALLTRIM(brnal)

    nSaldo:=0
    cEvIdFirma:=idfirma
    cEvVrBrNal:=idvn+"-"+brnal
    dDatNaloga:=datdok
    dDatValute:=datval
    do while !eof() .and. cNal == IdFirma + IdVn + BrNal
        select psuban
        if D_P=="1"
          nSaldo+=IznosBHD
        else
           nSaldo-=IznosBHD
        endif
        skip
    enddo

    if (gDebug > 5)
     log_write("azuriram: " + cNal + " saldo " + STR(nSaldo, 17, 2))
    endif

    // nalog je uravnotezen, azuriraj ga !

    pnalog_nalog(cNal)
    panal_anal(cNal)
    psint_sint(cNal)
    psuban_suban(cNal)

    if lLogAzur
            fin_azur_event_log(nUser, nSaldo, dDatNalog, dDatValute, cEvidFirma, cEvVrBrNal) 
    endif

    fin_pripr_delete(cNal)
    select PSUBAN

enddo

BoxC()

select fin_pripr
__dbpack()

select PSUBAN
zap
select PANAL
zap
select PSINT
zap
select PNALOG
zap
close all

return .t.


// ----------------------------------------
// ----------------------------------------
function preskoci_ako_nalog_ima_tacku_u_nazivu(cNal)

IF "." $ cNal
        MsgBeep("Nalog " + IdFirma + "-" + idvn + "-" + (brnal) + " sadrzi znak '.' i zato nece biti azuriran!")
        DO WHILE !EOF() .and. cNal==IDFirma+IdVn+BrNal
            SKIP 1
        ENDDO
        return .t.
ENDIF

return .f.

// --------------------------------
// --------------------------------
function nalog_postoji_u_suban(cNal)

    @ m_x + 3,  m_y + 2 SAY "NALOZI         "
    select  SUBAN
    SET ORDER TO TAG "4"  //"4","idFirma+IdVN+BrNal+Rbr"
    seek cNal
    if found()
        MsgBeep("Vec postoji u suban ? "+ IdFirma + "-" + IdVn + "-" + ALLTRIM(BrNal) + "  !")
        close all
        return .t.
    endif

return .f.

// -----------------------------
// -----------------------------
function psuban_partner_check()

if !empty(psuban->idpartner)
      
    select partn
    hseek psuban->idpartner

    if !found() .and. !lIzgenerisi
      
        MsgBeep("Stavka br." + psuban->rbr + ": Nepostojeca sifra partnera!")

        IF PSUBAN->idvn=="00" .and. Pitanje( ,"Preuzeti nepostojecu sifru iz sezone?","N") == 'D'
          PreuzSezSPK("P")
        ELSE
          select PSUBAN
	      zapp()
          select PANAL
	      zapp()
          select PSINT
	      zapp()
          close all
          return .f.
        ENDIF

     endif
endif

SELECT PSUBAN 
return .t.


function fin_azur_event_log(nUser, nSaldo, dDatNalog, dDatValute, cEvidFirma, cEvVrBrNal) 
local cOpis

cOpis := cEvIdFirma + "-" + cEvVrBrNal
EventLog(nUser, goModul:oDataBase:cName, "DOK", "AZUR", ;
            nSaldo, nil, nil, nil, ;
            cOpis, "", "", dDatNaloga, dDatValute, ;
            "", "Azuriranje dokumenta - zavrsio !!!")

return



// -----------------------------
// -----------------------------
function psuban_konto_check()

if !empty(psuban->idkonto)
    
    select konto
    hseek psuban->idkonto
    
    if !found() .and. !lIzgenerisi
        
        MsgBeep("Stavka br."+psuban->rbr+": Nepostojeca sifra konta!")
        IF PSUBAN->idvn=="00" .and. Pitanje(,"Preuzeti nepostojecu sifru iz sezone?","N")=='D'
          PreuzSezSPK("K")
        ELSE
          select PSUBAN
          select PANAL
          select PSINT
          close all
          return .f.
        ENDIF
    endif
endif

SELECT PSUBAN
return .t. 

// -------------------
// -------------------
function panal_anal(cNal)

@ m_x+3,m_y+2 SAY "ANALITIKA       "
select PANAL
seek cNal
do while !eof() .and. cNal==IdFirma+IdVn+BrNal
    Scatter()
    select ANAL
    append ncnl
    Gather2()
    select PANAL
    skip
enddo

return

// -------------------
// -------------------
function psint_sint(cNal)
  @ m_x+3,m_y+2 SAY "SINTETIKA       "
  select PSINT
  seek cNal

do while !eof() .and. cNal==IdFirma+IdVn+BrNal
    Scatter()
    select SINT
    append ncnl
    Gather2()
    select PSINT
    skip
enddo

return


//-----------------------
//-----------------------
function pnalog_nalog(cNal)

select PNALOG
seek cNal
if found()
    Scatter()
    //_Sifra:=sifrakorisn
    select NALOG
    append ncnl
    Gather2()
else
    Beep(4)
    Msg("Greska... ponovi stampu naloga ...")
endif

return

//-----------------------
//-----------------------
function psuban_suban(cNal)
local nSaldo :=0
local nC := 0

@ m_x+3,m_y+2 SAY "SUBANALITIKA   "
select SUBAN
set order to tag "3"
select PSUBAN
seek cNal
  
nC:=0
do while !eof() .and. cNal==IdFirma+IdVn+BrNal

    @ m_x+3,m_y+25 SAY ++nC  pict "99999999999"

    Scatter()
    if _d_p=="1" 
          nSaldo:=_IznosBHD
    else
          nSaldo:= -_IznosBHD
    endif
    SELECT SUBAN
    SEEK _IdFirma+_IdKonto+_IdPartner+_BrDok    // isti dokument

    nRec:=recno()
    do while  !eof() .and. (_IdFirma+_IdKonto+_IdPartner+_BrDok)== (IdFirma+IdKonto+IdPartner+BrDok)
       if d_P=="1"
           nSaldo+= IznosBHD
       else
           nSaldo -= IznosBHD
       endif
       skip
    enddo

    if ABS(round(nSaldo,3)) <= gnLOSt
        GO nRec
        do while  !eof() .and. (_IdFirma+_IdKonto+_IdPartner+_BrDok)== (IdFirma+IdKonto+IdPartner+BrDok)
            field->OtvSt:="9"
            skip
        enddo
        _OtvSt:="9"
    endif

    append ncnl
    Gather2()

    select PSUBAN
    skip

enddo

return


/*! \fn SifkPartnBank()
 *  \brief Dodaje u tabelu SifK stavke PARTN i BANK
 */
function SifkPartnBank()

O_SIFK
set order to tag "ID2"
seek padr("PARTN",8)+"BANK"
if !found()
 if Pitanje(,"U sifk dodati PARTN/BANK  ?","D")=="D"
    append blank
    replace id with "PARTN" , oznaka with "BANK", naz with "Banke",;
            Veza with "N", Duzina with 16 , Tip with "C"
 endif
endif
use
return NIL

/*! \fn OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
 */
function OKumul(nArea, cStaza, cIme, nIndexa, cDefault)

select (nArea)
 
my_use (cIme)
return NIL

// ------------------------------
// ------------------------------
function fin_pripr_delete(cNal)

// nalog je uravnotezen, moze se izbrisati iz PRIPR
select fin_pripr
seek cNal
@ m_x+3,m_y+2 SAY "BRISEM PRIPREMU "
do while !eof() .and. cNal==IdFirma+IdVn+BrNal
    skip
    ntRec:=RECNO()
    skip -1
    dbdelete2()
    go ntRec
enddo

return .t.

// -----------------------------------------------------------------
// provjerava da li u pripremi postoji vise razlicitih dokumenata
// -----------------------------------------------------------------
static function _is_vise_dok()
local lRet := .f.
local nTRec := RECNO()
local cBrNal 
local cTmpNal := "XXXXXXXX"

select fin_pripr
go top

cTmpNal := field->brnal

do while !EOF() 
	cBrNal := field->brnal
	if  cBrNal == cTmpNal 
		cTmpNal := cBrNal
		skip
		loop
	else
		lRet := .t.
		exit
	endif
enddo

return lRet


// ------------------------------------------------------------
// provjeri duple stavke u pripremi za vise dokumenata
// ------------------------------------------------------------
static function prov_duple_stavke() 
local cSeekNal
local lNalExist:=.f.

select fin_pripr
go top

// provjeri duple dokumente
do while !EOF()
	cSeekNal := fin_pripr->(idfirma + idvn + brnal)
	if dupli_nalog(cSeekNal)
		lNalExist := .t.
		exit
	endif
	
	select fin_pripr
	skip
enddo

// postoje dokumenti dupli
if lNalExist
	MsgBeep("U pripremi su se pojavili dupli nalozi !!!")
	if Pitanje(,"Pobrisati duple naloge (D/N)?", "D")=="N"
		MsgBeep("Dupli nalozi ostavljeni u tabeli pripreme!#Prekidam operaciju azuriranja!")
		return 1
	else
		Box(,1,60)
			cKumPripr := "P"
			@ m_x+1, m_y+2 SAY "Zelite brisati stavke iz kumulativa ili pripreme (K/P)" GET cKumPripr VALID !Empty(cKumPripr) .or. cKumPripr $ "KP" PICT "@!"
			read
		BoxC()
		
		if cKumPripr == "P"
			// brisi pripremu
			return prip_brisi_duple()
		else
			// brisi kumulativ
			return kum_brisi_duple()
		endif
	endif
endif

return 0

// ------------------------------------------------------------
// brisi stavke iz pripreme koje se vec nalaze u kumulativu
// ------------------------------------------------------------
static function prip_brisi_duple()
local cSeek
select fin_pripr
go top

do while !EOF()

	cSeek := fin_pripr->(idfirma + idvn + brnal)
	
	if dupli_nalog( cSeek )
		// pobrisi stavku
		select fin_pripr
		delete
	endif
	
	select fin_pripr
	skip
enddo

return 0

// -------------------------------------------------------------
// brisi stavke iz kumulativa koje se vec nalaze u pripremi
// -------------------------------------------------------------
static function kum_brisi_duple()
local cSeek
select fin_pripr
go top

cKontrola := "XXX"

do while !EOF()
	
	cSeek := fin_pripr->(idfirma + idvn + brnal)
	
	if cSeek == cKontrola
		skip
		loop
	endif
	
	if dupli_nalog( cSeek )
		
		MsgO("Brisem stavke iz kumulativa ... sacekajte trenutak!")
		
		// brisi nalog
		select nalog
		
		if !flock()
			msg("Datoteka je zauzeta ",3)
			closeret
		endif
	
		set order to tag "1"
		go top
		seek cSeek
		
		if Found()
			
			do while !eof() .and. nalog->(idfirma+idvn+brnal) == cSeek
      				skip 1
				nRec:=RecNo()
				skip -1
      				DbDelete2()
      				go nRec
    			enddo
    		endif
		
            // brisi iz suban
            select suban
            if !flock()
                msg("Datoteka je zauzeta ",3)
                closeret
            endif
            
            set order to tag "4"
            go top
            seek cSeek
            if Found()
                do while !EOF() .and. suban->(idfirma + idvn + brnal) == cSeek
                    
                    skip 1
                    nRec:=RecNo()
                    skip -1
                    DbDelete2()
                    go nRec
                enddo
            endif
        
            // brisi iz sint
            select sint
            if !flock()
                msg("Datoteka je zauzeta ",3)
                closeret
            endif
        
            set order to tag "2"
            go top
            seek cSeek
            if Found()
                do while !EOF() .and. sint->(idfirma + idvn + brnal) == cSeek
                    
                    skip 1
                    nRec:=RecNo()
                    skip -1
                    DbDelete2()
                    go nRec
                enddo
            endif
            
            // brisi iz anal
            select anal
            if !flock()
                msg("Datoteka je zauzeta ",3)
                closeret
            endif
            
            set order to tag "2"
            go top
            seek cSeek
            if Found()
                do while !EOF() .and. anal->(idfirma + idvn + brnal) == cSeek
                    skip 1
                    nRec:=RecNo()
                    skip -1
                    DbDelete2()
                    go nRec
                enddo
            endif
        
	
		    MsgC()
	   endif
	
	   cKontrola := cSeek
	
	   select fin_pripr
	   skip

enddo

return 0

// ------------------------------------------
// provjerava da li je dokument dupli
// ------------------------------------------
static function dupli_nalog(cSeek)
select nalog
set order to tag "1"
go top
seek cSeek
if Found()
	return .t.
endif
return .f.


// --------------------------------
// validacija broja naloga
// --------------------------------
static function __val_nalog( cNalog )
local lRet := .t.
local cTmp
local cChar
local i

cTmp := RIGHT( cNalog, 4 )

// vidi jesu li sve brojevi
for i := 1 to LEN( cTmp )
	
	cChar := SUBSTR( cTmp, i, 1 )
	
	if cChar $ "0123456789"
		loop
	else
		lRet := .f.
		exit
	endif

next

return lRet



// ---------------------------------------------
// centralna funkcija za odredjivanje
// novog broja naloga !!!!
// cIdFirma - firma
// cIdVn - tip naloga
// ---------------------------------------------
function NextNal( cIdFirma, cIdVN )
local nArr
nArr:=SELECT()

if gBrojac=="1"
	select NALOG
	set order to tag "1"
	seek cIdFirma+cIdVN+chr(254)
	skip -1
	altd()
	if ( idfirma + idvn == cIdFirma + cIdVN )
		
		// napravi validaciju polja ...
		do while !BOF()

			if !__val_nalog( field->brnal )
				skip -1
				loop
			else
				exit
			endif
		enddo
		
		cBrNal := NovaSifra(brNal)
	else
		cBrNal := "00000001"
	endif
else
	select NALOG
	set order to tag "2"
	seek cIdFirma+chr(254)
	skip -1
	cBrNal:=padl(alltrim(str(val(brnal)+1)),8,"0")
endif

select (nArr)

return cBrNal


// ----------------------------------------------------------------
// specijalna funkcija regeneracije brojeva naloga u kum tabelama
// C(4) -> C(8) konverzija
// stari broj A001 -> 0000A001
// ----------------------------------------------------------------
function regen_tbl()

if !SigmaSIF("REGEN")
	MsgBeep("Ne diraj lava dok spava !")
	return
endif

// otvori sve potrebne tabele
O_SUBAN

if LEN( suban->brnal ) = 4
	msgbeep("potrebno odraditi modifikaciju FIN.CHS prvo !")
	return
endif

O_NALOG
O_ANAL
O_SINT


// pa idemo redom
select suban
_renum_convert()
select nalog
_renum_convert()
select anal
_renum_convert()
select sint
_renum_convert()

return


// --------------------------------------------------
// konvertuje polje BRNAL na zadatoj tabeli
// --------------------------------------------------
static function _renum_convert()
local xValue
local nCnt

set order to tag "0"
go top

Box(,2,50)

@ m_x + 1, m_y + 2 SAY "Konvertovanje u toku... "

nCnt := 0
do while !EOF()
	xValue := field->brnal
	if !EMPTY(xValue)
		replace field->brnal with PADL(ALLTRIM(xValue), 8, "0")
		++ nCnt
	endif
	@ m_x + 2, m_y + 2 SAY PADR( "odradjeno " + ALLTRIM(STR(nCnt)), 45 )
	skip
enddo

BoxC()

return
