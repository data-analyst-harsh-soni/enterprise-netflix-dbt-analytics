{{ config(

    materialized='incremental',

    unique_key='rating_sk',

    incremental_strategy='merge',

    on_schema_change='sync_all_columns',

    tags=['fact','analytics','ratings'],

    meta={
        "owner":"Harsh Soni",
        "team":"Analytics Engineering",
        "domain":"Movie Analytics",
        "source_system":"MovieLens",
        "criticality":"High"
    }

) }}

WITH ratings AS (

    SELECT *

    FROM {{ ref('stg_ratings') }}

),

movies AS (

    SELECT
        movie_sk,
        movie_id

    FROM {{ ref('dim_movies') }}

),

users AS (

    SELECT
        user_sk,
        user_id

    FROM {{ ref('dim_users') }}

),

dates AS (

    SELECT
        date_sk,
        full_date

    FROM {{ ref('dim_date') }}

),

final AS (

    SELECT

        {{ dbt_utils.generate_surrogate_key([
            'r.user_id',
            'r.movie_id',
            'r.rating_timestamp'
        ]) }} AS rating_sk,

        m.movie_sk,

        u.user_sk,

        d.date_sk,
        r.movie_id,

        r.user_id,

        r.rating,

        r.rating_timestamp,
        YEAR(r.rating_timestamp) AS rating_year,

        MONTH(r.rating_timestamp) AS rating_month,

        DAY(r.rating_timestamp) AS rating_day,

        CASE
            WHEN DAYOFWEEK(r.rating_timestamp) IN (1,7)
            THEN TRUE
            ELSE FALSE
        END AS is_weekend_rating,

        CURRENT_TIMESTAMP() AS record_created_at,

        CURRENT_TIMESTAMP() AS record_updated_at,

        'MovieLens' AS source_system

    FROM ratings r

    LEFT JOIN movies m
        ON r.movie_id = m.movie_id

    LEFT JOIN users u
        ON r.user_id = u.user_id

    LEFT JOIN dates d
        ON CAST(r.rating_timestamp AS DATE)=d.full_date

)

SELECT *

FROM final

{% if is_incremental() %}

WHERE rating_timestamp >
(
    SELECT COALESCE(MAX(rating_timestamp),'1900-01-01')
    FROM {{ this }}
)

{% endif %}