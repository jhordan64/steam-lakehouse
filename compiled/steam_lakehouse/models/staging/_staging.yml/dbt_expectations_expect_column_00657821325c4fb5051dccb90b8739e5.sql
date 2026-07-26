






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and positive_ratio >= 0 and positive_ratio <= 100
)
 as expression


    from `steam_lakehouse`.`dbt_dev_silver`.`stg_steam__review_summary`
    where
        positive_ratio is not null
    
    

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







