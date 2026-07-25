-- Metadata de IGDB aplanada y lista para unir contra Steam por appid.

with source as (

    select * from {{ source('bronze', 'igdb_games') }}

),

renamed as (

    select
        cast(steam_appid as bigint)                       as appid,
        cast(igdb_id as bigint)                           as igdb_id,
        nullif(trim(name), '')                            as game_name,
        slug                                              as igdb_slug,
        cast(from_unixtime(first_release_date) as date)   as release_date,
        cast(total_rating as double)                      as igdb_rating,
        cast(total_rating_count as bigint)                as igdb_rating_count,
        genres                                            as genres,
        developers                                        as developers,
        publishers                                        as publishers,
        cast(_ingested_at as timestamp)                   as ingested_at

    from source
    where steam_appid is not null

),

latest as (

    select *
    from renamed
    qualify row_number() over (
        partition by appid
        order by ingested_at desc
    ) = 1

)

select * from latest
