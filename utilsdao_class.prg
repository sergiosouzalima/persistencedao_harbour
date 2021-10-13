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

    PROTECTED:
        DATA pConnection    AS POINTER  INIT NIL
        
    HIDDEN: 
        DATA cMessage       AS STRING   INIT ""
        DATA ahRecordSet    AS ARRAY    INIT {}
        METHOD FormatErrorMsg( pDataBase, nSqlErrorCode, cSql )
        METHOD CheckIfErrors(lOk, nSqlErrorCode, oError) 
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
    LOCAL lOk := .T., cMessage := ""
    LOCAL oError := NIL, nSqlErrorCode := 0
    TRY
        nSqlErrorCode := sqlite3_exec(pConnection, cSql)
    CATCH oError
    FINALLY
        lOk := ::CheckIfErrors( lOk, nSqlErrorCode, oError )
        cMessage := "Operacao realizada com sucesso!" IF lOk
        cMessage := ::FormatErrorMsg( pConnection, nSqlErrorCode, cSql, cMessage ) UNLESS lOk
        ::cMessage := cMessage
    ENDTRY
RETURN lOk

METHOD Insert( pConnection, cSql ) CLASS UtilsDao
    LOCAL lOk := .T., cMessage := ""
    LOCAL oError := NIL, nSqlErrorCode := 0
    TRY
        //cSql := hb_StrReplace( cSql, hRecord )
        nSqlErrorCode := sqlite3_exec( pConnection, cSql )
    CATCH oError
    FINALLY
        lOk := ::CheckIfErrors( lOk, nSqlErrorCode, oError )
        cMessage := "Operacao realizada com sucesso!" IF lOk
        cMessage := ::FormatErrorMsg( pConnection, nSqlErrorCode, cSql, cMessage ) UNLESS lOk
        ::cMessage := cMessage
    ENDTRY
RETURN lOk

METHOD Update( pConnection, cSql ) CLASS UtilsDao
    LOCAL lOk := .T., cMessage := ""
    LOCAL oError := NIL, nSqlErrorCode := 0
    TRY
        //cSql := hb_StrReplace( cSql, hRecord )
        nSqlErrorCode := sqlite3_exec( pConnection, cSql )
    CATCH oError
    FINALLY
        lOk := ::CheckIfErrors( lOk, nSqlErrorCode, oError )
        cMessage := "Operacao realizada com sucesso!" IF lOk
        cMessage := ::FormatErrorMsg( pConnection, nSqlErrorCode, cSql, cMessage ) UNLESS lOk
        ::cMessage := cMessage
    ENDTRY
RETURN lOk

METHOD FeedRecordSet( pRecords ) CLASS UtilsDao
    LOCAL ahRecordSet := {}, hRecordSet := { => }
    LOCAL nQtdCols := 0, nI := 0
    LOCAL nColType := 0, cColName := ""

    // hb_Alert("passo 0100")

    DO WHILE sqlite3_step( pRecords ) == SQLITE_ROW
        // hb_Alert("passo 0200")
        nQtdCols := sqlite3_column_count( pRecords )
        // hb_Alert("passo 0300")
        IF nQtdCols > 0
            // hb_Alert("passo 0400")
            hRecordSet := { => }
            FOR nI := 1 TO nQtdCols
                // hb_Alert("passo 0500")
                nColType := sqlite3_column_type( pRecords, nI )
                // hb_Alert("passo 0600 nColType:" + str(nColType))
                cColName := sqlite3_column_name( pRecords, nI )
                //IF !Empty(cColName)
                    // hb_Alert("passo 0700 " + cColName)
                    // hb_Alert(cColName) IF Empty(cColName)
                    hRecordSet[cColName] := sqlite3_column_int( pRecords, nI )      IF nColType == 1 // SQLITE_INTEGER
                    // hb_Alert("passo 0800")
                    //hRecordSet[nColName] := sqlite3_column_float( pRecords, nI )    IF nColType == 2 // SQLITE_FLOAT
                    hRecordSet[cColName] := sqlite3_column_text( pRecords, nI )     IF nColType == 3 // SQLITE_TEXT
                    // hb_Alert("passo 0900")
                    hRecordSet[cColName] := sqlite3_column_blob( pRecords, nI )     IF nColType == 4 // SQLITE_BLOB
                    // hb_Alert("passo 1000")
                    //hRecordSet[nColName] := sqlite3_column_null( pRecords, nI )     IF nColType == 5 // SQLITE_NULL
                //ENDIF
            NEXT
            // hb_Alert("passo 1100")
            AADD( ahRecordSet, hRecordSet )
            // hb_Alert("passo 1200")
       ENDIF
    ENDDO
    // hb_Alert("passo 1300")
RETURN ahRecordSet


METHOD FindBy( pConnection, cSql ) CLASS UtilsDao
    LOCAL lOk := .T., cMessage := ""
    LOCAL oError := NIL, nSqlErrorCode := 0
    LOCAL pRecords := NIL, hResultRecordSet := { => }
    TRY
        pRecords := sqlite3_prepare( pConnection, cSql )
        //sqlite3_step(pRecords)
        ::ahRecordSet := ::FeedRecordSet( pRecords ) 
        nSqlErrorCode := sqlite3_errcode( pConnection )
        sqlite3_clear_bindings(pRecords)
        sqlite3_finalize(pRecords)
    CATCH oError
    FINALLY
        // hb_Alert("passo 1400")
        pRecords := NIL
        // hb_Alert("passo 1500")
        lOk := ::CheckIfErrors( lOk, nSqlErrorCode, oError )
        // hb_Alert("passo 1600")
        cMessage := "Consulta realizada com sucesso!" IF lOk
        // hb_Alert("passo 1600")
        cMessage := ::FormatErrorMsg( pConnection, nSqlErrorCode, cSql, cMessage ) UNLESS lOk
        // hb_Alert("passo 1700")
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

METHOD CheckIfErrors(lOk, nSqlErrorCode, oError) CLASS UtilsDao
    LOCAL lOkResult := lOk .AND. nSqlErrorCode != SQLITE_ERROR .AND. oError == NIL
RETURN lOkResult

METHOD FormatErrorMsg( pConnection, nSqlErrorCode, cSql, cMessage ) CLASS UtilsDao
    LOCAL cMessageResult := cMessage
    cMessageResult := ;
        "Error: "   + LTrim(Str(nSqlErrorCode)) + ". " + ;
        "SQL: "     + sqlite3_errmsg(pConnection) + ". " + cSql IF Empty(cMessageResult)
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

