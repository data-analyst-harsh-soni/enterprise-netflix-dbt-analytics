{{ config(

    materialized='table',

    tags=['mart','business','movie'],

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

final AS (

    SELECT

        m.movie_sk,

        m.movie_id,

        m.title,

        m.genres,

        m.release_year,

        COALESCE(a.total_ratings,0) AS total_ratings,

        ROUND(COALESCE(a.average_rating,0),2) AS average_rating,

        COALESCE(a.minimum_rating,0) AS minimum_rating,

        COALESCE(a.maximum_rating,0) AS maximum_rating,

        a.last_rating_timestamp,

        COALESCE(a.total_genome_tags,0) AS total_genome_tags,

        ROUND(COALESCE(a.average_relevance_score,0),4)
            AS average_relevance_score,

        CASE

            WHEN COALESCE(a.average_rating,0) >= 4.5
                THEN 'Excellent'

            WHEN COALESCE(a.average_rating,0) >= 4.0
                THEN 'Very Good'

            WHEN COALESCE(a.average_rating,0) >= 3.5
                THEN 'Good'

            WHEN COALESCE(a.average_rating,0) >= 3.0
                THEN 'Average'

            ELSE 'Poor'

        END AS rating_category,

        CASE

            WHEN COALESCE(a.total_ratings,0) >= 10000
                THEN 'Blockbuster'

            WHEN COALESCE(a.total_ratings,0) >= 5000
                THEN 'Popular'

            WHEN COALESCE(a.total_ratings,0) >= 1000
                THEN 'Trending'

            ELSE 'Niche'

        END AS popularity_category,

        CURRENT_TIMESTAMP() AS record_created_at,

        CURRENT_TIMESTAMP() AS record_updated_at,

        'MovieLens' AS source_system

    FROM movies m

    LEFT JOIN activity a

        ON m.movie_sk = a.movie_sk

)

SELECT *

FROM final