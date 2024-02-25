{{ 
    config(
        materialized="view"
    ) 
}}

with
    fhv_tripdata as (
        select
            {{
                dbt_utils.generate_surrogate_key(
                    ["dispatching_base_num", "pickup_datetime"]
                )
            }} as tripid,
            dispatching_base_num,
            -- timestamps
            cast(pickup_datetime as timestamp) as pickup_datetime,
            cast(dropoff_datetime as timestamp) as dropoff_datetime,
            -- identifier
            {{ dbt.safe_cast("PUlocationID", api.Column.translate_type("integer")) }}
            as pickup_locationid,
            {{ dbt.safe_cast("DOlocationID", api.Column.translate_type("integer")) }}
            as dropoff_locationid,
            {{ dbt.safe_cast("SR_Flag", api.Column.translate_type("integer")) }}
            as sr_flag,
            affiliated_base_number as affiliated_base_number
        from {{ source("staging", "fhv_tripdata") }}
    )
select *
from fhv_tripdata
where date(pickup_datetime) between '2019-01-01' and '2019-12-31'

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var("is_test_run", default=true) %} 

limit 100 

{% endif %}
