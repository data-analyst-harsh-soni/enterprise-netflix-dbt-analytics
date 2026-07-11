{{ config(

    materialized='table',

    tags=['dimension','analytics','calendar'],

    meta={
        "owner":"Harsh Soni",
        "team":"Analytics Engineering",
        "domain":"Movie Analytics",
        "source_system":"MovieLens",
        "criticality":"High"
    }

) }}

WITH dates AS (

    SELECT DISTINCT

        CAST(rating_timestamp AS DATE) AS full_date

    FROM {{ ref('stg_ratings') }}

),

final AS (

    SELECT

        TO_NUMBER(TO_CHAR(full_date,'YYYYMMDD')) AS date_sk,

        full_date,

        YEAR(full_date) AS year,

        QUARTER(full_date) AS quarter,

        MONTH(full_date) AS month,

        MONTHNAME(full_date) AS month_name,

        WEEK(full_date) AS week_number,

        DAY(full_date) AS day_number,

        DAYNAME(full_date) AS day_name,

        DAYOFYEAR(full_date) AS day_of_year,

        CASE
            WHEN DAYOFWEEK(full_date) IN (1,7)
            THEN TRUE
            ELSE FALSE
        END AS is_weekend,

        CASE
            WHEN full_date = DATE_TRUNC('MONTH',full_date)
            THEN TRUE
            ELSE FALSE
        END AS is_month_start,

        CASE
            WHEN full_date = LAST_DAY(full_date)
            THEN TRUE
            ELSE FALSE
        END AS is_month_end,

        CASE
            WHEN full_date = DATE_TRUNC('YEAR',full_date)
            THEN TRUE
            ELSE FALSE
        END AS is_year_start,

        CASE
            WHEN full_date = LAST_DAY(full_date,'YEAR')
            THEN TRUE
            ELSE FALSE
        END AS is_year_end,

        CURRENT_TIMESTAMP() AS record_created_at,

        CURRENT_TIMESTAMP() AS record_updated_at,

        'MovieLens' AS source_system

    FROM dates

)

SELECT *

FROM final