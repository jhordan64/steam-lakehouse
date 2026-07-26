






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and igdb_rating >= 0 and igdb_rating <= 100
)
 as expression


    from `steam_lakehouse`.`dbt_dev_silver`.`stg_igdb__games`
    where
        igdb_rating is not null
    
    

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







