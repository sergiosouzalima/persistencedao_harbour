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
        DATA pRecordSet     AS POINTER  INIT NIL
        METHOD FormatErrorMsg( pDataBase, nSqlErrorCode, cSql )
        METHOD CheckIfErrors(lOk, nSqlErrorCode, oError) 
        METHOD AdjustDate(dDate)

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

METHOD FindBy( pConnection, cSql ) CLASS UtilsDao
    LOCAL lOk := .T., cMessage := ""
    LOCAL oError := NIL, nSqlErrorCode := 0
    LOCAL pRecord := NIL
    
    TRY
        //cSql := hb_StrReplace( cSql, hRecord)
        pRecord := sqlite3_prepare( pConnection, cSql )
        sqlite3_step(pRecord)
        nSqlErrorCode := sqlite3_errcode( pConnection )
        ::pRecordSet := pRecord
        sqlite3_clear_bindings(pRecord)
        sqlite3_finalize(pRecord)
    CATCH oError
    FINALLY
        pRecord := NIL
        lOk := ::CheckIfErrors( lOk, nSqlErrorCode, oError )
        cMessage := "Consulta realizada com sucesso!" IF lOk
        cMessage := ::FormatErrorMsg( pConnection, nSqlErrorCode, cSql, cMessage ) UNLESS lOk
        ::cMessage := cMessage
    ENDTRY
RETURN lOk

METHOD GetMessage() CLASS UtilsDao
RETURN ::cMessage

METHOD GetRecordSet() CLASS UtilsDao
RETURN ::pRecordSet

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

