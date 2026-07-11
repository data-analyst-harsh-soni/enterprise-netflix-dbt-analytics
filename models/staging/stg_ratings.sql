{{ config(

    materialized='view',

    tags=['staging','ratings','analytics'],

    meta={
        "owner":"Harsh Soni",
        "team":"Analytics Engineering",
        "domain":"Movie Analytics",
        "source_system":"MovieLens",
        "layer":"Staging",
        "criticality":"High"
    }

) }}

WITH raw_ratings AS (

    SELECT *

    FROM {{ source('netflix_raw', 'RAW_RATINGS') }}

),

final AS (

    SELECT

        userId AS user_id,

        movieId AS movie_id,

        
        rating,

        TO_TIMESTAMP_LTZ(timestamp) AS rating_timestamp

    FROM raw_ratings

)

SELECT *

FROM final