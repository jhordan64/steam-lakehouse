{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['appid', 'measured_at_hour'],
        partition_by=['measured_date'],
        on_schema_change='append_new_columns'
    )
}}

-- Normaliza las lecturas horarias de jugadores concurrentes.
-- La API puede devolver la misma hora dos veces si hubo un reintento,
-- por eso deduplicamos quedandonos con la lectura mas reciente.

with source as (

    select * from {{ source('bronze', 'steam_player_counts') }}

    {% if is_incremental() %}
        where _loaded_at >= (
            select coalesce(max(_loaded_at), '1900-01-01')
                   - interval {{ var('lookback_hours') }} hours
            from {{ this }}
        )
    {% endif %}

),

renamed as (

    select
        cast(appid as bigint)                       as appid,
        cast(player_count as bigint)                as player_count,
        cast(result as int)                         as api_result_code,
        cast(_ingested_at as timestamp)             as measured_at,
        date_trunc('hour', cast(_ingested_at as timestamp)) as measured_at_hour,
        cast(_ingested_at as date)                  as measured_date,
        _source_file,
        _loaded_at

    from source
    where appid is not null
      and player_count is not null
      -- result = 1 significa que Valve devolvio una lectura valida
      and result = 1

),

deduplicated as (

    select *
    from renamed
    qualify row_number() over (
        partition by appid, measured_at_hour
        order by measured_at desc
    ) = 1

)

select * from deduplicated
