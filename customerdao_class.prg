/*
    System.......: DAO
    Program......: customerdao_class.prg
    Description..: Belongs to Model DAO to allow access to a datasource named Customer.
    Author.......: Sergio Lima
    Updated at...: Oct, 2021
*/


#include "hbclass.ch"
#require "hbsqlit3"
#include "custom_commands.ch"

#define SQL_CUSTOMER_CREATE_TABLE ;
    "CREATE TABLE IF NOT EXISTS CUSTOMER(" + ;
    " ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT," +;
    " CUSTOMER_NAME VARCHAR2(40) NOT NULL," +;
    " BIRTH_DATE CHAR(10) NOT NULL," +;
    " GENDER_ID INTEGER NOT NULL," +;
    " ADDRESS_DESCRIPTION VARCHAR2(40)," +;
    " COUNTRY_CODE_PHONE_NUMBER CHAR(02)," +;
    " AREA_PHONE_NUMBER CHAR(03)," +;
    " PHONE_NUMBER VARCHAR2(10)," +;
    " CUSTOMER_EMAIL VARCHAR2(40)," +;
    " DOCUMENT_NUMBER VARCHAR2(20)," +;
    " ZIP_CODE_NUMBER CHAR(09)," +;
    " CITY_NAME VARCHAR2(20)," +; 
    " CITY_STATE_INITIALS CHAR(02)," +;
    " CREATED_AT datetime default current_timestamp," +;
    " UPDATED_AT datetime default current_timestamp);" //," +;      
    //" FOREIGN KEY(GENDER_ID) REFERENCES GENDER(ID) ON UPDATE RESTRICT ON DELETE RESTRICT);"


CREATE CLASS CustomerDao INHERIT DatasourceDao
    EXPORTED:
        METHOD New() CONSTRUCTOR
        METHOD Destroy()
        METHOD CreateTable()
        METHOD GetMessage()

    PROTECTED:
        DATA pConnection    AS POINTER  INIT NIL
        
    HIDDEN: 
        DATA cMessage       AS STRING   INIT ""
        METHOD FormatErrorMsg( pDataBase, nSqlErrorCode, cSql )
        METHOD CheckIfErrors(lOk, nSqlErrorCode, oError) 
        METHOD AdjustDate(dDate)

    ERROR HANDLER OnError( xParam )
ENDCLASS

METHOD New() CLASS CustomerDao
    ::pConnection := ::Super:New():getConnection()
RETURN Self

METHOD Destroy() CLASS CustomerDao
    Self := NIL
RETURN Self

METHOD CreateTable() CLASS CustomerDao
    LOCAL lOk := .T., cMessage := ""
    LOCAL oError := NIL, nSqlErrorCode := 0, cSql := SQL_CUSTOMER_CREATE_TABLE
    TRY
        nSqlErrorCode := sqlite3_exec(::pConnection, cSql)
    CATCH oError
    FINALLY
        lOk := ::CheckIfErrors( lOk, nSqlErrorCode, oError )
        cMessage := "Operacao realizada com sucesso!" IF lOk
        cMessage := ::FormatErrorMsg( ::pConnection, nSqlErrorCode, cSql, cMessage ) UNLESS lOk
        ::cMessage := cMessage
    ENDTRY
RETURN lOk

METHOD GetMessage() CLASS CustomerDao
RETURN ::cMessage

METHOD AdjustDate(dDate) CLASS CustomerDao
    LOCAL cDate := DToS(dDate)    
RETURN  SubStr(cDate,7,2) + "/" + SubStr(cDate,5,2) + "/" + SubStr(cDate,1,4)

METHOD CheckIfErrors(lOk, nSqlErrorCode, oError) CLASS CustomerDao
    LOCAL lOkResult := lOk .AND. nSqlErrorCode != SQLITE_ERROR .AND. oError == NIL
RETURN lOkResult

METHOD FormatErrorMsg( pConnection, nSqlErrorCode, cSql, cMessage ) CLASS CustomerDao
    LOCAL cMessageResult := cMessage
    cMessageResult := ;
        "Error: "   + LTrim(Str(nSqlErrorCode)) + ". " + ;
        "SQL: "     + sqlite3_errmsg(pConnection) + ". " + cSql IF Empty(cMessageResult)
RETURN cMessageResult

METHOD ONERROR( xParam ) CLASS CustomerDao
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

