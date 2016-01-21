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


function Get1_24()

_datfaktp := _datdok

@ m_x + 5, m_y + 2 SAY "KUPAC:" GET _idpartner PICT "@!" ;
            VALID EMPTY( _idpartner ) .or. P_Firma( @_idpartner, 5, 30 )

@ m_x + 6, m_y + 2 SAY "Dokument - Broj:" GET _brfaktp
@ m_x + 6, col() + 2 SAY "Datum:" GET _datfaktp

_idzaduz := ""

read

ESC_RETURN K_ESC

_kolicina := 1
_idtarifa := PADR( IzFMKINI( "KALK", "T24", "N1" ), LEN( _idtarifa ) )
_tprevoz := _tbanktr := _tspedtr := _tcardaz := _tzavtr := "U"

private nTroskovi := 0

@ m_x + 8, m_y + 2 SAY "R.br" GET nRBr PICT '999' VALID {|| CentrTxt("",24), .t. }
@ m_x + 10, m_y + 2 SAY c24T1 GET _prevoz PICT picdem
@ m_x + 10, m_y + 40 SAY c24T2 GET _banktr PICT picdem
@ m_x + 11, m_y + 2 SAY c24T3 GET _spedtr PICT picdem
@ m_x + 11, m_y + 40 SAY c24T4 GET _cardaz PICT picdem
@ m_x + 12, m_y + 2 SAY c24T5 GET _zavtr PICT picdem
@ m_x + 12, m_y + 40 SAY c24T6 GET _mpc PICT picdem
@ m_x + 13, m_y + 2 SAY c24T7 GET _mpcsapp PICT picdem ;
            VALID {|| nTroskovi := _prevoz + _banktr + _spedtr + _cardaz + _zavtr + _mpc + _mpcsapp, ;
                    DevPos( m_x + 15, m_y + 40 ), qqout("Ukupno troskovi:", nTroskovi), .t. }
@ m_x + 16, m_y + 2 SAY "Tarifni stav:" GET _idtarifa ;
                    VALID {|| P_Tarifa( @_idtarifa ), devpos(m_x+16,m_y+40), ;
                            qqout("Porez na usluge (%): ",tarifa->vpp),.t.}

@ m_x + 17, m_y + 2 SAY "Fakturna vrijednost bez poreza:" GET _fcj PICT picdem ;
                    VALID {|| _nc := IIF( _fcj == 0, _nc, nTroskovi + ( _fcj - nTroskovi ) * ( 1 + tarifa->vpp / 100 ) ), .t. }

@ m_x + 18, m_y + 2 SAY "Fakturna vrijednost sa porezom:" GET _nc PICT picdem ;
                    VALID {|| _fcj := IIF( _fcj == 0 .or. ( _fcj <> 0 .and. _nc <> 0 ), ;
                            nTroskovi + ( _nc - nTroskovi ) / ( 1 + tarifa->vpp / 100 ), _fcj ), ShowGets(), .t. }

read

_marza := _fcj - nTroskovi

@ m_x + 19, m_y + 2 SAY "Prihod :" GET _marza PICT picdem

read

nStrana := 3
return lastkey()



// PDV verzija
function Get1_24PDV()

_datfaktp := _datdok

@ m_x + 5, m_y + 2 SAY "KUPAC:" GET _idpartner PICT "@!" ;
            VALID EMPTY( _idpartner ) .or. P_Firma( @_idpartner, 5, 30 )

@ m_x + 6, m_y + 2 SAY "Dokument - Broj:" GET _brfaktp
@ m_x + 6, col() + 2 SAY "Datum:" GET _datfaktp

_idzaduz := ""

read

ESC_RETURN K_ESC

_kolicina := 1

if EMPTY( _idtarifa )
    _idtarifa := PADR( "PDV17", 6 )
endif

select kalk_pripr
_tprevoz := _tbanktr := _tspedtr := _tcardaz := _tzavtr := "U"

private nTroskovi := 0

@ m_x + 8, m_y + 2 SAY "R.br" GET nRBr PICT '999' VALID {|| CentrTxt("",24), .t. }
@ m_x + 10, m_y + 2 SAY c24T1 GET _prevoz PICT picdem
@ m_x + 10, m_y + 40 SAY c24T2 GET _banktr PICT picdem
@ m_x + 11, m_y + 2 SAY c24T3 GET _spedtr PICT picdem
@ m_x + 11, m_y + 40 SAY c24T4 GET _cardaz PICT picdem
@ m_x + 12, m_y + 2 SAY c24T5 GET _zavtr PICT picdem
@ m_x + 12, m_y + 40 SAY c24T6 GET _mpc PICT picdem
@ m_x + 13, m_y + 2 SAY c24T7 GET _mpcsapp PICT picdem 
@ m_x + 13, m_y + 40 SAY c24T8 GET _fcj3 PICT picdem ;
        VALID {|| nTroskovi := _prevoz + _banktr + _spedtr + _cardaz + _zavtr + _mpc + _mpcsapp + _fcj3, ;
                DevPos( m_x + 15, m_y + 40), qqout("Ukupno troskovi:",nTroskovi), .t. }

@ m_x + 16, m_y + 2 SAY "Tarifni stav:" GET _idtarifa VALID {|| P_Tarifa(@_IdTarifa), ShowTar(_idtarifa), .t.}

@ m_x + 17, m_y + 2 SAY "Fakturna vrijednost bez PDV:" GET _fcj PICT picdem ;
        VALID {|| _nc := IIF( _fcj == 0, _nc, nTroskovi + ( _fcj - nTroskovi ) * ( 1 + tarifa->opp / 100 ) ),.t. }

@ m_x + 18, m_y + 2 SAY "Fakturna vrijednost sa  PDV:" GET _nc PICT picdem ;
        VALID {|| _fcj := IIF( _fcj == 0 .or. ( _fcj <> 0 .and. _nc <> 0 ), ;
                    nTroskovi + ( _nc - nTroskovi ) / ( 1 + tarifa->opp / 100 ), _fcj ), ShowGets(), .t. }

read

_marza := _fcj - nTroskovi

@ m_x + 19, m_y + 2 SAY "Prihod :" GET _marza PICT picdem

read

nStrana := 3
return LastKey()


// -----------------------------------------------
// prikazi tarifu na unosu
// -----------------------------------------------
static function ShowTar( id_tarifa )

select ( F_TARIFA )
if !Used()
    O_TARIFA
endif

select tarifa
hseek id_tarifa

select kalk_pripr

devpos( m_x + 16, m_y + 40 )
qqout( "PDV (%): ", tarifa->opp )

return


