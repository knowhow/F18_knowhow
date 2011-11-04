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
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/specif/vindija/1g/vindija.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.1 $
 * $Log: vindija.prg,v $
 * Revision 1.1  2002/06/26 17:55:24  ernad
 *
 *
 * ciscenja knjiz.prg
 *
 *
 */
 
/*! \fn PuniDVRIz10()
 *  \brief Popuni Ditributer-Vozilo-Relacija iz 10-ke
 *  \brief Specificno za vindiju
 *  \todo Prebaciti na lokaciju dokumenata za vindiju
 */
 
function PuniDVRIz10()
*{
LOCAL nArr:=SELECT(), lVrati:=.f.
  SELECT FAKT; SET ORDER TO TAG "1"
  SEEK _idfirma+"10"+left(_brdok,gNumDio)
  IF _idfirma+"10"+left(_brdok,gNumDio)==idfirma+idtipdok+left(brdok,gNumDio)
    lVrati:=.t.
    _idpartner:= idpartner
    _idpm     := idpm
    _IdRelac  := IdRelac
    _IdDist   := IdDist
    _IdVozila := IdVozila
    _Marsruta := Marsruta
  ELSE
    MsgBeep("Pod zadanim brojem ne postoji faktura za storniranje!")
  ENDIF
  SELECT (nArr)
return lVrati
*}


