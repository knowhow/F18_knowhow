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

#include "fmk.ch"

// -----------------------------------
// kreiranje tabela - svi moduli 
// -----------------------------------
function cre_sifrarnici_1(ver)
local _created

// RJ
cIme := "rj.dbf" 

if !file(f18_ime_dbf("rj"))
    aDBf:={}
    AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
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
        my_use("valute")
        close all
    
        fill_tbl_valute()

endif

CREATE_INDEX("ID","id", "valute")
CREATE_INDEX("NAZ","tip+id+dtos(datum)", "valute")
CREATE_INDEX("ID2","id+dtos(datum)", "valute")
index_mcode(cIme)

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
   AADD(aDBf,{ 'REG'              , 'C' ,   1 ,  0 })
   DBCREATE2('ops', aDbf)
   reset_semaphore_version("ops")
   my_use("ops")
   close all
endif

CREATE_INDEX("ID","id", "ops")
CREATE_INDEX("IDJ","idj", "ops")
CREATE_INDEX("IDKAN","idKAN", "ops")
CREATE_INDEX("IDN0","IDN0", "ops")
CREATE_INDEX("NAZ","naz", "ops")
index_mcode(SIFPATH, "ops")

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
        my_usex("banke")
        close all
endif
CREATE_INDEX("ID","id", cIme)
CREATE_INDEX("NAZ","naz", cIme)
index_mcode(SIFPATH, cIme)

// RNAL
cIme:="rnal"
if !file( f18_ime_dbf(cIme))
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
   add_f_mcode(@aDbf)
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  60 ,  0 })
   DBCREATE2('RNAL.DBF', aDbf)
endif
CREATE_INDEX("ID","id", cIme)  // vrste naloga
CREATE_INDEX("NAZ","naz", cIme)
index_mcode(SIFPATH, cIme)

// REFER
if !file( f18_ime_dbf("refer"))
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
   AADD(aDBf,{ 'IDOPS'               , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  40 ,  0 })
   DBCREATE2( 'REFER', aDbf )
endif
CREATE_INDEX("ID","id", "refer") 
CREATE_INDEX("NAZ","naz", "refer")

// VRSTEP
if !FILE(f18_ime_dbf("vrstep"))
    aDbf:={}
	AADD(aDbf,{"ID" ,"C", 2,0})
	AADD(aDbf,{"NAZ","C",20,0})
	DBcreate2( "VRSTEP", aDbf )
    reset_semaphore_version("vrstep")
    my_use("vrstep")
endif	
CREATE_INDEX("ID", "Id", "VRSTEP")

// KONCIJ
if !FILE(f18_ime_dbf("koncij"))
    aDbf:={}
    AADD(aDBf,{ "ID"                  , "C" ,   7 ,  0 })
    AADD(aDBf,{ "SHEMA"               , "C" ,   1 ,  0 })
    AADD(aDBf,{ "NAZ"                 , "C" ,   2 ,  0 })
    AADD(aDBf,{ "IDPRODMJES"          , "C" ,   2 ,  0 })
    DBcreate2("KONCIJ",aDbf)
    reset_semaphore_version("koncij")
    my_use("koncij")
endif
CREATE_INDEX("ID","id", "KONCIJ" )

//PKONTO.DBF
if !FILE(f18_ime_dbf("pkonto"))
    aDbf:={}
    AADD(aDBf,{ "ID"                  , "C" ,  7  ,  0 })
    AADD(aDBf,{ "TIP"                 , "C" ,  1 ,   0 })
    DBcreate2( "PKONTO", aDbf )
    reset_semaphore_version("pkonto")
    my_use("pkonto")    
endif
CREATE_INDEX("ID","ID", "PKONTO" )
CREATE_INDEX("NAZ","TIP", "PKONTO" )

//TRFP2.DBF
if !FILE(f18_ime_dbf("trfp2"))
    aDbf:={}
    AADD(aDBf,{ "ID"                  , "C" ,  60 ,  0 })
    AADD(aDBf,{ "SHEMA"               , "C" ,   1 ,  0 })
    AADD(aDBf,{ "NAZ"                 , "C" ,  20 ,  0 })
    AADD(aDBf,{ "IDKONTO"             , "C" ,   7 ,  0 })
    AADD(aDBf,{ "DOKUMENT"            , "C" ,   1 ,  0 })
    AADD(aDBf,{ "PARTNER"             , "C" ,   1 ,  0 })
    AADD(aDBf,{ "D_P"                 , "C" ,   1 ,  0 })
    AADD(aDBf,{ "ZNAK"                , "C" ,   1 ,  0 })
    AADD(aDBf,{ "IDVD"                , "C" ,   2 ,  0 })
    AADD(aDBf,{ "IDVN"                , "C" ,   2 ,  0 })
    AADD(aDBf,{ "IDTARIFA"            , "C" ,   6 ,  0 })
    DBcreate2( "TRFP2", aDbf ) 
    reset_semaphore_version("trfp2")
    my_use("trfp2")
endif
CREATE_INDEX("ID","idvd+shema+Idkonto", "TRFP2")

//TRFP3.DBF    
if !FILE(f18_ime_dbf("trfp3"))
    aDbf:={}
    AADD(aDBf,{ "ID"                  , "C" ,  60 ,  0 })
    AADD(aDBf,{ "SHEMA"               , "C" ,   1 ,  0 })
    AADD(aDBf,{ "NAZ"                 , "C" ,  20 ,  0 })
    AADD(aDBf,{ "IDKONTO"             , "C" ,   7 ,  0 })
    AADD(aDBf,{ "D_P"                 , "C" ,   1 ,  0 })
    AADD(aDBf,{ "ZNAK"                , "C" ,   1 ,  0 })
    AADD(aDBf,{ "IDVN"                , "C" ,   2 ,  0 })
    DBcreate2("TRFP3",aDbf)
    reset_semaphore_version("trfp3")
    my_use("trfp3")
endif
CREATE_INDEX("ID","shema+Idkonto","TRFP3")

//VPRIH.DBF
if !FILE(f18_ime_dbf("vprih"))
    aDbf:={}
    AADD(aDBf,{ "ID"                  , "C" ,   3,  0 })
    AADD(aDBf,{ "NAZ"                 , "C" ,  20,  0 })
    DBcreate2("VPRIH", aDbf) 
endif
CREATE_INDEX ("ID", "Id", "VPRIH")






nArea := nil

// kreiraj lokal tabelu : LOKAL
cre_lokal(F_LOKAL)

// kreiraj tabele dok_src : DOK_SRC
cre_doksrc()

// kreiraj relacije : RELATION
cre_relation()

// kreiraj pravila : RULES
cre_fmkrules()

return .t.


// ----------------------------------------
// ----------------------------------------
function fill_tbl_valute()
local _rec

close all
my_use ('valute')


append blank
_rec := dbf_get_rec()
_rec["id"]    := "000" 
_rec["naz"]   := "KONVERTIBILNA MARKA"
_rec["naz2"]  := "KM"
_rec["datum"] := CTOD("01.01.04")
_rec["tip"]   := "D"
_rec["kurs1"] := 1
_rec["kurs2"] := 1
_rec["kurs3"] := 1
update_rec_server_and_dbf('valute', _rec)

append blank
_rec := dbf_get_rec()
_rec["id"]    := "978" 
_rec["naz"]   := "EURO"
_rec["naz2"]  := "EUR"
_rec["datum"] := CTOD("01.01.04")
_rec["tip"]   := "P"
_rec["kurs1"] := 0.512
_rec["kurs2"] := 0.512
_rec["kurs3"] := 0.512
update_rec_server_and_dbf('valute', _rec)


CLOSE ALL

return .t.

