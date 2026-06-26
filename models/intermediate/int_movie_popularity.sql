{{ config(
    materialized='view',
    tags=['intermediate','analytics','popularity'],
    meta={
      "owner":"Harsh Soni",
      "team":"Analytics Engineering",
      "source_system":"MovieLens"
    }
) }}

WITH stats AS (

    SELECT *

    FROM {{ ref('int_movie_statistics') }}

),

global_average AS (

    SELECT

        AVG(average_rating) AS global_avg

    FROM stats

)

SELECT

    s.movie_id,

    s.rating_count,

    s.average_rating,

    s.popularity_score,

    ROUND(

        (

            (s.rating_count * s.average_rating)

            +

            (100 * g.global_avg)

        )

        /

        (s.rating_count + 100),

        2

    ) AS weighted_rating

FROM stats s

CROSS JOIN global_average g