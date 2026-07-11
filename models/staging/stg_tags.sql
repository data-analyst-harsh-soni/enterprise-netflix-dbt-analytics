{{ config(

    materialized='view',

    tags=['staging','tags','analytics'],

    meta={
        "owner":"Harsh Soni",
        "team":"Analytics Engineering",
        "domain":"Movie Analytics",
        "source_system":"MovieLens",
        "layer":"Staging",
        "criticality":"High"
    }

) }}

WITH raw_tags AS (

    SELECT *

    FROM {{ source('netflix_raw', 'RAW_TAGS') }}

),

final AS (

    SELECT

        userId AS user_id,

        movieId AS movie_id,

        tag,

        TO_TIMESTAMP_LTZ(timestamp) AS tag_timestamp

    FROM raw_tags

)

SELECT *

FROM final