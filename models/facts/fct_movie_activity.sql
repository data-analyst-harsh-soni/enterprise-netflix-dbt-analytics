{{ config(

    materialized='incremental',

    unique_key='movie_activity_sk',

    incremental_strategy='merge',

    on_schema_change='sync_all_columns',

    tags=['fact','analytics','activity'],

    meta={
        "owner":"Harsh Soni",
        "team":"Analytics Engineering",
        "domain":"Movie Analytics",
        "source_system":"MovieLens",
        "criticality":"High"
    }

) }}

WITH ratings AS (

    SELECT *

    FROM {{ ref('stg_ratings') }}

),

genome_scores AS (

    SELECT *

    FROM {{ ref('stg_genome_scores') }}

),

movies AS (

    SELECT

        movie_sk,
        movie_id

    FROM {{ ref('dim_movies') }}

),

rating_summary AS (

    SELECT

        movie_id,

        COUNT(*) AS total_ratings,

        AVG(rating) AS average_rating,

        MIN(rating) AS minimum_rating,

        MAX(rating) AS maximum_rating,

        MAX(rating_timestamp) AS last_rating_timestamp

    FROM ratings

    GROUP BY movie_id

),

genome_summary AS (

    SELECT

        movie_id,

        COUNT(*) AS total_genome_tags,

        AVG(relevance) AS average_relevance_score

    FROM genome_scores

    GROUP BY movie_id

),

final AS (

    SELECT

        {{ dbt_utils.generate_surrogate_key(['m.movie_id']) }}
        AS movie_activity_sk,

        m.movie_sk,

        m.movie_id,

        COALESCE(r.total_ratings,0) AS total_ratings,

        ROUND(COALESCE(r.average_rating,0),2) AS average_rating,

        COALESCE(r.minimum_rating,0) AS minimum_rating,

        COALESCE(r.maximum_rating,0) AS maximum_rating,

        r.last_rating_timestamp,

        COALESCE(g.total_genome_tags,0) AS total_genome_tags,

        ROUND(COALESCE(g.average_relevance_score,0),4)
            AS average_relevance_score,

        CURRENT_TIMESTAMP() AS record_created_at,

        CURRENT_TIMESTAMP() AS record_updated_at,

        'MovieLens' AS source_system

    FROM movies m

    LEFT JOIN rating_summary r

        ON m.movie_id = r.movie_id

    LEFT JOIN genome_summary g

        ON m.movie_id = g.movie_id

)

SELECT *

FROM final

{% if is_incremental() %}

WHERE movie_activity_sk NOT IN (

    SELECT movie_activity_sk

    FROM {{ this }}

)

{% endif %}