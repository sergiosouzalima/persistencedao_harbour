/*
    System.......: DAO
    Program......: customerdao_class.prg
    Description..: Belongs to Model DAO to allow access to a datasource named Customer.
    Author.......: Sergio Lima
    Updated at...: Oct, 2021
*/


#include "hbclass.ch"
#require "hbsqlit3"
#include "custom_commands_v1.0.0.ch"

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

#define SQL_CUSTOMER_INSERT ;
    "INSERT INTO CUSTOMER(" +;
    " CUSTOMER_NAME, GENDER_ID, ADDRESS_DESCRIPTION," +;
    " COUNTRY_CODE_PHONE_NUMBER, AREA_PHONE_NUMBER, PHONE_NUMBER," +;
    " CUSTOMER_EMAIL, BIRTH_DATE, DOCUMENT_NUMBER," +;
    " ZIP_CODE_NUMBER, CITY_NAME, CITY_STATE_INITIALS) VALUES(" +;
    " '#CUSTOMER_NAME', #GENDER_ID, '#ADDRESS_DESCRIPTION'," +;
    " '#COUNTRY_CODE_PHONE_NUMBER', '#AREA_PHONE_NUMBER', '#PHONE_NUMBER'," +;
    " '#CUSTOMER_EMAIL', '#BIRTH_DATE', '#DOCUMENT_NUMBER'," +;
    " '#ZIP_CODE_NUMBER', '#CITY_NAME', '#CITY_STATE_INITIALS');"

#define SQL_CUSTOMER_UPDATE ;
    "UPDATE CUSTOMER SET" +;
    " CUSTOMER_NAME = '#CUSTOMER_NAME', ADDRESS_DESCRIPTION = '#ADDRESS_DESCRIPTION'," +;
    " GENDER_ID = #GENDER_ID," +;
    " COUNTRY_CODE_PHONE_NUMBER = '#COUNTRY_CODE_PHONE_NUMBER'," +;
    " AREA_PHONE_NUMBER = '#AREA_PHONE_NUMBER', PHONE_NUMBER = '#PHONE_NUMBER'," +;
    " CUSTOMER_EMAIL = '#CUSTOMER_EMAIL', BIRTH_DATE = '#BIRTH_DATE', DOCUMENT_NUMBER = '#DOCUMENT_NUMBER'," +;
    " ZIP_CODE_NUMBER = '#ZIP_CODE_NUMBER', CITY_NAME = '#CITY_NAME', CITY_STATE_INITIALS = '#CITY_STATE_INITIALS'," +;
    " UPDATED_AT = current_timestamp"+;
    " WHERE ID = #ID;"

#define SQL_CUSTOMER_DELETE ;
    "DELETE FROM CUSTOMER WHERE ID = #ID;"

#define SQL_CUSTOMER_FIND_BY_ID ;
    "SELECT" +;
    " ID," +;
    " CUSTOMER_NAME," +;
    " BIRTH_DATE," +;
    " GENDER_ID," +;
    " ADDRESS_DESCRIPTION," +;
    " COUNTRY_CODE_PHONE_NUMBER," +;
    " AREA_PHONE_NUMBER," +;
    " PHONE_NUMBER," +;
    " CUSTOMER_EMAIL," +;
    " DOCUMENT_NUMBER," +;
    " ZIP_CODE_NUMBER," +;
    " CITY_NAME," +;
    " CITY_STATE_INITIALS," +;
    " CREATED_AT," +;
    " UPDATED_AT" +;
    " FROM CUSTOMER" +;
    " WHERE ID = #ID;"

#define SQL_CUSTOMER_FIND_BY_CUSTOMER_NAME ;
    "SELECT" +;
    " ID," +;
    " CUSTOMER_NAME," +;
    " BIRTH_DATE," +;
    " GENDER_ID," +;
    " ADDRESS_DESCRIPTION," +;
    " COUNTRY_CODE_PHONE_NUMBER," +;
    " AREA_PHONE_NUMBER," +;
    " PHONE_NUMBER," +;
    " CUSTOMER_EMAIL," +;
    " DOCUMENT_NUMBER," +;
    " ZIP_CODE_NUMBER," +;
    " CITY_NAME," +;
    " CITY_STATE_INITIALS," +;
    " CREATED_AT," +;
    " UPDATED_AT" +;
    " FROM CUSTOMER" +;
    " WHERE CUSTOMER_NAME = '#CUSTOMER_NAME';"

#define SQL_CUSTOMER_AVOID_DUP ;
    "SELECT" +;
    " ID," +;
    " CUSTOMER_NAME," +;
    " BIRTH_DATE," +;
    " GENDER_ID," +;
    " ADDRESS_DESCRIPTION," +;
    " COUNTRY_CODE_PHONE_NUMBER," +;
    " AREA_PHONE_NUMBER," +;
    " PHONE_NUMBER," +;
    " CUSTOMER_EMAIL," +;
    " DOCUMENT_NUMBER," +;
    " ZIP_CODE_NUMBER," +;
    " CITY_NAME," +;
    " CITY_STATE_INITIALS," +;
    " CREATED_AT," +;
    " UPDATED_AT" +;
    " FROM CUSTOMER" +;
    " WHERE ID <> #ID AND CUSTOMER_NAME = '#CUSTOMER_NAME';"

CREATE CLASS CustomerDao INHERIT DatasourceDao
    EXPORTED:
        METHOD  New( cConnection ) CONSTRUCTOR
        METHOD  Destroy()
        METHOD  getConnection()
        METHOD  Destroy()
        METHOD  closeConnection()
        METHOD  CreateTable()
        METHOD  Insert( hRecord )
        METHOD  Update( nId, hRecord )
        METHOD  Delete( nId )
        METHOD  FindById( nId )
        METHOD  FindByCustomerName( cCustomerName )
        METHOD  FindCustomerAvoidDup( nId, cCustomerName )
        // ----------------
        // Status indicators
        METHOD  ChangedRecords( nChangedRecords )   SETGET
        DATA    nChangedRecords                     AS INTEGER  INIT 0
        METHOD  RecordSet( ahRecordSet )            SETGET
        DATA    ahRecordSet                         AS ARRAY    INIT {}
        METHOD  SqlErrorCode( nSqlErrorCode )       SETGET
        DATA    nSqlErrorCode                       AS INTEGER  INIT 0
        METHOD  Error( oError )                     SETGET
        DATA    oError                              AS OBJECT   INIT NIL
        METHOD  Found()
        METHOD  NotFound()
        METHOD  RecordSetLength()
        METHOD  FoundMany()
        // ----------------
    PROTECTED:
        DATA    pConnection    AS POINTER  INIT NIL

    HIDDEN:
        METHOD  FeedRecordSet( pRecords )
        METHOD  FindBy( hRecord, cSql )
        METHOD  InitStatusIndicators()

    ERROR HANDLER OnError( xParam )
ENDCLASS

METHOD New( cConnection ) CLASS CustomerDao
    ::pConnection := ::Super:New( hb_defaultValue(cConnection, "datasource.s3db") ):getConnection()
RETURN Self

METHOD Destroy() CLASS CustomerDao
    Self := NIL
RETURN Self

METHOD getConnection() CLASS CustomerDao
RETURN ::pConnection

METHOD closeConnection() CLASS CustomerDao
RETURN ::Destroy()
// ----------------

// Status indicators
METHOD RecordSetLength() CLASS CustomerDao
RETURN Len(::RecordSet)

METHOD Found() CLASS CustomerDao
RETURN ::RecordSetLength() > 0

METHOD FoundMany() CLASS CustomerDao
RETURN ::RecordSetLength() > 1

METHOD NotFound() CLASS CustomerDao
RETURN !::Found()

METHOD ChangedRecords(nChangedRecords) CLASS CustomerDao
    ::nChangedRecords := nChangedRecords IF hb_IsNumeric(nChangedRecords)
RETURN ::nChangedRecords

METHOD RecordSet(ahRecordSet) CLASS CustomerDao
    ::ahRecordSet := ahRecordSet IF hb_IsArray(ahRecordSet)
RETURN ::ahRecordSet

METHOD SqlErrorCode(nSqlErrorCode) CLASS CustomerDao
    ::nSqlErrorCode := nSqlErrorCode IF hb_IsNumeric(nSqlErrorCode)
RETURN ::nSqlErrorCode

METHOD Error(oError) CLASS CustomerDao
    ::oError := oError IF hb_IsObject(oError)
RETURN ::oError

METHOD InitStatusIndicators() CLASS CustomerDao
    ::ChangedRecords := 0 ; ::RecordSet := {} ; ::SqlErrorCode := 0 ; ::Error := NIL
RETURN NIL
//-------------------

METHOD CreateTable() CLASS CustomerDao
    LOCAL oError := NIL
    TRY
        ::InitStatusIndicators()
        ::SqlErrorCode := sqlite3_exec( ::pConnection, SQL_CUSTOMER_CREATE_TABLE )
        ::ChangedRecords := sqlite3_total_changes( ::pConnection )
    CATCH oError
        ::Error := oError
    ENDTRY
RETURN NIL

METHOD Insert( hRecord ) CLASS CustomerDao
    LOCAL oError := NIL
    TRY
        ::InitStatusIndicators()
        ::SqlErrorCode := sqlite3_exec( ::pConnection, hb_StrReplace( SQL_CUSTOMER_INSERT, hRecord ) )
        ::ChangedRecords := sqlite3_changes( ::pConnection )
    CATCH oError
        ::Error := oError
    ENDTRY
RETURN NIL

METHOD FeedRecordSet( pRecords ) CLASS CustomerDao
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

METHOD FindBy( hRecord, cSql ) CLASS CustomerDao
    LOCAL oError := NIL, pRecords := NIL

    TRY
        ::InitStatusIndicators()
        pRecords := sqlite3_prepare( ::pConnection, hb_StrReplace( cSql, hRecord ) )
        ::RecordSet := ::FeedRecordSet( pRecords )
        ::SqlErrorCode := sqlite3_errcode( ::pConnection )
        ::ChangedRecords := sqlite3_total_changes( ::pConnection )
    CATCH oError
        ::Error := oError
    FINALLY
        sqlite3_clear_bindings(pRecords)    UNLESS pRecords == NIL
        sqlite3_finalize(pRecords)          UNLESS pRecords == NIL
    ENDTRY
RETURN NIL

METHOD FindById( nId ) CLASS CustomerDao
    LOCAL hRecord := { => }
    ::InitStatusIndicators()
    hRecord["#ID"] := Alltrim(Str(hb_defaultValue(nId, 0)))
    ::FindBy( hRecord, SQL_CUSTOMER_FIND_BY_ID )
RETURN NIL

METHOD FindByCustomerName( cCustomerName ) CLASS CustomerDao
    LOCAL hRecord := { => }
    ::InitStatusIndicators()
    hRecord["#CUSTOMER_NAME"] := hb_defaultValue(cCustomerName, "")
    ::FindBy( hRecord, SQL_CUSTOMER_FIND_BY_CUSTOMER_NAME )
RETURN NIL

METHOD FindCustomerAvoidDup( nId, cCustomerName ) CLASS CustomerDao
    LOCAL hRecord := { => }
    ::InitStatusIndicators()
    hRecord["#ID"] := AllTrim(Str(hb_defaultValue(nId, 0)))
    hRecord["#CUSTOMER_NAME"] := hb_defaultValue(cCustomerName, "")
    ::FindBy( hRecord, SQL_CUSTOMER_AVOID_DUP )
RETURN NIL

METHOD Delete( nId ) CLASS CustomerDao
    LOCAL oError := NIL, hRecord := { => }

    TRY
        ::InitStatusIndicators()
        hRecord["#ID"] := Alltrim(Str(hb_defaultValue(nId, 0)))
        ::SqlErrorCode := sqlite3_exec( ::pConnection, hb_StrReplace( SQL_CUSTOMER_DELETE, hRecord ) )
        ::ChangedRecords := sqlite3_changes( ::pConnection )
    CATCH oError
        ::Error := oError
    ENDTRY
RETURN NIL

METHOD Update( nId, hRecord ) CLASS CustomerDao
    LOCAL oError := NIL

    TRY
        ::InitStatusIndicators()
        hRecord["#ID"] := Alltrim(Str(hb_defaultValue(nId, 0)))
        ::SqlErrorCode := sqlite3_exec( ::pConnection, hb_StrReplace( SQL_CUSTOMER_UPDATE, hRecord ) )
        ::ChangedRecords := sqlite3_changes( ::pConnection )
    CATCH oError
        ::Error := oError
    ENDTRY
RETURN NIL

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