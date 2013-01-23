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


#include "pos.ch"
#include "hbclass.ch"
 
// ----------------------------------------------------------
// ----------------------------------------------------------
CLASS TDbPos INHERIT TDB 
	method New
	method install	
	method kreiraj	
	method open
ENDCLASS


// --------------------------------------------
// --------------------------------------------
method New()

 ::super:new()
 ::cName:="POS"
 ::lAdmin:=.f.

 ::kreiraj()

return self
 


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

return



// -------------------------------------------
// -------------------------------------------
method open

select F_POS
if !used()
    O_POS
endif

select F_MJTRUR
if !used()
    O_MJTRUR
endif

select F_UREDJ
if !used()
    O_UREDJ
endif

select F_ODJ
if !used()
    O_ODJ
endif

select F_K2C
if !used()
    O_K2C
endif

select F_ROBA
if !used()
    O_ROBA
endif

select F_SIFK
if !used()
    O_SIFK
endif

select F_SIFV
if !used()
    O_SIFV
endif

select F__PRIPR
if !used()
    O__POS_PRIPR
endif

select F__POS
if !used()
    O__POS
endif

return .t.




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
AADD ( aDbf, { "STO_BR",    "N",  3, 0} )
AADD ( aDbf, { "ZAK_BR",    "N",  4, 0} )
AADD ( aDbf, { "FISC_RN",   "N", 10, 0} )

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



