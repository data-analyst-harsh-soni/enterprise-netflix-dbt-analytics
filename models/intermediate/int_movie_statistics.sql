{{ config(
    materialized='view',
    tags=['intermediate','analytics','statistics'],
    meta={
      "owner":"Harsh Soni",
      "team":"Analytics Engineering",
      "source_system":"MovieLens"
    }
) }}

WITH ratings AS (

    SELECT *
    FROM {{ ref('stg_ratings') }}

),

movie_stats AS (

    SELECT

        movie_id,

        COUNT(*) AS rating_count,

        ROUND(AVG(rating),2) AS average_rating,

        MIN(rating) AS min_rating,

        MAX(rating) AS max_rating,

        MAX(rating_timestamp) AS latest_rating_date,

        ROUND(
            AVG(rating) * LN(COUNT(*)+1),
            2
        ) AS popularity_score

    FROM ratings

    GROUP BY movie_id

)

SELECT *

FROM movie_stats