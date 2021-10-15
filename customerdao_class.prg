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

CREATE CLASS CustomerDao INHERIT DatasourceDao
    EXPORTED:
        METHOD  New( cConnection ) CONSTRUCTOR
        METHOD  Destroy()
        METHOD  getConnection() 
        METHOD  Destroy()
        METHOD  closeConnection()
        METHOD  CreateTable()
        METHOD  Insert( hRecord )
        METHOD  Update( hRecord )
        METHOD  Delete( nId )
        METHOD  FindById( nId )
        METHOD  FindByCustomerName( cCustomerName ) 
        METHOD  SqlErrorCode( nSqlErrorCode )       SETGET
        METHOD  ChangedRecords( nChangedRecords )   SETGET
        METHOD  Error( oError )                     SETGET
        METHOD  RecordSet(ahRecordSet)              SETGET
        DATA    nSqlErrorCode                       AS INTEGER  INIT 0
        DATA    nChangedRecords                     AS INTEGER  INIT 0
        DATA    ahRecordSet                         AS ARRAY    INIT {}

    PROTECTED:
        DATA    pConnection    AS POINTER  INIT NIL
        
    HIDDEN: 
        METHOD  FeedRecordSet( pRecords )
        METHOD  FindBy( hRecord, cSql )

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

METHOD SqlErrorCode(nSqlErrorCode) CLASS CustomerDao
    ::nSqlErrorCode := nSqlErrorCode IF hb_IsNumeric(nSqlErrorCode)
RETURN ::nSqlErrorCode

METHOD ChangedRecords(nChangedRecords) CLASS CustomerDao
    ::nChangedRecords := nChangedRecords IF hb_IsNumeric(nChangedRecords)
RETURN ::nChangedRecords

METHOD Error(oError) CLASS CustomerDao
    ::oError := oError IF hb_IsObject(oError) .OR. oError == NIL
RETURN ::oError

METHOD RecordSet(ahRecordSet) CLASS CustomerDao
    ::ahRecordSet := ahRecordSet IF hb_IsArray(ahRecordSet)
RETURN ::ahRecordSet

METHOD CreateTable() CLASS CustomerDao
    LOCAL oError := NIL
    TRY
        ::SqlErrorCode := sqlite3_exec( ::pConnection, SQL_CUSTOMER_CREATE_TABLE )
        ::ChangedRecords := sqlite3_total_changes( ::pConnection ) 
    CATCH oError
    ENDTRY
RETURN ::SqlErrorCode == 0 .AND. ::ChangedRecords == 0 .AND. oError == NIL

METHOD Insert( hRecord ) CLASS CustomerDao
    LOCAL oError := NIL

    TRY
        ::SqlErrorCode := sqlite3_exec( ::pConnection, hb_StrReplace( SQL_CUSTOMER_INSERT, hRecord ) )
        ::ChangedRecords := sqlite3_changes( ::pConnection )
    CATCH oError
    ENDTRY
RETURN ::SqlErrorCode == 0 .AND. ::ChangedRecords > 0 .AND. oError == NIL

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
    //hb_Alert("passo 05350 " + str(len(ahRecordSet)) )
RETURN ahRecordSet

METHOD FindBy( hRecord, cSql ) CLASS CustomerDao
    LOCAL oError := NIL, pRecords := NIL

    TRY
        ////hb_Alert("passo 05200")
        pRecords := sqlite3_prepare( ::pConnection, hb_StrReplace( cSql, hRecord ) )
        //hb_Alert("passo 05300 " + hb_StrReplace( cSql, hRecord ))
        ::RecordSet := ::FeedRecordSet( pRecords ) 
        //hb_Alert("passo 05360 " + str(len(::RecordSet)) )
        ////hb_Alert("passo 05400")
        ::SqlErrorCode := sqlite3_errcode( ::pConnection )
        ////hb_Alert("passo 05500")
        ::ChangedRecords := sqlite3_total_changes( ::pConnection )
        ////hb_Alert("passo 05600")
    CATCH oError
        ////hb_Alert("passo 05700")
    FINALLY
        ////hb_Alert("passo 05800")
        sqlite3_clear_bindings(pRecords)    UNLESS pRecords == NIL
        ////hb_Alert("passo 05900")
        sqlite3_finalize(pRecords)          UNLESS pRecords == NIL
    ENDTRY
    ////hb_Alert("passo 06000")
    //hb_Alert( "::SqlErrorCode  " + str(::SqlErrorCode)) 
    //hb_Alert( "::ChangedRecords" + str(::ChangedRecords)) 
    //hb_Alert( "::Len(::RecordSet) " + str(Len(::RecordSet)))
RETURN ::SqlErrorCode == SQLITE_DONE .AND. ::ChangedRecords == 0 .AND. oError == NIL .AND. Len(::RecordSet) > 0

METHOD FindById( nId ) CLASS CustomerDao
    LOCAL hRecord := { => }
    hRecord["#ID"] := Alltrim(Str(hb_defaultValue(nId, 0)))
    ////hb_Alert("passo 05000")
RETURN ::FindBy( hRecord, SQL_CUSTOMER_FIND_BY_ID )

METHOD FindByCustomerName( cCustomerName ) CLASS CustomerDao
    LOCAL hRecord := { => }
    hRecord["#CUSTOMER_NAME"] := hb_defaultValue(cCustomerName, "")
RETURN ::FindBy( hRecord, SQL_CUSTOMER_FIND_BY_CUSTOMER_NAME )

METHOD Delete( nId ) CLASS CustomerDao
    LOCAL oError := NIL, hRecord := { => }

    TRY
        hRecord["#ID"] := Alltrim(Str(hb_defaultValue(nId, 0)))
        ::SqlErrorCode := sqlite3_exec( ::pConnection, hb_StrReplace( SQL_CUSTOMER_DELETE, hRecord ) )
        ::ChangedRecords := sqlite3_changes( ::pConnection )
    CATCH oError
    ENDTRY
RETURN ::SqlErrorCode == 0 .AND. ::ChangedRecords == 1 .AND. ::Error == NIL

METHOD Update( nId, hRecord ) CLASS CustomerDao
    LOCAL oError := NIL

    TRY
        hRecord["#ID"] := Alltrim(Str(hb_defaultValue(nId, 0)))
        ::SqlErrorCode := sqlite3_exec( ::pConnection, hb_StrReplace( SQL_CUSTOMER_UPDATE, hRecord ) )
        ::ChangedRecords := sqlite3_changes( ::pConnection )
    CATCH oError
    ENDTRY
RETURN ::SqlErrorCode == 0 .AND. ::ChangedRecords == 1 .AND. oError == NIL

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