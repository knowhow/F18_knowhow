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


#include "fin.ch"

static picdem := "9999999999.99"
static gDatObr
static gKumKam
static gPdvObr

// -----------------------------------------------
// glavni menij za obradu kamata
// -----------------------------------------------
function fin_kamate_menu()
local _izbor := 1
local _opc := {}
local _opcexe := {}

AADD( _opc, "1. obracun pojedinacnog dokumenta              " )
AADD( _opcexe, { || kamate_obracun_pojedinacni() } )
AADD( _opc, "2. unos/ispravka pripreme kamata   " )
AADD( _opcexe, { || kamate_unos() } )
AADD( _opc, "3. prenos FIN->kamate         " )
AADD( _opcexe, { || prenos_fin_kam() } )
AADD( _opc, "4. kontrola cjelovitosti kamatnih stopa   " )
AADD( _opcexe, { || kontrola_cjelovitosti_ks() } )
AADD( _opc, "5. lista kamatnih stopa  " )
AADD( _opcexe, { || p_ks() } )

gDatObr := DATE()

f18_menu( "kamat", .f., _izbor, _opc, _opcexe )

return


// ---------------------------------------------
// unos kamata
// ---------------------------------------------
function kamate_unos()
local _i
local _x := MAXROWS() - 15
local _y := MAXCOLS() - 5
private ImeKol := {}
private Kol := {}

O_Edit()

ImeKol:={ ;
          {"KONTO",         {|| IdKonto  }, "Idkonto"   }, ;
          {"Partner",       {|| IdPartner}, "IdPartner" }, ;
          {"Brdok",         {|| Brdok    }, "Brdok"     }, ;
          {"DatOd",         {|| DatOd    }, "DatOd"     }, ;
          {"DatDo",         {|| DatDo    }, "DatDo"     }, ;
          {"Osnovica",      {|| Osnovica }, "Osnovica"  }, ;
          {"M1",            {|| M1       }, "M1"        }  ;
        }

for _i := 1 to LEN( imekol )
	AADD( Kol, _i )
next

Box(, _x, _y )
	@ m_x + (_x-2), m_y + 2 SAY " <c-N>  Nove Stavke      ³ <ENT> Ispravi stavku   ³ <c-T> Brisi Stavku"
	@ m_x + (_x-1), m_y + 2 SAY " <c-A>  Ispravka Dokum.  ³ <c-P> Stampa svi KL    ³ <c-U> Lista uk.dug"
	@ m_x + _x, m_y + 2 SAY " <c-F9> Brisi pripremu   ³ <a-P> Stampa pojedinac.³                   "
	ObjDbedit( "PNal", _x , _y ,{|| _key_handler() },"","KAMATE Priprema.....ÍÍÍÍÍ", , , , ,3)
BoxC()

my_close_all_dbf()
return


// otvaranje potrebnih tabela
static function O_Edit()
O_KS
O_PARTN
O_KONTO
O_KAM_PRIPR
O_KAM_KAMAT
select kam_pripr
set order to tag "1"
go top
return



// korekcija unos/ispravka
static function ispravka_unosa( l_novi )

if l_novi
	_idkonto := PADR( "2110", 7 )
endif

set cursor on

@ m_x+1, m_y+2  SAY "Partner  :" get _IdPartner pict "@!" valid P_Firma(@_idpartner)
@ m_x+3, m_y+2  SAY "Broj Veze:" get _BrDok
@ m_x+5, m_y+2  SAY "Datum od  " GET _datOd VALID PostojiLi( _idPartner, _brDok, _datOd, l_novi )
@ m_x+5, col()+2 SAY "do" GET _datDo
@ m_x+7, m_y+2  SAY "Osnovica  " get _Osnovica pict "999999999.99"

read

ESC_RETURN 0

return 1



// postoji li zapis vec
static function PostojiLi(idp, brd, dod, fNovi)
local _vrati := .t.
local _rec_no

PushWA()

select kam_pripr
_rec_no := RECNO()
go top

do while !EOF()
	if idpartner == idp .and. brdok==brd .and. DTOC(datod)==DTOC(dod) .and. ( RECNO() != _rec_no .or. fNovi )
      	_vrati := .f.
      	Msg("Greska! Vec ste unijeli ovaj podatak!",3)
      	exit
    endif
    skip 1
enddo

go (_rec_no)

PopWA()

return _vrati


// -----------------------------------------------
// obrada dogadjaja tastature
// -----------------------------------------------
static function _key_handler()
local nTr2

if (Ch == K_CTRL_T .or. Ch == K_ENTER) .and. reccount2() == 0
    return DE_CONT
endif

select kam_pripr

do case

    case Ch == K_CTRL_T
        RETURN browse_brisi_stavku()

    case Ch = K_CTRL_F9
        RETURN browse_brisi_pripremu()

    // ispravka stavke
    case Ch == K_ENTER
        
        Box( "ist", 20, 75, .f. )

        Scatter()
            
        if ispravka_unosa(.f.)==0
            BoxC()
            return DE_CONT
        else
            Gather()
            BoxC()
            return DE_REFRESH
        endif

    case Ch == K_CTRL_K

   	    fin_kamate_generisi_mj_uplate()
	    return DE_CONT

    case Ch == K_CTRL_A

        PushWA()

        select kam_pripr
        go top

        Box( "anal", 13, 75, .f., "Ispravka stavki dokumenta" )

            nDug := 0
            nPot := 0

            do while !EOF()
                skip
	            nTR2 := RECNO()
	            skip-1
                Scatter()
                @ m_x + 1, m_y + 1 CLEAR to m_x+12,m_y+74
                if ispravka_unosa(.f.)==0
                    exit
                endif
                select kam_pripr
                Gather()
                go nTR2
            enddo

            PopWA()

         BoxC()

         return DE_REFRESH

    // unos nove stavke
    case Ch == K_CTRL_N  
        
        nDug := 0
        nPot := 0
        nPrvi := 0
        
        go bottom
        
        Box("knjn",13,77,.f.,"Unos novih stavki")
        
        do while .t.
            Scatter()
            @ m_x+1,m_y+1 CLEAR to m_x+12,m_y+76
            if ispravka_unosa(.t.)==0
                exit
            endif
            select kam_pripr
            append blank
            Gather()
        enddo

        BoxC()
        return DE_REFRESH

    // printanje kamatnog lista
    case Ch == K_CTRL_P

        fin_kamate_print()
        return DE_REFRESH
     
    // lista
    case Ch == K_CTRL_U
        
        nArr := SELECT()
        nUD1 := 0
        nUD2 := 0
        nUD3 := 0

        if FILE( my_home() + "pom.dbf" )
        
            select (F_TMP_1)
            use
            my_use_temp( "POM", my_home() + "pom", .f., .t. )
        
            select pom
            go top
        
            START PRINT CRET
        
            ? "PREGLED UKUPNIH DUGOVANJA PO KUPCIMA"
            ? "------------------------------------"
            ?
            ? "      SIFRA I NAZIV KUPCA            DUG         KAMATA       UKUPNO   "
            ? "-------------------------------- ------------ ------------ ------------"
        
            DO WHILE !EOF()
                ? field->idpartner, PADR( Ocitaj( F_PARTN, field->idpartner, "naz" ), 25 ),;
                    STR( field->osndug, 12, 2 ), STR( field->kamate, 12, 2 ), STR( field->osndug + field->kamate,12,2)
                nUd1 += field->osndug
                nUd2 += field->kamate
                nUd3 += ( field->osndug + field->kamate )
                SKIP 1
            ENDDO

            ? "-------------------------------- ------------ ------------ ------------"
            ? "UKUPNO SVI KUPCI................",;
                STR(nUd1,12,2), STR(nUd2,12,2), STR(nUd3,12,2)
            
            END PRINT
            use
        endif
        
        O_KAM_PRIPR
        SELECT (nArr)
        return DE_REFRESH
	
    case Ch == K_ALT_P

        select kam_pripr

     	private nKamMala := 0
     	private nOsnDug := 0
     	private nSOsnSD := 0
     	private nKamate := 0
     	private cVarObrac := "Z"

     	cIdpartner:=EVAL( (TB:getColumn(2)):Block )

    	Box(,2,70)
       		@ m_x+1,m_y+2 SAY "Varijanta (Z-zatezna kamata,P-prosti kamatni racun)" GET cVarObrac valid cVarObrac$"ZP" pict "@!"
       		read
     	BoxC()

        START PRINT CRET
        
	    if ObracV(cIdPartner, .f., cVarObrac ) > nKamMala
      		ObracV(cIdPartner, nil, cVarObrac )
     	endif
     
     	END PRINT

        O_KAM_PRIPR
        select kam_pripr
     	go top

	    return DE_REFRESH

    case Ch == K_ALT_A
        return DE_REFRESH

endcase

return DE_CONT




static function rekalkulisi_osnovni_dug()
local _date := DATE()
local _t_rec, _id_partner
local _osn_dug, _br_dok, _racun
local _predhodni
local _l_prvi

Box(, 1, 50 )
    @ m_x + 1, m_y + 2 SAY "Ukucaj tacan datum:" GET _date
    read
BoxC()
            
gDatObr := _date

select kam_pripr
go top
      
do while !EOF()
                
    _id_partner := field->idpartner
                
    select kam_pripr
                
    _t_rec := recno()
    _osn_dug := 0
                
    do while !EOF() .and. _id_partner == field->idpartner
        
        _br_dok := field->brdok
        _racun := 0
        _predhodni := 0
        _l_prvi := .f.
                    
        do while !EOF() .and. _id_partner == field->idpartner .and. field->brdok == _br_dok
                        
            if _l_prvi
                _racun := field->osnovica
                _l_prvi := .f.
            else
                _racun := _racun - ( _predhodni - field->osnovica )
            endif
                        
            _racun := iznosnadan( _racun, _date, field->datod )
            _predhodni := field->osnovica
            skip
        enddo
                    
        _osn_dug += _racun
    enddo
                
    go _t_rec
                
    do while !EOF() .and. _id_partner == field->idpartner
        replace field->osndug with _osn_dug
        skip
    enddo

enddo
 
return



// ------------------------------------------------------
static function kreiraj_pomocnu_tabelu()
local aDbf := {}
        
AADD ( aDbf , {"IDPARTNER" , "C",  6, 0} )
AADD ( aDbf , {"OSNDUG"    , "N", 12, 2} )
AADD ( aDbf , {"KAMATE"    , "N", 12, 2} )
AADD ( aDbf , {"PDV"       , "N", 12, 2} )

FERASE( my_home() + "pom.dbf" )
FERASE( my_home() + "pom.cdx" )

DBCREATE( my_home() + "pom.dbf", aDbf )
use

select ( F_TMP_1 )
my_use_temp( "POM", my_home() + "pom.dbf", .f., .t. )
go top

return


// -------------------------------------------------------
static function fin_kamate_print()
local _mala_kamata := 15
local _var_obr := "Z"      
local _kum_kam := "D"
local _pdv_obr := "D"

if pitanje(, "Rekalkulisati osnovni dug ?", "N" ) == "D"
    rekalkulisi_osnovni_dug()
endif
            
// kreiraj pomocnu tabelu
kreiraj_pomocnu_tabelu()
    
Box(, 6, 70 )  
    
    @ m_x + 1, m_y + 2 SAY "Ne ispisuj kam.listove za iznos kamata ispod" GET _mala_kamata ;
        PICT "999999.99"

    @ m_x + 2, m_y + 2 SAY "Varijanta (Z-zatezna kamata,P-prosti kamatni racun)" GET _var_obr ;
        VALID _var_obr $ "ZP" PICT "@!"

    @ m_x + 4, m_y + 2 SAY "Prikazivati kolonu 'kumulativ kamate' (D/N) ?" GET _kum_kam ;
        VALID _kum_kam $ "DN" PICT "@!"
 
    @ m_x + 5, m_y + 2 SAY "Dodaj PDV na obracun kamate (D/N) ?" GET _pdv_obr ;
        VALID _pdv_obr $ "DN" PICT "@!"
    
    read

BoxC()

gKumKam := _kum_kam
gPdvObr := _pdv_obr
     
START PRINT CRET

?
 
O_KAM_PRIPR
select kam_pripr
go top
     
do while !EOF()

    _id_partner := field->idpartner
      
    private nOsnDug := 0
    private nKamate := 0
    private nSOsnSD := 0
    private nPdv := 0
    private nPdvTotal := 0
    private nKamTotal := 0
      
    if ObracV( _id_partner, .f., _var_obr ) > _mala_kamata 

        my_flock()

        select pom
        append blank
        
        replace field->idpartner with _id_partner
        replace field->osndug with nOsnDug 
        replace field->kamate with nKamate 
		replace field->pdv with nPdvTotal

        my_unlock()
        
        select kam_pripr
        
        ObracV( _id_partner, .t., _var_obr )

    endif

    select kam_pripr
    seek _id_partner + CHR(250)

enddo
     
END PRINT
     
O_KAM_PRIPR
select kam_pripr
go top
     
return



// -----------------------------------------------------------
// obracun kamate
// -----------------------------------------------------------
static function ObracV( cIdPartner, fprint, cVarObrac )
local nKumKamSD := 0   
local cTxtPdv
local cTxtUkupno

if fprint == NIL                            
	fprint := .t.
endif

nGlavn := 2892359.28
dDatOd := CTOD("01.02.92")
dDatDo := CTOD("30.09.96")

O_KS
select ks
set order to tag "2"

nStr := 0

if fprint
        
	nPdvTotal := nKamate * (17 / 100)
	
    cTxtPdv := "PDV (17%)"
	cTxtPdv += " "
	cTxtPdv += REPLICATE(".", 44)
	cTxtPdv += str(nPdvTotal, 12, 2)
	cTxtPdv += " KM"
		
	cTxtUkupno := "Ukupno sa PDV"
	cTxtUkupno += " "
	cTxtUkupno += REPLICATE(".", 40)
	cTxtUkupno += str(nKamate + nPdvTotal, 12, 2)
	cTxtUkupno += " KM"
	
	?
	P_10CPI
	?? padc("- Strana "+str(++nStr,4)+"-",80)
	?
	
    select partn
	hseek cIdPartner
	
    cPom:=trim(partn->adresa)
	
    if !empty(partn->telefon)
		cPom+=", TEL:"+partn->telefon
	endif
	
    cPom:=padr(cPom,42)
	dDatPom:=gDatObr

endif 

select kam_pripr
seek cIdPartner

if fPrint

	if prow()>40
   		FF
   		? 
		P_10CPI
   		?? padc("- Strana "+str(++nStr,4)+"-",80)
   		?
	endif

	P_10CPI
	B_ON
	? space(20), PADC( "K A M A T N I    L I S T", 30 )
	B_OFF

	IF gKumKam == "N"
  		P_12CPI
	ELSE
  		P_COND
	ENDIF

	?
	?
	?

	if cVarObrac == "Z"
		m:=" ---------- -------- -------- --- ------------- ------------- -------- ------- -------------"+IF(gKumKam=="D"," -------------","")
	else
		m:=" ---------- -------- -------- --- ------------- ------------- -------- -------------"+IF(gKumKam=="D"," -------------","")
	endif

	NStrana("1") 

endif 

nSKumKam := 0
select kam_pripr
cIdPartner := field->idpartner

if !fprint
	nOsnDug := field->osndug
endif

do while !EOF() .and. field->idpartner == cIdPartner

    fStampajBr := .t.
    fPrviBD := .t.
    nKumKamBD := 0
    nKumKamSD := 0
    cBrDok := field->brdok
    cM1 := field->m1
    nOsnovSD := kam_pripr->osnovica

    do while !EOF() .and. field->idpartner == cIdpartner .and. field->brdok == cBrdok

	    dDatOd := kam_pripr->datod
	    dDatdo := kam_pripr->datdo
	    nOsnovSD := kam_pripr->osnovica

	    if fprviBD
  		    nGlavnBD := kam_pripr->osnovica
  		    fPrviBD := .f.
	    else
  		    
            if cVarObrac == "Z"
	  		    nGlavnBD := kam_pripr->osnovica + nKumKamSD
  		    else
	  		    nGlavnBD := kam_pripr->osnovica
  		    endif
	    endif
	
	    nGlavn := nGlavnBD

 	    select ks
	    seek dtos(dDatOd)

	    if dDatOd < field->DatOd .or. EOF()
 		    skip -1
	    endif

	    do while .t.
		
            dDDatDo := min( field->DatDO, dDatDo )
		    nPeriod := dDDatDo - dDatOd + 1
		
            if ( cVarObrac == "P" )
			    if ( Prestupna( YEAR(dDatOd ) ) )
				    nExp := 366
			    else
				    nExp:=365
			    endif
		    else
			    if field->tip == "G"
	 			    if field->duz == 0
	   				    nExp := 365
	 			    else
	   				    nExp := field->duz
	 			    endif
			    elseif field->tip == "M"
	 			    if field->duz == 0
	  				    dExp := "01."
	  				    if month(ddDatdo)==12
	   					    dExp += "01." + ALLTRIM( STR( YEAR( dDDatdo) + 1 ) )
	  				    else
	   					    dExp += ALLTRIM( STR( MONTH( dDDatdo) + 1 ) ) + "." + ALLTRIM( STR( YEAR( dDDatdo ) ) )
	  				    endif
	  				    nExp := DAY( CTOD( dExp ) - 1 )
	 			    else
	  				    nExp := field->duz
	 			    endif
			    elseif field->tip == "3"
	 			    nExp := field->duz
                else
                    nExp := field->duz
			    endif
		    endif

		    if field->den <> 0 .and. dDatOd == field->datod
 			    if fprint
   				    ? "********* Izvrsena Denominacija osnovice sa koeficijentom:",den,"****"
 			    endif
 			    nOsnovSD := ROUND( nOsnovSD * field->den, 2 )
 			    nGlavn := ROUND( nGlavn * field->den, 2 )
 			    nKumKamSD := ROUND( nKumKamSD * field->den, 2 )
		    endif

		    if ( cVarObrac == "Z" )
			    nKKam := ( ( 1 + field->stkam / 100 ) ^ ( nPeriod / nExp ) - 1.00000 )
			    nIznKam := nKKam * nGlavn
		    else
			    nKStopa := field->stkam / 100
			    cPom777 := IzFmkIni( "KAM", "FormulaZaProstuKamatu", "nGlavn*nKStopa*nPeriod/nExp", KUMPATH )
			    nIznKam := &(cPom777)
		    endif
			
            nIznKam := ROUND( nIznKam, 2 )

		    if fprint
  			    
                if prow()>55
   				    FF
    			    Nstrana()
  			    endif
  			    
                if fStampajbr
    			    ? " " + cBrdok + " "
    			    fStampajBr := .f.
  			    else
    			    ? " " + SPACE(10) + " "
  			    endif
  			    
                ?? dDatOd, dDDatDo
  			    
                @ prow(), pcol() + 1 SAY nPeriod pict "999"
  			    @ prow(), pcol() + 1 SAY nOsnovSD pict picdem
			    @ prow(), pcol() + 1 SAY nGlavn pict picdem
  			    
                if ( cVarObrac == "Z" ) 
	  			    @ prow(),pcol()+1 SAY field->tip
	  			    @ prow(),pcol()+1 SAY field->stkam pict "999.99"
	  			    @ prow(),pcol()+1 SAY nKKam * 100 pict "9999.99"
  			    else
	  			    @ prow(),pcol()+1 SAY field->stkam pict "999.99"
  			    endif

  			    nCol1 := pcol() + 1
  			    @ prow(), pcol() + 1 SAY nIznKam pict picdem

		    endif 

            if ( cVarObrac == "Z" )
	            nGlavnBD += nIznKam
            endif

            nKumKamBD += nIznKam
            nKumKamSD += nIznKam

            if ( cVarObrac == "Z" )
	            nGlavn += nIznKam
            endif

            if fprint .and. gKumKam == "D"
                @ prow(), pcol() + 1 SAY nKumKamSD pict picdem  
            endif

            if dDatDo <= field->DatDo 
                select kam_pripr
                exit
            endif

            skip

            if EOF()
                Msg("PARTNER: "+kam_pripr->idpartner+", BR.DOK.: "+kam_pripr->brdok+;
                    "#GRESKA : Fali datumski interval u kam.stopama!",10)
                exit
            endif

            dDatOd := field->DatOd

        enddo 

        select kam_pripr
        skip

    enddo 

    nKumKamSD := IznosNaDan( nKumKamSD, gDatObr, IF(EMPTY(cM1), KS->datdo, KS2->datdo ), cM1 )

    if fprint
        if prow()>59
            FF
            Nstrana()
        endif
        ? m
        ? " UKUPNO ZA", cBrdok
        @ prow(),nCol1 SAY nKumKamBD pict picdem

        ? " UKUPNO NA DAN",gDatObr,":"
        @ prow(),nCol1 SAY nKumKamSD pict picdem
        ? m
    endif

    nSKumKam += nKumKamSD

    select kam_pripr

enddo 

if fprint
    
    if prow() > 54
  		FF
  		NStrana()
	endif

    ? m
    ? " SVEUKUPNO KAMATA NA DAN " + DTOC(gDatObr) + ":"
    @ prow(),pcol() SAY nOsnDug pict picdem
    @ prow(),ncol1  SAY nSKumKam pict picdem
    ? m

    P_10CPI

    if prow() < 62 + gPStranica
	    for i := 1 to 62 + gPStranica - prow()
   		    ?
 	    next
    endif

    _potpis()

    FF

endif 

if !fprint
	nKamate := nSKumKam
endif

return nSKumKam



static function _potpis()
?  PADC("     Obradio:                                 Direktor:    ",80)
?
?  PADC("_____________________                    __________________",80)
?
return



static function NStrana( cTip, cVarObrac )

if cTip == NIL
    cTip := ""
endif

if cTip == ""
    ?
    P_10CPI
    ?? padc("- Strana "+str(++nStr,4)+"-",80)
    ?
endif

if cTip == "1" .or. cTip = ""
   
    if gKumKam == "N"
        P_12CPI
    else
        P_COND
    endif

    ? m

    if cVarObrac == "Z"
   	    ? "   Broj          Period      dana     ostatak       kamatna   Tip kam  Konform.    Iznos    "+IF(gKumKam=="D","   kumulativ   ","")
   	    ? "  racuna                              racuna       osnovica   i stopa   koef       kamate   "+IF(gKumKam=="D","    kamate     ","")
    else
   	    ? "   Broj          Period      dana     ostatak       kamatna    Stopa       Iznos    "+IF(gKumKam=="D","   kumulativ   ","") 
	    ? "  racuna                              racuna       osnovica                kamate   "+IF(gKumKam=="D","    kamate     ","")
    endif

    ? m

endif

return



static function IznosNaDan(nIznos,dTrazeni,dProsli,cM1)
//* dtrazeni = 30.06.98
//* dprosli  = 15.05.94
//* znaci: uracunaj sve denominacije od 15.05.94 do 30.06.98
local nK := 1
 
PushWA()
SELECT KS
GO TOP
DO WHILE !EOF()
    IF DTOS(dTrazeni) < DTOS(DatOd)
        EXIT
    ELSEIF DTOS(dProsli) >= DTOS(DatOd)
        SKIP 1
        LOOP
    ENDIF
    IF den<>0
        nK := nK * field->den
    ENDIF
    SKIP 1
ENDDO
PopWA()
RETURN nIznos*nK


