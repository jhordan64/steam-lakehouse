





with validation_errors as (

    select
        game_key, measured_date
    from `steam_lakehouse`.`dbt_dev_gold`.`agg_game_daily`
    group by game_key, measured_date
    having count(*) > 1

)

select *
from validation_errors


