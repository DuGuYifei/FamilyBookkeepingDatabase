CREATE VIEW FM_PF AS
    SELECT FamilyMember.ID_FM, FamilyMember.Name, PersonalFunds.ID_PF
        FROM FamilyMember, PersonalFunds
        WHERE FamilyMember.ID_FM = PersonalFunds.ID_FM
    WITH CHECK OPTION;
GO

Select * FROM FM_PF;