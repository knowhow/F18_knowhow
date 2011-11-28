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


#include "fmk.ch"

function OFmkSvi()
O_KONTO
O_PARTN
O_TNAL
O_TDOK
O_VALUTE
O_RJ
O_BANKE
O_OPS

select(F_SIFK)

if !used()
	O_SIFK
  	O_SIFV
endif

if (IsRamaGlas() .or. gModul=="FAKT" .and. glRadNal)
	O_RNAL
endif

if FILE(f18_ime_dbf("RULES"))
	O_RULES
endif

return


function OSifVindija()
O_RELAC
O_VOZILA
O_KALPOS
return


function OSifFtxt()
O_FTXT
return


function OSifUgov()
O_UGOV
O_RUGOV

if (rugov->(FIELDPOS("DESTIN"))<>0)
	O_DEST
endif

O_PARTN
O_ROBA
O_SIFK
O_SIFV
return


// ---------------------------
// dodaje polje match_code
// ---------------------------
function add_f_mcode(aDbf)
AADD(aDbf, {"MATCH_CODE", "C", 10, 0})
return

// ------------------------------------
// kreiranje indexa matchcode
// ------------------------------------
function index_mcode(cPath, cTable)
if fieldpos("MATCH_CODE")<>0
	//CREATE_INDEX("MCODE", "match_code", cPath + cTable)
endif
return

// -----------------------------------
// kreiranje tabela - svi moduli 
// -----------------------------------
function CreFmkSvi()


// RJ
cIme := "rj.dbf" 

if !file(f18_ime_dbf("rj"))
   	aDBf:={}
   	//if goModul:oDataBase:cName == "LD"
   	//	AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
   	//else
   		AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
   	//endif
	add_f_mcode(@aDbf)
	AADD(aDBf,{ 'NAZ'                 , 'C' ,  35 ,  0 })

   	DBCREATE2("rj", aDbf)
    reset_semaphore_version("rj")
    my_use("rj")
	close all 
endif

CREATE_INDEX("ID","id", "rj")
CREATE_INDEX("NAZ","NAZ", "rj")
index_mcode(KUMPATH, "rj")


// PARTN
aDbf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
add_f_mcode(@aDbf)
AADD(aDBf,{ 'NAZ'                 , 'C' , 250 ,  0 })
AADD(aDBf,{ 'NAZ2'                , 'C' ,  25 ,  0 })
AADD(aDBf,{ '_KUP'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ '_DOB'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ '_BANKA'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ '_RADNIK'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PTT'                 , 'C' ,   5 ,  0 })
AADD(aDBf,{ 'MJESTO'              , 'C' ,  16 ,  0 })
AADD(aDBf,{ 'ADRESA'              , 'C' ,  24 ,  0 })
AADD(aDBf,{ 'ZIROR'               , 'C' ,  22 ,  0 })
AADD(aDBf,{ 'DZIROR'              , 'C' ,  22 ,  0 })
AADD(aDBf,{ 'TELEFON'             , 'C' ,  12 ,  0 })
AADD(aDBf,{ 'FAX'                 , 'C' ,  12 ,  0 })
AADD(aDBf,{ 'MOBTEL'              , 'C' ,  20 ,  0 })

if !file(f18_ime_dbf("partn"))

    dbcreate2('partn', aDbf)
    reset_semaphore_version("partn")
    my_use("partn")
	close all 
endif

if !file(f18_ime_dbf("_partn"))
        dbcreate2('_partn', aDbf)
endif
CREATE_INDEX("ID", "id", "partn")
CREATE_INDEX("NAZ", "NAZ", "partn")

CREATE_INDEX("ID", "id", "_partn")

index_mcode(SIFPATH, "partn")

// KONTO
if !file(f18_ime_dbf("konto"))
   aDbf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   7 ,  0 })
   add_f_mcode(@aDbf)
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  57 ,  0 })

   dbcreate2('konto', aDbf)

   reset_semaphore_version("konto")
   my_use("konto")
   close all
endif

CREATE_INDEX("ID","id", "konto")
CREATE_INDEX("NAZ","naz", "konto")
index_mcode(SIFPATH, "KONTO")

// VALUTE
cIme := f18_ime_dbf("valute")
if !file(cIme)
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
        add_f_mcode(@aDbf)
    	AADD(aDBf,{ 'NAZ'                 , 'C' ,  30 ,  0 })
        AADD(aDBf,{ 'NAZ2'                , 'C' ,   4 ,  0 })
        AADD(aDBf,{ 'DATUM'               , 'D' ,   8 ,  0 })
        AADD(aDBf,{ 'KURS1'               , 'N' ,  10 ,  5 })
        AADD(aDBf,{ 'KURS2'               , 'N' ,  10 ,  5 })
        AADD(aDBf,{ 'KURS3'               , 'N' ,  10 ,  5 })
        AADD(aDBf,{ 'TIP'                 , 'C' ,   1 ,  0 })
        dbcreate2("valute", aDbf)
        reset_semaphore_version("valute")
		close all
        my_use ('valute')
        append blank
        replace id with "000", naz with "KONVERTIBILNA MARKA", ;
                NAZ2 WITH "KM", DATUM WITH CTOD("01.01.04"), TIP WITH "D",;
                KURS1 WITH 1, KURS2 WITH 1, KURS3 WITH 1
        append blank
        replace id with "978", naz with "EURO", ;
                NAZ2 WITH "EUR", DATUM WITH CTOD("01.01.04"), TIP WITH "P",;
                KURS1 WITH 0.512, KURS2 WITH 0.512, KURS3 WITH 0.512
        CLOSE ALL
endif
CREATE_INDEX("ID","id", "valute")
CREATE_INDEX("NAZ","tip+id+dtos(datum)", "valute")
CREATE_INDEX("ID2","id+dtos(datum)", "valute")
index_mcode(SIFPATH, cIme)

// TOKVAL
if !file(f18_ime_dbf('tokval.dbf'))
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,  8  ,  2 })
	AADD(aDBf,{ 'NAZ'                 , 'N' ,  8 ,   2 })
        AADD(aDBf,{ 'NAZ2'                , 'N' ,  8 ,   2 })
        dbcreate2( 'tokval', aDbf)
endif
CREATE_INDEX("ID","id", "tokval")

// SIFK
if !file(f18_ime_dbf("sifk"))
   aDbf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   8 ,  0 })
   AADD(aDBf,{ 'SORT'                , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  25 ,  0 })
   AADD(aDBf,{ 'Oznaka'              , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'Veza'                , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'f_unique'            , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'Izvor'               , 'C' ,  15 ,  0 })
   AADD(aDBf,{ 'Uslov'               , 'C' , 100 ,  0 })
   AADD(aDBf,{ 'Duzina'              , 'N' ,   2 ,  0 })
   AADD(aDBf,{ 'f_decimal'           , 'N' ,   1 ,  0 })
   AADD(aDBf,{ 'Tip'                 , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'KVALID'              , 'C' , 100 ,  0 })
   AADD(aDBf,{ 'KWHEN'               , 'C' , 100 ,  0 })
   AADD(aDBf,{ 'UBROWSU'             , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'EDKOLONA'            , 'N' ,   2 ,  0 })
   AADD(aDBf,{ 'K1'                  , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'K2'                  , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'K3'                  , 'C' ,   3 ,  0 })
   AADD(aDBf,{ 'K4'                  , 'C' ,   4 ,  0 })

   // Primjer:
   // ID   = ROBA
   // NAZ  = Barkod
   // Oznaka = BARK
   // VEZA  = N ( 1 - moze biti samo jedna karakteristika, N - n karakteristika)
   // F_UNIQUE = D - radi se o jedinstvenom broju
   // Izvor =  ( sifrarnik  koji sadrzi moguce vrijednosti)
   // Uslov =  ( za koje grupe artikala ova karakteristika je interesantna
   // DUZINA = 13
   // Tip = C ( N numericka, C - karakter, D datum )
   // Valid = "ImeFje()"
   // validacija  mogu biti vrijednosti A,B,C,D
   //             aktiviraj funkciju ImeFje()
   dbcreate2('SIFK', aDbf)
   reset_semaphore_version("sifk")
   my_use("sifk")
   close all
endif
CREATE_INDEX("ID","id+SORT+naz",  "sifk")
CREATE_INDEX("ID2","id+oznaka", "sifk")
CREATE_INDEX("NAZ","naz", "sifk")


if !file(f18_ime_dbf("sifv.dbf"))  // sifrarnici - vrijednosti karakteristika
   aDbf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   8 ,  0 })
   AADD(aDBf,{ 'Oznaka'              , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'IdSif'               , 'C' ,  15 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  50 ,  0 })
   // Primjer:
   // ID  = ROBA
   // OZNAKA = BARK
   // IDSIF  = 2MON0005
   // NAZ = 02030303030303

   dbcreate2('sifv', aDbf)
   reset_semaphore_version("sifv")
   my_use("sifv")
   close all
endif
CREATE_INDEX("ID"      , "id+oznaka+IdSif+Naz", "sifv")
CREATE_INDEX("IDIDSIF" , "id+IdSif", "sifv")
CREATE_INDEX("NAZ"     , "id+oznaka+naz", "sifv")


// TNAL
if !file(f18_ime_dbf("tnal"))
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
        add_f_mcode(@aDbf)
	    AADD(aDBf,{ 'NAZ'                 , 'C' ,  29 ,  0 })
        dbcreate2('tnal',aDbf)
        reset_semaphore_version("tnal")
        my_use("tnal")
        close all
endif
CREATE_INDEX("ID","id", "tnal")  
CREATE_INDEX("NAZ","naz", "tnal")
index_mcode(SIFPATH, "TNAL")

// TDOK
if !file(f18_ime_dbf("tdok"))
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
        add_f_mcode(@aDbf)
	    AADD(aDBf,{ 'NAZ'                 , 'C' ,  13 ,  0 })
        dbcreate2(f18_ime_dbf('tdok'), aDbf)
        reset_semaphore_version("tdok")
        my_use("tdok")
        close all
endif
CREATE_INDEX("ID","id", "TDOK")  // Tip dokumenta
CREATE_INDEX("NAZ","naz", "TDOK")
index_mcode(SIFPATH, "TDOK")

// OPS
if !file(f18_ime_dbf("ops"))
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'IDJ'                 , 'C' ,   3 ,  0 })
   add_f_mcode(@aDbf)
   AADD(aDBf,{ 'IdN0'                , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'IdKan'               , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
   AADD(aDBf,{ 'ZIPCODE'             , 'C' ,   5 ,  0 })
   AADD(aDBf,{ 'PUCCANTON'           , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'PUCCITY'             , 'C' ,   5 ,  0 })
   DBCREATE2('ops', aDbf)
   reset_semaphore_version("ops")
   my_use("ops")
   close all
endif

CREATE_INDEX("ID","id", "ops")
if used()
    if PoljeExist("IDJ")
        CREATE_INDEX("IDJ","idj", "ops")
    endif
    if PoljeExist("IDKAN")
        CREATE_INDEX("IDKAN","idKAN", "ops")
    endif
    if PoljeExist("IDN0")
        CREATE_INDEX("IDN0","IDN0", "ops")
    endif
    CREATE_INDEX("NAZ","naz", "ops")
    index_mcode(SIFPATH, "ops")
endif

// BANKE
cIme:="banke"
if !file(f18_ime_dbf(cIme) )
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   3 ,  0 })
        add_f_mcode(@aDbf)
	    AADD(aDBf,{ 'NAZ'                 , 'C' ,  45 ,  0 })
        AADD(aDBf,{ 'Mjesto'              , 'C' ,  20 ,  0 })
        AADD(aDBf,{ 'Adresa'              , 'C' ,  30 ,  0 })
        DBCREATE2("BANKE" , aDbf)
        reset_semaphore_version("banke")
        my_use("banke")
        close all
endif
CREATE_INDEX("ID","id", SIFPATH + cIme)
CREATE_INDEX("NAZ","naz", SIFPATH + cIme)
index_mcode(SIFPATH, cIme)

// RNAL
cIme:="rnal"
if !file( f18_ime_dbf(cIme))
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
   add_f_mcode(@aDbf)
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  60 ,  0 })
   DBCREATE2(SIFPATH+'RNAL.DBF', aDbf)
endif
CREATE_INDEX("ID","id", SIFPATH + cIme)  // vrste naloga
CREATE_INDEX("NAZ","naz", SIFPATH + cIme)
index_mcode(SIFPATH, cIme)

nArea:=nil

// kreiraj lokal tabelu : LOKAL
cre_lokal(F_LOKAL)

// kreiraj tabele dok_src : DOK_SRC
cre_doksrc()

// kreiraj relacije : RELATION
cre_relation()

// kreiraj pravila : RULES
cre_fmkrules()

return

// --------------------------------------------
// provjerava da li polje postoji, samo za ops
// --------------------------------------------
function PoljeExist(cNazPolja)

O_OPS

if OPS->(FieldPos(cNazPolja))<>0
	use
	return .t.
else
	use
	return .f.
endif


