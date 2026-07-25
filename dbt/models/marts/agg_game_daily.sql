{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['game_key', 'measured_date'],
        partition_by=['measured_date']
    )
}}

-- Resumen diario listo para Power BI. Reduce ~24x el volumen que viaja al
-- dashboard, que es lo que mantiene el import rapido en el tier gratis.

with hourly as (

    select * from {{ ref('fct_player_activity_hourly') }}

    {% if is_incremental() %}
        where measured_date >= (
            select coalesce(max(measured_date), '1900-01-01') - interval 3 days
            from {{ this }}
        )
    {% endif %}

)

select
    game_key,
    appid,
    measured_date,
    count(*)                     as hours_observed,
    max(player_count)            as peak_players,
    min(player_count)            as trough_players,
    round(avg(player_count), 0)  as avg_players,
    max_by(hour_of_day, player_count) as peak_hour_utc

from hourly
group by game_key, appid, measured_date
