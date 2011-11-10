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



// -------------------------------
// nabavke koje su oporezive
// --------------------------------
function t_i_opor(cIdTar)
local lRet

cIdTar := PADR(cIdTar, 6)

lRet := .f.

// standardne nabavke
lRet := lRet .or. (cIdTar == PADR("PDV17", 6) )
// nabavka poljoprivreda - oporezivo
lRet := lRet .or. (cIdTar == PADR("PDV7PO", 6) )
// avansne nabavke
lRet := lRet .or. (cIdTar == PADR("PDV7AV", 6) )

// neposlovne svrhe
lRet := lRet .or. (cIdTar == PADR("PDV7NP", 6) )

return lRet

// -------------------------------
// nabavke ne prizna je se ulazni porez
// --------------------------------
function t_u_n_poup(cIdTar)
local lRet

cIdTar := PADR(cIdTar, 6)

lRet := .f.

// standardne nabavke
// nabavka poljoprivreda - oporezivo
lRet := lRet .or. (cIdTar == PADR("PDV7NP", 6) )

return lRet


// -------------------------------
// nabavke oporezive,
// priznat ulazni porez, osim pausalne naknade poljoprivrednicima
// -------------------------------
function t_u_poup(cIdTar)
local lRet

cIdTar := PADR(cIdTar, 6)

lRet := .f.

// standardne nabavke
lRet := lRet .or. (cIdTar == PADR("PDV17", 6) )
// avansne nabavke
lRet := lRet .or. (cIdTar == PADR("PDV7AV", 6) )

return lRet

// -------------------------------
// nabavke oporezive,
// pausalne naknade poljoprivrednicima
// -------------------------------
function t_u_polj(cIdTar)
local lRet

cIdTar := PADR(cIdTar, 6)

lRet := .f.

// nabavka poljoprivreda - oporezivo
lRet := lRet .or. (cIdTar == PADR("PDV7PO", 6) )

return lRet

// -------------------------------
// nabavke neoporezive,
// neoporezivi dio nabavke od poljprovrednika
// -------------------------------
function t_u_polj_0(cIdTar)
local lRet

cIdTar := PADR(cIdTar, 6)

lRet := .f.

// nabavka poljoprivreda - oporezivo
lRet := lRet .or. (cIdTar == PADR("PDV0PO", 6) )

return lRet



// -------------------------------
// nabavke uvoz
// --------------------------------
function t_u_uvoz(cIdTar)
local lRet

cIdTar := PADR(cIdTar, 6)

lRet := .f.
lRet := lRet .or. (cIdTar == PADR("PDV7UV",6) )

return lRet

// ------------------------------------------
// nabavke neoporezivo - ne pdv obveznici
// ------------------------------------------
function t_u_neop(cIdTar)
local lRet

cIdTar := PADR(cIdTar, 6)

lRet := .f.
lRet := lRet .or. (cIdTar == PADR("PDV0", 6) )
lRet := lRet .or. (cIdTar == PADR("PDV0UV", 6) )
return lRet

// -------------------------------
// isporuke neoporezivo, osim izvoza
// --------------------------------
function t_i_neop(cIdTar)
local lRet

cIdTar := PADR(cIdTar, 6)

lRet := .f.
lRet := lRet .or. (cIdTar == PADR("PDV0",6) )

return lRet


// -------------------------------
// isporuke izvoz
// --------------------------------
function t_i_izvoz(cIdTar)
local lRet

cIdTar := PADR(cIdTar, 6)

lRet := .f.
lRet := lRet .or. (cIdTar == PADR("PDV0IZ", 6) )
return lRet



