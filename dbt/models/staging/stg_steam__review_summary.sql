-- Resumen de reseñas por juego, con el ratio positivo ya calculado.

with source as (

    select * from {{ source('bronze', 'steam_review_summary') }}

),

renamed as (

    select
        cast(appid as bigint)           as appid,
        cast(review_score as int)       as review_score,
        review_score_desc,
        cast(total_positive as bigint)  as total_positive,
        cast(total_negative as bigint)  as total_negative,
        cast(total_reviews as bigint)   as total_reviews,
        cast(_ingested_at as timestamp) as ingested_at

    from source
    where appid is not null

),

latest as (

    select *
    from renamed
    qualify row_number() over (
        partition by appid
        order by ingested_at desc
    ) = 1

)

select
    appid,
    review_score,
    review_score_desc,
    total_positive,
    total_negative,
    total_reviews,
    case
        when total_reviews > 0
            then round(total_positive * 100.0 / total_reviews, 2)
    end as positive_ratio,
    ingested_at as reviews_updated_at

from latest
