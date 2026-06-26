{{ config(
    materialized='view',
    tags=['intermediate','analytics','users'],
    meta={
      "owner":"Harsh Soni",
      "team":"Analytics Engineering",
      "source_system":"MovieLens"
    }
) }}

WITH ratings AS (

    SELECT *
    FROM {{ ref('stg_ratings') }}

),

tags AS (

    SELECT *
    FROM {{ ref('stg_tags') }}

),

genre_activity AS (

    SELECT

        r.user_id,

        m.genres,

        COUNT(*) AS genre_count,

        ROW_NUMBER() OVER(

            PARTITION BY r.user_id

            ORDER BY COUNT(*) DESC

        ) AS rn

    FROM ratings r

    JOIN {{ ref('dim_movies') }} m

        ON r.movie_id = m.movie_id

    GROUP BY
        r.user_id,
        m.genres

),

user_tags AS (

    SELECT

        user_id,

        COUNT(*) AS total_tags

    FROM tags

    GROUP BY user_id

)

SELECT

    r.user_id,

    COUNT(*) AS total_ratings,

    ROUND(AVG(r.rating),2) AS average_rating_given,

    MIN(r.rating) AS minimum_rating_given,

    MAX(r.rating) AS maximum_rating_given,

    COALESCE(MAX(ut.total_tags),0) AS total_tags,

    MAX(r.rating_timestamp) AS last_active,

    DATEDIFF(
        day,
        MIN(r.rating_timestamp),
        MAX(r.rating_timestamp)
    ) AS active_days,

    MAX(
        CASE
            WHEN ga.rn=1
            THEN ga.genres
        END
    ) AS favorite_genre

FROM ratings r

LEFT JOIN user_tags ut

    ON r.user_id=ut.user_id

LEFT JOIN genre_activity ga

    ON r.user_id=ga.user_id

GROUP BY
    r.user_id