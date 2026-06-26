{{ config(
    materialized='table',

    tags=['dimension','analytics','users'],

    meta={
      "owner":"Harsh Soni",
      "team":"Analytics Engineering",
      "domain":"Movie Analytics",
      "source_system":"MovieLens",
      "criticality":"High"
    }
) }}

WITH users AS (

    SELECT *

    FROM {{ ref('int_user_activity') }}

),

final AS (

    SELECT

        ------------------------------------------------------------------
        -- Surrogate Key
        ------------------------------------------------------------------

        {{ dbt_utils.generate_surrogate_key(['user_id']) }} AS user_sk,

        ------------------------------------------------------------------
        -- Business Key
        ------------------------------------------------------------------

        user_id,

        ------------------------------------------------------------------
        -- User Metrics
        ------------------------------------------------------------------

        total_ratings,

        average_rating_given,

        minimum_rating_given,

        maximum_rating_given,

        total_tags,

        last_active,

        active_days,

        favorite_genre,

        ------------------------------------------------------------------
        -- Metadata
        ------------------------------------------------------------------

        CURRENT_TIMESTAMP() AS record_created_at,

        CURRENT_TIMESTAMP() AS record_updated_at,

        'MovieLens' AS source_system

    FROM users

)

SELECT *

FROM final