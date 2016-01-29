#include "f18.ch"


/*! \fn FormDat1(dUlazni)
 *  \brief formatira datum sa stoljecem (dUlazni)=> cDat
 *  \param dUlazni - ulazni datum
 */

FUNCTION FormDat1( dUlazni )

   LOCAL cVrati

   SET CENTURY ON
   cVrati := DToC( dUlazni ) + "."
   SET CENTURY OFF

   RETURN cVrati
