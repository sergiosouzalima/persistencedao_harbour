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
		LOCAL oDatasourceDao, oCustomerDao

		hb_vfErase("datasource.s3db")

		oCustomerDao := CustomerDao():New()

		describe "CustomerDao Class"
			describe "When instantiate"
				describe "DatasourceDao():New( [cDataBaseName] ) --> oDataSource"
					context "and new method" expect(oCustomerDao) TO_BE_CLASS_NAME("CustomerDao")
				enddescribe
			enddescribe

			describe "oCustomerDao:CreateTable() -> Boolean"
				context "When getting method result" expect (oCustomerDao:CreateTable()) TO_BE_TRUTHY
				context "When getting operation message" expect (oCustomerDao:GetMessage()) TO_BE("Operacao realizada com sucesso!")
			enddescribe

		enddescribe
	endtests

RETURN NIL
