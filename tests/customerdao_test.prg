/*
    System.......: DAO
    Program......: customerdao_class.prg
    Description..: Belongs to Model DaoCustomer to allow access to a datasource named Customer.
    Author.......: Sergio Lima
    Updated at...: Oct, 2021

	How to compile:
	hbmk2 customerdao_test.hbp

	How to run:
	./customerdao_test

*/

#include "hbclass.ch"
#require "hbsqlit3"
#include "../../hbexpect/lib/hbexpect.ch"

FUNCTION Main()

	begin hbexpect
		LOCAL oCustomerDao, hRecord, ahRecordSet, hResultRecord

		hb_vfErase("datasource.s3db")

		describe "CustomerDao Class"
			oCustomerDao := CustomerDao():New()
			describe "When instantiate"
				describe "CustomerDao():New( [cDataBaseName] ) --> oDataSource"
					context "and new method" expect(oCustomerDao) TO_BE_CLASS_NAME("CustomerDao")
				enddescribe
			enddescribe

			describe "oCustomerDao:CreateTable()"
				oCustomerDao:CreateTable()
				context "When getting SqlErrorCode" expect (oCustomerDao:SqlErrorCode()) TO_BE_ZERO
				context "When getting ChangedRecords" expect (oCustomerDao:ChangedRecords()) TO_BE_ZERO
				context "When getting Error" expect (oCustomerDao:Error()) TO_BE_NIL
			enddescribe

			describe "oCustomerDao:Insert( hRecord )"

				describe "When invalid data to insert"
					hRecord := {}
					oCustomerDao:Insert(hRecord)
					context "When getting SqlErrorCode" expect (oCustomerDao:SqlErrorCode()) TO_BE_ZERO
					context "When getting ChangedRecords" expect (oCustomerDao:ChangedRecords()) TO_BE_ZERO
					context "When getting Error" expect (oCustomerDao:Error()) TO_BE_NIL
				enddescribe

				describe "When valid data to insert"
					hRecord := { ;
							"#CUSTOMER_NAME"                =>  "PRIMEIRO CLIENTE", ;
							"#BIRTH_DATE"                   =>  "22/01/1980", ;
							"#GENDER_ID"                    =>  "2", ;
							"#ADDRESS_DESCRIPTION"          =>  "5th AV, 505", ;
							"#COUNTRY_CODE_PHONE_NUMBER"    =>  "55", ;
							"#AREA_PHONE_NUMBER"            =>  "11", ;
							"#PHONE_NUMBER"                 =>  "555-55555", ;
							"#CUSTOMER_EMAIL"               =>  "nome-cliente@mail.com", ;
							"#DOCUMENT_NUMBER"              =>  "99876999-99", ;
							"#ZIP_CODE_NUMBER"              =>  "04041-999", ;
							"#CITY_NAME"                    =>  "Sao Paulo", ;
							"#CITY_STATE_INITIALS"          =>  "SP";
						}

					oCustomerDao:Insert(hRecord)
					context "When getting SqlErrorCode" expect (oCustomerDao:SqlErrorCode()) TO_BE_ZERO
					context "When getting ChangedRecords" expect (oCustomerDao:ChangedRecords()) TO_BE_ONE
					context "When getting Error" expect (oCustomerDao:Error()) TO_BE_NIL
				enddescribe
			enddescribe
			oCustomerDao := oCustomerDao:Destroy()

			oCustomerDao := CustomerDao():New()
			describe "oCustomerDao:FindById( nId )"

				describe "When nId exists"
					oCustomerDao:FindById( 1 )

					ahRecordSet := oCustomerDao:RecordSet()
					ahRecordSet[01] := hb_HDel( ahRecordSet[01], "CREATED_AT")
					ahRecordSet[01] := hb_HDel( ahRecordSet[01], "UPDATED_AT")

					hResultRecord := { ;
						"ID"							=> "1", ;
						"CUSTOMER_NAME"                	=>  "PRIMEIRO CLIENTE", ;
						"BIRTH_DATE"                   	=>  "22/01/1980", ;
						"GENDER_ID"                    	=>  "2", ;
						"ADDRESS_DESCRIPTION"          	=>  "5th AV, 505", ;
						"COUNTRY_CODE_PHONE_NUMBER"    	=>  "55", ;
						"AREA_PHONE_NUMBER"            	=>  "11", ;
						"PHONE_NUMBER"                 	=>  "555-55555", ;
						"CUSTOMER_EMAIL"               	=>  "nome-cliente@mail.com", ;
						"DOCUMENT_NUMBER"              	=>  "99876999-99", ;
						"ZIP_CODE_NUMBER"              	=>  "04041-999", ;
						"CITY_NAME"                    	=>  "Sao Paulo", ;
						"CITY_STATE_INITIALS"          	=>  "SP";
					}
					context "and getting method RecordSet()" expect (ahRecordSet[01]) TO_BE(hResultRecord)
					// SQLITE_DONE  101 /* sqlite3_step() has finished executing */
					context "When getting SqlErrorCode" expect (oCustomerDao:SqlErrorCode()) TO_BE(101)
					context "When getting ChangedRecords" expect (oCustomerDao:ChangedRecords()) TO_BE_ZERO
					context "When getting Error" expect (oCustomerDao:Error()) TO_BE_NIL
				enddescribe

				describe "When nId does not exist"
					oCustomerDao:FindById( 999 )
					// SQLITE_DONE  101 /* sqlite3_step() has finished executing */
					context "When getting SqlErrorCode" expect (oCustomerDao:SqlErrorCode()) TO_BE(101)
					context "When getting ChangedRecords" expect (oCustomerDao:ChangedRecords()) TO_BE_ZERO
					context "When getting Error" expect (oCustomerDao:Error()) TO_BE_NIL
					context "When getting RecordSet" expect (oCustomerDao:RecordSet()) TO_BE({})
				enddescribe

			enddescribe
			oCustomerDao := oCustomerDao:Destroy()

			oCustomerDao := CustomerDao():New()
			describe "oCustomerDao:FindByCustomerName( cCustomerName )"

				describe "When cCustomerName exists"
					oCustomerDao:FindByCustomerName( "PRIMEIRO CLIENTE" )

					ahRecordSet := oCustomerDao:RecordSet()
					ahRecordSet[01] := hb_HDel( ahRecordSet[01], "CREATED_AT")
					ahRecordSet[01] := hb_HDel( ahRecordSet[01], "UPDATED_AT")

					hResultRecord := { ;
						"ID"							=> "1", ;
						"CUSTOMER_NAME"                	=>  "PRIMEIRO CLIENTE", ;
						"BIRTH_DATE"                   	=>  "22/01/1980", ;
						"GENDER_ID"                    	=>  "2", ;
						"ADDRESS_DESCRIPTION"          	=>  "5th AV, 505", ;
						"COUNTRY_CODE_PHONE_NUMBER"    	=>  "55", ;
						"AREA_PHONE_NUMBER"            	=>  "11", ;
						"PHONE_NUMBER"                 	=>  "555-55555", ;
						"CUSTOMER_EMAIL"               	=>  "nome-cliente@mail.com", ;
						"DOCUMENT_NUMBER"              	=>  "99876999-99", ;
						"ZIP_CODE_NUMBER"              	=>  "04041-999", ;
						"CITY_NAME"                    	=>  "Sao Paulo", ;
						"CITY_STATE_INITIALS"          	=>  "SP";
					}
					context "and getting method RecordSet()" expect (ahRecordSet[01]) TO_BE(hResultRecord)
					// SQLITE_DONE  101 /* sqlite3_step() has finished executing */
					context "When getting SqlErrorCode" expect (oCustomerDao:SqlErrorCode()) TO_BE(101)
					context "When getting ChangedRecords" expect (oCustomerDao:ChangedRecords()) TO_BE_ZERO
					context "When getting Error" expect (oCustomerDao:Error()) TO_BE_NIL
				enddescribe

				describe "When cCustomerName does not exist"
					oCustomerDao:FindByCustomerName( "XYZ" )
					// SQLITE_DONE  101 /* sqlite3_step() has finished executing */
					context "When getting SqlErrorCode" expect (oCustomerDao:SqlErrorCode()) TO_BE(101)
					context "When getting ChangedRecords" expect (oCustomerDao:ChangedRecords()) TO_BE_ZERO
					context "When getting Error" expect (oCustomerDao:Error()) TO_BE_NIL
					context "When getting RecordSet" expect (oCustomerDao:RecordSet()) TO_BE({})
				enddescribe

			enddescribe
			oCustomerDao := oCustomerDao:Destroy()

			oCustomerDao := CustomerDao():New()
			describe "oCustomerDao:Update( nId, hRecord )"

				describe "When invalid data to update"
					hRecord := {}
					oCustomerDao:Update( 999, hRecord)
				enddescribe

				describe "When valid data to update"
					hRecord := { ;
							"#CUSTOMER_NAME"                =>  "PRIMEIRO CLIENTE ALTERADO", ;
							"#BIRTH_DATE"                   =>  "22/01/1980", ;
							"#GENDER_ID"                    =>  "2", ;
							"#ADDRESS_DESCRIPTION"          =>  "5th AV, 505", ;
							"#COUNTRY_CODE_PHONE_NUMBER"    =>  "55", ;
							"#AREA_PHONE_NUMBER"            =>  "11", ;
							"#PHONE_NUMBER"                 =>  "555-55555", ;
							"#CUSTOMER_EMAIL"               =>  "nome-cliente@mail.com", ;
							"#DOCUMENT_NUMBER"              =>  "99876999-99", ;
							"#ZIP_CODE_NUMBER"              =>  "04041-999", ;
							"#CITY_NAME"                    =>  "Sao Paulo", ;
							"#CITY_STATE_INITIALS"          =>  "SP";
						}

					oCustomerDao:Update( 1, hRecord )
					context "When getting SqlErrorCode" expect (oCustomerDao:SqlErrorCode()) TO_BE_ZERO
					context "When getting ChangedRecords" expect (oCustomerDao:ChangedRecords()) TO_BE_ONE
					context "When getting Error" expect (oCustomerDao:Error()) TO_BE_NIL
				enddescribe
			enddescribe
			oCustomerDao := oCustomerDao:Destroy()

			oCustomerDao := CustomerDao():New()
			describe "oCustomerDao:Delete( nId ) -> lOk"
				describe "When invalid data to delete"
					oCustomerDao:Delete( 999 )
					context "When getting SqlErrorCode" expect (oCustomerDao:SqlErrorCode()) TO_BE_ZERO
					context "When getting ChangedRecords" expect (oCustomerDao:ChangedRecords()) TO_BE_ZERO
					context "When getting Error" expect (oCustomerDao:Error()) TO_BE_NIL
				enddescribe

				describe "When valid data to delete"
					oCustomerDao:Delete( 1 )
					context "When getting SqlErrorCode" expect (oCustomerDao:SqlErrorCode()) TO_BE_ZERO
					context "When getting ChangedRecords" expect (oCustomerDao:ChangedRecords()) TO_BE_ONE
					context "When getting Error" expect (oCustomerDao:Error()) TO_BE_NIL
				enddescribe
			enddescribe
			oCustomerDao := oCustomerDao:Destroy()

		enddescribe

	endhbexpect

RETURN NIL
