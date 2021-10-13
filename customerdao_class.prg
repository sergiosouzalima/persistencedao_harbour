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

CREATE CLASS CustomerDao INHERIT DatasourceDao
    EXPORTED:
        METHOD New() CONSTRUCTOR
        METHOD Destroy()
        METHOD CreateTable()
        METHOD Insert( hRecord )
        METHOD Update( hRecord )
        METHOD FindById( nId ) 
        METHOD GetMessage()
        METHOD GetRecordSet()

    PROTECTED:
        DATA pConnection    AS POINTER  INIT NIL
        
    HIDDEN: 
        DATA cMessage       AS STRING   INIT ""
        DATA ahRecordSet    AS ARRAY    INIT {}

    ERROR HANDLER OnError( xParam )
ENDCLASS

METHOD New() CLASS CustomerDao
    ::pConnection := ::Super:New():getConnection()
RETURN Self

METHOD Destroy() CLASS CustomerDao
    Self := NIL
RETURN Self

METHOD CreateTable() CLASS CustomerDao
    LOCAL oUtils := UtilsDao():New()
    LOCAL lOk := oUtils:CreateTable( ::pConnection, SQL_CUSTOMER_CREATE_TABLE )
    ::cMessage := oUtils:GetMessage()
    oUtils := UtilsDao():Destroy()
RETURN lOk

METHOD Insert( hRecord ) CLASS CustomerDao
    LOCAL oUtils := UtilsDao():New()
    LOCAL lOk :=.F., cSql := SQL_CUSTOMER_INSERT

    cSql := hb_StrReplace( cSql, hRecord )
    lOk := oUtils:Insert( ::pConnection, cSql )
    ::cMessage := oUtils:GetMessage()
    oUtils := UtilsDao():Destroy()
RETURN lOk

METHOD Update( nId, hRecord ) CLASS CustomerDao
    LOCAL oUtils := UtilsDao():New()
    LOCAL lOk :=.F., cSql := SQL_CUSTOMER_UPDATE
    LOCAL hUpdateRecord := hRecord

    hUpdateRecord["#ID"] := Alltrim(Str(nId))
    cSql := hb_StrReplace( cSql, hUpdateRecord )
    lOk := oUtils:Update( ::pConnection, cSql )
    ::cMessage := oUtils:GetMessage()
    oUtils := UtilsDao():Destroy()
RETURN lOk

METHOD FindById( nId ) CLASS CustomerDao
    LOCAL oUtils := UtilsDao():New()
    LOCAL lOk :=.F., cSql := SQL_CUSTOMER_FIND_BY_ID
    LOCAL hFindRecord := { => }
    
    hFindRecord["#ID"] := Alltrim(Str(nId))
    cSql := hb_StrReplace( cSql, hFindRecord )
    lOk := oUtils:FindBy( ::pConnection, cSql )
    ::cMessage := oUtils:GetMessage()
    ::ahRecordSet := oUtils:GetRecordSet()
    oUtils := UtilsDao():Destroy()
RETURN lOk

METHOD GetMessage() CLASS CustomerDao
RETURN ::cMessage

METHOD GetRecordSet() CLASS CustomerDao
RETURN ::ahRecordSet

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

