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


#include "pos.ch"
#include "hbclass.ch"
 
// ----------------------------------------------------------
// ----------------------------------------------------------
CLASS TDbPos INHERIT TDB 
	method New
	method skloniSezonu	
	method install	
	method setgaDBFs	
	method ostalef	
	method obaza	
	method kreiraj	
	method konvZn
	method open
	method reindex
	method del_pos_z
	method integ
	method chkinteg
ENDCLASS


// --------------------------------------------
// --------------------------------------------
method New()

 ::cName:="POS"
 ::lAdmin:=.f.

 ::kreiraj()

return self
 

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
method skloniSezonu(cSezona, finverse, fda, fnulirati, fRS)
local cScr
save screen to cScr

  if fda==NIL
    fDA:=.f.
  endif
  if finverse==NIL
    finverse:=.f.
  endif
  if fNulirati==NIL
    fnulirati:=.f.
  endif
  if fRS==NIL
   // mrezna radna stanica , sezona je otvorena
   fRS:=.f.
  endif
if fRS // radna stanica
  if file(ToUnix(PRIVPATH+cSezona+"\_PRIPR.DBF"))
      // nema se sta raditi ......., pripr.dbf u sezoni postoji !
      return
  endif
  aFilesK:={}
  aFilesS:={}
  aFilesP:={}
endif

  cls

  ?
  if finverse
   ? "Prenos iz  sezonskih direktorija u radne podatke"
  else
   ? "Prenos radnih podataka u sezonske direktorije"
  endif
  ?
  // privatne datoteke
  fnul:=.f.
  Skloni(PRIVPATH,"PARAMS.DBF", cSezona, finverse,fda,fnul)
  Skloni(PRIVPATH,"K2C.DBF", cSezona, finverse,fda,fnul)
  Skloni(PRIVPATH,"MJTRUR.DBF", cSezona, finverse,fda,fnul)

  // radne (pomocne) datoteke
  Skloni(PRIVPATH,"_POS.DBF", cSezona, finverse,fda,fnul)
  Skloni(PRIVPATH,"_PRIPR.DBF", cSezona, finverse,fda,fnul)
  Skloni(PRIVPATH,"PRIPRZ.DBF", cSezona, finverse,fda,fnul)
  Skloni(PRIVPATH,"PRIPRG.DBF", cSezona, finverse,fda,fnul)
  Skloni(PRIVPATH,"FMK.INI", cSezona, finverse,fda,fnul)


  if fRS
   // mrezna radna stanica!!! , baci samo privatne direktorije
   ?
   ?
   ?
   Beep(4)
   ? "pritisni nesto za nastavak.."

   restore screen from cScr
   return
  endif

  // datoteke prometa
  //
  if fnulirati; fnul:=.t.; else; fnul:=.f.; endif  // kumulativ datoteke
  Skloni(KUMPATH,"DOKS.DBF",cSezona,finverse,fda,fnul)
  Skloni(KUMPATH,"POS.DBF",cSezona,finverse,fda,fnul)
  Skloni(KUMPATH,"FMK.INI",cSezona,finverse,fda,fnul)
  
  if is_doksrc()
  	Skloni(KUMPATH,"DOKSRC.DBF",cSezona,finverse,fda,fnul)
  endif
  
  //sifrarnici
  fnul:=.f.
  Skloni(SIFPATH,"roba.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"roba.ftp",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"SIROV.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"SAST.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"STRAD.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"OSOB.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"TARIFA.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"VALUTE.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"VRSTEP.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"KASE.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"ODJ.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"DIO.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"RNGOST.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"UREDJ.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"FMK.INI",cSezona,finverse,fda,fnul)

  ?
  ?
  ?
  Beep(4)
  ? "pritisni nesto za nastavak.."

  restore screen from cScr
return


// -----------------------------------------------------
// -----------------------------------------------------
method setgaDBFs()
// prebaceno u f18_utils.prg
return




// ----------------------------------------
// ----------------------------------------
method install()
install_start(goModul,.f.)
return


// ----------------------------------------
// ----------------------------------------
method kreiraj(nArea)
local aDbf
local gSql := "N"
local gStolovi := "N"

cDirRad := my_home()
cDirSif := my_home()
cDirPriv := my_home()

if (nArea==nil)
	nArea:=-1
endif

Beep(1)

if (nArea<>-1)
	CreSystemDb(nArea)
endif


if (nArea==-1 .or. nArea==(F_RNGPLA))
	// RNGPLA - izmirenje dugovanja po racunima gostiju
	//          (radi se samo na samostalnoj kasi, odnosno serveru)
	//          - vidjeti sta sa kred. karticama i slicno
	IF !FILE (f18_ime_dbf( "rngpla" ))
	   aDbf := { {"IDGOST",   "C",  8, 0}, ;
		     {"DATUM",    "D",  8, 0}, ;
		     {"IZNOS",    "N", 20, 3}, ;
		     {"IDVALUTA", "C",  4, 0}, ;
		     {"DAT_OD",   "D",  8, 0}, ;
		     {"DAT_DO",   "D",  8, 0}, ;
		     {"IDRADNIK", "C",  4, 0}  ;
		   }
	   DBcreate2 (KUMPATH + "RNGPLA.DBF", aDbf)
	ENDIF
	CREATE_INDEX ("1", "IdGost", KUMPATH+"RNGPLA")
endif

// _POS, _PRIPR, PRIPRZ, PRIPRG, _POSP
aDbf := g_pos_pripr_fields()

if (nArea==-1 .or. nArea==(F__POS))
	IF !FILE (f18_ime_dbf("_pos"))
	   DBcreate2 (PRIVPATH+"_POS", aDbf)
	ENDIF

	// dodavanje roba na racun; inventura, nivelacija
	// prebacivanje u DOKS/POS
	CREATE_INDEX ("1", "IdPos+IdVd+dtos(datum)+BrDok+IdRoba+IdCijena+STR(Cijena,10,3)", ;
		      PRIVPATH+"_POS")
		      
	// povrat pripreme zaduzenja, inventure, nivelacije
	CREATE_INDEX ("2", "IdVd+IdOdj+IdDio", PRIVPATH+"_POS")
	// generisanje trebovanja
	CREATE_INDEX ("3", "IdVd+IdRadnik+GT+IdDio+IdOdj+IdRoba", PRIVPATH+"_POS")
endif

if (nArea==-1 .or. nArea==(F__POSP))
	IF !FILE( f18_ime_dbf("_posp") )
	   DBcreate2 (PRIVPATH + "_POSP", aDbf )
	ENDIF
endif

if (nArea==-1 .or. nArea==(F__PRIPR))
	// narudzba na jedan radni rac
	IF !FILE( f18_ime_dbf( "_pos_pripr" ) )
	   DBcreate2 (PRIVPATH + "_POS_PRIPR", aDbf )
	ENDIF
	CREATE_INDEX ("1", "IdRoba", PRIVPATH+"_POS_PRIPR")
endif

if (nArea==-1 .or. nArea==(F_PRIPRZ))
	// priprema inventure, nivelacije, zaduzenja
	IF !FILE ( f18_ime_dbf( "priprz") )
	   DBcreate2 (PRIVPATH + "PRIPRZ", aDbf )
	ENDIF
	CREATE_INDEX ("1", "IdRoba", PRIVPATH + "PRIPRZ")
endif

if (nArea==-1 .or. nArea==(F_PRIPRG))
	// generisanje utroska sirovina za jednu smjenu
	IF !FILE( f18_ime_dbf( "priprg" ))
	   DBcreate2 (PRIVPATH + "PRIPRG", aDbf )
	ENDIF

	// generisanje utroska sirovina
	CREATE_INDEX ("1", ;
		      "IdPos+IdOdj+IdDio+IdRoba+DTOS(Datum)+Smjena", PRIVPATH+"PRIPRG")
	// prebacivanje u DOKS/POS
	CREATE_INDEX ("2", ;
		      "IdPos+DTOS (Datum)+Smjena", PRIVPATH+"PRIPRG")

	if (IzFmkIni('TOPS','SpajanjeRazdCijene','N', KUMPATH)=='D')
		CREATE_INDEX ("3", "IdVd+IdPos+IdVrsteP+IdGost+Placen+IdDio+IdOdj+IdRoba+STR(Cijena,10,2)", PRIVPATH+"PRIPRG")
	else
		CREATE_INDEX ("3", "IdVd+IdPos+IdVrsteP+IdGost+Placen+IdDio+IdOdj+IdRoba", PRIVPATH+"PRIPRG")
	endif
	
	CREATE_INDEX ("4", "IdVd+IdPos+IdVrsteP+IdGost+DToS(datum)", PRIVPATH+"PRIPRG")

endif

if (nArea==-1 .or. nArea==(F_K2C))
	// K2C
	IF !FILE ( f18_ime_dbf("k2c") )
	   aDbf := {}
	   AADD ( aDbf, {"KEYCODE", "N",  4, 0} )
	   AADD ( aDbf, {"IDROBA",  "C", 10, 0} )
	   DBcreate2 (PRIVPATH+"K2C.DBF", aDbf)
	ENDIF
	CREATE_INDEX ("1", "STR (KeyCode, 4)", PRIVPATH+"K2C")
	CREATE_INDEX ("2", "IdRoba", PRIVPATH+"K2C")
endif

if (nArea==-1 .or. nArea==(F_MJTRUR))
	// MJTRUR - parovi (mjesto trebovanja,uredjaj)
	IF !FILE(f18_ime_dbf("mjtrur"))
	   aDbf := {}
	   AADD ( aDbf, {"IDDIO",      "C",  2, 0} )
	   AADD ( aDbf, {"IDODJ",      "C",  2, 0} )
	   AADD ( aDbf, {"IDUREDJAJ" , "C",  2, 0} )
	   DBcreate2 (PRIVPATH+'MJTRUR.DBF', aDbf)
	ENDIF
	CREATE_INDEX ("1", "IdDio+IdOdj", PRIVPATH+"MJTRUR")
endif

if (nArea==-1 .or. nArea==(F_ROBAIZ))
	// ROBAIZ (ako se roba ne izuzima na punktu kojeg pokriva kasa)
	IF ! FILE (f18_ime_dbf("robaiz"))
	  aDbf := {}
	  AADD ( aDbf, {"IDROBA",     "C", 10, 0} )
	  AADD ( aDbf, {"IDDIO",      "C",  2, 0} )
	  DBcreate2 (PRIVPATH+'ROBAIZ.DBF', aDbf)
	ENDIF
	CREATE_INDEX ("1", "IdRoba", PRIVPATH+"ROBAIZ")
endif

if (nArea==-1 .or. nArea==(F_DIO))
	// DIO - dijelovi objekta - HOPS
	IF ! FILE ( f18_ime_dbf("dio"))
	   aDbf := {}
	   AADD ( aDbf, {"ID" ,      "C",  2, 0} )
	   AADD ( aDbf, {"NAZ",      "C", 25, 0} )
	   DBcreate2 (SIFPATH+'DIO.DBF', aDbf)
	ENDIF
	CREATE_INDEX ("ID", "ID", SIFPATH+"DIO")
endif

if (nArea==-1 .or. nArea==(F_UREDJ))
	// UREDJAJ - parovi (mjesto trebovanja,uredjaj)
	IF ! FILE ( f18_ime_dbf("uredj"))
	   aDbf := {}
	   AADD ( aDbf, {"ID"        , "C",  2, 0} )
	   AADD ( aDbf, {"NAZ"       , "C", 30, 0} )
	   AADD ( aDbf, {"PORT"      , "C", 10, 0} )
	   DBcreate2 (SIFPATH+'UREDJ.DBF', aDbf)
	ENDIF
	CREATE_INDEX ("ID", "ID", SIFPATH+"UREDJ")
	CREATE_INDEX ("NAZ", "NAZ", SIFPATH+"UREDJ")
endif

if (nArea==-1 .or. nArea==(F_MARS))
	// MARS.DBF
	IF ! FILE ( f18_ime_dbf("mars") )
	   aDbf := {}
	   AADD ( aDbf, { "ID",        "C",  8, 0} )
	   AADD ( aDbf, { "ID2",       "C",  8, 0} )
	   AADD ( aDbf, { "KM",        "N",  6, 1} )
	   DBcreate2 ( SIFPATH + "MARS.DBF", aDbf )
	ENDIF
	CREATE_INDEX ("ID", "ID"     , SIFPATH+"MARS")
	CREATE_INDEX ("2" , "ID+ID2" , SIFPATH+"MARS")
endif

// planika integritet
if (gSql == "D")
	CreDIntDB()
endif

return




// -------------------------------------
// -------------------------------------
method obaza(i)
local lIdIDalje
local cDbfName

PUBLIC gSifPath := SIFPATH


lIdiDalje:=.f.

if ( i==F_POS_DOKS .or. i==F_POS .or. i==F_RNGPLA .or. i==F__POS .or. i==F__PRIPR .or. i==F_PRIPRZ .or. i==F__POSP .or. i==F_DOKSPF) 
	lIdiDalje:=.t.
endif

if (i==F_PRIPRG .or. i==F_K2C .or. i==F_MJTRUR .or. i==F_ROBAIZ .or. i==F_ROBA) 
	lIdiDalje:=.t.
endif

if i==F_SIROV .or. i==F_SAST .or. i==F_OSOB .or. i==F_STRAD 
	lIdiDalje:=.t.
endif

if i==F_TARIFA .or. i==F_VALUTE .or. i==F_VRSTEP .or. i==F_KASE .or. i==F_ODJ 
	lIdiDalje:=.t.
endif

if i==F_DIO .or. i==F_UREDJ .or. i==F_RNGOST .or. i==F_MARS .or. i==F_PARAMS .or. i==F_GPARAMS .or. i==F_KORISN .or. i==F_MPARAMS .or. i==F_GPARAMSP
	lIdiDalje:=.t.
endif

if (IsPlanika() .and. i==F_PROMVP)
	lIdiDalje:=.t.
endif

if (IsPlanika() .and. i==F_MESSAGE .and. i==F_TMPMSG)
	lIdiDalje:=.t.
endif

if is_doksrc()
	if i==F_DOKSRC .or. i==F_P_DOKSRC
		lIdiDalje := .t.
	endif
endif

// integritet
if (gSql=="D" .and. (i==F_DINTEG1 .or. i==F_DINTEG2 .or. i==F_INTEG1 .or. i==F_INTEG2) )
	lIdiDalje:=.t.
endif

if lIdiDalje
	cDbfName:=DBFName(i,.t.)
	select(i)
	usex(cDbfName)
else
	use
	return
endif

return


// --------------------------------------------
// --------------------------------------------
method ostalef()
if !SigmaSif("SIGMAXXX")
 return
endif

PUBLIC gSifPath := SIFPATH
PUBLIC gKumPath := KUMPATH

if pitanje(,"Izvrsiti prenos k7 iz c:\tops\robknj.dbf","N")=="D"
   close all
   my_use("roba", "ROBA", .t.)
   set order to tag "ID"

   my_use ("robknj", "ROBKNJ", .t.)
   go top
   do while !eof()
      select roba; seek robknj->id
      if found()
         replace k7 with robknj->k7
      endif

      select robknj
      skip
   enddo
   MsgC()

endif

if pitanje(,"Izvrsiti promjenu sifre artikla u sifrarniku i prometu? (D/N)","N")=="D"
  close all
  cStara := cNova := SPACE(10)
  cDN    := " "
  Box(,5,70)
    @ m_x+2, m_y+2 SAY "Zamijeniti sifru artikla:" GET cStara
    @ m_x+3, m_y+2 SAY "Nova sifra artikla      :" GET cNova
    @ m_x+4, m_y+2 SAY "Da li ste 100 % sigurni da ovo zelite ? (D/N)" GET cDN VALID cDN$"DN" PICT "@!"
    READ
  BoxC()
  if cDN=="D"

    nPR:=0
    my_use ("roba",  "ROBA", .t.)
    set order to tag "ID"
    seek cStara
    do while !eof() .and. id==cStara
      skip 1; nRec:=RECNO(); skip -1
      ++nPR
      Scatter()
       _id := cNova
      Gather()
      go (nRec)
    enddo

    nPP:=0
    my_use ("pos", "POS", .t.)
    set order to tag "6"
    seek cStara
    do while !eof() .and. idroba==cStara
      skip 1; nRec:=RECNO(); skip -1
      ++nPP
      Scatter()
       _idroba := cNova
      Gather()
      go (nRec)
    enddo

    MsgBeep( "Broj promjena stavki u ROBA.DBF="+ALLTRIM(STR(nPR))+;
             ", u POS.DBF="+ALLTRIM(STR(nPP)) )

  endif
endif

closeret
return


// -------------------------------------------------
// -------------------------------------------------
method konvZn()

 LOCAL cIz:="7", cU:="8", aPriv:={}, aKum:={}, aSif:={}
 LOCAL GetList:={}, cSif:="D", cKum:="D", cPriv:="D"

 IF !SigmaSif("KZ      ")
   RETURN
 ENDIF

 Box(,8,50)
  @ m_x+2, m_y+2 SAY "Trenutni standard (7/8)        " GET cIz   VALID   cIz$"78"  PICT "9"
  @ m_x+3, m_y+2 SAY "Konvertovati u standard (7/8/A)" GET cU    VALID    cU$"78A" PICT "@!"
  @ m_x+5, m_y+2 SAY "Konvertovati sifrarnike (D/N)  " GET cSif  VALID  cSif$"DN"  PICT "@!"
  @ m_x+6, m_y+2 SAY "Konvertovati radne baze (D/N)  " GET cKum  VALID  cKum$"DN"  PICT "@!"
  @ m_x+7, m_y+2 SAY "Konvertovati priv.baze  (D/N)  " GET cPriv VALID cPriv$"DN"  PICT "@!"
  READ
  IF LASTKEY()==K_ESC; BoxC(); RETURN; ENDIF
  IF Pitanje(,"Jeste li sigurni da zelite izvrsiti konverziju (D/N)","N")=="N"
    BoxC(); RETURN
  ENDIF
 BoxC()

 aPriv := { F__POS, F__PRIPR, F_PRIPRZ, F_PRIPRG, F_K2C, F_MJTRUR, F_ROBAIZ,;
            F_RAZDR }

 aKum  := { F_POS_DOKS, F_POS, F_RNGPLA }

 aSif  := { F_ROBA, F_SIROV, F_SAST, F_STRAD, F_TARIFA, F_VALUTE,;
            F_VRSTEP, F_ODJ, F_DIO, F_UREDJ, F_RNGOST, F_MARS }


 IF cSif  == "N"; aSif  := {}; ENDIF
 IF cKum  == "N"; aKum  := {}; ENDIF
 IF cPriv == "N"; aPriv := {}; ENDIF

 KZNbaza(aPriv,aKum,aSif,cIz,cU)
RETURN



// -------------------------------------------
// -------------------------------------------
method open

if gPratiStanje $ "D!"
  O_POS
endif

if gModul=="HOPS"
  O_DIO
  O_ROBAIZ
endif

O_MJTRUR
O_UREDJ
O_ODJ
O_K2C
O_ROBA
O_SIFK
O_SIFV
O__POS_PRIPR
O__POS

return .t.


// --------------------------------------------
// --------------------------------------------
method reindex
pos_reindex_all()
return


// --------------------------------------------
// --------------------------------------------
method del_pos_z
local nTArea := SELECT()

O__POS
select _pos
go top

msgo("....brisem iz pomocne tabele _POS zakljucene stavke....")

do while !EOF()
	if _pos->gt == OBR_JEST
		del_skip()
	else
		skip
	endif
enddo

msgc()

select (nTArea)
return


// -------------------------------------------
// -------------------------------------------
method integ

if gSql == "N"
	return
endif

if gAppSrv
	return
endif

// vazi samo za prodavnicu
if gSamoProdaja == "D"
	lReindex := .f.
	UpdInt1(.f., @lReindex)
	UpdInt2(.f., @lReindex)
else
	return
endif


// -------------------------------------------
// -------------------------------------------
method chkinteg

// ako je aplikacioni server onda izadji....
if gAppSrv
	return
endif

if gSql == "N"
	return
endif

nRes1:=0
nRes2:=0

if gSamoProdaja == "N" .and. IzFmkIni("TOPS","INTEG","N",EXEPATH)=="D"
	lReindex := .f.
	BrisiError()
	nRes1:=ChkInt1(.f., @lReindex)
	nRes2:=ChkInt2(.f., @lReindex)
	if (nRes1 + nRes2) <> 0
		RptInteg(.f., .t.)
	endif
else
	return
endif


// --------------------------------
// --------------------------------
function g_pos_pripr_fields()
local aDbf

// _POS, _PRIPR, PRIPRZ, PRIPRG, _POSP
aDbf := {}
AADD ( aDbf, { "BRDOK",     "C",  6, 0} )
AADD ( aDbf, { "CIJENA",    "N", 10, 3} )
AADD ( aDbf, { "DATUM",     "D",  8, 0} )
AADD ( aDbf, { "GT",        "C",  1, 0} )
AADD ( aDbf, { "IDCIJENA",  "C",  1, 0} )
AADD ( aDbf, { "IDDIO",     "C",  2, 0} )
AADD ( aDbf, { "IDGOST",    "C",  8, 0} )
AADD ( aDbf, { "IDODJ",     "C",  2, 0} )
AADD ( aDbf, { "IDPOS",     "C",  2, 0} )
AADD ( aDbf, { "IDRADNIK",  "C",  4, 0} )
AADD ( aDbf, { "IDROBA",    "C", 10, 0} )

AADD ( aDbf, { "IDTARIFA",  "C",  6, 0} )
AADD ( aDbf, { "IDVD",      "C",  2, 0} )
AADD ( aDbf, { "IDVRSTEP",  "C",  2, 0} )
AADD ( aDbf, { "JMJ",       "C",  3, 0} )

// za inventuru, nivelaciju
AADD ( aDbf, { "KOL2",      "N", 18, 3} )       
AADD ( aDbf, { "KOLICINA",  "N", 18, 3} )
AADD ( aDbf, { "M1",        "C",  1, 0} )
AADD ( aDbf, { "MU_I",      "C",  1, 0} )
AADD ( aDbf, { "NCIJENA",   "N", 10, 3} )
AADD ( aDbf, { "PLACEN",    "C",  1, 0} )
AADD ( aDbf, { "PREBACEN",  "C",  1, 0} )
AADD ( aDbf, { "ROBANAZ",   "C", 40, 0} )
AADD ( aDbf, { "SMJENA",    "C",  1, 0} )
AADD ( aDbf, { "STO",       "C",  3, 0} )
AADD ( aDbf, { "VRIJEME",   "C",  5, 0} )

AADD( aDBf, { 'K1'                  , 'C' ,   4 ,  0 })
// planika: dobavljac   - grupe artikala
AADD( aDBf, { 'K2'                  , 'C' ,   4 ,  0 })
// planika: stavljaju se oznake za velicinu obuce
//          X - ne broji se parovno

AADD( aDBf, { 'K7'                  , 'C' ,   1 ,  0 })
AADD( aDBf, { 'K8'                  , 'C' ,   2 ,  0 })
AADD( aDBf, { 'K9'                  , 'C' ,   3 ,  0 })
// planika: stavljaju se oznake za velicinu obuce
//          X - ne broji se parovno

AADD( aDBf, { 'N1'     , 'N' ,  12 ,  2 })
AADD( aDBf, { 'N2'     , 'N' ,  12 ,  2 })

AADD( aDBf, { 'BARKOD' , 'C' ,  13 ,  0 })
AADD( aDBf, { 'KATBR'  , 'C' ,  14 ,  0 })

AADD( aDBf, { 'C_1'    , 'C' ,   6 ,  0 })
AADD( aDBf, { 'C_2'    , 'C' ,  10 ,  0 })
AADD( aDBf, { 'C_3'    , 'C' ,  50 ,  0 })

return aDbf



