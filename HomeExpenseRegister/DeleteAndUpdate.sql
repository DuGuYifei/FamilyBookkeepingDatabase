/*
-- Cannot use because there is collision with FK, except for creating trigger instead of cascade
delete from FamilyMember where ID_FM = 1
update FamilyMember set ID_FM=15 where FamilyMember.Name = 'Yifei'
*/

-- Show the cascade delete situation it will also delete the info in debit
select * from debit where ID_EX = 12
delete from Expenditure where ID_EX = 12
select * from debit where ID_EX = 12

-- Will also delete in the loan and repayment
select * from loan where ID_Debt = 7
select * from repayment where ID_Debt = 7
delete from Debt where ID_Debt = 7
select * from loan where ID_Debt = 7
select * from repayment where ID_Debt = 7

-- Will also set null in expenditure
select * from Expenditure where ID_TE = 1
delete from PaymentObject where ID_PO = 13
select * from Expenditure where ID_TE = 1

select * from FamilyMember where ID_FM = 1
update FamilyMember set Name = 'Cat' where ID_FM = 1
select * from FamilyMember where ID_FM = 1