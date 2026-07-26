






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and hours_observed >= 1 and hours_observed <= 24
)
 as expression


    from `steam_lakehouse`.`dbt_dev_gold`.`agg_game_daily`
    

),
validation_errors as (

    select
        *
    from
        grouped_expression
    where
        not(expression = true)

)

select *
from validation_errors







