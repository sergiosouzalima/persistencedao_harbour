/*
    System.......: DAO
    Program......: utilsdao_class.prg
    Description..: Commum methods to persistence DAO classes.
    Author.......: Sergio Lima
    Updated at...: Oct, 2021
*/


#include "hbclass.ch"
#require "hbsqlit3"
#include "custom_commands.ch"

CREATE CLASS UtilsDao
    EXPORTED:
        METHOD New() CONSTRUCTOR
        METHOD Destroy()
        METHOD CreateTable()
        METHOD Insert( pConnection, cSql )
        METHOD Update( pConnection, cSql )
        METHOD FindBy( pConnection, cSql )
        METHOD GetMessage()
        METHOD GetRecordSet()
        METHOD FormatErrorMsg( cMessage, cSql, nSqlErrorCode, pConnection )
        METHOD CheckIfErrors( lOk, oError, nSqlErrorCode )

    PROTECTED:
        DATA pConnection    AS POINTER  INIT NIL
        
    HIDDEN: 
        DATA cMessage       AS STRING   INIT ""
        DATA ahRecordSet    AS ARRAY    INIT {}
        METHOD AdjustDate(dDate)
        METHOD FeedRecordSet( pRecords )

    ERROR HANDLER OnError( xParam )
ENDCLASS

METHOD New() CLASS UtilsDao
RETURN Self

METHOD Destroy() CLASS UtilsDao
    Self := NIL
RETURN Self

METHOD CreateTable(pConnection, cSql) CLASS UtilsDao
    LOCAL lOk := .T., cMessage := "", oError := NIL, nSqlErrorCode := 0
    TRY
        nSqlErrorCode := sqlite3_exec(pConnection, cSql)
    CATCH oError
    FINALLY
        lOk := ::CheckIfErrors( lOk, oError, nSqlErrorCode )
        cMessage := "Operacao realizada com sucesso!" IF lOk
        cMessage := ::FormatErrorMsg( cMessage, cSql, nSqlErrorCode, pConnection ) UNLESS lOk
        ::cMessage := cMessage
    ENDTRY
RETURN lOk

METHOD Insert( pConnection, cSql ) CLASS UtilsDao
    LOCAL lOk := .T., cMessage := "", oError := NIL, nSqlErrorCode := 0
    TRY
        nSqlErrorCode := sqlite3_exec( pConnection, cSql )
        lOk := sqlite3_total_changes(pConnection) > 0
        cMessage := "Nenhum registro inserido!" UNLESS lOk
    CATCH oError
    FINALLY
        lOk := ::CheckIfErrors( lOk, oError, nSqlErrorCode )
        cMessage := "Operacao realizada com sucesso!" IF lOk
        cMessage := ::FormatErrorMsg( cMessage, cSql, nSqlErrorCode, pConnection ) UNLESS lOk
        ::cMessage := cMessage
    ENDTRY
RETURN lOk

METHOD Update( pConnection, cSql ) CLASS UtilsDao
    LOCAL lOk := .T., cMessage := "", oError := NIL, nSqlErrorCode := 0
    TRY
        // hb_Alert("Passo 0350")
        nSqlErrorCode := sqlite3_exec( pConnection, cSql )
        // hb_Alert("Passo 0352")
        lOk := sqlite3_total_changes(pConnection) > 0
        // hb_Alert("Passo 0353")
        cMessage := "Nenhum registro alterado!" UNLESS lOk
        // hb_Alert("Passo 0354")
    CATCH oError
    FINALLY
        // hb_Alert("Passo 0355")
        lOk := ::CheckIfErrors( lOk, oError, nSqlErrorCode )
        // hb_Alert("Passo 0356")
        cMessage := "Operacao realizada com sucesso!" IF lOk
        // hb_Alert("Passo 0357")
        cMessage := ::FormatErrorMsg( cMessage, cSql, nSqlErrorCode, pConnection ) UNLESS lOk
        // hb_Alert("Passo 0358")
        ::cMessage := cMessage
    ENDTRY
RETURN lOk

METHOD FeedRecordSet( pRecords ) CLASS UtilsDao    
    LOCAL ahRecordSet := {}, hRecordSet := { => }
    LOCAL nQtdCols := 0, nI := 0
    LOCAL nColType := 0, cColName := ""

    RETURN ahRecordSet IF sqlite3_column_count( pRecords ) <= 0

    DO WHILE sqlite3_step( pRecords ) == SQLITE_ROW
        nQtdCols := sqlite3_column_count( pRecords )
        IF nQtdCols > 0
            hRecordSet := { => }
            FOR nI := 1 TO nQtdCols
                nColType := sqlite3_column_type( pRecords, nI )
                cColName := sqlite3_column_name( pRecords, nI )
                hRecordSet[cColName] := sqlite3_column_int( pRecords, nI )      IF nColType == 1 // SQLITE_INTEGER
                hRecordSet[cColName] := sqlite3_column_text( pRecords, nI )     IF nColType == 3 // SQLITE_TEXT
                hRecordSet[cColName] := sqlite3_column_blob( pRecords, nI )     IF nColType == 4 // SQLITE_BLOB
            NEXT
            AADD( ahRecordSet, hRecordSet )
        ENDIF
    ENDDO
RETURN ahRecordSet

METHOD FindBy( pConnection, cSql ) CLASS UtilsDao
    LOCAL lOk := .T., cMessage := "", oError := NIL, nSqlErrorCode := 0
    LOCAL pRecords := NIL, hResultRecordSet := { => }
    TRY
        pRecords := sqlite3_prepare( pConnection, cSql )
        ::ahRecordSet := ::FeedRecordSet( pRecords ) 
        nSqlErrorCode := sqlite3_errcode( pConnection )
        sqlite3_clear_bindings(pRecords)
        sqlite3_finalize(pRecords)
        lOk := Len(::ahRecordSet) != 0
        cMessage := "Nenhum registro encontrado" UNLESS lOk
    CATCH oError
    FINALLY
        pRecords := NIL
        lOk := ::CheckIfErrors( lOk, oError, nSqlErrorCode )
        cMessage := "Consulta realizada com sucesso!" IF lOk
        cMessage := ::FormatErrorMsg( cMessage, cSql, nSqlErrorCode, pConnection ) UNLESS lOk
        ::cMessage := cMessage
    ENDTRY
RETURN lOk

METHOD GetMessage() CLASS UtilsDao
RETURN ::cMessage

METHOD GetRecordSet() CLASS UtilsDao
RETURN ::ahRecordSet

METHOD AdjustDate(dDate) CLASS UtilsDao
    LOCAL cDate := DToS(dDate)    
RETURN  SubStr(cDate,7,2) + "/" + SubStr(cDate,5,2) + "/" + SubStr(cDate,1,4)

METHOD CheckIfErrors(lOk, oError, nSqlErrorCode) CLASS UtilsDao
    LOCAL nSqlErrorCodeRes := hb_defaultValue( nSqlErrorCode, SQLITE_ERROR )
    LOCAL lOkResult := lOk .AND. nSqlErrorCodeRes != SQLITE_ERROR .AND. oError == NIL
RETURN lOkResult

METHOD FormatErrorMsg( cMessage, cSql, nSqlErrorCode, pConnection ) CLASS UtilsDao
    LOCAL nSqlErrorCodeRes := hb_defaultValue( nSqlErrorCode, 0 )
    LOCAL pConnectionRes := hb_defaultValue( pConnection, NIL )
    LOCAL cMessageResult := cMessage
    cMessageResult := ;
        "Error: "   + LTrim(Str(nSqlErrorCodeRes)) + ". " + ;
        "SQL: "     + sqlite3_errmsg(pConnectionRes) + ". " + cSql IF Empty(cMessageResult)
RETURN cMessageResult

METHOD ONERROR( xParam ) CLASS UtilsDao
    LOCAL cCol := __GetMessage(), xResult
 
    IF Left( cCol, 1 ) == "_" // underscore means it's a variable
       cCol = Right( cCol, Len( cCol ) - 1 )
       IF ! __objHasData( Self, cCol )
          __objAddData( Self, cCol )
       ENDIF
       IF xParam == NIL
          xResult = __ObjSendMsg( Self, cCol )
       ELSE
          xResult = __ObjSendMsg( Self, "_" + cCol, xParam )
       ENDIF
    ELSE
       xResult := "Method not created " + cCol
    ENDIF
    ? "*** Error => ", xResult
RETURN xResult

