WITH raw_movies AS (
    SELECT * FROM {{ source('netflix', 'r_movies') }}
)
SELECT 
    movieId AS movie_id,
    title,
    genres
FROM raw_movies