{{ config(
    materialized='view',
    tags=['intermediate','analytics','links'],
    meta={
      "owner":"Harsh Soni",
      "team":"Analytics Engineering",
      "source_system":"MovieLens"
    }
) }}

SELECT

    movie_id,

    imdb_id,

    tmdb_id,

    CASE
        WHEN imdb_id IS NOT NULL THEN
            CONCAT(
                'https://www.imdb.com/title/tt',
                LPAD(imdb_id::VARCHAR,7,'0')
            )
    END AS imdb_url,

    CASE
        WHEN tmdb_id IS NOT NULL THEN
            CONCAT(
                'https://www.themoviedb.org/movie/',
                tmdb_id
            )
    END AS tmdb_url

FROM {{ ref('stg_links') }}