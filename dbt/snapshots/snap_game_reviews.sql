{% snapshot snap_game_reviews %}

{{
    config(
        unique_key='appid',
        strategy='check',
        check_cols=['review_score', 'review_score_desc', 'total_reviews'],
        invalidate_hard_deletes=True
    )
}}

-- SCD tipo 2 sobre la reputacion de cada juego.
-- Permite responder preguntas historicas que la API no guarda:
-- "cuando paso este juego de Mixed a Mostly Positive?"

select
    appid,
    review_score,
    review_score_desc,
    total_positive,
    total_negative,
    total_reviews,
    reviews_updated_at

from {{ ref('stg_steam__review_summary') }}

{% endsnapshot %}
