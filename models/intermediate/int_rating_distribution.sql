{{ config(
    materialized='view',
    tags=['intermediate','analytics','ratings'],
    meta={
      "owner":"Harsh Soni",
      "team":"Analytics Engineering",
      "source_system":"MovieLens"
    }
) }}

WITH rating_distribution AS (

    SELECT
        rating,
        COUNT(*) AS rating_count

    FROM {{ ref('stg_ratings') }}

    GROUP BY rating

)

SELECT

    rating,

    rating_count,

    ROUND(
        rating_count * 100.0 /
        SUM(rating_count) OVER (),
        2
    ) AS percentage,

    SUM(rating_count) OVER (
        ORDER BY rating
    ) AS cumulative_rating_count,

    ROUND(
        SUM(rating_count) OVER (
            ORDER BY rating
        ) * 100.0 /
        SUM(rating_count) OVER (),
        2
    ) AS cumulative_percentage

FROM rating_distribution

ORDER BY rating