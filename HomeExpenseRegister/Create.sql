CREATE TABLE FamilyMember(
    ID_FM				INT			NOT NULL	IDENTITY(1,1),
    Name				VARCHAR(64)	NOT NULL,
    Gender				CHAR(1)		NOT NULL,
    --RelationWithAdmin	VARCHAR(64),
	--Email				VARCHAR(64),
    PRIMARY KEY (ID_FM),
	Check (Gender='F' OR Gender='M')
	--Check (Email like '%@%.%')
);
Alter TABLE FamilyMember 
	ADD RelationWithAdmin VARCHAR(64);

CREATE TABLE FormatOfFunds(
    ID_FF		INT			NOT NULL IDENTITY(1,1),
    FormatName	VARCHAR(64)	NOT NULL,
    PRIMARY KEY (ID_FF)
);


CREATE TABLE PaymentObject(
    ID_PO		INT			NOT NULL IDENTITY(1,1),
    ObjectName	VARCHAR(64) NOT NULL,
    PRIMARY KEY (ID_PO)
);
	

CREATE TABLE PersonalFunds(
    ID_PF		INT				NOT NULL IDENTITY(1,1),
    ID_FM		INT				NOT NULL FOREIGN KEY references FamilyMember(ID_FM),
    ID_FF		INT				NOT NULL FOREIGN KEY references FormatOfFunds(ID_FF),
    Balance		DECIMAL(16,2)	NOT NULL,
    AccountNum  VARCHAR(64),
    PRIMARY KEY (ID_PF)
);


CREATE TABLE TypeOfExpenditure(
    ID_TE		INT			NOT NULL IDENTITY(1,1),
    TypeName	VARCHAR(64) NOT NULL,
    PRIMARY KEY (ID_TE)
);


CREATE TABLE TypeOfIncome(
    ID_TI		INT			NOT NULL IDENTITY(1,1),
    TypeName	VARCHAR(64) NOT NULL,
    PRIMARY KEY (ID_TI)
);


CREATE TABLE InternalTransfer(
    ID_InTran	INT				NOT NULL IDENTITY(1,1),
    ID_PF_From	INT				NOT NULL FOREIGN KEY references PersonalFunds(ID_PF),
    ID_PF_To	INT				NOT NULL FOREIGN KEY references PersonalFunds(ID_PF),
    IT_Time		DATETIME		NOT NULL,
    Amount		DECIMAL(16,2)	NOT NULL,
    PRIMARY KEY (ID_InTran)
);


CREATE TABLE Expenditure(
    ID_EX		INT				NOT NULL	IDENTITY(1,1),
    E_Time		DATETIME		NOT NULL,
    ID_PF		INT				NOT NULL	FOREIGN KEY references PersonalFunds(ID_PF) ON DELETE CASCADE,
    ID_TE		INT				NOT NULL	FOREIGN KEY references TypeOfExpenditure(ID_TE) ON DELETE CASCADE,
    ExAmount	DECIMAL(16,2)	NOT NULL,
    ID_PO		INT							FOREIGN KEY references PaymentObject(ID_PO) ON DELETE SET NULL,
    PRIMARY KEY (ID_EX)
);


CREATE TABLE Income(
    ID_IN		INT				NOT NULL IDENTITY(1,1),
    I_Time		DATETIME		NOT NULL,
    ID_PF		INT				NOT NULL FOREIGN KEY references PersonalFunds(ID_PF) ON DELETE CASCADE,
    ID_TI		INT				NOT NULL FOREIGN KEY references TypeOfIncome(ID_TI) ON DELETE CASCADE,
    InAmount	DECIMAL(16,2)	NOT NULL,
    PRIMARY KEY (ID_IN)
);


CREATE TABLE Budget(
    ID_FM		INT				NOT NULL FOREIGN KEY references FamilyMember(ID_FM) ON DELETE CASCADE,
    ID_TE		INT				NOT NULL FOREIGN KEY references TypeOfExpenditure(ID_TE) ON DELETE CASCADE,
    BudAmount	DECIMAL(16,2)	NOT NULL,
    Time_month	INT				NOT NULL,
    PRIMARY KEY (ID_FM,ID_TE)
);

CREATE TABLE NewBudget(
    ID_FM		INT				NOT NULL,
    ID_TE		INT				NOT NULL,
    PRIMARY KEY (ID_FM,ID_TE),
	FOREIGN KEY (ID_FM,ID_TE) references Budget(ID_FM,ID_TE)
);


CREATE TABLE Debt(
    ID_Debt		INT				NOT NULL IDENTITY(1,1),
    Creditor	VARCHAR(64)		NOT NULL,
    ID_FM		INT				NOT NULL FOREIGN KEY references FamilyMember(ID_FM) ON DELETE CASCADE,
    BalanceDue	DECIMAL(16,2)	NOT NULL,
    Comment		VARCHAR(900),
    PRIMARY KEY (ID_Debt)
);


CREATE TABLE Loan(
    ID_Loan		INT			    NOT NULL IDENTITY(1,1),
    ID_Debt		INT			    NOT NULL FOREIGN KEY references Debt(ID_Debt) ON DELETE CASCADE,
    ID_PF		INT			    NOT NULL FOREIGN KEY references PersonalFunds(ID_PF) ON DELETE CASCADE,
    L_Time		DATETIME	    NOT NULL,
    LoanAmount  DECIMAL(16,2)	NOT NULL,
    PRIMARY KEY (ID_Loan)
);


CREATE TABLE Repayment(
    ID_Repay	INT				NOT NULL IDENTITY(1,1),
    ID_Debt		INT				NOT NULL FOREIGN KEY references Debt(ID_Debt) ON DELETE CASCADE,
    ID_PF		INT				NOT NULL FOREIGN KEY references PersonalFunds(ID_PF) ON DELETE CASCADE,
    R_Time		DATETIME		NOT NULL,
    RepayAmount DECIMAL(16,2)	NOT NULL,
    PRIMARY KEY (ID_Repay)
);


CREATE TABLE Credit(
    ID_Credit	INT				NOT NULL IDENTITY(1,1),
    ID_FM		INT				NOT NULL FOREIGN KEY references FamilyMember(ID_FM) ON DELETE CASCADE,
    ID_TE		INT				NOT NULL FOREIGN KEY references TypeOfExpenditure(ID_TE) ON DELETE CASCADE,
    C_Time		DATETIME		NOT NULL,
    BalanceDue	DECIMAL(16,2)	NOT NULL,
    Comment VARCHAR(900),
    PRIMARY KEY (ID_Credit)
);


CREATE TABLE Debit(
    ID_EX			INT				NOT NULL FOREIGN KEY references Expenditure(ID_EX) ON DELETE CASCADE,
    --D_Time		DATETIME		NOT NULL,
    --DebitAmount	DECIMAL(16,2)	NOT NULL,
	ID_Credit		INT				NOT NULL FOREIGN KEY references Credit(ID_Credit),
    PRIMARY KEY (ID_EX)
);