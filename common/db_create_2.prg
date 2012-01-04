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
function index_mcode(dummy, alias)

if fieldpos("MATCH_CODE") <> 0
    CREATE_INDEX("MCODE", "match_code", alias)
endif

return


// ----------------------------------------------------
// ----------------------------------------------------
function cre_sifk_sifv()

// SIFK
if !file(f18_ime_dbf("sifk"))
   aDbf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   8 ,  0 })
   AADD(aDBf,{ 'Oznaka'              , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  25 ,  0 })
   AADD(aDBf,{ 'SORT'                , 'C' ,   2 ,  0 })
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

CREATE_INDEX("ID", "id + sort + naz", "sifk")
CREATE_INDEX("ID2", "id + oznaka"   , "sifk")
CREATE_INDEX("NAZ", "naz"           , "sifk")


if !file(f18_ime_dbf("sifv.dbf"))  
   aDbf:={}
   AADD(aDBf,{ 'id'                  , 'C' ,   8 ,  0 })
   AADD(aDBf,{ 'oznaka'              , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'idsif'               , 'C' ,  15 ,  0 })
   AADD(aDBf,{ 'naz'                 , 'C' ,  50 ,  0 })

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

CREATE_INDEX("ID"      , "id + oznaka + idsif + naz", "sifv")
CREATE_INDEX("IDIDSIF" , "id + idsif",            "sifv")
CREATE_INDEX("NAZ"     , "id + oznaka + naz",       "sifv")

return .t.


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


