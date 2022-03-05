--delete one fk from one table
--select fk.name,fk.object_id,OBJECT_NAME(fk.parent_object_id) as referenceTableName
--from sys.foreign_keys as fk
--join sys.objects as o on fk.referenced_object_id=o.object_id
--where o.name='FamilyMember'
--ALTER TABLE dbo.SC DROP CONSTRAINT FK__FamilyMember__anothername__1B29035F


drop table NewBudget
drop table Debit
drop table Credit
drop table Repayment
drop table Loan
drop table Debt
drop table Budget
drop table Income
drop table Expenditure
drop table InternalTransfer
drop table TypeOfIncome
drop table TypeOfExpenditure
drop table PersonalFunds
drop table PaymentObject
drop table FormatOfFunds
drop table FamilyMember