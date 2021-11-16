/*
    System.......: DAO
    Program......: persistence_class.prg
    Description..: Belongs to Model DAO to allow access to a datasource.
    Author.......: Sergio Lima
    Updated at...: Nov, 2021
*/


#include "hbclass.ch"
#require "hbsqlit3"
#include "custom_commands_v1.1.0.ch"

CREATE CLASS PersistenceDao INHERIT DatasourceDao, Params

    EXPORTED:
        METHOD  New( cConnection ) CONSTRUCTOR
        METHOD  Destroy()
        METHOD  getConnection()
        METHOD  closeConnection()
        METHOD  ChangedRecords( nChangedRecords )   SETGET
       // METHOD  RecordSet( ahRecordSet )            SETGET
        //METHOD  AuxRecordSet( ahAuxRecordSet )      SETGET
        METHOD  SqlErrorCode( nSqlErrorCode )       SETGET
        METHOD  Error( oError )                     SETGET
        METHOD  Id( cID )                           SETGET
        METHOD  CreatedAt( cCreatedAt )             SETGET
        METHOD  UpdatedAt( cUpdatedAt )             SETGET
        METHOD  Message( cMessage )                 SETGET
        METHOD  Valid( lValid )                     SETGET
        /*METHOD  Found()
        METHOD  NotFound()
        METHOD  RecordSetLength()
        METHOD  FoundMany()*/
        METHOD  Search( cSql, hRecord )
        // ----------------
    PROTECTED:
        DATA    pConnection         AS POINTER  INIT NIL
        METHOD  ExecuteCommand( cSql )
        //METHOD  FindBy( hRecord, cSql )
        METHOD  InitStatusIndicators()

    HIDDEN:
        DATA    nChangedRecords     AS INTEGER  INIT 0
        //DATA    ahRecordSet         AS ARRAY    INIT {}
        //DATA    ahAuxRecordSet      AS ARRAY    INIT {}
        DATA    nSqlErrorCode       AS INTEGER  INIT 0
        DATA    oError              AS OBJECT   INIT NIL
        DATA    cID                 AS STRING   INIT ""
        DATA    cCreatedAt          AS STRING   INIT ""
        DATA    cUpdatedAt          AS STRING   INIT ""
        DATA    cMessage            AS STRING   INIT ""
        DATA    lValid              AS LOGICAL  INIT .F.
        METHOD  FeedRecordSet( pRecords )

    ERROR HANDLER OnError( xParam )
ENDCLASS

METHOD New( cConnection ) CLASS PersistenceDao
    ::pConnection := ::Super:New( hb_defaultValue(cConnection, "database.s3db") ):getConnection()
RETURN Self

METHOD Destroy() CLASS PersistenceDao
    Self := NIL
RETURN Self

METHOD getConnection() CLASS PersistenceDao
RETURN ::pConnection

METHOD closeConnection() CLASS PersistenceDao
RETURN ::Destroy()
// ----------------

// Status indicators
/*METHOD RecordSetLength() CLASS PersistenceDao
RETURN Len(::RecordSet)

METHOD Found() CLASS PersistenceDao
RETURN ::RecordSetLength() > 0

METHOD FoundMany() CLASS PersistenceDao
RETURN ::RecordSetLength() > 1

METHOD NotFound() CLASS PersistenceDao
RETURN !::Found()*/

METHOD ChangedRecords(nChangedRecords) CLASS PersistenceDao
    ::nChangedRecords := nChangedRecords IF hb_IsNumeric(nChangedRecords)
RETURN ::nChangedRecords

/*METHOD RecordSet(ahRecordSet) CLASS PersistenceDao
    ::ahRecordSet := ahRecordSet IF hb_IsArray(ahRecordSet)
RETURN ::ahRecordSet*/

/*METHOD AuxRecordSet( ahAuxRecordSet ) CLASS PersistenceDao
    ::ahAuxRecordSet := ahAuxRecordSet IF hb_IsArray(ahAuxRecordSet)
RETURN ::ahAuxRecordSet*/

METHOD SqlErrorCode(nSqlErrorCode) CLASS PersistenceDao
    ::nSqlErrorCode := nSqlErrorCode IF hb_IsNumeric(nSqlErrorCode)
RETURN ::nSqlErrorCode

METHOD Error(oError) CLASS PersistenceDao
    ::oError := oError IF hb_IsObject(oError)
RETURN ::oError

METHOD InitStatusIndicators() CLASS PersistenceDao
    ::ChangedRecords := 0 ; ::RecordSet := {} ; ::SqlErrorCode := 0 ; ::Error := NIL ; ::Valid := .F.
RETURN NIL

METHOD Id( cID ) CLASS PersistenceDao
    ::cID := cID IF hb_IsString(cID)
RETURN ::cID

METHOD CreatedAt( cCreatedAt ) CLASS PersistenceDao
    ::cCreatedAt := cCreatedAt IF hb_IsString(cCreatedAt)
RETURN ::cCreatedAt

METHOD UpdatedAt( cUpdatedAt ) CLASS PersistenceDao
    ::cUpdatedAt := cUpdatedAt IF hb_IsString(cUpdatedAt)
RETURN ::cUpdatedAt

METHOD Message( cMessage ) CLASS PersistenceDao
    ::cMessage := cMessage IF hb_IsString(cMessage)
RETURN ::cMessage

METHOD Valid( lValid ) CLASS PersistenceDao
    ::lValid := lValid IF hb_isLogical(lValid)
RETURN ::lValid
//-------------------

METHOD ExecuteCommand( cSql ) CLASS PersistenceDao
    LOCAL oError := NIL
    TRY
        ::SqlErrorCode := sqlite3_exec( ::pConnection, cSql )
        Throw( ErrorNew() ) UNLESS ::SqlErrorCode == SQLITE_OK
        ::ChangedRecords := sqlite3_total_changes( ::pConnection )
    CATCH oError
        oError:Description := Error():New():getErrorDescription( cSql, ::SqlErrorCode )
        ::Error := oError
    ENDTRY
RETURN NIL

METHOD FeedRecordSet( pRecords ) CLASS PersistenceDao
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
                hRecordSet[cColName] := AllTrim(Str(sqlite3_column_int( pRecords, nI )))    IF nColType == 1 // SQLITE_INTEGER
                hRecordSet[cColName] := sqlite3_column_text( pRecords, nI )                 IF nColType == 3 // SQLITE_TEXT
                hRecordSet[cColName] := sqlite3_column_blob( pRecords, nI )                 IF nColType == 4 // SQLITE_BLOB
            NEXT
            AADD( ahRecordSet, hRecordSet )
        ENDIF
    ENDDO
RETURN ahRecordSet

/*METHOD FindBy( hRecord, cSql ) CLASS PersistenceDao
    LOCAL oError := NIL, pRecords := NIL

    TRY
        cSql := hb_StrReplace( cSql, hRecord )
        pRecords := sqlite3_prepare( ::pConnection, cSql )
        ::SqlErrorCode := sqlite3_errcode( ::pConnection )
        Throw( ErrorNew() ) UNLESS ::SqlErrorCode == SQLITE_OK
        ::RecordSet := ::FeedRecordSet( pRecords )
        ::ChangedRecords := sqlite3_total_changes( ::pConnection )
    CATCH oError
        oError:Description := Error():New():getErrorDescription( cSql, ::SqlErrorCode )
        ::Error := oError
    FINALLY
        sqlite3_clear_bindings(pRecords)    UNLESS pRecords == NIL
        sqlite3_finalize(pRecords)          UNLESS pRecords == NIL
    ENDTRY
RETURN NIL*/

METHOD Search( cSql, hParamRecord ) CLASS PersistenceDao
    LOCAL oError := NIL, pRecords := NIL, nSqlErrorCode := 0
    LOCAL oParams := Params():New()
    LOCAL hRecord := hb_defaultValue( hParamRecord, { => } )

    TRY
        cSql := hb_StrReplace( cSql, hRecord )
        pRecords := sqlite3_prepare( ::pConnection, cSql )
        nSqlErrorCode := sqlite3_errcode( ::pConnection )
        Throw( ErrorNew() ) UNLESS nSqlErrorCode == SQLITE_OK
        oParams:RecordSet := ::FeedRecordSet( pRecords )
        ::Params:New():RecordSet := ::FeedRecordSet( pRecords )
    CATCH oError
        oError:Description := Error():New():getErrorDescription( cSql, ::SqlErrorCode )
        ::Error := oError
    FINALLY
        sqlite3_clear_bindings(pRecords)    UNLESS pRecords == NIL
        sqlite3_finalize(pRecords)          UNLESS pRecords == NIL
    ENDTRY
RETURN oParams

METHOD ONERROR( xParam ) CLASS PersistenceDao
    LOCAL xResult := NIL
    xResult := Error():New():getOnErrorMessage( Self, xParam, __GetMessage() )
    ? "*** Error => ", xResult
RETURN xResult