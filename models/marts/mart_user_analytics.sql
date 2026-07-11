{{ config(

    materialized='table',

    tags=['mart','business','user'],

    meta={
        "owner":"Harsh Soni",
        "team":"Analytics Engineering",
        "consumer":"Power BI"
    }

) }}


WITH users AS (

    SELECT *

    FROM {{ ref('dim_users') }}

),

ratings AS (

    SELECT *

    FROM {{ ref('fct_ratings') }}

),

user_summary AS (

    SELECT

        user_sk,

        COUNT(*) AS total_ratings,

        COUNT(DISTINCT movie_id) AS movies_rated,

        ROUND(AVG(rating),2) AS average_rating_given,

        MIN(rating) AS minimum_rating_given,

        MAX(rating) AS maximum_rating_given,

        MIN(rating_timestamp) AS first_rating_date,

        MAX(rating_timestamp) AS last_rating_date

    FROM ratings

    GROUP BY user_sk

),

final AS (

    SELECT

    
        u.user_sk,

        u.user_id,

        COALESCE(s.total_ratings,0) AS total_ratings,

        COALESCE(s.movies_rated,0) AS movies_rated,

        COALESCE(s.average_rating_given,0) AS average_rating_given,

        COALESCE(s.minimum_rating_given,0) AS minimum_rating_given,

        COALESCE(s.maximum_rating_given,0) AS maximum_rating_given,

        s.first_rating_date,

        s.last_rating_date,

        CASE

            WHEN COALESCE(s.total_ratings,0) >= 1000
                THEN 'Power User'

            WHEN COALESCE(s.total_ratings,0) >= 500
                THEN 'Highly Active'

            WHEN COALESCE(s.total_ratings,0) >= 100
                THEN 'Active'

            WHEN COALESCE(s.total_ratings,0) >= 25
                THEN 'Occasional'

            ELSE 'New User'

        END AS engagement_segment,

        CURRENT_TIMESTAMP() AS record_created_at,

        CURRENT_TIMESTAMP() AS record_updated_at,

        'MovieLens' AS source_system

    FROM users u

    LEFT JOIN user_summary s

        ON u.user_sk = s.user_sk

)

SELECT *

FROM final