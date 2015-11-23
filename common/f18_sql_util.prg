
// --------------------------------------------------------
// sql_table_empty("tnal") => .t. ako je sql tabela prazna
// ---------------------------------------------------------
FUNCTION   sql_table_empty( alias )

   LOCAL _a_dbf_rec := get_a_dbf_rec( alias, .T. )

   IF _a_dbf_rec[ "temp" ]
      RETURN .T.
   ENDIF

   RETURN table_count( "fmk." + _a_dbf_rec[ "table" ] ) == 0
