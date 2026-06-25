{{ config(materialized = 'table') }}

WITH fct_ratings AS (
    SELECT * FROM {{ ref('fct_ratings') }}
),
seed_dates AS (
    SELECT * FROM {{ ref('seed_movie_release_dates') }}
)

SELECT 
    f.*,
    CASE
        WHEN d.release_date IS NULL THEN 'unknown'
        ELSE 'known'
    END AS release_info_available
FROM fct_ratings f
LEFT JOIN seed_dates d
ON f.movie_id = d.movie_id