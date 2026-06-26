{{ config(
    materialized='view',
    tags=['intermediate','analytics','engagement'],
    meta={
      "owner":"Harsh Soni",
      "team":"Analytics Engineering",
      "source_system":"MovieLens"
    }
) }}

WITH rating_stats AS (

    SELECT *

    FROM {{ ref('int_movie_statistics') }}

),

tag_stats AS (

    SELECT *

    FROM {{ ref('int_movie_tags') }}

)

SELECT

    r.movie_id,

    r.rating_count,

    r.average_rating,

    r.popularity_score,

    COALESCE(t.total_tags,0) AS total_tags,

    COALESCE(t.unique_tags,0) AS unique_tags,

    ROUND(

        r.popularity_score +

        COALESCE(t.total_tags,0) * 0.10,

        2

    ) AS engagement_score

FROM rating_stats r

LEFT JOIN tag_stats t

ON r.movie_id=t.movie_id