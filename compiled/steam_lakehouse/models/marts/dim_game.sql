-- Dimension de juego: une el catalogo oficial de Steam con la metadata de IGDB.
-- Es la unica tabla donde el negocio debe buscar "que es este juego".

with steam as (

    select * from `steam_lakehouse`.`dbt_dev_silver`.`stg_steam__apps`

),

igdb as (

    select * from `steam_lakehouse`.`dbt_dev_silver`.`stg_igdb__games`

),

reviews as (

    select * from `steam_lakehouse`.`dbt_dev_silver`.`stg_steam__review_summary`

),

joined as (

    select
        md5(cast(concat(coalesce(cast(steam.appid as string), '_dbt_utils_surrogate_key_null_')) as string)) as game_key,
        steam.appid,
        coalesce(igdb.game_name, steam.app_name)  as game_name,
        steam.app_name                            as steam_name,
        igdb.igdb_id,
        igdb.release_date,
        igdb.igdb_rating,
        igdb.igdb_rating_count,
        igdb.genres,
        igdb.developers,
        igdb.publishers,
        reviews.review_score_desc,
        reviews.total_reviews,
        reviews.positive_ratio,
        igdb.igdb_id is not null                  as has_igdb_match,
        current_timestamp()                       as dbt_updated_at

    from steam
    left join igdb   on steam.appid = igdb.appid
    left join reviews on steam.appid = reviews.appid

)

select * from joined