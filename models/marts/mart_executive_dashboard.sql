{{ config(

    materialized='table',

    tags=['mart','business','executive'],

    meta={
        "owner":"Harsh Soni",
        "team":"Analytics Engineering",
        "consumer":"Power BI"
    }

) }}


WITH movie_summary AS (

    SELECT

        COUNT(*) AS total_movies,

        COUNT(DISTINCT genres) AS total_genres,

        COUNT(DISTINCT release_year) AS release_years

    FROM {{ ref('dim_movies') }}

),

user_summary AS (

    SELECT

        COUNT(*) AS total_users

    FROM {{ ref('dim_users') }}

),

rating_summary AS (

    SELECT

        COUNT(*) AS total_ratings,

        ROUND(AVG(rating),2) AS average_rating,

        MIN(rating) AS minimum_rating,

        MAX(rating) AS maximum_rating

    FROM {{ ref('fct_ratings') }}

),

activity_summary AS (

    SELECT

        SUM(total_genome_tags) AS total_genome_tags,

        ROUND(AVG(average_relevance_score),4) AS average_relevance_score

    FROM {{ ref('fct_movie_activity') }}

),

final AS (

    SELECT

        ms.total_movies,

        ms.total_genres,

        ms.release_years,

        us.total_users,

        rs.total_ratings,

        rs.average_rating,

        rs.minimum_rating,

        rs.maximum_rating,

        ac.total_genome_tags,

        ac.average_relevance_score,

        CURRENT_TIMESTAMP() AS record_created_at,

        CURRENT_TIMESTAMP() AS record_updated_at,

        'MovieLens' AS source_system

    FROM movie_summary ms

    CROSS JOIN user_summary us

    CROSS JOIN rating_summary rs

    CROSS JOIN activity_summary ac

)

SELECT *

FROM final