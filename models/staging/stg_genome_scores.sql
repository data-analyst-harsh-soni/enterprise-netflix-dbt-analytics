{{ config(

    materialized='view',

    tags=['staging','genome','analytics'],

    meta={
        "owner":"Harsh Soni",
        "team":"Analytics Engineering",
        "domain":"Movie Analytics",
        "source_system":"MovieLens",
        "layer":"Staging",
        "criticality":"High"
    }

) }}


WITH raw_genome_scores AS (

    SELECT *

    FROM {{ source('netflix_raw', 'RAW_GENOME_SCORES') }}

),

final AS (

    SELECT

        movieId AS movie_id,

        tagId AS tag_id,

        relevance

    FROM raw_genome_scores

)

SELECT *

FROM final