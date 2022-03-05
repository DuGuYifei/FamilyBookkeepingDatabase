-------------------------------------------------------------------------------------------------------------------------------------------------
-- Yifei Liu
-- s188026
-- Group Thursday
-------------------------------------------------------------------------------------------------------------------------------------------------

-- 1. List Yifei's sum of each kind of expenditure in year 2021 which has budget 
--    and show whether they over budget(t or f)

SELECT ID_TE, type, bud, sum_ex, 
    CASE
        WHEN bud < sum_ex THEN 't'
        ELSE 'f'
    END AS OverBud
    FROM(
        Select TypeName as type, Sum(ExAmount) AS sum_ex
        FROM (
            Select TypeOfExpenditure.TypeName, Expenditure.ExAmount
                FROM Budget JOIN FamilyMember ON Budget.ID_FM = FamilyMember.ID_FM, TypeOfExpenditure, Expenditure, PersonalFunds
                WHERE 
                    FamilyMember.Name = 'Yifei' AND 
                    TypeOfExpenditure.ID_TE = Budget.ID_TE AND 
                    Expenditure.ID_TE = Budget.ID_TE AND 
                    Expenditure.E_Time >= '2021.1.1' AND
                    Expenditure.E_Time < '2022.1.1' AND
                    Expenditure.ID_PF = PersonalFunds.ID_PF AND
                    PersonalFunds.ID_FM = FamilyMember.ID_FM
        ) T
        GROUP BY TypeName
    ) A
    JOIN(
        SELECT Budget.ID_TE, TypeOfExpenditure.TypeName, CAST(Budget.BudAmount/Budget.Time_month * 12 as decimal(16, 2)) AS bud
            FROM Budget JOIN FamilyMember ON Budget.ID_FM = FamilyMember.ID_FM, TypeOfExpenditure
            WHERE 
                FamilyMember.Name = 'Yifei' AND 
                TypeOfExpenditure.ID_TE = Budget.ID_TE
    ) B
    ON A.type = B.TypeName;

-------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. Which kind of income is the biggest economic soursce of the family.
GO

CREATE VIEW ID_SumIN AS
    SELECT Income.ID_TI, Sum(Income.InAmount) as sum_in
        From Income
        GROUP BY Income.ID_TI

GO

SELECT TypeOfIncome.ID_TI, TypeOfIncome.TypeName, max_in.max_income
    FROM TypeOfIncome JOIN(
        SELECT ID_TI, sum_in as max_income
            FROM ID_SumIN
            WHERE sum_in IN(
                SELECT MAX(sum_in)
                    From ID_SumIN
        )
    ) max_in
        ON TypeOfIncome.ID_TI = max_in.ID_TI;


-------------------------------------------------------------------------------------------------------------------------------------------------

-- 3. Show rank (from top to low) of total income of each person in the family, and out put the relationship with admin
GO
CREATE VIEW FM_PF AS
    SELECT FamilyMember.ID_FM, FamilyMember.Name, PersonalFunds.ID_PF
        FROM FamilyMember, PersonalFunds
        WHERE FamilyMember.ID_FM = PersonalFunds.ID_FM
    WITH CHECK OPTION;
GO

SELECT T1.Name, FamilyMember.RelationWithAdmin, T1.sum_income
    FROM(
        SELECT FM_PF.Name, SUM(Income.InAmount) as sum_income
            FROM FM_PF, Income
            WHERE 
            FM_PF.ID_PF = Income.ID_PF
        GROUP BY FM_PF.Name
    ) T1
    JOIN FamilyMember ON FamilyMember.Name = T1.Name
    ORDER BY T1.sum_income DESC;

-------------------------------------------------------------------------------------------------------------------------------------------------

-- 4. Because the data are all inputed by hand at fisrt and didn't correct the value by function, 
--    please select out all wrong debt info in database. And show wrong and correct balance amount of debt.
--   (
--    Sum(Loan) - Sum(Repay) = Debt:
--    Debt table has the remain money need to repay, 
--    loan has the info that get the debt first day where the money went, 
--    repay has info every time repay debt
--   )
SELECT 
    CASE 
        WHEN id_d != 0 THEN id_d
        WHEN id_l != 0 THEN id_l
        ELSE TA.id_r
    END AS DebtID,
    sum_loan, sum_repay, remain
    FROM
        (SELECT *
            FROM
                (SELECT Loan.ID_Debt as id_l, SUM(Loan.LoanAmount) as sum_loan
                    FROM Loan
                    GROUP BY ID_Debt) T1
                FULL JOIN
                (SELECT Repayment.ID_Debt as id_r, SUM(Repayment.RepayAmount) as sum_repay
                    FROM Repayment
                    GROUP BY ID_Debt) T2
                ON T1.id_l = T2.id_r) TA
        FULL OUTER JOIN
        (SELECT Debt.ID_Debt as id_d, Debt.BalanceDue as remain
            FROM Debt) TB
        ON TA.id_l = TB.id_d
    WHERE
        sum_loan - sum_repay != remain;


-------------------------------------------------------------------------------------------------------------------------------------------------

-- 5. List all the expenditure of Yifei which not less than 200 except for accomodation and catering
SELECT Expenditure.ID_TE, TypeOfExpenditure.TypeName, Expenditure.E_Time, Expenditure.ExAmount
    FROM Expenditure, TypeOfExpenditure, FM_PF
    WHERE 
        Expenditure.ID_TE = TypeOfExpenditure.ID_TE AND
        Expenditure.ID_PF = FM_PF.ID_PF AND
        FM_PF.Name = 'Yifei' AND
        Expenditure.ExAmount >= 200 AND
        Expenditure.ID_TE IN(
            SELECT ID_TE
                FROM TypeOfExpenditure
                WHERE 
                    TypeOfExpenditure.TypeName != 'accomodation' AND
                    TypeOfExpenditure.TypeName != 'catering'
        )
    ORDER BY Expenditure.ID_TE;

-------------------------------------------------------------------------------------------------------------------------------------------------

-- 6. List the sum of expenditure and income of each person which has expenditure or income data.
SELECT 
    T1.sum_ex, 
    CASE
        WHEN T1.ex_name = NULL THEN T2.in_name
        ELSE T1.ex_name
    END AS OverBud, 
    T2.sum_in
    FROM
        (SELECT FM_PF.Name as ex_name, SUM(Expenditure.ExAmount) as sum_ex
            FROM FM_PF, Expenditure
            WHERE  
                FM_PF.ID_PF = Expenditure.ID_PF
            GROUP BY FM_PF.Name) T1 FULL OUTER JOIN
        (SELECT FM_PF.Name as in_name, SUM(Income.InAmount) as sum_in
            FROM FM_PF, Income
            WHERE  
                FM_PF.ID_PF = Income.ID_PF
            GROUP BY FM_PF.Name
        ) T2
            ON T1.ex_name = T2.in_name;

-------------------------------------------------------------------------------------------------------------------------------------------------

-- 7. List the sum of liability of each person has data in debt and credit.
--   (Liability = debt + credit:
--    debt means borrow money, credit means buy thing with credit)
GO
CREATE VIEW Liability AS
    SELECT FamilyMember.Name,T.liability
        FROM
            FamilyMember,
            (SELECT 
                CASE 
                    WHEN T1.ID_FM != 0 THEN T1.ID_FM 
                    ELSE T2.ID_FM 
                END AS ID_FM,
                (ISNULL(sum_debt,0) + ISNULL(sum_credit,0)) AS liability
                FROM
                (SELECT Debt.ID_FM, SUM(Debt.BalanceDue) as sum_debt
                    FROM Debt
                    GROUP BY Debt.ID_FM) T1
                FULL OUTER JOIN
                (SELECT Credit.ID_FM, SUM(Credit.BalanceDue) as sum_credit
                    FROM Credit
                    GROUP BY Credit.ID_FM) T2
                ON T1.ID_FM = T2.ID_FM)T
            WHERE FamilyMember.ID_FM = T.ID_FM;
GO

SELECT * FROM Liability;

-------------------------------------------------------------------------------------------------------------------------------------------------

-- 8. List sum of expenditure to each payment object, and rank them from top to low.
SELECT PaymentObject.ID_PO, PaymentObject.ObjectName, T1.sum_ex
    FROM PaymentObject JOIN(
        SELECT Expenditure.ID_PO ,Sum(Expenditure.ExAmount) as sum_ex
        FROM Expenditure
        GROUP BY Expenditure.ID_PO
    )T1 ON PaymentObject.ID_PO = T1.ID_PO
ORDER BY sum_ex DESC;

-------------------------------------------------------------------------------------------------------------------------------------------------

-- 9. Select top 3 field expenditure except for catering and accomodation.
SELECT TOP 3 *
    FROM (
    SELECT Expenditure.ID_TE, SUM(Expenditure.ExAmount) as sum_ex
        FROM Expenditure
        WHERE 
            Expenditure.ID_TE NOT IN(
                SELECT ID_TE
                    FROM TypeOfExpenditure
                    WHERE 
                        TypeOfExpenditure.TypeName = 'accomodation' AND
                        TypeOfExpenditure.TypeName = 'catering'
            )
        GROUP BY Expenditure.ID_TE
        --ORDER BY sum_ex
    ) T
    ORDER BY sum_ex DESC;

-------------------------------------------------------------------------------------------------------------------------------------------------

-- 10.List every Family member's asset(personal funds) and liability, 
--    and
--    show whether they have positive asset after subtracting liability(true or false)
GO
CREATE VIEW BalanceSheet AS
    SELECT 
        CASE
            WHEN Liability.name != NULL THEN Liability.Name
            ELSE TT.Name
        END AS Name,
        Liability.liability,
        TT.asset,
        (ISNULL(asset,0) - ISNULL(liability,0)) AS A_sub_L,
        CASE
            WHEN (ISNULL(asset,0) - ISNULL(liability,0)) > 0 Then 'True'
            ELSE 'FALSE'
        END AS is_positive
        FROM 
            Liability
            FULL OUTER JOIN
            (SELECT FamilyMember.Name, T.asset
                FROM FamilyMember,
                (SELECT PersonalFunds.ID_FM, SUM(PersonalFunds.Balance) as asset
                    FROM PersonalFunds
                    GROUP BY PersonalFunds.ID_FM) T
                WHERE FamilyMember.ID_FM = T.ID_FM) TT
            ON Liability.Name = TT.Name;
GO

SELECT * FROM BalanceSheet;

-------------------------------------------------------------------------------------------------------------------------------------------------