with source as (
    select * from {{ ref('raw_plans') }}
),

renamed as (
    select
        plan_id,
        plan_name,
        upper(plan_type)                           as plan_type,
        cast(deductible_individual  as decimal(18,2)) as deductible_individual,
        cast(deductible_family      as decimal(18,2)) as deductible_family,
        cast(oop_max_individual     as decimal(18,2)) as oop_max_individual,
        cast(oop_max_family         as decimal(18,2)) as oop_max_family,
        cast(premium_individual     as decimal(18,2)) as premium_individual,
        cast(premium_family         as decimal(18,2)) as premium_family,
        cast(copay_pcp              as decimal(18,2)) as copay_pcp,
        cast(copay_specialist       as decimal(18,2)) as copay_specialist,
        cast(coinsurance_pct        as integer)       as coinsurance_pct,
        cast(effective_date         as date)          as effective_date,
        cast(termination_date       as date)          as termination_date
    from source
)

select * from renamed

