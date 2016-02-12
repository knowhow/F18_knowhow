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



function StDoks()
local nCol1 := 0, cImeKup
local cidfirma
local nul,nizl,nRbr
local m
private qqTipDok
private ddatod,ddatdo

O_KALK_DOKS

if reccount2() == 0
    kalk_gen_doks_iz_kalk()
endif

my_close_all_dbf()

SStDoks()

return





function SStDoks()
local lImaUkSt := .f.
local _head
local _n_col := 20
local _pkonto, _mkonto
local _qqmkonto, _qqpkonto
local _partn_naz := "N"

O_KALK_DOKS
O_PARTN
O_KALK

cIdfirma := gFirma
dDatOd := CTOD("")
dDatDo := DATE()
_mkonto := SPACE( 300 )
_pkonto := SPACE( 300 )
_qqpkonto := ""
_qqmkonto := ""

qqVD := ""

Box(, 12, 75 )

	private cStampaj := "N"
	qqBrDok := ""

	cIdFirma := fetch_metric( "kalk_lista_dokumenata_firma", my_user(), cIdFirma )
	qqVD := fetch_metric( "kalk_lista_dokumenata_vd", my_user(), qqVD )
	qqBrDok := fetch_metric( "kalk_lista_dokumenata_brdok", my_user(), qqBrDok )
	dDatOd := fetch_metric( "kalk_lista_dokumenata_datum_od", my_user(), dDatOd )
	dDatDo := fetch_metric( "kalk_lista_dokumenata_datum_do", my_user(), dDatDo )
	_mkonto := fetch_metric( "kalk_lista_dokumenata_mkonto", my_user(), _mkonto )
	_pkonto := fetch_metric( "kalk_lista_dokumenata_pkonto", my_user(), _pkonto )
	_partn_naz := fetch_metric( "kalk_lista_dokumenata_ispis_partnera", my_user(), _partn_naz )
	
	qqVD := padr(qqVD,2)
	qqBrDok := PADR(qqBrDok,60)

	cImeKup := space(20)
	cIdPartner := space(6)

	do while .t.

	if gNW=="X"
   		cIdFirma := padr(cidfirma,2)
   		@ m_x + 1, m_y + 2 SAY "Firma - prazno svi" GET cIdFirma valid {|| .t. }
   		read
 	endif

 	if !empty(cidfirma)
    	@ m_x + 2, m_y + 2 SAY "Tip dokumenta (prazno svi tipovi)" GET qqVD pict "@!"
    	qqVD:="  "
 	else
    	cIdfirma:=""
 	endif

 	@ m_x + 3, m_y + 2 SAY "Od datuma "  get dDatOd
 	@ m_x + 3, col() + 1 SAY "do"  get dDatDo
 	@ m_x + 5, m_y + 2 SAY "Partner" GET cIdPartner pict "@!" valid empty(cidpartner) .or. P_Firma(@cIdPartner)
 	@ m_x + 6, m_y + 2 SAY " Magacinska konta:" GET _mkonto pict "@S30"
 	@ m_x + 7, m_y + 2 SAY "Prodavnicka konta:" GET _pkonto pict "@S30"
 	@ m_x + 8, m_y + 2 SAY "Brojevi dokumenata (prazno-svi)" GET qqBrDok PICT "@!S40"
 	@ m_x + 10, m_y + 2 SAY "Ispis naziva partnera (D/N)?" GET _partn_naz PICT "@!" VALID _partn_naz $ "DN"
 	@ m_x + 12, m_y + 2 SAY "Izvrsiti stampanje sadrzaja ovih dokumenata ?"  get cStampaj pict "@!" valid cStampaj$"DN"

 	read

 	ESC_BCR

	aUsl1 := Parsiraj( qqBrDok, "BRDOK" )

	if !EMPTY( _mkonto )
		_qqmkonto := Parsiraj( _mkonto, "mkonto" )
	endif

	if !EMPTY( _pkonto )
		_qqpkonto := Parsiraj( _pkonto, "pkonto" )
	endif

	if aUsl1 <> NIL
		exit
	endif

	enddo

	qqVD := TRIM( qqVD )
	qqBrDok := TRIM( qqBrDok )

	set_metric( "kalk_lista_dokumenata_firma", my_user(), cIdFirma )
	set_metric( "kalk_lista_dokumenata_vd", my_user(), qqVD )
	set_metric( "kalk_lista_dokumenata_brdok", my_user(), qqBrDok )
	set_metric( "kalk_lista_dokumenata_datum_od", my_user(), dDatOd )
	set_metric( "kalk_lista_dokumenata_datum_do", my_user(), dDatDo )
	set_metric( "kalk_lista_dokumenata_mkonto", my_user(), _mkonto )
	set_metric( "kalk_lista_dokumenata_pkonto", my_user(), _pkonto )
	set_metric( "kalk_lista_dokumenata_ispis_partnera", my_user(), _partn_naz )
	
BoxC()

select kalk_doks

if FieldPos("ukstavki") <> 0
	lImaUkSt := .t.
endif

private cFilt := ".t."

if !empty(dDatOd) .or. !empty(dDatDo)
	cFilt += ".and. DatDok>=" + dbf_quote(dDatOd) + ".and. DatDok<=" + dbf_quote(dDatDo)
endif

if !empty(qqVD)
  	cFilt+=".and. idvd=="+dbf_quote(qqVD)
endif

if !empty(cIdPartner)
  	cFilt+=".and. idpartner=="+dbf_quote(cIdPartner)
endif

if !empty(qqBrDok)
  	cFilt+=(".and."+aUsl1)
endif

if !EMPTY( _qqmkonto )
	cFilt += ( ".and." + _qqmkonto )
endif

if !EMPTY( _qqpkonto )
	cFilt += ( ".and." + _qqpkonto )
endif

set filter to &cFilt

qqVD := TRIM(qqVD)

seek cIdFirma + qqVD

if cStampaj == "D"
	kalk_stampa_dokumenta( .t., "IZDOKS" )
   	my_close_all_dbf()
	return
endif

EOF CRET

gaZagFix := { 6, 3 }

START PRINT CRET
?

Preduzece()

if gDuzKonto > 7
	P_COND2
else
 	P_COND
endif

?? "KALK: Stampa dokumenata na dan:", DATE(), SPACE(10), "za period", dDatOd, "-", dDatDo

if !empty(qqVD)
	?? space(2),"za tipove dokumenta:",trim(qqVD)
endif

if !empty(qqBrDok)
	?? space(2),"za brojeve dokumenta:",trim(qqBrDok)
endif

m := _get_rpt_line()
_head := _get_rpt_header()

? m
? _head
? m

nC := 0
nCol1 := 30
nNV := nVPV := nRabat := nMPV := 0
nUkStavki := 0

do while !EOF() .and. IdFirma = cIdFirma
  
    select partn
    HSEEK kalk_doks->idpartner

    select kalk_doks

	? STR( ++nC, 4 ) + "."

	@ prow(), pcol() + 1 SAY field->datdok
	@ prow(), pcol() + 1 SAY PADR( field->idfirma + "-" + field->idVd + "-" + field->brdok, 16)

	if field->idvd == "80"
		
		select kalk
		go top
		seek kalk_doks->idfirma + kalk_doks->idvd + kalk_doks->brdok
		
		if !EMPTY( kalk->idkonto2 )
			@ prow(), pcol() + 1 SAY PADR( ALLTRIM(field->idkonto) + "->" + ALLTRIM( field->idkonto2), 15)
		else
			@ prow(), pcol() + 1 SAY PADR( kalk_doks->mkonto, 7 )
			@ prow(), pcol() + 1 SAY PADR( kalk_doks->pkonto, 7 )
		endif

		select kalk_doks

	else
		@ prow(), pcol() + 1 SAY PADR( kalk_doks->mkonto, 7 )
		@ prow(), pcol() + 1 SAY PADR( kalk_doks->pkonto, 7 )
	endif

	@ prow(), _n_col := pcol() + 1 SAY PADR( field->idpartner, 6 )
	@ prow(), pcol() + 1 SAY PADR( field->idzaduz, 6 )
	@ prow(), pcol() + 1 SAY PADR( field->idzaduz2, 6 )
  
	nCol1 := pcol() + 1

  	@ prow(),pcol()+1 SAY str(nv,12,2)
  	@ prow(),pcol()+1 SAY str(vpv,12,2)
  	@ prow(),pcol()+1 SAY str(rabat,12,2)
  	@ prow(),pcol()+1 SAY str(mpv,12,2)
  
  	if fieldpos("sifra")<>0
    	@ prow(),pcol()+1 SAY padr(iif(empty(sifra),space(2),left(CryptSC(sifra),2)),6)
  	endif

    // drugi red
    if _partn_naz == "D" .and. !EMPTY( field->idpartner )
        ?
        @ prow(), _n_col SAY ALLTRIM( partn->naz )
    endif

  	nNV += NV
 	nVPV += VPV
  	nRabat += Rabat
 	nMPV += MPV

  	if lImaUkSt
		if field->ukStavki==0

			nStavki:=0

			select kalk
			set order to tag "1"
			seek kalk_doks->(idFirma+idVd+brDok)

			do while !eof() .and. idFirma+idVd+brDok==kalk_doks->(idFirma+idVd+brDok)
				nStavki:=nStavki+1
				skip 1
			enddo

			select kalk_doks
			_rec := dbf_get_rec()
            _rec["ukstavki"] := nStavki
            update_rec_server_and_dbf( "kalk_doks", _rec, 1, "FULL" )
		
        endif
  		
        nUkStavki+=field->ukStavki
		@ prow(),pcol()+1 SAY str(field->ukStavki,6)

	endif

  	skip

enddo

? m
? "UKUPNO "

@ prow(),nCol1 SAY str(nnv,12,2)
@ prow(),pcol()+1 SAY str(nvpv,12,2)
@ prow(),pcol()+1 SAY str(nrabat,12,2)
@ prow(),pcol()+1 SAY str(nmpv,12,2)

if fieldpos("sifra")<>0
   ?? "       "
endif

if lImaUkSt
	@ prow(),pcol()+1 SAY str(nUkStavki,6)
endif
? m

FF
ENDPRINT

my_close_all_dbf()
return


static function _get_rpt_header()
local _head := ""

_head += PADC( "Rbr", 5 )
_head += SPACE(1)
_head += PADC( "Datum", 8 )
_head += SPACE(1)
_head += PADC( "Dokument", 16 )
_head += SPACE(1)
_head += PADC( "M-konto", 7 )
_head += SPACE(1)
_head += PADC( "P-konto", 7 )
_head += SPACE(1)
_head += PADC( "Part.", 6 )
_head += SPACE(1)
_head += PADC( "Zad.", 6 )
_head += SPACE(1)
_head += PADC( "Zad.2", 6 )
_head += SPACE(1)
_head += PADC( "NV", 12 )
_head += SPACE(1)
_head += PADC( "VPV", 12 )
_head += SPACE(1)
_head += PADC( "RABATV", 12 )
_head += SPACE(1)
_head += PADC( "MPV", 12 )
_head += SPACE(1)
_head += PADC( "Op.", 6 )

return _head



// ------------------------------------------------------
// vraca liniju za report
// ------------------------------------------------------
static function _get_rpt_line()
local _line := ""

_line += REPLICATE( "-", 5 )
_line += SPACE(1)
_line += REPLICATE( "-", 8 )
_line += SPACE(1)
_line += REPLICATE( "-", 16 )
_line += SPACE(1)
_line += REPLICATE( "-", 7 )
_line += SPACE(1)
_line += REPLICATE( "-", 7 )
_line += SPACE(1)
_line += REPLICATE( "-", 6 )
_line += SPACE(1)
_line += REPLICATE( "-", 6 )
_line += SPACE(1)
_line += REPLICATE( "-", 6 )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )
_line += SPACE(1)
_line += REPLICATE( "-", 6 )

return _line




/*! \fn kalk_gen_doks_iz_kalk()
 *  \brief Generisanje tabele DOKS na osnovu tabele KALK
 */

function kalk_gen_doks_iz_kalk()
*{
O_KALK

select kalk
go top

do while !eof()
  select kalk_doks
  append blank

  select kalk
  cIDFirma:=idfirma
  private cBrDok:=BrDok,cIdVD:=IdVD,dDatDok:=datdok

  cIdpartner:=idpartner; cmkonto:=mkonto; cpkonto:=pkonto ; cIdZaduz:=idzaduz; cIdzaduz2:=idzaduz2
  select kalk_doks
  replace idfirma with cidfirma, brdok with cbrdok,;
          datdok with ddatdok, idvd with cidvd,;
          idpartner with cIdPartner, mkonto with cMKONTO,pkonto with cPKONTO,;
          idzaduz with cidzaduz, idzaduz2 with cidzaduz2,;
          brfaktp with kalk->BrFaktP

  select kalk

  nNV:=nVPV:=nMPV:=nRABAT:=0
  do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
    if mu_i="1"
      nNV+=nc*(kolicina-gkolicina-gkolicin2)
      nVPV+=vpc*(kolicina-gkolicina-gkolicin2)
    elseif mu_i="3"
      nVPV+=vpc*(kolicina-gkolicina-gkolicin2)
    elseif mu_i="5"
      nNV-=nc*(kolicina)
      nVPV-=vpc*(kolicina)
      nRabat+=vpc*rabatv/100*kolicina
    endif

    if pu_i=="1"
     if empty(mu_i)
       nNV+=nc*kolicina
     endif
     nMPV+=mpcsapp*kolicina
    elseif pu_i=="5"
     if empty(mu_i)
      nNV-=nc*kolicina
     endif
     nMPV-=mpcsapp*kolicina
    elseif pu_i=="I"
      nMPV-=mpcsapp*gkolicin2
      nNV-=nc*gkolicin2
    elseif pu_i=="3"
      nMPV+=mpcsapp*kolicina
    endif

    skip
  enddo

  select kalk_doks
  replace nv with nnv, vpv with nvpv, rabat with nrabat, mpv with nmpv

  select kalk

enddo

return
*}
