SET LANGUAGE English;
SET DATEFIRST 1; -- Monday = 1

DECLARE @FechaInicio DATE = '2005-01-01';
DECLARE @FechaFin    DATE = '2030-12-31';

;WITH Fecha AS (
    
    -- Fecha inicial
    SELECT @FechaInicio AS Fecha

    UNION ALL

    -- Incremento de 1 día
    SELECT DATEADD(DAY, 1, Fecha)
    FROM Fecha
    WHERE Fecha < @FechaFin
)

INSERT INTO Dim_Time (
    TIME_KEY,
    DATE_VALUE,
    [YEAR],
    [MONTH],
    [DAY],
    [MONTH_NAME],
    [DAY_NAME],
    [QUARTER],
    [DAY_WEEK],
    [IS_WEEKEND]
)

SELECT
    -- Clave tipo YYYYMMDD
    CONVERT(INT, CONVERT(VARCHAR(8), Fecha, 112)) AS TIME_KEY,

    -- Fecha completa
    Fecha AS DATE_VALUE,

    -- Componentes temporales
    YEAR(Fecha) AS [YEAR],
    MONTH(Fecha) AS [MONTH],
    DAY(Fecha) AS [DAY],

    -- Nombres en inglés
    DATENAME(MONTH, Fecha) AS [MONTH_NAME],
    DATENAME(WEEKDAY, Fecha) AS [DAY_NAME],

    -- Trimestre
    DATEPART(QUARTER, Fecha) AS [QUARTER],

    -- Lunes = 1
    DATEPART(WEEKDAY, Fecha) AS [DAY_WEEK],

    -- Sábado(6) o Domingo(7)
    CASE
        WHEN DATEPART(WEEKDAY, Fecha) IN (6,7) THEN 1
        ELSE 0
    END AS [IS_WEEKEND]

FROM Fecha

WHERE NOT EXISTS (
    SELECT 1
    FROM Dim_Time T
    WHERE T.TIME_KEY = CONVERT(INT, CONVERT(VARCHAR(8), Fecha, 112))
)

OPTION (MAXRECURSION 0);