{{ config(

    materialized='table',

    tags=['mart','business','genre'],

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

genre_base AS (

    SELECT

        m.movie_sk,

        m.movie_id,

        m.title,

        m.genres,

        m.release_year,

        a.total_ratings,

        a.average_rating,

        a.minimum_rating,

        a.maximum_rating,

        a.total_genome_tags,

        a.average_relevance_score

    FROM movies m

    LEFT JOIN activity a

        ON m.movie_sk = a.movie_sk

),

final AS (

    SELECT

        
        genres,

        COUNT(movie_id) AS total_movies,

        MIN(release_year) AS first_release_year,

        MAX(release_year) AS latest_release_year,

        SUM(COALESCE(total_ratings,0)) AS total_ratings,

        ROUND(AVG(COALESCE(average_rating,0)),2) AS average_rating,

        MIN(COALESCE(minimum_rating,0)) AS minimum_rating,

        MAX(COALESCE(maximum_rating,0)) AS maximum_rating,

        SUM(COALESCE(total_genome_tags,0)) AS total_genome_tags,

        ROUND(AVG(COALESCE(average_relevance_score,0)),4)
            AS average_relevance_score,

        CASE

            WHEN AVG(COALESCE(average_rating,0)) >= 4.5
                THEN 'Excellent'

            WHEN AVG(COALESCE(average_rating,0)) >= 4.0
                THEN 'Very Good'

            WHEN AVG(COALESCE(average_rating,0)) >= 3.5
                THEN 'Good'

            WHEN AVG(COALESCE(average_rating,0)) >= 3.0
                THEN 'Average'

            ELSE 'Poor'

        END AS genre_rating_category,

        CURRENT_TIMESTAMP() AS record_created_at,

        CURRENT_TIMESTAMP() AS record_updated_at,

        'MovieLens' AS source_system

    FROM genre_base

    GROUP BY genres

)

SELECT *

FROM final