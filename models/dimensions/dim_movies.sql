{{ config(
    materialized='table',

    tags=['dimension','analytics','movies'],

    meta={
      "owner":"Harsh Soni",
      "team":"Analytics Engineering",
      "domain":"Movie Analytics",
      "source_system":"MovieLens",
      "criticality":"High"
    }
) }}

WITH movies AS (

    SELECT *

    FROM {{ ref('stg_movies') }}

),

final AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['movie_id']) }} AS movie_sk,

        movie_id,

        title,

        genres,

        TRY_TO_NUMBER(
            REGEXP_SUBSTR(
                title,
                '\\(([0-9]{4})\\)',
                1,
                1,
                'e',
                1
            )
        ) AS release_year,

        CURRENT_TIMESTAMP() AS record_created_at,

        CURRENT_TIMESTAMP() AS record_updated_at,

        'MovieLens' AS source_system

    FROM movies

)

SELECT *

FROM final