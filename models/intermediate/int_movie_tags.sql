{{ config(
    materialized='view',
    tags=['intermediate','analytics','tags'],
    meta={
      "owner":"Harsh Soni",
      "team":"Analytics Engineering",
      "source_system":"MovieLens"
    }
) }}

WITH tags AS (

    SELECT *

    FROM {{ ref('stg_tags') }}

),

tag_frequency AS (

    SELECT

        movie_id,

        tag,

        COUNT(*) AS tag_frequency

    FROM tags

    GROUP BY movie_id,tag

),

ranked_tags AS (

    SELECT

        *,

        ROW_NUMBER() OVER(

            PARTITION BY movie_id

            ORDER BY tag_frequency DESC,
                     tag

        ) rn

    FROM tag_frequency

)

SELECT

    t.movie_id,

    COUNT(*) AS total_tags,

    COUNT(DISTINCT t.tag) AS unique_tags,

    MAX(

        CASE

            WHEN r.rn=1

            THEN r.tag

        END

    ) AS most_common_tag,

    MAX(

        CASE

            WHEN r.rn=1

            THEN r.tag_frequency

        END

    ) AS most_common_tag_frequency

FROM tags t

LEFT JOIN ranked_tags r

ON t.movie_id=r.movie_id

GROUP BY t.movie_id