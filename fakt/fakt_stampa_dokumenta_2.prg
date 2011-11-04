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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */

/*! \file fmk/fakt/dok/1g/stdok2.prg
 *  \brief Stampa fakture u varijanti 2
 */


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_KrozDelphi
  * \brief Da li se dokumenti stampaju kroz Delphi RB ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_KrozDelphi;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_SifRoba_PBarkod
  * \brief Da li se mogu ispisivati bar-kodovi u dokumentima ?
  * \param 0 - ne, default vrijednost
  * \param 1 - da, na upit "Zelite li ispis bar-kodova?" ponudjen je odgovor "N"
  * \param 2 - da, na upit "Zelite li ispis bar-kodova?" ponudjen je odgovor "D"
  */
*string FmkIni_SifPath_SifRoba_PBarkod;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_NazRTM
  * \brief Naziv RTM fajla koji se koristi za stampu dokumenta kroz Delphi RB
  * \param fakt1 - default vrijednost
  */
*string FmkIni_ExePath_FAKT_NazRTM;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_NazRTMFax
  * \brief Naziv RTM fajla koji se koristi za stampu dokumenta za slanje faksom
  * \param fax1 - default vrijednost
  */
*string FmkIni_ExePath_FAKT_NazRTMFax;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_StampaWin2000
  * \brief Da li je operativni sistem Windows 2000 ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_StampaWin2000;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_PozivDelphiRB
  * \brief Komanda za poziv Delphi RB-a za operativni sistem Windows 2000 
  * \param DelphiRB - default vrijednost
  */
*string FmkIni_ExePath_FAKT_PozivDelphiRB;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_10Duplo
  * \brief Da li se koristi dupli prored fakture ako faktura ima do 10 stavki?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_10Duplo;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_StampaViseDokumenata
  * \brief Da li se moze stampati vise od jednog dokumenta u pripremi ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_StampaViseDokumenata;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Zaglavlje_Linija1
  * \brief 1.red zaglavlja dokumenta pri stampanju kroz Delphi RB
  * \param gNFirma - default vrijednost
  */
*string FmkIni_KumPath_Zaglavlje_Linija1;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Zaglavlje_Linija2
  * \brief 2.red zaglavlja dokumenta pri stampanju kroz Delphi RB
  * \param - - nije definisano, default vrijednost
  */
*string FmkIni_KumPath_Zaglavlje_Linija2;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Zaglavlje_Linija3
  * \brief 3.red zaglavlja dokumenta pri stampanju kroz Delphi RB
  * \param - - nije definisano, default vrijednost
  */
*string FmkIni_KumPath_Zaglavlje_Linija3;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Zaglavlje_Linija4
  * \brief 4.red zaglavlja dokumenta pri stampanju kroz Delphi RB
  * \param - - nije definisano, default vrijednost
  */
*string FmkIni_KumPath_Zaglavlje_Linija4;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Zaglavlje_Linija5
  * \brief 5.red zaglavlja dokumenta pri stampanju kroz Delphi RB
  * \param - - nije definisano, default vrijednost
  */
*string FmkIni_KumPath_Zaglavlje_Linija5;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_CekanjeNaSljedeciPozivDRB
  * \brief Broj sekundi cekanja na provjeru da li je Delphi RB zavrsio posljednji zadani posao 
  * \param 6 - default vrijednost
  */
*string FmkIni_KumPath_FAKT_CekanjeNaSljedeciPozivDRB;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_POREZI_PPUgostKaoPPU
  * \brief Odredjuje nacin obracuna poreza u maloprodaji (u ugostiteljstvu)
  * \param M - racuna PRUC iskljucivo koristeci propisani donji limit RUC-a, default vrijednost
  * \param R - racuna PRUC na osnovu stvarne RUC ili na osnovu pr.d.lim.RUC-a ako je stvarni RUC manji od propisanog limita
  * \param J - metoda koju koriste u Jerry-ju
  * \param D - racuna PPU a ne PRUC (stari sistem), s tim da se PP racuna na istu osnovicu kao i PPU
  * \param N - racuna PPU a ne PRUC (stari sistem), s tim da se PP racuna na istu osnovicu kao i PPP
  */
*string FmkIni_ExePath_POREZI_PPUgostKaoPPU;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_SifRoba_PDRazmak
  * \brief Ako se stampaju bar-kodovi u dokumentu, da li se pravi razmak izmedju stavki u dokumentu ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_SifRoba_PDRazmak;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_UpitFax_Slati
  * \brief Ako se stampa preko Delphi RB-a, da li se pravi dokument za slanje faksom ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_PrivPath_UpitFax_Slati;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_DELPHIRB_Aktivan
  * \brief Indikator aktivnosti Delphi RB-a
  * \param 1 - aktivan
  * \param 0 - nije aktivan
  */
*string FmkIni_ExePath_DELPHIRB_Aktivan;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_Opcine
  * \brief Koristi li se sifrarnik opcina i sifra opcine u sifrarniku partnera?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_FAKT_Opcine;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_KupacDesno
  * \brief Da li se podaci o kupcu ispisuju uz desnu marginu dokumenta ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_KupacDesno;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_I19jeOtpremnica
  * \brief Da li se i dokument tipa 19 tretira kao otpremnica ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_I19jeOtpremnica;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_PrikaziNaruciocaAkoJeRazlicitOdKupca
  * \brief Ako je narucilac razlicit od kupca, da li se stampa narucilac?
  * \param D - da, default vrijednost
  * \param N - ne
  */
*string FmkIni_KumPath_FAKT_PrikaziNaruciocaAkoJeRazlicitOdKupca;


/*! \ingroup ini
 *  \var *string FmkIni_ExePath_FAKT_DelphiRB
 *  \brief Da li ce se fakture stampati kroz DelphiRB ?
 *  \param D  - Prilikom poziva stampe dokumenti se stampaju kroz DelphiRB
 *  \param N  - Obicna stampa dokumenata
 *  \param P  - Pitanje prilikom poziva stampe DelphiRB ili obicni TXT
 */
*string FmkIni_ExePath_FAKT_DelphiRB;

/*! \fn KatBr()
 *  \brief Kataloski broj
 */
 
function KatBr()
*{
if roba->(fieldpos("KATBR"))<>0
  if !empty(roba->katbr)
     return " ("+trim(roba->katbr)+")"
  endif
endif
return ""
*}



/*! \fn UgRabTXT()
 *  \brief Uzima tekst iz fajla gFUgRab
 */
 
static function UgRabTXT()
*{
local cPom:=""
local cFajl:=PRIVPATH+gFUgRab
if FILE(cFajl)
	cPom:=FILESTR(cFajl)
endif
return cPom
*}


/*! \fn DiVoRel()
 *  \brief 
 *  \todo nesto vezano za vindiju
 */
 
function DiVoRel()
*{
LOCAL nArr:=SELECT(), cIdVozila:=idvozila
  SELECT (F_VOZILA)
  IF !USED()
    O_VOZILA
  ENDIF
  SEEK cIdVozila
  SELECT (nArr)
  ? space(gnLMarg)
  ?? "Distributer:", TRIM(iddist)
  ?? "   Vozilo:", TRIM(VOZILA->naz), TRIM(VOZILA->tablice)
  ?? "   Relacija:", TRIM(idrelac)
return
*}


/*! \fn IspisiAmbalazu()
 *  \brief Ispisuje ambalazu
 */
 
function IspisiAmbalazu()
*{
// LOCAL nPak:=0, nKom:=0
// Prepak(IdRoba,ROBA->jmj,@nPak,@nKom,kolicina)
// @ prow(),pcol()+1 SAY STR(nPak,2)+"P+"+STR(nKom,2)+"K"
@ prow(),pcol()+1 SAY STR(ambp,2)+"P+"+STR(ambk,2)+"K"
return
*}



/*! \fn IspisiPoNar()
 *  \brief Ispisi po narudzbi
 */
 
function IspisiPoNar()
*{
LOCAL cV:=""
 IF lPoNarudzbi
   IF !EMPTY(brojnar)
     cV += "nar.br."+TRIM(brojnar)
   ENDIF
   IF !EMPTY(idnar) .and.;
      ( cIdTipDok="0" .or. idpartner<>idnar .and. IzFMKIni("FAKT","PrikaziNaruciocaAkoJeRazlicitOdKupca","D",KUMPATH)=="D" )
     cV += "  narucilac:"+TRIM(idnar)
   ENDIF
   cV:=ALLTRIM(cV)
   IF !EMPTY(cV)
     cV := " ("+cV+")"
   ENDIF
 ENDIF
return cV
*}


/*! \fn Kolicina()
 *  \brief
 */
 
function Kolicina()
*{
return IF(lPovDob,-kolicina,kolicina)
*}



function ImaC1_3()
*{
local cPom:=""
if pripr->(fieldpos("C1"))<>0
	cPom+=pripr->c1
endif
if pripr->(fieldpos("C2"))<>0
	cPom+=pripr->c2
endif
if pripr->(fieldpos("C3"))<>0
	cPom+=pripr->c3
endif
return !EMPTY(cPom)
*}



function PrintC1_3()
*{
if pripr->(fieldpos("C1"))<>0 .and. !empty(pripr->c1)
	?? "C1="+trim(pripr->c1),""
endif
if pripr->(fieldpos("C2"))<>0 .and. !empty(pripr->c2)
	?? "C2="+trim(pripr->c2),""
endif
if pripr->(fieldpos("C3"))<>0 .and. !empty(pripr->c3)
	?? "C3="+trim(pripr->c3),""
endif
if pripr->(fieldpos("opis"))<>0 .and. !empty(pripr->opis)
	?? "op="+trim(pripr->opis),""
endif


return
*}

