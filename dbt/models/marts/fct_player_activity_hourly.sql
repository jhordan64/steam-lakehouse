{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['game_key', 'measured_at_hour'],
        partition_by=['measured_date'],
        on_schema_change='append_new_columns'
    )
}}

-- Tabla de hechos principal. Grano: un juego por hora.
-- Incluye ventanas moviles para poder responder "que juego esta creciendo"
-- sin recalcular nada en la capa de BI.

with player_counts as (

    select * from {{ ref('stg_steam__player_counts') }}

    {% if is_incremental() %}
        where measured_at_hour >= (
            select coalesce(max(measured_at_hour), '1900-01-01')
                   - interval {{ var('lookback_hours') }} hours
            from {{ this }}
        )
    {% endif %}

),

games as (

    select game_key, appid from {{ ref('dim_game') }}

),

enriched as (

    select
        games.game_key,
        player_counts.appid,
        player_counts.measured_at_hour,
        player_counts.measured_date,
        hour(player_counts.measured_at_hour)      as hour_of_day,
        dayofweek(player_counts.measured_at_hour) as day_of_week,
        player_counts.player_count,

        lag(player_counts.player_count) over (
            partition by player_counts.appid
            order by player_counts.measured_at_hour
        ) as player_count_prev_hour,

        avg(player_counts.player_count) over (
            partition by player_counts.appid
            order by player_counts.measured_at_hour
            rows between 23 preceding and current row
        ) as player_count_ma_24h

    from player_counts
    inner join games on player_counts.appid = games.appid

)

select
    game_key,
    appid,
    measured_at_hour,
    measured_date,
    hour_of_day,
    day_of_week,
    player_count,
    player_count_prev_hour,
    player_count - player_count_prev_hour as player_delta_hour,
    round(player_count_ma_24h, 2)         as player_count_ma_24h,

    case
        when player_count_prev_hour is null or player_count_prev_hour = 0 then null
        else round(
            (player_count - player_count_prev_hour) * 100.0 / player_count_prev_hour, 2
        )
    end as player_growth_pct_hour

from enriched
