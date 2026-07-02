CREATE OR ALTER VIEW dbo.View_FactBilling
AS

WITH BillingWithPrice AS
(
    SELECT
        BillingData.BILLING_ID,
        BillingData.[DATE],
        BillingData.CUSTOMER_ID,
        BillingData.EMPLOYEE_ID,
        BillingData.PRODUCT_ID,
        BillingData.QUANTITY,
        BillingData.REGION,

        PriceData.PRICE AS UNIT_PRICE,

        CASE
            WHEN PriceData.PRICE IS NULL THEN 1
            ELSE 0
        END AS PRICE_NOT_FOUND,

        BillingData.QUANTITY * PriceData.PRICE AS SUBTOTAL

    FROM
    (
        SELECT
            BILLING_ID,
            [DATE],
            CUSTOMER_ID,
            EMPLOYEE_ID,
            PRODUCT_ID,
            QUANTITY,
            REGION
        FROM Stg_Billing

        UNION ALL

        SELECT
            billing_id,
            [date],
            customer_id,
            employee_id,
            product_id,
            quantity,
            region
        FROM Stg_BillingHist

    ) AS BillingData

    OUTER APPLY
    (
        SELECT TOP 1
            PriceData.PRICE

        FROM datawarehouse.dbo.Dim_Price AS PriceData

        WHERE PriceData.PRODUCT_ID = BillingData.PRODUCT_ID
          AND PriceData.[DATE] <= BillingData.[DATE]

        ORDER BY PriceData.[DATE] DESC

    ) AS PriceData
),


BillingWithTotal AS
(
    SELECT
        BillingWithPrice.*,

        SUM(SUBTOTAL) OVER
        (
            PARTITION BY BILLING_ID
        ) AS TOTAL_BILLING

    FROM BillingWithPrice
)


SELECT
    BillingTotalData.BILLING_ID,
    BillingTotalData.[DATE],
    BillingTotalData.CUSTOMER_ID,
    BillingTotalData.EMPLOYEE_ID,
    BillingTotalData.PRODUCT_ID,
    BillingTotalData.QUANTITY,
    BillingTotalData.REGION,

    BillingTotalData.UNIT_PRICE,
    BillingTotalData.PRICE_NOT_FOUND,

    BillingTotalData.SUBTOTAL,
    BillingTotalData.TOTAL_BILLING,

    DiscountData.PERCENTAGE AS DISCOUNT,

    CASE
        WHEN DiscountData.PERCENTAGE IS NULL THEN NULL

        ELSE
            BillingTotalData.TOTAL_BILLING
            -
            (
                BillingTotalData.TOTAL_BILLING
                * DiscountData.PERCENTAGE / 100.0
            )

    END AS TOTAL_DISCOUNTED


FROM BillingWithTotal AS BillingTotalData


OUTER APPLY
(
    SELECT TOP 1
        DiscountData.PERCENTAGE

    FROM datawarehouse.dbo.Dim_Discounts AS DiscountData

    WHERE BillingTotalData.[DATE] >= DiscountData.DATE_FROM

      AND
      (
          DiscountData.DATE_UNTIL IS NULL
          OR BillingTotalData.[DATE] <= DiscountData.DATE_UNTIL
      )

      AND BillingTotalData.TOTAL_BILLING >= DiscountData.TOTAL_BILLING

    ORDER BY DiscountData.TOTAL_BILLING DESC

) AS DiscountData;