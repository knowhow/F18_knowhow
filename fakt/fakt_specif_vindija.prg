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


#include "fakt.ch"

function PuniDVRIz10()

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

