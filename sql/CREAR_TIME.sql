IF OBJECT_ID('dbo.dim_Time', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.dim_Time (
        TIME_KEY      INT PRIMARY KEY,
        DATE_VALUE    DATE NOT NULL,
        [YEAR]        INT,
        [MONTH]       INT,
        [DAY]         INT,
        MONTH_NAME    NVARCHAR(20),
        DAY_NAME      NVARCHAR(20),
        [QUARTER]     INT,
        DAY_WEEK      INT,
        IS_WEEKEND    BIT
    );
END