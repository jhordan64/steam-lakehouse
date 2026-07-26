
  
    
        create or replace table `steam_lakehouse`.`dbt_dev`.`metadata`
      
      using delta
      
      
      
      
      
      
      
      as
      

SELECT
    '0.18.3' as dbt_pkg_version
  