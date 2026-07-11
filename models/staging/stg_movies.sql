{{ config(

    materialized='view',

    tags=['staging','movies','analytics'],

    meta={
        "owner":"Harsh Soni",
        "team":"Analytics Engineering",
        "domain":"Movie Analytics",
        "source_system":"MovieLens",
        "layer":"Staging",
        "criticality":"High"
    }

) }}
WITH raw_movies AS (

    SELECT *

    FROM {{ source('netflix_raw', 'RAW_MOVIES') }}

),

final AS (

    SELECT

        MOVIEID AS movie_id,

        TITLE AS title,

        GENRES AS genres

    FROM raw_movies

)

SELECT *

FROM final