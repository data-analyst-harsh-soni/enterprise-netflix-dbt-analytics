{{ config(materialized = 'table') }}

WITH raw_ratings AS (
  SELECT * FROM NETFLIX.RAW.RAW_RATINGS
)

SELECT
  userId AS user_id,
  movieId AS movie_id,
  rating,
  TO_TIMESTAMP_LTZ(timestamp) AS rating_timestamp
FROM raw_ratings