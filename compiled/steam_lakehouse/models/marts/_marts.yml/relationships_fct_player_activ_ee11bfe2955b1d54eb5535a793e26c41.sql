
    
    

with child as (
    select game_key as from_field
    from `steam_lakehouse`.`dbt_dev_gold`.`fct_player_activity_hourly`
    where game_key is not null
),

parent as (
    select game_key as to_field
    from `steam_lakehouse`.`dbt_dev_gold`.`dim_game`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


