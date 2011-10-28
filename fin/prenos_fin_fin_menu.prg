#include "fin.ch"
/*
 * ----------------------------------------------------------------
 *                              Copyright "bring.out" doo Sarajevo 
 * ----------------------------------------------------------------
 *
 */


/*! \file fmk/fin/razoff/1g/mnu_off.prg
 *  \brief Menij prenosa podataka
 */
 

/*! \fn MnuUdaljeneLokacije()
 *  \brief Menij prenosa udaljenih lokacija
 */

function MnuUdaljeneLokacije()

private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. fin <-> fin (diskete,modem)        ")
AADD(opcexe, {|| FinDisk()})

Menu_SC("rof")

return


