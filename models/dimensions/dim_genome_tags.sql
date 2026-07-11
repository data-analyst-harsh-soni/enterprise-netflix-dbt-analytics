{{ config(

    materialized='table',

    tags=['dimension','analytics','genome'],

    meta={
        "owner":"Harsh Soni",
        "team":"Analytics Engineering",
        "domain":"Movie Analytics",
        "source_system":"MovieLens",
        "criticality":"High"
    }

) }}

WITH genome_tags AS (

    SELECT *

    FROM {{ ref('stg_genome_tags') }}

),

final AS (

    SELECT

        {{ dbt_utils.generate_surrogate_key(['tag_id']) }} AS tag_sk,

        tag_id,

        tag_name,

        CURRENT_TIMESTAMP() AS record_created_at,

        CURRENT_TIMESTAMP() AS record_updated_at,

        'MovieLens' AS source_system

    FROM genome_tags

)

SELECT *

FROM final