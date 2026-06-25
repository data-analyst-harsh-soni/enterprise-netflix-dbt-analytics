WITH ratings AS (
  SELECT DISTINCT user_id FROM {{ ref('fct_ratings') }}
),

tags AS (
  SELECT DISTINCT user_id FROM {{ ref('stg_tags') }}
)

SELECT DISTINCT user_id
FROM (
  SELECT * FROM ratings
  UNION
  SELECT * FROM tags
)
