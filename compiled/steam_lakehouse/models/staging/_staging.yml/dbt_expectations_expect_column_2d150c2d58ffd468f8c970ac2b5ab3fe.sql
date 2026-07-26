






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and player_count >= 0 and player_count <= 5000000
)
 as expression


    from `steam_lakehouse`.`dbt_dev_silver`.`stg_steam__player_counts`
    

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







