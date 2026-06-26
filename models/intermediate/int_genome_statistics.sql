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

    ROUND(AVG(relevance_score),4) AS average_relevance,

    MIN(relevance_score) AS minimum_relevance,

    MAX(relevance_score) AS maximum_relevance

FROM {{ ref('fct_genome_scores') }}

GROUP BY tag_id