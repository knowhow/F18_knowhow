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


function prenos_fakt_kalk_magacin()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc,"1. fakt->kalk (10->14) racun veleprodaje               ")
AADD(_opcexe,{||  mag_fa_ka_prenos_10_14() })
AADD(_opc,"2. fakt->kalk (12->96) otpremnica")
AADD(_opcexe,{||  mag_fa_ka_prenos_otpr()  })
AADD(_opc,"3. fakt->kalk (19->96) izlazi po ostalim osnovama")
AADD(_opcexe,{||  mag_fa_ka_prenos_otpr("19") })         
AADD(_opc,"4. fakt->kalk (01->10) ulaz od dobavljaca")
AADD(_opcexe,{||  mag_fa_ka_prenos_otpr("01_10") })          
AADD(_opc,"5. fakt->kalk (0x->16) doprema u magacin")
AADD(_opcexe,{||  mag_fa_ka_prenos_otpr("0x") })          
AADD(_opc,"6. fakt->kalk, prenos otpremnica za period")
AADD(_opcexe,{||  mag_fa_ka_prenos_otpr_period() })          

f18_menu("fkma", .f., _izbor, _opc, _opcexe )

my_close_all_dbf()
return



/*! \fn mag_fa_ka_prenos_10_14()
 *  \brief Prenos FAKT 10 -> KALK 14 (veleprodajni racun)
 */
 
function mag_fa_ka_prenos_10_14()
local nRabat := 0
local cIdFirma := gFirma
local cIdTipDok := "10"
local cBrDok := SPACE(8)
local cBrKalk := SPACE(8)
local cFaktFirma := gFirma
local dDatPl := CTOD("")
local fDoks2 := .t.
local _params := fakt_params()

private lVrsteP := _params["fakt_vrste_placanja"]

O_KONCIJ
O_KALK_PRIPR
O_KALK
O_KALK_DOKS
O_KALK_DOKS2
O_ROBA
O_KONTO
O_PARTN
O_TARIFA
O_FAKT

dDatKalk := fetch_metric( "kalk_fakt_prenos_10_14_datum", my_user(), DATE() )
cIdKonto := fetch_metric( "kalk_fakt_prenos_10_14_konto_1", my_user(), PADR("1200",7) )
cIdKonto2 := fetch_metric( "kalk_fakt_prenos_10_14_konto_2", my_user(), PADR("1310",7) )
cIdZaduz2 := SPACE(6)

if glBrojacPoKontima
    Box("#FAKT->KALK",3,70)
        @ m_x+2, m_y+2 SAY "Konto razduzuje" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
        read
    BoxC()
    cSufiks:=SufBrKalk(cIdKonto2)
    cBrKalk:=SljBrKalk("14", cIdFirma, cSufiks)
else
    cBrKalk:=GetNextKalkDoc(cIdFirma, "14")
endif

Box(,15,60)

do while .t.

	nRBr:=0
  	@ m_x+1,m_y+2   SAY "Broj kalkulacije 14 -" GET cBrKalk pict "@!"
  	@ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  	@ m_x+4,m_y+2   SAY "Konto razduzuje:" GET cIdKonto2 pict "@!" when !glBrojacPoKontima valid P_Konto(@cIdKonto2)

  	if gNW<>"X"
  		@ m_x+4,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
  	endif

  	cFaktFirma := IF( cIdKonto2 == gKomKonto, gKomFakt, cIdFirma )
  	@ m_x+6,m_y+2 SAY "Broj fakture: " GET cFaktFirma
  	@ m_x+6,col()+2 SAY "- "+cidtipdok
  	@ m_x+6,col()+2 SAY "-" GET cBrDok
  	
	read
  	
	if lastkey()==K_ESC
    	exit
  	endif

  	select fakt
  	seek cFaktFirma+cIdTipDok+cBrDok

  	if !found()
    	Beep(4)
     	@ m_x+14,m_y+2 SAY "Ne postoji ovaj dokument !!"
     	inkey(4)
     	@ m_x+14,m_y+2 SAY space(30)
     	loop
  	else

    	IF lVrsteP
       		cIdVrsteP := idvrstep
     	ENDIF

     	aMemo := ParsMemo( txt )

     	if LEN( aMemo ) >= 5
       		@ m_x + 10, m_y + 2 SAY PADR( TRIM( aMemo[3] ), 30 )
       		@ m_x + 11, m_y + 2 SAY PADR( TRIM( aMemo[4] ), 30 )
       		@ m_x + 12, m_y + 2 SAY PADR( TRIM( aMemo[5] ), 30 )
     	else
        	cTxt:=""
    	endif

     	if len(aMemo)>=9
       		dDatPl:=ctod(aMemo[9])
     	endif

     	cIdPartner:=space(6)
     	if !empty(idpartner)
       		cIdPartner:=idpartner
     	endif

     	private cBeze:=" "

     	@ m_x+14,m_y+2 SAY "Sifra partnera:"  GET cIdpartner pict "@!" valid P_Firma(@cIdPartner)
     	@ m_x+15,m_y+2 SAY "<ENTER> - prenos" GET cBeze

    	read
		ESC_BCR

     	select kalk_pripr
     	locate for BrFaktP = cBrDok 

		// faktura je vec prenesena     
		if found()
      		Beep(4)
      		@ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
     	 	inkey(4)
      		@ m_x+8,m_y+2 SAY space(30)
      		loop
     	endif
     	go bottom
     	if brdok==cBrKalk
    		nRbr:=val(Rbr)
     	endif
     	select fakt
     	IF !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
      		MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       		LOOP
     	ENDIF

     	if fdoks2
        	
            select kalk_doks2
			hseek cidfirma + "14" + cbrkalk
        	
            if !found()
           		append blank
                _rec := dbf_get_rec()
                _rec["idvd"] := "14"
                _rec["idfirma"] := cIdFirma
                _rec["brdok"] := cBrKalk
        	else
                _rec := dbf_get_rec()
            endif

            _rec["datval"] := dDatPl

        	IF lVrsteP
                _rec["k2"] := cIdVrsteP
        	ENDIF

            update_rec_server_and_dbf( "kalk_doks2", _rec, 1, "FULL" )

        	select fakt

     	endif

     	do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok

       		select ROBA
       		hseek fakt->idroba

       		select tarifa
       		hseek roba->idtarifa

       		if (RobaZastCijena(roba->idTarifa) .and. !IsPdvObveznik(cIdPartner))
            	// nije pdv obveznik
        		// roba ima zasticenu cijenu
            	nRabat := 0
       		else
        		nRabat:= fakt->rabat
       		endif

       		select fakt
       		if alltrim(podbr)=="."  .or. roba->tip $ "UY"
          		skip
      			loop
       		endif

       		select kalk_pripr
       		APPEND BLANK
       		replace idfirma with cIdFirma,;
               rbr     with str(++nRbr,3),;
               idvd with "14",;   // izlazna faktura
               brdok with cBrKalk,;
               datdok with dDatKalk,;
               idpartner with cIdPartner,;
               idtarifa with ROBA->idtarifa,;
               brfaktp with fakt->brdok,;
               datfaktp with fakt->datdok,;
               idkonto   with cidkonto,;
               idkonto2  with cidkonto2,;
               idzaduz2  with cidzaduz2,;
               kolicina with fakt->kolicina,;
               idroba with fakt->idroba,;
               nc  with ROBA->nc,;
               vpc with fakt->cijena,;
               rabatv with nRabat,;
               mpc with fakt->porez
       		select fakt
       		skip
     	enddo

     	@ m_x + 8, m_y + 2 SAY "Dokument je prenesen !!"
    
        set_metric( "kalk_fakt_prenos_10_14_datum", my_user(), dDatKalk )
        set_metric( "kalk_fakt_prenos_10_14_konto_1", my_user(), cIdKonto )
        set_metric( "kalk_fakt_prenos_10_14_konto_2", my_user(), cIdKonto2 )

     	if gBrojac == "D"
      		cBrKalk := UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
     	endif

     	inkey(4)

     	@ m_x + 8, m_y + 2 SAY space(30)

  	endif

enddo

BoxC()

my_close_all_dbf()
return



static function _o_prenos_tbls()
O_KONCIJ
O_KALK_PRIPR
O_KALK
O_KALK_DOKS
O_ROBA
O_KONTO
O_PARTN
O_TARIFA
O_FAKT
return

// ----------------------------------------------------------
// magacin: fakt->kalk prenos otpremnica
// ----------------------------------------------------------
function mag_fa_ka_prenos_otpr( cIndik )
local cIdFirma := gFirma
local cIdTipDok := "12"
local cBrDok := SPACE(8)
local cBrKalk := SPACE(8)
local cTipKalk := "96"
local cFaktDob := SPACE(10)
local dDatKalk, cIdZaduz2, cIdKonto, cIdKonto2
local cSufix

if cIndik != NIL .and. cIndik == "19"
    cIdTipDok := "19"
endif

if cIndik != NIL .and. cIndik == "0x"
    cIdTipDok := "0x"
endif

if cIndik = "01_10"
    cTipKalk := "10"
    cIdtipdok := "01"
elseif cIndik = "0x"
    cTipKalk := "16"
endif

_o_prenos_tbls()

dDatKalk := date()

if cIdTipDok == "01"
    cIdKonto := PADR( "1310", 7 )
    cIdKonto2 := PADR( "", 7 )
elseif cIdTipDok == "0x"
    cIdKonto := PADR( "1310", 7 )
    cIdKonto2 := PADR( "", 7 )
else
    cIdKonto := PADR( "", 7 )
    cIdKonto2 :=PADR( "1310", 7 )
endif

cIdKonto := fetch_metric("kalk_fakt_prenos_otpr_konto_1", my_user(), cIdKonto )
cIdKonto2 := fetch_metric("kalk_fakt_prenos_otpr_konto_2", my_user(), cIdKonto2 )

cIdZaduz2 := SPACE(6)

if glBrojacPoKontima

    Box( "#FAKT->KALK", 3, 70 )
        @ m_x + 2, m_y + 2 SAY "Konto zaduzuje" GET cIdKonto ;
                PICT "@!" ;
                VALID P_Konto( @cIdKonto )
        read
    BoxC()

    cSufiks := SufBrKalk( cIdKonto )
    cBrKalk := SljBrKalk( cTipKalk, cIdFirma, cSufiks )

else
    cBrKalk := GetNextKalkDoc( cIdFirma, cTipKalk )
endif

Box(, 15, 60 )

do while .t.

    nRBr := 0
  
    @ m_x + 1, m_y + 2 SAY "Broj kalkulacije "+cTipKalk+" -" GET cBrKalk pict "@!"
    @ m_x + 1, col() + 2 SAY "Datum:" GET dDatKalk
    @ m_x + 3, m_y + 2 SAY "Konto zaduzuje :" GET cIdKonto  pict "@!" when !glBrojacPoKontima valid P_Konto(@cIdKonto)
    @ m_x + 4, m_y + 2 SAY "Konto razduzuje:" GET cIdKonto2 pict "@!" valid empty(cidkonto2) .or. P_Konto(@cIdKonto2)
    if gNW <> "X"
        @ m_x + 4, col() + 2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
    endif

    cFaktFirma := cIdFirma
  
    @ m_x + 6, m_y + 2 SAY SPACE(60)
    @ m_x + 6, m_y + 2 SAY "Broj dokumenta u FAKT: " GET cFaktFirma
    @ m_x + 6, col() + 1 SAY "-" GET cIdTipDok VALID cIdTipDok $ "00#01#10#12#19#16"
    @ m_x + 6, col() + 1 SAY "-" GET cBrDok

    read

    if cIDTipDok == "10" .and. cTipKalk == "10"
        @ m_x + 7, m_y + 2 SAY "Faktura dobavljaca: " GET cFaktDob
    else
        cFaktDob := cBrDok
    endif
 
    read
  
    if lastkey() == K_ESC
        exit
    endif

    select fakt
    seek cFaktFirma + cIdTipDok + cBrDok
  
    if !FOUND()
        Beep(4)
        @ m_x + 14, m_y + 2 SAY "Ne postoji ovaj dokument !!"
        inkey(4)
        @ m_x + 14, m_y + 2 SAY SPACE(30)
        loop
    else

        // iscupaj podatke iz memo polja

        aMemo := ParsMemo( field->txt )

        if LEN( aMemo ) >= 5
            @ m_x + 10, m_y + 2 SAY PADR( TRIM( aMemo[3] ), 30 )
            @ m_x + 11, m_y + 2 SAY PADR( TRIM( aMemo[4] ), 30 )
            @ m_x + 12, m_y + 2 SAY PADR( TRIM( aMemo[5] ), 30 )
        else
            cTxt := ""
        endif
     
        // uzmi i partnera za prebaciti
        cIdPartner := field->idpartner
     
        private cBeze := " "

        if cTipKalk $ "10"
       
            cIdPartner := SPACE(6)
            @ m_x + 14, m_y + 2 SAY "Sifra partnera:"  GET cIdpartner PICT "@!" VALID P_Firma(@cIdPartner)
            @ m_x + 15, m_y + 2 SAY "<ENTER> - prenos" GET cBeze
       
            read
     
        endif

        select kalk_pripr
        locate for brfaktp = cBrDok 
        // da li je faktura je vec prenesena ??????

        if FOUND()
            Beep(4)
            @ m_x + 8, m_y + 2 SAY "Dokument je vec prenesen !!"
            inkey(4)
            @ m_x + 8, m_y + 2 SAY SPACE(30)
            loop
        endif
     
        go bottom
     
        if field->brdok == cBrKalk
            nRbr := VAL( field->rbr )
        endif

        select koncij
        seek TRIM( cIdKonto )

        select fakt
     
        if !ProvjeriSif("!eof() .and. '" + cFaktFirma + cIdTipDok + cBrDok + "'==IdFirma+IdTipDok+BrDok","IDROBA", F_ROBA )
            MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
            loop
        endif
     
        do while !EOF() .and. cFaktFirma + cIdTipDok + cBrDok == field->IdFirma + field->IdTipDok + field->BrDok

            select roba
            hseek fakt->idroba

            select tarifa
            hseek roba->idtarifa

            select fakt
            if ALLTRIM( podbr ) == "."  .or. roba->tip $ "UY"
                skip
                loop
            endif

            select kalk_pripr
            append blank

            _rec := dbf_get_rec()
            _rec["idfirma"] := cIdFirma
            _rec["rbr"] := STR( ++ nRbr, 3 )
            _rec["idvd"] := cTipKalk
            _rec["brdok"] := cBrKalk
            _rec["datdok"] := dDatKalk
            _rec["idpartner"] := cIdPartner
            _rec["idtarifa"] := roba->idtarifa
            _rec["brfaktp"] := cFaktDob
            _rec["datfaktp"] := fakt->datdok
            _rec["idkonto"] := cIdKonto
            _rec["idkonto2"] := cIdKonto2
            _rec["idzaduz2"] := cIdZaduz2
            _rec["kolicina"] := fakt->kolicina
            _rec["idroba"] := fakt->idroba
            _rec["nc"] := roba->nc
            _rec["vpc"] := fakt->cijena
            _rec["rabatv"] := fakt->rabat
            _rec["mpc"] := fakt->porez

            if cTipKalk $ "10#16" 
                // kod ulaza puni sa cijenama iz sifranika
                // replace vpc with roba->vpc
                _rec["vpc"] := KoncijVPC()
            endif

            if cTipKalk $ "96"
                // veza radni nalog !
                _tmp := aMemo[20]
                if !EMPTY( _tmp )
                    _rec["idzaduz2"] := _tmp
                endif
            endif

            // update-uj zapis
            dbf_update_rec( _rec )

            select fakt
            skip

        enddo
     
        @ m_x + 8, m_y + 2 SAY "Dokument je prenesen !!"
     
        set_metric("kalk_fakt_prenos_otpr_konto_1", my_user(), cIdKonto )
        set_metric("kalk_fakt_prenos_otpr_konto_2", my_user(), cIdKonto2 )

        if gBrojac == "D"
            cBrKalk := UBrojDok( VAL( LEFT( cBrKalk, 5 )) + 1, 5, RIGHT( cBrKalk, 3 ) )
        endif
     
        inkey(4)
     
        @ m_x + 8, m_y + 2 SAY SPACE(30)
  
    endif

enddo

BoxC()

my_close_all_dbf()

return



// ----------------------------------------------------------
// magacin: fakt->kalk prenos otpremnica za period
// ----------------------------------------------------------
function mag_fa_ka_prenos_otpr_period()
local _id_firma := gFirma
local _fakt_id_firma := gFirma
local _tip_dok_fakt := PADR( "12;", 150 )
local _dat_fakt_od, _dat_fakt_do
local _br_kalk_dok := SPACE(8)
local _tip_kalk := "96"
local _dat_kalk
local _id_konto
local _id_konto_2
local _sufix, _r_br, _razduzuje
local _fakt_dobavljac := SPACE(10)
local _artikli := SPACE(150)
local _usl_roba

_o_prenos_tbls()

_dat_kalk := DATE()
_id_konto := PADR( "", 7 )
_id_konto_2 := PADR( "1010", 7 )
_razduzuje := SPACE(6)
_dat_fakt_od := DATE()
_dat_fakt_do := DATE()
_br_kalk_dok := GetNextKalkDoc( _id_firma, _tip_kalk )
    
_id_konto := fetch_metric("kalk_fakt_prenos_otpr_konto_1", my_user(), _id_konto )
_id_konto_2 := fetch_metric("kalk_fakt_prenos_otpr_konto_2", my_user(), _id_konto_2 )

Box(, 15, 70 )

DO WHILE .t.

    _r_br := 0
  
    @ m_x + 1, m_y + 2 SAY "Broj kalkulacije " + _tip_kalk + " -" GET _br_kalk_dok PICT "@!"
    @ m_x + 1, col() + 2 SAY "Datum:" GET _dat_kalk
    @ m_x + 3, m_y + 2 SAY "Konto zaduzuje :" GET _id_konto PICT "@!" VALID EMPTY( _id_konto ) .OR. P_Konto( @_id_konto )
    @ m_x + 4, m_y + 2 SAY "Konto razduzuje:" GET _id_konto_2 PICT "@!" VALID EMPTY( _id_konto_2 ) .OR. P_Konto( @_id_konto_2 )

    if gNW <> "X"
        @ m_x + 4, col() + 2 SAY "Razduzuje:" GET _razduzuje PICT "@!" VALID EMPTY(_razduzuje) .OR. P_Firma( @_razduzuje )
    endif

    _fakt_id_firma := _id_firma
 
    // postavi uslove za period...
    @ m_x + 6, m_y + 2 SAY "FAKT: id firma:" GET _fakt_id_firma
    @ m_x + 7, m_y + 2 SAY "Vrste dokumenata:" GET _tip_dok_fakt PICT "@S30"
    @ m_x + 8, m_y + 2 SAY "Dokumenti u periodu od" GET _dat_fakt_od 
    @ m_x + 8, col() + 1 SAY "do" GET _dat_fakt_do

    // uslov za sifre artikla
    @ m_x + 10, m_y + 2 SAY "Uslov po artiklima:" GET _artikli PICT "@S30"
    
    READ

    IF LastKey() == K_ESC
        EXIT
    ENDIF

    SELECT fakt
    SET ORDER TO TAG "1"
    SEEK _fakt_id_firma
  
    DO WHILE !EOF() .AND. field->idfirma == _fakt_id_firma

        // provjeri po vrsti dokumenta
        IF !( field->idtipdok $ _tip_dok_fakt )
            SKIP
            LOOP
        ENDIF

        // provjeri po datumskom uslovu
        IF field->datdok < _dat_fakt_od .OR. field->datdok > _dat_fakt_do  
            SKIP
            LOOP
        ENDIF

        // provjera po robama...
        IF !EMPTY( _artikli )

            _usl_roba := Parsiraj( _artikli, "idroba" )
                   
            IF !( &_usl_roba )
                SKIP
                LOOP
            ENDIF
          
        ENDIF

        SELECT KONCIJ
        SEEK TRIM( _id_konto )

        SELECT fakt
     
        // provjeri sifru u sifrarniku...
        IF !ProvjeriSif("!eof() .and. '" + fakt->idfirma + fakt->idtipdok + fakt->brdok + "'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
            MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
            LOOP
        ENDIF
     
        SELECT ROBA
        hseek fakt->idroba

        SELECT tarifa
        hseek roba->idtarifa

        SELECT fakt

        // preskoci ako su usluge ili podbroj stavke...
        IF ALLTRIM( podbr ) == "." .OR. roba->tip $ "UY"
            SKIP
            LOOP
        ENDIF

        // dobro, sada imam prave dokumente koje treba da prebacujem,
        // bacimo se na posao...

        SELECT kalk_pripr
        GO BOTTOM
        // provjeri da li već postoji artikal prenesen, pa ga saberi sa prethodnim
        LOCATE FOR idroba == fakt->idroba        

        IF FOUND()

            // saberi ga sa prethodnim u pripremi
            RREPLACE kolicina with kolicina + fakt->kolicina        
        
        ELSE
            
            // nema artikla, dodaj novi...        
            APPEND BLANK

            REPLACE idfirma with _id_firma,;
               rbr with str( ++ _r_br, 3 ),;
               idvd with _tip_kalk,;
               brdok with _br_kalk_dok,;
               datdok with _dat_kalk,;
               idpartner with "",;
               idtarifa with ROBA->idtarifa,;
               brfaktp with _fakt_dobavljac,;
               datfaktp with fakt->datdok,;
               idkonto   with _id_konto,;
               idkonto2  with _id_konto_2,;
               idzaduz2  with _razduzuje,;
               kolicina with fakt->kolicina,;
               idroba with fakt->idroba,;
               nc  with ROBA->nc,;
               vpc with fakt->cijena,;
               rabatv with fakt->rabat,;
               mpc with fakt->porez

            IF _tip_kalk $ "96" .and. fakt->(fieldpos("idrnal")) <> 0
                REPLACE idzaduz2 with fakt->idRNal
            ENDIF

        ENDIF

        SELECT fakt
        SKIP
    
    ENDDO
     
    @ m_x + 14, m_y + 2 SAY "Dokument je generisan !!"
     
    set_metric("kalk_fakt_prenos_otpr_konto_1", my_user(), _id_konto )
    set_metric("kalk_fakt_prenos_otpr_konto_2", my_user(), _id_konto_2 )

    inkey(4)
     
    @ m_x + 14, m_y + 2 SAY SPACE(30)
  
ENDDO

BoxC()

my_close_all_dbf()

return



// ---------------------------------------------
// odredjuje sufiks broja dokumenta
// ---------------------------------------------
function SufBrKalk( cIdKonto )
local nArr := SELECT()
local cSufiks := SPACE(3)

select koncij
seek cIdKonto

if FOUND() 
    if FIELDPOS( "sufiks" ) <> 0
        cSufiks := field->sufiks
    endif
endif
select (nArr)

return cSufiks


// --------------------------
// --------------------------
function IsNumeric(cString)

if AT(cString, "0123456789") <> 0
    lResult:=.t.
else
    lResult:=.f.
endif

return lResult


