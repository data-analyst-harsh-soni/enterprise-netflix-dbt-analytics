{{ config(

    materialized='view',

    tags=['staging','links','analytics'],

    meta={
        "owner":"Harsh Soni",
        "team":"Analytics Engineering",
        "domain":"Movie Analytics",
        "source_system":"MovieLens",
        "layer":"Staging",
        "criticality":"Medium"
    }

) }}

WITH raw_links AS (

    SELECT *

    FROM {{ source('netflix_raw', 'RAW_LINKS') }}

),

final AS (

    SELECT

        movieId AS movie_id,

        imdbId AS imdb_id,

        tmdbId AS tmdb_id

    FROM raw_links

)

SELECT *

FROM final