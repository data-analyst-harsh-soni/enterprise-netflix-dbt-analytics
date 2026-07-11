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

WITH raw_genome_tags AS (

    SELECT *

    FROM {{ source('netflix_raw', 'RAW_GENOME_TAGS') }}

),

final AS (

    SELECT

        tagId AS tag_id,

        tag AS tag_name

    FROM raw_genome_tags

)

SELECT *

FROM final