{{ config(
    materialized='view',
    tags=['intermediate','analytics','genome'],
    meta={
      "owner":"Harsh Soni",
      "team":"Analytics Engineering",
      "source_system":"MovieLens"
    }
) }}

SELECT

    tag_id,

    COUNT(*) AS total_movies,

    ROUND(AVG(relevance),4) AS average_relevance,

    MIN(relevance) AS minimum_relevance,

    MAX(relevance) AS maximum_relevance

FROM {{ ref('fct_genome_scores') }}

GROUP BY tag_id