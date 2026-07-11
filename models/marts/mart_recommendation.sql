{{ config(

    materialized='table',

    tags=['mart','business','recommendation'],

    meta={
        "owner":"Harsh Soni",
        "team":"Analytics Engineering",
        "consumer":"Power BI"
    }

) }}



WITH movies AS (

    SELECT *

    FROM {{ ref('dim_movies') }}

),

activity AS (

    SELECT *

    FROM {{ ref('fct_movie_activity') }}

),

recommendation_base AS (

    SELECT

        m.movie_sk,

        m.movie_id,

        m.title,

        m.genres,

        m.release_year,

        COALESCE(a.total_ratings,0) AS total_ratings,

        COALESCE(a.average_rating,0) AS average_rating,

        COALESCE(a.total_genome_tags,0) AS total_genome_tags,

        COALESCE(a.average_relevance_score,0) AS average_relevance_score,

        a.last_rating_timestamp

    FROM movies m

    LEFT JOIN activity a

        ON m.movie_sk = a.movie_sk

),

final AS (

    SELECT

        
        movie_sk,
        movie_id,
        title,

        genres,

        release_year,
        total_ratings,

        ROUND(average_rating,2) AS average_rating,

        total_genome_tags,

        ROUND(average_relevance_score,4) AS average_relevance_score,

        last_rating_timestamp,

        ROUND(

            (
                average_rating * 0.60
            ) +

            (
                LEAST(total_ratings,10000) / 10000 * 0.25
            ) +

            (
                average_relevance_score * 0.15
            )

        ,4) AS recommendation_score,

        CASE

            WHEN average_rating >= 4.5
                 AND total_ratings >= 1000
                THEN 'Must Watch'

            WHEN average_rating >= 4.0
                THEN 'Highly Recommended'

            WHEN average_rating >= 3.5
                THEN 'Recommended'

            WHEN average_rating >= 3.0
                THEN 'Average'

            ELSE 'Low Priority'

        END AS recommendation_category,

        CURRENT_TIMESTAMP() AS record_created_at,

        CURRENT_TIMESTAMP() AS record_updated_at,

        'MovieLens' AS source_system

    FROM recommendation_base

)

SELECT *

FROM final