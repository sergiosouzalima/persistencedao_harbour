/*
    System.......: DAO
    Program......: persistence_class.prg
    Description..: Belongs to Model DAO to allow access to a datasource.
    Author.......: Sergio Lima
    Updated at...: Oct, 2021
*/


#include "hbclass.ch"
#require "hbsqlit3"
#include "custom_commands_v1.0.0.ch"

CREATE CLASS PersistenceDao INHERIT DatasourceDao
    EXPORTED:
        METHOD  New( cConnection ) CONSTRUCTOR
        METHOD  Destroy()
        METHOD  getConnection()
        METHOD  closeConnection()
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

        DATA cCreatedAt                 AS STRING   INIT ""
        METHOD CreatedAt( cCreatedAt ) SETGET

        DATA cUpdatedAt                 AS STRING   INIT ""
        METHOD UpdatedAt( cUpdatedAt ) SETGET

        DATA    nNumberOfRecords           AS INTEGER  INIT 0
        METHOD  NumberOfRecords( nNumberOfRecords ) SETGET

        METHOD  Found()
        METHOD  NotFound()
        METHOD  RecordSetLength()
        METHOD  FoundMany()
        // ----------------
    PROTECTED:
        DATA    pConnection    AS POINTER  INIT NIL
        METHOD  ExecuteCommand( cSql )
        METHOD  FindBy( hRecord, cSql )
        METHOD  InitStatusIndicators()

    HIDDEN:
        METHOD  FeedRecordSet( pRecords )

    ERROR HANDLER OnError( xParam )
ENDCLASS

METHOD New( cConnection ) CLASS PersistenceDao
    ::pConnection := ::Super:New( hb_defaultValue(cConnection, "datasource.s3db") ):getConnection()
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
METHOD RecordSetLength() CLASS PersistenceDao
RETURN Len(::RecordSet)

METHOD Found() CLASS PersistenceDao
RETURN ::RecordSetLength() > 0

METHOD FoundMany() CLASS PersistenceDao
RETURN ::RecordSetLength() > 1

METHOD NotFound() CLASS PersistenceDao
RETURN !::Found()

METHOD ChangedRecords(nChangedRecords) CLASS PersistenceDao
    ::nChangedRecords := nChangedRecords IF hb_IsNumeric(nChangedRecords)
RETURN ::nChangedRecords

METHOD RecordSet(ahRecordSet) CLASS PersistenceDao
    ::ahRecordSet := ahRecordSet IF hb_IsArray(ahRecordSet)
RETURN ::ahRecordSet

METHOD SqlErrorCode(nSqlErrorCode) CLASS PersistenceDao
    ::nSqlErrorCode := nSqlErrorCode IF hb_IsNumeric(nSqlErrorCode)
RETURN ::nSqlErrorCode

METHOD Error(oError) CLASS PersistenceDao
    ::oError := oError IF hb_IsObject(oError)
RETURN ::oError

METHOD InitStatusIndicators() CLASS PersistenceDao
    ::ChangedRecords := 0 ; ::RecordSet := {} ; ::SqlErrorCode := 0 ; ::Error := NIL
RETURN NIL

METHOD NumberOfRecords( nNumberOfRecords ) CLASS PersistenceDao
    ::nNumberOfRecords := nNumberOfRecords IF hb_IsNumeric(nNumberOfRecords)
RETURN ::nNumberOfRecords

METHOD CreatedAt( cCreatedAt ) CLASS PersistenceDao
    ::cCreatedAt := cCreatedAt IF hb_IsString(cCreatedAt)
RETURN ::cCreatedAt

METHOD UpdatedAt( cUpdatedAt ) CLASS PersistenceDao
    ::cUpdatedAt := cUpdatedAt IF hb_IsString(cUpdatedAt)
RETURN ::cUpdatedAt
//-------------------

METHOD ExecuteCommand( cSql ) CLASS PersistenceDao
    LOCAL oError := NIL
    TRY
        ::SqlErrorCode := sqlite3_exec( ::pConnection, cSql )
        ::ChangedRecords := sqlite3_total_changes( ::pConnection )
    CATCH oError
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

METHOD FindBy( hRecord, cSql ) CLASS PersistenceDao
    LOCAL oError := NIL, pRecords := NIL

    TRY
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

METHOD ONERROR( xParam ) CLASS PersistenceDao
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
