#include "f18.ch"


/*! \fn FormDat1(dUlazni)
 *  \brief formatira datum sa stoljecem (dUlazni)=> cDat
 *  \param dUlazni - ulazni datum
 */
 
function FormDat1(dUlazni)

LOCAL cVrati
 
  SET CENTURY ON
  cVrati:=DTOC(dUlazni)+"."
  SET CENTURY OFF
RETURN cVrati


