-- Catalogo de Steam reducido a lo util: una fila por appid con el nombre
-- mas reciente que devolvio la API.

with source as (

    select * from {{ source('bronze', 'steam_app_list') }}

),

renamed as (

    select
        cast(appid as bigint)           as appid,
        nullif(trim(name), '')          as app_name,
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
    app_name,
    ingested_at as catalog_updated_at
from latest
where app_name is not null
