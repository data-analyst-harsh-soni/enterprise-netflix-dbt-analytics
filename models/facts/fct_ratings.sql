{{ config(materialized='incremental') }}

SELECT
    user_id,
    movie_id,
    rating,
    rating_timestamp
FROM {{ ref('stg_ratings') }}

{% if is_incremental() %}
WHERE rating_timestamp >
(
    SELECT COALESCE(
        MAX(rating_timestamp),
        TO_TIMESTAMP_LTZ('1970-01-01 00:00:00')
    )
    FROM {{ this }}
)
{% endif %}

