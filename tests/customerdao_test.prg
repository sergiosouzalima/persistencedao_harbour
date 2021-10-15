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

		oCustomerDao := CustomerDao():New()

		describe "CustomerDao Class"
			describe "When instantiate"
				describe "DatasourceDao():New( [cDataBaseName] ) --> oDataSource"
					context "and new method" expect(oCustomerDao) TO_BE_CLASS_NAME("CustomerDao")
				enddescribe
			enddescribe

			describe "oCustomerDao:CreateTable() -> lOk"
				context "When getting method result" expect (oCustomerDao:CreateTable()) TO_BE_TRUTHY
				context "When getting SqlErrorCode" expect (oCustomerDao:SqlErrorCode()) TO_BE_ZERO
				context "When getting ChangedRecords" expect (oCustomerDao:ChangedRecords()) TO_BE_ZERO
				context "When getting Error" expect (oCustomerDao:Error()) TO_BE_NIL
			enddescribe

			describe "oCustomerDao:Insert( hRecord ) -> lOk"

				describe "When invalid data to insert"
					hRecord := {}
					context "and getting method result" expect (oCustomerDao:Insert(hRecord)) TO_BE_FALSY
					context "When getting SqlErrorCode" expect (oCustomerDao:SqlErrorCode()) TO_BE(SQLITE_CONSTRAINT)
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

					context "and getting method result" expect (oCustomerDao:Insert(hRecord)) TO_BE_TRUTHY
					context "When getting SqlErrorCode" expect (oCustomerDao:SqlErrorCode()) TO_BE_ZERO
					context "When getting ChangedRecords" expect (oCustomerDao:ChangedRecords()) TO_BE_ONE
					context "When getting Error" expect (oCustomerDao:Error()) TO_BE_NIL
				enddescribe
			enddescribe

			describe "oCustomerDao:FindById( nId ) -> lOk"

				describe "When nId exists"
					context "and checking result" expect (oCustomerDao:FindById( 1 )) TO_BE_TRUTHY

					ahRecordSet := oCustomerDao:RecordSet() 
					ahRecordSet[01] := hb_HDel( ahRecordSet[01], "CREATED_AT")
					ahRecordSet[01] := hb_HDel( ahRecordSet[01], "UPDATED_AT")
					
					hResultRecord := { ;
						"ID"							=> 1, ;
						"CUSTOMER_NAME"                	=>  "PRIMEIRO CLIENTE", ;
						"BIRTH_DATE"                   	=>  "22/01/1980", ;
						"GENDER_ID"                    	=>  2, ;
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
				enddescribe

				describe "When nId does not exist"
					context "and checking result" expect (oCustomerDao:FindById( 999 )) TO_BE_FALSY
				enddescribe

			enddescribe

			describe "oCustomerDao:FindByCustomerName( cCustomerName ) -> lOk"

				describe "When cCustomerName exists"
					context "and checking result" expect (oCustomerDao:FindByCustomerName( "PRIMEIRO CLIENTE" )) TO_BE_TRUTHY

					ahRecordSet := oCustomerDao:RecordSet() 
					ahRecordSet[01] := hb_HDel( ahRecordSet[01], "CREATED_AT")
					ahRecordSet[01] := hb_HDel( ahRecordSet[01], "UPDATED_AT")
					
					hResultRecord := { ;
						"ID"							=> 1, ;
						"CUSTOMER_NAME"                	=>  "PRIMEIRO CLIENTE", ;
						"BIRTH_DATE"                   	=>  "22/01/1980", ;
						"GENDER_ID"                    	=>  2, ;
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
				enddescribe

				describe "When cCustomerName does not exist"
					context "and checking result" expect (oCustomerDao:FindByCustomerName( "XYZ" )) TO_BE_FALSY
				enddescribe

			enddescribe


			describe "oCustomerDao:Update( nId, hRecord ) -> lOk"

				describe "When invalid data to update"
					hRecord := {}
					context "and getting method result" expect (oCustomerDao:Update( 999, hRecord)) TO_BE_FALSY
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

					context "and getting method result" expect (oCustomerDao:Update( 1, hRecord )) TO_BE_TRUTHY
				enddescribe
			enddescribe

			describe "oCustomerDao:Delete( nId ) -> lOk"
				describe "When invalid data to delete"
					context "and getting method result" expect (oCustomerDao:Delete( 999 )) TO_BE_FALSY
				enddescribe

				describe "When valid data to delete"
					context "and getting method result" expect (oCustomerDao:Delete( 1 )) TO_BE_TRUTHY
				enddescribe
			enddescribe

		enddescribe

		oCustomerDao := oCustomerDao:Destroy()

	endhbexpect

RETURN NIL
