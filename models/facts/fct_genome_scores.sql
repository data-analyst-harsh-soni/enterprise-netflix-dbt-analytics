{{ config(

    materialized='incremental',

    unique_key='genome_score_sk',

    incremental_strategy='merge',

    on_schema_change='sync_all_columns',

    tags=['fact','analytics','genome'],

    meta={
        "owner":"Harsh Soni",
        "team":"Analytics Engineering",
        "domain":"Movie Analytics",
        "source_system":"MovieLens",
        "criticality":"High"
    }

) }}

WITH genome_scores AS (

    SELECT *

    FROM {{ ref('stg_genome_scores') }}

),

movies AS (

    SELECT

        movie_sk,
        movie_id

    FROM {{ ref('dim_movies') }}

),

tags AS (

    SELECT

        tag_sk,
        tag_id

    FROM {{ ref('dim_genome_tags') }}

),

final AS (

    SELECT

        {{ dbt_utils.generate_surrogate_key([
            'g.movie_id',
            'g.tag_id'
        ]) }} AS genome_score_sk,

        m.movie_sk,

        t.tag_sk,
        g.movie_id,

        g.tag_id,

        g.relevance,

        CASE

            WHEN g.relevance >= 0.80
                THEN 'High'

            WHEN g.relevance >= 0.50
                THEN 'Medium'

            ELSE 'Low'

        END AS relevance_bucket,

        CURRENT_TIMESTAMP() AS record_created_at,

        CURRENT_TIMESTAMP() AS record_updated_at,

        'MovieLens' AS source_system

    FROM genome_scores g

    LEFT JOIN movies m

        ON g.movie_id = m.movie_id

    LEFT JOIN tags t

        ON g.tag_id = t.tag_id

)

SELECT *

FROM final

{% if is_incremental() %}

WHERE genome_score_sk NOT IN (

    SELECT genome_score_sk

    FROM {{ this }}

)

{% endif %}