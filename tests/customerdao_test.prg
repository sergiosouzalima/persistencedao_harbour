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

	begin tests
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
				context "and GetRecordSet()" expect (oCustomerDao:GetMessage()) TO_BE("Operacao realizada com sucesso!")
			enddescribe

			describe "oCustomerDao:Insert( hRecord ) -> lOk"

				describe "When invalid data to insert"
					hRecord := {}
					context "and getting method result" expect (oCustomerDao:Insert(hRecord)) TO_BE_FALSY
					context "and GetRecordSet()" expect (oCustomerDao:GetMessage()) TO_BE("Nenhum registro inserido!")
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
					context "and GetRecordSet()" expect (oCustomerDao:GetMessage()) TO_BE("Operacao realizada com sucesso!")
				enddescribe
			enddescribe

			describe "oCustomerDao:FindById( nId ) -> lOk"

				describe "When nId exists"
					context "and checking result" expect (oCustomerDao:FindById( 1 )) TO_BE_TRUTHY
					context "and GetRecordSet()" expect (oCustomerDao:GetMessage()) TO_BE("Consulta realizada com sucesso!")

					ahRecordSet := oCustomerDao:GetRecordSet() 
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
					context "and getting this method GetRecordSet()" expect (ahRecordSet[01]) TO_BE(hResultRecord)
				enddescribe

				describe "When nId does not exist"
					context "and checking result" expect (oCustomerDao:FindById( 999 )) TO_BE_FALSY
					context "and GetRecordSet()" expect (oCustomerDao:GetMessage()) TO_BE("Nenhum registro encontrado")
				enddescribe			
			enddescribe

		enddescribe
	endtests

RETURN NIL
