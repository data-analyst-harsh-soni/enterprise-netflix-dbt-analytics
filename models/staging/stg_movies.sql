WITH raw_movies AS (

    SELECT *
    FROM {{ source('netflix_raw', 'RAW_MOVIES') }}

)

SELECT
    MOVIEID AS movie_id,
    TITLE AS title,
    GENRES AS genres

FROM raw_movies

