{{ config(
    materialized='view',
    tags=['intermediate','analytics','genre'],
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

movies AS (

    SELECT *
    FROM {{ ref('dim_movies') }}

),

joined AS (

    SELECT

        r.movie_id,

        m.genres,

        r.rating

    FROM ratings r

    JOIN movies m

        ON r.movie_id = m.movie_id

)

SELECT

    genres,

    COUNT(DISTINCT movie_id) AS total_movies,

    COUNT(*) AS total_ratings,

    ROUND(AVG(rating),2) AS average_rating,

    MIN(rating) AS minimum_rating,

    MAX(rating) AS maximum_rating

FROM joined

GROUP BY genres